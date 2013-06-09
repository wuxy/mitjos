
obj/user/forktree:     file format elf32-i386

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
  80003a:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  80003d:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  800040:	8b 75 08             	mov    0x8(%ebp),%esi
  800043:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  800047:	89 34 24             	mov    %esi,(%esp)
  80004a:	e8 b1 07 00 00       	call   800800 <strlen>
  80004f:	83 f8 02             	cmp    $0x2,%eax
  800052:	7f 3c                	jg     800090 <forkchild+0x5c>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  800054:	0f be c3             	movsbl %bl,%eax
  800057:	89 44 24 10          	mov    %eax,0x10(%esp)
  80005b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80005f:	c7 44 24 08 40 29 80 	movl   $0x802940,0x8(%esp)
  800066:	00 
  800067:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  80006e:	00 
  80006f:	8d 5d f4             	lea    0xfffffff4(%ebp),%ebx
  800072:	89 1c 24             	mov    %ebx,(%esp)
  800075:	e8 25 07 00 00       	call   80079f <snprintf>
	if (sfork() == 0) {
  80007a:	e8 f8 10 00 00       	call   801177 <sfork>
  80007f:	85 c0                	test   %eax,%eax
  800081:	75 0d                	jne    800090 <forkchild+0x5c>
		forktree(nxt);
  800083:	89 1c 24             	mov    %ebx,(%esp)
  800086:	e8 0f 00 00 00       	call   80009a <forktree>
		exit();
  80008b:	e8 c4 00 00 00       	call   800154 <exit>
	}
}
  800090:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  800093:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
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
  8000a4:	e8 64 0f 00 00       	call   80100d <sys_getenvid>
  8000a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b1:	c7 04 24 45 29 80 00 	movl   $0x802945,(%esp)
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
  8000e9:	c7 04 24 55 29 80 00 	movl   $0x802955,(%esp)
  8000f0:	e8 a5 ff ff ff       	call   80009a <forktree>
}
  8000f5:	c9                   	leave  
  8000f6:	c3                   	ret    
	...

008000f8 <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	83 ec 18             	sub    $0x18,%esp
  8000fe:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  800101:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  800104:	8b 75 08             	mov    0x8(%ebp),%esi
  800107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  80010a:	c7 05 3c 60 80 00 00 	movl   $0x0,0x80603c
  800111:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  800114:	e8 f4 0e 00 00       	call   80100d <sys_getenvid>
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

	// call user main routine调用用户主例程
	umain(argc, argv);
  800136:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80013a:	89 34 24             	mov    %esi,(%esp)
  80013d:	e8 a1 ff ff ff       	call   8000e3 <umain>

	// exit gracefully
	exit();
  800142:	e8 0d 00 00 00       	call   800154 <exit>
}
  800147:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  80014a:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
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
  80015a:	e8 87 1a 00 00       	call   801be6 <close_all>
	sys_env_destroy(0);
  80015f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800166:	e8 d6 0e 00 00       	call   801041 <sys_env_destroy>
}
  80016b:	c9                   	leave  
  80016c:	c3                   	ret    
  80016d:	00 00                	add    %al,(%eax)
	...

00800170 <vcprintf>:
}

int
vcprintf(const char *fmt, va_list ap)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800179:	c7 85 f8 fe ff ff 00 	movl   $0x0,0xfffffef8(%ebp)
  800180:	00 00 00 
	b.cnt = 0;
  800183:	c7 85 fc fe ff ff 00 	movl   $0x0,0xfffffefc(%ebp)
  80018a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80018d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800190:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800194:	8b 45 08             	mov    0x8(%ebp),%eax
  800197:	89 44 24 08          	mov    %eax,0x8(%esp)
  80019b:	8d 85 f8 fe ff ff    	lea    0xfffffef8(%ebp),%eax
  8001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a5:	c7 04 24 ee 01 80 00 	movl   $0x8001ee,(%esp)
  8001ac:	e8 c0 01 00 00       	call   800371 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b1:	8b 85 f8 fe ff ff    	mov    0xfffffef8(%ebp),%eax
  8001b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bb:	8d 85 00 ff ff ff    	lea    0xffffff00(%ebp),%eax
  8001c1:	89 04 24             	mov    %eax,(%esp)
  8001c4:	e8 df 0a 00 00       	call   800ca8 <sys_cputs>
  8001c9:	8b 85 fc fe ff ff    	mov    0xfffffefc(%ebp),%eax

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
  8001da:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
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
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	53                   	push   %ebx
  8001f2:	83 ec 14             	sub    $0x14,%esp
  8001f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001f8:	8b 03                	mov    (%ebx),%eax
  8001fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fd:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800201:	83 c0 01             	add    $0x1,%eax
  800204:	89 03                	mov    %eax,(%ebx)
  800206:	3d ff 00 00 00       	cmp    $0xff,%eax
  80020b:	75 19                	jne    800226 <putch+0x38>
  80020d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800214:	00 
  800215:	8d 43 08             	lea    0x8(%ebx),%eax
  800218:	89 04 24             	mov    %eax,(%esp)
  80021b:	e8 88 0a 00 00       	call   800ca8 <sys_cputs>
  800220:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800226:	83 43 04 01          	addl   $0x1,0x4(%ebx)
  80022a:	83 c4 14             	add    $0x14,%esp
  80022d:	5b                   	pop    %ebx
  80022e:	5d                   	pop    %ebp
  80022f:	c3                   	ret    

00800230 <printnum>:
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
  800239:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  80023c:	89 d7                	mov    %edx,%edi
  80023e:	8b 45 08             	mov    0x8(%ebp),%eax
  800241:	8b 55 0c             	mov    0xc(%ebp),%edx
  800244:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800247:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  80024a:	8b 55 10             	mov    0x10(%ebp),%edx
  80024d:	8b 45 14             	mov    0x14(%ebp),%eax
  800250:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800253:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  800256:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  80025d:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800260:	39 4d ec             	cmp    %ecx,0xffffffec(%ebp)
  800263:	72 11                	jb     800276 <printnum+0x46>
  800265:	8b 4d d8             	mov    0xffffffd8(%ebp),%ecx
  800268:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  80026b:	76 09                	jbe    800276 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80026d:	8d 58 ff             	lea    0xffffffff(%eax),%ebx
  800270:	85 db                	test   %ebx,%ebx
  800272:	7f 54                	jg     8002c8 <printnum+0x98>
  800274:	eb 61                	jmp    8002d7 <printnum+0xa7>
  800276:	89 74 24 10          	mov    %esi,0x10(%esp)
  80027a:	83 e8 01             	sub    $0x1,%eax
  80027d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800281:	89 54 24 08          	mov    %edx,0x8(%esp)
  800285:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800289:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80028d:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800290:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800293:	89 44 24 08          	mov    %eax,0x8(%esp)
  800297:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80029b:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  80029e:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  8002a1:	89 14 24             	mov    %edx,(%esp)
  8002a4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8002a8:	e8 d3 23 00 00       	call   802680 <__udivdi3>
  8002ad:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002b1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002b5:	89 04 24             	mov    %eax,(%esp)
  8002b8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002bc:	89 fa                	mov    %edi,%edx
  8002be:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  8002c1:	e8 6a ff ff ff       	call   800230 <printnum>
  8002c6:	eb 0f                	jmp    8002d7 <printnum+0xa7>
			putch(padc, putdat);
  8002c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002cc:	89 34 24             	mov    %esi,(%esp)
  8002cf:	ff 55 e4             	call   *0xffffffe4(%ebp)
  8002d2:	83 eb 01             	sub    $0x1,%ebx
  8002d5:	75 f1                	jne    8002c8 <printnum+0x98>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002d7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002db:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002df:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8002e2:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  8002e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002ed:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  8002f0:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  8002f3:	89 14 24             	mov    %edx,(%esp)
  8002f6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8002fa:	e8 b1 24 00 00       	call   8027b0 <__umoddi3>
  8002ff:	89 74 24 04          	mov    %esi,0x4(%esp)
  800303:	0f be 80 6d 29 80 00 	movsbl 0x80296d(%eax),%eax
  80030a:	89 04 24             	mov    %eax,(%esp)
  80030d:	ff 55 e4             	call   *0xffffffe4(%ebp)
}
  800310:	83 c4 3c             	add    $0x3c,%esp
  800313:	5b                   	pop    %ebx
  800314:	5e                   	pop    %esi
  800315:	5f                   	pop    %edi
  800316:	5d                   	pop    %ebp
  800317:	c3                   	ret    

00800318 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  80031d:	83 fa 01             	cmp    $0x1,%edx
  800320:	7e 0e                	jle    800330 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  800322:	8b 10                	mov    (%eax),%edx
  800324:	8d 42 08             	lea    0x8(%edx),%eax
  800327:	89 01                	mov    %eax,(%ecx)
  800329:	8b 02                	mov    (%edx),%eax
  80032b:	8b 52 04             	mov    0x4(%edx),%edx
  80032e:	eb 22                	jmp    800352 <getuint+0x3a>
	else if (lflag)
  800330:	85 d2                	test   %edx,%edx
  800332:	74 10                	je     800344 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800334:	8b 10                	mov    (%eax),%edx
  800336:	8d 42 04             	lea    0x4(%edx),%eax
  800339:	89 01                	mov    %eax,(%ecx)
  80033b:	8b 02                	mov    (%edx),%eax
  80033d:	ba 00 00 00 00       	mov    $0x0,%edx
  800342:	eb 0e                	jmp    800352 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800344:	8b 10                	mov    (%eax),%edx
  800346:	8d 42 04             	lea    0x4(%edx),%eax
  800349:	89 01                	mov    %eax,(%ecx)
  80034b:	8b 02                	mov    (%edx),%eax
  80034d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <sprintputch>:

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
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  80035a:	83 41 08 01          	addl   $0x1,0x8(%ecx)
	if (b->buf < b->ebuf)
  80035e:	8b 11                	mov    (%ecx),%edx
  800360:	3b 51 04             	cmp    0x4(%ecx),%edx
  800363:	73 0a                	jae    80036f <sprintputch+0x1b>
		*b->buf++ = ch;
  800365:	8b 45 08             	mov    0x8(%ebp),%eax
  800368:	88 02                	mov    %al,(%edx)
  80036a:	8d 42 01             	lea    0x1(%edx),%eax
  80036d:	89 01                	mov    %eax,(%ecx)
}
  80036f:	5d                   	pop    %ebp
  800370:	c3                   	ret    

00800371 <vprintfmt>:
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	57                   	push   %edi
  800375:	56                   	push   %esi
  800376:	53                   	push   %ebx
  800377:	83 ec 4c             	sub    $0x4c,%esp
  80037a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80037d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800380:	eb 03                	jmp    800385 <vprintfmt+0x14>
  800382:	8b 5d e8             	mov    0xffffffe8(%ebp),%ebx
  800385:	0f b6 03             	movzbl (%ebx),%eax
  800388:	83 c3 01             	add    $0x1,%ebx
  80038b:	3c 25                	cmp    $0x25,%al
  80038d:	74 30                	je     8003bf <vprintfmt+0x4e>
  80038f:	84 c0                	test   %al,%al
  800391:	0f 84 a8 03 00 00    	je     80073f <vprintfmt+0x3ce>
  800397:	0f b6 d0             	movzbl %al,%edx
  80039a:	eb 0a                	jmp    8003a6 <vprintfmt+0x35>
  80039c:	84 c0                	test   %al,%al
  80039e:	66 90                	xchg   %ax,%ax
  8003a0:	0f 84 99 03 00 00    	je     80073f <vprintfmt+0x3ce>
  8003a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ad:	89 14 24             	mov    %edx,(%esp)
  8003b0:	ff d7                	call   *%edi
  8003b2:	0f b6 03             	movzbl (%ebx),%eax
  8003b5:	0f b6 d0             	movzbl %al,%edx
  8003b8:	83 c3 01             	add    $0x1,%ebx
  8003bb:	3c 25                	cmp    $0x25,%al
  8003bd:	75 dd                	jne    80039c <vprintfmt+0x2b>
  8003bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c4:	c7 45 ec ff ff ff ff 	movl   $0xffffffff,0xffffffec(%ebp)
  8003cb:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  8003d2:	c7 45 dc 00 00 00 00 	movl   $0x0,0xffffffdc(%ebp)
  8003d9:	c6 45 e3 20          	movb   $0x20,0xffffffe3(%ebp)
  8003dd:	eb 07                	jmp    8003e6 <vprintfmt+0x75>
  8003df:	c7 45 dc 01 00 00 00 	movl   $0x1,0xffffffdc(%ebp)
  8003e6:	0f b6 03             	movzbl (%ebx),%eax
  8003e9:	0f b6 d0             	movzbl %al,%edx
  8003ec:	83 c3 01             	add    $0x1,%ebx
  8003ef:	83 e8 23             	sub    $0x23,%eax
  8003f2:	3c 55                	cmp    $0x55,%al
  8003f4:	0f 87 11 03 00 00    	ja     80070b <vprintfmt+0x39a>
  8003fa:	0f b6 c0             	movzbl %al,%eax
  8003fd:	ff 24 85 a0 2a 80 00 	jmp    *0x802aa0(,%eax,4)
  800404:	c6 45 e3 30          	movb   $0x30,0xffffffe3(%ebp)
  800408:	eb dc                	jmp    8003e6 <vprintfmt+0x75>
  80040a:	83 ea 30             	sub    $0x30,%edx
  80040d:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  800410:	0f be 13             	movsbl (%ebx),%edx
  800413:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800416:	83 f8 09             	cmp    $0x9,%eax
  800419:	76 08                	jbe    800423 <vprintfmt+0xb2>
  80041b:	eb 42                	jmp    80045f <vprintfmt+0xee>
  80041d:	c6 45 e3 2d          	movb   $0x2d,0xffffffe3(%ebp)
  800421:	eb c3                	jmp    8003e6 <vprintfmt+0x75>
  800423:	83 c3 01             	add    $0x1,%ebx
  800426:	8b 75 e4             	mov    0xffffffe4(%ebp),%esi
  800429:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  80042c:	8d 44 42 d0          	lea    0xffffffd0(%edx,%eax,2),%eax
  800430:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  800433:	0f be 13             	movsbl (%ebx),%edx
  800436:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800439:	83 f8 09             	cmp    $0x9,%eax
  80043c:	77 21                	ja     80045f <vprintfmt+0xee>
  80043e:	eb e3                	jmp    800423 <vprintfmt+0xb2>
  800440:	8b 55 14             	mov    0x14(%ebp),%edx
  800443:	8d 42 04             	lea    0x4(%edx),%eax
  800446:	89 45 14             	mov    %eax,0x14(%ebp)
  800449:	8b 12                	mov    (%edx),%edx
  80044b:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  80044e:	eb 0f                	jmp    80045f <vprintfmt+0xee>
  800450:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800454:	79 90                	jns    8003e6 <vprintfmt+0x75>
  800456:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  80045d:	eb 87                	jmp    8003e6 <vprintfmt+0x75>
  80045f:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800463:	79 81                	jns    8003e6 <vprintfmt+0x75>
  800465:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  800468:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  80046b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  800472:	e9 6f ff ff ff       	jmp    8003e6 <vprintfmt+0x75>
  800477:	83 c1 01             	add    $0x1,%ecx
  80047a:	e9 67 ff ff ff       	jmp    8003e6 <vprintfmt+0x75>
  80047f:	8b 45 14             	mov    0x14(%ebp),%eax
  800482:	8d 50 04             	lea    0x4(%eax),%edx
  800485:	89 55 14             	mov    %edx,0x14(%ebp)
  800488:	8b 55 0c             	mov    0xc(%ebp),%edx
  80048b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80048f:	8b 00                	mov    (%eax),%eax
  800491:	89 04 24             	mov    %eax,(%esp)
  800494:	ff d7                	call   *%edi
  800496:	e9 ea fe ff ff       	jmp    800385 <vprintfmt+0x14>
  80049b:	8b 55 14             	mov    0x14(%ebp),%edx
  80049e:	8d 42 04             	lea    0x4(%edx),%eax
  8004a1:	89 45 14             	mov    %eax,0x14(%ebp)
  8004a4:	8b 02                	mov    (%edx),%eax
  8004a6:	89 c2                	mov    %eax,%edx
  8004a8:	c1 fa 1f             	sar    $0x1f,%edx
  8004ab:	31 d0                	xor    %edx,%eax
  8004ad:	29 d0                	sub    %edx,%eax
  8004af:	83 f8 0f             	cmp    $0xf,%eax
  8004b2:	7f 0b                	jg     8004bf <vprintfmt+0x14e>
  8004b4:	8b 14 85 00 2c 80 00 	mov    0x802c00(,%eax,4),%edx
  8004bb:	85 d2                	test   %edx,%edx
  8004bd:	75 20                	jne    8004df <vprintfmt+0x16e>
  8004bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004c3:	c7 44 24 08 7e 29 80 	movl   $0x80297e,0x8(%esp)
  8004ca:	00 
  8004cb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004d2:	89 3c 24             	mov    %edi,(%esp)
  8004d5:	e8 f0 02 00 00       	call   8007ca <printfmt>
  8004da:	e9 a6 fe ff ff       	jmp    800385 <vprintfmt+0x14>
  8004df:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004e3:	c7 44 24 08 46 2e 80 	movl   $0x802e46,0x8(%esp)
  8004ea:	00 
  8004eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f2:	89 3c 24             	mov    %edi,(%esp)
  8004f5:	e8 d0 02 00 00       	call   8007ca <printfmt>
  8004fa:	e9 86 fe ff ff       	jmp    800385 <vprintfmt+0x14>
  8004ff:	8b 75 ec             	mov    0xffffffec(%ebp),%esi
  800502:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  800505:	89 5d e8             	mov    %ebx,0xffffffe8(%ebp)
  800508:	8b 55 14             	mov    0x14(%ebp),%edx
  80050b:	8d 42 04             	lea    0x4(%edx),%eax
  80050e:	89 45 14             	mov    %eax,0x14(%ebp)
  800511:	8b 12                	mov    (%edx),%edx
  800513:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  800516:	85 d2                	test   %edx,%edx
  800518:	75 07                	jne    800521 <vprintfmt+0x1b0>
  80051a:	c7 45 d8 87 29 80 00 	movl   $0x802987,0xffffffd8(%ebp)
  800521:	85 f6                	test   %esi,%esi
  800523:	7e 40                	jle    800565 <vprintfmt+0x1f4>
  800525:	80 7d e3 2d          	cmpb   $0x2d,0xffffffe3(%ebp)
  800529:	74 3a                	je     800565 <vprintfmt+0x1f4>
  80052b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80052f:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800532:	89 14 24             	mov    %edx,(%esp)
  800535:	e8 e6 02 00 00       	call   800820 <strnlen>
  80053a:	29 c6                	sub    %eax,%esi
  80053c:	89 75 ec             	mov    %esi,0xffffffec(%ebp)
  80053f:	85 f6                	test   %esi,%esi
  800541:	7e 22                	jle    800565 <vprintfmt+0x1f4>
  800543:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  800547:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  80054a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80054d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800551:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  800554:	89 04 24             	mov    %eax,(%esp)
  800557:	ff d7                	call   *%edi
  800559:	83 ee 01             	sub    $0x1,%esi
  80055c:	75 ec                	jne    80054a <vprintfmt+0x1d9>
  80055e:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  800565:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800568:	0f b6 02             	movzbl (%edx),%eax
  80056b:	0f be d0             	movsbl %al,%edx
  80056e:	8b 75 d8             	mov    0xffffffd8(%ebp),%esi
  800571:	84 c0                	test   %al,%al
  800573:	75 40                	jne    8005b5 <vprintfmt+0x244>
  800575:	eb 4a                	jmp    8005c1 <vprintfmt+0x250>
  800577:	83 7d dc 00          	cmpl   $0x0,0xffffffdc(%ebp)
  80057b:	74 1a                	je     800597 <vprintfmt+0x226>
  80057d:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  800580:	83 f8 5e             	cmp    $0x5e,%eax
  800583:	76 12                	jbe    800597 <vprintfmt+0x226>
  800585:	8b 45 0c             	mov    0xc(%ebp),%eax
  800588:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800593:	ff d7                	call   *%edi
  800595:	eb 0c                	jmp    8005a3 <vprintfmt+0x232>
  800597:	8b 45 0c             	mov    0xc(%ebp),%eax
  80059a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059e:	89 14 24             	mov    %edx,(%esp)
  8005a1:	ff d7                	call   *%edi
  8005a3:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  8005a7:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8005ab:	83 c6 01             	add    $0x1,%esi
  8005ae:	84 c0                	test   %al,%al
  8005b0:	74 0f                	je     8005c1 <vprintfmt+0x250>
  8005b2:	0f be d0             	movsbl %al,%edx
  8005b5:	83 7d e4 00          	cmpl   $0x0,0xffffffe4(%ebp)
  8005b9:	78 bc                	js     800577 <vprintfmt+0x206>
  8005bb:	83 6d e4 01          	subl   $0x1,0xffffffe4(%ebp)
  8005bf:	79 b6                	jns    800577 <vprintfmt+0x206>
  8005c1:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  8005c5:	0f 8e ba fd ff ff    	jle    800385 <vprintfmt+0x14>
  8005cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005d2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005d9:	ff d7                	call   *%edi
  8005db:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  8005df:	0f 84 9d fd ff ff    	je     800382 <vprintfmt+0x11>
  8005e5:	eb e4                	jmp    8005cb <vprintfmt+0x25a>
  8005e7:	83 f9 01             	cmp    $0x1,%ecx
  8005ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8005f0:	7e 10                	jle    800602 <vprintfmt+0x291>
  8005f2:	8b 55 14             	mov    0x14(%ebp),%edx
  8005f5:	8d 42 08             	lea    0x8(%edx),%eax
  8005f8:	89 45 14             	mov    %eax,0x14(%ebp)
  8005fb:	8b 02                	mov    (%edx),%eax
  8005fd:	8b 52 04             	mov    0x4(%edx),%edx
  800600:	eb 26                	jmp    800628 <vprintfmt+0x2b7>
  800602:	85 c9                	test   %ecx,%ecx
  800604:	74 12                	je     800618 <vprintfmt+0x2a7>
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8d 50 04             	lea    0x4(%eax),%edx
  80060c:	89 55 14             	mov    %edx,0x14(%ebp)
  80060f:	8b 00                	mov    (%eax),%eax
  800611:	89 c2                	mov    %eax,%edx
  800613:	c1 fa 1f             	sar    $0x1f,%edx
  800616:	eb 10                	jmp    800628 <vprintfmt+0x2b7>
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8d 50 04             	lea    0x4(%eax),%edx
  80061e:	89 55 14             	mov    %edx,0x14(%ebp)
  800621:	8b 00                	mov    (%eax),%eax
  800623:	89 c2                	mov    %eax,%edx
  800625:	c1 fa 1f             	sar    $0x1f,%edx
  800628:	89 d1                	mov    %edx,%ecx
  80062a:	89 c2                	mov    %eax,%edx
  80062c:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  80062f:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  800632:	be 0a 00 00 00       	mov    $0xa,%esi
  800637:	85 c9                	test   %ecx,%ecx
  800639:	0f 89 92 00 00 00    	jns    8006d1 <vprintfmt+0x360>
  80063f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800642:	89 74 24 04          	mov    %esi,0x4(%esp)
  800646:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80064d:	ff d7                	call   *%edi
  80064f:	8b 55 d0             	mov    0xffffffd0(%ebp),%edx
  800652:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
  800655:	f7 da                	neg    %edx
  800657:	83 d1 00             	adc    $0x0,%ecx
  80065a:	f7 d9                	neg    %ecx
  80065c:	be 0a 00 00 00       	mov    $0xa,%esi
  800661:	eb 6e                	jmp    8006d1 <vprintfmt+0x360>
  800663:	8d 45 14             	lea    0x14(%ebp),%eax
  800666:	89 ca                	mov    %ecx,%edx
  800668:	e8 ab fc ff ff       	call   800318 <getuint>
  80066d:	89 d1                	mov    %edx,%ecx
  80066f:	89 c2                	mov    %eax,%edx
  800671:	be 0a 00 00 00       	mov    $0xa,%esi
  800676:	eb 59                	jmp    8006d1 <vprintfmt+0x360>
  800678:	8d 45 14             	lea    0x14(%ebp),%eax
  80067b:	89 ca                	mov    %ecx,%edx
  80067d:	e8 96 fc ff ff       	call   800318 <getuint>
  800682:	e9 fe fc ff ff       	jmp    800385 <vprintfmt+0x14>
  800687:	8b 45 0c             	mov    0xc(%ebp),%eax
  80068a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80068e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800695:	ff d7                	call   *%edi
  800697:	8b 55 0c             	mov    0xc(%ebp),%edx
  80069a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80069e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006a5:	ff d7                	call   *%edi
  8006a7:	8b 55 14             	mov    0x14(%ebp),%edx
  8006aa:	8d 42 04             	lea    0x4(%edx),%eax
  8006ad:	89 45 14             	mov    %eax,0x14(%ebp)
  8006b0:	8b 12                	mov    (%edx),%edx
  8006b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b7:	be 10 00 00 00       	mov    $0x10,%esi
  8006bc:	eb 13                	jmp    8006d1 <vprintfmt+0x360>
  8006be:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c1:	89 ca                	mov    %ecx,%edx
  8006c3:	e8 50 fc ff ff       	call   800318 <getuint>
  8006c8:	89 d1                	mov    %edx,%ecx
  8006ca:	89 c2                	mov    %eax,%edx
  8006cc:	be 10 00 00 00       	mov    $0x10,%esi
  8006d1:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  8006d5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006d9:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  8006dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006e0:	89 74 24 08          	mov    %esi,0x8(%esp)
  8006e4:	89 14 24             	mov    %edx,(%esp)
  8006e7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006ee:	89 f8                	mov    %edi,%eax
  8006f0:	e8 3b fb ff ff       	call   800230 <printnum>
  8006f5:	e9 8b fc ff ff       	jmp    800385 <vprintfmt+0x14>
  8006fa:	8b 75 0c             	mov    0xc(%ebp),%esi
  8006fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  800701:	89 14 24             	mov    %edx,(%esp)
  800704:	ff d7                	call   *%edi
  800706:	e9 7a fc ff ff       	jmp    800385 <vprintfmt+0x14>
  80070b:	89 de                	mov    %ebx,%esi
  80070d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800710:	89 44 24 04          	mov    %eax,0x4(%esp)
  800714:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80071b:	ff d7                	call   *%edi
  80071d:	83 eb 01             	sub    $0x1,%ebx
  800720:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  800724:	0f 84 5b fc ff ff    	je     800385 <vprintfmt+0x14>
  80072a:	8d 56 fd             	lea    0xfffffffd(%esi),%edx
  80072d:	0f b6 02             	movzbl (%edx),%eax
  800730:	83 ea 01             	sub    $0x1,%edx
  800733:	3c 25                	cmp    $0x25,%al
  800735:	75 f6                	jne    80072d <vprintfmt+0x3bc>
  800737:	8d 5a 02             	lea    0x2(%edx),%ebx
  80073a:	e9 46 fc ff ff       	jmp    800385 <vprintfmt+0x14>
  80073f:	83 c4 4c             	add    $0x4c,%esp
  800742:	5b                   	pop    %ebx
  800743:	5e                   	pop    %esi
  800744:	5f                   	pop    %edi
  800745:	5d                   	pop    %ebp
  800746:	c3                   	ret    

00800747 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	83 ec 28             	sub    $0x28,%esp
  80074d:	8b 55 08             	mov    0x8(%ebp),%edx
  800750:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800753:	85 d2                	test   %edx,%edx
  800755:	74 04                	je     80075b <vsnprintf+0x14>
  800757:	85 c0                	test   %eax,%eax
  800759:	7f 07                	jg     800762 <vsnprintf+0x1b>
  80075b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800760:	eb 3b                	jmp    80079d <vsnprintf+0x56>
  800762:	c7 45 fc 00 00 00 00 	movl   $0x0,0xfffffffc(%ebp)
  800769:	8d 44 02 ff          	lea    0xffffffff(%edx,%eax,1),%eax
  80076d:	89 45 f8             	mov    %eax,0xfffffff8(%ebp)
  800770:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800773:	8b 45 14             	mov    0x14(%ebp),%eax
  800776:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80077a:	8b 45 10             	mov    0x10(%ebp),%eax
  80077d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800781:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  800784:	89 44 24 04          	mov    %eax,0x4(%esp)
  800788:	c7 04 24 54 03 80 00 	movl   $0x800354,(%esp)
  80078f:	e8 dd fb ff ff       	call   800371 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800794:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  800797:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079a:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
}
  80079d:	c9                   	leave  
  80079e:	c3                   	ret    

0080079f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a5:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a8:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8007ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007af:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c0:	89 04 24             	mov    %eax,(%esp)
  8007c3:	e8 7f ff ff ff       	call   800747 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c8:	c9                   	leave  
  8007c9:	c3                   	ret    

008007ca <printfmt>:
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	83 ec 28             	sub    $0x28,%esp
  8007d0:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d3:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
  8007d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007da:	8b 45 10             	mov    0x10(%ebp),%eax
  8007dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007eb:	89 04 24             	mov    %eax,(%esp)
  8007ee:	e8 7e fb ff ff       	call   800371 <vprintfmt>
  8007f3:	c9                   	leave  
  8007f4:	c3                   	ret    
	...

00800800 <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800806:	b8 00 00 00 00       	mov    $0x0,%eax
  80080b:	80 3a 00             	cmpb   $0x0,(%edx)
  80080e:	74 0e                	je     80081e <strlen+0x1e>
  800810:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800815:	83 c0 01             	add    $0x1,%eax
  800818:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  80081c:	75 f7                	jne    800815 <strlen+0x15>
	return n;
}
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800826:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800829:	85 d2                	test   %edx,%edx
  80082b:	74 19                	je     800846 <strnlen+0x26>
  80082d:	80 39 00             	cmpb   $0x0,(%ecx)
  800830:	74 14                	je     800846 <strnlen+0x26>
  800832:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800837:	83 c0 01             	add    $0x1,%eax
  80083a:	39 d0                	cmp    %edx,%eax
  80083c:	74 0d                	je     80084b <strnlen+0x2b>
  80083e:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800842:	74 07                	je     80084b <strnlen+0x2b>
  800844:	eb f1                	jmp    800837 <strnlen+0x17>
  800846:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  80084b:	5d                   	pop    %ebp
  80084c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800850:	c3                   	ret    

00800851 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	53                   	push   %ebx
  800855:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800858:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085b:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80085d:	0f b6 01             	movzbl (%ecx),%eax
  800860:	88 02                	mov    %al,(%edx)
  800862:	83 c2 01             	add    $0x1,%edx
  800865:	83 c1 01             	add    $0x1,%ecx
  800868:	84 c0                	test   %al,%al
  80086a:	75 f1                	jne    80085d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80086c:	89 d8                	mov    %ebx,%eax
  80086e:	5b                   	pop    %ebx
  80086f:	5d                   	pop    %ebp
  800870:	c3                   	ret    

00800871 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	57                   	push   %edi
  800875:	56                   	push   %esi
  800876:	53                   	push   %ebx
  800877:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800880:	85 f6                	test   %esi,%esi
  800882:	74 1c                	je     8008a0 <strncpy+0x2f>
  800884:	89 fa                	mov    %edi,%edx
  800886:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  80088b:	0f b6 01             	movzbl (%ecx),%eax
  80088e:	88 02                	mov    %al,(%edx)
  800890:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800893:	80 39 01             	cmpb   $0x1,(%ecx)
  800896:	83 d9 ff             	sbb    $0xffffffff,%ecx
  800899:	83 c3 01             	add    $0x1,%ebx
  80089c:	39 f3                	cmp    %esi,%ebx
  80089e:	75 eb                	jne    80088b <strncpy+0x1a>
	}
	return ret;
}
  8008a0:	89 f8                	mov    %edi,%eax
  8008a2:	5b                   	pop    %ebx
  8008a3:	5e                   	pop    %esi
  8008a4:	5f                   	pop    %edi
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	56                   	push   %esi
  8008ab:	53                   	push   %ebx
  8008ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8008af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b2:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b5:	89 f0                	mov    %esi,%eax
  8008b7:	85 d2                	test   %edx,%edx
  8008b9:	74 2c                	je     8008e7 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  8008bb:	89 d3                	mov    %edx,%ebx
  8008bd:	83 eb 01             	sub    $0x1,%ebx
  8008c0:	74 20                	je     8008e2 <strlcpy+0x3b>
  8008c2:	0f b6 11             	movzbl (%ecx),%edx
  8008c5:	84 d2                	test   %dl,%dl
  8008c7:	74 19                	je     8008e2 <strlcpy+0x3b>
  8008c9:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  8008cb:	88 10                	mov    %dl,(%eax)
  8008cd:	83 c0 01             	add    $0x1,%eax
  8008d0:	83 eb 01             	sub    $0x1,%ebx
  8008d3:	74 0f                	je     8008e4 <strlcpy+0x3d>
  8008d5:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  8008d9:	83 c1 01             	add    $0x1,%ecx
  8008dc:	84 d2                	test   %dl,%dl
  8008de:	74 04                	je     8008e4 <strlcpy+0x3d>
  8008e0:	eb e9                	jmp    8008cb <strlcpy+0x24>
  8008e2:	89 f0                	mov    %esi,%eax
		*dst = '\0';
  8008e4:	c6 00 00             	movb   $0x0,(%eax)
  8008e7:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8008e9:	5b                   	pop    %ebx
  8008ea:	5e                   	pop    %esi
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	57                   	push   %edi
  8008f1:	56                   	push   %esi
  8008f2:	53                   	push   %ebx
  8008f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8008f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f9:	8b 7d 10             	mov    0x10(%ebp),%edi
    int c;
    char *q = buf;

    if (buf_size <= 0)
  8008fc:	85 c9                	test   %ecx,%ecx
  8008fe:	7e 30                	jle    800930 <pstrcpy+0x43>
        return;

    for(;;) {
        c = *str++;
  800900:	0f b6 07             	movzbl (%edi),%eax
        if (c == 0 || q >= buf + buf_size - 1)
  800903:	84 c0                	test   %al,%al
  800905:	74 26                	je     80092d <pstrcpy+0x40>
  800907:	8d 74 0a ff          	lea    0xffffffff(%edx,%ecx,1),%esi
  80090b:	0f be d8             	movsbl %al,%ebx
  80090e:	89 f9                	mov    %edi,%ecx
  800910:	39 f2                	cmp    %esi,%edx
  800912:	72 09                	jb     80091d <pstrcpy+0x30>
  800914:	eb 17                	jmp    80092d <pstrcpy+0x40>
  800916:	83 c1 01             	add    $0x1,%ecx
  800919:	39 f2                	cmp    %esi,%edx
  80091b:	73 10                	jae    80092d <pstrcpy+0x40>
            break;
        *q++ = c;
  80091d:	88 1a                	mov    %bl,(%edx)
  80091f:	83 c2 01             	add    $0x1,%edx
  800922:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800926:	0f be d8             	movsbl %al,%ebx
  800929:	84 c0                	test   %al,%al
  80092b:	75 e9                	jne    800916 <pstrcpy+0x29>
    }
    *q = '\0';
  80092d:	c6 02 00             	movb   $0x0,(%edx)
}
  800930:	5b                   	pop    %ebx
  800931:	5e                   	pop    %esi
  800932:	5f                   	pop    %edi
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	8b 55 08             	mov    0x8(%ebp),%edx
  80093b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  80093e:	0f b6 02             	movzbl (%edx),%eax
  800941:	84 c0                	test   %al,%al
  800943:	74 16                	je     80095b <strcmp+0x26>
  800945:	3a 01                	cmp    (%ecx),%al
  800947:	75 12                	jne    80095b <strcmp+0x26>
		p++, q++;
  800949:	83 c1 01             	add    $0x1,%ecx
  80094c:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  800950:	84 c0                	test   %al,%al
  800952:	74 07                	je     80095b <strcmp+0x26>
  800954:	83 c2 01             	add    $0x1,%edx
  800957:	3a 01                	cmp    (%ecx),%al
  800959:	74 ee                	je     800949 <strcmp+0x14>
  80095b:	0f b6 c0             	movzbl %al,%eax
  80095e:	0f b6 11             	movzbl (%ecx),%edx
  800961:	29 d0                	sub    %edx,%eax
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	53                   	push   %ebx
  800969:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80096f:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800972:	85 d2                	test   %edx,%edx
  800974:	74 2d                	je     8009a3 <strncmp+0x3e>
  800976:	0f b6 01             	movzbl (%ecx),%eax
  800979:	84 c0                	test   %al,%al
  80097b:	74 1a                	je     800997 <strncmp+0x32>
  80097d:	3a 03                	cmp    (%ebx),%al
  80097f:	75 16                	jne    800997 <strncmp+0x32>
  800981:	83 ea 01             	sub    $0x1,%edx
  800984:	74 1d                	je     8009a3 <strncmp+0x3e>
		n--, p++, q++;
  800986:	83 c1 01             	add    $0x1,%ecx
  800989:	83 c3 01             	add    $0x1,%ebx
  80098c:	0f b6 01             	movzbl (%ecx),%eax
  80098f:	84 c0                	test   %al,%al
  800991:	74 04                	je     800997 <strncmp+0x32>
  800993:	3a 03                	cmp    (%ebx),%al
  800995:	74 ea                	je     800981 <strncmp+0x1c>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800997:	0f b6 11             	movzbl (%ecx),%edx
  80099a:	0f b6 03             	movzbl (%ebx),%eax
  80099d:	29 c2                	sub    %eax,%edx
  80099f:	89 d0                	mov    %edx,%eax
  8009a1:	eb 05                	jmp    8009a8 <strncmp+0x43>
  8009a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a8:	5b                   	pop    %ebx
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b5:	0f b6 10             	movzbl (%eax),%edx
  8009b8:	84 d2                	test   %dl,%dl
  8009ba:	74 16                	je     8009d2 <strchr+0x27>
		if (*s == c)
  8009bc:	38 ca                	cmp    %cl,%dl
  8009be:	75 06                	jne    8009c6 <strchr+0x1b>
  8009c0:	eb 15                	jmp    8009d7 <strchr+0x2c>
  8009c2:	38 ca                	cmp    %cl,%dl
  8009c4:	74 11                	je     8009d7 <strchr+0x2c>
  8009c6:	83 c0 01             	add    $0x1,%eax
  8009c9:	0f b6 10             	movzbl (%eax),%edx
  8009cc:	84 d2                	test   %dl,%dl
  8009ce:	66 90                	xchg   %ax,%ax
  8009d0:	75 f0                	jne    8009c2 <strchr+0x17>
  8009d2:	b8 00 00 00 00       	mov    $0x0,%eax
			return (char *) s;
	return 0;
}
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    

008009d9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009df:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e3:	0f b6 10             	movzbl (%eax),%edx
  8009e6:	84 d2                	test   %dl,%dl
  8009e8:	74 14                	je     8009fe <strfind+0x25>
		if (*s == c)
  8009ea:	38 ca                	cmp    %cl,%dl
  8009ec:	75 06                	jne    8009f4 <strfind+0x1b>
  8009ee:	eb 0e                	jmp    8009fe <strfind+0x25>
  8009f0:	38 ca                	cmp    %cl,%dl
  8009f2:	74 0a                	je     8009fe <strfind+0x25>
  8009f4:	83 c0 01             	add    $0x1,%eax
  8009f7:	0f b6 10             	movzbl (%eax),%edx
  8009fa:	84 d2                	test   %dl,%dl
  8009fc:	75 f2                	jne    8009f0 <strfind+0x17>
			break;
	return (char *) s;
}
  8009fe:	5d                   	pop    %ebp
  8009ff:	90                   	nop    
  800a00:	c3                   	ret    

00800a01 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	83 ec 08             	sub    $0x8,%esp
  800a07:	89 1c 24             	mov    %ebx,(%esp)
  800a0a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a0e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a14:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800a17:	85 db                	test   %ebx,%ebx
  800a19:	74 32                	je     800a4d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a1b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a21:	75 25                	jne    800a48 <memset+0x47>
  800a23:	f6 c3 03             	test   $0x3,%bl
  800a26:	75 20                	jne    800a48 <memset+0x47>
		c &= 0xFF;
  800a28:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a2b:	89 d0                	mov    %edx,%eax
  800a2d:	c1 e0 18             	shl    $0x18,%eax
  800a30:	89 d1                	mov    %edx,%ecx
  800a32:	c1 e1 10             	shl    $0x10,%ecx
  800a35:	09 c8                	or     %ecx,%eax
  800a37:	09 d0                	or     %edx,%eax
  800a39:	c1 e2 08             	shl    $0x8,%edx
  800a3c:	09 d0                	or     %edx,%eax
  800a3e:	89 d9                	mov    %ebx,%ecx
  800a40:	c1 e9 02             	shr    $0x2,%ecx
  800a43:	fc                   	cld    
  800a44:	f3 ab                	rep stos %eax,%es:(%edi)
  800a46:	eb 05                	jmp    800a4d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a48:	89 d9                	mov    %ebx,%ecx
  800a4a:	fc                   	cld    
  800a4b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a4d:	89 f8                	mov    %edi,%eax
  800a4f:	8b 1c 24             	mov    (%esp),%ebx
  800a52:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800a56:	89 ec                	mov    %ebp,%esp
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	83 ec 08             	sub    $0x8,%esp
  800a60:	89 34 24             	mov    %esi,(%esp)
  800a63:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a67:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800a6d:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a70:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a72:	39 c6                	cmp    %eax,%esi
  800a74:	73 36                	jae    800aac <memmove+0x52>
  800a76:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a79:	39 d0                	cmp    %edx,%eax
  800a7b:	73 2f                	jae    800aac <memmove+0x52>
		s += n;
		d += n;
  800a7d:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a80:	f6 c2 03             	test   $0x3,%dl
  800a83:	75 1b                	jne    800aa0 <memmove+0x46>
  800a85:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a8b:	75 13                	jne    800aa0 <memmove+0x46>
  800a8d:	f6 c1 03             	test   $0x3,%cl
  800a90:	75 0e                	jne    800aa0 <memmove+0x46>
			asm volatile("std; rep movsl\n"
  800a92:	8d 7e fc             	lea    0xfffffffc(%esi),%edi
  800a95:	8d 72 fc             	lea    0xfffffffc(%edx),%esi
  800a98:	c1 e9 02             	shr    $0x2,%ecx
  800a9b:	fd                   	std    
  800a9c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a9e:	eb 09                	jmp    800aa9 <memmove+0x4f>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aa0:	8d 7e ff             	lea    0xffffffff(%esi),%edi
  800aa3:	8d 72 ff             	lea    0xffffffff(%edx),%esi
  800aa6:	fd                   	std    
  800aa7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aa9:	fc                   	cld    
  800aaa:	eb 21                	jmp    800acd <memmove+0x73>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aac:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ab2:	75 16                	jne    800aca <memmove+0x70>
  800ab4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aba:	75 0e                	jne    800aca <memmove+0x70>
  800abc:	f6 c1 03             	test   $0x3,%cl
  800abf:	90                   	nop    
  800ac0:	75 08                	jne    800aca <memmove+0x70>
			asm volatile("cld; rep movsl\n"
  800ac2:	c1 e9 02             	shr    $0x2,%ecx
  800ac5:	fc                   	cld    
  800ac6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac8:	eb 03                	jmp    800acd <memmove+0x73>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aca:	fc                   	cld    
  800acb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800acd:	8b 34 24             	mov    (%esp),%esi
  800ad0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ad4:	89 ec                	mov    %ebp,%esp
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <memcpy>:

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
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ade:	8b 45 10             	mov    0x10(%ebp),%eax
  800ae1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ae5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aec:	8b 45 08             	mov    0x8(%ebp),%eax
  800aef:	89 04 24             	mov    %eax,(%esp)
  800af2:	e8 63 ff ff ff       	call   800a5a <memmove>
}
  800af7:	c9                   	leave  
  800af8:	c3                   	ret    

00800af9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	56                   	push   %esi
  800afd:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afe:	8b 75 10             	mov    0x10(%ebp),%esi
  800b01:	83 ee 01             	sub    $0x1,%esi
  800b04:	83 fe ff             	cmp    $0xffffffff,%esi
  800b07:	74 38                	je     800b41 <memcmp+0x48>
  800b09:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0c:	8b 55 0c             	mov    0xc(%ebp),%edx
		if (*s1 != *s2)
  800b0f:	0f b6 18             	movzbl (%eax),%ebx
  800b12:	0f b6 0a             	movzbl (%edx),%ecx
  800b15:	38 cb                	cmp    %cl,%bl
  800b17:	74 20                	je     800b39 <memcmp+0x40>
  800b19:	eb 12                	jmp    800b2d <memcmp+0x34>
  800b1b:	0f b6 58 01          	movzbl 0x1(%eax),%ebx
  800b1f:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
  800b23:	83 c0 01             	add    $0x1,%eax
  800b26:	83 c2 01             	add    $0x1,%edx
  800b29:	38 cb                	cmp    %cl,%bl
  800b2b:	74 0c                	je     800b39 <memcmp+0x40>
			return (int) *s1 - (int) *s2;
  800b2d:	0f b6 d3             	movzbl %bl,%edx
  800b30:	0f b6 c1             	movzbl %cl,%eax
  800b33:	29 c2                	sub    %eax,%edx
  800b35:	89 d0                	mov    %edx,%eax
  800b37:	eb 0d                	jmp    800b46 <memcmp+0x4d>
  800b39:	83 ee 01             	sub    $0x1,%esi
  800b3c:	83 fe ff             	cmp    $0xffffffff,%esi
  800b3f:	75 da                	jne    800b1b <memcmp+0x22>
  800b41:	b8 00 00 00 00       	mov    $0x0,%eax
		s1++, s2++;
	}

	return 0;
}
  800b46:	5b                   	pop    %ebx
  800b47:	5e                   	pop    %esi
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	53                   	push   %ebx
  800b4e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800b51:	89 da                	mov    %ebx,%edx
  800b53:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b56:	39 d3                	cmp    %edx,%ebx
  800b58:	73 1a                	jae    800b74 <memfind+0x2a>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b5a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
			break;
  800b5e:	89 d8                	mov    %ebx,%eax
  800b60:	38 0b                	cmp    %cl,(%ebx)
  800b62:	75 06                	jne    800b6a <memfind+0x20>
  800b64:	eb 0e                	jmp    800b74 <memfind+0x2a>
  800b66:	38 08                	cmp    %cl,(%eax)
  800b68:	74 0c                	je     800b76 <memfind+0x2c>
  800b6a:	83 c0 01             	add    $0x1,%eax
  800b6d:	39 d0                	cmp    %edx,%eax
  800b6f:	90                   	nop    
  800b70:	75 f4                	jne    800b66 <memfind+0x1c>
  800b72:	eb 02                	jmp    800b76 <memfind+0x2c>
  800b74:	89 d8                	mov    %ebx,%eax
	return (void *) s;
}
  800b76:	5b                   	pop    %ebx
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	57                   	push   %edi
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
  800b7f:	83 ec 04             	sub    $0x4,%esp
  800b82:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b85:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b88:	0f b6 03             	movzbl (%ebx),%eax
  800b8b:	3c 20                	cmp    $0x20,%al
  800b8d:	74 04                	je     800b93 <strtol+0x1a>
  800b8f:	3c 09                	cmp    $0x9,%al
  800b91:	75 0e                	jne    800ba1 <strtol+0x28>
		s++;
  800b93:	83 c3 01             	add    $0x1,%ebx
  800b96:	0f b6 03             	movzbl (%ebx),%eax
  800b99:	3c 20                	cmp    $0x20,%al
  800b9b:	74 f6                	je     800b93 <strtol+0x1a>
  800b9d:	3c 09                	cmp    $0x9,%al
  800b9f:	74 f2                	je     800b93 <strtol+0x1a>

	// plus/minus sign
	if (*s == '+')
  800ba1:	3c 2b                	cmp    $0x2b,%al
  800ba3:	75 0d                	jne    800bb2 <strtol+0x39>
		s++;
  800ba5:	83 c3 01             	add    $0x1,%ebx
  800ba8:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800baf:	90                   	nop    
  800bb0:	eb 15                	jmp    800bc7 <strtol+0x4e>
	else if (*s == '-')
  800bb2:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800bb9:	3c 2d                	cmp    $0x2d,%al
  800bbb:	75 0a                	jne    800bc7 <strtol+0x4e>
		s++, neg = 1;
  800bbd:	83 c3 01             	add    $0x1,%ebx
  800bc0:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc7:	85 f6                	test   %esi,%esi
  800bc9:	0f 94 c0             	sete   %al
  800bcc:	84 c0                	test   %al,%al
  800bce:	75 05                	jne    800bd5 <strtol+0x5c>
  800bd0:	83 fe 10             	cmp    $0x10,%esi
  800bd3:	75 17                	jne    800bec <strtol+0x73>
  800bd5:	80 3b 30             	cmpb   $0x30,(%ebx)
  800bd8:	75 12                	jne    800bec <strtol+0x73>
  800bda:	80 7b 01 78          	cmpb   $0x78,0x1(%ebx)
  800bde:	66 90                	xchg   %ax,%ax
  800be0:	75 0a                	jne    800bec <strtol+0x73>
		s += 2, base = 16;
  800be2:	83 c3 02             	add    $0x2,%ebx
  800be5:	be 10 00 00 00       	mov    $0x10,%esi
  800bea:	eb 1f                	jmp    800c0b <strtol+0x92>
	else if (base == 0 && s[0] == '0')
  800bec:	85 f6                	test   %esi,%esi
  800bee:	66 90                	xchg   %ax,%ax
  800bf0:	75 10                	jne    800c02 <strtol+0x89>
  800bf2:	80 3b 30             	cmpb   $0x30,(%ebx)
  800bf5:	75 0b                	jne    800c02 <strtol+0x89>
		s++, base = 8;
  800bf7:	83 c3 01             	add    $0x1,%ebx
  800bfa:	66 be 08 00          	mov    $0x8,%si
  800bfe:	66 90                	xchg   %ax,%ax
  800c00:	eb 09                	jmp    800c0b <strtol+0x92>
	else if (base == 0)
  800c02:	84 c0                	test   %al,%al
  800c04:	74 05                	je     800c0b <strtol+0x92>
  800c06:	be 0a 00 00 00       	mov    $0xa,%esi
  800c0b:	bf 00 00 00 00       	mov    $0x0,%edi
		base = 10;

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c10:	0f b6 13             	movzbl (%ebx),%edx
  800c13:	89 d1                	mov    %edx,%ecx
  800c15:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800c18:	3c 09                	cmp    $0x9,%al
  800c1a:	77 08                	ja     800c24 <strtol+0xab>
			dig = *s - '0';
  800c1c:	0f be c2             	movsbl %dl,%eax
  800c1f:	8d 50 d0             	lea    0xffffffd0(%eax),%edx
  800c22:	eb 1c                	jmp    800c40 <strtol+0xc7>
		else if (*s >= 'a' && *s <= 'z')
  800c24:	8d 41 9f             	lea    0xffffff9f(%ecx),%eax
  800c27:	3c 19                	cmp    $0x19,%al
  800c29:	77 08                	ja     800c33 <strtol+0xba>
			dig = *s - 'a' + 10;
  800c2b:	0f be c2             	movsbl %dl,%eax
  800c2e:	8d 50 a9             	lea    0xffffffa9(%eax),%edx
  800c31:	eb 0d                	jmp    800c40 <strtol+0xc7>
		else if (*s >= 'A' && *s <= 'Z')
  800c33:	8d 41 bf             	lea    0xffffffbf(%ecx),%eax
  800c36:	3c 19                	cmp    $0x19,%al
  800c38:	77 17                	ja     800c51 <strtol+0xd8>
			dig = *s - 'A' + 10;
  800c3a:	0f be c2             	movsbl %dl,%eax
  800c3d:	8d 50 c9             	lea    0xffffffc9(%eax),%edx
		else
			break;
		if (dig >= base)
  800c40:	39 f2                	cmp    %esi,%edx
  800c42:	7d 0d                	jge    800c51 <strtol+0xd8>
			break;
		s++, val = (val * base) + dig;
  800c44:	83 c3 01             	add    $0x1,%ebx
  800c47:	89 f8                	mov    %edi,%eax
  800c49:	0f af c6             	imul   %esi,%eax
  800c4c:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800c4f:	eb bf                	jmp    800c10 <strtol+0x97>
		// we don't properly detect overflow!
	}
  800c51:	89 f8                	mov    %edi,%eax

	if (endptr)
  800c53:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c57:	74 05                	je     800c5e <strtol+0xe5>
		*endptr = (char *) s;
  800c59:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c5c:	89 1a                	mov    %ebx,(%edx)
	return (neg ? -val : val);
  800c5e:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800c62:	74 04                	je     800c68 <strtol+0xef>
  800c64:	89 c7                	mov    %eax,%edi
  800c66:	f7 df                	neg    %edi
}
  800c68:	89 f8                	mov    %edi,%eax
  800c6a:	83 c4 04             	add    $0x4,%esp
  800c6d:	5b                   	pop    %ebx
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    
	...

00800c74 <sys_cgetc>:
}

int
sys_cgetc(void)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	83 ec 0c             	sub    $0xc,%esp
  800c7a:	89 1c 24             	mov    %ebx,(%esp)
  800c7d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c81:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c85:	b8 01 00 00 00       	mov    $0x1,%eax
  800c8a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c8f:	89 fa                	mov    %edi,%edx
  800c91:	89 f9                	mov    %edi,%ecx
  800c93:	89 fb                	mov    %edi,%ebx
  800c95:	89 fe                	mov    %edi,%esi
  800c97:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c99:	8b 1c 24             	mov    (%esp),%ebx
  800c9c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ca0:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ca4:	89 ec                	mov    %ebp,%esp
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    

00800ca8 <sys_cputs>:
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	83 ec 0c             	sub    $0xc,%esp
  800cae:	89 1c 24             	mov    %ebx,(%esp)
  800cb1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cb5:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800cb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbf:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc4:	89 f8                	mov    %edi,%eax
  800cc6:	89 fb                	mov    %edi,%ebx
  800cc8:	89 fe                	mov    %edi,%esi
  800cca:	cd 30                	int    $0x30
  800ccc:	8b 1c 24             	mov    (%esp),%ebx
  800ccf:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cd3:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cd7:	89 ec                	mov    %ebp,%esp
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sys_time_msec>:

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
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	83 ec 0c             	sub    $0xc,%esp
  800ce1:	89 1c 24             	mov    %ebx,(%esp)
  800ce4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ce8:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800cec:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cf1:	bf 00 00 00 00       	mov    $0x0,%edi
  800cf6:	89 fa                	mov    %edi,%edx
  800cf8:	89 f9                	mov    %edi,%ecx
  800cfa:	89 fb                	mov    %edi,%ebx
  800cfc:	89 fe                	mov    %edi,%esi
  800cfe:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d00:	8b 1c 24             	mov    (%esp),%ebx
  800d03:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d07:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d0b:	89 ec                	mov    %ebp,%esp
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <sys_ipc_recv>:
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	83 ec 28             	sub    $0x28,%esp
  800d15:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800d18:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800d1b:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800d1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d21:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d26:	bf 00 00 00 00       	mov    $0x0,%edi
  800d2b:	89 f9                	mov    %edi,%ecx
  800d2d:	89 fb                	mov    %edi,%ebx
  800d2f:	89 fe                	mov    %edi,%esi
  800d31:	cd 30                	int    $0x30
  800d33:	85 c0                	test   %eax,%eax
  800d35:	7e 28                	jle    800d5f <sys_ipc_recv+0x50>
  800d37:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d3b:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d42:	00 
  800d43:	c7 44 24 08 5f 2c 80 	movl   $0x802c5f,0x8(%esp)
  800d4a:	00 
  800d4b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d52:	00 
  800d53:	c7 04 24 7c 2c 80 00 	movl   $0x802c7c,(%esp)
  800d5a:	e8 69 16 00 00       	call   8023c8 <_panic>
  800d5f:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800d62:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800d65:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800d68:	89 ec                	mov    %ebp,%esp
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <sys_ipc_try_send>:
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	83 ec 0c             	sub    $0xc,%esp
  800d72:	89 1c 24             	mov    %ebx,(%esp)
  800d75:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d79:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d83:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d86:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d89:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d8e:	be 00 00 00 00       	mov    $0x0,%esi
  800d93:	cd 30                	int    $0x30
  800d95:	8b 1c 24             	mov    (%esp),%ebx
  800d98:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d9c:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800da0:	89 ec                	mov    %ebp,%esp
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <sys_env_set_pgfault_upcall>:
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	83 ec 28             	sub    $0x28,%esp
  800daa:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800dad:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800db0:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800db3:	8b 55 08             	mov    0x8(%ebp),%edx
  800db6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dbe:	bf 00 00 00 00       	mov    $0x0,%edi
  800dc3:	89 fb                	mov    %edi,%ebx
  800dc5:	89 fe                	mov    %edi,%esi
  800dc7:	cd 30                	int    $0x30
  800dc9:	85 c0                	test   %eax,%eax
  800dcb:	7e 28                	jle    800df5 <sys_env_set_pgfault_upcall+0x51>
  800dcd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd1:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800dd8:	00 
  800dd9:	c7 44 24 08 5f 2c 80 	movl   $0x802c5f,0x8(%esp)
  800de0:	00 
  800de1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de8:	00 
  800de9:	c7 04 24 7c 2c 80 00 	movl   $0x802c7c,(%esp)
  800df0:	e8 d3 15 00 00       	call   8023c8 <_panic>
  800df5:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800df8:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800dfb:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800dfe:	89 ec                	mov    %ebp,%esp
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <sys_env_set_trapframe>:
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	83 ec 28             	sub    $0x28,%esp
  800e08:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800e0b:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800e0e:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800e11:	8b 55 08             	mov    0x8(%ebp),%edx
  800e14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e17:	b8 09 00 00 00       	mov    $0x9,%eax
  800e1c:	bf 00 00 00 00       	mov    $0x0,%edi
  800e21:	89 fb                	mov    %edi,%ebx
  800e23:	89 fe                	mov    %edi,%esi
  800e25:	cd 30                	int    $0x30
  800e27:	85 c0                	test   %eax,%eax
  800e29:	7e 28                	jle    800e53 <sys_env_set_trapframe+0x51>
  800e2b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e2f:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e36:	00 
  800e37:	c7 44 24 08 5f 2c 80 	movl   $0x802c5f,0x8(%esp)
  800e3e:	00 
  800e3f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e46:	00 
  800e47:	c7 04 24 7c 2c 80 00 	movl   $0x802c7c,(%esp)
  800e4e:	e8 75 15 00 00       	call   8023c8 <_panic>
  800e53:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800e56:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800e59:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800e5c:	89 ec                	mov    %ebp,%esp
  800e5e:	5d                   	pop    %ebp
  800e5f:	c3                   	ret    

00800e60 <sys_env_set_status>:
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	83 ec 28             	sub    $0x28,%esp
  800e66:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800e69:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800e6c:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800e6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e75:	b8 08 00 00 00       	mov    $0x8,%eax
  800e7a:	bf 00 00 00 00       	mov    $0x0,%edi
  800e7f:	89 fb                	mov    %edi,%ebx
  800e81:	89 fe                	mov    %edi,%esi
  800e83:	cd 30                	int    $0x30
  800e85:	85 c0                	test   %eax,%eax
  800e87:	7e 28                	jle    800eb1 <sys_env_set_status+0x51>
  800e89:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e8d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e94:	00 
  800e95:	c7 44 24 08 5f 2c 80 	movl   $0x802c5f,0x8(%esp)
  800e9c:	00 
  800e9d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea4:	00 
  800ea5:	c7 04 24 7c 2c 80 00 	movl   $0x802c7c,(%esp)
  800eac:	e8 17 15 00 00       	call   8023c8 <_panic>
  800eb1:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800eb4:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800eb7:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800eba:	89 ec                	mov    %ebp,%esp
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    

00800ebe <sys_page_unmap>:
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	83 ec 28             	sub    $0x28,%esp
  800ec4:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800ec7:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800eca:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800ecd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed3:	b8 06 00 00 00       	mov    $0x6,%eax
  800ed8:	bf 00 00 00 00       	mov    $0x0,%edi
  800edd:	89 fb                	mov    %edi,%ebx
  800edf:	89 fe                	mov    %edi,%esi
  800ee1:	cd 30                	int    $0x30
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	7e 28                	jle    800f0f <sys_page_unmap+0x51>
  800ee7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eeb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ef2:	00 
  800ef3:	c7 44 24 08 5f 2c 80 	movl   $0x802c5f,0x8(%esp)
  800efa:	00 
  800efb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f02:	00 
  800f03:	c7 04 24 7c 2c 80 00 	movl   $0x802c7c,(%esp)
  800f0a:	e8 b9 14 00 00       	call   8023c8 <_panic>
  800f0f:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800f12:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800f15:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800f18:	89 ec                	mov    %ebp,%esp
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    

00800f1c <sys_page_map>:
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	83 ec 28             	sub    $0x28,%esp
  800f22:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800f25:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800f28:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800f2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f31:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f34:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f37:	8b 75 18             	mov    0x18(%ebp),%esi
  800f3a:	b8 05 00 00 00       	mov    $0x5,%eax
  800f3f:	cd 30                	int    $0x30
  800f41:	85 c0                	test   %eax,%eax
  800f43:	7e 28                	jle    800f6d <sys_page_map+0x51>
  800f45:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f49:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f50:	00 
  800f51:	c7 44 24 08 5f 2c 80 	movl   $0x802c5f,0x8(%esp)
  800f58:	00 
  800f59:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f60:	00 
  800f61:	c7 04 24 7c 2c 80 00 	movl   $0x802c7c,(%esp)
  800f68:	e8 5b 14 00 00       	call   8023c8 <_panic>
  800f6d:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800f70:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800f73:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800f76:	89 ec                	mov    %ebp,%esp
  800f78:	5d                   	pop    %ebp
  800f79:	c3                   	ret    

00800f7a <sys_page_alloc>:
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	83 ec 28             	sub    $0x28,%esp
  800f80:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800f83:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800f86:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800f89:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f92:	b8 04 00 00 00       	mov    $0x4,%eax
  800f97:	bf 00 00 00 00       	mov    $0x0,%edi
  800f9c:	89 fe                	mov    %edi,%esi
  800f9e:	cd 30                	int    $0x30
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	7e 28                	jle    800fcc <sys_page_alloc+0x52>
  800fa4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fa8:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800faf:	00 
  800fb0:	c7 44 24 08 5f 2c 80 	movl   $0x802c5f,0x8(%esp)
  800fb7:	00 
  800fb8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fbf:	00 
  800fc0:	c7 04 24 7c 2c 80 00 	movl   $0x802c7c,(%esp)
  800fc7:	e8 fc 13 00 00       	call   8023c8 <_panic>
  800fcc:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800fcf:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800fd2:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800fd5:	89 ec                	mov    %ebp,%esp
  800fd7:	5d                   	pop    %ebp
  800fd8:	c3                   	ret    

00800fd9 <sys_yield>:
  800fd9:	55                   	push   %ebp
  800fda:	89 e5                	mov    %esp,%ebp
  800fdc:	83 ec 0c             	sub    $0xc,%esp
  800fdf:	89 1c 24             	mov    %ebx,(%esp)
  800fe2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fe6:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800fea:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fef:	bf 00 00 00 00       	mov    $0x0,%edi
  800ff4:	89 fa                	mov    %edi,%edx
  800ff6:	89 f9                	mov    %edi,%ecx
  800ff8:	89 fb                	mov    %edi,%ebx
  800ffa:	89 fe                	mov    %edi,%esi
  800ffc:	cd 30                	int    $0x30
  800ffe:	8b 1c 24             	mov    (%esp),%ebx
  801001:	8b 74 24 04          	mov    0x4(%esp),%esi
  801005:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801009:	89 ec                	mov    %ebp,%esp
  80100b:	5d                   	pop    %ebp
  80100c:	c3                   	ret    

0080100d <sys_getenvid>:
  80100d:	55                   	push   %ebp
  80100e:	89 e5                	mov    %esp,%ebp
  801010:	83 ec 0c             	sub    $0xc,%esp
  801013:	89 1c 24             	mov    %ebx,(%esp)
  801016:	89 74 24 04          	mov    %esi,0x4(%esp)
  80101a:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80101e:	b8 02 00 00 00       	mov    $0x2,%eax
  801023:	bf 00 00 00 00       	mov    $0x0,%edi
  801028:	89 fa                	mov    %edi,%edx
  80102a:	89 f9                	mov    %edi,%ecx
  80102c:	89 fb                	mov    %edi,%ebx
  80102e:	89 fe                	mov    %edi,%esi
  801030:	cd 30                	int    $0x30
  801032:	8b 1c 24             	mov    (%esp),%ebx
  801035:	8b 74 24 04          	mov    0x4(%esp),%esi
  801039:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80103d:	89 ec                	mov    %ebp,%esp
  80103f:	5d                   	pop    %ebp
  801040:	c3                   	ret    

00801041 <sys_env_destroy>:
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	83 ec 28             	sub    $0x28,%esp
  801047:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  80104a:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  80104d:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  801050:	8b 55 08             	mov    0x8(%ebp),%edx
  801053:	b8 03 00 00 00       	mov    $0x3,%eax
  801058:	bf 00 00 00 00       	mov    $0x0,%edi
  80105d:	89 f9                	mov    %edi,%ecx
  80105f:	89 fb                	mov    %edi,%ebx
  801061:	89 fe                	mov    %edi,%esi
  801063:	cd 30                	int    $0x30
  801065:	85 c0                	test   %eax,%eax
  801067:	7e 28                	jle    801091 <sys_env_destroy+0x50>
  801069:	89 44 24 10          	mov    %eax,0x10(%esp)
  80106d:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801074:	00 
  801075:	c7 44 24 08 5f 2c 80 	movl   $0x802c5f,0x8(%esp)
  80107c:	00 
  80107d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801084:	00 
  801085:	c7 04 24 7c 2c 80 00 	movl   $0x802c7c,(%esp)
  80108c:	e8 37 13 00 00       	call   8023c8 <_panic>
  801091:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801094:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801097:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  80109a:	89 ec                	mov    %ebp,%esp
  80109c:	5d                   	pop    %ebp
  80109d:	c3                   	ret    
	...

008010a0 <duppage>:
// It is also OK to panic on error.
// 
static int
duppage(envid_t envid, unsigned pn)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	53                   	push   %ebx
  8010a4:	83 ec 14             	sub    $0x14,%esp
  8010a7:	89 c1                	mov    %eax,%ecx
	int r;

	// LAB 4: Your code here.
	pde_t *pde;
	pte_t *pte;
	void *addr=(void*)(pn*PGSIZE);
  8010a9:	89 d3                	mov    %edx,%ebx
  8010ab:	c1 e3 0c             	shl    $0xc,%ebx
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
  8010ae:	89 d8                	mov    %ebx,%eax
  8010b0:	c1 e8 16             	shr    $0x16,%eax
  8010b3:	f6 04 85 00 d0 7b ef 	testb  $0x1,0xef7bd000(,%eax,4)
  8010ba:	01 
  8010bb:	74 14                	je     8010d1 <duppage+0x31>
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else    panic("page table for pn page is not exist");
	if((*pte&PTE_W)||(*pte&PTE_COW))
  8010bd:	89 d8                	mov    %ebx,%eax
  8010bf:	c1 e8 0c             	shr    $0xc,%eax
  8010c2:	f7 04 85 00 00 40 ef 	testl  $0x802,0xef400000(,%eax,4)
  8010c9:	02 08 00 00 
  8010cd:	75 1e                	jne    8010ed <duppage+0x4d>
  8010cf:	eb 73                	jmp    801144 <duppage+0xa4>
  8010d1:	c7 44 24 08 8c 2c 80 	movl   $0x802c8c,0x8(%esp)
  8010d8:	00 
  8010d9:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
  8010e0:	00 
  8010e1:	c7 04 24 4a 2d 80 00 	movl   $0x802d4a,(%esp)
  8010e8:	e8 db 12 00 00       	call   8023c8 <_panic>
	{
		if((r=sys_page_map(0,addr,envid,addr,PTE_COW|PTE_U))<0)
  8010ed:	c7 44 24 10 04 08 00 	movl   $0x804,0x10(%esp)
  8010f4:	00 
  8010f5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801101:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801108:	e8 0f fe ff ff       	call   800f1c <sys_page_map>
  80110d:	85 c0                	test   %eax,%eax
  80110f:	78 60                	js     801171 <duppage+0xd1>
			return r;
		if((r=sys_page_map(0,addr,0,addr,PTE_COW|PTE_U))<0)//映射的时候注意env的id
  801111:	c7 44 24 10 04 08 00 	movl   $0x804,0x10(%esp)
  801118:	00 
  801119:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80111d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801124:	00 
  801125:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801129:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801130:	e8 e7 fd ff ff       	call   800f1c <sys_page_map>
  801135:	85 c0                	test   %eax,%eax
  801137:	0f 9f c2             	setg   %dl
  80113a:	0f b6 d2             	movzbl %dl,%edx
  80113d:	83 ea 01             	sub    $0x1,%edx
  801140:	21 d0                	and    %edx,%eax
  801142:	eb 2d                	jmp    801171 <duppage+0xd1>
                        return r;
	}
	else{	
		if((r=sys_page_map(0,addr,envid,addr,PTE_U|PTE_P))<0)
  801144:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80114b:	00 
  80114c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801150:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801154:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801158:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80115f:	e8 b8 fd ff ff       	call   800f1c <sys_page_map>
  801164:	85 c0                	test   %eax,%eax
  801166:	0f 9f c2             	setg   %dl
  801169:	0f b6 d2             	movzbl %dl,%edx
  80116c:	83 ea 01             	sub    $0x1,%edx
  80116f:	21 d0                	and    %edx,%eax
			return r;
	}
	//panic("duppage not implemented");
	return 0;
}
  801171:	83 c4 14             	add    $0x14,%esp
  801174:	5b                   	pop    %ebx
  801175:	5d                   	pop    %ebp
  801176:	c3                   	ret    

00801177 <sfork>:

//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use vpd, vpt, and duppage.
//   Remember to fix "env" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
	// LAB 4: Your code here.	
	int r;
	pde_t *pde;
	pte_t *pte;
	unsigned i;
	uint32_t addr;
	envid_t envid;
	envid = sys_exofork();//创建子环境
	if(envid < 0)
		panic("sys_exofork: %e", envid);
	if(envid==0)//子环境中
	{
		env = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	else{//父环境中
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
		{
			if(i==(unsigned)VPN(UXSTACKTOP-PGSIZE))//特殊处理，用户层缺页异常栈
				continue;
			addr=i*PGSIZE;
			pde =(pde_t*) &vpd[VPD(addr)];
			if(*pde&PTE_P)//这里只处理有物理页面映射的页表项
			{
				pte=(pte_t*)&vpt[VPN(addr)];
			}
			else    continue;
			if((*pte&PTE_W)||(*pte&PTE_COW))
			{
				if((r=duppage(envid,i))<0)
					return r;
			}
		}
		if((r=sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
			return r;//设置子环境的缺页异常栈
		if((r=sys_env_set_pgfault_upcall(envid,(void*)_pgfault_upcall))<0)
			return r;//设置子环境的缺页异常处理入口点
		if((r=sys_env_set_status(envid,ENV_RUNNABLE))<0)
			return r;//设置子环境的状态为可运行
		return envid;
	}
	//panic("fork not implemented");
}
static int
sduppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	pde_t *pde;
	pte_t *pte;
	void *addr=(void*)(pn*PGSIZE);
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else    panic("page table for pn page is not exist");
	if(*pte&PTE_W)
	{
		//cprintf("sduppage:addr=%x\n",addr);
		if((r=sys_page_map(0,addr,envid,addr,PTE_W|PTE_U))<0)
			return r;
		if((r=sys_page_map(0,addr,0,addr,PTE_W|PTE_U))<0)//映射的时候注意env的id
                        return r;
	}
	else{	
		if((r=sys_page_map(0,addr,envid,addr,PTE_U|PTE_P))<0)
			return r;
	}
	//panic("duppage not implemented");
	return 0;
}
// Challenge!
int
sfork(void)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
  80117a:	57                   	push   %edi
  80117b:	56                   	push   %esi
  80117c:	53                   	push   %ebx
  80117d:	83 ec 1c             	sub    $0x1c,%esp
static __inline envid_t
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801180:	ba 07 00 00 00       	mov    $0x7,%edx
  801185:	89 d0                	mov    %edx,%eax
  801187:	cd 30                	int    $0x30
  801189:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
	int r;
	pde_t *pde;
	pte_t *pte;
	unsigned i;
	uint32_t addr;
	envid_t envid;
	envid = sys_exofork();//创建子环境
	if(envid < 0)
  80118c:	85 c0                	test   %eax,%eax
  80118e:	79 20                	jns    8011b0 <sfork+0x39>
		panic("sys_exofork: %e", envid);
  801190:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801194:	c7 44 24 08 55 2d 80 	movl   $0x802d55,0x8(%esp)
  80119b:	00 
  80119c:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  8011a3:	00 
  8011a4:	c7 04 24 4a 2d 80 00 	movl   $0x802d4a,(%esp)
  8011ab:	e8 18 12 00 00       	call   8023c8 <_panic>
	if(envid==0)//子环境中
  8011b0:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8011b4:	75 21                	jne    8011d7 <sfork+0x60>
	{
		env = &envs[ENVX(sys_getenvid())];
  8011b6:	e8 52 fe ff ff       	call   80100d <sys_getenvid>
  8011bb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011c0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011c3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011c8:	a3 3c 60 80 00       	mov    %eax,0x80603c
  8011cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d2:	e9 83 01 00 00       	jmp    80135a <sfork+0x1e3>
		return 0;
	}
	else{//父环境中,注意：这里需要设置父环境的缺页异常栈，还需要设置子环境的缺页异常栈，
	//父子环境的页异常栈不共享？具体原因还得思考
		env = &envs[ENVX(sys_getenvid())];
  8011d7:	e8 31 fe ff ff       	call   80100d <sys_getenvid>
  8011dc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011e1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011e4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011e9:	a3 3c 60 80 00       	mov    %eax,0x80603c
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
  8011ee:	c7 04 24 62 13 80 00 	movl   $0x801362,(%esp)
  8011f5:	e8 3a 12 00 00       	call   802434 <set_pgfault_handler>
  8011fa:	be 00 00 00 00       	mov    $0x0,%esi
  8011ff:	bf 00 00 00 00       	mov    $0x0,%edi
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
		{
			addr=i*PGSIZE;
			pde =(pde_t*) &vpd[VPD(addr)];
  801204:	89 f8                	mov    %edi,%eax
  801206:	c1 e8 16             	shr    $0x16,%eax
  801209:	c1 e0 02             	shl    $0x2,%eax
			if(*pde&PTE_P)//这里只处理有物理页面映射的页表项
  80120c:	f6 80 00 d0 7b ef 01 	testb  $0x1,0xef7bd000(%eax)
  801213:	0f 84 dc 00 00 00    	je     8012f5 <sfork+0x17e>
			{
				pte=(pte_t*)&vpt[VPN(addr)];
			}
			else    continue;
			if((i==(unsigned)VPN(USTACKTOP-PGSIZE))||(i==(unsigned)VPN(PFTEMP)))
  801219:	81 fe fd eb 0e 00    	cmp    $0xeebfd,%esi
  80121f:	74 08                	je     801229 <sfork+0xb2>
  801221:	81 fe ff 07 00 00    	cmp    $0x7ff,%esi
  801227:	75 17                	jne    801240 <sfork+0xc9>
								//特殊处理，用户层普通栈
			{	
				if((r=duppage(envid,i))<0)
  801229:	89 f2                	mov    %esi,%edx
  80122b:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80122e:	e8 6d fe ff ff       	call   8010a0 <duppage>
  801233:	85 c0                	test   %eax,%eax
  801235:	0f 89 ba 00 00 00    	jns    8012f5 <sfork+0x17e>
  80123b:	e9 1a 01 00 00       	jmp    80135a <sfork+0x1e3>
  801240:	f6 80 00 d0 7b ef 01 	testb  $0x1,0xef7bd000(%eax)
  801247:	74 11                	je     80125a <sfork+0xe3>
  801249:	89 f8                	mov    %edi,%eax
  80124b:	c1 e8 0c             	shr    $0xc,%eax
  80124e:	f6 04 85 00 00 40 ef 	testb  $0x2,0xef400000(,%eax,4)
  801255:	02 
  801256:	75 1e                	jne    801276 <sfork+0xff>
  801258:	eb 74                	jmp    8012ce <sfork+0x157>
  80125a:	c7 44 24 08 8c 2c 80 	movl   $0x802c8c,0x8(%esp)
  801261:	00 
  801262:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
  801269:	00 
  80126a:	c7 04 24 4a 2d 80 00 	movl   $0x802d4a,(%esp)
  801271:	e8 52 11 00 00       	call   8023c8 <_panic>
  801276:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
  80127d:	00 
  80127e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801282:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  801285:	89 44 24 08          	mov    %eax,0x8(%esp)
  801289:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80128d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801294:	e8 83 fc ff ff       	call   800f1c <sys_page_map>
  801299:	85 c0                	test   %eax,%eax
  80129b:	0f 88 b9 00 00 00    	js     80135a <sfork+0x1e3>
  8012a1:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
  8012a8:	00 
  8012a9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012ad:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012b4:	00 
  8012b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012c0:	e8 57 fc ff ff       	call   800f1c <sys_page_map>
  8012c5:	85 c0                	test   %eax,%eax
  8012c7:	79 2c                	jns    8012f5 <sfork+0x17e>
  8012c9:	e9 8c 00 00 00       	jmp    80135a <sfork+0x1e3>
  8012ce:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8012d5:	00 
  8012d6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012da:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8012dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012e1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012ec:	e8 2b fc ff ff       	call   800f1c <sys_page_map>
  8012f1:	85 c0                	test   %eax,%eax
  8012f3:	78 65                	js     80135a <sfork+0x1e3>
  8012f5:	83 c6 01             	add    $0x1,%esi
  8012f8:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8012fe:	81 fe 00 ec 0e 00    	cmp    $0xeec00,%esi
  801304:	0f 85 fa fe ff ff    	jne    801204 <sfork+0x8d>
					return r;
				continue;
			}
			if((r=sduppage(envid,i))<0)
				return r;
		}
		if((r=sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  80130a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801311:	00 
  801312:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801319:	ee 
  80131a:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80131d:	89 04 24             	mov    %eax,(%esp)
  801320:	e8 55 fc ff ff       	call   800f7a <sys_page_alloc>
  801325:	85 c0                	test   %eax,%eax
  801327:	78 31                	js     80135a <sfork+0x1e3>
                        return r;//设置子环境的缺页异常栈
		if((r=sys_env_set_pgfault_upcall(envid,(void*)_pgfault_upcall))<0)
  801329:	c7 44 24 04 b8 24 80 	movl   $0x8024b8,0x4(%esp)
  801330:	00 
  801331:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  801334:	89 04 24             	mov    %eax,(%esp)
  801337:	e8 68 fa ff ff       	call   800da4 <sys_env_set_pgfault_upcall>
  80133c:	85 c0                	test   %eax,%eax
  80133e:	78 1a                	js     80135a <sfork+0x1e3>
			return r;//设置子环境的缺页异常处理入口点
		if((r=sys_env_set_status(envid,ENV_RUNNABLE))<0)
  801340:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801347:	00 
  801348:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80134b:	89 04 24             	mov    %eax,(%esp)
  80134e:	e8 0d fb ff ff       	call   800e60 <sys_env_set_status>
  801353:	85 c0                	test   %eax,%eax
  801355:	78 03                	js     80135a <sfork+0x1e3>
  801357:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
			return r;//设置子环境的状态为可运行
		return envid;
	}
	//panic("sfork not implemented");
	//return -E_INVAL;
}
  80135a:	83 c4 1c             	add    $0x1c,%esp
  80135d:	5b                   	pop    %ebx
  80135e:	5e                   	pop    %esi
  80135f:	5f                   	pop    %edi
  801360:	5d                   	pop    %ebp
  801361:	c3                   	ret    

00801362 <pgfault>:
  801362:	55                   	push   %ebp
  801363:	89 e5                	mov    %esp,%ebp
  801365:	56                   	push   %esi
  801366:	53                   	push   %ebx
  801367:	83 ec 20             	sub    $0x20,%esp
  80136a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80136d:	8b 71 04             	mov    0x4(%ecx),%esi
  801370:	8b 19                	mov    (%ecx),%ebx
  801372:	89 d8                	mov    %ebx,%eax
  801374:	c1 e8 16             	shr    $0x16,%eax
  801377:	c1 e0 02             	shl    $0x2,%eax
  80137a:	8d 90 00 d0 7b ef    	lea    0xef7bd000(%eax),%edx
  801380:	f6 80 00 d0 7b ef 01 	testb  $0x1,0xef7bd000(%eax)
  801387:	74 16                	je     80139f <pgfault+0x3d>
  801389:	89 d8                	mov    %ebx,%eax
  80138b:	c1 e8 0c             	shr    $0xc,%eax
  80138e:	8d 04 85 00 00 40 ef 	lea    0xef400000(,%eax,4),%eax
  801395:	f7 c6 02 00 00 00    	test   $0x2,%esi
  80139b:	75 3f                	jne    8013dc <pgfault+0x7a>
  80139d:	eb 43                	jmp    8013e2 <pgfault+0x80>
  80139f:	8b 41 28             	mov    0x28(%ecx),%eax
  8013a2:	8b 12                	mov    (%edx),%edx
  8013a4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8013ac:	89 74 24 08          	mov    %esi,0x8(%esp)
  8013b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013b4:	c7 04 24 b0 2c 80 00 	movl   $0x802cb0,(%esp)
  8013bb:	e8 11 ee ff ff       	call   8001d1 <cprintf>
  8013c0:	c7 44 24 08 d4 2c 80 	movl   $0x802cd4,0x8(%esp)
  8013c7:	00 
  8013c8:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  8013cf:	00 
  8013d0:	c7 04 24 4a 2d 80 00 	movl   $0x802d4a,(%esp)
  8013d7:	e8 ec 0f 00 00       	call   8023c8 <_panic>
  8013dc:	f6 40 01 08          	testb  $0x8,0x1(%eax)
  8013e0:	75 49                	jne    80142b <pgfault+0xc9>
  8013e2:	8b 51 28             	mov    0x28(%ecx),%edx
  8013e5:	8b 08                	mov    (%eax),%ecx
  8013e7:	a1 3c 60 80 00       	mov    0x80603c,%eax
  8013ec:	8b 40 4c             	mov    0x4c(%eax),%eax
  8013ef:	89 54 24 14          	mov    %edx,0x14(%esp)
  8013f3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8013f7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013fb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801403:	c7 04 24 fc 2c 80 00 	movl   $0x802cfc,(%esp)
  80140a:	e8 c2 ed ff ff       	call   8001d1 <cprintf>
  80140f:	c7 44 24 08 65 2d 80 	movl   $0x802d65,0x8(%esp)
  801416:	00 
  801417:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  80141e:	00 
  80141f:	c7 04 24 4a 2d 80 00 	movl   $0x802d4a,(%esp)
  801426:	e8 9d 0f 00 00       	call   8023c8 <_panic>
  80142b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801432:	00 
  801433:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80143a:	00 
  80143b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801442:	e8 33 fb ff ff       	call   800f7a <sys_page_alloc>
  801447:	85 c0                	test   %eax,%eax
  801449:	79 20                	jns    80146b <pgfault+0x109>
  80144b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80144f:	c7 44 24 08 28 2d 80 	movl   $0x802d28,0x8(%esp)
  801456:	00 
  801457:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  80145e:	00 
  80145f:	c7 04 24 4a 2d 80 00 	movl   $0x802d4a,(%esp)
  801466:	e8 5d 0f 00 00       	call   8023c8 <_panic>
  80146b:	89 de                	mov    %ebx,%esi
  80146d:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  801473:	89 f2                	mov    %esi,%edx
  801475:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  80147b:	89 c3                	mov    %eax,%ebx
  80147d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801483:	39 de                	cmp    %ebx,%esi
  801485:	73 13                	jae    80149a <pgfault+0x138>
  801487:	b9 00 f0 7f 00       	mov    $0x7ff000,%ecx
  80148c:	8b 02                	mov    (%edx),%eax
  80148e:	89 01                	mov    %eax,(%ecx)
  801490:	83 c1 04             	add    $0x4,%ecx
  801493:	83 c2 04             	add    $0x4,%edx
  801496:	39 d3                	cmp    %edx,%ebx
  801498:	77 f2                	ja     80148c <pgfault+0x12a>
  80149a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8014a1:	00 
  8014a2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8014a6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014ad:	00 
  8014ae:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8014b5:	00 
  8014b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014bd:	e8 5a fa ff ff       	call   800f1c <sys_page_map>
  8014c2:	85 c0                	test   %eax,%eax
  8014c4:	79 1c                	jns    8014e2 <pgfault+0x180>
  8014c6:	c7 44 24 08 80 2d 80 	movl   $0x802d80,0x8(%esp)
  8014cd:	00 
  8014ce:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  8014d5:	00 
  8014d6:	c7 04 24 4a 2d 80 00 	movl   $0x802d4a,(%esp)
  8014dd:	e8 e6 0e 00 00       	call   8023c8 <_panic>
  8014e2:	83 c4 20             	add    $0x20,%esp
  8014e5:	5b                   	pop    %ebx
  8014e6:	5e                   	pop    %esi
  8014e7:	5d                   	pop    %ebp
  8014e8:	c3                   	ret    

008014e9 <fork>:
  8014e9:	55                   	push   %ebp
  8014ea:	89 e5                	mov    %esp,%ebp
  8014ec:	56                   	push   %esi
  8014ed:	53                   	push   %ebx
  8014ee:	83 ec 10             	sub    $0x10,%esp
static __inline envid_t
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8014f1:	ba 07 00 00 00       	mov    $0x7,%edx
  8014f6:	89 d0                	mov    %edx,%eax
  8014f8:	cd 30                	int    $0x30
  8014fa:	89 c6                	mov    %eax,%esi
  8014fc:	85 c0                	test   %eax,%eax
  8014fe:	79 20                	jns    801520 <fork+0x37>
  801500:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801504:	c7 44 24 08 55 2d 80 	movl   $0x802d55,0x8(%esp)
  80150b:	00 
  80150c:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  801513:	00 
  801514:	c7 04 24 4a 2d 80 00 	movl   $0x802d4a,(%esp)
  80151b:	e8 a8 0e 00 00       	call   8023c8 <_panic>
  801520:	85 c0                	test   %eax,%eax
  801522:	75 21                	jne    801545 <fork+0x5c>
  801524:	e8 e4 fa ff ff       	call   80100d <sys_getenvid>
  801529:	25 ff 03 00 00       	and    $0x3ff,%eax
  80152e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801531:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801536:	a3 3c 60 80 00       	mov    %eax,0x80603c
  80153b:	b8 00 00 00 00       	mov    $0x0,%eax
  801540:	e9 9f 00 00 00       	jmp    8015e4 <fork+0xfb>
  801545:	c7 04 24 62 13 80 00 	movl   $0x801362,(%esp)
  80154c:	e8 e3 0e 00 00       	call   802434 <set_pgfault_handler>
  801551:	bb 00 00 00 00       	mov    $0x0,%ebx
  801556:	eb 08                	jmp    801560 <fork+0x77>
  801558:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  80155e:	74 3e                	je     80159e <fork+0xb5>
  801560:	89 da                	mov    %ebx,%edx
  801562:	c1 e2 0c             	shl    $0xc,%edx
  801565:	89 d0                	mov    %edx,%eax
  801567:	c1 e8 16             	shr    $0x16,%eax
  80156a:	f6 04 85 00 d0 7b ef 	testb  $0x1,0xef7bd000(,%eax,4)
  801571:	01 
  801572:	74 1f                	je     801593 <fork+0xaa>
  801574:	89 d0                	mov    %edx,%eax
  801576:	c1 e8 0c             	shr    $0xc,%eax
  801579:	f7 04 85 00 00 40 ef 	testl  $0x802,0xef400000(,%eax,4)
  801580:	02 08 00 00 
  801584:	74 0d                	je     801593 <fork+0xaa>
  801586:	89 da                	mov    %ebx,%edx
  801588:	89 f0                	mov    %esi,%eax
  80158a:	e8 11 fb ff ff       	call   8010a0 <duppage>
  80158f:	85 c0                	test   %eax,%eax
  801591:	78 51                	js     8015e4 <fork+0xfb>
  801593:	83 c3 01             	add    $0x1,%ebx
  801596:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  80159c:	75 ba                	jne    801558 <fork+0x6f>
  80159e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8015a5:	00 
  8015a6:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8015ad:	ee 
  8015ae:	89 34 24             	mov    %esi,(%esp)
  8015b1:	e8 c4 f9 ff ff       	call   800f7a <sys_page_alloc>
  8015b6:	85 c0                	test   %eax,%eax
  8015b8:	78 2a                	js     8015e4 <fork+0xfb>
  8015ba:	c7 44 24 04 b8 24 80 	movl   $0x8024b8,0x4(%esp)
  8015c1:	00 
  8015c2:	89 34 24             	mov    %esi,(%esp)
  8015c5:	e8 da f7 ff ff       	call   800da4 <sys_env_set_pgfault_upcall>
  8015ca:	85 c0                	test   %eax,%eax
  8015cc:	78 16                	js     8015e4 <fork+0xfb>
  8015ce:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8015d5:	00 
  8015d6:	89 34 24             	mov    %esi,(%esp)
  8015d9:	e8 82 f8 ff ff       	call   800e60 <sys_env_set_status>
  8015de:	85 c0                	test   %eax,%eax
  8015e0:	78 02                	js     8015e4 <fork+0xfb>
  8015e2:	89 f0                	mov    %esi,%eax
  8015e4:	83 c4 10             	add    $0x10,%esp
  8015e7:	5b                   	pop    %ebx
  8015e8:	5e                   	pop    %esi
  8015e9:	5d                   	pop    %ebp
  8015ea:	c3                   	ret    
  8015eb:	00 00                	add    %al,(%eax)
  8015ed:	00 00                	add    %al,(%eax)
	...

008015f0 <fd2num>:
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8015fb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8015fe:	5d                   	pop    %ebp
  8015ff:	c3                   	ret    

00801600 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801606:	8b 45 08             	mov    0x8(%ebp),%eax
  801609:	89 04 24             	mov    %eax,(%esp)
  80160c:	e8 df ff ff ff       	call   8015f0 <fd2num>
  801611:	c1 e0 0c             	shl    $0xc,%eax
  801614:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801619:	c9                   	leave  
  80161a:	c3                   	ret    

0080161b <fd_alloc>:

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
  80161b:	55                   	push   %ebp
  80161c:	89 e5                	mov    %esp,%ebp
  80161e:	53                   	push   %ebx
  80161f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801622:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  801627:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801629:	89 d0                	mov    %edx,%eax
  80162b:	c1 e8 16             	shr    $0x16,%eax
  80162e:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  801635:	a8 01                	test   $0x1,%al
  801637:	74 10                	je     801649 <fd_alloc+0x2e>
  801639:	89 d0                	mov    %edx,%eax
  80163b:	c1 e8 0c             	shr    $0xc,%eax
  80163e:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  801645:	a8 01                	test   $0x1,%al
  801647:	75 09                	jne    801652 <fd_alloc+0x37>
			*fd_store = fd;
  801649:	89 0b                	mov    %ecx,(%ebx)
  80164b:	b8 00 00 00 00       	mov    $0x0,%eax
  801650:	eb 19                	jmp    80166b <fd_alloc+0x50>
			return 0;
  801652:	81 c2 00 10 00 00    	add    $0x1000,%edx
  801658:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  80165e:	75 c7                	jne    801627 <fd_alloc+0xc>
		}
	}
	*fd_store = 0;
  801660:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801666:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  80166b:	5b                   	pop    %ebx
  80166c:	5d                   	pop    %ebp
  80166d:	c3                   	ret    

0080166e <fd_lookup>:

// Check that fdnum is in range and mapped.
// If it is, set *fd_store to the fd page virtual address.
//
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801674:	83 f8 1f             	cmp    $0x1f,%eax
  801677:	77 35                	ja     8016ae <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801679:	c1 e0 0c             	shl    $0xc,%eax
  80167c:	8d 90 00 00 00 d0    	lea    0xd0000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  801682:	89 d0                	mov    %edx,%eax
  801684:	c1 e8 16             	shr    $0x16,%eax
  801687:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  80168e:	a8 01                	test   $0x1,%al
  801690:	74 1c                	je     8016ae <fd_lookup+0x40>
  801692:	89 d0                	mov    %edx,%eax
  801694:	c1 e8 0c             	shr    $0xc,%eax
  801697:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  80169e:	a8 01                	test   $0x1,%al
  8016a0:	74 0c                	je     8016ae <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8016a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016a5:	89 10                	mov    %edx,(%eax)
  8016a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ac:	eb 05                	jmp    8016b3 <fd_lookup+0x45>
	return 0;
  8016ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8016b3:	5d                   	pop    %ebp
  8016b4:	c3                   	ret    

008016b5 <seek>:

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
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016bb:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  8016be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c5:	89 04 24             	mov    %eax,(%esp)
  8016c8:	e8 a1 ff ff ff       	call   80166e <fd_lookup>
  8016cd:	85 c0                	test   %eax,%eax
  8016cf:	78 0e                	js     8016df <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8016d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016d4:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  8016d7:	89 50 04             	mov    %edx,0x4(%eax)
  8016da:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8016df:	c9                   	leave  
  8016e0:	c3                   	ret    

008016e1 <dev_lookup>:
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	53                   	push   %ebx
  8016e5:	83 ec 14             	sub    $0x14,%esp
  8016e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016ee:	ba 04 60 80 00       	mov    $0x806004,%edx
  8016f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8016f8:	39 0d 04 60 80 00    	cmp    %ecx,0x806004
  8016fe:	75 12                	jne    801712 <dev_lookup+0x31>
  801700:	eb 04                	jmp    801706 <dev_lookup+0x25>
  801702:	39 0a                	cmp    %ecx,(%edx)
  801704:	75 0c                	jne    801712 <dev_lookup+0x31>
  801706:	89 13                	mov    %edx,(%ebx)
  801708:	b8 00 00 00 00       	mov    $0x0,%eax
  80170d:	8d 76 00             	lea    0x0(%esi),%esi
  801710:	eb 35                	jmp    801747 <dev_lookup+0x66>
  801712:	83 c0 01             	add    $0x1,%eax
  801715:	8b 14 85 10 2e 80 00 	mov    0x802e10(,%eax,4),%edx
  80171c:	85 d2                	test   %edx,%edx
  80171e:	75 e2                	jne    801702 <dev_lookup+0x21>
  801720:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801725:	8b 40 4c             	mov    0x4c(%eax),%eax
  801728:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80172c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801730:	c7 04 24 94 2d 80 00 	movl   $0x802d94,(%esp)
  801737:	e8 95 ea ff ff       	call   8001d1 <cprintf>
  80173c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801742:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801747:	83 c4 14             	add    $0x14,%esp
  80174a:	5b                   	pop    %ebx
  80174b:	5d                   	pop    %ebp
  80174c:	c3                   	ret    

0080174d <fstat>:

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
  80174d:	55                   	push   %ebp
  80174e:	89 e5                	mov    %esp,%ebp
  801750:	53                   	push   %ebx
  801751:	83 ec 24             	sub    $0x24,%esp
  801754:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801757:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80175a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80175e:	8b 45 08             	mov    0x8(%ebp),%eax
  801761:	89 04 24             	mov    %eax,(%esp)
  801764:	e8 05 ff ff ff       	call   80166e <fd_lookup>
  801769:	89 c2                	mov    %eax,%edx
  80176b:	85 c0                	test   %eax,%eax
  80176d:	78 57                	js     8017c6 <fstat+0x79>
  80176f:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801772:	89 44 24 04          	mov    %eax,0x4(%esp)
  801776:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801779:	8b 00                	mov    (%eax),%eax
  80177b:	89 04 24             	mov    %eax,(%esp)
  80177e:	e8 5e ff ff ff       	call   8016e1 <dev_lookup>
  801783:	89 c2                	mov    %eax,%edx
  801785:	85 c0                	test   %eax,%eax
  801787:	78 3d                	js     8017c6 <fstat+0x79>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801789:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  80178e:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
  801791:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801795:	74 2f                	je     8017c6 <fstat+0x79>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801797:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80179a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017a1:	00 00 00 
	stat->st_isdir = 0;
  8017a4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017ab:	00 00 00 
	stat->st_dev = dev;
  8017ae:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  8017b1:	89 93 88 00 00 00    	mov    %edx,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017bb:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8017be:	89 04 24             	mov    %eax,(%esp)
  8017c1:	ff 52 14             	call   *0x14(%edx)
  8017c4:	89 c2                	mov    %eax,%edx
}
  8017c6:	89 d0                	mov    %edx,%eax
  8017c8:	83 c4 24             	add    $0x24,%esp
  8017cb:	5b                   	pop    %ebx
  8017cc:	5d                   	pop    %ebp
  8017cd:	c3                   	ret    

008017ce <ftruncate>:
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	53                   	push   %ebx
  8017d2:	83 ec 24             	sub    $0x24,%esp
  8017d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8017d8:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8017db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017df:	89 1c 24             	mov    %ebx,(%esp)
  8017e2:	e8 87 fe ff ff       	call   80166e <fd_lookup>
  8017e7:	85 c0                	test   %eax,%eax
  8017e9:	78 61                	js     80184c <ftruncate+0x7e>
  8017eb:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8017ee:	8b 10                	mov    (%eax),%edx
  8017f0:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  8017f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f7:	89 14 24             	mov    %edx,(%esp)
  8017fa:	e8 e2 fe ff ff       	call   8016e1 <dev_lookup>
  8017ff:	85 c0                	test   %eax,%eax
  801801:	78 49                	js     80184c <ftruncate+0x7e>
  801803:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  801806:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  80180a:	75 23                	jne    80182f <ftruncate+0x61>
  80180c:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801811:	8b 40 4c             	mov    0x4c(%eax),%eax
  801814:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801818:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181c:	c7 04 24 b4 2d 80 00 	movl   $0x802db4,(%esp)
  801823:	e8 a9 e9 ff ff       	call   8001d1 <cprintf>
  801828:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80182d:	eb 1d                	jmp    80184c <ftruncate+0x7e>
  80182f:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801832:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801837:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  80183b:	74 0f                	je     80184c <ftruncate+0x7e>
  80183d:	8b 52 18             	mov    0x18(%edx),%edx
  801840:	8b 45 0c             	mov    0xc(%ebp),%eax
  801843:	89 44 24 04          	mov    %eax,0x4(%esp)
  801847:	89 0c 24             	mov    %ecx,(%esp)
  80184a:	ff d2                	call   *%edx
  80184c:	83 c4 24             	add    $0x24,%esp
  80184f:	5b                   	pop    %ebx
  801850:	5d                   	pop    %ebp
  801851:	c3                   	ret    

00801852 <write>:
  801852:	55                   	push   %ebp
  801853:	89 e5                	mov    %esp,%ebp
  801855:	53                   	push   %ebx
  801856:	83 ec 24             	sub    $0x24,%esp
  801859:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80185c:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80185f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801863:	89 1c 24             	mov    %ebx,(%esp)
  801866:	e8 03 fe ff ff       	call   80166e <fd_lookup>
  80186b:	85 c0                	test   %eax,%eax
  80186d:	78 68                	js     8018d7 <write+0x85>
  80186f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801872:	8b 10                	mov    (%eax),%edx
  801874:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801877:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187b:	89 14 24             	mov    %edx,(%esp)
  80187e:	e8 5e fe ff ff       	call   8016e1 <dev_lookup>
  801883:	85 c0                	test   %eax,%eax
  801885:	78 50                	js     8018d7 <write+0x85>
  801887:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  80188a:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  80188e:	75 23                	jne    8018b3 <write+0x61>
  801890:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801895:	8b 40 4c             	mov    0x4c(%eax),%eax
  801898:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80189c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a0:	c7 04 24 d5 2d 80 00 	movl   $0x802dd5,(%esp)
  8018a7:	e8 25 e9 ff ff       	call   8001d1 <cprintf>
  8018ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018b1:	eb 24                	jmp    8018d7 <write+0x85>
  8018b3:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  8018b6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018bb:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  8018bf:	74 16                	je     8018d7 <write+0x85>
  8018c1:	8b 42 0c             	mov    0xc(%edx),%eax
  8018c4:	8b 55 10             	mov    0x10(%ebp),%edx
  8018c7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8018cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018d2:	89 0c 24             	mov    %ecx,(%esp)
  8018d5:	ff d0                	call   *%eax
  8018d7:	83 c4 24             	add    $0x24,%esp
  8018da:	5b                   	pop    %ebx
  8018db:	5d                   	pop    %ebp
  8018dc:	c3                   	ret    

008018dd <read>:
  8018dd:	55                   	push   %ebp
  8018de:	89 e5                	mov    %esp,%ebp
  8018e0:	53                   	push   %ebx
  8018e1:	83 ec 24             	sub    $0x24,%esp
  8018e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8018e7:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8018ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ee:	89 1c 24             	mov    %ebx,(%esp)
  8018f1:	e8 78 fd ff ff       	call   80166e <fd_lookup>
  8018f6:	85 c0                	test   %eax,%eax
  8018f8:	78 6d                	js     801967 <read+0x8a>
  8018fa:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8018fd:	8b 10                	mov    (%eax),%edx
  8018ff:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801902:	89 44 24 04          	mov    %eax,0x4(%esp)
  801906:	89 14 24             	mov    %edx,(%esp)
  801909:	e8 d3 fd ff ff       	call   8016e1 <dev_lookup>
  80190e:	85 c0                	test   %eax,%eax
  801910:	78 55                	js     801967 <read+0x8a>
  801912:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  801915:	8b 41 08             	mov    0x8(%ecx),%eax
  801918:	83 e0 03             	and    $0x3,%eax
  80191b:	83 f8 01             	cmp    $0x1,%eax
  80191e:	75 23                	jne    801943 <read+0x66>
  801920:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801925:	8b 40 4c             	mov    0x4c(%eax),%eax
  801928:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80192c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801930:	c7 04 24 f2 2d 80 00 	movl   $0x802df2,(%esp)
  801937:	e8 95 e8 ff ff       	call   8001d1 <cprintf>
  80193c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801941:	eb 24                	jmp    801967 <read+0x8a>
  801943:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801946:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80194b:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  80194f:	74 16                	je     801967 <read+0x8a>
  801951:	8b 42 08             	mov    0x8(%edx),%eax
  801954:	8b 55 10             	mov    0x10(%ebp),%edx
  801957:	89 54 24 08          	mov    %edx,0x8(%esp)
  80195b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80195e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801962:	89 0c 24             	mov    %ecx,(%esp)
  801965:	ff d0                	call   *%eax
  801967:	83 c4 24             	add    $0x24,%esp
  80196a:	5b                   	pop    %ebx
  80196b:	5d                   	pop    %ebp
  80196c:	c3                   	ret    

0080196d <readn>:
  80196d:	55                   	push   %ebp
  80196e:	89 e5                	mov    %esp,%ebp
  801970:	57                   	push   %edi
  801971:	56                   	push   %esi
  801972:	53                   	push   %ebx
  801973:	83 ec 0c             	sub    $0xc,%esp
  801976:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801979:	8b 75 10             	mov    0x10(%ebp),%esi
  80197c:	b8 00 00 00 00       	mov    $0x0,%eax
  801981:	85 f6                	test   %esi,%esi
  801983:	74 36                	je     8019bb <readn+0x4e>
  801985:	bb 00 00 00 00       	mov    $0x0,%ebx
  80198a:	ba 00 00 00 00       	mov    $0x0,%edx
  80198f:	89 f0                	mov    %esi,%eax
  801991:	29 d0                	sub    %edx,%eax
  801993:	89 44 24 08          	mov    %eax,0x8(%esp)
  801997:	8d 04 17             	lea    (%edi,%edx,1),%eax
  80199a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199e:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a1:	89 04 24             	mov    %eax,(%esp)
  8019a4:	e8 34 ff ff ff       	call   8018dd <read>
  8019a9:	85 c0                	test   %eax,%eax
  8019ab:	78 0e                	js     8019bb <readn+0x4e>
  8019ad:	85 c0                	test   %eax,%eax
  8019af:	74 08                	je     8019b9 <readn+0x4c>
  8019b1:	01 c3                	add    %eax,%ebx
  8019b3:	89 da                	mov    %ebx,%edx
  8019b5:	39 f3                	cmp    %esi,%ebx
  8019b7:	72 d6                	jb     80198f <readn+0x22>
  8019b9:	89 d8                	mov    %ebx,%eax
  8019bb:	83 c4 0c             	add    $0xc,%esp
  8019be:	5b                   	pop    %ebx
  8019bf:	5e                   	pop    %esi
  8019c0:	5f                   	pop    %edi
  8019c1:	5d                   	pop    %ebp
  8019c2:	c3                   	ret    

008019c3 <fd_close>:
  8019c3:	55                   	push   %ebp
  8019c4:	89 e5                	mov    %esp,%ebp
  8019c6:	83 ec 28             	sub    $0x28,%esp
  8019c9:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  8019cc:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  8019cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8019d2:	89 34 24             	mov    %esi,(%esp)
  8019d5:	e8 16 fc ff ff       	call   8015f0 <fd2num>
  8019da:	8d 55 f4             	lea    0xfffffff4(%ebp),%edx
  8019dd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8019e1:	89 04 24             	mov    %eax,(%esp)
  8019e4:	e8 85 fc ff ff       	call   80166e <fd_lookup>
  8019e9:	89 c3                	mov    %eax,%ebx
  8019eb:	85 c0                	test   %eax,%eax
  8019ed:	78 05                	js     8019f4 <fd_close+0x31>
  8019ef:	3b 75 f4             	cmp    0xfffffff4(%ebp),%esi
  8019f2:	74 0e                	je     801a02 <fd_close+0x3f>
  8019f4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019f8:	75 45                	jne    801a3f <fd_close+0x7c>
  8019fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019ff:	90                   	nop    
  801a00:	eb 3d                	jmp    801a3f <fd_close+0x7c>
  801a02:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  801a05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a09:	8b 06                	mov    (%esi),%eax
  801a0b:	89 04 24             	mov    %eax,(%esp)
  801a0e:	e8 ce fc ff ff       	call   8016e1 <dev_lookup>
  801a13:	89 c3                	mov    %eax,%ebx
  801a15:	85 c0                	test   %eax,%eax
  801a17:	78 16                	js     801a2f <fd_close+0x6c>
  801a19:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  801a1c:	8b 40 10             	mov    0x10(%eax),%eax
  801a1f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a24:	85 c0                	test   %eax,%eax
  801a26:	74 07                	je     801a2f <fd_close+0x6c>
  801a28:	89 34 24             	mov    %esi,(%esp)
  801a2b:	ff d0                	call   *%eax
  801a2d:	89 c3                	mov    %eax,%ebx
  801a2f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a33:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a3a:	e8 7f f4 ff ff       	call   800ebe <sys_page_unmap>
  801a3f:	89 d8                	mov    %ebx,%eax
  801a41:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  801a44:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  801a47:	89 ec                	mov    %ebp,%esp
  801a49:	5d                   	pop    %ebp
  801a4a:	c3                   	ret    

00801a4b <close>:
  801a4b:	55                   	push   %ebp
  801a4c:	89 e5                	mov    %esp,%ebp
  801a4e:	83 ec 18             	sub    $0x18,%esp
  801a51:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  801a54:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a58:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5b:	89 04 24             	mov    %eax,(%esp)
  801a5e:	e8 0b fc ff ff       	call   80166e <fd_lookup>
  801a63:	85 c0                	test   %eax,%eax
  801a65:	78 13                	js     801a7a <close+0x2f>
  801a67:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a6e:	00 
  801a6f:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  801a72:	89 04 24             	mov    %eax,(%esp)
  801a75:	e8 49 ff ff ff       	call   8019c3 <fd_close>
  801a7a:	c9                   	leave  
  801a7b:	c3                   	ret    

00801a7c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a7c:	55                   	push   %ebp
  801a7d:	89 e5                	mov    %esp,%ebp
  801a7f:	83 ec 18             	sub    $0x18,%esp
  801a82:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  801a85:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a88:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a8f:	00 
  801a90:	8b 45 08             	mov    0x8(%ebp),%eax
  801a93:	89 04 24             	mov    %eax,(%esp)
  801a96:	e8 58 03 00 00       	call   801df3 <open>
  801a9b:	89 c6                	mov    %eax,%esi
  801a9d:	85 c0                	test   %eax,%eax
  801a9f:	78 1b                	js     801abc <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801aa1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa8:	89 34 24             	mov    %esi,(%esp)
  801aab:	e8 9d fc ff ff       	call   80174d <fstat>
  801ab0:	89 c3                	mov    %eax,%ebx
	close(fd);
  801ab2:	89 34 24             	mov    %esi,(%esp)
  801ab5:	e8 91 ff ff ff       	call   801a4b <close>
  801aba:	89 de                	mov    %ebx,%esi
	return r;
}
  801abc:	89 f0                	mov    %esi,%eax
  801abe:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  801ac1:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  801ac4:	89 ec                	mov    %ebp,%esp
  801ac6:	5d                   	pop    %ebp
  801ac7:	c3                   	ret    

00801ac8 <dup>:
  801ac8:	55                   	push   %ebp
  801ac9:	89 e5                	mov    %esp,%ebp
  801acb:	83 ec 38             	sub    $0x38,%esp
  801ace:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  801ad1:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  801ad4:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  801ad7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ada:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  801add:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae4:	89 04 24             	mov    %eax,(%esp)
  801ae7:	e8 82 fb ff ff       	call   80166e <fd_lookup>
  801aec:	89 c3                	mov    %eax,%ebx
  801aee:	85 c0                	test   %eax,%eax
  801af0:	0f 88 e1 00 00 00    	js     801bd7 <dup+0x10f>
  801af6:	89 3c 24             	mov    %edi,(%esp)
  801af9:	e8 4d ff ff ff       	call   801a4b <close>
  801afe:	89 f8                	mov    %edi,%eax
  801b00:	c1 e0 0c             	shl    $0xc,%eax
  801b03:	8d b0 00 00 00 d0    	lea    0xd0000000(%eax),%esi
  801b09:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  801b0c:	89 04 24             	mov    %eax,(%esp)
  801b0f:	e8 ec fa ff ff       	call   801600 <fd2data>
  801b14:	89 c3                	mov    %eax,%ebx
  801b16:	89 34 24             	mov    %esi,(%esp)
  801b19:	e8 e2 fa ff ff       	call   801600 <fd2data>
  801b1e:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  801b21:	89 d8                	mov    %ebx,%eax
  801b23:	c1 e8 16             	shr    $0x16,%eax
  801b26:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  801b2d:	a8 01                	test   $0x1,%al
  801b2f:	74 45                	je     801b76 <dup+0xae>
  801b31:	89 da                	mov    %ebx,%edx
  801b33:	c1 ea 0c             	shr    $0xc,%edx
  801b36:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  801b3d:	a8 01                	test   $0x1,%al
  801b3f:	74 35                	je     801b76 <dup+0xae>
  801b41:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  801b48:	25 07 0e 00 00       	and    $0xe07,%eax
  801b4d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801b51:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  801b54:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b58:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b5f:	00 
  801b60:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b64:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b6b:	e8 ac f3 ff ff       	call   800f1c <sys_page_map>
  801b70:	89 c3                	mov    %eax,%ebx
  801b72:	85 c0                	test   %eax,%eax
  801b74:	78 3e                	js     801bb4 <dup+0xec>
  801b76:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  801b79:	89 d0                	mov    %edx,%eax
  801b7b:	c1 e8 0c             	shr    $0xc,%eax
  801b7e:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  801b85:	25 07 0e 00 00       	and    $0xe07,%eax
  801b8a:	89 44 24 10          	mov    %eax,0x10(%esp)
  801b8e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801b92:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b99:	00 
  801b9a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b9e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ba5:	e8 72 f3 ff ff       	call   800f1c <sys_page_map>
  801baa:	89 c3                	mov    %eax,%ebx
  801bac:	85 c0                	test   %eax,%eax
  801bae:	78 04                	js     801bb4 <dup+0xec>
  801bb0:	89 fb                	mov    %edi,%ebx
  801bb2:	eb 23                	jmp    801bd7 <dup+0x10f>
  801bb4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bb8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bbf:	e8 fa f2 ff ff       	call   800ebe <sys_page_unmap>
  801bc4:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  801bc7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bcb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bd2:	e8 e7 f2 ff ff       	call   800ebe <sys_page_unmap>
  801bd7:	89 d8                	mov    %ebx,%eax
  801bd9:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801bdc:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801bdf:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801be2:	89 ec                	mov    %ebp,%esp
  801be4:	5d                   	pop    %ebp
  801be5:	c3                   	ret    

00801be6 <close_all>:
  801be6:	55                   	push   %ebp
  801be7:	89 e5                	mov    %esp,%ebp
  801be9:	53                   	push   %ebx
  801bea:	83 ec 04             	sub    $0x4,%esp
  801bed:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bf2:	89 1c 24             	mov    %ebx,(%esp)
  801bf5:	e8 51 fe ff ff       	call   801a4b <close>
  801bfa:	83 c3 01             	add    $0x1,%ebx
  801bfd:	83 fb 20             	cmp    $0x20,%ebx
  801c00:	75 f0                	jne    801bf2 <close_all+0xc>
  801c02:	83 c4 04             	add    $0x4,%esp
  801c05:	5b                   	pop    %ebx
  801c06:	5d                   	pop    %ebp
  801c07:	c3                   	ret    

00801c08 <fsipc>:
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801c08:	55                   	push   %ebp
  801c09:	89 e5                	mov    %esp,%ebp
  801c0b:	53                   	push   %ebx
  801c0c:	83 ec 14             	sub    $0x14,%esp
  801c0f:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801c11:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  801c17:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c1e:	00 
  801c1f:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801c26:	00 
  801c27:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c2b:	89 14 24             	mov    %edx,(%esp)
  801c2e:	e8 ad 08 00 00       	call   8024e0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801c33:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c3a:	00 
  801c3b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c3f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c46:	e8 49 09 00 00       	call   802594 <ipc_recv>
}
  801c4b:	83 c4 14             	add    $0x14,%esp
  801c4e:	5b                   	pop    %ebx
  801c4f:	5d                   	pop    %ebp
  801c50:	c3                   	ret    

00801c51 <sync>:

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
  801c51:	55                   	push   %ebp
  801c52:	89 e5                	mov    %esp,%ebp
  801c54:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c57:	ba 00 00 00 00       	mov    $0x0,%edx
  801c5c:	b8 08 00 00 00       	mov    $0x8,%eax
  801c61:	e8 a2 ff ff ff       	call   801c08 <fsipc>
}
  801c66:	c9                   	leave  
  801c67:	c3                   	ret    

00801c68 <devfile_trunc>:
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
  801c6b:	83 ec 08             	sub    $0x8,%esp
  801c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c71:	8b 40 0c             	mov    0xc(%eax),%eax
  801c74:	a3 00 30 80 00       	mov    %eax,0x803000
  801c79:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c7c:	a3 04 30 80 00       	mov    %eax,0x803004
  801c81:	ba 00 00 00 00       	mov    $0x0,%edx
  801c86:	b8 02 00 00 00       	mov    $0x2,%eax
  801c8b:	e8 78 ff ff ff       	call   801c08 <fsipc>
  801c90:	c9                   	leave  
  801c91:	c3                   	ret    

00801c92 <devfile_flush>:
  801c92:	55                   	push   %ebp
  801c93:	89 e5                	mov    %esp,%ebp
  801c95:	83 ec 08             	sub    $0x8,%esp
  801c98:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9b:	8b 40 0c             	mov    0xc(%eax),%eax
  801c9e:	a3 00 30 80 00       	mov    %eax,0x803000
  801ca3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ca8:	b8 06 00 00 00       	mov    $0x6,%eax
  801cad:	e8 56 ff ff ff       	call   801c08 <fsipc>
  801cb2:	c9                   	leave  
  801cb3:	c3                   	ret    

00801cb4 <devfile_stat>:
  801cb4:	55                   	push   %ebp
  801cb5:	89 e5                	mov    %esp,%ebp
  801cb7:	53                   	push   %ebx
  801cb8:	83 ec 14             	sub    $0x14,%esp
  801cbb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801cbe:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc1:	8b 40 0c             	mov    0xc(%eax),%eax
  801cc4:	a3 00 30 80 00       	mov    %eax,0x803000
  801cc9:	ba 00 00 00 00       	mov    $0x0,%edx
  801cce:	b8 05 00 00 00       	mov    $0x5,%eax
  801cd3:	e8 30 ff ff ff       	call   801c08 <fsipc>
  801cd8:	85 c0                	test   %eax,%eax
  801cda:	78 2b                	js     801d07 <devfile_stat+0x53>
  801cdc:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801ce3:	00 
  801ce4:	89 1c 24             	mov    %ebx,(%esp)
  801ce7:	e8 65 eb ff ff       	call   800851 <strcpy>
  801cec:	a1 80 30 80 00       	mov    0x803080,%eax
  801cf1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  801cf7:	a1 84 30 80 00       	mov    0x803084,%eax
  801cfc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801d02:	b8 00 00 00 00       	mov    $0x0,%eax
  801d07:	83 c4 14             	add    $0x14,%esp
  801d0a:	5b                   	pop    %ebx
  801d0b:	5d                   	pop    %ebp
  801d0c:	c3                   	ret    

00801d0d <devfile_write>:
  801d0d:	55                   	push   %ebp
  801d0e:	89 e5                	mov    %esp,%ebp
  801d10:	83 ec 18             	sub    $0x18,%esp
  801d13:	8b 55 10             	mov    0x10(%ebp),%edx
  801d16:	8b 45 08             	mov    0x8(%ebp),%eax
  801d19:	8b 40 0c             	mov    0xc(%eax),%eax
  801d1c:	a3 00 30 80 00       	mov    %eax,0x803000
  801d21:	89 d0                	mov    %edx,%eax
  801d23:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  801d29:	76 05                	jbe    801d30 <devfile_write+0x23>
  801d2b:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801d30:	89 15 04 30 80 00    	mov    %edx,0x803004
  801d36:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d41:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  801d48:	e8 0d ed ff ff       	call   800a5a <memmove>
  801d4d:	ba 00 00 00 00       	mov    $0x0,%edx
  801d52:	b8 04 00 00 00       	mov    $0x4,%eax
  801d57:	e8 ac fe ff ff       	call   801c08 <fsipc>
  801d5c:	c9                   	leave  
  801d5d:	c3                   	ret    

00801d5e <devfile_read>:
  801d5e:	55                   	push   %ebp
  801d5f:	89 e5                	mov    %esp,%ebp
  801d61:	53                   	push   %ebx
  801d62:	83 ec 14             	sub    $0x14,%esp
  801d65:	8b 45 08             	mov    0x8(%ebp),%eax
  801d68:	8b 40 0c             	mov    0xc(%eax),%eax
  801d6b:	a3 00 30 80 00       	mov    %eax,0x803000
  801d70:	8b 45 10             	mov    0x10(%ebp),%eax
  801d73:	a3 04 30 80 00       	mov    %eax,0x803004
  801d78:	ba 00 30 80 00       	mov    $0x803000,%edx
  801d7d:	b8 03 00 00 00       	mov    $0x3,%eax
  801d82:	e8 81 fe ff ff       	call   801c08 <fsipc>
  801d87:	89 c3                	mov    %eax,%ebx
  801d89:	85 c0                	test   %eax,%eax
  801d8b:	7e 17                	jle    801da4 <devfile_read+0x46>
  801d8d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d91:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801d98:	00 
  801d99:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d9c:	89 04 24             	mov    %eax,(%esp)
  801d9f:	e8 b6 ec ff ff       	call   800a5a <memmove>
  801da4:	89 d8                	mov    %ebx,%eax
  801da6:	83 c4 14             	add    $0x14,%esp
  801da9:	5b                   	pop    %ebx
  801daa:	5d                   	pop    %ebp
  801dab:	c3                   	ret    

00801dac <remove>:
  801dac:	55                   	push   %ebp
  801dad:	89 e5                	mov    %esp,%ebp
  801daf:	53                   	push   %ebx
  801db0:	83 ec 14             	sub    $0x14,%esp
  801db3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801db6:	89 1c 24             	mov    %ebx,(%esp)
  801db9:	e8 42 ea ff ff       	call   800800 <strlen>
  801dbe:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  801dc3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801dc8:	7f 21                	jg     801deb <remove+0x3f>
  801dca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dce:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801dd5:	e8 77 ea ff ff       	call   800851 <strcpy>
  801dda:	ba 00 00 00 00       	mov    $0x0,%edx
  801ddf:	b8 07 00 00 00       	mov    $0x7,%eax
  801de4:	e8 1f fe ff ff       	call   801c08 <fsipc>
  801de9:	89 c2                	mov    %eax,%edx
  801deb:	89 d0                	mov    %edx,%eax
  801ded:	83 c4 14             	add    $0x14,%esp
  801df0:	5b                   	pop    %ebx
  801df1:	5d                   	pop    %ebp
  801df2:	c3                   	ret    

00801df3 <open>:
  801df3:	55                   	push   %ebp
  801df4:	89 e5                	mov    %esp,%ebp
  801df6:	56                   	push   %esi
  801df7:	53                   	push   %ebx
  801df8:	83 ec 30             	sub    $0x30,%esp
  801dfb:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  801dfe:	89 04 24             	mov    %eax,(%esp)
  801e01:	e8 15 f8 ff ff       	call   80161b <fd_alloc>
  801e06:	89 c3                	mov    %eax,%ebx
  801e08:	85 c0                	test   %eax,%eax
  801e0a:	79 18                	jns    801e24 <open+0x31>
  801e0c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e13:	00 
  801e14:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801e17:	89 04 24             	mov    %eax,(%esp)
  801e1a:	e8 a4 fb ff ff       	call   8019c3 <fd_close>
  801e1f:	e9 9f 00 00 00       	jmp    801ec3 <open+0xd0>
  801e24:	8b 45 08             	mov    0x8(%ebp),%eax
  801e27:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e2b:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801e32:	e8 1a ea ff ff       	call   800851 <strcpy>
  801e37:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e3a:	a3 00 34 80 00       	mov    %eax,0x803400
  801e3f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801e42:	89 04 24             	mov    %eax,(%esp)
  801e45:	e8 b6 f7 ff ff       	call   801600 <fd2data>
  801e4a:	89 c6                	mov    %eax,%esi
  801e4c:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  801e4f:	b8 01 00 00 00       	mov    $0x1,%eax
  801e54:	e8 af fd ff ff       	call   801c08 <fsipc>
  801e59:	89 c3                	mov    %eax,%ebx
  801e5b:	85 c0                	test   %eax,%eax
  801e5d:	79 15                	jns    801e74 <open+0x81>
  801e5f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801e66:	00 
  801e67:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801e6a:	89 04 24             	mov    %eax,(%esp)
  801e6d:	e8 51 fb ff ff       	call   8019c3 <fd_close>
  801e72:	eb 4f                	jmp    801ec3 <open+0xd0>
  801e74:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801e7b:	00 
  801e7c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801e80:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e87:	00 
  801e88:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801e8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e96:	e8 81 f0 ff ff       	call   800f1c <sys_page_map>
  801e9b:	89 c3                	mov    %eax,%ebx
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	79 15                	jns    801eb6 <open+0xc3>
  801ea1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ea8:	00 
  801ea9:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801eac:	89 04 24             	mov    %eax,(%esp)
  801eaf:	e8 0f fb ff ff       	call   8019c3 <fd_close>
  801eb4:	eb 0d                	jmp    801ec3 <open+0xd0>
  801eb6:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801eb9:	89 04 24             	mov    %eax,(%esp)
  801ebc:	e8 2f f7 ff ff       	call   8015f0 <fd2num>
  801ec1:	89 c3                	mov    %eax,%ebx
  801ec3:	89 d8                	mov    %ebx,%eax
  801ec5:	83 c4 30             	add    $0x30,%esp
  801ec8:	5b                   	pop    %ebx
  801ec9:	5e                   	pop    %esi
  801eca:	5d                   	pop    %ebp
  801ecb:	c3                   	ret    
  801ecc:	00 00                	add    %al,(%eax)
	...

00801ed0 <devsock_stat>:
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
  801ed3:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  801ed6:	c7 44 24 04 1c 2e 80 	movl   $0x802e1c,0x4(%esp)
  801edd:	00 
  801ede:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee1:	89 04 24             	mov    %eax,(%esp)
  801ee4:	e8 68 e9 ff ff       	call   800851 <strcpy>
	return 0;
}
  801ee9:	b8 00 00 00 00       	mov    $0x0,%eax
  801eee:	c9                   	leave  
  801eef:	c3                   	ret    

00801ef0 <devsock_close>:
  801ef0:	55                   	push   %ebp
  801ef1:	89 e5                	mov    %esp,%ebp
  801ef3:	83 ec 08             	sub    $0x8,%esp
  801ef6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef9:	8b 40 0c             	mov    0xc(%eax),%eax
  801efc:	89 04 24             	mov    %eax,(%esp)
  801eff:	e8 be 02 00 00       	call   8021c2 <nsipc_close>
  801f04:	c9                   	leave  
  801f05:	c3                   	ret    

00801f06 <devsock_write>:
  801f06:	55                   	push   %ebp
  801f07:	89 e5                	mov    %esp,%ebp
  801f09:	83 ec 18             	sub    $0x18,%esp
  801f0c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f13:	00 
  801f14:	8b 45 10             	mov    0x10(%ebp),%eax
  801f17:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f22:	8b 45 08             	mov    0x8(%ebp),%eax
  801f25:	8b 40 0c             	mov    0xc(%eax),%eax
  801f28:	89 04 24             	mov    %eax,(%esp)
  801f2b:	e8 ce 02 00 00       	call   8021fe <nsipc_send>
  801f30:	c9                   	leave  
  801f31:	c3                   	ret    

00801f32 <devsock_read>:
  801f32:	55                   	push   %ebp
  801f33:	89 e5                	mov    %esp,%ebp
  801f35:	83 ec 18             	sub    $0x18,%esp
  801f38:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f3f:	00 
  801f40:	8b 45 10             	mov    0x10(%ebp),%eax
  801f43:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f47:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f51:	8b 40 0c             	mov    0xc(%eax),%eax
  801f54:	89 04 24             	mov    %eax,(%esp)
  801f57:	e8 15 03 00 00       	call   802271 <nsipc_recv>
  801f5c:	c9                   	leave  
  801f5d:	c3                   	ret    

00801f5e <alloc_sockfd>:
  801f5e:	55                   	push   %ebp
  801f5f:	89 e5                	mov    %esp,%ebp
  801f61:	56                   	push   %esi
  801f62:	53                   	push   %ebx
  801f63:	83 ec 20             	sub    $0x20,%esp
  801f66:	89 c6                	mov    %eax,%esi
  801f68:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  801f6b:	89 04 24             	mov    %eax,(%esp)
  801f6e:	e8 a8 f6 ff ff       	call   80161b <fd_alloc>
  801f73:	89 c3                	mov    %eax,%ebx
  801f75:	85 c0                	test   %eax,%eax
  801f77:	78 21                	js     801f9a <alloc_sockfd+0x3c>
  801f79:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801f80:	00 
  801f81:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801f84:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f88:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f8f:	e8 e6 ef ff ff       	call   800f7a <sys_page_alloc>
  801f94:	89 c3                	mov    %eax,%ebx
  801f96:	85 c0                	test   %eax,%eax
  801f98:	79 0a                	jns    801fa4 <alloc_sockfd+0x46>
  801f9a:	89 34 24             	mov    %esi,(%esp)
  801f9d:	e8 20 02 00 00       	call   8021c2 <nsipc_close>
  801fa2:	eb 28                	jmp    801fcc <alloc_sockfd+0x6e>
  801fa4:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801faa:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801fad:	89 10                	mov    %edx,(%eax)
  801faf:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801fb2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
  801fb9:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801fbc:	89 70 0c             	mov    %esi,0xc(%eax)
  801fbf:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801fc2:	89 04 24             	mov    %eax,(%esp)
  801fc5:	e8 26 f6 ff ff       	call   8015f0 <fd2num>
  801fca:	89 c3                	mov    %eax,%ebx
  801fcc:	89 d8                	mov    %ebx,%eax
  801fce:	83 c4 20             	add    $0x20,%esp
  801fd1:	5b                   	pop    %ebx
  801fd2:	5e                   	pop    %esi
  801fd3:	5d                   	pop    %ebp
  801fd4:	c3                   	ret    

00801fd5 <socket>:

int
socket(int domain, int type, int protocol)
{
  801fd5:	55                   	push   %ebp
  801fd6:	89 e5                	mov    %esp,%ebp
  801fd8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801fdb:	8b 45 10             	mov    0x10(%ebp),%eax
  801fde:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fe2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fe5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe9:	8b 45 08             	mov    0x8(%ebp),%eax
  801fec:	89 04 24             	mov    %eax,(%esp)
  801fef:	e8 82 01 00 00       	call   802176 <nsipc_socket>
  801ff4:	85 c0                	test   %eax,%eax
  801ff6:	78 05                	js     801ffd <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801ff8:	e8 61 ff ff ff       	call   801f5e <alloc_sockfd>
}
  801ffd:	c9                   	leave  
  801ffe:	66 90                	xchg   %ax,%ax
  802000:	c3                   	ret    

00802001 <fd2sockid>:
  802001:	55                   	push   %ebp
  802002:	89 e5                	mov    %esp,%ebp
  802004:	83 ec 18             	sub    $0x18,%esp
  802007:	8d 55 fc             	lea    0xfffffffc(%ebp),%edx
  80200a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80200e:	89 04 24             	mov    %eax,(%esp)
  802011:	e8 58 f6 ff ff       	call   80166e <fd_lookup>
  802016:	89 c2                	mov    %eax,%edx
  802018:	85 c0                	test   %eax,%eax
  80201a:	78 15                	js     802031 <fd2sockid+0x30>
  80201c:	8b 4d fc             	mov    0xfffffffc(%ebp),%ecx
  80201f:	8b 01                	mov    (%ecx),%eax
  802021:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  802026:	3b 05 20 60 80 00    	cmp    0x806020,%eax
  80202c:	75 03                	jne    802031 <fd2sockid+0x30>
  80202e:	8b 51 0c             	mov    0xc(%ecx),%edx
  802031:	89 d0                	mov    %edx,%eax
  802033:	c9                   	leave  
  802034:	c3                   	ret    

00802035 <listen>:
  802035:	55                   	push   %ebp
  802036:	89 e5                	mov    %esp,%ebp
  802038:	83 ec 08             	sub    $0x8,%esp
  80203b:	8b 45 08             	mov    0x8(%ebp),%eax
  80203e:	e8 be ff ff ff       	call   802001 <fd2sockid>
  802043:	89 c2                	mov    %eax,%edx
  802045:	85 c0                	test   %eax,%eax
  802047:	78 11                	js     80205a <listen+0x25>
  802049:	8b 45 0c             	mov    0xc(%ebp),%eax
  80204c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802050:	89 14 24             	mov    %edx,(%esp)
  802053:	e8 48 01 00 00       	call   8021a0 <nsipc_listen>
  802058:	89 c2                	mov    %eax,%edx
  80205a:	89 d0                	mov    %edx,%eax
  80205c:	c9                   	leave  
  80205d:	c3                   	ret    

0080205e <connect>:
  80205e:	55                   	push   %ebp
  80205f:	89 e5                	mov    %esp,%ebp
  802061:	83 ec 18             	sub    $0x18,%esp
  802064:	8b 45 08             	mov    0x8(%ebp),%eax
  802067:	e8 95 ff ff ff       	call   802001 <fd2sockid>
  80206c:	89 c2                	mov    %eax,%edx
  80206e:	85 c0                	test   %eax,%eax
  802070:	78 18                	js     80208a <connect+0x2c>
  802072:	8b 45 10             	mov    0x10(%ebp),%eax
  802075:	89 44 24 08          	mov    %eax,0x8(%esp)
  802079:	8b 45 0c             	mov    0xc(%ebp),%eax
  80207c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802080:	89 14 24             	mov    %edx,(%esp)
  802083:	e8 71 02 00 00       	call   8022f9 <nsipc_connect>
  802088:	89 c2                	mov    %eax,%edx
  80208a:	89 d0                	mov    %edx,%eax
  80208c:	c9                   	leave  
  80208d:	c3                   	ret    

0080208e <shutdown>:
  80208e:	55                   	push   %ebp
  80208f:	89 e5                	mov    %esp,%ebp
  802091:	83 ec 08             	sub    $0x8,%esp
  802094:	8b 45 08             	mov    0x8(%ebp),%eax
  802097:	e8 65 ff ff ff       	call   802001 <fd2sockid>
  80209c:	89 c2                	mov    %eax,%edx
  80209e:	85 c0                	test   %eax,%eax
  8020a0:	78 11                	js     8020b3 <shutdown+0x25>
  8020a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020a9:	89 14 24             	mov    %edx,(%esp)
  8020ac:	e8 2b 01 00 00       	call   8021dc <nsipc_shutdown>
  8020b1:	89 c2                	mov    %eax,%edx
  8020b3:	89 d0                	mov    %edx,%eax
  8020b5:	c9                   	leave  
  8020b6:	c3                   	ret    

008020b7 <bind>:
  8020b7:	55                   	push   %ebp
  8020b8:	89 e5                	mov    %esp,%ebp
  8020ba:	83 ec 18             	sub    $0x18,%esp
  8020bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c0:	e8 3c ff ff ff       	call   802001 <fd2sockid>
  8020c5:	89 c2                	mov    %eax,%edx
  8020c7:	85 c0                	test   %eax,%eax
  8020c9:	78 18                	js     8020e3 <bind+0x2c>
  8020cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8020ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d9:	89 14 24             	mov    %edx,(%esp)
  8020dc:	e8 57 02 00 00       	call   802338 <nsipc_bind>
  8020e1:	89 c2                	mov    %eax,%edx
  8020e3:	89 d0                	mov    %edx,%eax
  8020e5:	c9                   	leave  
  8020e6:	c3                   	ret    

008020e7 <accept>:
  8020e7:	55                   	push   %ebp
  8020e8:	89 e5                	mov    %esp,%ebp
  8020ea:	83 ec 18             	sub    $0x18,%esp
  8020ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f0:	e8 0c ff ff ff       	call   802001 <fd2sockid>
  8020f5:	89 c2                	mov    %eax,%edx
  8020f7:	85 c0                	test   %eax,%eax
  8020f9:	78 23                	js     80211e <accept+0x37>
  8020fb:	8b 45 10             	mov    0x10(%ebp),%eax
  8020fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  802102:	8b 45 0c             	mov    0xc(%ebp),%eax
  802105:	89 44 24 04          	mov    %eax,0x4(%esp)
  802109:	89 14 24             	mov    %edx,(%esp)
  80210c:	e8 66 02 00 00       	call   802377 <nsipc_accept>
  802111:	89 c2                	mov    %eax,%edx
  802113:	85 c0                	test   %eax,%eax
  802115:	78 07                	js     80211e <accept+0x37>
  802117:	e8 42 fe ff ff       	call   801f5e <alloc_sockfd>
  80211c:	89 c2                	mov    %eax,%edx
  80211e:	89 d0                	mov    %edx,%eax
  802120:	c9                   	leave  
  802121:	c3                   	ret    
	...

00802130 <nsipc>:
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802130:	55                   	push   %ebp
  802131:	89 e5                	mov    %esp,%ebp
  802133:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802136:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  80213c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802143:	00 
  802144:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  80214b:	00 
  80214c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802150:	89 14 24             	mov    %edx,(%esp)
  802153:	e8 88 03 00 00       	call   8024e0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802158:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80215f:	00 
  802160:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802167:	00 
  802168:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80216f:	e8 20 04 00 00       	call   802594 <ipc_recv>
}
  802174:	c9                   	leave  
  802175:	c3                   	ret    

00802176 <nsipc_socket>:

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
  802176:	55                   	push   %ebp
  802177:	89 e5                	mov    %esp,%ebp
  802179:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80217c:	8b 45 08             	mov    0x8(%ebp),%eax
  80217f:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.socket.req_type = type;
  802184:	8b 45 0c             	mov    0xc(%ebp),%eax
  802187:	a3 04 50 80 00       	mov    %eax,0x805004
	nsipcbuf.socket.req_protocol = protocol;
  80218c:	8b 45 10             	mov    0x10(%ebp),%eax
  80218f:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SOCKET);
  802194:	b8 09 00 00 00       	mov    $0x9,%eax
  802199:	e8 92 ff ff ff       	call   802130 <nsipc>
}
  80219e:	c9                   	leave  
  80219f:	c3                   	ret    

008021a0 <nsipc_listen>:
  8021a0:	55                   	push   %ebp
  8021a1:	89 e5                	mov    %esp,%ebp
  8021a3:	83 ec 08             	sub    $0x8,%esp
  8021a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a9:	a3 00 50 80 00       	mov    %eax,0x805000
  8021ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021b1:	a3 04 50 80 00       	mov    %eax,0x805004
  8021b6:	b8 06 00 00 00       	mov    $0x6,%eax
  8021bb:	e8 70 ff ff ff       	call   802130 <nsipc>
  8021c0:	c9                   	leave  
  8021c1:	c3                   	ret    

008021c2 <nsipc_close>:
  8021c2:	55                   	push   %ebp
  8021c3:	89 e5                	mov    %esp,%ebp
  8021c5:	83 ec 08             	sub    $0x8,%esp
  8021c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021cb:	a3 00 50 80 00       	mov    %eax,0x805000
  8021d0:	b8 04 00 00 00       	mov    $0x4,%eax
  8021d5:	e8 56 ff ff ff       	call   802130 <nsipc>
  8021da:	c9                   	leave  
  8021db:	c3                   	ret    

008021dc <nsipc_shutdown>:
  8021dc:	55                   	push   %ebp
  8021dd:	89 e5                	mov    %esp,%ebp
  8021df:	83 ec 08             	sub    $0x8,%esp
  8021e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e5:	a3 00 50 80 00       	mov    %eax,0x805000
  8021ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021ed:	a3 04 50 80 00       	mov    %eax,0x805004
  8021f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8021f7:	e8 34 ff ff ff       	call   802130 <nsipc>
  8021fc:	c9                   	leave  
  8021fd:	c3                   	ret    

008021fe <nsipc_send>:
  8021fe:	55                   	push   %ebp
  8021ff:	89 e5                	mov    %esp,%ebp
  802201:	53                   	push   %ebx
  802202:	83 ec 14             	sub    $0x14,%esp
  802205:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802208:	8b 45 08             	mov    0x8(%ebp),%eax
  80220b:	a3 00 50 80 00       	mov    %eax,0x805000
  802210:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802216:	7e 24                	jle    80223c <nsipc_send+0x3e>
  802218:	c7 44 24 0c 28 2e 80 	movl   $0x802e28,0xc(%esp)
  80221f:	00 
  802220:	c7 44 24 08 34 2e 80 	movl   $0x802e34,0x8(%esp)
  802227:	00 
  802228:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  80222f:	00 
  802230:	c7 04 24 49 2e 80 00 	movl   $0x802e49,(%esp)
  802237:	e8 8c 01 00 00       	call   8023c8 <_panic>
  80223c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802240:	8b 45 0c             	mov    0xc(%ebp),%eax
  802243:	89 44 24 04          	mov    %eax,0x4(%esp)
  802247:	c7 04 24 0c 50 80 00 	movl   $0x80500c,(%esp)
  80224e:	e8 07 e8 ff ff       	call   800a5a <memmove>
  802253:	89 1d 04 50 80 00    	mov    %ebx,0x805004
  802259:	8b 45 14             	mov    0x14(%ebp),%eax
  80225c:	a3 08 50 80 00       	mov    %eax,0x805008
  802261:	b8 08 00 00 00       	mov    $0x8,%eax
  802266:	e8 c5 fe ff ff       	call   802130 <nsipc>
  80226b:	83 c4 14             	add    $0x14,%esp
  80226e:	5b                   	pop    %ebx
  80226f:	5d                   	pop    %ebp
  802270:	c3                   	ret    

00802271 <nsipc_recv>:
  802271:	55                   	push   %ebp
  802272:	89 e5                	mov    %esp,%ebp
  802274:	83 ec 18             	sub    $0x18,%esp
  802277:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  80227a:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  80227d:	8b 75 10             	mov    0x10(%ebp),%esi
  802280:	8b 45 08             	mov    0x8(%ebp),%eax
  802283:	a3 00 50 80 00       	mov    %eax,0x805000
  802288:	89 35 04 50 80 00    	mov    %esi,0x805004
  80228e:	8b 45 14             	mov    0x14(%ebp),%eax
  802291:	a3 08 50 80 00       	mov    %eax,0x805008
  802296:	b8 07 00 00 00       	mov    $0x7,%eax
  80229b:	e8 90 fe ff ff       	call   802130 <nsipc>
  8022a0:	89 c3                	mov    %eax,%ebx
  8022a2:	85 c0                	test   %eax,%eax
  8022a4:	78 47                	js     8022ed <nsipc_recv+0x7c>
  8022a6:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8022ab:	7f 05                	jg     8022b2 <nsipc_recv+0x41>
  8022ad:	39 c6                	cmp    %eax,%esi
  8022af:	90                   	nop    
  8022b0:	7d 24                	jge    8022d6 <nsipc_recv+0x65>
  8022b2:	c7 44 24 0c 55 2e 80 	movl   $0x802e55,0xc(%esp)
  8022b9:	00 
  8022ba:	c7 44 24 08 34 2e 80 	movl   $0x802e34,0x8(%esp)
  8022c1:	00 
  8022c2:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  8022c9:	00 
  8022ca:	c7 04 24 49 2e 80 00 	movl   $0x802e49,(%esp)
  8022d1:	e8 f2 00 00 00       	call   8023c8 <_panic>
  8022d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022da:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8022e1:	00 
  8022e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022e5:	89 04 24             	mov    %eax,(%esp)
  8022e8:	e8 6d e7 ff ff       	call   800a5a <memmove>
  8022ed:	89 d8                	mov    %ebx,%eax
  8022ef:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  8022f2:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  8022f5:	89 ec                	mov    %ebp,%esp
  8022f7:	5d                   	pop    %ebp
  8022f8:	c3                   	ret    

008022f9 <nsipc_connect>:
  8022f9:	55                   	push   %ebp
  8022fa:	89 e5                	mov    %esp,%ebp
  8022fc:	53                   	push   %ebx
  8022fd:	83 ec 14             	sub    $0x14,%esp
  802300:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802303:	8b 45 08             	mov    0x8(%ebp),%eax
  802306:	a3 00 50 80 00       	mov    %eax,0x805000
  80230b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80230f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802312:	89 44 24 04          	mov    %eax,0x4(%esp)
  802316:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  80231d:	e8 38 e7 ff ff       	call   800a5a <memmove>
  802322:	89 1d 14 50 80 00    	mov    %ebx,0x805014
  802328:	b8 05 00 00 00       	mov    $0x5,%eax
  80232d:	e8 fe fd ff ff       	call   802130 <nsipc>
  802332:	83 c4 14             	add    $0x14,%esp
  802335:	5b                   	pop    %ebx
  802336:	5d                   	pop    %ebp
  802337:	c3                   	ret    

00802338 <nsipc_bind>:
  802338:	55                   	push   %ebp
  802339:	89 e5                	mov    %esp,%ebp
  80233b:	53                   	push   %ebx
  80233c:	83 ec 14             	sub    $0x14,%esp
  80233f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802342:	8b 45 08             	mov    0x8(%ebp),%eax
  802345:	a3 00 50 80 00       	mov    %eax,0x805000
  80234a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80234e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802351:	89 44 24 04          	mov    %eax,0x4(%esp)
  802355:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  80235c:	e8 f9 e6 ff ff       	call   800a5a <memmove>
  802361:	89 1d 14 50 80 00    	mov    %ebx,0x805014
  802367:	b8 02 00 00 00       	mov    $0x2,%eax
  80236c:	e8 bf fd ff ff       	call   802130 <nsipc>
  802371:	83 c4 14             	add    $0x14,%esp
  802374:	5b                   	pop    %ebx
  802375:	5d                   	pop    %ebp
  802376:	c3                   	ret    

00802377 <nsipc_accept>:
  802377:	55                   	push   %ebp
  802378:	89 e5                	mov    %esp,%ebp
  80237a:	53                   	push   %ebx
  80237b:	83 ec 14             	sub    $0x14,%esp
  80237e:	8b 45 08             	mov    0x8(%ebp),%eax
  802381:	a3 00 50 80 00       	mov    %eax,0x805000
  802386:	b8 01 00 00 00       	mov    $0x1,%eax
  80238b:	e8 a0 fd ff ff       	call   802130 <nsipc>
  802390:	89 c3                	mov    %eax,%ebx
  802392:	85 c0                	test   %eax,%eax
  802394:	78 27                	js     8023bd <nsipc_accept+0x46>
  802396:	a1 10 50 80 00       	mov    0x805010,%eax
  80239b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80239f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8023a6:	00 
  8023a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023aa:	89 04 24             	mov    %eax,(%esp)
  8023ad:	e8 a8 e6 ff ff       	call   800a5a <memmove>
  8023b2:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8023b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8023bb:	89 10                	mov    %edx,(%eax)
  8023bd:	89 d8                	mov    %ebx,%eax
  8023bf:	83 c4 14             	add    $0x14,%esp
  8023c2:	5b                   	pop    %ebx
  8023c3:	5d                   	pop    %ebp
  8023c4:	c3                   	ret    
  8023c5:	00 00                	add    %al,(%eax)
	...

008023c8 <_panic>:
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  8023c8:	55                   	push   %ebp
  8023c9:	89 e5                	mov    %esp,%ebp
  8023cb:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8023ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8023d1:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)

	// Print the panic message
	if (argv0)
  8023d4:	a1 40 60 80 00       	mov    0x806040,%eax
  8023d9:	85 c0                	test   %eax,%eax
  8023db:	74 10                	je     8023ed <_panic+0x25>
		cprintf("%s: ", argv0);
  8023dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023e1:	c7 04 24 6a 2e 80 00 	movl   $0x802e6a,(%esp)
  8023e8:	e8 e4 dd ff ff       	call   8001d1 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8023ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023fb:	a1 00 60 80 00       	mov    0x806000,%eax
  802400:	89 44 24 04          	mov    %eax,0x4(%esp)
  802404:	c7 04 24 6f 2e 80 00 	movl   $0x802e6f,(%esp)
  80240b:	e8 c1 dd ff ff       	call   8001d1 <cprintf>
	vcprintf(fmt, ap);
  802410:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  802413:	89 44 24 04          	mov    %eax,0x4(%esp)
  802417:	8b 45 10             	mov    0x10(%ebp),%eax
  80241a:	89 04 24             	mov    %eax,(%esp)
  80241d:	e8 4e dd ff ff       	call   800170 <vcprintf>
	cprintf("\n");
  802422:	c7 04 24 54 29 80 00 	movl   $0x802954,(%esp)
  802429:	e8 a3 dd ff ff       	call   8001d1 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80242e:	cc                   	int3   
  80242f:	eb fd                	jmp    80242e <_panic+0x66>
  802431:	00 00                	add    %al,(%eax)
	...

00802434 <set_pgfault_handler>:
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802434:	55                   	push   %ebp
  802435:	89 e5                	mov    %esp,%ebp
  802437:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80243a:	83 3d 44 60 80 00 00 	cmpl   $0x0,0x806044
  802441:	75 6a                	jne    8024ad <set_pgfault_handler+0x79>
		// First time through!
		// LAB 4: Your code here.
		env=(struct Env*)&envs[ENVX(sys_getenvid())];
  802443:	e8 c5 eb ff ff       	call   80100d <sys_getenvid>
  802448:	25 ff 03 00 00       	and    $0x3ff,%eax
  80244d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802450:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802455:	a3 3c 60 80 00       	mov    %eax,0x80603c
		if((r=sys_page_alloc(env->env_id,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  80245a:	8b 40 4c             	mov    0x4c(%eax),%eax
  80245d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802464:	00 
  802465:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80246c:	ee 
  80246d:	89 04 24             	mov    %eax,(%esp)
  802470:	e8 05 eb ff ff       	call   800f7a <sys_page_alloc>
  802475:	85 c0                	test   %eax,%eax
  802477:	79 1c                	jns    802495 <set_pgfault_handler+0x61>
		{
			panic("Alloc a page for an exception stack failed");
  802479:	c7 44 24 08 8c 2e 80 	movl   $0x802e8c,0x8(%esp)
  802480:	00 
  802481:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802488:	00 
  802489:	c7 04 24 b8 2e 80 00 	movl   $0x802eb8,(%esp)
  802490:	e8 33 ff ff ff       	call   8023c8 <_panic>
		}
		sys_env_set_pgfault_upcall(env->env_id,(void*)_pgfault_upcall);
  802495:	a1 3c 60 80 00       	mov    0x80603c,%eax
  80249a:	8b 40 4c             	mov    0x4c(%eax),%eax
  80249d:	c7 44 24 04 b8 24 80 	movl   $0x8024b8,0x4(%esp)
  8024a4:	00 
  8024a5:	89 04 24             	mov    %eax,(%esp)
  8024a8:	e8 f7 e8 ff ff       	call   800da4 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8024ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8024b0:	a3 44 60 80 00       	mov    %eax,0x806044
}
  8024b5:	c9                   	leave  
  8024b6:	c3                   	ret    
	...

008024b8 <_pgfault_upcall>:
.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8024b8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8024b9:	a1 44 60 80 00       	mov    0x806044,%eax
	call *%eax
  8024be:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8024c0:	83 c4 04             	add    $0x4,%esp
	
	// Now the C page fault handler has returned and you must return
	// to the trap time state.
	// Push trap-time %eip onto the trap-time stack.
	//
	// Explanation:
	//   We must prepare the trap-time stack for our eventual return to
	//   re-execute the instruction that faulted.
	//   Unfortunately, we can't return directly from the exception stack:
	//   We can't call 'jmp', since that requires that we load the address
	//   into a register, and all registers must have their trap-time
	//   values after the return.
	//   We can't call 'ret' from the exception stack either, since if we
	//   did, %esp would have the wrong value.
	//   So instead, we push the trap-time %eip onto the *trap-time* stack!
	//   Below we'll switch to that stack and call 'ret', which will
	//   restore %eip to its pre-fault value.
	//
	//   In the case of a recursive fault on the exception stack,
	//   note that the word we're pushing now will fit in the
	//   blank word that the kernel reserved for us.
	//
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.这个有点难度，需要认真编写
	movl  0x28(%esp),%eax //把utf->utf_eip入栈
  8024c3:	8b 44 24 28          	mov    0x28(%esp),%eax
	pushl %eax
  8024c7:	50                   	push   %eax
	movl %esp,%eax
  8024c8:	89 e0                	mov    %esp,%eax
	movl 0x34(%eax),%esp  //切换到用户普通栈，压入utf_eip
  8024ca:	8b 60 34             	mov    0x34(%eax),%esp
	pushl (%eax)
  8024cd:	ff 30                	pushl  (%eax)
	movl %eax,%esp	     //切到用户异常栈
  8024cf:	89 c4                	mov    %eax,%esp
	subl $0x4,0x34(%esp) //将utf->utf_esp减去4,指向返回地址,后面不能算术操作，就在这算
  8024d1:	83 6c 24 34 04       	subl   $0x4,0x34(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0xc,%esp     //恢复通用寄存器
  8024d6:	83 c4 0c             	add    $0xc,%esp
	popal
  8024d9:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp  //恢复eflags
  8024da:	83 c4 04             	add    $0x4,%esp
	popfl          //在用户态，该指令能否修改eflags?可以的
  8024dd:	9d                   	popf   
		       //执行完这个指令后，不能进行算术任何算术运算哦，否则eflags里面的值不对
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp     //切换到用户普通栈，用户从异常处理退出后，需要继续使用该栈
  8024de:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8024df:	c3                   	ret    

008024e0 <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024e0:	55                   	push   %ebp
  8024e1:	89 e5                	mov    %esp,%ebp
  8024e3:	57                   	push   %edi
  8024e4:	56                   	push   %esi
  8024e5:	53                   	push   %ebx
  8024e6:	83 ec 1c             	sub    $0x1c,%esp
  8024e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8024ec:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  8024ef:	e8 19 eb ff ff       	call   80100d <sys_getenvid>
  8024f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8024f9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8024fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802501:	a3 3c 60 80 00       	mov    %eax,0x80603c
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  802506:	e8 02 eb ff ff       	call   80100d <sys_getenvid>
  80250b:	25 ff 03 00 00       	and    $0x3ff,%eax
  802510:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802513:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802518:	a3 3c 60 80 00       	mov    %eax,0x80603c
		if(env->env_id==to_env){
  80251d:	8b 40 4c             	mov    0x4c(%eax),%eax
  802520:	39 f0                	cmp    %esi,%eax
  802522:	75 0e                	jne    802532 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  802524:	c7 04 24 c6 2e 80 00 	movl   $0x802ec6,(%esp)
  80252b:	e8 a1 dc ff ff       	call   8001d1 <cprintf>
  802530:	eb 5a                	jmp    80258c <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  802532:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802536:	8b 45 10             	mov    0x10(%ebp),%eax
  802539:	89 44 24 08          	mov    %eax,0x8(%esp)
  80253d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802540:	89 44 24 04          	mov    %eax,0x4(%esp)
  802544:	89 34 24             	mov    %esi,(%esp)
  802547:	e8 20 e8 ff ff       	call   800d6c <sys_ipc_try_send>
  80254c:	89 c3                	mov    %eax,%ebx
  80254e:	85 c0                	test   %eax,%eax
  802550:	79 25                	jns    802577 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  802552:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802555:	74 2b                	je     802582 <ipc_send+0xa2>
				panic("send error:%e",r);
  802557:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80255b:	c7 44 24 08 e2 2e 80 	movl   $0x802ee2,0x8(%esp)
  802562:	00 
  802563:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80256a:	00 
  80256b:	c7 04 24 f0 2e 80 00 	movl   $0x802ef0,(%esp)
  802572:	e8 51 fe ff ff       	call   8023c8 <_panic>
		}
			sys_yield();
  802577:	e8 5d ea ff ff       	call   800fd9 <sys_yield>
		
	}while(r!=0);
  80257c:	85 db                	test   %ebx,%ebx
  80257e:	75 86                	jne    802506 <ipc_send+0x26>
  802580:	eb 0a                	jmp    80258c <ipc_send+0xac>
  802582:	e8 52 ea ff ff       	call   800fd9 <sys_yield>
  802587:	e9 7a ff ff ff       	jmp    802506 <ipc_send+0x26>
	return;
	//panic("ipc_send not implemented");
}
  80258c:	83 c4 1c             	add    $0x1c,%esp
  80258f:	5b                   	pop    %ebx
  802590:	5e                   	pop    %esi
  802591:	5f                   	pop    %edi
  802592:	5d                   	pop    %ebp
  802593:	c3                   	ret    

00802594 <ipc_recv>:
  802594:	55                   	push   %ebp
  802595:	89 e5                	mov    %esp,%ebp
  802597:	57                   	push   %edi
  802598:	56                   	push   %esi
  802599:	53                   	push   %ebx
  80259a:	83 ec 0c             	sub    $0xc,%esp
  80259d:	8b 75 08             	mov    0x8(%ebp),%esi
  8025a0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8025a3:	e8 65 ea ff ff       	call   80100d <sys_getenvid>
  8025a8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8025ad:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8025b0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8025b5:	a3 3c 60 80 00       	mov    %eax,0x80603c
  8025ba:	85 f6                	test   %esi,%esi
  8025bc:	74 29                	je     8025e7 <ipc_recv+0x53>
  8025be:	8b 40 4c             	mov    0x4c(%eax),%eax
  8025c1:	3b 06                	cmp    (%esi),%eax
  8025c3:	75 22                	jne    8025e7 <ipc_recv+0x53>
  8025c5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8025cb:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8025d1:	c7 04 24 c6 2e 80 00 	movl   $0x802ec6,(%esp)
  8025d8:	e8 f4 db ff ff       	call   8001d1 <cprintf>
  8025dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8025e2:	e9 8a 00 00 00       	jmp    802671 <ipc_recv+0xdd>
  8025e7:	e8 21 ea ff ff       	call   80100d <sys_getenvid>
  8025ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8025f1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8025f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8025f9:	a3 3c 60 80 00       	mov    %eax,0x80603c
  8025fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  802601:	89 04 24             	mov    %eax,(%esp)
  802604:	e8 06 e7 ff ff       	call   800d0f <sys_ipc_recv>
  802609:	89 c3                	mov    %eax,%ebx
  80260b:	85 c0                	test   %eax,%eax
  80260d:	79 1a                	jns    802629 <ipc_recv+0x95>
  80260f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802615:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  80261b:	c7 04 24 fa 2e 80 00 	movl   $0x802efa,(%esp)
  802622:	e8 aa db ff ff       	call   8001d1 <cprintf>
  802627:	eb 48                	jmp    802671 <ipc_recv+0xdd>
  802629:	e8 df e9 ff ff       	call   80100d <sys_getenvid>
  80262e:	25 ff 03 00 00       	and    $0x3ff,%eax
  802633:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802636:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80263b:	a3 3c 60 80 00       	mov    %eax,0x80603c
  802640:	85 f6                	test   %esi,%esi
  802642:	74 05                	je     802649 <ipc_recv+0xb5>
  802644:	8b 40 74             	mov    0x74(%eax),%eax
  802647:	89 06                	mov    %eax,(%esi)
  802649:	85 ff                	test   %edi,%edi
  80264b:	74 0a                	je     802657 <ipc_recv+0xc3>
  80264d:	a1 3c 60 80 00       	mov    0x80603c,%eax
  802652:	8b 40 78             	mov    0x78(%eax),%eax
  802655:	89 07                	mov    %eax,(%edi)
  802657:	e8 b1 e9 ff ff       	call   80100d <sys_getenvid>
  80265c:	25 ff 03 00 00       	and    $0x3ff,%eax
  802661:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802664:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802669:	a3 3c 60 80 00       	mov    %eax,0x80603c
  80266e:	8b 58 70             	mov    0x70(%eax),%ebx
  802671:	89 d8                	mov    %ebx,%eax
  802673:	83 c4 0c             	add    $0xc,%esp
  802676:	5b                   	pop    %ebx
  802677:	5e                   	pop    %esi
  802678:	5f                   	pop    %edi
  802679:	5d                   	pop    %ebp
  80267a:	c3                   	ret    
  80267b:	00 00                	add    %al,(%eax)
  80267d:	00 00                	add    %al,(%eax)
	...

00802680 <__udivdi3>:
  802680:	55                   	push   %ebp
  802681:	89 e5                	mov    %esp,%ebp
  802683:	57                   	push   %edi
  802684:	56                   	push   %esi
  802685:	83 ec 1c             	sub    $0x1c,%esp
  802688:	8b 45 10             	mov    0x10(%ebp),%eax
  80268b:	8b 55 14             	mov    0x14(%ebp),%edx
  80268e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802691:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  802694:	89 c1                	mov    %eax,%ecx
  802696:	8b 45 08             	mov    0x8(%ebp),%eax
  802699:	85 d2                	test   %edx,%edx
  80269b:	89 d6                	mov    %edx,%esi
  80269d:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
  8026a0:	75 1e                	jne    8026c0 <__udivdi3+0x40>
  8026a2:	39 f9                	cmp    %edi,%ecx
  8026a4:	0f 86 8d 00 00 00    	jbe    802737 <__udivdi3+0xb7>
  8026aa:	89 fa                	mov    %edi,%edx
  8026ac:	f7 f1                	div    %ecx
  8026ae:	89 c1                	mov    %eax,%ecx
  8026b0:	89 c8                	mov    %ecx,%eax
  8026b2:	89 f2                	mov    %esi,%edx
  8026b4:	83 c4 1c             	add    $0x1c,%esp
  8026b7:	5e                   	pop    %esi
  8026b8:	5f                   	pop    %edi
  8026b9:	5d                   	pop    %ebp
  8026ba:	c3                   	ret    
  8026bb:	90                   	nop    
  8026bc:	8d 74 26 00          	lea    0x0(%esi),%esi
  8026c0:	39 fa                	cmp    %edi,%edx
  8026c2:	0f 87 98 00 00 00    	ja     802760 <__udivdi3+0xe0>
  8026c8:	0f bd c2             	bsr    %edx,%eax
  8026cb:	83 f0 1f             	xor    $0x1f,%eax
  8026ce:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8026d1:	74 7f                	je     802752 <__udivdi3+0xd2>
  8026d3:	b8 20 00 00 00       	mov    $0x20,%eax
  8026d8:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  8026db:	2b 45 e4             	sub    0xffffffe4(%ebp),%eax
  8026de:	89 c1                	mov    %eax,%ecx
  8026e0:	d3 ea                	shr    %cl,%edx
  8026e2:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8026e6:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  8026e9:	89 f0                	mov    %esi,%eax
  8026eb:	d3 e0                	shl    %cl,%eax
  8026ed:	09 c2                	or     %eax,%edx
  8026ef:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8026f2:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  8026f5:	89 fa                	mov    %edi,%edx
  8026f7:	d3 e0                	shl    %cl,%eax
  8026f9:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  8026fd:	89 45 f4             	mov    %eax,0xfffffff4(%ebp)
  802700:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802703:	d3 e8                	shr    %cl,%eax
  802705:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802709:	d3 e2                	shl    %cl,%edx
  80270b:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  80270f:	09 d0                	or     %edx,%eax
  802711:	d3 ef                	shr    %cl,%edi
  802713:	89 fa                	mov    %edi,%edx
  802715:	f7 75 e0             	divl   0xffffffe0(%ebp)
  802718:	89 d1                	mov    %edx,%ecx
  80271a:	89 c7                	mov    %eax,%edi
  80271c:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80271f:	f7 e7                	mul    %edi
  802721:	39 d1                	cmp    %edx,%ecx
  802723:	89 c6                	mov    %eax,%esi
  802725:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  802728:	72 6f                	jb     802799 <__udivdi3+0x119>
  80272a:	39 ca                	cmp    %ecx,%edx
  80272c:	74 5e                	je     80278c <__udivdi3+0x10c>
  80272e:	89 f9                	mov    %edi,%ecx
  802730:	31 f6                	xor    %esi,%esi
  802732:	e9 79 ff ff ff       	jmp    8026b0 <__udivdi3+0x30>
  802737:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80273a:	85 c0                	test   %eax,%eax
  80273c:	74 32                	je     802770 <__udivdi3+0xf0>
  80273e:	89 f2                	mov    %esi,%edx
  802740:	89 f8                	mov    %edi,%eax
  802742:	f7 f1                	div    %ecx
  802744:	89 c6                	mov    %eax,%esi
  802746:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802749:	f7 f1                	div    %ecx
  80274b:	89 c1                	mov    %eax,%ecx
  80274d:	e9 5e ff ff ff       	jmp    8026b0 <__udivdi3+0x30>
  802752:	39 d7                	cmp    %edx,%edi
  802754:	77 2a                	ja     802780 <__udivdi3+0x100>
  802756:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  802759:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
  80275c:	73 22                	jae    802780 <__udivdi3+0x100>
  80275e:	66 90                	xchg   %ax,%ax
  802760:	31 c9                	xor    %ecx,%ecx
  802762:	31 f6                	xor    %esi,%esi
  802764:	e9 47 ff ff ff       	jmp    8026b0 <__udivdi3+0x30>
  802769:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  802770:	b8 01 00 00 00       	mov    $0x1,%eax
  802775:	31 d2                	xor    %edx,%edx
  802777:	f7 75 f0             	divl   0xfffffff0(%ebp)
  80277a:	89 c1                	mov    %eax,%ecx
  80277c:	eb c0                	jmp    80273e <__udivdi3+0xbe>
  80277e:	66 90                	xchg   %ax,%ax
  802780:	b9 01 00 00 00       	mov    $0x1,%ecx
  802785:	31 f6                	xor    %esi,%esi
  802787:	e9 24 ff ff ff       	jmp    8026b0 <__udivdi3+0x30>
  80278c:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  80278f:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802793:	d3 e0                	shl    %cl,%eax
  802795:	39 c6                	cmp    %eax,%esi
  802797:	76 95                	jbe    80272e <__udivdi3+0xae>
  802799:	8d 4f ff             	lea    0xffffffff(%edi),%ecx
  80279c:	31 f6                	xor    %esi,%esi
  80279e:	e9 0d ff ff ff       	jmp    8026b0 <__udivdi3+0x30>
	...

008027b0 <__umoddi3>:
  8027b0:	55                   	push   %ebp
  8027b1:	89 e5                	mov    %esp,%ebp
  8027b3:	57                   	push   %edi
  8027b4:	56                   	push   %esi
  8027b5:	83 ec 30             	sub    $0x30,%esp
  8027b8:	8b 55 14             	mov    0x14(%ebp),%edx
  8027bb:	8b 45 10             	mov    0x10(%ebp),%eax
  8027be:	8b 75 08             	mov    0x8(%ebp),%esi
  8027c1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8027c4:	85 d2                	test   %edx,%edx
  8027c6:	c7 45 d0 00 00 00 00 	movl   $0x0,0xffffffd0(%ebp)
  8027cd:	89 c1                	mov    %eax,%ecx
  8027cf:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  8027d6:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  8027d9:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  8027dc:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  8027df:	89 7d e0             	mov    %edi,0xffffffe0(%ebp)
  8027e2:	75 1c                	jne    802800 <__umoddi3+0x50>
  8027e4:	39 f8                	cmp    %edi,%eax
  8027e6:	89 fa                	mov    %edi,%edx
  8027e8:	0f 86 d4 00 00 00    	jbe    8028c2 <__umoddi3+0x112>
  8027ee:	89 f0                	mov    %esi,%eax
  8027f0:	f7 f1                	div    %ecx
  8027f2:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  8027f5:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  8027fc:	eb 12                	jmp    802810 <__umoddi3+0x60>
  8027fe:	66 90                	xchg   %ax,%ax
  802800:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802803:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  802806:	76 18                	jbe    802820 <__umoddi3+0x70>
  802808:	89 75 d0             	mov    %esi,0xffffffd0(%ebp)
  80280b:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  80280e:	66 90                	xchg   %ax,%ax
  802810:	8b 45 d0             	mov    0xffffffd0(%ebp),%eax
  802813:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  802816:	83 c4 30             	add    $0x30,%esp
  802819:	5e                   	pop    %esi
  80281a:	5f                   	pop    %edi
  80281b:	5d                   	pop    %ebp
  80281c:	c3                   	ret    
  80281d:	8d 76 00             	lea    0x0(%esi),%esi
  802820:	0f bd 45 e8          	bsr    0xffffffe8(%ebp),%eax
  802824:	83 f0 1f             	xor    $0x1f,%eax
  802827:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  80282a:	0f 84 c0 00 00 00    	je     8028f0 <__umoddi3+0x140>
  802830:	b8 20 00 00 00       	mov    $0x20,%eax
  802835:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  802838:	2b 45 dc             	sub    0xffffffdc(%ebp),%eax
  80283b:	8b 7d ec             	mov    0xffffffec(%ebp),%edi
  80283e:	8b 75 f0             	mov    0xfffffff0(%ebp),%esi
  802841:	89 c1                	mov    %eax,%ecx
  802843:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  802846:	d3 ea                	shr    %cl,%edx
  802848:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  80284b:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  80284f:	d3 e0                	shl    %cl,%eax
  802851:	09 c2                	or     %eax,%edx
  802853:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802856:	d3 e7                	shl    %cl,%edi
  802858:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  80285c:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  80285f:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  802862:	d3 e8                	shr    %cl,%eax
  802864:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  802868:	d3 e2                	shl    %cl,%edx
  80286a:	09 d0                	or     %edx,%eax
  80286c:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  80286f:	d3 e6                	shl    %cl,%esi
  802871:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802875:	d3 ea                	shr    %cl,%edx
  802877:	f7 75 f4             	divl   0xfffffff4(%ebp)
  80287a:	89 55 cc             	mov    %edx,0xffffffcc(%ebp)
  80287d:	f7 e7                	mul    %edi
  80287f:	39 55 cc             	cmp    %edx,0xffffffcc(%ebp)
  802882:	0f 82 a5 00 00 00    	jb     80292d <__umoddi3+0x17d>
  802888:	3b 55 cc             	cmp    0xffffffcc(%ebp),%edx
  80288b:	0f 84 94 00 00 00    	je     802925 <__umoddi3+0x175>
  802891:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
  802894:	29 c6                	sub    %eax,%esi
  802896:	19 d1                	sbb    %edx,%ecx
  802898:	89 4d cc             	mov    %ecx,0xffffffcc(%ebp)
  80289b:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  80289f:	89 f2                	mov    %esi,%edx
  8028a1:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  8028a4:	d3 ea                	shr    %cl,%edx
  8028a6:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8028aa:	d3 e0                	shl    %cl,%eax
  8028ac:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  8028b0:	09 c2                	or     %eax,%edx
  8028b2:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  8028b5:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  8028b8:	d3 e8                	shr    %cl,%eax
  8028ba:	89 45 d4             	mov    %eax,0xffffffd4(%ebp)
  8028bd:	e9 4e ff ff ff       	jmp    802810 <__umoddi3+0x60>
  8028c2:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  8028c5:	85 c0                	test   %eax,%eax
  8028c7:	74 17                	je     8028e0 <__umoddi3+0x130>
  8028c9:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  8028cc:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
  8028cf:	f7 f1                	div    %ecx
  8028d1:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8028d4:	f7 f1                	div    %ecx
  8028d6:	e9 17 ff ff ff       	jmp    8027f2 <__umoddi3+0x42>
  8028db:	90                   	nop    
  8028dc:	8d 74 26 00          	lea    0x0(%esi),%esi
  8028e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8028e5:	31 d2                	xor    %edx,%edx
  8028e7:	f7 75 ec             	divl   0xffffffec(%ebp)
  8028ea:	89 c1                	mov    %eax,%ecx
  8028ec:	eb db                	jmp    8028c9 <__umoddi3+0x119>
  8028ee:	66 90                	xchg   %ax,%ax
  8028f0:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8028f3:	39 45 e0             	cmp    %eax,0xffffffe0(%ebp)
  8028f6:	77 19                	ja     802911 <__umoddi3+0x161>
  8028f8:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  8028fb:	39 55 f0             	cmp    %edx,0xfffffff0(%ebp)
  8028fe:	73 11                	jae    802911 <__umoddi3+0x161>
  802900:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  802903:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802906:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802909:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  80290c:	e9 ff fe ff ff       	jmp    802810 <__umoddi3+0x60>
  802911:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802914:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802917:	2b 45 ec             	sub    0xffffffec(%ebp),%eax
  80291a:	1b 4d e8             	sbb    0xffffffe8(%ebp),%ecx
  80291d:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  802920:	89 4d e0             	mov    %ecx,0xffffffe0(%ebp)
  802923:	eb db                	jmp    802900 <__umoddi3+0x150>
  802925:	39 f0                	cmp    %esi,%eax
  802927:	0f 86 64 ff ff ff    	jbe    802891 <__umoddi3+0xe1>
  80292d:	29 f8                	sub    %edi,%eax
  80292f:	1b 55 f4             	sbb    0xfffffff4(%ebp),%edx
  802932:	e9 5a ff ff ff       	jmp    802891 <__umoddi3+0xe1>
