
obj/user/hello:     file format elf32-i386

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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
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
  800037:	83 ec 08             	sub    $0x8,%esp
	cprintf("hello, world\n");
  80003a:	c7 04 24 c0 22 80 00 	movl   $0x8022c0,(%esp)
  800041:	e8 f3 00 00 00       	call   800139 <cprintf>
	cprintf("i am environment %08x\n", env->env_id);
  800046:	a1 3c 60 80 00       	mov    0x80603c,%eax
  80004b:	8b 40 4c             	mov    0x4c(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 ce 22 80 00 	movl   $0x8022ce,(%esp)
  800059:	e8 db 00 00 00       	call   800139 <cprintf>
}
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	83 ec 18             	sub    $0x18,%esp
  800066:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  800069:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  80006c:	8b 75 08             	mov    0x8(%ebp),%esi
  80006f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  800072:	c7 05 3c 60 80 00 00 	movl   $0x0,0x80603c
  800079:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  80007c:	e8 fc 0e 00 00       	call   800f7d <sys_getenvid>
  800081:	25 ff 03 00 00       	and    $0x3ff,%eax
  800086:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800089:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008e:	a3 3c 60 80 00       	mov    %eax,0x80603c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800093:	85 f6                	test   %esi,%esi
  800095:	7e 07                	jle    80009e <libmain+0x3e>
		binaryname = argv[0];
  800097:	8b 03                	mov    (%ebx),%eax
  800099:	a3 00 60 80 00       	mov    %eax,0x806000

	// call user main routine调用用户主例程
	umain(argc, argv);
  80009e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a2:	89 34 24             	mov    %esi,(%esp)
  8000a5:	e8 8a ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000aa:	e8 0d 00 00 00       	call   8000bc <exit>
}
  8000af:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  8000b2:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  8000b5:	89 ec                	mov    %ebp,%esp
  8000b7:	5d                   	pop    %ebp
  8000b8:	c3                   	ret    
  8000b9:	00 00                	add    %al,(%eax)
	...

008000bc <exit>:
#include <inc/lib.h>

void
exit(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000c2:	e8 3f 15 00 00       	call   801606 <close_all>
	sys_env_destroy(0);
  8000c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ce:	e8 de 0e 00 00       	call   800fb1 <sys_env_destroy>
}
  8000d3:	c9                   	leave  
  8000d4:	c3                   	ret    
  8000d5:	00 00                	add    %al,(%eax)
	...

008000d8 <vcprintf>:
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000e1:	c7 85 f8 fe ff ff 00 	movl   $0x0,0xfffffef8(%ebp)
  8000e8:	00 00 00 
	b.cnt = 0;
  8000eb:	c7 85 fc fe ff ff 00 	movl   $0x0,0xfffffefc(%ebp)
  8000f2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8000ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800103:	8d 85 f8 fe ff ff    	lea    0xfffffef8(%ebp),%eax
  800109:	89 44 24 04          	mov    %eax,0x4(%esp)
  80010d:	c7 04 24 56 01 80 00 	movl   $0x800156,(%esp)
  800114:	e8 c8 01 00 00       	call   8002e1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800119:	8b 85 f8 fe ff ff    	mov    0xfffffef8(%ebp),%eax
  80011f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800123:	8d 85 00 ff ff ff    	lea    0xffffff00(%ebp),%eax
  800129:	89 04 24             	mov    %eax,(%esp)
  80012c:	e8 e7 0a 00 00       	call   800c18 <sys_cputs>
  800131:	8b 85 fc fe ff ff    	mov    0xfffffefc(%ebp),%eax

	return b.cnt;
}
  800137:	c9                   	leave  
  800138:	c3                   	ret    

00800139 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80013f:	8d 45 0c             	lea    0xc(%ebp),%eax
  800142:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
	cnt = vcprintf(fmt, ap);
  800145:	89 44 24 04          	mov    %eax,0x4(%esp)
  800149:	8b 45 08             	mov    0x8(%ebp),%eax
  80014c:	89 04 24             	mov    %eax,(%esp)
  80014f:	e8 84 ff ff ff       	call   8000d8 <vcprintf>
	va_end(ap);

	return cnt;
}
  800154:	c9                   	leave  
  800155:	c3                   	ret    

00800156 <putch>:
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	53                   	push   %ebx
  80015a:	83 ec 14             	sub    $0x14,%esp
  80015d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800160:	8b 03                	mov    (%ebx),%eax
  800162:	8b 55 08             	mov    0x8(%ebp),%edx
  800165:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800169:	83 c0 01             	add    $0x1,%eax
  80016c:	89 03                	mov    %eax,(%ebx)
  80016e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800173:	75 19                	jne    80018e <putch+0x38>
  800175:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80017c:	00 
  80017d:	8d 43 08             	lea    0x8(%ebx),%eax
  800180:	89 04 24             	mov    %eax,(%esp)
  800183:	e8 90 0a 00 00       	call   800c18 <sys_cputs>
  800188:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80018e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
  800192:	83 c4 14             	add    $0x14,%esp
  800195:	5b                   	pop    %ebx
  800196:	5d                   	pop    %ebp
  800197:	c3                   	ret    
	...

008001a0 <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	57                   	push   %edi
  8001a4:	56                   	push   %esi
  8001a5:	53                   	push   %ebx
  8001a6:	83 ec 3c             	sub    $0x3c,%esp
  8001a9:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8001ac:	89 d7                	mov    %edx,%edi
  8001ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b4:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  8001b7:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  8001ba:	8b 55 10             	mov    0x10(%ebp),%edx
  8001bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8001c0:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c3:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  8001c6:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  8001cd:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  8001d0:	39 4d ec             	cmp    %ecx,0xffffffec(%ebp)
  8001d3:	72 11                	jb     8001e6 <printnum+0x46>
  8001d5:	8b 4d d8             	mov    0xffffffd8(%ebp),%ecx
  8001d8:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  8001db:	76 09                	jbe    8001e6 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001dd:	8d 58 ff             	lea    0xffffffff(%eax),%ebx
  8001e0:	85 db                	test   %ebx,%ebx
  8001e2:	7f 54                	jg     800238 <printnum+0x98>
  8001e4:	eb 61                	jmp    800247 <printnum+0xa7>
  8001e6:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001ea:	83 e8 01             	sub    $0x1,%eax
  8001ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001f1:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001f5:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001f9:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001fd:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800200:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800203:	89 44 24 08          	mov    %eax,0x8(%esp)
  800207:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80020b:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  80020e:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800211:	89 14 24             	mov    %edx,(%esp)
  800214:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800218:	e8 e3 1d 00 00       	call   802000 <__udivdi3>
  80021d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800221:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800225:	89 04 24             	mov    %eax,(%esp)
  800228:	89 54 24 04          	mov    %edx,0x4(%esp)
  80022c:	89 fa                	mov    %edi,%edx
  80022e:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  800231:	e8 6a ff ff ff       	call   8001a0 <printnum>
  800236:	eb 0f                	jmp    800247 <printnum+0xa7>
			putch(padc, putdat);
  800238:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80023c:	89 34 24             	mov    %esi,(%esp)
  80023f:	ff 55 e4             	call   *0xffffffe4(%ebp)
  800242:	83 eb 01             	sub    $0x1,%ebx
  800245:	75 f1                	jne    800238 <printnum+0x98>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800247:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80024b:	8b 74 24 04          	mov    0x4(%esp),%esi
  80024f:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800252:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800255:	89 44 24 08          	mov    %eax,0x8(%esp)
  800259:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80025d:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800260:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800263:	89 14 24             	mov    %edx,(%esp)
  800266:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80026a:	e8 c1 1e 00 00       	call   802130 <__umoddi3>
  80026f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800273:	0f be 80 fc 22 80 00 	movsbl 0x8022fc(%eax),%eax
  80027a:	89 04 24             	mov    %eax,(%esp)
  80027d:	ff 55 e4             	call   *0xffffffe4(%ebp)
}
  800280:	83 c4 3c             	add    $0x3c,%esp
  800283:	5b                   	pop    %ebx
  800284:	5e                   	pop    %esi
  800285:	5f                   	pop    %edi
  800286:	5d                   	pop    %ebp
  800287:	c3                   	ret    

00800288 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  80028d:	83 fa 01             	cmp    $0x1,%edx
  800290:	7e 0e                	jle    8002a0 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  800292:	8b 10                	mov    (%eax),%edx
  800294:	8d 42 08             	lea    0x8(%edx),%eax
  800297:	89 01                	mov    %eax,(%ecx)
  800299:	8b 02                	mov    (%edx),%eax
  80029b:	8b 52 04             	mov    0x4(%edx),%edx
  80029e:	eb 22                	jmp    8002c2 <getuint+0x3a>
	else if (lflag)
  8002a0:	85 d2                	test   %edx,%edx
  8002a2:	74 10                	je     8002b4 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8002a4:	8b 10                	mov    (%eax),%edx
  8002a6:	8d 42 04             	lea    0x4(%edx),%eax
  8002a9:	89 01                	mov    %eax,(%ecx)
  8002ab:	8b 02                	mov    (%edx),%eax
  8002ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b2:	eb 0e                	jmp    8002c2 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  8002b4:	8b 10                	mov    (%eax),%edx
  8002b6:	8d 42 04             	lea    0x4(%edx),%eax
  8002b9:	89 01                	mov    %eax,(%ecx)
  8002bb:	8b 02                	mov    (%edx),%eax
  8002bd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <sprintputch>:

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
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  8002ca:	83 41 08 01          	addl   $0x1,0x8(%ecx)
	if (b->buf < b->ebuf)
  8002ce:	8b 11                	mov    (%ecx),%edx
  8002d0:	3b 51 04             	cmp    0x4(%ecx),%edx
  8002d3:	73 0a                	jae    8002df <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d8:	88 02                	mov    %al,(%edx)
  8002da:	8d 42 01             	lea    0x1(%edx),%eax
  8002dd:	89 01                	mov    %eax,(%ecx)
}
  8002df:	5d                   	pop    %ebp
  8002e0:	c3                   	ret    

008002e1 <vprintfmt>:
  8002e1:	55                   	push   %ebp
  8002e2:	89 e5                	mov    %esp,%ebp
  8002e4:	57                   	push   %edi
  8002e5:	56                   	push   %esi
  8002e6:	53                   	push   %ebx
  8002e7:	83 ec 4c             	sub    $0x4c,%esp
  8002ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002f0:	eb 03                	jmp    8002f5 <vprintfmt+0x14>
  8002f2:	8b 5d e8             	mov    0xffffffe8(%ebp),%ebx
  8002f5:	0f b6 03             	movzbl (%ebx),%eax
  8002f8:	83 c3 01             	add    $0x1,%ebx
  8002fb:	3c 25                	cmp    $0x25,%al
  8002fd:	74 30                	je     80032f <vprintfmt+0x4e>
  8002ff:	84 c0                	test   %al,%al
  800301:	0f 84 a8 03 00 00    	je     8006af <vprintfmt+0x3ce>
  800307:	0f b6 d0             	movzbl %al,%edx
  80030a:	eb 0a                	jmp    800316 <vprintfmt+0x35>
  80030c:	84 c0                	test   %al,%al
  80030e:	66 90                	xchg   %ax,%ax
  800310:	0f 84 99 03 00 00    	je     8006af <vprintfmt+0x3ce>
  800316:	8b 45 0c             	mov    0xc(%ebp),%eax
  800319:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031d:	89 14 24             	mov    %edx,(%esp)
  800320:	ff d7                	call   *%edi
  800322:	0f b6 03             	movzbl (%ebx),%eax
  800325:	0f b6 d0             	movzbl %al,%edx
  800328:	83 c3 01             	add    $0x1,%ebx
  80032b:	3c 25                	cmp    $0x25,%al
  80032d:	75 dd                	jne    80030c <vprintfmt+0x2b>
  80032f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800334:	c7 45 ec ff ff ff ff 	movl   $0xffffffff,0xffffffec(%ebp)
  80033b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  800342:	c7 45 dc 00 00 00 00 	movl   $0x0,0xffffffdc(%ebp)
  800349:	c6 45 e3 20          	movb   $0x20,0xffffffe3(%ebp)
  80034d:	eb 07                	jmp    800356 <vprintfmt+0x75>
  80034f:	c7 45 dc 01 00 00 00 	movl   $0x1,0xffffffdc(%ebp)
  800356:	0f b6 03             	movzbl (%ebx),%eax
  800359:	0f b6 d0             	movzbl %al,%edx
  80035c:	83 c3 01             	add    $0x1,%ebx
  80035f:	83 e8 23             	sub    $0x23,%eax
  800362:	3c 55                	cmp    $0x55,%al
  800364:	0f 87 11 03 00 00    	ja     80067b <vprintfmt+0x39a>
  80036a:	0f b6 c0             	movzbl %al,%eax
  80036d:	ff 24 85 40 24 80 00 	jmp    *0x802440(,%eax,4)
  800374:	c6 45 e3 30          	movb   $0x30,0xffffffe3(%ebp)
  800378:	eb dc                	jmp    800356 <vprintfmt+0x75>
  80037a:	83 ea 30             	sub    $0x30,%edx
  80037d:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  800380:	0f be 13             	movsbl (%ebx),%edx
  800383:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800386:	83 f8 09             	cmp    $0x9,%eax
  800389:	76 08                	jbe    800393 <vprintfmt+0xb2>
  80038b:	eb 42                	jmp    8003cf <vprintfmt+0xee>
  80038d:	c6 45 e3 2d          	movb   $0x2d,0xffffffe3(%ebp)
  800391:	eb c3                	jmp    800356 <vprintfmt+0x75>
  800393:	83 c3 01             	add    $0x1,%ebx
  800396:	8b 75 e4             	mov    0xffffffe4(%ebp),%esi
  800399:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  80039c:	8d 44 42 d0          	lea    0xffffffd0(%edx,%eax,2),%eax
  8003a0:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8003a3:	0f be 13             	movsbl (%ebx),%edx
  8003a6:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  8003a9:	83 f8 09             	cmp    $0x9,%eax
  8003ac:	77 21                	ja     8003cf <vprintfmt+0xee>
  8003ae:	eb e3                	jmp    800393 <vprintfmt+0xb2>
  8003b0:	8b 55 14             	mov    0x14(%ebp),%edx
  8003b3:	8d 42 04             	lea    0x4(%edx),%eax
  8003b6:	89 45 14             	mov    %eax,0x14(%ebp)
  8003b9:	8b 12                	mov    (%edx),%edx
  8003bb:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  8003be:	eb 0f                	jmp    8003cf <vprintfmt+0xee>
  8003c0:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  8003c4:	79 90                	jns    800356 <vprintfmt+0x75>
  8003c6:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  8003cd:	eb 87                	jmp    800356 <vprintfmt+0x75>
  8003cf:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  8003d3:	79 81                	jns    800356 <vprintfmt+0x75>
  8003d5:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  8003d8:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  8003db:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  8003e2:	e9 6f ff ff ff       	jmp    800356 <vprintfmt+0x75>
  8003e7:	83 c1 01             	add    $0x1,%ecx
  8003ea:	e9 67 ff ff ff       	jmp    800356 <vprintfmt+0x75>
  8003ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f2:	8d 50 04             	lea    0x4(%eax),%edx
  8003f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003ff:	8b 00                	mov    (%eax),%eax
  800401:	89 04 24             	mov    %eax,(%esp)
  800404:	ff d7                	call   *%edi
  800406:	e9 ea fe ff ff       	jmp    8002f5 <vprintfmt+0x14>
  80040b:	8b 55 14             	mov    0x14(%ebp),%edx
  80040e:	8d 42 04             	lea    0x4(%edx),%eax
  800411:	89 45 14             	mov    %eax,0x14(%ebp)
  800414:	8b 02                	mov    (%edx),%eax
  800416:	89 c2                	mov    %eax,%edx
  800418:	c1 fa 1f             	sar    $0x1f,%edx
  80041b:	31 d0                	xor    %edx,%eax
  80041d:	29 d0                	sub    %edx,%eax
  80041f:	83 f8 0f             	cmp    $0xf,%eax
  800422:	7f 0b                	jg     80042f <vprintfmt+0x14e>
  800424:	8b 14 85 a0 25 80 00 	mov    0x8025a0(,%eax,4),%edx
  80042b:	85 d2                	test   %edx,%edx
  80042d:	75 20                	jne    80044f <vprintfmt+0x16e>
  80042f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800433:	c7 44 24 08 0d 23 80 	movl   $0x80230d,0x8(%esp)
  80043a:	00 
  80043b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80043e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800442:	89 3c 24             	mov    %edi,(%esp)
  800445:	e8 f0 02 00 00       	call   80073a <printfmt>
  80044a:	e9 a6 fe ff ff       	jmp    8002f5 <vprintfmt+0x14>
  80044f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800453:	c7 44 24 08 e2 26 80 	movl   $0x8026e2,0x8(%esp)
  80045a:	00 
  80045b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800462:	89 3c 24             	mov    %edi,(%esp)
  800465:	e8 d0 02 00 00       	call   80073a <printfmt>
  80046a:	e9 86 fe ff ff       	jmp    8002f5 <vprintfmt+0x14>
  80046f:	8b 75 ec             	mov    0xffffffec(%ebp),%esi
  800472:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  800475:	89 5d e8             	mov    %ebx,0xffffffe8(%ebp)
  800478:	8b 55 14             	mov    0x14(%ebp),%edx
  80047b:	8d 42 04             	lea    0x4(%edx),%eax
  80047e:	89 45 14             	mov    %eax,0x14(%ebp)
  800481:	8b 12                	mov    (%edx),%edx
  800483:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  800486:	85 d2                	test   %edx,%edx
  800488:	75 07                	jne    800491 <vprintfmt+0x1b0>
  80048a:	c7 45 d8 16 23 80 00 	movl   $0x802316,0xffffffd8(%ebp)
  800491:	85 f6                	test   %esi,%esi
  800493:	7e 40                	jle    8004d5 <vprintfmt+0x1f4>
  800495:	80 7d e3 2d          	cmpb   $0x2d,0xffffffe3(%ebp)
  800499:	74 3a                	je     8004d5 <vprintfmt+0x1f4>
  80049b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80049f:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  8004a2:	89 14 24             	mov    %edx,(%esp)
  8004a5:	e8 e6 02 00 00       	call   800790 <strnlen>
  8004aa:	29 c6                	sub    %eax,%esi
  8004ac:	89 75 ec             	mov    %esi,0xffffffec(%ebp)
  8004af:	85 f6                	test   %esi,%esi
  8004b1:	7e 22                	jle    8004d5 <vprintfmt+0x1f4>
  8004b3:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  8004b7:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  8004ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004bd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004c1:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  8004c4:	89 04 24             	mov    %eax,(%esp)
  8004c7:	ff d7                	call   *%edi
  8004c9:	83 ee 01             	sub    $0x1,%esi
  8004cc:	75 ec                	jne    8004ba <vprintfmt+0x1d9>
  8004ce:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  8004d5:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  8004d8:	0f b6 02             	movzbl (%edx),%eax
  8004db:	0f be d0             	movsbl %al,%edx
  8004de:	8b 75 d8             	mov    0xffffffd8(%ebp),%esi
  8004e1:	84 c0                	test   %al,%al
  8004e3:	75 40                	jne    800525 <vprintfmt+0x244>
  8004e5:	eb 4a                	jmp    800531 <vprintfmt+0x250>
  8004e7:	83 7d dc 00          	cmpl   $0x0,0xffffffdc(%ebp)
  8004eb:	74 1a                	je     800507 <vprintfmt+0x226>
  8004ed:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  8004f0:	83 f8 5e             	cmp    $0x5e,%eax
  8004f3:	76 12                	jbe    800507 <vprintfmt+0x226>
  8004f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004fc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800503:	ff d7                	call   *%edi
  800505:	eb 0c                	jmp    800513 <vprintfmt+0x232>
  800507:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050e:	89 14 24             	mov    %edx,(%esp)
  800511:	ff d7                	call   *%edi
  800513:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  800517:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80051b:	83 c6 01             	add    $0x1,%esi
  80051e:	84 c0                	test   %al,%al
  800520:	74 0f                	je     800531 <vprintfmt+0x250>
  800522:	0f be d0             	movsbl %al,%edx
  800525:	83 7d e4 00          	cmpl   $0x0,0xffffffe4(%ebp)
  800529:	78 bc                	js     8004e7 <vprintfmt+0x206>
  80052b:	83 6d e4 01          	subl   $0x1,0xffffffe4(%ebp)
  80052f:	79 b6                	jns    8004e7 <vprintfmt+0x206>
  800531:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800535:	0f 8e ba fd ff ff    	jle    8002f5 <vprintfmt+0x14>
  80053b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80053e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800542:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800549:	ff d7                	call   *%edi
  80054b:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  80054f:	0f 84 9d fd ff ff    	je     8002f2 <vprintfmt+0x11>
  800555:	eb e4                	jmp    80053b <vprintfmt+0x25a>
  800557:	83 f9 01             	cmp    $0x1,%ecx
  80055a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800560:	7e 10                	jle    800572 <vprintfmt+0x291>
  800562:	8b 55 14             	mov    0x14(%ebp),%edx
  800565:	8d 42 08             	lea    0x8(%edx),%eax
  800568:	89 45 14             	mov    %eax,0x14(%ebp)
  80056b:	8b 02                	mov    (%edx),%eax
  80056d:	8b 52 04             	mov    0x4(%edx),%edx
  800570:	eb 26                	jmp    800598 <vprintfmt+0x2b7>
  800572:	85 c9                	test   %ecx,%ecx
  800574:	74 12                	je     800588 <vprintfmt+0x2a7>
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8d 50 04             	lea    0x4(%eax),%edx
  80057c:	89 55 14             	mov    %edx,0x14(%ebp)
  80057f:	8b 00                	mov    (%eax),%eax
  800581:	89 c2                	mov    %eax,%edx
  800583:	c1 fa 1f             	sar    $0x1f,%edx
  800586:	eb 10                	jmp    800598 <vprintfmt+0x2b7>
  800588:	8b 45 14             	mov    0x14(%ebp),%eax
  80058b:	8d 50 04             	lea    0x4(%eax),%edx
  80058e:	89 55 14             	mov    %edx,0x14(%ebp)
  800591:	8b 00                	mov    (%eax),%eax
  800593:	89 c2                	mov    %eax,%edx
  800595:	c1 fa 1f             	sar    $0x1f,%edx
  800598:	89 d1                	mov    %edx,%ecx
  80059a:	89 c2                	mov    %eax,%edx
  80059c:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  80059f:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  8005a2:	be 0a 00 00 00       	mov    $0xa,%esi
  8005a7:	85 c9                	test   %ecx,%ecx
  8005a9:	0f 89 92 00 00 00    	jns    800641 <vprintfmt+0x360>
  8005af:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005b6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005bd:	ff d7                	call   *%edi
  8005bf:	8b 55 d0             	mov    0xffffffd0(%ebp),%edx
  8005c2:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
  8005c5:	f7 da                	neg    %edx
  8005c7:	83 d1 00             	adc    $0x0,%ecx
  8005ca:	f7 d9                	neg    %ecx
  8005cc:	be 0a 00 00 00       	mov    $0xa,%esi
  8005d1:	eb 6e                	jmp    800641 <vprintfmt+0x360>
  8005d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d6:	89 ca                	mov    %ecx,%edx
  8005d8:	e8 ab fc ff ff       	call   800288 <getuint>
  8005dd:	89 d1                	mov    %edx,%ecx
  8005df:	89 c2                	mov    %eax,%edx
  8005e1:	be 0a 00 00 00       	mov    $0xa,%esi
  8005e6:	eb 59                	jmp    800641 <vprintfmt+0x360>
  8005e8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005eb:	89 ca                	mov    %ecx,%edx
  8005ed:	e8 96 fc ff ff       	call   800288 <getuint>
  8005f2:	e9 fe fc ff ff       	jmp    8002f5 <vprintfmt+0x14>
  8005f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005fe:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800605:	ff d7                	call   *%edi
  800607:	8b 55 0c             	mov    0xc(%ebp),%edx
  80060a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80060e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800615:	ff d7                	call   *%edi
  800617:	8b 55 14             	mov    0x14(%ebp),%edx
  80061a:	8d 42 04             	lea    0x4(%edx),%eax
  80061d:	89 45 14             	mov    %eax,0x14(%ebp)
  800620:	8b 12                	mov    (%edx),%edx
  800622:	b9 00 00 00 00       	mov    $0x0,%ecx
  800627:	be 10 00 00 00       	mov    $0x10,%esi
  80062c:	eb 13                	jmp    800641 <vprintfmt+0x360>
  80062e:	8d 45 14             	lea    0x14(%ebp),%eax
  800631:	89 ca                	mov    %ecx,%edx
  800633:	e8 50 fc ff ff       	call   800288 <getuint>
  800638:	89 d1                	mov    %edx,%ecx
  80063a:	89 c2                	mov    %eax,%edx
  80063c:	be 10 00 00 00       	mov    $0x10,%esi
  800641:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  800645:	89 44 24 10          	mov    %eax,0x10(%esp)
  800649:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  80064c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800650:	89 74 24 08          	mov    %esi,0x8(%esp)
  800654:	89 14 24             	mov    %edx,(%esp)
  800657:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80065b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80065e:	89 f8                	mov    %edi,%eax
  800660:	e8 3b fb ff ff       	call   8001a0 <printnum>
  800665:	e9 8b fc ff ff       	jmp    8002f5 <vprintfmt+0x14>
  80066a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80066d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800671:	89 14 24             	mov    %edx,(%esp)
  800674:	ff d7                	call   *%edi
  800676:	e9 7a fc ff ff       	jmp    8002f5 <vprintfmt+0x14>
  80067b:	89 de                	mov    %ebx,%esi
  80067d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800680:	89 44 24 04          	mov    %eax,0x4(%esp)
  800684:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80068b:	ff d7                	call   *%edi
  80068d:	83 eb 01             	sub    $0x1,%ebx
  800690:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  800694:	0f 84 5b fc ff ff    	je     8002f5 <vprintfmt+0x14>
  80069a:	8d 56 fd             	lea    0xfffffffd(%esi),%edx
  80069d:	0f b6 02             	movzbl (%edx),%eax
  8006a0:	83 ea 01             	sub    $0x1,%edx
  8006a3:	3c 25                	cmp    $0x25,%al
  8006a5:	75 f6                	jne    80069d <vprintfmt+0x3bc>
  8006a7:	8d 5a 02             	lea    0x2(%edx),%ebx
  8006aa:	e9 46 fc ff ff       	jmp    8002f5 <vprintfmt+0x14>
  8006af:	83 c4 4c             	add    $0x4c,%esp
  8006b2:	5b                   	pop    %ebx
  8006b3:	5e                   	pop    %esi
  8006b4:	5f                   	pop    %edi
  8006b5:	5d                   	pop    %ebp
  8006b6:	c3                   	ret    

008006b7 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b7:	55                   	push   %ebp
  8006b8:	89 e5                	mov    %esp,%ebp
  8006ba:	83 ec 28             	sub    $0x28,%esp
  8006bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8006c0:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8006c3:	85 d2                	test   %edx,%edx
  8006c5:	74 04                	je     8006cb <vsnprintf+0x14>
  8006c7:	85 c0                	test   %eax,%eax
  8006c9:	7f 07                	jg     8006d2 <vsnprintf+0x1b>
  8006cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006d0:	eb 3b                	jmp    80070d <vsnprintf+0x56>
  8006d2:	c7 45 fc 00 00 00 00 	movl   $0x0,0xfffffffc(%ebp)
  8006d9:	8d 44 02 ff          	lea    0xffffffff(%edx,%eax,1),%eax
  8006dd:	89 45 f8             	mov    %eax,0xfffffff8(%ebp)
  8006e0:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8006ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f1:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8006f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f8:	c7 04 24 c4 02 80 00 	movl   $0x8002c4,(%esp)
  8006ff:	e8 dd fb ff ff       	call   8002e1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800704:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  800707:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80070a:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
}
  80070d:	c9                   	leave  
  80070e:	c3                   	ret    

0080070f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
  800712:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800715:	8d 45 14             	lea    0x14(%ebp),%eax
  800718:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  80071b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80071f:	8b 45 10             	mov    0x10(%ebp),%eax
  800722:	89 44 24 08          	mov    %eax,0x8(%esp)
  800726:	8b 45 0c             	mov    0xc(%ebp),%eax
  800729:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072d:	8b 45 08             	mov    0x8(%ebp),%eax
  800730:	89 04 24             	mov    %eax,(%esp)
  800733:	e8 7f ff ff ff       	call   8006b7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800738:	c9                   	leave  
  800739:	c3                   	ret    

0080073a <printfmt>:
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	83 ec 28             	sub    $0x28,%esp
  800740:	8d 45 14             	lea    0x14(%ebp),%eax
  800743:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
  800746:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80074a:	8b 45 10             	mov    0x10(%ebp),%eax
  80074d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800751:	8b 45 0c             	mov    0xc(%ebp),%eax
  800754:	89 44 24 04          	mov    %eax,0x4(%esp)
  800758:	8b 45 08             	mov    0x8(%ebp),%eax
  80075b:	89 04 24             	mov    %eax,(%esp)
  80075e:	e8 7e fb ff ff       	call   8002e1 <vprintfmt>
  800763:	c9                   	leave  
  800764:	c3                   	ret    
	...

00800770 <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800776:	b8 00 00 00 00       	mov    $0x0,%eax
  80077b:	80 3a 00             	cmpb   $0x0,(%edx)
  80077e:	74 0e                	je     80078e <strlen+0x1e>
  800780:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800785:	83 c0 01             	add    $0x1,%eax
  800788:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  80078c:	75 f7                	jne    800785 <strlen+0x15>
	return n;
}
  80078e:	5d                   	pop    %ebp
  80078f:	c3                   	ret    

00800790 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800796:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800799:	85 d2                	test   %edx,%edx
  80079b:	74 19                	je     8007b6 <strnlen+0x26>
  80079d:	80 39 00             	cmpb   $0x0,(%ecx)
  8007a0:	74 14                	je     8007b6 <strnlen+0x26>
  8007a2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007a7:	83 c0 01             	add    $0x1,%eax
  8007aa:	39 d0                	cmp    %edx,%eax
  8007ac:	74 0d                	je     8007bb <strnlen+0x2b>
  8007ae:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  8007b2:	74 07                	je     8007bb <strnlen+0x2b>
  8007b4:	eb f1                	jmp    8007a7 <strnlen+0x17>
  8007b6:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  8007bb:	5d                   	pop    %ebp
  8007bc:	8d 74 26 00          	lea    0x0(%esi),%esi
  8007c0:	c3                   	ret    

008007c1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	53                   	push   %ebx
  8007c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007cb:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007cd:	0f b6 01             	movzbl (%ecx),%eax
  8007d0:	88 02                	mov    %al,(%edx)
  8007d2:	83 c2 01             	add    $0x1,%edx
  8007d5:	83 c1 01             	add    $0x1,%ecx
  8007d8:	84 c0                	test   %al,%al
  8007da:	75 f1                	jne    8007cd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007dc:	89 d8                	mov    %ebx,%eax
  8007de:	5b                   	pop    %ebx
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	57                   	push   %edi
  8007e5:	56                   	push   %esi
  8007e6:	53                   	push   %ebx
  8007e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ed:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f0:	85 f6                	test   %esi,%esi
  8007f2:	74 1c                	je     800810 <strncpy+0x2f>
  8007f4:	89 fa                	mov    %edi,%edx
  8007f6:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  8007fb:	0f b6 01             	movzbl (%ecx),%eax
  8007fe:	88 02                	mov    %al,(%edx)
  800800:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800803:	80 39 01             	cmpb   $0x1,(%ecx)
  800806:	83 d9 ff             	sbb    $0xffffffff,%ecx
  800809:	83 c3 01             	add    $0x1,%ebx
  80080c:	39 f3                	cmp    %esi,%ebx
  80080e:	75 eb                	jne    8007fb <strncpy+0x1a>
	}
	return ret;
}
  800810:	89 f8                	mov    %edi,%eax
  800812:	5b                   	pop    %ebx
  800813:	5e                   	pop    %esi
  800814:	5f                   	pop    %edi
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	56                   	push   %esi
  80081b:	53                   	push   %ebx
  80081c:	8b 75 08             	mov    0x8(%ebp),%esi
  80081f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800822:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800825:	89 f0                	mov    %esi,%eax
  800827:	85 d2                	test   %edx,%edx
  800829:	74 2c                	je     800857 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  80082b:	89 d3                	mov    %edx,%ebx
  80082d:	83 eb 01             	sub    $0x1,%ebx
  800830:	74 20                	je     800852 <strlcpy+0x3b>
  800832:	0f b6 11             	movzbl (%ecx),%edx
  800835:	84 d2                	test   %dl,%dl
  800837:	74 19                	je     800852 <strlcpy+0x3b>
  800839:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  80083b:	88 10                	mov    %dl,(%eax)
  80083d:	83 c0 01             	add    $0x1,%eax
  800840:	83 eb 01             	sub    $0x1,%ebx
  800843:	74 0f                	je     800854 <strlcpy+0x3d>
  800845:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  800849:	83 c1 01             	add    $0x1,%ecx
  80084c:	84 d2                	test   %dl,%dl
  80084e:	74 04                	je     800854 <strlcpy+0x3d>
  800850:	eb e9                	jmp    80083b <strlcpy+0x24>
  800852:	89 f0                	mov    %esi,%eax
		*dst = '\0';
  800854:	c6 00 00             	movb   $0x0,(%eax)
  800857:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800859:	5b                   	pop    %ebx
  80085a:	5e                   	pop    %esi
  80085b:	5d                   	pop    %ebp
  80085c:	c3                   	ret    

0080085d <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	57                   	push   %edi
  800861:	56                   	push   %esi
  800862:	53                   	push   %ebx
  800863:	8b 55 08             	mov    0x8(%ebp),%edx
  800866:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800869:	8b 7d 10             	mov    0x10(%ebp),%edi
    int c;
    char *q = buf;

    if (buf_size <= 0)
  80086c:	85 c9                	test   %ecx,%ecx
  80086e:	7e 30                	jle    8008a0 <pstrcpy+0x43>
        return;

    for(;;) {
        c = *str++;
  800870:	0f b6 07             	movzbl (%edi),%eax
        if (c == 0 || q >= buf + buf_size - 1)
  800873:	84 c0                	test   %al,%al
  800875:	74 26                	je     80089d <pstrcpy+0x40>
  800877:	8d 74 0a ff          	lea    0xffffffff(%edx,%ecx,1),%esi
  80087b:	0f be d8             	movsbl %al,%ebx
  80087e:	89 f9                	mov    %edi,%ecx
  800880:	39 f2                	cmp    %esi,%edx
  800882:	72 09                	jb     80088d <pstrcpy+0x30>
  800884:	eb 17                	jmp    80089d <pstrcpy+0x40>
  800886:	83 c1 01             	add    $0x1,%ecx
  800889:	39 f2                	cmp    %esi,%edx
  80088b:	73 10                	jae    80089d <pstrcpy+0x40>
            break;
        *q++ = c;
  80088d:	88 1a                	mov    %bl,(%edx)
  80088f:	83 c2 01             	add    $0x1,%edx
  800892:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800896:	0f be d8             	movsbl %al,%ebx
  800899:	84 c0                	test   %al,%al
  80089b:	75 e9                	jne    800886 <pstrcpy+0x29>
    }
    *q = '\0';
  80089d:	c6 02 00             	movb   $0x0,(%edx)
}
  8008a0:	5b                   	pop    %ebx
  8008a1:	5e                   	pop    %esi
  8008a2:	5f                   	pop    %edi
  8008a3:	5d                   	pop    %ebp
  8008a4:	c3                   	ret    

008008a5 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8008ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  8008ae:	0f b6 02             	movzbl (%edx),%eax
  8008b1:	84 c0                	test   %al,%al
  8008b3:	74 16                	je     8008cb <strcmp+0x26>
  8008b5:	3a 01                	cmp    (%ecx),%al
  8008b7:	75 12                	jne    8008cb <strcmp+0x26>
		p++, q++;
  8008b9:	83 c1 01             	add    $0x1,%ecx
  8008bc:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  8008c0:	84 c0                	test   %al,%al
  8008c2:	74 07                	je     8008cb <strcmp+0x26>
  8008c4:	83 c2 01             	add    $0x1,%edx
  8008c7:	3a 01                	cmp    (%ecx),%al
  8008c9:	74 ee                	je     8008b9 <strcmp+0x14>
  8008cb:	0f b6 c0             	movzbl %al,%eax
  8008ce:	0f b6 11             	movzbl (%ecx),%edx
  8008d1:	29 d0                	sub    %edx,%eax
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	53                   	push   %ebx
  8008d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008df:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008e2:	85 d2                	test   %edx,%edx
  8008e4:	74 2d                	je     800913 <strncmp+0x3e>
  8008e6:	0f b6 01             	movzbl (%ecx),%eax
  8008e9:	84 c0                	test   %al,%al
  8008eb:	74 1a                	je     800907 <strncmp+0x32>
  8008ed:	3a 03                	cmp    (%ebx),%al
  8008ef:	75 16                	jne    800907 <strncmp+0x32>
  8008f1:	83 ea 01             	sub    $0x1,%edx
  8008f4:	74 1d                	je     800913 <strncmp+0x3e>
		n--, p++, q++;
  8008f6:	83 c1 01             	add    $0x1,%ecx
  8008f9:	83 c3 01             	add    $0x1,%ebx
  8008fc:	0f b6 01             	movzbl (%ecx),%eax
  8008ff:	84 c0                	test   %al,%al
  800901:	74 04                	je     800907 <strncmp+0x32>
  800903:	3a 03                	cmp    (%ebx),%al
  800905:	74 ea                	je     8008f1 <strncmp+0x1c>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800907:	0f b6 11             	movzbl (%ecx),%edx
  80090a:	0f b6 03             	movzbl (%ebx),%eax
  80090d:	29 c2                	sub    %eax,%edx
  80090f:	89 d0                	mov    %edx,%eax
  800911:	eb 05                	jmp    800918 <strncmp+0x43>
  800913:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800918:	5b                   	pop    %ebx
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800925:	0f b6 10             	movzbl (%eax),%edx
  800928:	84 d2                	test   %dl,%dl
  80092a:	74 16                	je     800942 <strchr+0x27>
		if (*s == c)
  80092c:	38 ca                	cmp    %cl,%dl
  80092e:	75 06                	jne    800936 <strchr+0x1b>
  800930:	eb 15                	jmp    800947 <strchr+0x2c>
  800932:	38 ca                	cmp    %cl,%dl
  800934:	74 11                	je     800947 <strchr+0x2c>
  800936:	83 c0 01             	add    $0x1,%eax
  800939:	0f b6 10             	movzbl (%eax),%edx
  80093c:	84 d2                	test   %dl,%dl
  80093e:	66 90                	xchg   %ax,%ax
  800940:	75 f0                	jne    800932 <strchr+0x17>
  800942:	b8 00 00 00 00       	mov    $0x0,%eax
			return (char *) s;
	return 0;
}
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	8b 45 08             	mov    0x8(%ebp),%eax
  80094f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800953:	0f b6 10             	movzbl (%eax),%edx
  800956:	84 d2                	test   %dl,%dl
  800958:	74 14                	je     80096e <strfind+0x25>
		if (*s == c)
  80095a:	38 ca                	cmp    %cl,%dl
  80095c:	75 06                	jne    800964 <strfind+0x1b>
  80095e:	eb 0e                	jmp    80096e <strfind+0x25>
  800960:	38 ca                	cmp    %cl,%dl
  800962:	74 0a                	je     80096e <strfind+0x25>
  800964:	83 c0 01             	add    $0x1,%eax
  800967:	0f b6 10             	movzbl (%eax),%edx
  80096a:	84 d2                	test   %dl,%dl
  80096c:	75 f2                	jne    800960 <strfind+0x17>
			break;
	return (char *) s;
}
  80096e:	5d                   	pop    %ebp
  80096f:	90                   	nop    
  800970:	c3                   	ret    

00800971 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	83 ec 08             	sub    $0x8,%esp
  800977:	89 1c 24             	mov    %ebx,(%esp)
  80097a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80097e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800981:	8b 45 0c             	mov    0xc(%ebp),%eax
  800984:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800987:	85 db                	test   %ebx,%ebx
  800989:	74 32                	je     8009bd <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80098b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800991:	75 25                	jne    8009b8 <memset+0x47>
  800993:	f6 c3 03             	test   $0x3,%bl
  800996:	75 20                	jne    8009b8 <memset+0x47>
		c &= 0xFF;
  800998:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80099b:	89 d0                	mov    %edx,%eax
  80099d:	c1 e0 18             	shl    $0x18,%eax
  8009a0:	89 d1                	mov    %edx,%ecx
  8009a2:	c1 e1 10             	shl    $0x10,%ecx
  8009a5:	09 c8                	or     %ecx,%eax
  8009a7:	09 d0                	or     %edx,%eax
  8009a9:	c1 e2 08             	shl    $0x8,%edx
  8009ac:	09 d0                	or     %edx,%eax
  8009ae:	89 d9                	mov    %ebx,%ecx
  8009b0:	c1 e9 02             	shr    $0x2,%ecx
  8009b3:	fc                   	cld    
  8009b4:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b6:	eb 05                	jmp    8009bd <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009b8:	89 d9                	mov    %ebx,%ecx
  8009ba:	fc                   	cld    
  8009bb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009bd:	89 f8                	mov    %edi,%eax
  8009bf:	8b 1c 24             	mov    (%esp),%ebx
  8009c2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8009c6:	89 ec                	mov    %ebp,%esp
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	83 ec 08             	sub    $0x8,%esp
  8009d0:	89 34 24             	mov    %esi,(%esp)
  8009d3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009da:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  8009dd:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8009e0:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8009e2:	39 c6                	cmp    %eax,%esi
  8009e4:	73 36                	jae    800a1c <memmove+0x52>
  8009e6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009e9:	39 d0                	cmp    %edx,%eax
  8009eb:	73 2f                	jae    800a1c <memmove+0x52>
		s += n;
		d += n;
  8009ed:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f0:	f6 c2 03             	test   $0x3,%dl
  8009f3:	75 1b                	jne    800a10 <memmove+0x46>
  8009f5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009fb:	75 13                	jne    800a10 <memmove+0x46>
  8009fd:	f6 c1 03             	test   $0x3,%cl
  800a00:	75 0e                	jne    800a10 <memmove+0x46>
			asm volatile("std; rep movsl\n"
  800a02:	8d 7e fc             	lea    0xfffffffc(%esi),%edi
  800a05:	8d 72 fc             	lea    0xfffffffc(%edx),%esi
  800a08:	c1 e9 02             	shr    $0x2,%ecx
  800a0b:	fd                   	std    
  800a0c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0e:	eb 09                	jmp    800a19 <memmove+0x4f>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a10:	8d 7e ff             	lea    0xffffffff(%esi),%edi
  800a13:	8d 72 ff             	lea    0xffffffff(%edx),%esi
  800a16:	fd                   	std    
  800a17:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a19:	fc                   	cld    
  800a1a:	eb 21                	jmp    800a3d <memmove+0x73>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a22:	75 16                	jne    800a3a <memmove+0x70>
  800a24:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a2a:	75 0e                	jne    800a3a <memmove+0x70>
  800a2c:	f6 c1 03             	test   $0x3,%cl
  800a2f:	90                   	nop    
  800a30:	75 08                	jne    800a3a <memmove+0x70>
			asm volatile("cld; rep movsl\n"
  800a32:	c1 e9 02             	shr    $0x2,%ecx
  800a35:	fc                   	cld    
  800a36:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a38:	eb 03                	jmp    800a3d <memmove+0x73>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a3a:	fc                   	cld    
  800a3b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a3d:	8b 34 24             	mov    (%esp),%esi
  800a40:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800a44:	89 ec                	mov    %ebp,%esp
  800a46:	5d                   	pop    %ebp
  800a47:	c3                   	ret    

00800a48 <memcpy>:

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
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a4e:	8b 45 10             	mov    0x10(%ebp),%eax
  800a51:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a58:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5f:	89 04 24             	mov    %eax,(%esp)
  800a62:	e8 63 ff ff ff       	call   8009ca <memmove>
}
  800a67:	c9                   	leave  
  800a68:	c3                   	ret    

00800a69 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	56                   	push   %esi
  800a6d:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6e:	8b 75 10             	mov    0x10(%ebp),%esi
  800a71:	83 ee 01             	sub    $0x1,%esi
  800a74:	83 fe ff             	cmp    $0xffffffff,%esi
  800a77:	74 38                	je     800ab1 <memcmp+0x48>
  800a79:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7c:	8b 55 0c             	mov    0xc(%ebp),%edx
		if (*s1 != *s2)
  800a7f:	0f b6 18             	movzbl (%eax),%ebx
  800a82:	0f b6 0a             	movzbl (%edx),%ecx
  800a85:	38 cb                	cmp    %cl,%bl
  800a87:	74 20                	je     800aa9 <memcmp+0x40>
  800a89:	eb 12                	jmp    800a9d <memcmp+0x34>
  800a8b:	0f b6 58 01          	movzbl 0x1(%eax),%ebx
  800a8f:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
  800a93:	83 c0 01             	add    $0x1,%eax
  800a96:	83 c2 01             	add    $0x1,%edx
  800a99:	38 cb                	cmp    %cl,%bl
  800a9b:	74 0c                	je     800aa9 <memcmp+0x40>
			return (int) *s1 - (int) *s2;
  800a9d:	0f b6 d3             	movzbl %bl,%edx
  800aa0:	0f b6 c1             	movzbl %cl,%eax
  800aa3:	29 c2                	sub    %eax,%edx
  800aa5:	89 d0                	mov    %edx,%eax
  800aa7:	eb 0d                	jmp    800ab6 <memcmp+0x4d>
  800aa9:	83 ee 01             	sub    $0x1,%esi
  800aac:	83 fe ff             	cmp    $0xffffffff,%esi
  800aaf:	75 da                	jne    800a8b <memcmp+0x22>
  800ab1:	b8 00 00 00 00       	mov    $0x0,%eax
		s1++, s2++;
	}

	return 0;
}
  800ab6:	5b                   	pop    %ebx
  800ab7:	5e                   	pop    %esi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	53                   	push   %ebx
  800abe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800ac1:	89 da                	mov    %ebx,%edx
  800ac3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ac6:	39 d3                	cmp    %edx,%ebx
  800ac8:	73 1a                	jae    800ae4 <memfind+0x2a>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aca:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
			break;
  800ace:	89 d8                	mov    %ebx,%eax
  800ad0:	38 0b                	cmp    %cl,(%ebx)
  800ad2:	75 06                	jne    800ada <memfind+0x20>
  800ad4:	eb 0e                	jmp    800ae4 <memfind+0x2a>
  800ad6:	38 08                	cmp    %cl,(%eax)
  800ad8:	74 0c                	je     800ae6 <memfind+0x2c>
  800ada:	83 c0 01             	add    $0x1,%eax
  800add:	39 d0                	cmp    %edx,%eax
  800adf:	90                   	nop    
  800ae0:	75 f4                	jne    800ad6 <memfind+0x1c>
  800ae2:	eb 02                	jmp    800ae6 <memfind+0x2c>
  800ae4:	89 d8                	mov    %ebx,%eax
	return (void *) s;
}
  800ae6:	5b                   	pop    %ebx
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    

00800ae9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	57                   	push   %edi
  800aed:	56                   	push   %esi
  800aee:	53                   	push   %ebx
  800aef:	83 ec 04             	sub    $0x4,%esp
  800af2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800af5:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af8:	0f b6 03             	movzbl (%ebx),%eax
  800afb:	3c 20                	cmp    $0x20,%al
  800afd:	74 04                	je     800b03 <strtol+0x1a>
  800aff:	3c 09                	cmp    $0x9,%al
  800b01:	75 0e                	jne    800b11 <strtol+0x28>
		s++;
  800b03:	83 c3 01             	add    $0x1,%ebx
  800b06:	0f b6 03             	movzbl (%ebx),%eax
  800b09:	3c 20                	cmp    $0x20,%al
  800b0b:	74 f6                	je     800b03 <strtol+0x1a>
  800b0d:	3c 09                	cmp    $0x9,%al
  800b0f:	74 f2                	je     800b03 <strtol+0x1a>

	// plus/minus sign
	if (*s == '+')
  800b11:	3c 2b                	cmp    $0x2b,%al
  800b13:	75 0d                	jne    800b22 <strtol+0x39>
		s++;
  800b15:	83 c3 01             	add    $0x1,%ebx
  800b18:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800b1f:	90                   	nop    
  800b20:	eb 15                	jmp    800b37 <strtol+0x4e>
	else if (*s == '-')
  800b22:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800b29:	3c 2d                	cmp    $0x2d,%al
  800b2b:	75 0a                	jne    800b37 <strtol+0x4e>
		s++, neg = 1;
  800b2d:	83 c3 01             	add    $0x1,%ebx
  800b30:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b37:	85 f6                	test   %esi,%esi
  800b39:	0f 94 c0             	sete   %al
  800b3c:	84 c0                	test   %al,%al
  800b3e:	75 05                	jne    800b45 <strtol+0x5c>
  800b40:	83 fe 10             	cmp    $0x10,%esi
  800b43:	75 17                	jne    800b5c <strtol+0x73>
  800b45:	80 3b 30             	cmpb   $0x30,(%ebx)
  800b48:	75 12                	jne    800b5c <strtol+0x73>
  800b4a:	80 7b 01 78          	cmpb   $0x78,0x1(%ebx)
  800b4e:	66 90                	xchg   %ax,%ax
  800b50:	75 0a                	jne    800b5c <strtol+0x73>
		s += 2, base = 16;
  800b52:	83 c3 02             	add    $0x2,%ebx
  800b55:	be 10 00 00 00       	mov    $0x10,%esi
  800b5a:	eb 1f                	jmp    800b7b <strtol+0x92>
	else if (base == 0 && s[0] == '0')
  800b5c:	85 f6                	test   %esi,%esi
  800b5e:	66 90                	xchg   %ax,%ax
  800b60:	75 10                	jne    800b72 <strtol+0x89>
  800b62:	80 3b 30             	cmpb   $0x30,(%ebx)
  800b65:	75 0b                	jne    800b72 <strtol+0x89>
		s++, base = 8;
  800b67:	83 c3 01             	add    $0x1,%ebx
  800b6a:	66 be 08 00          	mov    $0x8,%si
  800b6e:	66 90                	xchg   %ax,%ax
  800b70:	eb 09                	jmp    800b7b <strtol+0x92>
	else if (base == 0)
  800b72:	84 c0                	test   %al,%al
  800b74:	74 05                	je     800b7b <strtol+0x92>
  800b76:	be 0a 00 00 00       	mov    $0xa,%esi
  800b7b:	bf 00 00 00 00       	mov    $0x0,%edi
		base = 10;

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b80:	0f b6 13             	movzbl (%ebx),%edx
  800b83:	89 d1                	mov    %edx,%ecx
  800b85:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800b88:	3c 09                	cmp    $0x9,%al
  800b8a:	77 08                	ja     800b94 <strtol+0xab>
			dig = *s - '0';
  800b8c:	0f be c2             	movsbl %dl,%eax
  800b8f:	8d 50 d0             	lea    0xffffffd0(%eax),%edx
  800b92:	eb 1c                	jmp    800bb0 <strtol+0xc7>
		else if (*s >= 'a' && *s <= 'z')
  800b94:	8d 41 9f             	lea    0xffffff9f(%ecx),%eax
  800b97:	3c 19                	cmp    $0x19,%al
  800b99:	77 08                	ja     800ba3 <strtol+0xba>
			dig = *s - 'a' + 10;
  800b9b:	0f be c2             	movsbl %dl,%eax
  800b9e:	8d 50 a9             	lea    0xffffffa9(%eax),%edx
  800ba1:	eb 0d                	jmp    800bb0 <strtol+0xc7>
		else if (*s >= 'A' && *s <= 'Z')
  800ba3:	8d 41 bf             	lea    0xffffffbf(%ecx),%eax
  800ba6:	3c 19                	cmp    $0x19,%al
  800ba8:	77 17                	ja     800bc1 <strtol+0xd8>
			dig = *s - 'A' + 10;
  800baa:	0f be c2             	movsbl %dl,%eax
  800bad:	8d 50 c9             	lea    0xffffffc9(%eax),%edx
		else
			break;
		if (dig >= base)
  800bb0:	39 f2                	cmp    %esi,%edx
  800bb2:	7d 0d                	jge    800bc1 <strtol+0xd8>
			break;
		s++, val = (val * base) + dig;
  800bb4:	83 c3 01             	add    $0x1,%ebx
  800bb7:	89 f8                	mov    %edi,%eax
  800bb9:	0f af c6             	imul   %esi,%eax
  800bbc:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800bbf:	eb bf                	jmp    800b80 <strtol+0x97>
		// we don't properly detect overflow!
	}
  800bc1:	89 f8                	mov    %edi,%eax

	if (endptr)
  800bc3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc7:	74 05                	je     800bce <strtol+0xe5>
		*endptr = (char *) s;
  800bc9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bcc:	89 1a                	mov    %ebx,(%edx)
	return (neg ? -val : val);
  800bce:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800bd2:	74 04                	je     800bd8 <strtol+0xef>
  800bd4:	89 c7                	mov    %eax,%edi
  800bd6:	f7 df                	neg    %edi
}
  800bd8:	89 f8                	mov    %edi,%eax
  800bda:	83 c4 04             	add    $0x4,%esp
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    
	...

00800be4 <sys_cgetc>:
}

int
sys_cgetc(void)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	83 ec 0c             	sub    $0xc,%esp
  800bea:	89 1c 24             	mov    %ebx,(%esp)
  800bed:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bf1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800bf5:	b8 01 00 00 00       	mov    $0x1,%eax
  800bfa:	bf 00 00 00 00       	mov    $0x0,%edi
  800bff:	89 fa                	mov    %edi,%edx
  800c01:	89 f9                	mov    %edi,%ecx
  800c03:	89 fb                	mov    %edi,%ebx
  800c05:	89 fe                	mov    %edi,%esi
  800c07:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c09:	8b 1c 24             	mov    (%esp),%ebx
  800c0c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c10:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c14:	89 ec                	mov    %ebp,%esp
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <sys_cputs>:
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	83 ec 0c             	sub    $0xc,%esp
  800c1e:	89 1c 24             	mov    %ebx,(%esp)
  800c21:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c25:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c29:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c34:	89 f8                	mov    %edi,%eax
  800c36:	89 fb                	mov    %edi,%ebx
  800c38:	89 fe                	mov    %edi,%esi
  800c3a:	cd 30                	int    $0x30
  800c3c:	8b 1c 24             	mov    (%esp),%ebx
  800c3f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c43:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c47:	89 ec                	mov    %ebp,%esp
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <sys_time_msec>:

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
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	83 ec 0c             	sub    $0xc,%esp
  800c51:	89 1c 24             	mov    %ebx,(%esp)
  800c54:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c58:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c5c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800c61:	bf 00 00 00 00       	mov    $0x0,%edi
  800c66:	89 fa                	mov    %edi,%edx
  800c68:	89 f9                	mov    %edi,%ecx
  800c6a:	89 fb                	mov    %edi,%ebx
  800c6c:	89 fe                	mov    %edi,%esi
  800c6e:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800c70:	8b 1c 24             	mov    (%esp),%ebx
  800c73:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c77:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c7b:	89 ec                	mov    %ebp,%esp
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <sys_ipc_recv>:
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	83 ec 28             	sub    $0x28,%esp
  800c85:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800c88:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800c8b:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800c8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c91:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c96:	bf 00 00 00 00       	mov    $0x0,%edi
  800c9b:	89 f9                	mov    %edi,%ecx
  800c9d:	89 fb                	mov    %edi,%ebx
  800c9f:	89 fe                	mov    %edi,%esi
  800ca1:	cd 30                	int    $0x30
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	7e 28                	jle    800ccf <sys_ipc_recv+0x50>
  800ca7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cab:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800cb2:	00 
  800cb3:	c7 44 24 08 ff 25 80 	movl   $0x8025ff,0x8(%esp)
  800cba:	00 
  800cbb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc2:	00 
  800cc3:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  800cca:	e8 19 11 00 00       	call   801de8 <_panic>
  800ccf:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800cd2:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800cd5:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800cd8:	89 ec                	mov    %ebp,%esp
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    

00800cdc <sys_ipc_try_send>:
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	83 ec 0c             	sub    $0xc,%esp
  800ce2:	89 1c 24             	mov    %ebx,(%esp)
  800ce5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ce9:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ced:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf9:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cfe:	be 00 00 00 00       	mov    $0x0,%esi
  800d03:	cd 30                	int    $0x30
  800d05:	8b 1c 24             	mov    (%esp),%ebx
  800d08:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d0c:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d10:	89 ec                	mov    %ebp,%esp
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <sys_env_set_pgfault_upcall>:
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	83 ec 28             	sub    $0x28,%esp
  800d1a:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800d1d:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800d20:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800d23:	8b 55 08             	mov    0x8(%ebp),%edx
  800d26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d29:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d2e:	bf 00 00 00 00       	mov    $0x0,%edi
  800d33:	89 fb                	mov    %edi,%ebx
  800d35:	89 fe                	mov    %edi,%esi
  800d37:	cd 30                	int    $0x30
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	7e 28                	jle    800d65 <sys_env_set_pgfault_upcall+0x51>
  800d3d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d41:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d48:	00 
  800d49:	c7 44 24 08 ff 25 80 	movl   $0x8025ff,0x8(%esp)
  800d50:	00 
  800d51:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d58:	00 
  800d59:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  800d60:	e8 83 10 00 00       	call   801de8 <_panic>
  800d65:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800d68:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800d6b:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800d6e:	89 ec                	mov    %ebp,%esp
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <sys_env_set_trapframe>:
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	83 ec 28             	sub    $0x28,%esp
  800d78:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800d7b:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800d7e:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800d81:	8b 55 08             	mov    0x8(%ebp),%edx
  800d84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d87:	b8 09 00 00 00       	mov    $0x9,%eax
  800d8c:	bf 00 00 00 00       	mov    $0x0,%edi
  800d91:	89 fb                	mov    %edi,%ebx
  800d93:	89 fe                	mov    %edi,%esi
  800d95:	cd 30                	int    $0x30
  800d97:	85 c0                	test   %eax,%eax
  800d99:	7e 28                	jle    800dc3 <sys_env_set_trapframe+0x51>
  800d9b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d9f:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800da6:	00 
  800da7:	c7 44 24 08 ff 25 80 	movl   $0x8025ff,0x8(%esp)
  800dae:	00 
  800daf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db6:	00 
  800db7:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  800dbe:	e8 25 10 00 00       	call   801de8 <_panic>
  800dc3:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800dc6:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800dc9:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800dcc:	89 ec                	mov    %ebp,%esp
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <sys_env_set_status>:
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	83 ec 28             	sub    $0x28,%esp
  800dd6:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800dd9:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800ddc:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800ddf:	8b 55 08             	mov    0x8(%ebp),%edx
  800de2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de5:	b8 08 00 00 00       	mov    $0x8,%eax
  800dea:	bf 00 00 00 00       	mov    $0x0,%edi
  800def:	89 fb                	mov    %edi,%ebx
  800df1:	89 fe                	mov    %edi,%esi
  800df3:	cd 30                	int    $0x30
  800df5:	85 c0                	test   %eax,%eax
  800df7:	7e 28                	jle    800e21 <sys_env_set_status+0x51>
  800df9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dfd:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e04:	00 
  800e05:	c7 44 24 08 ff 25 80 	movl   $0x8025ff,0x8(%esp)
  800e0c:	00 
  800e0d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e14:	00 
  800e15:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  800e1c:	e8 c7 0f 00 00       	call   801de8 <_panic>
  800e21:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800e24:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800e27:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800e2a:	89 ec                	mov    %ebp,%esp
  800e2c:	5d                   	pop    %ebp
  800e2d:	c3                   	ret    

00800e2e <sys_page_unmap>:
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	83 ec 28             	sub    $0x28,%esp
  800e34:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800e37:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800e3a:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800e3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e43:	b8 06 00 00 00       	mov    $0x6,%eax
  800e48:	bf 00 00 00 00       	mov    $0x0,%edi
  800e4d:	89 fb                	mov    %edi,%ebx
  800e4f:	89 fe                	mov    %edi,%esi
  800e51:	cd 30                	int    $0x30
  800e53:	85 c0                	test   %eax,%eax
  800e55:	7e 28                	jle    800e7f <sys_page_unmap+0x51>
  800e57:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e5b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e62:	00 
  800e63:	c7 44 24 08 ff 25 80 	movl   $0x8025ff,0x8(%esp)
  800e6a:	00 
  800e6b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e72:	00 
  800e73:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  800e7a:	e8 69 0f 00 00       	call   801de8 <_panic>
  800e7f:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800e82:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800e85:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800e88:	89 ec                	mov    %ebp,%esp
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    

00800e8c <sys_page_map>:
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	83 ec 28             	sub    $0x28,%esp
  800e92:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800e95:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800e98:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800e9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ea4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ea7:	8b 75 18             	mov    0x18(%ebp),%esi
  800eaa:	b8 05 00 00 00       	mov    $0x5,%eax
  800eaf:	cd 30                	int    $0x30
  800eb1:	85 c0                	test   %eax,%eax
  800eb3:	7e 28                	jle    800edd <sys_page_map+0x51>
  800eb5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb9:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ec0:	00 
  800ec1:	c7 44 24 08 ff 25 80 	movl   $0x8025ff,0x8(%esp)
  800ec8:	00 
  800ec9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed0:	00 
  800ed1:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  800ed8:	e8 0b 0f 00 00       	call   801de8 <_panic>
  800edd:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800ee0:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800ee3:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800ee6:	89 ec                	mov    %ebp,%esp
  800ee8:	5d                   	pop    %ebp
  800ee9:	c3                   	ret    

00800eea <sys_page_alloc>:
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
  800eed:	83 ec 28             	sub    $0x28,%esp
  800ef0:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800ef3:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800ef6:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800ef9:	8b 55 08             	mov    0x8(%ebp),%edx
  800efc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f02:	b8 04 00 00 00       	mov    $0x4,%eax
  800f07:	bf 00 00 00 00       	mov    $0x0,%edi
  800f0c:	89 fe                	mov    %edi,%esi
  800f0e:	cd 30                	int    $0x30
  800f10:	85 c0                	test   %eax,%eax
  800f12:	7e 28                	jle    800f3c <sys_page_alloc+0x52>
  800f14:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f18:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f1f:	00 
  800f20:	c7 44 24 08 ff 25 80 	movl   $0x8025ff,0x8(%esp)
  800f27:	00 
  800f28:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f2f:	00 
  800f30:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  800f37:	e8 ac 0e 00 00       	call   801de8 <_panic>
  800f3c:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800f3f:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800f42:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800f45:	89 ec                	mov    %ebp,%esp
  800f47:	5d                   	pop    %ebp
  800f48:	c3                   	ret    

00800f49 <sys_yield>:
  800f49:	55                   	push   %ebp
  800f4a:	89 e5                	mov    %esp,%ebp
  800f4c:	83 ec 0c             	sub    $0xc,%esp
  800f4f:	89 1c 24             	mov    %ebx,(%esp)
  800f52:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f56:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f5a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f5f:	bf 00 00 00 00       	mov    $0x0,%edi
  800f64:	89 fa                	mov    %edi,%edx
  800f66:	89 f9                	mov    %edi,%ecx
  800f68:	89 fb                	mov    %edi,%ebx
  800f6a:	89 fe                	mov    %edi,%esi
  800f6c:	cd 30                	int    $0x30
  800f6e:	8b 1c 24             	mov    (%esp),%ebx
  800f71:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f75:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f79:	89 ec                	mov    %ebp,%esp
  800f7b:	5d                   	pop    %ebp
  800f7c:	c3                   	ret    

00800f7d <sys_getenvid>:
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
  800f80:	83 ec 0c             	sub    $0xc,%esp
  800f83:	89 1c 24             	mov    %ebx,(%esp)
  800f86:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f8a:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f8e:	b8 02 00 00 00       	mov    $0x2,%eax
  800f93:	bf 00 00 00 00       	mov    $0x0,%edi
  800f98:	89 fa                	mov    %edi,%edx
  800f9a:	89 f9                	mov    %edi,%ecx
  800f9c:	89 fb                	mov    %edi,%ebx
  800f9e:	89 fe                	mov    %edi,%esi
  800fa0:	cd 30                	int    $0x30
  800fa2:	8b 1c 24             	mov    (%esp),%ebx
  800fa5:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fa9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fad:	89 ec                	mov    %ebp,%esp
  800faf:	5d                   	pop    %ebp
  800fb0:	c3                   	ret    

00800fb1 <sys_env_destroy>:
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	83 ec 28             	sub    $0x28,%esp
  800fb7:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800fba:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800fbd:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800fc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc3:	b8 03 00 00 00       	mov    $0x3,%eax
  800fc8:	bf 00 00 00 00       	mov    $0x0,%edi
  800fcd:	89 f9                	mov    %edi,%ecx
  800fcf:	89 fb                	mov    %edi,%ebx
  800fd1:	89 fe                	mov    %edi,%esi
  800fd3:	cd 30                	int    $0x30
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	7e 28                	jle    801001 <sys_env_destroy+0x50>
  800fd9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fdd:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800fe4:	00 
  800fe5:	c7 44 24 08 ff 25 80 	movl   $0x8025ff,0x8(%esp)
  800fec:	00 
  800fed:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ff4:	00 
  800ff5:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  800ffc:	e8 e7 0d 00 00       	call   801de8 <_panic>
  801001:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801004:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801007:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  80100a:	89 ec                	mov    %ebp,%esp
  80100c:	5d                   	pop    %ebp
  80100d:	c3                   	ret    
	...

00801010 <fd2num>:
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	8b 45 08             	mov    0x8(%ebp),%eax
  801016:	05 00 00 00 30       	add    $0x30000000,%eax
  80101b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80101e:	5d                   	pop    %ebp
  80101f:	c3                   	ret    

00801020 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801026:	8b 45 08             	mov    0x8(%ebp),%eax
  801029:	89 04 24             	mov    %eax,(%esp)
  80102c:	e8 df ff ff ff       	call   801010 <fd2num>
  801031:	c1 e0 0c             	shl    $0xc,%eax
  801034:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801039:	c9                   	leave  
  80103a:	c3                   	ret    

0080103b <fd_alloc>:

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
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	53                   	push   %ebx
  80103f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801042:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  801047:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801049:	89 d0                	mov    %edx,%eax
  80104b:	c1 e8 16             	shr    $0x16,%eax
  80104e:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  801055:	a8 01                	test   $0x1,%al
  801057:	74 10                	je     801069 <fd_alloc+0x2e>
  801059:	89 d0                	mov    %edx,%eax
  80105b:	c1 e8 0c             	shr    $0xc,%eax
  80105e:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  801065:	a8 01                	test   $0x1,%al
  801067:	75 09                	jne    801072 <fd_alloc+0x37>
			*fd_store = fd;
  801069:	89 0b                	mov    %ecx,(%ebx)
  80106b:	b8 00 00 00 00       	mov    $0x0,%eax
  801070:	eb 19                	jmp    80108b <fd_alloc+0x50>
			return 0;
  801072:	81 c2 00 10 00 00    	add    $0x1000,%edx
  801078:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  80107e:	75 c7                	jne    801047 <fd_alloc+0xc>
		}
	}
	*fd_store = 0;
  801080:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801086:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  80108b:	5b                   	pop    %ebx
  80108c:	5d                   	pop    %ebp
  80108d:	c3                   	ret    

0080108e <fd_lookup>:

// Check that fdnum is in range and mapped.
// If it is, set *fd_store to the fd page virtual address.
//
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80108e:	55                   	push   %ebp
  80108f:	89 e5                	mov    %esp,%ebp
  801091:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801094:	83 f8 1f             	cmp    $0x1f,%eax
  801097:	77 35                	ja     8010ce <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801099:	c1 e0 0c             	shl    $0xc,%eax
  80109c:	8d 90 00 00 00 d0    	lea    0xd0000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  8010a2:	89 d0                	mov    %edx,%eax
  8010a4:	c1 e8 16             	shr    $0x16,%eax
  8010a7:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  8010ae:	a8 01                	test   $0x1,%al
  8010b0:	74 1c                	je     8010ce <fd_lookup+0x40>
  8010b2:	89 d0                	mov    %edx,%eax
  8010b4:	c1 e8 0c             	shr    $0xc,%eax
  8010b7:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  8010be:	a8 01                	test   $0x1,%al
  8010c0:	74 0c                	je     8010ce <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010c5:	89 10                	mov    %edx,(%eax)
  8010c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8010cc:	eb 05                	jmp    8010d3 <fd_lookup+0x45>
	return 0;
  8010ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010d3:	5d                   	pop    %ebp
  8010d4:	c3                   	ret    

008010d5 <seek>:

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
  8010d5:	55                   	push   %ebp
  8010d6:	89 e5                	mov    %esp,%ebp
  8010d8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010db:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  8010de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e5:	89 04 24             	mov    %eax,(%esp)
  8010e8:	e8 a1 ff ff ff       	call   80108e <fd_lookup>
  8010ed:	85 c0                	test   %eax,%eax
  8010ef:	78 0e                	js     8010ff <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8010f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010f4:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  8010f7:	89 50 04             	mov    %edx,0x4(%eax)
  8010fa:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8010ff:	c9                   	leave  
  801100:	c3                   	ret    

00801101 <dev_lookup>:
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	53                   	push   %ebx
  801105:	83 ec 14             	sub    $0x14,%esp
  801108:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80110b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80110e:	ba 04 60 80 00       	mov    $0x806004,%edx
  801113:	b8 00 00 00 00       	mov    $0x0,%eax
  801118:	39 0d 04 60 80 00    	cmp    %ecx,0x806004
  80111e:	75 12                	jne    801132 <dev_lookup+0x31>
  801120:	eb 04                	jmp    801126 <dev_lookup+0x25>
  801122:	39 0a                	cmp    %ecx,(%edx)
  801124:	75 0c                	jne    801132 <dev_lookup+0x31>
  801126:	89 13                	mov    %edx,(%ebx)
  801128:	b8 00 00 00 00       	mov    $0x0,%eax
  80112d:	8d 76 00             	lea    0x0(%esi),%esi
  801130:	eb 35                	jmp    801167 <dev_lookup+0x66>
  801132:	83 c0 01             	add    $0x1,%eax
  801135:	8b 14 85 ac 26 80 00 	mov    0x8026ac(,%eax,4),%edx
  80113c:	85 d2                	test   %edx,%edx
  80113e:	75 e2                	jne    801122 <dev_lookup+0x21>
  801140:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801145:	8b 40 4c             	mov    0x4c(%eax),%eax
  801148:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80114c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801150:	c7 04 24 2c 26 80 00 	movl   $0x80262c,(%esp)
  801157:	e8 dd ef ff ff       	call   800139 <cprintf>
  80115c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801162:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801167:	83 c4 14             	add    $0x14,%esp
  80116a:	5b                   	pop    %ebx
  80116b:	5d                   	pop    %ebp
  80116c:	c3                   	ret    

0080116d <fstat>:

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
  80116d:	55                   	push   %ebp
  80116e:	89 e5                	mov    %esp,%ebp
  801170:	53                   	push   %ebx
  801171:	83 ec 24             	sub    $0x24,%esp
  801174:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801177:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80117a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80117e:	8b 45 08             	mov    0x8(%ebp),%eax
  801181:	89 04 24             	mov    %eax,(%esp)
  801184:	e8 05 ff ff ff       	call   80108e <fd_lookup>
  801189:	89 c2                	mov    %eax,%edx
  80118b:	85 c0                	test   %eax,%eax
  80118d:	78 57                	js     8011e6 <fstat+0x79>
  80118f:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801192:	89 44 24 04          	mov    %eax,0x4(%esp)
  801196:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801199:	8b 00                	mov    (%eax),%eax
  80119b:	89 04 24             	mov    %eax,(%esp)
  80119e:	e8 5e ff ff ff       	call   801101 <dev_lookup>
  8011a3:	89 c2                	mov    %eax,%edx
  8011a5:	85 c0                	test   %eax,%eax
  8011a7:	78 3d                	js     8011e6 <fstat+0x79>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8011a9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  8011ae:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
  8011b1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8011b5:	74 2f                	je     8011e6 <fstat+0x79>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8011b7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8011ba:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8011c1:	00 00 00 
	stat->st_isdir = 0;
  8011c4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8011cb:	00 00 00 
	stat->st_dev = dev;
  8011ce:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  8011d1:	89 93 88 00 00 00    	mov    %edx,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8011d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011db:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8011de:	89 04 24             	mov    %eax,(%esp)
  8011e1:	ff 52 14             	call   *0x14(%edx)
  8011e4:	89 c2                	mov    %eax,%edx
}
  8011e6:	89 d0                	mov    %edx,%eax
  8011e8:	83 c4 24             	add    $0x24,%esp
  8011eb:	5b                   	pop    %ebx
  8011ec:	5d                   	pop    %ebp
  8011ed:	c3                   	ret    

008011ee <ftruncate>:
  8011ee:	55                   	push   %ebp
  8011ef:	89 e5                	mov    %esp,%ebp
  8011f1:	53                   	push   %ebx
  8011f2:	83 ec 24             	sub    $0x24,%esp
  8011f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8011f8:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8011fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ff:	89 1c 24             	mov    %ebx,(%esp)
  801202:	e8 87 fe ff ff       	call   80108e <fd_lookup>
  801207:	85 c0                	test   %eax,%eax
  801209:	78 61                	js     80126c <ftruncate+0x7e>
  80120b:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80120e:	8b 10                	mov    (%eax),%edx
  801210:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801213:	89 44 24 04          	mov    %eax,0x4(%esp)
  801217:	89 14 24             	mov    %edx,(%esp)
  80121a:	e8 e2 fe ff ff       	call   801101 <dev_lookup>
  80121f:	85 c0                	test   %eax,%eax
  801221:	78 49                	js     80126c <ftruncate+0x7e>
  801223:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  801226:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  80122a:	75 23                	jne    80124f <ftruncate+0x61>
  80122c:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801231:	8b 40 4c             	mov    0x4c(%eax),%eax
  801234:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801238:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123c:	c7 04 24 4c 26 80 00 	movl   $0x80264c,(%esp)
  801243:	e8 f1 ee ff ff       	call   800139 <cprintf>
  801248:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80124d:	eb 1d                	jmp    80126c <ftruncate+0x7e>
  80124f:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801252:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801257:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  80125b:	74 0f                	je     80126c <ftruncate+0x7e>
  80125d:	8b 52 18             	mov    0x18(%edx),%edx
  801260:	8b 45 0c             	mov    0xc(%ebp),%eax
  801263:	89 44 24 04          	mov    %eax,0x4(%esp)
  801267:	89 0c 24             	mov    %ecx,(%esp)
  80126a:	ff d2                	call   *%edx
  80126c:	83 c4 24             	add    $0x24,%esp
  80126f:	5b                   	pop    %ebx
  801270:	5d                   	pop    %ebp
  801271:	c3                   	ret    

00801272 <write>:
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	53                   	push   %ebx
  801276:	83 ec 24             	sub    $0x24,%esp
  801279:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80127c:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80127f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801283:	89 1c 24             	mov    %ebx,(%esp)
  801286:	e8 03 fe ff ff       	call   80108e <fd_lookup>
  80128b:	85 c0                	test   %eax,%eax
  80128d:	78 68                	js     8012f7 <write+0x85>
  80128f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801292:	8b 10                	mov    (%eax),%edx
  801294:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801297:	89 44 24 04          	mov    %eax,0x4(%esp)
  80129b:	89 14 24             	mov    %edx,(%esp)
  80129e:	e8 5e fe ff ff       	call   801101 <dev_lookup>
  8012a3:	85 c0                	test   %eax,%eax
  8012a5:	78 50                	js     8012f7 <write+0x85>
  8012a7:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  8012aa:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  8012ae:	75 23                	jne    8012d3 <write+0x61>
  8012b0:	a1 3c 60 80 00       	mov    0x80603c,%eax
  8012b5:	8b 40 4c             	mov    0x4c(%eax),%eax
  8012b8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c0:	c7 04 24 70 26 80 00 	movl   $0x802670,(%esp)
  8012c7:	e8 6d ee ff ff       	call   800139 <cprintf>
  8012cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d1:	eb 24                	jmp    8012f7 <write+0x85>
  8012d3:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  8012d6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012db:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  8012df:	74 16                	je     8012f7 <write+0x85>
  8012e1:	8b 42 0c             	mov    0xc(%edx),%eax
  8012e4:	8b 55 10             	mov    0x10(%ebp),%edx
  8012e7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012f2:	89 0c 24             	mov    %ecx,(%esp)
  8012f5:	ff d0                	call   *%eax
  8012f7:	83 c4 24             	add    $0x24,%esp
  8012fa:	5b                   	pop    %ebx
  8012fb:	5d                   	pop    %ebp
  8012fc:	c3                   	ret    

008012fd <read>:
  8012fd:	55                   	push   %ebp
  8012fe:	89 e5                	mov    %esp,%ebp
  801300:	53                   	push   %ebx
  801301:	83 ec 24             	sub    $0x24,%esp
  801304:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801307:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80130a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130e:	89 1c 24             	mov    %ebx,(%esp)
  801311:	e8 78 fd ff ff       	call   80108e <fd_lookup>
  801316:	85 c0                	test   %eax,%eax
  801318:	78 6d                	js     801387 <read+0x8a>
  80131a:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80131d:	8b 10                	mov    (%eax),%edx
  80131f:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801322:	89 44 24 04          	mov    %eax,0x4(%esp)
  801326:	89 14 24             	mov    %edx,(%esp)
  801329:	e8 d3 fd ff ff       	call   801101 <dev_lookup>
  80132e:	85 c0                	test   %eax,%eax
  801330:	78 55                	js     801387 <read+0x8a>
  801332:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  801335:	8b 41 08             	mov    0x8(%ecx),%eax
  801338:	83 e0 03             	and    $0x3,%eax
  80133b:	83 f8 01             	cmp    $0x1,%eax
  80133e:	75 23                	jne    801363 <read+0x66>
  801340:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801345:	8b 40 4c             	mov    0x4c(%eax),%eax
  801348:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80134c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801350:	c7 04 24 8d 26 80 00 	movl   $0x80268d,(%esp)
  801357:	e8 dd ed ff ff       	call   800139 <cprintf>
  80135c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801361:	eb 24                	jmp    801387 <read+0x8a>
  801363:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801366:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80136b:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  80136f:	74 16                	je     801387 <read+0x8a>
  801371:	8b 42 08             	mov    0x8(%edx),%eax
  801374:	8b 55 10             	mov    0x10(%ebp),%edx
  801377:	89 54 24 08          	mov    %edx,0x8(%esp)
  80137b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80137e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801382:	89 0c 24             	mov    %ecx,(%esp)
  801385:	ff d0                	call   *%eax
  801387:	83 c4 24             	add    $0x24,%esp
  80138a:	5b                   	pop    %ebx
  80138b:	5d                   	pop    %ebp
  80138c:	c3                   	ret    

0080138d <readn>:
  80138d:	55                   	push   %ebp
  80138e:	89 e5                	mov    %esp,%ebp
  801390:	57                   	push   %edi
  801391:	56                   	push   %esi
  801392:	53                   	push   %ebx
  801393:	83 ec 0c             	sub    $0xc,%esp
  801396:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801399:	8b 75 10             	mov    0x10(%ebp),%esi
  80139c:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a1:	85 f6                	test   %esi,%esi
  8013a3:	74 36                	je     8013db <readn+0x4e>
  8013a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8013af:	89 f0                	mov    %esi,%eax
  8013b1:	29 d0                	sub    %edx,%eax
  8013b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013b7:	8d 04 17             	lea    (%edi,%edx,1),%eax
  8013ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013be:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c1:	89 04 24             	mov    %eax,(%esp)
  8013c4:	e8 34 ff ff ff       	call   8012fd <read>
  8013c9:	85 c0                	test   %eax,%eax
  8013cb:	78 0e                	js     8013db <readn+0x4e>
  8013cd:	85 c0                	test   %eax,%eax
  8013cf:	74 08                	je     8013d9 <readn+0x4c>
  8013d1:	01 c3                	add    %eax,%ebx
  8013d3:	89 da                	mov    %ebx,%edx
  8013d5:	39 f3                	cmp    %esi,%ebx
  8013d7:	72 d6                	jb     8013af <readn+0x22>
  8013d9:	89 d8                	mov    %ebx,%eax
  8013db:	83 c4 0c             	add    $0xc,%esp
  8013de:	5b                   	pop    %ebx
  8013df:	5e                   	pop    %esi
  8013e0:	5f                   	pop    %edi
  8013e1:	5d                   	pop    %ebp
  8013e2:	c3                   	ret    

008013e3 <fd_close>:
  8013e3:	55                   	push   %ebp
  8013e4:	89 e5                	mov    %esp,%ebp
  8013e6:	83 ec 28             	sub    $0x28,%esp
  8013e9:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  8013ec:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  8013ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8013f2:	89 34 24             	mov    %esi,(%esp)
  8013f5:	e8 16 fc ff ff       	call   801010 <fd2num>
  8013fa:	8d 55 f4             	lea    0xfffffff4(%ebp),%edx
  8013fd:	89 54 24 04          	mov    %edx,0x4(%esp)
  801401:	89 04 24             	mov    %eax,(%esp)
  801404:	e8 85 fc ff ff       	call   80108e <fd_lookup>
  801409:	89 c3                	mov    %eax,%ebx
  80140b:	85 c0                	test   %eax,%eax
  80140d:	78 05                	js     801414 <fd_close+0x31>
  80140f:	3b 75 f4             	cmp    0xfffffff4(%ebp),%esi
  801412:	74 0e                	je     801422 <fd_close+0x3f>
  801414:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801418:	75 45                	jne    80145f <fd_close+0x7c>
  80141a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80141f:	90                   	nop    
  801420:	eb 3d                	jmp    80145f <fd_close+0x7c>
  801422:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  801425:	89 44 24 04          	mov    %eax,0x4(%esp)
  801429:	8b 06                	mov    (%esi),%eax
  80142b:	89 04 24             	mov    %eax,(%esp)
  80142e:	e8 ce fc ff ff       	call   801101 <dev_lookup>
  801433:	89 c3                	mov    %eax,%ebx
  801435:	85 c0                	test   %eax,%eax
  801437:	78 16                	js     80144f <fd_close+0x6c>
  801439:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80143c:	8b 40 10             	mov    0x10(%eax),%eax
  80143f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801444:	85 c0                	test   %eax,%eax
  801446:	74 07                	je     80144f <fd_close+0x6c>
  801448:	89 34 24             	mov    %esi,(%esp)
  80144b:	ff d0                	call   *%eax
  80144d:	89 c3                	mov    %eax,%ebx
  80144f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801453:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80145a:	e8 cf f9 ff ff       	call   800e2e <sys_page_unmap>
  80145f:	89 d8                	mov    %ebx,%eax
  801461:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  801464:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  801467:	89 ec                	mov    %ebp,%esp
  801469:	5d                   	pop    %ebp
  80146a:	c3                   	ret    

0080146b <close>:
  80146b:	55                   	push   %ebp
  80146c:	89 e5                	mov    %esp,%ebp
  80146e:	83 ec 18             	sub    $0x18,%esp
  801471:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  801474:	89 44 24 04          	mov    %eax,0x4(%esp)
  801478:	8b 45 08             	mov    0x8(%ebp),%eax
  80147b:	89 04 24             	mov    %eax,(%esp)
  80147e:	e8 0b fc ff ff       	call   80108e <fd_lookup>
  801483:	85 c0                	test   %eax,%eax
  801485:	78 13                	js     80149a <close+0x2f>
  801487:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80148e:	00 
  80148f:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  801492:	89 04 24             	mov    %eax,(%esp)
  801495:	e8 49 ff ff ff       	call   8013e3 <fd_close>
  80149a:	c9                   	leave  
  80149b:	c3                   	ret    

0080149c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80149c:	55                   	push   %ebp
  80149d:	89 e5                	mov    %esp,%ebp
  80149f:	83 ec 18             	sub    $0x18,%esp
  8014a2:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  8014a5:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014a8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014af:	00 
  8014b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b3:	89 04 24             	mov    %eax,(%esp)
  8014b6:	e8 58 03 00 00       	call   801813 <open>
  8014bb:	89 c6                	mov    %eax,%esi
  8014bd:	85 c0                	test   %eax,%eax
  8014bf:	78 1b                	js     8014dc <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8014c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c8:	89 34 24             	mov    %esi,(%esp)
  8014cb:	e8 9d fc ff ff       	call   80116d <fstat>
  8014d0:	89 c3                	mov    %eax,%ebx
	close(fd);
  8014d2:	89 34 24             	mov    %esi,(%esp)
  8014d5:	e8 91 ff ff ff       	call   80146b <close>
  8014da:	89 de                	mov    %ebx,%esi
	return r;
}
  8014dc:	89 f0                	mov    %esi,%eax
  8014de:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  8014e1:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  8014e4:	89 ec                	mov    %ebp,%esp
  8014e6:	5d                   	pop    %ebp
  8014e7:	c3                   	ret    

008014e8 <dup>:
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
  8014eb:	83 ec 38             	sub    $0x38,%esp
  8014ee:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  8014f1:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  8014f4:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  8014f7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8014fa:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  8014fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801501:	8b 45 08             	mov    0x8(%ebp),%eax
  801504:	89 04 24             	mov    %eax,(%esp)
  801507:	e8 82 fb ff ff       	call   80108e <fd_lookup>
  80150c:	89 c3                	mov    %eax,%ebx
  80150e:	85 c0                	test   %eax,%eax
  801510:	0f 88 e1 00 00 00    	js     8015f7 <dup+0x10f>
  801516:	89 3c 24             	mov    %edi,(%esp)
  801519:	e8 4d ff ff ff       	call   80146b <close>
  80151e:	89 f8                	mov    %edi,%eax
  801520:	c1 e0 0c             	shl    $0xc,%eax
  801523:	8d b0 00 00 00 d0    	lea    0xd0000000(%eax),%esi
  801529:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80152c:	89 04 24             	mov    %eax,(%esp)
  80152f:	e8 ec fa ff ff       	call   801020 <fd2data>
  801534:	89 c3                	mov    %eax,%ebx
  801536:	89 34 24             	mov    %esi,(%esp)
  801539:	e8 e2 fa ff ff       	call   801020 <fd2data>
  80153e:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  801541:	89 d8                	mov    %ebx,%eax
  801543:	c1 e8 16             	shr    $0x16,%eax
  801546:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  80154d:	a8 01                	test   $0x1,%al
  80154f:	74 45                	je     801596 <dup+0xae>
  801551:	89 da                	mov    %ebx,%edx
  801553:	c1 ea 0c             	shr    $0xc,%edx
  801556:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  80155d:	a8 01                	test   $0x1,%al
  80155f:	74 35                	je     801596 <dup+0xae>
  801561:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  801568:	25 07 0e 00 00       	and    $0xe07,%eax
  80156d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801571:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  801574:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801578:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80157f:	00 
  801580:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801584:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80158b:	e8 fc f8 ff ff       	call   800e8c <sys_page_map>
  801590:	89 c3                	mov    %eax,%ebx
  801592:	85 c0                	test   %eax,%eax
  801594:	78 3e                	js     8015d4 <dup+0xec>
  801596:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  801599:	89 d0                	mov    %edx,%eax
  80159b:	c1 e8 0c             	shr    $0xc,%eax
  80159e:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  8015a5:	25 07 0e 00 00       	and    $0xe07,%eax
  8015aa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015ae:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8015b2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015b9:	00 
  8015ba:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015c5:	e8 c2 f8 ff ff       	call   800e8c <sys_page_map>
  8015ca:	89 c3                	mov    %eax,%ebx
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	78 04                	js     8015d4 <dup+0xec>
  8015d0:	89 fb                	mov    %edi,%ebx
  8015d2:	eb 23                	jmp    8015f7 <dup+0x10f>
  8015d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015df:	e8 4a f8 ff ff       	call   800e2e <sys_page_unmap>
  8015e4:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  8015e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015f2:	e8 37 f8 ff ff       	call   800e2e <sys_page_unmap>
  8015f7:	89 d8                	mov    %ebx,%eax
  8015f9:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  8015fc:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  8015ff:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801602:	89 ec                	mov    %ebp,%esp
  801604:	5d                   	pop    %ebp
  801605:	c3                   	ret    

00801606 <close_all>:
  801606:	55                   	push   %ebp
  801607:	89 e5                	mov    %esp,%ebp
  801609:	53                   	push   %ebx
  80160a:	83 ec 04             	sub    $0x4,%esp
  80160d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801612:	89 1c 24             	mov    %ebx,(%esp)
  801615:	e8 51 fe ff ff       	call   80146b <close>
  80161a:	83 c3 01             	add    $0x1,%ebx
  80161d:	83 fb 20             	cmp    $0x20,%ebx
  801620:	75 f0                	jne    801612 <close_all+0xc>
  801622:	83 c4 04             	add    $0x4,%esp
  801625:	5b                   	pop    %ebx
  801626:	5d                   	pop    %ebp
  801627:	c3                   	ret    

00801628 <fsipc>:
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801628:	55                   	push   %ebp
  801629:	89 e5                	mov    %esp,%ebp
  80162b:	53                   	push   %ebx
  80162c:	83 ec 14             	sub    $0x14,%esp
  80162f:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801631:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  801637:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80163e:	00 
  80163f:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801646:	00 
  801647:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164b:	89 14 24             	mov    %edx,(%esp)
  80164e:	e8 0d 08 00 00       	call   801e60 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801653:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80165a:	00 
  80165b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80165f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801666:	e8 a9 08 00 00       	call   801f14 <ipc_recv>
}
  80166b:	83 c4 14             	add    $0x14,%esp
  80166e:	5b                   	pop    %ebx
  80166f:	5d                   	pop    %ebp
  801670:	c3                   	ret    

00801671 <sync>:

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
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801677:	ba 00 00 00 00       	mov    $0x0,%edx
  80167c:	b8 08 00 00 00       	mov    $0x8,%eax
  801681:	e8 a2 ff ff ff       	call   801628 <fsipc>
}
  801686:	c9                   	leave  
  801687:	c3                   	ret    

00801688 <devfile_trunc>:
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	83 ec 08             	sub    $0x8,%esp
  80168e:	8b 45 08             	mov    0x8(%ebp),%eax
  801691:	8b 40 0c             	mov    0xc(%eax),%eax
  801694:	a3 00 30 80 00       	mov    %eax,0x803000
  801699:	8b 45 0c             	mov    0xc(%ebp),%eax
  80169c:	a3 04 30 80 00       	mov    %eax,0x803004
  8016a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a6:	b8 02 00 00 00       	mov    $0x2,%eax
  8016ab:	e8 78 ff ff ff       	call   801628 <fsipc>
  8016b0:	c9                   	leave  
  8016b1:	c3                   	ret    

008016b2 <devfile_flush>:
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	83 ec 08             	sub    $0x8,%esp
  8016b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8016be:	a3 00 30 80 00       	mov    %eax,0x803000
  8016c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c8:	b8 06 00 00 00       	mov    $0x6,%eax
  8016cd:	e8 56 ff ff ff       	call   801628 <fsipc>
  8016d2:	c9                   	leave  
  8016d3:	c3                   	ret    

008016d4 <devfile_stat>:
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	53                   	push   %ebx
  8016d8:	83 ec 14             	sub    $0x14,%esp
  8016db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016de:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e4:	a3 00 30 80 00       	mov    %eax,0x803000
  8016e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ee:	b8 05 00 00 00       	mov    $0x5,%eax
  8016f3:	e8 30 ff ff ff       	call   801628 <fsipc>
  8016f8:	85 c0                	test   %eax,%eax
  8016fa:	78 2b                	js     801727 <devfile_stat+0x53>
  8016fc:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801703:	00 
  801704:	89 1c 24             	mov    %ebx,(%esp)
  801707:	e8 b5 f0 ff ff       	call   8007c1 <strcpy>
  80170c:	a1 80 30 80 00       	mov    0x803080,%eax
  801711:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  801717:	a1 84 30 80 00       	mov    0x803084,%eax
  80171c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801722:	b8 00 00 00 00       	mov    $0x0,%eax
  801727:	83 c4 14             	add    $0x14,%esp
  80172a:	5b                   	pop    %ebx
  80172b:	5d                   	pop    %ebp
  80172c:	c3                   	ret    

0080172d <devfile_write>:
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	83 ec 18             	sub    $0x18,%esp
  801733:	8b 55 10             	mov    0x10(%ebp),%edx
  801736:	8b 45 08             	mov    0x8(%ebp),%eax
  801739:	8b 40 0c             	mov    0xc(%eax),%eax
  80173c:	a3 00 30 80 00       	mov    %eax,0x803000
  801741:	89 d0                	mov    %edx,%eax
  801743:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  801749:	76 05                	jbe    801750 <devfile_write+0x23>
  80174b:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801750:	89 15 04 30 80 00    	mov    %edx,0x803004
  801756:	89 44 24 08          	mov    %eax,0x8(%esp)
  80175a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80175d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801761:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  801768:	e8 5d f2 ff ff       	call   8009ca <memmove>
  80176d:	ba 00 00 00 00       	mov    $0x0,%edx
  801772:	b8 04 00 00 00       	mov    $0x4,%eax
  801777:	e8 ac fe ff ff       	call   801628 <fsipc>
  80177c:	c9                   	leave  
  80177d:	c3                   	ret    

0080177e <devfile_read>:
  80177e:	55                   	push   %ebp
  80177f:	89 e5                	mov    %esp,%ebp
  801781:	53                   	push   %ebx
  801782:	83 ec 14             	sub    $0x14,%esp
  801785:	8b 45 08             	mov    0x8(%ebp),%eax
  801788:	8b 40 0c             	mov    0xc(%eax),%eax
  80178b:	a3 00 30 80 00       	mov    %eax,0x803000
  801790:	8b 45 10             	mov    0x10(%ebp),%eax
  801793:	a3 04 30 80 00       	mov    %eax,0x803004
  801798:	ba 00 30 80 00       	mov    $0x803000,%edx
  80179d:	b8 03 00 00 00       	mov    $0x3,%eax
  8017a2:	e8 81 fe ff ff       	call   801628 <fsipc>
  8017a7:	89 c3                	mov    %eax,%ebx
  8017a9:	85 c0                	test   %eax,%eax
  8017ab:	7e 17                	jle    8017c4 <devfile_read+0x46>
  8017ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017b1:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  8017b8:	00 
  8017b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017bc:	89 04 24             	mov    %eax,(%esp)
  8017bf:	e8 06 f2 ff ff       	call   8009ca <memmove>
  8017c4:	89 d8                	mov    %ebx,%eax
  8017c6:	83 c4 14             	add    $0x14,%esp
  8017c9:	5b                   	pop    %ebx
  8017ca:	5d                   	pop    %ebp
  8017cb:	c3                   	ret    

008017cc <remove>:
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	53                   	push   %ebx
  8017d0:	83 ec 14             	sub    $0x14,%esp
  8017d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8017d6:	89 1c 24             	mov    %ebx,(%esp)
  8017d9:	e8 92 ef ff ff       	call   800770 <strlen>
  8017de:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  8017e3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017e8:	7f 21                	jg     80180b <remove+0x3f>
  8017ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017ee:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  8017f5:	e8 c7 ef ff ff       	call   8007c1 <strcpy>
  8017fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ff:	b8 07 00 00 00       	mov    $0x7,%eax
  801804:	e8 1f fe ff ff       	call   801628 <fsipc>
  801809:	89 c2                	mov    %eax,%edx
  80180b:	89 d0                	mov    %edx,%eax
  80180d:	83 c4 14             	add    $0x14,%esp
  801810:	5b                   	pop    %ebx
  801811:	5d                   	pop    %ebp
  801812:	c3                   	ret    

00801813 <open>:
  801813:	55                   	push   %ebp
  801814:	89 e5                	mov    %esp,%ebp
  801816:	56                   	push   %esi
  801817:	53                   	push   %ebx
  801818:	83 ec 30             	sub    $0x30,%esp
  80181b:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80181e:	89 04 24             	mov    %eax,(%esp)
  801821:	e8 15 f8 ff ff       	call   80103b <fd_alloc>
  801826:	89 c3                	mov    %eax,%ebx
  801828:	85 c0                	test   %eax,%eax
  80182a:	79 18                	jns    801844 <open+0x31>
  80182c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801833:	00 
  801834:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801837:	89 04 24             	mov    %eax,(%esp)
  80183a:	e8 a4 fb ff ff       	call   8013e3 <fd_close>
  80183f:	e9 9f 00 00 00       	jmp    8018e3 <open+0xd0>
  801844:	8b 45 08             	mov    0x8(%ebp),%eax
  801847:	89 44 24 04          	mov    %eax,0x4(%esp)
  80184b:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801852:	e8 6a ef ff ff       	call   8007c1 <strcpy>
  801857:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185a:	a3 00 34 80 00       	mov    %eax,0x803400
  80185f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801862:	89 04 24             	mov    %eax,(%esp)
  801865:	e8 b6 f7 ff ff       	call   801020 <fd2data>
  80186a:	89 c6                	mov    %eax,%esi
  80186c:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  80186f:	b8 01 00 00 00       	mov    $0x1,%eax
  801874:	e8 af fd ff ff       	call   801628 <fsipc>
  801879:	89 c3                	mov    %eax,%ebx
  80187b:	85 c0                	test   %eax,%eax
  80187d:	79 15                	jns    801894 <open+0x81>
  80187f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801886:	00 
  801887:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80188a:	89 04 24             	mov    %eax,(%esp)
  80188d:	e8 51 fb ff ff       	call   8013e3 <fd_close>
  801892:	eb 4f                	jmp    8018e3 <open+0xd0>
  801894:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80189b:	00 
  80189c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8018a0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018a7:	00 
  8018a8:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8018ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018b6:	e8 d1 f5 ff ff       	call   800e8c <sys_page_map>
  8018bb:	89 c3                	mov    %eax,%ebx
  8018bd:	85 c0                	test   %eax,%eax
  8018bf:	79 15                	jns    8018d6 <open+0xc3>
  8018c1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8018c8:	00 
  8018c9:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8018cc:	89 04 24             	mov    %eax,(%esp)
  8018cf:	e8 0f fb ff ff       	call   8013e3 <fd_close>
  8018d4:	eb 0d                	jmp    8018e3 <open+0xd0>
  8018d6:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8018d9:	89 04 24             	mov    %eax,(%esp)
  8018dc:	e8 2f f7 ff ff       	call   801010 <fd2num>
  8018e1:	89 c3                	mov    %eax,%ebx
  8018e3:	89 d8                	mov    %ebx,%eax
  8018e5:	83 c4 30             	add    $0x30,%esp
  8018e8:	5b                   	pop    %ebx
  8018e9:	5e                   	pop    %esi
  8018ea:	5d                   	pop    %ebp
  8018eb:	c3                   	ret    
  8018ec:	00 00                	add    %al,(%eax)
	...

008018f0 <devsock_stat>:
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8018f0:	55                   	push   %ebp
  8018f1:	89 e5                	mov    %esp,%ebp
  8018f3:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  8018f6:	c7 44 24 04 b8 26 80 	movl   $0x8026b8,0x4(%esp)
  8018fd:	00 
  8018fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801901:	89 04 24             	mov    %eax,(%esp)
  801904:	e8 b8 ee ff ff       	call   8007c1 <strcpy>
	return 0;
}
  801909:	b8 00 00 00 00       	mov    $0x0,%eax
  80190e:	c9                   	leave  
  80190f:	c3                   	ret    

00801910 <devsock_close>:
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	83 ec 08             	sub    $0x8,%esp
  801916:	8b 45 08             	mov    0x8(%ebp),%eax
  801919:	8b 40 0c             	mov    0xc(%eax),%eax
  80191c:	89 04 24             	mov    %eax,(%esp)
  80191f:	e8 be 02 00 00       	call   801be2 <nsipc_close>
  801924:	c9                   	leave  
  801925:	c3                   	ret    

00801926 <devsock_write>:
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	83 ec 18             	sub    $0x18,%esp
  80192c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801933:	00 
  801934:	8b 45 10             	mov    0x10(%ebp),%eax
  801937:	89 44 24 08          	mov    %eax,0x8(%esp)
  80193b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80193e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801942:	8b 45 08             	mov    0x8(%ebp),%eax
  801945:	8b 40 0c             	mov    0xc(%eax),%eax
  801948:	89 04 24             	mov    %eax,(%esp)
  80194b:	e8 ce 02 00 00       	call   801c1e <nsipc_send>
  801950:	c9                   	leave  
  801951:	c3                   	ret    

00801952 <devsock_read>:
  801952:	55                   	push   %ebp
  801953:	89 e5                	mov    %esp,%ebp
  801955:	83 ec 18             	sub    $0x18,%esp
  801958:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80195f:	00 
  801960:	8b 45 10             	mov    0x10(%ebp),%eax
  801963:	89 44 24 08          	mov    %eax,0x8(%esp)
  801967:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80196e:	8b 45 08             	mov    0x8(%ebp),%eax
  801971:	8b 40 0c             	mov    0xc(%eax),%eax
  801974:	89 04 24             	mov    %eax,(%esp)
  801977:	e8 15 03 00 00       	call   801c91 <nsipc_recv>
  80197c:	c9                   	leave  
  80197d:	c3                   	ret    

0080197e <alloc_sockfd>:
  80197e:	55                   	push   %ebp
  80197f:	89 e5                	mov    %esp,%ebp
  801981:	56                   	push   %esi
  801982:	53                   	push   %ebx
  801983:	83 ec 20             	sub    $0x20,%esp
  801986:	89 c6                	mov    %eax,%esi
  801988:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80198b:	89 04 24             	mov    %eax,(%esp)
  80198e:	e8 a8 f6 ff ff       	call   80103b <fd_alloc>
  801993:	89 c3                	mov    %eax,%ebx
  801995:	85 c0                	test   %eax,%eax
  801997:	78 21                	js     8019ba <alloc_sockfd+0x3c>
  801999:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8019a0:	00 
  8019a1:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8019a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019af:	e8 36 f5 ff ff       	call   800eea <sys_page_alloc>
  8019b4:	89 c3                	mov    %eax,%ebx
  8019b6:	85 c0                	test   %eax,%eax
  8019b8:	79 0a                	jns    8019c4 <alloc_sockfd+0x46>
  8019ba:	89 34 24             	mov    %esi,(%esp)
  8019bd:	e8 20 02 00 00       	call   801be2 <nsipc_close>
  8019c2:	eb 28                	jmp    8019ec <alloc_sockfd+0x6e>
  8019c4:	8b 15 20 60 80 00    	mov    0x806020,%edx
  8019ca:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8019cd:	89 10                	mov    %edx,(%eax)
  8019cf:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8019d2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
  8019d9:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8019dc:	89 70 0c             	mov    %esi,0xc(%eax)
  8019df:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8019e2:	89 04 24             	mov    %eax,(%esp)
  8019e5:	e8 26 f6 ff ff       	call   801010 <fd2num>
  8019ea:	89 c3                	mov    %eax,%ebx
  8019ec:	89 d8                	mov    %ebx,%eax
  8019ee:	83 c4 20             	add    $0x20,%esp
  8019f1:	5b                   	pop    %ebx
  8019f2:	5e                   	pop    %esi
  8019f3:	5d                   	pop    %ebp
  8019f4:	c3                   	ret    

008019f5 <socket>:

int
socket(int domain, int type, int protocol)
{
  8019f5:	55                   	push   %ebp
  8019f6:	89 e5                	mov    %esp,%ebp
  8019f8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8019fb:	8b 45 10             	mov    0x10(%ebp),%eax
  8019fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a02:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a09:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0c:	89 04 24             	mov    %eax,(%esp)
  801a0f:	e8 82 01 00 00       	call   801b96 <nsipc_socket>
  801a14:	85 c0                	test   %eax,%eax
  801a16:	78 05                	js     801a1d <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801a18:	e8 61 ff ff ff       	call   80197e <alloc_sockfd>
}
  801a1d:	c9                   	leave  
  801a1e:	66 90                	xchg   %ax,%ax
  801a20:	c3                   	ret    

00801a21 <fd2sockid>:
  801a21:	55                   	push   %ebp
  801a22:	89 e5                	mov    %esp,%ebp
  801a24:	83 ec 18             	sub    $0x18,%esp
  801a27:	8d 55 fc             	lea    0xfffffffc(%ebp),%edx
  801a2a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a2e:	89 04 24             	mov    %eax,(%esp)
  801a31:	e8 58 f6 ff ff       	call   80108e <fd_lookup>
  801a36:	89 c2                	mov    %eax,%edx
  801a38:	85 c0                	test   %eax,%eax
  801a3a:	78 15                	js     801a51 <fd2sockid+0x30>
  801a3c:	8b 4d fc             	mov    0xfffffffc(%ebp),%ecx
  801a3f:	8b 01                	mov    (%ecx),%eax
  801a41:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  801a46:	3b 05 20 60 80 00    	cmp    0x806020,%eax
  801a4c:	75 03                	jne    801a51 <fd2sockid+0x30>
  801a4e:	8b 51 0c             	mov    0xc(%ecx),%edx
  801a51:	89 d0                	mov    %edx,%eax
  801a53:	c9                   	leave  
  801a54:	c3                   	ret    

00801a55 <listen>:
  801a55:	55                   	push   %ebp
  801a56:	89 e5                	mov    %esp,%ebp
  801a58:	83 ec 08             	sub    $0x8,%esp
  801a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5e:	e8 be ff ff ff       	call   801a21 <fd2sockid>
  801a63:	89 c2                	mov    %eax,%edx
  801a65:	85 c0                	test   %eax,%eax
  801a67:	78 11                	js     801a7a <listen+0x25>
  801a69:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a70:	89 14 24             	mov    %edx,(%esp)
  801a73:	e8 48 01 00 00       	call   801bc0 <nsipc_listen>
  801a78:	89 c2                	mov    %eax,%edx
  801a7a:	89 d0                	mov    %edx,%eax
  801a7c:	c9                   	leave  
  801a7d:	c3                   	ret    

00801a7e <connect>:
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	83 ec 18             	sub    $0x18,%esp
  801a84:	8b 45 08             	mov    0x8(%ebp),%eax
  801a87:	e8 95 ff ff ff       	call   801a21 <fd2sockid>
  801a8c:	89 c2                	mov    %eax,%edx
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	78 18                	js     801aaa <connect+0x2c>
  801a92:	8b 45 10             	mov    0x10(%ebp),%eax
  801a95:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a99:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa0:	89 14 24             	mov    %edx,(%esp)
  801aa3:	e8 71 02 00 00       	call   801d19 <nsipc_connect>
  801aa8:	89 c2                	mov    %eax,%edx
  801aaa:	89 d0                	mov    %edx,%eax
  801aac:	c9                   	leave  
  801aad:	c3                   	ret    

00801aae <shutdown>:
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	83 ec 08             	sub    $0x8,%esp
  801ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab7:	e8 65 ff ff ff       	call   801a21 <fd2sockid>
  801abc:	89 c2                	mov    %eax,%edx
  801abe:	85 c0                	test   %eax,%eax
  801ac0:	78 11                	js     801ad3 <shutdown+0x25>
  801ac2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac9:	89 14 24             	mov    %edx,(%esp)
  801acc:	e8 2b 01 00 00       	call   801bfc <nsipc_shutdown>
  801ad1:	89 c2                	mov    %eax,%edx
  801ad3:	89 d0                	mov    %edx,%eax
  801ad5:	c9                   	leave  
  801ad6:	c3                   	ret    

00801ad7 <bind>:
  801ad7:	55                   	push   %ebp
  801ad8:	89 e5                	mov    %esp,%ebp
  801ada:	83 ec 18             	sub    $0x18,%esp
  801add:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae0:	e8 3c ff ff ff       	call   801a21 <fd2sockid>
  801ae5:	89 c2                	mov    %eax,%edx
  801ae7:	85 c0                	test   %eax,%eax
  801ae9:	78 18                	js     801b03 <bind+0x2c>
  801aeb:	8b 45 10             	mov    0x10(%ebp),%eax
  801aee:	89 44 24 08          	mov    %eax,0x8(%esp)
  801af2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af9:	89 14 24             	mov    %edx,(%esp)
  801afc:	e8 57 02 00 00       	call   801d58 <nsipc_bind>
  801b01:	89 c2                	mov    %eax,%edx
  801b03:	89 d0                	mov    %edx,%eax
  801b05:	c9                   	leave  
  801b06:	c3                   	ret    

00801b07 <accept>:
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	83 ec 18             	sub    $0x18,%esp
  801b0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b10:	e8 0c ff ff ff       	call   801a21 <fd2sockid>
  801b15:	89 c2                	mov    %eax,%edx
  801b17:	85 c0                	test   %eax,%eax
  801b19:	78 23                	js     801b3e <accept+0x37>
  801b1b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b1e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b22:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b25:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b29:	89 14 24             	mov    %edx,(%esp)
  801b2c:	e8 66 02 00 00       	call   801d97 <nsipc_accept>
  801b31:	89 c2                	mov    %eax,%edx
  801b33:	85 c0                	test   %eax,%eax
  801b35:	78 07                	js     801b3e <accept+0x37>
  801b37:	e8 42 fe ff ff       	call   80197e <alloc_sockfd>
  801b3c:	89 c2                	mov    %eax,%edx
  801b3e:	89 d0                	mov    %edx,%eax
  801b40:	c9                   	leave  
  801b41:	c3                   	ret    
	...

00801b50 <nsipc>:
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b56:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  801b5c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b63:	00 
  801b64:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801b6b:	00 
  801b6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b70:	89 14 24             	mov    %edx,(%esp)
  801b73:	e8 e8 02 00 00       	call   801e60 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801b78:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b7f:	00 
  801b80:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b87:	00 
  801b88:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b8f:	e8 80 03 00 00       	call   801f14 <ipc_recv>
}
  801b94:	c9                   	leave  
  801b95:	c3                   	ret    

00801b96 <nsipc_socket>:

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
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801b9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9f:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.socket.req_type = type;
  801ba4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba7:	a3 04 50 80 00       	mov    %eax,0x805004
	nsipcbuf.socket.req_protocol = protocol;
  801bac:	8b 45 10             	mov    0x10(%ebp),%eax
  801baf:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SOCKET);
  801bb4:	b8 09 00 00 00       	mov    $0x9,%eax
  801bb9:	e8 92 ff ff ff       	call   801b50 <nsipc>
}
  801bbe:	c9                   	leave  
  801bbf:	c3                   	ret    

00801bc0 <nsipc_listen>:
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	83 ec 08             	sub    $0x8,%esp
  801bc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc9:	a3 00 50 80 00       	mov    %eax,0x805000
  801bce:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bd1:	a3 04 50 80 00       	mov    %eax,0x805004
  801bd6:	b8 06 00 00 00       	mov    $0x6,%eax
  801bdb:	e8 70 ff ff ff       	call   801b50 <nsipc>
  801be0:	c9                   	leave  
  801be1:	c3                   	ret    

00801be2 <nsipc_close>:
  801be2:	55                   	push   %ebp
  801be3:	89 e5                	mov    %esp,%ebp
  801be5:	83 ec 08             	sub    $0x8,%esp
  801be8:	8b 45 08             	mov    0x8(%ebp),%eax
  801beb:	a3 00 50 80 00       	mov    %eax,0x805000
  801bf0:	b8 04 00 00 00       	mov    $0x4,%eax
  801bf5:	e8 56 ff ff ff       	call   801b50 <nsipc>
  801bfa:	c9                   	leave  
  801bfb:	c3                   	ret    

00801bfc <nsipc_shutdown>:
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	83 ec 08             	sub    $0x8,%esp
  801c02:	8b 45 08             	mov    0x8(%ebp),%eax
  801c05:	a3 00 50 80 00       	mov    %eax,0x805000
  801c0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c0d:	a3 04 50 80 00       	mov    %eax,0x805004
  801c12:	b8 03 00 00 00       	mov    $0x3,%eax
  801c17:	e8 34 ff ff ff       	call   801b50 <nsipc>
  801c1c:	c9                   	leave  
  801c1d:	c3                   	ret    

00801c1e <nsipc_send>:
  801c1e:	55                   	push   %ebp
  801c1f:	89 e5                	mov    %esp,%ebp
  801c21:	53                   	push   %ebx
  801c22:	83 ec 14             	sub    $0x14,%esp
  801c25:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c28:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2b:	a3 00 50 80 00       	mov    %eax,0x805000
  801c30:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c36:	7e 24                	jle    801c5c <nsipc_send+0x3e>
  801c38:	c7 44 24 0c c4 26 80 	movl   $0x8026c4,0xc(%esp)
  801c3f:	00 
  801c40:	c7 44 24 08 d0 26 80 	movl   $0x8026d0,0x8(%esp)
  801c47:	00 
  801c48:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  801c4f:	00 
  801c50:	c7 04 24 e5 26 80 00 	movl   $0x8026e5,(%esp)
  801c57:	e8 8c 01 00 00       	call   801de8 <_panic>
  801c5c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c60:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c63:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c67:	c7 04 24 0c 50 80 00 	movl   $0x80500c,(%esp)
  801c6e:	e8 57 ed ff ff       	call   8009ca <memmove>
  801c73:	89 1d 04 50 80 00    	mov    %ebx,0x805004
  801c79:	8b 45 14             	mov    0x14(%ebp),%eax
  801c7c:	a3 08 50 80 00       	mov    %eax,0x805008
  801c81:	b8 08 00 00 00       	mov    $0x8,%eax
  801c86:	e8 c5 fe ff ff       	call   801b50 <nsipc>
  801c8b:	83 c4 14             	add    $0x14,%esp
  801c8e:	5b                   	pop    %ebx
  801c8f:	5d                   	pop    %ebp
  801c90:	c3                   	ret    

00801c91 <nsipc_recv>:
  801c91:	55                   	push   %ebp
  801c92:	89 e5                	mov    %esp,%ebp
  801c94:	83 ec 18             	sub    $0x18,%esp
  801c97:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  801c9a:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  801c9d:	8b 75 10             	mov    0x10(%ebp),%esi
  801ca0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca3:	a3 00 50 80 00       	mov    %eax,0x805000
  801ca8:	89 35 04 50 80 00    	mov    %esi,0x805004
  801cae:	8b 45 14             	mov    0x14(%ebp),%eax
  801cb1:	a3 08 50 80 00       	mov    %eax,0x805008
  801cb6:	b8 07 00 00 00       	mov    $0x7,%eax
  801cbb:	e8 90 fe ff ff       	call   801b50 <nsipc>
  801cc0:	89 c3                	mov    %eax,%ebx
  801cc2:	85 c0                	test   %eax,%eax
  801cc4:	78 47                	js     801d0d <nsipc_recv+0x7c>
  801cc6:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801ccb:	7f 05                	jg     801cd2 <nsipc_recv+0x41>
  801ccd:	39 c6                	cmp    %eax,%esi
  801ccf:	90                   	nop    
  801cd0:	7d 24                	jge    801cf6 <nsipc_recv+0x65>
  801cd2:	c7 44 24 0c f1 26 80 	movl   $0x8026f1,0xc(%esp)
  801cd9:	00 
  801cda:	c7 44 24 08 d0 26 80 	movl   $0x8026d0,0x8(%esp)
  801ce1:	00 
  801ce2:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  801ce9:	00 
  801cea:	c7 04 24 e5 26 80 00 	movl   $0x8026e5,(%esp)
  801cf1:	e8 f2 00 00 00       	call   801de8 <_panic>
  801cf6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cfa:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801d01:	00 
  801d02:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d05:	89 04 24             	mov    %eax,(%esp)
  801d08:	e8 bd ec ff ff       	call   8009ca <memmove>
  801d0d:	89 d8                	mov    %ebx,%eax
  801d0f:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  801d12:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  801d15:	89 ec                	mov    %ebp,%esp
  801d17:	5d                   	pop    %ebp
  801d18:	c3                   	ret    

00801d19 <nsipc_connect>:
  801d19:	55                   	push   %ebp
  801d1a:	89 e5                	mov    %esp,%ebp
  801d1c:	53                   	push   %ebx
  801d1d:	83 ec 14             	sub    $0x14,%esp
  801d20:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d23:	8b 45 08             	mov    0x8(%ebp),%eax
  801d26:	a3 00 50 80 00       	mov    %eax,0x805000
  801d2b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d32:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d36:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  801d3d:	e8 88 ec ff ff       	call   8009ca <memmove>
  801d42:	89 1d 14 50 80 00    	mov    %ebx,0x805014
  801d48:	b8 05 00 00 00       	mov    $0x5,%eax
  801d4d:	e8 fe fd ff ff       	call   801b50 <nsipc>
  801d52:	83 c4 14             	add    $0x14,%esp
  801d55:	5b                   	pop    %ebx
  801d56:	5d                   	pop    %ebp
  801d57:	c3                   	ret    

00801d58 <nsipc_bind>:
  801d58:	55                   	push   %ebp
  801d59:	89 e5                	mov    %esp,%ebp
  801d5b:	53                   	push   %ebx
  801d5c:	83 ec 14             	sub    $0x14,%esp
  801d5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d62:	8b 45 08             	mov    0x8(%ebp),%eax
  801d65:	a3 00 50 80 00       	mov    %eax,0x805000
  801d6a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d71:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d75:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  801d7c:	e8 49 ec ff ff       	call   8009ca <memmove>
  801d81:	89 1d 14 50 80 00    	mov    %ebx,0x805014
  801d87:	b8 02 00 00 00       	mov    $0x2,%eax
  801d8c:	e8 bf fd ff ff       	call   801b50 <nsipc>
  801d91:	83 c4 14             	add    $0x14,%esp
  801d94:	5b                   	pop    %ebx
  801d95:	5d                   	pop    %ebp
  801d96:	c3                   	ret    

00801d97 <nsipc_accept>:
  801d97:	55                   	push   %ebp
  801d98:	89 e5                	mov    %esp,%ebp
  801d9a:	53                   	push   %ebx
  801d9b:	83 ec 14             	sub    $0x14,%esp
  801d9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801da1:	a3 00 50 80 00       	mov    %eax,0x805000
  801da6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dab:	e8 a0 fd ff ff       	call   801b50 <nsipc>
  801db0:	89 c3                	mov    %eax,%ebx
  801db2:	85 c0                	test   %eax,%eax
  801db4:	78 27                	js     801ddd <nsipc_accept+0x46>
  801db6:	a1 10 50 80 00       	mov    0x805010,%eax
  801dbb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dbf:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801dc6:	00 
  801dc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dca:	89 04 24             	mov    %eax,(%esp)
  801dcd:	e8 f8 eb ff ff       	call   8009ca <memmove>
  801dd2:	8b 15 10 50 80 00    	mov    0x805010,%edx
  801dd8:	8b 45 10             	mov    0x10(%ebp),%eax
  801ddb:	89 10                	mov    %edx,(%eax)
  801ddd:	89 d8                	mov    %ebx,%eax
  801ddf:	83 c4 14             	add    $0x14,%esp
  801de2:	5b                   	pop    %ebx
  801de3:	5d                   	pop    %ebp
  801de4:	c3                   	ret    
  801de5:	00 00                	add    %al,(%eax)
	...

00801de8 <_panic>:
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  801de8:	55                   	push   %ebp
  801de9:	89 e5                	mov    %esp,%ebp
  801deb:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  801dee:	8d 45 14             	lea    0x14(%ebp),%eax
  801df1:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)

	// Print the panic message
	if (argv0)
  801df4:	a1 40 60 80 00       	mov    0x806040,%eax
  801df9:	85 c0                	test   %eax,%eax
  801dfb:	74 10                	je     801e0d <_panic+0x25>
		cprintf("%s: ", argv0);
  801dfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e01:	c7 04 24 06 27 80 00 	movl   $0x802706,(%esp)
  801e08:	e8 2c e3 ff ff       	call   800139 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  801e0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e10:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e14:	8b 45 08             	mov    0x8(%ebp),%eax
  801e17:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e1b:	a1 00 60 80 00       	mov    0x806000,%eax
  801e20:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e24:	c7 04 24 0b 27 80 00 	movl   $0x80270b,(%esp)
  801e2b:	e8 09 e3 ff ff       	call   800139 <cprintf>
	vcprintf(fmt, ap);
  801e30:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  801e33:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e37:	8b 45 10             	mov    0x10(%ebp),%eax
  801e3a:	89 04 24             	mov    %eax,(%esp)
  801e3d:	e8 96 e2 ff ff       	call   8000d8 <vcprintf>
	cprintf("\n");
  801e42:	c7 04 24 69 27 80 00 	movl   $0x802769,(%esp)
  801e49:	e8 eb e2 ff ff       	call   800139 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e4e:	cc                   	int3   
  801e4f:	eb fd                	jmp    801e4e <_panic+0x66>
	...

00801e60 <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e60:	55                   	push   %ebp
  801e61:	89 e5                	mov    %esp,%ebp
  801e63:	57                   	push   %edi
  801e64:	56                   	push   %esi
  801e65:	53                   	push   %ebx
  801e66:	83 ec 1c             	sub    $0x1c,%esp
  801e69:	8b 75 08             	mov    0x8(%ebp),%esi
  801e6c:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  801e6f:	e8 09 f1 ff ff       	call   800f7d <sys_getenvid>
  801e74:	25 ff 03 00 00       	and    $0x3ff,%eax
  801e79:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e7c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e81:	a3 3c 60 80 00       	mov    %eax,0x80603c
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  801e86:	e8 f2 f0 ff ff       	call   800f7d <sys_getenvid>
  801e8b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801e90:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e93:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e98:	a3 3c 60 80 00       	mov    %eax,0x80603c
		if(env->env_id==to_env){
  801e9d:	8b 40 4c             	mov    0x4c(%eax),%eax
  801ea0:	39 f0                	cmp    %esi,%eax
  801ea2:	75 0e                	jne    801eb2 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  801ea4:	c7 04 24 27 27 80 00 	movl   $0x802727,(%esp)
  801eab:	e8 89 e2 ff ff       	call   800139 <cprintf>
  801eb0:	eb 5a                	jmp    801f0c <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  801eb2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801eb6:	8b 45 10             	mov    0x10(%ebp),%eax
  801eb9:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ebd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec4:	89 34 24             	mov    %esi,(%esp)
  801ec7:	e8 10 ee ff ff       	call   800cdc <sys_ipc_try_send>
  801ecc:	89 c3                	mov    %eax,%ebx
  801ece:	85 c0                	test   %eax,%eax
  801ed0:	79 25                	jns    801ef7 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  801ed2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ed5:	74 2b                	je     801f02 <ipc_send+0xa2>
				panic("send error:%e",r);
  801ed7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801edb:	c7 44 24 08 43 27 80 	movl   $0x802743,0x8(%esp)
  801ee2:	00 
  801ee3:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  801eea:	00 
  801eeb:	c7 04 24 51 27 80 00 	movl   $0x802751,(%esp)
  801ef2:	e8 f1 fe ff ff       	call   801de8 <_panic>
		}
			sys_yield();
  801ef7:	e8 4d f0 ff ff       	call   800f49 <sys_yield>
		
	}while(r!=0);
  801efc:	85 db                	test   %ebx,%ebx
  801efe:	75 86                	jne    801e86 <ipc_send+0x26>
  801f00:	eb 0a                	jmp    801f0c <ipc_send+0xac>
  801f02:	e8 42 f0 ff ff       	call   800f49 <sys_yield>
  801f07:	e9 7a ff ff ff       	jmp    801e86 <ipc_send+0x26>
	return;
	//panic("ipc_send not implemented");
}
  801f0c:	83 c4 1c             	add    $0x1c,%esp
  801f0f:	5b                   	pop    %ebx
  801f10:	5e                   	pop    %esi
  801f11:	5f                   	pop    %edi
  801f12:	5d                   	pop    %ebp
  801f13:	c3                   	ret    

00801f14 <ipc_recv>:
  801f14:	55                   	push   %ebp
  801f15:	89 e5                	mov    %esp,%ebp
  801f17:	57                   	push   %edi
  801f18:	56                   	push   %esi
  801f19:	53                   	push   %ebx
  801f1a:	83 ec 0c             	sub    $0xc,%esp
  801f1d:	8b 75 08             	mov    0x8(%ebp),%esi
  801f20:	8b 7d 10             	mov    0x10(%ebp),%edi
  801f23:	e8 55 f0 ff ff       	call   800f7d <sys_getenvid>
  801f28:	25 ff 03 00 00       	and    $0x3ff,%eax
  801f2d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f30:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f35:	a3 3c 60 80 00       	mov    %eax,0x80603c
  801f3a:	85 f6                	test   %esi,%esi
  801f3c:	74 29                	je     801f67 <ipc_recv+0x53>
  801f3e:	8b 40 4c             	mov    0x4c(%eax),%eax
  801f41:	3b 06                	cmp    (%esi),%eax
  801f43:	75 22                	jne    801f67 <ipc_recv+0x53>
  801f45:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801f4b:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801f51:	c7 04 24 27 27 80 00 	movl   $0x802727,(%esp)
  801f58:	e8 dc e1 ff ff       	call   800139 <cprintf>
  801f5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f62:	e9 8a 00 00 00       	jmp    801ff1 <ipc_recv+0xdd>
  801f67:	e8 11 f0 ff ff       	call   800f7d <sys_getenvid>
  801f6c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801f71:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f74:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f79:	a3 3c 60 80 00       	mov    %eax,0x80603c
  801f7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f81:	89 04 24             	mov    %eax,(%esp)
  801f84:	e8 f6 ec ff ff       	call   800c7f <sys_ipc_recv>
  801f89:	89 c3                	mov    %eax,%ebx
  801f8b:	85 c0                	test   %eax,%eax
  801f8d:	79 1a                	jns    801fa9 <ipc_recv+0x95>
  801f8f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801f95:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801f9b:	c7 04 24 5b 27 80 00 	movl   $0x80275b,(%esp)
  801fa2:	e8 92 e1 ff ff       	call   800139 <cprintf>
  801fa7:	eb 48                	jmp    801ff1 <ipc_recv+0xdd>
  801fa9:	e8 cf ef ff ff       	call   800f7d <sys_getenvid>
  801fae:	25 ff 03 00 00       	and    $0x3ff,%eax
  801fb3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fb6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fbb:	a3 3c 60 80 00       	mov    %eax,0x80603c
  801fc0:	85 f6                	test   %esi,%esi
  801fc2:	74 05                	je     801fc9 <ipc_recv+0xb5>
  801fc4:	8b 40 74             	mov    0x74(%eax),%eax
  801fc7:	89 06                	mov    %eax,(%esi)
  801fc9:	85 ff                	test   %edi,%edi
  801fcb:	74 0a                	je     801fd7 <ipc_recv+0xc3>
  801fcd:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801fd2:	8b 40 78             	mov    0x78(%eax),%eax
  801fd5:	89 07                	mov    %eax,(%edi)
  801fd7:	e8 a1 ef ff ff       	call   800f7d <sys_getenvid>
  801fdc:	25 ff 03 00 00       	and    $0x3ff,%eax
  801fe1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fe4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fe9:	a3 3c 60 80 00       	mov    %eax,0x80603c
  801fee:	8b 58 70             	mov    0x70(%eax),%ebx
  801ff1:	89 d8                	mov    %ebx,%eax
  801ff3:	83 c4 0c             	add    $0xc,%esp
  801ff6:	5b                   	pop    %ebx
  801ff7:	5e                   	pop    %esi
  801ff8:	5f                   	pop    %edi
  801ff9:	5d                   	pop    %ebp
  801ffa:	c3                   	ret    
  801ffb:	00 00                	add    %al,(%eax)
  801ffd:	00 00                	add    %al,(%eax)
	...

00802000 <__udivdi3>:
  802000:	55                   	push   %ebp
  802001:	89 e5                	mov    %esp,%ebp
  802003:	57                   	push   %edi
  802004:	56                   	push   %esi
  802005:	83 ec 1c             	sub    $0x1c,%esp
  802008:	8b 45 10             	mov    0x10(%ebp),%eax
  80200b:	8b 55 14             	mov    0x14(%ebp),%edx
  80200e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802011:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  802014:	89 c1                	mov    %eax,%ecx
  802016:	8b 45 08             	mov    0x8(%ebp),%eax
  802019:	85 d2                	test   %edx,%edx
  80201b:	89 d6                	mov    %edx,%esi
  80201d:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
  802020:	75 1e                	jne    802040 <__udivdi3+0x40>
  802022:	39 f9                	cmp    %edi,%ecx
  802024:	0f 86 8d 00 00 00    	jbe    8020b7 <__udivdi3+0xb7>
  80202a:	89 fa                	mov    %edi,%edx
  80202c:	f7 f1                	div    %ecx
  80202e:	89 c1                	mov    %eax,%ecx
  802030:	89 c8                	mov    %ecx,%eax
  802032:	89 f2                	mov    %esi,%edx
  802034:	83 c4 1c             	add    $0x1c,%esp
  802037:	5e                   	pop    %esi
  802038:	5f                   	pop    %edi
  802039:	5d                   	pop    %ebp
  80203a:	c3                   	ret    
  80203b:	90                   	nop    
  80203c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802040:	39 fa                	cmp    %edi,%edx
  802042:	0f 87 98 00 00 00    	ja     8020e0 <__udivdi3+0xe0>
  802048:	0f bd c2             	bsr    %edx,%eax
  80204b:	83 f0 1f             	xor    $0x1f,%eax
  80204e:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  802051:	74 7f                	je     8020d2 <__udivdi3+0xd2>
  802053:	b8 20 00 00 00       	mov    $0x20,%eax
  802058:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  80205b:	2b 45 e4             	sub    0xffffffe4(%ebp),%eax
  80205e:	89 c1                	mov    %eax,%ecx
  802060:	d3 ea                	shr    %cl,%edx
  802062:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802066:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  802069:	89 f0                	mov    %esi,%eax
  80206b:	d3 e0                	shl    %cl,%eax
  80206d:	09 c2                	or     %eax,%edx
  80206f:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802072:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  802075:	89 fa                	mov    %edi,%edx
  802077:	d3 e0                	shl    %cl,%eax
  802079:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  80207d:	89 45 f4             	mov    %eax,0xfffffff4(%ebp)
  802080:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802083:	d3 e8                	shr    %cl,%eax
  802085:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802089:	d3 e2                	shl    %cl,%edx
  80208b:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  80208f:	09 d0                	or     %edx,%eax
  802091:	d3 ef                	shr    %cl,%edi
  802093:	89 fa                	mov    %edi,%edx
  802095:	f7 75 e0             	divl   0xffffffe0(%ebp)
  802098:	89 d1                	mov    %edx,%ecx
  80209a:	89 c7                	mov    %eax,%edi
  80209c:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80209f:	f7 e7                	mul    %edi
  8020a1:	39 d1                	cmp    %edx,%ecx
  8020a3:	89 c6                	mov    %eax,%esi
  8020a5:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  8020a8:	72 6f                	jb     802119 <__udivdi3+0x119>
  8020aa:	39 ca                	cmp    %ecx,%edx
  8020ac:	74 5e                	je     80210c <__udivdi3+0x10c>
  8020ae:	89 f9                	mov    %edi,%ecx
  8020b0:	31 f6                	xor    %esi,%esi
  8020b2:	e9 79 ff ff ff       	jmp    802030 <__udivdi3+0x30>
  8020b7:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8020ba:	85 c0                	test   %eax,%eax
  8020bc:	74 32                	je     8020f0 <__udivdi3+0xf0>
  8020be:	89 f2                	mov    %esi,%edx
  8020c0:	89 f8                	mov    %edi,%eax
  8020c2:	f7 f1                	div    %ecx
  8020c4:	89 c6                	mov    %eax,%esi
  8020c6:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8020c9:	f7 f1                	div    %ecx
  8020cb:	89 c1                	mov    %eax,%ecx
  8020cd:	e9 5e ff ff ff       	jmp    802030 <__udivdi3+0x30>
  8020d2:	39 d7                	cmp    %edx,%edi
  8020d4:	77 2a                	ja     802100 <__udivdi3+0x100>
  8020d6:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  8020d9:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
  8020dc:	73 22                	jae    802100 <__udivdi3+0x100>
  8020de:	66 90                	xchg   %ax,%ax
  8020e0:	31 c9                	xor    %ecx,%ecx
  8020e2:	31 f6                	xor    %esi,%esi
  8020e4:	e9 47 ff ff ff       	jmp    802030 <__udivdi3+0x30>
  8020e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  8020f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8020f5:	31 d2                	xor    %edx,%edx
  8020f7:	f7 75 f0             	divl   0xfffffff0(%ebp)
  8020fa:	89 c1                	mov    %eax,%ecx
  8020fc:	eb c0                	jmp    8020be <__udivdi3+0xbe>
  8020fe:	66 90                	xchg   %ax,%ax
  802100:	b9 01 00 00 00       	mov    $0x1,%ecx
  802105:	31 f6                	xor    %esi,%esi
  802107:	e9 24 ff ff ff       	jmp    802030 <__udivdi3+0x30>
  80210c:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  80210f:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802113:	d3 e0                	shl    %cl,%eax
  802115:	39 c6                	cmp    %eax,%esi
  802117:	76 95                	jbe    8020ae <__udivdi3+0xae>
  802119:	8d 4f ff             	lea    0xffffffff(%edi),%ecx
  80211c:	31 f6                	xor    %esi,%esi
  80211e:	e9 0d ff ff ff       	jmp    802030 <__udivdi3+0x30>
	...

00802130 <__umoddi3>:
  802130:	55                   	push   %ebp
  802131:	89 e5                	mov    %esp,%ebp
  802133:	57                   	push   %edi
  802134:	56                   	push   %esi
  802135:	83 ec 30             	sub    $0x30,%esp
  802138:	8b 55 14             	mov    0x14(%ebp),%edx
  80213b:	8b 45 10             	mov    0x10(%ebp),%eax
  80213e:	8b 75 08             	mov    0x8(%ebp),%esi
  802141:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802144:	85 d2                	test   %edx,%edx
  802146:	c7 45 d0 00 00 00 00 	movl   $0x0,0xffffffd0(%ebp)
  80214d:	89 c1                	mov    %eax,%ecx
  80214f:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  802156:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  802159:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  80215c:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  80215f:	89 7d e0             	mov    %edi,0xffffffe0(%ebp)
  802162:	75 1c                	jne    802180 <__umoddi3+0x50>
  802164:	39 f8                	cmp    %edi,%eax
  802166:	89 fa                	mov    %edi,%edx
  802168:	0f 86 d4 00 00 00    	jbe    802242 <__umoddi3+0x112>
  80216e:	89 f0                	mov    %esi,%eax
  802170:	f7 f1                	div    %ecx
  802172:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802175:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  80217c:	eb 12                	jmp    802190 <__umoddi3+0x60>
  80217e:	66 90                	xchg   %ax,%ax
  802180:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802183:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  802186:	76 18                	jbe    8021a0 <__umoddi3+0x70>
  802188:	89 75 d0             	mov    %esi,0xffffffd0(%ebp)
  80218b:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  80218e:	66 90                	xchg   %ax,%ax
  802190:	8b 45 d0             	mov    0xffffffd0(%ebp),%eax
  802193:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  802196:	83 c4 30             	add    $0x30,%esp
  802199:	5e                   	pop    %esi
  80219a:	5f                   	pop    %edi
  80219b:	5d                   	pop    %ebp
  80219c:	c3                   	ret    
  80219d:	8d 76 00             	lea    0x0(%esi),%esi
  8021a0:	0f bd 45 e8          	bsr    0xffffffe8(%ebp),%eax
  8021a4:	83 f0 1f             	xor    $0x1f,%eax
  8021a7:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  8021aa:	0f 84 c0 00 00 00    	je     802270 <__umoddi3+0x140>
  8021b0:	b8 20 00 00 00       	mov    $0x20,%eax
  8021b5:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  8021b8:	2b 45 dc             	sub    0xffffffdc(%ebp),%eax
  8021bb:	8b 7d ec             	mov    0xffffffec(%ebp),%edi
  8021be:	8b 75 f0             	mov    0xfffffff0(%ebp),%esi
  8021c1:	89 c1                	mov    %eax,%ecx
  8021c3:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8021c6:	d3 ea                	shr    %cl,%edx
  8021c8:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8021cb:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  8021cf:	d3 e0                	shl    %cl,%eax
  8021d1:	09 c2                	or     %eax,%edx
  8021d3:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8021d6:	d3 e7                	shl    %cl,%edi
  8021d8:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8021dc:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  8021df:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  8021e2:	d3 e8                	shr    %cl,%eax
  8021e4:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  8021e8:	d3 e2                	shl    %cl,%edx
  8021ea:	09 d0                	or     %edx,%eax
  8021ec:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  8021ef:	d3 e6                	shl    %cl,%esi
  8021f1:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8021f5:	d3 ea                	shr    %cl,%edx
  8021f7:	f7 75 f4             	divl   0xfffffff4(%ebp)
  8021fa:	89 55 cc             	mov    %edx,0xffffffcc(%ebp)
  8021fd:	f7 e7                	mul    %edi
  8021ff:	39 55 cc             	cmp    %edx,0xffffffcc(%ebp)
  802202:	0f 82 a5 00 00 00    	jb     8022ad <__umoddi3+0x17d>
  802208:	3b 55 cc             	cmp    0xffffffcc(%ebp),%edx
  80220b:	0f 84 94 00 00 00    	je     8022a5 <__umoddi3+0x175>
  802211:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
  802214:	29 c6                	sub    %eax,%esi
  802216:	19 d1                	sbb    %edx,%ecx
  802218:	89 4d cc             	mov    %ecx,0xffffffcc(%ebp)
  80221b:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  80221f:	89 f2                	mov    %esi,%edx
  802221:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  802224:	d3 ea                	shr    %cl,%edx
  802226:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  80222a:	d3 e0                	shl    %cl,%eax
  80222c:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  802230:	09 c2                	or     %eax,%edx
  802232:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  802235:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802238:	d3 e8                	shr    %cl,%eax
  80223a:	89 45 d4             	mov    %eax,0xffffffd4(%ebp)
  80223d:	e9 4e ff ff ff       	jmp    802190 <__umoddi3+0x60>
  802242:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  802245:	85 c0                	test   %eax,%eax
  802247:	74 17                	je     802260 <__umoddi3+0x130>
  802249:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  80224c:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
  80224f:	f7 f1                	div    %ecx
  802251:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802254:	f7 f1                	div    %ecx
  802256:	e9 17 ff ff ff       	jmp    802172 <__umoddi3+0x42>
  80225b:	90                   	nop    
  80225c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802260:	b8 01 00 00 00       	mov    $0x1,%eax
  802265:	31 d2                	xor    %edx,%edx
  802267:	f7 75 ec             	divl   0xffffffec(%ebp)
  80226a:	89 c1                	mov    %eax,%ecx
  80226c:	eb db                	jmp    802249 <__umoddi3+0x119>
  80226e:	66 90                	xchg   %ax,%ax
  802270:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802273:	39 45 e0             	cmp    %eax,0xffffffe0(%ebp)
  802276:	77 19                	ja     802291 <__umoddi3+0x161>
  802278:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  80227b:	39 55 f0             	cmp    %edx,0xfffffff0(%ebp)
  80227e:	73 11                	jae    802291 <__umoddi3+0x161>
  802280:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  802283:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802286:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802289:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  80228c:	e9 ff fe ff ff       	jmp    802190 <__umoddi3+0x60>
  802291:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802294:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802297:	2b 45 ec             	sub    0xffffffec(%ebp),%eax
  80229a:	1b 4d e8             	sbb    0xffffffe8(%ebp),%ecx
  80229d:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  8022a0:	89 4d e0             	mov    %ecx,0xffffffe0(%ebp)
  8022a3:	eb db                	jmp    802280 <__umoddi3+0x150>
  8022a5:	39 f0                	cmp    %esi,%eax
  8022a7:	0f 86 64 ff ff ff    	jbe    802211 <__umoddi3+0xe1>
  8022ad:	29 f8                	sub    %edi,%eax
  8022af:	1b 55 f4             	sbb    0xfffffff4(%ebp),%edx
  8022b2:	e9 5a ff ff ff       	jmp    802211 <__umoddi3+0xe1>
