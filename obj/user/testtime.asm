
obj/user/testtime:     file format elf32-i386

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
  80002c:	e8 97 00 00 00       	call   8000c8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <sleep>:
#include <inc/lib.h>
#include <inc/x86.h>

void
sleep(int sec)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	53                   	push   %ebx
  800044:	83 ec 04             	sub    $0x4,%esp
	unsigned end = sys_time_msec() + sec * 1000;
  800047:	e8 4f 0c 00 00       	call   800c9b <sys_time_msec>
  80004c:	69 55 08 e8 03 00 00 	imul   $0x3e8,0x8(%ebp),%edx
  800053:	8d 1c 10             	lea    (%eax,%edx,1),%ebx
  800056:	eb 05                	jmp    80005d <sleep+0x1d>
	while (sys_time_msec() < end)
		sys_yield();
  800058:	e8 3c 0f 00 00       	call   800f99 <sys_yield>

void
sleep(int sec)
{
	unsigned end = sys_time_msec() + sec * 1000;
	while (sys_time_msec() < end)
  80005d:	e8 39 0c 00 00       	call   800c9b <sys_time_msec>
  800062:	39 c3                	cmp    %eax,%ebx
  800064:	77 f2                	ja     800058 <sleep+0x18>
		sys_yield();
}
  800066:	83 c4 04             	add    $0x4,%esp
  800069:	5b                   	pop    %ebx
  80006a:	5d                   	pop    %ebp
  80006b:	c3                   	ret    

0080006c <umain>:

void
umain(int argc, char **argv)
{
  80006c:	55                   	push   %ebp
  80006d:	89 e5                	mov    %esp,%ebp
  80006f:	53                   	push   %ebx
  800070:	83 ec 14             	sub    $0x14,%esp
	int i;

	sleep(2);
  800073:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80007a:	e8 c1 ff ff ff       	call   800040 <sleep>

	cprintf("starting count down: ");
  80007f:	c7 04 24 c0 22 80 00 	movl   $0x8022c0,(%esp)
  800086:	e8 16 01 00 00       	call   8001a1 <cprintf>
  80008b:	bb 05 00 00 00       	mov    $0x5,%ebx
	for (i = 5; i >= 0; i--) {
		cprintf("%d ", i);
  800090:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800094:	c7 04 24 d6 22 80 00 	movl   $0x8022d6,(%esp)
  80009b:	e8 01 01 00 00       	call   8001a1 <cprintf>
		sleep(1);
  8000a0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000a7:	e8 94 ff ff ff       	call   800040 <sleep>
	int i;

	sleep(2);

	cprintf("starting count down: ");
	for (i = 5; i >= 0; i--) {
  8000ac:	83 eb 01             	sub    $0x1,%ebx
  8000af:	83 fb ff             	cmp    $0xffffffff,%ebx
  8000b2:	75 dc                	jne    800090 <umain+0x24>
		cprintf("%d ", i);
		sleep(1);
	}
	cprintf("\n");
  8000b4:	c7 04 24 69 27 80 00 	movl   $0x802769,(%esp)
  8000bb:	e8 e1 00 00 00       	call   8001a1 <cprintf>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  8000c0:	cc                   	int3   
	breakpoint();
}
  8000c1:	83 c4 14             	add    $0x14,%esp
  8000c4:	5b                   	pop    %ebx
  8000c5:	5d                   	pop    %ebp
  8000c6:	c3                   	ret    
	...

008000c8 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	83 ec 18             	sub    $0x18,%esp
  8000ce:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000d1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8000d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  8000da:	c7 05 3c 60 80 00 00 	movl   $0x0,0x80603c
  8000e1:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  8000e4:	e8 e4 0e 00 00       	call   800fcd <sys_getenvid>
  8000e9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ee:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f6:	a3 3c 60 80 00       	mov    %eax,0x80603c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000fb:	85 f6                	test   %esi,%esi
  8000fd:	7e 07                	jle    800106 <libmain+0x3e>
		binaryname = argv[0];
  8000ff:	8b 03                	mov    (%ebx),%eax
  800101:	a3 00 60 80 00       	mov    %eax,0x806000

	// call user main routine
	umain(argc, argv);
  800106:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80010a:	89 34 24             	mov    %esi,(%esp)
  80010d:	e8 5a ff ff ff       	call   80006c <umain>

	// exit gracefully
	exit();
  800112:	e8 0d 00 00 00       	call   800124 <exit>
}
  800117:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80011a:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80011d:	89 ec                	mov    %ebp,%esp
  80011f:	5d                   	pop    %ebp
  800120:	c3                   	ret    
  800121:	00 00                	add    %al,(%eax)
	...

00800124 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012a:	e8 21 15 00 00       	call   801650 <close_all>
	sys_env_destroy(0);
  80012f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800136:	e8 c6 0e 00 00       	call   801001 <sys_env_destroy>
}
  80013b:	c9                   	leave  
  80013c:	c3                   	ret    
  80013d:	00 00                	add    %al,(%eax)
	...

00800140 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800149:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  800150:	00 00 00 
	b.cnt = 0;
  800153:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  80015a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800160:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800164:	8b 45 08             	mov    0x8(%ebp),%eax
  800167:	89 44 24 08          	mov    %eax,0x8(%esp)
  80016b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800171:	89 44 24 04          	mov    %eax,0x4(%esp)
  800175:	c7 04 24 be 01 80 00 	movl   $0x8001be,(%esp)
  80017c:	e8 c4 01 00 00       	call   800345 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800181:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
  800187:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018b:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  800191:	89 04 24             	mov    %eax,(%esp)
  800194:	e8 cf 0a 00 00       	call   800c68 <sys_cputs>
  800199:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  80019f:	c9                   	leave  
  8001a0:	c3                   	ret    

008001a1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a7:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001aa:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  8001ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b4:	89 04 24             	mov    %eax,(%esp)
  8001b7:	e8 84 ff ff ff       	call   800140 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bc:	c9                   	leave  
  8001bd:	c3                   	ret    

008001be <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 14             	sub    $0x14,%esp
  8001c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001c8:	8b 03                	mov    (%ebx),%eax
  8001ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cd:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001d1:	83 c0 01             	add    $0x1,%eax
  8001d4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001db:	75 19                	jne    8001f6 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001dd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001e4:	00 
  8001e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e8:	89 04 24             	mov    %eax,(%esp)
  8001eb:	e8 78 0a 00 00       	call   800c68 <sys_cputs>
		b->idx = 0;
  8001f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001f6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001fa:	83 c4 14             	add    $0x14,%esp
  8001fd:	5b                   	pop    %ebx
  8001fe:	5d                   	pop    %ebp
  8001ff:	c3                   	ret    

00800200 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	57                   	push   %edi
  800204:	56                   	push   %esi
  800205:	53                   	push   %ebx
  800206:	83 ec 3c             	sub    $0x3c,%esp
  800209:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80020c:	89 d7                	mov    %edx,%edi
  80020e:	8b 45 08             	mov    0x8(%ebp),%eax
  800211:	8b 55 0c             	mov    0xc(%ebp),%edx
  800214:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800217:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80021a:	8b 55 10             	mov    0x10(%ebp),%edx
  80021d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800220:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800223:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  80022a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80022d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  800230:	72 14                	jb     800246 <printnum+0x46>
  800232:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800235:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800238:	76 0c                	jbe    800246 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80023d:	83 eb 01             	sub    $0x1,%ebx
  800240:	85 db                	test   %ebx,%ebx
  800242:	7f 57                	jg     80029b <printnum+0x9b>
  800244:	eb 64                	jmp    8002aa <printnum+0xaa>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800246:	89 74 24 10          	mov    %esi,0x10(%esp)
  80024a:	8b 45 14             	mov    0x14(%ebp),%eax
  80024d:	83 e8 01             	sub    $0x1,%eax
  800250:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800254:	89 54 24 08          	mov    %edx,0x8(%esp)
  800258:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80025c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800260:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800263:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800266:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80026e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800271:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800274:	89 04 24             	mov    %eax,(%esp)
  800277:	89 54 24 04          	mov    %edx,0x4(%esp)
  80027b:	e8 a0 1d 00 00       	call   802020 <__udivdi3>
  800280:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800284:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800288:	89 04 24             	mov    %eax,(%esp)
  80028b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80028f:	89 fa                	mov    %edi,%edx
  800291:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800294:	e8 67 ff ff ff       	call   800200 <printnum>
  800299:	eb 0f                	jmp    8002aa <printnum+0xaa>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80029f:	89 34 24             	mov    %esi,(%esp)
  8002a2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a5:	83 eb 01             	sub    $0x1,%ebx
  8002a8:	75 f1                	jne    80029b <printnum+0x9b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ae:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8002b5:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8002b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002bc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002c3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002c6:	89 04 24             	mov    %eax,(%esp)
  8002c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002cd:	e8 7e 1e 00 00       	call   802150 <__umoddi3>
  8002d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002d6:	0f be 80 f1 22 80 00 	movsbl 0x8022f1(%eax),%eax
  8002dd:	89 04 24             	mov    %eax,(%esp)
  8002e0:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002e3:	83 c4 3c             	add    $0x3c,%esp
  8002e6:	5b                   	pop    %ebx
  8002e7:	5e                   	pop    %esi
  8002e8:	5f                   	pop    %edi
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8002f0:	83 fa 01             	cmp    $0x1,%edx
  8002f3:	7e 0e                	jle    800303 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8002f5:	8b 10                	mov    (%eax),%edx
  8002f7:	8d 42 08             	lea    0x8(%edx),%eax
  8002fa:	89 01                	mov    %eax,(%ecx)
  8002fc:	8b 02                	mov    (%edx),%eax
  8002fe:	8b 52 04             	mov    0x4(%edx),%edx
  800301:	eb 22                	jmp    800325 <getuint+0x3a>
	else if (lflag)
  800303:	85 d2                	test   %edx,%edx
  800305:	74 10                	je     800317 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800307:	8b 10                	mov    (%eax),%edx
  800309:	8d 42 04             	lea    0x4(%edx),%eax
  80030c:	89 01                	mov    %eax,(%ecx)
  80030e:	8b 02                	mov    (%edx),%eax
  800310:	ba 00 00 00 00       	mov    $0x0,%edx
  800315:	eb 0e                	jmp    800325 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800317:	8b 10                	mov    (%eax),%edx
  800319:	8d 42 04             	lea    0x4(%edx),%eax
  80031c:	89 01                	mov    %eax,(%ecx)
  80031e:	8b 02                	mov    (%edx),%eax
  800320:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800325:	5d                   	pop    %ebp
  800326:	c3                   	ret    

00800327 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800327:	55                   	push   %ebp
  800328:	89 e5                	mov    %esp,%ebp
  80032a:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  80032d:	83 42 08 01          	addl   $0x1,0x8(%edx)
	if (b->buf < b->ebuf)
  800331:	8b 02                	mov    (%edx),%eax
  800333:	3b 42 04             	cmp    0x4(%edx),%eax
  800336:	73 0b                	jae    800343 <sprintputch+0x1c>
		*b->buf++ = ch;
  800338:	0f b6 4d 08          	movzbl 0x8(%ebp),%ecx
  80033c:	88 08                	mov    %cl,(%eax)
  80033e:	83 c0 01             	add    $0x1,%eax
  800341:	89 02                	mov    %eax,(%edx)
}
  800343:	5d                   	pop    %ebp
  800344:	c3                   	ret    

00800345 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	57                   	push   %edi
  800349:	56                   	push   %esi
  80034a:	53                   	push   %ebx
  80034b:	83 ec 3c             	sub    $0x3c,%esp
  80034e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800351:	eb 18                	jmp    80036b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800353:	84 c0                	test   %al,%al
  800355:	0f 84 9f 03 00 00    	je     8006fa <vprintfmt+0x3b5>
				return;
			putch(ch, putdat);
  80035b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80035e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800362:	0f b6 c0             	movzbl %al,%eax
  800365:	89 04 24             	mov    %eax,(%esp)
  800368:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80036b:	0f b6 03             	movzbl (%ebx),%eax
  80036e:	83 c3 01             	add    $0x1,%ebx
  800371:	3c 25                	cmp    $0x25,%al
  800373:	75 de                	jne    800353 <vprintfmt+0xe>
  800375:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037a:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
  800381:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800386:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80038d:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
  800391:	eb 07                	jmp    80039a <vprintfmt+0x55>
  800393:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	0f b6 13             	movzbl (%ebx),%edx
  80039d:	83 c3 01             	add    $0x1,%ebx
  8003a0:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003a3:	3c 55                	cmp    $0x55,%al
  8003a5:	0f 87 22 03 00 00    	ja     8006cd <vprintfmt+0x388>
  8003ab:	0f b6 c0             	movzbl %al,%eax
  8003ae:	ff 24 85 40 24 80 00 	jmp    *0x802440(,%eax,4)
  8003b5:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
  8003b9:	eb df                	jmp    80039a <vprintfmt+0x55>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003bb:	0f b6 c2             	movzbl %dl,%eax
  8003be:	8d 78 d0             	lea    -0x30(%eax),%edi
				ch = *fmt;
  8003c1:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  8003c4:	8d 42 d0             	lea    -0x30(%edx),%eax
  8003c7:	83 f8 09             	cmp    $0x9,%eax
  8003ca:	76 08                	jbe    8003d4 <vprintfmt+0x8f>
  8003cc:	eb 39                	jmp    800407 <vprintfmt+0xc2>
  8003ce:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
  8003d2:	eb c6                	jmp    80039a <vprintfmt+0x55>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d4:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  8003d7:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  8003da:	8d 7c 42 d0          	lea    -0x30(%edx,%eax,2),%edi
				ch = *fmt;
  8003de:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  8003e1:	8d 42 d0             	lea    -0x30(%edx),%eax
  8003e4:	83 f8 09             	cmp    $0x9,%eax
  8003e7:	77 1e                	ja     800407 <vprintfmt+0xc2>
  8003e9:	eb e9                	jmp    8003d4 <vprintfmt+0x8f>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003eb:	8b 55 14             	mov    0x14(%ebp),%edx
  8003ee:	8d 42 04             	lea    0x4(%edx),%eax
  8003f1:	89 45 14             	mov    %eax,0x14(%ebp)
  8003f4:	8b 3a                	mov    (%edx),%edi
  8003f6:	eb 0f                	jmp    800407 <vprintfmt+0xc2>
			goto process_precision;

		case '.':
			if (width < 0)
  8003f8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8003fc:	79 9c                	jns    80039a <vprintfmt+0x55>
  8003fe:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800405:	eb 93                	jmp    80039a <vprintfmt+0x55>
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800407:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80040b:	90                   	nop    
  80040c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800410:	79 88                	jns    80039a <vprintfmt+0x55>
  800412:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800415:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80041a:	e9 7b ff ff ff       	jmp    80039a <vprintfmt+0x55>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80041f:	83 c1 01             	add    $0x1,%ecx
  800422:	e9 73 ff ff ff       	jmp    80039a <vprintfmt+0x55>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800427:	8b 45 14             	mov    0x14(%ebp),%eax
  80042a:	8d 50 04             	lea    0x4(%eax),%edx
  80042d:	89 55 14             	mov    %edx,0x14(%ebp)
  800430:	8b 55 0c             	mov    0xc(%ebp),%edx
  800433:	89 54 24 04          	mov    %edx,0x4(%esp)
  800437:	8b 00                	mov    (%eax),%eax
  800439:	89 04 24             	mov    %eax,(%esp)
  80043c:	ff 55 08             	call   *0x8(%ebp)
  80043f:	e9 27 ff ff ff       	jmp    80036b <vprintfmt+0x26>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800444:	8b 55 14             	mov    0x14(%ebp),%edx
  800447:	8d 42 04             	lea    0x4(%edx),%eax
  80044a:	89 45 14             	mov    %eax,0x14(%ebp)
  80044d:	8b 02                	mov    (%edx),%eax
  80044f:	89 c2                	mov    %eax,%edx
  800451:	c1 fa 1f             	sar    $0x1f,%edx
  800454:	31 d0                	xor    %edx,%eax
  800456:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800458:	83 f8 0f             	cmp    $0xf,%eax
  80045b:	7f 0b                	jg     800468 <vprintfmt+0x123>
  80045d:	8b 14 85 a0 25 80 00 	mov    0x8025a0(,%eax,4),%edx
  800464:	85 d2                	test   %edx,%edx
  800466:	75 23                	jne    80048b <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800468:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80046c:	c7 44 24 08 02 23 80 	movl   $0x802302,0x8(%esp)
  800473:	00 
  800474:	8b 45 0c             	mov    0xc(%ebp),%eax
  800477:	89 44 24 04          	mov    %eax,0x4(%esp)
  80047b:	8b 55 08             	mov    0x8(%ebp),%edx
  80047e:	89 14 24             	mov    %edx,(%esp)
  800481:	e8 ff 02 00 00       	call   800785 <printfmt>
  800486:	e9 e0 fe ff ff       	jmp    80036b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80048b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80048f:	c7 44 24 08 e2 26 80 	movl   $0x8026e2,0x8(%esp)
  800496:	00 
  800497:	8b 45 0c             	mov    0xc(%ebp),%eax
  80049a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049e:	8b 55 08             	mov    0x8(%ebp),%edx
  8004a1:	89 14 24             	mov    %edx,(%esp)
  8004a4:	e8 dc 02 00 00       	call   800785 <printfmt>
  8004a9:	e9 bd fe ff ff       	jmp    80036b <vprintfmt+0x26>
  8004ae:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8004b1:	89 f9                	mov    %edi,%ecx
  8004b3:	89 5d ec             	mov    %ebx,-0x14(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b6:	8b 55 14             	mov    0x14(%ebp),%edx
  8004b9:	8d 42 04             	lea    0x4(%edx),%eax
  8004bc:	89 45 14             	mov    %eax,0x14(%ebp)
  8004bf:	8b 12                	mov    (%edx),%edx
  8004c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004c4:	85 d2                	test   %edx,%edx
  8004c6:	75 07                	jne    8004cf <vprintfmt+0x18a>
  8004c8:	c7 45 dc 0b 23 80 00 	movl   $0x80230b,-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8004cf:	85 f6                	test   %esi,%esi
  8004d1:	7e 41                	jle    800514 <vprintfmt+0x1cf>
  8004d3:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  8004d7:	74 3b                	je     800514 <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004e0:	89 04 24             	mov    %eax,(%esp)
  8004e3:	e8 e8 02 00 00       	call   8007d0 <strnlen>
  8004e8:	29 c6                	sub    %eax,%esi
  8004ea:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8004ed:	85 f6                	test   %esi,%esi
  8004ef:	7e 23                	jle    800514 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004f1:	0f be 55 eb          	movsbl -0x15(%ebp),%edx
  8004f5:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8004f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ff:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800502:	89 14 24             	mov    %edx,(%esp)
  800505:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800508:	83 ee 01             	sub    $0x1,%esi
  80050b:	75 eb                	jne    8004f8 <vprintfmt+0x1b3>
  80050d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800514:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800517:	0f b6 02             	movzbl (%edx),%eax
  80051a:	0f be d0             	movsbl %al,%edx
  80051d:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800520:	84 c0                	test   %al,%al
  800522:	75 42                	jne    800566 <vprintfmt+0x221>
  800524:	eb 49                	jmp    80056f <vprintfmt+0x22a>
				if (altflag && (ch < ' ' || ch > '~'))
  800526:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80052a:	74 1b                	je     800547 <vprintfmt+0x202>
  80052c:	8d 42 e0             	lea    -0x20(%edx),%eax
  80052f:	83 f8 5e             	cmp    $0x5e,%eax
  800532:	76 13                	jbe    800547 <vprintfmt+0x202>
					putch('?', putdat);
  800534:	8b 45 0c             	mov    0xc(%ebp),%eax
  800537:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800542:	ff 55 08             	call   *0x8(%ebp)
  800545:	eb 0d                	jmp    800554 <vprintfmt+0x20f>
				else
					putch(ch, putdat);
  800547:	8b 45 0c             	mov    0xc(%ebp),%eax
  80054a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054e:	89 14 24             	mov    %edx,(%esp)
  800551:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800554:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  800558:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80055c:	83 c6 01             	add    $0x1,%esi
  80055f:	84 c0                	test   %al,%al
  800561:	74 0c                	je     80056f <vprintfmt+0x22a>
  800563:	0f be d0             	movsbl %al,%edx
  800566:	85 ff                	test   %edi,%edi
  800568:	78 bc                	js     800526 <vprintfmt+0x1e1>
  80056a:	83 ef 01             	sub    $0x1,%edi
  80056d:	79 b7                	jns    800526 <vprintfmt+0x1e1>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80056f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800573:	0f 8e f2 fd ff ff    	jle    80036b <vprintfmt+0x26>
				putch(' ', putdat);
  800579:	8b 55 0c             	mov    0xc(%ebp),%edx
  80057c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800580:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800587:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058a:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  80058e:	75 e9                	jne    800579 <vprintfmt+0x234>
  800590:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  800593:	e9 d3 fd ff ff       	jmp    80036b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800598:	83 f9 01             	cmp    $0x1,%ecx
  80059b:	90                   	nop    
  80059c:	8d 74 26 00          	lea    0x0(%esi),%esi
  8005a0:	7e 10                	jle    8005b2 <vprintfmt+0x26d>
		return va_arg(*ap, long long);
  8005a2:	8b 55 14             	mov    0x14(%ebp),%edx
  8005a5:	8d 42 08             	lea    0x8(%edx),%eax
  8005a8:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ab:	8b 32                	mov    (%edx),%esi
  8005ad:	8b 7a 04             	mov    0x4(%edx),%edi
  8005b0:	eb 2a                	jmp    8005dc <vprintfmt+0x297>
	else if (lflag)
  8005b2:	85 c9                	test   %ecx,%ecx
  8005b4:	74 14                	je     8005ca <vprintfmt+0x285>
		return va_arg(*ap, long);
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8d 50 04             	lea    0x4(%eax),%edx
  8005bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bf:	8b 00                	mov    (%eax),%eax
  8005c1:	89 c6                	mov    %eax,%esi
  8005c3:	89 c7                	mov    %eax,%edi
  8005c5:	c1 ff 1f             	sar    $0x1f,%edi
  8005c8:	eb 12                	jmp    8005dc <vprintfmt+0x297>
	else
		return va_arg(*ap, int);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 50 04             	lea    0x4(%eax),%edx
  8005d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	89 c6                	mov    %eax,%esi
  8005d7:	89 c7                	mov    %eax,%edi
  8005d9:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005dc:	89 f2                	mov    %esi,%edx
  8005de:	89 f9                	mov    %edi,%ecx
  8005e0:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
			if ((long long) num < 0) {
  8005e7:	85 ff                	test   %edi,%edi
  8005e9:	0f 89 9b 00 00 00    	jns    80068a <vprintfmt+0x345>
				putch('-', putdat);
  8005ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005fd:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800600:	89 f2                	mov    %esi,%edx
  800602:	89 f9                	mov    %edi,%ecx
  800604:	f7 da                	neg    %edx
  800606:	83 d1 00             	adc    $0x0,%ecx
  800609:	f7 d9                	neg    %ecx
  80060b:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  800612:	eb 76                	jmp    80068a <vprintfmt+0x345>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800614:	89 ca                	mov    %ecx,%edx
  800616:	8d 45 14             	lea    0x14(%ebp),%eax
  800619:	e8 cd fc ff ff       	call   8002eb <getuint>
  80061e:	89 d1                	mov    %edx,%ecx
  800620:	89 c2                	mov    %eax,%edx
  800622:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  800629:	eb 5f                	jmp    80068a <vprintfmt+0x345>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap,lflag);
  80062b:	89 ca                	mov    %ecx,%edx
  80062d:	8d 45 14             	lea    0x14(%ebp),%eax
  800630:	e8 b6 fc ff ff       	call   8002eb <getuint>
  800635:	e9 31 fd ff ff       	jmp    80036b <vprintfmt+0x26>
			base=8;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80063a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80063d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800641:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800648:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80064b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80064e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800652:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800659:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  80065c:	8b 55 14             	mov    0x14(%ebp),%edx
  80065f:	8d 42 04             	lea    0x4(%edx),%eax
  800662:	89 45 14             	mov    %eax,0x14(%ebp)
  800665:	8b 12                	mov    (%edx),%edx
  800667:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066c:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  800673:	eb 15                	jmp    80068a <vprintfmt+0x345>
			base = 16;
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800675:	89 ca                	mov    %ecx,%edx
  800677:	8d 45 14             	lea    0x14(%ebp),%eax
  80067a:	e8 6c fc ff ff       	call   8002eb <getuint>
  80067f:	89 d1                	mov    %edx,%ecx
  800681:	89 c2                	mov    %eax,%edx
  800683:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80068a:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  80068e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800692:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800695:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800699:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80069c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006a0:	89 14 24             	mov    %edx,(%esp)
  8006a3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ad:	e8 4e fb ff ff       	call   800200 <printnum>
  8006b2:	e9 b4 fc ff ff       	jmp    80036b <vprintfmt+0x26>
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006ba:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006be:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006c5:	ff 55 08             	call   *0x8(%ebp)
  8006c8:	e9 9e fc ff ff       	jmp    80036b <vprintfmt+0x26>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006db:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006de:	83 eb 01             	sub    $0x1,%ebx
  8006e1:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8006e5:	0f 84 80 fc ff ff    	je     80036b <vprintfmt+0x26>
  8006eb:	83 eb 01             	sub    $0x1,%ebx
  8006ee:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8006f2:	0f 84 73 fc ff ff    	je     80036b <vprintfmt+0x26>
  8006f8:	eb f1                	jmp    8006eb <vprintfmt+0x3a6>
				/* do nothing */;
			break;
		}
	}
}
  8006fa:	83 c4 3c             	add    $0x3c,%esp
  8006fd:	5b                   	pop    %ebx
  8006fe:	5e                   	pop    %esi
  8006ff:	5f                   	pop    %edi
  800700:	5d                   	pop    %ebp
  800701:	c3                   	ret    

00800702 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
  800705:	83 ec 28             	sub    $0x28,%esp
  800708:	8b 55 08             	mov    0x8(%ebp),%edx
  80070b:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80070e:	85 d2                	test   %edx,%edx
  800710:	74 04                	je     800716 <vsnprintf+0x14>
  800712:	85 c0                	test   %eax,%eax
  800714:	7f 07                	jg     80071d <vsnprintf+0x1b>
  800716:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80071b:	eb 3b                	jmp    800758 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80071d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800724:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
  800728:	89 45 f8             	mov    %eax,-0x8(%ebp)
  80072b:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80072e:	8b 45 14             	mov    0x14(%ebp),%eax
  800731:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800735:	8b 45 10             	mov    0x10(%ebp),%eax
  800738:	89 44 24 08          	mov    %eax,0x8(%esp)
  80073c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80073f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800743:	c7 04 24 27 03 80 00 	movl   $0x800327,(%esp)
  80074a:	e8 f6 fb ff ff       	call   800345 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800752:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800755:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800758:	c9                   	leave  
  800759:	c3                   	ret    

0080075a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800760:	8d 45 14             	lea    0x14(%ebp),%eax
  800763:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800766:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80076a:	8b 45 10             	mov    0x10(%ebp),%eax
  80076d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800771:	8b 45 0c             	mov    0xc(%ebp),%eax
  800774:	89 44 24 04          	mov    %eax,0x4(%esp)
  800778:	8b 45 08             	mov    0x8(%ebp),%eax
  80077b:	89 04 24             	mov    %eax,(%esp)
  80077e:	e8 7f ff ff ff       	call   800702 <vsnprintf>
	va_end(ap);

	return rc;
}
  800783:	c9                   	leave  
  800784:	c3                   	ret    

00800785 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  80078b:	8d 45 14             	lea    0x14(%ebp),%eax
  80078e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800791:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800795:	8b 45 10             	mov    0x10(%ebp),%eax
  800798:	89 44 24 08          	mov    %eax,0x8(%esp)
  80079c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80079f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a6:	89 04 24             	mov    %eax,(%esp)
  8007a9:	e8 97 fb ff ff       	call   800345 <vprintfmt>
	va_end(ap);
}
  8007ae:	c9                   	leave  
  8007af:	c3                   	ret    

008007b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bb:	80 3a 00             	cmpb   $0x0,(%edx)
  8007be:	74 0e                	je     8007ce <strlen+0x1e>
  8007c0:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007c5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c8:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  8007cc:	75 f7                	jne    8007c5 <strlen+0x15>
		n++;
	return n;
}
  8007ce:	5d                   	pop    %ebp
  8007cf:	c3                   	ret    

008007d0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d9:	85 d2                	test   %edx,%edx
  8007db:	74 19                	je     8007f6 <strnlen+0x26>
  8007dd:	80 39 00             	cmpb   $0x0,(%ecx)
  8007e0:	74 14                	je     8007f6 <strnlen+0x26>
  8007e2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007e7:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ea:	39 d0                	cmp    %edx,%eax
  8007ec:	74 0d                	je     8007fb <strnlen+0x2b>
  8007ee:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  8007f2:	74 07                	je     8007fb <strnlen+0x2b>
  8007f4:	eb f1                	jmp    8007e7 <strnlen+0x17>
  8007f6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007fb:	5d                   	pop    %ebp
  8007fc:	8d 74 26 00          	lea    0x0(%esi),%esi
  800800:	c3                   	ret    

00800801 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	53                   	push   %ebx
  800805:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800808:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080b:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80080d:	0f b6 01             	movzbl (%ecx),%eax
  800810:	88 02                	mov    %al,(%edx)
  800812:	83 c2 01             	add    $0x1,%edx
  800815:	83 c1 01             	add    $0x1,%ecx
  800818:	84 c0                	test   %al,%al
  80081a:	75 f1                	jne    80080d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80081c:	89 d8                	mov    %ebx,%eax
  80081e:	5b                   	pop    %ebx
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	57                   	push   %edi
  800825:	56                   	push   %esi
  800826:	53                   	push   %ebx
  800827:	8b 7d 08             	mov    0x8(%ebp),%edi
  80082a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800830:	85 f6                	test   %esi,%esi
  800832:	74 1c                	je     800850 <strncpy+0x2f>
  800834:	89 fa                	mov    %edi,%edx
  800836:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  80083b:	0f b6 01             	movzbl (%ecx),%eax
  80083e:	88 02                	mov    %al,(%edx)
  800840:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800843:	80 39 01             	cmpb   $0x1,(%ecx)
  800846:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800849:	83 c3 01             	add    $0x1,%ebx
  80084c:	39 f3                	cmp    %esi,%ebx
  80084e:	75 eb                	jne    80083b <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800850:	89 f8                	mov    %edi,%eax
  800852:	5b                   	pop    %ebx
  800853:	5e                   	pop    %esi
  800854:	5f                   	pop    %edi
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	56                   	push   %esi
  80085b:	53                   	push   %ebx
  80085c:	8b 75 08             	mov    0x8(%ebp),%esi
  80085f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800862:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800865:	89 f0                	mov    %esi,%eax
  800867:	85 d2                	test   %edx,%edx
  800869:	74 2c                	je     800897 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  80086b:	89 d3                	mov    %edx,%ebx
  80086d:	83 eb 01             	sub    $0x1,%ebx
  800870:	74 20                	je     800892 <strlcpy+0x3b>
  800872:	0f b6 11             	movzbl (%ecx),%edx
  800875:	84 d2                	test   %dl,%dl
  800877:	74 19                	je     800892 <strlcpy+0x3b>
  800879:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  80087b:	88 10                	mov    %dl,(%eax)
  80087d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800880:	83 eb 01             	sub    $0x1,%ebx
  800883:	74 0f                	je     800894 <strlcpy+0x3d>
  800885:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  800889:	83 c1 01             	add    $0x1,%ecx
  80088c:	84 d2                	test   %dl,%dl
  80088e:	74 04                	je     800894 <strlcpy+0x3d>
  800890:	eb e9                	jmp    80087b <strlcpy+0x24>
  800892:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800894:	c6 00 00             	movb   $0x0,(%eax)
  800897:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800899:	5b                   	pop    %ebx
  80089a:	5e                   	pop    %esi
  80089b:	5d                   	pop    %ebp
  80089c:	c3                   	ret    

0080089d <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	56                   	push   %esi
  8008a1:	53                   	push   %ebx
  8008a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a8:	8b 55 10             	mov    0x10(%ebp),%edx
    int c;
    char *q = buf;

    if (buf_size <= 0)
  8008ab:	85 c0                	test   %eax,%eax
  8008ad:	7e 2e                	jle    8008dd <pstrcpy+0x40>
        return;

    for(;;) {
        c = *str++;
  8008af:	0f b6 0a             	movzbl (%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  8008b2:	84 c9                	test   %cl,%cl
  8008b4:	74 22                	je     8008d8 <pstrcpy+0x3b>
  8008b6:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  8008ba:	89 f0                	mov    %esi,%eax
  8008bc:	39 de                	cmp    %ebx,%esi
  8008be:	72 09                	jb     8008c9 <pstrcpy+0x2c>
  8008c0:	eb 16                	jmp    8008d8 <pstrcpy+0x3b>
  8008c2:	83 c2 01             	add    $0x1,%edx
  8008c5:	39 d8                	cmp    %ebx,%eax
  8008c7:	73 11                	jae    8008da <pstrcpy+0x3d>
            break;
        *q++ = c;
  8008c9:	88 08                	mov    %cl,(%eax)
  8008cb:	83 c0 01             	add    $0x1,%eax

    if (buf_size <= 0)
        return;

    for(;;) {
        c = *str++;
  8008ce:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  8008d2:	84 c9                	test   %cl,%cl
  8008d4:	75 ec                	jne    8008c2 <pstrcpy+0x25>
  8008d6:	eb 02                	jmp    8008da <pstrcpy+0x3d>
  8008d8:	89 f0                	mov    %esi,%eax
            break;
        *q++ = c;
    }
    *q = '\0';
  8008da:	c6 00 00             	movb   $0x0,(%eax)
}
  8008dd:	5b                   	pop    %ebx
  8008de:	5e                   	pop    %esi
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8008e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  8008ea:	0f b6 02             	movzbl (%edx),%eax
  8008ed:	84 c0                	test   %al,%al
  8008ef:	74 16                	je     800907 <strcmp+0x26>
  8008f1:	3a 01                	cmp    (%ecx),%al
  8008f3:	75 12                	jne    800907 <strcmp+0x26>
		p++, q++;
  8008f5:	83 c1 01             	add    $0x1,%ecx
    *q = '\0';
}
int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008f8:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  8008fc:	84 c0                	test   %al,%al
  8008fe:	74 07                	je     800907 <strcmp+0x26>
  800900:	83 c2 01             	add    $0x1,%edx
  800903:	3a 01                	cmp    (%ecx),%al
  800905:	74 ee                	je     8008f5 <strcmp+0x14>
  800907:	0f b6 c0             	movzbl %al,%eax
  80090a:	0f b6 11             	movzbl (%ecx),%edx
  80090d:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	53                   	push   %ebx
  800915:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800918:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80091b:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80091e:	85 d2                	test   %edx,%edx
  800920:	74 2d                	je     80094f <strncmp+0x3e>
  800922:	0f b6 01             	movzbl (%ecx),%eax
  800925:	84 c0                	test   %al,%al
  800927:	74 1a                	je     800943 <strncmp+0x32>
  800929:	3a 03                	cmp    (%ebx),%al
  80092b:	75 16                	jne    800943 <strncmp+0x32>
  80092d:	83 ea 01             	sub    $0x1,%edx
  800930:	74 1d                	je     80094f <strncmp+0x3e>
		n--, p++, q++;
  800932:	83 c1 01             	add    $0x1,%ecx
  800935:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800938:	0f b6 01             	movzbl (%ecx),%eax
  80093b:	84 c0                	test   %al,%al
  80093d:	74 04                	je     800943 <strncmp+0x32>
  80093f:	3a 03                	cmp    (%ebx),%al
  800941:	74 ea                	je     80092d <strncmp+0x1c>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800943:	0f b6 11             	movzbl (%ecx),%edx
  800946:	0f b6 03             	movzbl (%ebx),%eax
  800949:	29 c2                	sub    %eax,%edx
  80094b:	89 d0                	mov    %edx,%eax
  80094d:	eb 05                	jmp    800954 <strncmp+0x43>
  80094f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800954:	5b                   	pop    %ebx
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800961:	0f b6 10             	movzbl (%eax),%edx
  800964:	84 d2                	test   %dl,%dl
  800966:	74 14                	je     80097c <strchr+0x25>
		if (*s == c)
  800968:	38 ca                	cmp    %cl,%dl
  80096a:	75 06                	jne    800972 <strchr+0x1b>
  80096c:	eb 13                	jmp    800981 <strchr+0x2a>
  80096e:	38 ca                	cmp    %cl,%dl
  800970:	74 0f                	je     800981 <strchr+0x2a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800972:	83 c0 01             	add    $0x1,%eax
  800975:	0f b6 10             	movzbl (%eax),%edx
  800978:	84 d2                	test   %dl,%dl
  80097a:	75 f2                	jne    80096e <strchr+0x17>
  80097c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80098d:	0f b6 10             	movzbl (%eax),%edx
  800990:	84 d2                	test   %dl,%dl
  800992:	74 18                	je     8009ac <strfind+0x29>
		if (*s == c)
  800994:	38 ca                	cmp    %cl,%dl
  800996:	75 0a                	jne    8009a2 <strfind+0x1f>
  800998:	eb 12                	jmp    8009ac <strfind+0x29>
  80099a:	38 ca                	cmp    %cl,%dl
  80099c:	8d 74 26 00          	lea    0x0(%esi),%esi
  8009a0:	74 0a                	je     8009ac <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009a2:	83 c0 01             	add    $0x1,%eax
  8009a5:	0f b6 10             	movzbl (%eax),%edx
  8009a8:	84 d2                	test   %dl,%dl
  8009aa:	75 ee                	jne    80099a <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	83 ec 08             	sub    $0x8,%esp
  8009b4:	89 1c 24             	mov    %ebx,(%esp)
  8009b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009bb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009be:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  8009c1:	85 db                	test   %ebx,%ebx
  8009c3:	74 36                	je     8009fb <memset+0x4d>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009c5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009cb:	75 26                	jne    8009f3 <memset+0x45>
  8009cd:	f6 c3 03             	test   $0x3,%bl
  8009d0:	75 21                	jne    8009f3 <memset+0x45>
		c &= 0xFF;
  8009d2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009d6:	89 d0                	mov    %edx,%eax
  8009d8:	c1 e0 18             	shl    $0x18,%eax
  8009db:	89 d1                	mov    %edx,%ecx
  8009dd:	c1 e1 10             	shl    $0x10,%ecx
  8009e0:	09 c8                	or     %ecx,%eax
  8009e2:	09 d0                	or     %edx,%eax
  8009e4:	c1 e2 08             	shl    $0x8,%edx
  8009e7:	09 d0                	or     %edx,%eax
  8009e9:	89 d9                	mov    %ebx,%ecx
  8009eb:	c1 e9 02             	shr    $0x2,%ecx
  8009ee:	fc                   	cld    
  8009ef:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f1:	eb 08                	jmp    8009fb <memset+0x4d>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f6:	89 d9                	mov    %ebx,%ecx
  8009f8:	fc                   	cld    
  8009f9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009fb:	89 f8                	mov    %edi,%eax
  8009fd:	8b 1c 24             	mov    (%esp),%ebx
  800a00:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800a04:	89 ec                	mov    %ebp,%esp
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	83 ec 08             	sub    $0x8,%esp
  800a0e:	89 34 24             	mov    %esi,(%esp)
  800a11:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a15:	8b 45 08             	mov    0x8(%ebp),%eax
  800a18:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800a1b:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a1e:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a20:	39 c6                	cmp    %eax,%esi
  800a22:	73 38                	jae    800a5c <memmove+0x54>
  800a24:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a27:	39 d0                	cmp    %edx,%eax
  800a29:	73 31                	jae    800a5c <memmove+0x54>
		s += n;
		d += n;
  800a2b:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a2e:	f6 c2 03             	test   $0x3,%dl
  800a31:	75 1d                	jne    800a50 <memmove+0x48>
  800a33:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a39:	75 15                	jne    800a50 <memmove+0x48>
  800a3b:	f6 c1 03             	test   $0x3,%cl
  800a3e:	66 90                	xchg   %ax,%ax
  800a40:	75 0e                	jne    800a50 <memmove+0x48>
			asm volatile("std; rep movsl\n"
  800a42:	8d 7e fc             	lea    -0x4(%esi),%edi
  800a45:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a48:	c1 e9 02             	shr    $0x2,%ecx
  800a4b:	fd                   	std    
  800a4c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4e:	eb 09                	jmp    800a59 <memmove+0x51>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a50:	8d 7e ff             	lea    -0x1(%esi),%edi
  800a53:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a56:	fd                   	std    
  800a57:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a59:	fc                   	cld    
  800a5a:	eb 21                	jmp    800a7d <memmove+0x75>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a62:	75 16                	jne    800a7a <memmove+0x72>
  800a64:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a6a:	75 0e                	jne    800a7a <memmove+0x72>
  800a6c:	f6 c1 03             	test   $0x3,%cl
  800a6f:	90                   	nop    
  800a70:	75 08                	jne    800a7a <memmove+0x72>
			asm volatile("cld; rep movsl\n"
  800a72:	c1 e9 02             	shr    $0x2,%ecx
  800a75:	fc                   	cld    
  800a76:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a78:	eb 03                	jmp    800a7d <memmove+0x75>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a7a:	fc                   	cld    
  800a7b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a7d:	8b 34 24             	mov    (%esp),%esi
  800a80:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800a84:	89 ec                	mov    %ebp,%esp
  800a86:	5d                   	pop    %ebp
  800a87:	c3                   	ret    

00800a88 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a8e:	8b 45 10             	mov    0x10(%ebp),%eax
  800a91:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a95:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a98:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9f:	89 04 24             	mov    %eax,(%esp)
  800aa2:	e8 61 ff ff ff       	call   800a08 <memmove>
}
  800aa7:	c9                   	leave  
  800aa8:	c3                   	ret    

00800aa9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	57                   	push   %edi
  800aad:	56                   	push   %esi
  800aae:	53                   	push   %ebx
  800aaf:	83 ec 04             	sub    $0x4,%esp
  800ab2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab8:	8b 55 10             	mov    0x10(%ebp),%edx
  800abb:	83 ea 01             	sub    $0x1,%edx
  800abe:	83 fa ff             	cmp    $0xffffffff,%edx
  800ac1:	74 47                	je     800b0a <memcmp+0x61>
		if (*s1 != *s2)
  800ac3:	0f b6 30             	movzbl (%eax),%esi
  800ac6:	0f b6 39             	movzbl (%ecx),%edi
			return (int) *s1 - (int) *s2;
  800ac9:	89 45 f0             	mov    %eax,-0x10(%ebp)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  800acc:	89 f0                	mov    %esi,%eax
  800ace:	89 fb                	mov    %edi,%ebx
  800ad0:	38 d8                	cmp    %bl,%al
  800ad2:	74 2e                	je     800b02 <memcmp+0x59>
  800ad4:	eb 1c                	jmp    800af2 <memcmp+0x49>
  800ad6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ad9:	0f b6 70 01          	movzbl 0x1(%eax),%esi
  800add:	0f b6 79 01          	movzbl 0x1(%ecx),%edi
  800ae1:	83 c0 01             	add    $0x1,%eax
  800ae4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ae7:	83 c1 01             	add    $0x1,%ecx
  800aea:	89 f3                	mov    %esi,%ebx
  800aec:	89 f8                	mov    %edi,%eax
  800aee:	38 c3                	cmp    %al,%bl
  800af0:	74 10                	je     800b02 <memcmp+0x59>
			return (int) *s1 - (int) *s2;
  800af2:	89 f1                	mov    %esi,%ecx
  800af4:	0f b6 d1             	movzbl %cl,%edx
  800af7:	89 fb                	mov    %edi,%ebx
  800af9:	0f b6 c3             	movzbl %bl,%eax
  800afc:	29 c2                	sub    %eax,%edx
  800afe:	89 d0                	mov    %edx,%eax
  800b00:	eb 0d                	jmp    800b0f <memcmp+0x66>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b02:	83 ea 01             	sub    $0x1,%edx
  800b05:	83 fa ff             	cmp    $0xffffffff,%edx
  800b08:	75 cc                	jne    800ad6 <memcmp+0x2d>
  800b0a:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b0f:	83 c4 04             	add    $0x4,%esp
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	5f                   	pop    %edi
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b1d:	89 c1                	mov    %eax,%ecx
  800b1f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
  800b22:	39 c8                	cmp    %ecx,%eax
  800b24:	73 15                	jae    800b3b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b26:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
  800b2a:	38 10                	cmp    %dl,(%eax)
  800b2c:	75 06                	jne    800b34 <memfind+0x1d>
  800b2e:	eb 0b                	jmp    800b3b <memfind+0x24>
  800b30:	38 10                	cmp    %dl,(%eax)
  800b32:	74 07                	je     800b3b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b34:	83 c0 01             	add    $0x1,%eax
  800b37:	39 c8                	cmp    %ecx,%eax
  800b39:	75 f5                	jne    800b30 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b3b:	5d                   	pop    %ebp
  800b3c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800b40:	c3                   	ret    

00800b41 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	57                   	push   %edi
  800b45:	56                   	push   %esi
  800b46:	53                   	push   %ebx
  800b47:	83 ec 04             	sub    $0x4,%esp
  800b4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4d:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b50:	0f b6 01             	movzbl (%ecx),%eax
  800b53:	3c 20                	cmp    $0x20,%al
  800b55:	74 04                	je     800b5b <strtol+0x1a>
  800b57:	3c 09                	cmp    $0x9,%al
  800b59:	75 0e                	jne    800b69 <strtol+0x28>
		s++;
  800b5b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b5e:	0f b6 01             	movzbl (%ecx),%eax
  800b61:	3c 20                	cmp    $0x20,%al
  800b63:	74 f6                	je     800b5b <strtol+0x1a>
  800b65:	3c 09                	cmp    $0x9,%al
  800b67:	74 f2                	je     800b5b <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b69:	3c 2b                	cmp    $0x2b,%al
  800b6b:	75 0c                	jne    800b79 <strtol+0x38>
		s++;
  800b6d:	83 c1 01             	add    $0x1,%ecx
  800b70:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b77:	eb 15                	jmp    800b8e <strtol+0x4d>
	else if (*s == '-')
  800b79:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b80:	3c 2d                	cmp    $0x2d,%al
  800b82:	75 0a                	jne    800b8e <strtol+0x4d>
		s++, neg = 1;
  800b84:	83 c1 01             	add    $0x1,%ecx
  800b87:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b8e:	85 f6                	test   %esi,%esi
  800b90:	0f 94 c0             	sete   %al
  800b93:	74 05                	je     800b9a <strtol+0x59>
  800b95:	83 fe 10             	cmp    $0x10,%esi
  800b98:	75 18                	jne    800bb2 <strtol+0x71>
  800b9a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b9d:	75 13                	jne    800bb2 <strtol+0x71>
  800b9f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ba3:	75 0d                	jne    800bb2 <strtol+0x71>
		s += 2, base = 16;
  800ba5:	83 c1 02             	add    $0x2,%ecx
  800ba8:	be 10 00 00 00       	mov    $0x10,%esi
  800bad:	8d 76 00             	lea    0x0(%esi),%esi
  800bb0:	eb 1b                	jmp    800bcd <strtol+0x8c>
	else if (base == 0 && s[0] == '0')
  800bb2:	85 f6                	test   %esi,%esi
  800bb4:	75 0e                	jne    800bc4 <strtol+0x83>
  800bb6:	80 39 30             	cmpb   $0x30,(%ecx)
  800bb9:	75 09                	jne    800bc4 <strtol+0x83>
		s++, base = 8;
  800bbb:	83 c1 01             	add    $0x1,%ecx
  800bbe:	66 be 08 00          	mov    $0x8,%si
  800bc2:	eb 09                	jmp    800bcd <strtol+0x8c>
	else if (base == 0)
  800bc4:	84 c0                	test   %al,%al
  800bc6:	74 05                	je     800bcd <strtol+0x8c>
  800bc8:	be 0a 00 00 00       	mov    $0xa,%esi
  800bcd:	bf 00 00 00 00       	mov    $0x0,%edi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bd2:	0f b6 11             	movzbl (%ecx),%edx
  800bd5:	89 d3                	mov    %edx,%ebx
  800bd7:	8d 42 d0             	lea    -0x30(%edx),%eax
  800bda:	3c 09                	cmp    $0x9,%al
  800bdc:	77 08                	ja     800be6 <strtol+0xa5>
			dig = *s - '0';
  800bde:	0f be c2             	movsbl %dl,%eax
  800be1:	8d 50 d0             	lea    -0x30(%eax),%edx
  800be4:	eb 1c                	jmp    800c02 <strtol+0xc1>
		else if (*s >= 'a' && *s <= 'z')
  800be6:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800be9:	3c 19                	cmp    $0x19,%al
  800beb:	77 08                	ja     800bf5 <strtol+0xb4>
			dig = *s - 'a' + 10;
  800bed:	0f be c2             	movsbl %dl,%eax
  800bf0:	8d 50 a9             	lea    -0x57(%eax),%edx
  800bf3:	eb 0d                	jmp    800c02 <strtol+0xc1>
		else if (*s >= 'A' && *s <= 'Z')
  800bf5:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800bf8:	3c 19                	cmp    $0x19,%al
  800bfa:	77 17                	ja     800c13 <strtol+0xd2>
			dig = *s - 'A' + 10;
  800bfc:	0f be c2             	movsbl %dl,%eax
  800bff:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800c02:	39 f2                	cmp    %esi,%edx
  800c04:	7d 0d                	jge    800c13 <strtol+0xd2>
			break;
		s++, val = (val * base) + dig;
  800c06:	83 c1 01             	add    $0x1,%ecx
  800c09:	89 f8                	mov    %edi,%eax
  800c0b:	0f af c6             	imul   %esi,%eax
  800c0e:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800c11:	eb bf                	jmp    800bd2 <strtol+0x91>
		// we don't properly detect overflow!
	}
  800c13:	89 f8                	mov    %edi,%eax

	if (endptr)
  800c15:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c19:	74 05                	je     800c20 <strtol+0xdf>
		*endptr = (char *) s;
  800c1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1e:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800c20:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c24:	74 04                	je     800c2a <strtol+0xe9>
  800c26:	89 c7                	mov    %eax,%edi
  800c28:	f7 df                	neg    %edi
}
  800c2a:	89 f8                	mov    %edi,%eax
  800c2c:	83 c4 04             	add    $0x4,%esp
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	83 ec 0c             	sub    $0xc,%esp
  800c3a:	89 1c 24             	mov    %ebx,(%esp)
  800c3d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c41:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c45:	b8 01 00 00 00       	mov    $0x1,%eax
  800c4a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c4f:	89 fa                	mov    %edi,%edx
  800c51:	89 f9                	mov    %edi,%ecx
  800c53:	89 fb                	mov    %edi,%ebx
  800c55:	89 fe                	mov    %edi,%esi
  800c57:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c59:	8b 1c 24             	mov    (%esp),%ebx
  800c5c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c60:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c64:	89 ec                	mov    %ebp,%esp
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	83 ec 0c             	sub    $0xc,%esp
  800c6e:	89 1c 24             	mov    %ebx,(%esp)
  800c71:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c75:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c79:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c84:	89 f8                	mov    %edi,%eax
  800c86:	89 fb                	mov    %edi,%ebx
  800c88:	89 fe                	mov    %edi,%esi
  800c8a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c8c:	8b 1c 24             	mov    (%esp),%ebx
  800c8f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c93:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c97:	89 ec                	mov    %ebp,%esp
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	83 ec 0c             	sub    $0xc,%esp
  800ca1:	89 1c 24             	mov    %ebx,(%esp)
  800ca4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ca8:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cac:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cb1:	bf 00 00 00 00       	mov    $0x0,%edi
  800cb6:	89 fa                	mov    %edi,%edx
  800cb8:	89 f9                	mov    %edi,%ecx
  800cba:	89 fb                	mov    %edi,%ebx
  800cbc:	89 fe                	mov    %edi,%esi
  800cbe:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800cc0:	8b 1c 24             	mov    (%esp),%ebx
  800cc3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cc7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ccb:	89 ec                	mov    %ebp,%esp
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    

00800ccf <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	83 ec 28             	sub    $0x28,%esp
  800cd5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cd8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cdb:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800cde:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ce6:	bf 00 00 00 00       	mov    $0x0,%edi
  800ceb:	89 f9                	mov    %edi,%ecx
  800ced:	89 fb                	mov    %edi,%ebx
  800cef:	89 fe                	mov    %edi,%esi
  800cf1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800cf3:	85 c0                	test   %eax,%eax
  800cf5:	7e 28                	jle    800d1f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cfb:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d02:	00 
  800d03:	c7 44 24 08 ff 25 80 	movl   $0x8025ff,0x8(%esp)
  800d0a:	00 
  800d0b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d12:	00 
  800d13:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  800d1a:	e8 ed 10 00 00       	call   801e0c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d1f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d22:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d25:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d28:	89 ec                	mov    %ebp,%esp
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	83 ec 0c             	sub    $0xc,%esp
  800d32:	89 1c 24             	mov    %ebx,(%esp)
  800d35:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d39:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d43:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d46:	8b 7d 14             	mov    0x14(%ebp),%edi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d49:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d4e:	be 00 00 00 00       	mov    $0x0,%esi
  800d53:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d55:	8b 1c 24             	mov    (%esp),%ebx
  800d58:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d5c:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d60:	89 ec                	mov    %ebp,%esp
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	83 ec 28             	sub    $0x28,%esp
  800d6a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d6d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d70:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d73:	8b 55 08             	mov    0x8(%ebp),%edx
  800d76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d79:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d7e:	bf 00 00 00 00       	mov    $0x0,%edi
  800d83:	89 fb                	mov    %edi,%ebx
  800d85:	89 fe                	mov    %edi,%esi
  800d87:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800d89:	85 c0                	test   %eax,%eax
  800d8b:	7e 28                	jle    800db5 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d91:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d98:	00 
  800d99:	c7 44 24 08 ff 25 80 	movl   $0x8025ff,0x8(%esp)
  800da0:	00 
  800da1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da8:	00 
  800da9:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  800db0:	e8 57 10 00 00       	call   801e0c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800db5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800db8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dbb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dbe:	89 ec                	mov    %ebp,%esp
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    

00800dc2 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	83 ec 28             	sub    $0x28,%esp
  800dc8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dcb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dce:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800dd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd7:	b8 09 00 00 00       	mov    $0x9,%eax
  800ddc:	bf 00 00 00 00       	mov    $0x0,%edi
  800de1:	89 fb                	mov    %edi,%ebx
  800de3:	89 fe                	mov    %edi,%esi
  800de5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800de7:	85 c0                	test   %eax,%eax
  800de9:	7e 28                	jle    800e13 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800deb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800def:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800df6:	00 
  800df7:	c7 44 24 08 ff 25 80 	movl   $0x8025ff,0x8(%esp)
  800dfe:	00 
  800dff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e06:	00 
  800e07:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  800e0e:	e8 f9 0f 00 00       	call   801e0c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e13:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e16:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e19:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e1c:	89 ec                	mov    %ebp,%esp
  800e1e:	5d                   	pop    %ebp
  800e1f:	c3                   	ret    

00800e20 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800e35:	b8 08 00 00 00       	mov    $0x8,%eax
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
  800e47:	7e 28                	jle    800e71 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e49:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e54:	00 
  800e55:	c7 44 24 08 ff 25 80 	movl   $0x8025ff,0x8(%esp)
  800e5c:	00 
  800e5d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e64:	00 
  800e65:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  800e6c:	e8 9b 0f 00 00       	call   801e0c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e71:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e74:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e77:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e7a:	89 ec                	mov    %ebp,%esp
  800e7c:	5d                   	pop    %ebp
  800e7d:	c3                   	ret    

00800e7e <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
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
  800e93:	b8 06 00 00 00       	mov    $0x6,%eax
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
  800ea5:	7e 28                	jle    800ecf <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eab:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800eb2:	00 
  800eb3:	c7 44 24 08 ff 25 80 	movl   $0x8025ff,0x8(%esp)
  800eba:	00 
  800ebb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec2:	00 
  800ec3:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  800eca:	e8 3d 0f 00 00       	call   801e0c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ecf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ed2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ed5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ed8:	89 ec                	mov    %ebp,%esp
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	83 ec 28             	sub    $0x28,%esp
  800ee2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ee5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ee8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800eeb:	8b 55 08             	mov    0x8(%ebp),%edx
  800eee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ef7:	8b 75 18             	mov    0x18(%ebp),%esi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efa:	b8 05 00 00 00       	mov    $0x5,%eax
  800eff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f01:	85 c0                	test   %eax,%eax
  800f03:	7e 28                	jle    800f2d <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f05:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f09:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f10:	00 
  800f11:	c7 44 24 08 ff 25 80 	movl   $0x8025ff,0x8(%esp)
  800f18:	00 
  800f19:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f20:	00 
  800f21:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  800f28:	e8 df 0e 00 00       	call   801e0c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f2d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f30:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f33:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f36:	89 ec                	mov    %ebp,%esp
  800f38:	5d                   	pop    %ebp
  800f39:	c3                   	ret    

00800f3a <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f3a:	55                   	push   %ebp
  800f3b:	89 e5                	mov    %esp,%ebp
  800f3d:	83 ec 28             	sub    $0x28,%esp
  800f40:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f43:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f46:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f49:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f52:	b8 04 00 00 00       	mov    $0x4,%eax
  800f57:	bf 00 00 00 00       	mov    $0x0,%edi
  800f5c:	89 fe                	mov    %edi,%esi
  800f5e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f60:	85 c0                	test   %eax,%eax
  800f62:	7e 28                	jle    800f8c <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f64:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f68:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f6f:	00 
  800f70:	c7 44 24 08 ff 25 80 	movl   $0x8025ff,0x8(%esp)
  800f77:	00 
  800f78:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f7f:	00 
  800f80:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  800f87:	e8 80 0e 00 00       	call   801e0c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f8c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f8f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f92:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f95:	89 ec                	mov    %ebp,%esp
  800f97:	5d                   	pop    %ebp
  800f98:	c3                   	ret    

00800f99 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800f99:	55                   	push   %ebp
  800f9a:	89 e5                	mov    %esp,%ebp
  800f9c:	83 ec 0c             	sub    $0xc,%esp
  800f9f:	89 1c 24             	mov    %ebx,(%esp)
  800fa2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fa6:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800faa:	b8 0b 00 00 00       	mov    $0xb,%eax
  800faf:	bf 00 00 00 00       	mov    $0x0,%edi
  800fb4:	89 fa                	mov    %edi,%edx
  800fb6:	89 f9                	mov    %edi,%ecx
  800fb8:	89 fb                	mov    %edi,%ebx
  800fba:	89 fe                	mov    %edi,%esi
  800fbc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800fbe:	8b 1c 24             	mov    (%esp),%ebx
  800fc1:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fc5:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fc9:	89 ec                	mov    %ebp,%esp
  800fcb:	5d                   	pop    %ebp
  800fcc:	c3                   	ret    

00800fcd <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800fcd:	55                   	push   %ebp
  800fce:	89 e5                	mov    %esp,%ebp
  800fd0:	83 ec 0c             	sub    $0xc,%esp
  800fd3:	89 1c 24             	mov    %ebx,(%esp)
  800fd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fda:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fde:	b8 02 00 00 00       	mov    $0x2,%eax
  800fe3:	bf 00 00 00 00       	mov    $0x0,%edi
  800fe8:	89 fa                	mov    %edi,%edx
  800fea:	89 f9                	mov    %edi,%ecx
  800fec:	89 fb                	mov    %edi,%ebx
  800fee:	89 fe                	mov    %edi,%esi
  800ff0:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ff2:	8b 1c 24             	mov    (%esp),%ebx
  800ff5:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ff9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ffd:	89 ec                	mov    %ebp,%esp
  800fff:	5d                   	pop    %ebp
  801000:	c3                   	ret    

00801001 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	83 ec 28             	sub    $0x28,%esp
  801007:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80100a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80100d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801010:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801013:	b8 03 00 00 00       	mov    $0x3,%eax
  801018:	bf 00 00 00 00       	mov    $0x0,%edi
  80101d:	89 f9                	mov    %edi,%ecx
  80101f:	89 fb                	mov    %edi,%ebx
  801021:	89 fe                	mov    %edi,%esi
  801023:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801025:	85 c0                	test   %eax,%eax
  801027:	7e 28                	jle    801051 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801029:	89 44 24 10          	mov    %eax,0x10(%esp)
  80102d:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801034:	00 
  801035:	c7 44 24 08 ff 25 80 	movl   $0x8025ff,0x8(%esp)
  80103c:	00 
  80103d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801044:	00 
  801045:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  80104c:	e8 bb 0d 00 00       	call   801e0c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801051:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801054:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801057:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80105a:	89 ec                	mov    %ebp,%esp
  80105c:	5d                   	pop    %ebp
  80105d:	c3                   	ret    
	...

00801060 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	8b 45 08             	mov    0x8(%ebp),%eax
  801066:	05 00 00 00 30       	add    $0x30000000,%eax
  80106b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80106e:	5d                   	pop    %ebp
  80106f:	c3                   	ret    

00801070 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801076:	8b 45 08             	mov    0x8(%ebp),%eax
  801079:	89 04 24             	mov    %eax,(%esp)
  80107c:	e8 df ff ff ff       	call   801060 <fd2num>
  801081:	c1 e0 0c             	shl    $0xc,%eax
  801084:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801089:	c9                   	leave  
  80108a:	c3                   	ret    

0080108b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80108b:	55                   	push   %ebp
  80108c:	89 e5                	mov    %esp,%ebp
  80108e:	53                   	push   %ebx
  80108f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801092:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  801097:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801099:	89 d0                	mov    %edx,%eax
  80109b:	c1 e8 16             	shr    $0x16,%eax
  80109e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010a5:	a8 01                	test   $0x1,%al
  8010a7:	74 10                	je     8010b9 <fd_alloc+0x2e>
  8010a9:	89 d0                	mov    %edx,%eax
  8010ab:	c1 e8 0c             	shr    $0xc,%eax
  8010ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010b5:	a8 01                	test   $0x1,%al
  8010b7:	75 09                	jne    8010c2 <fd_alloc+0x37>
			*fd_store = fd;
  8010b9:	89 0b                	mov    %ecx,(%ebx)
  8010bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c0:	eb 19                	jmp    8010db <fd_alloc+0x50>
			return 0;
  8010c2:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010c8:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  8010ce:	75 c7                	jne    801097 <fd_alloc+0xc>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010d0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010d6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8010db:	5b                   	pop    %ebx
  8010dc:	5d                   	pop    %ebp
  8010dd:	c3                   	ret    

008010de <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010e1:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  8010e5:	77 38                	ja     80111f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ea:	c1 e0 0c             	shl    $0xc,%eax
  8010ed:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  8010f3:	89 d0                	mov    %edx,%eax
  8010f5:	c1 e8 16             	shr    $0x16,%eax
  8010f8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010ff:	a8 01                	test   $0x1,%al
  801101:	74 1c                	je     80111f <fd_lookup+0x41>
  801103:	89 d0                	mov    %edx,%eax
  801105:	c1 e8 0c             	shr    $0xc,%eax
  801108:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80110f:	a8 01                	test   $0x1,%al
  801111:	74 0c                	je     80111f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801113:	8b 45 0c             	mov    0xc(%ebp),%eax
  801116:	89 10                	mov    %edx,(%eax)
  801118:	b8 00 00 00 00       	mov    $0x0,%eax
  80111d:	eb 05                	jmp    801124 <fd_lookup+0x46>
	return 0;
  80111f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801124:	5d                   	pop    %ebp
  801125:	c3                   	ret    

00801126 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801126:	55                   	push   %ebp
  801127:	89 e5                	mov    %esp,%ebp
  801129:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80112c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80112f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801133:	8b 45 08             	mov    0x8(%ebp),%eax
  801136:	89 04 24             	mov    %eax,(%esp)
  801139:	e8 a0 ff ff ff       	call   8010de <fd_lookup>
  80113e:	85 c0                	test   %eax,%eax
  801140:	78 0e                	js     801150 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801142:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801145:	8b 55 0c             	mov    0xc(%ebp),%edx
  801148:	89 50 04             	mov    %edx,0x4(%eax)
  80114b:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801150:	c9                   	leave  
  801151:	c3                   	ret    

00801152 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801152:	55                   	push   %ebp
  801153:	89 e5                	mov    %esp,%ebp
  801155:	53                   	push   %ebx
  801156:	83 ec 14             	sub    $0x14,%esp
  801159:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80115c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80115f:	ba 04 60 80 00       	mov    $0x806004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801164:	b8 00 00 00 00       	mov    $0x0,%eax
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801169:	39 0d 04 60 80 00    	cmp    %ecx,0x806004
  80116f:	75 11                	jne    801182 <dev_lookup+0x30>
  801171:	eb 04                	jmp    801177 <dev_lookup+0x25>
  801173:	39 0a                	cmp    %ecx,(%edx)
  801175:	75 0b                	jne    801182 <dev_lookup+0x30>
			*dev = devtab[i];
  801177:	89 13                	mov    %edx,(%ebx)
  801179:	b8 00 00 00 00       	mov    $0x0,%eax
  80117e:	66 90                	xchg   %ax,%ax
  801180:	eb 35                	jmp    8011b7 <dev_lookup+0x65>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801182:	83 c0 01             	add    $0x1,%eax
  801185:	8b 14 85 ac 26 80 00 	mov    0x8026ac(,%eax,4),%edx
  80118c:	85 d2                	test   %edx,%edx
  80118e:	75 e3                	jne    801173 <dev_lookup+0x21>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  801190:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801195:	8b 40 4c             	mov    0x4c(%eax),%eax
  801198:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80119c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a0:	c7 04 24 2c 26 80 00 	movl   $0x80262c,(%esp)
  8011a7:	e8 f5 ef ff ff       	call   8001a1 <cprintf>
	*dev = 0;
  8011ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8011b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8011b7:	83 c4 14             	add    $0x14,%esp
  8011ba:	5b                   	pop    %ebx
  8011bb:	5d                   	pop    %ebp
  8011bc:	c3                   	ret    

008011bd <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8011bd:	55                   	push   %ebp
  8011be:	89 e5                	mov    %esp,%ebp
  8011c0:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c3:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8011c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8011cd:	89 04 24             	mov    %eax,(%esp)
  8011d0:	e8 09 ff ff ff       	call   8010de <fd_lookup>
  8011d5:	89 c2                	mov    %eax,%edx
  8011d7:	85 c0                	test   %eax,%eax
  8011d9:	78 5a                	js     801235 <fstat+0x78>
  8011db:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011e5:	8b 00                	mov    (%eax),%eax
  8011e7:	89 04 24             	mov    %eax,(%esp)
  8011ea:	e8 63 ff ff ff       	call   801152 <dev_lookup>
  8011ef:	89 c2                	mov    %eax,%edx
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	78 40                	js     801235 <fstat+0x78>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8011f5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  8011fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011fd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801201:	74 32                	je     801235 <fstat+0x78>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801203:	8b 45 0c             	mov    0xc(%ebp),%eax
  801206:	c6 00 00             	movb   $0x0,(%eax)
	stat->st_size = 0;
  801209:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  801210:	00 00 00 
	stat->st_isdir = 0;
  801213:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
  80121a:	00 00 00 
	stat->st_dev = dev;
  80121d:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801220:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
	return (*dev->dev_stat)(fd, stat);
  801226:	89 44 24 04          	mov    %eax,0x4(%esp)
  80122a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80122d:	89 04 24             	mov    %eax,(%esp)
  801230:	ff 52 14             	call   *0x14(%edx)
  801233:	89 c2                	mov    %eax,%edx
}
  801235:	89 d0                	mov    %edx,%eax
  801237:	c9                   	leave  
  801238:	c3                   	ret    

00801239 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801239:	55                   	push   %ebp
  80123a:	89 e5                	mov    %esp,%ebp
  80123c:	53                   	push   %ebx
  80123d:	83 ec 24             	sub    $0x24,%esp
  801240:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801243:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801246:	89 44 24 04          	mov    %eax,0x4(%esp)
  80124a:	89 1c 24             	mov    %ebx,(%esp)
  80124d:	e8 8c fe ff ff       	call   8010de <fd_lookup>
  801252:	85 c0                	test   %eax,%eax
  801254:	78 61                	js     8012b7 <ftruncate+0x7e>
  801256:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801259:	8b 10                	mov    (%eax),%edx
  80125b:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80125e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801262:	89 14 24             	mov    %edx,(%esp)
  801265:	e8 e8 fe ff ff       	call   801152 <dev_lookup>
  80126a:	85 c0                	test   %eax,%eax
  80126c:	78 49                	js     8012b7 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80126e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801271:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801275:	75 23                	jne    80129a <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801277:	a1 3c 60 80 00       	mov    0x80603c,%eax
  80127c:	8b 40 4c             	mov    0x4c(%eax),%eax
  80127f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801283:	89 44 24 04          	mov    %eax,0x4(%esp)
  801287:	c7 04 24 4c 26 80 00 	movl   $0x80264c,(%esp)
  80128e:	e8 0e ef ff ff       	call   8001a1 <cprintf>
  801293:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801298:	eb 1d                	jmp    8012b7 <ftruncate+0x7e>
			env->env_id, fdnum); 
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80129a:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80129d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012a2:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  8012a6:	74 0f                	je     8012b7 <ftruncate+0x7e>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012a8:	8b 42 18             	mov    0x18(%edx),%eax
  8012ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012b2:	89 0c 24             	mov    %ecx,(%esp)
  8012b5:	ff d0                	call   *%eax
}
  8012b7:	83 c4 24             	add    $0x24,%esp
  8012ba:	5b                   	pop    %ebx
  8012bb:	5d                   	pop    %ebp
  8012bc:	c3                   	ret    

008012bd <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
  8012c0:	53                   	push   %ebx
  8012c1:	83 ec 24             	sub    $0x24,%esp
  8012c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ce:	89 1c 24             	mov    %ebx,(%esp)
  8012d1:	e8 08 fe ff ff       	call   8010de <fd_lookup>
  8012d6:	85 c0                	test   %eax,%eax
  8012d8:	78 68                	js     801342 <write+0x85>
  8012da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012dd:	8b 10                	mov    (%eax),%edx
  8012df:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8012e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e6:	89 14 24             	mov    %edx,(%esp)
  8012e9:	e8 64 fe ff ff       	call   801152 <dev_lookup>
  8012ee:	85 c0                	test   %eax,%eax
  8012f0:	78 50                	js     801342 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012f2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  8012f5:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  8012f9:	75 23                	jne    80131e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  8012fb:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801300:	8b 40 4c             	mov    0x4c(%eax),%eax
  801303:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801307:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130b:	c7 04 24 70 26 80 00 	movl   $0x802670,(%esp)
  801312:	e8 8a ee ff ff       	call   8001a1 <cprintf>
  801317:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80131c:	eb 24                	jmp    801342 <write+0x85>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80131e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801321:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801326:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  80132a:	74 16                	je     801342 <write+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80132c:	8b 42 0c             	mov    0xc(%edx),%eax
  80132f:	8b 55 10             	mov    0x10(%ebp),%edx
  801332:	89 54 24 08          	mov    %edx,0x8(%esp)
  801336:	8b 55 0c             	mov    0xc(%ebp),%edx
  801339:	89 54 24 04          	mov    %edx,0x4(%esp)
  80133d:	89 0c 24             	mov    %ecx,(%esp)
  801340:	ff d0                	call   *%eax
}
  801342:	83 c4 24             	add    $0x24,%esp
  801345:	5b                   	pop    %ebx
  801346:	5d                   	pop    %ebp
  801347:	c3                   	ret    

00801348 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801348:	55                   	push   %ebp
  801349:	89 e5                	mov    %esp,%ebp
  80134b:	53                   	push   %ebx
  80134c:	83 ec 24             	sub    $0x24,%esp
  80134f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801352:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801355:	89 44 24 04          	mov    %eax,0x4(%esp)
  801359:	89 1c 24             	mov    %ebx,(%esp)
  80135c:	e8 7d fd ff ff       	call   8010de <fd_lookup>
  801361:	85 c0                	test   %eax,%eax
  801363:	78 6d                	js     8013d2 <read+0x8a>
  801365:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801368:	8b 10                	mov    (%eax),%edx
  80136a:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80136d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801371:	89 14 24             	mov    %edx,(%esp)
  801374:	e8 d9 fd ff ff       	call   801152 <dev_lookup>
  801379:	85 c0                	test   %eax,%eax
  80137b:	78 55                	js     8013d2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80137d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801380:	8b 41 08             	mov    0x8(%ecx),%eax
  801383:	83 e0 03             	and    $0x3,%eax
  801386:	83 f8 01             	cmp    $0x1,%eax
  801389:	75 23                	jne    8013ae <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  80138b:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801390:	8b 40 4c             	mov    0x4c(%eax),%eax
  801393:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801397:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139b:	c7 04 24 8d 26 80 00 	movl   $0x80268d,(%esp)
  8013a2:	e8 fa ed ff ff       	call   8001a1 <cprintf>
  8013a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013ac:	eb 24                	jmp    8013d2 <read+0x8a>
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8013ae:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8013b1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013b6:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  8013ba:	74 16                	je     8013d2 <read+0x8a>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013bc:	8b 42 08             	mov    0x8(%edx),%eax
  8013bf:	8b 55 10             	mov    0x10(%ebp),%edx
  8013c2:	89 54 24 08          	mov    %edx,0x8(%esp)
  8013c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013cd:	89 0c 24             	mov    %ecx,(%esp)
  8013d0:	ff d0                	call   *%eax
}
  8013d2:	83 c4 24             	add    $0x24,%esp
  8013d5:	5b                   	pop    %ebx
  8013d6:	5d                   	pop    %ebp
  8013d7:	c3                   	ret    

008013d8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013d8:	55                   	push   %ebp
  8013d9:	89 e5                	mov    %esp,%ebp
  8013db:	57                   	push   %edi
  8013dc:	56                   	push   %esi
  8013dd:	53                   	push   %ebx
  8013de:	83 ec 0c             	sub    $0xc,%esp
  8013e1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8013e4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ec:	85 f6                	test   %esi,%esi
  8013ee:	74 36                	je     801426 <readn+0x4e>
  8013f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013f5:	ba 00 00 00 00       	mov    $0x0,%edx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013fa:	89 f0                	mov    %esi,%eax
  8013fc:	29 d0                	sub    %edx,%eax
  8013fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801402:	8d 04 17             	lea    (%edi,%edx,1),%eax
  801405:	89 44 24 04          	mov    %eax,0x4(%esp)
  801409:	8b 45 08             	mov    0x8(%ebp),%eax
  80140c:	89 04 24             	mov    %eax,(%esp)
  80140f:	e8 34 ff ff ff       	call   801348 <read>
		if (m < 0)
  801414:	85 c0                	test   %eax,%eax
  801416:	78 0e                	js     801426 <readn+0x4e>
			return m;
		if (m == 0)
  801418:	85 c0                	test   %eax,%eax
  80141a:	74 08                	je     801424 <readn+0x4c>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80141c:	01 c3                	add    %eax,%ebx
  80141e:	89 da                	mov    %ebx,%edx
  801420:	39 f3                	cmp    %esi,%ebx
  801422:	72 d6                	jb     8013fa <readn+0x22>
  801424:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801426:	83 c4 0c             	add    $0xc,%esp
  801429:	5b                   	pop    %ebx
  80142a:	5e                   	pop    %esi
  80142b:	5f                   	pop    %edi
  80142c:	5d                   	pop    %ebp
  80142d:	c3                   	ret    

0080142e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	83 ec 28             	sub    $0x28,%esp
  801434:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801437:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80143a:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80143d:	89 34 24             	mov    %esi,(%esp)
  801440:	e8 1b fc ff ff       	call   801060 <fd2num>
  801445:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801448:	89 54 24 04          	mov    %edx,0x4(%esp)
  80144c:	89 04 24             	mov    %eax,(%esp)
  80144f:	e8 8a fc ff ff       	call   8010de <fd_lookup>
  801454:	89 c3                	mov    %eax,%ebx
  801456:	85 c0                	test   %eax,%eax
  801458:	78 05                	js     80145f <fd_close+0x31>
  80145a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80145d:	74 0d                	je     80146c <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80145f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801463:	75 44                	jne    8014a9 <fd_close+0x7b>
  801465:	bb 00 00 00 00       	mov    $0x0,%ebx
  80146a:	eb 3d                	jmp    8014a9 <fd_close+0x7b>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80146c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80146f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801473:	8b 06                	mov    (%esi),%eax
  801475:	89 04 24             	mov    %eax,(%esp)
  801478:	e8 d5 fc ff ff       	call   801152 <dev_lookup>
  80147d:	89 c3                	mov    %eax,%ebx
  80147f:	85 c0                	test   %eax,%eax
  801481:	78 16                	js     801499 <fd_close+0x6b>
		if (dev->dev_close)
  801483:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801486:	8b 40 10             	mov    0x10(%eax),%eax
  801489:	bb 00 00 00 00       	mov    $0x0,%ebx
  80148e:	85 c0                	test   %eax,%eax
  801490:	74 07                	je     801499 <fd_close+0x6b>
			r = (*dev->dev_close)(fd);
  801492:	89 34 24             	mov    %esi,(%esp)
  801495:	ff d0                	call   *%eax
  801497:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801499:	89 74 24 04          	mov    %esi,0x4(%esp)
  80149d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014a4:	e8 d5 f9 ff ff       	call   800e7e <sys_page_unmap>
	return r;
}
  8014a9:	89 d8                	mov    %ebx,%eax
  8014ab:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014ae:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8014b1:	89 ec                	mov    %ebp,%esp
  8014b3:	5d                   	pop    %ebp
  8014b4:	c3                   	ret    

008014b5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014b5:	55                   	push   %ebp
  8014b6:	89 e5                	mov    %esp,%ebp
  8014b8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014bb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c5:	89 04 24             	mov    %eax,(%esp)
  8014c8:	e8 11 fc ff ff       	call   8010de <fd_lookup>
  8014cd:	85 c0                	test   %eax,%eax
  8014cf:	78 13                	js     8014e4 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8014d1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8014d8:	00 
  8014d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014dc:	89 04 24             	mov    %eax,(%esp)
  8014df:	e8 4a ff ff ff       	call   80142e <fd_close>
}
  8014e4:	c9                   	leave  
  8014e5:	c3                   	ret    

008014e6 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8014e6:	55                   	push   %ebp
  8014e7:	89 e5                	mov    %esp,%ebp
  8014e9:	83 ec 18             	sub    $0x18,%esp
  8014ec:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8014ef:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014f2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014f9:	00 
  8014fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fd:	89 04 24             	mov    %eax,(%esp)
  801500:	e8 5a 03 00 00       	call   80185f <open>
  801505:	89 c6                	mov    %eax,%esi
  801507:	85 c0                	test   %eax,%eax
  801509:	78 1b                	js     801526 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  80150b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80150e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801512:	89 34 24             	mov    %esi,(%esp)
  801515:	e8 a3 fc ff ff       	call   8011bd <fstat>
  80151a:	89 c3                	mov    %eax,%ebx
	close(fd);
  80151c:	89 34 24             	mov    %esi,(%esp)
  80151f:	e8 91 ff ff ff       	call   8014b5 <close>
  801524:	89 de                	mov    %ebx,%esi
	return r;
}
  801526:	89 f0                	mov    %esi,%eax
  801528:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80152b:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80152e:	89 ec                	mov    %ebp,%esp
  801530:	5d                   	pop    %ebp
  801531:	c3                   	ret    

00801532 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801532:	55                   	push   %ebp
  801533:	89 e5                	mov    %esp,%ebp
  801535:	83 ec 38             	sub    $0x38,%esp
  801538:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80153b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80153e:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801541:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801544:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801547:	89 44 24 04          	mov    %eax,0x4(%esp)
  80154b:	8b 45 08             	mov    0x8(%ebp),%eax
  80154e:	89 04 24             	mov    %eax,(%esp)
  801551:	e8 88 fb ff ff       	call   8010de <fd_lookup>
  801556:	89 c3                	mov    %eax,%ebx
  801558:	85 c0                	test   %eax,%eax
  80155a:	0f 88 e1 00 00 00    	js     801641 <dup+0x10f>
		return r;
	close(newfdnum);
  801560:	89 3c 24             	mov    %edi,(%esp)
  801563:	e8 4d ff ff ff       	call   8014b5 <close>

	newfd = INDEX2FD(newfdnum);
  801568:	89 f8                	mov    %edi,%eax
  80156a:	c1 e0 0c             	shl    $0xc,%eax
  80156d:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  801573:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801576:	89 04 24             	mov    %eax,(%esp)
  801579:	e8 f2 fa ff ff       	call   801070 <fd2data>
  80157e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801580:	89 34 24             	mov    %esi,(%esp)
  801583:	e8 e8 fa ff ff       	call   801070 <fd2data>
  801588:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  80158b:	89 d8                	mov    %ebx,%eax
  80158d:	c1 e8 16             	shr    $0x16,%eax
  801590:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801597:	a8 01                	test   $0x1,%al
  801599:	74 45                	je     8015e0 <dup+0xae>
  80159b:	89 da                	mov    %ebx,%edx
  80159d:	c1 ea 0c             	shr    $0xc,%edx
  8015a0:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8015a7:	a8 01                	test   $0x1,%al
  8015a9:	74 35                	je     8015e0 <dup+0xae>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  8015ab:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8015b2:	25 07 0e 00 00       	and    $0xe07,%eax
  8015b7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8015be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015c2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015c9:	00 
  8015ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015d5:	e8 02 f9 ff ff       	call   800edc <sys_page_map>
  8015da:	89 c3                	mov    %eax,%ebx
  8015dc:	85 c0                	test   %eax,%eax
  8015de:	78 3e                	js     80161e <dup+0xec>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  8015e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015e3:	89 d0                	mov    %edx,%eax
  8015e5:	c1 e8 0c             	shr    $0xc,%eax
  8015e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015ef:	25 07 0e 00 00       	and    $0xe07,%eax
  8015f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015f8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8015fc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801603:	00 
  801604:	89 54 24 04          	mov    %edx,0x4(%esp)
  801608:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80160f:	e8 c8 f8 ff ff       	call   800edc <sys_page_map>
  801614:	89 c3                	mov    %eax,%ebx
  801616:	85 c0                	test   %eax,%eax
  801618:	78 04                	js     80161e <dup+0xec>
		goto err;
  80161a:	89 fb                	mov    %edi,%ebx
  80161c:	eb 23                	jmp    801641 <dup+0x10f>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80161e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801622:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801629:	e8 50 f8 ff ff       	call   800e7e <sys_page_unmap>
	sys_page_unmap(0, nva);
  80162e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801631:	89 44 24 04          	mov    %eax,0x4(%esp)
  801635:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80163c:	e8 3d f8 ff ff       	call   800e7e <sys_page_unmap>
	return r;
}
  801641:	89 d8                	mov    %ebx,%eax
  801643:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801646:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801649:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80164c:	89 ec                	mov    %ebp,%esp
  80164e:	5d                   	pop    %ebp
  80164f:	c3                   	ret    

00801650 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801650:	55                   	push   %ebp
  801651:	89 e5                	mov    %esp,%ebp
  801653:	53                   	push   %ebx
  801654:	83 ec 04             	sub    $0x4,%esp
  801657:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  80165c:	89 1c 24             	mov    %ebx,(%esp)
  80165f:	e8 51 fe ff ff       	call   8014b5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801664:	83 c3 01             	add    $0x1,%ebx
  801667:	83 fb 20             	cmp    $0x20,%ebx
  80166a:	75 f0                	jne    80165c <close_all+0xc>
		close(i);
}
  80166c:	83 c4 04             	add    $0x4,%esp
  80166f:	5b                   	pop    %ebx
  801670:	5d                   	pop    %ebp
  801671:	c3                   	ret    
	...

00801674 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	53                   	push   %ebx
  801678:	83 ec 14             	sub    $0x14,%esp
  80167b:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80167d:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  801683:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80168a:	00 
  80168b:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801692:	00 
  801693:	89 44 24 04          	mov    %eax,0x4(%esp)
  801697:	89 14 24             	mov    %edx,(%esp)
  80169a:	e8 e1 07 00 00       	call   801e80 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80169f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016a6:	00 
  8016a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016b2:	e8 7d 08 00 00       	call   801f34 <ipc_recv>
}
  8016b7:	83 c4 14             	add    $0x14,%esp
  8016ba:	5b                   	pop    %ebx
  8016bb:	5d                   	pop    %ebp
  8016bc:	c3                   	ret    

008016bd <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c8:	b8 08 00 00 00       	mov    $0x8,%eax
  8016cd:	e8 a2 ff ff ff       	call   801674 <fsipc>
}
  8016d2:	c9                   	leave  
  8016d3:	c3                   	ret    

008016d4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016da:	8b 45 08             	mov    0x8(%ebp),%eax
  8016dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e0:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.set_size.req_size = newsize;
  8016e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e8:	a3 04 30 80 00       	mov    %eax,0x803004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f2:	b8 02 00 00 00       	mov    $0x2,%eax
  8016f7:	e8 78 ff ff ff       	call   801674 <fsipc>
}
  8016fc:	c9                   	leave  
  8016fd:	c3                   	ret    

008016fe <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801704:	8b 45 08             	mov    0x8(%ebp),%eax
  801707:	8b 40 0c             	mov    0xc(%eax),%eax
  80170a:	a3 00 30 80 00       	mov    %eax,0x803000
	return fsipc(FSREQ_FLUSH, NULL);
  80170f:	ba 00 00 00 00       	mov    $0x0,%edx
  801714:	b8 06 00 00 00       	mov    $0x6,%eax
  801719:	e8 56 ff ff ff       	call   801674 <fsipc>
}
  80171e:	c9                   	leave  
  80171f:	c3                   	ret    

00801720 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	53                   	push   %ebx
  801724:	83 ec 14             	sub    $0x14,%esp
  801727:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80172a:	8b 45 08             	mov    0x8(%ebp),%eax
  80172d:	8b 40 0c             	mov    0xc(%eax),%eax
  801730:	a3 00 30 80 00       	mov    %eax,0x803000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801735:	ba 00 00 00 00       	mov    $0x0,%edx
  80173a:	b8 05 00 00 00       	mov    $0x5,%eax
  80173f:	e8 30 ff ff ff       	call   801674 <fsipc>
  801744:	85 c0                	test   %eax,%eax
  801746:	78 2b                	js     801773 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801748:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  80174f:	00 
  801750:	89 1c 24             	mov    %ebx,(%esp)
  801753:	e8 a9 f0 ff ff       	call   800801 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801758:	a1 80 30 80 00       	mov    0x803080,%eax
  80175d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801763:	a1 84 30 80 00       	mov    0x803084,%eax
  801768:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  80176e:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801773:	83 c4 14             	add    $0x14,%esp
  801776:	5b                   	pop    %ebx
  801777:	5d                   	pop    %ebp
  801778:	c3                   	ret    

00801779 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	83 ec 18             	sub    $0x18,%esp
  80177f:	8b 55 10             	mov    0x10(%ebp),%edx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	ssize_t writesize;
	size_t bufsize;
	fsipcbuf.write.req_fileid=fd->fd_file.id;
  801782:	8b 45 08             	mov    0x8(%ebp),%eax
  801785:	8b 40 0c             	mov    0xc(%eax),%eax
  801788:	a3 00 30 80 00       	mov    %eax,0x803000
	bufsize=sizeof(fsipcbuf.write.req_buf);
	if(n<bufsize)
  80178d:	89 d0                	mov    %edx,%eax
  80178f:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  801795:	76 05                	jbe    80179c <devfile_write+0x23>
  801797:	b8 f8 0f 00 00       	mov    $0xff8,%eax
		bufsize=n;	
	fsipcbuf.write.req_n=n;
  80179c:	89 15 04 30 80 00    	mov    %edx,0x803004
	memmove((void*)fsipcbuf.write.req_buf,buf,bufsize);
  8017a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ad:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  8017b4:	e8 4f f2 ff ff       	call   800a08 <memmove>
	writesize=(ssize_t)fsipc(FSREQ_WRITE,NULL);
  8017b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017be:	b8 04 00 00 00       	mov    $0x4,%eax
  8017c3:	e8 ac fe ff ff       	call   801674 <fsipc>
	return writesize;
	//panic("devfile_write not implemented");
}
  8017c8:	c9                   	leave  
  8017c9:	c3                   	ret    

008017ca <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017ca:	55                   	push   %ebp
  8017cb:	89 e5                	mov    %esp,%ebp
  8017cd:	53                   	push   %ebx
  8017ce:	83 ec 14             	sub    $0x14,%esp
	// system server.
	// LAB 5: Your code here
	ssize_t readsize;
	if(debug)
		cprintf("devfile_read:fileid=%x readsize=%x\n",fd->fd_file.id,n);
	fsipcbuf.read.req_fileid=fd->fd_file.id;
  8017d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d7:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.read.req_n=n;
  8017dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8017df:	a3 04 30 80 00       	mov    %eax,0x803004
	readsize=(ssize_t)fsipc(FSREQ_READ,&fsipcbuf);
  8017e4:	ba 00 30 80 00       	mov    $0x803000,%edx
  8017e9:	b8 03 00 00 00       	mov    $0x3,%eax
  8017ee:	e8 81 fe ff ff       	call   801674 <fsipc>
  8017f3:	89 c3                	mov    %eax,%ebx
	//cprintf("readsize=%d\n",readsize);
	if(debug)
		cprintf("devfile_read:buf1=%s\nbuf2=%s\n",(char*)&fsipcbuf,fsipcbuf.readRet.ret_buf);
	if(readsize>0)
  8017f5:	85 c0                	test   %eax,%eax
  8017f7:	7e 17                	jle    801810 <devfile_read+0x46>
		memmove(buf,(void*)&fsipcbuf,(size_t)readsize);
  8017f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017fd:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801804:	00 
  801805:	8b 45 0c             	mov    0xc(%ebp),%eax
  801808:	89 04 24             	mov    %eax,(%esp)
  80180b:	e8 f8 f1 ff ff       	call   800a08 <memmove>
	//cprintf("readsize=%d",readsize);
	return readsize;
	//panic("devfile_read not implemented");
}
  801810:	89 d8                	mov    %ebx,%eax
  801812:	83 c4 14             	add    $0x14,%esp
  801815:	5b                   	pop    %ebx
  801816:	5d                   	pop    %ebp
  801817:	c3                   	ret    

00801818 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
  80181b:	53                   	push   %ebx
  80181c:	83 ec 14             	sub    $0x14,%esp
  80181f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801822:	89 1c 24             	mov    %ebx,(%esp)
  801825:	e8 86 ef ff ff       	call   8007b0 <strlen>
  80182a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  80182f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801834:	7f 21                	jg     801857 <remove+0x3f>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801836:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80183a:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801841:	e8 bb ef ff ff       	call   800801 <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801846:	ba 00 00 00 00       	mov    $0x0,%edx
  80184b:	b8 07 00 00 00       	mov    $0x7,%eax
  801850:	e8 1f fe ff ff       	call   801674 <fsipc>
  801855:	89 c2                	mov    %eax,%edx
}
  801857:	89 d0                	mov    %edx,%eax
  801859:	83 c4 14             	add    $0x14,%esp
  80185c:	5b                   	pop    %ebx
  80185d:	5d                   	pop    %ebp
  80185e:	c3                   	ret    

0080185f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80185f:	55                   	push   %ebp
  801860:	89 e5                	mov    %esp,%ebp
  801862:	56                   	push   %esi
  801863:	53                   	push   %ebx
  801864:	83 ec 30             	sub    $0x30,%esp

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;
	void *page;
	if((r=fd_alloc(&fd))<0){
  801867:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80186a:	89 04 24             	mov    %eax,(%esp)
  80186d:	e8 19 f8 ff ff       	call   80108b <fd_alloc>
  801872:	89 c3                	mov    %eax,%ebx
  801874:	85 c0                	test   %eax,%eax
  801876:	79 18                	jns    801890 <open+0x31>
		fd_close(fd,0);
  801878:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80187f:	00 
  801880:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801883:	89 04 24             	mov    %eax,(%esp)
  801886:	e8 a3 fb ff ff       	call   80142e <fd_close>
  80188b:	e9 9f 00 00 00       	jmp    80192f <open+0xd0>
		return r;
	}
	//cprintf("open:fd=%x\n",fd);
	strcpy(fsipcbuf.open.req_path,path);
  801890:	8b 45 08             	mov    0x8(%ebp),%eax
  801893:	89 44 24 04          	mov    %eax,0x4(%esp)
  801897:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  80189e:	e8 5e ef ff ff       	call   800801 <strcpy>
	fsipcbuf.open.req_omode=mode;
  8018a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a6:	a3 00 34 80 00       	mov    %eax,0x803400
	page=(void*)fd2data(fd);
  8018ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ae:	89 04 24             	mov    %eax,(%esp)
  8018b1:	e8 ba f7 ff ff       	call   801070 <fd2data>
  8018b6:	89 c6                	mov    %eax,%esi
	if((r=fsipc(FSREQ_OPEN,(void*)fd))<0)
  8018b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018bb:	b8 01 00 00 00       	mov    $0x1,%eax
  8018c0:	e8 af fd ff ff       	call   801674 <fsipc>
  8018c5:	89 c3                	mov    %eax,%ebx
  8018c7:	85 c0                	test   %eax,%eax
  8018c9:	79 15                	jns    8018e0 <open+0x81>
	{
		fd_close(fd,1);
  8018cb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8018d2:	00 
  8018d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d6:	89 04 24             	mov    %eax,(%esp)
  8018d9:	e8 50 fb ff ff       	call   80142e <fd_close>
  8018de:	eb 4f                	jmp    80192f <open+0xd0>
		return r;	
	}
	//cprintf("open:page=%x\n",page);
	if((r=sys_page_map(0,(void*)fd,0,(void*)page,PTE_P | PTE_W | PTE_U))<0)
  8018e0:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8018e7:	00 
  8018e8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8018ec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018f3:	00 
  8018f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801902:	e8 d5 f5 ff ff       	call   800edc <sys_page_map>
  801907:	89 c3                	mov    %eax,%ebx
  801909:	85 c0                	test   %eax,%eax
  80190b:	79 15                	jns    801922 <open+0xc3>
	{
		fd_close(fd,1);
  80190d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801914:	00 
  801915:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801918:	89 04 24             	mov    %eax,(%esp)
  80191b:	e8 0e fb ff ff       	call   80142e <fd_close>
  801920:	eb 0d                	jmp    80192f <open+0xd0>
		return r;
	}
	//cprintf("open:fileid=%x\n",fd->fd_file.id);
	return fd2num(fd);
  801922:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801925:	89 04 24             	mov    %eax,(%esp)
  801928:	e8 33 f7 ff ff       	call   801060 <fd2num>
  80192d:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  80192f:	89 d8                	mov    %ebx,%eax
  801931:	83 c4 30             	add    $0x30,%esp
  801934:	5b                   	pop    %ebx
  801935:	5e                   	pop    %esi
  801936:	5d                   	pop    %ebp
  801937:	c3                   	ret    
	...

00801940 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  801946:	c7 44 24 04 b8 26 80 	movl   $0x8026b8,0x4(%esp)
  80194d:	00 
  80194e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801951:	89 04 24             	mov    %eax,(%esp)
  801954:	e8 a8 ee ff ff       	call   800801 <strcpy>
	return 0;
}
  801959:	b8 00 00 00 00       	mov    $0x0,%eax
  80195e:	c9                   	leave  
  80195f:	c3                   	ret    

00801960 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801960:	55                   	push   %ebp
  801961:	89 e5                	mov    %esp,%ebp
  801963:	83 ec 08             	sub    $0x8,%esp
	return nsipc_close(fd->fd_sock.sockid);
  801966:	8b 45 08             	mov    0x8(%ebp),%eax
  801969:	8b 40 0c             	mov    0xc(%eax),%eax
  80196c:	89 04 24             	mov    %eax,(%esp)
  80196f:	e8 9e 02 00 00       	call   801c12 <nsipc_close>
}
  801974:	c9                   	leave  
  801975:	c3                   	ret    

00801976 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801976:	55                   	push   %ebp
  801977:	89 e5                	mov    %esp,%ebp
  801979:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80197c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801983:	00 
  801984:	8b 45 10             	mov    0x10(%ebp),%eax
  801987:	89 44 24 08          	mov    %eax,0x8(%esp)
  80198b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80198e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801992:	8b 45 08             	mov    0x8(%ebp),%eax
  801995:	8b 40 0c             	mov    0xc(%eax),%eax
  801998:	89 04 24             	mov    %eax,(%esp)
  80199b:	e8 ae 02 00 00       	call   801c4e <nsipc_send>
}
  8019a0:	c9                   	leave  
  8019a1:	c3                   	ret    

008019a2 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019a8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8019af:	00 
  8019b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8019b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019be:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c1:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c4:	89 04 24             	mov    %eax,(%esp)
  8019c7:	e8 f5 02 00 00       	call   801cc1 <nsipc_recv>
}
  8019cc:	c9                   	leave  
  8019cd:	c3                   	ret    

008019ce <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  8019ce:	55                   	push   %ebp
  8019cf:	89 e5                	mov    %esp,%ebp
  8019d1:	56                   	push   %esi
  8019d2:	53                   	push   %ebx
  8019d3:	83 ec 20             	sub    $0x20,%esp
  8019d6:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8019d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019db:	89 04 24             	mov    %eax,(%esp)
  8019de:	e8 a8 f6 ff ff       	call   80108b <fd_alloc>
  8019e3:	89 c3                	mov    %eax,%ebx
  8019e5:	85 c0                	test   %eax,%eax
  8019e7:	78 21                	js     801a0a <alloc_sockfd+0x3c>
  8019e9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8019f0:	00 
  8019f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019ff:	e8 36 f5 ff ff       	call   800f3a <sys_page_alloc>
  801a04:	89 c3                	mov    %eax,%ebx
  801a06:	85 c0                	test   %eax,%eax
  801a08:	79 0a                	jns    801a14 <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U)) < 0) {
		nsipc_close(sockid);
  801a0a:	89 34 24             	mov    %esi,(%esp)
  801a0d:	e8 00 02 00 00       	call   801c12 <nsipc_close>
  801a12:	eb 28                	jmp    801a3c <alloc_sockfd+0x6e>
		return r;
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a14:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1d:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a22:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a2c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a32:	89 04 24             	mov    %eax,(%esp)
  801a35:	e8 26 f6 ff ff       	call   801060 <fd2num>
  801a3a:	89 c3                	mov    %eax,%ebx
}
  801a3c:	89 d8                	mov    %ebx,%eax
  801a3e:	83 c4 20             	add    $0x20,%esp
  801a41:	5b                   	pop    %ebx
  801a42:	5e                   	pop    %esi
  801a43:	5d                   	pop    %ebp
  801a44:	c3                   	ret    

00801a45 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a4b:	8b 45 10             	mov    0x10(%ebp),%eax
  801a4e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a52:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a55:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a59:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5c:	89 04 24             	mov    %eax,(%esp)
  801a5f:	e8 62 01 00 00       	call   801bc6 <nsipc_socket>
  801a64:	85 c0                	test   %eax,%eax
  801a66:	78 05                	js     801a6d <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801a68:	e8 61 ff ff ff       	call   8019ce <alloc_sockfd>
}
  801a6d:	c9                   	leave  
  801a6e:	66 90                	xchg   %ax,%ax
  801a70:	c3                   	ret    

00801a71 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	83 ec 18             	sub    $0x18,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a77:	8d 55 fc             	lea    -0x4(%ebp),%edx
  801a7a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a7e:	89 04 24             	mov    %eax,(%esp)
  801a81:	e8 58 f6 ff ff       	call   8010de <fd_lookup>
  801a86:	89 c2                	mov    %eax,%edx
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	78 15                	js     801aa1 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a8c:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  801a8f:	8b 01                	mov    (%ecx),%eax
  801a91:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  801a96:	3b 05 20 60 80 00    	cmp    0x806020,%eax
  801a9c:	75 03                	jne    801aa1 <fd2sockid+0x30>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a9e:	8b 51 0c             	mov    0xc(%ecx),%edx
}
  801aa1:	89 d0                	mov    %edx,%eax
  801aa3:	c9                   	leave  
  801aa4:	c3                   	ret    

00801aa5 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  801aa5:	55                   	push   %ebp
  801aa6:	89 e5                	mov    %esp,%ebp
  801aa8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801aab:	8b 45 08             	mov    0x8(%ebp),%eax
  801aae:	e8 be ff ff ff       	call   801a71 <fd2sockid>
  801ab3:	85 c0                	test   %eax,%eax
  801ab5:	78 0f                	js     801ac6 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801ab7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801aba:	89 54 24 04          	mov    %edx,0x4(%esp)
  801abe:	89 04 24             	mov    %eax,(%esp)
  801ac1:	e8 2a 01 00 00       	call   801bf0 <nsipc_listen>
}
  801ac6:	c9                   	leave  
  801ac7:	c3                   	ret    

00801ac8 <connect>:
	return nsipc_close(fd->fd_sock.sockid);
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ac8:	55                   	push   %ebp
  801ac9:	89 e5                	mov    %esp,%ebp
  801acb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ace:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad1:	e8 9b ff ff ff       	call   801a71 <fd2sockid>
  801ad6:	85 c0                	test   %eax,%eax
  801ad8:	78 16                	js     801af0 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801ada:	8b 55 10             	mov    0x10(%ebp),%edx
  801add:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ae1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ae4:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ae8:	89 04 24             	mov    %eax,(%esp)
  801aeb:	e8 51 02 00 00       	call   801d41 <nsipc_connect>
}
  801af0:	c9                   	leave  
  801af1:	c3                   	ret    

00801af2 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801af8:	8b 45 08             	mov    0x8(%ebp),%eax
  801afb:	e8 71 ff ff ff       	call   801a71 <fd2sockid>
  801b00:	85 c0                	test   %eax,%eax
  801b02:	78 0f                	js     801b13 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b04:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b07:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b0b:	89 04 24             	mov    %eax,(%esp)
  801b0e:	e8 19 01 00 00       	call   801c2c <nsipc_shutdown>
}
  801b13:	c9                   	leave  
  801b14:	c3                   	ret    

00801b15 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1e:	e8 4e ff ff ff       	call   801a71 <fd2sockid>
  801b23:	85 c0                	test   %eax,%eax
  801b25:	78 16                	js     801b3d <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801b27:	8b 55 10             	mov    0x10(%ebp),%edx
  801b2a:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b31:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b35:	89 04 24             	mov    %eax,(%esp)
  801b38:	e8 43 02 00 00       	call   801d80 <nsipc_bind>
}
  801b3d:	c9                   	leave  
  801b3e:	c3                   	ret    

00801b3f <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b3f:	55                   	push   %ebp
  801b40:	89 e5                	mov    %esp,%ebp
  801b42:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b45:	8b 45 08             	mov    0x8(%ebp),%eax
  801b48:	e8 24 ff ff ff       	call   801a71 <fd2sockid>
  801b4d:	85 c0                	test   %eax,%eax
  801b4f:	78 1f                	js     801b70 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b51:	8b 55 10             	mov    0x10(%ebp),%edx
  801b54:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b58:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b5b:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b5f:	89 04 24             	mov    %eax,(%esp)
  801b62:	e8 58 02 00 00       	call   801dbf <nsipc_accept>
  801b67:	85 c0                	test   %eax,%eax
  801b69:	78 05                	js     801b70 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801b6b:	e8 5e fe ff ff       	call   8019ce <alloc_sockfd>
}
  801b70:	c9                   	leave  
  801b71:	c3                   	ret    
	...

00801b80 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b86:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  801b8c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b93:	00 
  801b94:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801b9b:	00 
  801b9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba0:	89 14 24             	mov    %edx,(%esp)
  801ba3:	e8 d8 02 00 00       	call   801e80 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ba8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801baf:	00 
  801bb0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bb7:	00 
  801bb8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bbf:	e8 70 03 00 00       	call   801f34 <ipc_recv>
}
  801bc4:	c9                   	leave  
  801bc5:	c3                   	ret    

00801bc6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801bc6:	55                   	push   %ebp
  801bc7:	89 e5                	mov    %esp,%ebp
  801bc9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801bcc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcf:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.socket.req_type = type;
  801bd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bd7:	a3 04 50 80 00       	mov    %eax,0x805004
	nsipcbuf.socket.req_protocol = protocol;
  801bdc:	8b 45 10             	mov    0x10(%ebp),%eax
  801bdf:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SOCKET);
  801be4:	b8 09 00 00 00       	mov    $0x9,%eax
  801be9:	e8 92 ff ff ff       	call   801b80 <nsipc>
}
  801bee:	c9                   	leave  
  801bef:	c3                   	ret    

00801bf0 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  801bf0:	55                   	push   %ebp
  801bf1:	89 e5                	mov    %esp,%ebp
  801bf3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf9:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.listen.req_backlog = backlog;
  801bfe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c01:	a3 04 50 80 00       	mov    %eax,0x805004
	return nsipc(NSREQ_LISTEN);
  801c06:	b8 06 00 00 00       	mov    $0x6,%eax
  801c0b:	e8 70 ff ff ff       	call   801b80 <nsipc>
}
  801c10:	c9                   	leave  
  801c11:	c3                   	ret    

00801c12 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  801c12:	55                   	push   %ebp
  801c13:	89 e5                	mov    %esp,%ebp
  801c15:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c18:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1b:	a3 00 50 80 00       	mov    %eax,0x805000
	return nsipc(NSREQ_CLOSE);
  801c20:	b8 04 00 00 00       	mov    $0x4,%eax
  801c25:	e8 56 ff ff ff       	call   801b80 <nsipc>
}
  801c2a:	c9                   	leave  
  801c2b:	c3                   	ret    

00801c2c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  801c2c:	55                   	push   %ebp
  801c2d:	89 e5                	mov    %esp,%ebp
  801c2f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c32:	8b 45 08             	mov    0x8(%ebp),%eax
  801c35:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.shutdown.req_how = how;
  801c3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c3d:	a3 04 50 80 00       	mov    %eax,0x805004
	return nsipc(NSREQ_SHUTDOWN);
  801c42:	b8 03 00 00 00       	mov    $0x3,%eax
  801c47:	e8 34 ff ff ff       	call   801b80 <nsipc>
}
  801c4c:	c9                   	leave  
  801c4d:	c3                   	ret    

00801c4e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c4e:	55                   	push   %ebp
  801c4f:	89 e5                	mov    %esp,%ebp
  801c51:	53                   	push   %ebx
  801c52:	83 ec 14             	sub    $0x14,%esp
  801c55:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c58:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5b:	a3 00 50 80 00       	mov    %eax,0x805000
	assert(size < 1600);
  801c60:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c66:	7e 24                	jle    801c8c <nsipc_send+0x3e>
  801c68:	c7 44 24 0c c4 26 80 	movl   $0x8026c4,0xc(%esp)
  801c6f:	00 
  801c70:	c7 44 24 08 d0 26 80 	movl   $0x8026d0,0x8(%esp)
  801c77:	00 
  801c78:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  801c7f:	00 
  801c80:	c7 04 24 e5 26 80 00 	movl   $0x8026e5,(%esp)
  801c87:	e8 80 01 00 00       	call   801e0c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c8c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c90:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c93:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c97:	c7 04 24 0c 50 80 00 	movl   $0x80500c,(%esp)
  801c9e:	e8 65 ed ff ff       	call   800a08 <memmove>
	nsipcbuf.send.req_size = size;
  801ca3:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	nsipcbuf.send.req_flags = flags;
  801ca9:	8b 45 14             	mov    0x14(%ebp),%eax
  801cac:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SEND);
  801cb1:	b8 08 00 00 00       	mov    $0x8,%eax
  801cb6:	e8 c5 fe ff ff       	call   801b80 <nsipc>
}
  801cbb:	83 c4 14             	add    $0x14,%esp
  801cbe:	5b                   	pop    %ebx
  801cbf:	5d                   	pop    %ebp
  801cc0:	c3                   	ret    

00801cc1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801cc1:	55                   	push   %ebp
  801cc2:	89 e5                	mov    %esp,%ebp
  801cc4:	56                   	push   %esi
  801cc5:	53                   	push   %ebx
  801cc6:	83 ec 10             	sub    $0x10,%esp
  801cc9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801ccc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ccf:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.recv.req_len = len;
  801cd4:	89 35 04 50 80 00    	mov    %esi,0x805004
	nsipcbuf.recv.req_flags = flags;
  801cda:	8b 45 14             	mov    0x14(%ebp),%eax
  801cdd:	a3 08 50 80 00       	mov    %eax,0x805008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ce2:	b8 07 00 00 00       	mov    $0x7,%eax
  801ce7:	e8 94 fe ff ff       	call   801b80 <nsipc>
  801cec:	89 c3                	mov    %eax,%ebx
  801cee:	85 c0                	test   %eax,%eax
  801cf0:	78 46                	js     801d38 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801cf2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801cf7:	7f 04                	jg     801cfd <nsipc_recv+0x3c>
  801cf9:	39 c6                	cmp    %eax,%esi
  801cfb:	7d 24                	jge    801d21 <nsipc_recv+0x60>
  801cfd:	c7 44 24 0c f1 26 80 	movl   $0x8026f1,0xc(%esp)
  801d04:	00 
  801d05:	c7 44 24 08 d0 26 80 	movl   $0x8026d0,0x8(%esp)
  801d0c:	00 
  801d0d:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  801d14:	00 
  801d15:	c7 04 24 e5 26 80 00 	movl   $0x8026e5,(%esp)
  801d1c:	e8 eb 00 00 00       	call   801e0c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d21:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d25:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801d2c:	00 
  801d2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d30:	89 04 24             	mov    %eax,(%esp)
  801d33:	e8 d0 ec ff ff       	call   800a08 <memmove>
	}

	return r;
}
  801d38:	89 d8                	mov    %ebx,%eax
  801d3a:	83 c4 10             	add    $0x10,%esp
  801d3d:	5b                   	pop    %ebx
  801d3e:	5e                   	pop    %esi
  801d3f:	5d                   	pop    %ebp
  801d40:	c3                   	ret    

00801d41 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d41:	55                   	push   %ebp
  801d42:	89 e5                	mov    %esp,%ebp
  801d44:	53                   	push   %ebx
  801d45:	83 ec 14             	sub    $0x14,%esp
  801d48:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4e:	a3 00 50 80 00       	mov    %eax,0x805000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d53:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d57:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d5e:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  801d65:	e8 9e ec ff ff       	call   800a08 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d6a:	89 1d 14 50 80 00    	mov    %ebx,0x805014
	return nsipc(NSREQ_CONNECT);
  801d70:	b8 05 00 00 00       	mov    $0x5,%eax
  801d75:	e8 06 fe ff ff       	call   801b80 <nsipc>
}
  801d7a:	83 c4 14             	add    $0x14,%esp
  801d7d:	5b                   	pop    %ebx
  801d7e:	5d                   	pop    %ebp
  801d7f:	c3                   	ret    

00801d80 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
  801d83:	53                   	push   %ebx
  801d84:	83 ec 14             	sub    $0x14,%esp
  801d87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8d:	a3 00 50 80 00       	mov    %eax,0x805000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d92:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d96:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d99:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d9d:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  801da4:	e8 5f ec ff ff       	call   800a08 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801da9:	89 1d 14 50 80 00    	mov    %ebx,0x805014
	return nsipc(NSREQ_BIND);
  801daf:	b8 02 00 00 00       	mov    $0x2,%eax
  801db4:	e8 c7 fd ff ff       	call   801b80 <nsipc>
}
  801db9:	83 c4 14             	add    $0x14,%esp
  801dbc:	5b                   	pop    %ebx
  801dbd:	5d                   	pop    %ebp
  801dbe:	c3                   	ret    

00801dbf <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801dbf:	55                   	push   %ebp
  801dc0:	89 e5                	mov    %esp,%ebp
  801dc2:	53                   	push   %ebx
  801dc3:	83 ec 14             	sub    $0x14,%esp
	int r;
	
	nsipcbuf.accept.req_s = s;
  801dc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801dce:	b8 01 00 00 00       	mov    $0x1,%eax
  801dd3:	e8 a8 fd ff ff       	call   801b80 <nsipc>
  801dd8:	89 c3                	mov    %eax,%ebx
  801dda:	85 c0                	test   %eax,%eax
  801ddc:	78 26                	js     801e04 <nsipc_accept+0x45>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801dde:	a1 10 50 80 00       	mov    0x805010,%eax
  801de3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801de7:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801dee:	00 
  801def:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df2:	89 04 24             	mov    %eax,(%esp)
  801df5:	e8 0e ec ff ff       	call   800a08 <memmove>
		*addrlen = ret->ret_addrlen;
  801dfa:	a1 10 50 80 00       	mov    0x805010,%eax
  801dff:	8b 55 10             	mov    0x10(%ebp),%edx
  801e02:	89 02                	mov    %eax,(%edx)
	}
	return r;
}
  801e04:	89 d8                	mov    %ebx,%eax
  801e06:	83 c4 14             	add    $0x14,%esp
  801e09:	5b                   	pop    %ebx
  801e0a:	5d                   	pop    %ebp
  801e0b:	c3                   	ret    

00801e0c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  801e0c:	55                   	push   %ebp
  801e0d:	89 e5                	mov    %esp,%ebp
  801e0f:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  801e12:	8d 45 14             	lea    0x14(%ebp),%eax
  801e15:	89 45 fc             	mov    %eax,-0x4(%ebp)

	// Print the panic message
	if (argv0)
  801e18:	a1 40 60 80 00       	mov    0x806040,%eax
  801e1d:	85 c0                	test   %eax,%eax
  801e1f:	74 10                	je     801e31 <_panic+0x25>
		cprintf("%s: ", argv0);
  801e21:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e25:	c7 04 24 06 27 80 00 	movl   $0x802706,(%esp)
  801e2c:	e8 70 e3 ff ff       	call   8001a1 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  801e31:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e34:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e38:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e3f:	a1 00 60 80 00       	mov    0x806000,%eax
  801e44:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e48:	c7 04 24 0b 27 80 00 	movl   $0x80270b,(%esp)
  801e4f:	e8 4d e3 ff ff       	call   8001a1 <cprintf>
	vcprintf(fmt, ap);
  801e54:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801e57:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e5b:	8b 45 10             	mov    0x10(%ebp),%eax
  801e5e:	89 04 24             	mov    %eax,(%esp)
  801e61:	e8 da e2 ff ff       	call   800140 <vcprintf>
	cprintf("\n");
  801e66:	c7 04 24 69 27 80 00 	movl   $0x802769,(%esp)
  801e6d:	e8 2f e3 ff ff       	call   8001a1 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e72:	cc                   	int3   
  801e73:	eb fd                	jmp    801e72 <_panic+0x66>
	...

00801e80 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	57                   	push   %edi
  801e84:	56                   	push   %esi
  801e85:	53                   	push   %ebx
  801e86:	83 ec 1c             	sub    $0x1c,%esp
  801e89:	8b 75 08             	mov    0x8(%ebp),%esi
  801e8c:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  801e8f:	e8 39 f1 ff ff       	call   800fcd <sys_getenvid>
  801e94:	25 ff 03 00 00       	and    $0x3ff,%eax
  801e99:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e9c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ea1:	a3 3c 60 80 00       	mov    %eax,0x80603c
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  801ea6:	e8 22 f1 ff ff       	call   800fcd <sys_getenvid>
  801eab:	25 ff 03 00 00       	and    $0x3ff,%eax
  801eb0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801eb3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801eb8:	a3 3c 60 80 00       	mov    %eax,0x80603c
		if(env->env_id==to_env){
  801ebd:	8b 40 4c             	mov    0x4c(%eax),%eax
  801ec0:	39 f0                	cmp    %esi,%eax
  801ec2:	75 0e                	jne    801ed2 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  801ec4:	c7 04 24 27 27 80 00 	movl   $0x802727,(%esp)
  801ecb:	e8 d1 e2 ff ff       	call   8001a1 <cprintf>
  801ed0:	eb 5a                	jmp    801f2c <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  801ed2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ed6:	8b 45 10             	mov    0x10(%ebp),%eax
  801ed9:	89 44 24 08          	mov    %eax,0x8(%esp)
  801edd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ee4:	89 34 24             	mov    %esi,(%esp)
  801ee7:	e8 40 ee ff ff       	call   800d2c <sys_ipc_try_send>
  801eec:	89 c3                	mov    %eax,%ebx
  801eee:	85 c0                	test   %eax,%eax
  801ef0:	79 25                	jns    801f17 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  801ef2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ef5:	74 2b                	je     801f22 <ipc_send+0xa2>
				panic("send error:%e",r);
  801ef7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801efb:	c7 44 24 08 43 27 80 	movl   $0x802743,0x8(%esp)
  801f02:	00 
  801f03:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  801f0a:	00 
  801f0b:	c7 04 24 51 27 80 00 	movl   $0x802751,(%esp)
  801f12:	e8 f5 fe ff ff       	call   801e0c <_panic>
		}
			sys_yield();
  801f17:	e8 7d f0 ff ff       	call   800f99 <sys_yield>
		
	}while(r!=0);
  801f1c:	85 db                	test   %ebx,%ebx
  801f1e:	75 86                	jne    801ea6 <ipc_send+0x26>
  801f20:	eb 0a                	jmp    801f2c <ipc_send+0xac>
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
		{	
			if(r!=-E_IPC_NOT_RECV)
				panic("send error:%e",r);
		}
			sys_yield();
  801f22:	e8 72 f0 ff ff       	call   800f99 <sys_yield>
  801f27:	e9 7a ff ff ff       	jmp    801ea6 <ipc_send+0x26>
		
	}while(r!=0);
	return;
	//panic("ipc_send not implemented");
}
  801f2c:	83 c4 1c             	add    $0x1c,%esp
  801f2f:	5b                   	pop    %ebx
  801f30:	5e                   	pop    %esi
  801f31:	5f                   	pop    %edi
  801f32:	5d                   	pop    %ebp
  801f33:	c3                   	ret    

00801f34 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f34:	55                   	push   %ebp
  801f35:	89 e5                	mov    %esp,%ebp
  801f37:	57                   	push   %edi
  801f38:	56                   	push   %esi
  801f39:	53                   	push   %ebx
  801f3a:	83 ec 0c             	sub    $0xc,%esp
  801f3d:	8b 75 08             	mov    0x8(%ebp),%esi
  801f40:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	void *dstva=NULL;
	if(pg)
		dstva=pg;
	env = &envs[ENVX(sys_getenvid())];
  801f43:	e8 85 f0 ff ff       	call   800fcd <sys_getenvid>
  801f48:	25 ff 03 00 00       	and    $0x3ff,%eax
  801f4d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f50:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f55:	a3 3c 60 80 00       	mov    %eax,0x80603c
	if(from_env_store&&(env->env_id==*from_env_store))
  801f5a:	85 f6                	test   %esi,%esi
  801f5c:	74 29                	je     801f87 <ipc_recv+0x53>
  801f5e:	8b 40 4c             	mov    0x4c(%eax),%eax
  801f61:	3b 06                	cmp    (%esi),%eax
  801f63:	75 22                	jne    801f87 <ipc_recv+0x53>
	{
		*from_env_store=0;
  801f65:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  801f6b:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("send:the reciver is sender\n");
  801f71:	c7 04 24 27 27 80 00 	movl   $0x802727,(%esp)
  801f78:	e8 24 e2 ff ff       	call   8001a1 <cprintf>
  801f7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f82:	e9 8a 00 00 00       	jmp    802011 <ipc_recv+0xdd>
		return 0;
	}
	env = &envs[ENVX(sys_getenvid())];
  801f87:	e8 41 f0 ff ff       	call   800fcd <sys_getenvid>
  801f8c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801f91:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f94:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f99:	a3 3c 60 80 00       	mov    %eax,0x80603c
	if((r=sys_ipc_recv(dstva))<0)
  801f9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fa1:	89 04 24             	mov    %eax,(%esp)
  801fa4:	e8 26 ed ff ff       	call   800ccf <sys_ipc_recv>
  801fa9:	89 c3                	mov    %eax,%ebx
  801fab:	85 c0                	test   %eax,%eax
  801fad:	79 1a                	jns    801fc9 <ipc_recv+0x95>
	{
		*from_env_store=0;
  801faf:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  801fb5:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("reciver failed\n");
  801fbb:	c7 04 24 5b 27 80 00 	movl   $0x80275b,(%esp)
  801fc2:	e8 da e1 ff ff       	call   8001a1 <cprintf>
  801fc7:	eb 48                	jmp    802011 <ipc_recv+0xdd>
		return r;
	}
	else{//接收成功
		env = &envs[ENVX(sys_getenvid())];
  801fc9:	e8 ff ef ff ff       	call   800fcd <sys_getenvid>
  801fce:	25 ff 03 00 00       	and    $0x3ff,%eax
  801fd3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fd6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fdb:	a3 3c 60 80 00       	mov    %eax,0x80603c
		if(from_env_store)
  801fe0:	85 f6                	test   %esi,%esi
  801fe2:	74 05                	je     801fe9 <ipc_recv+0xb5>
			*from_env_store=env->env_ipc_from;	
  801fe4:	8b 40 74             	mov    0x74(%eax),%eax
  801fe7:	89 06                	mov    %eax,(%esi)
		if(perm_store)
  801fe9:	85 ff                	test   %edi,%edi
  801feb:	74 0a                	je     801ff7 <ipc_recv+0xc3>
			*perm_store=env->env_ipc_perm;
  801fed:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801ff2:	8b 40 78             	mov    0x78(%eax),%eax
  801ff5:	89 07                	mov    %eax,(%edi)
		env = &envs[ENVX(sys_getenvid())];
  801ff7:	e8 d1 ef ff ff       	call   800fcd <sys_getenvid>
  801ffc:	25 ff 03 00 00       	and    $0x3ff,%eax
  802001:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802004:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802009:	a3 3c 60 80 00       	mov    %eax,0x80603c
		return env->env_ipc_value;
  80200e:	8b 58 70             	mov    0x70(%eax),%ebx
	}
	//panic("ipc_recv not implemented");
	return 0;
}
  802011:	89 d8                	mov    %ebx,%eax
  802013:	83 c4 0c             	add    $0xc,%esp
  802016:	5b                   	pop    %ebx
  802017:	5e                   	pop    %esi
  802018:	5f                   	pop    %edi
  802019:	5d                   	pop    %ebp
  80201a:	c3                   	ret    
  80201b:	00 00                	add    %al,(%eax)
  80201d:	00 00                	add    %al,(%eax)
	...

00802020 <__udivdi3>:
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	57                   	push   %edi
  802024:	56                   	push   %esi
  802025:	83 ec 18             	sub    $0x18,%esp
  802028:	8b 45 10             	mov    0x10(%ebp),%eax
  80202b:	8b 55 14             	mov    0x14(%ebp),%edx
  80202e:	8b 75 0c             	mov    0xc(%ebp),%esi
  802031:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802034:	89 c1                	mov    %eax,%ecx
  802036:	8b 45 08             	mov    0x8(%ebp),%eax
  802039:	85 d2                	test   %edx,%edx
  80203b:	89 d7                	mov    %edx,%edi
  80203d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802040:	75 1e                	jne    802060 <__udivdi3+0x40>
  802042:	39 f1                	cmp    %esi,%ecx
  802044:	0f 86 8d 00 00 00    	jbe    8020d7 <__udivdi3+0xb7>
  80204a:	89 f2                	mov    %esi,%edx
  80204c:	31 f6                	xor    %esi,%esi
  80204e:	f7 f1                	div    %ecx
  802050:	89 c1                	mov    %eax,%ecx
  802052:	89 c8                	mov    %ecx,%eax
  802054:	89 f2                	mov    %esi,%edx
  802056:	83 c4 18             	add    $0x18,%esp
  802059:	5e                   	pop    %esi
  80205a:	5f                   	pop    %edi
  80205b:	5d                   	pop    %ebp
  80205c:	c3                   	ret    
  80205d:	8d 76 00             	lea    0x0(%esi),%esi
  802060:	39 f2                	cmp    %esi,%edx
  802062:	0f 87 a8 00 00 00    	ja     802110 <__udivdi3+0xf0>
  802068:	0f bd c2             	bsr    %edx,%eax
  80206b:	83 f0 1f             	xor    $0x1f,%eax
  80206e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802071:	0f 84 89 00 00 00    	je     802100 <__udivdi3+0xe0>
  802077:	b8 20 00 00 00       	mov    $0x20,%eax
  80207c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80207f:	2b 45 e8             	sub    -0x18(%ebp),%eax
  802082:	89 c1                	mov    %eax,%ecx
  802084:	d3 ea                	shr    %cl,%edx
  802086:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  80208a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80208d:	89 f8                	mov    %edi,%eax
  80208f:	8b 7d f4             	mov    -0xc(%ebp),%edi
  802092:	d3 e0                	shl    %cl,%eax
  802094:	09 c2                	or     %eax,%edx
  802096:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802099:	d3 e7                	shl    %cl,%edi
  80209b:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80209f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8020a2:	89 f2                	mov    %esi,%edx
  8020a4:	d3 e8                	shr    %cl,%eax
  8020a6:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  8020aa:	d3 e2                	shl    %cl,%edx
  8020ac:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020b0:	09 d0                	or     %edx,%eax
  8020b2:	d3 ee                	shr    %cl,%esi
  8020b4:	89 f2                	mov    %esi,%edx
  8020b6:	f7 75 e4             	divl   -0x1c(%ebp)
  8020b9:	89 d1                	mov    %edx,%ecx
  8020bb:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8020be:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8020c1:	f7 e7                	mul    %edi
  8020c3:	39 d1                	cmp    %edx,%ecx
  8020c5:	89 c6                	mov    %eax,%esi
  8020c7:	72 70                	jb     802139 <__udivdi3+0x119>
  8020c9:	39 ca                	cmp    %ecx,%edx
  8020cb:	74 5f                	je     80212c <__udivdi3+0x10c>
  8020cd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8020d0:	31 f6                	xor    %esi,%esi
  8020d2:	e9 7b ff ff ff       	jmp    802052 <__udivdi3+0x32>
  8020d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020da:	85 c0                	test   %eax,%eax
  8020dc:	75 0c                	jne    8020ea <__udivdi3+0xca>
  8020de:	b8 01 00 00 00       	mov    $0x1,%eax
  8020e3:	31 d2                	xor    %edx,%edx
  8020e5:	f7 75 f4             	divl   -0xc(%ebp)
  8020e8:	89 c1                	mov    %eax,%ecx
  8020ea:	89 f0                	mov    %esi,%eax
  8020ec:	89 fa                	mov    %edi,%edx
  8020ee:	f7 f1                	div    %ecx
  8020f0:	89 c6                	mov    %eax,%esi
  8020f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8020f5:	f7 f1                	div    %ecx
  8020f7:	89 c1                	mov    %eax,%ecx
  8020f9:	e9 54 ff ff ff       	jmp    802052 <__udivdi3+0x32>
  8020fe:	66 90                	xchg   %ax,%ax
  802100:	39 d6                	cmp    %edx,%esi
  802102:	77 1c                	ja     802120 <__udivdi3+0x100>
  802104:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802107:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  80210a:	73 14                	jae    802120 <__udivdi3+0x100>
  80210c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802110:	31 c9                	xor    %ecx,%ecx
  802112:	31 f6                	xor    %esi,%esi
  802114:	e9 39 ff ff ff       	jmp    802052 <__udivdi3+0x32>
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  802120:	b9 01 00 00 00       	mov    $0x1,%ecx
  802125:	31 f6                	xor    %esi,%esi
  802127:	e9 26 ff ff ff       	jmp    802052 <__udivdi3+0x32>
  80212c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80212f:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  802133:	d3 e0                	shl    %cl,%eax
  802135:	39 c6                	cmp    %eax,%esi
  802137:	76 94                	jbe    8020cd <__udivdi3+0xad>
  802139:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80213c:	31 f6                	xor    %esi,%esi
  80213e:	83 e9 01             	sub    $0x1,%ecx
  802141:	e9 0c ff ff ff       	jmp    802052 <__udivdi3+0x32>
	...

00802150 <__umoddi3>:
  802150:	55                   	push   %ebp
  802151:	89 e5                	mov    %esp,%ebp
  802153:	57                   	push   %edi
  802154:	56                   	push   %esi
  802155:	83 ec 30             	sub    $0x30,%esp
  802158:	8b 45 10             	mov    0x10(%ebp),%eax
  80215b:	8b 55 14             	mov    0x14(%ebp),%edx
  80215e:	8b 75 08             	mov    0x8(%ebp),%esi
  802161:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802164:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802167:	89 c1                	mov    %eax,%ecx
  802169:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80216c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80216f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  802176:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80217d:	89 fa                	mov    %edi,%edx
  80217f:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  802182:	85 c0                	test   %eax,%eax
  802184:	89 75 f0             	mov    %esi,-0x10(%ebp)
  802187:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80218a:	75 14                	jne    8021a0 <__umoddi3+0x50>
  80218c:	39 f9                	cmp    %edi,%ecx
  80218e:	76 60                	jbe    8021f0 <__umoddi3+0xa0>
  802190:	89 f0                	mov    %esi,%eax
  802192:	f7 f1                	div    %ecx
  802194:	89 55 d0             	mov    %edx,-0x30(%ebp)
  802197:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80219e:	eb 10                	jmp    8021b0 <__umoddi3+0x60>
  8021a0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8021a3:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  8021a6:	76 18                	jbe    8021c0 <__umoddi3+0x70>
  8021a8:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8021ab:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8021ae:	66 90                	xchg   %ax,%ax
  8021b0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8021b3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8021b6:	83 c4 30             	add    $0x30,%esp
  8021b9:	5e                   	pop    %esi
  8021ba:	5f                   	pop    %edi
  8021bb:	5d                   	pop    %ebp
  8021bc:	c3                   	ret    
  8021bd:	8d 76 00             	lea    0x0(%esi),%esi
  8021c0:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
  8021c4:	83 f0 1f             	xor    $0x1f,%eax
  8021c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8021ca:	75 46                	jne    802212 <__umoddi3+0xc2>
  8021cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8021cf:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  8021d2:	0f 87 c9 00 00 00    	ja     8022a1 <__umoddi3+0x151>
  8021d8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  8021db:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8021de:	0f 83 bd 00 00 00    	jae    8022a1 <__umoddi3+0x151>
  8021e4:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8021e7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8021ea:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8021ed:	eb c1                	jmp    8021b0 <__umoddi3+0x60>
  8021ef:	90                   	nop    
  8021f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8021f3:	85 c0                	test   %eax,%eax
  8021f5:	75 0c                	jne    802203 <__umoddi3+0xb3>
  8021f7:	b8 01 00 00 00       	mov    $0x1,%eax
  8021fc:	31 d2                	xor    %edx,%edx
  8021fe:	f7 75 ec             	divl   -0x14(%ebp)
  802201:	89 c1                	mov    %eax,%ecx
  802203:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802206:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802209:	f7 f1                	div    %ecx
  80220b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80220e:	f7 f1                	div    %ecx
  802210:	eb 82                	jmp    802194 <__umoddi3+0x44>
  802212:	b8 20 00 00 00       	mov    $0x20,%eax
  802217:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80221a:	2b 45 d8             	sub    -0x28(%ebp),%eax
  80221d:	8b 75 ec             	mov    -0x14(%ebp),%esi
  802220:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802223:	89 c1                	mov    %eax,%ecx
  802225:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802228:	d3 ea                	shr    %cl,%edx
  80222a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80222d:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  802231:	d3 e0                	shl    %cl,%eax
  802233:	09 c2                	or     %eax,%edx
  802235:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802238:	d3 e6                	shl    %cl,%esi
  80223a:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  80223e:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802241:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802244:	d3 e8                	shr    %cl,%eax
  802246:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  80224a:	d3 e2                	shl    %cl,%edx
  80224c:	09 d0                	or     %edx,%eax
  80224e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802251:	d3 e7                	shl    %cl,%edi
  802253:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  802257:	d3 ea                	shr    %cl,%edx
  802259:	f7 75 f4             	divl   -0xc(%ebp)
  80225c:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80225f:	f7 e6                	mul    %esi
  802261:	39 55 cc             	cmp    %edx,-0x34(%ebp)
  802264:	72 53                	jb     8022b9 <__umoddi3+0x169>
  802266:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  802269:	74 4a                	je     8022b5 <__umoddi3+0x165>
  80226b:	90                   	nop    
  80226c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802270:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  802273:	29 c7                	sub    %eax,%edi
  802275:	19 d1                	sbb    %edx,%ecx
  802277:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80227a:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  80227e:	89 fa                	mov    %edi,%edx
  802280:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802283:	d3 ea                	shr    %cl,%edx
  802285:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  802289:	d3 e0                	shl    %cl,%eax
  80228b:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  80228f:	09 c2                	or     %eax,%edx
  802291:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802294:	89 55 d0             	mov    %edx,-0x30(%ebp)
  802297:	d3 e8                	shr    %cl,%eax
  802299:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80229c:	e9 0f ff ff ff       	jmp    8021b0 <__umoddi3+0x60>
  8022a1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8022a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022a7:	2b 45 ec             	sub    -0x14(%ebp),%eax
  8022aa:	1b 55 e8             	sbb    -0x18(%ebp),%edx
  8022ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8022b0:	e9 2f ff ff ff       	jmp    8021e4 <__umoddi3+0x94>
  8022b5:	39 f8                	cmp    %edi,%eax
  8022b7:	76 b7                	jbe    802270 <__umoddi3+0x120>
  8022b9:	29 f0                	sub    %esi,%eax
  8022bb:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8022be:	eb b0                	jmp    802270 <__umoddi3+0x120>
