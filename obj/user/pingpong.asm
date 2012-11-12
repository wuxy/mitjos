
obj/user/pingpong:     file format elf32-i386

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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
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
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003d:	e8 97 14 00 00       	call   8014d9 <fork>
  800042:	89 c3                	mov    %eax,%ebx
  800044:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800047:	85 c0                	test   %eax,%eax
  800049:	74 3c                	je     800087 <umain+0x53>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004b:	e8 ad 0f 00 00       	call   800ffd <sys_getenvid>
  800050:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800054:	89 44 24 04          	mov    %eax,0x4(%esp)
  800058:	c7 04 24 00 29 80 00 	movl   $0x802900,(%esp)
  80005f:	e8 6d 01 00 00       	call   8001d1 <cprintf>
		ipc_send(who, 0, 0, 0);
  800064:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006b:	00 
  80006c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800073:	00 
  800074:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007b:	00 
  80007c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 59 15 00 00       	call   8015e0 <ipc_send>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800087:	8d 7d f0             	lea    -0x10(%ebp),%edi
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800099:	00 
  80009a:	89 3c 24             	mov    %edi,(%esp)
  80009d:	e8 f2 15 00 00       	call   801694 <ipc_recv>
  8000a2:	89 c6                	mov    %eax,%esi
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a4:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8000a7:	e8 51 0f 00 00       	call   800ffd <sys_getenvid>
  8000ac:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000b0:	89 74 24 08          	mov    %esi,0x8(%esp)
  8000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b8:	c7 04 24 16 29 80 00 	movl   $0x802916,(%esp)
  8000bf:	e8 0d 01 00 00       	call   8001d1 <cprintf>
		if (i == 10)
  8000c4:	83 fe 0a             	cmp    $0xa,%esi
  8000c7:	74 27                	je     8000f0 <umain+0xbc>
			return;
		i++;
  8000c9:	8d 5e 01             	lea    0x1(%esi),%ebx
		ipc_send(who, i, 0, 0);
  8000cc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d3:	00 
  8000d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000db:	00 
  8000dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8000e3:	89 04 24             	mov    %eax,(%esp)
  8000e6:	e8 f5 14 00 00       	call   8015e0 <ipc_send>
		if (i == 10)
  8000eb:	83 fb 0a             	cmp    $0xa,%ebx
  8000ee:	75 9a                	jne    80008a <umain+0x56>
			return;
	}
		
}
  8000f0:	83 c4 2c             	add    $0x2c,%esp
  8000f3:	5b                   	pop    %ebx
  8000f4:	5e                   	pop    %esi
  8000f5:	5f                   	pop    %edi
  8000f6:	5d                   	pop    %ebp
  8000f7:	c3                   	ret    

008000f8 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	83 ec 18             	sub    $0x18,%esp
  8000fe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800101:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800104:	8b 75 08             	mov    0x8(%ebp),%esi
  800107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  80010a:	c7 05 3c 60 80 00 00 	movl   $0x0,0x80603c
  800111:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  800114:	e8 e4 0e 00 00       	call   800ffd <sys_getenvid>
  800119:	25 ff 03 00 00       	and    $0x3ff,%eax
  80011e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800121:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800126:	a3 3c 60 80 00       	mov    %eax,0x80603c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012b:	85 f6                	test   %esi,%esi
  80012d:	7e 07                	jle    800136 <libmain+0x3e>
		binaryname = argv[0];
  80012f:	8b 03                	mov    (%ebx),%eax
  800131:	a3 00 60 80 00       	mov    %eax,0x806000

	// call user main routine
	umain(argc, argv);
  800136:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80013a:	89 34 24             	mov    %esi,(%esp)
  80013d:	e8 f2 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800142:	e8 0d 00 00 00       	call   800154 <exit>
}
  800147:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80014a:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80014d:	89 ec                	mov    %ebp,%esp
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    
  800151:	00 00                	add    %al,(%eax)
	...

00800154 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80015a:	e8 11 1c 00 00       	call   801d70 <close_all>
	sys_env_destroy(0);
  80015f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800166:	e8 c6 0e 00 00       	call   801031 <sys_env_destroy>
}
  80016b:	c9                   	leave  
  80016c:	c3                   	ret    
  80016d:	00 00                	add    %al,(%eax)
	...

00800170 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800179:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  800180:	00 00 00 
	b.cnt = 0;
  800183:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  80018a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80018d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800190:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800194:	8b 45 08             	mov    0x8(%ebp),%eax
  800197:	89 44 24 08          	mov    %eax,0x8(%esp)
  80019b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a5:	c7 04 24 ee 01 80 00 	movl   $0x8001ee,(%esp)
  8001ac:	e8 c4 01 00 00       	call   800375 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b1:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
  8001b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bb:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  8001c1:	89 04 24             	mov    %eax,(%esp)
  8001c4:	e8 cf 0a 00 00       	call   800c98 <sys_cputs>
  8001c9:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  8001cf:	c9                   	leave  
  8001d0:	c3                   	ret    

008001d1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d1:	55                   	push   %ebp
  8001d2:	89 e5                	mov    %esp,%ebp
  8001d4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d7:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001da:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  8001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e4:	89 04 24             	mov    %eax,(%esp)
  8001e7:	e8 84 ff ff ff       	call   800170 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ec:	c9                   	leave  
  8001ed:	c3                   	ret    

008001ee <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	53                   	push   %ebx
  8001f2:	83 ec 14             	sub    $0x14,%esp
  8001f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001f8:	8b 03                	mov    (%ebx),%eax
  8001fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fd:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800201:	83 c0 01             	add    $0x1,%eax
  800204:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800206:	3d ff 00 00 00       	cmp    $0xff,%eax
  80020b:	75 19                	jne    800226 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80020d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800214:	00 
  800215:	8d 43 08             	lea    0x8(%ebx),%eax
  800218:	89 04 24             	mov    %eax,(%esp)
  80021b:	e8 78 0a 00 00       	call   800c98 <sys_cputs>
		b->idx = 0;
  800220:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800226:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80022a:	83 c4 14             	add    $0x14,%esp
  80022d:	5b                   	pop    %ebx
  80022e:	5d                   	pop    %ebp
  80022f:	c3                   	ret    

00800230 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	57                   	push   %edi
  800234:	56                   	push   %esi
  800235:	53                   	push   %ebx
  800236:	83 ec 3c             	sub    $0x3c,%esp
  800239:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80023c:	89 d7                	mov    %edx,%edi
  80023e:	8b 45 08             	mov    0x8(%ebp),%eax
  800241:	8b 55 0c             	mov    0xc(%ebp),%edx
  800244:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800247:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80024a:	8b 55 10             	mov    0x10(%ebp),%edx
  80024d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800250:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800253:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  80025a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80025d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  800260:	72 14                	jb     800276 <printnum+0x46>
  800262:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800265:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800268:	76 0c                	jbe    800276 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80026a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80026d:	83 eb 01             	sub    $0x1,%ebx
  800270:	85 db                	test   %ebx,%ebx
  800272:	7f 57                	jg     8002cb <printnum+0x9b>
  800274:	eb 64                	jmp    8002da <printnum+0xaa>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800276:	89 74 24 10          	mov    %esi,0x10(%esp)
  80027a:	8b 45 14             	mov    0x14(%ebp),%eax
  80027d:	83 e8 01             	sub    $0x1,%eax
  800280:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800284:	89 54 24 08          	mov    %edx,0x8(%esp)
  800288:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80028c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800290:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800293:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800296:	89 44 24 08          	mov    %eax,0x8(%esp)
  80029a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80029e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002a1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002a4:	89 04 24             	mov    %eax,(%esp)
  8002a7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ab:	e8 a0 23 00 00       	call   802650 <__udivdi3>
  8002b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002b4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002b8:	89 04 24             	mov    %eax,(%esp)
  8002bb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002bf:	89 fa                	mov    %edi,%edx
  8002c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002c4:	e8 67 ff ff ff       	call   800230 <printnum>
  8002c9:	eb 0f                	jmp    8002da <printnum+0xaa>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002cb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002cf:	89 34 24             	mov    %esi,(%esp)
  8002d2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002d5:	83 eb 01             	sub    $0x1,%ebx
  8002d8:	75 f1                	jne    8002cb <printnum+0x9b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002de:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8002e5:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8002e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ec:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002f3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002f6:	89 04 24             	mov    %eax,(%esp)
  8002f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002fd:	e8 7e 24 00 00       	call   802780 <__umoddi3>
  800302:	89 74 24 04          	mov    %esi,0x4(%esp)
  800306:	0f be 80 40 29 80 00 	movsbl 0x802940(%eax),%eax
  80030d:	89 04 24             	mov    %eax,(%esp)
  800310:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800313:	83 c4 3c             	add    $0x3c,%esp
  800316:	5b                   	pop    %ebx
  800317:	5e                   	pop    %esi
  800318:	5f                   	pop    %edi
  800319:	5d                   	pop    %ebp
  80031a:	c3                   	ret    

0080031b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800320:	83 fa 01             	cmp    $0x1,%edx
  800323:	7e 0e                	jle    800333 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  800325:	8b 10                	mov    (%eax),%edx
  800327:	8d 42 08             	lea    0x8(%edx),%eax
  80032a:	89 01                	mov    %eax,(%ecx)
  80032c:	8b 02                	mov    (%edx),%eax
  80032e:	8b 52 04             	mov    0x4(%edx),%edx
  800331:	eb 22                	jmp    800355 <getuint+0x3a>
	else if (lflag)
  800333:	85 d2                	test   %edx,%edx
  800335:	74 10                	je     800347 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800337:	8b 10                	mov    (%eax),%edx
  800339:	8d 42 04             	lea    0x4(%edx),%eax
  80033c:	89 01                	mov    %eax,(%ecx)
  80033e:	8b 02                	mov    (%edx),%eax
  800340:	ba 00 00 00 00       	mov    $0x0,%edx
  800345:	eb 0e                	jmp    800355 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800347:	8b 10                	mov    (%eax),%edx
  800349:	8d 42 04             	lea    0x4(%edx),%eax
  80034c:	89 01                	mov    %eax,(%ecx)
  80034e:	8b 02                	mov    (%edx),%eax
  800350:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
  80035a:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  80035d:	83 42 08 01          	addl   $0x1,0x8(%edx)
	if (b->buf < b->ebuf)
  800361:	8b 02                	mov    (%edx),%eax
  800363:	3b 42 04             	cmp    0x4(%edx),%eax
  800366:	73 0b                	jae    800373 <sprintputch+0x1c>
		*b->buf++ = ch;
  800368:	0f b6 4d 08          	movzbl 0x8(%ebp),%ecx
  80036c:	88 08                	mov    %cl,(%eax)
  80036e:	83 c0 01             	add    $0x1,%eax
  800371:	89 02                	mov    %eax,(%edx)
}
  800373:	5d                   	pop    %ebp
  800374:	c3                   	ret    

00800375 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800375:	55                   	push   %ebp
  800376:	89 e5                	mov    %esp,%ebp
  800378:	57                   	push   %edi
  800379:	56                   	push   %esi
  80037a:	53                   	push   %ebx
  80037b:	83 ec 3c             	sub    $0x3c,%esp
  80037e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800381:	eb 18                	jmp    80039b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800383:	84 c0                	test   %al,%al
  800385:	0f 84 9f 03 00 00    	je     80072a <vprintfmt+0x3b5>
				return;
			putch(ch, putdat);
  80038b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80038e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800392:	0f b6 c0             	movzbl %al,%eax
  800395:	89 04 24             	mov    %eax,(%esp)
  800398:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80039b:	0f b6 03             	movzbl (%ebx),%eax
  80039e:	83 c3 01             	add    $0x1,%ebx
  8003a1:	3c 25                	cmp    $0x25,%al
  8003a3:	75 de                	jne    800383 <vprintfmt+0xe>
  8003a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003aa:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
  8003b1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003b6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003bd:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
  8003c1:	eb 07                	jmp    8003ca <vprintfmt+0x55>
  8003c3:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	0f b6 13             	movzbl (%ebx),%edx
  8003cd:	83 c3 01             	add    $0x1,%ebx
  8003d0:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003d3:	3c 55                	cmp    $0x55,%al
  8003d5:	0f 87 22 03 00 00    	ja     8006fd <vprintfmt+0x388>
  8003db:	0f b6 c0             	movzbl %al,%eax
  8003de:	ff 24 85 80 2a 80 00 	jmp    *0x802a80(,%eax,4)
  8003e5:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
  8003e9:	eb df                	jmp    8003ca <vprintfmt+0x55>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003eb:	0f b6 c2             	movzbl %dl,%eax
  8003ee:	8d 78 d0             	lea    -0x30(%eax),%edi
				ch = *fmt;
  8003f1:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  8003f4:	8d 42 d0             	lea    -0x30(%edx),%eax
  8003f7:	83 f8 09             	cmp    $0x9,%eax
  8003fa:	76 08                	jbe    800404 <vprintfmt+0x8f>
  8003fc:	eb 39                	jmp    800437 <vprintfmt+0xc2>
  8003fe:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
  800402:	eb c6                	jmp    8003ca <vprintfmt+0x55>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800404:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800407:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  80040a:	8d 7c 42 d0          	lea    -0x30(%edx,%eax,2),%edi
				ch = *fmt;
  80040e:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800411:	8d 42 d0             	lea    -0x30(%edx),%eax
  800414:	83 f8 09             	cmp    $0x9,%eax
  800417:	77 1e                	ja     800437 <vprintfmt+0xc2>
  800419:	eb e9                	jmp    800404 <vprintfmt+0x8f>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80041b:	8b 55 14             	mov    0x14(%ebp),%edx
  80041e:	8d 42 04             	lea    0x4(%edx),%eax
  800421:	89 45 14             	mov    %eax,0x14(%ebp)
  800424:	8b 3a                	mov    (%edx),%edi
  800426:	eb 0f                	jmp    800437 <vprintfmt+0xc2>
			goto process_precision;

		case '.':
			if (width < 0)
  800428:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80042c:	79 9c                	jns    8003ca <vprintfmt+0x55>
  80042e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800435:	eb 93                	jmp    8003ca <vprintfmt+0x55>
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800437:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80043b:	90                   	nop    
  80043c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800440:	79 88                	jns    8003ca <vprintfmt+0x55>
  800442:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800445:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80044a:	e9 7b ff ff ff       	jmp    8003ca <vprintfmt+0x55>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80044f:	83 c1 01             	add    $0x1,%ecx
  800452:	e9 73 ff ff ff       	jmp    8003ca <vprintfmt+0x55>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800457:	8b 45 14             	mov    0x14(%ebp),%eax
  80045a:	8d 50 04             	lea    0x4(%eax),%edx
  80045d:	89 55 14             	mov    %edx,0x14(%ebp)
  800460:	8b 55 0c             	mov    0xc(%ebp),%edx
  800463:	89 54 24 04          	mov    %edx,0x4(%esp)
  800467:	8b 00                	mov    (%eax),%eax
  800469:	89 04 24             	mov    %eax,(%esp)
  80046c:	ff 55 08             	call   *0x8(%ebp)
  80046f:	e9 27 ff ff ff       	jmp    80039b <vprintfmt+0x26>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800474:	8b 55 14             	mov    0x14(%ebp),%edx
  800477:	8d 42 04             	lea    0x4(%edx),%eax
  80047a:	89 45 14             	mov    %eax,0x14(%ebp)
  80047d:	8b 02                	mov    (%edx),%eax
  80047f:	89 c2                	mov    %eax,%edx
  800481:	c1 fa 1f             	sar    $0x1f,%edx
  800484:	31 d0                	xor    %edx,%eax
  800486:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800488:	83 f8 0f             	cmp    $0xf,%eax
  80048b:	7f 0b                	jg     800498 <vprintfmt+0x123>
  80048d:	8b 14 85 e0 2b 80 00 	mov    0x802be0(,%eax,4),%edx
  800494:	85 d2                	test   %edx,%edx
  800496:	75 23                	jne    8004bb <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800498:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80049c:	c7 44 24 08 51 29 80 	movl   $0x802951,0x8(%esp)
  8004a3:	00 
  8004a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8004ae:	89 14 24             	mov    %edx,(%esp)
  8004b1:	e8 ff 02 00 00       	call   8007b5 <printfmt>
  8004b6:	e9 e0 fe ff ff       	jmp    80039b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004bb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004bf:	c7 44 24 08 6a 2e 80 	movl   $0x802e6a,0x8(%esp)
  8004c6:	00 
  8004c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8004d1:	89 14 24             	mov    %edx,(%esp)
  8004d4:	e8 dc 02 00 00       	call   8007b5 <printfmt>
  8004d9:	e9 bd fe ff ff       	jmp    80039b <vprintfmt+0x26>
  8004de:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8004e1:	89 f9                	mov    %edi,%ecx
  8004e3:	89 5d ec             	mov    %ebx,-0x14(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e6:	8b 55 14             	mov    0x14(%ebp),%edx
  8004e9:	8d 42 04             	lea    0x4(%edx),%eax
  8004ec:	89 45 14             	mov    %eax,0x14(%ebp)
  8004ef:	8b 12                	mov    (%edx),%edx
  8004f1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004f4:	85 d2                	test   %edx,%edx
  8004f6:	75 07                	jne    8004ff <vprintfmt+0x18a>
  8004f8:	c7 45 dc 5a 29 80 00 	movl   $0x80295a,-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8004ff:	85 f6                	test   %esi,%esi
  800501:	7e 41                	jle    800544 <vprintfmt+0x1cf>
  800503:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  800507:	74 3b                	je     800544 <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
  800509:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80050d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800510:	89 04 24             	mov    %eax,(%esp)
  800513:	e8 e8 02 00 00       	call   800800 <strnlen>
  800518:	29 c6                	sub    %eax,%esi
  80051a:	89 75 f0             	mov    %esi,-0x10(%ebp)
  80051d:	85 f6                	test   %esi,%esi
  80051f:	7e 23                	jle    800544 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800521:	0f be 55 eb          	movsbl -0x15(%ebp),%edx
  800525:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800528:	8b 45 0c             	mov    0xc(%ebp),%eax
  80052b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800532:	89 14 24             	mov    %edx,(%esp)
  800535:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800538:	83 ee 01             	sub    $0x1,%esi
  80053b:	75 eb                	jne    800528 <vprintfmt+0x1b3>
  80053d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800544:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800547:	0f b6 02             	movzbl (%edx),%eax
  80054a:	0f be d0             	movsbl %al,%edx
  80054d:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800550:	84 c0                	test   %al,%al
  800552:	75 42                	jne    800596 <vprintfmt+0x221>
  800554:	eb 49                	jmp    80059f <vprintfmt+0x22a>
				if (altflag && (ch < ' ' || ch > '~'))
  800556:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80055a:	74 1b                	je     800577 <vprintfmt+0x202>
  80055c:	8d 42 e0             	lea    -0x20(%edx),%eax
  80055f:	83 f8 5e             	cmp    $0x5e,%eax
  800562:	76 13                	jbe    800577 <vprintfmt+0x202>
					putch('?', putdat);
  800564:	8b 45 0c             	mov    0xc(%ebp),%eax
  800567:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800572:	ff 55 08             	call   *0x8(%ebp)
  800575:	eb 0d                	jmp    800584 <vprintfmt+0x20f>
				else
					putch(ch, putdat);
  800577:	8b 45 0c             	mov    0xc(%ebp),%eax
  80057a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80057e:	89 14 24             	mov    %edx,(%esp)
  800581:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800584:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  800588:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80058c:	83 c6 01             	add    $0x1,%esi
  80058f:	84 c0                	test   %al,%al
  800591:	74 0c                	je     80059f <vprintfmt+0x22a>
  800593:	0f be d0             	movsbl %al,%edx
  800596:	85 ff                	test   %edi,%edi
  800598:	78 bc                	js     800556 <vprintfmt+0x1e1>
  80059a:	83 ef 01             	sub    $0x1,%edi
  80059d:	79 b7                	jns    800556 <vprintfmt+0x1e1>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8005a3:	0f 8e f2 fd ff ff    	jle    80039b <vprintfmt+0x26>
				putch(' ', putdat);
  8005a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005b0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005b7:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ba:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  8005be:	75 e9                	jne    8005a9 <vprintfmt+0x234>
  8005c0:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  8005c3:	e9 d3 fd ff ff       	jmp    80039b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c8:	83 f9 01             	cmp    $0x1,%ecx
  8005cb:	90                   	nop    
  8005cc:	8d 74 26 00          	lea    0x0(%esi),%esi
  8005d0:	7e 10                	jle    8005e2 <vprintfmt+0x26d>
		return va_arg(*ap, long long);
  8005d2:	8b 55 14             	mov    0x14(%ebp),%edx
  8005d5:	8d 42 08             	lea    0x8(%edx),%eax
  8005d8:	89 45 14             	mov    %eax,0x14(%ebp)
  8005db:	8b 32                	mov    (%edx),%esi
  8005dd:	8b 7a 04             	mov    0x4(%edx),%edi
  8005e0:	eb 2a                	jmp    80060c <vprintfmt+0x297>
	else if (lflag)
  8005e2:	85 c9                	test   %ecx,%ecx
  8005e4:	74 14                	je     8005fa <vprintfmt+0x285>
		return va_arg(*ap, long);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ef:	8b 00                	mov    (%eax),%eax
  8005f1:	89 c6                	mov    %eax,%esi
  8005f3:	89 c7                	mov    %eax,%edi
  8005f5:	c1 ff 1f             	sar    $0x1f,%edi
  8005f8:	eb 12                	jmp    80060c <vprintfmt+0x297>
	else
		return va_arg(*ap, int);
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8d 50 04             	lea    0x4(%eax),%edx
  800600:	89 55 14             	mov    %edx,0x14(%ebp)
  800603:	8b 00                	mov    (%eax),%eax
  800605:	89 c6                	mov    %eax,%esi
  800607:	89 c7                	mov    %eax,%edi
  800609:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80060c:	89 f2                	mov    %esi,%edx
  80060e:	89 f9                	mov    %edi,%ecx
  800610:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
			if ((long long) num < 0) {
  800617:	85 ff                	test   %edi,%edi
  800619:	0f 89 9b 00 00 00    	jns    8006ba <vprintfmt+0x345>
				putch('-', putdat);
  80061f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800622:	89 44 24 04          	mov    %eax,0x4(%esp)
  800626:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80062d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800630:	89 f2                	mov    %esi,%edx
  800632:	89 f9                	mov    %edi,%ecx
  800634:	f7 da                	neg    %edx
  800636:	83 d1 00             	adc    $0x0,%ecx
  800639:	f7 d9                	neg    %ecx
  80063b:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  800642:	eb 76                	jmp    8006ba <vprintfmt+0x345>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800644:	89 ca                	mov    %ecx,%edx
  800646:	8d 45 14             	lea    0x14(%ebp),%eax
  800649:	e8 cd fc ff ff       	call   80031b <getuint>
  80064e:	89 d1                	mov    %edx,%ecx
  800650:	89 c2                	mov    %eax,%edx
  800652:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  800659:	eb 5f                	jmp    8006ba <vprintfmt+0x345>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap,lflag);
  80065b:	89 ca                	mov    %ecx,%edx
  80065d:	8d 45 14             	lea    0x14(%ebp),%eax
  800660:	e8 b6 fc ff ff       	call   80031b <getuint>
  800665:	e9 31 fd ff ff       	jmp    80039b <vprintfmt+0x26>
			base=8;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80066a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80066d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800671:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800678:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80067b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80067e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800682:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800689:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  80068c:	8b 55 14             	mov    0x14(%ebp),%edx
  80068f:	8d 42 04             	lea    0x4(%edx),%eax
  800692:	89 45 14             	mov    %eax,0x14(%ebp)
  800695:	8b 12                	mov    (%edx),%edx
  800697:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069c:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  8006a3:	eb 15                	jmp    8006ba <vprintfmt+0x345>
			base = 16;
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a5:	89 ca                	mov    %ecx,%edx
  8006a7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006aa:	e8 6c fc ff ff       	call   80031b <getuint>
  8006af:	89 d1                	mov    %edx,%ecx
  8006b1:	89 c2                	mov    %eax,%edx
  8006b3:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006ba:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  8006be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006d0:	89 14 24             	mov    %edx,(%esp)
  8006d3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006da:	8b 45 08             	mov    0x8(%ebp),%eax
  8006dd:	e8 4e fb ff ff       	call   800230 <printnum>
  8006e2:	e9 b4 fc ff ff       	jmp    80039b <vprintfmt+0x26>
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006ea:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006ee:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006f5:	ff 55 08             	call   *0x8(%ebp)
  8006f8:	e9 9e fc ff ff       	jmp    80039b <vprintfmt+0x26>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800700:	89 44 24 04          	mov    %eax,0x4(%esp)
  800704:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80070b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80070e:	83 eb 01             	sub    $0x1,%ebx
  800711:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800715:	0f 84 80 fc ff ff    	je     80039b <vprintfmt+0x26>
  80071b:	83 eb 01             	sub    $0x1,%ebx
  80071e:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800722:	0f 84 73 fc ff ff    	je     80039b <vprintfmt+0x26>
  800728:	eb f1                	jmp    80071b <vprintfmt+0x3a6>
				/* do nothing */;
			break;
		}
	}
}
  80072a:	83 c4 3c             	add    $0x3c,%esp
  80072d:	5b                   	pop    %ebx
  80072e:	5e                   	pop    %esi
  80072f:	5f                   	pop    %edi
  800730:	5d                   	pop    %ebp
  800731:	c3                   	ret    

00800732 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	83 ec 28             	sub    $0x28,%esp
  800738:	8b 55 08             	mov    0x8(%ebp),%edx
  80073b:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80073e:	85 d2                	test   %edx,%edx
  800740:	74 04                	je     800746 <vsnprintf+0x14>
  800742:	85 c0                	test   %eax,%eax
  800744:	7f 07                	jg     80074d <vsnprintf+0x1b>
  800746:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80074b:	eb 3b                	jmp    800788 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80074d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800754:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
  800758:	89 45 f8             	mov    %eax,-0x8(%ebp)
  80075b:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80075e:	8b 45 14             	mov    0x14(%ebp),%eax
  800761:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800765:	8b 45 10             	mov    0x10(%ebp),%eax
  800768:	89 44 24 08          	mov    %eax,0x8(%esp)
  80076c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80076f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800773:	c7 04 24 57 03 80 00 	movl   $0x800357,(%esp)
  80077a:	e8 f6 fb ff ff       	call   800375 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80077f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800782:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800785:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800788:	c9                   	leave  
  800789:	c3                   	ret    

0080078a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800790:	8d 45 14             	lea    0x14(%ebp),%eax
  800793:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800796:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80079a:	8b 45 10             	mov    0x10(%ebp),%eax
  80079d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ab:	89 04 24             	mov    %eax,(%esp)
  8007ae:	e8 7f ff ff ff       	call   800732 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b3:	c9                   	leave  
  8007b4:	c3                   	ret    

008007b5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8007bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8007be:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8007c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d6:	89 04 24             	mov    %eax,(%esp)
  8007d9:	e8 97 fb ff ff       	call   800375 <vprintfmt>
	va_end(ap);
}
  8007de:	c9                   	leave  
  8007df:	c3                   	ret    

008007e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007eb:	80 3a 00             	cmpb   $0x0,(%edx)
  8007ee:	74 0e                	je     8007fe <strlen+0x1e>
  8007f0:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007f5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f8:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  8007fc:	75 f7                	jne    8007f5 <strlen+0x15>
		n++;
	return n;
}
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800806:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800809:	85 d2                	test   %edx,%edx
  80080b:	74 19                	je     800826 <strnlen+0x26>
  80080d:	80 39 00             	cmpb   $0x0,(%ecx)
  800810:	74 14                	je     800826 <strnlen+0x26>
  800812:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800817:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081a:	39 d0                	cmp    %edx,%eax
  80081c:	74 0d                	je     80082b <strnlen+0x2b>
  80081e:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800822:	74 07                	je     80082b <strnlen+0x2b>
  800824:	eb f1                	jmp    800817 <strnlen+0x17>
  800826:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80082b:	5d                   	pop    %ebp
  80082c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800830:	c3                   	ret    

00800831 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	53                   	push   %ebx
  800835:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800838:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083b:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80083d:	0f b6 01             	movzbl (%ecx),%eax
  800840:	88 02                	mov    %al,(%edx)
  800842:	83 c2 01             	add    $0x1,%edx
  800845:	83 c1 01             	add    $0x1,%ecx
  800848:	84 c0                	test   %al,%al
  80084a:	75 f1                	jne    80083d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80084c:	89 d8                	mov    %ebx,%eax
  80084e:	5b                   	pop    %ebx
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	57                   	push   %edi
  800855:	56                   	push   %esi
  800856:	53                   	push   %ebx
  800857:	8b 7d 08             	mov    0x8(%ebp),%edi
  80085a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800860:	85 f6                	test   %esi,%esi
  800862:	74 1c                	je     800880 <strncpy+0x2f>
  800864:	89 fa                	mov    %edi,%edx
  800866:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  80086b:	0f b6 01             	movzbl (%ecx),%eax
  80086e:	88 02                	mov    %al,(%edx)
  800870:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800873:	80 39 01             	cmpb   $0x1,(%ecx)
  800876:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800879:	83 c3 01             	add    $0x1,%ebx
  80087c:	39 f3                	cmp    %esi,%ebx
  80087e:	75 eb                	jne    80086b <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800880:	89 f8                	mov    %edi,%eax
  800882:	5b                   	pop    %ebx
  800883:	5e                   	pop    %esi
  800884:	5f                   	pop    %edi
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	56                   	push   %esi
  80088b:	53                   	push   %ebx
  80088c:	8b 75 08             	mov    0x8(%ebp),%esi
  80088f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800892:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800895:	89 f0                	mov    %esi,%eax
  800897:	85 d2                	test   %edx,%edx
  800899:	74 2c                	je     8008c7 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  80089b:	89 d3                	mov    %edx,%ebx
  80089d:	83 eb 01             	sub    $0x1,%ebx
  8008a0:	74 20                	je     8008c2 <strlcpy+0x3b>
  8008a2:	0f b6 11             	movzbl (%ecx),%edx
  8008a5:	84 d2                	test   %dl,%dl
  8008a7:	74 19                	je     8008c2 <strlcpy+0x3b>
  8008a9:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  8008ab:	88 10                	mov    %dl,(%eax)
  8008ad:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008b0:	83 eb 01             	sub    $0x1,%ebx
  8008b3:	74 0f                	je     8008c4 <strlcpy+0x3d>
  8008b5:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  8008b9:	83 c1 01             	add    $0x1,%ecx
  8008bc:	84 d2                	test   %dl,%dl
  8008be:	74 04                	je     8008c4 <strlcpy+0x3d>
  8008c0:	eb e9                	jmp    8008ab <strlcpy+0x24>
  8008c2:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008c4:	c6 00 00             	movb   $0x0,(%eax)
  8008c7:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8008c9:	5b                   	pop    %ebx
  8008ca:	5e                   	pop    %esi
  8008cb:	5d                   	pop    %ebp
  8008cc:	c3                   	ret    

008008cd <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	56                   	push   %esi
  8008d1:	53                   	push   %ebx
  8008d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d8:	8b 55 10             	mov    0x10(%ebp),%edx
    int c;
    char *q = buf;

    if (buf_size <= 0)
  8008db:	85 c0                	test   %eax,%eax
  8008dd:	7e 2e                	jle    80090d <pstrcpy+0x40>
        return;

    for(;;) {
        c = *str++;
  8008df:	0f b6 0a             	movzbl (%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  8008e2:	84 c9                	test   %cl,%cl
  8008e4:	74 22                	je     800908 <pstrcpy+0x3b>
  8008e6:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  8008ea:	89 f0                	mov    %esi,%eax
  8008ec:	39 de                	cmp    %ebx,%esi
  8008ee:	72 09                	jb     8008f9 <pstrcpy+0x2c>
  8008f0:	eb 16                	jmp    800908 <pstrcpy+0x3b>
  8008f2:	83 c2 01             	add    $0x1,%edx
  8008f5:	39 d8                	cmp    %ebx,%eax
  8008f7:	73 11                	jae    80090a <pstrcpy+0x3d>
            break;
        *q++ = c;
  8008f9:	88 08                	mov    %cl,(%eax)
  8008fb:	83 c0 01             	add    $0x1,%eax

    if (buf_size <= 0)
        return;

    for(;;) {
        c = *str++;
  8008fe:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  800902:	84 c9                	test   %cl,%cl
  800904:	75 ec                	jne    8008f2 <pstrcpy+0x25>
  800906:	eb 02                	jmp    80090a <pstrcpy+0x3d>
  800908:	89 f0                	mov    %esi,%eax
            break;
        *q++ = c;
    }
    *q = '\0';
  80090a:	c6 00 00             	movb   $0x0,(%eax)
}
  80090d:	5b                   	pop    %ebx
  80090e:	5e                   	pop    %esi
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	8b 55 08             	mov    0x8(%ebp),%edx
  800917:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  80091a:	0f b6 02             	movzbl (%edx),%eax
  80091d:	84 c0                	test   %al,%al
  80091f:	74 16                	je     800937 <strcmp+0x26>
  800921:	3a 01                	cmp    (%ecx),%al
  800923:	75 12                	jne    800937 <strcmp+0x26>
		p++, q++;
  800925:	83 c1 01             	add    $0x1,%ecx
    *q = '\0';
}
int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800928:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  80092c:	84 c0                	test   %al,%al
  80092e:	74 07                	je     800937 <strcmp+0x26>
  800930:	83 c2 01             	add    $0x1,%edx
  800933:	3a 01                	cmp    (%ecx),%al
  800935:	74 ee                	je     800925 <strcmp+0x14>
  800937:	0f b6 c0             	movzbl %al,%eax
  80093a:	0f b6 11             	movzbl (%ecx),%edx
  80093d:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	53                   	push   %ebx
  800945:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800948:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80094b:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80094e:	85 d2                	test   %edx,%edx
  800950:	74 2d                	je     80097f <strncmp+0x3e>
  800952:	0f b6 01             	movzbl (%ecx),%eax
  800955:	84 c0                	test   %al,%al
  800957:	74 1a                	je     800973 <strncmp+0x32>
  800959:	3a 03                	cmp    (%ebx),%al
  80095b:	75 16                	jne    800973 <strncmp+0x32>
  80095d:	83 ea 01             	sub    $0x1,%edx
  800960:	74 1d                	je     80097f <strncmp+0x3e>
		n--, p++, q++;
  800962:	83 c1 01             	add    $0x1,%ecx
  800965:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800968:	0f b6 01             	movzbl (%ecx),%eax
  80096b:	84 c0                	test   %al,%al
  80096d:	74 04                	je     800973 <strncmp+0x32>
  80096f:	3a 03                	cmp    (%ebx),%al
  800971:	74 ea                	je     80095d <strncmp+0x1c>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800973:	0f b6 11             	movzbl (%ecx),%edx
  800976:	0f b6 03             	movzbl (%ebx),%eax
  800979:	29 c2                	sub    %eax,%edx
  80097b:	89 d0                	mov    %edx,%eax
  80097d:	eb 05                	jmp    800984 <strncmp+0x43>
  80097f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800984:	5b                   	pop    %ebx
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800991:	0f b6 10             	movzbl (%eax),%edx
  800994:	84 d2                	test   %dl,%dl
  800996:	74 14                	je     8009ac <strchr+0x25>
		if (*s == c)
  800998:	38 ca                	cmp    %cl,%dl
  80099a:	75 06                	jne    8009a2 <strchr+0x1b>
  80099c:	eb 13                	jmp    8009b1 <strchr+0x2a>
  80099e:	38 ca                	cmp    %cl,%dl
  8009a0:	74 0f                	je     8009b1 <strchr+0x2a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009a2:	83 c0 01             	add    $0x1,%eax
  8009a5:	0f b6 10             	movzbl (%eax),%edx
  8009a8:	84 d2                	test   %dl,%dl
  8009aa:	75 f2                	jne    80099e <strchr+0x17>
  8009ac:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8009b1:	5d                   	pop    %ebp
  8009b2:	c3                   	ret    

008009b3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009bd:	0f b6 10             	movzbl (%eax),%edx
  8009c0:	84 d2                	test   %dl,%dl
  8009c2:	74 18                	je     8009dc <strfind+0x29>
		if (*s == c)
  8009c4:	38 ca                	cmp    %cl,%dl
  8009c6:	75 0a                	jne    8009d2 <strfind+0x1f>
  8009c8:	eb 12                	jmp    8009dc <strfind+0x29>
  8009ca:	38 ca                	cmp    %cl,%dl
  8009cc:	8d 74 26 00          	lea    0x0(%esi),%esi
  8009d0:	74 0a                	je     8009dc <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009d2:	83 c0 01             	add    $0x1,%eax
  8009d5:	0f b6 10             	movzbl (%eax),%edx
  8009d8:	84 d2                	test   %dl,%dl
  8009da:	75 ee                	jne    8009ca <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	83 ec 08             	sub    $0x8,%esp
  8009e4:	89 1c 24             	mov    %ebx,(%esp)
  8009e7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  8009f1:	85 db                	test   %ebx,%ebx
  8009f3:	74 36                	je     800a2b <memset+0x4d>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009fb:	75 26                	jne    800a23 <memset+0x45>
  8009fd:	f6 c3 03             	test   $0x3,%bl
  800a00:	75 21                	jne    800a23 <memset+0x45>
		c &= 0xFF;
  800a02:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a06:	89 d0                	mov    %edx,%eax
  800a08:	c1 e0 18             	shl    $0x18,%eax
  800a0b:	89 d1                	mov    %edx,%ecx
  800a0d:	c1 e1 10             	shl    $0x10,%ecx
  800a10:	09 c8                	or     %ecx,%eax
  800a12:	09 d0                	or     %edx,%eax
  800a14:	c1 e2 08             	shl    $0x8,%edx
  800a17:	09 d0                	or     %edx,%eax
  800a19:	89 d9                	mov    %ebx,%ecx
  800a1b:	c1 e9 02             	shr    $0x2,%ecx
  800a1e:	fc                   	cld    
  800a1f:	f3 ab                	rep stos %eax,%es:(%edi)
  800a21:	eb 08                	jmp    800a2b <memset+0x4d>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a26:	89 d9                	mov    %ebx,%ecx
  800a28:	fc                   	cld    
  800a29:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a2b:	89 f8                	mov    %edi,%eax
  800a2d:	8b 1c 24             	mov    (%esp),%ebx
  800a30:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800a34:	89 ec                	mov    %ebp,%esp
  800a36:	5d                   	pop    %ebp
  800a37:	c3                   	ret    

00800a38 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	83 ec 08             	sub    $0x8,%esp
  800a3e:	89 34 24             	mov    %esi,(%esp)
  800a41:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a45:	8b 45 08             	mov    0x8(%ebp),%eax
  800a48:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800a4b:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a4e:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a50:	39 c6                	cmp    %eax,%esi
  800a52:	73 38                	jae    800a8c <memmove+0x54>
  800a54:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a57:	39 d0                	cmp    %edx,%eax
  800a59:	73 31                	jae    800a8c <memmove+0x54>
		s += n;
		d += n;
  800a5b:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5e:	f6 c2 03             	test   $0x3,%dl
  800a61:	75 1d                	jne    800a80 <memmove+0x48>
  800a63:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a69:	75 15                	jne    800a80 <memmove+0x48>
  800a6b:	f6 c1 03             	test   $0x3,%cl
  800a6e:	66 90                	xchg   %ax,%ax
  800a70:	75 0e                	jne    800a80 <memmove+0x48>
			asm volatile("std; rep movsl\n"
  800a72:	8d 7e fc             	lea    -0x4(%esi),%edi
  800a75:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a78:	c1 e9 02             	shr    $0x2,%ecx
  800a7b:	fd                   	std    
  800a7c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a7e:	eb 09                	jmp    800a89 <memmove+0x51>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a80:	8d 7e ff             	lea    -0x1(%esi),%edi
  800a83:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a86:	fd                   	std    
  800a87:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a89:	fc                   	cld    
  800a8a:	eb 21                	jmp    800aad <memmove+0x75>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a92:	75 16                	jne    800aaa <memmove+0x72>
  800a94:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a9a:	75 0e                	jne    800aaa <memmove+0x72>
  800a9c:	f6 c1 03             	test   $0x3,%cl
  800a9f:	90                   	nop    
  800aa0:	75 08                	jne    800aaa <memmove+0x72>
			asm volatile("cld; rep movsl\n"
  800aa2:	c1 e9 02             	shr    $0x2,%ecx
  800aa5:	fc                   	cld    
  800aa6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa8:	eb 03                	jmp    800aad <memmove+0x75>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aaa:	fc                   	cld    
  800aab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aad:	8b 34 24             	mov    (%esp),%esi
  800ab0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ab4:	89 ec                	mov    %ebp,%esp
  800ab6:	5d                   	pop    %ebp
  800ab7:	c3                   	ret    

00800ab8 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800ab8:	55                   	push   %ebp
  800ab9:	89 e5                	mov    %esp,%ebp
  800abb:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800abe:	8b 45 10             	mov    0x10(%ebp),%eax
  800ac1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ac5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800acc:	8b 45 08             	mov    0x8(%ebp),%eax
  800acf:	89 04 24             	mov    %eax,(%esp)
  800ad2:	e8 61 ff ff ff       	call   800a38 <memmove>
}
  800ad7:	c9                   	leave  
  800ad8:	c3                   	ret    

00800ad9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	57                   	push   %edi
  800add:	56                   	push   %esi
  800ade:	53                   	push   %ebx
  800adf:	83 ec 04             	sub    $0x4,%esp
  800ae2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae8:	8b 55 10             	mov    0x10(%ebp),%edx
  800aeb:	83 ea 01             	sub    $0x1,%edx
  800aee:	83 fa ff             	cmp    $0xffffffff,%edx
  800af1:	74 47                	je     800b3a <memcmp+0x61>
		if (*s1 != *s2)
  800af3:	0f b6 30             	movzbl (%eax),%esi
  800af6:	0f b6 39             	movzbl (%ecx),%edi
			return (int) *s1 - (int) *s2;
  800af9:	89 45 f0             	mov    %eax,-0x10(%ebp)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  800afc:	89 f0                	mov    %esi,%eax
  800afe:	89 fb                	mov    %edi,%ebx
  800b00:	38 d8                	cmp    %bl,%al
  800b02:	74 2e                	je     800b32 <memcmp+0x59>
  800b04:	eb 1c                	jmp    800b22 <memcmp+0x49>
  800b06:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b09:	0f b6 70 01          	movzbl 0x1(%eax),%esi
  800b0d:	0f b6 79 01          	movzbl 0x1(%ecx),%edi
  800b11:	83 c0 01             	add    $0x1,%eax
  800b14:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b17:	83 c1 01             	add    $0x1,%ecx
  800b1a:	89 f3                	mov    %esi,%ebx
  800b1c:	89 f8                	mov    %edi,%eax
  800b1e:	38 c3                	cmp    %al,%bl
  800b20:	74 10                	je     800b32 <memcmp+0x59>
			return (int) *s1 - (int) *s2;
  800b22:	89 f1                	mov    %esi,%ecx
  800b24:	0f b6 d1             	movzbl %cl,%edx
  800b27:	89 fb                	mov    %edi,%ebx
  800b29:	0f b6 c3             	movzbl %bl,%eax
  800b2c:	29 c2                	sub    %eax,%edx
  800b2e:	89 d0                	mov    %edx,%eax
  800b30:	eb 0d                	jmp    800b3f <memcmp+0x66>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b32:	83 ea 01             	sub    $0x1,%edx
  800b35:	83 fa ff             	cmp    $0xffffffff,%edx
  800b38:	75 cc                	jne    800b06 <memcmp+0x2d>
  800b3a:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b3f:	83 c4 04             	add    $0x4,%esp
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5f                   	pop    %edi
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    

00800b47 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b4d:	89 c1                	mov    %eax,%ecx
  800b4f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
  800b52:	39 c8                	cmp    %ecx,%eax
  800b54:	73 15                	jae    800b6b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b56:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
  800b5a:	38 10                	cmp    %dl,(%eax)
  800b5c:	75 06                	jne    800b64 <memfind+0x1d>
  800b5e:	eb 0b                	jmp    800b6b <memfind+0x24>
  800b60:	38 10                	cmp    %dl,(%eax)
  800b62:	74 07                	je     800b6b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b64:	83 c0 01             	add    $0x1,%eax
  800b67:	39 c8                	cmp    %ecx,%eax
  800b69:	75 f5                	jne    800b60 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b6b:	5d                   	pop    %ebp
  800b6c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800b70:	c3                   	ret    

00800b71 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
  800b77:	83 ec 04             	sub    $0x4,%esp
  800b7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b7d:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b80:	0f b6 01             	movzbl (%ecx),%eax
  800b83:	3c 20                	cmp    $0x20,%al
  800b85:	74 04                	je     800b8b <strtol+0x1a>
  800b87:	3c 09                	cmp    $0x9,%al
  800b89:	75 0e                	jne    800b99 <strtol+0x28>
		s++;
  800b8b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b8e:	0f b6 01             	movzbl (%ecx),%eax
  800b91:	3c 20                	cmp    $0x20,%al
  800b93:	74 f6                	je     800b8b <strtol+0x1a>
  800b95:	3c 09                	cmp    $0x9,%al
  800b97:	74 f2                	je     800b8b <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b99:	3c 2b                	cmp    $0x2b,%al
  800b9b:	75 0c                	jne    800ba9 <strtol+0x38>
		s++;
  800b9d:	83 c1 01             	add    $0x1,%ecx
  800ba0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ba7:	eb 15                	jmp    800bbe <strtol+0x4d>
	else if (*s == '-')
  800ba9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bb0:	3c 2d                	cmp    $0x2d,%al
  800bb2:	75 0a                	jne    800bbe <strtol+0x4d>
		s++, neg = 1;
  800bb4:	83 c1 01             	add    $0x1,%ecx
  800bb7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bbe:	85 f6                	test   %esi,%esi
  800bc0:	0f 94 c0             	sete   %al
  800bc3:	74 05                	je     800bca <strtol+0x59>
  800bc5:	83 fe 10             	cmp    $0x10,%esi
  800bc8:	75 18                	jne    800be2 <strtol+0x71>
  800bca:	80 39 30             	cmpb   $0x30,(%ecx)
  800bcd:	75 13                	jne    800be2 <strtol+0x71>
  800bcf:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bd3:	75 0d                	jne    800be2 <strtol+0x71>
		s += 2, base = 16;
  800bd5:	83 c1 02             	add    $0x2,%ecx
  800bd8:	be 10 00 00 00       	mov    $0x10,%esi
  800bdd:	8d 76 00             	lea    0x0(%esi),%esi
  800be0:	eb 1b                	jmp    800bfd <strtol+0x8c>
	else if (base == 0 && s[0] == '0')
  800be2:	85 f6                	test   %esi,%esi
  800be4:	75 0e                	jne    800bf4 <strtol+0x83>
  800be6:	80 39 30             	cmpb   $0x30,(%ecx)
  800be9:	75 09                	jne    800bf4 <strtol+0x83>
		s++, base = 8;
  800beb:	83 c1 01             	add    $0x1,%ecx
  800bee:	66 be 08 00          	mov    $0x8,%si
  800bf2:	eb 09                	jmp    800bfd <strtol+0x8c>
	else if (base == 0)
  800bf4:	84 c0                	test   %al,%al
  800bf6:	74 05                	je     800bfd <strtol+0x8c>
  800bf8:	be 0a 00 00 00       	mov    $0xa,%esi
  800bfd:	bf 00 00 00 00       	mov    $0x0,%edi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c02:	0f b6 11             	movzbl (%ecx),%edx
  800c05:	89 d3                	mov    %edx,%ebx
  800c07:	8d 42 d0             	lea    -0x30(%edx),%eax
  800c0a:	3c 09                	cmp    $0x9,%al
  800c0c:	77 08                	ja     800c16 <strtol+0xa5>
			dig = *s - '0';
  800c0e:	0f be c2             	movsbl %dl,%eax
  800c11:	8d 50 d0             	lea    -0x30(%eax),%edx
  800c14:	eb 1c                	jmp    800c32 <strtol+0xc1>
		else if (*s >= 'a' && *s <= 'z')
  800c16:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800c19:	3c 19                	cmp    $0x19,%al
  800c1b:	77 08                	ja     800c25 <strtol+0xb4>
			dig = *s - 'a' + 10;
  800c1d:	0f be c2             	movsbl %dl,%eax
  800c20:	8d 50 a9             	lea    -0x57(%eax),%edx
  800c23:	eb 0d                	jmp    800c32 <strtol+0xc1>
		else if (*s >= 'A' && *s <= 'Z')
  800c25:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800c28:	3c 19                	cmp    $0x19,%al
  800c2a:	77 17                	ja     800c43 <strtol+0xd2>
			dig = *s - 'A' + 10;
  800c2c:	0f be c2             	movsbl %dl,%eax
  800c2f:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800c32:	39 f2                	cmp    %esi,%edx
  800c34:	7d 0d                	jge    800c43 <strtol+0xd2>
			break;
		s++, val = (val * base) + dig;
  800c36:	83 c1 01             	add    $0x1,%ecx
  800c39:	89 f8                	mov    %edi,%eax
  800c3b:	0f af c6             	imul   %esi,%eax
  800c3e:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800c41:	eb bf                	jmp    800c02 <strtol+0x91>
		// we don't properly detect overflow!
	}
  800c43:	89 f8                	mov    %edi,%eax

	if (endptr)
  800c45:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c49:	74 05                	je     800c50 <strtol+0xdf>
		*endptr = (char *) s;
  800c4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c4e:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800c50:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c54:	74 04                	je     800c5a <strtol+0xe9>
  800c56:	89 c7                	mov    %eax,%edi
  800c58:	f7 df                	neg    %edi
}
  800c5a:	89 f8                	mov    %edi,%eax
  800c5c:	83 c4 04             	add    $0x4,%esp
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	83 ec 0c             	sub    $0xc,%esp
  800c6a:	89 1c 24             	mov    %ebx,(%esp)
  800c6d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c71:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c75:	b8 01 00 00 00       	mov    $0x1,%eax
  800c7a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c7f:	89 fa                	mov    %edi,%edx
  800c81:	89 f9                	mov    %edi,%ecx
  800c83:	89 fb                	mov    %edi,%ebx
  800c85:	89 fe                	mov    %edi,%esi
  800c87:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c89:	8b 1c 24             	mov    (%esp),%ebx
  800c8c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c90:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c94:	89 ec                	mov    %ebp,%esp
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	83 ec 0c             	sub    $0xc,%esp
  800c9e:	89 1c 24             	mov    %ebx,(%esp)
  800ca1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ca5:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ca9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caf:	bf 00 00 00 00       	mov    $0x0,%edi
  800cb4:	89 f8                	mov    %edi,%eax
  800cb6:	89 fb                	mov    %edi,%ebx
  800cb8:	89 fe                	mov    %edi,%esi
  800cba:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cbc:	8b 1c 24             	mov    (%esp),%ebx
  800cbf:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cc3:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cc7:	89 ec                	mov    %ebp,%esp
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	83 ec 0c             	sub    $0xc,%esp
  800cd1:	89 1c 24             	mov    %ebx,(%esp)
  800cd4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cd8:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdc:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ce1:	bf 00 00 00 00       	mov    $0x0,%edi
  800ce6:	89 fa                	mov    %edi,%edx
  800ce8:	89 f9                	mov    %edi,%ecx
  800cea:	89 fb                	mov    %edi,%ebx
  800cec:	89 fe                	mov    %edi,%esi
  800cee:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800cf0:	8b 1c 24             	mov    (%esp),%ebx
  800cf3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cf7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cfb:	89 ec                	mov    %ebp,%esp
  800cfd:	5d                   	pop    %ebp
  800cfe:	c3                   	ret    

00800cff <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	83 ec 28             	sub    $0x28,%esp
  800d05:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d08:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d0b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d0e:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d11:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d16:	bf 00 00 00 00       	mov    $0x0,%edi
  800d1b:	89 f9                	mov    %edi,%ecx
  800d1d:	89 fb                	mov    %edi,%ebx
  800d1f:	89 fe                	mov    %edi,%esi
  800d21:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800d23:	85 c0                	test   %eax,%eax
  800d25:	7e 28                	jle    800d4f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d27:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2b:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d32:	00 
  800d33:	c7 44 24 08 3f 2c 80 	movl   $0x802c3f,0x8(%esp)
  800d3a:	00 
  800d3b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d42:	00 
  800d43:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  800d4a:	e8 dd 17 00 00       	call   80252c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d4f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d52:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d55:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d58:	89 ec                	mov    %ebp,%esp
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    

00800d5c <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	83 ec 0c             	sub    $0xc,%esp
  800d62:	89 1c 24             	mov    %ebx,(%esp)
  800d65:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d69:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d73:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d76:	8b 7d 14             	mov    0x14(%ebp),%edi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d79:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d7e:	be 00 00 00 00       	mov    $0x0,%esi
  800d83:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d85:	8b 1c 24             	mov    (%esp),%ebx
  800d88:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d8c:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d90:	89 ec                	mov    %ebp,%esp
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    

00800d94 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	83 ec 28             	sub    $0x28,%esp
  800d9a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d9d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800da0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800da3:	8b 55 08             	mov    0x8(%ebp),%edx
  800da6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dae:	bf 00 00 00 00       	mov    $0x0,%edi
  800db3:	89 fb                	mov    %edi,%ebx
  800db5:	89 fe                	mov    %edi,%esi
  800db7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800db9:	85 c0                	test   %eax,%eax
  800dbb:	7e 28                	jle    800de5 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc1:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800dc8:	00 
  800dc9:	c7 44 24 08 3f 2c 80 	movl   $0x802c3f,0x8(%esp)
  800dd0:	00 
  800dd1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd8:	00 
  800dd9:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  800de0:	e8 47 17 00 00       	call   80252c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800de5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800deb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dee:	89 ec                	mov    %ebp,%esp
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    

00800df2 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	83 ec 28             	sub    $0x28,%esp
  800df8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dfb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dfe:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e01:	8b 55 08             	mov    0x8(%ebp),%edx
  800e04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e07:	b8 09 00 00 00       	mov    $0x9,%eax
  800e0c:	bf 00 00 00 00       	mov    $0x0,%edi
  800e11:	89 fb                	mov    %edi,%ebx
  800e13:	89 fe                	mov    %edi,%esi
  800e15:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800e17:	85 c0                	test   %eax,%eax
  800e19:	7e 28                	jle    800e43 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1f:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e26:	00 
  800e27:	c7 44 24 08 3f 2c 80 	movl   $0x802c3f,0x8(%esp)
  800e2e:	00 
  800e2f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e36:	00 
  800e37:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  800e3e:	e8 e9 16 00 00       	call   80252c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e43:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e46:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e49:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e4c:	89 ec                	mov    %ebp,%esp
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	83 ec 28             	sub    $0x28,%esp
  800e56:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e59:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e5c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e65:	b8 08 00 00 00       	mov    $0x8,%eax
  800e6a:	bf 00 00 00 00       	mov    $0x0,%edi
  800e6f:	89 fb                	mov    %edi,%ebx
  800e71:	89 fe                	mov    %edi,%esi
  800e73:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800e75:	85 c0                	test   %eax,%eax
  800e77:	7e 28                	jle    800ea1 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e79:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e7d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e84:	00 
  800e85:	c7 44 24 08 3f 2c 80 	movl   $0x802c3f,0x8(%esp)
  800e8c:	00 
  800e8d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e94:	00 
  800e95:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  800e9c:	e8 8b 16 00 00       	call   80252c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ea1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ea4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eaa:	89 ec                	mov    %ebp,%esp
  800eac:	5d                   	pop    %ebp
  800ead:	c3                   	ret    

00800eae <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	83 ec 28             	sub    $0x28,%esp
  800eb4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eb7:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eba:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ebd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec3:	b8 06 00 00 00       	mov    $0x6,%eax
  800ec8:	bf 00 00 00 00       	mov    $0x0,%edi
  800ecd:	89 fb                	mov    %edi,%ebx
  800ecf:	89 fe                	mov    %edi,%esi
  800ed1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	7e 28                	jle    800eff <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800edb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ee2:	00 
  800ee3:	c7 44 24 08 3f 2c 80 	movl   $0x802c3f,0x8(%esp)
  800eea:	00 
  800eeb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef2:	00 
  800ef3:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  800efa:	e8 2d 16 00 00       	call   80252c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800eff:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f02:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f05:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f08:	89 ec                	mov    %ebp,%esp
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    

00800f0c <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	83 ec 28             	sub    $0x28,%esp
  800f12:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f15:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f18:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f21:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f24:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f27:	8b 75 18             	mov    0x18(%ebp),%esi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2a:	b8 05 00 00 00       	mov    $0x5,%eax
  800f2f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f31:	85 c0                	test   %eax,%eax
  800f33:	7e 28                	jle    800f5d <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f35:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f39:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f40:	00 
  800f41:	c7 44 24 08 3f 2c 80 	movl   $0x802c3f,0x8(%esp)
  800f48:	00 
  800f49:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f50:	00 
  800f51:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  800f58:	e8 cf 15 00 00       	call   80252c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f5d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f60:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f63:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f66:	89 ec                	mov    %ebp,%esp
  800f68:	5d                   	pop    %ebp
  800f69:	c3                   	ret    

00800f6a <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	83 ec 28             	sub    $0x28,%esp
  800f70:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f73:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f76:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f79:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f82:	b8 04 00 00 00       	mov    $0x4,%eax
  800f87:	bf 00 00 00 00       	mov    $0x0,%edi
  800f8c:	89 fe                	mov    %edi,%esi
  800f8e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f90:	85 c0                	test   %eax,%eax
  800f92:	7e 28                	jle    800fbc <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f94:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f98:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f9f:	00 
  800fa0:	c7 44 24 08 3f 2c 80 	movl   $0x802c3f,0x8(%esp)
  800fa7:	00 
  800fa8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800faf:	00 
  800fb0:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  800fb7:	e8 70 15 00 00       	call   80252c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fbc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fbf:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fc2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fc5:	89 ec                	mov    %ebp,%esp
  800fc7:	5d                   	pop    %ebp
  800fc8:	c3                   	ret    

00800fc9 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800fc9:	55                   	push   %ebp
  800fca:	89 e5                	mov    %esp,%ebp
  800fcc:	83 ec 0c             	sub    $0xc,%esp
  800fcf:	89 1c 24             	mov    %ebx,(%esp)
  800fd2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fd6:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fda:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fdf:	bf 00 00 00 00       	mov    $0x0,%edi
  800fe4:	89 fa                	mov    %edi,%edx
  800fe6:	89 f9                	mov    %edi,%ecx
  800fe8:	89 fb                	mov    %edi,%ebx
  800fea:	89 fe                	mov    %edi,%esi
  800fec:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800fee:	8b 1c 24             	mov    (%esp),%ebx
  800ff1:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ff5:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ff9:	89 ec                	mov    %ebp,%esp
  800ffb:	5d                   	pop    %ebp
  800ffc:	c3                   	ret    

00800ffd <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	83 ec 0c             	sub    $0xc,%esp
  801003:	89 1c 24             	mov    %ebx,(%esp)
  801006:	89 74 24 04          	mov    %esi,0x4(%esp)
  80100a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80100e:	b8 02 00 00 00       	mov    $0x2,%eax
  801013:	bf 00 00 00 00       	mov    $0x0,%edi
  801018:	89 fa                	mov    %edi,%edx
  80101a:	89 f9                	mov    %edi,%ecx
  80101c:	89 fb                	mov    %edi,%ebx
  80101e:	89 fe                	mov    %edi,%esi
  801020:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801022:	8b 1c 24             	mov    (%esp),%ebx
  801025:	8b 74 24 04          	mov    0x4(%esp),%esi
  801029:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80102d:	89 ec                	mov    %ebp,%esp
  80102f:	5d                   	pop    %ebp
  801030:	c3                   	ret    

00801031 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801031:	55                   	push   %ebp
  801032:	89 e5                	mov    %esp,%ebp
  801034:	83 ec 28             	sub    $0x28,%esp
  801037:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80103a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80103d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801040:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801043:	b8 03 00 00 00       	mov    $0x3,%eax
  801048:	bf 00 00 00 00       	mov    $0x0,%edi
  80104d:	89 f9                	mov    %edi,%ecx
  80104f:	89 fb                	mov    %edi,%ebx
  801051:	89 fe                	mov    %edi,%esi
  801053:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801055:	85 c0                	test   %eax,%eax
  801057:	7e 28                	jle    801081 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801059:	89 44 24 10          	mov    %eax,0x10(%esp)
  80105d:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801064:	00 
  801065:	c7 44 24 08 3f 2c 80 	movl   $0x802c3f,0x8(%esp)
  80106c:	00 
  80106d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801074:	00 
  801075:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  80107c:	e8 ab 14 00 00       	call   80252c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801081:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801084:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801087:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80108a:	89 ec                	mov    %ebp,%esp
  80108c:	5d                   	pop    %ebp
  80108d:	c3                   	ret    
	...

00801090 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
// 
static int
duppage(envid_t envid, unsigned pn)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	53                   	push   %ebx
  801094:	83 ec 14             	sub    $0x14,%esp
  801097:	89 c1                	mov    %eax,%ecx
	int r;

	// LAB 4: Your code here.
	pde_t *pde;
	pte_t *pte;
	void *addr=(void*)(pn*PGSIZE);
  801099:	89 d3                	mov    %edx,%ebx
  80109b:	c1 e3 0c             	shl    $0xc,%ebx
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
  80109e:	89 d8                	mov    %ebx,%eax
  8010a0:	c1 e8 16             	shr    $0x16,%eax
  8010a3:	f6 04 85 00 d0 7b ef 	testb  $0x1,-0x10843000(,%eax,4)
  8010aa:	01 
  8010ab:	74 14                	je     8010c1 <duppage+0x31>
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else    panic("page table for pn page is not exist");
	if((*pte&PTE_W)||(*pte&PTE_COW))
  8010ad:	89 d8                	mov    %ebx,%eax
  8010af:	c1 e8 0c             	shr    $0xc,%eax
  8010b2:	f7 04 85 00 00 40 ef 	testl  $0x802,-0x10c00000(,%eax,4)
  8010b9:	02 08 00 00 
  8010bd:	75 1e                	jne    8010dd <duppage+0x4d>
  8010bf:	eb 73                	jmp    801134 <duppage+0xa4>
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else    panic("page table for pn page is not exist");
  8010c1:	c7 44 24 08 6c 2c 80 	movl   $0x802c6c,0x8(%esp)
  8010c8:	00 
  8010c9:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
  8010d0:	00 
  8010d1:	c7 04 24 2a 2d 80 00 	movl   $0x802d2a,(%esp)
  8010d8:	e8 4f 14 00 00       	call   80252c <_panic>
	if((*pte&PTE_W)||(*pte&PTE_COW))
	{
		if((r=sys_page_map(0,addr,envid,addr,PTE_COW|PTE_U))<0)
  8010dd:	c7 44 24 10 04 08 00 	movl   $0x804,0x10(%esp)
  8010e4:	00 
  8010e5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010e9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010f8:	e8 0f fe ff ff       	call   800f0c <sys_page_map>
  8010fd:	85 c0                	test   %eax,%eax
  8010ff:	78 60                	js     801161 <duppage+0xd1>
			return r;
		if((r=sys_page_map(0,addr,0,addr,PTE_COW|PTE_U))<0)//映射的时候注意env的id
  801101:	c7 44 24 10 04 08 00 	movl   $0x804,0x10(%esp)
  801108:	00 
  801109:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80110d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801114:	00 
  801115:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801119:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801120:	e8 e7 fd ff ff       	call   800f0c <sys_page_map>
  801125:	85 c0                	test   %eax,%eax
  801127:	0f 9f c2             	setg   %dl
  80112a:	0f b6 d2             	movzbl %dl,%edx
  80112d:	83 ea 01             	sub    $0x1,%edx
  801130:	21 d0                	and    %edx,%eax
  801132:	eb 2d                	jmp    801161 <duppage+0xd1>
                        return r;
	}
	else{	
		if((r=sys_page_map(0,addr,envid,addr,PTE_U|PTE_P))<0)
  801134:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80113b:	00 
  80113c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801140:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801144:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801148:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80114f:	e8 b8 fd ff ff       	call   800f0c <sys_page_map>
  801154:	85 c0                	test   %eax,%eax
  801156:	0f 9f c2             	setg   %dl
  801159:	0f b6 d2             	movzbl %dl,%edx
  80115c:	83 ea 01             	sub    $0x1,%edx
  80115f:	21 d0                	and    %edx,%eax
			return r;
	}
	//panic("duppage not implemented");
	return 0;
}
  801161:	83 c4 14             	add    $0x14,%esp
  801164:	5b                   	pop    %ebx
  801165:	5d                   	pop    %ebp
  801166:	c3                   	ret    

00801167 <sfork>:
	return 0;
}
// Challenge!
int
sfork(void)
{
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	57                   	push   %edi
  80116b:	56                   	push   %esi
  80116c:	53                   	push   %ebx
  80116d:	83 ec 1c             	sub    $0x1c,%esp
static __inline envid_t sys_exofork(void) __attribute__((always_inline));
static __inline envid_t
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801170:	ba 07 00 00 00       	mov    $0x7,%edx
  801175:	89 d0                	mov    %edx,%eax
  801177:	cd 30                	int    $0x30
  801179:	89 45 f0             	mov    %eax,-0x10(%ebp)
	pte_t *pte;
	unsigned i;
	uint32_t addr;
	envid_t envid;
	envid = sys_exofork();//创建子环境
	if(envid < 0)
  80117c:	85 c0                	test   %eax,%eax
  80117e:	79 20                	jns    8011a0 <sfork+0x39>
		panic("sys_exofork: %e", envid);
  801180:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801184:	c7 44 24 08 35 2d 80 	movl   $0x802d35,0x8(%esp)
  80118b:	00 
  80118c:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  801193:	00 
  801194:	c7 04 24 2a 2d 80 00 	movl   $0x802d2a,(%esp)
  80119b:	e8 8c 13 00 00       	call   80252c <_panic>
	if(envid==0)//子环境中
  8011a0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8011a4:	75 21                	jne    8011c7 <sfork+0x60>
	{
		env = &envs[ENVX(sys_getenvid())];
  8011a6:	e8 52 fe ff ff       	call   800ffd <sys_getenvid>
  8011ab:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011b0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011b3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011b8:	a3 3c 60 80 00       	mov    %eax,0x80603c
  8011bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c2:	e9 83 01 00 00       	jmp    80134a <sfork+0x1e3>
		return 0;
	}
	else{//父环境中,注意：这里需要设置父环境的缺页异常栈，还需要设置子环境的缺页异常栈，
	//父子环境的页异常栈不共享？具体原因还得思考
		env = &envs[ENVX(sys_getenvid())];
  8011c7:	e8 31 fe ff ff       	call   800ffd <sys_getenvid>
  8011cc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011d1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011d4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011d9:	a3 3c 60 80 00       	mov    %eax,0x80603c
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
  8011de:	c7 04 24 52 13 80 00 	movl   $0x801352,(%esp)
  8011e5:	e8 ae 13 00 00       	call   802598 <set_pgfault_handler>
  8011ea:	be 00 00 00 00       	mov    $0x0,%esi
  8011ef:	bf 00 00 00 00       	mov    $0x0,%edi
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
		{
			addr=i*PGSIZE;
			pde =(pde_t*) &vpd[VPD(addr)];
  8011f4:	89 f8                	mov    %edi,%eax
  8011f6:	c1 e8 16             	shr    $0x16,%eax
  8011f9:	c1 e0 02             	shl    $0x2,%eax
			if(*pde&PTE_P)//这里只处理有物理页面映射的页表项
  8011fc:	f6 80 00 d0 7b ef 01 	testb  $0x1,-0x10843000(%eax)
  801203:	0f 84 dc 00 00 00    	je     8012e5 <sfork+0x17e>
			{
				pte=(pte_t*)&vpt[VPN(addr)];
			}
			else    continue;
			if((i==(unsigned)VPN(USTACKTOP-PGSIZE))||(i==(unsigned)VPN(PFTEMP)))
  801209:	81 fe fd eb 0e 00    	cmp    $0xeebfd,%esi
  80120f:	74 08                	je     801219 <sfork+0xb2>
  801211:	81 fe ff 07 00 00    	cmp    $0x7ff,%esi
  801217:	75 17                	jne    801230 <sfork+0xc9>
								//特殊处理，用户层普通栈
			{	
				if((r=duppage(envid,i))<0)
  801219:	89 f2                	mov    %esi,%edx
  80121b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121e:	e8 6d fe ff ff       	call   801090 <duppage>
  801223:	85 c0                	test   %eax,%eax
  801225:	0f 89 ba 00 00 00    	jns    8012e5 <sfork+0x17e>
  80122b:	e9 1a 01 00 00       	jmp    80134a <sfork+0x1e3>
	// LAB 4: Your code here.
	pde_t *pde;
	pte_t *pte;
	void *addr=(void*)(pn*PGSIZE);
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
  801230:	f6 80 00 d0 7b ef 01 	testb  $0x1,-0x10843000(%eax)
  801237:	74 11                	je     80124a <sfork+0xe3>
	{
		pte=(pte_t*)&vpt[VPN(addr)];
  801239:	89 f8                	mov    %edi,%eax
  80123b:	c1 e8 0c             	shr    $0xc,%eax
	}
	else    panic("page table for pn page is not exist");
	if(*pte&PTE_W)
  80123e:	f6 04 85 00 00 40 ef 	testb  $0x2,-0x10c00000(,%eax,4)
  801245:	02 
  801246:	75 1e                	jne    801266 <sfork+0xff>
  801248:	eb 74                	jmp    8012be <sfork+0x157>
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else    panic("page table for pn page is not exist");
  80124a:	c7 44 24 08 6c 2c 80 	movl   $0x802c6c,0x8(%esp)
  801251:	00 
  801252:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
  801259:	00 
  80125a:	c7 04 24 2a 2d 80 00 	movl   $0x802d2a,(%esp)
  801261:	e8 c6 12 00 00       	call   80252c <_panic>
	if(*pte&PTE_W)
	{
		//cprintf("sduppage:addr=%x\n",addr);
		if((r=sys_page_map(0,addr,envid,addr,PTE_W|PTE_U))<0)
  801266:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
  80126d:	00 
  80126e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801272:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801275:	89 44 24 08          	mov    %eax,0x8(%esp)
  801279:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80127d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801284:	e8 83 fc ff ff       	call   800f0c <sys_page_map>
  801289:	85 c0                	test   %eax,%eax
  80128b:	0f 88 b9 00 00 00    	js     80134a <sfork+0x1e3>
			return r;
		if((r=sys_page_map(0,addr,0,addr,PTE_W|PTE_U))<0)//映射的时候注意env的id
  801291:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
  801298:	00 
  801299:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80129d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012a4:	00 
  8012a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012b0:	e8 57 fc ff ff       	call   800f0c <sys_page_map>
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	79 2c                	jns    8012e5 <sfork+0x17e>
  8012b9:	e9 8c 00 00 00       	jmp    80134a <sfork+0x1e3>
                        return r;
	}
	else{	
		if((r=sys_page_map(0,addr,envid,addr,PTE_U|PTE_P))<0)
  8012be:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8012c5:	00 
  8012c6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012dc:	e8 2b fc ff ff       	call   800f0c <sys_page_map>
  8012e1:	85 c0                	test   %eax,%eax
  8012e3:	78 65                	js     80134a <sfork+0x1e3>
	}
	else{//父环境中,注意：这里需要设置父环境的缺页异常栈，还需要设置子环境的缺页异常栈，
	//父子环境的页异常栈不共享？具体原因还得思考
		env = &envs[ENVX(sys_getenvid())];
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
  8012e5:	83 c6 01             	add    $0x1,%esi
  8012e8:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8012ee:	81 fe 00 ec 0e 00    	cmp    $0xeec00,%esi
  8012f4:	0f 85 fa fe ff ff    	jne    8011f4 <sfork+0x8d>
				continue;
			}
			if((r=sduppage(envid,i))<0)
				return r;
		}
		if((r=sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  8012fa:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801301:	00 
  801302:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801309:	ee 
  80130a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130d:	89 04 24             	mov    %eax,(%esp)
  801310:	e8 55 fc ff ff       	call   800f6a <sys_page_alloc>
  801315:	85 c0                	test   %eax,%eax
  801317:	78 31                	js     80134a <sfork+0x1e3>
                        return r;//设置子环境的缺页异常栈
		if((r=sys_env_set_pgfault_upcall(envid,(void*)_pgfault_upcall))<0)
  801319:	c7 44 24 04 1c 26 80 	movl   $0x80261c,0x4(%esp)
  801320:	00 
  801321:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801324:	89 04 24             	mov    %eax,(%esp)
  801327:	e8 68 fa ff ff       	call   800d94 <sys_env_set_pgfault_upcall>
  80132c:	85 c0                	test   %eax,%eax
  80132e:	78 1a                	js     80134a <sfork+0x1e3>
			return r;//设置子环境的缺页异常处理入口点
		if((r=sys_env_set_status(envid,ENV_RUNNABLE))<0)
  801330:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801337:	00 
  801338:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133b:	89 04 24             	mov    %eax,(%esp)
  80133e:	e8 0d fb ff ff       	call   800e50 <sys_env_set_status>
  801343:	85 c0                	test   %eax,%eax
  801345:	78 03                	js     80134a <sfork+0x1e3>
  801347:	8b 45 f0             	mov    -0x10(%ebp),%eax
			return r;//设置子环境的状态为可运行
		return envid;
	}
	//panic("sfork not implemented");
	//return -E_INVAL;
}
  80134a:	83 c4 1c             	add    $0x1c,%esp
  80134d:	5b                   	pop    %ebx
  80134e:	5e                   	pop    %esi
  80134f:	5f                   	pop    %edi
  801350:	5d                   	pop    %ebp
  801351:	c3                   	ret    

00801352 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801352:	55                   	push   %ebp
  801353:	89 e5                	mov    %esp,%ebp
  801355:	56                   	push   %esi
  801356:	53                   	push   %ebx
  801357:	83 ec 20             	sub    $0x20,%esp
  80135a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
  80135d:	8b 71 04             	mov    0x4(%ecx),%esi

	// LAB 4: Your code here.
	pde_t *pde;
	pte_t *pte;
	uint32_t *va,*srcva,*dstva;
	pde =(pde_t*) &vpd[VPD(addr)];
  801360:	8b 19                	mov    (%ecx),%ebx
  801362:	89 d8                	mov    %ebx,%eax
  801364:	c1 e8 16             	shr    $0x16,%eax
  801367:	c1 e0 02             	shl    $0x2,%eax
  80136a:	8d 90 00 d0 7b ef    	lea    -0x10843000(%eax),%edx
	if(*pde&PTE_P)
  801370:	f6 80 00 d0 7b ef 01 	testb  $0x1,-0x10843000(%eax)
  801377:	74 16                	je     80138f <pgfault+0x3d>
	{
		pte=(pte_t*)&vpt[VPN(addr)];
  801379:	89 d8                	mov    %ebx,%eax
  80137b:	c1 e8 0c             	shr    $0xc,%eax
  80137e:	8d 04 85 00 00 40 ef 	lea    -0x10c00000(,%eax,4),%eax
	else{
		cprintf("addr=%x err=%x *pde=%x utf_eip=%x\n",(uint32_t)addr,err,*pde,utf->utf_eip);	
		panic("page table for fault va is not exist");
	}
	//cprintf("addr=%x err=%x *pte=%x utf_eip=%x\n",(uint32_t)addr,err,*pte,utf->utf_eip);
	if(!(err&FEC_WR)||!(*pte&PTE_COW))
  801385:	f7 c6 02 00 00 00    	test   $0x2,%esi
  80138b:	75 3f                	jne    8013cc <pgfault+0x7a>
  80138d:	eb 43                	jmp    8013d2 <pgfault+0x80>
	if(*pde&PTE_P)
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else{
		cprintf("addr=%x err=%x *pde=%x utf_eip=%x\n",(uint32_t)addr,err,*pde,utf->utf_eip);	
  80138f:	8b 41 28             	mov    0x28(%ecx),%eax
  801392:	8b 12                	mov    (%edx),%edx
  801394:	89 44 24 10          	mov    %eax,0x10(%esp)
  801398:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80139c:	89 74 24 08          	mov    %esi,0x8(%esp)
  8013a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013a4:	c7 04 24 90 2c 80 00 	movl   $0x802c90,(%esp)
  8013ab:	e8 21 ee ff ff       	call   8001d1 <cprintf>
		panic("page table for fault va is not exist");
  8013b0:	c7 44 24 08 b4 2c 80 	movl   $0x802cb4,0x8(%esp)
  8013b7:	00 
  8013b8:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  8013bf:	00 
  8013c0:	c7 04 24 2a 2d 80 00 	movl   $0x802d2a,(%esp)
  8013c7:	e8 60 11 00 00       	call   80252c <_panic>
	}
	//cprintf("addr=%x err=%x *pte=%x utf_eip=%x\n",(uint32_t)addr,err,*pte,utf->utf_eip);
	if(!(err&FEC_WR)||!(*pte&PTE_COW))
  8013cc:	f6 40 01 08          	testb  $0x8,0x1(%eax)
  8013d0:	75 49                	jne    80141b <pgfault+0xc9>
	{	
		cprintf("envid=%x addr=%x err=%x *pte=%x utf_eip=%x\n",env->env_id,(uint32_t)addr,err,*pte,utf->utf_eip);
  8013d2:	8b 51 28             	mov    0x28(%ecx),%edx
  8013d5:	8b 08                	mov    (%eax),%ecx
  8013d7:	a1 3c 60 80 00       	mov    0x80603c,%eax
  8013dc:	8b 40 4c             	mov    0x4c(%eax),%eax
  8013df:	89 54 24 14          	mov    %edx,0x14(%esp)
  8013e3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8013e7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013eb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f3:	c7 04 24 dc 2c 80 00 	movl   $0x802cdc,(%esp)
  8013fa:	e8 d2 ed ff ff       	call   8001d1 <cprintf>
		panic("faulting access is illegle");
  8013ff:	c7 44 24 08 45 2d 80 	movl   $0x802d45,0x8(%esp)
  801406:	00 
  801407:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  80140e:	00 
  80140f:	c7 04 24 2a 2d 80 00 	movl   $0x802d2a,(%esp)
  801416:	e8 11 11 00 00       	call   80252c <_panic>
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	//cprintf("pgfault:env_id=%x\n",env->env_id);
	if((r=sys_page_alloc(0,PFTEMP,PTE_W|PTE_U|PTE_P))<0)
  80141b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801422:	00 
  801423:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80142a:	00 
  80142b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801432:	e8 33 fb ff ff       	call   800f6a <sys_page_alloc>
  801437:	85 c0                	test   %eax,%eax
  801439:	79 20                	jns    80145b <pgfault+0x109>
			//输入id=0表示当前环境id(curenv->env_id),这个时候不能用env->env-id,子环境中env的修改会缺页
		panic("alloc a page for PFTEMP failed:%e",r);
  80143b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80143f:	c7 44 24 08 08 2d 80 	movl   $0x802d08,0x8(%esp)
  801446:	00 
  801447:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  80144e:	00 
  80144f:	c7 04 24 2a 2d 80 00 	movl   $0x802d2a,(%esp)
  801456:	e8 d1 10 00 00       	call   80252c <_panic>
	//cprintf("PFTEMP=%x add=%x\n",PFTEMP,(uint32_t)addr&0xfffff000);
	srcva = (uint32_t*)((uint32_t)addr&0xfffff000);
  80145b:	89 de                	mov    %ebx,%esi
  80145d:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  801463:	89 f2                	mov    %esi,%edx
	dstva = (uint32_t*)PFTEMP;
	//strncpy((char*)PFTEMP,(char*)((uint32_t)addr&0xfffff000),PGSIZE);
	for(;srcva<(uint32_t*)(ROUNDUP(addr,PGSIZE));srcva++)//数据拷贝要注意，用strncpy出错了，原因还得分析
  801465:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  80146b:	89 c3                	mov    %eax,%ebx
  80146d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801473:	39 de                	cmp    %ebx,%esi
  801475:	73 13                	jae    80148a <pgfault+0x138>
  801477:	b9 00 f0 7f 00       	mov    $0x7ff000,%ecx
	{
		*dstva=*srcva;
  80147c:	8b 02                	mov    (%edx),%eax
  80147e:	89 01                	mov    %eax,(%ecx)
		dstva++;
  801480:	83 c1 04             	add    $0x4,%ecx
		panic("alloc a page for PFTEMP failed:%e",r);
	//cprintf("PFTEMP=%x add=%x\n",PFTEMP,(uint32_t)addr&0xfffff000);
	srcva = (uint32_t*)((uint32_t)addr&0xfffff000);
	dstva = (uint32_t*)PFTEMP;
	//strncpy((char*)PFTEMP,(char*)((uint32_t)addr&0xfffff000),PGSIZE);
	for(;srcva<(uint32_t*)(ROUNDUP(addr,PGSIZE));srcva++)//数据拷贝要注意，用strncpy出错了，原因还得分析
  801483:	83 c2 04             	add    $0x4,%edx
  801486:	39 da                	cmp    %ebx,%edx
  801488:	72 f2                	jb     80147c <pgfault+0x12a>
	{
		*dstva=*srcva;
		dstva++;
	}
	if((r=sys_page_map(0,(void*)PFTEMP,0,(void*)((uint32_t)addr&0xfffff000),PTE_W|PTE_U|PTE_P))<0)
  80148a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801491:	00 
  801492:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801496:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80149d:	00 
  80149e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8014a5:	00 
  8014a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014ad:	e8 5a fa ff ff       	call   800f0c <sys_page_map>
  8014b2:	85 c0                	test   %eax,%eax
  8014b4:	79 1c                	jns    8014d2 <pgfault+0x180>
			//输入id=0表示当前环境id(curenv->env_id),这个时候不能用env->env-id,子环境中env的修改会缺页
		panic("page mapping failed");
  8014b6:	c7 44 24 08 60 2d 80 	movl   $0x802d60,0x8(%esp)
  8014bd:	00 
  8014be:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  8014c5:	00 
  8014c6:	c7 04 24 2a 2d 80 00 	movl   $0x802d2a,(%esp)
  8014cd:	e8 5a 10 00 00       	call   80252c <_panic>
	//panic("pgfault not implemented");
}
  8014d2:	83 c4 20             	add    $0x20,%esp
  8014d5:	5b                   	pop    %ebx
  8014d6:	5e                   	pop    %esi
  8014d7:	5d                   	pop    %ebp
  8014d8:	c3                   	ret    

008014d9 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8014d9:	55                   	push   %ebp
  8014da:	89 e5                	mov    %esp,%ebp
  8014dc:	56                   	push   %esi
  8014dd:	53                   	push   %ebx
  8014de:	83 ec 10             	sub    $0x10,%esp
  8014e1:	ba 07 00 00 00       	mov    $0x7,%edx
  8014e6:	89 d0                	mov    %edx,%eax
  8014e8:	cd 30                	int    $0x30
  8014ea:	89 c6                	mov    %eax,%esi
	pte_t *pte;
	unsigned i;
	uint32_t addr;
	envid_t envid;
	envid = sys_exofork();//创建子环境
	if(envid < 0)
  8014ec:	85 c0                	test   %eax,%eax
  8014ee:	79 20                	jns    801510 <fork+0x37>
		panic("sys_exofork: %e", envid);
  8014f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014f4:	c7 44 24 08 35 2d 80 	movl   $0x802d35,0x8(%esp)
  8014fb:	00 
  8014fc:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  801503:	00 
  801504:	c7 04 24 2a 2d 80 00 	movl   $0x802d2a,(%esp)
  80150b:	e8 1c 10 00 00       	call   80252c <_panic>
	if(envid==0)//子环境中
  801510:	85 c0                	test   %eax,%eax
  801512:	75 21                	jne    801535 <fork+0x5c>
	{
		env = &envs[ENVX(sys_getenvid())];
  801514:	e8 e4 fa ff ff       	call   800ffd <sys_getenvid>
  801519:	25 ff 03 00 00       	and    $0x3ff,%eax
  80151e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801521:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801526:	a3 3c 60 80 00       	mov    %eax,0x80603c
  80152b:	b8 00 00 00 00       	mov    $0x0,%eax
  801530:	e9 9e 00 00 00       	jmp    8015d3 <fork+0xfa>
		return 0;
	}
	else{//父环境中
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
  801535:	c7 04 24 52 13 80 00 	movl   $0x801352,(%esp)
  80153c:	e8 57 10 00 00       	call   802598 <set_pgfault_handler>
  801541:	bb 00 00 00 00       	mov    $0x0,%ebx
  801546:	eb 08                	jmp    801550 <fork+0x77>
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
		{
			if(i==(unsigned)VPN(UXSTACKTOP-PGSIZE))//特殊处理，用户层缺页异常栈
  801548:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  80154e:	74 3d                	je     80158d <fork+0xb4>
				continue;
  801550:	89 da                	mov    %ebx,%edx
  801552:	c1 e2 0c             	shl    $0xc,%edx
			addr=i*PGSIZE;
			pde =(pde_t*) &vpd[VPD(addr)];
  801555:	89 d0                	mov    %edx,%eax
  801557:	c1 e8 16             	shr    $0x16,%eax
			if(*pde&PTE_P)//这里只处理有物理页面映射的页表项
  80155a:	f6 04 85 00 d0 7b ef 	testb  $0x1,-0x10843000(,%eax,4)
  801561:	01 
  801562:	74 1e                	je     801582 <fork+0xa9>
			{
				pte=(pte_t*)&vpt[VPN(addr)];
  801564:	89 d0                	mov    %edx,%eax
  801566:	c1 e8 0a             	shr    $0xa,%eax
			}
			else    continue;
			if((*pte&PTE_W)||(*pte&PTE_COW))
  801569:	f7 80 00 00 40 ef 02 	testl  $0x802,-0x10c00000(%eax)
  801570:	08 00 00 
  801573:	74 0d                	je     801582 <fork+0xa9>
			{
				if((r=duppage(envid,i))<0)
  801575:	89 da                	mov    %ebx,%edx
  801577:	89 f0                	mov    %esi,%eax
  801579:	e8 12 fb ff ff       	call   801090 <duppage>
  80157e:	85 c0                	test   %eax,%eax
  801580:	78 51                	js     8015d3 <fork+0xfa>
		env = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	else{//父环境中
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
  801582:	83 c3 01             	add    $0x1,%ebx
  801585:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  80158b:	75 bb                	jne    801548 <fork+0x6f>
			{
				if((r=duppage(envid,i))<0)
					return r;
			}
		}
		if((r=sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  80158d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801594:	00 
  801595:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80159c:	ee 
  80159d:	89 34 24             	mov    %esi,(%esp)
  8015a0:	e8 c5 f9 ff ff       	call   800f6a <sys_page_alloc>
  8015a5:	85 c0                	test   %eax,%eax
  8015a7:	78 2a                	js     8015d3 <fork+0xfa>
			return r;//设置子环境的缺页异常栈
		if((r=sys_env_set_pgfault_upcall(envid,(void*)_pgfault_upcall))<0)
  8015a9:	c7 44 24 04 1c 26 80 	movl   $0x80261c,0x4(%esp)
  8015b0:	00 
  8015b1:	89 34 24             	mov    %esi,(%esp)
  8015b4:	e8 db f7 ff ff       	call   800d94 <sys_env_set_pgfault_upcall>
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	78 16                	js     8015d3 <fork+0xfa>
			return r;//设置子环境的缺页异常处理入口点
		if((r=sys_env_set_status(envid,ENV_RUNNABLE))<0)
  8015bd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8015c4:	00 
  8015c5:	89 34 24             	mov    %esi,(%esp)
  8015c8:	e8 83 f8 ff ff       	call   800e50 <sys_env_set_status>
  8015cd:	85 c0                	test   %eax,%eax
  8015cf:	78 02                	js     8015d3 <fork+0xfa>
  8015d1:	89 f0                	mov    %esi,%eax
			return r;//设置子环境的状态为可运行
		return envid;
	}
	//panic("fork not implemented");
}
  8015d3:	83 c4 10             	add    $0x10,%esp
  8015d6:	5b                   	pop    %ebx
  8015d7:	5e                   	pop    %esi
  8015d8:	5d                   	pop    %ebp
  8015d9:	c3                   	ret    
  8015da:	00 00                	add    %al,(%eax)
  8015dc:	00 00                	add    %al,(%eax)
	...

008015e0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8015e0:	55                   	push   %ebp
  8015e1:	89 e5                	mov    %esp,%ebp
  8015e3:	57                   	push   %edi
  8015e4:	56                   	push   %esi
  8015e5:	53                   	push   %ebx
  8015e6:	83 ec 1c             	sub    $0x1c,%esp
  8015e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8015ec:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  8015ef:	e8 09 fa ff ff       	call   800ffd <sys_getenvid>
  8015f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8015f9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8015fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801601:	a3 3c 60 80 00       	mov    %eax,0x80603c
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  801606:	e8 f2 f9 ff ff       	call   800ffd <sys_getenvid>
  80160b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801610:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801613:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801618:	a3 3c 60 80 00       	mov    %eax,0x80603c
		if(env->env_id==to_env){
  80161d:	8b 40 4c             	mov    0x4c(%eax),%eax
  801620:	39 f0                	cmp    %esi,%eax
  801622:	75 0e                	jne    801632 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  801624:	c7 04 24 74 2d 80 00 	movl   $0x802d74,(%esp)
  80162b:	e8 a1 eb ff ff       	call   8001d1 <cprintf>
  801630:	eb 5a                	jmp    80168c <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  801632:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801636:	8b 45 10             	mov    0x10(%ebp),%eax
  801639:	89 44 24 08          	mov    %eax,0x8(%esp)
  80163d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801640:	89 44 24 04          	mov    %eax,0x4(%esp)
  801644:	89 34 24             	mov    %esi,(%esp)
  801647:	e8 10 f7 ff ff       	call   800d5c <sys_ipc_try_send>
  80164c:	89 c3                	mov    %eax,%ebx
  80164e:	85 c0                	test   %eax,%eax
  801650:	79 25                	jns    801677 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  801652:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801655:	74 2b                	je     801682 <ipc_send+0xa2>
				panic("send error:%e",r);
  801657:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80165b:	c7 44 24 08 90 2d 80 	movl   $0x802d90,0x8(%esp)
  801662:	00 
  801663:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80166a:	00 
  80166b:	c7 04 24 9e 2d 80 00 	movl   $0x802d9e,(%esp)
  801672:	e8 b5 0e 00 00       	call   80252c <_panic>
		}
			sys_yield();
  801677:	e8 4d f9 ff ff       	call   800fc9 <sys_yield>
		
	}while(r!=0);
  80167c:	85 db                	test   %ebx,%ebx
  80167e:	75 86                	jne    801606 <ipc_send+0x26>
  801680:	eb 0a                	jmp    80168c <ipc_send+0xac>
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
		{	
			if(r!=-E_IPC_NOT_RECV)
				panic("send error:%e",r);
		}
			sys_yield();
  801682:	e8 42 f9 ff ff       	call   800fc9 <sys_yield>
  801687:	e9 7a ff ff ff       	jmp    801606 <ipc_send+0x26>
		
	}while(r!=0);
	return;
	//panic("ipc_send not implemented");
}
  80168c:	83 c4 1c             	add    $0x1c,%esp
  80168f:	5b                   	pop    %ebx
  801690:	5e                   	pop    %esi
  801691:	5f                   	pop    %edi
  801692:	5d                   	pop    %ebp
  801693:	c3                   	ret    

00801694 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801694:	55                   	push   %ebp
  801695:	89 e5                	mov    %esp,%ebp
  801697:	57                   	push   %edi
  801698:	56                   	push   %esi
  801699:	53                   	push   %ebx
  80169a:	83 ec 0c             	sub    $0xc,%esp
  80169d:	8b 75 08             	mov    0x8(%ebp),%esi
  8016a0:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	void *dstva=NULL;
	if(pg)
		dstva=pg;
	env = &envs[ENVX(sys_getenvid())];
  8016a3:	e8 55 f9 ff ff       	call   800ffd <sys_getenvid>
  8016a8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8016ad:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8016b0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8016b5:	a3 3c 60 80 00       	mov    %eax,0x80603c
	if(from_env_store&&(env->env_id==*from_env_store))
  8016ba:	85 f6                	test   %esi,%esi
  8016bc:	74 29                	je     8016e7 <ipc_recv+0x53>
  8016be:	8b 40 4c             	mov    0x4c(%eax),%eax
  8016c1:	3b 06                	cmp    (%esi),%eax
  8016c3:	75 22                	jne    8016e7 <ipc_recv+0x53>
	{
		*from_env_store=0;
  8016c5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  8016cb:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("send:the reciver is sender\n");
  8016d1:	c7 04 24 74 2d 80 00 	movl   $0x802d74,(%esp)
  8016d8:	e8 f4 ea ff ff       	call   8001d1 <cprintf>
  8016dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016e2:	e9 8a 00 00 00       	jmp    801771 <ipc_recv+0xdd>
		return 0;
	}
	env = &envs[ENVX(sys_getenvid())];
  8016e7:	e8 11 f9 ff ff       	call   800ffd <sys_getenvid>
  8016ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8016f1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8016f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8016f9:	a3 3c 60 80 00       	mov    %eax,0x80603c
	if((r=sys_ipc_recv(dstva))<0)
  8016fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801701:	89 04 24             	mov    %eax,(%esp)
  801704:	e8 f6 f5 ff ff       	call   800cff <sys_ipc_recv>
  801709:	89 c3                	mov    %eax,%ebx
  80170b:	85 c0                	test   %eax,%eax
  80170d:	79 1a                	jns    801729 <ipc_recv+0x95>
	{
		*from_env_store=0;
  80170f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  801715:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("reciver failed\n");
  80171b:	c7 04 24 a8 2d 80 00 	movl   $0x802da8,(%esp)
  801722:	e8 aa ea ff ff       	call   8001d1 <cprintf>
  801727:	eb 48                	jmp    801771 <ipc_recv+0xdd>
		return r;
	}
	else{//接收成功
		env = &envs[ENVX(sys_getenvid())];
  801729:	e8 cf f8 ff ff       	call   800ffd <sys_getenvid>
  80172e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801733:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801736:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80173b:	a3 3c 60 80 00       	mov    %eax,0x80603c
		if(from_env_store)
  801740:	85 f6                	test   %esi,%esi
  801742:	74 05                	je     801749 <ipc_recv+0xb5>
			*from_env_store=env->env_ipc_from;	
  801744:	8b 40 74             	mov    0x74(%eax),%eax
  801747:	89 06                	mov    %eax,(%esi)
		if(perm_store)
  801749:	85 ff                	test   %edi,%edi
  80174b:	74 0a                	je     801757 <ipc_recv+0xc3>
			*perm_store=env->env_ipc_perm;
  80174d:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801752:	8b 40 78             	mov    0x78(%eax),%eax
  801755:	89 07                	mov    %eax,(%edi)
		env = &envs[ENVX(sys_getenvid())];
  801757:	e8 a1 f8 ff ff       	call   800ffd <sys_getenvid>
  80175c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801761:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801764:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801769:	a3 3c 60 80 00       	mov    %eax,0x80603c
		return env->env_ipc_value;
  80176e:	8b 58 70             	mov    0x70(%eax),%ebx
	}
	//panic("ipc_recv not implemented");
	return 0;
}
  801771:	89 d8                	mov    %ebx,%eax
  801773:	83 c4 0c             	add    $0xc,%esp
  801776:	5b                   	pop    %ebx
  801777:	5e                   	pop    %esi
  801778:	5f                   	pop    %edi
  801779:	5d                   	pop    %ebp
  80177a:	c3                   	ret    
  80177b:	00 00                	add    %al,(%eax)
  80177d:	00 00                	add    %al,(%eax)
	...

00801780 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	8b 45 08             	mov    0x8(%ebp),%eax
  801786:	05 00 00 00 30       	add    $0x30000000,%eax
  80178b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80178e:	5d                   	pop    %ebp
  80178f:	c3                   	ret    

00801790 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801796:	8b 45 08             	mov    0x8(%ebp),%eax
  801799:	89 04 24             	mov    %eax,(%esp)
  80179c:	e8 df ff ff ff       	call   801780 <fd2num>
  8017a1:	c1 e0 0c             	shl    $0xc,%eax
  8017a4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8017a9:	c9                   	leave  
  8017aa:	c3                   	ret    

008017ab <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	53                   	push   %ebx
  8017af:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8017b2:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  8017b7:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  8017b9:	89 d0                	mov    %edx,%eax
  8017bb:	c1 e8 16             	shr    $0x16,%eax
  8017be:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8017c5:	a8 01                	test   $0x1,%al
  8017c7:	74 10                	je     8017d9 <fd_alloc+0x2e>
  8017c9:	89 d0                	mov    %edx,%eax
  8017cb:	c1 e8 0c             	shr    $0xc,%eax
  8017ce:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017d5:	a8 01                	test   $0x1,%al
  8017d7:	75 09                	jne    8017e2 <fd_alloc+0x37>
			*fd_store = fd;
  8017d9:	89 0b                	mov    %ecx,(%ebx)
  8017db:	b8 00 00 00 00       	mov    $0x0,%eax
  8017e0:	eb 19                	jmp    8017fb <fd_alloc+0x50>
			return 0;
  8017e2:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8017e8:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  8017ee:	75 c7                	jne    8017b7 <fd_alloc+0xc>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8017f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8017f6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8017fb:	5b                   	pop    %ebx
  8017fc:	5d                   	pop    %ebp
  8017fd:	c3                   	ret    

008017fe <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8017fe:	55                   	push   %ebp
  8017ff:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801801:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  801805:	77 38                	ja     80183f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801807:	8b 45 08             	mov    0x8(%ebp),%eax
  80180a:	c1 e0 0c             	shl    $0xc,%eax
  80180d:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  801813:	89 d0                	mov    %edx,%eax
  801815:	c1 e8 16             	shr    $0x16,%eax
  801818:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80181f:	a8 01                	test   $0x1,%al
  801821:	74 1c                	je     80183f <fd_lookup+0x41>
  801823:	89 d0                	mov    %edx,%eax
  801825:	c1 e8 0c             	shr    $0xc,%eax
  801828:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80182f:	a8 01                	test   $0x1,%al
  801831:	74 0c                	je     80183f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801833:	8b 45 0c             	mov    0xc(%ebp),%eax
  801836:	89 10                	mov    %edx,(%eax)
  801838:	b8 00 00 00 00       	mov    $0x0,%eax
  80183d:	eb 05                	jmp    801844 <fd_lookup+0x46>
	return 0;
  80183f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801844:	5d                   	pop    %ebp
  801845:	c3                   	ret    

00801846 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80184c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80184f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801853:	8b 45 08             	mov    0x8(%ebp),%eax
  801856:	89 04 24             	mov    %eax,(%esp)
  801859:	e8 a0 ff ff ff       	call   8017fe <fd_lookup>
  80185e:	85 c0                	test   %eax,%eax
  801860:	78 0e                	js     801870 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801862:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801865:	8b 55 0c             	mov    0xc(%ebp),%edx
  801868:	89 50 04             	mov    %edx,0x4(%eax)
  80186b:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801870:	c9                   	leave  
  801871:	c3                   	ret    

00801872 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	53                   	push   %ebx
  801876:	83 ec 14             	sub    $0x14,%esp
  801879:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80187c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80187f:	ba 04 60 80 00       	mov    $0x806004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801884:	b8 00 00 00 00       	mov    $0x0,%eax
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801889:	39 0d 04 60 80 00    	cmp    %ecx,0x806004
  80188f:	75 11                	jne    8018a2 <dev_lookup+0x30>
  801891:	eb 04                	jmp    801897 <dev_lookup+0x25>
  801893:	39 0a                	cmp    %ecx,(%edx)
  801895:	75 0b                	jne    8018a2 <dev_lookup+0x30>
			*dev = devtab[i];
  801897:	89 13                	mov    %edx,(%ebx)
  801899:	b8 00 00 00 00       	mov    $0x0,%eax
  80189e:	66 90                	xchg   %ax,%ax
  8018a0:	eb 35                	jmp    8018d7 <dev_lookup+0x65>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8018a2:	83 c0 01             	add    $0x1,%eax
  8018a5:	8b 14 85 34 2e 80 00 	mov    0x802e34(,%eax,4),%edx
  8018ac:	85 d2                	test   %edx,%edx
  8018ae:	75 e3                	jne    801893 <dev_lookup+0x21>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  8018b0:	a1 3c 60 80 00       	mov    0x80603c,%eax
  8018b5:	8b 40 4c             	mov    0x4c(%eax),%eax
  8018b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c0:	c7 04 24 b8 2d 80 00 	movl   $0x802db8,(%esp)
  8018c7:	e8 05 e9 ff ff       	call   8001d1 <cprintf>
	*dev = 0;
  8018cc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8018d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8018d7:	83 c4 14             	add    $0x14,%esp
  8018da:	5b                   	pop    %ebx
  8018db:	5d                   	pop    %ebp
  8018dc:	c3                   	ret    

008018dd <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8018dd:	55                   	push   %ebp
  8018de:	89 e5                	mov    %esp,%ebp
  8018e0:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018e3:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8018e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ed:	89 04 24             	mov    %eax,(%esp)
  8018f0:	e8 09 ff ff ff       	call   8017fe <fd_lookup>
  8018f5:	89 c2                	mov    %eax,%edx
  8018f7:	85 c0                	test   %eax,%eax
  8018f9:	78 5a                	js     801955 <fstat+0x78>
  8018fb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801902:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801905:	8b 00                	mov    (%eax),%eax
  801907:	89 04 24             	mov    %eax,(%esp)
  80190a:	e8 63 ff ff ff       	call   801872 <dev_lookup>
  80190f:	89 c2                	mov    %eax,%edx
  801911:	85 c0                	test   %eax,%eax
  801913:	78 40                	js     801955 <fstat+0x78>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801915:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  80191a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80191d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801921:	74 32                	je     801955 <fstat+0x78>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801923:	8b 45 0c             	mov    0xc(%ebp),%eax
  801926:	c6 00 00             	movb   $0x0,(%eax)
	stat->st_size = 0;
  801929:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  801930:	00 00 00 
	stat->st_isdir = 0;
  801933:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
  80193a:	00 00 00 
	stat->st_dev = dev;
  80193d:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801940:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
	return (*dev->dev_stat)(fd, stat);
  801946:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80194d:	89 04 24             	mov    %eax,(%esp)
  801950:	ff 52 14             	call   *0x14(%edx)
  801953:	89 c2                	mov    %eax,%edx
}
  801955:	89 d0                	mov    %edx,%eax
  801957:	c9                   	leave  
  801958:	c3                   	ret    

00801959 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801959:	55                   	push   %ebp
  80195a:	89 e5                	mov    %esp,%ebp
  80195c:	53                   	push   %ebx
  80195d:	83 ec 24             	sub    $0x24,%esp
  801960:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801963:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801966:	89 44 24 04          	mov    %eax,0x4(%esp)
  80196a:	89 1c 24             	mov    %ebx,(%esp)
  80196d:	e8 8c fe ff ff       	call   8017fe <fd_lookup>
  801972:	85 c0                	test   %eax,%eax
  801974:	78 61                	js     8019d7 <ftruncate+0x7e>
  801976:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801979:	8b 10                	mov    (%eax),%edx
  80197b:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80197e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801982:	89 14 24             	mov    %edx,(%esp)
  801985:	e8 e8 fe ff ff       	call   801872 <dev_lookup>
  80198a:	85 c0                	test   %eax,%eax
  80198c:	78 49                	js     8019d7 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80198e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801991:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801995:	75 23                	jne    8019ba <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801997:	a1 3c 60 80 00       	mov    0x80603c,%eax
  80199c:	8b 40 4c             	mov    0x4c(%eax),%eax
  80199f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a7:	c7 04 24 d8 2d 80 00 	movl   $0x802dd8,(%esp)
  8019ae:	e8 1e e8 ff ff       	call   8001d1 <cprintf>
  8019b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019b8:	eb 1d                	jmp    8019d7 <ftruncate+0x7e>
			env->env_id, fdnum); 
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8019ba:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8019bd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019c2:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  8019c6:	74 0f                	je     8019d7 <ftruncate+0x7e>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019c8:	8b 42 18             	mov    0x18(%edx),%eax
  8019cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8019d2:	89 0c 24             	mov    %ecx,(%esp)
  8019d5:	ff d0                	call   *%eax
}
  8019d7:	83 c4 24             	add    $0x24,%esp
  8019da:	5b                   	pop    %ebx
  8019db:	5d                   	pop    %ebp
  8019dc:	c3                   	ret    

008019dd <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8019dd:	55                   	push   %ebp
  8019de:	89 e5                	mov    %esp,%ebp
  8019e0:	53                   	push   %ebx
  8019e1:	83 ec 24             	sub    $0x24,%esp
  8019e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ee:	89 1c 24             	mov    %ebx,(%esp)
  8019f1:	e8 08 fe ff ff       	call   8017fe <fd_lookup>
  8019f6:	85 c0                	test   %eax,%eax
  8019f8:	78 68                	js     801a62 <write+0x85>
  8019fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019fd:	8b 10                	mov    (%eax),%edx
  8019ff:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801a02:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a06:	89 14 24             	mov    %edx,(%esp)
  801a09:	e8 64 fe ff ff       	call   801872 <dev_lookup>
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	78 50                	js     801a62 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a12:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801a15:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801a19:	75 23                	jne    801a3e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  801a1b:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801a20:	8b 40 4c             	mov    0x4c(%eax),%eax
  801a23:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a27:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a2b:	c7 04 24 f9 2d 80 00 	movl   $0x802df9,(%esp)
  801a32:	e8 9a e7 ff ff       	call   8001d1 <cprintf>
  801a37:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a3c:	eb 24                	jmp    801a62 <write+0x85>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801a3e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801a41:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a46:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  801a4a:	74 16                	je     801a62 <write+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801a4c:	8b 42 0c             	mov    0xc(%edx),%eax
  801a4f:	8b 55 10             	mov    0x10(%ebp),%edx
  801a52:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a56:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a59:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a5d:	89 0c 24             	mov    %ecx,(%esp)
  801a60:	ff d0                	call   *%eax
}
  801a62:	83 c4 24             	add    $0x24,%esp
  801a65:	5b                   	pop    %ebx
  801a66:	5d                   	pop    %ebp
  801a67:	c3                   	ret    

00801a68 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801a68:	55                   	push   %ebp
  801a69:	89 e5                	mov    %esp,%ebp
  801a6b:	53                   	push   %ebx
  801a6c:	83 ec 24             	sub    $0x24,%esp
  801a6f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a75:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a79:	89 1c 24             	mov    %ebx,(%esp)
  801a7c:	e8 7d fd ff ff       	call   8017fe <fd_lookup>
  801a81:	85 c0                	test   %eax,%eax
  801a83:	78 6d                	js     801af2 <read+0x8a>
  801a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a88:	8b 10                	mov    (%eax),%edx
  801a8a:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801a8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a91:	89 14 24             	mov    %edx,(%esp)
  801a94:	e8 d9 fd ff ff       	call   801872 <dev_lookup>
  801a99:	85 c0                	test   %eax,%eax
  801a9b:	78 55                	js     801af2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801a9d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801aa0:	8b 41 08             	mov    0x8(%ecx),%eax
  801aa3:	83 e0 03             	and    $0x3,%eax
  801aa6:	83 f8 01             	cmp    $0x1,%eax
  801aa9:	75 23                	jne    801ace <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  801aab:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801ab0:	8b 40 4c             	mov    0x4c(%eax),%eax
  801ab3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801abb:	c7 04 24 16 2e 80 00 	movl   $0x802e16,(%esp)
  801ac2:	e8 0a e7 ff ff       	call   8001d1 <cprintf>
  801ac7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801acc:	eb 24                	jmp    801af2 <read+0x8a>
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801ace:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801ad1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801ad6:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  801ada:	74 16                	je     801af2 <read+0x8a>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801adc:	8b 42 08             	mov    0x8(%edx),%eax
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

00801af8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801af8:	55                   	push   %ebp
  801af9:	89 e5                	mov    %esp,%ebp
  801afb:	57                   	push   %edi
  801afc:	56                   	push   %esi
  801afd:	53                   	push   %ebx
  801afe:	83 ec 0c             	sub    $0xc,%esp
  801b01:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801b04:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801b07:	b8 00 00 00 00       	mov    $0x0,%eax
  801b0c:	85 f6                	test   %esi,%esi
  801b0e:	74 36                	je     801b46 <readn+0x4e>
  801b10:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b15:	ba 00 00 00 00       	mov    $0x0,%edx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801b1a:	89 f0                	mov    %esi,%eax
  801b1c:	29 d0                	sub    %edx,%eax
  801b1e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b22:	8d 04 17             	lea    (%edi,%edx,1),%eax
  801b25:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b29:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2c:	89 04 24             	mov    %eax,(%esp)
  801b2f:	e8 34 ff ff ff       	call   801a68 <read>
		if (m < 0)
  801b34:	85 c0                	test   %eax,%eax
  801b36:	78 0e                	js     801b46 <readn+0x4e>
			return m;
		if (m == 0)
  801b38:	85 c0                	test   %eax,%eax
  801b3a:	74 08                	je     801b44 <readn+0x4c>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801b3c:	01 c3                	add    %eax,%ebx
  801b3e:	89 da                	mov    %ebx,%edx
  801b40:	39 f3                	cmp    %esi,%ebx
  801b42:	72 d6                	jb     801b1a <readn+0x22>
  801b44:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801b46:	83 c4 0c             	add    $0xc,%esp
  801b49:	5b                   	pop    %ebx
  801b4a:	5e                   	pop    %esi
  801b4b:	5f                   	pop    %edi
  801b4c:	5d                   	pop    %ebp
  801b4d:	c3                   	ret    

00801b4e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801b4e:	55                   	push   %ebp
  801b4f:	89 e5                	mov    %esp,%ebp
  801b51:	83 ec 28             	sub    $0x28,%esp
  801b54:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b57:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801b5a:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801b5d:	89 34 24             	mov    %esi,(%esp)
  801b60:	e8 1b fc ff ff       	call   801780 <fd2num>
  801b65:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b68:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b6c:	89 04 24             	mov    %eax,(%esp)
  801b6f:	e8 8a fc ff ff       	call   8017fe <fd_lookup>
  801b74:	89 c3                	mov    %eax,%ebx
  801b76:	85 c0                	test   %eax,%eax
  801b78:	78 05                	js     801b7f <fd_close+0x31>
  801b7a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801b7d:	74 0d                	je     801b8c <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801b7f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b83:	75 44                	jne    801bc9 <fd_close+0x7b>
  801b85:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b8a:	eb 3d                	jmp    801bc9 <fd_close+0x7b>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801b8c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b93:	8b 06                	mov    (%esi),%eax
  801b95:	89 04 24             	mov    %eax,(%esp)
  801b98:	e8 d5 fc ff ff       	call   801872 <dev_lookup>
  801b9d:	89 c3                	mov    %eax,%ebx
  801b9f:	85 c0                	test   %eax,%eax
  801ba1:	78 16                	js     801bb9 <fd_close+0x6b>
		if (dev->dev_close)
  801ba3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ba6:	8b 40 10             	mov    0x10(%eax),%eax
  801ba9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	74 07                	je     801bb9 <fd_close+0x6b>
			r = (*dev->dev_close)(fd);
  801bb2:	89 34 24             	mov    %esi,(%esp)
  801bb5:	ff d0                	call   *%eax
  801bb7:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801bb9:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bbd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bc4:	e8 e5 f2 ff ff       	call   800eae <sys_page_unmap>
	return r;
}
  801bc9:	89 d8                	mov    %ebx,%eax
  801bcb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801bce:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801bd1:	89 ec                	mov    %ebp,%esp
  801bd3:	5d                   	pop    %ebp
  801bd4:	c3                   	ret    

00801bd5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801bd5:	55                   	push   %ebp
  801bd6:	89 e5                	mov    %esp,%ebp
  801bd8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bdb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801bde:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be2:	8b 45 08             	mov    0x8(%ebp),%eax
  801be5:	89 04 24             	mov    %eax,(%esp)
  801be8:	e8 11 fc ff ff       	call   8017fe <fd_lookup>
  801bed:	85 c0                	test   %eax,%eax
  801bef:	78 13                	js     801c04 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801bf1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801bf8:	00 
  801bf9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801bfc:	89 04 24             	mov    %eax,(%esp)
  801bff:	e8 4a ff ff ff       	call   801b4e <fd_close>
}
  801c04:	c9                   	leave  
  801c05:	c3                   	ret    

00801c06 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801c06:	55                   	push   %ebp
  801c07:	89 e5                	mov    %esp,%ebp
  801c09:	83 ec 18             	sub    $0x18,%esp
  801c0c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801c0f:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801c12:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c19:	00 
  801c1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1d:	89 04 24             	mov    %eax,(%esp)
  801c20:	e8 5a 03 00 00       	call   801f7f <open>
  801c25:	89 c6                	mov    %eax,%esi
  801c27:	85 c0                	test   %eax,%eax
  801c29:	78 1b                	js     801c46 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801c2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c32:	89 34 24             	mov    %esi,(%esp)
  801c35:	e8 a3 fc ff ff       	call   8018dd <fstat>
  801c3a:	89 c3                	mov    %eax,%ebx
	close(fd);
  801c3c:	89 34 24             	mov    %esi,(%esp)
  801c3f:	e8 91 ff ff ff       	call   801bd5 <close>
  801c44:	89 de                	mov    %ebx,%esi
	return r;
}
  801c46:	89 f0                	mov    %esi,%eax
  801c48:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801c4b:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801c4e:	89 ec                	mov    %ebp,%esp
  801c50:	5d                   	pop    %ebp
  801c51:	c3                   	ret    

00801c52 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	83 ec 38             	sub    $0x38,%esp
  801c58:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801c5b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801c5e:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801c61:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801c64:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c67:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6e:	89 04 24             	mov    %eax,(%esp)
  801c71:	e8 88 fb ff ff       	call   8017fe <fd_lookup>
  801c76:	89 c3                	mov    %eax,%ebx
  801c78:	85 c0                	test   %eax,%eax
  801c7a:	0f 88 e1 00 00 00    	js     801d61 <dup+0x10f>
		return r;
	close(newfdnum);
  801c80:	89 3c 24             	mov    %edi,(%esp)
  801c83:	e8 4d ff ff ff       	call   801bd5 <close>

	newfd = INDEX2FD(newfdnum);
  801c88:	89 f8                	mov    %edi,%eax
  801c8a:	c1 e0 0c             	shl    $0xc,%eax
  801c8d:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  801c93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c96:	89 04 24             	mov    %eax,(%esp)
  801c99:	e8 f2 fa ff ff       	call   801790 <fd2data>
  801c9e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801ca0:	89 34 24             	mov    %esi,(%esp)
  801ca3:	e8 e8 fa ff ff       	call   801790 <fd2data>
  801ca8:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  801cab:	89 d8                	mov    %ebx,%eax
  801cad:	c1 e8 16             	shr    $0x16,%eax
  801cb0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801cb7:	a8 01                	test   $0x1,%al
  801cb9:	74 45                	je     801d00 <dup+0xae>
  801cbb:	89 da                	mov    %ebx,%edx
  801cbd:	c1 ea 0c             	shr    $0xc,%edx
  801cc0:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801cc7:	a8 01                	test   $0x1,%al
  801cc9:	74 35                	je     801d00 <dup+0xae>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  801ccb:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801cd2:	25 07 0e 00 00       	and    $0xe07,%eax
  801cd7:	89 44 24 10          	mov    %eax,0x10(%esp)
  801cdb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cde:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ce2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ce9:	00 
  801cea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cf5:	e8 12 f2 ff ff       	call   800f0c <sys_page_map>
  801cfa:	89 c3                	mov    %eax,%ebx
  801cfc:	85 c0                	test   %eax,%eax
  801cfe:	78 3e                	js     801d3e <dup+0xec>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  801d00:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d03:	89 d0                	mov    %edx,%eax
  801d05:	c1 e8 0c             	shr    $0xc,%eax
  801d08:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d0f:	25 07 0e 00 00       	and    $0xe07,%eax
  801d14:	89 44 24 10          	mov    %eax,0x10(%esp)
  801d18:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801d1c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d23:	00 
  801d24:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d28:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d2f:	e8 d8 f1 ff ff       	call   800f0c <sys_page_map>
  801d34:	89 c3                	mov    %eax,%ebx
  801d36:	85 c0                	test   %eax,%eax
  801d38:	78 04                	js     801d3e <dup+0xec>
		goto err;
  801d3a:	89 fb                	mov    %edi,%ebx
  801d3c:	eb 23                	jmp    801d61 <dup+0x10f>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801d3e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d42:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d49:	e8 60 f1 ff ff       	call   800eae <sys_page_unmap>
	sys_page_unmap(0, nva);
  801d4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d51:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d5c:	e8 4d f1 ff ff       	call   800eae <sys_page_unmap>
	return r;
}
  801d61:	89 d8                	mov    %ebx,%eax
  801d63:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801d66:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801d69:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801d6c:	89 ec                	mov    %ebp,%esp
  801d6e:	5d                   	pop    %ebp
  801d6f:	c3                   	ret    

00801d70 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801d70:	55                   	push   %ebp
  801d71:	89 e5                	mov    %esp,%ebp
  801d73:	53                   	push   %ebx
  801d74:	83 ec 04             	sub    $0x4,%esp
  801d77:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801d7c:	89 1c 24             	mov    %ebx,(%esp)
  801d7f:	e8 51 fe ff ff       	call   801bd5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801d84:	83 c3 01             	add    $0x1,%ebx
  801d87:	83 fb 20             	cmp    $0x20,%ebx
  801d8a:	75 f0                	jne    801d7c <close_all+0xc>
		close(i);
}
  801d8c:	83 c4 04             	add    $0x4,%esp
  801d8f:	5b                   	pop    %ebx
  801d90:	5d                   	pop    %ebp
  801d91:	c3                   	ret    
	...

00801d94 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801d94:	55                   	push   %ebp
  801d95:	89 e5                	mov    %esp,%ebp
  801d97:	53                   	push   %ebx
  801d98:	83 ec 14             	sub    $0x14,%esp
  801d9b:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801d9d:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  801da3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801daa:	00 
  801dab:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801db2:	00 
  801db3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801db7:	89 14 24             	mov    %edx,(%esp)
  801dba:	e8 21 f8 ff ff       	call   8015e0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801dbf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801dc6:	00 
  801dc7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dcb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dd2:	e8 bd f8 ff ff       	call   801694 <ipc_recv>
}
  801dd7:	83 c4 14             	add    $0x14,%esp
  801dda:	5b                   	pop    %ebx
  801ddb:	5d                   	pop    %ebp
  801ddc:	c3                   	ret    

00801ddd <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801ddd:	55                   	push   %ebp
  801dde:	89 e5                	mov    %esp,%ebp
  801de0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801de3:	ba 00 00 00 00       	mov    $0x0,%edx
  801de8:	b8 08 00 00 00       	mov    $0x8,%eax
  801ded:	e8 a2 ff ff ff       	call   801d94 <fsipc>
}
  801df2:	c9                   	leave  
  801df3:	c3                   	ret    

00801df4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801df4:	55                   	push   %ebp
  801df5:	89 e5                	mov    %esp,%ebp
  801df7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801dfa:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfd:	8b 40 0c             	mov    0xc(%eax),%eax
  801e00:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.set_size.req_size = newsize;
  801e05:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e08:	a3 04 30 80 00       	mov    %eax,0x803004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801e0d:	ba 00 00 00 00       	mov    $0x0,%edx
  801e12:	b8 02 00 00 00       	mov    $0x2,%eax
  801e17:	e8 78 ff ff ff       	call   801d94 <fsipc>
}
  801e1c:	c9                   	leave  
  801e1d:	c3                   	ret    

00801e1e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801e1e:	55                   	push   %ebp
  801e1f:	89 e5                	mov    %esp,%ebp
  801e21:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801e24:	8b 45 08             	mov    0x8(%ebp),%eax
  801e27:	8b 40 0c             	mov    0xc(%eax),%eax
  801e2a:	a3 00 30 80 00       	mov    %eax,0x803000
	return fsipc(FSREQ_FLUSH, NULL);
  801e2f:	ba 00 00 00 00       	mov    $0x0,%edx
  801e34:	b8 06 00 00 00       	mov    $0x6,%eax
  801e39:	e8 56 ff ff ff       	call   801d94 <fsipc>
}
  801e3e:	c9                   	leave  
  801e3f:	c3                   	ret    

00801e40 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801e40:	55                   	push   %ebp
  801e41:	89 e5                	mov    %esp,%ebp
  801e43:	53                   	push   %ebx
  801e44:	83 ec 14             	sub    $0x14,%esp
  801e47:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801e4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4d:	8b 40 0c             	mov    0xc(%eax),%eax
  801e50:	a3 00 30 80 00       	mov    %eax,0x803000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801e55:	ba 00 00 00 00       	mov    $0x0,%edx
  801e5a:	b8 05 00 00 00       	mov    $0x5,%eax
  801e5f:	e8 30 ff ff ff       	call   801d94 <fsipc>
  801e64:	85 c0                	test   %eax,%eax
  801e66:	78 2b                	js     801e93 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801e68:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801e6f:	00 
  801e70:	89 1c 24             	mov    %ebx,(%esp)
  801e73:	e8 b9 e9 ff ff       	call   800831 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801e78:	a1 80 30 80 00       	mov    0x803080,%eax
  801e7d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801e83:	a1 84 30 80 00       	mov    0x803084,%eax
  801e88:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801e8e:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801e93:	83 c4 14             	add    $0x14,%esp
  801e96:	5b                   	pop    %ebx
  801e97:	5d                   	pop    %ebp
  801e98:	c3                   	ret    

00801e99 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801e99:	55                   	push   %ebp
  801e9a:	89 e5                	mov    %esp,%ebp
  801e9c:	83 ec 18             	sub    $0x18,%esp
  801e9f:	8b 55 10             	mov    0x10(%ebp),%edx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	ssize_t writesize;
	size_t bufsize;
	fsipcbuf.write.req_fileid=fd->fd_file.id;
  801ea2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea5:	8b 40 0c             	mov    0xc(%eax),%eax
  801ea8:	a3 00 30 80 00       	mov    %eax,0x803000
	bufsize=sizeof(fsipcbuf.write.req_buf);
	if(n<bufsize)
  801ead:	89 d0                	mov    %edx,%eax
  801eaf:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  801eb5:	76 05                	jbe    801ebc <devfile_write+0x23>
  801eb7:	b8 f8 0f 00 00       	mov    $0xff8,%eax
		bufsize=n;	
	fsipcbuf.write.req_n=n;
  801ebc:	89 15 04 30 80 00    	mov    %edx,0x803004
	memmove((void*)fsipcbuf.write.req_buf,buf,bufsize);
  801ec2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ec6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ecd:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  801ed4:	e8 5f eb ff ff       	call   800a38 <memmove>
	writesize=(ssize_t)fsipc(FSREQ_WRITE,NULL);
  801ed9:	ba 00 00 00 00       	mov    $0x0,%edx
  801ede:	b8 04 00 00 00       	mov    $0x4,%eax
  801ee3:	e8 ac fe ff ff       	call   801d94 <fsipc>
	return writesize;
	//panic("devfile_write not implemented");
}
  801ee8:	c9                   	leave  
  801ee9:	c3                   	ret    

00801eea <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801eea:	55                   	push   %ebp
  801eeb:	89 e5                	mov    %esp,%ebp
  801eed:	53                   	push   %ebx
  801eee:	83 ec 14             	sub    $0x14,%esp
	// system server.
	// LAB 5: Your code here
	ssize_t readsize;
	if(debug)
		cprintf("devfile_read:fileid=%x readsize=%x\n",fd->fd_file.id,n);
	fsipcbuf.read.req_fileid=fd->fd_file.id;
  801ef1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef4:	8b 40 0c             	mov    0xc(%eax),%eax
  801ef7:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.read.req_n=n;
  801efc:	8b 45 10             	mov    0x10(%ebp),%eax
  801eff:	a3 04 30 80 00       	mov    %eax,0x803004
	readsize=(ssize_t)fsipc(FSREQ_READ,&fsipcbuf);
  801f04:	ba 00 30 80 00       	mov    $0x803000,%edx
  801f09:	b8 03 00 00 00       	mov    $0x3,%eax
  801f0e:	e8 81 fe ff ff       	call   801d94 <fsipc>
  801f13:	89 c3                	mov    %eax,%ebx
	//cprintf("readsize=%d\n",readsize);
	if(debug)
		cprintf("devfile_read:buf1=%s\nbuf2=%s\n",(char*)&fsipcbuf,fsipcbuf.readRet.ret_buf);
	if(readsize>0)
  801f15:	85 c0                	test   %eax,%eax
  801f17:	7e 17                	jle    801f30 <devfile_read+0x46>
		memmove(buf,(void*)&fsipcbuf,(size_t)readsize);
  801f19:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f1d:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801f24:	00 
  801f25:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f28:	89 04 24             	mov    %eax,(%esp)
  801f2b:	e8 08 eb ff ff       	call   800a38 <memmove>
	//cprintf("readsize=%d",readsize);
	return readsize;
	//panic("devfile_read not implemented");
}
  801f30:	89 d8                	mov    %ebx,%eax
  801f32:	83 c4 14             	add    $0x14,%esp
  801f35:	5b                   	pop    %ebx
  801f36:	5d                   	pop    %ebp
  801f37:	c3                   	ret    

00801f38 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801f38:	55                   	push   %ebp
  801f39:	89 e5                	mov    %esp,%ebp
  801f3b:	53                   	push   %ebx
  801f3c:	83 ec 14             	sub    $0x14,%esp
  801f3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801f42:	89 1c 24             	mov    %ebx,(%esp)
  801f45:	e8 96 e8 ff ff       	call   8007e0 <strlen>
  801f4a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  801f4f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801f54:	7f 21                	jg     801f77 <remove+0x3f>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801f56:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f5a:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801f61:	e8 cb e8 ff ff       	call   800831 <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801f66:	ba 00 00 00 00       	mov    $0x0,%edx
  801f6b:	b8 07 00 00 00       	mov    $0x7,%eax
  801f70:	e8 1f fe ff ff       	call   801d94 <fsipc>
  801f75:	89 c2                	mov    %eax,%edx
}
  801f77:	89 d0                	mov    %edx,%eax
  801f79:	83 c4 14             	add    $0x14,%esp
  801f7c:	5b                   	pop    %ebx
  801f7d:	5d                   	pop    %ebp
  801f7e:	c3                   	ret    

00801f7f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801f7f:	55                   	push   %ebp
  801f80:	89 e5                	mov    %esp,%ebp
  801f82:	56                   	push   %esi
  801f83:	53                   	push   %ebx
  801f84:	83 ec 30             	sub    $0x30,%esp

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;
	void *page;
	if((r=fd_alloc(&fd))<0){
  801f87:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f8a:	89 04 24             	mov    %eax,(%esp)
  801f8d:	e8 19 f8 ff ff       	call   8017ab <fd_alloc>
  801f92:	89 c3                	mov    %eax,%ebx
  801f94:	85 c0                	test   %eax,%eax
  801f96:	79 18                	jns    801fb0 <open+0x31>
		fd_close(fd,0);
  801f98:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f9f:	00 
  801fa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa3:	89 04 24             	mov    %eax,(%esp)
  801fa6:	e8 a3 fb ff ff       	call   801b4e <fd_close>
  801fab:	e9 9f 00 00 00       	jmp    80204f <open+0xd0>
		return r;
	}
	//cprintf("open:fd=%x\n",fd);
	strcpy(fsipcbuf.open.req_path,path);
  801fb0:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fb7:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801fbe:	e8 6e e8 ff ff       	call   800831 <strcpy>
	fsipcbuf.open.req_omode=mode;
  801fc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc6:	a3 00 34 80 00       	mov    %eax,0x803400
	page=(void*)fd2data(fd);
  801fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fce:	89 04 24             	mov    %eax,(%esp)
  801fd1:	e8 ba f7 ff ff       	call   801790 <fd2data>
  801fd6:	89 c6                	mov    %eax,%esi
	if((r=fsipc(FSREQ_OPEN,(void*)fd))<0)
  801fd8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fdb:	b8 01 00 00 00       	mov    $0x1,%eax
  801fe0:	e8 af fd ff ff       	call   801d94 <fsipc>
  801fe5:	89 c3                	mov    %eax,%ebx
  801fe7:	85 c0                	test   %eax,%eax
  801fe9:	79 15                	jns    802000 <open+0x81>
	{
		fd_close(fd,1);
  801feb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ff2:	00 
  801ff3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff6:	89 04 24             	mov    %eax,(%esp)
  801ff9:	e8 50 fb ff ff       	call   801b4e <fd_close>
  801ffe:	eb 4f                	jmp    80204f <open+0xd0>
		return r;	
	}
	//cprintf("open:page=%x\n",page);
	if((r=sys_page_map(0,(void*)fd,0,(void*)page,PTE_P | PTE_W | PTE_U))<0)
  802000:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  802007:	00 
  802008:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80200c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802013:	00 
  802014:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802017:	89 44 24 04          	mov    %eax,0x4(%esp)
  80201b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802022:	e8 e5 ee ff ff       	call   800f0c <sys_page_map>
  802027:	89 c3                	mov    %eax,%ebx
  802029:	85 c0                	test   %eax,%eax
  80202b:	79 15                	jns    802042 <open+0xc3>
	{
		fd_close(fd,1);
  80202d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802034:	00 
  802035:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802038:	89 04 24             	mov    %eax,(%esp)
  80203b:	e8 0e fb ff ff       	call   801b4e <fd_close>
  802040:	eb 0d                	jmp    80204f <open+0xd0>
		return r;
	}
	//cprintf("open:fileid=%x\n",fd->fd_file.id);
	return fd2num(fd);
  802042:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802045:	89 04 24             	mov    %eax,(%esp)
  802048:	e8 33 f7 ff ff       	call   801780 <fd2num>
  80204d:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  80204f:	89 d8                	mov    %ebx,%eax
  802051:	83 c4 30             	add    $0x30,%esp
  802054:	5b                   	pop    %ebx
  802055:	5e                   	pop    %esi
  802056:	5d                   	pop    %ebp
  802057:	c3                   	ret    
	...

00802060 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802060:	55                   	push   %ebp
  802061:	89 e5                	mov    %esp,%ebp
  802063:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  802066:	c7 44 24 04 40 2e 80 	movl   $0x802e40,0x4(%esp)
  80206d:	00 
  80206e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802071:	89 04 24             	mov    %eax,(%esp)
  802074:	e8 b8 e7 ff ff       	call   800831 <strcpy>
	return 0;
}
  802079:	b8 00 00 00 00       	mov    $0x0,%eax
  80207e:	c9                   	leave  
  80207f:	c3                   	ret    

00802080 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802080:	55                   	push   %ebp
  802081:	89 e5                	mov    %esp,%ebp
  802083:	83 ec 08             	sub    $0x8,%esp
	return nsipc_close(fd->fd_sock.sockid);
  802086:	8b 45 08             	mov    0x8(%ebp),%eax
  802089:	8b 40 0c             	mov    0xc(%eax),%eax
  80208c:	89 04 24             	mov    %eax,(%esp)
  80208f:	e8 9e 02 00 00       	call   802332 <nsipc_close>
}
  802094:	c9                   	leave  
  802095:	c3                   	ret    

00802096 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802096:	55                   	push   %ebp
  802097:	89 e5                	mov    %esp,%ebp
  802099:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80209c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8020a3:	00 
  8020a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8020a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8020b8:	89 04 24             	mov    %eax,(%esp)
  8020bb:	e8 ae 02 00 00       	call   80236e <nsipc_send>
}
  8020c0:	c9                   	leave  
  8020c1:	c3                   	ret    

008020c2 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8020c2:	55                   	push   %ebp
  8020c3:	89 e5                	mov    %esp,%ebp
  8020c5:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8020c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8020cf:	00 
  8020d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8020d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020de:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8020e4:	89 04 24             	mov    %eax,(%esp)
  8020e7:	e8 f5 02 00 00       	call   8023e1 <nsipc_recv>
}
  8020ec:	c9                   	leave  
  8020ed:	c3                   	ret    

008020ee <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  8020ee:	55                   	push   %ebp
  8020ef:	89 e5                	mov    %esp,%ebp
  8020f1:	56                   	push   %esi
  8020f2:	53                   	push   %ebx
  8020f3:	83 ec 20             	sub    $0x20,%esp
  8020f6:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8020f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020fb:	89 04 24             	mov    %eax,(%esp)
  8020fe:	e8 a8 f6 ff ff       	call   8017ab <fd_alloc>
  802103:	89 c3                	mov    %eax,%ebx
  802105:	85 c0                	test   %eax,%eax
  802107:	78 21                	js     80212a <alloc_sockfd+0x3c>
  802109:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802110:	00 
  802111:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802114:	89 44 24 04          	mov    %eax,0x4(%esp)
  802118:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80211f:	e8 46 ee ff ff       	call   800f6a <sys_page_alloc>
  802124:	89 c3                	mov    %eax,%ebx
  802126:	85 c0                	test   %eax,%eax
  802128:	79 0a                	jns    802134 <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U)) < 0) {
		nsipc_close(sockid);
  80212a:	89 34 24             	mov    %esi,(%esp)
  80212d:	e8 00 02 00 00       	call   802332 <nsipc_close>
  802132:	eb 28                	jmp    80215c <alloc_sockfd+0x6e>
		return r;
	}

	sfd->fd_dev_id = devsock.dev_id;
  802134:	8b 15 20 60 80 00    	mov    0x806020,%edx
  80213a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213d:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80213f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802142:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802149:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80214c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80214f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802152:	89 04 24             	mov    %eax,(%esp)
  802155:	e8 26 f6 ff ff       	call   801780 <fd2num>
  80215a:	89 c3                	mov    %eax,%ebx
}
  80215c:	89 d8                	mov    %ebx,%eax
  80215e:	83 c4 20             	add    $0x20,%esp
  802161:	5b                   	pop    %ebx
  802162:	5e                   	pop    %esi
  802163:	5d                   	pop    %ebp
  802164:	c3                   	ret    

00802165 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802165:	55                   	push   %ebp
  802166:	89 e5                	mov    %esp,%ebp
  802168:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80216b:	8b 45 10             	mov    0x10(%ebp),%eax
  80216e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802172:	8b 45 0c             	mov    0xc(%ebp),%eax
  802175:	89 44 24 04          	mov    %eax,0x4(%esp)
  802179:	8b 45 08             	mov    0x8(%ebp),%eax
  80217c:	89 04 24             	mov    %eax,(%esp)
  80217f:	e8 62 01 00 00       	call   8022e6 <nsipc_socket>
  802184:	85 c0                	test   %eax,%eax
  802186:	78 05                	js     80218d <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802188:	e8 61 ff ff ff       	call   8020ee <alloc_sockfd>
}
  80218d:	c9                   	leave  
  80218e:	66 90                	xchg   %ax,%ax
  802190:	c3                   	ret    

00802191 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802191:	55                   	push   %ebp
  802192:	89 e5                	mov    %esp,%ebp
  802194:	83 ec 18             	sub    $0x18,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802197:	8d 55 fc             	lea    -0x4(%ebp),%edx
  80219a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80219e:	89 04 24             	mov    %eax,(%esp)
  8021a1:	e8 58 f6 ff ff       	call   8017fe <fd_lookup>
  8021a6:	89 c2                	mov    %eax,%edx
  8021a8:	85 c0                	test   %eax,%eax
  8021aa:	78 15                	js     8021c1 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8021ac:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  8021af:	8b 01                	mov    (%ecx),%eax
  8021b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  8021b6:	3b 05 20 60 80 00    	cmp    0x806020,%eax
  8021bc:	75 03                	jne    8021c1 <fd2sockid+0x30>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8021be:	8b 51 0c             	mov    0xc(%ecx),%edx
}
  8021c1:	89 d0                	mov    %edx,%eax
  8021c3:	c9                   	leave  
  8021c4:	c3                   	ret    

008021c5 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  8021c5:	55                   	push   %ebp
  8021c6:	89 e5                	mov    %esp,%ebp
  8021c8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ce:	e8 be ff ff ff       	call   802191 <fd2sockid>
  8021d3:	85 c0                	test   %eax,%eax
  8021d5:	78 0f                	js     8021e6 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8021d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021da:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021de:	89 04 24             	mov    %eax,(%esp)
  8021e1:	e8 2a 01 00 00       	call   802310 <nsipc_listen>
}
  8021e6:	c9                   	leave  
  8021e7:	c3                   	ret    

008021e8 <connect>:
	return nsipc_close(fd->fd_sock.sockid);
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8021e8:	55                   	push   %ebp
  8021e9:	89 e5                	mov    %esp,%ebp
  8021eb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f1:	e8 9b ff ff ff       	call   802191 <fd2sockid>
  8021f6:	85 c0                	test   %eax,%eax
  8021f8:	78 16                	js     802210 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  8021fa:	8b 55 10             	mov    0x10(%ebp),%edx
  8021fd:	89 54 24 08          	mov    %edx,0x8(%esp)
  802201:	8b 55 0c             	mov    0xc(%ebp),%edx
  802204:	89 54 24 04          	mov    %edx,0x4(%esp)
  802208:	89 04 24             	mov    %eax,(%esp)
  80220b:	e8 51 02 00 00       	call   802461 <nsipc_connect>
}
  802210:	c9                   	leave  
  802211:	c3                   	ret    

00802212 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  802212:	55                   	push   %ebp
  802213:	89 e5                	mov    %esp,%ebp
  802215:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802218:	8b 45 08             	mov    0x8(%ebp),%eax
  80221b:	e8 71 ff ff ff       	call   802191 <fd2sockid>
  802220:	85 c0                	test   %eax,%eax
  802222:	78 0f                	js     802233 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802224:	8b 55 0c             	mov    0xc(%ebp),%edx
  802227:	89 54 24 04          	mov    %edx,0x4(%esp)
  80222b:	89 04 24             	mov    %eax,(%esp)
  80222e:	e8 19 01 00 00       	call   80234c <nsipc_shutdown>
}
  802233:	c9                   	leave  
  802234:	c3                   	ret    

00802235 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802235:	55                   	push   %ebp
  802236:	89 e5                	mov    %esp,%ebp
  802238:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80223b:	8b 45 08             	mov    0x8(%ebp),%eax
  80223e:	e8 4e ff ff ff       	call   802191 <fd2sockid>
  802243:	85 c0                	test   %eax,%eax
  802245:	78 16                	js     80225d <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  802247:	8b 55 10             	mov    0x10(%ebp),%edx
  80224a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80224e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802251:	89 54 24 04          	mov    %edx,0x4(%esp)
  802255:	89 04 24             	mov    %eax,(%esp)
  802258:	e8 43 02 00 00       	call   8024a0 <nsipc_bind>
}
  80225d:	c9                   	leave  
  80225e:	c3                   	ret    

0080225f <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80225f:	55                   	push   %ebp
  802260:	89 e5                	mov    %esp,%ebp
  802262:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802265:	8b 45 08             	mov    0x8(%ebp),%eax
  802268:	e8 24 ff ff ff       	call   802191 <fd2sockid>
  80226d:	85 c0                	test   %eax,%eax
  80226f:	78 1f                	js     802290 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802271:	8b 55 10             	mov    0x10(%ebp),%edx
  802274:	89 54 24 08          	mov    %edx,0x8(%esp)
  802278:	8b 55 0c             	mov    0xc(%ebp),%edx
  80227b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80227f:	89 04 24             	mov    %eax,(%esp)
  802282:	e8 58 02 00 00       	call   8024df <nsipc_accept>
  802287:	85 c0                	test   %eax,%eax
  802289:	78 05                	js     802290 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80228b:	e8 5e fe ff ff       	call   8020ee <alloc_sockfd>
}
  802290:	c9                   	leave  
  802291:	c3                   	ret    
	...

008022a0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8022a0:	55                   	push   %ebp
  8022a1:	89 e5                	mov    %esp,%ebp
  8022a3:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8022a6:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  8022ac:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8022b3:	00 
  8022b4:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8022bb:	00 
  8022bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022c0:	89 14 24             	mov    %edx,(%esp)
  8022c3:	e8 18 f3 ff ff       	call   8015e0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8022c8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8022cf:	00 
  8022d0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8022d7:	00 
  8022d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022df:	e8 b0 f3 ff ff       	call   801694 <ipc_recv>
}
  8022e4:	c9                   	leave  
  8022e5:	c3                   	ret    

008022e6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  8022e6:	55                   	push   %ebp
  8022e7:	89 e5                	mov    %esp,%ebp
  8022e9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8022ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ef:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.socket.req_type = type;
  8022f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022f7:	a3 04 50 80 00       	mov    %eax,0x805004
	nsipcbuf.socket.req_protocol = protocol;
  8022fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8022ff:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SOCKET);
  802304:	b8 09 00 00 00       	mov    $0x9,%eax
  802309:	e8 92 ff ff ff       	call   8022a0 <nsipc>
}
  80230e:	c9                   	leave  
  80230f:	c3                   	ret    

00802310 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  802310:	55                   	push   %ebp
  802311:	89 e5                	mov    %esp,%ebp
  802313:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802316:	8b 45 08             	mov    0x8(%ebp),%eax
  802319:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.listen.req_backlog = backlog;
  80231e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802321:	a3 04 50 80 00       	mov    %eax,0x805004
	return nsipc(NSREQ_LISTEN);
  802326:	b8 06 00 00 00       	mov    $0x6,%eax
  80232b:	e8 70 ff ff ff       	call   8022a0 <nsipc>
}
  802330:	c9                   	leave  
  802331:	c3                   	ret    

00802332 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802332:	55                   	push   %ebp
  802333:	89 e5                	mov    %esp,%ebp
  802335:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802338:	8b 45 08             	mov    0x8(%ebp),%eax
  80233b:	a3 00 50 80 00       	mov    %eax,0x805000
	return nsipc(NSREQ_CLOSE);
  802340:	b8 04 00 00 00       	mov    $0x4,%eax
  802345:	e8 56 ff ff ff       	call   8022a0 <nsipc>
}
  80234a:	c9                   	leave  
  80234b:	c3                   	ret    

0080234c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80234c:	55                   	push   %ebp
  80234d:	89 e5                	mov    %esp,%ebp
  80234f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802352:	8b 45 08             	mov    0x8(%ebp),%eax
  802355:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.shutdown.req_how = how;
  80235a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80235d:	a3 04 50 80 00       	mov    %eax,0x805004
	return nsipc(NSREQ_SHUTDOWN);
  802362:	b8 03 00 00 00       	mov    $0x3,%eax
  802367:	e8 34 ff ff ff       	call   8022a0 <nsipc>
}
  80236c:	c9                   	leave  
  80236d:	c3                   	ret    

0080236e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80236e:	55                   	push   %ebp
  80236f:	89 e5                	mov    %esp,%ebp
  802371:	53                   	push   %ebx
  802372:	83 ec 14             	sub    $0x14,%esp
  802375:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802378:	8b 45 08             	mov    0x8(%ebp),%eax
  80237b:	a3 00 50 80 00       	mov    %eax,0x805000
	assert(size < 1600);
  802380:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802386:	7e 24                	jle    8023ac <nsipc_send+0x3e>
  802388:	c7 44 24 0c 4c 2e 80 	movl   $0x802e4c,0xc(%esp)
  80238f:	00 
  802390:	c7 44 24 08 58 2e 80 	movl   $0x802e58,0x8(%esp)
  802397:	00 
  802398:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  80239f:	00 
  8023a0:	c7 04 24 6d 2e 80 00 	movl   $0x802e6d,(%esp)
  8023a7:	e8 80 01 00 00       	call   80252c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8023ac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023b7:	c7 04 24 0c 50 80 00 	movl   $0x80500c,(%esp)
  8023be:	e8 75 e6 ff ff       	call   800a38 <memmove>
	nsipcbuf.send.req_size = size;
  8023c3:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	nsipcbuf.send.req_flags = flags;
  8023c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8023cc:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SEND);
  8023d1:	b8 08 00 00 00       	mov    $0x8,%eax
  8023d6:	e8 c5 fe ff ff       	call   8022a0 <nsipc>
}
  8023db:	83 c4 14             	add    $0x14,%esp
  8023de:	5b                   	pop    %ebx
  8023df:	5d                   	pop    %ebp
  8023e0:	c3                   	ret    

008023e1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8023e1:	55                   	push   %ebp
  8023e2:	89 e5                	mov    %esp,%ebp
  8023e4:	56                   	push   %esi
  8023e5:	53                   	push   %ebx
  8023e6:	83 ec 10             	sub    $0x10,%esp
  8023e9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8023ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ef:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.recv.req_len = len;
  8023f4:	89 35 04 50 80 00    	mov    %esi,0x805004
	nsipcbuf.recv.req_flags = flags;
  8023fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8023fd:	a3 08 50 80 00       	mov    %eax,0x805008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802402:	b8 07 00 00 00       	mov    $0x7,%eax
  802407:	e8 94 fe ff ff       	call   8022a0 <nsipc>
  80240c:	89 c3                	mov    %eax,%ebx
  80240e:	85 c0                	test   %eax,%eax
  802410:	78 46                	js     802458 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802412:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802417:	7f 04                	jg     80241d <nsipc_recv+0x3c>
  802419:	39 c6                	cmp    %eax,%esi
  80241b:	7d 24                	jge    802441 <nsipc_recv+0x60>
  80241d:	c7 44 24 0c 79 2e 80 	movl   $0x802e79,0xc(%esp)
  802424:	00 
  802425:	c7 44 24 08 58 2e 80 	movl   $0x802e58,0x8(%esp)
  80242c:	00 
  80242d:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  802434:	00 
  802435:	c7 04 24 6d 2e 80 00 	movl   $0x802e6d,(%esp)
  80243c:	e8 eb 00 00 00       	call   80252c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802441:	89 44 24 08          	mov    %eax,0x8(%esp)
  802445:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80244c:	00 
  80244d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802450:	89 04 24             	mov    %eax,(%esp)
  802453:	e8 e0 e5 ff ff       	call   800a38 <memmove>
	}

	return r;
}
  802458:	89 d8                	mov    %ebx,%eax
  80245a:	83 c4 10             	add    $0x10,%esp
  80245d:	5b                   	pop    %ebx
  80245e:	5e                   	pop    %esi
  80245f:	5d                   	pop    %ebp
  802460:	c3                   	ret    

00802461 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802461:	55                   	push   %ebp
  802462:	89 e5                	mov    %esp,%ebp
  802464:	53                   	push   %ebx
  802465:	83 ec 14             	sub    $0x14,%esp
  802468:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80246b:	8b 45 08             	mov    0x8(%ebp),%eax
  80246e:	a3 00 50 80 00       	mov    %eax,0x805000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802473:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802477:	8b 45 0c             	mov    0xc(%ebp),%eax
  80247a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80247e:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  802485:	e8 ae e5 ff ff       	call   800a38 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80248a:	89 1d 14 50 80 00    	mov    %ebx,0x805014
	return nsipc(NSREQ_CONNECT);
  802490:	b8 05 00 00 00       	mov    $0x5,%eax
  802495:	e8 06 fe ff ff       	call   8022a0 <nsipc>
}
  80249a:	83 c4 14             	add    $0x14,%esp
  80249d:	5b                   	pop    %ebx
  80249e:	5d                   	pop    %ebp
  80249f:	c3                   	ret    

008024a0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8024a0:	55                   	push   %ebp
  8024a1:	89 e5                	mov    %esp,%ebp
  8024a3:	53                   	push   %ebx
  8024a4:	83 ec 14             	sub    $0x14,%esp
  8024a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8024aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8024ad:	a3 00 50 80 00       	mov    %eax,0x805000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8024b2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024bd:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  8024c4:	e8 6f e5 ff ff       	call   800a38 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8024c9:	89 1d 14 50 80 00    	mov    %ebx,0x805014
	return nsipc(NSREQ_BIND);
  8024cf:	b8 02 00 00 00       	mov    $0x2,%eax
  8024d4:	e8 c7 fd ff ff       	call   8022a0 <nsipc>
}
  8024d9:	83 c4 14             	add    $0x14,%esp
  8024dc:	5b                   	pop    %ebx
  8024dd:	5d                   	pop    %ebp
  8024de:	c3                   	ret    

008024df <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8024df:	55                   	push   %ebp
  8024e0:	89 e5                	mov    %esp,%ebp
  8024e2:	53                   	push   %ebx
  8024e3:	83 ec 14             	sub    $0x14,%esp
	int r;
	
	nsipcbuf.accept.req_s = s;
  8024e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8024e9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8024ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8024f3:	e8 a8 fd ff ff       	call   8022a0 <nsipc>
  8024f8:	89 c3                	mov    %eax,%ebx
  8024fa:	85 c0                	test   %eax,%eax
  8024fc:	78 26                	js     802524 <nsipc_accept+0x45>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8024fe:	a1 10 50 80 00       	mov    0x805010,%eax
  802503:	89 44 24 08          	mov    %eax,0x8(%esp)
  802507:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80250e:	00 
  80250f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802512:	89 04 24             	mov    %eax,(%esp)
  802515:	e8 1e e5 ff ff       	call   800a38 <memmove>
		*addrlen = ret->ret_addrlen;
  80251a:	a1 10 50 80 00       	mov    0x805010,%eax
  80251f:	8b 55 10             	mov    0x10(%ebp),%edx
  802522:	89 02                	mov    %eax,(%edx)
	}
	return r;
}
  802524:	89 d8                	mov    %ebx,%eax
  802526:	83 c4 14             	add    $0x14,%esp
  802529:	5b                   	pop    %ebx
  80252a:	5d                   	pop    %ebp
  80252b:	c3                   	ret    

0080252c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  80252c:	55                   	push   %ebp
  80252d:	89 e5                	mov    %esp,%ebp
  80252f:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  802532:	8d 45 14             	lea    0x14(%ebp),%eax
  802535:	89 45 fc             	mov    %eax,-0x4(%ebp)

	// Print the panic message
	if (argv0)
  802538:	a1 40 60 80 00       	mov    0x806040,%eax
  80253d:	85 c0                	test   %eax,%eax
  80253f:	74 10                	je     802551 <_panic+0x25>
		cprintf("%s: ", argv0);
  802541:	89 44 24 04          	mov    %eax,0x4(%esp)
  802545:	c7 04 24 8e 2e 80 00 	movl   $0x802e8e,(%esp)
  80254c:	e8 80 dc ff ff       	call   8001d1 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  802551:	8b 45 0c             	mov    0xc(%ebp),%eax
  802554:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802558:	8b 45 08             	mov    0x8(%ebp),%eax
  80255b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80255f:	a1 00 60 80 00       	mov    0x806000,%eax
  802564:	89 44 24 04          	mov    %eax,0x4(%esp)
  802568:	c7 04 24 93 2e 80 00 	movl   $0x802e93,(%esp)
  80256f:	e8 5d dc ff ff       	call   8001d1 <cprintf>
	vcprintf(fmt, ap);
  802574:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802577:	89 44 24 04          	mov    %eax,0x4(%esp)
  80257b:	8b 45 10             	mov    0x10(%ebp),%eax
  80257e:	89 04 24             	mov    %eax,(%esp)
  802581:	e8 ea db ff ff       	call   800170 <vcprintf>
	cprintf("\n");
  802586:	c7 04 24 b6 2d 80 00 	movl   $0x802db6,(%esp)
  80258d:	e8 3f dc ff ff       	call   8001d1 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802592:	cc                   	int3   
  802593:	eb fd                	jmp    802592 <_panic+0x66>
  802595:	00 00                	add    %al,(%eax)
	...

00802598 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802598:	55                   	push   %ebp
  802599:	89 e5                	mov    %esp,%ebp
  80259b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80259e:	83 3d 44 60 80 00 00 	cmpl   $0x0,0x806044
  8025a5:	75 6a                	jne    802611 <set_pgfault_handler+0x79>
		// First time through!
		// LAB 4: Your code here.
		env=(struct Env*)&envs[ENVX(sys_getenvid())];
  8025a7:	e8 51 ea ff ff       	call   800ffd <sys_getenvid>
  8025ac:	25 ff 03 00 00       	and    $0x3ff,%eax
  8025b1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8025b4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8025b9:	a3 3c 60 80 00       	mov    %eax,0x80603c
		if((r=sys_page_alloc(env->env_id,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  8025be:	8b 40 4c             	mov    0x4c(%eax),%eax
  8025c1:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8025c8:	00 
  8025c9:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8025d0:	ee 
  8025d1:	89 04 24             	mov    %eax,(%esp)
  8025d4:	e8 91 e9 ff ff       	call   800f6a <sys_page_alloc>
  8025d9:	85 c0                	test   %eax,%eax
  8025db:	79 1c                	jns    8025f9 <set_pgfault_handler+0x61>
		{
			panic("Alloc a page for an exception stack failed");
  8025dd:	c7 44 24 08 b0 2e 80 	movl   $0x802eb0,0x8(%esp)
  8025e4:	00 
  8025e5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8025ec:	00 
  8025ed:	c7 04 24 dc 2e 80 00 	movl   $0x802edc,(%esp)
  8025f4:	e8 33 ff ff ff       	call   80252c <_panic>
		}
		sys_env_set_pgfault_upcall(env->env_id,(void*)_pgfault_upcall);
  8025f9:	a1 3c 60 80 00       	mov    0x80603c,%eax
  8025fe:	8b 40 4c             	mov    0x4c(%eax),%eax
  802601:	c7 44 24 04 1c 26 80 	movl   $0x80261c,0x4(%esp)
  802608:	00 
  802609:	89 04 24             	mov    %eax,(%esp)
  80260c:	e8 83 e7 ff ff       	call   800d94 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802611:	8b 45 08             	mov    0x8(%ebp),%eax
  802614:	a3 44 60 80 00       	mov    %eax,0x806044
}
  802619:	c9                   	leave  
  80261a:	c3                   	ret    
	...

0080261c <_pgfault_upcall>:
  80261c:	54                   	push   %esp
  80261d:	a1 44 60 80 00       	mov    0x806044,%eax
  802622:	ff d0                	call   *%eax
  802624:	83 c4 04             	add    $0x4,%esp
  802627:	8b 44 24 28          	mov    0x28(%esp),%eax
  80262b:	50                   	push   %eax
  80262c:	89 e0                	mov    %esp,%eax
  80262e:	8b 60 34             	mov    0x34(%eax),%esp
  802631:	ff 30                	pushl  (%eax)
  802633:	89 c4                	mov    %eax,%esp
  802635:	83 6c 24 34 04       	subl   $0x4,0x34(%esp)
  80263a:	83 c4 0c             	add    $0xc,%esp
  80263d:	61                   	popa   
  80263e:	83 c4 04             	add    $0x4,%esp
  802641:	9d                   	popf   
  802642:	5c                   	pop    %esp
  802643:	c3                   	ret    
	...

00802650 <__udivdi3>:
  802650:	55                   	push   %ebp
  802651:	89 e5                	mov    %esp,%ebp
  802653:	57                   	push   %edi
  802654:	56                   	push   %esi
  802655:	83 ec 18             	sub    $0x18,%esp
  802658:	8b 45 10             	mov    0x10(%ebp),%eax
  80265b:	8b 55 14             	mov    0x14(%ebp),%edx
  80265e:	8b 75 0c             	mov    0xc(%ebp),%esi
  802661:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802664:	89 c1                	mov    %eax,%ecx
  802666:	8b 45 08             	mov    0x8(%ebp),%eax
  802669:	85 d2                	test   %edx,%edx
  80266b:	89 d7                	mov    %edx,%edi
  80266d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802670:	75 1e                	jne    802690 <__udivdi3+0x40>
  802672:	39 f1                	cmp    %esi,%ecx
  802674:	0f 86 8d 00 00 00    	jbe    802707 <__udivdi3+0xb7>
  80267a:	89 f2                	mov    %esi,%edx
  80267c:	31 f6                	xor    %esi,%esi
  80267e:	f7 f1                	div    %ecx
  802680:	89 c1                	mov    %eax,%ecx
  802682:	89 c8                	mov    %ecx,%eax
  802684:	89 f2                	mov    %esi,%edx
  802686:	83 c4 18             	add    $0x18,%esp
  802689:	5e                   	pop    %esi
  80268a:	5f                   	pop    %edi
  80268b:	5d                   	pop    %ebp
  80268c:	c3                   	ret    
  80268d:	8d 76 00             	lea    0x0(%esi),%esi
  802690:	39 f2                	cmp    %esi,%edx
  802692:	0f 87 a8 00 00 00    	ja     802740 <__udivdi3+0xf0>
  802698:	0f bd c2             	bsr    %edx,%eax
  80269b:	83 f0 1f             	xor    $0x1f,%eax
  80269e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8026a1:	0f 84 89 00 00 00    	je     802730 <__udivdi3+0xe0>
  8026a7:	b8 20 00 00 00       	mov    $0x20,%eax
  8026ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8026af:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8026b2:	89 c1                	mov    %eax,%ecx
  8026b4:	d3 ea                	shr    %cl,%edx
  8026b6:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  8026ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8026bd:	89 f8                	mov    %edi,%eax
  8026bf:	8b 7d f4             	mov    -0xc(%ebp),%edi
  8026c2:	d3 e0                	shl    %cl,%eax
  8026c4:	09 c2                	or     %eax,%edx
  8026c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8026c9:	d3 e7                	shl    %cl,%edi
  8026cb:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026cf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8026d2:	89 f2                	mov    %esi,%edx
  8026d4:	d3 e8                	shr    %cl,%eax
  8026d6:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  8026da:	d3 e2                	shl    %cl,%edx
  8026dc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026e0:	09 d0                	or     %edx,%eax
  8026e2:	d3 ee                	shr    %cl,%esi
  8026e4:	89 f2                	mov    %esi,%edx
  8026e6:	f7 75 e4             	divl   -0x1c(%ebp)
  8026e9:	89 d1                	mov    %edx,%ecx
  8026eb:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8026ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8026f1:	f7 e7                	mul    %edi
  8026f3:	39 d1                	cmp    %edx,%ecx
  8026f5:	89 c6                	mov    %eax,%esi
  8026f7:	72 70                	jb     802769 <__udivdi3+0x119>
  8026f9:	39 ca                	cmp    %ecx,%edx
  8026fb:	74 5f                	je     80275c <__udivdi3+0x10c>
  8026fd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802700:	31 f6                	xor    %esi,%esi
  802702:	e9 7b ff ff ff       	jmp    802682 <__udivdi3+0x32>
  802707:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80270a:	85 c0                	test   %eax,%eax
  80270c:	75 0c                	jne    80271a <__udivdi3+0xca>
  80270e:	b8 01 00 00 00       	mov    $0x1,%eax
  802713:	31 d2                	xor    %edx,%edx
  802715:	f7 75 f4             	divl   -0xc(%ebp)
  802718:	89 c1                	mov    %eax,%ecx
  80271a:	89 f0                	mov    %esi,%eax
  80271c:	89 fa                	mov    %edi,%edx
  80271e:	f7 f1                	div    %ecx
  802720:	89 c6                	mov    %eax,%esi
  802722:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802725:	f7 f1                	div    %ecx
  802727:	89 c1                	mov    %eax,%ecx
  802729:	e9 54 ff ff ff       	jmp    802682 <__udivdi3+0x32>
  80272e:	66 90                	xchg   %ax,%ax
  802730:	39 d6                	cmp    %edx,%esi
  802732:	77 1c                	ja     802750 <__udivdi3+0x100>
  802734:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802737:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  80273a:	73 14                	jae    802750 <__udivdi3+0x100>
  80273c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802740:	31 c9                	xor    %ecx,%ecx
  802742:	31 f6                	xor    %esi,%esi
  802744:	e9 39 ff ff ff       	jmp    802682 <__udivdi3+0x32>
  802749:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  802750:	b9 01 00 00 00       	mov    $0x1,%ecx
  802755:	31 f6                	xor    %esi,%esi
  802757:	e9 26 ff ff ff       	jmp    802682 <__udivdi3+0x32>
  80275c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80275f:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  802763:	d3 e0                	shl    %cl,%eax
  802765:	39 c6                	cmp    %eax,%esi
  802767:	76 94                	jbe    8026fd <__udivdi3+0xad>
  802769:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80276c:	31 f6                	xor    %esi,%esi
  80276e:	83 e9 01             	sub    $0x1,%ecx
  802771:	e9 0c ff ff ff       	jmp    802682 <__udivdi3+0x32>
	...

00802780 <__umoddi3>:
  802780:	55                   	push   %ebp
  802781:	89 e5                	mov    %esp,%ebp
  802783:	57                   	push   %edi
  802784:	56                   	push   %esi
  802785:	83 ec 30             	sub    $0x30,%esp
  802788:	8b 45 10             	mov    0x10(%ebp),%eax
  80278b:	8b 55 14             	mov    0x14(%ebp),%edx
  80278e:	8b 75 08             	mov    0x8(%ebp),%esi
  802791:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802794:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802797:	89 c1                	mov    %eax,%ecx
  802799:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80279c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80279f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8027a6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8027ad:	89 fa                	mov    %edi,%edx
  8027af:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8027b2:	85 c0                	test   %eax,%eax
  8027b4:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8027b7:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8027ba:	75 14                	jne    8027d0 <__umoddi3+0x50>
  8027bc:	39 f9                	cmp    %edi,%ecx
  8027be:	76 60                	jbe    802820 <__umoddi3+0xa0>
  8027c0:	89 f0                	mov    %esi,%eax
  8027c2:	f7 f1                	div    %ecx
  8027c4:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8027c7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8027ce:	eb 10                	jmp    8027e0 <__umoddi3+0x60>
  8027d0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8027d3:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  8027d6:	76 18                	jbe    8027f0 <__umoddi3+0x70>
  8027d8:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8027db:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8027de:	66 90                	xchg   %ax,%ax
  8027e0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8027e3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8027e6:	83 c4 30             	add    $0x30,%esp
  8027e9:	5e                   	pop    %esi
  8027ea:	5f                   	pop    %edi
  8027eb:	5d                   	pop    %ebp
  8027ec:	c3                   	ret    
  8027ed:	8d 76 00             	lea    0x0(%esi),%esi
  8027f0:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
  8027f4:	83 f0 1f             	xor    $0x1f,%eax
  8027f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8027fa:	75 46                	jne    802842 <__umoddi3+0xc2>
  8027fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8027ff:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  802802:	0f 87 c9 00 00 00    	ja     8028d1 <__umoddi3+0x151>
  802808:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  80280b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80280e:	0f 83 bd 00 00 00    	jae    8028d1 <__umoddi3+0x151>
  802814:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802817:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80281a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80281d:	eb c1                	jmp    8027e0 <__umoddi3+0x60>
  80281f:	90                   	nop    
  802820:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802823:	85 c0                	test   %eax,%eax
  802825:	75 0c                	jne    802833 <__umoddi3+0xb3>
  802827:	b8 01 00 00 00       	mov    $0x1,%eax
  80282c:	31 d2                	xor    %edx,%edx
  80282e:	f7 75 ec             	divl   -0x14(%ebp)
  802831:	89 c1                	mov    %eax,%ecx
  802833:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802836:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802839:	f7 f1                	div    %ecx
  80283b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80283e:	f7 f1                	div    %ecx
  802840:	eb 82                	jmp    8027c4 <__umoddi3+0x44>
  802842:	b8 20 00 00 00       	mov    $0x20,%eax
  802847:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80284a:	2b 45 d8             	sub    -0x28(%ebp),%eax
  80284d:	8b 75 ec             	mov    -0x14(%ebp),%esi
  802850:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802853:	89 c1                	mov    %eax,%ecx
  802855:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802858:	d3 ea                	shr    %cl,%edx
  80285a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80285d:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  802861:	d3 e0                	shl    %cl,%eax
  802863:	09 c2                	or     %eax,%edx
  802865:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802868:	d3 e6                	shl    %cl,%esi
  80286a:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  80286e:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802871:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802874:	d3 e8                	shr    %cl,%eax
  802876:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  80287a:	d3 e2                	shl    %cl,%edx
  80287c:	09 d0                	or     %edx,%eax
  80287e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802881:	d3 e7                	shl    %cl,%edi
  802883:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  802887:	d3 ea                	shr    %cl,%edx
  802889:	f7 75 f4             	divl   -0xc(%ebp)
  80288c:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80288f:	f7 e6                	mul    %esi
  802891:	39 55 cc             	cmp    %edx,-0x34(%ebp)
  802894:	72 53                	jb     8028e9 <__umoddi3+0x169>
  802896:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  802899:	74 4a                	je     8028e5 <__umoddi3+0x165>
  80289b:	90                   	nop    
  80289c:	8d 74 26 00          	lea    0x0(%esi),%esi
  8028a0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8028a3:	29 c7                	sub    %eax,%edi
  8028a5:	19 d1                	sbb    %edx,%ecx
  8028a7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8028aa:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8028ae:	89 fa                	mov    %edi,%edx
  8028b0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8028b3:	d3 ea                	shr    %cl,%edx
  8028b5:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  8028b9:	d3 e0                	shl    %cl,%eax
  8028bb:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8028bf:	09 c2                	or     %eax,%edx
  8028c1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8028c4:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8028c7:	d3 e8                	shr    %cl,%eax
  8028c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8028cc:	e9 0f ff ff ff       	jmp    8027e0 <__umoddi3+0x60>
  8028d1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8028d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8028d7:	2b 45 ec             	sub    -0x14(%ebp),%eax
  8028da:	1b 55 e8             	sbb    -0x18(%ebp),%edx
  8028dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8028e0:	e9 2f ff ff ff       	jmp    802814 <__umoddi3+0x94>
  8028e5:	39 f8                	cmp    %edi,%eax
  8028e7:	76 b7                	jbe    8028a0 <__umoddi3+0x120>
  8028e9:	29 f0                	sub    %esi,%eax
  8028eb:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8028ee:	eb b0                	jmp    8028a0 <__umoddi3+0x120>
