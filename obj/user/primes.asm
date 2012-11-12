
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
  800053:	e8 fc 16 00 00       	call   801754 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("%d ", p);
  80005a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005e:	c7 04 24 40 29 80 00 	movl   $0x802940,(%esp)
  800065:	e8 1f 02 00 00       	call   800289 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  80006a:	e8 2a 15 00 00       	call   801599 <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 20                	jns    800095 <primeproc+0x61>
		panic("fork: %e", id);
  800075:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800079:	c7 44 24 08 7c 2d 80 	movl   $0x802d7c,0x8(%esp)
  800080:	00 
  800081:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800088:	00 
  800089:	c7 04 24 44 29 80 00 	movl   $0x802944,(%esp)
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
  8000af:	e8 a0 16 00 00       	call   801754 <ipc_recv>
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
  8000d8:	e8 c3 15 00 00       	call   8016a0 <ipc_send>
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
  8000e7:	e8 ad 14 00 00       	call   801599 <fork>
  8000ec:	89 c6                	mov    %eax,%esi
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	79 20                	jns    800112 <umain+0x33>
		panic("fork: %e", id);
  8000f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f6:	c7 44 24 08 7c 2d 80 	movl   $0x802d7c,0x8(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800105:	00 
  800106:	c7 04 24 44 29 80 00 	movl   $0x802944,(%esp)
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
  800137:	e8 64 15 00 00       	call   8016a0 <ipc_send>
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
  800156:	c7 05 3c 60 80 00 00 	movl   $0x0,0x80603c
  80015d:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  800160:	e8 58 0f 00 00       	call   8010bd <sys_getenvid>
  800165:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80016d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800172:	a3 3c 60 80 00       	mov    %eax,0x80603c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800177:	85 f6                	test   %esi,%esi
  800179:	7e 07                	jle    800182 <libmain+0x3e>
		binaryname = argv[0];
  80017b:	8b 03                	mov    (%ebx),%eax
  80017d:	a3 00 60 80 00       	mov    %eax,0x806000

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
  8001a6:	e8 85 1c 00 00       	call   801e30 <close_all>
	sys_env_destroy(0);
  8001ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001b2:	e8 3a 0f 00 00       	call   8010f1 <sys_env_destroy>
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
  8001c8:	a1 40 60 80 00       	mov    0x806040,%eax
  8001cd:	85 c0                	test   %eax,%eax
  8001cf:	74 10                	je     8001e1 <_panic+0x25>
		cprintf("%s: ", argv0);
  8001d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d5:	c7 04 24 69 29 80 00 	movl   $0x802969,(%esp)
  8001dc:	e8 a8 00 00 00       	call   800289 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8001e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ef:	a1 00 60 80 00       	mov    0x806000,%eax
  8001f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f8:	c7 04 24 6e 29 80 00 	movl   $0x80296e,(%esp)
  8001ff:	e8 85 00 00 00       	call   800289 <cprintf>
	vcprintf(fmt, ap);
  800204:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800207:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020b:	8b 45 10             	mov    0x10(%ebp),%eax
  80020e:	89 04 24             	mov    %eax,(%esp)
  800211:	e8 12 00 00 00       	call   800228 <vcprintf>
	cprintf("\n");
  800216:	c7 04 24 f6 2d 80 00 	movl   $0x802df6,(%esp)
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
  80036b:	e8 30 23 00 00       	call   8026a0 <__udivdi3>
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
  8003bd:	e8 0e 24 00 00       	call   8027d0 <__umoddi3>
  8003c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003c6:	0f be 80 8a 29 80 00 	movsbl 0x80298a(%eax),%eax
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
  80049e:	ff 24 85 c0 2a 80 00 	jmp    *0x802ac0(,%eax,4)
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
  80054d:	8b 14 85 20 2c 80 00 	mov    0x802c20(,%eax,4),%edx
  800554:	85 d2                	test   %edx,%edx
  800556:	75 23                	jne    80057b <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800558:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80055c:	c7 44 24 08 9b 29 80 	movl   $0x80299b,0x8(%esp)
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
  80057f:	c7 44 24 08 aa 2e 80 	movl   $0x802eaa,0x8(%esp)
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
  8005b8:	c7 45 dc a4 29 80 00 	movl   $0x8029a4,-0x24(%ebp)
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

00800d8b <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	83 ec 0c             	sub    $0xc,%esp
  800d91:	89 1c 24             	mov    %ebx,(%esp)
  800d94:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d98:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800da1:	bf 00 00 00 00       	mov    $0x0,%edi
  800da6:	89 fa                	mov    %edi,%edx
  800da8:	89 f9                	mov    %edi,%ecx
  800daa:	89 fb                	mov    %edi,%ebx
  800dac:	89 fe                	mov    %edi,%esi
  800dae:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800db0:	8b 1c 24             	mov    (%esp),%ebx
  800db3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800db7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800dbb:	89 ec                	mov    %ebp,%esp
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    

00800dbf <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	83 ec 28             	sub    $0x28,%esp
  800dc5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dc8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dcb:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800dce:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dd6:	bf 00 00 00 00       	mov    $0x0,%edi
  800ddb:	89 f9                	mov    %edi,%ecx
  800ddd:	89 fb                	mov    %edi,%ebx
  800ddf:	89 fe                	mov    %edi,%esi
  800de1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800de3:	85 c0                	test   %eax,%eax
  800de5:	7e 28                	jle    800e0f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800deb:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800df2:	00 
  800df3:	c7 44 24 08 7f 2c 80 	movl   $0x802c7f,0x8(%esp)
  800dfa:	00 
  800dfb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e02:	00 
  800e03:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  800e0a:	e8 ad f3 ff ff       	call   8001bc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e0f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e12:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e15:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e18:	89 ec                	mov    %ebp,%esp
  800e1a:	5d                   	pop    %ebp
  800e1b:	c3                   	ret    

00800e1c <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	83 ec 0c             	sub    $0xc,%esp
  800e22:	89 1c 24             	mov    %ebx,(%esp)
  800e25:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e29:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e33:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e36:	8b 7d 14             	mov    0x14(%ebp),%edi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e39:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e3e:	be 00 00 00 00       	mov    $0x0,%esi
  800e43:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e45:	8b 1c 24             	mov    (%esp),%ebx
  800e48:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e4c:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e50:	89 ec                	mov    %ebp,%esp
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    

00800e54 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	83 ec 28             	sub    $0x28,%esp
  800e5a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e5d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e60:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e63:	8b 55 08             	mov    0x8(%ebp),%edx
  800e66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e69:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e6e:	bf 00 00 00 00       	mov    $0x0,%edi
  800e73:	89 fb                	mov    %edi,%ebx
  800e75:	89 fe                	mov    %edi,%esi
  800e77:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800e79:	85 c0                	test   %eax,%eax
  800e7b:	7e 28                	jle    800ea5 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e81:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e88:	00 
  800e89:	c7 44 24 08 7f 2c 80 	movl   $0x802c7f,0x8(%esp)
  800e90:	00 
  800e91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e98:	00 
  800e99:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  800ea0:	e8 17 f3 ff ff       	call   8001bc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ea5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ea8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eab:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eae:	89 ec                	mov    %ebp,%esp
  800eb0:	5d                   	pop    %ebp
  800eb1:	c3                   	ret    

00800eb2 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800eb2:	55                   	push   %ebp
  800eb3:	89 e5                	mov    %esp,%ebp
  800eb5:	83 ec 28             	sub    $0x28,%esp
  800eb8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ebb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ebe:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ec1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec7:	b8 09 00 00 00       	mov    $0x9,%eax
  800ecc:	bf 00 00 00 00       	mov    $0x0,%edi
  800ed1:	89 fb                	mov    %edi,%ebx
  800ed3:	89 fe                	mov    %edi,%esi
  800ed5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800ed7:	85 c0                	test   %eax,%eax
  800ed9:	7e 28                	jle    800f03 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800edb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800edf:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ee6:	00 
  800ee7:	c7 44 24 08 7f 2c 80 	movl   $0x802c7f,0x8(%esp)
  800eee:	00 
  800eef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef6:	00 
  800ef7:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  800efe:	e8 b9 f2 ff ff       	call   8001bc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f03:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f06:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f09:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f0c:	89 ec                	mov    %ebp,%esp
  800f0e:	5d                   	pop    %ebp
  800f0f:	c3                   	ret    

00800f10 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	83 ec 28             	sub    $0x28,%esp
  800f16:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f19:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f1c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f25:	b8 08 00 00 00       	mov    $0x8,%eax
  800f2a:	bf 00 00 00 00       	mov    $0x0,%edi
  800f2f:	89 fb                	mov    %edi,%ebx
  800f31:	89 fe                	mov    %edi,%esi
  800f33:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f35:	85 c0                	test   %eax,%eax
  800f37:	7e 28                	jle    800f61 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f39:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f3d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f44:	00 
  800f45:	c7 44 24 08 7f 2c 80 	movl   $0x802c7f,0x8(%esp)
  800f4c:	00 
  800f4d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f54:	00 
  800f55:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  800f5c:	e8 5b f2 ff ff       	call   8001bc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f61:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f64:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f67:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f6a:	89 ec                	mov    %ebp,%esp
  800f6c:	5d                   	pop    %ebp
  800f6d:	c3                   	ret    

00800f6e <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800f6e:	55                   	push   %ebp
  800f6f:	89 e5                	mov    %esp,%ebp
  800f71:	83 ec 28             	sub    $0x28,%esp
  800f74:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f77:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f7a:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f83:	b8 06 00 00 00       	mov    $0x6,%eax
  800f88:	bf 00 00 00 00       	mov    $0x0,%edi
  800f8d:	89 fb                	mov    %edi,%ebx
  800f8f:	89 fe                	mov    %edi,%esi
  800f91:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f93:	85 c0                	test   %eax,%eax
  800f95:	7e 28                	jle    800fbf <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f97:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f9b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800fa2:	00 
  800fa3:	c7 44 24 08 7f 2c 80 	movl   $0x802c7f,0x8(%esp)
  800faa:	00 
  800fab:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fb2:	00 
  800fb3:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  800fba:	e8 fd f1 ff ff       	call   8001bc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fbf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fc2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fc5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fc8:	89 ec                	mov    %ebp,%esp
  800fca:	5d                   	pop    %ebp
  800fcb:	c3                   	ret    

00800fcc <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
  800fcf:	83 ec 28             	sub    $0x28,%esp
  800fd2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fd5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fd8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800fdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fe4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fe7:	8b 75 18             	mov    0x18(%ebp),%esi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fea:	b8 05 00 00 00       	mov    $0x5,%eax
  800fef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	7e 28                	jle    80101d <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff9:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801000:	00 
  801001:	c7 44 24 08 7f 2c 80 	movl   $0x802c7f,0x8(%esp)
  801008:	00 
  801009:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801010:	00 
  801011:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  801018:	e8 9f f1 ff ff       	call   8001bc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80101d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801020:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801023:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801026:	89 ec                	mov    %ebp,%esp
  801028:	5d                   	pop    %ebp
  801029:	c3                   	ret    

0080102a <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80102a:	55                   	push   %ebp
  80102b:	89 e5                	mov    %esp,%ebp
  80102d:	83 ec 28             	sub    $0x28,%esp
  801030:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801033:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801036:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801039:	8b 55 08             	mov    0x8(%ebp),%edx
  80103c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80103f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801042:	b8 04 00 00 00       	mov    $0x4,%eax
  801047:	bf 00 00 00 00       	mov    $0x0,%edi
  80104c:	89 fe                	mov    %edi,%esi
  80104e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801050:	85 c0                	test   %eax,%eax
  801052:	7e 28                	jle    80107c <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  801054:	89 44 24 10          	mov    %eax,0x10(%esp)
  801058:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80105f:	00 
  801060:	c7 44 24 08 7f 2c 80 	movl   $0x802c7f,0x8(%esp)
  801067:	00 
  801068:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80106f:	00 
  801070:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  801077:	e8 40 f1 ff ff       	call   8001bc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80107c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80107f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801082:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801085:	89 ec                	mov    %ebp,%esp
  801087:	5d                   	pop    %ebp
  801088:	c3                   	ret    

00801089 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
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
  80109a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80109f:	bf 00 00 00 00       	mov    $0x0,%edi
  8010a4:	89 fa                	mov    %edi,%edx
  8010a6:	89 f9                	mov    %edi,%ecx
  8010a8:	89 fb                	mov    %edi,%ebx
  8010aa:	89 fe                	mov    %edi,%esi
  8010ac:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010ae:	8b 1c 24             	mov    (%esp),%ebx
  8010b1:	8b 74 24 04          	mov    0x4(%esp),%esi
  8010b5:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8010b9:	89 ec                	mov    %ebp,%esp
  8010bb:	5d                   	pop    %ebp
  8010bc:	c3                   	ret    

008010bd <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8010bd:	55                   	push   %ebp
  8010be:	89 e5                	mov    %esp,%ebp
  8010c0:	83 ec 0c             	sub    $0xc,%esp
  8010c3:	89 1c 24             	mov    %ebx,(%esp)
  8010c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010ca:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ce:	b8 02 00 00 00       	mov    $0x2,%eax
  8010d3:	bf 00 00 00 00       	mov    $0x0,%edi
  8010d8:	89 fa                	mov    %edi,%edx
  8010da:	89 f9                	mov    %edi,%ecx
  8010dc:	89 fb                	mov    %edi,%ebx
  8010de:	89 fe                	mov    %edi,%esi
  8010e0:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010e2:	8b 1c 24             	mov    (%esp),%ebx
  8010e5:	8b 74 24 04          	mov    0x4(%esp),%esi
  8010e9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8010ed:	89 ec                	mov    %ebp,%esp
  8010ef:	5d                   	pop    %ebp
  8010f0:	c3                   	ret    

008010f1 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
  8010f4:	83 ec 28             	sub    $0x28,%esp
  8010f7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010fa:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010fd:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801100:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801103:	b8 03 00 00 00       	mov    $0x3,%eax
  801108:	bf 00 00 00 00       	mov    $0x0,%edi
  80110d:	89 f9                	mov    %edi,%ecx
  80110f:	89 fb                	mov    %edi,%ebx
  801111:	89 fe                	mov    %edi,%esi
  801113:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801115:	85 c0                	test   %eax,%eax
  801117:	7e 28                	jle    801141 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801119:	89 44 24 10          	mov    %eax,0x10(%esp)
  80111d:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801124:	00 
  801125:	c7 44 24 08 7f 2c 80 	movl   $0x802c7f,0x8(%esp)
  80112c:	00 
  80112d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801134:	00 
  801135:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  80113c:	e8 7b f0 ff ff       	call   8001bc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801141:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801144:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801147:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80114a:	89 ec                	mov    %ebp,%esp
  80114c:	5d                   	pop    %ebp
  80114d:	c3                   	ret    
	...

00801150 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
// 
static int
duppage(envid_t envid, unsigned pn)
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
  801153:	53                   	push   %ebx
  801154:	83 ec 14             	sub    $0x14,%esp
  801157:	89 c1                	mov    %eax,%ecx
	int r;

	// LAB 4: Your code here.
	pde_t *pde;
	pte_t *pte;
	void *addr=(void*)(pn*PGSIZE);
  801159:	89 d3                	mov    %edx,%ebx
  80115b:	c1 e3 0c             	shl    $0xc,%ebx
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
  80115e:	89 d8                	mov    %ebx,%eax
  801160:	c1 e8 16             	shr    $0x16,%eax
  801163:	f6 04 85 00 d0 7b ef 	testb  $0x1,-0x10843000(,%eax,4)
  80116a:	01 
  80116b:	74 14                	je     801181 <duppage+0x31>
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else    panic("page table for pn page is not exist");
	if((*pte&PTE_W)||(*pte&PTE_COW))
  80116d:	89 d8                	mov    %ebx,%eax
  80116f:	c1 e8 0c             	shr    $0xc,%eax
  801172:	f7 04 85 00 00 40 ef 	testl  $0x802,-0x10c00000(,%eax,4)
  801179:	02 08 00 00 
  80117d:	75 1e                	jne    80119d <duppage+0x4d>
  80117f:	eb 73                	jmp    8011f4 <duppage+0xa4>
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else    panic("page table for pn page is not exist");
  801181:	c7 44 24 08 ac 2c 80 	movl   $0x802cac,0x8(%esp)
  801188:	00 
  801189:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
  801190:	00 
  801191:	c7 04 24 6a 2d 80 00 	movl   $0x802d6a,(%esp)
  801198:	e8 1f f0 ff ff       	call   8001bc <_panic>
	if((*pte&PTE_W)||(*pte&PTE_COW))
	{
		if((r=sys_page_map(0,addr,envid,addr,PTE_COW|PTE_U))<0)
  80119d:	c7 44 24 10 04 08 00 	movl   $0x804,0x10(%esp)
  8011a4:	00 
  8011a5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011a9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011b8:	e8 0f fe ff ff       	call   800fcc <sys_page_map>
  8011bd:	85 c0                	test   %eax,%eax
  8011bf:	78 60                	js     801221 <duppage+0xd1>
			return r;
		if((r=sys_page_map(0,addr,0,addr,PTE_COW|PTE_U))<0)//映射的时候注意env的id
  8011c1:	c7 44 24 10 04 08 00 	movl   $0x804,0x10(%esp)
  8011c8:	00 
  8011c9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011cd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011d4:	00 
  8011d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011e0:	e8 e7 fd ff ff       	call   800fcc <sys_page_map>
  8011e5:	85 c0                	test   %eax,%eax
  8011e7:	0f 9f c2             	setg   %dl
  8011ea:	0f b6 d2             	movzbl %dl,%edx
  8011ed:	83 ea 01             	sub    $0x1,%edx
  8011f0:	21 d0                	and    %edx,%eax
  8011f2:	eb 2d                	jmp    801221 <duppage+0xd1>
                        return r;
	}
	else{	
		if((r=sys_page_map(0,addr,envid,addr,PTE_U|PTE_P))<0)
  8011f4:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8011fb:	00 
  8011fc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801200:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801204:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801208:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80120f:	e8 b8 fd ff ff       	call   800fcc <sys_page_map>
  801214:	85 c0                	test   %eax,%eax
  801216:	0f 9f c2             	setg   %dl
  801219:	0f b6 d2             	movzbl %dl,%edx
  80121c:	83 ea 01             	sub    $0x1,%edx
  80121f:	21 d0                	and    %edx,%eax
			return r;
	}
	//panic("duppage not implemented");
	return 0;
}
  801221:	83 c4 14             	add    $0x14,%esp
  801224:	5b                   	pop    %ebx
  801225:	5d                   	pop    %ebp
  801226:	c3                   	ret    

00801227 <sfork>:
	return 0;
}
// Challenge!
int
sfork(void)
{
  801227:	55                   	push   %ebp
  801228:	89 e5                	mov    %esp,%ebp
  80122a:	57                   	push   %edi
  80122b:	56                   	push   %esi
  80122c:	53                   	push   %ebx
  80122d:	83 ec 1c             	sub    $0x1c,%esp
static __inline envid_t sys_exofork(void) __attribute__((always_inline));
static __inline envid_t
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801230:	ba 07 00 00 00       	mov    $0x7,%edx
  801235:	89 d0                	mov    %edx,%eax
  801237:	cd 30                	int    $0x30
  801239:	89 45 f0             	mov    %eax,-0x10(%ebp)
	pte_t *pte;
	unsigned i;
	uint32_t addr;
	envid_t envid;
	envid = sys_exofork();//创建子环境
	if(envid < 0)
  80123c:	85 c0                	test   %eax,%eax
  80123e:	79 20                	jns    801260 <sfork+0x39>
		panic("sys_exofork: %e", envid);
  801240:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801244:	c7 44 24 08 75 2d 80 	movl   $0x802d75,0x8(%esp)
  80124b:	00 
  80124c:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  801253:	00 
  801254:	c7 04 24 6a 2d 80 00 	movl   $0x802d6a,(%esp)
  80125b:	e8 5c ef ff ff       	call   8001bc <_panic>
	if(envid==0)//子环境中
  801260:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801264:	75 21                	jne    801287 <sfork+0x60>
	{
		env = &envs[ENVX(sys_getenvid())];
  801266:	e8 52 fe ff ff       	call   8010bd <sys_getenvid>
  80126b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801270:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801273:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801278:	a3 3c 60 80 00       	mov    %eax,0x80603c
  80127d:	b8 00 00 00 00       	mov    $0x0,%eax
  801282:	e9 83 01 00 00       	jmp    80140a <sfork+0x1e3>
		return 0;
	}
	else{//父环境中,注意：这里需要设置父环境的缺页异常栈，还需要设置子环境的缺页异常栈，
	//父子环境的页异常栈不共享？具体原因还得思考
		env = &envs[ENVX(sys_getenvid())];
  801287:	e8 31 fe ff ff       	call   8010bd <sys_getenvid>
  80128c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801291:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801294:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801299:	a3 3c 60 80 00       	mov    %eax,0x80603c
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
  80129e:	c7 04 24 12 14 80 00 	movl   $0x801412,(%esp)
  8012a5:	e8 42 13 00 00       	call   8025ec <set_pgfault_handler>
  8012aa:	be 00 00 00 00       	mov    $0x0,%esi
  8012af:	bf 00 00 00 00       	mov    $0x0,%edi
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
		{
			addr=i*PGSIZE;
			pde =(pde_t*) &vpd[VPD(addr)];
  8012b4:	89 f8                	mov    %edi,%eax
  8012b6:	c1 e8 16             	shr    $0x16,%eax
  8012b9:	c1 e0 02             	shl    $0x2,%eax
			if(*pde&PTE_P)//这里只处理有物理页面映射的页表项
  8012bc:	f6 80 00 d0 7b ef 01 	testb  $0x1,-0x10843000(%eax)
  8012c3:	0f 84 dc 00 00 00    	je     8013a5 <sfork+0x17e>
			{
				pte=(pte_t*)&vpt[VPN(addr)];
			}
			else    continue;
			if((i==(unsigned)VPN(USTACKTOP-PGSIZE))||(i==(unsigned)VPN(PFTEMP)))
  8012c9:	81 fe fd eb 0e 00    	cmp    $0xeebfd,%esi
  8012cf:	74 08                	je     8012d9 <sfork+0xb2>
  8012d1:	81 fe ff 07 00 00    	cmp    $0x7ff,%esi
  8012d7:	75 17                	jne    8012f0 <sfork+0xc9>
								//特殊处理，用户层普通栈
			{	
				if((r=duppage(envid,i))<0)
  8012d9:	89 f2                	mov    %esi,%edx
  8012db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012de:	e8 6d fe ff ff       	call   801150 <duppage>
  8012e3:	85 c0                	test   %eax,%eax
  8012e5:	0f 89 ba 00 00 00    	jns    8013a5 <sfork+0x17e>
  8012eb:	e9 1a 01 00 00       	jmp    80140a <sfork+0x1e3>
	// LAB 4: Your code here.
	pde_t *pde;
	pte_t *pte;
	void *addr=(void*)(pn*PGSIZE);
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
  8012f0:	f6 80 00 d0 7b ef 01 	testb  $0x1,-0x10843000(%eax)
  8012f7:	74 11                	je     80130a <sfork+0xe3>
	{
		pte=(pte_t*)&vpt[VPN(addr)];
  8012f9:	89 f8                	mov    %edi,%eax
  8012fb:	c1 e8 0c             	shr    $0xc,%eax
	}
	else    panic("page table for pn page is not exist");
	if(*pte&PTE_W)
  8012fe:	f6 04 85 00 00 40 ef 	testb  $0x2,-0x10c00000(,%eax,4)
  801305:	02 
  801306:	75 1e                	jne    801326 <sfork+0xff>
  801308:	eb 74                	jmp    80137e <sfork+0x157>
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else    panic("page table for pn page is not exist");
  80130a:	c7 44 24 08 ac 2c 80 	movl   $0x802cac,0x8(%esp)
  801311:	00 
  801312:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
  801319:	00 
  80131a:	c7 04 24 6a 2d 80 00 	movl   $0x802d6a,(%esp)
  801321:	e8 96 ee ff ff       	call   8001bc <_panic>
	if(*pte&PTE_W)
	{
		//cprintf("sduppage:addr=%x\n",addr);
		if((r=sys_page_map(0,addr,envid,addr,PTE_W|PTE_U))<0)
  801326:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
  80132d:	00 
  80132e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801332:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801335:	89 44 24 08          	mov    %eax,0x8(%esp)
  801339:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80133d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801344:	e8 83 fc ff ff       	call   800fcc <sys_page_map>
  801349:	85 c0                	test   %eax,%eax
  80134b:	0f 88 b9 00 00 00    	js     80140a <sfork+0x1e3>
			return r;
		if((r=sys_page_map(0,addr,0,addr,PTE_W|PTE_U))<0)//映射的时候注意env的id
  801351:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
  801358:	00 
  801359:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80135d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801364:	00 
  801365:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801369:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801370:	e8 57 fc ff ff       	call   800fcc <sys_page_map>
  801375:	85 c0                	test   %eax,%eax
  801377:	79 2c                	jns    8013a5 <sfork+0x17e>
  801379:	e9 8c 00 00 00       	jmp    80140a <sfork+0x1e3>
                        return r;
	}
	else{	
		if((r=sys_page_map(0,addr,envid,addr,PTE_U|PTE_P))<0)
  80137e:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801385:	00 
  801386:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80138a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801391:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801395:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80139c:	e8 2b fc ff ff       	call   800fcc <sys_page_map>
  8013a1:	85 c0                	test   %eax,%eax
  8013a3:	78 65                	js     80140a <sfork+0x1e3>
	}
	else{//父环境中,注意：这里需要设置父环境的缺页异常栈，还需要设置子环境的缺页异常栈，
	//父子环境的页异常栈不共享？具体原因还得思考
		env = &envs[ENVX(sys_getenvid())];
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
  8013a5:	83 c6 01             	add    $0x1,%esi
  8013a8:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8013ae:	81 fe 00 ec 0e 00    	cmp    $0xeec00,%esi
  8013b4:	0f 85 fa fe ff ff    	jne    8012b4 <sfork+0x8d>
				continue;
			}
			if((r=sduppage(envid,i))<0)
				return r;
		}
		if((r=sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  8013ba:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013c1:	00 
  8013c2:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013c9:	ee 
  8013ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013cd:	89 04 24             	mov    %eax,(%esp)
  8013d0:	e8 55 fc ff ff       	call   80102a <sys_page_alloc>
  8013d5:	85 c0                	test   %eax,%eax
  8013d7:	78 31                	js     80140a <sfork+0x1e3>
                        return r;//设置子环境的缺页异常栈
		if((r=sys_env_set_pgfault_upcall(envid,(void*)_pgfault_upcall))<0)
  8013d9:	c7 44 24 04 70 26 80 	movl   $0x802670,0x4(%esp)
  8013e0:	00 
  8013e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e4:	89 04 24             	mov    %eax,(%esp)
  8013e7:	e8 68 fa ff ff       	call   800e54 <sys_env_set_pgfault_upcall>
  8013ec:	85 c0                	test   %eax,%eax
  8013ee:	78 1a                	js     80140a <sfork+0x1e3>
			return r;//设置子环境的缺页异常处理入口点
		if((r=sys_env_set_status(envid,ENV_RUNNABLE))<0)
  8013f0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8013f7:	00 
  8013f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013fb:	89 04 24             	mov    %eax,(%esp)
  8013fe:	e8 0d fb ff ff       	call   800f10 <sys_env_set_status>
  801403:	85 c0                	test   %eax,%eax
  801405:	78 03                	js     80140a <sfork+0x1e3>
  801407:	8b 45 f0             	mov    -0x10(%ebp),%eax
			return r;//设置子环境的状态为可运行
		return envid;
	}
	//panic("sfork not implemented");
	//return -E_INVAL;
}
  80140a:	83 c4 1c             	add    $0x1c,%esp
  80140d:	5b                   	pop    %ebx
  80140e:	5e                   	pop    %esi
  80140f:	5f                   	pop    %edi
  801410:	5d                   	pop    %ebp
  801411:	c3                   	ret    

00801412 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801412:	55                   	push   %ebp
  801413:	89 e5                	mov    %esp,%ebp
  801415:	56                   	push   %esi
  801416:	53                   	push   %ebx
  801417:	83 ec 20             	sub    $0x20,%esp
  80141a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
  80141d:	8b 71 04             	mov    0x4(%ecx),%esi

	// LAB 4: Your code here.
	pde_t *pde;
	pte_t *pte;
	uint32_t *va,*srcva,*dstva;
	pde =(pde_t*) &vpd[VPD(addr)];
  801420:	8b 19                	mov    (%ecx),%ebx
  801422:	89 d8                	mov    %ebx,%eax
  801424:	c1 e8 16             	shr    $0x16,%eax
  801427:	c1 e0 02             	shl    $0x2,%eax
  80142a:	8d 90 00 d0 7b ef    	lea    -0x10843000(%eax),%edx
	if(*pde&PTE_P)
  801430:	f6 80 00 d0 7b ef 01 	testb  $0x1,-0x10843000(%eax)
  801437:	74 16                	je     80144f <pgfault+0x3d>
	{
		pte=(pte_t*)&vpt[VPN(addr)];
  801439:	89 d8                	mov    %ebx,%eax
  80143b:	c1 e8 0c             	shr    $0xc,%eax
  80143e:	8d 04 85 00 00 40 ef 	lea    -0x10c00000(,%eax,4),%eax
	else{
		cprintf("addr=%x err=%x *pde=%x utf_eip=%x\n",(uint32_t)addr,err,*pde,utf->utf_eip);	
		panic("page table for fault va is not exist");
	}
	//cprintf("addr=%x err=%x *pte=%x utf_eip=%x\n",(uint32_t)addr,err,*pte,utf->utf_eip);
	if(!(err&FEC_WR)||!(*pte&PTE_COW))
  801445:	f7 c6 02 00 00 00    	test   $0x2,%esi
  80144b:	75 3f                	jne    80148c <pgfault+0x7a>
  80144d:	eb 43                	jmp    801492 <pgfault+0x80>
	if(*pde&PTE_P)
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else{
		cprintf("addr=%x err=%x *pde=%x utf_eip=%x\n",(uint32_t)addr,err,*pde,utf->utf_eip);	
  80144f:	8b 41 28             	mov    0x28(%ecx),%eax
  801452:	8b 12                	mov    (%edx),%edx
  801454:	89 44 24 10          	mov    %eax,0x10(%esp)
  801458:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80145c:	89 74 24 08          	mov    %esi,0x8(%esp)
  801460:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801464:	c7 04 24 d0 2c 80 00 	movl   $0x802cd0,(%esp)
  80146b:	e8 19 ee ff ff       	call   800289 <cprintf>
		panic("page table for fault va is not exist");
  801470:	c7 44 24 08 f4 2c 80 	movl   $0x802cf4,0x8(%esp)
  801477:	00 
  801478:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80147f:	00 
  801480:	c7 04 24 6a 2d 80 00 	movl   $0x802d6a,(%esp)
  801487:	e8 30 ed ff ff       	call   8001bc <_panic>
	}
	//cprintf("addr=%x err=%x *pte=%x utf_eip=%x\n",(uint32_t)addr,err,*pte,utf->utf_eip);
	if(!(err&FEC_WR)||!(*pte&PTE_COW))
  80148c:	f6 40 01 08          	testb  $0x8,0x1(%eax)
  801490:	75 49                	jne    8014db <pgfault+0xc9>
	{	
		cprintf("envid=%x addr=%x err=%x *pte=%x utf_eip=%x\n",env->env_id,(uint32_t)addr,err,*pte,utf->utf_eip);
  801492:	8b 51 28             	mov    0x28(%ecx),%edx
  801495:	8b 08                	mov    (%eax),%ecx
  801497:	a1 3c 60 80 00       	mov    0x80603c,%eax
  80149c:	8b 40 4c             	mov    0x4c(%eax),%eax
  80149f:	89 54 24 14          	mov    %edx,0x14(%esp)
  8014a3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8014a7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8014ab:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b3:	c7 04 24 1c 2d 80 00 	movl   $0x802d1c,(%esp)
  8014ba:	e8 ca ed ff ff       	call   800289 <cprintf>
		panic("faulting access is illegle");
  8014bf:	c7 44 24 08 85 2d 80 	movl   $0x802d85,0x8(%esp)
  8014c6:	00 
  8014c7:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8014ce:	00 
  8014cf:	c7 04 24 6a 2d 80 00 	movl   $0x802d6a,(%esp)
  8014d6:	e8 e1 ec ff ff       	call   8001bc <_panic>
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	//cprintf("pgfault:env_id=%x\n",env->env_id);
	if((r=sys_page_alloc(0,PFTEMP,PTE_W|PTE_U|PTE_P))<0)
  8014db:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8014e2:	00 
  8014e3:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8014ea:	00 
  8014eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014f2:	e8 33 fb ff ff       	call   80102a <sys_page_alloc>
  8014f7:	85 c0                	test   %eax,%eax
  8014f9:	79 20                	jns    80151b <pgfault+0x109>
			//输入id=0表示当前环境id(curenv->env_id),这个时候不能用env->env-id,子环境中env的修改会缺页
		panic("alloc a page for PFTEMP failed:%e",r);
  8014fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014ff:	c7 44 24 08 48 2d 80 	movl   $0x802d48,0x8(%esp)
  801506:	00 
  801507:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  80150e:	00 
  80150f:	c7 04 24 6a 2d 80 00 	movl   $0x802d6a,(%esp)
  801516:	e8 a1 ec ff ff       	call   8001bc <_panic>
	//cprintf("PFTEMP=%x add=%x\n",PFTEMP,(uint32_t)addr&0xfffff000);
	srcva = (uint32_t*)((uint32_t)addr&0xfffff000);
  80151b:	89 de                	mov    %ebx,%esi
  80151d:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  801523:	89 f2                	mov    %esi,%edx
	dstva = (uint32_t*)PFTEMP;
	//strncpy((char*)PFTEMP,(char*)((uint32_t)addr&0xfffff000),PGSIZE);
	for(;srcva<(uint32_t*)(ROUNDUP(addr,PGSIZE));srcva++)//数据拷贝要注意，用strncpy出错了，原因还得分析
  801525:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  80152b:	89 c3                	mov    %eax,%ebx
  80152d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801533:	39 de                	cmp    %ebx,%esi
  801535:	73 13                	jae    80154a <pgfault+0x138>
  801537:	b9 00 f0 7f 00       	mov    $0x7ff000,%ecx
	{
		*dstva=*srcva;
  80153c:	8b 02                	mov    (%edx),%eax
  80153e:	89 01                	mov    %eax,(%ecx)
		dstva++;
  801540:	83 c1 04             	add    $0x4,%ecx
		panic("alloc a page for PFTEMP failed:%e",r);
	//cprintf("PFTEMP=%x add=%x\n",PFTEMP,(uint32_t)addr&0xfffff000);
	srcva = (uint32_t*)((uint32_t)addr&0xfffff000);
	dstva = (uint32_t*)PFTEMP;
	//strncpy((char*)PFTEMP,(char*)((uint32_t)addr&0xfffff000),PGSIZE);
	for(;srcva<(uint32_t*)(ROUNDUP(addr,PGSIZE));srcva++)//数据拷贝要注意，用strncpy出错了，原因还得分析
  801543:	83 c2 04             	add    $0x4,%edx
  801546:	39 da                	cmp    %ebx,%edx
  801548:	72 f2                	jb     80153c <pgfault+0x12a>
	{
		*dstva=*srcva;
		dstva++;
	}
	if((r=sys_page_map(0,(void*)PFTEMP,0,(void*)((uint32_t)addr&0xfffff000),PTE_W|PTE_U|PTE_P))<0)
  80154a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801551:	00 
  801552:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801556:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80155d:	00 
  80155e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801565:	00 
  801566:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80156d:	e8 5a fa ff ff       	call   800fcc <sys_page_map>
  801572:	85 c0                	test   %eax,%eax
  801574:	79 1c                	jns    801592 <pgfault+0x180>
			//输入id=0表示当前环境id(curenv->env_id),这个时候不能用env->env-id,子环境中env的修改会缺页
		panic("page mapping failed");
  801576:	c7 44 24 08 a0 2d 80 	movl   $0x802da0,0x8(%esp)
  80157d:	00 
  80157e:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801585:	00 
  801586:	c7 04 24 6a 2d 80 00 	movl   $0x802d6a,(%esp)
  80158d:	e8 2a ec ff ff       	call   8001bc <_panic>
	//panic("pgfault not implemented");
}
  801592:	83 c4 20             	add    $0x20,%esp
  801595:	5b                   	pop    %ebx
  801596:	5e                   	pop    %esi
  801597:	5d                   	pop    %ebp
  801598:	c3                   	ret    

00801599 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801599:	55                   	push   %ebp
  80159a:	89 e5                	mov    %esp,%ebp
  80159c:	56                   	push   %esi
  80159d:	53                   	push   %ebx
  80159e:	83 ec 10             	sub    $0x10,%esp
  8015a1:	ba 07 00 00 00       	mov    $0x7,%edx
  8015a6:	89 d0                	mov    %edx,%eax
  8015a8:	cd 30                	int    $0x30
  8015aa:	89 c6                	mov    %eax,%esi
	pte_t *pte;
	unsigned i;
	uint32_t addr;
	envid_t envid;
	envid = sys_exofork();//创建子环境
	if(envid < 0)
  8015ac:	85 c0                	test   %eax,%eax
  8015ae:	79 20                	jns    8015d0 <fork+0x37>
		panic("sys_exofork: %e", envid);
  8015b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015b4:	c7 44 24 08 75 2d 80 	movl   $0x802d75,0x8(%esp)
  8015bb:	00 
  8015bc:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  8015c3:	00 
  8015c4:	c7 04 24 6a 2d 80 00 	movl   $0x802d6a,(%esp)
  8015cb:	e8 ec eb ff ff       	call   8001bc <_panic>
	if(envid==0)//子环境中
  8015d0:	85 c0                	test   %eax,%eax
  8015d2:	75 21                	jne    8015f5 <fork+0x5c>
	{
		env = &envs[ENVX(sys_getenvid())];
  8015d4:	e8 e4 fa ff ff       	call   8010bd <sys_getenvid>
  8015d9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8015de:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8015e1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8015e6:	a3 3c 60 80 00       	mov    %eax,0x80603c
  8015eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8015f0:	e9 9e 00 00 00       	jmp    801693 <fork+0xfa>
		return 0;
	}
	else{//父环境中
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
  8015f5:	c7 04 24 12 14 80 00 	movl   $0x801412,(%esp)
  8015fc:	e8 eb 0f 00 00       	call   8025ec <set_pgfault_handler>
  801601:	bb 00 00 00 00       	mov    $0x0,%ebx
  801606:	eb 08                	jmp    801610 <fork+0x77>
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
		{
			if(i==(unsigned)VPN(UXSTACKTOP-PGSIZE))//特殊处理，用户层缺页异常栈
  801608:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  80160e:	74 3d                	je     80164d <fork+0xb4>
				continue;
  801610:	89 da                	mov    %ebx,%edx
  801612:	c1 e2 0c             	shl    $0xc,%edx
			addr=i*PGSIZE;
			pde =(pde_t*) &vpd[VPD(addr)];
  801615:	89 d0                	mov    %edx,%eax
  801617:	c1 e8 16             	shr    $0x16,%eax
			if(*pde&PTE_P)//这里只处理有物理页面映射的页表项
  80161a:	f6 04 85 00 d0 7b ef 	testb  $0x1,-0x10843000(,%eax,4)
  801621:	01 
  801622:	74 1e                	je     801642 <fork+0xa9>
			{
				pte=(pte_t*)&vpt[VPN(addr)];
  801624:	89 d0                	mov    %edx,%eax
  801626:	c1 e8 0a             	shr    $0xa,%eax
			}
			else    continue;
			if((*pte&PTE_W)||(*pte&PTE_COW))
  801629:	f7 80 00 00 40 ef 02 	testl  $0x802,-0x10c00000(%eax)
  801630:	08 00 00 
  801633:	74 0d                	je     801642 <fork+0xa9>
			{
				if((r=duppage(envid,i))<0)
  801635:	89 da                	mov    %ebx,%edx
  801637:	89 f0                	mov    %esi,%eax
  801639:	e8 12 fb ff ff       	call   801150 <duppage>
  80163e:	85 c0                	test   %eax,%eax
  801640:	78 51                	js     801693 <fork+0xfa>
		env = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	else{//父环境中
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
  801642:	83 c3 01             	add    $0x1,%ebx
  801645:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  80164b:	75 bb                	jne    801608 <fork+0x6f>
			{
				if((r=duppage(envid,i))<0)
					return r;
			}
		}
		if((r=sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  80164d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801654:	00 
  801655:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80165c:	ee 
  80165d:	89 34 24             	mov    %esi,(%esp)
  801660:	e8 c5 f9 ff ff       	call   80102a <sys_page_alloc>
  801665:	85 c0                	test   %eax,%eax
  801667:	78 2a                	js     801693 <fork+0xfa>
			return r;//设置子环境的缺页异常栈
		if((r=sys_env_set_pgfault_upcall(envid,(void*)_pgfault_upcall))<0)
  801669:	c7 44 24 04 70 26 80 	movl   $0x802670,0x4(%esp)
  801670:	00 
  801671:	89 34 24             	mov    %esi,(%esp)
  801674:	e8 db f7 ff ff       	call   800e54 <sys_env_set_pgfault_upcall>
  801679:	85 c0                	test   %eax,%eax
  80167b:	78 16                	js     801693 <fork+0xfa>
			return r;//设置子环境的缺页异常处理入口点
		if((r=sys_env_set_status(envid,ENV_RUNNABLE))<0)
  80167d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801684:	00 
  801685:	89 34 24             	mov    %esi,(%esp)
  801688:	e8 83 f8 ff ff       	call   800f10 <sys_env_set_status>
  80168d:	85 c0                	test   %eax,%eax
  80168f:	78 02                	js     801693 <fork+0xfa>
  801691:	89 f0                	mov    %esi,%eax
			return r;//设置子环境的状态为可运行
		return envid;
	}
	//panic("fork not implemented");
}
  801693:	83 c4 10             	add    $0x10,%esp
  801696:	5b                   	pop    %ebx
  801697:	5e                   	pop    %esi
  801698:	5d                   	pop    %ebp
  801699:	c3                   	ret    
  80169a:	00 00                	add    %al,(%eax)
  80169c:	00 00                	add    %al,(%eax)
	...

008016a0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
  8016a3:	57                   	push   %edi
  8016a4:	56                   	push   %esi
  8016a5:	53                   	push   %ebx
  8016a6:	83 ec 1c             	sub    $0x1c,%esp
  8016a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8016ac:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  8016af:	e8 09 fa ff ff       	call   8010bd <sys_getenvid>
  8016b4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8016b9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8016bc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8016c1:	a3 3c 60 80 00       	mov    %eax,0x80603c
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  8016c6:	e8 f2 f9 ff ff       	call   8010bd <sys_getenvid>
  8016cb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8016d0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8016d3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8016d8:	a3 3c 60 80 00       	mov    %eax,0x80603c
		if(env->env_id==to_env){
  8016dd:	8b 40 4c             	mov    0x4c(%eax),%eax
  8016e0:	39 f0                	cmp    %esi,%eax
  8016e2:	75 0e                	jne    8016f2 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  8016e4:	c7 04 24 b4 2d 80 00 	movl   $0x802db4,(%esp)
  8016eb:	e8 99 eb ff ff       	call   800289 <cprintf>
  8016f0:	eb 5a                	jmp    80174c <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  8016f2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8016f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8016f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801700:	89 44 24 04          	mov    %eax,0x4(%esp)
  801704:	89 34 24             	mov    %esi,(%esp)
  801707:	e8 10 f7 ff ff       	call   800e1c <sys_ipc_try_send>
  80170c:	89 c3                	mov    %eax,%ebx
  80170e:	85 c0                	test   %eax,%eax
  801710:	79 25                	jns    801737 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  801712:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801715:	74 2b                	je     801742 <ipc_send+0xa2>
				panic("send error:%e",r);
  801717:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80171b:	c7 44 24 08 d0 2d 80 	movl   $0x802dd0,0x8(%esp)
  801722:	00 
  801723:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80172a:	00 
  80172b:	c7 04 24 de 2d 80 00 	movl   $0x802dde,(%esp)
  801732:	e8 85 ea ff ff       	call   8001bc <_panic>
		}
			sys_yield();
  801737:	e8 4d f9 ff ff       	call   801089 <sys_yield>
		
	}while(r!=0);
  80173c:	85 db                	test   %ebx,%ebx
  80173e:	75 86                	jne    8016c6 <ipc_send+0x26>
  801740:	eb 0a                	jmp    80174c <ipc_send+0xac>
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
		{	
			if(r!=-E_IPC_NOT_RECV)
				panic("send error:%e",r);
		}
			sys_yield();
  801742:	e8 42 f9 ff ff       	call   801089 <sys_yield>
  801747:	e9 7a ff ff ff       	jmp    8016c6 <ipc_send+0x26>
		
	}while(r!=0);
	return;
	//panic("ipc_send not implemented");
}
  80174c:	83 c4 1c             	add    $0x1c,%esp
  80174f:	5b                   	pop    %ebx
  801750:	5e                   	pop    %esi
  801751:	5f                   	pop    %edi
  801752:	5d                   	pop    %ebp
  801753:	c3                   	ret    

00801754 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801754:	55                   	push   %ebp
  801755:	89 e5                	mov    %esp,%ebp
  801757:	57                   	push   %edi
  801758:	56                   	push   %esi
  801759:	53                   	push   %ebx
  80175a:	83 ec 0c             	sub    $0xc,%esp
  80175d:	8b 75 08             	mov    0x8(%ebp),%esi
  801760:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	void *dstva=NULL;
	if(pg)
		dstva=pg;
	env = &envs[ENVX(sys_getenvid())];
  801763:	e8 55 f9 ff ff       	call   8010bd <sys_getenvid>
  801768:	25 ff 03 00 00       	and    $0x3ff,%eax
  80176d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801770:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801775:	a3 3c 60 80 00       	mov    %eax,0x80603c
	if(from_env_store&&(env->env_id==*from_env_store))
  80177a:	85 f6                	test   %esi,%esi
  80177c:	74 29                	je     8017a7 <ipc_recv+0x53>
  80177e:	8b 40 4c             	mov    0x4c(%eax),%eax
  801781:	3b 06                	cmp    (%esi),%eax
  801783:	75 22                	jne    8017a7 <ipc_recv+0x53>
	{
		*from_env_store=0;
  801785:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  80178b:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("send:the reciver is sender\n");
  801791:	c7 04 24 b4 2d 80 00 	movl   $0x802db4,(%esp)
  801798:	e8 ec ea ff ff       	call   800289 <cprintf>
  80179d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017a2:	e9 8a 00 00 00       	jmp    801831 <ipc_recv+0xdd>
		return 0;
	}
	env = &envs[ENVX(sys_getenvid())];
  8017a7:	e8 11 f9 ff ff       	call   8010bd <sys_getenvid>
  8017ac:	25 ff 03 00 00       	and    $0x3ff,%eax
  8017b1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8017b4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8017b9:	a3 3c 60 80 00       	mov    %eax,0x80603c
	if((r=sys_ipc_recv(dstva))<0)
  8017be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c1:	89 04 24             	mov    %eax,(%esp)
  8017c4:	e8 f6 f5 ff ff       	call   800dbf <sys_ipc_recv>
  8017c9:	89 c3                	mov    %eax,%ebx
  8017cb:	85 c0                	test   %eax,%eax
  8017cd:	79 1a                	jns    8017e9 <ipc_recv+0x95>
	{
		*from_env_store=0;
  8017cf:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  8017d5:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("reciver failed\n");
  8017db:	c7 04 24 e8 2d 80 00 	movl   $0x802de8,(%esp)
  8017e2:	e8 a2 ea ff ff       	call   800289 <cprintf>
  8017e7:	eb 48                	jmp    801831 <ipc_recv+0xdd>
		return r;
	}
	else{//接收成功
		env = &envs[ENVX(sys_getenvid())];
  8017e9:	e8 cf f8 ff ff       	call   8010bd <sys_getenvid>
  8017ee:	25 ff 03 00 00       	and    $0x3ff,%eax
  8017f3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8017f6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8017fb:	a3 3c 60 80 00       	mov    %eax,0x80603c
		if(from_env_store)
  801800:	85 f6                	test   %esi,%esi
  801802:	74 05                	je     801809 <ipc_recv+0xb5>
			*from_env_store=env->env_ipc_from;	
  801804:	8b 40 74             	mov    0x74(%eax),%eax
  801807:	89 06                	mov    %eax,(%esi)
		if(perm_store)
  801809:	85 ff                	test   %edi,%edi
  80180b:	74 0a                	je     801817 <ipc_recv+0xc3>
			*perm_store=env->env_ipc_perm;
  80180d:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801812:	8b 40 78             	mov    0x78(%eax),%eax
  801815:	89 07                	mov    %eax,(%edi)
		env = &envs[ENVX(sys_getenvid())];
  801817:	e8 a1 f8 ff ff       	call   8010bd <sys_getenvid>
  80181c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801821:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801824:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801829:	a3 3c 60 80 00       	mov    %eax,0x80603c
		return env->env_ipc_value;
  80182e:	8b 58 70             	mov    0x70(%eax),%ebx
	}
	//panic("ipc_recv not implemented");
	return 0;
}
  801831:	89 d8                	mov    %ebx,%eax
  801833:	83 c4 0c             	add    $0xc,%esp
  801836:	5b                   	pop    %ebx
  801837:	5e                   	pop    %esi
  801838:	5f                   	pop    %edi
  801839:	5d                   	pop    %ebp
  80183a:	c3                   	ret    
  80183b:	00 00                	add    %al,(%eax)
  80183d:	00 00                	add    %al,(%eax)
	...

00801840 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	8b 45 08             	mov    0x8(%ebp),%eax
  801846:	05 00 00 00 30       	add    $0x30000000,%eax
  80184b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80184e:	5d                   	pop    %ebp
  80184f:	c3                   	ret    

00801850 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801856:	8b 45 08             	mov    0x8(%ebp),%eax
  801859:	89 04 24             	mov    %eax,(%esp)
  80185c:	e8 df ff ff ff       	call   801840 <fd2num>
  801861:	c1 e0 0c             	shl    $0xc,%eax
  801864:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801869:	c9                   	leave  
  80186a:	c3                   	ret    

0080186b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80186b:	55                   	push   %ebp
  80186c:	89 e5                	mov    %esp,%ebp
  80186e:	53                   	push   %ebx
  80186f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801872:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  801877:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801879:	89 d0                	mov    %edx,%eax
  80187b:	c1 e8 16             	shr    $0x16,%eax
  80187e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801885:	a8 01                	test   $0x1,%al
  801887:	74 10                	je     801899 <fd_alloc+0x2e>
  801889:	89 d0                	mov    %edx,%eax
  80188b:	c1 e8 0c             	shr    $0xc,%eax
  80188e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801895:	a8 01                	test   $0x1,%al
  801897:	75 09                	jne    8018a2 <fd_alloc+0x37>
			*fd_store = fd;
  801899:	89 0b                	mov    %ecx,(%ebx)
  80189b:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a0:	eb 19                	jmp    8018bb <fd_alloc+0x50>
			return 0;
  8018a2:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8018a8:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  8018ae:	75 c7                	jne    801877 <fd_alloc+0xc>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8018b0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8018b6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8018bb:	5b                   	pop    %ebx
  8018bc:	5d                   	pop    %ebp
  8018bd:	c3                   	ret    

008018be <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8018be:	55                   	push   %ebp
  8018bf:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8018c1:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  8018c5:	77 38                	ja     8018ff <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8018c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ca:	c1 e0 0c             	shl    $0xc,%eax
  8018cd:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  8018d3:	89 d0                	mov    %edx,%eax
  8018d5:	c1 e8 16             	shr    $0x16,%eax
  8018d8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8018df:	a8 01                	test   $0x1,%al
  8018e1:	74 1c                	je     8018ff <fd_lookup+0x41>
  8018e3:	89 d0                	mov    %edx,%eax
  8018e5:	c1 e8 0c             	shr    $0xc,%eax
  8018e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018ef:	a8 01                	test   $0x1,%al
  8018f1:	74 0c                	je     8018ff <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8018f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f6:	89 10                	mov    %edx,(%eax)
  8018f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8018fd:	eb 05                	jmp    801904 <fd_lookup+0x46>
	return 0;
  8018ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801904:	5d                   	pop    %ebp
  801905:	c3                   	ret    

00801906 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801906:	55                   	push   %ebp
  801907:	89 e5                	mov    %esp,%ebp
  801909:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80190c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80190f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801913:	8b 45 08             	mov    0x8(%ebp),%eax
  801916:	89 04 24             	mov    %eax,(%esp)
  801919:	e8 a0 ff ff ff       	call   8018be <fd_lookup>
  80191e:	85 c0                	test   %eax,%eax
  801920:	78 0e                	js     801930 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801922:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801925:	8b 55 0c             	mov    0xc(%ebp),%edx
  801928:	89 50 04             	mov    %edx,0x4(%eax)
  80192b:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801930:	c9                   	leave  
  801931:	c3                   	ret    

00801932 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801932:	55                   	push   %ebp
  801933:	89 e5                	mov    %esp,%ebp
  801935:	53                   	push   %ebx
  801936:	83 ec 14             	sub    $0x14,%esp
  801939:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80193c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80193f:	ba 04 60 80 00       	mov    $0x806004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801944:	b8 00 00 00 00       	mov    $0x0,%eax
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801949:	39 0d 04 60 80 00    	cmp    %ecx,0x806004
  80194f:	75 11                	jne    801962 <dev_lookup+0x30>
  801951:	eb 04                	jmp    801957 <dev_lookup+0x25>
  801953:	39 0a                	cmp    %ecx,(%edx)
  801955:	75 0b                	jne    801962 <dev_lookup+0x30>
			*dev = devtab[i];
  801957:	89 13                	mov    %edx,(%ebx)
  801959:	b8 00 00 00 00       	mov    $0x0,%eax
  80195e:	66 90                	xchg   %ax,%ax
  801960:	eb 35                	jmp    801997 <dev_lookup+0x65>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801962:	83 c0 01             	add    $0x1,%eax
  801965:	8b 14 85 74 2e 80 00 	mov    0x802e74(,%eax,4),%edx
  80196c:	85 d2                	test   %edx,%edx
  80196e:	75 e3                	jne    801953 <dev_lookup+0x21>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  801970:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801975:	8b 40 4c             	mov    0x4c(%eax),%eax
  801978:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80197c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801980:	c7 04 24 f8 2d 80 00 	movl   $0x802df8,(%esp)
  801987:	e8 fd e8 ff ff       	call   800289 <cprintf>
	*dev = 0;
  80198c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801992:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801997:	83 c4 14             	add    $0x14,%esp
  80199a:	5b                   	pop    %ebx
  80199b:	5d                   	pop    %ebp
  80199c:	c3                   	ret    

0080199d <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80199d:	55                   	push   %ebp
  80199e:	89 e5                	mov    %esp,%ebp
  8019a0:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019a3:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8019a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ad:	89 04 24             	mov    %eax,(%esp)
  8019b0:	e8 09 ff ff ff       	call   8018be <fd_lookup>
  8019b5:	89 c2                	mov    %eax,%edx
  8019b7:	85 c0                	test   %eax,%eax
  8019b9:	78 5a                	js     801a15 <fstat+0x78>
  8019bb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8019be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8019c5:	8b 00                	mov    (%eax),%eax
  8019c7:	89 04 24             	mov    %eax,(%esp)
  8019ca:	e8 63 ff ff ff       	call   801932 <dev_lookup>
  8019cf:	89 c2                	mov    %eax,%edx
  8019d1:	85 c0                	test   %eax,%eax
  8019d3:	78 40                	js     801a15 <fstat+0x78>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8019d5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  8019da:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8019dd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019e1:	74 32                	je     801a15 <fstat+0x78>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e6:	c6 00 00             	movb   $0x0,(%eax)
	stat->st_size = 0;
  8019e9:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  8019f0:	00 00 00 
	stat->st_isdir = 0;
  8019f3:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
  8019fa:	00 00 00 
	stat->st_dev = dev;
  8019fd:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801a00:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
	return (*dev->dev_stat)(fd, stat);
  801a06:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a0a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801a0d:	89 04 24             	mov    %eax,(%esp)
  801a10:	ff 52 14             	call   *0x14(%edx)
  801a13:	89 c2                	mov    %eax,%edx
}
  801a15:	89 d0                	mov    %edx,%eax
  801a17:	c9                   	leave  
  801a18:	c3                   	ret    

00801a19 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801a19:	55                   	push   %ebp
  801a1a:	89 e5                	mov    %esp,%ebp
  801a1c:	53                   	push   %ebx
  801a1d:	83 ec 24             	sub    $0x24,%esp
  801a20:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a26:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a2a:	89 1c 24             	mov    %ebx,(%esp)
  801a2d:	e8 8c fe ff ff       	call   8018be <fd_lookup>
  801a32:	85 c0                	test   %eax,%eax
  801a34:	78 61                	js     801a97 <ftruncate+0x7e>
  801a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a39:	8b 10                	mov    (%eax),%edx
  801a3b:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801a3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a42:	89 14 24             	mov    %edx,(%esp)
  801a45:	e8 e8 fe ff ff       	call   801932 <dev_lookup>
  801a4a:	85 c0                	test   %eax,%eax
  801a4c:	78 49                	js     801a97 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a4e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801a51:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801a55:	75 23                	jne    801a7a <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801a57:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801a5c:	8b 40 4c             	mov    0x4c(%eax),%eax
  801a5f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a63:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a67:	c7 04 24 18 2e 80 00 	movl   $0x802e18,(%esp)
  801a6e:	e8 16 e8 ff ff       	call   800289 <cprintf>
  801a73:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a78:	eb 1d                	jmp    801a97 <ftruncate+0x7e>
			env->env_id, fdnum); 
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801a7a:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801a7d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a82:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  801a86:	74 0f                	je     801a97 <ftruncate+0x7e>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801a88:	8b 42 18             	mov    0x18(%edx),%eax
  801a8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a8e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a92:	89 0c 24             	mov    %ecx,(%esp)
  801a95:	ff d0                	call   *%eax
}
  801a97:	83 c4 24             	add    $0x24,%esp
  801a9a:	5b                   	pop    %ebx
  801a9b:	5d                   	pop    %ebp
  801a9c:	c3                   	ret    

00801a9d <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801a9d:	55                   	push   %ebp
  801a9e:	89 e5                	mov    %esp,%ebp
  801aa0:	53                   	push   %ebx
  801aa1:	83 ec 24             	sub    $0x24,%esp
  801aa4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801aa7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aaa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aae:	89 1c 24             	mov    %ebx,(%esp)
  801ab1:	e8 08 fe ff ff       	call   8018be <fd_lookup>
  801ab6:	85 c0                	test   %eax,%eax
  801ab8:	78 68                	js     801b22 <write+0x85>
  801aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801abd:	8b 10                	mov    (%eax),%edx
  801abf:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac6:	89 14 24             	mov    %edx,(%esp)
  801ac9:	e8 64 fe ff ff       	call   801932 <dev_lookup>
  801ace:	85 c0                	test   %eax,%eax
  801ad0:	78 50                	js     801b22 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801ad2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801ad5:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801ad9:	75 23                	jne    801afe <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  801adb:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801ae0:	8b 40 4c             	mov    0x4c(%eax),%eax
  801ae3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ae7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aeb:	c7 04 24 39 2e 80 00 	movl   $0x802e39,(%esp)
  801af2:	e8 92 e7 ff ff       	call   800289 <cprintf>
  801af7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801afc:	eb 24                	jmp    801b22 <write+0x85>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801afe:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801b01:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b06:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  801b0a:	74 16                	je     801b22 <write+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801b0c:	8b 42 0c             	mov    0xc(%edx),%eax
  801b0f:	8b 55 10             	mov    0x10(%ebp),%edx
  801b12:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b16:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b19:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b1d:	89 0c 24             	mov    %ecx,(%esp)
  801b20:	ff d0                	call   *%eax
}
  801b22:	83 c4 24             	add    $0x24,%esp
  801b25:	5b                   	pop    %ebx
  801b26:	5d                   	pop    %ebp
  801b27:	c3                   	ret    

00801b28 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801b28:	55                   	push   %ebp
  801b29:	89 e5                	mov    %esp,%ebp
  801b2b:	53                   	push   %ebx
  801b2c:	83 ec 24             	sub    $0x24,%esp
  801b2f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b32:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b35:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b39:	89 1c 24             	mov    %ebx,(%esp)
  801b3c:	e8 7d fd ff ff       	call   8018be <fd_lookup>
  801b41:	85 c0                	test   %eax,%eax
  801b43:	78 6d                	js     801bb2 <read+0x8a>
  801b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b48:	8b 10                	mov    (%eax),%edx
  801b4a:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801b4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b51:	89 14 24             	mov    %edx,(%esp)
  801b54:	e8 d9 fd ff ff       	call   801932 <dev_lookup>
  801b59:	85 c0                	test   %eax,%eax
  801b5b:	78 55                	js     801bb2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801b5d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801b60:	8b 41 08             	mov    0x8(%ecx),%eax
  801b63:	83 e0 03             	and    $0x3,%eax
  801b66:	83 f8 01             	cmp    $0x1,%eax
  801b69:	75 23                	jne    801b8e <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  801b6b:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801b70:	8b 40 4c             	mov    0x4c(%eax),%eax
  801b73:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b77:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b7b:	c7 04 24 56 2e 80 00 	movl   $0x802e56,(%esp)
  801b82:	e8 02 e7 ff ff       	call   800289 <cprintf>
  801b87:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b8c:	eb 24                	jmp    801bb2 <read+0x8a>
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801b8e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801b91:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b96:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  801b9a:	74 16                	je     801bb2 <read+0x8a>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801b9c:	8b 42 08             	mov    0x8(%edx),%eax
  801b9f:	8b 55 10             	mov    0x10(%ebp),%edx
  801ba2:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ba6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ba9:	89 54 24 04          	mov    %edx,0x4(%esp)
  801bad:	89 0c 24             	mov    %ecx,(%esp)
  801bb0:	ff d0                	call   *%eax
}
  801bb2:	83 c4 24             	add    $0x24,%esp
  801bb5:	5b                   	pop    %ebx
  801bb6:	5d                   	pop    %ebp
  801bb7:	c3                   	ret    

00801bb8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801bb8:	55                   	push   %ebp
  801bb9:	89 e5                	mov    %esp,%ebp
  801bbb:	57                   	push   %edi
  801bbc:	56                   	push   %esi
  801bbd:	53                   	push   %ebx
  801bbe:	83 ec 0c             	sub    $0xc,%esp
  801bc1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801bc4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801bc7:	b8 00 00 00 00       	mov    $0x0,%eax
  801bcc:	85 f6                	test   %esi,%esi
  801bce:	74 36                	je     801c06 <readn+0x4e>
  801bd0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bd5:	ba 00 00 00 00       	mov    $0x0,%edx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801bda:	89 f0                	mov    %esi,%eax
  801bdc:	29 d0                	sub    %edx,%eax
  801bde:	89 44 24 08          	mov    %eax,0x8(%esp)
  801be2:	8d 04 17             	lea    (%edi,%edx,1),%eax
  801be5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bec:	89 04 24             	mov    %eax,(%esp)
  801bef:	e8 34 ff ff ff       	call   801b28 <read>
		if (m < 0)
  801bf4:	85 c0                	test   %eax,%eax
  801bf6:	78 0e                	js     801c06 <readn+0x4e>
			return m;
		if (m == 0)
  801bf8:	85 c0                	test   %eax,%eax
  801bfa:	74 08                	je     801c04 <readn+0x4c>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801bfc:	01 c3                	add    %eax,%ebx
  801bfe:	89 da                	mov    %ebx,%edx
  801c00:	39 f3                	cmp    %esi,%ebx
  801c02:	72 d6                	jb     801bda <readn+0x22>
  801c04:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801c06:	83 c4 0c             	add    $0xc,%esp
  801c09:	5b                   	pop    %ebx
  801c0a:	5e                   	pop    %esi
  801c0b:	5f                   	pop    %edi
  801c0c:	5d                   	pop    %ebp
  801c0d:	c3                   	ret    

00801c0e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801c0e:	55                   	push   %ebp
  801c0f:	89 e5                	mov    %esp,%ebp
  801c11:	83 ec 28             	sub    $0x28,%esp
  801c14:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801c17:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801c1a:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801c1d:	89 34 24             	mov    %esi,(%esp)
  801c20:	e8 1b fc ff ff       	call   801840 <fd2num>
  801c25:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c28:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c2c:	89 04 24             	mov    %eax,(%esp)
  801c2f:	e8 8a fc ff ff       	call   8018be <fd_lookup>
  801c34:	89 c3                	mov    %eax,%ebx
  801c36:	85 c0                	test   %eax,%eax
  801c38:	78 05                	js     801c3f <fd_close+0x31>
  801c3a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801c3d:	74 0d                	je     801c4c <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801c3f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801c43:	75 44                	jne    801c89 <fd_close+0x7b>
  801c45:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c4a:	eb 3d                	jmp    801c89 <fd_close+0x7b>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801c4c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c53:	8b 06                	mov    (%esi),%eax
  801c55:	89 04 24             	mov    %eax,(%esp)
  801c58:	e8 d5 fc ff ff       	call   801932 <dev_lookup>
  801c5d:	89 c3                	mov    %eax,%ebx
  801c5f:	85 c0                	test   %eax,%eax
  801c61:	78 16                	js     801c79 <fd_close+0x6b>
		if (dev->dev_close)
  801c63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c66:	8b 40 10             	mov    0x10(%eax),%eax
  801c69:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c6e:	85 c0                	test   %eax,%eax
  801c70:	74 07                	je     801c79 <fd_close+0x6b>
			r = (*dev->dev_close)(fd);
  801c72:	89 34 24             	mov    %esi,(%esp)
  801c75:	ff d0                	call   *%eax
  801c77:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801c79:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c84:	e8 e5 f2 ff ff       	call   800f6e <sys_page_unmap>
	return r;
}
  801c89:	89 d8                	mov    %ebx,%eax
  801c8b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801c8e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801c91:	89 ec                	mov    %ebp,%esp
  801c93:	5d                   	pop    %ebp
  801c94:	c3                   	ret    

00801c95 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801c95:	55                   	push   %ebp
  801c96:	89 e5                	mov    %esp,%ebp
  801c98:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c9b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801c9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ca2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca5:	89 04 24             	mov    %eax,(%esp)
  801ca8:	e8 11 fc ff ff       	call   8018be <fd_lookup>
  801cad:	85 c0                	test   %eax,%eax
  801caf:	78 13                	js     801cc4 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801cb1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801cb8:	00 
  801cb9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801cbc:	89 04 24             	mov    %eax,(%esp)
  801cbf:	e8 4a ff ff ff       	call   801c0e <fd_close>
}
  801cc4:	c9                   	leave  
  801cc5:	c3                   	ret    

00801cc6 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801cc6:	55                   	push   %ebp
  801cc7:	89 e5                	mov    %esp,%ebp
  801cc9:	83 ec 18             	sub    $0x18,%esp
  801ccc:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ccf:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801cd2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801cd9:	00 
  801cda:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdd:	89 04 24             	mov    %eax,(%esp)
  801ce0:	e8 5a 03 00 00       	call   80203f <open>
  801ce5:	89 c6                	mov    %eax,%esi
  801ce7:	85 c0                	test   %eax,%eax
  801ce9:	78 1b                	js     801d06 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801ceb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cee:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cf2:	89 34 24             	mov    %esi,(%esp)
  801cf5:	e8 a3 fc ff ff       	call   80199d <fstat>
  801cfa:	89 c3                	mov    %eax,%ebx
	close(fd);
  801cfc:	89 34 24             	mov    %esi,(%esp)
  801cff:	e8 91 ff ff ff       	call   801c95 <close>
  801d04:	89 de                	mov    %ebx,%esi
	return r;
}
  801d06:	89 f0                	mov    %esi,%eax
  801d08:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d0b:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d0e:	89 ec                	mov    %ebp,%esp
  801d10:	5d                   	pop    %ebp
  801d11:	c3                   	ret    

00801d12 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801d12:	55                   	push   %ebp
  801d13:	89 e5                	mov    %esp,%ebp
  801d15:	83 ec 38             	sub    $0x38,%esp
  801d18:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801d1b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801d1e:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801d21:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801d24:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d27:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2e:	89 04 24             	mov    %eax,(%esp)
  801d31:	e8 88 fb ff ff       	call   8018be <fd_lookup>
  801d36:	89 c3                	mov    %eax,%ebx
  801d38:	85 c0                	test   %eax,%eax
  801d3a:	0f 88 e1 00 00 00    	js     801e21 <dup+0x10f>
		return r;
	close(newfdnum);
  801d40:	89 3c 24             	mov    %edi,(%esp)
  801d43:	e8 4d ff ff ff       	call   801c95 <close>

	newfd = INDEX2FD(newfdnum);
  801d48:	89 f8                	mov    %edi,%eax
  801d4a:	c1 e0 0c             	shl    $0xc,%eax
  801d4d:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  801d53:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d56:	89 04 24             	mov    %eax,(%esp)
  801d59:	e8 f2 fa ff ff       	call   801850 <fd2data>
  801d5e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801d60:	89 34 24             	mov    %esi,(%esp)
  801d63:	e8 e8 fa ff ff       	call   801850 <fd2data>
  801d68:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  801d6b:	89 d8                	mov    %ebx,%eax
  801d6d:	c1 e8 16             	shr    $0x16,%eax
  801d70:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801d77:	a8 01                	test   $0x1,%al
  801d79:	74 45                	je     801dc0 <dup+0xae>
  801d7b:	89 da                	mov    %ebx,%edx
  801d7d:	c1 ea 0c             	shr    $0xc,%edx
  801d80:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801d87:	a8 01                	test   $0x1,%al
  801d89:	74 35                	je     801dc0 <dup+0xae>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  801d8b:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801d92:	25 07 0e 00 00       	and    $0xe07,%eax
  801d97:	89 44 24 10          	mov    %eax,0x10(%esp)
  801d9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d9e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801da2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801da9:	00 
  801daa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801db5:	e8 12 f2 ff ff       	call   800fcc <sys_page_map>
  801dba:	89 c3                	mov    %eax,%ebx
  801dbc:	85 c0                	test   %eax,%eax
  801dbe:	78 3e                	js     801dfe <dup+0xec>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  801dc0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801dc3:	89 d0                	mov    %edx,%eax
  801dc5:	c1 e8 0c             	shr    $0xc,%eax
  801dc8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801dcf:	25 07 0e 00 00       	and    $0xe07,%eax
  801dd4:	89 44 24 10          	mov    %eax,0x10(%esp)
  801dd8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801ddc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801de3:	00 
  801de4:	89 54 24 04          	mov    %edx,0x4(%esp)
  801de8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801def:	e8 d8 f1 ff ff       	call   800fcc <sys_page_map>
  801df4:	89 c3                	mov    %eax,%ebx
  801df6:	85 c0                	test   %eax,%eax
  801df8:	78 04                	js     801dfe <dup+0xec>
		goto err;
  801dfa:	89 fb                	mov    %edi,%ebx
  801dfc:	eb 23                	jmp    801e21 <dup+0x10f>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801dfe:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e02:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e09:	e8 60 f1 ff ff       	call   800f6e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801e0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e11:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e15:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e1c:	e8 4d f1 ff ff       	call   800f6e <sys_page_unmap>
	return r;
}
  801e21:	89 d8                	mov    %ebx,%eax
  801e23:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801e26:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801e29:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801e2c:	89 ec                	mov    %ebp,%esp
  801e2e:	5d                   	pop    %ebp
  801e2f:	c3                   	ret    

00801e30 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801e30:	55                   	push   %ebp
  801e31:	89 e5                	mov    %esp,%ebp
  801e33:	53                   	push   %ebx
  801e34:	83 ec 04             	sub    $0x4,%esp
  801e37:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801e3c:	89 1c 24             	mov    %ebx,(%esp)
  801e3f:	e8 51 fe ff ff       	call   801c95 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801e44:	83 c3 01             	add    $0x1,%ebx
  801e47:	83 fb 20             	cmp    $0x20,%ebx
  801e4a:	75 f0                	jne    801e3c <close_all+0xc>
		close(i);
}
  801e4c:	83 c4 04             	add    $0x4,%esp
  801e4f:	5b                   	pop    %ebx
  801e50:	5d                   	pop    %ebp
  801e51:	c3                   	ret    
	...

00801e54 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801e54:	55                   	push   %ebp
  801e55:	89 e5                	mov    %esp,%ebp
  801e57:	53                   	push   %ebx
  801e58:	83 ec 14             	sub    $0x14,%esp
  801e5b:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801e5d:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  801e63:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801e6a:	00 
  801e6b:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801e72:	00 
  801e73:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e77:	89 14 24             	mov    %edx,(%esp)
  801e7a:	e8 21 f8 ff ff       	call   8016a0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801e7f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e86:	00 
  801e87:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e8b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e92:	e8 bd f8 ff ff       	call   801754 <ipc_recv>
}
  801e97:	83 c4 14             	add    $0x14,%esp
  801e9a:	5b                   	pop    %ebx
  801e9b:	5d                   	pop    %ebp
  801e9c:	c3                   	ret    

00801e9d <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801e9d:	55                   	push   %ebp
  801e9e:	89 e5                	mov    %esp,%ebp
  801ea0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ea3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ea8:	b8 08 00 00 00       	mov    $0x8,%eax
  801ead:	e8 a2 ff ff ff       	call   801e54 <fsipc>
}
  801eb2:	c9                   	leave  
  801eb3:	c3                   	ret    

00801eb4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801eb4:	55                   	push   %ebp
  801eb5:	89 e5                	mov    %esp,%ebp
  801eb7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801eba:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebd:	8b 40 0c             	mov    0xc(%eax),%eax
  801ec0:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.set_size.req_size = newsize;
  801ec5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec8:	a3 04 30 80 00       	mov    %eax,0x803004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801ecd:	ba 00 00 00 00       	mov    $0x0,%edx
  801ed2:	b8 02 00 00 00       	mov    $0x2,%eax
  801ed7:	e8 78 ff ff ff       	call   801e54 <fsipc>
}
  801edc:	c9                   	leave  
  801edd:	c3                   	ret    

00801ede <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801ede:	55                   	push   %ebp
  801edf:	89 e5                	mov    %esp,%ebp
  801ee1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801ee4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee7:	8b 40 0c             	mov    0xc(%eax),%eax
  801eea:	a3 00 30 80 00       	mov    %eax,0x803000
	return fsipc(FSREQ_FLUSH, NULL);
  801eef:	ba 00 00 00 00       	mov    $0x0,%edx
  801ef4:	b8 06 00 00 00       	mov    $0x6,%eax
  801ef9:	e8 56 ff ff ff       	call   801e54 <fsipc>
}
  801efe:	c9                   	leave  
  801eff:	c3                   	ret    

00801f00 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	53                   	push   %ebx
  801f04:	83 ec 14             	sub    $0x14,%esp
  801f07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801f0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0d:	8b 40 0c             	mov    0xc(%eax),%eax
  801f10:	a3 00 30 80 00       	mov    %eax,0x803000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801f15:	ba 00 00 00 00       	mov    $0x0,%edx
  801f1a:	b8 05 00 00 00       	mov    $0x5,%eax
  801f1f:	e8 30 ff ff ff       	call   801e54 <fsipc>
  801f24:	85 c0                	test   %eax,%eax
  801f26:	78 2b                	js     801f53 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801f28:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801f2f:	00 
  801f30:	89 1c 24             	mov    %ebx,(%esp)
  801f33:	e8 b9 e9 ff ff       	call   8008f1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801f38:	a1 80 30 80 00       	mov    0x803080,%eax
  801f3d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801f43:	a1 84 30 80 00       	mov    0x803084,%eax
  801f48:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801f4e:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801f53:	83 c4 14             	add    $0x14,%esp
  801f56:	5b                   	pop    %ebx
  801f57:	5d                   	pop    %ebp
  801f58:	c3                   	ret    

00801f59 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801f59:	55                   	push   %ebp
  801f5a:	89 e5                	mov    %esp,%ebp
  801f5c:	83 ec 18             	sub    $0x18,%esp
  801f5f:	8b 55 10             	mov    0x10(%ebp),%edx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	ssize_t writesize;
	size_t bufsize;
	fsipcbuf.write.req_fileid=fd->fd_file.id;
  801f62:	8b 45 08             	mov    0x8(%ebp),%eax
  801f65:	8b 40 0c             	mov    0xc(%eax),%eax
  801f68:	a3 00 30 80 00       	mov    %eax,0x803000
	bufsize=sizeof(fsipcbuf.write.req_buf);
	if(n<bufsize)
  801f6d:	89 d0                	mov    %edx,%eax
  801f6f:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  801f75:	76 05                	jbe    801f7c <devfile_write+0x23>
  801f77:	b8 f8 0f 00 00       	mov    $0xff8,%eax
		bufsize=n;	
	fsipcbuf.write.req_n=n;
  801f7c:	89 15 04 30 80 00    	mov    %edx,0x803004
	memmove((void*)fsipcbuf.write.req_buf,buf,bufsize);
  801f82:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f86:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f89:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f8d:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  801f94:	e8 5f eb ff ff       	call   800af8 <memmove>
	writesize=(ssize_t)fsipc(FSREQ_WRITE,NULL);
  801f99:	ba 00 00 00 00       	mov    $0x0,%edx
  801f9e:	b8 04 00 00 00       	mov    $0x4,%eax
  801fa3:	e8 ac fe ff ff       	call   801e54 <fsipc>
	return writesize;
	//panic("devfile_write not implemented");
}
  801fa8:	c9                   	leave  
  801fa9:	c3                   	ret    

00801faa <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801faa:	55                   	push   %ebp
  801fab:	89 e5                	mov    %esp,%ebp
  801fad:	53                   	push   %ebx
  801fae:	83 ec 14             	sub    $0x14,%esp
	// system server.
	// LAB 5: Your code here
	ssize_t readsize;
	if(debug)
		cprintf("devfile_read:fileid=%x readsize=%x\n",fd->fd_file.id,n);
	fsipcbuf.read.req_fileid=fd->fd_file.id;
  801fb1:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb4:	8b 40 0c             	mov    0xc(%eax),%eax
  801fb7:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.read.req_n=n;
  801fbc:	8b 45 10             	mov    0x10(%ebp),%eax
  801fbf:	a3 04 30 80 00       	mov    %eax,0x803004
	readsize=(ssize_t)fsipc(FSREQ_READ,&fsipcbuf);
  801fc4:	ba 00 30 80 00       	mov    $0x803000,%edx
  801fc9:	b8 03 00 00 00       	mov    $0x3,%eax
  801fce:	e8 81 fe ff ff       	call   801e54 <fsipc>
  801fd3:	89 c3                	mov    %eax,%ebx
	//cprintf("readsize=%d\n",readsize);
	if(debug)
		cprintf("devfile_read:buf1=%s\nbuf2=%s\n",(char*)&fsipcbuf,fsipcbuf.readRet.ret_buf);
	if(readsize>0)
  801fd5:	85 c0                	test   %eax,%eax
  801fd7:	7e 17                	jle    801ff0 <devfile_read+0x46>
		memmove(buf,(void*)&fsipcbuf,(size_t)readsize);
  801fd9:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fdd:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801fe4:	00 
  801fe5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fe8:	89 04 24             	mov    %eax,(%esp)
  801feb:	e8 08 eb ff ff       	call   800af8 <memmove>
	//cprintf("readsize=%d",readsize);
	return readsize;
	//panic("devfile_read not implemented");
}
  801ff0:	89 d8                	mov    %ebx,%eax
  801ff2:	83 c4 14             	add    $0x14,%esp
  801ff5:	5b                   	pop    %ebx
  801ff6:	5d                   	pop    %ebp
  801ff7:	c3                   	ret    

00801ff8 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801ff8:	55                   	push   %ebp
  801ff9:	89 e5                	mov    %esp,%ebp
  801ffb:	53                   	push   %ebx
  801ffc:	83 ec 14             	sub    $0x14,%esp
  801fff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  802002:	89 1c 24             	mov    %ebx,(%esp)
  802005:	e8 96 e8 ff ff       	call   8008a0 <strlen>
  80200a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  80200f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802014:	7f 21                	jg     802037 <remove+0x3f>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  802016:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80201a:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  802021:	e8 cb e8 ff ff       	call   8008f1 <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  802026:	ba 00 00 00 00       	mov    $0x0,%edx
  80202b:	b8 07 00 00 00       	mov    $0x7,%eax
  802030:	e8 1f fe ff ff       	call   801e54 <fsipc>
  802035:	89 c2                	mov    %eax,%edx
}
  802037:	89 d0                	mov    %edx,%eax
  802039:	83 c4 14             	add    $0x14,%esp
  80203c:	5b                   	pop    %ebx
  80203d:	5d                   	pop    %ebp
  80203e:	c3                   	ret    

0080203f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80203f:	55                   	push   %ebp
  802040:	89 e5                	mov    %esp,%ebp
  802042:	56                   	push   %esi
  802043:	53                   	push   %ebx
  802044:	83 ec 30             	sub    $0x30,%esp

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;
	void *page;
	if((r=fd_alloc(&fd))<0){
  802047:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80204a:	89 04 24             	mov    %eax,(%esp)
  80204d:	e8 19 f8 ff ff       	call   80186b <fd_alloc>
  802052:	89 c3                	mov    %eax,%ebx
  802054:	85 c0                	test   %eax,%eax
  802056:	79 18                	jns    802070 <open+0x31>
		fd_close(fd,0);
  802058:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80205f:	00 
  802060:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802063:	89 04 24             	mov    %eax,(%esp)
  802066:	e8 a3 fb ff ff       	call   801c0e <fd_close>
  80206b:	e9 9f 00 00 00       	jmp    80210f <open+0xd0>
		return r;
	}
	//cprintf("open:fd=%x\n",fd);
	strcpy(fsipcbuf.open.req_path,path);
  802070:	8b 45 08             	mov    0x8(%ebp),%eax
  802073:	89 44 24 04          	mov    %eax,0x4(%esp)
  802077:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  80207e:	e8 6e e8 ff ff       	call   8008f1 <strcpy>
	fsipcbuf.open.req_omode=mode;
  802083:	8b 45 0c             	mov    0xc(%ebp),%eax
  802086:	a3 00 34 80 00       	mov    %eax,0x803400
	page=(void*)fd2data(fd);
  80208b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80208e:	89 04 24             	mov    %eax,(%esp)
  802091:	e8 ba f7 ff ff       	call   801850 <fd2data>
  802096:	89 c6                	mov    %eax,%esi
	if((r=fsipc(FSREQ_OPEN,(void*)fd))<0)
  802098:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80209b:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a0:	e8 af fd ff ff       	call   801e54 <fsipc>
  8020a5:	89 c3                	mov    %eax,%ebx
  8020a7:	85 c0                	test   %eax,%eax
  8020a9:	79 15                	jns    8020c0 <open+0x81>
	{
		fd_close(fd,1);
  8020ab:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8020b2:	00 
  8020b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b6:	89 04 24             	mov    %eax,(%esp)
  8020b9:	e8 50 fb ff ff       	call   801c0e <fd_close>
  8020be:	eb 4f                	jmp    80210f <open+0xd0>
		return r;	
	}
	//cprintf("open:page=%x\n",page);
	if((r=sys_page_map(0,(void*)fd,0,(void*)page,PTE_P | PTE_W | PTE_U))<0)
  8020c0:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8020c7:	00 
  8020c8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8020cc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8020d3:	00 
  8020d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020e2:	e8 e5 ee ff ff       	call   800fcc <sys_page_map>
  8020e7:	89 c3                	mov    %eax,%ebx
  8020e9:	85 c0                	test   %eax,%eax
  8020eb:	79 15                	jns    802102 <open+0xc3>
	{
		fd_close(fd,1);
  8020ed:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8020f4:	00 
  8020f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f8:	89 04 24             	mov    %eax,(%esp)
  8020fb:	e8 0e fb ff ff       	call   801c0e <fd_close>
  802100:	eb 0d                	jmp    80210f <open+0xd0>
		return r;
	}
	//cprintf("open:fileid=%x\n",fd->fd_file.id);
	return fd2num(fd);
  802102:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802105:	89 04 24             	mov    %eax,(%esp)
  802108:	e8 33 f7 ff ff       	call   801840 <fd2num>
  80210d:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  80210f:	89 d8                	mov    %ebx,%eax
  802111:	83 c4 30             	add    $0x30,%esp
  802114:	5b                   	pop    %ebx
  802115:	5e                   	pop    %esi
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    
	...

00802120 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802120:	55                   	push   %ebp
  802121:	89 e5                	mov    %esp,%ebp
  802123:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  802126:	c7 44 24 04 80 2e 80 	movl   $0x802e80,0x4(%esp)
  80212d:	00 
  80212e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802131:	89 04 24             	mov    %eax,(%esp)
  802134:	e8 b8 e7 ff ff       	call   8008f1 <strcpy>
	return 0;
}
  802139:	b8 00 00 00 00       	mov    $0x0,%eax
  80213e:	c9                   	leave  
  80213f:	c3                   	ret    

00802140 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802140:	55                   	push   %ebp
  802141:	89 e5                	mov    %esp,%ebp
  802143:	83 ec 08             	sub    $0x8,%esp
	return nsipc_close(fd->fd_sock.sockid);
  802146:	8b 45 08             	mov    0x8(%ebp),%eax
  802149:	8b 40 0c             	mov    0xc(%eax),%eax
  80214c:	89 04 24             	mov    %eax,(%esp)
  80214f:	e8 9e 02 00 00       	call   8023f2 <nsipc_close>
}
  802154:	c9                   	leave  
  802155:	c3                   	ret    

00802156 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802156:	55                   	push   %ebp
  802157:	89 e5                	mov    %esp,%ebp
  802159:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80215c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802163:	00 
  802164:	8b 45 10             	mov    0x10(%ebp),%eax
  802167:	89 44 24 08          	mov    %eax,0x8(%esp)
  80216b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80216e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802172:	8b 45 08             	mov    0x8(%ebp),%eax
  802175:	8b 40 0c             	mov    0xc(%eax),%eax
  802178:	89 04 24             	mov    %eax,(%esp)
  80217b:	e8 ae 02 00 00       	call   80242e <nsipc_send>
}
  802180:	c9                   	leave  
  802181:	c3                   	ret    

00802182 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  802182:	55                   	push   %ebp
  802183:	89 e5                	mov    %esp,%ebp
  802185:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802188:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80218f:	00 
  802190:	8b 45 10             	mov    0x10(%ebp),%eax
  802193:	89 44 24 08          	mov    %eax,0x8(%esp)
  802197:	8b 45 0c             	mov    0xc(%ebp),%eax
  80219a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80219e:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a1:	8b 40 0c             	mov    0xc(%eax),%eax
  8021a4:	89 04 24             	mov    %eax,(%esp)
  8021a7:	e8 f5 02 00 00       	call   8024a1 <nsipc_recv>
}
  8021ac:	c9                   	leave  
  8021ad:	c3                   	ret    

008021ae <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  8021ae:	55                   	push   %ebp
  8021af:	89 e5                	mov    %esp,%ebp
  8021b1:	56                   	push   %esi
  8021b2:	53                   	push   %ebx
  8021b3:	83 ec 20             	sub    $0x20,%esp
  8021b6:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8021b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021bb:	89 04 24             	mov    %eax,(%esp)
  8021be:	e8 a8 f6 ff ff       	call   80186b <fd_alloc>
  8021c3:	89 c3                	mov    %eax,%ebx
  8021c5:	85 c0                	test   %eax,%eax
  8021c7:	78 21                	js     8021ea <alloc_sockfd+0x3c>
  8021c9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8021d0:	00 
  8021d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021df:	e8 46 ee ff ff       	call   80102a <sys_page_alloc>
  8021e4:	89 c3                	mov    %eax,%ebx
  8021e6:	85 c0                	test   %eax,%eax
  8021e8:	79 0a                	jns    8021f4 <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U)) < 0) {
		nsipc_close(sockid);
  8021ea:	89 34 24             	mov    %esi,(%esp)
  8021ed:	e8 00 02 00 00       	call   8023f2 <nsipc_close>
  8021f2:	eb 28                	jmp    80221c <alloc_sockfd+0x6e>
		return r;
	}

	sfd->fd_dev_id = devsock.dev_id;
  8021f4:	8b 15 20 60 80 00    	mov    0x806020,%edx
  8021fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021fd:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8021ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802202:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802209:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80220c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80220f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802212:	89 04 24             	mov    %eax,(%esp)
  802215:	e8 26 f6 ff ff       	call   801840 <fd2num>
  80221a:	89 c3                	mov    %eax,%ebx
}
  80221c:	89 d8                	mov    %ebx,%eax
  80221e:	83 c4 20             	add    $0x20,%esp
  802221:	5b                   	pop    %ebx
  802222:	5e                   	pop    %esi
  802223:	5d                   	pop    %ebp
  802224:	c3                   	ret    

00802225 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802225:	55                   	push   %ebp
  802226:	89 e5                	mov    %esp,%ebp
  802228:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80222b:	8b 45 10             	mov    0x10(%ebp),%eax
  80222e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802232:	8b 45 0c             	mov    0xc(%ebp),%eax
  802235:	89 44 24 04          	mov    %eax,0x4(%esp)
  802239:	8b 45 08             	mov    0x8(%ebp),%eax
  80223c:	89 04 24             	mov    %eax,(%esp)
  80223f:	e8 62 01 00 00       	call   8023a6 <nsipc_socket>
  802244:	85 c0                	test   %eax,%eax
  802246:	78 05                	js     80224d <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802248:	e8 61 ff ff ff       	call   8021ae <alloc_sockfd>
}
  80224d:	c9                   	leave  
  80224e:	66 90                	xchg   %ax,%ax
  802250:	c3                   	ret    

00802251 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802251:	55                   	push   %ebp
  802252:	89 e5                	mov    %esp,%ebp
  802254:	83 ec 18             	sub    $0x18,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802257:	8d 55 fc             	lea    -0x4(%ebp),%edx
  80225a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80225e:	89 04 24             	mov    %eax,(%esp)
  802261:	e8 58 f6 ff ff       	call   8018be <fd_lookup>
  802266:	89 c2                	mov    %eax,%edx
  802268:	85 c0                	test   %eax,%eax
  80226a:	78 15                	js     802281 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80226c:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  80226f:	8b 01                	mov    (%ecx),%eax
  802271:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  802276:	3b 05 20 60 80 00    	cmp    0x806020,%eax
  80227c:	75 03                	jne    802281 <fd2sockid+0x30>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80227e:	8b 51 0c             	mov    0xc(%ecx),%edx
}
  802281:	89 d0                	mov    %edx,%eax
  802283:	c9                   	leave  
  802284:	c3                   	ret    

00802285 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  802285:	55                   	push   %ebp
  802286:	89 e5                	mov    %esp,%ebp
  802288:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80228b:	8b 45 08             	mov    0x8(%ebp),%eax
  80228e:	e8 be ff ff ff       	call   802251 <fd2sockid>
  802293:	85 c0                	test   %eax,%eax
  802295:	78 0f                	js     8022a6 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802297:	8b 55 0c             	mov    0xc(%ebp),%edx
  80229a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80229e:	89 04 24             	mov    %eax,(%esp)
  8022a1:	e8 2a 01 00 00       	call   8023d0 <nsipc_listen>
}
  8022a6:	c9                   	leave  
  8022a7:	c3                   	ret    

008022a8 <connect>:
	return nsipc_close(fd->fd_sock.sockid);
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8022a8:	55                   	push   %ebp
  8022a9:	89 e5                	mov    %esp,%ebp
  8022ab:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8022ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b1:	e8 9b ff ff ff       	call   802251 <fd2sockid>
  8022b6:	85 c0                	test   %eax,%eax
  8022b8:	78 16                	js     8022d0 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  8022ba:	8b 55 10             	mov    0x10(%ebp),%edx
  8022bd:	89 54 24 08          	mov    %edx,0x8(%esp)
  8022c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022c4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022c8:	89 04 24             	mov    %eax,(%esp)
  8022cb:	e8 51 02 00 00       	call   802521 <nsipc_connect>
}
  8022d0:	c9                   	leave  
  8022d1:	c3                   	ret    

008022d2 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  8022d2:	55                   	push   %ebp
  8022d3:	89 e5                	mov    %esp,%ebp
  8022d5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8022d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022db:	e8 71 ff ff ff       	call   802251 <fd2sockid>
  8022e0:	85 c0                	test   %eax,%eax
  8022e2:	78 0f                	js     8022f3 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8022e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022e7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022eb:	89 04 24             	mov    %eax,(%esp)
  8022ee:	e8 19 01 00 00       	call   80240c <nsipc_shutdown>
}
  8022f3:	c9                   	leave  
  8022f4:	c3                   	ret    

008022f5 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8022f5:	55                   	push   %ebp
  8022f6:	89 e5                	mov    %esp,%ebp
  8022f8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8022fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8022fe:	e8 4e ff ff ff       	call   802251 <fd2sockid>
  802303:	85 c0                	test   %eax,%eax
  802305:	78 16                	js     80231d <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  802307:	8b 55 10             	mov    0x10(%ebp),%edx
  80230a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80230e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802311:	89 54 24 04          	mov    %edx,0x4(%esp)
  802315:	89 04 24             	mov    %eax,(%esp)
  802318:	e8 43 02 00 00       	call   802560 <nsipc_bind>
}
  80231d:	c9                   	leave  
  80231e:	c3                   	ret    

0080231f <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80231f:	55                   	push   %ebp
  802320:	89 e5                	mov    %esp,%ebp
  802322:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802325:	8b 45 08             	mov    0x8(%ebp),%eax
  802328:	e8 24 ff ff ff       	call   802251 <fd2sockid>
  80232d:	85 c0                	test   %eax,%eax
  80232f:	78 1f                	js     802350 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802331:	8b 55 10             	mov    0x10(%ebp),%edx
  802334:	89 54 24 08          	mov    %edx,0x8(%esp)
  802338:	8b 55 0c             	mov    0xc(%ebp),%edx
  80233b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80233f:	89 04 24             	mov    %eax,(%esp)
  802342:	e8 58 02 00 00       	call   80259f <nsipc_accept>
  802347:	85 c0                	test   %eax,%eax
  802349:	78 05                	js     802350 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80234b:	e8 5e fe ff ff       	call   8021ae <alloc_sockfd>
}
  802350:	c9                   	leave  
  802351:	c3                   	ret    
	...

00802360 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802360:	55                   	push   %ebp
  802361:	89 e5                	mov    %esp,%ebp
  802363:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802366:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  80236c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802373:	00 
  802374:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  80237b:	00 
  80237c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802380:	89 14 24             	mov    %edx,(%esp)
  802383:	e8 18 f3 ff ff       	call   8016a0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802388:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80238f:	00 
  802390:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802397:	00 
  802398:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80239f:	e8 b0 f3 ff ff       	call   801754 <ipc_recv>
}
  8023a4:	c9                   	leave  
  8023a5:	c3                   	ret    

008023a6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  8023a6:	55                   	push   %ebp
  8023a7:	89 e5                	mov    %esp,%ebp
  8023a9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8023ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8023af:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.socket.req_type = type;
  8023b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023b7:	a3 04 50 80 00       	mov    %eax,0x805004
	nsipcbuf.socket.req_protocol = protocol;
  8023bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8023bf:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SOCKET);
  8023c4:	b8 09 00 00 00       	mov    $0x9,%eax
  8023c9:	e8 92 ff ff ff       	call   802360 <nsipc>
}
  8023ce:	c9                   	leave  
  8023cf:	c3                   	ret    

008023d0 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  8023d0:	55                   	push   %ebp
  8023d1:	89 e5                	mov    %esp,%ebp
  8023d3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8023d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8023d9:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.listen.req_backlog = backlog;
  8023de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023e1:	a3 04 50 80 00       	mov    %eax,0x805004
	return nsipc(NSREQ_LISTEN);
  8023e6:	b8 06 00 00 00       	mov    $0x6,%eax
  8023eb:	e8 70 ff ff ff       	call   802360 <nsipc>
}
  8023f0:	c9                   	leave  
  8023f1:	c3                   	ret    

008023f2 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  8023f2:	55                   	push   %ebp
  8023f3:	89 e5                	mov    %esp,%ebp
  8023f5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8023f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8023fb:	a3 00 50 80 00       	mov    %eax,0x805000
	return nsipc(NSREQ_CLOSE);
  802400:	b8 04 00 00 00       	mov    $0x4,%eax
  802405:	e8 56 ff ff ff       	call   802360 <nsipc>
}
  80240a:	c9                   	leave  
  80240b:	c3                   	ret    

0080240c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80240c:	55                   	push   %ebp
  80240d:	89 e5                	mov    %esp,%ebp
  80240f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802412:	8b 45 08             	mov    0x8(%ebp),%eax
  802415:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.shutdown.req_how = how;
  80241a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80241d:	a3 04 50 80 00       	mov    %eax,0x805004
	return nsipc(NSREQ_SHUTDOWN);
  802422:	b8 03 00 00 00       	mov    $0x3,%eax
  802427:	e8 34 ff ff ff       	call   802360 <nsipc>
}
  80242c:	c9                   	leave  
  80242d:	c3                   	ret    

0080242e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80242e:	55                   	push   %ebp
  80242f:	89 e5                	mov    %esp,%ebp
  802431:	53                   	push   %ebx
  802432:	83 ec 14             	sub    $0x14,%esp
  802435:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802438:	8b 45 08             	mov    0x8(%ebp),%eax
  80243b:	a3 00 50 80 00       	mov    %eax,0x805000
	assert(size < 1600);
  802440:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802446:	7e 24                	jle    80246c <nsipc_send+0x3e>
  802448:	c7 44 24 0c 8c 2e 80 	movl   $0x802e8c,0xc(%esp)
  80244f:	00 
  802450:	c7 44 24 08 98 2e 80 	movl   $0x802e98,0x8(%esp)
  802457:	00 
  802458:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  80245f:	00 
  802460:	c7 04 24 ad 2e 80 00 	movl   $0x802ead,(%esp)
  802467:	e8 50 dd ff ff       	call   8001bc <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80246c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802470:	8b 45 0c             	mov    0xc(%ebp),%eax
  802473:	89 44 24 04          	mov    %eax,0x4(%esp)
  802477:	c7 04 24 0c 50 80 00 	movl   $0x80500c,(%esp)
  80247e:	e8 75 e6 ff ff       	call   800af8 <memmove>
	nsipcbuf.send.req_size = size;
  802483:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	nsipcbuf.send.req_flags = flags;
  802489:	8b 45 14             	mov    0x14(%ebp),%eax
  80248c:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SEND);
  802491:	b8 08 00 00 00       	mov    $0x8,%eax
  802496:	e8 c5 fe ff ff       	call   802360 <nsipc>
}
  80249b:	83 c4 14             	add    $0x14,%esp
  80249e:	5b                   	pop    %ebx
  80249f:	5d                   	pop    %ebp
  8024a0:	c3                   	ret    

008024a1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8024a1:	55                   	push   %ebp
  8024a2:	89 e5                	mov    %esp,%ebp
  8024a4:	56                   	push   %esi
  8024a5:	53                   	push   %ebx
  8024a6:	83 ec 10             	sub    $0x10,%esp
  8024a9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8024ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8024af:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.recv.req_len = len;
  8024b4:	89 35 04 50 80 00    	mov    %esi,0x805004
	nsipcbuf.recv.req_flags = flags;
  8024ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8024bd:	a3 08 50 80 00       	mov    %eax,0x805008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8024c2:	b8 07 00 00 00       	mov    $0x7,%eax
  8024c7:	e8 94 fe ff ff       	call   802360 <nsipc>
  8024cc:	89 c3                	mov    %eax,%ebx
  8024ce:	85 c0                	test   %eax,%eax
  8024d0:	78 46                	js     802518 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8024d2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8024d7:	7f 04                	jg     8024dd <nsipc_recv+0x3c>
  8024d9:	39 c6                	cmp    %eax,%esi
  8024db:	7d 24                	jge    802501 <nsipc_recv+0x60>
  8024dd:	c7 44 24 0c b9 2e 80 	movl   $0x802eb9,0xc(%esp)
  8024e4:	00 
  8024e5:	c7 44 24 08 98 2e 80 	movl   $0x802e98,0x8(%esp)
  8024ec:	00 
  8024ed:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  8024f4:	00 
  8024f5:	c7 04 24 ad 2e 80 00 	movl   $0x802ead,(%esp)
  8024fc:	e8 bb dc ff ff       	call   8001bc <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802501:	89 44 24 08          	mov    %eax,0x8(%esp)
  802505:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80250c:	00 
  80250d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802510:	89 04 24             	mov    %eax,(%esp)
  802513:	e8 e0 e5 ff ff       	call   800af8 <memmove>
	}

	return r;
}
  802518:	89 d8                	mov    %ebx,%eax
  80251a:	83 c4 10             	add    $0x10,%esp
  80251d:	5b                   	pop    %ebx
  80251e:	5e                   	pop    %esi
  80251f:	5d                   	pop    %ebp
  802520:	c3                   	ret    

00802521 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802521:	55                   	push   %ebp
  802522:	89 e5                	mov    %esp,%ebp
  802524:	53                   	push   %ebx
  802525:	83 ec 14             	sub    $0x14,%esp
  802528:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80252b:	8b 45 08             	mov    0x8(%ebp),%eax
  80252e:	a3 00 50 80 00       	mov    %eax,0x805000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802533:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802537:	8b 45 0c             	mov    0xc(%ebp),%eax
  80253a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80253e:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  802545:	e8 ae e5 ff ff       	call   800af8 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80254a:	89 1d 14 50 80 00    	mov    %ebx,0x805014
	return nsipc(NSREQ_CONNECT);
  802550:	b8 05 00 00 00       	mov    $0x5,%eax
  802555:	e8 06 fe ff ff       	call   802360 <nsipc>
}
  80255a:	83 c4 14             	add    $0x14,%esp
  80255d:	5b                   	pop    %ebx
  80255e:	5d                   	pop    %ebp
  80255f:	c3                   	ret    

00802560 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802560:	55                   	push   %ebp
  802561:	89 e5                	mov    %esp,%ebp
  802563:	53                   	push   %ebx
  802564:	83 ec 14             	sub    $0x14,%esp
  802567:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80256a:	8b 45 08             	mov    0x8(%ebp),%eax
  80256d:	a3 00 50 80 00       	mov    %eax,0x805000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802572:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802576:	8b 45 0c             	mov    0xc(%ebp),%eax
  802579:	89 44 24 04          	mov    %eax,0x4(%esp)
  80257d:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  802584:	e8 6f e5 ff ff       	call   800af8 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802589:	89 1d 14 50 80 00    	mov    %ebx,0x805014
	return nsipc(NSREQ_BIND);
  80258f:	b8 02 00 00 00       	mov    $0x2,%eax
  802594:	e8 c7 fd ff ff       	call   802360 <nsipc>
}
  802599:	83 c4 14             	add    $0x14,%esp
  80259c:	5b                   	pop    %ebx
  80259d:	5d                   	pop    %ebp
  80259e:	c3                   	ret    

0080259f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80259f:	55                   	push   %ebp
  8025a0:	89 e5                	mov    %esp,%ebp
  8025a2:	53                   	push   %ebx
  8025a3:	83 ec 14             	sub    $0x14,%esp
	int r;
	
	nsipcbuf.accept.req_s = s;
  8025a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8025a9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8025ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8025b3:	e8 a8 fd ff ff       	call   802360 <nsipc>
  8025b8:	89 c3                	mov    %eax,%ebx
  8025ba:	85 c0                	test   %eax,%eax
  8025bc:	78 26                	js     8025e4 <nsipc_accept+0x45>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8025be:	a1 10 50 80 00       	mov    0x805010,%eax
  8025c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025c7:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8025ce:	00 
  8025cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025d2:	89 04 24             	mov    %eax,(%esp)
  8025d5:	e8 1e e5 ff ff       	call   800af8 <memmove>
		*addrlen = ret->ret_addrlen;
  8025da:	a1 10 50 80 00       	mov    0x805010,%eax
  8025df:	8b 55 10             	mov    0x10(%ebp),%edx
  8025e2:	89 02                	mov    %eax,(%edx)
	}
	return r;
}
  8025e4:	89 d8                	mov    %ebx,%eax
  8025e6:	83 c4 14             	add    $0x14,%esp
  8025e9:	5b                   	pop    %ebx
  8025ea:	5d                   	pop    %ebp
  8025eb:	c3                   	ret    

008025ec <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8025ec:	55                   	push   %ebp
  8025ed:	89 e5                	mov    %esp,%ebp
  8025ef:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8025f2:	83 3d 44 60 80 00 00 	cmpl   $0x0,0x806044
  8025f9:	75 6a                	jne    802665 <set_pgfault_handler+0x79>
		// First time through!
		// LAB 4: Your code here.
		env=(struct Env*)&envs[ENVX(sys_getenvid())];
  8025fb:	e8 bd ea ff ff       	call   8010bd <sys_getenvid>
  802600:	25 ff 03 00 00       	and    $0x3ff,%eax
  802605:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802608:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80260d:	a3 3c 60 80 00       	mov    %eax,0x80603c
		if((r=sys_page_alloc(env->env_id,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  802612:	8b 40 4c             	mov    0x4c(%eax),%eax
  802615:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80261c:	00 
  80261d:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802624:	ee 
  802625:	89 04 24             	mov    %eax,(%esp)
  802628:	e8 fd e9 ff ff       	call   80102a <sys_page_alloc>
  80262d:	85 c0                	test   %eax,%eax
  80262f:	79 1c                	jns    80264d <set_pgfault_handler+0x61>
		{
			panic("Alloc a page for an exception stack failed");
  802631:	c7 44 24 08 d0 2e 80 	movl   $0x802ed0,0x8(%esp)
  802638:	00 
  802639:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802640:	00 
  802641:	c7 04 24 fc 2e 80 00 	movl   $0x802efc,(%esp)
  802648:	e8 6f db ff ff       	call   8001bc <_panic>
		}
		sys_env_set_pgfault_upcall(env->env_id,(void*)_pgfault_upcall);
  80264d:	a1 3c 60 80 00       	mov    0x80603c,%eax
  802652:	8b 40 4c             	mov    0x4c(%eax),%eax
  802655:	c7 44 24 04 70 26 80 	movl   $0x802670,0x4(%esp)
  80265c:	00 
  80265d:	89 04 24             	mov    %eax,(%esp)
  802660:	e8 ef e7 ff ff       	call   800e54 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802665:	8b 45 08             	mov    0x8(%ebp),%eax
  802668:	a3 44 60 80 00       	mov    %eax,0x806044
}
  80266d:	c9                   	leave  
  80266e:	c3                   	ret    
	...

00802670 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802670:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802671:	a1 44 60 80 00       	mov    0x806044,%eax
	call *%eax
  802676:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802678:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.这个有点难度，需要认真编写
	movl  0x28(%esp),%eax //把utf->utf_eip入栈
  80267b:	8b 44 24 28          	mov    0x28(%esp),%eax
	pushl %eax
  80267f:	50                   	push   %eax
	movl %esp,%eax
  802680:	89 e0                	mov    %esp,%eax
	movl 0x34(%eax),%esp  //切换到用户普通栈，压入utf_eip
  802682:	8b 60 34             	mov    0x34(%eax),%esp
	pushl (%eax)
  802685:	ff 30                	pushl  (%eax)
	movl %eax,%esp	     //切到用户异常栈
  802687:	89 c4                	mov    %eax,%esp
	subl $0x4,0x34(%esp) //将utf->utf_esp减去4,指向返回地址,后面不能算术操作，就在这算
  802689:	83 6c 24 34 04       	subl   $0x4,0x34(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0xc,%esp     //恢复通用寄存器
  80268e:	83 c4 0c             	add    $0xc,%esp
	popal
  802691:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp  //恢复eflags
  802692:	83 c4 04             	add    $0x4,%esp
	popfl          //在用户态，该指令能否修改eflags?可以的
  802695:	9d                   	popf   
		       //执行完这个指令后，不能进行算术任何算术运算哦，否则eflags里面的值不对
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp     //切换到用户普通栈，用户从异常处理退出后，需要继续使用该栈
  802696:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802697:	c3                   	ret    
	...

008026a0 <__udivdi3>:
  8026a0:	55                   	push   %ebp
  8026a1:	89 e5                	mov    %esp,%ebp
  8026a3:	57                   	push   %edi
  8026a4:	56                   	push   %esi
  8026a5:	83 ec 18             	sub    $0x18,%esp
  8026a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8026ab:	8b 55 14             	mov    0x14(%ebp),%edx
  8026ae:	8b 75 0c             	mov    0xc(%ebp),%esi
  8026b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8026b4:	89 c1                	mov    %eax,%ecx
  8026b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8026b9:	85 d2                	test   %edx,%edx
  8026bb:	89 d7                	mov    %edx,%edi
  8026bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8026c0:	75 1e                	jne    8026e0 <__udivdi3+0x40>
  8026c2:	39 f1                	cmp    %esi,%ecx
  8026c4:	0f 86 8d 00 00 00    	jbe    802757 <__udivdi3+0xb7>
  8026ca:	89 f2                	mov    %esi,%edx
  8026cc:	31 f6                	xor    %esi,%esi
  8026ce:	f7 f1                	div    %ecx
  8026d0:	89 c1                	mov    %eax,%ecx
  8026d2:	89 c8                	mov    %ecx,%eax
  8026d4:	89 f2                	mov    %esi,%edx
  8026d6:	83 c4 18             	add    $0x18,%esp
  8026d9:	5e                   	pop    %esi
  8026da:	5f                   	pop    %edi
  8026db:	5d                   	pop    %ebp
  8026dc:	c3                   	ret    
  8026dd:	8d 76 00             	lea    0x0(%esi),%esi
  8026e0:	39 f2                	cmp    %esi,%edx
  8026e2:	0f 87 a8 00 00 00    	ja     802790 <__udivdi3+0xf0>
  8026e8:	0f bd c2             	bsr    %edx,%eax
  8026eb:	83 f0 1f             	xor    $0x1f,%eax
  8026ee:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8026f1:	0f 84 89 00 00 00    	je     802780 <__udivdi3+0xe0>
  8026f7:	b8 20 00 00 00       	mov    $0x20,%eax
  8026fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8026ff:	2b 45 e8             	sub    -0x18(%ebp),%eax
  802702:	89 c1                	mov    %eax,%ecx
  802704:	d3 ea                	shr    %cl,%edx
  802706:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  80270a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80270d:	89 f8                	mov    %edi,%eax
  80270f:	8b 7d f4             	mov    -0xc(%ebp),%edi
  802712:	d3 e0                	shl    %cl,%eax
  802714:	09 c2                	or     %eax,%edx
  802716:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802719:	d3 e7                	shl    %cl,%edi
  80271b:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80271f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802722:	89 f2                	mov    %esi,%edx
  802724:	d3 e8                	shr    %cl,%eax
  802726:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  80272a:	d3 e2                	shl    %cl,%edx
  80272c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802730:	09 d0                	or     %edx,%eax
  802732:	d3 ee                	shr    %cl,%esi
  802734:	89 f2                	mov    %esi,%edx
  802736:	f7 75 e4             	divl   -0x1c(%ebp)
  802739:	89 d1                	mov    %edx,%ecx
  80273b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80273e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802741:	f7 e7                	mul    %edi
  802743:	39 d1                	cmp    %edx,%ecx
  802745:	89 c6                	mov    %eax,%esi
  802747:	72 70                	jb     8027b9 <__udivdi3+0x119>
  802749:	39 ca                	cmp    %ecx,%edx
  80274b:	74 5f                	je     8027ac <__udivdi3+0x10c>
  80274d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802750:	31 f6                	xor    %esi,%esi
  802752:	e9 7b ff ff ff       	jmp    8026d2 <__udivdi3+0x32>
  802757:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80275a:	85 c0                	test   %eax,%eax
  80275c:	75 0c                	jne    80276a <__udivdi3+0xca>
  80275e:	b8 01 00 00 00       	mov    $0x1,%eax
  802763:	31 d2                	xor    %edx,%edx
  802765:	f7 75 f4             	divl   -0xc(%ebp)
  802768:	89 c1                	mov    %eax,%ecx
  80276a:	89 f0                	mov    %esi,%eax
  80276c:	89 fa                	mov    %edi,%edx
  80276e:	f7 f1                	div    %ecx
  802770:	89 c6                	mov    %eax,%esi
  802772:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802775:	f7 f1                	div    %ecx
  802777:	89 c1                	mov    %eax,%ecx
  802779:	e9 54 ff ff ff       	jmp    8026d2 <__udivdi3+0x32>
  80277e:	66 90                	xchg   %ax,%ax
  802780:	39 d6                	cmp    %edx,%esi
  802782:	77 1c                	ja     8027a0 <__udivdi3+0x100>
  802784:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802787:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  80278a:	73 14                	jae    8027a0 <__udivdi3+0x100>
  80278c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802790:	31 c9                	xor    %ecx,%ecx
  802792:	31 f6                	xor    %esi,%esi
  802794:	e9 39 ff ff ff       	jmp    8026d2 <__udivdi3+0x32>
  802799:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  8027a0:	b9 01 00 00 00       	mov    $0x1,%ecx
  8027a5:	31 f6                	xor    %esi,%esi
  8027a7:	e9 26 ff ff ff       	jmp    8026d2 <__udivdi3+0x32>
  8027ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8027af:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  8027b3:	d3 e0                	shl    %cl,%eax
  8027b5:	39 c6                	cmp    %eax,%esi
  8027b7:	76 94                	jbe    80274d <__udivdi3+0xad>
  8027b9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8027bc:	31 f6                	xor    %esi,%esi
  8027be:	83 e9 01             	sub    $0x1,%ecx
  8027c1:	e9 0c ff ff ff       	jmp    8026d2 <__udivdi3+0x32>
	...

008027d0 <__umoddi3>:
  8027d0:	55                   	push   %ebp
  8027d1:	89 e5                	mov    %esp,%ebp
  8027d3:	57                   	push   %edi
  8027d4:	56                   	push   %esi
  8027d5:	83 ec 30             	sub    $0x30,%esp
  8027d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8027db:	8b 55 14             	mov    0x14(%ebp),%edx
  8027de:	8b 75 08             	mov    0x8(%ebp),%esi
  8027e1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8027e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8027e7:	89 c1                	mov    %eax,%ecx
  8027e9:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8027ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8027ef:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8027f6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8027fd:	89 fa                	mov    %edi,%edx
  8027ff:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  802802:	85 c0                	test   %eax,%eax
  802804:	89 75 f0             	mov    %esi,-0x10(%ebp)
  802807:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80280a:	75 14                	jne    802820 <__umoddi3+0x50>
  80280c:	39 f9                	cmp    %edi,%ecx
  80280e:	76 60                	jbe    802870 <__umoddi3+0xa0>
  802810:	89 f0                	mov    %esi,%eax
  802812:	f7 f1                	div    %ecx
  802814:	89 55 d0             	mov    %edx,-0x30(%ebp)
  802817:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80281e:	eb 10                	jmp    802830 <__umoddi3+0x60>
  802820:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802823:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  802826:	76 18                	jbe    802840 <__umoddi3+0x70>
  802828:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80282b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80282e:	66 90                	xchg   %ax,%ax
  802830:	8b 45 d0             	mov    -0x30(%ebp),%eax
  802833:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  802836:	83 c4 30             	add    $0x30,%esp
  802839:	5e                   	pop    %esi
  80283a:	5f                   	pop    %edi
  80283b:	5d                   	pop    %ebp
  80283c:	c3                   	ret    
  80283d:	8d 76 00             	lea    0x0(%esi),%esi
  802840:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
  802844:	83 f0 1f             	xor    $0x1f,%eax
  802847:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80284a:	75 46                	jne    802892 <__umoddi3+0xc2>
  80284c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80284f:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  802852:	0f 87 c9 00 00 00    	ja     802921 <__umoddi3+0x151>
  802858:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  80285b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80285e:	0f 83 bd 00 00 00    	jae    802921 <__umoddi3+0x151>
  802864:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802867:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80286a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80286d:	eb c1                	jmp    802830 <__umoddi3+0x60>
  80286f:	90                   	nop    
  802870:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802873:	85 c0                	test   %eax,%eax
  802875:	75 0c                	jne    802883 <__umoddi3+0xb3>
  802877:	b8 01 00 00 00       	mov    $0x1,%eax
  80287c:	31 d2                	xor    %edx,%edx
  80287e:	f7 75 ec             	divl   -0x14(%ebp)
  802881:	89 c1                	mov    %eax,%ecx
  802883:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802886:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802889:	f7 f1                	div    %ecx
  80288b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80288e:	f7 f1                	div    %ecx
  802890:	eb 82                	jmp    802814 <__umoddi3+0x44>
  802892:	b8 20 00 00 00       	mov    $0x20,%eax
  802897:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80289a:	2b 45 d8             	sub    -0x28(%ebp),%eax
  80289d:	8b 75 ec             	mov    -0x14(%ebp),%esi
  8028a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8028a3:	89 c1                	mov    %eax,%ecx
  8028a5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8028a8:	d3 ea                	shr    %cl,%edx
  8028aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8028ad:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8028b1:	d3 e0                	shl    %cl,%eax
  8028b3:	09 c2                	or     %eax,%edx
  8028b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8028b8:	d3 e6                	shl    %cl,%esi
  8028ba:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  8028be:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8028c1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8028c4:	d3 e8                	shr    %cl,%eax
  8028c6:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8028ca:	d3 e2                	shl    %cl,%edx
  8028cc:	09 d0                	or     %edx,%eax
  8028ce:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8028d1:	d3 e7                	shl    %cl,%edi
  8028d3:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  8028d7:	d3 ea                	shr    %cl,%edx
  8028d9:	f7 75 f4             	divl   -0xc(%ebp)
  8028dc:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8028df:	f7 e6                	mul    %esi
  8028e1:	39 55 cc             	cmp    %edx,-0x34(%ebp)
  8028e4:	72 53                	jb     802939 <__umoddi3+0x169>
  8028e6:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  8028e9:	74 4a                	je     802935 <__umoddi3+0x165>
  8028eb:	90                   	nop    
  8028ec:	8d 74 26 00          	lea    0x0(%esi),%esi
  8028f0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8028f3:	29 c7                	sub    %eax,%edi
  8028f5:	19 d1                	sbb    %edx,%ecx
  8028f7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8028fa:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8028fe:	89 fa                	mov    %edi,%edx
  802900:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802903:	d3 ea                	shr    %cl,%edx
  802905:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  802909:	d3 e0                	shl    %cl,%eax
  80290b:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  80290f:	09 c2                	or     %eax,%edx
  802911:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802914:	89 55 d0             	mov    %edx,-0x30(%ebp)
  802917:	d3 e8                	shr    %cl,%eax
  802919:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80291c:	e9 0f ff ff ff       	jmp    802830 <__umoddi3+0x60>
  802921:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802924:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802927:	2b 45 ec             	sub    -0x14(%ebp),%eax
  80292a:	1b 55 e8             	sbb    -0x18(%ebp),%edx
  80292d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802930:	e9 2f ff ff ff       	jmp    802864 <__umoddi3+0x94>
  802935:	39 f8                	cmp    %edi,%eax
  802937:	76 b7                	jbe    8028f0 <__umoddi3+0x120>
  802939:	29 f0                	sub    %esi,%eax
  80293b:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  80293e:	eb b0                	jmp    8028f0 <__umoddi3+0x120>
