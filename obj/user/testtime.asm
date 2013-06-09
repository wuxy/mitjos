
obj/user/testtime:     file format elf32-i386

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
  80002c:	e8 97 00 00 00       	call   8000c8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <sleep>:
#include <inc/x86.h>

void
sleep(int sec)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	53                   	push   %ebx
  800044:	83 ec 04             	sub    $0x4,%esp
	unsigned end = sys_time_msec() + sec * 1000;
  800047:	e8 5f 0c 00 00       	call   800cab <sys_time_msec>
  80004c:	69 55 08 e8 03 00 00 	imul   $0x3e8,0x8(%ebp),%edx
  800053:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
  800056:	eb 05                	jmp    80005d <sleep+0x1d>
	while (sys_time_msec() < end)
		sys_yield();
  800058:	e8 4c 0f 00 00       	call   800fa9 <sys_yield>
  80005d:	e8 49 0c 00 00       	call   800cab <sys_time_msec>
  800062:	39 c3                	cmp    %eax,%ebx
  800064:	77 f2                	ja     800058 <sleep+0x18>
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
  80007f:	c7 04 24 20 23 80 00 	movl   $0x802320,(%esp)
  800086:	e8 16 01 00 00       	call   8001a1 <cprintf>
  80008b:	bb 05 00 00 00       	mov    $0x5,%ebx
	for (i = 5; i >= 0; i--) {
		cprintf("%d ", i);
  800090:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800094:	c7 04 24 36 23 80 00 	movl   $0x802336,(%esp)
  80009b:	e8 01 01 00 00       	call   8001a1 <cprintf>
		sleep(1);
  8000a0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000a7:	e8 94 ff ff ff       	call   800040 <sleep>
  8000ac:	83 eb 01             	sub    $0x1,%ebx
  8000af:	83 fb ff             	cmp    $0xffffffff,%ebx
  8000b2:	75 dc                	jne    800090 <umain+0x24>
	}
	cprintf("\n");
  8000b4:	c7 04 24 c9 27 80 00 	movl   $0x8027c9,(%esp)
  8000bb:	e8 e1 00 00 00       	call   8001a1 <cprintf>

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
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	83 ec 18             	sub    $0x18,%esp
  8000ce:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  8000d1:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  8000d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8000d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  8000da:	c7 05 3c 60 80 00 00 	movl   $0x0,0x80603c
  8000e1:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  8000e4:	e8 f4 0e 00 00       	call   800fdd <sys_getenvid>
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

	// call user main routine调用用户主例程
	umain(argc, argv);
  800106:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80010a:	89 34 24             	mov    %esi,(%esp)
  80010d:	e8 5a ff ff ff       	call   80006c <umain>

	// exit gracefully
	exit();
  800112:	e8 0d 00 00 00       	call   800124 <exit>
}
  800117:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  80011a:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
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
  80012a:	e8 37 15 00 00       	call   801666 <close_all>
	sys_env_destroy(0);
  80012f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800136:	e8 d6 0e 00 00       	call   801011 <sys_env_destroy>
}
  80013b:	c9                   	leave  
  80013c:	c3                   	ret    
  80013d:	00 00                	add    %al,(%eax)
	...

00800140 <vcprintf>:
}

int
vcprintf(const char *fmt, va_list ap)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800149:	c7 85 f8 fe ff ff 00 	movl   $0x0,0xfffffef8(%ebp)
  800150:	00 00 00 
	b.cnt = 0;
  800153:	c7 85 fc fe ff ff 00 	movl   $0x0,0xfffffefc(%ebp)
  80015a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800160:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800164:	8b 45 08             	mov    0x8(%ebp),%eax
  800167:	89 44 24 08          	mov    %eax,0x8(%esp)
  80016b:	8d 85 f8 fe ff ff    	lea    0xfffffef8(%ebp),%eax
  800171:	89 44 24 04          	mov    %eax,0x4(%esp)
  800175:	c7 04 24 be 01 80 00 	movl   $0x8001be,(%esp)
  80017c:	e8 c0 01 00 00       	call   800341 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800181:	8b 85 f8 fe ff ff    	mov    0xfffffef8(%ebp),%eax
  800187:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018b:	8d 85 00 ff ff ff    	lea    0xffffff00(%ebp),%eax
  800191:	89 04 24             	mov    %eax,(%esp)
  800194:	e8 df 0a 00 00       	call   800c78 <sys_cputs>
  800199:	8b 85 fc fe ff ff    	mov    0xfffffefc(%ebp),%eax

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
  8001aa:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
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
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 14             	sub    $0x14,%esp
  8001c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001c8:	8b 03                	mov    (%ebx),%eax
  8001ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cd:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001d1:	83 c0 01             	add    $0x1,%eax
  8001d4:	89 03                	mov    %eax,(%ebx)
  8001d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001db:	75 19                	jne    8001f6 <putch+0x38>
  8001dd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001e4:	00 
  8001e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e8:	89 04 24             	mov    %eax,(%esp)
  8001eb:	e8 88 0a 00 00       	call   800c78 <sys_cputs>
  8001f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001f6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
  8001fa:	83 c4 14             	add    $0x14,%esp
  8001fd:	5b                   	pop    %ebx
  8001fe:	5d                   	pop    %ebp
  8001ff:	c3                   	ret    

00800200 <printnum>:
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
  800209:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  80020c:	89 d7                	mov    %edx,%edi
  80020e:	8b 45 08             	mov    0x8(%ebp),%eax
  800211:	8b 55 0c             	mov    0xc(%ebp),%edx
  800214:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800217:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  80021a:	8b 55 10             	mov    0x10(%ebp),%edx
  80021d:	8b 45 14             	mov    0x14(%ebp),%eax
  800220:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800223:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  800226:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  80022d:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800230:	39 4d ec             	cmp    %ecx,0xffffffec(%ebp)
  800233:	72 11                	jb     800246 <printnum+0x46>
  800235:	8b 4d d8             	mov    0xffffffd8(%ebp),%ecx
  800238:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  80023b:	76 09                	jbe    800246 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023d:	8d 58 ff             	lea    0xffffffff(%eax),%ebx
  800240:	85 db                	test   %ebx,%ebx
  800242:	7f 54                	jg     800298 <printnum+0x98>
  800244:	eb 61                	jmp    8002a7 <printnum+0xa7>
  800246:	89 74 24 10          	mov    %esi,0x10(%esp)
  80024a:	83 e8 01             	sub    $0x1,%eax
  80024d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800251:	89 54 24 08          	mov    %edx,0x8(%esp)
  800255:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800259:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80025d:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800260:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800263:	89 44 24 08          	mov    %eax,0x8(%esp)
  800267:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80026b:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  80026e:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800271:	89 14 24             	mov    %edx,(%esp)
  800274:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800278:	e8 e3 1d 00 00       	call   802060 <__udivdi3>
  80027d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800281:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800285:	89 04 24             	mov    %eax,(%esp)
  800288:	89 54 24 04          	mov    %edx,0x4(%esp)
  80028c:	89 fa                	mov    %edi,%edx
  80028e:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  800291:	e8 6a ff ff ff       	call   800200 <printnum>
  800296:	eb 0f                	jmp    8002a7 <printnum+0xa7>
			putch(padc, putdat);
  800298:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80029c:	89 34 24             	mov    %esi,(%esp)
  80029f:	ff 55 e4             	call   *0xffffffe4(%ebp)
  8002a2:	83 eb 01             	sub    $0x1,%ebx
  8002a5:	75 f1                	jne    800298 <printnum+0x98>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ab:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002af:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8002b2:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  8002b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002bd:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  8002c0:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  8002c3:	89 14 24             	mov    %edx,(%esp)
  8002c6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8002ca:	e8 c1 1e 00 00       	call   802190 <__umoddi3>
  8002cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002d3:	0f be 80 51 23 80 00 	movsbl 0x802351(%eax),%eax
  8002da:	89 04 24             	mov    %eax,(%esp)
  8002dd:	ff 55 e4             	call   *0xffffffe4(%ebp)
}
  8002e0:	83 c4 3c             	add    $0x3c,%esp
  8002e3:	5b                   	pop    %ebx
  8002e4:	5e                   	pop    %esi
  8002e5:	5f                   	pop    %edi
  8002e6:	5d                   	pop    %ebp
  8002e7:	c3                   	ret    

008002e8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8002ed:	83 fa 01             	cmp    $0x1,%edx
  8002f0:	7e 0e                	jle    800300 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8002f2:	8b 10                	mov    (%eax),%edx
  8002f4:	8d 42 08             	lea    0x8(%edx),%eax
  8002f7:	89 01                	mov    %eax,(%ecx)
  8002f9:	8b 02                	mov    (%edx),%eax
  8002fb:	8b 52 04             	mov    0x4(%edx),%edx
  8002fe:	eb 22                	jmp    800322 <getuint+0x3a>
	else if (lflag)
  800300:	85 d2                	test   %edx,%edx
  800302:	74 10                	je     800314 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800304:	8b 10                	mov    (%eax),%edx
  800306:	8d 42 04             	lea    0x4(%edx),%eax
  800309:	89 01                	mov    %eax,(%ecx)
  80030b:	8b 02                	mov    (%edx),%eax
  80030d:	ba 00 00 00 00       	mov    $0x0,%edx
  800312:	eb 0e                	jmp    800322 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800314:	8b 10                	mov    (%eax),%edx
  800316:	8d 42 04             	lea    0x4(%edx),%eax
  800319:	89 01                	mov    %eax,(%ecx)
  80031b:	8b 02                	mov    (%edx),%eax
  80031d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800322:	5d                   	pop    %ebp
  800323:	c3                   	ret    

00800324 <sprintputch>:

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
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  80032a:	83 41 08 01          	addl   $0x1,0x8(%ecx)
	if (b->buf < b->ebuf)
  80032e:	8b 11                	mov    (%ecx),%edx
  800330:	3b 51 04             	cmp    0x4(%ecx),%edx
  800333:	73 0a                	jae    80033f <sprintputch+0x1b>
		*b->buf++ = ch;
  800335:	8b 45 08             	mov    0x8(%ebp),%eax
  800338:	88 02                	mov    %al,(%edx)
  80033a:	8d 42 01             	lea    0x1(%edx),%eax
  80033d:	89 01                	mov    %eax,(%ecx)
}
  80033f:	5d                   	pop    %ebp
  800340:	c3                   	ret    

00800341 <vprintfmt>:
  800341:	55                   	push   %ebp
  800342:	89 e5                	mov    %esp,%ebp
  800344:	57                   	push   %edi
  800345:	56                   	push   %esi
  800346:	53                   	push   %ebx
  800347:	83 ec 4c             	sub    $0x4c,%esp
  80034a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80034d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800350:	eb 03                	jmp    800355 <vprintfmt+0x14>
  800352:	8b 5d e8             	mov    0xffffffe8(%ebp),%ebx
  800355:	0f b6 03             	movzbl (%ebx),%eax
  800358:	83 c3 01             	add    $0x1,%ebx
  80035b:	3c 25                	cmp    $0x25,%al
  80035d:	74 30                	je     80038f <vprintfmt+0x4e>
  80035f:	84 c0                	test   %al,%al
  800361:	0f 84 a8 03 00 00    	je     80070f <vprintfmt+0x3ce>
  800367:	0f b6 d0             	movzbl %al,%edx
  80036a:	eb 0a                	jmp    800376 <vprintfmt+0x35>
  80036c:	84 c0                	test   %al,%al
  80036e:	66 90                	xchg   %ax,%ax
  800370:	0f 84 99 03 00 00    	je     80070f <vprintfmt+0x3ce>
  800376:	8b 45 0c             	mov    0xc(%ebp),%eax
  800379:	89 44 24 04          	mov    %eax,0x4(%esp)
  80037d:	89 14 24             	mov    %edx,(%esp)
  800380:	ff d7                	call   *%edi
  800382:	0f b6 03             	movzbl (%ebx),%eax
  800385:	0f b6 d0             	movzbl %al,%edx
  800388:	83 c3 01             	add    $0x1,%ebx
  80038b:	3c 25                	cmp    $0x25,%al
  80038d:	75 dd                	jne    80036c <vprintfmt+0x2b>
  80038f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800394:	c7 45 ec ff ff ff ff 	movl   $0xffffffff,0xffffffec(%ebp)
  80039b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  8003a2:	c7 45 dc 00 00 00 00 	movl   $0x0,0xffffffdc(%ebp)
  8003a9:	c6 45 e3 20          	movb   $0x20,0xffffffe3(%ebp)
  8003ad:	eb 07                	jmp    8003b6 <vprintfmt+0x75>
  8003af:	c7 45 dc 01 00 00 00 	movl   $0x1,0xffffffdc(%ebp)
  8003b6:	0f b6 03             	movzbl (%ebx),%eax
  8003b9:	0f b6 d0             	movzbl %al,%edx
  8003bc:	83 c3 01             	add    $0x1,%ebx
  8003bf:	83 e8 23             	sub    $0x23,%eax
  8003c2:	3c 55                	cmp    $0x55,%al
  8003c4:	0f 87 11 03 00 00    	ja     8006db <vprintfmt+0x39a>
  8003ca:	0f b6 c0             	movzbl %al,%eax
  8003cd:	ff 24 85 a0 24 80 00 	jmp    *0x8024a0(,%eax,4)
  8003d4:	c6 45 e3 30          	movb   $0x30,0xffffffe3(%ebp)
  8003d8:	eb dc                	jmp    8003b6 <vprintfmt+0x75>
  8003da:	83 ea 30             	sub    $0x30,%edx
  8003dd:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  8003e0:	0f be 13             	movsbl (%ebx),%edx
  8003e3:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  8003e6:	83 f8 09             	cmp    $0x9,%eax
  8003e9:	76 08                	jbe    8003f3 <vprintfmt+0xb2>
  8003eb:	eb 42                	jmp    80042f <vprintfmt+0xee>
  8003ed:	c6 45 e3 2d          	movb   $0x2d,0xffffffe3(%ebp)
  8003f1:	eb c3                	jmp    8003b6 <vprintfmt+0x75>
  8003f3:	83 c3 01             	add    $0x1,%ebx
  8003f6:	8b 75 e4             	mov    0xffffffe4(%ebp),%esi
  8003f9:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8003fc:	8d 44 42 d0          	lea    0xffffffd0(%edx,%eax,2),%eax
  800400:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  800403:	0f be 13             	movsbl (%ebx),%edx
  800406:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800409:	83 f8 09             	cmp    $0x9,%eax
  80040c:	77 21                	ja     80042f <vprintfmt+0xee>
  80040e:	eb e3                	jmp    8003f3 <vprintfmt+0xb2>
  800410:	8b 55 14             	mov    0x14(%ebp),%edx
  800413:	8d 42 04             	lea    0x4(%edx),%eax
  800416:	89 45 14             	mov    %eax,0x14(%ebp)
  800419:	8b 12                	mov    (%edx),%edx
  80041b:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  80041e:	eb 0f                	jmp    80042f <vprintfmt+0xee>
  800420:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800424:	79 90                	jns    8003b6 <vprintfmt+0x75>
  800426:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  80042d:	eb 87                	jmp    8003b6 <vprintfmt+0x75>
  80042f:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800433:	79 81                	jns    8003b6 <vprintfmt+0x75>
  800435:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  800438:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  80043b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  800442:	e9 6f ff ff ff       	jmp    8003b6 <vprintfmt+0x75>
  800447:	83 c1 01             	add    $0x1,%ecx
  80044a:	e9 67 ff ff ff       	jmp    8003b6 <vprintfmt+0x75>
  80044f:	8b 45 14             	mov    0x14(%ebp),%eax
  800452:	8d 50 04             	lea    0x4(%eax),%edx
  800455:	89 55 14             	mov    %edx,0x14(%ebp)
  800458:	8b 55 0c             	mov    0xc(%ebp),%edx
  80045b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80045f:	8b 00                	mov    (%eax),%eax
  800461:	89 04 24             	mov    %eax,(%esp)
  800464:	ff d7                	call   *%edi
  800466:	e9 ea fe ff ff       	jmp    800355 <vprintfmt+0x14>
  80046b:	8b 55 14             	mov    0x14(%ebp),%edx
  80046e:	8d 42 04             	lea    0x4(%edx),%eax
  800471:	89 45 14             	mov    %eax,0x14(%ebp)
  800474:	8b 02                	mov    (%edx),%eax
  800476:	89 c2                	mov    %eax,%edx
  800478:	c1 fa 1f             	sar    $0x1f,%edx
  80047b:	31 d0                	xor    %edx,%eax
  80047d:	29 d0                	sub    %edx,%eax
  80047f:	83 f8 0f             	cmp    $0xf,%eax
  800482:	7f 0b                	jg     80048f <vprintfmt+0x14e>
  800484:	8b 14 85 00 26 80 00 	mov    0x802600(,%eax,4),%edx
  80048b:	85 d2                	test   %edx,%edx
  80048d:	75 20                	jne    8004af <vprintfmt+0x16e>
  80048f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800493:	c7 44 24 08 62 23 80 	movl   $0x802362,0x8(%esp)
  80049a:	00 
  80049b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80049e:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004a2:	89 3c 24             	mov    %edi,(%esp)
  8004a5:	e8 f0 02 00 00       	call   80079a <printfmt>
  8004aa:	e9 a6 fe ff ff       	jmp    800355 <vprintfmt+0x14>
  8004af:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004b3:	c7 44 24 08 42 27 80 	movl   $0x802742,0x8(%esp)
  8004ba:	00 
  8004bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c2:	89 3c 24             	mov    %edi,(%esp)
  8004c5:	e8 d0 02 00 00       	call   80079a <printfmt>
  8004ca:	e9 86 fe ff ff       	jmp    800355 <vprintfmt+0x14>
  8004cf:	8b 75 ec             	mov    0xffffffec(%ebp),%esi
  8004d2:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  8004d5:	89 5d e8             	mov    %ebx,0xffffffe8(%ebp)
  8004d8:	8b 55 14             	mov    0x14(%ebp),%edx
  8004db:	8d 42 04             	lea    0x4(%edx),%eax
  8004de:	89 45 14             	mov    %eax,0x14(%ebp)
  8004e1:	8b 12                	mov    (%edx),%edx
  8004e3:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  8004e6:	85 d2                	test   %edx,%edx
  8004e8:	75 07                	jne    8004f1 <vprintfmt+0x1b0>
  8004ea:	c7 45 d8 6b 23 80 00 	movl   $0x80236b,0xffffffd8(%ebp)
  8004f1:	85 f6                	test   %esi,%esi
  8004f3:	7e 40                	jle    800535 <vprintfmt+0x1f4>
  8004f5:	80 7d e3 2d          	cmpb   $0x2d,0xffffffe3(%ebp)
  8004f9:	74 3a                	je     800535 <vprintfmt+0x1f4>
  8004fb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004ff:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800502:	89 14 24             	mov    %edx,(%esp)
  800505:	e8 e6 02 00 00       	call   8007f0 <strnlen>
  80050a:	29 c6                	sub    %eax,%esi
  80050c:	89 75 ec             	mov    %esi,0xffffffec(%ebp)
  80050f:	85 f6                	test   %esi,%esi
  800511:	7e 22                	jle    800535 <vprintfmt+0x1f4>
  800513:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  800517:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  80051a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80051d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800521:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  800524:	89 04 24             	mov    %eax,(%esp)
  800527:	ff d7                	call   *%edi
  800529:	83 ee 01             	sub    $0x1,%esi
  80052c:	75 ec                	jne    80051a <vprintfmt+0x1d9>
  80052e:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  800535:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800538:	0f b6 02             	movzbl (%edx),%eax
  80053b:	0f be d0             	movsbl %al,%edx
  80053e:	8b 75 d8             	mov    0xffffffd8(%ebp),%esi
  800541:	84 c0                	test   %al,%al
  800543:	75 40                	jne    800585 <vprintfmt+0x244>
  800545:	eb 4a                	jmp    800591 <vprintfmt+0x250>
  800547:	83 7d dc 00          	cmpl   $0x0,0xffffffdc(%ebp)
  80054b:	74 1a                	je     800567 <vprintfmt+0x226>
  80054d:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  800550:	83 f8 5e             	cmp    $0x5e,%eax
  800553:	76 12                	jbe    800567 <vprintfmt+0x226>
  800555:	8b 45 0c             	mov    0xc(%ebp),%eax
  800558:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800563:	ff d7                	call   *%edi
  800565:	eb 0c                	jmp    800573 <vprintfmt+0x232>
  800567:	8b 45 0c             	mov    0xc(%ebp),%eax
  80056a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056e:	89 14 24             	mov    %edx,(%esp)
  800571:	ff d7                	call   *%edi
  800573:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  800577:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80057b:	83 c6 01             	add    $0x1,%esi
  80057e:	84 c0                	test   %al,%al
  800580:	74 0f                	je     800591 <vprintfmt+0x250>
  800582:	0f be d0             	movsbl %al,%edx
  800585:	83 7d e4 00          	cmpl   $0x0,0xffffffe4(%ebp)
  800589:	78 bc                	js     800547 <vprintfmt+0x206>
  80058b:	83 6d e4 01          	subl   $0x1,0xffffffe4(%ebp)
  80058f:	79 b6                	jns    800547 <vprintfmt+0x206>
  800591:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800595:	0f 8e ba fd ff ff    	jle    800355 <vprintfmt+0x14>
  80059b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80059e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005a2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005a9:	ff d7                	call   *%edi
  8005ab:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  8005af:	0f 84 9d fd ff ff    	je     800352 <vprintfmt+0x11>
  8005b5:	eb e4                	jmp    80059b <vprintfmt+0x25a>
  8005b7:	83 f9 01             	cmp    $0x1,%ecx
  8005ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8005c0:	7e 10                	jle    8005d2 <vprintfmt+0x291>
  8005c2:	8b 55 14             	mov    0x14(%ebp),%edx
  8005c5:	8d 42 08             	lea    0x8(%edx),%eax
  8005c8:	89 45 14             	mov    %eax,0x14(%ebp)
  8005cb:	8b 02                	mov    (%edx),%eax
  8005cd:	8b 52 04             	mov    0x4(%edx),%edx
  8005d0:	eb 26                	jmp    8005f8 <vprintfmt+0x2b7>
  8005d2:	85 c9                	test   %ecx,%ecx
  8005d4:	74 12                	je     8005e8 <vprintfmt+0x2a7>
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8d 50 04             	lea    0x4(%eax),%edx
  8005dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005df:	8b 00                	mov    (%eax),%eax
  8005e1:	89 c2                	mov    %eax,%edx
  8005e3:	c1 fa 1f             	sar    $0x1f,%edx
  8005e6:	eb 10                	jmp    8005f8 <vprintfmt+0x2b7>
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8d 50 04             	lea    0x4(%eax),%edx
  8005ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f1:	8b 00                	mov    (%eax),%eax
  8005f3:	89 c2                	mov    %eax,%edx
  8005f5:	c1 fa 1f             	sar    $0x1f,%edx
  8005f8:	89 d1                	mov    %edx,%ecx
  8005fa:	89 c2                	mov    %eax,%edx
  8005fc:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  8005ff:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  800602:	be 0a 00 00 00       	mov    $0xa,%esi
  800607:	85 c9                	test   %ecx,%ecx
  800609:	0f 89 92 00 00 00    	jns    8006a1 <vprintfmt+0x360>
  80060f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800612:	89 74 24 04          	mov    %esi,0x4(%esp)
  800616:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80061d:	ff d7                	call   *%edi
  80061f:	8b 55 d0             	mov    0xffffffd0(%ebp),%edx
  800622:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
  800625:	f7 da                	neg    %edx
  800627:	83 d1 00             	adc    $0x0,%ecx
  80062a:	f7 d9                	neg    %ecx
  80062c:	be 0a 00 00 00       	mov    $0xa,%esi
  800631:	eb 6e                	jmp    8006a1 <vprintfmt+0x360>
  800633:	8d 45 14             	lea    0x14(%ebp),%eax
  800636:	89 ca                	mov    %ecx,%edx
  800638:	e8 ab fc ff ff       	call   8002e8 <getuint>
  80063d:	89 d1                	mov    %edx,%ecx
  80063f:	89 c2                	mov    %eax,%edx
  800641:	be 0a 00 00 00       	mov    $0xa,%esi
  800646:	eb 59                	jmp    8006a1 <vprintfmt+0x360>
  800648:	8d 45 14             	lea    0x14(%ebp),%eax
  80064b:	89 ca                	mov    %ecx,%edx
  80064d:	e8 96 fc ff ff       	call   8002e8 <getuint>
  800652:	e9 fe fc ff ff       	jmp    800355 <vprintfmt+0x14>
  800657:	8b 45 0c             	mov    0xc(%ebp),%eax
  80065a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800665:	ff d7                	call   *%edi
  800667:	8b 55 0c             	mov    0xc(%ebp),%edx
  80066a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80066e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800675:	ff d7                	call   *%edi
  800677:	8b 55 14             	mov    0x14(%ebp),%edx
  80067a:	8d 42 04             	lea    0x4(%edx),%eax
  80067d:	89 45 14             	mov    %eax,0x14(%ebp)
  800680:	8b 12                	mov    (%edx),%edx
  800682:	b9 00 00 00 00       	mov    $0x0,%ecx
  800687:	be 10 00 00 00       	mov    $0x10,%esi
  80068c:	eb 13                	jmp    8006a1 <vprintfmt+0x360>
  80068e:	8d 45 14             	lea    0x14(%ebp),%eax
  800691:	89 ca                	mov    %ecx,%edx
  800693:	e8 50 fc ff ff       	call   8002e8 <getuint>
  800698:	89 d1                	mov    %edx,%ecx
  80069a:	89 c2                	mov    %eax,%edx
  80069c:	be 10 00 00 00       	mov    $0x10,%esi
  8006a1:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  8006a5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006a9:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  8006ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006b0:	89 74 24 08          	mov    %esi,0x8(%esp)
  8006b4:	89 14 24             	mov    %edx,(%esp)
  8006b7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006be:	89 f8                	mov    %edi,%eax
  8006c0:	e8 3b fb ff ff       	call   800200 <printnum>
  8006c5:	e9 8b fc ff ff       	jmp    800355 <vprintfmt+0x14>
  8006ca:	8b 75 0c             	mov    0xc(%ebp),%esi
  8006cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d1:	89 14 24             	mov    %edx,(%esp)
  8006d4:	ff d7                	call   *%edi
  8006d6:	e9 7a fc ff ff       	jmp    800355 <vprintfmt+0x14>
  8006db:	89 de                	mov    %ebx,%esi
  8006dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006eb:	ff d7                	call   *%edi
  8006ed:	83 eb 01             	sub    $0x1,%ebx
  8006f0:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  8006f4:	0f 84 5b fc ff ff    	je     800355 <vprintfmt+0x14>
  8006fa:	8d 56 fd             	lea    0xfffffffd(%esi),%edx
  8006fd:	0f b6 02             	movzbl (%edx),%eax
  800700:	83 ea 01             	sub    $0x1,%edx
  800703:	3c 25                	cmp    $0x25,%al
  800705:	75 f6                	jne    8006fd <vprintfmt+0x3bc>
  800707:	8d 5a 02             	lea    0x2(%edx),%ebx
  80070a:	e9 46 fc ff ff       	jmp    800355 <vprintfmt+0x14>
  80070f:	83 c4 4c             	add    $0x4c,%esp
  800712:	5b                   	pop    %ebx
  800713:	5e                   	pop    %esi
  800714:	5f                   	pop    %edi
  800715:	5d                   	pop    %ebp
  800716:	c3                   	ret    

00800717 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	83 ec 28             	sub    $0x28,%esp
  80071d:	8b 55 08             	mov    0x8(%ebp),%edx
  800720:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800723:	85 d2                	test   %edx,%edx
  800725:	74 04                	je     80072b <vsnprintf+0x14>
  800727:	85 c0                	test   %eax,%eax
  800729:	7f 07                	jg     800732 <vsnprintf+0x1b>
  80072b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800730:	eb 3b                	jmp    80076d <vsnprintf+0x56>
  800732:	c7 45 fc 00 00 00 00 	movl   $0x0,0xfffffffc(%ebp)
  800739:	8d 44 02 ff          	lea    0xffffffff(%edx,%eax,1),%eax
  80073d:	89 45 f8             	mov    %eax,0xfffffff8(%ebp)
  800740:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800743:	8b 45 14             	mov    0x14(%ebp),%eax
  800746:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80074a:	8b 45 10             	mov    0x10(%ebp),%eax
  80074d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800751:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  800754:	89 44 24 04          	mov    %eax,0x4(%esp)
  800758:	c7 04 24 24 03 80 00 	movl   $0x800324,(%esp)
  80075f:	e8 dd fb ff ff       	call   800341 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800764:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  800767:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80076a:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
}
  80076d:	c9                   	leave  
  80076e:	c3                   	ret    

0080076f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800775:	8d 45 14             	lea    0x14(%ebp),%eax
  800778:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  80077b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80077f:	8b 45 10             	mov    0x10(%ebp),%eax
  800782:	89 44 24 08          	mov    %eax,0x8(%esp)
  800786:	8b 45 0c             	mov    0xc(%ebp),%eax
  800789:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078d:	8b 45 08             	mov    0x8(%ebp),%eax
  800790:	89 04 24             	mov    %eax,(%esp)
  800793:	e8 7f ff ff ff       	call   800717 <vsnprintf>
	va_end(ap);

	return rc;
}
  800798:	c9                   	leave  
  800799:	c3                   	ret    

0080079a <printfmt>:
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	83 ec 28             	sub    $0x28,%esp
  8007a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a3:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
  8007a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bb:	89 04 24             	mov    %eax,(%esp)
  8007be:	e8 7e fb ff ff       	call   800341 <vprintfmt>
  8007c3:	c9                   	leave  
  8007c4:	c3                   	ret    
	...

008007d0 <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007db:	80 3a 00             	cmpb   $0x0,(%edx)
  8007de:	74 0e                	je     8007ee <strlen+0x1e>
  8007e0:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007e5:	83 c0 01             	add    $0x1,%eax
  8007e8:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  8007ec:	75 f7                	jne    8007e5 <strlen+0x15>
	return n;
}
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f9:	85 d2                	test   %edx,%edx
  8007fb:	74 19                	je     800816 <strnlen+0x26>
  8007fd:	80 39 00             	cmpb   $0x0,(%ecx)
  800800:	74 14                	je     800816 <strnlen+0x26>
  800802:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800807:	83 c0 01             	add    $0x1,%eax
  80080a:	39 d0                	cmp    %edx,%eax
  80080c:	74 0d                	je     80081b <strnlen+0x2b>
  80080e:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800812:	74 07                	je     80081b <strnlen+0x2b>
  800814:	eb f1                	jmp    800807 <strnlen+0x17>
  800816:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  80081b:	5d                   	pop    %ebp
  80081c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800820:	c3                   	ret    

00800821 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	53                   	push   %ebx
  800825:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800828:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082b:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80082d:	0f b6 01             	movzbl (%ecx),%eax
  800830:	88 02                	mov    %al,(%edx)
  800832:	83 c2 01             	add    $0x1,%edx
  800835:	83 c1 01             	add    $0x1,%ecx
  800838:	84 c0                	test   %al,%al
  80083a:	75 f1                	jne    80082d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80083c:	89 d8                	mov    %ebx,%eax
  80083e:	5b                   	pop    %ebx
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	57                   	push   %edi
  800845:	56                   	push   %esi
  800846:	53                   	push   %ebx
  800847:	8b 7d 08             	mov    0x8(%ebp),%edi
  80084a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800850:	85 f6                	test   %esi,%esi
  800852:	74 1c                	je     800870 <strncpy+0x2f>
  800854:	89 fa                	mov    %edi,%edx
  800856:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  80085b:	0f b6 01             	movzbl (%ecx),%eax
  80085e:	88 02                	mov    %al,(%edx)
  800860:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800863:	80 39 01             	cmpb   $0x1,(%ecx)
  800866:	83 d9 ff             	sbb    $0xffffffff,%ecx
  800869:	83 c3 01             	add    $0x1,%ebx
  80086c:	39 f3                	cmp    %esi,%ebx
  80086e:	75 eb                	jne    80085b <strncpy+0x1a>
	}
	return ret;
}
  800870:	89 f8                	mov    %edi,%eax
  800872:	5b                   	pop    %ebx
  800873:	5e                   	pop    %esi
  800874:	5f                   	pop    %edi
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	56                   	push   %esi
  80087b:	53                   	push   %ebx
  80087c:	8b 75 08             	mov    0x8(%ebp),%esi
  80087f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800882:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800885:	89 f0                	mov    %esi,%eax
  800887:	85 d2                	test   %edx,%edx
  800889:	74 2c                	je     8008b7 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  80088b:	89 d3                	mov    %edx,%ebx
  80088d:	83 eb 01             	sub    $0x1,%ebx
  800890:	74 20                	je     8008b2 <strlcpy+0x3b>
  800892:	0f b6 11             	movzbl (%ecx),%edx
  800895:	84 d2                	test   %dl,%dl
  800897:	74 19                	je     8008b2 <strlcpy+0x3b>
  800899:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  80089b:	88 10                	mov    %dl,(%eax)
  80089d:	83 c0 01             	add    $0x1,%eax
  8008a0:	83 eb 01             	sub    $0x1,%ebx
  8008a3:	74 0f                	je     8008b4 <strlcpy+0x3d>
  8008a5:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  8008a9:	83 c1 01             	add    $0x1,%ecx
  8008ac:	84 d2                	test   %dl,%dl
  8008ae:	74 04                	je     8008b4 <strlcpy+0x3d>
  8008b0:	eb e9                	jmp    80089b <strlcpy+0x24>
  8008b2:	89 f0                	mov    %esi,%eax
		*dst = '\0';
  8008b4:	c6 00 00             	movb   $0x0,(%eax)
  8008b7:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8008b9:	5b                   	pop    %ebx
  8008ba:	5e                   	pop    %esi
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	57                   	push   %edi
  8008c1:	56                   	push   %esi
  8008c2:	53                   	push   %ebx
  8008c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8008c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c9:	8b 7d 10             	mov    0x10(%ebp),%edi
    int c;
    char *q = buf;

    if (buf_size <= 0)
  8008cc:	85 c9                	test   %ecx,%ecx
  8008ce:	7e 30                	jle    800900 <pstrcpy+0x43>
        return;

    for(;;) {
        c = *str++;
  8008d0:	0f b6 07             	movzbl (%edi),%eax
        if (c == 0 || q >= buf + buf_size - 1)
  8008d3:	84 c0                	test   %al,%al
  8008d5:	74 26                	je     8008fd <pstrcpy+0x40>
  8008d7:	8d 74 0a ff          	lea    0xffffffff(%edx,%ecx,1),%esi
  8008db:	0f be d8             	movsbl %al,%ebx
  8008de:	89 f9                	mov    %edi,%ecx
  8008e0:	39 f2                	cmp    %esi,%edx
  8008e2:	72 09                	jb     8008ed <pstrcpy+0x30>
  8008e4:	eb 17                	jmp    8008fd <pstrcpy+0x40>
  8008e6:	83 c1 01             	add    $0x1,%ecx
  8008e9:	39 f2                	cmp    %esi,%edx
  8008eb:	73 10                	jae    8008fd <pstrcpy+0x40>
            break;
        *q++ = c;
  8008ed:	88 1a                	mov    %bl,(%edx)
  8008ef:	83 c2 01             	add    $0x1,%edx
  8008f2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  8008f6:	0f be d8             	movsbl %al,%ebx
  8008f9:	84 c0                	test   %al,%al
  8008fb:	75 e9                	jne    8008e6 <pstrcpy+0x29>
    }
    *q = '\0';
  8008fd:	c6 02 00             	movb   $0x0,(%edx)
}
  800900:	5b                   	pop    %ebx
  800901:	5e                   	pop    %esi
  800902:	5f                   	pop    %edi
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	8b 55 08             	mov    0x8(%ebp),%edx
  80090b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  80090e:	0f b6 02             	movzbl (%edx),%eax
  800911:	84 c0                	test   %al,%al
  800913:	74 16                	je     80092b <strcmp+0x26>
  800915:	3a 01                	cmp    (%ecx),%al
  800917:	75 12                	jne    80092b <strcmp+0x26>
		p++, q++;
  800919:	83 c1 01             	add    $0x1,%ecx
  80091c:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  800920:	84 c0                	test   %al,%al
  800922:	74 07                	je     80092b <strcmp+0x26>
  800924:	83 c2 01             	add    $0x1,%edx
  800927:	3a 01                	cmp    (%ecx),%al
  800929:	74 ee                	je     800919 <strcmp+0x14>
  80092b:	0f b6 c0             	movzbl %al,%eax
  80092e:	0f b6 11             	movzbl (%ecx),%edx
  800931:	29 d0                	sub    %edx,%eax
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	53                   	push   %ebx
  800939:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80093f:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800942:	85 d2                	test   %edx,%edx
  800944:	74 2d                	je     800973 <strncmp+0x3e>
  800946:	0f b6 01             	movzbl (%ecx),%eax
  800949:	84 c0                	test   %al,%al
  80094b:	74 1a                	je     800967 <strncmp+0x32>
  80094d:	3a 03                	cmp    (%ebx),%al
  80094f:	75 16                	jne    800967 <strncmp+0x32>
  800951:	83 ea 01             	sub    $0x1,%edx
  800954:	74 1d                	je     800973 <strncmp+0x3e>
		n--, p++, q++;
  800956:	83 c1 01             	add    $0x1,%ecx
  800959:	83 c3 01             	add    $0x1,%ebx
  80095c:	0f b6 01             	movzbl (%ecx),%eax
  80095f:	84 c0                	test   %al,%al
  800961:	74 04                	je     800967 <strncmp+0x32>
  800963:	3a 03                	cmp    (%ebx),%al
  800965:	74 ea                	je     800951 <strncmp+0x1c>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800967:	0f b6 11             	movzbl (%ecx),%edx
  80096a:	0f b6 03             	movzbl (%ebx),%eax
  80096d:	29 c2                	sub    %eax,%edx
  80096f:	89 d0                	mov    %edx,%eax
  800971:	eb 05                	jmp    800978 <strncmp+0x43>
  800973:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800978:	5b                   	pop    %ebx
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800985:	0f b6 10             	movzbl (%eax),%edx
  800988:	84 d2                	test   %dl,%dl
  80098a:	74 16                	je     8009a2 <strchr+0x27>
		if (*s == c)
  80098c:	38 ca                	cmp    %cl,%dl
  80098e:	75 06                	jne    800996 <strchr+0x1b>
  800990:	eb 15                	jmp    8009a7 <strchr+0x2c>
  800992:	38 ca                	cmp    %cl,%dl
  800994:	74 11                	je     8009a7 <strchr+0x2c>
  800996:	83 c0 01             	add    $0x1,%eax
  800999:	0f b6 10             	movzbl (%eax),%edx
  80099c:	84 d2                	test   %dl,%dl
  80099e:	66 90                	xchg   %ax,%ax
  8009a0:	75 f0                	jne    800992 <strchr+0x17>
  8009a2:	b8 00 00 00 00       	mov    $0x0,%eax
			return (char *) s;
	return 0;
}
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b3:	0f b6 10             	movzbl (%eax),%edx
  8009b6:	84 d2                	test   %dl,%dl
  8009b8:	74 14                	je     8009ce <strfind+0x25>
		if (*s == c)
  8009ba:	38 ca                	cmp    %cl,%dl
  8009bc:	75 06                	jne    8009c4 <strfind+0x1b>
  8009be:	eb 0e                	jmp    8009ce <strfind+0x25>
  8009c0:	38 ca                	cmp    %cl,%dl
  8009c2:	74 0a                	je     8009ce <strfind+0x25>
  8009c4:	83 c0 01             	add    $0x1,%eax
  8009c7:	0f b6 10             	movzbl (%eax),%edx
  8009ca:	84 d2                	test   %dl,%dl
  8009cc:	75 f2                	jne    8009c0 <strfind+0x17>
			break;
	return (char *) s;
}
  8009ce:	5d                   	pop    %ebp
  8009cf:	90                   	nop    
  8009d0:	c3                   	ret    

008009d1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	83 ec 08             	sub    $0x8,%esp
  8009d7:	89 1c 24             	mov    %ebx,(%esp)
  8009da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009de:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  8009e7:	85 db                	test   %ebx,%ebx
  8009e9:	74 32                	je     800a1d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009eb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009f1:	75 25                	jne    800a18 <memset+0x47>
  8009f3:	f6 c3 03             	test   $0x3,%bl
  8009f6:	75 20                	jne    800a18 <memset+0x47>
		c &= 0xFF;
  8009f8:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009fb:	89 d0                	mov    %edx,%eax
  8009fd:	c1 e0 18             	shl    $0x18,%eax
  800a00:	89 d1                	mov    %edx,%ecx
  800a02:	c1 e1 10             	shl    $0x10,%ecx
  800a05:	09 c8                	or     %ecx,%eax
  800a07:	09 d0                	or     %edx,%eax
  800a09:	c1 e2 08             	shl    $0x8,%edx
  800a0c:	09 d0                	or     %edx,%eax
  800a0e:	89 d9                	mov    %ebx,%ecx
  800a10:	c1 e9 02             	shr    $0x2,%ecx
  800a13:	fc                   	cld    
  800a14:	f3 ab                	rep stos %eax,%es:(%edi)
  800a16:	eb 05                	jmp    800a1d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a18:	89 d9                	mov    %ebx,%ecx
  800a1a:	fc                   	cld    
  800a1b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a1d:	89 f8                	mov    %edi,%eax
  800a1f:	8b 1c 24             	mov    (%esp),%ebx
  800a22:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800a26:	89 ec                	mov    %ebp,%esp
  800a28:	5d                   	pop    %ebp
  800a29:	c3                   	ret    

00800a2a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	83 ec 08             	sub    $0x8,%esp
  800a30:	89 34 24             	mov    %esi,(%esp)
  800a33:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a37:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800a3d:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a40:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a42:	39 c6                	cmp    %eax,%esi
  800a44:	73 36                	jae    800a7c <memmove+0x52>
  800a46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a49:	39 d0                	cmp    %edx,%eax
  800a4b:	73 2f                	jae    800a7c <memmove+0x52>
		s += n;
		d += n;
  800a4d:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a50:	f6 c2 03             	test   $0x3,%dl
  800a53:	75 1b                	jne    800a70 <memmove+0x46>
  800a55:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a5b:	75 13                	jne    800a70 <memmove+0x46>
  800a5d:	f6 c1 03             	test   $0x3,%cl
  800a60:	75 0e                	jne    800a70 <memmove+0x46>
			asm volatile("std; rep movsl\n"
  800a62:	8d 7e fc             	lea    0xfffffffc(%esi),%edi
  800a65:	8d 72 fc             	lea    0xfffffffc(%edx),%esi
  800a68:	c1 e9 02             	shr    $0x2,%ecx
  800a6b:	fd                   	std    
  800a6c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6e:	eb 09                	jmp    800a79 <memmove+0x4f>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a70:	8d 7e ff             	lea    0xffffffff(%esi),%edi
  800a73:	8d 72 ff             	lea    0xffffffff(%edx),%esi
  800a76:	fd                   	std    
  800a77:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a79:	fc                   	cld    
  800a7a:	eb 21                	jmp    800a9d <memmove+0x73>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a82:	75 16                	jne    800a9a <memmove+0x70>
  800a84:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a8a:	75 0e                	jne    800a9a <memmove+0x70>
  800a8c:	f6 c1 03             	test   $0x3,%cl
  800a8f:	90                   	nop    
  800a90:	75 08                	jne    800a9a <memmove+0x70>
			asm volatile("cld; rep movsl\n"
  800a92:	c1 e9 02             	shr    $0x2,%ecx
  800a95:	fc                   	cld    
  800a96:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a98:	eb 03                	jmp    800a9d <memmove+0x73>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a9a:	fc                   	cld    
  800a9b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a9d:	8b 34 24             	mov    (%esp),%esi
  800aa0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800aa4:	89 ec                	mov    %ebp,%esp
  800aa6:	5d                   	pop    %ebp
  800aa7:	c3                   	ret    

00800aa8 <memcpy>:

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
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aae:	8b 45 10             	mov    0x10(%ebp),%eax
  800ab1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ab5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800abc:	8b 45 08             	mov    0x8(%ebp),%eax
  800abf:	89 04 24             	mov    %eax,(%esp)
  800ac2:	e8 63 ff ff ff       	call   800a2a <memmove>
}
  800ac7:	c9                   	leave  
  800ac8:	c3                   	ret    

00800ac9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	56                   	push   %esi
  800acd:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ace:	8b 75 10             	mov    0x10(%ebp),%esi
  800ad1:	83 ee 01             	sub    $0x1,%esi
  800ad4:	83 fe ff             	cmp    $0xffffffff,%esi
  800ad7:	74 38                	je     800b11 <memcmp+0x48>
  800ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  800adc:	8b 55 0c             	mov    0xc(%ebp),%edx
		if (*s1 != *s2)
  800adf:	0f b6 18             	movzbl (%eax),%ebx
  800ae2:	0f b6 0a             	movzbl (%edx),%ecx
  800ae5:	38 cb                	cmp    %cl,%bl
  800ae7:	74 20                	je     800b09 <memcmp+0x40>
  800ae9:	eb 12                	jmp    800afd <memcmp+0x34>
  800aeb:	0f b6 58 01          	movzbl 0x1(%eax),%ebx
  800aef:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
  800af3:	83 c0 01             	add    $0x1,%eax
  800af6:	83 c2 01             	add    $0x1,%edx
  800af9:	38 cb                	cmp    %cl,%bl
  800afb:	74 0c                	je     800b09 <memcmp+0x40>
			return (int) *s1 - (int) *s2;
  800afd:	0f b6 d3             	movzbl %bl,%edx
  800b00:	0f b6 c1             	movzbl %cl,%eax
  800b03:	29 c2                	sub    %eax,%edx
  800b05:	89 d0                	mov    %edx,%eax
  800b07:	eb 0d                	jmp    800b16 <memcmp+0x4d>
  800b09:	83 ee 01             	sub    $0x1,%esi
  800b0c:	83 fe ff             	cmp    $0xffffffff,%esi
  800b0f:	75 da                	jne    800aeb <memcmp+0x22>
  800b11:	b8 00 00 00 00       	mov    $0x0,%eax
		s1++, s2++;
	}

	return 0;
}
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	53                   	push   %ebx
  800b1e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800b21:	89 da                	mov    %ebx,%edx
  800b23:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b26:	39 d3                	cmp    %edx,%ebx
  800b28:	73 1a                	jae    800b44 <memfind+0x2a>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b2a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
			break;
  800b2e:	89 d8                	mov    %ebx,%eax
  800b30:	38 0b                	cmp    %cl,(%ebx)
  800b32:	75 06                	jne    800b3a <memfind+0x20>
  800b34:	eb 0e                	jmp    800b44 <memfind+0x2a>
  800b36:	38 08                	cmp    %cl,(%eax)
  800b38:	74 0c                	je     800b46 <memfind+0x2c>
  800b3a:	83 c0 01             	add    $0x1,%eax
  800b3d:	39 d0                	cmp    %edx,%eax
  800b3f:	90                   	nop    
  800b40:	75 f4                	jne    800b36 <memfind+0x1c>
  800b42:	eb 02                	jmp    800b46 <memfind+0x2c>
  800b44:	89 d8                	mov    %ebx,%eax
	return (void *) s;
}
  800b46:	5b                   	pop    %ebx
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    

00800b49 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	57                   	push   %edi
  800b4d:	56                   	push   %esi
  800b4e:	53                   	push   %ebx
  800b4f:	83 ec 04             	sub    $0x4,%esp
  800b52:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b55:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b58:	0f b6 03             	movzbl (%ebx),%eax
  800b5b:	3c 20                	cmp    $0x20,%al
  800b5d:	74 04                	je     800b63 <strtol+0x1a>
  800b5f:	3c 09                	cmp    $0x9,%al
  800b61:	75 0e                	jne    800b71 <strtol+0x28>
		s++;
  800b63:	83 c3 01             	add    $0x1,%ebx
  800b66:	0f b6 03             	movzbl (%ebx),%eax
  800b69:	3c 20                	cmp    $0x20,%al
  800b6b:	74 f6                	je     800b63 <strtol+0x1a>
  800b6d:	3c 09                	cmp    $0x9,%al
  800b6f:	74 f2                	je     800b63 <strtol+0x1a>

	// plus/minus sign
	if (*s == '+')
  800b71:	3c 2b                	cmp    $0x2b,%al
  800b73:	75 0d                	jne    800b82 <strtol+0x39>
		s++;
  800b75:	83 c3 01             	add    $0x1,%ebx
  800b78:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800b7f:	90                   	nop    
  800b80:	eb 15                	jmp    800b97 <strtol+0x4e>
	else if (*s == '-')
  800b82:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800b89:	3c 2d                	cmp    $0x2d,%al
  800b8b:	75 0a                	jne    800b97 <strtol+0x4e>
		s++, neg = 1;
  800b8d:	83 c3 01             	add    $0x1,%ebx
  800b90:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b97:	85 f6                	test   %esi,%esi
  800b99:	0f 94 c0             	sete   %al
  800b9c:	84 c0                	test   %al,%al
  800b9e:	75 05                	jne    800ba5 <strtol+0x5c>
  800ba0:	83 fe 10             	cmp    $0x10,%esi
  800ba3:	75 17                	jne    800bbc <strtol+0x73>
  800ba5:	80 3b 30             	cmpb   $0x30,(%ebx)
  800ba8:	75 12                	jne    800bbc <strtol+0x73>
  800baa:	80 7b 01 78          	cmpb   $0x78,0x1(%ebx)
  800bae:	66 90                	xchg   %ax,%ax
  800bb0:	75 0a                	jne    800bbc <strtol+0x73>
		s += 2, base = 16;
  800bb2:	83 c3 02             	add    $0x2,%ebx
  800bb5:	be 10 00 00 00       	mov    $0x10,%esi
  800bba:	eb 1f                	jmp    800bdb <strtol+0x92>
	else if (base == 0 && s[0] == '0')
  800bbc:	85 f6                	test   %esi,%esi
  800bbe:	66 90                	xchg   %ax,%ax
  800bc0:	75 10                	jne    800bd2 <strtol+0x89>
  800bc2:	80 3b 30             	cmpb   $0x30,(%ebx)
  800bc5:	75 0b                	jne    800bd2 <strtol+0x89>
		s++, base = 8;
  800bc7:	83 c3 01             	add    $0x1,%ebx
  800bca:	66 be 08 00          	mov    $0x8,%si
  800bce:	66 90                	xchg   %ax,%ax
  800bd0:	eb 09                	jmp    800bdb <strtol+0x92>
	else if (base == 0)
  800bd2:	84 c0                	test   %al,%al
  800bd4:	74 05                	je     800bdb <strtol+0x92>
  800bd6:	be 0a 00 00 00       	mov    $0xa,%esi
  800bdb:	bf 00 00 00 00       	mov    $0x0,%edi
		base = 10;

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800be0:	0f b6 13             	movzbl (%ebx),%edx
  800be3:	89 d1                	mov    %edx,%ecx
  800be5:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800be8:	3c 09                	cmp    $0x9,%al
  800bea:	77 08                	ja     800bf4 <strtol+0xab>
			dig = *s - '0';
  800bec:	0f be c2             	movsbl %dl,%eax
  800bef:	8d 50 d0             	lea    0xffffffd0(%eax),%edx
  800bf2:	eb 1c                	jmp    800c10 <strtol+0xc7>
		else if (*s >= 'a' && *s <= 'z')
  800bf4:	8d 41 9f             	lea    0xffffff9f(%ecx),%eax
  800bf7:	3c 19                	cmp    $0x19,%al
  800bf9:	77 08                	ja     800c03 <strtol+0xba>
			dig = *s - 'a' + 10;
  800bfb:	0f be c2             	movsbl %dl,%eax
  800bfe:	8d 50 a9             	lea    0xffffffa9(%eax),%edx
  800c01:	eb 0d                	jmp    800c10 <strtol+0xc7>
		else if (*s >= 'A' && *s <= 'Z')
  800c03:	8d 41 bf             	lea    0xffffffbf(%ecx),%eax
  800c06:	3c 19                	cmp    $0x19,%al
  800c08:	77 17                	ja     800c21 <strtol+0xd8>
			dig = *s - 'A' + 10;
  800c0a:	0f be c2             	movsbl %dl,%eax
  800c0d:	8d 50 c9             	lea    0xffffffc9(%eax),%edx
		else
			break;
		if (dig >= base)
  800c10:	39 f2                	cmp    %esi,%edx
  800c12:	7d 0d                	jge    800c21 <strtol+0xd8>
			break;
		s++, val = (val * base) + dig;
  800c14:	83 c3 01             	add    $0x1,%ebx
  800c17:	89 f8                	mov    %edi,%eax
  800c19:	0f af c6             	imul   %esi,%eax
  800c1c:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800c1f:	eb bf                	jmp    800be0 <strtol+0x97>
		// we don't properly detect overflow!
	}
  800c21:	89 f8                	mov    %edi,%eax

	if (endptr)
  800c23:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c27:	74 05                	je     800c2e <strtol+0xe5>
		*endptr = (char *) s;
  800c29:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c2c:	89 1a                	mov    %ebx,(%edx)
	return (neg ? -val : val);
  800c2e:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800c32:	74 04                	je     800c38 <strtol+0xef>
  800c34:	89 c7                	mov    %eax,%edi
  800c36:	f7 df                	neg    %edi
}
  800c38:	89 f8                	mov    %edi,%eax
  800c3a:	83 c4 04             	add    $0x4,%esp
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    
	...

00800c44 <sys_cgetc>:
}

int
sys_cgetc(void)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	83 ec 0c             	sub    $0xc,%esp
  800c4a:	89 1c 24             	mov    %ebx,(%esp)
  800c4d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c51:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c55:	b8 01 00 00 00       	mov    $0x1,%eax
  800c5a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c5f:	89 fa                	mov    %edi,%edx
  800c61:	89 f9                	mov    %edi,%ecx
  800c63:	89 fb                	mov    %edi,%ebx
  800c65:	89 fe                	mov    %edi,%esi
  800c67:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c69:	8b 1c 24             	mov    (%esp),%ebx
  800c6c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c70:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c74:	89 ec                	mov    %ebp,%esp
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    

00800c78 <sys_cputs>:
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	83 ec 0c             	sub    $0xc,%esp
  800c7e:	89 1c 24             	mov    %ebx,(%esp)
  800c81:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c85:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c89:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c94:	89 f8                	mov    %edi,%eax
  800c96:	89 fb                	mov    %edi,%ebx
  800c98:	89 fe                	mov    %edi,%esi
  800c9a:	cd 30                	int    $0x30
  800c9c:	8b 1c 24             	mov    (%esp),%ebx
  800c9f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ca3:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ca7:	89 ec                	mov    %ebp,%esp
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <sys_time_msec>:

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
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	83 ec 0c             	sub    $0xc,%esp
  800cb1:	89 1c 24             	mov    %ebx,(%esp)
  800cb4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cb8:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800cbc:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cc1:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc6:	89 fa                	mov    %edi,%edx
  800cc8:	89 f9                	mov    %edi,%ecx
  800cca:	89 fb                	mov    %edi,%ebx
  800ccc:	89 fe                	mov    %edi,%esi
  800cce:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800cd0:	8b 1c 24             	mov    (%esp),%ebx
  800cd3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cd7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cdb:	89 ec                	mov    %ebp,%esp
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <sys_ipc_recv>:
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	83 ec 28             	sub    $0x28,%esp
  800ce5:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800ce8:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800ceb:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800cee:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cf6:	bf 00 00 00 00       	mov    $0x0,%edi
  800cfb:	89 f9                	mov    %edi,%ecx
  800cfd:	89 fb                	mov    %edi,%ebx
  800cff:	89 fe                	mov    %edi,%esi
  800d01:	cd 30                	int    $0x30
  800d03:	85 c0                	test   %eax,%eax
  800d05:	7e 28                	jle    800d2f <sys_ipc_recv+0x50>
  800d07:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d0b:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d12:	00 
  800d13:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800d1a:	00 
  800d1b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d22:	00 
  800d23:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800d2a:	e8 19 11 00 00       	call   801e48 <_panic>
  800d2f:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800d32:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800d35:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800d38:	89 ec                	mov    %ebp,%esp
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <sys_ipc_try_send>:
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	83 ec 0c             	sub    $0xc,%esp
  800d42:	89 1c 24             	mov    %ebx,(%esp)
  800d45:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d49:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d53:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d56:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d59:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d5e:	be 00 00 00 00       	mov    $0x0,%esi
  800d63:	cd 30                	int    $0x30
  800d65:	8b 1c 24             	mov    (%esp),%ebx
  800d68:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d6c:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d70:	89 ec                	mov    %ebp,%esp
  800d72:	5d                   	pop    %ebp
  800d73:	c3                   	ret    

00800d74 <sys_env_set_pgfault_upcall>:
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	83 ec 28             	sub    $0x28,%esp
  800d7a:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800d7d:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800d80:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800d83:	8b 55 08             	mov    0x8(%ebp),%edx
  800d86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d89:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d8e:	bf 00 00 00 00       	mov    $0x0,%edi
  800d93:	89 fb                	mov    %edi,%ebx
  800d95:	89 fe                	mov    %edi,%esi
  800d97:	cd 30                	int    $0x30
  800d99:	85 c0                	test   %eax,%eax
  800d9b:	7e 28                	jle    800dc5 <sys_env_set_pgfault_upcall+0x51>
  800d9d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da1:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800da8:	00 
  800da9:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800db0:	00 
  800db1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db8:	00 
  800db9:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800dc0:	e8 83 10 00 00       	call   801e48 <_panic>
  800dc5:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800dc8:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800dcb:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800dce:	89 ec                	mov    %ebp,%esp
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    

00800dd2 <sys_env_set_trapframe>:
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	83 ec 28             	sub    $0x28,%esp
  800dd8:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800ddb:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800dde:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800de1:	8b 55 08             	mov    0x8(%ebp),%edx
  800de4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de7:	b8 09 00 00 00       	mov    $0x9,%eax
  800dec:	bf 00 00 00 00       	mov    $0x0,%edi
  800df1:	89 fb                	mov    %edi,%ebx
  800df3:	89 fe                	mov    %edi,%esi
  800df5:	cd 30                	int    $0x30
  800df7:	85 c0                	test   %eax,%eax
  800df9:	7e 28                	jle    800e23 <sys_env_set_trapframe+0x51>
  800dfb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dff:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e06:	00 
  800e07:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800e0e:	00 
  800e0f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e16:	00 
  800e17:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800e1e:	e8 25 10 00 00       	call   801e48 <_panic>
  800e23:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800e26:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800e29:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800e2c:	89 ec                	mov    %ebp,%esp
  800e2e:	5d                   	pop    %ebp
  800e2f:	c3                   	ret    

00800e30 <sys_env_set_status>:
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
  800e33:	83 ec 28             	sub    $0x28,%esp
  800e36:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800e39:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800e3c:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800e3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e45:	b8 08 00 00 00       	mov    $0x8,%eax
  800e4a:	bf 00 00 00 00       	mov    $0x0,%edi
  800e4f:	89 fb                	mov    %edi,%ebx
  800e51:	89 fe                	mov    %edi,%esi
  800e53:	cd 30                	int    $0x30
  800e55:	85 c0                	test   %eax,%eax
  800e57:	7e 28                	jle    800e81 <sys_env_set_status+0x51>
  800e59:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e5d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e64:	00 
  800e65:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800e6c:	00 
  800e6d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e74:	00 
  800e75:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800e7c:	e8 c7 0f 00 00       	call   801e48 <_panic>
  800e81:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800e84:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800e87:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800e8a:	89 ec                	mov    %ebp,%esp
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <sys_page_unmap>:
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	83 ec 28             	sub    $0x28,%esp
  800e94:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800e97:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800e9a:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800e9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea3:	b8 06 00 00 00       	mov    $0x6,%eax
  800ea8:	bf 00 00 00 00       	mov    $0x0,%edi
  800ead:	89 fb                	mov    %edi,%ebx
  800eaf:	89 fe                	mov    %edi,%esi
  800eb1:	cd 30                	int    $0x30
  800eb3:	85 c0                	test   %eax,%eax
  800eb5:	7e 28                	jle    800edf <sys_page_unmap+0x51>
  800eb7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ebb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ec2:	00 
  800ec3:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800eca:	00 
  800ecb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed2:	00 
  800ed3:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800eda:	e8 69 0f 00 00       	call   801e48 <_panic>
  800edf:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800ee2:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800ee5:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800ee8:	89 ec                	mov    %ebp,%esp
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    

00800eec <sys_page_map>:
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	83 ec 28             	sub    $0x28,%esp
  800ef2:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800ef5:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800ef8:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800efb:	8b 55 08             	mov    0x8(%ebp),%edx
  800efe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f04:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f07:	8b 75 18             	mov    0x18(%ebp),%esi
  800f0a:	b8 05 00 00 00       	mov    $0x5,%eax
  800f0f:	cd 30                	int    $0x30
  800f11:	85 c0                	test   %eax,%eax
  800f13:	7e 28                	jle    800f3d <sys_page_map+0x51>
  800f15:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f19:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f20:	00 
  800f21:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800f28:	00 
  800f29:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f30:	00 
  800f31:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800f38:	e8 0b 0f 00 00       	call   801e48 <_panic>
  800f3d:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800f40:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800f43:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800f46:	89 ec                	mov    %ebp,%esp
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    

00800f4a <sys_page_alloc>:
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	83 ec 28             	sub    $0x28,%esp
  800f50:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800f53:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800f56:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800f59:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f62:	b8 04 00 00 00       	mov    $0x4,%eax
  800f67:	bf 00 00 00 00       	mov    $0x0,%edi
  800f6c:	89 fe                	mov    %edi,%esi
  800f6e:	cd 30                	int    $0x30
  800f70:	85 c0                	test   %eax,%eax
  800f72:	7e 28                	jle    800f9c <sys_page_alloc+0x52>
  800f74:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f78:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f7f:	00 
  800f80:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800f87:	00 
  800f88:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f8f:	00 
  800f90:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800f97:	e8 ac 0e 00 00       	call   801e48 <_panic>
  800f9c:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800f9f:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800fa2:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800fa5:	89 ec                	mov    %ebp,%esp
  800fa7:	5d                   	pop    %ebp
  800fa8:	c3                   	ret    

00800fa9 <sys_yield>:
  800fa9:	55                   	push   %ebp
  800faa:	89 e5                	mov    %esp,%ebp
  800fac:	83 ec 0c             	sub    $0xc,%esp
  800faf:	89 1c 24             	mov    %ebx,(%esp)
  800fb2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fb6:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800fba:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fbf:	bf 00 00 00 00       	mov    $0x0,%edi
  800fc4:	89 fa                	mov    %edi,%edx
  800fc6:	89 f9                	mov    %edi,%ecx
  800fc8:	89 fb                	mov    %edi,%ebx
  800fca:	89 fe                	mov    %edi,%esi
  800fcc:	cd 30                	int    $0x30
  800fce:	8b 1c 24             	mov    (%esp),%ebx
  800fd1:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fd5:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fd9:	89 ec                	mov    %ebp,%esp
  800fdb:	5d                   	pop    %ebp
  800fdc:	c3                   	ret    

00800fdd <sys_getenvid>:
  800fdd:	55                   	push   %ebp
  800fde:	89 e5                	mov    %esp,%ebp
  800fe0:	83 ec 0c             	sub    $0xc,%esp
  800fe3:	89 1c 24             	mov    %ebx,(%esp)
  800fe6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fea:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800fee:	b8 02 00 00 00       	mov    $0x2,%eax
  800ff3:	bf 00 00 00 00       	mov    $0x0,%edi
  800ff8:	89 fa                	mov    %edi,%edx
  800ffa:	89 f9                	mov    %edi,%ecx
  800ffc:	89 fb                	mov    %edi,%ebx
  800ffe:	89 fe                	mov    %edi,%esi
  801000:	cd 30                	int    $0x30
  801002:	8b 1c 24             	mov    (%esp),%ebx
  801005:	8b 74 24 04          	mov    0x4(%esp),%esi
  801009:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80100d:	89 ec                	mov    %ebp,%esp
  80100f:	5d                   	pop    %ebp
  801010:	c3                   	ret    

00801011 <sys_env_destroy>:
  801011:	55                   	push   %ebp
  801012:	89 e5                	mov    %esp,%ebp
  801014:	83 ec 28             	sub    $0x28,%esp
  801017:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  80101a:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  80101d:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  801020:	8b 55 08             	mov    0x8(%ebp),%edx
  801023:	b8 03 00 00 00       	mov    $0x3,%eax
  801028:	bf 00 00 00 00       	mov    $0x0,%edi
  80102d:	89 f9                	mov    %edi,%ecx
  80102f:	89 fb                	mov    %edi,%ebx
  801031:	89 fe                	mov    %edi,%esi
  801033:	cd 30                	int    $0x30
  801035:	85 c0                	test   %eax,%eax
  801037:	7e 28                	jle    801061 <sys_env_destroy+0x50>
  801039:	89 44 24 10          	mov    %eax,0x10(%esp)
  80103d:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801044:	00 
  801045:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  80104c:	00 
  80104d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801054:	00 
  801055:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  80105c:	e8 e7 0d 00 00       	call   801e48 <_panic>
  801061:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801064:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801067:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  80106a:	89 ec                	mov    %ebp,%esp
  80106c:	5d                   	pop    %ebp
  80106d:	c3                   	ret    
	...

00801070 <fd2num>:
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	8b 45 08             	mov    0x8(%ebp),%eax
  801076:	05 00 00 00 30       	add    $0x30000000,%eax
  80107b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80107e:	5d                   	pop    %ebp
  80107f:	c3                   	ret    

00801080 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801086:	8b 45 08             	mov    0x8(%ebp),%eax
  801089:	89 04 24             	mov    %eax,(%esp)
  80108c:	e8 df ff ff ff       	call   801070 <fd2num>
  801091:	c1 e0 0c             	shl    $0xc,%eax
  801094:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801099:	c9                   	leave  
  80109a:	c3                   	ret    

0080109b <fd_alloc>:

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
  80109b:	55                   	push   %ebp
  80109c:	89 e5                	mov    %esp,%ebp
  80109e:	53                   	push   %ebx
  80109f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8010a2:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  8010a7:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  8010a9:	89 d0                	mov    %edx,%eax
  8010ab:	c1 e8 16             	shr    $0x16,%eax
  8010ae:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  8010b5:	a8 01                	test   $0x1,%al
  8010b7:	74 10                	je     8010c9 <fd_alloc+0x2e>
  8010b9:	89 d0                	mov    %edx,%eax
  8010bb:	c1 e8 0c             	shr    $0xc,%eax
  8010be:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  8010c5:	a8 01                	test   $0x1,%al
  8010c7:	75 09                	jne    8010d2 <fd_alloc+0x37>
			*fd_store = fd;
  8010c9:	89 0b                	mov    %ecx,(%ebx)
  8010cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d0:	eb 19                	jmp    8010eb <fd_alloc+0x50>
			return 0;
  8010d2:	81 c2 00 10 00 00    	add    $0x1000,%edx
  8010d8:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  8010de:	75 c7                	jne    8010a7 <fd_alloc+0xc>
		}
	}
	*fd_store = 0;
  8010e0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010e6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8010eb:	5b                   	pop    %ebx
  8010ec:	5d                   	pop    %ebp
  8010ed:	c3                   	ret    

008010ee <fd_lookup>:

// Check that fdnum is in range and mapped.
// If it is, set *fd_store to the fd page virtual address.
//
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010ee:	55                   	push   %ebp
  8010ef:	89 e5                	mov    %esp,%ebp
  8010f1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010f4:	83 f8 1f             	cmp    $0x1f,%eax
  8010f7:	77 35                	ja     80112e <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010f9:	c1 e0 0c             	shl    $0xc,%eax
  8010fc:	8d 90 00 00 00 d0    	lea    0xd0000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  801102:	89 d0                	mov    %edx,%eax
  801104:	c1 e8 16             	shr    $0x16,%eax
  801107:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  80110e:	a8 01                	test   $0x1,%al
  801110:	74 1c                	je     80112e <fd_lookup+0x40>
  801112:	89 d0                	mov    %edx,%eax
  801114:	c1 e8 0c             	shr    $0xc,%eax
  801117:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  80111e:	a8 01                	test   $0x1,%al
  801120:	74 0c                	je     80112e <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801122:	8b 45 0c             	mov    0xc(%ebp),%eax
  801125:	89 10                	mov    %edx,(%eax)
  801127:	b8 00 00 00 00       	mov    $0x0,%eax
  80112c:	eb 05                	jmp    801133 <fd_lookup+0x45>
	return 0;
  80112e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801133:	5d                   	pop    %ebp
  801134:	c3                   	ret    

00801135 <seek>:

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
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80113b:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  80113e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801142:	8b 45 08             	mov    0x8(%ebp),%eax
  801145:	89 04 24             	mov    %eax,(%esp)
  801148:	e8 a1 ff ff ff       	call   8010ee <fd_lookup>
  80114d:	85 c0                	test   %eax,%eax
  80114f:	78 0e                	js     80115f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801151:	8b 55 0c             	mov    0xc(%ebp),%edx
  801154:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  801157:	89 50 04             	mov    %edx,0x4(%eax)
  80115a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80115f:	c9                   	leave  
  801160:	c3                   	ret    

00801161 <dev_lookup>:
  801161:	55                   	push   %ebp
  801162:	89 e5                	mov    %esp,%ebp
  801164:	53                   	push   %ebx
  801165:	83 ec 14             	sub    $0x14,%esp
  801168:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80116b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80116e:	ba 04 60 80 00       	mov    $0x806004,%edx
  801173:	b8 00 00 00 00       	mov    $0x0,%eax
  801178:	39 0d 04 60 80 00    	cmp    %ecx,0x806004
  80117e:	75 12                	jne    801192 <dev_lookup+0x31>
  801180:	eb 04                	jmp    801186 <dev_lookup+0x25>
  801182:	39 0a                	cmp    %ecx,(%edx)
  801184:	75 0c                	jne    801192 <dev_lookup+0x31>
  801186:	89 13                	mov    %edx,(%ebx)
  801188:	b8 00 00 00 00       	mov    $0x0,%eax
  80118d:	8d 76 00             	lea    0x0(%esi),%esi
  801190:	eb 35                	jmp    8011c7 <dev_lookup+0x66>
  801192:	83 c0 01             	add    $0x1,%eax
  801195:	8b 14 85 0c 27 80 00 	mov    0x80270c(,%eax,4),%edx
  80119c:	85 d2                	test   %edx,%edx
  80119e:	75 e2                	jne    801182 <dev_lookup+0x21>
  8011a0:	a1 3c 60 80 00       	mov    0x80603c,%eax
  8011a5:	8b 40 4c             	mov    0x4c(%eax),%eax
  8011a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b0:	c7 04 24 8c 26 80 00 	movl   $0x80268c,(%esp)
  8011b7:	e8 e5 ef ff ff       	call   8001a1 <cprintf>
  8011bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8011c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011c7:	83 c4 14             	add    $0x14,%esp
  8011ca:	5b                   	pop    %ebx
  8011cb:	5d                   	pop    %ebp
  8011cc:	c3                   	ret    

008011cd <fstat>:

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
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	53                   	push   %ebx
  8011d1:	83 ec 24             	sub    $0x24,%esp
  8011d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011d7:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8011da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011de:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e1:	89 04 24             	mov    %eax,(%esp)
  8011e4:	e8 05 ff ff ff       	call   8010ee <fd_lookup>
  8011e9:	89 c2                	mov    %eax,%edx
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	78 57                	js     801246 <fstat+0x79>
  8011ef:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  8011f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f6:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8011f9:	8b 00                	mov    (%eax),%eax
  8011fb:	89 04 24             	mov    %eax,(%esp)
  8011fe:	e8 5e ff ff ff       	call   801161 <dev_lookup>
  801203:	89 c2                	mov    %eax,%edx
  801205:	85 c0                	test   %eax,%eax
  801207:	78 3d                	js     801246 <fstat+0x79>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801209:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  80120e:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
  801211:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801215:	74 2f                	je     801246 <fstat+0x79>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801217:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80121a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801221:	00 00 00 
	stat->st_isdir = 0;
  801224:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80122b:	00 00 00 
	stat->st_dev = dev;
  80122e:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801231:	89 93 88 00 00 00    	mov    %edx,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801237:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80123b:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80123e:	89 04 24             	mov    %eax,(%esp)
  801241:	ff 52 14             	call   *0x14(%edx)
  801244:	89 c2                	mov    %eax,%edx
}
  801246:	89 d0                	mov    %edx,%eax
  801248:	83 c4 24             	add    $0x24,%esp
  80124b:	5b                   	pop    %ebx
  80124c:	5d                   	pop    %ebp
  80124d:	c3                   	ret    

0080124e <ftruncate>:
  80124e:	55                   	push   %ebp
  80124f:	89 e5                	mov    %esp,%ebp
  801251:	53                   	push   %ebx
  801252:	83 ec 24             	sub    $0x24,%esp
  801255:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801258:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80125b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80125f:	89 1c 24             	mov    %ebx,(%esp)
  801262:	e8 87 fe ff ff       	call   8010ee <fd_lookup>
  801267:	85 c0                	test   %eax,%eax
  801269:	78 61                	js     8012cc <ftruncate+0x7e>
  80126b:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80126e:	8b 10                	mov    (%eax),%edx
  801270:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801273:	89 44 24 04          	mov    %eax,0x4(%esp)
  801277:	89 14 24             	mov    %edx,(%esp)
  80127a:	e8 e2 fe ff ff       	call   801161 <dev_lookup>
  80127f:	85 c0                	test   %eax,%eax
  801281:	78 49                	js     8012cc <ftruncate+0x7e>
  801283:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  801286:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  80128a:	75 23                	jne    8012af <ftruncate+0x61>
  80128c:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801291:	8b 40 4c             	mov    0x4c(%eax),%eax
  801294:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801298:	89 44 24 04          	mov    %eax,0x4(%esp)
  80129c:	c7 04 24 ac 26 80 00 	movl   $0x8026ac,(%esp)
  8012a3:	e8 f9 ee ff ff       	call   8001a1 <cprintf>
  8012a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ad:	eb 1d                	jmp    8012cc <ftruncate+0x7e>
  8012af:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  8012b2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012b7:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  8012bb:	74 0f                	je     8012cc <ftruncate+0x7e>
  8012bd:	8b 52 18             	mov    0x18(%edx),%edx
  8012c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c7:	89 0c 24             	mov    %ecx,(%esp)
  8012ca:	ff d2                	call   *%edx
  8012cc:	83 c4 24             	add    $0x24,%esp
  8012cf:	5b                   	pop    %ebx
  8012d0:	5d                   	pop    %ebp
  8012d1:	c3                   	ret    

008012d2 <write>:
  8012d2:	55                   	push   %ebp
  8012d3:	89 e5                	mov    %esp,%ebp
  8012d5:	53                   	push   %ebx
  8012d6:	83 ec 24             	sub    $0x24,%esp
  8012d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012dc:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8012df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e3:	89 1c 24             	mov    %ebx,(%esp)
  8012e6:	e8 03 fe ff ff       	call   8010ee <fd_lookup>
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	78 68                	js     801357 <write+0x85>
  8012ef:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8012f2:	8b 10                	mov    (%eax),%edx
  8012f4:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  8012f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012fb:	89 14 24             	mov    %edx,(%esp)
  8012fe:	e8 5e fe ff ff       	call   801161 <dev_lookup>
  801303:	85 c0                	test   %eax,%eax
  801305:	78 50                	js     801357 <write+0x85>
  801307:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  80130a:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  80130e:	75 23                	jne    801333 <write+0x61>
  801310:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801315:	8b 40 4c             	mov    0x4c(%eax),%eax
  801318:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80131c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801320:	c7 04 24 d0 26 80 00 	movl   $0x8026d0,(%esp)
  801327:	e8 75 ee ff ff       	call   8001a1 <cprintf>
  80132c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801331:	eb 24                	jmp    801357 <write+0x85>
  801333:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801336:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80133b:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  80133f:	74 16                	je     801357 <write+0x85>
  801341:	8b 42 0c             	mov    0xc(%edx),%eax
  801344:	8b 55 10             	mov    0x10(%ebp),%edx
  801347:	89 54 24 08          	mov    %edx,0x8(%esp)
  80134b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80134e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801352:	89 0c 24             	mov    %ecx,(%esp)
  801355:	ff d0                	call   *%eax
  801357:	83 c4 24             	add    $0x24,%esp
  80135a:	5b                   	pop    %ebx
  80135b:	5d                   	pop    %ebp
  80135c:	c3                   	ret    

0080135d <read>:
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	53                   	push   %ebx
  801361:	83 ec 24             	sub    $0x24,%esp
  801364:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801367:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80136a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136e:	89 1c 24             	mov    %ebx,(%esp)
  801371:	e8 78 fd ff ff       	call   8010ee <fd_lookup>
  801376:	85 c0                	test   %eax,%eax
  801378:	78 6d                	js     8013e7 <read+0x8a>
  80137a:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80137d:	8b 10                	mov    (%eax),%edx
  80137f:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801382:	89 44 24 04          	mov    %eax,0x4(%esp)
  801386:	89 14 24             	mov    %edx,(%esp)
  801389:	e8 d3 fd ff ff       	call   801161 <dev_lookup>
  80138e:	85 c0                	test   %eax,%eax
  801390:	78 55                	js     8013e7 <read+0x8a>
  801392:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  801395:	8b 41 08             	mov    0x8(%ecx),%eax
  801398:	83 e0 03             	and    $0x3,%eax
  80139b:	83 f8 01             	cmp    $0x1,%eax
  80139e:	75 23                	jne    8013c3 <read+0x66>
  8013a0:	a1 3c 60 80 00       	mov    0x80603c,%eax
  8013a5:	8b 40 4c             	mov    0x4c(%eax),%eax
  8013a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b0:	c7 04 24 ed 26 80 00 	movl   $0x8026ed,(%esp)
  8013b7:	e8 e5 ed ff ff       	call   8001a1 <cprintf>
  8013bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013c1:	eb 24                	jmp    8013e7 <read+0x8a>
  8013c3:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  8013c6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013cb:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  8013cf:	74 16                	je     8013e7 <read+0x8a>
  8013d1:	8b 42 08             	mov    0x8(%edx),%eax
  8013d4:	8b 55 10             	mov    0x10(%ebp),%edx
  8013d7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8013db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013de:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013e2:	89 0c 24             	mov    %ecx,(%esp)
  8013e5:	ff d0                	call   *%eax
  8013e7:	83 c4 24             	add    $0x24,%esp
  8013ea:	5b                   	pop    %ebx
  8013eb:	5d                   	pop    %ebp
  8013ec:	c3                   	ret    

008013ed <readn>:
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
  8013f0:	57                   	push   %edi
  8013f1:	56                   	push   %esi
  8013f2:	53                   	push   %ebx
  8013f3:	83 ec 0c             	sub    $0xc,%esp
  8013f6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8013f9:	8b 75 10             	mov    0x10(%ebp),%esi
  8013fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801401:	85 f6                	test   %esi,%esi
  801403:	74 36                	je     80143b <readn+0x4e>
  801405:	bb 00 00 00 00       	mov    $0x0,%ebx
  80140a:	ba 00 00 00 00       	mov    $0x0,%edx
  80140f:	89 f0                	mov    %esi,%eax
  801411:	29 d0                	sub    %edx,%eax
  801413:	89 44 24 08          	mov    %eax,0x8(%esp)
  801417:	8d 04 17             	lea    (%edi,%edx,1),%eax
  80141a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141e:	8b 45 08             	mov    0x8(%ebp),%eax
  801421:	89 04 24             	mov    %eax,(%esp)
  801424:	e8 34 ff ff ff       	call   80135d <read>
  801429:	85 c0                	test   %eax,%eax
  80142b:	78 0e                	js     80143b <readn+0x4e>
  80142d:	85 c0                	test   %eax,%eax
  80142f:	74 08                	je     801439 <readn+0x4c>
  801431:	01 c3                	add    %eax,%ebx
  801433:	89 da                	mov    %ebx,%edx
  801435:	39 f3                	cmp    %esi,%ebx
  801437:	72 d6                	jb     80140f <readn+0x22>
  801439:	89 d8                	mov    %ebx,%eax
  80143b:	83 c4 0c             	add    $0xc,%esp
  80143e:	5b                   	pop    %ebx
  80143f:	5e                   	pop    %esi
  801440:	5f                   	pop    %edi
  801441:	5d                   	pop    %ebp
  801442:	c3                   	ret    

00801443 <fd_close>:
  801443:	55                   	push   %ebp
  801444:	89 e5                	mov    %esp,%ebp
  801446:	83 ec 28             	sub    $0x28,%esp
  801449:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  80144c:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  80144f:	8b 75 08             	mov    0x8(%ebp),%esi
  801452:	89 34 24             	mov    %esi,(%esp)
  801455:	e8 16 fc ff ff       	call   801070 <fd2num>
  80145a:	8d 55 f4             	lea    0xfffffff4(%ebp),%edx
  80145d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801461:	89 04 24             	mov    %eax,(%esp)
  801464:	e8 85 fc ff ff       	call   8010ee <fd_lookup>
  801469:	89 c3                	mov    %eax,%ebx
  80146b:	85 c0                	test   %eax,%eax
  80146d:	78 05                	js     801474 <fd_close+0x31>
  80146f:	3b 75 f4             	cmp    0xfffffff4(%ebp),%esi
  801472:	74 0e                	je     801482 <fd_close+0x3f>
  801474:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801478:	75 45                	jne    8014bf <fd_close+0x7c>
  80147a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80147f:	90                   	nop    
  801480:	eb 3d                	jmp    8014bf <fd_close+0x7c>
  801482:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  801485:	89 44 24 04          	mov    %eax,0x4(%esp)
  801489:	8b 06                	mov    (%esi),%eax
  80148b:	89 04 24             	mov    %eax,(%esp)
  80148e:	e8 ce fc ff ff       	call   801161 <dev_lookup>
  801493:	89 c3                	mov    %eax,%ebx
  801495:	85 c0                	test   %eax,%eax
  801497:	78 16                	js     8014af <fd_close+0x6c>
  801499:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80149c:	8b 40 10             	mov    0x10(%eax),%eax
  80149f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	74 07                	je     8014af <fd_close+0x6c>
  8014a8:	89 34 24             	mov    %esi,(%esp)
  8014ab:	ff d0                	call   *%eax
  8014ad:	89 c3                	mov    %eax,%ebx
  8014af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014ba:	e8 cf f9 ff ff       	call   800e8e <sys_page_unmap>
  8014bf:	89 d8                	mov    %ebx,%eax
  8014c1:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  8014c4:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  8014c7:	89 ec                	mov    %ebp,%esp
  8014c9:	5d                   	pop    %ebp
  8014ca:	c3                   	ret    

008014cb <close>:
  8014cb:	55                   	push   %ebp
  8014cc:	89 e5                	mov    %esp,%ebp
  8014ce:	83 ec 18             	sub    $0x18,%esp
  8014d1:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  8014d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014db:	89 04 24             	mov    %eax,(%esp)
  8014de:	e8 0b fc ff ff       	call   8010ee <fd_lookup>
  8014e3:	85 c0                	test   %eax,%eax
  8014e5:	78 13                	js     8014fa <close+0x2f>
  8014e7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8014ee:	00 
  8014ef:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  8014f2:	89 04 24             	mov    %eax,(%esp)
  8014f5:	e8 49 ff ff ff       	call   801443 <fd_close>
  8014fa:	c9                   	leave  
  8014fb:	c3                   	ret    

008014fc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	83 ec 18             	sub    $0x18,%esp
  801502:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  801505:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801508:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80150f:	00 
  801510:	8b 45 08             	mov    0x8(%ebp),%eax
  801513:	89 04 24             	mov    %eax,(%esp)
  801516:	e8 58 03 00 00       	call   801873 <open>
  80151b:	89 c6                	mov    %eax,%esi
  80151d:	85 c0                	test   %eax,%eax
  80151f:	78 1b                	js     80153c <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801521:	8b 45 0c             	mov    0xc(%ebp),%eax
  801524:	89 44 24 04          	mov    %eax,0x4(%esp)
  801528:	89 34 24             	mov    %esi,(%esp)
  80152b:	e8 9d fc ff ff       	call   8011cd <fstat>
  801530:	89 c3                	mov    %eax,%ebx
	close(fd);
  801532:	89 34 24             	mov    %esi,(%esp)
  801535:	e8 91 ff ff ff       	call   8014cb <close>
  80153a:	89 de                	mov    %ebx,%esi
	return r;
}
  80153c:	89 f0                	mov    %esi,%eax
  80153e:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  801541:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  801544:	89 ec                	mov    %ebp,%esp
  801546:	5d                   	pop    %ebp
  801547:	c3                   	ret    

00801548 <dup>:
  801548:	55                   	push   %ebp
  801549:	89 e5                	mov    %esp,%ebp
  80154b:	83 ec 38             	sub    $0x38,%esp
  80154e:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  801551:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  801554:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  801557:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80155a:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  80155d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801561:	8b 45 08             	mov    0x8(%ebp),%eax
  801564:	89 04 24             	mov    %eax,(%esp)
  801567:	e8 82 fb ff ff       	call   8010ee <fd_lookup>
  80156c:	89 c3                	mov    %eax,%ebx
  80156e:	85 c0                	test   %eax,%eax
  801570:	0f 88 e1 00 00 00    	js     801657 <dup+0x10f>
  801576:	89 3c 24             	mov    %edi,(%esp)
  801579:	e8 4d ff ff ff       	call   8014cb <close>
  80157e:	89 f8                	mov    %edi,%eax
  801580:	c1 e0 0c             	shl    $0xc,%eax
  801583:	8d b0 00 00 00 d0    	lea    0xd0000000(%eax),%esi
  801589:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80158c:	89 04 24             	mov    %eax,(%esp)
  80158f:	e8 ec fa ff ff       	call   801080 <fd2data>
  801594:	89 c3                	mov    %eax,%ebx
  801596:	89 34 24             	mov    %esi,(%esp)
  801599:	e8 e2 fa ff ff       	call   801080 <fd2data>
  80159e:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  8015a1:	89 d8                	mov    %ebx,%eax
  8015a3:	c1 e8 16             	shr    $0x16,%eax
  8015a6:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  8015ad:	a8 01                	test   $0x1,%al
  8015af:	74 45                	je     8015f6 <dup+0xae>
  8015b1:	89 da                	mov    %ebx,%edx
  8015b3:	c1 ea 0c             	shr    $0xc,%edx
  8015b6:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  8015bd:	a8 01                	test   $0x1,%al
  8015bf:	74 35                	je     8015f6 <dup+0xae>
  8015c1:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  8015c8:	25 07 0e 00 00       	and    $0xe07,%eax
  8015cd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015d1:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  8015d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015d8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015df:	00 
  8015e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015eb:	e8 fc f8 ff ff       	call   800eec <sys_page_map>
  8015f0:	89 c3                	mov    %eax,%ebx
  8015f2:	85 c0                	test   %eax,%eax
  8015f4:	78 3e                	js     801634 <dup+0xec>
  8015f6:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  8015f9:	89 d0                	mov    %edx,%eax
  8015fb:	c1 e8 0c             	shr    $0xc,%eax
  8015fe:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  801605:	25 07 0e 00 00       	and    $0xe07,%eax
  80160a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80160e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801612:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801619:	00 
  80161a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80161e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801625:	e8 c2 f8 ff ff       	call   800eec <sys_page_map>
  80162a:	89 c3                	mov    %eax,%ebx
  80162c:	85 c0                	test   %eax,%eax
  80162e:	78 04                	js     801634 <dup+0xec>
  801630:	89 fb                	mov    %edi,%ebx
  801632:	eb 23                	jmp    801657 <dup+0x10f>
  801634:	89 74 24 04          	mov    %esi,0x4(%esp)
  801638:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80163f:	e8 4a f8 ff ff       	call   800e8e <sys_page_unmap>
  801644:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  801647:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801652:	e8 37 f8 ff ff       	call   800e8e <sys_page_unmap>
  801657:	89 d8                	mov    %ebx,%eax
  801659:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  80165c:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  80165f:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801662:	89 ec                	mov    %ebp,%esp
  801664:	5d                   	pop    %ebp
  801665:	c3                   	ret    

00801666 <close_all>:
  801666:	55                   	push   %ebp
  801667:	89 e5                	mov    %esp,%ebp
  801669:	53                   	push   %ebx
  80166a:	83 ec 04             	sub    $0x4,%esp
  80166d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801672:	89 1c 24             	mov    %ebx,(%esp)
  801675:	e8 51 fe ff ff       	call   8014cb <close>
  80167a:	83 c3 01             	add    $0x1,%ebx
  80167d:	83 fb 20             	cmp    $0x20,%ebx
  801680:	75 f0                	jne    801672 <close_all+0xc>
  801682:	83 c4 04             	add    $0x4,%esp
  801685:	5b                   	pop    %ebx
  801686:	5d                   	pop    %ebp
  801687:	c3                   	ret    

00801688 <fsipc>:
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	53                   	push   %ebx
  80168c:	83 ec 14             	sub    $0x14,%esp
  80168f:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801691:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  801697:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80169e:	00 
  80169f:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  8016a6:	00 
  8016a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ab:	89 14 24             	mov    %edx,(%esp)
  8016ae:	e8 0d 08 00 00       	call   801ec0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016b3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016ba:	00 
  8016bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016c6:	e8 a9 08 00 00       	call   801f74 <ipc_recv>
}
  8016cb:	83 c4 14             	add    $0x14,%esp
  8016ce:	5b                   	pop    %ebx
  8016cf:	5d                   	pop    %ebp
  8016d0:	c3                   	ret    

008016d1 <sync>:

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
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016dc:	b8 08 00 00 00       	mov    $0x8,%eax
  8016e1:	e8 a2 ff ff ff       	call   801688 <fsipc>
}
  8016e6:	c9                   	leave  
  8016e7:	c3                   	ret    

008016e8 <devfile_trunc>:
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	83 ec 08             	sub    $0x8,%esp
  8016ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f1:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f4:	a3 00 30 80 00       	mov    %eax,0x803000
  8016f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016fc:	a3 04 30 80 00       	mov    %eax,0x803004
  801701:	ba 00 00 00 00       	mov    $0x0,%edx
  801706:	b8 02 00 00 00       	mov    $0x2,%eax
  80170b:	e8 78 ff ff ff       	call   801688 <fsipc>
  801710:	c9                   	leave  
  801711:	c3                   	ret    

00801712 <devfile_flush>:
  801712:	55                   	push   %ebp
  801713:	89 e5                	mov    %esp,%ebp
  801715:	83 ec 08             	sub    $0x8,%esp
  801718:	8b 45 08             	mov    0x8(%ebp),%eax
  80171b:	8b 40 0c             	mov    0xc(%eax),%eax
  80171e:	a3 00 30 80 00       	mov    %eax,0x803000
  801723:	ba 00 00 00 00       	mov    $0x0,%edx
  801728:	b8 06 00 00 00       	mov    $0x6,%eax
  80172d:	e8 56 ff ff ff       	call   801688 <fsipc>
  801732:	c9                   	leave  
  801733:	c3                   	ret    

00801734 <devfile_stat>:
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	53                   	push   %ebx
  801738:	83 ec 14             	sub    $0x14,%esp
  80173b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80173e:	8b 45 08             	mov    0x8(%ebp),%eax
  801741:	8b 40 0c             	mov    0xc(%eax),%eax
  801744:	a3 00 30 80 00       	mov    %eax,0x803000
  801749:	ba 00 00 00 00       	mov    $0x0,%edx
  80174e:	b8 05 00 00 00       	mov    $0x5,%eax
  801753:	e8 30 ff ff ff       	call   801688 <fsipc>
  801758:	85 c0                	test   %eax,%eax
  80175a:	78 2b                	js     801787 <devfile_stat+0x53>
  80175c:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801763:	00 
  801764:	89 1c 24             	mov    %ebx,(%esp)
  801767:	e8 b5 f0 ff ff       	call   800821 <strcpy>
  80176c:	a1 80 30 80 00       	mov    0x803080,%eax
  801771:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  801777:	a1 84 30 80 00       	mov    0x803084,%eax
  80177c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801782:	b8 00 00 00 00       	mov    $0x0,%eax
  801787:	83 c4 14             	add    $0x14,%esp
  80178a:	5b                   	pop    %ebx
  80178b:	5d                   	pop    %ebp
  80178c:	c3                   	ret    

0080178d <devfile_write>:
  80178d:	55                   	push   %ebp
  80178e:	89 e5                	mov    %esp,%ebp
  801790:	83 ec 18             	sub    $0x18,%esp
  801793:	8b 55 10             	mov    0x10(%ebp),%edx
  801796:	8b 45 08             	mov    0x8(%ebp),%eax
  801799:	8b 40 0c             	mov    0xc(%eax),%eax
  80179c:	a3 00 30 80 00       	mov    %eax,0x803000
  8017a1:	89 d0                	mov    %edx,%eax
  8017a3:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  8017a9:	76 05                	jbe    8017b0 <devfile_write+0x23>
  8017ab:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  8017b0:	89 15 04 30 80 00    	mov    %edx,0x803004
  8017b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c1:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  8017c8:	e8 5d f2 ff ff       	call   800a2a <memmove>
  8017cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d2:	b8 04 00 00 00       	mov    $0x4,%eax
  8017d7:	e8 ac fe ff ff       	call   801688 <fsipc>
  8017dc:	c9                   	leave  
  8017dd:	c3                   	ret    

008017de <devfile_read>:
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	53                   	push   %ebx
  8017e2:	83 ec 14             	sub    $0x14,%esp
  8017e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e8:	8b 40 0c             	mov    0xc(%eax),%eax
  8017eb:	a3 00 30 80 00       	mov    %eax,0x803000
  8017f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8017f3:	a3 04 30 80 00       	mov    %eax,0x803004
  8017f8:	ba 00 30 80 00       	mov    $0x803000,%edx
  8017fd:	b8 03 00 00 00       	mov    $0x3,%eax
  801802:	e8 81 fe ff ff       	call   801688 <fsipc>
  801807:	89 c3                	mov    %eax,%ebx
  801809:	85 c0                	test   %eax,%eax
  80180b:	7e 17                	jle    801824 <devfile_read+0x46>
  80180d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801811:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801818:	00 
  801819:	8b 45 0c             	mov    0xc(%ebp),%eax
  80181c:	89 04 24             	mov    %eax,(%esp)
  80181f:	e8 06 f2 ff ff       	call   800a2a <memmove>
  801824:	89 d8                	mov    %ebx,%eax
  801826:	83 c4 14             	add    $0x14,%esp
  801829:	5b                   	pop    %ebx
  80182a:	5d                   	pop    %ebp
  80182b:	c3                   	ret    

0080182c <remove>:
  80182c:	55                   	push   %ebp
  80182d:	89 e5                	mov    %esp,%ebp
  80182f:	53                   	push   %ebx
  801830:	83 ec 14             	sub    $0x14,%esp
  801833:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801836:	89 1c 24             	mov    %ebx,(%esp)
  801839:	e8 92 ef ff ff       	call   8007d0 <strlen>
  80183e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  801843:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801848:	7f 21                	jg     80186b <remove+0x3f>
  80184a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80184e:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801855:	e8 c7 ef ff ff       	call   800821 <strcpy>
  80185a:	ba 00 00 00 00       	mov    $0x0,%edx
  80185f:	b8 07 00 00 00       	mov    $0x7,%eax
  801864:	e8 1f fe ff ff       	call   801688 <fsipc>
  801869:	89 c2                	mov    %eax,%edx
  80186b:	89 d0                	mov    %edx,%eax
  80186d:	83 c4 14             	add    $0x14,%esp
  801870:	5b                   	pop    %ebx
  801871:	5d                   	pop    %ebp
  801872:	c3                   	ret    

00801873 <open>:
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	56                   	push   %esi
  801877:	53                   	push   %ebx
  801878:	83 ec 30             	sub    $0x30,%esp
  80187b:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80187e:	89 04 24             	mov    %eax,(%esp)
  801881:	e8 15 f8 ff ff       	call   80109b <fd_alloc>
  801886:	89 c3                	mov    %eax,%ebx
  801888:	85 c0                	test   %eax,%eax
  80188a:	79 18                	jns    8018a4 <open+0x31>
  80188c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801893:	00 
  801894:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801897:	89 04 24             	mov    %eax,(%esp)
  80189a:	e8 a4 fb ff ff       	call   801443 <fd_close>
  80189f:	e9 9f 00 00 00       	jmp    801943 <open+0xd0>
  8018a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ab:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  8018b2:	e8 6a ef ff ff       	call   800821 <strcpy>
  8018b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ba:	a3 00 34 80 00       	mov    %eax,0x803400
  8018bf:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8018c2:	89 04 24             	mov    %eax,(%esp)
  8018c5:	e8 b6 f7 ff ff       	call   801080 <fd2data>
  8018ca:	89 c6                	mov    %eax,%esi
  8018cc:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  8018cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8018d4:	e8 af fd ff ff       	call   801688 <fsipc>
  8018d9:	89 c3                	mov    %eax,%ebx
  8018db:	85 c0                	test   %eax,%eax
  8018dd:	79 15                	jns    8018f4 <open+0x81>
  8018df:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8018e6:	00 
  8018e7:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8018ea:	89 04 24             	mov    %eax,(%esp)
  8018ed:	e8 51 fb ff ff       	call   801443 <fd_close>
  8018f2:	eb 4f                	jmp    801943 <open+0xd0>
  8018f4:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8018fb:	00 
  8018fc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801900:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801907:	00 
  801908:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80190b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801916:	e8 d1 f5 ff ff       	call   800eec <sys_page_map>
  80191b:	89 c3                	mov    %eax,%ebx
  80191d:	85 c0                	test   %eax,%eax
  80191f:	79 15                	jns    801936 <open+0xc3>
  801921:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801928:	00 
  801929:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80192c:	89 04 24             	mov    %eax,(%esp)
  80192f:	e8 0f fb ff ff       	call   801443 <fd_close>
  801934:	eb 0d                	jmp    801943 <open+0xd0>
  801936:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801939:	89 04 24             	mov    %eax,(%esp)
  80193c:	e8 2f f7 ff ff       	call   801070 <fd2num>
  801941:	89 c3                	mov    %eax,%ebx
  801943:	89 d8                	mov    %ebx,%eax
  801945:	83 c4 30             	add    $0x30,%esp
  801948:	5b                   	pop    %ebx
  801949:	5e                   	pop    %esi
  80194a:	5d                   	pop    %ebp
  80194b:	c3                   	ret    
  80194c:	00 00                	add    %al,(%eax)
	...

00801950 <devsock_stat>:
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  801956:	c7 44 24 04 18 27 80 	movl   $0x802718,0x4(%esp)
  80195d:	00 
  80195e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801961:	89 04 24             	mov    %eax,(%esp)
  801964:	e8 b8 ee ff ff       	call   800821 <strcpy>
	return 0;
}
  801969:	b8 00 00 00 00       	mov    $0x0,%eax
  80196e:	c9                   	leave  
  80196f:	c3                   	ret    

00801970 <devsock_close>:
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
  801973:	83 ec 08             	sub    $0x8,%esp
  801976:	8b 45 08             	mov    0x8(%ebp),%eax
  801979:	8b 40 0c             	mov    0xc(%eax),%eax
  80197c:	89 04 24             	mov    %eax,(%esp)
  80197f:	e8 be 02 00 00       	call   801c42 <nsipc_close>
  801984:	c9                   	leave  
  801985:	c3                   	ret    

00801986 <devsock_write>:
  801986:	55                   	push   %ebp
  801987:	89 e5                	mov    %esp,%ebp
  801989:	83 ec 18             	sub    $0x18,%esp
  80198c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801993:	00 
  801994:	8b 45 10             	mov    0x10(%ebp),%eax
  801997:	89 44 24 08          	mov    %eax,0x8(%esp)
  80199b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80199e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8019a8:	89 04 24             	mov    %eax,(%esp)
  8019ab:	e8 ce 02 00 00       	call   801c7e <nsipc_send>
  8019b0:	c9                   	leave  
  8019b1:	c3                   	ret    

008019b2 <devsock_read>:
  8019b2:	55                   	push   %ebp
  8019b3:	89 e5                	mov    %esp,%ebp
  8019b5:	83 ec 18             	sub    $0x18,%esp
  8019b8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8019bf:	00 
  8019c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8019c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8019d4:	89 04 24             	mov    %eax,(%esp)
  8019d7:	e8 15 03 00 00       	call   801cf1 <nsipc_recv>
  8019dc:	c9                   	leave  
  8019dd:	c3                   	ret    

008019de <alloc_sockfd>:
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	56                   	push   %esi
  8019e2:	53                   	push   %ebx
  8019e3:	83 ec 20             	sub    $0x20,%esp
  8019e6:	89 c6                	mov    %eax,%esi
  8019e8:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8019eb:	89 04 24             	mov    %eax,(%esp)
  8019ee:	e8 a8 f6 ff ff       	call   80109b <fd_alloc>
  8019f3:	89 c3                	mov    %eax,%ebx
  8019f5:	85 c0                	test   %eax,%eax
  8019f7:	78 21                	js     801a1a <alloc_sockfd+0x3c>
  8019f9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801a00:	00 
  801a01:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801a04:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a08:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a0f:	e8 36 f5 ff ff       	call   800f4a <sys_page_alloc>
  801a14:	89 c3                	mov    %eax,%ebx
  801a16:	85 c0                	test   %eax,%eax
  801a18:	79 0a                	jns    801a24 <alloc_sockfd+0x46>
  801a1a:	89 34 24             	mov    %esi,(%esp)
  801a1d:	e8 20 02 00 00       	call   801c42 <nsipc_close>
  801a22:	eb 28                	jmp    801a4c <alloc_sockfd+0x6e>
  801a24:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801a2a:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801a2d:	89 10                	mov    %edx,(%eax)
  801a2f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801a32:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
  801a39:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801a3c:	89 70 0c             	mov    %esi,0xc(%eax)
  801a3f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801a42:	89 04 24             	mov    %eax,(%esp)
  801a45:	e8 26 f6 ff ff       	call   801070 <fd2num>
  801a4a:	89 c3                	mov    %eax,%ebx
  801a4c:	89 d8                	mov    %ebx,%eax
  801a4e:	83 c4 20             	add    $0x20,%esp
  801a51:	5b                   	pop    %ebx
  801a52:	5e                   	pop    %esi
  801a53:	5d                   	pop    %ebp
  801a54:	c3                   	ret    

00801a55 <socket>:

int
socket(int domain, int type, int protocol)
{
  801a55:	55                   	push   %ebp
  801a56:	89 e5                	mov    %esp,%ebp
  801a58:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a5b:	8b 45 10             	mov    0x10(%ebp),%eax
  801a5e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a62:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a65:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a69:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6c:	89 04 24             	mov    %eax,(%esp)
  801a6f:	e8 82 01 00 00       	call   801bf6 <nsipc_socket>
  801a74:	85 c0                	test   %eax,%eax
  801a76:	78 05                	js     801a7d <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801a78:	e8 61 ff ff ff       	call   8019de <alloc_sockfd>
}
  801a7d:	c9                   	leave  
  801a7e:	66 90                	xchg   %ax,%ax
  801a80:	c3                   	ret    

00801a81 <fd2sockid>:
  801a81:	55                   	push   %ebp
  801a82:	89 e5                	mov    %esp,%ebp
  801a84:	83 ec 18             	sub    $0x18,%esp
  801a87:	8d 55 fc             	lea    0xfffffffc(%ebp),%edx
  801a8a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a8e:	89 04 24             	mov    %eax,(%esp)
  801a91:	e8 58 f6 ff ff       	call   8010ee <fd_lookup>
  801a96:	89 c2                	mov    %eax,%edx
  801a98:	85 c0                	test   %eax,%eax
  801a9a:	78 15                	js     801ab1 <fd2sockid+0x30>
  801a9c:	8b 4d fc             	mov    0xfffffffc(%ebp),%ecx
  801a9f:	8b 01                	mov    (%ecx),%eax
  801aa1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  801aa6:	3b 05 20 60 80 00    	cmp    0x806020,%eax
  801aac:	75 03                	jne    801ab1 <fd2sockid+0x30>
  801aae:	8b 51 0c             	mov    0xc(%ecx),%edx
  801ab1:	89 d0                	mov    %edx,%eax
  801ab3:	c9                   	leave  
  801ab4:	c3                   	ret    

00801ab5 <listen>:
  801ab5:	55                   	push   %ebp
  801ab6:	89 e5                	mov    %esp,%ebp
  801ab8:	83 ec 08             	sub    $0x8,%esp
  801abb:	8b 45 08             	mov    0x8(%ebp),%eax
  801abe:	e8 be ff ff ff       	call   801a81 <fd2sockid>
  801ac3:	89 c2                	mov    %eax,%edx
  801ac5:	85 c0                	test   %eax,%eax
  801ac7:	78 11                	js     801ada <listen+0x25>
  801ac9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801acc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad0:	89 14 24             	mov    %edx,(%esp)
  801ad3:	e8 48 01 00 00       	call   801c20 <nsipc_listen>
  801ad8:	89 c2                	mov    %eax,%edx
  801ada:	89 d0                	mov    %edx,%eax
  801adc:	c9                   	leave  
  801add:	c3                   	ret    

00801ade <connect>:
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	83 ec 18             	sub    $0x18,%esp
  801ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae7:	e8 95 ff ff ff       	call   801a81 <fd2sockid>
  801aec:	89 c2                	mov    %eax,%edx
  801aee:	85 c0                	test   %eax,%eax
  801af0:	78 18                	js     801b0a <connect+0x2c>
  801af2:	8b 45 10             	mov    0x10(%ebp),%eax
  801af5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801af9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801afc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b00:	89 14 24             	mov    %edx,(%esp)
  801b03:	e8 71 02 00 00       	call   801d79 <nsipc_connect>
  801b08:	89 c2                	mov    %eax,%edx
  801b0a:	89 d0                	mov    %edx,%eax
  801b0c:	c9                   	leave  
  801b0d:	c3                   	ret    

00801b0e <shutdown>:
  801b0e:	55                   	push   %ebp
  801b0f:	89 e5                	mov    %esp,%ebp
  801b11:	83 ec 08             	sub    $0x8,%esp
  801b14:	8b 45 08             	mov    0x8(%ebp),%eax
  801b17:	e8 65 ff ff ff       	call   801a81 <fd2sockid>
  801b1c:	89 c2                	mov    %eax,%edx
  801b1e:	85 c0                	test   %eax,%eax
  801b20:	78 11                	js     801b33 <shutdown+0x25>
  801b22:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b25:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b29:	89 14 24             	mov    %edx,(%esp)
  801b2c:	e8 2b 01 00 00       	call   801c5c <nsipc_shutdown>
  801b31:	89 c2                	mov    %eax,%edx
  801b33:	89 d0                	mov    %edx,%eax
  801b35:	c9                   	leave  
  801b36:	c3                   	ret    

00801b37 <bind>:
  801b37:	55                   	push   %ebp
  801b38:	89 e5                	mov    %esp,%ebp
  801b3a:	83 ec 18             	sub    $0x18,%esp
  801b3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b40:	e8 3c ff ff ff       	call   801a81 <fd2sockid>
  801b45:	89 c2                	mov    %eax,%edx
  801b47:	85 c0                	test   %eax,%eax
  801b49:	78 18                	js     801b63 <bind+0x2c>
  801b4b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b4e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b52:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b55:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b59:	89 14 24             	mov    %edx,(%esp)
  801b5c:	e8 57 02 00 00       	call   801db8 <nsipc_bind>
  801b61:	89 c2                	mov    %eax,%edx
  801b63:	89 d0                	mov    %edx,%eax
  801b65:	c9                   	leave  
  801b66:	c3                   	ret    

00801b67 <accept>:
  801b67:	55                   	push   %ebp
  801b68:	89 e5                	mov    %esp,%ebp
  801b6a:	83 ec 18             	sub    $0x18,%esp
  801b6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b70:	e8 0c ff ff ff       	call   801a81 <fd2sockid>
  801b75:	89 c2                	mov    %eax,%edx
  801b77:	85 c0                	test   %eax,%eax
  801b79:	78 23                	js     801b9e <accept+0x37>
  801b7b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b7e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b82:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b85:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b89:	89 14 24             	mov    %edx,(%esp)
  801b8c:	e8 66 02 00 00       	call   801df7 <nsipc_accept>
  801b91:	89 c2                	mov    %eax,%edx
  801b93:	85 c0                	test   %eax,%eax
  801b95:	78 07                	js     801b9e <accept+0x37>
  801b97:	e8 42 fe ff ff       	call   8019de <alloc_sockfd>
  801b9c:	89 c2                	mov    %eax,%edx
  801b9e:	89 d0                	mov    %edx,%eax
  801ba0:	c9                   	leave  
  801ba1:	c3                   	ret    
	...

00801bb0 <nsipc>:
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bb6:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  801bbc:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801bc3:	00 
  801bc4:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801bcb:	00 
  801bcc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd0:	89 14 24             	mov    %edx,(%esp)
  801bd3:	e8 e8 02 00 00       	call   801ec0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801bd8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bdf:	00 
  801be0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801be7:	00 
  801be8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bef:	e8 80 03 00 00       	call   801f74 <ipc_recv>
}
  801bf4:	c9                   	leave  
  801bf5:	c3                   	ret    

00801bf6 <nsipc_socket>:

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
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
  801bf9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801bfc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bff:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.socket.req_type = type;
  801c04:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c07:	a3 04 50 80 00       	mov    %eax,0x805004
	nsipcbuf.socket.req_protocol = protocol;
  801c0c:	8b 45 10             	mov    0x10(%ebp),%eax
  801c0f:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SOCKET);
  801c14:	b8 09 00 00 00       	mov    $0x9,%eax
  801c19:	e8 92 ff ff ff       	call   801bb0 <nsipc>
}
  801c1e:	c9                   	leave  
  801c1f:	c3                   	ret    

00801c20 <nsipc_listen>:
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	83 ec 08             	sub    $0x8,%esp
  801c26:	8b 45 08             	mov    0x8(%ebp),%eax
  801c29:	a3 00 50 80 00       	mov    %eax,0x805000
  801c2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c31:	a3 04 50 80 00       	mov    %eax,0x805004
  801c36:	b8 06 00 00 00       	mov    $0x6,%eax
  801c3b:	e8 70 ff ff ff       	call   801bb0 <nsipc>
  801c40:	c9                   	leave  
  801c41:	c3                   	ret    

00801c42 <nsipc_close>:
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	83 ec 08             	sub    $0x8,%esp
  801c48:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4b:	a3 00 50 80 00       	mov    %eax,0x805000
  801c50:	b8 04 00 00 00       	mov    $0x4,%eax
  801c55:	e8 56 ff ff ff       	call   801bb0 <nsipc>
  801c5a:	c9                   	leave  
  801c5b:	c3                   	ret    

00801c5c <nsipc_shutdown>:
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	83 ec 08             	sub    $0x8,%esp
  801c62:	8b 45 08             	mov    0x8(%ebp),%eax
  801c65:	a3 00 50 80 00       	mov    %eax,0x805000
  801c6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c6d:	a3 04 50 80 00       	mov    %eax,0x805004
  801c72:	b8 03 00 00 00       	mov    $0x3,%eax
  801c77:	e8 34 ff ff ff       	call   801bb0 <nsipc>
  801c7c:	c9                   	leave  
  801c7d:	c3                   	ret    

00801c7e <nsipc_send>:
  801c7e:	55                   	push   %ebp
  801c7f:	89 e5                	mov    %esp,%ebp
  801c81:	53                   	push   %ebx
  801c82:	83 ec 14             	sub    $0x14,%esp
  801c85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c88:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8b:	a3 00 50 80 00       	mov    %eax,0x805000
  801c90:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c96:	7e 24                	jle    801cbc <nsipc_send+0x3e>
  801c98:	c7 44 24 0c 24 27 80 	movl   $0x802724,0xc(%esp)
  801c9f:	00 
  801ca0:	c7 44 24 08 30 27 80 	movl   $0x802730,0x8(%esp)
  801ca7:	00 
  801ca8:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  801caf:	00 
  801cb0:	c7 04 24 45 27 80 00 	movl   $0x802745,(%esp)
  801cb7:	e8 8c 01 00 00       	call   801e48 <_panic>
  801cbc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cc0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc7:	c7 04 24 0c 50 80 00 	movl   $0x80500c,(%esp)
  801cce:	e8 57 ed ff ff       	call   800a2a <memmove>
  801cd3:	89 1d 04 50 80 00    	mov    %ebx,0x805004
  801cd9:	8b 45 14             	mov    0x14(%ebp),%eax
  801cdc:	a3 08 50 80 00       	mov    %eax,0x805008
  801ce1:	b8 08 00 00 00       	mov    $0x8,%eax
  801ce6:	e8 c5 fe ff ff       	call   801bb0 <nsipc>
  801ceb:	83 c4 14             	add    $0x14,%esp
  801cee:	5b                   	pop    %ebx
  801cef:	5d                   	pop    %ebp
  801cf0:	c3                   	ret    

00801cf1 <nsipc_recv>:
  801cf1:	55                   	push   %ebp
  801cf2:	89 e5                	mov    %esp,%ebp
  801cf4:	83 ec 18             	sub    $0x18,%esp
  801cf7:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  801cfa:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  801cfd:	8b 75 10             	mov    0x10(%ebp),%esi
  801d00:	8b 45 08             	mov    0x8(%ebp),%eax
  801d03:	a3 00 50 80 00       	mov    %eax,0x805000
  801d08:	89 35 04 50 80 00    	mov    %esi,0x805004
  801d0e:	8b 45 14             	mov    0x14(%ebp),%eax
  801d11:	a3 08 50 80 00       	mov    %eax,0x805008
  801d16:	b8 07 00 00 00       	mov    $0x7,%eax
  801d1b:	e8 90 fe ff ff       	call   801bb0 <nsipc>
  801d20:	89 c3                	mov    %eax,%ebx
  801d22:	85 c0                	test   %eax,%eax
  801d24:	78 47                	js     801d6d <nsipc_recv+0x7c>
  801d26:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d2b:	7f 05                	jg     801d32 <nsipc_recv+0x41>
  801d2d:	39 c6                	cmp    %eax,%esi
  801d2f:	90                   	nop    
  801d30:	7d 24                	jge    801d56 <nsipc_recv+0x65>
  801d32:	c7 44 24 0c 51 27 80 	movl   $0x802751,0xc(%esp)
  801d39:	00 
  801d3a:	c7 44 24 08 30 27 80 	movl   $0x802730,0x8(%esp)
  801d41:	00 
  801d42:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  801d49:	00 
  801d4a:	c7 04 24 45 27 80 00 	movl   $0x802745,(%esp)
  801d51:	e8 f2 00 00 00       	call   801e48 <_panic>
  801d56:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d5a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801d61:	00 
  801d62:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d65:	89 04 24             	mov    %eax,(%esp)
  801d68:	e8 bd ec ff ff       	call   800a2a <memmove>
  801d6d:	89 d8                	mov    %ebx,%eax
  801d6f:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  801d72:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  801d75:	89 ec                	mov    %ebp,%esp
  801d77:	5d                   	pop    %ebp
  801d78:	c3                   	ret    

00801d79 <nsipc_connect>:
  801d79:	55                   	push   %ebp
  801d7a:	89 e5                	mov    %esp,%ebp
  801d7c:	53                   	push   %ebx
  801d7d:	83 ec 14             	sub    $0x14,%esp
  801d80:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d83:	8b 45 08             	mov    0x8(%ebp),%eax
  801d86:	a3 00 50 80 00       	mov    %eax,0x805000
  801d8b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d92:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d96:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  801d9d:	e8 88 ec ff ff       	call   800a2a <memmove>
  801da2:	89 1d 14 50 80 00    	mov    %ebx,0x805014
  801da8:	b8 05 00 00 00       	mov    $0x5,%eax
  801dad:	e8 fe fd ff ff       	call   801bb0 <nsipc>
  801db2:	83 c4 14             	add    $0x14,%esp
  801db5:	5b                   	pop    %ebx
  801db6:	5d                   	pop    %ebp
  801db7:	c3                   	ret    

00801db8 <nsipc_bind>:
  801db8:	55                   	push   %ebp
  801db9:	89 e5                	mov    %esp,%ebp
  801dbb:	53                   	push   %ebx
  801dbc:	83 ec 14             	sub    $0x14,%esp
  801dbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc5:	a3 00 50 80 00       	mov    %eax,0x805000
  801dca:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dce:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd5:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  801ddc:	e8 49 ec ff ff       	call   800a2a <memmove>
  801de1:	89 1d 14 50 80 00    	mov    %ebx,0x805014
  801de7:	b8 02 00 00 00       	mov    $0x2,%eax
  801dec:	e8 bf fd ff ff       	call   801bb0 <nsipc>
  801df1:	83 c4 14             	add    $0x14,%esp
  801df4:	5b                   	pop    %ebx
  801df5:	5d                   	pop    %ebp
  801df6:	c3                   	ret    

00801df7 <nsipc_accept>:
  801df7:	55                   	push   %ebp
  801df8:	89 e5                	mov    %esp,%ebp
  801dfa:	53                   	push   %ebx
  801dfb:	83 ec 14             	sub    $0x14,%esp
  801dfe:	8b 45 08             	mov    0x8(%ebp),%eax
  801e01:	a3 00 50 80 00       	mov    %eax,0x805000
  801e06:	b8 01 00 00 00       	mov    $0x1,%eax
  801e0b:	e8 a0 fd ff ff       	call   801bb0 <nsipc>
  801e10:	89 c3                	mov    %eax,%ebx
  801e12:	85 c0                	test   %eax,%eax
  801e14:	78 27                	js     801e3d <nsipc_accept+0x46>
  801e16:	a1 10 50 80 00       	mov    0x805010,%eax
  801e1b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e1f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801e26:	00 
  801e27:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e2a:	89 04 24             	mov    %eax,(%esp)
  801e2d:	e8 f8 eb ff ff       	call   800a2a <memmove>
  801e32:	8b 15 10 50 80 00    	mov    0x805010,%edx
  801e38:	8b 45 10             	mov    0x10(%ebp),%eax
  801e3b:	89 10                	mov    %edx,(%eax)
  801e3d:	89 d8                	mov    %ebx,%eax
  801e3f:	83 c4 14             	add    $0x14,%esp
  801e42:	5b                   	pop    %ebx
  801e43:	5d                   	pop    %ebp
  801e44:	c3                   	ret    
  801e45:	00 00                	add    %al,(%eax)
	...

00801e48 <_panic>:
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  801e48:	55                   	push   %ebp
  801e49:	89 e5                	mov    %esp,%ebp
  801e4b:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  801e4e:	8d 45 14             	lea    0x14(%ebp),%eax
  801e51:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)

	// Print the panic message
	if (argv0)
  801e54:	a1 40 60 80 00       	mov    0x806040,%eax
  801e59:	85 c0                	test   %eax,%eax
  801e5b:	74 10                	je     801e6d <_panic+0x25>
		cprintf("%s: ", argv0);
  801e5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e61:	c7 04 24 66 27 80 00 	movl   $0x802766,(%esp)
  801e68:	e8 34 e3 ff ff       	call   8001a1 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  801e6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e70:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e74:	8b 45 08             	mov    0x8(%ebp),%eax
  801e77:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e7b:	a1 00 60 80 00       	mov    0x806000,%eax
  801e80:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e84:	c7 04 24 6b 27 80 00 	movl   $0x80276b,(%esp)
  801e8b:	e8 11 e3 ff ff       	call   8001a1 <cprintf>
	vcprintf(fmt, ap);
  801e90:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  801e93:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e97:	8b 45 10             	mov    0x10(%ebp),%eax
  801e9a:	89 04 24             	mov    %eax,(%esp)
  801e9d:	e8 9e e2 ff ff       	call   800140 <vcprintf>
	cprintf("\n");
  801ea2:	c7 04 24 c9 27 80 00 	movl   $0x8027c9,(%esp)
  801ea9:	e8 f3 e2 ff ff       	call   8001a1 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801eae:	cc                   	int3   
  801eaf:	eb fd                	jmp    801eae <_panic+0x66>
	...

00801ec0 <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ec0:	55                   	push   %ebp
  801ec1:	89 e5                	mov    %esp,%ebp
  801ec3:	57                   	push   %edi
  801ec4:	56                   	push   %esi
  801ec5:	53                   	push   %ebx
  801ec6:	83 ec 1c             	sub    $0x1c,%esp
  801ec9:	8b 75 08             	mov    0x8(%ebp),%esi
  801ecc:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  801ecf:	e8 09 f1 ff ff       	call   800fdd <sys_getenvid>
  801ed4:	25 ff 03 00 00       	and    $0x3ff,%eax
  801ed9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801edc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ee1:	a3 3c 60 80 00       	mov    %eax,0x80603c
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  801ee6:	e8 f2 f0 ff ff       	call   800fdd <sys_getenvid>
  801eeb:	25 ff 03 00 00       	and    $0x3ff,%eax
  801ef0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ef3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ef8:	a3 3c 60 80 00       	mov    %eax,0x80603c
		if(env->env_id==to_env){
  801efd:	8b 40 4c             	mov    0x4c(%eax),%eax
  801f00:	39 f0                	cmp    %esi,%eax
  801f02:	75 0e                	jne    801f12 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  801f04:	c7 04 24 87 27 80 00 	movl   $0x802787,(%esp)
  801f0b:	e8 91 e2 ff ff       	call   8001a1 <cprintf>
  801f10:	eb 5a                	jmp    801f6c <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  801f12:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f16:	8b 45 10             	mov    0x10(%ebp),%eax
  801f19:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f20:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f24:	89 34 24             	mov    %esi,(%esp)
  801f27:	e8 10 ee ff ff       	call   800d3c <sys_ipc_try_send>
  801f2c:	89 c3                	mov    %eax,%ebx
  801f2e:	85 c0                	test   %eax,%eax
  801f30:	79 25                	jns    801f57 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  801f32:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f35:	74 2b                	je     801f62 <ipc_send+0xa2>
				panic("send error:%e",r);
  801f37:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f3b:	c7 44 24 08 a3 27 80 	movl   $0x8027a3,0x8(%esp)
  801f42:	00 
  801f43:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  801f4a:	00 
  801f4b:	c7 04 24 b1 27 80 00 	movl   $0x8027b1,(%esp)
  801f52:	e8 f1 fe ff ff       	call   801e48 <_panic>
		}
			sys_yield();
  801f57:	e8 4d f0 ff ff       	call   800fa9 <sys_yield>
		
	}while(r!=0);
  801f5c:	85 db                	test   %ebx,%ebx
  801f5e:	75 86                	jne    801ee6 <ipc_send+0x26>
  801f60:	eb 0a                	jmp    801f6c <ipc_send+0xac>
  801f62:	e8 42 f0 ff ff       	call   800fa9 <sys_yield>
  801f67:	e9 7a ff ff ff       	jmp    801ee6 <ipc_send+0x26>
	return;
	//panic("ipc_send not implemented");
}
  801f6c:	83 c4 1c             	add    $0x1c,%esp
  801f6f:	5b                   	pop    %ebx
  801f70:	5e                   	pop    %esi
  801f71:	5f                   	pop    %edi
  801f72:	5d                   	pop    %ebp
  801f73:	c3                   	ret    

00801f74 <ipc_recv>:
  801f74:	55                   	push   %ebp
  801f75:	89 e5                	mov    %esp,%ebp
  801f77:	57                   	push   %edi
  801f78:	56                   	push   %esi
  801f79:	53                   	push   %ebx
  801f7a:	83 ec 0c             	sub    $0xc,%esp
  801f7d:	8b 75 08             	mov    0x8(%ebp),%esi
  801f80:	8b 7d 10             	mov    0x10(%ebp),%edi
  801f83:	e8 55 f0 ff ff       	call   800fdd <sys_getenvid>
  801f88:	25 ff 03 00 00       	and    $0x3ff,%eax
  801f8d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f90:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f95:	a3 3c 60 80 00       	mov    %eax,0x80603c
  801f9a:	85 f6                	test   %esi,%esi
  801f9c:	74 29                	je     801fc7 <ipc_recv+0x53>
  801f9e:	8b 40 4c             	mov    0x4c(%eax),%eax
  801fa1:	3b 06                	cmp    (%esi),%eax
  801fa3:	75 22                	jne    801fc7 <ipc_recv+0x53>
  801fa5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801fab:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801fb1:	c7 04 24 87 27 80 00 	movl   $0x802787,(%esp)
  801fb8:	e8 e4 e1 ff ff       	call   8001a1 <cprintf>
  801fbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fc2:	e9 8a 00 00 00       	jmp    802051 <ipc_recv+0xdd>
  801fc7:	e8 11 f0 ff ff       	call   800fdd <sys_getenvid>
  801fcc:	25 ff 03 00 00       	and    $0x3ff,%eax
  801fd1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fd4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fd9:	a3 3c 60 80 00       	mov    %eax,0x80603c
  801fde:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fe1:	89 04 24             	mov    %eax,(%esp)
  801fe4:	e8 f6 ec ff ff       	call   800cdf <sys_ipc_recv>
  801fe9:	89 c3                	mov    %eax,%ebx
  801feb:	85 c0                	test   %eax,%eax
  801fed:	79 1a                	jns    802009 <ipc_recv+0x95>
  801fef:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801ff5:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801ffb:	c7 04 24 bb 27 80 00 	movl   $0x8027bb,(%esp)
  802002:	e8 9a e1 ff ff       	call   8001a1 <cprintf>
  802007:	eb 48                	jmp    802051 <ipc_recv+0xdd>
  802009:	e8 cf ef ff ff       	call   800fdd <sys_getenvid>
  80200e:	25 ff 03 00 00       	and    $0x3ff,%eax
  802013:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802016:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80201b:	a3 3c 60 80 00       	mov    %eax,0x80603c
  802020:	85 f6                	test   %esi,%esi
  802022:	74 05                	je     802029 <ipc_recv+0xb5>
  802024:	8b 40 74             	mov    0x74(%eax),%eax
  802027:	89 06                	mov    %eax,(%esi)
  802029:	85 ff                	test   %edi,%edi
  80202b:	74 0a                	je     802037 <ipc_recv+0xc3>
  80202d:	a1 3c 60 80 00       	mov    0x80603c,%eax
  802032:	8b 40 78             	mov    0x78(%eax),%eax
  802035:	89 07                	mov    %eax,(%edi)
  802037:	e8 a1 ef ff ff       	call   800fdd <sys_getenvid>
  80203c:	25 ff 03 00 00       	and    $0x3ff,%eax
  802041:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802044:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802049:	a3 3c 60 80 00       	mov    %eax,0x80603c
  80204e:	8b 58 70             	mov    0x70(%eax),%ebx
  802051:	89 d8                	mov    %ebx,%eax
  802053:	83 c4 0c             	add    $0xc,%esp
  802056:	5b                   	pop    %ebx
  802057:	5e                   	pop    %esi
  802058:	5f                   	pop    %edi
  802059:	5d                   	pop    %ebp
  80205a:	c3                   	ret    
  80205b:	00 00                	add    %al,(%eax)
  80205d:	00 00                	add    %al,(%eax)
	...

00802060 <__udivdi3>:
  802060:	55                   	push   %ebp
  802061:	89 e5                	mov    %esp,%ebp
  802063:	57                   	push   %edi
  802064:	56                   	push   %esi
  802065:	83 ec 1c             	sub    $0x1c,%esp
  802068:	8b 45 10             	mov    0x10(%ebp),%eax
  80206b:	8b 55 14             	mov    0x14(%ebp),%edx
  80206e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802071:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  802074:	89 c1                	mov    %eax,%ecx
  802076:	8b 45 08             	mov    0x8(%ebp),%eax
  802079:	85 d2                	test   %edx,%edx
  80207b:	89 d6                	mov    %edx,%esi
  80207d:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
  802080:	75 1e                	jne    8020a0 <__udivdi3+0x40>
  802082:	39 f9                	cmp    %edi,%ecx
  802084:	0f 86 8d 00 00 00    	jbe    802117 <__udivdi3+0xb7>
  80208a:	89 fa                	mov    %edi,%edx
  80208c:	f7 f1                	div    %ecx
  80208e:	89 c1                	mov    %eax,%ecx
  802090:	89 c8                	mov    %ecx,%eax
  802092:	89 f2                	mov    %esi,%edx
  802094:	83 c4 1c             	add    $0x1c,%esp
  802097:	5e                   	pop    %esi
  802098:	5f                   	pop    %edi
  802099:	5d                   	pop    %ebp
  80209a:	c3                   	ret    
  80209b:	90                   	nop    
  80209c:	8d 74 26 00          	lea    0x0(%esi),%esi
  8020a0:	39 fa                	cmp    %edi,%edx
  8020a2:	0f 87 98 00 00 00    	ja     802140 <__udivdi3+0xe0>
  8020a8:	0f bd c2             	bsr    %edx,%eax
  8020ab:	83 f0 1f             	xor    $0x1f,%eax
  8020ae:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8020b1:	74 7f                	je     802132 <__udivdi3+0xd2>
  8020b3:	b8 20 00 00 00       	mov    $0x20,%eax
  8020b8:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  8020bb:	2b 45 e4             	sub    0xffffffe4(%ebp),%eax
  8020be:	89 c1                	mov    %eax,%ecx
  8020c0:	d3 ea                	shr    %cl,%edx
  8020c2:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8020c6:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  8020c9:	89 f0                	mov    %esi,%eax
  8020cb:	d3 e0                	shl    %cl,%eax
  8020cd:	09 c2                	or     %eax,%edx
  8020cf:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8020d2:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  8020d5:	89 fa                	mov    %edi,%edx
  8020d7:	d3 e0                	shl    %cl,%eax
  8020d9:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  8020dd:	89 45 f4             	mov    %eax,0xfffffff4(%ebp)
  8020e0:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8020e3:	d3 e8                	shr    %cl,%eax
  8020e5:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8020e9:	d3 e2                	shl    %cl,%edx
  8020eb:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  8020ef:	09 d0                	or     %edx,%eax
  8020f1:	d3 ef                	shr    %cl,%edi
  8020f3:	89 fa                	mov    %edi,%edx
  8020f5:	f7 75 e0             	divl   0xffffffe0(%ebp)
  8020f8:	89 d1                	mov    %edx,%ecx
  8020fa:	89 c7                	mov    %eax,%edi
  8020fc:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8020ff:	f7 e7                	mul    %edi
  802101:	39 d1                	cmp    %edx,%ecx
  802103:	89 c6                	mov    %eax,%esi
  802105:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  802108:	72 6f                	jb     802179 <__udivdi3+0x119>
  80210a:	39 ca                	cmp    %ecx,%edx
  80210c:	74 5e                	je     80216c <__udivdi3+0x10c>
  80210e:	89 f9                	mov    %edi,%ecx
  802110:	31 f6                	xor    %esi,%esi
  802112:	e9 79 ff ff ff       	jmp    802090 <__udivdi3+0x30>
  802117:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80211a:	85 c0                	test   %eax,%eax
  80211c:	74 32                	je     802150 <__udivdi3+0xf0>
  80211e:	89 f2                	mov    %esi,%edx
  802120:	89 f8                	mov    %edi,%eax
  802122:	f7 f1                	div    %ecx
  802124:	89 c6                	mov    %eax,%esi
  802126:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802129:	f7 f1                	div    %ecx
  80212b:	89 c1                	mov    %eax,%ecx
  80212d:	e9 5e ff ff ff       	jmp    802090 <__udivdi3+0x30>
  802132:	39 d7                	cmp    %edx,%edi
  802134:	77 2a                	ja     802160 <__udivdi3+0x100>
  802136:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  802139:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
  80213c:	73 22                	jae    802160 <__udivdi3+0x100>
  80213e:	66 90                	xchg   %ax,%ax
  802140:	31 c9                	xor    %ecx,%ecx
  802142:	31 f6                	xor    %esi,%esi
  802144:	e9 47 ff ff ff       	jmp    802090 <__udivdi3+0x30>
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  802150:	b8 01 00 00 00       	mov    $0x1,%eax
  802155:	31 d2                	xor    %edx,%edx
  802157:	f7 75 f0             	divl   0xfffffff0(%ebp)
  80215a:	89 c1                	mov    %eax,%ecx
  80215c:	eb c0                	jmp    80211e <__udivdi3+0xbe>
  80215e:	66 90                	xchg   %ax,%ax
  802160:	b9 01 00 00 00       	mov    $0x1,%ecx
  802165:	31 f6                	xor    %esi,%esi
  802167:	e9 24 ff ff ff       	jmp    802090 <__udivdi3+0x30>
  80216c:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  80216f:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802173:	d3 e0                	shl    %cl,%eax
  802175:	39 c6                	cmp    %eax,%esi
  802177:	76 95                	jbe    80210e <__udivdi3+0xae>
  802179:	8d 4f ff             	lea    0xffffffff(%edi),%ecx
  80217c:	31 f6                	xor    %esi,%esi
  80217e:	e9 0d ff ff ff       	jmp    802090 <__udivdi3+0x30>
	...

00802190 <__umoddi3>:
  802190:	55                   	push   %ebp
  802191:	89 e5                	mov    %esp,%ebp
  802193:	57                   	push   %edi
  802194:	56                   	push   %esi
  802195:	83 ec 30             	sub    $0x30,%esp
  802198:	8b 55 14             	mov    0x14(%ebp),%edx
  80219b:	8b 45 10             	mov    0x10(%ebp),%eax
  80219e:	8b 75 08             	mov    0x8(%ebp),%esi
  8021a1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8021a4:	85 d2                	test   %edx,%edx
  8021a6:	c7 45 d0 00 00 00 00 	movl   $0x0,0xffffffd0(%ebp)
  8021ad:	89 c1                	mov    %eax,%ecx
  8021af:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  8021b6:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  8021b9:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  8021bc:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  8021bf:	89 7d e0             	mov    %edi,0xffffffe0(%ebp)
  8021c2:	75 1c                	jne    8021e0 <__umoddi3+0x50>
  8021c4:	39 f8                	cmp    %edi,%eax
  8021c6:	89 fa                	mov    %edi,%edx
  8021c8:	0f 86 d4 00 00 00    	jbe    8022a2 <__umoddi3+0x112>
  8021ce:	89 f0                	mov    %esi,%eax
  8021d0:	f7 f1                	div    %ecx
  8021d2:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  8021d5:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  8021dc:	eb 12                	jmp    8021f0 <__umoddi3+0x60>
  8021de:	66 90                	xchg   %ax,%ax
  8021e0:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  8021e3:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  8021e6:	76 18                	jbe    802200 <__umoddi3+0x70>
  8021e8:	89 75 d0             	mov    %esi,0xffffffd0(%ebp)
  8021eb:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  8021ee:	66 90                	xchg   %ax,%ax
  8021f0:	8b 45 d0             	mov    0xffffffd0(%ebp),%eax
  8021f3:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  8021f6:	83 c4 30             	add    $0x30,%esp
  8021f9:	5e                   	pop    %esi
  8021fa:	5f                   	pop    %edi
  8021fb:	5d                   	pop    %ebp
  8021fc:	c3                   	ret    
  8021fd:	8d 76 00             	lea    0x0(%esi),%esi
  802200:	0f bd 45 e8          	bsr    0xffffffe8(%ebp),%eax
  802204:	83 f0 1f             	xor    $0x1f,%eax
  802207:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  80220a:	0f 84 c0 00 00 00    	je     8022d0 <__umoddi3+0x140>
  802210:	b8 20 00 00 00       	mov    $0x20,%eax
  802215:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  802218:	2b 45 dc             	sub    0xffffffdc(%ebp),%eax
  80221b:	8b 7d ec             	mov    0xffffffec(%ebp),%edi
  80221e:	8b 75 f0             	mov    0xfffffff0(%ebp),%esi
  802221:	89 c1                	mov    %eax,%ecx
  802223:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  802226:	d3 ea                	shr    %cl,%edx
  802228:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  80222b:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  80222f:	d3 e0                	shl    %cl,%eax
  802231:	09 c2                	or     %eax,%edx
  802233:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802236:	d3 e7                	shl    %cl,%edi
  802238:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  80223c:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  80223f:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  802242:	d3 e8                	shr    %cl,%eax
  802244:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  802248:	d3 e2                	shl    %cl,%edx
  80224a:	09 d0                	or     %edx,%eax
  80224c:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  80224f:	d3 e6                	shl    %cl,%esi
  802251:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802255:	d3 ea                	shr    %cl,%edx
  802257:	f7 75 f4             	divl   0xfffffff4(%ebp)
  80225a:	89 55 cc             	mov    %edx,0xffffffcc(%ebp)
  80225d:	f7 e7                	mul    %edi
  80225f:	39 55 cc             	cmp    %edx,0xffffffcc(%ebp)
  802262:	0f 82 a5 00 00 00    	jb     80230d <__umoddi3+0x17d>
  802268:	3b 55 cc             	cmp    0xffffffcc(%ebp),%edx
  80226b:	0f 84 94 00 00 00    	je     802305 <__umoddi3+0x175>
  802271:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
  802274:	29 c6                	sub    %eax,%esi
  802276:	19 d1                	sbb    %edx,%ecx
  802278:	89 4d cc             	mov    %ecx,0xffffffcc(%ebp)
  80227b:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  80227f:	89 f2                	mov    %esi,%edx
  802281:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  802284:	d3 ea                	shr    %cl,%edx
  802286:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  80228a:	d3 e0                	shl    %cl,%eax
  80228c:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  802290:	09 c2                	or     %eax,%edx
  802292:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  802295:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802298:	d3 e8                	shr    %cl,%eax
  80229a:	89 45 d4             	mov    %eax,0xffffffd4(%ebp)
  80229d:	e9 4e ff ff ff       	jmp    8021f0 <__umoddi3+0x60>
  8022a2:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  8022a5:	85 c0                	test   %eax,%eax
  8022a7:	74 17                	je     8022c0 <__umoddi3+0x130>
  8022a9:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  8022ac:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
  8022af:	f7 f1                	div    %ecx
  8022b1:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8022b4:	f7 f1                	div    %ecx
  8022b6:	e9 17 ff ff ff       	jmp    8021d2 <__umoddi3+0x42>
  8022bb:	90                   	nop    
  8022bc:	8d 74 26 00          	lea    0x0(%esi),%esi
  8022c0:	b8 01 00 00 00       	mov    $0x1,%eax
  8022c5:	31 d2                	xor    %edx,%edx
  8022c7:	f7 75 ec             	divl   0xffffffec(%ebp)
  8022ca:	89 c1                	mov    %eax,%ecx
  8022cc:	eb db                	jmp    8022a9 <__umoddi3+0x119>
  8022ce:	66 90                	xchg   %ax,%ax
  8022d0:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8022d3:	39 45 e0             	cmp    %eax,0xffffffe0(%ebp)
  8022d6:	77 19                	ja     8022f1 <__umoddi3+0x161>
  8022d8:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  8022db:	39 55 f0             	cmp    %edx,0xfffffff0(%ebp)
  8022de:	73 11                	jae    8022f1 <__umoddi3+0x161>
  8022e0:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  8022e3:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  8022e6:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  8022e9:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  8022ec:	e9 ff fe ff ff       	jmp    8021f0 <__umoddi3+0x60>
  8022f1:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  8022f4:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8022f7:	2b 45 ec             	sub    0xffffffec(%ebp),%eax
  8022fa:	1b 4d e8             	sbb    0xffffffe8(%ebp),%ecx
  8022fd:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  802300:	89 4d e0             	mov    %ecx,0xffffffe0(%ebp)
  802303:	eb db                	jmp    8022e0 <__umoddi3+0x150>
  802305:	39 f0                	cmp    %esi,%eax
  802307:	0f 86 64 ff ff ff    	jbe    802271 <__umoddi3+0xe1>
  80230d:	29 f8                	sub    %edi,%eax
  80230f:	1b 55 f4             	sbb    0xfffffff4(%ebp),%edx
  802312:	e9 5a ff ff ff       	jmp    802271 <__umoddi3+0xe1>
