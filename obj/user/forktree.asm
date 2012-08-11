
obj/user/forktree:     file format elf32-i386

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

00800034 <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 38             	sub    $0x38,%esp
  80003a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80003d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800040:	8b 75 08             	mov    0x8(%ebp),%esi
  800043:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  800047:	89 34 24             	mov    %esi,(%esp)
  80004a:	e8 91 07 00 00       	call   8007e0 <strlen>
  80004f:	83 f8 02             	cmp    $0x2,%eax
  800052:	7f 3c                	jg     800090 <forkchild+0x5c>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  800054:	0f be c3             	movsbl %bl,%eax
  800057:	89 44 24 10          	mov    %eax,0x10(%esp)
  80005b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80005f:	c7 44 24 08 20 24 80 	movl   $0x802420,0x8(%esp)
  800066:	00 
  800067:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  80006e:	00 
  80006f:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  800072:	89 1c 24             	mov    %ebx,(%esp)
  800075:	e8 10 07 00 00       	call   80078a <snprintf>
	if (sfork() == 0) {
  80007a:	e8 b8 10 00 00       	call   801137 <sfork>
  80007f:	85 c0                	test   %eax,%eax
  800081:	75 0d                	jne    800090 <forkchild+0x5c>
		forktree(nxt);
  800083:	89 1c 24             	mov    %ebx,(%esp)
  800086:	e8 0f 00 00 00       	call   80009a <forktree>
		exit();
  80008b:	e8 c4 00 00 00       	call   800154 <exit>
	}
}
  800090:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800093:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800096:	89 ec                	mov    %ebp,%esp
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <forktree>:

void
forktree(const char *cur)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	53                   	push   %ebx
  80009e:	83 ec 14             	sub    $0x14,%esp
  8000a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  8000a4:	e8 20 0f 00 00       	call   800fc9 <sys_getenvid>
  8000a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b1:	c7 04 24 25 24 80 00 	movl   $0x802425,(%esp)
  8000b8:	e8 14 01 00 00       	call   8001d1 <cprintf>

	forkchild(cur, '0');
  8000bd:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  8000c4:	00 
  8000c5:	89 1c 24             	mov    %ebx,(%esp)
  8000c8:	e8 67 ff ff ff       	call   800034 <forkchild>
	forkchild(cur, '1');
  8000cd:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  8000d4:	00 
  8000d5:	89 1c 24             	mov    %ebx,(%esp)
  8000d8:	e8 57 ff ff ff       	call   800034 <forkchild>
}
  8000dd:	83 c4 14             	add    $0x14,%esp
  8000e0:	5b                   	pop    %ebx
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <umain>:

void
umain(void)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	83 ec 08             	sub    $0x8,%esp
	forktree("");
  8000e9:	c7 04 24 35 24 80 00 	movl   $0x802435,(%esp)
  8000f0:	e8 a5 ff ff ff       	call   80009a <forktree>
}
  8000f5:	c9                   	leave  
  8000f6:	c3                   	ret    
	...

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
  80013d:	e8 a1 ff ff ff       	call   8000e3 <umain>

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
  80015a:	e8 41 1a 00 00       	call   801ba0 <close_all>
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
  800306:	0f be 80 4d 24 80 00 	movsbl 0x80244d(%eax),%eax
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
  80049c:	c7 44 24 08 5e 24 80 	movl   $0x80245e,0x8(%esp)
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
  8004bf:	c7 44 24 08 67 24 80 	movl   $0x802467,0x8(%esp)
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
  8004f8:	c7 45 dc 6a 24 80 00 	movl   $0x80246a,-0x24(%ebp)
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
  800d16:	e8 91 11 00 00       	call   801eac <_panic>

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
  800dac:	e8 fb 10 00 00       	call   801eac <_panic>

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
  800e0a:	e8 9d 10 00 00       	call   801eac <_panic>

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
  800e68:	e8 3f 10 00 00       	call   801eac <_panic>

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
  800ec6:	e8 e1 0f 00 00       	call   801eac <_panic>

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
  800f24:	e8 83 0f 00 00       	call   801eac <_panic>

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
  800f83:	e8 24 0f 00 00       	call   801eac <_panic>

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
  801048:	e8 5f 0e 00 00       	call   801eac <_panic>

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
  8010a8:	e8 ff 0d 00 00       	call   801eac <_panic>
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
  80116b:	e8 3c 0d 00 00       	call   801eac <_panic>
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
  8011b5:	e8 5e 0d 00 00       	call   801f18 <set_pgfault_handler>
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
  801231:	e8 76 0c 00 00       	call   801eac <_panic>
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
  8012e9:	c7 44 24 04 9c 1f 80 	movl   $0x801f9c,0x4(%esp)
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
  801397:	e8 10 0b 00 00       	call   801eac <_panic>
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
  8013e6:	e8 c1 0a 00 00       	call   801eac <_panic>
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
  801426:	e8 81 0a 00 00       	call   801eac <_panic>
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
  80149d:	e8 0a 0a 00 00       	call   801eac <_panic>
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
  8014db:	e8 cc 09 00 00       	call   801eac <_panic>
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
  80150c:	e8 07 0a 00 00       	call   801f18 <set_pgfault_handler>
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
  801579:	c7 44 24 04 9c 1f 80 	movl   $0x801f9c,0x4(%esp)
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

008015b0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8015b0:	55                   	push   %ebp
  8015b1:	89 e5                	mov    %esp,%ebp
  8015b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b6:	05 00 00 00 30       	add    $0x30000000,%eax
  8015bb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8015be:	5d                   	pop    %ebp
  8015bf:	c3                   	ret    

008015c0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8015c0:	55                   	push   %ebp
  8015c1:	89 e5                	mov    %esp,%ebp
  8015c3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8015c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c9:	89 04 24             	mov    %eax,(%esp)
  8015cc:	e8 df ff ff ff       	call   8015b0 <fd2num>
  8015d1:	c1 e0 0c             	shl    $0xc,%eax
  8015d4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8015d9:	c9                   	leave  
  8015da:	c3                   	ret    

008015db <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	53                   	push   %ebx
  8015df:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8015e2:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  8015e7:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  8015e9:	89 d0                	mov    %edx,%eax
  8015eb:	c1 e8 16             	shr    $0x16,%eax
  8015ee:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015f5:	a8 01                	test   $0x1,%al
  8015f7:	74 10                	je     801609 <fd_alloc+0x2e>
  8015f9:	89 d0                	mov    %edx,%eax
  8015fb:	c1 e8 0c             	shr    $0xc,%eax
  8015fe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801605:	a8 01                	test   $0x1,%al
  801607:	75 09                	jne    801612 <fd_alloc+0x37>
			*fd_store = fd;
  801609:	89 0b                	mov    %ecx,(%ebx)
  80160b:	b8 00 00 00 00       	mov    $0x0,%eax
  801610:	eb 19                	jmp    80162b <fd_alloc+0x50>
			return 0;
  801612:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801618:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  80161e:	75 c7                	jne    8015e7 <fd_alloc+0xc>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801620:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801626:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  80162b:	5b                   	pop    %ebx
  80162c:	5d                   	pop    %ebp
  80162d:	c3                   	ret    

0080162e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80162e:	55                   	push   %ebp
  80162f:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801631:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  801635:	77 38                	ja     80166f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801637:	8b 45 08             	mov    0x8(%ebp),%eax
  80163a:	c1 e0 0c             	shl    $0xc,%eax
  80163d:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  801643:	89 d0                	mov    %edx,%eax
  801645:	c1 e8 16             	shr    $0x16,%eax
  801648:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80164f:	a8 01                	test   $0x1,%al
  801651:	74 1c                	je     80166f <fd_lookup+0x41>
  801653:	89 d0                	mov    %edx,%eax
  801655:	c1 e8 0c             	shr    $0xc,%eax
  801658:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80165f:	a8 01                	test   $0x1,%al
  801661:	74 0c                	je     80166f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801663:	8b 45 0c             	mov    0xc(%ebp),%eax
  801666:	89 10                	mov    %edx,(%eax)
  801668:	b8 00 00 00 00       	mov    $0x0,%eax
  80166d:	eb 05                	jmp    801674 <fd_lookup+0x46>
	return 0;
  80166f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801674:	5d                   	pop    %ebp
  801675:	c3                   	ret    

00801676 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801676:	55                   	push   %ebp
  801677:	89 e5                	mov    %esp,%ebp
  801679:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80167c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80167f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801683:	8b 45 08             	mov    0x8(%ebp),%eax
  801686:	89 04 24             	mov    %eax,(%esp)
  801689:	e8 a0 ff ff ff       	call   80162e <fd_lookup>
  80168e:	85 c0                	test   %eax,%eax
  801690:	78 0e                	js     8016a0 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801692:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801695:	8b 55 0c             	mov    0xc(%ebp),%edx
  801698:	89 50 04             	mov    %edx,0x4(%eax)
  80169b:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8016a0:	c9                   	leave  
  8016a1:	c3                   	ret    

008016a2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8016a2:	55                   	push   %ebp
  8016a3:	89 e5                	mov    %esp,%ebp
  8016a5:	53                   	push   %ebx
  8016a6:	83 ec 14             	sub    $0x14,%esp
  8016a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8016af:	ba 04 50 80 00       	mov    $0x805004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8016b4:	b8 00 00 00 00       	mov    $0x0,%eax
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8016b9:	39 0d 04 50 80 00    	cmp    %ecx,0x805004
  8016bf:	75 11                	jne    8016d2 <dev_lookup+0x30>
  8016c1:	eb 04                	jmp    8016c7 <dev_lookup+0x25>
  8016c3:	39 0a                	cmp    %ecx,(%edx)
  8016c5:	75 0b                	jne    8016d2 <dev_lookup+0x30>
			*dev = devtab[i];
  8016c7:	89 13                	mov    %edx,(%ebx)
  8016c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ce:	66 90                	xchg   %ax,%ax
  8016d0:	eb 35                	jmp    801707 <dev_lookup+0x65>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8016d2:	83 c0 01             	add    $0x1,%eax
  8016d5:	8b 14 85 10 29 80 00 	mov    0x802910(,%eax,4),%edx
  8016dc:	85 d2                	test   %edx,%edx
  8016de:	75 e3                	jne    8016c3 <dev_lookup+0x21>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  8016e0:	a1 20 50 80 00       	mov    0x805020,%eax
  8016e5:	8b 40 4c             	mov    0x4c(%eax),%eax
  8016e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f0:	c7 04 24 94 28 80 00 	movl   $0x802894,(%esp)
  8016f7:	e8 d5 ea ff ff       	call   8001d1 <cprintf>
	*dev = 0;
  8016fc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801702:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801707:	83 c4 14             	add    $0x14,%esp
  80170a:	5b                   	pop    %ebx
  80170b:	5d                   	pop    %ebp
  80170c:	c3                   	ret    

0080170d <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80170d:	55                   	push   %ebp
  80170e:	89 e5                	mov    %esp,%ebp
  801710:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801713:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801716:	89 44 24 04          	mov    %eax,0x4(%esp)
  80171a:	8b 45 08             	mov    0x8(%ebp),%eax
  80171d:	89 04 24             	mov    %eax,(%esp)
  801720:	e8 09 ff ff ff       	call   80162e <fd_lookup>
  801725:	89 c2                	mov    %eax,%edx
  801727:	85 c0                	test   %eax,%eax
  801729:	78 5a                	js     801785 <fstat+0x78>
  80172b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80172e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801732:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801735:	8b 00                	mov    (%eax),%eax
  801737:	89 04 24             	mov    %eax,(%esp)
  80173a:	e8 63 ff ff ff       	call   8016a2 <dev_lookup>
  80173f:	89 c2                	mov    %eax,%edx
  801741:	85 c0                	test   %eax,%eax
  801743:	78 40                	js     801785 <fstat+0x78>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801745:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  80174a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80174d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801751:	74 32                	je     801785 <fstat+0x78>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801753:	8b 45 0c             	mov    0xc(%ebp),%eax
  801756:	c6 00 00             	movb   $0x0,(%eax)
	stat->st_size = 0;
  801759:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  801760:	00 00 00 
	stat->st_isdir = 0;
  801763:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
  80176a:	00 00 00 
	stat->st_dev = dev;
  80176d:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801770:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
	return (*dev->dev_stat)(fd, stat);
  801776:	89 44 24 04          	mov    %eax,0x4(%esp)
  80177a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80177d:	89 04 24             	mov    %eax,(%esp)
  801780:	ff 52 14             	call   *0x14(%edx)
  801783:	89 c2                	mov    %eax,%edx
}
  801785:	89 d0                	mov    %edx,%eax
  801787:	c9                   	leave  
  801788:	c3                   	ret    

00801789 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801789:	55                   	push   %ebp
  80178a:	89 e5                	mov    %esp,%ebp
  80178c:	53                   	push   %ebx
  80178d:	83 ec 24             	sub    $0x24,%esp
  801790:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801793:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801796:	89 44 24 04          	mov    %eax,0x4(%esp)
  80179a:	89 1c 24             	mov    %ebx,(%esp)
  80179d:	e8 8c fe ff ff       	call   80162e <fd_lookup>
  8017a2:	85 c0                	test   %eax,%eax
  8017a4:	78 61                	js     801807 <ftruncate+0x7e>
  8017a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a9:	8b 10                	mov    (%eax),%edx
  8017ab:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8017ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b2:	89 14 24             	mov    %edx,(%esp)
  8017b5:	e8 e8 fe ff ff       	call   8016a2 <dev_lookup>
  8017ba:	85 c0                	test   %eax,%eax
  8017bc:	78 49                	js     801807 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017be:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  8017c1:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  8017c5:	75 23                	jne    8017ea <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017c7:	a1 20 50 80 00       	mov    0x805020,%eax
  8017cc:	8b 40 4c             	mov    0x4c(%eax),%eax
  8017cf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d7:	c7 04 24 b4 28 80 00 	movl   $0x8028b4,(%esp)
  8017de:	e8 ee e9 ff ff       	call   8001d1 <cprintf>
  8017e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017e8:	eb 1d                	jmp    801807 <ftruncate+0x7e>
			env->env_id, fdnum); 
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8017ea:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8017ed:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017f2:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  8017f6:	74 0f                	je     801807 <ftruncate+0x7e>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017f8:	8b 42 18             	mov    0x18(%edx),%eax
  8017fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  801802:	89 0c 24             	mov    %ecx,(%esp)
  801805:	ff d0                	call   *%eax
}
  801807:	83 c4 24             	add    $0x24,%esp
  80180a:	5b                   	pop    %ebx
  80180b:	5d                   	pop    %ebp
  80180c:	c3                   	ret    

0080180d <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80180d:	55                   	push   %ebp
  80180e:	89 e5                	mov    %esp,%ebp
  801810:	53                   	push   %ebx
  801811:	83 ec 24             	sub    $0x24,%esp
  801814:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801817:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181e:	89 1c 24             	mov    %ebx,(%esp)
  801821:	e8 08 fe ff ff       	call   80162e <fd_lookup>
  801826:	85 c0                	test   %eax,%eax
  801828:	78 68                	js     801892 <write+0x85>
  80182a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80182d:	8b 10                	mov    (%eax),%edx
  80182f:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801832:	89 44 24 04          	mov    %eax,0x4(%esp)
  801836:	89 14 24             	mov    %edx,(%esp)
  801839:	e8 64 fe ff ff       	call   8016a2 <dev_lookup>
  80183e:	85 c0                	test   %eax,%eax
  801840:	78 50                	js     801892 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801842:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801845:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801849:	75 23                	jne    80186e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  80184b:	a1 20 50 80 00       	mov    0x805020,%eax
  801850:	8b 40 4c             	mov    0x4c(%eax),%eax
  801853:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801857:	89 44 24 04          	mov    %eax,0x4(%esp)
  80185b:	c7 04 24 d5 28 80 00 	movl   $0x8028d5,(%esp)
  801862:	e8 6a e9 ff ff       	call   8001d1 <cprintf>
  801867:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80186c:	eb 24                	jmp    801892 <write+0x85>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80186e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801871:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801876:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  80187a:	74 16                	je     801892 <write+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80187c:	8b 42 0c             	mov    0xc(%edx),%eax
  80187f:	8b 55 10             	mov    0x10(%ebp),%edx
  801882:	89 54 24 08          	mov    %edx,0x8(%esp)
  801886:	8b 55 0c             	mov    0xc(%ebp),%edx
  801889:	89 54 24 04          	mov    %edx,0x4(%esp)
  80188d:	89 0c 24             	mov    %ecx,(%esp)
  801890:	ff d0                	call   *%eax
}
  801892:	83 c4 24             	add    $0x24,%esp
  801895:	5b                   	pop    %ebx
  801896:	5d                   	pop    %ebp
  801897:	c3                   	ret    

00801898 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	53                   	push   %ebx
  80189c:	83 ec 24             	sub    $0x24,%esp
  80189f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a9:	89 1c 24             	mov    %ebx,(%esp)
  8018ac:	e8 7d fd ff ff       	call   80162e <fd_lookup>
  8018b1:	85 c0                	test   %eax,%eax
  8018b3:	78 6d                	js     801922 <read+0x8a>
  8018b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b8:	8b 10                	mov    (%eax),%edx
  8018ba:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8018bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c1:	89 14 24             	mov    %edx,(%esp)
  8018c4:	e8 d9 fd ff ff       	call   8016a2 <dev_lookup>
  8018c9:	85 c0                	test   %eax,%eax
  8018cb:	78 55                	js     801922 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8018cd:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  8018d0:	8b 41 08             	mov    0x8(%ecx),%eax
  8018d3:	83 e0 03             	and    $0x3,%eax
  8018d6:	83 f8 01             	cmp    $0x1,%eax
  8018d9:	75 23                	jne    8018fe <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  8018db:	a1 20 50 80 00       	mov    0x805020,%eax
  8018e0:	8b 40 4c             	mov    0x4c(%eax),%eax
  8018e3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018eb:	c7 04 24 f2 28 80 00 	movl   $0x8028f2,(%esp)
  8018f2:	e8 da e8 ff ff       	call   8001d1 <cprintf>
  8018f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018fc:	eb 24                	jmp    801922 <read+0x8a>
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8018fe:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801901:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801906:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  80190a:	74 16                	je     801922 <read+0x8a>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80190c:	8b 42 08             	mov    0x8(%edx),%eax
  80190f:	8b 55 10             	mov    0x10(%ebp),%edx
  801912:	89 54 24 08          	mov    %edx,0x8(%esp)
  801916:	8b 55 0c             	mov    0xc(%ebp),%edx
  801919:	89 54 24 04          	mov    %edx,0x4(%esp)
  80191d:	89 0c 24             	mov    %ecx,(%esp)
  801920:	ff d0                	call   *%eax
}
  801922:	83 c4 24             	add    $0x24,%esp
  801925:	5b                   	pop    %ebx
  801926:	5d                   	pop    %ebp
  801927:	c3                   	ret    

00801928 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801928:	55                   	push   %ebp
  801929:	89 e5                	mov    %esp,%ebp
  80192b:	57                   	push   %edi
  80192c:	56                   	push   %esi
  80192d:	53                   	push   %ebx
  80192e:	83 ec 0c             	sub    $0xc,%esp
  801931:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801934:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801937:	b8 00 00 00 00       	mov    $0x0,%eax
  80193c:	85 f6                	test   %esi,%esi
  80193e:	74 36                	je     801976 <readn+0x4e>
  801940:	bb 00 00 00 00       	mov    $0x0,%ebx
  801945:	ba 00 00 00 00       	mov    $0x0,%edx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80194a:	89 f0                	mov    %esi,%eax
  80194c:	29 d0                	sub    %edx,%eax
  80194e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801952:	8d 04 17             	lea    (%edi,%edx,1),%eax
  801955:	89 44 24 04          	mov    %eax,0x4(%esp)
  801959:	8b 45 08             	mov    0x8(%ebp),%eax
  80195c:	89 04 24             	mov    %eax,(%esp)
  80195f:	e8 34 ff ff ff       	call   801898 <read>
		if (m < 0)
  801964:	85 c0                	test   %eax,%eax
  801966:	78 0e                	js     801976 <readn+0x4e>
			return m;
		if (m == 0)
  801968:	85 c0                	test   %eax,%eax
  80196a:	74 08                	je     801974 <readn+0x4c>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80196c:	01 c3                	add    %eax,%ebx
  80196e:	89 da                	mov    %ebx,%edx
  801970:	39 f3                	cmp    %esi,%ebx
  801972:	72 d6                	jb     80194a <readn+0x22>
  801974:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801976:	83 c4 0c             	add    $0xc,%esp
  801979:	5b                   	pop    %ebx
  80197a:	5e                   	pop    %esi
  80197b:	5f                   	pop    %edi
  80197c:	5d                   	pop    %ebp
  80197d:	c3                   	ret    

0080197e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80197e:	55                   	push   %ebp
  80197f:	89 e5                	mov    %esp,%ebp
  801981:	83 ec 28             	sub    $0x28,%esp
  801984:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801987:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80198a:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80198d:	89 34 24             	mov    %esi,(%esp)
  801990:	e8 1b fc ff ff       	call   8015b0 <fd2num>
  801995:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801998:	89 54 24 04          	mov    %edx,0x4(%esp)
  80199c:	89 04 24             	mov    %eax,(%esp)
  80199f:	e8 8a fc ff ff       	call   80162e <fd_lookup>
  8019a4:	89 c3                	mov    %eax,%ebx
  8019a6:	85 c0                	test   %eax,%eax
  8019a8:	78 05                	js     8019af <fd_close+0x31>
  8019aa:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8019ad:	74 0d                	je     8019bc <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8019af:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019b3:	75 44                	jne    8019f9 <fd_close+0x7b>
  8019b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019ba:	eb 3d                	jmp    8019f9 <fd_close+0x7b>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8019bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c3:	8b 06                	mov    (%esi),%eax
  8019c5:	89 04 24             	mov    %eax,(%esp)
  8019c8:	e8 d5 fc ff ff       	call   8016a2 <dev_lookup>
  8019cd:	89 c3                	mov    %eax,%ebx
  8019cf:	85 c0                	test   %eax,%eax
  8019d1:	78 16                	js     8019e9 <fd_close+0x6b>
		if (dev->dev_close)
  8019d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019d6:	8b 40 10             	mov    0x10(%eax),%eax
  8019d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019de:	85 c0                	test   %eax,%eax
  8019e0:	74 07                	je     8019e9 <fd_close+0x6b>
			r = (*dev->dev_close)(fd);
  8019e2:	89 34 24             	mov    %esi,(%esp)
  8019e5:	ff d0                	call   *%eax
  8019e7:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8019e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019f4:	e8 81 f4 ff ff       	call   800e7a <sys_page_unmap>
	return r;
}
  8019f9:	89 d8                	mov    %ebx,%eax
  8019fb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8019fe:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801a01:	89 ec                	mov    %ebp,%esp
  801a03:	5d                   	pop    %ebp
  801a04:	c3                   	ret    

00801a05 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801a05:	55                   	push   %ebp
  801a06:	89 e5                	mov    %esp,%ebp
  801a08:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a0b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801a0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a12:	8b 45 08             	mov    0x8(%ebp),%eax
  801a15:	89 04 24             	mov    %eax,(%esp)
  801a18:	e8 11 fc ff ff       	call   80162e <fd_lookup>
  801a1d:	85 c0                	test   %eax,%eax
  801a1f:	78 13                	js     801a34 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801a21:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a28:	00 
  801a29:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801a2c:	89 04 24             	mov    %eax,(%esp)
  801a2f:	e8 4a ff ff ff       	call   80197e <fd_close>
}
  801a34:	c9                   	leave  
  801a35:	c3                   	ret    

00801a36 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801a36:	55                   	push   %ebp
  801a37:	89 e5                	mov    %esp,%ebp
  801a39:	83 ec 18             	sub    $0x18,%esp
  801a3c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a3f:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a42:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a49:	00 
  801a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4d:	89 04 24             	mov    %eax,(%esp)
  801a50:	e8 6a 03 00 00       	call   801dbf <open>
  801a55:	89 c6                	mov    %eax,%esi
  801a57:	85 c0                	test   %eax,%eax
  801a59:	78 1b                	js     801a76 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801a5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a62:	89 34 24             	mov    %esi,(%esp)
  801a65:	e8 a3 fc ff ff       	call   80170d <fstat>
  801a6a:	89 c3                	mov    %eax,%ebx
	close(fd);
  801a6c:	89 34 24             	mov    %esi,(%esp)
  801a6f:	e8 91 ff ff ff       	call   801a05 <close>
  801a74:	89 de                	mov    %ebx,%esi
	return r;
}
  801a76:	89 f0                	mov    %esi,%eax
  801a78:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801a7b:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801a7e:	89 ec                	mov    %ebp,%esp
  801a80:	5d                   	pop    %ebp
  801a81:	c3                   	ret    

00801a82 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	83 ec 38             	sub    $0x38,%esp
  801a88:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801a8b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801a8e:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801a91:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801a94:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a97:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9e:	89 04 24             	mov    %eax,(%esp)
  801aa1:	e8 88 fb ff ff       	call   80162e <fd_lookup>
  801aa6:	89 c3                	mov    %eax,%ebx
  801aa8:	85 c0                	test   %eax,%eax
  801aaa:	0f 88 e1 00 00 00    	js     801b91 <dup+0x10f>
		return r;
	close(newfdnum);
  801ab0:	89 3c 24             	mov    %edi,(%esp)
  801ab3:	e8 4d ff ff ff       	call   801a05 <close>

	newfd = INDEX2FD(newfdnum);
  801ab8:	89 f8                	mov    %edi,%eax
  801aba:	c1 e0 0c             	shl    $0xc,%eax
  801abd:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  801ac3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ac6:	89 04 24             	mov    %eax,(%esp)
  801ac9:	e8 f2 fa ff ff       	call   8015c0 <fd2data>
  801ace:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801ad0:	89 34 24             	mov    %esi,(%esp)
  801ad3:	e8 e8 fa ff ff       	call   8015c0 <fd2data>
  801ad8:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  801adb:	89 d8                	mov    %ebx,%eax
  801add:	c1 e8 16             	shr    $0x16,%eax
  801ae0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ae7:	a8 01                	test   $0x1,%al
  801ae9:	74 45                	je     801b30 <dup+0xae>
  801aeb:	89 da                	mov    %ebx,%edx
  801aed:	c1 ea 0c             	shr    $0xc,%edx
  801af0:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801af7:	a8 01                	test   $0x1,%al
  801af9:	74 35                	je     801b30 <dup+0xae>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  801afb:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801b02:	25 07 0e 00 00       	and    $0xe07,%eax
  801b07:	89 44 24 10          	mov    %eax,0x10(%esp)
  801b0b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b12:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b19:	00 
  801b1a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b1e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b25:	e8 ae f3 ff ff       	call   800ed8 <sys_page_map>
  801b2a:	89 c3                	mov    %eax,%ebx
  801b2c:	85 c0                	test   %eax,%eax
  801b2e:	78 3e                	js     801b6e <dup+0xec>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  801b30:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b33:	89 d0                	mov    %edx,%eax
  801b35:	c1 e8 0c             	shr    $0xc,%eax
  801b38:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b3f:	25 07 0e 00 00       	and    $0xe07,%eax
  801b44:	89 44 24 10          	mov    %eax,0x10(%esp)
  801b48:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801b4c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b53:	00 
  801b54:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b58:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b5f:	e8 74 f3 ff ff       	call   800ed8 <sys_page_map>
  801b64:	89 c3                	mov    %eax,%ebx
  801b66:	85 c0                	test   %eax,%eax
  801b68:	78 04                	js     801b6e <dup+0xec>
		goto err;
  801b6a:	89 fb                	mov    %edi,%ebx
  801b6c:	eb 23                	jmp    801b91 <dup+0x10f>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801b6e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b72:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b79:	e8 fc f2 ff ff       	call   800e7a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801b7e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b81:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b8c:	e8 e9 f2 ff ff       	call   800e7a <sys_page_unmap>
	return r;
}
  801b91:	89 d8                	mov    %ebx,%eax
  801b93:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801b96:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801b99:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b9c:	89 ec                	mov    %ebp,%esp
  801b9e:	5d                   	pop    %ebp
  801b9f:	c3                   	ret    

00801ba0 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801ba0:	55                   	push   %ebp
  801ba1:	89 e5                	mov    %esp,%ebp
  801ba3:	53                   	push   %ebx
  801ba4:	83 ec 04             	sub    $0x4,%esp
  801ba7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801bac:	89 1c 24             	mov    %ebx,(%esp)
  801baf:	e8 51 fe ff ff       	call   801a05 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801bb4:	83 c3 01             	add    $0x1,%ebx
  801bb7:	83 fb 20             	cmp    $0x20,%ebx
  801bba:	75 f0                	jne    801bac <close_all+0xc>
		close(i);
}
  801bbc:	83 c4 04             	add    $0x4,%esp
  801bbf:	5b                   	pop    %ebx
  801bc0:	5d                   	pop    %ebp
  801bc1:	c3                   	ret    
	...

00801bc4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801bc4:	55                   	push   %ebp
  801bc5:	89 e5                	mov    %esp,%ebp
  801bc7:	53                   	push   %ebx
  801bc8:	83 ec 14             	sub    $0x14,%esp
  801bcb:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801bcd:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  801bd3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801bda:	00 
  801bdb:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801be2:	00 
  801be3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be7:	89 14 24             	mov    %edx,(%esp)
  801bea:	e8 e1 03 00 00       	call   801fd0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801bef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bf6:	00 
  801bf7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bfb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c02:	e8 7d 04 00 00       	call   802084 <ipc_recv>
}
  801c07:	83 c4 14             	add    $0x14,%esp
  801c0a:	5b                   	pop    %ebx
  801c0b:	5d                   	pop    %ebp
  801c0c:	c3                   	ret    

00801c0d <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801c0d:	55                   	push   %ebp
  801c0e:	89 e5                	mov    %esp,%ebp
  801c10:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c13:	ba 00 00 00 00       	mov    $0x0,%edx
  801c18:	b8 08 00 00 00       	mov    $0x8,%eax
  801c1d:	e8 a2 ff ff ff       	call   801bc4 <fsipc>
}
  801c22:	c9                   	leave  
  801c23:	c3                   	ret    

00801c24 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801c24:	55                   	push   %ebp
  801c25:	89 e5                	mov    %esp,%ebp
  801c27:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801c2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2d:	8b 40 0c             	mov    0xc(%eax),%eax
  801c30:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.set_size.req_size = newsize;
  801c35:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c38:	a3 04 30 80 00       	mov    %eax,0x803004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801c3d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c42:	b8 02 00 00 00       	mov    $0x2,%eax
  801c47:	e8 78 ff ff ff       	call   801bc4 <fsipc>
}
  801c4c:	c9                   	leave  
  801c4d:	c3                   	ret    

00801c4e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801c4e:	55                   	push   %ebp
  801c4f:	89 e5                	mov    %esp,%ebp
  801c51:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c54:	8b 45 08             	mov    0x8(%ebp),%eax
  801c57:	8b 40 0c             	mov    0xc(%eax),%eax
  801c5a:	a3 00 30 80 00       	mov    %eax,0x803000
	return fsipc(FSREQ_FLUSH, NULL);
  801c5f:	ba 00 00 00 00       	mov    $0x0,%edx
  801c64:	b8 06 00 00 00       	mov    $0x6,%eax
  801c69:	e8 56 ff ff ff       	call   801bc4 <fsipc>
}
  801c6e:	c9                   	leave  
  801c6f:	c3                   	ret    

00801c70 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801c70:	55                   	push   %ebp
  801c71:	89 e5                	mov    %esp,%ebp
  801c73:	53                   	push   %ebx
  801c74:	83 ec 14             	sub    $0x14,%esp
  801c77:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801c7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7d:	8b 40 0c             	mov    0xc(%eax),%eax
  801c80:	a3 00 30 80 00       	mov    %eax,0x803000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801c85:	ba 00 00 00 00       	mov    $0x0,%edx
  801c8a:	b8 05 00 00 00       	mov    $0x5,%eax
  801c8f:	e8 30 ff ff ff       	call   801bc4 <fsipc>
  801c94:	85 c0                	test   %eax,%eax
  801c96:	78 2b                	js     801cc3 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801c98:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801c9f:	00 
  801ca0:	89 1c 24             	mov    %ebx,(%esp)
  801ca3:	e8 89 eb ff ff       	call   800831 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ca8:	a1 80 30 80 00       	mov    0x803080,%eax
  801cad:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801cb3:	a1 84 30 80 00       	mov    0x803084,%eax
  801cb8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801cbe:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801cc3:	83 c4 14             	add    $0x14,%esp
  801cc6:	5b                   	pop    %ebx
  801cc7:	5d                   	pop    %ebp
  801cc8:	c3                   	ret    

00801cc9 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801cc9:	55                   	push   %ebp
  801cca:	89 e5                	mov    %esp,%ebp
  801ccc:	83 ec 18             	sub    $0x18,%esp
  801ccf:	8b 55 10             	mov    0x10(%ebp),%edx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	ssize_t writesize;
	size_t bufsize;
	fsipcbuf.write.req_fileid=fd->fd_file.id;
  801cd2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd5:	8b 40 0c             	mov    0xc(%eax),%eax
  801cd8:	a3 00 30 80 00       	mov    %eax,0x803000
	bufsize=sizeof(fsipcbuf.write.req_buf);
	if(n<bufsize)
  801cdd:	89 d0                	mov    %edx,%eax
  801cdf:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  801ce5:	76 05                	jbe    801cec <devfile_write+0x23>
  801ce7:	b8 f8 0f 00 00       	mov    $0xff8,%eax
		bufsize=n;	
	fsipcbuf.write.req_n=n;
  801cec:	89 15 04 30 80 00    	mov    %edx,0x803004
	memmove((void*)fsipcbuf.write.req_buf,buf,bufsize);
  801cf2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cf6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cfd:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  801d04:	e8 2f ed ff ff       	call   800a38 <memmove>
	writesize=(ssize_t)fsipc(FSREQ_WRITE,NULL);
  801d09:	ba 00 00 00 00       	mov    $0x0,%edx
  801d0e:	b8 04 00 00 00       	mov    $0x4,%eax
  801d13:	e8 ac fe ff ff       	call   801bc4 <fsipc>
	return writesize;
	//panic("devfile_write not implemented");
}
  801d18:	c9                   	leave  
  801d19:	c3                   	ret    

00801d1a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801d1a:	55                   	push   %ebp
  801d1b:	89 e5                	mov    %esp,%ebp
  801d1d:	53                   	push   %ebx
  801d1e:	83 ec 14             	sub    $0x14,%esp
	// system server.
	// LAB 5: Your code here
	ssize_t readsize;
	if(debug)
		cprintf("devfile_read:fileid=%x readsize=%x\n",fd->fd_file.id,n);
	fsipcbuf.read.req_fileid=fd->fd_file.id;
  801d21:	8b 45 08             	mov    0x8(%ebp),%eax
  801d24:	8b 40 0c             	mov    0xc(%eax),%eax
  801d27:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.read.req_n=n;
  801d2c:	8b 45 10             	mov    0x10(%ebp),%eax
  801d2f:	a3 04 30 80 00       	mov    %eax,0x803004
	readsize=(ssize_t)fsipc(FSREQ_READ,&fsipcbuf);
  801d34:	ba 00 30 80 00       	mov    $0x803000,%edx
  801d39:	b8 03 00 00 00       	mov    $0x3,%eax
  801d3e:	e8 81 fe ff ff       	call   801bc4 <fsipc>
  801d43:	89 c3                	mov    %eax,%ebx
	cprintf("readsize=%d\n",readsize);
  801d45:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d49:	c7 04 24 18 29 80 00 	movl   $0x802918,(%esp)
  801d50:	e8 7c e4 ff ff       	call   8001d1 <cprintf>
	if(debug)
		cprintf("devfile_read:buf1=%s\nbuf2=%s\n",(char*)&fsipcbuf,fsipcbuf.readRet.ret_buf);
	if(readsize>0)
  801d55:	85 db                	test   %ebx,%ebx
  801d57:	7e 17                	jle    801d70 <devfile_read+0x56>
		memmove(buf,(void*)&fsipcbuf,(size_t)readsize);
  801d59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d5d:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801d64:	00 
  801d65:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d68:	89 04 24             	mov    %eax,(%esp)
  801d6b:	e8 c8 ec ff ff       	call   800a38 <memmove>
	//cprintf("readsize=%d",readsize);
	return readsize;
	//panic("devfile_read not implemented");
}
  801d70:	89 d8                	mov    %ebx,%eax
  801d72:	83 c4 14             	add    $0x14,%esp
  801d75:	5b                   	pop    %ebx
  801d76:	5d                   	pop    %ebp
  801d77:	c3                   	ret    

00801d78 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801d78:	55                   	push   %ebp
  801d79:	89 e5                	mov    %esp,%ebp
  801d7b:	53                   	push   %ebx
  801d7c:	83 ec 14             	sub    $0x14,%esp
  801d7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801d82:	89 1c 24             	mov    %ebx,(%esp)
  801d85:	e8 56 ea ff ff       	call   8007e0 <strlen>
  801d8a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  801d8f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801d94:	7f 21                	jg     801db7 <remove+0x3f>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801d96:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d9a:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801da1:	e8 8b ea ff ff       	call   800831 <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801da6:	ba 00 00 00 00       	mov    $0x0,%edx
  801dab:	b8 07 00 00 00       	mov    $0x7,%eax
  801db0:	e8 0f fe ff ff       	call   801bc4 <fsipc>
  801db5:	89 c2                	mov    %eax,%edx
}
  801db7:	89 d0                	mov    %edx,%eax
  801db9:	83 c4 14             	add    $0x14,%esp
  801dbc:	5b                   	pop    %ebx
  801dbd:	5d                   	pop    %ebp
  801dbe:	c3                   	ret    

00801dbf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801dbf:	55                   	push   %ebp
  801dc0:	89 e5                	mov    %esp,%ebp
  801dc2:	53                   	push   %ebx
  801dc3:	83 ec 24             	sub    $0x24,%esp
	// file descriptor.

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;
	if((r=fd_alloc(&fd))<0){
  801dc6:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801dc9:	89 04 24             	mov    %eax,(%esp)
  801dcc:	e8 0a f8 ff ff       	call   8015db <fd_alloc>
  801dd1:	89 c3                	mov    %eax,%ebx
  801dd3:	85 c0                	test   %eax,%eax
  801dd5:	79 18                	jns    801def <open+0x30>
		fd_close(fd,0);
  801dd7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801dde:	00 
  801ddf:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801de2:	89 04 24             	mov    %eax,(%esp)
  801de5:	e8 94 fb ff ff       	call   80197e <fd_close>
  801dea:	e9 b4 00 00 00       	jmp    801ea3 <open+0xe4>
		return r;
	}
	cprintf("open:fd=%x\n",fd);
  801def:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801df2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801df6:	c7 04 24 25 29 80 00 	movl   $0x802925,(%esp)
  801dfd:	e8 cf e3 ff ff       	call   8001d1 <cprintf>
	strcpy(fsipcbuf.open.req_path,path);
  801e02:	8b 45 08             	mov    0x8(%ebp),%eax
  801e05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e09:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801e10:	e8 1c ea ff ff       	call   800831 <strcpy>
	fsipcbuf.open.req_omode=mode;
  801e15:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e18:	a3 00 34 80 00       	mov    %eax,0x803400
	if((r=fsipc(FSREQ_OPEN,(void*)fd))<0)
  801e1d:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801e20:	b8 01 00 00 00       	mov    $0x1,%eax
  801e25:	e8 9a fd ff ff       	call   801bc4 <fsipc>
  801e2a:	89 c3                	mov    %eax,%ebx
  801e2c:	85 c0                	test   %eax,%eax
  801e2e:	79 15                	jns    801e45 <open+0x86>
	{
		fd_close(fd,1);
  801e30:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801e37:	00 
  801e38:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801e3b:	89 04 24             	mov    %eax,(%esp)
  801e3e:	e8 3b fb ff ff       	call   80197e <fd_close>
  801e43:	eb 5e                	jmp    801ea3 <open+0xe4>
		return r;	
	}
	if((r=sys_page_map(0,(void*)fd,0,(void*)fd,PTE_P | PTE_W | PTE_U))<0)
  801e45:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801e48:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801e4f:	00 
  801e50:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e54:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e5b:	00 
  801e5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e60:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e67:	e8 6c f0 ff ff       	call   800ed8 <sys_page_map>
  801e6c:	89 c3                	mov    %eax,%ebx
  801e6e:	85 c0                	test   %eax,%eax
  801e70:	79 15                	jns    801e87 <open+0xc8>
	{
		fd_close(fd,1);
  801e72:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801e79:	00 
  801e7a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801e7d:	89 04 24             	mov    %eax,(%esp)
  801e80:	e8 f9 fa ff ff       	call   80197e <fd_close>
  801e85:	eb 1c                	jmp    801ea3 <open+0xe4>
		return r;
	}
	//INDEX2DATA(fd->fd_file.id);
	cprintf("fileid=%x\n",fd->fd_file.id);
  801e87:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801e8a:	8b 40 0c             	mov    0xc(%eax),%eax
  801e8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e91:	c7 04 24 31 29 80 00 	movl   $0x802931,(%esp)
  801e98:	e8 34 e3 ff ff       	call   8001d1 <cprintf>
	return fd->fd_file.id;
  801e9d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801ea0:	8b 58 0c             	mov    0xc(%eax),%ebx
	//panic("open not implemented");
}
  801ea3:	89 d8                	mov    %ebx,%eax
  801ea5:	83 c4 24             	add    $0x24,%esp
  801ea8:	5b                   	pop    %ebx
  801ea9:	5d                   	pop    %ebp
  801eaa:	c3                   	ret    
	...

00801eac <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  801eac:	55                   	push   %ebp
  801ead:	89 e5                	mov    %esp,%ebp
  801eaf:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  801eb2:	8d 45 14             	lea    0x14(%ebp),%eax
  801eb5:	89 45 fc             	mov    %eax,-0x4(%ebp)

	// Print the panic message
	if (argv0)
  801eb8:	a1 24 50 80 00       	mov    0x805024,%eax
  801ebd:	85 c0                	test   %eax,%eax
  801ebf:	74 10                	je     801ed1 <_panic+0x25>
		cprintf("%s: ", argv0);
  801ec1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec5:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  801ecc:	e8 00 e3 ff ff       	call   8001d1 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  801ed1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ed4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ed8:	8b 45 08             	mov    0x8(%ebp),%eax
  801edb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801edf:	a1 00 50 80 00       	mov    0x805000,%eax
  801ee4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ee8:	c7 04 24 41 29 80 00 	movl   $0x802941,(%esp)
  801eef:	e8 dd e2 ff ff       	call   8001d1 <cprintf>
	vcprintf(fmt, ap);
  801ef4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801ef7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801efb:	8b 45 10             	mov    0x10(%ebp),%eax
  801efe:	89 04 24             	mov    %eax,(%esp)
  801f01:	e8 6a e2 ff ff       	call   800170 <vcprintf>
	cprintf("\n");
  801f06:	c7 04 24 34 24 80 00 	movl   $0x802434,(%esp)
  801f0d:	e8 bf e2 ff ff       	call   8001d1 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f12:	cc                   	int3   
  801f13:	eb fd                	jmp    801f12 <_panic+0x66>
  801f15:	00 00                	add    %al,(%eax)
	...

00801f18 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f18:	55                   	push   %ebp
  801f19:	89 e5                	mov    %esp,%ebp
  801f1b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f1e:	83 3d 28 50 80 00 00 	cmpl   $0x0,0x805028
  801f25:	75 6a                	jne    801f91 <set_pgfault_handler+0x79>
		// First time through!
		// LAB 4: Your code here.
		env=(struct Env*)&envs[ENVX(sys_getenvid())];
  801f27:	e8 9d f0 ff ff       	call   800fc9 <sys_getenvid>
  801f2c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801f31:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f34:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f39:	a3 20 50 80 00       	mov    %eax,0x805020
		if((r=sys_page_alloc(env->env_id,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  801f3e:	8b 40 4c             	mov    0x4c(%eax),%eax
  801f41:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801f48:	00 
  801f49:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801f50:	ee 
  801f51:	89 04 24             	mov    %eax,(%esp)
  801f54:	e8 dd ef ff ff       	call   800f36 <sys_page_alloc>
  801f59:	85 c0                	test   %eax,%eax
  801f5b:	79 1c                	jns    801f79 <set_pgfault_handler+0x61>
		{
			panic("Alloc a page for an exception stack failed");
  801f5d:	c7 44 24 08 60 29 80 	movl   $0x802960,0x8(%esp)
  801f64:	00 
  801f65:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801f6c:	00 
  801f6d:	c7 04 24 8c 29 80 00 	movl   $0x80298c,(%esp)
  801f74:	e8 33 ff ff ff       	call   801eac <_panic>
		}
		sys_env_set_pgfault_upcall(env->env_id,(void*)_pgfault_upcall);
  801f79:	a1 20 50 80 00       	mov    0x805020,%eax
  801f7e:	8b 40 4c             	mov    0x4c(%eax),%eax
  801f81:	c7 44 24 04 9c 1f 80 	movl   $0x801f9c,0x4(%esp)
  801f88:	00 
  801f89:	89 04 24             	mov    %eax,(%esp)
  801f8c:	e8 cf ed ff ff       	call   800d60 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f91:	8b 45 08             	mov    0x8(%ebp),%eax
  801f94:	a3 28 50 80 00       	mov    %eax,0x805028
}
  801f99:	c9                   	leave  
  801f9a:	c3                   	ret    
	...

00801f9c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f9c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f9d:	a1 28 50 80 00       	mov    0x805028,%eax
	call *%eax
  801fa2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fa4:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.这个有点难度，需要认真编写
	movl  0x28(%esp),%eax //把utf->utf_eip入栈
  801fa7:	8b 44 24 28          	mov    0x28(%esp),%eax
	pushl %eax
  801fab:	50                   	push   %eax
	movl %esp,%eax
  801fac:	89 e0                	mov    %esp,%eax
	movl 0x34(%eax),%esp  //切换到用户普通栈，压入utf_eip
  801fae:	8b 60 34             	mov    0x34(%eax),%esp
	pushl (%eax)
  801fb1:	ff 30                	pushl  (%eax)
	movl %eax,%esp	     //切到用户异常栈
  801fb3:	89 c4                	mov    %eax,%esp
	subl $0x4,0x34(%esp) //将utf->utf_esp减去4,指向返回地址,后面不能算术操作，就在这算
  801fb5:	83 6c 24 34 04       	subl   $0x4,0x34(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0xc,%esp     //恢复通用寄存器
  801fba:	83 c4 0c             	add    $0xc,%esp
	popal
  801fbd:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp  //恢复eflags
  801fbe:	83 c4 04             	add    $0x4,%esp
	popfl          //在用户态，该指令能否修改eflags?可以的
  801fc1:	9d                   	popf   
		       //执行完这个指令后，不能进行算术任何算术运算哦，否则eflags里面的值不对
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp     //切换到用户普通栈，用户从异常处理退出后，需要继续使用该栈
  801fc2:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801fc3:	c3                   	ret    
	...

00801fd0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fd0:	55                   	push   %ebp
  801fd1:	89 e5                	mov    %esp,%ebp
  801fd3:	57                   	push   %edi
  801fd4:	56                   	push   %esi
  801fd5:	53                   	push   %ebx
  801fd6:	83 ec 1c             	sub    $0x1c,%esp
  801fd9:	8b 75 08             	mov    0x8(%ebp),%esi
  801fdc:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  801fdf:	e8 e5 ef ff ff       	call   800fc9 <sys_getenvid>
  801fe4:	25 ff 03 00 00       	and    $0x3ff,%eax
  801fe9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fec:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ff1:	a3 20 50 80 00       	mov    %eax,0x805020
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  801ff6:	e8 ce ef ff ff       	call   800fc9 <sys_getenvid>
  801ffb:	25 ff 03 00 00       	and    $0x3ff,%eax
  802000:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802003:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802008:	a3 20 50 80 00       	mov    %eax,0x805020
		if(env->env_id==to_env){
  80200d:	8b 40 4c             	mov    0x4c(%eax),%eax
  802010:	39 f0                	cmp    %esi,%eax
  802012:	75 0e                	jne    802022 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  802014:	c7 04 24 9a 29 80 00 	movl   $0x80299a,(%esp)
  80201b:	e8 b1 e1 ff ff       	call   8001d1 <cprintf>
  802020:	eb 5a                	jmp    80207c <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  802022:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802026:	8b 45 10             	mov    0x10(%ebp),%eax
  802029:	89 44 24 08          	mov    %eax,0x8(%esp)
  80202d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802030:	89 44 24 04          	mov    %eax,0x4(%esp)
  802034:	89 34 24             	mov    %esi,(%esp)
  802037:	e8 ec ec ff ff       	call   800d28 <sys_ipc_try_send>
  80203c:	89 c3                	mov    %eax,%ebx
  80203e:	85 c0                	test   %eax,%eax
  802040:	79 25                	jns    802067 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  802042:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802045:	74 2b                	je     802072 <ipc_send+0xa2>
				panic("send error:%e",r);
  802047:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80204b:	c7 44 24 08 b6 29 80 	movl   $0x8029b6,0x8(%esp)
  802052:	00 
  802053:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80205a:	00 
  80205b:	c7 04 24 c4 29 80 00 	movl   $0x8029c4,(%esp)
  802062:	e8 45 fe ff ff       	call   801eac <_panic>
		}
			sys_yield();
  802067:	e8 29 ef ff ff       	call   800f95 <sys_yield>
		
	}while(r!=0);
  80206c:	85 db                	test   %ebx,%ebx
  80206e:	75 86                	jne    801ff6 <ipc_send+0x26>
  802070:	eb 0a                	jmp    80207c <ipc_send+0xac>
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
		{	
			if(r!=-E_IPC_NOT_RECV)
				panic("send error:%e",r);
		}
			sys_yield();
  802072:	e8 1e ef ff ff       	call   800f95 <sys_yield>
  802077:	e9 7a ff ff ff       	jmp    801ff6 <ipc_send+0x26>
		
	}while(r!=0);
	return;
	//panic("ipc_send not implemented");
}
  80207c:	83 c4 1c             	add    $0x1c,%esp
  80207f:	5b                   	pop    %ebx
  802080:	5e                   	pop    %esi
  802081:	5f                   	pop    %edi
  802082:	5d                   	pop    %ebp
  802083:	c3                   	ret    

00802084 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802084:	55                   	push   %ebp
  802085:	89 e5                	mov    %esp,%ebp
  802087:	57                   	push   %edi
  802088:	56                   	push   %esi
  802089:	53                   	push   %ebx
  80208a:	83 ec 0c             	sub    $0xc,%esp
  80208d:	8b 75 08             	mov    0x8(%ebp),%esi
  802090:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	void *dstva=NULL;
	if(pg)
		dstva=pg;
	env = &envs[ENVX(sys_getenvid())];
  802093:	e8 31 ef ff ff       	call   800fc9 <sys_getenvid>
  802098:	25 ff 03 00 00       	and    $0x3ff,%eax
  80209d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020a0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020a5:	a3 20 50 80 00       	mov    %eax,0x805020
	if(from_env_store&&(env->env_id==*from_env_store))
  8020aa:	85 f6                	test   %esi,%esi
  8020ac:	74 29                	je     8020d7 <ipc_recv+0x53>
  8020ae:	8b 40 4c             	mov    0x4c(%eax),%eax
  8020b1:	3b 06                	cmp    (%esi),%eax
  8020b3:	75 22                	jne    8020d7 <ipc_recv+0x53>
	{
		*from_env_store=0;
  8020b5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  8020bb:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("send:the reciver is sender\n");
  8020c1:	c7 04 24 9a 29 80 00 	movl   $0x80299a,(%esp)
  8020c8:	e8 04 e1 ff ff       	call   8001d1 <cprintf>
  8020cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020d2:	e9 8a 00 00 00       	jmp    802161 <ipc_recv+0xdd>
		return 0;
	}
	env = &envs[ENVX(sys_getenvid())];
  8020d7:	e8 ed ee ff ff       	call   800fc9 <sys_getenvid>
  8020dc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8020e1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020e4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020e9:	a3 20 50 80 00       	mov    %eax,0x805020
	if((r=sys_ipc_recv(dstva))<0)
  8020ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020f1:	89 04 24             	mov    %eax,(%esp)
  8020f4:	e8 d2 eb ff ff       	call   800ccb <sys_ipc_recv>
  8020f9:	89 c3                	mov    %eax,%ebx
  8020fb:	85 c0                	test   %eax,%eax
  8020fd:	79 1a                	jns    802119 <ipc_recv+0x95>
	{
		*from_env_store=0;
  8020ff:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  802105:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("reciver failed\n");
  80210b:	c7 04 24 ce 29 80 00 	movl   $0x8029ce,(%esp)
  802112:	e8 ba e0 ff ff       	call   8001d1 <cprintf>
  802117:	eb 48                	jmp    802161 <ipc_recv+0xdd>
		return r;
	}
	else{//接收成功
		env = &envs[ENVX(sys_getenvid())];
  802119:	e8 ab ee ff ff       	call   800fc9 <sys_getenvid>
  80211e:	25 ff 03 00 00       	and    $0x3ff,%eax
  802123:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802126:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80212b:	a3 20 50 80 00       	mov    %eax,0x805020
		if(from_env_store)
  802130:	85 f6                	test   %esi,%esi
  802132:	74 05                	je     802139 <ipc_recv+0xb5>
			*from_env_store=env->env_ipc_from;	
  802134:	8b 40 74             	mov    0x74(%eax),%eax
  802137:	89 06                	mov    %eax,(%esi)
		if(perm_store)
  802139:	85 ff                	test   %edi,%edi
  80213b:	74 0a                	je     802147 <ipc_recv+0xc3>
			*perm_store=env->env_ipc_perm;
  80213d:	a1 20 50 80 00       	mov    0x805020,%eax
  802142:	8b 40 78             	mov    0x78(%eax),%eax
  802145:	89 07                	mov    %eax,(%edi)
		env = &envs[ENVX(sys_getenvid())];
  802147:	e8 7d ee ff ff       	call   800fc9 <sys_getenvid>
  80214c:	25 ff 03 00 00       	and    $0x3ff,%eax
  802151:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802154:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802159:	a3 20 50 80 00       	mov    %eax,0x805020
		return env->env_ipc_value;
  80215e:	8b 58 70             	mov    0x70(%eax),%ebx
	}
	//panic("ipc_recv not implemented");
	return 0;
}
  802161:	89 d8                	mov    %ebx,%eax
  802163:	83 c4 0c             	add    $0xc,%esp
  802166:	5b                   	pop    %ebx
  802167:	5e                   	pop    %esi
  802168:	5f                   	pop    %edi
  802169:	5d                   	pop    %ebp
  80216a:	c3                   	ret    
  80216b:	00 00                	add    %al,(%eax)
  80216d:	00 00                	add    %al,(%eax)
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
