
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
  80003d:	e8 67 14 00 00       	call   8014a9 <fork>
  800042:	89 c3                	mov    %eax,%ebx
  800044:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800047:	85 c0                	test   %eax,%eax
  800049:	74 3c                	je     800087 <umain+0x53>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004b:	e8 79 0f 00 00       	call   800fc9 <sys_getenvid>
  800050:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800054:	89 44 24 04          	mov    %eax,0x4(%esp)
  800058:	c7 04 24 20 24 80 00 	movl   $0x802420,(%esp)
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
  800082:	e8 29 15 00 00       	call   8015b0 <ipc_send>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800087:	8d 7d f0             	lea    -0x10(%ebp),%edi
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800099:	00 
  80009a:	89 3c 24             	mov    %edi,(%esp)
  80009d:	e8 c2 15 00 00       	call   801664 <ipc_recv>
  8000a2:	89 c6                	mov    %eax,%esi
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a4:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8000a7:	e8 1d 0f 00 00       	call   800fc9 <sys_getenvid>
  8000ac:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000b0:	89 74 24 08          	mov    %esi,0x8(%esp)
  8000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b8:	c7 04 24 36 24 80 00 	movl   $0x802436,(%esp)
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
  8000e6:	e8 c5 14 00 00       	call   8015b0 <ipc_send>
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
  80010a:	c7 05 20 50 80 00 00 	movl   $0x0,0x805020
  800111:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  800114:	e8 b0 0e 00 00       	call   800fc9 <sys_getenvid>
  800119:	25 ff 03 00 00       	and    $0x3ff,%eax
  80011e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800121:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800126:	a3 20 50 80 00       	mov    %eax,0x805020
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012b:	85 f6                	test   %esi,%esi
  80012d:	7e 07                	jle    800136 <libmain+0x3e>
		binaryname = argv[0];
  80012f:	8b 03                	mov    (%ebx),%eax
  800131:	a3 00 50 80 00       	mov    %eax,0x805000

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
  80015a:	e8 e1 1b 00 00       	call   801d40 <close_all>
	sys_env_destroy(0);
  80015f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800166:	e8 92 0e 00 00       	call   800ffd <sys_env_destroy>
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
  8002ab:	e8 c0 1e 00 00       	call   802170 <__udivdi3>
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
  8002fd:	e8 9e 1f 00 00       	call   8022a0 <__umoddi3>
  800302:	89 74 24 04          	mov    %esi,0x4(%esp)
  800306:	0f be 80 60 24 80 00 	movsbl 0x802460(%eax),%eax
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
  8003de:	ff 24 85 a0 25 80 00 	jmp    *0x8025a0(,%eax,4)
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
  80048d:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  800494:	85 d2                	test   %edx,%edx
  800496:	75 23                	jne    8004bb <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800498:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80049c:	c7 44 24 08 71 24 80 	movl   $0x802471,0x8(%esp)
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
  8004bf:	c7 44 24 08 7a 24 80 	movl   $0x80247a,0x8(%esp)
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
  8004f8:	c7 45 dc 7d 24 80 00 	movl   $0x80247d,-0x24(%ebp)
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

00800ccb <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	83 ec 28             	sub    $0x28,%esp
  800cd1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cd4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cd7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800cda:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ce2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ce7:	89 f9                	mov    %edi,%ecx
  800ce9:	89 fb                	mov    %edi,%ebx
  800ceb:	89 fe                	mov    %edi,%esi
  800ced:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800cef:	85 c0                	test   %eax,%eax
  800cf1:	7e 28                	jle    800d1b <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cf7:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800cfe:	00 
  800cff:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800d06:	00 
  800d07:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d0e:	00 
  800d0f:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800d16:	e8 31 13 00 00       	call   80204c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d1b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d1e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d21:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d24:	89 ec                	mov    %ebp,%esp
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    

00800d28 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	83 ec 0c             	sub    $0xc,%esp
  800d2e:	89 1c 24             	mov    %ebx,(%esp)
  800d31:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d35:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d39:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d42:	8b 7d 14             	mov    0x14(%ebp),%edi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d45:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d4a:	be 00 00 00 00       	mov    $0x0,%esi
  800d4f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d51:	8b 1c 24             	mov    (%esp),%ebx
  800d54:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d58:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d5c:	89 ec                	mov    %ebp,%esp
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	83 ec 28             	sub    $0x28,%esp
  800d66:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d69:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d6c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d75:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d7a:	bf 00 00 00 00       	mov    $0x0,%edi
  800d7f:	89 fb                	mov    %edi,%ebx
  800d81:	89 fe                	mov    %edi,%esi
  800d83:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800d85:	85 c0                	test   %eax,%eax
  800d87:	7e 28                	jle    800db1 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d89:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d8d:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d94:	00 
  800d95:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800d9c:	00 
  800d9d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da4:	00 
  800da5:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800dac:	e8 9b 12 00 00       	call   80204c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800db1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800db4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800db7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dba:	89 ec                	mov    %ebp,%esp
  800dbc:	5d                   	pop    %ebp
  800dbd:	c3                   	ret    

00800dbe <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dbe:	55                   	push   %ebp
  800dbf:	89 e5                	mov    %esp,%ebp
  800dc1:	83 ec 28             	sub    $0x28,%esp
  800dc4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dc7:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dca:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800dcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd3:	b8 09 00 00 00       	mov    $0x9,%eax
  800dd8:	bf 00 00 00 00       	mov    $0x0,%edi
  800ddd:	89 fb                	mov    %edi,%ebx
  800ddf:	89 fe                	mov    %edi,%esi
  800de1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800de3:	85 c0                	test   %eax,%eax
  800de5:	7e 28                	jle    800e0f <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800deb:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800df2:	00 
  800df3:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800dfa:	00 
  800dfb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e02:	00 
  800e03:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800e0a:	e8 3d 12 00 00       	call   80204c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e0f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e12:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e15:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e18:	89 ec                	mov    %ebp,%esp
  800e1a:	5d                   	pop    %ebp
  800e1b:	c3                   	ret    

00800e1c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	83 ec 28             	sub    $0x28,%esp
  800e22:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e25:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e28:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e31:	b8 08 00 00 00       	mov    $0x8,%eax
  800e36:	bf 00 00 00 00       	mov    $0x0,%edi
  800e3b:	89 fb                	mov    %edi,%ebx
  800e3d:	89 fe                	mov    %edi,%esi
  800e3f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800e41:	85 c0                	test   %eax,%eax
  800e43:	7e 28                	jle    800e6d <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e45:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e49:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e50:	00 
  800e51:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800e58:	00 
  800e59:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e60:	00 
  800e61:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800e68:	e8 df 11 00 00       	call   80204c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e6d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e70:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e73:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e76:	89 ec                	mov    %ebp,%esp
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    

00800e7a <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	83 ec 28             	sub    $0x28,%esp
  800e80:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e83:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e86:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e89:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8f:	b8 06 00 00 00       	mov    $0x6,%eax
  800e94:	bf 00 00 00 00       	mov    $0x0,%edi
  800e99:	89 fb                	mov    %edi,%ebx
  800e9b:	89 fe                	mov    %edi,%esi
  800e9d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800e9f:	85 c0                	test   %eax,%eax
  800ea1:	7e 28                	jle    800ecb <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800eae:	00 
  800eaf:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800eb6:	00 
  800eb7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ebe:	00 
  800ebf:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800ec6:	e8 81 11 00 00       	call   80204c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ecb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ece:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ed1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ed4:	89 ec                	mov    %ebp,%esp
  800ed6:	5d                   	pop    %ebp
  800ed7:	c3                   	ret    

00800ed8 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	83 ec 28             	sub    $0x28,%esp
  800ede:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ee1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ee4:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ee7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ef3:	8b 75 18             	mov    0x18(%ebp),%esi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef6:	b8 05 00 00 00       	mov    $0x5,%eax
  800efb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800efd:	85 c0                	test   %eax,%eax
  800eff:	7e 28                	jle    800f29 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f01:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f05:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f0c:	00 
  800f0d:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800f14:	00 
  800f15:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f1c:	00 
  800f1d:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800f24:	e8 23 11 00 00       	call   80204c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f29:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f2c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f2f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f32:	89 ec                	mov    %ebp,%esp
  800f34:	5d                   	pop    %ebp
  800f35:	c3                   	ret    

00800f36 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
  800f39:	83 ec 28             	sub    $0x28,%esp
  800f3c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f3f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f42:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f45:	8b 55 08             	mov    0x8(%ebp),%edx
  800f48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4e:	b8 04 00 00 00       	mov    $0x4,%eax
  800f53:	bf 00 00 00 00       	mov    $0x0,%edi
  800f58:	89 fe                	mov    %edi,%esi
  800f5a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	7e 28                	jle    800f88 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f60:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f64:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f6b:	00 
  800f6c:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800f73:	00 
  800f74:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f7b:	00 
  800f7c:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800f83:	e8 c4 10 00 00       	call   80204c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f88:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f8b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f8e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f91:	89 ec                	mov    %ebp,%esp
  800f93:	5d                   	pop    %ebp
  800f94:	c3                   	ret    

00800f95 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	83 ec 0c             	sub    $0xc,%esp
  800f9b:	89 1c 24             	mov    %ebx,(%esp)
  800f9e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fa2:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fab:	bf 00 00 00 00       	mov    $0x0,%edi
  800fb0:	89 fa                	mov    %edi,%edx
  800fb2:	89 f9                	mov    %edi,%ecx
  800fb4:	89 fb                	mov    %edi,%ebx
  800fb6:	89 fe                	mov    %edi,%esi
  800fb8:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800fba:	8b 1c 24             	mov    (%esp),%ebx
  800fbd:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fc1:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fc5:	89 ec                	mov    %ebp,%esp
  800fc7:	5d                   	pop    %ebp
  800fc8:	c3                   	ret    

00800fc9 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
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
  800fda:	b8 02 00 00 00       	mov    $0x2,%eax
  800fdf:	bf 00 00 00 00       	mov    $0x0,%edi
  800fe4:	89 fa                	mov    %edi,%edx
  800fe6:	89 f9                	mov    %edi,%ecx
  800fe8:	89 fb                	mov    %edi,%ebx
  800fea:	89 fe                	mov    %edi,%esi
  800fec:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800fee:	8b 1c 24             	mov    (%esp),%ebx
  800ff1:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ff5:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ff9:	89 ec                	mov    %ebp,%esp
  800ffb:	5d                   	pop    %ebp
  800ffc:	c3                   	ret    

00800ffd <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	83 ec 28             	sub    $0x28,%esp
  801003:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801006:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801009:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80100c:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80100f:	b8 03 00 00 00       	mov    $0x3,%eax
  801014:	bf 00 00 00 00       	mov    $0x0,%edi
  801019:	89 f9                	mov    %edi,%ecx
  80101b:	89 fb                	mov    %edi,%ebx
  80101d:	89 fe                	mov    %edi,%esi
  80101f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801021:	85 c0                	test   %eax,%eax
  801023:	7e 28                	jle    80104d <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801025:	89 44 24 10          	mov    %eax,0x10(%esp)
  801029:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801030:	00 
  801031:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  801038:	00 
  801039:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801040:	00 
  801041:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  801048:	e8 ff 0f 00 00       	call   80204c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80104d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801050:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801053:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801056:	89 ec                	mov    %ebp,%esp
  801058:	5d                   	pop    %ebp
  801059:	c3                   	ret    
  80105a:	00 00                	add    %al,(%eax)
  80105c:	00 00                	add    %al,(%eax)
	...

00801060 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
// 
static int
duppage(envid_t envid, unsigned pn)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	53                   	push   %ebx
  801064:	83 ec 14             	sub    $0x14,%esp
  801067:	89 c1                	mov    %eax,%ecx
	int r;

	// LAB 4: Your code here.
	pde_t *pde;
	pte_t *pte;
	void *addr=(void*)(pn*PGSIZE);
  801069:	89 d3                	mov    %edx,%ebx
  80106b:	c1 e3 0c             	shl    $0xc,%ebx
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
  80106e:	89 d8                	mov    %ebx,%eax
  801070:	c1 e8 16             	shr    $0x16,%eax
  801073:	f6 04 85 00 d0 7b ef 	testb  $0x1,-0x10843000(,%eax,4)
  80107a:	01 
  80107b:	74 14                	je     801091 <duppage+0x31>
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else    panic("page table for pn page is not exist");
	if((*pte&PTE_W)||(*pte&PTE_COW))
  80107d:	89 d8                	mov    %ebx,%eax
  80107f:	c1 e8 0c             	shr    $0xc,%eax
  801082:	f7 04 85 00 00 40 ef 	testl  $0x802,-0x10c00000(,%eax,4)
  801089:	02 08 00 00 
  80108d:	75 1e                	jne    8010ad <duppage+0x4d>
  80108f:	eb 73                	jmp    801104 <duppage+0xa4>
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else    panic("page table for pn page is not exist");
  801091:	c7 44 24 08 8c 27 80 	movl   $0x80278c,0x8(%esp)
  801098:	00 
  801099:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
  8010a0:	00 
  8010a1:	c7 04 24 4a 28 80 00 	movl   $0x80284a,(%esp)
  8010a8:	e8 9f 0f 00 00       	call   80204c <_panic>
	if((*pte&PTE_W)||(*pte&PTE_COW))
	{
		if((r=sys_page_map(0,addr,envid,addr,PTE_COW|PTE_U))<0)
  8010ad:	c7 44 24 10 04 08 00 	movl   $0x804,0x10(%esp)
  8010b4:	00 
  8010b5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010c8:	e8 0b fe ff ff       	call   800ed8 <sys_page_map>
  8010cd:	85 c0                	test   %eax,%eax
  8010cf:	78 60                	js     801131 <duppage+0xd1>
			return r;
		if((r=sys_page_map(0,addr,0,addr,PTE_COW|PTE_U))<0)//映射的时候注意env的id
  8010d1:	c7 44 24 10 04 08 00 	movl   $0x804,0x10(%esp)
  8010d8:	00 
  8010d9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010dd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010e4:	00 
  8010e5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010f0:	e8 e3 fd ff ff       	call   800ed8 <sys_page_map>
  8010f5:	85 c0                	test   %eax,%eax
  8010f7:	0f 9f c2             	setg   %dl
  8010fa:	0f b6 d2             	movzbl %dl,%edx
  8010fd:	83 ea 01             	sub    $0x1,%edx
  801100:	21 d0                	and    %edx,%eax
  801102:	eb 2d                	jmp    801131 <duppage+0xd1>
                        return r;
	}
	else{	
		if((r=sys_page_map(0,addr,envid,addr,PTE_U|PTE_P))<0)
  801104:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80110b:	00 
  80110c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801110:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801114:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801118:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80111f:	e8 b4 fd ff ff       	call   800ed8 <sys_page_map>
  801124:	85 c0                	test   %eax,%eax
  801126:	0f 9f c2             	setg   %dl
  801129:	0f b6 d2             	movzbl %dl,%edx
  80112c:	83 ea 01             	sub    $0x1,%edx
  80112f:	21 d0                	and    %edx,%eax
			return r;
	}
	//panic("duppage not implemented");
	return 0;
}
  801131:	83 c4 14             	add    $0x14,%esp
  801134:	5b                   	pop    %ebx
  801135:	5d                   	pop    %ebp
  801136:	c3                   	ret    

00801137 <sfork>:
	return 0;
}
// Challenge!
int
sfork(void)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	57                   	push   %edi
  80113b:	56                   	push   %esi
  80113c:	53                   	push   %ebx
  80113d:	83 ec 1c             	sub    $0x1c,%esp
static __inline envid_t sys_exofork(void) __attribute__((always_inline));
static __inline envid_t
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801140:	ba 07 00 00 00       	mov    $0x7,%edx
  801145:	89 d0                	mov    %edx,%eax
  801147:	cd 30                	int    $0x30
  801149:	89 45 f0             	mov    %eax,-0x10(%ebp)
	pte_t *pte;
	unsigned i;
	uint32_t addr;
	envid_t envid;
	envid = sys_exofork();//创建子环境
	if(envid < 0)
  80114c:	85 c0                	test   %eax,%eax
  80114e:	79 20                	jns    801170 <sfork+0x39>
		panic("sys_exofork: %e", envid);
  801150:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801154:	c7 44 24 08 55 28 80 	movl   $0x802855,0x8(%esp)
  80115b:	00 
  80115c:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  801163:	00 
  801164:	c7 04 24 4a 28 80 00 	movl   $0x80284a,(%esp)
  80116b:	e8 dc 0e 00 00       	call   80204c <_panic>
	if(envid==0)//子环境中
  801170:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801174:	75 21                	jne    801197 <sfork+0x60>
	{
		env = &envs[ENVX(sys_getenvid())];
  801176:	e8 4e fe ff ff       	call   800fc9 <sys_getenvid>
  80117b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801180:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801183:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801188:	a3 20 50 80 00       	mov    %eax,0x805020
  80118d:	b8 00 00 00 00       	mov    $0x0,%eax
  801192:	e9 83 01 00 00       	jmp    80131a <sfork+0x1e3>
		return 0;
	}
	else{//父环境中,注意：这里需要设置父环境的缺页异常栈，还需要设置子环境的缺页异常栈，
	//父子环境的页异常栈不共享？具体原因还得思考
		env = &envs[ENVX(sys_getenvid())];
  801197:	e8 2d fe ff ff       	call   800fc9 <sys_getenvid>
  80119c:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011a1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011a4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011a9:	a3 20 50 80 00       	mov    %eax,0x805020
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
  8011ae:	c7 04 24 22 13 80 00 	movl   $0x801322,(%esp)
  8011b5:	e8 fe 0e 00 00       	call   8020b8 <set_pgfault_handler>
  8011ba:	be 00 00 00 00       	mov    $0x0,%esi
  8011bf:	bf 00 00 00 00       	mov    $0x0,%edi
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
		{
			addr=i*PGSIZE;
			pde =(pde_t*) &vpd[VPD(addr)];
  8011c4:	89 f8                	mov    %edi,%eax
  8011c6:	c1 e8 16             	shr    $0x16,%eax
  8011c9:	c1 e0 02             	shl    $0x2,%eax
			if(*pde&PTE_P)//这里只处理有物理页面映射的页表项
  8011cc:	f6 80 00 d0 7b ef 01 	testb  $0x1,-0x10843000(%eax)
  8011d3:	0f 84 dc 00 00 00    	je     8012b5 <sfork+0x17e>
			{
				pte=(pte_t*)&vpt[VPN(addr)];
			}
			else    continue;
			if((i==(unsigned)VPN(USTACKTOP-PGSIZE))||(i==(unsigned)VPN(PFTEMP)))
  8011d9:	81 fe fd eb 0e 00    	cmp    $0xeebfd,%esi
  8011df:	74 08                	je     8011e9 <sfork+0xb2>
  8011e1:	81 fe ff 07 00 00    	cmp    $0x7ff,%esi
  8011e7:	75 17                	jne    801200 <sfork+0xc9>
								//特殊处理，用户层普通栈
			{	
				if((r=duppage(envid,i))<0)
  8011e9:	89 f2                	mov    %esi,%edx
  8011eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ee:	e8 6d fe ff ff       	call   801060 <duppage>
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	0f 89 ba 00 00 00    	jns    8012b5 <sfork+0x17e>
  8011fb:	e9 1a 01 00 00       	jmp    80131a <sfork+0x1e3>
	// LAB 4: Your code here.
	pde_t *pde;
	pte_t *pte;
	void *addr=(void*)(pn*PGSIZE);
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
  801200:	f6 80 00 d0 7b ef 01 	testb  $0x1,-0x10843000(%eax)
  801207:	74 11                	je     80121a <sfork+0xe3>
	{
		pte=(pte_t*)&vpt[VPN(addr)];
  801209:	89 f8                	mov    %edi,%eax
  80120b:	c1 e8 0c             	shr    $0xc,%eax
	}
	else    panic("page table for pn page is not exist");
	if(*pte&PTE_W)
  80120e:	f6 04 85 00 00 40 ef 	testb  $0x2,-0x10c00000(,%eax,4)
  801215:	02 
  801216:	75 1e                	jne    801236 <sfork+0xff>
  801218:	eb 74                	jmp    80128e <sfork+0x157>
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else    panic("page table for pn page is not exist");
  80121a:	c7 44 24 08 8c 27 80 	movl   $0x80278c,0x8(%esp)
  801221:	00 
  801222:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
  801229:	00 
  80122a:	c7 04 24 4a 28 80 00 	movl   $0x80284a,(%esp)
  801231:	e8 16 0e 00 00       	call   80204c <_panic>
	if(*pte&PTE_W)
	{
		//cprintf("sduppage:addr=%x\n",addr);
		if((r=sys_page_map(0,addr,envid,addr,PTE_W|PTE_U))<0)
  801236:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
  80123d:	00 
  80123e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801242:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801245:	89 44 24 08          	mov    %eax,0x8(%esp)
  801249:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80124d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801254:	e8 7f fc ff ff       	call   800ed8 <sys_page_map>
  801259:	85 c0                	test   %eax,%eax
  80125b:	0f 88 b9 00 00 00    	js     80131a <sfork+0x1e3>
			return r;
		if((r=sys_page_map(0,addr,0,addr,PTE_W|PTE_U))<0)//映射的时候注意env的id
  801261:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
  801268:	00 
  801269:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80126d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801274:	00 
  801275:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801279:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801280:	e8 53 fc ff ff       	call   800ed8 <sys_page_map>
  801285:	85 c0                	test   %eax,%eax
  801287:	79 2c                	jns    8012b5 <sfork+0x17e>
  801289:	e9 8c 00 00 00       	jmp    80131a <sfork+0x1e3>
                        return r;
	}
	else{	
		if((r=sys_page_map(0,addr,envid,addr,PTE_U|PTE_P))<0)
  80128e:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801295:	00 
  801296:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80129a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012ac:	e8 27 fc ff ff       	call   800ed8 <sys_page_map>
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	78 65                	js     80131a <sfork+0x1e3>
	}
	else{//父环境中,注意：这里需要设置父环境的缺页异常栈，还需要设置子环境的缺页异常栈，
	//父子环境的页异常栈不共享？具体原因还得思考
		env = &envs[ENVX(sys_getenvid())];
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
  8012b5:	83 c6 01             	add    $0x1,%esi
  8012b8:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8012be:	81 fe 00 ec 0e 00    	cmp    $0xeec00,%esi
  8012c4:	0f 85 fa fe ff ff    	jne    8011c4 <sfork+0x8d>
				continue;
			}
			if((r=sduppage(envid,i))<0)
				return r;
		}
		if((r=sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  8012ca:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012d1:	00 
  8012d2:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012d9:	ee 
  8012da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012dd:	89 04 24             	mov    %eax,(%esp)
  8012e0:	e8 51 fc ff ff       	call   800f36 <sys_page_alloc>
  8012e5:	85 c0                	test   %eax,%eax
  8012e7:	78 31                	js     80131a <sfork+0x1e3>
                        return r;//设置子环境的缺页异常栈
		if((r=sys_env_set_pgfault_upcall(envid,(void*)_pgfault_upcall))<0)
  8012e9:	c7 44 24 04 3c 21 80 	movl   $0x80213c,0x4(%esp)
  8012f0:	00 
  8012f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f4:	89 04 24             	mov    %eax,(%esp)
  8012f7:	e8 64 fa ff ff       	call   800d60 <sys_env_set_pgfault_upcall>
  8012fc:	85 c0                	test   %eax,%eax
  8012fe:	78 1a                	js     80131a <sfork+0x1e3>
			return r;//设置子环境的缺页异常处理入口点
		if((r=sys_env_set_status(envid,ENV_RUNNABLE))<0)
  801300:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801307:	00 
  801308:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130b:	89 04 24             	mov    %eax,(%esp)
  80130e:	e8 09 fb ff ff       	call   800e1c <sys_env_set_status>
  801313:	85 c0                	test   %eax,%eax
  801315:	78 03                	js     80131a <sfork+0x1e3>
  801317:	8b 45 f0             	mov    -0x10(%ebp),%eax
			return r;//设置子环境的状态为可运行
		return envid;
	}
	//panic("sfork not implemented");
	//return -E_INVAL;
}
  80131a:	83 c4 1c             	add    $0x1c,%esp
  80131d:	5b                   	pop    %ebx
  80131e:	5e                   	pop    %esi
  80131f:	5f                   	pop    %edi
  801320:	5d                   	pop    %ebp
  801321:	c3                   	ret    

00801322 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801322:	55                   	push   %ebp
  801323:	89 e5                	mov    %esp,%ebp
  801325:	56                   	push   %esi
  801326:	53                   	push   %ebx
  801327:	83 ec 20             	sub    $0x20,%esp
  80132a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
  80132d:	8b 71 04             	mov    0x4(%ecx),%esi

	// LAB 4: Your code here.
	pde_t *pde;
	pte_t *pte;
	uint32_t *va,*srcva,*dstva;
	pde =(pde_t*) &vpd[VPD(addr)];
  801330:	8b 19                	mov    (%ecx),%ebx
  801332:	89 d8                	mov    %ebx,%eax
  801334:	c1 e8 16             	shr    $0x16,%eax
  801337:	c1 e0 02             	shl    $0x2,%eax
  80133a:	8d 90 00 d0 7b ef    	lea    -0x10843000(%eax),%edx
	if(*pde&PTE_P)
  801340:	f6 80 00 d0 7b ef 01 	testb  $0x1,-0x10843000(%eax)
  801347:	74 16                	je     80135f <pgfault+0x3d>
	{
		pte=(pte_t*)&vpt[VPN(addr)];
  801349:	89 d8                	mov    %ebx,%eax
  80134b:	c1 e8 0c             	shr    $0xc,%eax
  80134e:	8d 04 85 00 00 40 ef 	lea    -0x10c00000(,%eax,4),%eax
	else{
		cprintf("addr=%x err=%x *pde=%x utf_eip=%x\n",(uint32_t)addr,err,*pde,utf->utf_eip);	
		panic("page table for fault va is not exist");
	}
	//cprintf("addr=%x err=%x *pte=%x utf_eip=%x\n",(uint32_t)addr,err,*pte,utf->utf_eip);
	if(!(err&FEC_WR)||!(*pte&PTE_COW))
  801355:	f7 c6 02 00 00 00    	test   $0x2,%esi
  80135b:	75 3f                	jne    80139c <pgfault+0x7a>
  80135d:	eb 43                	jmp    8013a2 <pgfault+0x80>
	if(*pde&PTE_P)
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else{
		cprintf("addr=%x err=%x *pde=%x utf_eip=%x\n",(uint32_t)addr,err,*pde,utf->utf_eip);	
  80135f:	8b 41 28             	mov    0x28(%ecx),%eax
  801362:	8b 12                	mov    (%edx),%edx
  801364:	89 44 24 10          	mov    %eax,0x10(%esp)
  801368:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80136c:	89 74 24 08          	mov    %esi,0x8(%esp)
  801370:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801374:	c7 04 24 b0 27 80 00 	movl   $0x8027b0,(%esp)
  80137b:	e8 51 ee ff ff       	call   8001d1 <cprintf>
		panic("page table for fault va is not exist");
  801380:	c7 44 24 08 d4 27 80 	movl   $0x8027d4,0x8(%esp)
  801387:	00 
  801388:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80138f:	00 
  801390:	c7 04 24 4a 28 80 00 	movl   $0x80284a,(%esp)
  801397:	e8 b0 0c 00 00       	call   80204c <_panic>
	}
	//cprintf("addr=%x err=%x *pte=%x utf_eip=%x\n",(uint32_t)addr,err,*pte,utf->utf_eip);
	if(!(err&FEC_WR)||!(*pte&PTE_COW))
  80139c:	f6 40 01 08          	testb  $0x8,0x1(%eax)
  8013a0:	75 49                	jne    8013eb <pgfault+0xc9>
	{	
		cprintf("envid=%x addr=%x err=%x *pte=%x utf_eip=%x\n",env->env_id,(uint32_t)addr,err,*pte,utf->utf_eip);
  8013a2:	8b 51 28             	mov    0x28(%ecx),%edx
  8013a5:	8b 08                	mov    (%eax),%ecx
  8013a7:	a1 20 50 80 00       	mov    0x805020,%eax
  8013ac:	8b 40 4c             	mov    0x4c(%eax),%eax
  8013af:	89 54 24 14          	mov    %edx,0x14(%esp)
  8013b3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8013b7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013bb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c3:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  8013ca:	e8 02 ee ff ff       	call   8001d1 <cprintf>
		panic("faulting access is illegle");
  8013cf:	c7 44 24 08 65 28 80 	movl   $0x802865,0x8(%esp)
  8013d6:	00 
  8013d7:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8013de:	00 
  8013df:	c7 04 24 4a 28 80 00 	movl   $0x80284a,(%esp)
  8013e6:	e8 61 0c 00 00       	call   80204c <_panic>
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	//cprintf("pgfault:env_id=%x\n",env->env_id);
	if((r=sys_page_alloc(0,PFTEMP,PTE_W|PTE_U|PTE_P))<0)
  8013eb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013f2:	00 
  8013f3:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8013fa:	00 
  8013fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801402:	e8 2f fb ff ff       	call   800f36 <sys_page_alloc>
  801407:	85 c0                	test   %eax,%eax
  801409:	79 20                	jns    80142b <pgfault+0x109>
			//输入id=0表示当前环境id(curenv->env_id),这个时候不能用env->env-id,子环境中env的修改会缺页
		panic("alloc a page for PFTEMP failed:%e",r);
  80140b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80140f:	c7 44 24 08 28 28 80 	movl   $0x802828,0x8(%esp)
  801416:	00 
  801417:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  80141e:	00 
  80141f:	c7 04 24 4a 28 80 00 	movl   $0x80284a,(%esp)
  801426:	e8 21 0c 00 00       	call   80204c <_panic>
	//cprintf("PFTEMP=%x add=%x\n",PFTEMP,(uint32_t)addr&0xfffff000);
	srcva = (uint32_t*)((uint32_t)addr&0xfffff000);
  80142b:	89 de                	mov    %ebx,%esi
  80142d:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  801433:	89 f2                	mov    %esi,%edx
	dstva = (uint32_t*)PFTEMP;
	//strncpy((char*)PFTEMP,(char*)((uint32_t)addr&0xfffff000),PGSIZE);
	for(;srcva<(uint32_t*)(ROUNDUP(addr,PGSIZE));srcva++)//数据拷贝要注意，用strncpy出错了，原因还得分析
  801435:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  80143b:	89 c3                	mov    %eax,%ebx
  80143d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801443:	39 de                	cmp    %ebx,%esi
  801445:	73 13                	jae    80145a <pgfault+0x138>
  801447:	b9 00 f0 7f 00       	mov    $0x7ff000,%ecx
	{
		*dstva=*srcva;
  80144c:	8b 02                	mov    (%edx),%eax
  80144e:	89 01                	mov    %eax,(%ecx)
		dstva++;
  801450:	83 c1 04             	add    $0x4,%ecx
		panic("alloc a page for PFTEMP failed:%e",r);
	//cprintf("PFTEMP=%x add=%x\n",PFTEMP,(uint32_t)addr&0xfffff000);
	srcva = (uint32_t*)((uint32_t)addr&0xfffff000);
	dstva = (uint32_t*)PFTEMP;
	//strncpy((char*)PFTEMP,(char*)((uint32_t)addr&0xfffff000),PGSIZE);
	for(;srcva<(uint32_t*)(ROUNDUP(addr,PGSIZE));srcva++)//数据拷贝要注意，用strncpy出错了，原因还得分析
  801453:	83 c2 04             	add    $0x4,%edx
  801456:	39 da                	cmp    %ebx,%edx
  801458:	72 f2                	jb     80144c <pgfault+0x12a>
	{
		*dstva=*srcva;
		dstva++;
	}
	if((r=sys_page_map(0,(void*)PFTEMP,0,(void*)((uint32_t)addr&0xfffff000),PTE_W|PTE_U|PTE_P))<0)
  80145a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801461:	00 
  801462:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801466:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80146d:	00 
  80146e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801475:	00 
  801476:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80147d:	e8 56 fa ff ff       	call   800ed8 <sys_page_map>
  801482:	85 c0                	test   %eax,%eax
  801484:	79 1c                	jns    8014a2 <pgfault+0x180>
			//输入id=0表示当前环境id(curenv->env_id),这个时候不能用env->env-id,子环境中env的修改会缺页
		panic("page mapping failed");
  801486:	c7 44 24 08 80 28 80 	movl   $0x802880,0x8(%esp)
  80148d:	00 
  80148e:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801495:	00 
  801496:	c7 04 24 4a 28 80 00 	movl   $0x80284a,(%esp)
  80149d:	e8 aa 0b 00 00       	call   80204c <_panic>
	//panic("pgfault not implemented");
}
  8014a2:	83 c4 20             	add    $0x20,%esp
  8014a5:	5b                   	pop    %ebx
  8014a6:	5e                   	pop    %esi
  8014a7:	5d                   	pop    %ebp
  8014a8:	c3                   	ret    

008014a9 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8014a9:	55                   	push   %ebp
  8014aa:	89 e5                	mov    %esp,%ebp
  8014ac:	56                   	push   %esi
  8014ad:	53                   	push   %ebx
  8014ae:	83 ec 10             	sub    $0x10,%esp
  8014b1:	ba 07 00 00 00       	mov    $0x7,%edx
  8014b6:	89 d0                	mov    %edx,%eax
  8014b8:	cd 30                	int    $0x30
  8014ba:	89 c6                	mov    %eax,%esi
	pte_t *pte;
	unsigned i;
	uint32_t addr;
	envid_t envid;
	envid = sys_exofork();//创建子环境
	if(envid < 0)
  8014bc:	85 c0                	test   %eax,%eax
  8014be:	79 20                	jns    8014e0 <fork+0x37>
		panic("sys_exofork: %e", envid);
  8014c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014c4:	c7 44 24 08 55 28 80 	movl   $0x802855,0x8(%esp)
  8014cb:	00 
  8014cc:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  8014d3:	00 
  8014d4:	c7 04 24 4a 28 80 00 	movl   $0x80284a,(%esp)
  8014db:	e8 6c 0b 00 00       	call   80204c <_panic>
	if(envid==0)//子环境中
  8014e0:	85 c0                	test   %eax,%eax
  8014e2:	75 21                	jne    801505 <fork+0x5c>
	{
		env = &envs[ENVX(sys_getenvid())];
  8014e4:	e8 e0 fa ff ff       	call   800fc9 <sys_getenvid>
  8014e9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8014ee:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8014f1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8014f6:	a3 20 50 80 00       	mov    %eax,0x805020
  8014fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801500:	e9 9e 00 00 00       	jmp    8015a3 <fork+0xfa>
		return 0;
	}
	else{//父环境中
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
  801505:	c7 04 24 22 13 80 00 	movl   $0x801322,(%esp)
  80150c:	e8 a7 0b 00 00       	call   8020b8 <set_pgfault_handler>
  801511:	bb 00 00 00 00       	mov    $0x0,%ebx
  801516:	eb 08                	jmp    801520 <fork+0x77>
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
		{
			if(i==(unsigned)VPN(UXSTACKTOP-PGSIZE))//特殊处理，用户层缺页异常栈
  801518:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  80151e:	74 3d                	je     80155d <fork+0xb4>
				continue;
  801520:	89 da                	mov    %ebx,%edx
  801522:	c1 e2 0c             	shl    $0xc,%edx
			addr=i*PGSIZE;
			pde =(pde_t*) &vpd[VPD(addr)];
  801525:	89 d0                	mov    %edx,%eax
  801527:	c1 e8 16             	shr    $0x16,%eax
			if(*pde&PTE_P)//这里只处理有物理页面映射的页表项
  80152a:	f6 04 85 00 d0 7b ef 	testb  $0x1,-0x10843000(,%eax,4)
  801531:	01 
  801532:	74 1e                	je     801552 <fork+0xa9>
			{
				pte=(pte_t*)&vpt[VPN(addr)];
  801534:	89 d0                	mov    %edx,%eax
  801536:	c1 e8 0a             	shr    $0xa,%eax
			}
			else    continue;
			if((*pte&PTE_W)||(*pte&PTE_COW))
  801539:	f7 80 00 00 40 ef 02 	testl  $0x802,-0x10c00000(%eax)
  801540:	08 00 00 
  801543:	74 0d                	je     801552 <fork+0xa9>
			{
				if((r=duppage(envid,i))<0)
  801545:	89 da                	mov    %ebx,%edx
  801547:	89 f0                	mov    %esi,%eax
  801549:	e8 12 fb ff ff       	call   801060 <duppage>
  80154e:	85 c0                	test   %eax,%eax
  801550:	78 51                	js     8015a3 <fork+0xfa>
		env = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	else{//父环境中
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
  801552:	83 c3 01             	add    $0x1,%ebx
  801555:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  80155b:	75 bb                	jne    801518 <fork+0x6f>
			{
				if((r=duppage(envid,i))<0)
					return r;
			}
		}
		if((r=sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  80155d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801564:	00 
  801565:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80156c:	ee 
  80156d:	89 34 24             	mov    %esi,(%esp)
  801570:	e8 c1 f9 ff ff       	call   800f36 <sys_page_alloc>
  801575:	85 c0                	test   %eax,%eax
  801577:	78 2a                	js     8015a3 <fork+0xfa>
			return r;//设置子环境的缺页异常栈
		if((r=sys_env_set_pgfault_upcall(envid,(void*)_pgfault_upcall))<0)
  801579:	c7 44 24 04 3c 21 80 	movl   $0x80213c,0x4(%esp)
  801580:	00 
  801581:	89 34 24             	mov    %esi,(%esp)
  801584:	e8 d7 f7 ff ff       	call   800d60 <sys_env_set_pgfault_upcall>
  801589:	85 c0                	test   %eax,%eax
  80158b:	78 16                	js     8015a3 <fork+0xfa>
			return r;//设置子环境的缺页异常处理入口点
		if((r=sys_env_set_status(envid,ENV_RUNNABLE))<0)
  80158d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801594:	00 
  801595:	89 34 24             	mov    %esi,(%esp)
  801598:	e8 7f f8 ff ff       	call   800e1c <sys_env_set_status>
  80159d:	85 c0                	test   %eax,%eax
  80159f:	78 02                	js     8015a3 <fork+0xfa>
  8015a1:	89 f0                	mov    %esi,%eax
			return r;//设置子环境的状态为可运行
		return envid;
	}
	//panic("fork not implemented");
}
  8015a3:	83 c4 10             	add    $0x10,%esp
  8015a6:	5b                   	pop    %ebx
  8015a7:	5e                   	pop    %esi
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
  8015bf:	e8 05 fa ff ff       	call   800fc9 <sys_getenvid>
  8015c4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8015c9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8015cc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8015d1:	a3 20 50 80 00       	mov    %eax,0x805020
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  8015d6:	e8 ee f9 ff ff       	call   800fc9 <sys_getenvid>
  8015db:	25 ff 03 00 00       	and    $0x3ff,%eax
  8015e0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8015e3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8015e8:	a3 20 50 80 00       	mov    %eax,0x805020
		if(env->env_id==to_env){
  8015ed:	8b 40 4c             	mov    0x4c(%eax),%eax
  8015f0:	39 f0                	cmp    %esi,%eax
  8015f2:	75 0e                	jne    801602 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  8015f4:	c7 04 24 94 28 80 00 	movl   $0x802894,(%esp)
  8015fb:	e8 d1 eb ff ff       	call   8001d1 <cprintf>
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
  801617:	e8 0c f7 ff ff       	call   800d28 <sys_ipc_try_send>
  80161c:	89 c3                	mov    %eax,%ebx
  80161e:	85 c0                	test   %eax,%eax
  801620:	79 25                	jns    801647 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  801622:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801625:	74 2b                	je     801652 <ipc_send+0xa2>
				panic("send error:%e",r);
  801627:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80162b:	c7 44 24 08 b0 28 80 	movl   $0x8028b0,0x8(%esp)
  801632:	00 
  801633:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80163a:	00 
  80163b:	c7 04 24 be 28 80 00 	movl   $0x8028be,(%esp)
  801642:	e8 05 0a 00 00       	call   80204c <_panic>
		}
			sys_yield();
  801647:	e8 49 f9 ff ff       	call   800f95 <sys_yield>
		
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
  801652:	e8 3e f9 ff ff       	call   800f95 <sys_yield>
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
  801673:	e8 51 f9 ff ff       	call   800fc9 <sys_getenvid>
  801678:	25 ff 03 00 00       	and    $0x3ff,%eax
  80167d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801680:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801685:	a3 20 50 80 00       	mov    %eax,0x805020
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
  8016a1:	c7 04 24 94 28 80 00 	movl   $0x802894,(%esp)
  8016a8:	e8 24 eb ff ff       	call   8001d1 <cprintf>
  8016ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016b2:	e9 8a 00 00 00       	jmp    801741 <ipc_recv+0xdd>
		return 0;
	}
	env = &envs[ENVX(sys_getenvid())];
  8016b7:	e8 0d f9 ff ff       	call   800fc9 <sys_getenvid>
  8016bc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8016c1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8016c4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8016c9:	a3 20 50 80 00       	mov    %eax,0x805020
	if((r=sys_ipc_recv(dstva))<0)
  8016ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016d1:	89 04 24             	mov    %eax,(%esp)
  8016d4:	e8 f2 f5 ff ff       	call   800ccb <sys_ipc_recv>
  8016d9:	89 c3                	mov    %eax,%ebx
  8016db:	85 c0                	test   %eax,%eax
  8016dd:	79 1a                	jns    8016f9 <ipc_recv+0x95>
	{
		*from_env_store=0;
  8016df:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  8016e5:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("reciver failed\n");
  8016eb:	c7 04 24 c8 28 80 00 	movl   $0x8028c8,(%esp)
  8016f2:	e8 da ea ff ff       	call   8001d1 <cprintf>
  8016f7:	eb 48                	jmp    801741 <ipc_recv+0xdd>
		return r;
	}
	else{//接收成功
		env = &envs[ENVX(sys_getenvid())];
  8016f9:	e8 cb f8 ff ff       	call   800fc9 <sys_getenvid>
  8016fe:	25 ff 03 00 00       	and    $0x3ff,%eax
  801703:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801706:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80170b:	a3 20 50 80 00       	mov    %eax,0x805020
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
  80171d:	a1 20 50 80 00       	mov    0x805020,%eax
  801722:	8b 40 78             	mov    0x78(%eax),%eax
  801725:	89 07                	mov    %eax,(%edi)
		env = &envs[ENVX(sys_getenvid())];
  801727:	e8 9d f8 ff ff       	call   800fc9 <sys_getenvid>
  80172c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801731:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801734:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801739:	a3 20 50 80 00       	mov    %eax,0x805020
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
  80184f:	ba 04 50 80 00       	mov    $0x805004,%edx
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
  801859:	39 0d 04 50 80 00    	cmp    %ecx,0x805004
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
  801875:	8b 14 85 54 29 80 00 	mov    0x802954(,%eax,4),%edx
  80187c:	85 d2                	test   %edx,%edx
  80187e:	75 e3                	jne    801863 <dev_lookup+0x21>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  801880:	a1 20 50 80 00       	mov    0x805020,%eax
  801885:	8b 40 4c             	mov    0x4c(%eax),%eax
  801888:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80188c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801890:	c7 04 24 d8 28 80 00 	movl   $0x8028d8,(%esp)
  801897:	e8 35 e9 ff ff       	call   8001d1 <cprintf>
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
  801967:	a1 20 50 80 00       	mov    0x805020,%eax
  80196c:	8b 40 4c             	mov    0x4c(%eax),%eax
  80196f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801973:	89 44 24 04          	mov    %eax,0x4(%esp)
  801977:	c7 04 24 f8 28 80 00 	movl   $0x8028f8,(%esp)
  80197e:	e8 4e e8 ff ff       	call   8001d1 <cprintf>
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
  8019eb:	a1 20 50 80 00       	mov    0x805020,%eax
  8019f0:	8b 40 4c             	mov    0x4c(%eax),%eax
  8019f3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019fb:	c7 04 24 19 29 80 00 	movl   $0x802919,(%esp)
  801a02:	e8 ca e7 ff ff       	call   8001d1 <cprintf>
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
  801a7b:	a1 20 50 80 00       	mov    0x805020,%eax
  801a80:	8b 40 4c             	mov    0x4c(%eax),%eax
  801a83:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a87:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8b:	c7 04 24 36 29 80 00 	movl   $0x802936,(%esp)
  801a92:	e8 3a e7 ff ff       	call   8001d1 <cprintf>
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
  801b94:	e8 e1 f2 ff ff       	call   800e7a <sys_page_unmap>
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
  801cc5:	e8 0e f2 ff ff       	call   800ed8 <sys_page_map>
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
  801cff:	e8 d4 f1 ff ff       	call   800ed8 <sys_page_map>
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
  801d19:	e8 5c f1 ff ff       	call   800e7a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801d1e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d21:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d2c:	e8 49 f1 ff ff       	call   800e7a <sys_page_unmap>
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
  801e43:	e8 e9 e9 ff ff       	call   800831 <strcpy>
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
  801ea4:	e8 8f eb ff ff       	call   800a38 <memmove>
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
  801ee9:	c7 04 24 5c 29 80 00 	movl   $0x80295c,(%esp)
  801ef0:	e8 dc e2 ff ff       	call   8001d1 <cprintf>
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
  801f0b:	e8 28 eb ff ff       	call   800a38 <memmove>
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
  801f25:	e8 b6 e8 ff ff       	call   8007e0 <strlen>
  801f2a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  801f2f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801f34:	7f 21                	jg     801f57 <remove+0x3f>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801f36:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f3a:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801f41:	e8 eb e8 ff ff       	call   800831 <strcpy>
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
  801f96:	c7 04 24 69 29 80 00 	movl   $0x802969,(%esp)
  801f9d:	e8 2f e2 ff ff       	call   8001d1 <cprintf>
	strcpy(fsipcbuf.open.req_path,path);
  801fa2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa9:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801fb0:	e8 7c e8 ff ff       	call   800831 <strcpy>
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
  802007:	e8 cc ee ff ff       	call   800ed8 <sys_page_map>
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
  802031:	c7 04 24 75 29 80 00 	movl   $0x802975,(%esp)
  802038:	e8 94 e1 ff ff       	call   8001d1 <cprintf>
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
	...

0080204c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  80204c:	55                   	push   %ebp
  80204d:	89 e5                	mov    %esp,%ebp
  80204f:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  802052:	8d 45 14             	lea    0x14(%ebp),%eax
  802055:	89 45 fc             	mov    %eax,-0x4(%ebp)

	// Print the panic message
	if (argv0)
  802058:	a1 24 50 80 00       	mov    0x805024,%eax
  80205d:	85 c0                	test   %eax,%eax
  80205f:	74 10                	je     802071 <_panic+0x25>
		cprintf("%s: ", argv0);
  802061:	89 44 24 04          	mov    %eax,0x4(%esp)
  802065:	c7 04 24 80 29 80 00 	movl   $0x802980,(%esp)
  80206c:	e8 60 e1 ff ff       	call   8001d1 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  802071:	8b 45 0c             	mov    0xc(%ebp),%eax
  802074:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802078:	8b 45 08             	mov    0x8(%ebp),%eax
  80207b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80207f:	a1 00 50 80 00       	mov    0x805000,%eax
  802084:	89 44 24 04          	mov    %eax,0x4(%esp)
  802088:	c7 04 24 85 29 80 00 	movl   $0x802985,(%esp)
  80208f:	e8 3d e1 ff ff       	call   8001d1 <cprintf>
	vcprintf(fmt, ap);
  802094:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802097:	89 44 24 04          	mov    %eax,0x4(%esp)
  80209b:	8b 45 10             	mov    0x10(%ebp),%eax
  80209e:	89 04 24             	mov    %eax,(%esp)
  8020a1:	e8 ca e0 ff ff       	call   800170 <vcprintf>
	cprintf("\n");
  8020a6:	c7 04 24 67 29 80 00 	movl   $0x802967,(%esp)
  8020ad:	e8 1f e1 ff ff       	call   8001d1 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8020b2:	cc                   	int3   
  8020b3:	eb fd                	jmp    8020b2 <_panic+0x66>
  8020b5:	00 00                	add    %al,(%eax)
	...

008020b8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8020b8:	55                   	push   %ebp
  8020b9:	89 e5                	mov    %esp,%ebp
  8020bb:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8020be:	83 3d 28 50 80 00 00 	cmpl   $0x0,0x805028
  8020c5:	75 6a                	jne    802131 <set_pgfault_handler+0x79>
		// First time through!
		// LAB 4: Your code here.
		env=(struct Env*)&envs[ENVX(sys_getenvid())];
  8020c7:	e8 fd ee ff ff       	call   800fc9 <sys_getenvid>
  8020cc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8020d1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020d4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020d9:	a3 20 50 80 00       	mov    %eax,0x805020
		if((r=sys_page_alloc(env->env_id,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  8020de:	8b 40 4c             	mov    0x4c(%eax),%eax
  8020e1:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8020e8:	00 
  8020e9:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8020f0:	ee 
  8020f1:	89 04 24             	mov    %eax,(%esp)
  8020f4:	e8 3d ee ff ff       	call   800f36 <sys_page_alloc>
  8020f9:	85 c0                	test   %eax,%eax
  8020fb:	79 1c                	jns    802119 <set_pgfault_handler+0x61>
		{
			panic("Alloc a page for an exception stack failed");
  8020fd:	c7 44 24 08 a4 29 80 	movl   $0x8029a4,0x8(%esp)
  802104:	00 
  802105:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80210c:	00 
  80210d:	c7 04 24 d0 29 80 00 	movl   $0x8029d0,(%esp)
  802114:	e8 33 ff ff ff       	call   80204c <_panic>
		}
		sys_env_set_pgfault_upcall(env->env_id,(void*)_pgfault_upcall);
  802119:	a1 20 50 80 00       	mov    0x805020,%eax
  80211e:	8b 40 4c             	mov    0x4c(%eax),%eax
  802121:	c7 44 24 04 3c 21 80 	movl   $0x80213c,0x4(%esp)
  802128:	00 
  802129:	89 04 24             	mov    %eax,(%esp)
  80212c:	e8 2f ec ff ff       	call   800d60 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802131:	8b 45 08             	mov    0x8(%ebp),%eax
  802134:	a3 28 50 80 00       	mov    %eax,0x805028
}
  802139:	c9                   	leave  
  80213a:	c3                   	ret    
	...

0080213c <_pgfault_upcall>:
  80213c:	54                   	push   %esp
  80213d:	a1 28 50 80 00       	mov    0x805028,%eax
  802142:	ff d0                	call   *%eax
  802144:	83 c4 04             	add    $0x4,%esp
  802147:	8b 44 24 28          	mov    0x28(%esp),%eax
  80214b:	50                   	push   %eax
  80214c:	89 e0                	mov    %esp,%eax
  80214e:	8b 60 34             	mov    0x34(%eax),%esp
  802151:	ff 30                	pushl  (%eax)
  802153:	89 c4                	mov    %eax,%esp
  802155:	83 6c 24 34 04       	subl   $0x4,0x34(%esp)
  80215a:	83 c4 0c             	add    $0xc,%esp
  80215d:	61                   	popa   
  80215e:	83 c4 04             	add    $0x4,%esp
  802161:	9d                   	popf   
  802162:	5c                   	pop    %esp
  802163:	c3                   	ret    
	...

00802170 <__udivdi3>:
  802170:	55                   	push   %ebp
  802171:	89 e5                	mov    %esp,%ebp
  802173:	57                   	push   %edi
  802174:	56                   	push   %esi
  802175:	83 ec 18             	sub    $0x18,%esp
  802178:	8b 45 10             	mov    0x10(%ebp),%eax
  80217b:	8b 55 14             	mov    0x14(%ebp),%edx
  80217e:	8b 75 0c             	mov    0xc(%ebp),%esi
  802181:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802184:	89 c1                	mov    %eax,%ecx
  802186:	8b 45 08             	mov    0x8(%ebp),%eax
  802189:	85 d2                	test   %edx,%edx
  80218b:	89 d7                	mov    %edx,%edi
  80218d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802190:	75 1e                	jne    8021b0 <__udivdi3+0x40>
  802192:	39 f1                	cmp    %esi,%ecx
  802194:	0f 86 8d 00 00 00    	jbe    802227 <__udivdi3+0xb7>
  80219a:	89 f2                	mov    %esi,%edx
  80219c:	31 f6                	xor    %esi,%esi
  80219e:	f7 f1                	div    %ecx
  8021a0:	89 c1                	mov    %eax,%ecx
  8021a2:	89 c8                	mov    %ecx,%eax
  8021a4:	89 f2                	mov    %esi,%edx
  8021a6:	83 c4 18             	add    $0x18,%esp
  8021a9:	5e                   	pop    %esi
  8021aa:	5f                   	pop    %edi
  8021ab:	5d                   	pop    %ebp
  8021ac:	c3                   	ret    
  8021ad:	8d 76 00             	lea    0x0(%esi),%esi
  8021b0:	39 f2                	cmp    %esi,%edx
  8021b2:	0f 87 a8 00 00 00    	ja     802260 <__udivdi3+0xf0>
  8021b8:	0f bd c2             	bsr    %edx,%eax
  8021bb:	83 f0 1f             	xor    $0x1f,%eax
  8021be:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8021c1:	0f 84 89 00 00 00    	je     802250 <__udivdi3+0xe0>
  8021c7:	b8 20 00 00 00       	mov    $0x20,%eax
  8021cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021cf:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8021d2:	89 c1                	mov    %eax,%ecx
  8021d4:	d3 ea                	shr    %cl,%edx
  8021d6:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  8021da:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8021dd:	89 f8                	mov    %edi,%eax
  8021df:	8b 7d f4             	mov    -0xc(%ebp),%edi
  8021e2:	d3 e0                	shl    %cl,%eax
  8021e4:	09 c2                	or     %eax,%edx
  8021e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8021e9:	d3 e7                	shl    %cl,%edi
  8021eb:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8021ef:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8021f2:	89 f2                	mov    %esi,%edx
  8021f4:	d3 e8                	shr    %cl,%eax
  8021f6:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  8021fa:	d3 e2                	shl    %cl,%edx
  8021fc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802200:	09 d0                	or     %edx,%eax
  802202:	d3 ee                	shr    %cl,%esi
  802204:	89 f2                	mov    %esi,%edx
  802206:	f7 75 e4             	divl   -0x1c(%ebp)
  802209:	89 d1                	mov    %edx,%ecx
  80220b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80220e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802211:	f7 e7                	mul    %edi
  802213:	39 d1                	cmp    %edx,%ecx
  802215:	89 c6                	mov    %eax,%esi
  802217:	72 70                	jb     802289 <__udivdi3+0x119>
  802219:	39 ca                	cmp    %ecx,%edx
  80221b:	74 5f                	je     80227c <__udivdi3+0x10c>
  80221d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802220:	31 f6                	xor    %esi,%esi
  802222:	e9 7b ff ff ff       	jmp    8021a2 <__udivdi3+0x32>
  802227:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80222a:	85 c0                	test   %eax,%eax
  80222c:	75 0c                	jne    80223a <__udivdi3+0xca>
  80222e:	b8 01 00 00 00       	mov    $0x1,%eax
  802233:	31 d2                	xor    %edx,%edx
  802235:	f7 75 f4             	divl   -0xc(%ebp)
  802238:	89 c1                	mov    %eax,%ecx
  80223a:	89 f0                	mov    %esi,%eax
  80223c:	89 fa                	mov    %edi,%edx
  80223e:	f7 f1                	div    %ecx
  802240:	89 c6                	mov    %eax,%esi
  802242:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802245:	f7 f1                	div    %ecx
  802247:	89 c1                	mov    %eax,%ecx
  802249:	e9 54 ff ff ff       	jmp    8021a2 <__udivdi3+0x32>
  80224e:	66 90                	xchg   %ax,%ax
  802250:	39 d6                	cmp    %edx,%esi
  802252:	77 1c                	ja     802270 <__udivdi3+0x100>
  802254:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802257:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  80225a:	73 14                	jae    802270 <__udivdi3+0x100>
  80225c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802260:	31 c9                	xor    %ecx,%ecx
  802262:	31 f6                	xor    %esi,%esi
  802264:	e9 39 ff ff ff       	jmp    8021a2 <__udivdi3+0x32>
  802269:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  802270:	b9 01 00 00 00       	mov    $0x1,%ecx
  802275:	31 f6                	xor    %esi,%esi
  802277:	e9 26 ff ff ff       	jmp    8021a2 <__udivdi3+0x32>
  80227c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80227f:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  802283:	d3 e0                	shl    %cl,%eax
  802285:	39 c6                	cmp    %eax,%esi
  802287:	76 94                	jbe    80221d <__udivdi3+0xad>
  802289:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80228c:	31 f6                	xor    %esi,%esi
  80228e:	83 e9 01             	sub    $0x1,%ecx
  802291:	e9 0c ff ff ff       	jmp    8021a2 <__udivdi3+0x32>
	...

008022a0 <__umoddi3>:
  8022a0:	55                   	push   %ebp
  8022a1:	89 e5                	mov    %esp,%ebp
  8022a3:	57                   	push   %edi
  8022a4:	56                   	push   %esi
  8022a5:	83 ec 30             	sub    $0x30,%esp
  8022a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8022ab:	8b 55 14             	mov    0x14(%ebp),%edx
  8022ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8022b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8022b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8022b7:	89 c1                	mov    %eax,%ecx
  8022b9:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8022bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8022bf:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8022c6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8022cd:	89 fa                	mov    %edi,%edx
  8022cf:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8022d2:	85 c0                	test   %eax,%eax
  8022d4:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8022d7:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8022da:	75 14                	jne    8022f0 <__umoddi3+0x50>
  8022dc:	39 f9                	cmp    %edi,%ecx
  8022de:	76 60                	jbe    802340 <__umoddi3+0xa0>
  8022e0:	89 f0                	mov    %esi,%eax
  8022e2:	f7 f1                	div    %ecx
  8022e4:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8022e7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8022ee:	eb 10                	jmp    802300 <__umoddi3+0x60>
  8022f0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8022f3:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  8022f6:	76 18                	jbe    802310 <__umoddi3+0x70>
  8022f8:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8022fb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8022fe:	66 90                	xchg   %ax,%ax
  802300:	8b 45 d0             	mov    -0x30(%ebp),%eax
  802303:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  802306:	83 c4 30             	add    $0x30,%esp
  802309:	5e                   	pop    %esi
  80230a:	5f                   	pop    %edi
  80230b:	5d                   	pop    %ebp
  80230c:	c3                   	ret    
  80230d:	8d 76 00             	lea    0x0(%esi),%esi
  802310:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
  802314:	83 f0 1f             	xor    $0x1f,%eax
  802317:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80231a:	75 46                	jne    802362 <__umoddi3+0xc2>
  80231c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80231f:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  802322:	0f 87 c9 00 00 00    	ja     8023f1 <__umoddi3+0x151>
  802328:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  80232b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80232e:	0f 83 bd 00 00 00    	jae    8023f1 <__umoddi3+0x151>
  802334:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802337:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80233a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80233d:	eb c1                	jmp    802300 <__umoddi3+0x60>
  80233f:	90                   	nop    
  802340:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802343:	85 c0                	test   %eax,%eax
  802345:	75 0c                	jne    802353 <__umoddi3+0xb3>
  802347:	b8 01 00 00 00       	mov    $0x1,%eax
  80234c:	31 d2                	xor    %edx,%edx
  80234e:	f7 75 ec             	divl   -0x14(%ebp)
  802351:	89 c1                	mov    %eax,%ecx
  802353:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802356:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802359:	f7 f1                	div    %ecx
  80235b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80235e:	f7 f1                	div    %ecx
  802360:	eb 82                	jmp    8022e4 <__umoddi3+0x44>
  802362:	b8 20 00 00 00       	mov    $0x20,%eax
  802367:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80236a:	2b 45 d8             	sub    -0x28(%ebp),%eax
  80236d:	8b 75 ec             	mov    -0x14(%ebp),%esi
  802370:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802373:	89 c1                	mov    %eax,%ecx
  802375:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802378:	d3 ea                	shr    %cl,%edx
  80237a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80237d:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  802381:	d3 e0                	shl    %cl,%eax
  802383:	09 c2                	or     %eax,%edx
  802385:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802388:	d3 e6                	shl    %cl,%esi
  80238a:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  80238e:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802391:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802394:	d3 e8                	shr    %cl,%eax
  802396:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  80239a:	d3 e2                	shl    %cl,%edx
  80239c:	09 d0                	or     %edx,%eax
  80239e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8023a1:	d3 e7                	shl    %cl,%edi
  8023a3:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  8023a7:	d3 ea                	shr    %cl,%edx
  8023a9:	f7 75 f4             	divl   -0xc(%ebp)
  8023ac:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8023af:	f7 e6                	mul    %esi
  8023b1:	39 55 cc             	cmp    %edx,-0x34(%ebp)
  8023b4:	72 53                	jb     802409 <__umoddi3+0x169>
  8023b6:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  8023b9:	74 4a                	je     802405 <__umoddi3+0x165>
  8023bb:	90                   	nop    
  8023bc:	8d 74 26 00          	lea    0x0(%esi),%esi
  8023c0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8023c3:	29 c7                	sub    %eax,%edi
  8023c5:	19 d1                	sbb    %edx,%ecx
  8023c7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8023ca:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8023ce:	89 fa                	mov    %edi,%edx
  8023d0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8023d3:	d3 ea                	shr    %cl,%edx
  8023d5:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  8023d9:	d3 e0                	shl    %cl,%eax
  8023db:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8023df:	09 c2                	or     %eax,%edx
  8023e1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8023e4:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8023e7:	d3 e8                	shr    %cl,%eax
  8023e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8023ec:	e9 0f ff ff ff       	jmp    802300 <__umoddi3+0x60>
  8023f1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8023f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023f7:	2b 45 ec             	sub    -0x14(%ebp),%eax
  8023fa:	1b 55 e8             	sbb    -0x18(%ebp),%edx
  8023fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802400:	e9 2f ff ff ff       	jmp    802334 <__umoddi3+0x94>
  802405:	39 f8                	cmp    %edi,%eax
  802407:	76 b7                	jbe    8023c0 <__umoddi3+0x120>
  802409:	29 f0                	sub    %esi,%eax
  80240b:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  80240e:	eb b0                	jmp    8023c0 <__umoddi3+0x120>
