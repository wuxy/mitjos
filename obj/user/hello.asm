
obj/user/hello:     file format elf32-i386

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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 08             	sub    $0x8,%esp
	cprintf("hello, world\n");
  80003a:	c7 04 24 80 1d 80 00 	movl   $0x801d80,(%esp)
  800041:	e8 f3 00 00 00       	call   800139 <cprintf>
	cprintf("i am environment %08x\n", env->env_id);
  800046:	a1 20 50 80 00       	mov    0x805020,%eax
  80004b:	8b 40 4c             	mov    0x4c(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 8e 1d 80 00 	movl   $0x801d8e,(%esp)
  800059:	e8 db 00 00 00       	call   800139 <cprintf>
}
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	83 ec 18             	sub    $0x18,%esp
  800066:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800069:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80006c:	8b 75 08             	mov    0x8(%ebp),%esi
  80006f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  800072:	c7 05 20 50 80 00 00 	movl   $0x0,0x805020
  800079:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  80007c:	e8 b8 0e 00 00       	call   800f39 <sys_getenvid>
  800081:	25 ff 03 00 00       	and    $0x3ff,%eax
  800086:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800089:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008e:	a3 20 50 80 00       	mov    %eax,0x805020
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800093:	85 f6                	test   %esi,%esi
  800095:	7e 07                	jle    80009e <libmain+0x3e>
		binaryname = argv[0];
  800097:	8b 03                	mov    (%ebx),%eax
  800099:	a3 00 50 80 00       	mov    %eax,0x805000

	// call user main routine
	umain(argc, argv);
  80009e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a2:	89 34 24             	mov    %esi,(%esp)
  8000a5:	e8 8a ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000aa:	e8 0d 00 00 00       	call   8000bc <exit>
}
  8000af:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000b2:	8b 75 fc             	mov    -0x4(%ebp),%esi
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
  8000c2:	e8 f9 14 00 00       	call   8015c0 <close_all>
	sys_env_destroy(0);
  8000c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ce:	e8 9a 0e 00 00       	call   800f6d <sys_env_destroy>
}
  8000d3:	c9                   	leave  
  8000d4:	c3                   	ret    
  8000d5:	00 00                	add    %al,(%eax)
	...

008000d8 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000e1:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  8000e8:	00 00 00 
	b.cnt = 0;
  8000eb:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  8000f2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8000ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800103:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800109:	89 44 24 04          	mov    %eax,0x4(%esp)
  80010d:	c7 04 24 56 01 80 00 	movl   $0x800156,(%esp)
  800114:	e8 cc 01 00 00       	call   8002e5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800119:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
  80011f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800123:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  800129:	89 04 24             	mov    %eax,(%esp)
  80012c:	e8 d7 0a 00 00       	call   800c08 <sys_cputs>
  800131:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

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
  800142:	89 45 fc             	mov    %eax,-0x4(%ebp)
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
};


static void
putch(int ch, struct printbuf *b)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	53                   	push   %ebx
  80015a:	83 ec 14             	sub    $0x14,%esp
  80015d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800160:	8b 03                	mov    (%ebx),%eax
  800162:	8b 55 08             	mov    0x8(%ebp),%edx
  800165:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800169:	83 c0 01             	add    $0x1,%eax
  80016c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80016e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800173:	75 19                	jne    80018e <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800175:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80017c:	00 
  80017d:	8d 43 08             	lea    0x8(%ebx),%eax
  800180:	89 04 24             	mov    %eax,(%esp)
  800183:	e8 80 0a 00 00       	call   800c08 <sys_cputs>
		b->idx = 0;
  800188:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80018e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800192:	83 c4 14             	add    $0x14,%esp
  800195:	5b                   	pop    %ebx
  800196:	5d                   	pop    %ebp
  800197:	c3                   	ret    
	...

008001a0 <printnum>:
 * using specified putch function and associated pointer putdat.
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
  8001a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001ac:	89 d7                	mov    %edx,%edi
  8001ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8001ba:	8b 55 10             	mov    0x10(%ebp),%edx
  8001bd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c0:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8001c3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  8001ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001cd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  8001d0:	72 14                	jb     8001e6 <printnum+0x46>
  8001d2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8001d5:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  8001d8:	76 0c                	jbe    8001e6 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001da:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001dd:	83 eb 01             	sub    $0x1,%ebx
  8001e0:	85 db                	test   %ebx,%ebx
  8001e2:	7f 57                	jg     80023b <printnum+0x9b>
  8001e4:	eb 64                	jmp    80024a <printnum+0xaa>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e6:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8001ed:	83 e8 01             	sub    $0x1,%eax
  8001f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001f4:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001f8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001fc:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800200:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800203:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800206:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80020e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800211:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800214:	89 04 24             	mov    %eax,(%esp)
  800217:	89 54 24 04          	mov    %edx,0x4(%esp)
  80021b:	e8 c0 18 00 00       	call   801ae0 <__udivdi3>
  800220:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800224:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800228:	89 04 24             	mov    %eax,(%esp)
  80022b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80022f:	89 fa                	mov    %edi,%edx
  800231:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800234:	e8 67 ff ff ff       	call   8001a0 <printnum>
  800239:	eb 0f                	jmp    80024a <printnum+0xaa>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80023b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80023f:	89 34 24             	mov    %esi,(%esp)
  800242:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800245:	83 eb 01             	sub    $0x1,%ebx
  800248:	75 f1                	jne    80023b <printnum+0x9b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80024a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80024e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800252:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800255:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800258:	89 44 24 08          	mov    %eax,0x8(%esp)
  80025c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800260:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800263:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800266:	89 04 24             	mov    %eax,(%esp)
  800269:	89 54 24 04          	mov    %edx,0x4(%esp)
  80026d:	e8 9e 19 00 00       	call   801c10 <__umoddi3>
  800272:	89 74 24 04          	mov    %esi,0x4(%esp)
  800276:	0f be 80 bc 1d 80 00 	movsbl 0x801dbc(%eax),%eax
  80027d:	89 04 24             	mov    %eax,(%esp)
  800280:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800283:	83 c4 3c             	add    $0x3c,%esp
  800286:	5b                   	pop    %ebx
  800287:	5e                   	pop    %esi
  800288:	5f                   	pop    %edi
  800289:	5d                   	pop    %ebp
  80028a:	c3                   	ret    

0080028b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800290:	83 fa 01             	cmp    $0x1,%edx
  800293:	7e 0e                	jle    8002a3 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  800295:	8b 10                	mov    (%eax),%edx
  800297:	8d 42 08             	lea    0x8(%edx),%eax
  80029a:	89 01                	mov    %eax,(%ecx)
  80029c:	8b 02                	mov    (%edx),%eax
  80029e:	8b 52 04             	mov    0x4(%edx),%edx
  8002a1:	eb 22                	jmp    8002c5 <getuint+0x3a>
	else if (lflag)
  8002a3:	85 d2                	test   %edx,%edx
  8002a5:	74 10                	je     8002b7 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8002a7:	8b 10                	mov    (%eax),%edx
  8002a9:	8d 42 04             	lea    0x4(%edx),%eax
  8002ac:	89 01                	mov    %eax,(%ecx)
  8002ae:	8b 02                	mov    (%edx),%eax
  8002b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b5:	eb 0e                	jmp    8002c5 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  8002b7:	8b 10                	mov    (%eax),%edx
  8002b9:	8d 42 04             	lea    0x4(%edx),%eax
  8002bc:	89 01                	mov    %eax,(%ecx)
  8002be:	8b 02                	mov    (%edx),%eax
  8002c0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002c5:	5d                   	pop    %ebp
  8002c6:	c3                   	ret    

008002c7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c7:	55                   	push   %ebp
  8002c8:	89 e5                	mov    %esp,%ebp
  8002ca:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  8002cd:	83 42 08 01          	addl   $0x1,0x8(%edx)
	if (b->buf < b->ebuf)
  8002d1:	8b 02                	mov    (%edx),%eax
  8002d3:	3b 42 04             	cmp    0x4(%edx),%eax
  8002d6:	73 0b                	jae    8002e3 <sprintputch+0x1c>
		*b->buf++ = ch;
  8002d8:	0f b6 4d 08          	movzbl 0x8(%ebp),%ecx
  8002dc:	88 08                	mov    %cl,(%eax)
  8002de:	83 c0 01             	add    $0x1,%eax
  8002e1:	89 02                	mov    %eax,(%edx)
}
  8002e3:	5d                   	pop    %ebp
  8002e4:	c3                   	ret    

008002e5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
  8002e8:	57                   	push   %edi
  8002e9:	56                   	push   %esi
  8002ea:	53                   	push   %ebx
  8002eb:	83 ec 3c             	sub    $0x3c,%esp
  8002ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002f1:	eb 18                	jmp    80030b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f3:	84 c0                	test   %al,%al
  8002f5:	0f 84 9f 03 00 00    	je     80069a <vprintfmt+0x3b5>
				return;
			putch(ch, putdat);
  8002fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  800302:	0f b6 c0             	movzbl %al,%eax
  800305:	89 04 24             	mov    %eax,(%esp)
  800308:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80030b:	0f b6 03             	movzbl (%ebx),%eax
  80030e:	83 c3 01             	add    $0x1,%ebx
  800311:	3c 25                	cmp    $0x25,%al
  800313:	75 de                	jne    8002f3 <vprintfmt+0xe>
  800315:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031a:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
  800321:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800326:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80032d:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
  800331:	eb 07                	jmp    80033a <vprintfmt+0x55>
  800333:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	0f b6 13             	movzbl (%ebx),%edx
  80033d:	83 c3 01             	add    $0x1,%ebx
  800340:	8d 42 dd             	lea    -0x23(%edx),%eax
  800343:	3c 55                	cmp    $0x55,%al
  800345:	0f 87 22 03 00 00    	ja     80066d <vprintfmt+0x388>
  80034b:	0f b6 c0             	movzbl %al,%eax
  80034e:	ff 24 85 00 1f 80 00 	jmp    *0x801f00(,%eax,4)
  800355:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
  800359:	eb df                	jmp    80033a <vprintfmt+0x55>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80035b:	0f b6 c2             	movzbl %dl,%eax
  80035e:	8d 78 d0             	lea    -0x30(%eax),%edi
				ch = *fmt;
  800361:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800364:	8d 42 d0             	lea    -0x30(%edx),%eax
  800367:	83 f8 09             	cmp    $0x9,%eax
  80036a:	76 08                	jbe    800374 <vprintfmt+0x8f>
  80036c:	eb 39                	jmp    8003a7 <vprintfmt+0xc2>
  80036e:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
  800372:	eb c6                	jmp    80033a <vprintfmt+0x55>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800374:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800377:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  80037a:	8d 7c 42 d0          	lea    -0x30(%edx,%eax,2),%edi
				ch = *fmt;
  80037e:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800381:	8d 42 d0             	lea    -0x30(%edx),%eax
  800384:	83 f8 09             	cmp    $0x9,%eax
  800387:	77 1e                	ja     8003a7 <vprintfmt+0xc2>
  800389:	eb e9                	jmp    800374 <vprintfmt+0x8f>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80038b:	8b 55 14             	mov    0x14(%ebp),%edx
  80038e:	8d 42 04             	lea    0x4(%edx),%eax
  800391:	89 45 14             	mov    %eax,0x14(%ebp)
  800394:	8b 3a                	mov    (%edx),%edi
  800396:	eb 0f                	jmp    8003a7 <vprintfmt+0xc2>
			goto process_precision;

		case '.':
			if (width < 0)
  800398:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80039c:	79 9c                	jns    80033a <vprintfmt+0x55>
  80039e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8003a5:	eb 93                	jmp    80033a <vprintfmt+0x55>
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8003ab:	90                   	nop    
  8003ac:	8d 74 26 00          	lea    0x0(%esi),%esi
  8003b0:	79 88                	jns    80033a <vprintfmt+0x55>
  8003b2:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8003b5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003ba:	e9 7b ff ff ff       	jmp    80033a <vprintfmt+0x55>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003bf:	83 c1 01             	add    $0x1,%ecx
  8003c2:	e9 73 ff ff ff       	jmp    80033a <vprintfmt+0x55>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ca:	8d 50 04             	lea    0x4(%eax),%edx
  8003cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003d7:	8b 00                	mov    (%eax),%eax
  8003d9:	89 04 24             	mov    %eax,(%esp)
  8003dc:	ff 55 08             	call   *0x8(%ebp)
  8003df:	e9 27 ff ff ff       	jmp    80030b <vprintfmt+0x26>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e4:	8b 55 14             	mov    0x14(%ebp),%edx
  8003e7:	8d 42 04             	lea    0x4(%edx),%eax
  8003ea:	89 45 14             	mov    %eax,0x14(%ebp)
  8003ed:	8b 02                	mov    (%edx),%eax
  8003ef:	89 c2                	mov    %eax,%edx
  8003f1:	c1 fa 1f             	sar    $0x1f,%edx
  8003f4:	31 d0                	xor    %edx,%eax
  8003f6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8003f8:	83 f8 0f             	cmp    $0xf,%eax
  8003fb:	7f 0b                	jg     800408 <vprintfmt+0x123>
  8003fd:	8b 14 85 60 20 80 00 	mov    0x802060(,%eax,4),%edx
  800404:	85 d2                	test   %edx,%edx
  800406:	75 23                	jne    80042b <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800408:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80040c:	c7 44 24 08 cd 1d 80 	movl   $0x801dcd,0x8(%esp)
  800413:	00 
  800414:	8b 45 0c             	mov    0xc(%ebp),%eax
  800417:	89 44 24 04          	mov    %eax,0x4(%esp)
  80041b:	8b 55 08             	mov    0x8(%ebp),%edx
  80041e:	89 14 24             	mov    %edx,(%esp)
  800421:	e8 ff 02 00 00       	call   800725 <printfmt>
  800426:	e9 e0 fe ff ff       	jmp    80030b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80042b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80042f:	c7 44 24 08 d6 1d 80 	movl   $0x801dd6,0x8(%esp)
  800436:	00 
  800437:	8b 45 0c             	mov    0xc(%ebp),%eax
  80043a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80043e:	8b 55 08             	mov    0x8(%ebp),%edx
  800441:	89 14 24             	mov    %edx,(%esp)
  800444:	e8 dc 02 00 00       	call   800725 <printfmt>
  800449:	e9 bd fe ff ff       	jmp    80030b <vprintfmt+0x26>
  80044e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800451:	89 f9                	mov    %edi,%ecx
  800453:	89 5d ec             	mov    %ebx,-0x14(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800456:	8b 55 14             	mov    0x14(%ebp),%edx
  800459:	8d 42 04             	lea    0x4(%edx),%eax
  80045c:	89 45 14             	mov    %eax,0x14(%ebp)
  80045f:	8b 12                	mov    (%edx),%edx
  800461:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800464:	85 d2                	test   %edx,%edx
  800466:	75 07                	jne    80046f <vprintfmt+0x18a>
  800468:	c7 45 dc d9 1d 80 00 	movl   $0x801dd9,-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80046f:	85 f6                	test   %esi,%esi
  800471:	7e 41                	jle    8004b4 <vprintfmt+0x1cf>
  800473:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  800477:	74 3b                	je     8004b4 <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
  800479:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80047d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800480:	89 04 24             	mov    %eax,(%esp)
  800483:	e8 e8 02 00 00       	call   800770 <strnlen>
  800488:	29 c6                	sub    %eax,%esi
  80048a:	89 75 f0             	mov    %esi,-0x10(%ebp)
  80048d:	85 f6                	test   %esi,%esi
  80048f:	7e 23                	jle    8004b4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800491:	0f be 55 eb          	movsbl -0x15(%ebp),%edx
  800495:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800498:	8b 45 0c             	mov    0xc(%ebp),%eax
  80049b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004a2:	89 14 24             	mov    %edx,(%esp)
  8004a5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a8:	83 ee 01             	sub    $0x1,%esi
  8004ab:	75 eb                	jne    800498 <vprintfmt+0x1b3>
  8004ad:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004b4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8004b7:	0f b6 02             	movzbl (%edx),%eax
  8004ba:	0f be d0             	movsbl %al,%edx
  8004bd:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004c0:	84 c0                	test   %al,%al
  8004c2:	75 42                	jne    800506 <vprintfmt+0x221>
  8004c4:	eb 49                	jmp    80050f <vprintfmt+0x22a>
				if (altflag && (ch < ' ' || ch > '~'))
  8004c6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ca:	74 1b                	je     8004e7 <vprintfmt+0x202>
  8004cc:	8d 42 e0             	lea    -0x20(%edx),%eax
  8004cf:	83 f8 5e             	cmp    $0x5e,%eax
  8004d2:	76 13                	jbe    8004e7 <vprintfmt+0x202>
					putch('?', putdat);
  8004d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004db:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004e2:	ff 55 08             	call   *0x8(%ebp)
  8004e5:	eb 0d                	jmp    8004f4 <vprintfmt+0x20f>
				else
					putch(ch, putdat);
  8004e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ee:	89 14 24             	mov    %edx,(%esp)
  8004f1:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f4:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  8004f8:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8004fc:	83 c6 01             	add    $0x1,%esi
  8004ff:	84 c0                	test   %al,%al
  800501:	74 0c                	je     80050f <vprintfmt+0x22a>
  800503:	0f be d0             	movsbl %al,%edx
  800506:	85 ff                	test   %edi,%edi
  800508:	78 bc                	js     8004c6 <vprintfmt+0x1e1>
  80050a:	83 ef 01             	sub    $0x1,%edi
  80050d:	79 b7                	jns    8004c6 <vprintfmt+0x1e1>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80050f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800513:	0f 8e f2 fd ff ff    	jle    80030b <vprintfmt+0x26>
				putch(' ', putdat);
  800519:	8b 55 0c             	mov    0xc(%ebp),%edx
  80051c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800520:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800527:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80052a:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  80052e:	75 e9                	jne    800519 <vprintfmt+0x234>
  800530:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  800533:	e9 d3 fd ff ff       	jmp    80030b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800538:	83 f9 01             	cmp    $0x1,%ecx
  80053b:	90                   	nop    
  80053c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800540:	7e 10                	jle    800552 <vprintfmt+0x26d>
		return va_arg(*ap, long long);
  800542:	8b 55 14             	mov    0x14(%ebp),%edx
  800545:	8d 42 08             	lea    0x8(%edx),%eax
  800548:	89 45 14             	mov    %eax,0x14(%ebp)
  80054b:	8b 32                	mov    (%edx),%esi
  80054d:	8b 7a 04             	mov    0x4(%edx),%edi
  800550:	eb 2a                	jmp    80057c <vprintfmt+0x297>
	else if (lflag)
  800552:	85 c9                	test   %ecx,%ecx
  800554:	74 14                	je     80056a <vprintfmt+0x285>
		return va_arg(*ap, long);
  800556:	8b 45 14             	mov    0x14(%ebp),%eax
  800559:	8d 50 04             	lea    0x4(%eax),%edx
  80055c:	89 55 14             	mov    %edx,0x14(%ebp)
  80055f:	8b 00                	mov    (%eax),%eax
  800561:	89 c6                	mov    %eax,%esi
  800563:	89 c7                	mov    %eax,%edi
  800565:	c1 ff 1f             	sar    $0x1f,%edi
  800568:	eb 12                	jmp    80057c <vprintfmt+0x297>
	else
		return va_arg(*ap, int);
  80056a:	8b 45 14             	mov    0x14(%ebp),%eax
  80056d:	8d 50 04             	lea    0x4(%eax),%edx
  800570:	89 55 14             	mov    %edx,0x14(%ebp)
  800573:	8b 00                	mov    (%eax),%eax
  800575:	89 c6                	mov    %eax,%esi
  800577:	89 c7                	mov    %eax,%edi
  800579:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80057c:	89 f2                	mov    %esi,%edx
  80057e:	89 f9                	mov    %edi,%ecx
  800580:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
			if ((long long) num < 0) {
  800587:	85 ff                	test   %edi,%edi
  800589:	0f 89 9b 00 00 00    	jns    80062a <vprintfmt+0x345>
				putch('-', putdat);
  80058f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800592:	89 44 24 04          	mov    %eax,0x4(%esp)
  800596:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80059d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005a0:	89 f2                	mov    %esi,%edx
  8005a2:	89 f9                	mov    %edi,%ecx
  8005a4:	f7 da                	neg    %edx
  8005a6:	83 d1 00             	adc    $0x0,%ecx
  8005a9:	f7 d9                	neg    %ecx
  8005ab:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  8005b2:	eb 76                	jmp    80062a <vprintfmt+0x345>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005b4:	89 ca                	mov    %ecx,%edx
  8005b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b9:	e8 cd fc ff ff       	call   80028b <getuint>
  8005be:	89 d1                	mov    %edx,%ecx
  8005c0:	89 c2                	mov    %eax,%edx
  8005c2:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  8005c9:	eb 5f                	jmp    80062a <vprintfmt+0x345>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap,lflag);
  8005cb:	89 ca                	mov    %ecx,%edx
  8005cd:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d0:	e8 b6 fc ff ff       	call   80028b <getuint>
  8005d5:	e9 31 fd ff ff       	jmp    80030b <vprintfmt+0x26>
			base=8;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005dd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005e1:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005e8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f2:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005f9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8005fc:	8b 55 14             	mov    0x14(%ebp),%edx
  8005ff:	8d 42 04             	lea    0x4(%edx),%eax
  800602:	89 45 14             	mov    %eax,0x14(%ebp)
  800605:	8b 12                	mov    (%edx),%edx
  800607:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060c:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  800613:	eb 15                	jmp    80062a <vprintfmt+0x345>
			base = 16;
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800615:	89 ca                	mov    %ecx,%edx
  800617:	8d 45 14             	lea    0x14(%ebp),%eax
  80061a:	e8 6c fc ff ff       	call   80028b <getuint>
  80061f:	89 d1                	mov    %edx,%ecx
  800621:	89 c2                	mov    %eax,%edx
  800623:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80062a:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  80062e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800632:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800635:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800639:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80063c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800640:	89 14 24             	mov    %edx,(%esp)
  800643:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800647:	8b 55 0c             	mov    0xc(%ebp),%edx
  80064a:	8b 45 08             	mov    0x8(%ebp),%eax
  80064d:	e8 4e fb ff ff       	call   8001a0 <printnum>
  800652:	e9 b4 fc ff ff       	jmp    80030b <vprintfmt+0x26>
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800657:	8b 55 0c             	mov    0xc(%ebp),%edx
  80065a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80065e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800665:	ff 55 08             	call   *0x8(%ebp)
  800668:	e9 9e fc ff ff       	jmp    80030b <vprintfmt+0x26>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80066d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800670:	89 44 24 04          	mov    %eax,0x4(%esp)
  800674:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80067b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80067e:	83 eb 01             	sub    $0x1,%ebx
  800681:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800685:	0f 84 80 fc ff ff    	je     80030b <vprintfmt+0x26>
  80068b:	83 eb 01             	sub    $0x1,%ebx
  80068e:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800692:	0f 84 73 fc ff ff    	je     80030b <vprintfmt+0x26>
  800698:	eb f1                	jmp    80068b <vprintfmt+0x3a6>
				/* do nothing */;
			break;
		}
	}
}
  80069a:	83 c4 3c             	add    $0x3c,%esp
  80069d:	5b                   	pop    %ebx
  80069e:	5e                   	pop    %esi
  80069f:	5f                   	pop    %edi
  8006a0:	5d                   	pop    %ebp
  8006a1:	c3                   	ret    

008006a2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006a2:	55                   	push   %ebp
  8006a3:	89 e5                	mov    %esp,%ebp
  8006a5:	83 ec 28             	sub    $0x28,%esp
  8006a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8006ab:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8006ae:	85 d2                	test   %edx,%edx
  8006b0:	74 04                	je     8006b6 <vsnprintf+0x14>
  8006b2:	85 c0                	test   %eax,%eax
  8006b4:	7f 07                	jg     8006bd <vsnprintf+0x1b>
  8006b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006bb:	eb 3b                	jmp    8006f8 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006bd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8006c4:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
  8006c8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  8006cb:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8006d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e3:	c7 04 24 c7 02 80 00 	movl   $0x8002c7,(%esp)
  8006ea:	e8 f6 fb ff ff       	call   8002e5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8006f8:	c9                   	leave  
  8006f9:	c3                   	ret    

008006fa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006fa:	55                   	push   %ebp
  8006fb:	89 e5                	mov    %esp,%ebp
  8006fd:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800700:	8d 45 14             	lea    0x14(%ebp),%eax
  800703:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800706:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80070a:	8b 45 10             	mov    0x10(%ebp),%eax
  80070d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800711:	8b 45 0c             	mov    0xc(%ebp),%eax
  800714:	89 44 24 04          	mov    %eax,0x4(%esp)
  800718:	8b 45 08             	mov    0x8(%ebp),%eax
  80071b:	89 04 24             	mov    %eax,(%esp)
  80071e:	e8 7f ff ff ff       	call   8006a2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800723:	c9                   	leave  
  800724:	c3                   	ret    

00800725 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800725:	55                   	push   %ebp
  800726:	89 e5                	mov    %esp,%ebp
  800728:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  80072b:	8d 45 14             	lea    0x14(%ebp),%eax
  80072e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800731:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800735:	8b 45 10             	mov    0x10(%ebp),%eax
  800738:	89 44 24 08          	mov    %eax,0x8(%esp)
  80073c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80073f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800743:	8b 45 08             	mov    0x8(%ebp),%eax
  800746:	89 04 24             	mov    %eax,(%esp)
  800749:	e8 97 fb ff ff       	call   8002e5 <vprintfmt>
	va_end(ap);
}
  80074e:	c9                   	leave  
  80074f:	c3                   	ret    

00800750 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800756:	b8 00 00 00 00       	mov    $0x0,%eax
  80075b:	80 3a 00             	cmpb   $0x0,(%edx)
  80075e:	74 0e                	je     80076e <strlen+0x1e>
  800760:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800765:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800768:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  80076c:	75 f7                	jne    800765 <strlen+0x15>
		n++;
	return n;
}
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800776:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800779:	85 d2                	test   %edx,%edx
  80077b:	74 19                	je     800796 <strnlen+0x26>
  80077d:	80 39 00             	cmpb   $0x0,(%ecx)
  800780:	74 14                	je     800796 <strnlen+0x26>
  800782:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800787:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078a:	39 d0                	cmp    %edx,%eax
  80078c:	74 0d                	je     80079b <strnlen+0x2b>
  80078e:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800792:	74 07                	je     80079b <strnlen+0x2b>
  800794:	eb f1                	jmp    800787 <strnlen+0x17>
  800796:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80079b:	5d                   	pop    %ebp
  80079c:	8d 74 26 00          	lea    0x0(%esi),%esi
  8007a0:	c3                   	ret    

008007a1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a1:	55                   	push   %ebp
  8007a2:	89 e5                	mov    %esp,%ebp
  8007a4:	53                   	push   %ebx
  8007a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ab:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ad:	0f b6 01             	movzbl (%ecx),%eax
  8007b0:	88 02                	mov    %al,(%edx)
  8007b2:	83 c2 01             	add    $0x1,%edx
  8007b5:	83 c1 01             	add    $0x1,%ecx
  8007b8:	84 c0                	test   %al,%al
  8007ba:	75 f1                	jne    8007ad <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007bc:	89 d8                	mov    %ebx,%eax
  8007be:	5b                   	pop    %ebx
  8007bf:	5d                   	pop    %ebp
  8007c0:	c3                   	ret    

008007c1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	57                   	push   %edi
  8007c5:	56                   	push   %esi
  8007c6:	53                   	push   %ebx
  8007c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007cd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d0:	85 f6                	test   %esi,%esi
  8007d2:	74 1c                	je     8007f0 <strncpy+0x2f>
  8007d4:	89 fa                	mov    %edi,%edx
  8007d6:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  8007db:	0f b6 01             	movzbl (%ecx),%eax
  8007de:	88 02                	mov    %al,(%edx)
  8007e0:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e3:	80 39 01             	cmpb   $0x1,(%ecx)
  8007e6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e9:	83 c3 01             	add    $0x1,%ebx
  8007ec:	39 f3                	cmp    %esi,%ebx
  8007ee:	75 eb                	jne    8007db <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007f0:	89 f8                	mov    %edi,%eax
  8007f2:	5b                   	pop    %ebx
  8007f3:	5e                   	pop    %esi
  8007f4:	5f                   	pop    %edi
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	56                   	push   %esi
  8007fb:	53                   	push   %ebx
  8007fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800802:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800805:	89 f0                	mov    %esi,%eax
  800807:	85 d2                	test   %edx,%edx
  800809:	74 2c                	je     800837 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  80080b:	89 d3                	mov    %edx,%ebx
  80080d:	83 eb 01             	sub    $0x1,%ebx
  800810:	74 20                	je     800832 <strlcpy+0x3b>
  800812:	0f b6 11             	movzbl (%ecx),%edx
  800815:	84 d2                	test   %dl,%dl
  800817:	74 19                	je     800832 <strlcpy+0x3b>
  800819:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  80081b:	88 10                	mov    %dl,(%eax)
  80081d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800820:	83 eb 01             	sub    $0x1,%ebx
  800823:	74 0f                	je     800834 <strlcpy+0x3d>
  800825:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  800829:	83 c1 01             	add    $0x1,%ecx
  80082c:	84 d2                	test   %dl,%dl
  80082e:	74 04                	je     800834 <strlcpy+0x3d>
  800830:	eb e9                	jmp    80081b <strlcpy+0x24>
  800832:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800834:	c6 00 00             	movb   $0x0,(%eax)
  800837:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800839:	5b                   	pop    %ebx
  80083a:	5e                   	pop    %esi
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	56                   	push   %esi
  800841:	53                   	push   %ebx
  800842:	8b 75 08             	mov    0x8(%ebp),%esi
  800845:	8b 45 0c             	mov    0xc(%ebp),%eax
  800848:	8b 55 10             	mov    0x10(%ebp),%edx
    int c;
    char *q = buf;

    if (buf_size <= 0)
  80084b:	85 c0                	test   %eax,%eax
  80084d:	7e 2e                	jle    80087d <pstrcpy+0x40>
        return;

    for(;;) {
        c = *str++;
  80084f:	0f b6 0a             	movzbl (%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  800852:	84 c9                	test   %cl,%cl
  800854:	74 22                	je     800878 <pstrcpy+0x3b>
  800856:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  80085a:	89 f0                	mov    %esi,%eax
  80085c:	39 de                	cmp    %ebx,%esi
  80085e:	72 09                	jb     800869 <pstrcpy+0x2c>
  800860:	eb 16                	jmp    800878 <pstrcpy+0x3b>
  800862:	83 c2 01             	add    $0x1,%edx
  800865:	39 d8                	cmp    %ebx,%eax
  800867:	73 11                	jae    80087a <pstrcpy+0x3d>
            break;
        *q++ = c;
  800869:	88 08                	mov    %cl,(%eax)
  80086b:	83 c0 01             	add    $0x1,%eax

    if (buf_size <= 0)
        return;

    for(;;) {
        c = *str++;
  80086e:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  800872:	84 c9                	test   %cl,%cl
  800874:	75 ec                	jne    800862 <pstrcpy+0x25>
  800876:	eb 02                	jmp    80087a <pstrcpy+0x3d>
  800878:	89 f0                	mov    %esi,%eax
            break;
        *q++ = c;
    }
    *q = '\0';
  80087a:	c6 00 00             	movb   $0x0,(%eax)
}
  80087d:	5b                   	pop    %ebx
  80087e:	5e                   	pop    %esi
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	8b 55 08             	mov    0x8(%ebp),%edx
  800887:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  80088a:	0f b6 02             	movzbl (%edx),%eax
  80088d:	84 c0                	test   %al,%al
  80088f:	74 16                	je     8008a7 <strcmp+0x26>
  800891:	3a 01                	cmp    (%ecx),%al
  800893:	75 12                	jne    8008a7 <strcmp+0x26>
		p++, q++;
  800895:	83 c1 01             	add    $0x1,%ecx
    *q = '\0';
}
int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800898:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  80089c:	84 c0                	test   %al,%al
  80089e:	74 07                	je     8008a7 <strcmp+0x26>
  8008a0:	83 c2 01             	add    $0x1,%edx
  8008a3:	3a 01                	cmp    (%ecx),%al
  8008a5:	74 ee                	je     800895 <strcmp+0x14>
  8008a7:	0f b6 c0             	movzbl %al,%eax
  8008aa:	0f b6 11             	movzbl (%ecx),%edx
  8008ad:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	53                   	push   %ebx
  8008b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008bb:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008be:	85 d2                	test   %edx,%edx
  8008c0:	74 2d                	je     8008ef <strncmp+0x3e>
  8008c2:	0f b6 01             	movzbl (%ecx),%eax
  8008c5:	84 c0                	test   %al,%al
  8008c7:	74 1a                	je     8008e3 <strncmp+0x32>
  8008c9:	3a 03                	cmp    (%ebx),%al
  8008cb:	75 16                	jne    8008e3 <strncmp+0x32>
  8008cd:	83 ea 01             	sub    $0x1,%edx
  8008d0:	74 1d                	je     8008ef <strncmp+0x3e>
		n--, p++, q++;
  8008d2:	83 c1 01             	add    $0x1,%ecx
  8008d5:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d8:	0f b6 01             	movzbl (%ecx),%eax
  8008db:	84 c0                	test   %al,%al
  8008dd:	74 04                	je     8008e3 <strncmp+0x32>
  8008df:	3a 03                	cmp    (%ebx),%al
  8008e1:	74 ea                	je     8008cd <strncmp+0x1c>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e3:	0f b6 11             	movzbl (%ecx),%edx
  8008e6:	0f b6 03             	movzbl (%ebx),%eax
  8008e9:	29 c2                	sub    %eax,%edx
  8008eb:	89 d0                	mov    %edx,%eax
  8008ed:	eb 05                	jmp    8008f4 <strncmp+0x43>
  8008ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f4:	5b                   	pop    %ebx
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800901:	0f b6 10             	movzbl (%eax),%edx
  800904:	84 d2                	test   %dl,%dl
  800906:	74 14                	je     80091c <strchr+0x25>
		if (*s == c)
  800908:	38 ca                	cmp    %cl,%dl
  80090a:	75 06                	jne    800912 <strchr+0x1b>
  80090c:	eb 13                	jmp    800921 <strchr+0x2a>
  80090e:	38 ca                	cmp    %cl,%dl
  800910:	74 0f                	je     800921 <strchr+0x2a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800912:	83 c0 01             	add    $0x1,%eax
  800915:	0f b6 10             	movzbl (%eax),%edx
  800918:	84 d2                	test   %dl,%dl
  80091a:	75 f2                	jne    80090e <strchr+0x17>
  80091c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800921:	5d                   	pop    %ebp
  800922:	c3                   	ret    

00800923 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	8b 45 08             	mov    0x8(%ebp),%eax
  800929:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80092d:	0f b6 10             	movzbl (%eax),%edx
  800930:	84 d2                	test   %dl,%dl
  800932:	74 18                	je     80094c <strfind+0x29>
		if (*s == c)
  800934:	38 ca                	cmp    %cl,%dl
  800936:	75 0a                	jne    800942 <strfind+0x1f>
  800938:	eb 12                	jmp    80094c <strfind+0x29>
  80093a:	38 ca                	cmp    %cl,%dl
  80093c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800940:	74 0a                	je     80094c <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800942:	83 c0 01             	add    $0x1,%eax
  800945:	0f b6 10             	movzbl (%eax),%edx
  800948:	84 d2                	test   %dl,%dl
  80094a:	75 ee                	jne    80093a <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	83 ec 08             	sub    $0x8,%esp
  800954:	89 1c 24             	mov    %ebx,(%esp)
  800957:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80095b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800961:	85 db                	test   %ebx,%ebx
  800963:	74 36                	je     80099b <memset+0x4d>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800965:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096b:	75 26                	jne    800993 <memset+0x45>
  80096d:	f6 c3 03             	test   $0x3,%bl
  800970:	75 21                	jne    800993 <memset+0x45>
		c &= 0xFF;
  800972:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800976:	89 d0                	mov    %edx,%eax
  800978:	c1 e0 18             	shl    $0x18,%eax
  80097b:	89 d1                	mov    %edx,%ecx
  80097d:	c1 e1 10             	shl    $0x10,%ecx
  800980:	09 c8                	or     %ecx,%eax
  800982:	09 d0                	or     %edx,%eax
  800984:	c1 e2 08             	shl    $0x8,%edx
  800987:	09 d0                	or     %edx,%eax
  800989:	89 d9                	mov    %ebx,%ecx
  80098b:	c1 e9 02             	shr    $0x2,%ecx
  80098e:	fc                   	cld    
  80098f:	f3 ab                	rep stos %eax,%es:(%edi)
  800991:	eb 08                	jmp    80099b <memset+0x4d>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800993:	8b 45 0c             	mov    0xc(%ebp),%eax
  800996:	89 d9                	mov    %ebx,%ecx
  800998:	fc                   	cld    
  800999:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80099b:	89 f8                	mov    %edi,%eax
  80099d:	8b 1c 24             	mov    (%esp),%ebx
  8009a0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8009a4:	89 ec                	mov    %ebp,%esp
  8009a6:	5d                   	pop    %ebp
  8009a7:	c3                   	ret    

008009a8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	83 ec 08             	sub    $0x8,%esp
  8009ae:	89 34 24             	mov    %esi,(%esp)
  8009b1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  8009bb:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8009be:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8009c0:	39 c6                	cmp    %eax,%esi
  8009c2:	73 38                	jae    8009fc <memmove+0x54>
  8009c4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c7:	39 d0                	cmp    %edx,%eax
  8009c9:	73 31                	jae    8009fc <memmove+0x54>
		s += n;
		d += n;
  8009cb:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ce:	f6 c2 03             	test   $0x3,%dl
  8009d1:	75 1d                	jne    8009f0 <memmove+0x48>
  8009d3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d9:	75 15                	jne    8009f0 <memmove+0x48>
  8009db:	f6 c1 03             	test   $0x3,%cl
  8009de:	66 90                	xchg   %ax,%ax
  8009e0:	75 0e                	jne    8009f0 <memmove+0x48>
			asm volatile("std; rep movsl\n"
  8009e2:	8d 7e fc             	lea    -0x4(%esi),%edi
  8009e5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e8:	c1 e9 02             	shr    $0x2,%ecx
  8009eb:	fd                   	std    
  8009ec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ee:	eb 09                	jmp    8009f9 <memmove+0x51>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009f0:	8d 7e ff             	lea    -0x1(%esi),%edi
  8009f3:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009f6:	fd                   	std    
  8009f7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009f9:	fc                   	cld    
  8009fa:	eb 21                	jmp    800a1d <memmove+0x75>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a02:	75 16                	jne    800a1a <memmove+0x72>
  800a04:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a0a:	75 0e                	jne    800a1a <memmove+0x72>
  800a0c:	f6 c1 03             	test   $0x3,%cl
  800a0f:	90                   	nop    
  800a10:	75 08                	jne    800a1a <memmove+0x72>
			asm volatile("cld; rep movsl\n"
  800a12:	c1 e9 02             	shr    $0x2,%ecx
  800a15:	fc                   	cld    
  800a16:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a18:	eb 03                	jmp    800a1d <memmove+0x75>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a1a:	fc                   	cld    
  800a1b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a1d:	8b 34 24             	mov    (%esp),%esi
  800a20:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800a24:	89 ec                	mov    %ebp,%esp
  800a26:	5d                   	pop    %ebp
  800a27:	c3                   	ret    

00800a28 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a2e:	8b 45 10             	mov    0x10(%ebp),%eax
  800a31:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a35:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a38:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	89 04 24             	mov    %eax,(%esp)
  800a42:	e8 61 ff ff ff       	call   8009a8 <memmove>
}
  800a47:	c9                   	leave  
  800a48:	c3                   	ret    

00800a49 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	57                   	push   %edi
  800a4d:	56                   	push   %esi
  800a4e:	53                   	push   %ebx
  800a4f:	83 ec 04             	sub    $0x4,%esp
  800a52:	8b 45 08             	mov    0x8(%ebp),%eax
  800a55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a58:	8b 55 10             	mov    0x10(%ebp),%edx
  800a5b:	83 ea 01             	sub    $0x1,%edx
  800a5e:	83 fa ff             	cmp    $0xffffffff,%edx
  800a61:	74 47                	je     800aaa <memcmp+0x61>
		if (*s1 != *s2)
  800a63:	0f b6 30             	movzbl (%eax),%esi
  800a66:	0f b6 39             	movzbl (%ecx),%edi
			return (int) *s1 - (int) *s2;
  800a69:	89 45 f0             	mov    %eax,-0x10(%ebp)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  800a6c:	89 f0                	mov    %esi,%eax
  800a6e:	89 fb                	mov    %edi,%ebx
  800a70:	38 d8                	cmp    %bl,%al
  800a72:	74 2e                	je     800aa2 <memcmp+0x59>
  800a74:	eb 1c                	jmp    800a92 <memcmp+0x49>
  800a76:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a79:	0f b6 70 01          	movzbl 0x1(%eax),%esi
  800a7d:	0f b6 79 01          	movzbl 0x1(%ecx),%edi
  800a81:	83 c0 01             	add    $0x1,%eax
  800a84:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a87:	83 c1 01             	add    $0x1,%ecx
  800a8a:	89 f3                	mov    %esi,%ebx
  800a8c:	89 f8                	mov    %edi,%eax
  800a8e:	38 c3                	cmp    %al,%bl
  800a90:	74 10                	je     800aa2 <memcmp+0x59>
			return (int) *s1 - (int) *s2;
  800a92:	89 f1                	mov    %esi,%ecx
  800a94:	0f b6 d1             	movzbl %cl,%edx
  800a97:	89 fb                	mov    %edi,%ebx
  800a99:	0f b6 c3             	movzbl %bl,%eax
  800a9c:	29 c2                	sub    %eax,%edx
  800a9e:	89 d0                	mov    %edx,%eax
  800aa0:	eb 0d                	jmp    800aaf <memcmp+0x66>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa2:	83 ea 01             	sub    $0x1,%edx
  800aa5:	83 fa ff             	cmp    $0xffffffff,%edx
  800aa8:	75 cc                	jne    800a76 <memcmp+0x2d>
  800aaa:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800aaf:	83 c4 04             	add    $0x4,%esp
  800ab2:	5b                   	pop    %ebx
  800ab3:	5e                   	pop    %esi
  800ab4:	5f                   	pop    %edi
  800ab5:	5d                   	pop    %ebp
  800ab6:	c3                   	ret    

00800ab7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800abd:	89 c1                	mov    %eax,%ecx
  800abf:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
  800ac2:	39 c8                	cmp    %ecx,%eax
  800ac4:	73 15                	jae    800adb <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
  800aca:	38 10                	cmp    %dl,(%eax)
  800acc:	75 06                	jne    800ad4 <memfind+0x1d>
  800ace:	eb 0b                	jmp    800adb <memfind+0x24>
  800ad0:	38 10                	cmp    %dl,(%eax)
  800ad2:	74 07                	je     800adb <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ad4:	83 c0 01             	add    $0x1,%eax
  800ad7:	39 c8                	cmp    %ecx,%eax
  800ad9:	75 f5                	jne    800ad0 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800adb:	5d                   	pop    %ebp
  800adc:	8d 74 26 00          	lea    0x0(%esi),%esi
  800ae0:	c3                   	ret    

00800ae1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	57                   	push   %edi
  800ae5:	56                   	push   %esi
  800ae6:	53                   	push   %ebx
  800ae7:	83 ec 04             	sub    $0x4,%esp
  800aea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aed:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af0:	0f b6 01             	movzbl (%ecx),%eax
  800af3:	3c 20                	cmp    $0x20,%al
  800af5:	74 04                	je     800afb <strtol+0x1a>
  800af7:	3c 09                	cmp    $0x9,%al
  800af9:	75 0e                	jne    800b09 <strtol+0x28>
		s++;
  800afb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800afe:	0f b6 01             	movzbl (%ecx),%eax
  800b01:	3c 20                	cmp    $0x20,%al
  800b03:	74 f6                	je     800afb <strtol+0x1a>
  800b05:	3c 09                	cmp    $0x9,%al
  800b07:	74 f2                	je     800afb <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b09:	3c 2b                	cmp    $0x2b,%al
  800b0b:	75 0c                	jne    800b19 <strtol+0x38>
		s++;
  800b0d:	83 c1 01             	add    $0x1,%ecx
  800b10:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b17:	eb 15                	jmp    800b2e <strtol+0x4d>
	else if (*s == '-')
  800b19:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b20:	3c 2d                	cmp    $0x2d,%al
  800b22:	75 0a                	jne    800b2e <strtol+0x4d>
		s++, neg = 1;
  800b24:	83 c1 01             	add    $0x1,%ecx
  800b27:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b2e:	85 f6                	test   %esi,%esi
  800b30:	0f 94 c0             	sete   %al
  800b33:	74 05                	je     800b3a <strtol+0x59>
  800b35:	83 fe 10             	cmp    $0x10,%esi
  800b38:	75 18                	jne    800b52 <strtol+0x71>
  800b3a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b3d:	75 13                	jne    800b52 <strtol+0x71>
  800b3f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b43:	75 0d                	jne    800b52 <strtol+0x71>
		s += 2, base = 16;
  800b45:	83 c1 02             	add    $0x2,%ecx
  800b48:	be 10 00 00 00       	mov    $0x10,%esi
  800b4d:	8d 76 00             	lea    0x0(%esi),%esi
  800b50:	eb 1b                	jmp    800b6d <strtol+0x8c>
	else if (base == 0 && s[0] == '0')
  800b52:	85 f6                	test   %esi,%esi
  800b54:	75 0e                	jne    800b64 <strtol+0x83>
  800b56:	80 39 30             	cmpb   $0x30,(%ecx)
  800b59:	75 09                	jne    800b64 <strtol+0x83>
		s++, base = 8;
  800b5b:	83 c1 01             	add    $0x1,%ecx
  800b5e:	66 be 08 00          	mov    $0x8,%si
  800b62:	eb 09                	jmp    800b6d <strtol+0x8c>
	else if (base == 0)
  800b64:	84 c0                	test   %al,%al
  800b66:	74 05                	je     800b6d <strtol+0x8c>
  800b68:	be 0a 00 00 00       	mov    $0xa,%esi
  800b6d:	bf 00 00 00 00       	mov    $0x0,%edi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b72:	0f b6 11             	movzbl (%ecx),%edx
  800b75:	89 d3                	mov    %edx,%ebx
  800b77:	8d 42 d0             	lea    -0x30(%edx),%eax
  800b7a:	3c 09                	cmp    $0x9,%al
  800b7c:	77 08                	ja     800b86 <strtol+0xa5>
			dig = *s - '0';
  800b7e:	0f be c2             	movsbl %dl,%eax
  800b81:	8d 50 d0             	lea    -0x30(%eax),%edx
  800b84:	eb 1c                	jmp    800ba2 <strtol+0xc1>
		else if (*s >= 'a' && *s <= 'z')
  800b86:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800b89:	3c 19                	cmp    $0x19,%al
  800b8b:	77 08                	ja     800b95 <strtol+0xb4>
			dig = *s - 'a' + 10;
  800b8d:	0f be c2             	movsbl %dl,%eax
  800b90:	8d 50 a9             	lea    -0x57(%eax),%edx
  800b93:	eb 0d                	jmp    800ba2 <strtol+0xc1>
		else if (*s >= 'A' && *s <= 'Z')
  800b95:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800b98:	3c 19                	cmp    $0x19,%al
  800b9a:	77 17                	ja     800bb3 <strtol+0xd2>
			dig = *s - 'A' + 10;
  800b9c:	0f be c2             	movsbl %dl,%eax
  800b9f:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800ba2:	39 f2                	cmp    %esi,%edx
  800ba4:	7d 0d                	jge    800bb3 <strtol+0xd2>
			break;
		s++, val = (val * base) + dig;
  800ba6:	83 c1 01             	add    $0x1,%ecx
  800ba9:	89 f8                	mov    %edi,%eax
  800bab:	0f af c6             	imul   %esi,%eax
  800bae:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800bb1:	eb bf                	jmp    800b72 <strtol+0x91>
		// we don't properly detect overflow!
	}
  800bb3:	89 f8                	mov    %edi,%eax

	if (endptr)
  800bb5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bb9:	74 05                	je     800bc0 <strtol+0xdf>
		*endptr = (char *) s;
  800bbb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bbe:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800bc0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800bc4:	74 04                	je     800bca <strtol+0xe9>
  800bc6:	89 c7                	mov    %eax,%edi
  800bc8:	f7 df                	neg    %edi
}
  800bca:	89 f8                	mov    %edi,%eax
  800bcc:	83 c4 04             	add    $0x4,%esp
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	83 ec 0c             	sub    $0xc,%esp
  800bda:	89 1c 24             	mov    %ebx,(%esp)
  800bdd:	89 74 24 04          	mov    %esi,0x4(%esp)
  800be1:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be5:	b8 01 00 00 00       	mov    $0x1,%eax
  800bea:	bf 00 00 00 00       	mov    $0x0,%edi
  800bef:	89 fa                	mov    %edi,%edx
  800bf1:	89 f9                	mov    %edi,%ecx
  800bf3:	89 fb                	mov    %edi,%ebx
  800bf5:	89 fe                	mov    %edi,%esi
  800bf7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bf9:	8b 1c 24             	mov    (%esp),%ebx
  800bfc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c00:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c04:	89 ec                	mov    %ebp,%esp
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	83 ec 0c             	sub    $0xc,%esp
  800c0e:	89 1c 24             	mov    %ebx,(%esp)
  800c11:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c15:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c24:	89 f8                	mov    %edi,%eax
  800c26:	89 fb                	mov    %edi,%ebx
  800c28:	89 fe                	mov    %edi,%esi
  800c2a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c2c:	8b 1c 24             	mov    (%esp),%ebx
  800c2f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c33:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c37:	89 ec                	mov    %ebp,%esp
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	83 ec 28             	sub    $0x28,%esp
  800c41:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c44:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c47:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c4a:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c52:	bf 00 00 00 00       	mov    $0x0,%edi
  800c57:	89 f9                	mov    %edi,%ecx
  800c59:	89 fb                	mov    %edi,%ebx
  800c5b:	89 fe                	mov    %edi,%esi
  800c5d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	7e 28                	jle    800c8b <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c63:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c67:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800c6e:	00 
  800c6f:	c7 44 24 08 bf 20 80 	movl   $0x8020bf,0x8(%esp)
  800c76:	00 
  800c77:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c7e:	00 
  800c7f:	c7 04 24 dc 20 80 00 	movl   $0x8020dc,(%esp)
  800c86:	e8 41 0c 00 00       	call   8018cc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800c8b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c8e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c91:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c94:	89 ec                	mov    %ebp,%esp
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	83 ec 0c             	sub    $0xc,%esp
  800c9e:	89 1c 24             	mov    %ebx,(%esp)
  800ca1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ca5:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ca9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb2:	8b 7d 14             	mov    0x14(%ebp),%edi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cba:	be 00 00 00 00       	mov    $0x0,%esi
  800cbf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc1:	8b 1c 24             	mov    (%esp),%ebx
  800cc4:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cc8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ccc:	89 ec                	mov    %ebp,%esp
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	83 ec 28             	sub    $0x28,%esp
  800cd6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cd9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cdc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800cdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cea:	bf 00 00 00 00       	mov    $0x0,%edi
  800cef:	89 fb                	mov    %edi,%ebx
  800cf1:	89 fe                	mov    %edi,%esi
  800cf3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800cf5:	85 c0                	test   %eax,%eax
  800cf7:	7e 28                	jle    800d21 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cfd:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d04:	00 
  800d05:	c7 44 24 08 bf 20 80 	movl   $0x8020bf,0x8(%esp)
  800d0c:	00 
  800d0d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d14:	00 
  800d15:	c7 04 24 dc 20 80 00 	movl   $0x8020dc,(%esp)
  800d1c:	e8 ab 0b 00 00       	call   8018cc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d21:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d24:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d27:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d2a:	89 ec                	mov    %ebp,%esp
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    

00800d2e <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	83 ec 28             	sub    $0x28,%esp
  800d34:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d37:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d3a:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d43:	b8 09 00 00 00       	mov    $0x9,%eax
  800d48:	bf 00 00 00 00       	mov    $0x0,%edi
  800d4d:	89 fb                	mov    %edi,%ebx
  800d4f:	89 fe                	mov    %edi,%esi
  800d51:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800d53:	85 c0                	test   %eax,%eax
  800d55:	7e 28                	jle    800d7f <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d57:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d5b:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d62:	00 
  800d63:	c7 44 24 08 bf 20 80 	movl   $0x8020bf,0x8(%esp)
  800d6a:	00 
  800d6b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d72:	00 
  800d73:	c7 04 24 dc 20 80 00 	movl   $0x8020dc,(%esp)
  800d7a:	e8 4d 0b 00 00       	call   8018cc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d7f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d82:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d85:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d88:	89 ec                	mov    %ebp,%esp
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	83 ec 28             	sub    $0x28,%esp
  800d92:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d95:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d98:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da1:	b8 08 00 00 00       	mov    $0x8,%eax
  800da6:	bf 00 00 00 00       	mov    $0x0,%edi
  800dab:	89 fb                	mov    %edi,%ebx
  800dad:	89 fe                	mov    %edi,%esi
  800daf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800db1:	85 c0                	test   %eax,%eax
  800db3:	7e 28                	jle    800ddd <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db9:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dc0:	00 
  800dc1:	c7 44 24 08 bf 20 80 	movl   $0x8020bf,0x8(%esp)
  800dc8:	00 
  800dc9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd0:	00 
  800dd1:	c7 04 24 dc 20 80 00 	movl   $0x8020dc,(%esp)
  800dd8:	e8 ef 0a 00 00       	call   8018cc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ddd:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800de3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800de6:	89 ec                	mov    %ebp,%esp
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    

00800dea <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	83 ec 28             	sub    $0x28,%esp
  800df0:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800df3:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800df6:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800df9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dff:	b8 06 00 00 00       	mov    $0x6,%eax
  800e04:	bf 00 00 00 00       	mov    $0x0,%edi
  800e09:	89 fb                	mov    %edi,%ebx
  800e0b:	89 fe                	mov    %edi,%esi
  800e0d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	7e 28                	jle    800e3b <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e13:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e17:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e1e:	00 
  800e1f:	c7 44 24 08 bf 20 80 	movl   $0x8020bf,0x8(%esp)
  800e26:	00 
  800e27:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e2e:	00 
  800e2f:	c7 04 24 dc 20 80 00 	movl   $0x8020dc,(%esp)
  800e36:	e8 91 0a 00 00       	call   8018cc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e3b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e3e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e41:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e44:	89 ec                	mov    %ebp,%esp
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    

00800e48 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	83 ec 28             	sub    $0x28,%esp
  800e4e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e51:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e54:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e57:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e60:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e63:	8b 75 18             	mov    0x18(%ebp),%esi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e66:	b8 05 00 00 00       	mov    $0x5,%eax
  800e6b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800e6d:	85 c0                	test   %eax,%eax
  800e6f:	7e 28                	jle    800e99 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e71:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e75:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e7c:	00 
  800e7d:	c7 44 24 08 bf 20 80 	movl   $0x8020bf,0x8(%esp)
  800e84:	00 
  800e85:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e8c:	00 
  800e8d:	c7 04 24 dc 20 80 00 	movl   $0x8020dc,(%esp)
  800e94:	e8 33 0a 00 00       	call   8018cc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e99:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e9c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e9f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ea2:	89 ec                	mov    %ebp,%esp
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	83 ec 28             	sub    $0x28,%esp
  800eac:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eaf:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eb2:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800eb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebe:	b8 04 00 00 00       	mov    $0x4,%eax
  800ec3:	bf 00 00 00 00       	mov    $0x0,%edi
  800ec8:	89 fe                	mov    %edi,%esi
  800eca:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800ecc:	85 c0                	test   %eax,%eax
  800ece:	7e 28                	jle    800ef8 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed4:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800edb:	00 
  800edc:	c7 44 24 08 bf 20 80 	movl   $0x8020bf,0x8(%esp)
  800ee3:	00 
  800ee4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eeb:	00 
  800eec:	c7 04 24 dc 20 80 00 	movl   $0x8020dc,(%esp)
  800ef3:	e8 d4 09 00 00       	call   8018cc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ef8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800efb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800efe:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f01:	89 ec                	mov    %ebp,%esp
  800f03:	5d                   	pop    %ebp
  800f04:	c3                   	ret    

00800f05 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	83 ec 0c             	sub    $0xc,%esp
  800f0b:	89 1c 24             	mov    %ebx,(%esp)
  800f0e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f12:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f16:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f1b:	bf 00 00 00 00       	mov    $0x0,%edi
  800f20:	89 fa                	mov    %edi,%edx
  800f22:	89 f9                	mov    %edi,%ecx
  800f24:	89 fb                	mov    %edi,%ebx
  800f26:	89 fe                	mov    %edi,%esi
  800f28:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f2a:	8b 1c 24             	mov    (%esp),%ebx
  800f2d:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f31:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f35:	89 ec                	mov    %ebp,%esp
  800f37:	5d                   	pop    %ebp
  800f38:	c3                   	ret    

00800f39 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800f39:	55                   	push   %ebp
  800f3a:	89 e5                	mov    %esp,%ebp
  800f3c:	83 ec 0c             	sub    $0xc,%esp
  800f3f:	89 1c 24             	mov    %ebx,(%esp)
  800f42:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f46:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4a:	b8 02 00 00 00       	mov    $0x2,%eax
  800f4f:	bf 00 00 00 00       	mov    $0x0,%edi
  800f54:	89 fa                	mov    %edi,%edx
  800f56:	89 f9                	mov    %edi,%ecx
  800f58:	89 fb                	mov    %edi,%ebx
  800f5a:	89 fe                	mov    %edi,%esi
  800f5c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f5e:	8b 1c 24             	mov    (%esp),%ebx
  800f61:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f65:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f69:	89 ec                	mov    %ebp,%esp
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    

00800f6d <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	83 ec 28             	sub    $0x28,%esp
  800f73:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f76:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f79:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f7c:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f7f:	b8 03 00 00 00       	mov    $0x3,%eax
  800f84:	bf 00 00 00 00       	mov    $0x0,%edi
  800f89:	89 f9                	mov    %edi,%ecx
  800f8b:	89 fb                	mov    %edi,%ebx
  800f8d:	89 fe                	mov    %edi,%esi
  800f8f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f91:	85 c0                	test   %eax,%eax
  800f93:	7e 28                	jle    800fbd <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f95:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f99:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800fa0:	00 
  800fa1:	c7 44 24 08 bf 20 80 	movl   $0x8020bf,0x8(%esp)
  800fa8:	00 
  800fa9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fb0:	00 
  800fb1:	c7 04 24 dc 20 80 00 	movl   $0x8020dc,(%esp)
  800fb8:	e8 0f 09 00 00       	call   8018cc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800fbd:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fc0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fc3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fc6:	89 ec                	mov    %ebp,%esp
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    
  800fca:	00 00                	add    %al,(%eax)
  800fcc:	00 00                	add    %al,(%eax)
	...

00800fd0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd6:	05 00 00 00 30       	add    $0x30000000,%eax
  800fdb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  800fde:	5d                   	pop    %ebp
  800fdf:	c3                   	ret    

00800fe0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800fe6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe9:	89 04 24             	mov    %eax,(%esp)
  800fec:	e8 df ff ff ff       	call   800fd0 <fd2num>
  800ff1:	c1 e0 0c             	shl    $0xc,%eax
  800ff4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ff9:	c9                   	leave  
  800ffa:	c3                   	ret    

00800ffb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	53                   	push   %ebx
  800fff:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801002:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  801007:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801009:	89 d0                	mov    %edx,%eax
  80100b:	c1 e8 16             	shr    $0x16,%eax
  80100e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801015:	a8 01                	test   $0x1,%al
  801017:	74 10                	je     801029 <fd_alloc+0x2e>
  801019:	89 d0                	mov    %edx,%eax
  80101b:	c1 e8 0c             	shr    $0xc,%eax
  80101e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801025:	a8 01                	test   $0x1,%al
  801027:	75 09                	jne    801032 <fd_alloc+0x37>
			*fd_store = fd;
  801029:	89 0b                	mov    %ecx,(%ebx)
  80102b:	b8 00 00 00 00       	mov    $0x0,%eax
  801030:	eb 19                	jmp    80104b <fd_alloc+0x50>
			return 0;
  801032:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801038:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  80103e:	75 c7                	jne    801007 <fd_alloc+0xc>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801040:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801046:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  80104b:	5b                   	pop    %ebx
  80104c:	5d                   	pop    %ebp
  80104d:	c3                   	ret    

0080104e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801051:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  801055:	77 38                	ja     80108f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801057:	8b 45 08             	mov    0x8(%ebp),%eax
  80105a:	c1 e0 0c             	shl    $0xc,%eax
  80105d:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  801063:	89 d0                	mov    %edx,%eax
  801065:	c1 e8 16             	shr    $0x16,%eax
  801068:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80106f:	a8 01                	test   $0x1,%al
  801071:	74 1c                	je     80108f <fd_lookup+0x41>
  801073:	89 d0                	mov    %edx,%eax
  801075:	c1 e8 0c             	shr    $0xc,%eax
  801078:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80107f:	a8 01                	test   $0x1,%al
  801081:	74 0c                	je     80108f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801083:	8b 45 0c             	mov    0xc(%ebp),%eax
  801086:	89 10                	mov    %edx,(%eax)
  801088:	b8 00 00 00 00       	mov    $0x0,%eax
  80108d:	eb 05                	jmp    801094 <fd_lookup+0x46>
	return 0;
  80108f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801094:	5d                   	pop    %ebp
  801095:	c3                   	ret    

00801096 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801096:	55                   	push   %ebp
  801097:	89 e5                	mov    %esp,%ebp
  801099:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80109c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80109f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a6:	89 04 24             	mov    %eax,(%esp)
  8010a9:	e8 a0 ff ff ff       	call   80104e <fd_lookup>
  8010ae:	85 c0                	test   %eax,%eax
  8010b0:	78 0e                	js     8010c0 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8010b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8010b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010b8:	89 50 04             	mov    %edx,0x4(%eax)
  8010bb:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8010c0:	c9                   	leave  
  8010c1:	c3                   	ret    

008010c2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010c2:	55                   	push   %ebp
  8010c3:	89 e5                	mov    %esp,%ebp
  8010c5:	53                   	push   %ebx
  8010c6:	83 ec 14             	sub    $0x14,%esp
  8010c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8010cf:	ba 04 50 80 00       	mov    $0x805004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8010d4:	b8 00 00 00 00       	mov    $0x0,%eax
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8010d9:	39 0d 04 50 80 00    	cmp    %ecx,0x805004
  8010df:	75 11                	jne    8010f2 <dev_lookup+0x30>
  8010e1:	eb 04                	jmp    8010e7 <dev_lookup+0x25>
  8010e3:	39 0a                	cmp    %ecx,(%edx)
  8010e5:	75 0b                	jne    8010f2 <dev_lookup+0x30>
			*dev = devtab[i];
  8010e7:	89 13                	mov    %edx,(%ebx)
  8010e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ee:	66 90                	xchg   %ax,%ax
  8010f0:	eb 35                	jmp    801127 <dev_lookup+0x65>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8010f2:	83 c0 01             	add    $0x1,%eax
  8010f5:	8b 14 85 6c 21 80 00 	mov    0x80216c(,%eax,4),%edx
  8010fc:	85 d2                	test   %edx,%edx
  8010fe:	75 e3                	jne    8010e3 <dev_lookup+0x21>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  801100:	a1 20 50 80 00       	mov    0x805020,%eax
  801105:	8b 40 4c             	mov    0x4c(%eax),%eax
  801108:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80110c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801110:	c7 04 24 ec 20 80 00 	movl   $0x8020ec,(%esp)
  801117:	e8 1d f0 ff ff       	call   800139 <cprintf>
	*dev = 0;
  80111c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801122:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801127:	83 c4 14             	add    $0x14,%esp
  80112a:	5b                   	pop    %ebx
  80112b:	5d                   	pop    %ebp
  80112c:	c3                   	ret    

0080112d <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80112d:	55                   	push   %ebp
  80112e:	89 e5                	mov    %esp,%ebp
  801130:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801133:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801136:	89 44 24 04          	mov    %eax,0x4(%esp)
  80113a:	8b 45 08             	mov    0x8(%ebp),%eax
  80113d:	89 04 24             	mov    %eax,(%esp)
  801140:	e8 09 ff ff ff       	call   80104e <fd_lookup>
  801145:	89 c2                	mov    %eax,%edx
  801147:	85 c0                	test   %eax,%eax
  801149:	78 5a                	js     8011a5 <fstat+0x78>
  80114b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80114e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801152:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801155:	8b 00                	mov    (%eax),%eax
  801157:	89 04 24             	mov    %eax,(%esp)
  80115a:	e8 63 ff ff ff       	call   8010c2 <dev_lookup>
  80115f:	89 c2                	mov    %eax,%edx
  801161:	85 c0                	test   %eax,%eax
  801163:	78 40                	js     8011a5 <fstat+0x78>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801165:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  80116a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80116d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801171:	74 32                	je     8011a5 <fstat+0x78>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801173:	8b 45 0c             	mov    0xc(%ebp),%eax
  801176:	c6 00 00             	movb   $0x0,(%eax)
	stat->st_size = 0;
  801179:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  801180:	00 00 00 
	stat->st_isdir = 0;
  801183:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
  80118a:	00 00 00 
	stat->st_dev = dev;
  80118d:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801190:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
	return (*dev->dev_stat)(fd, stat);
  801196:	89 44 24 04          	mov    %eax,0x4(%esp)
  80119a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80119d:	89 04 24             	mov    %eax,(%esp)
  8011a0:	ff 52 14             	call   *0x14(%edx)
  8011a3:	89 c2                	mov    %eax,%edx
}
  8011a5:	89 d0                	mov    %edx,%eax
  8011a7:	c9                   	leave  
  8011a8:	c3                   	ret    

008011a9 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8011a9:	55                   	push   %ebp
  8011aa:	89 e5                	mov    %esp,%ebp
  8011ac:	53                   	push   %ebx
  8011ad:	83 ec 24             	sub    $0x24,%esp
  8011b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ba:	89 1c 24             	mov    %ebx,(%esp)
  8011bd:	e8 8c fe ff ff       	call   80104e <fd_lookup>
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	78 61                	js     801227 <ftruncate+0x7e>
  8011c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011c9:	8b 10                	mov    (%eax),%edx
  8011cb:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8011ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d2:	89 14 24             	mov    %edx,(%esp)
  8011d5:	e8 e8 fe ff ff       	call   8010c2 <dev_lookup>
  8011da:	85 c0                	test   %eax,%eax
  8011dc:	78 49                	js     801227 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011de:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  8011e1:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  8011e5:	75 23                	jne    80120a <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011e7:	a1 20 50 80 00       	mov    0x805020,%eax
  8011ec:	8b 40 4c             	mov    0x4c(%eax),%eax
  8011ef:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f7:	c7 04 24 0c 21 80 00 	movl   $0x80210c,(%esp)
  8011fe:	e8 36 ef ff ff       	call   800139 <cprintf>
  801203:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801208:	eb 1d                	jmp    801227 <ftruncate+0x7e>
			env->env_id, fdnum); 
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80120a:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80120d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801212:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  801216:	74 0f                	je     801227 <ftruncate+0x7e>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801218:	8b 42 18             	mov    0x18(%edx),%eax
  80121b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80121e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801222:	89 0c 24             	mov    %ecx,(%esp)
  801225:	ff d0                	call   *%eax
}
  801227:	83 c4 24             	add    $0x24,%esp
  80122a:	5b                   	pop    %ebx
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    

0080122d <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	53                   	push   %ebx
  801231:	83 ec 24             	sub    $0x24,%esp
  801234:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801237:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123e:	89 1c 24             	mov    %ebx,(%esp)
  801241:	e8 08 fe ff ff       	call   80104e <fd_lookup>
  801246:	85 c0                	test   %eax,%eax
  801248:	78 68                	js     8012b2 <write+0x85>
  80124a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80124d:	8b 10                	mov    (%eax),%edx
  80124f:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801252:	89 44 24 04          	mov    %eax,0x4(%esp)
  801256:	89 14 24             	mov    %edx,(%esp)
  801259:	e8 64 fe ff ff       	call   8010c2 <dev_lookup>
  80125e:	85 c0                	test   %eax,%eax
  801260:	78 50                	js     8012b2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801262:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801265:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801269:	75 23                	jne    80128e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  80126b:	a1 20 50 80 00       	mov    0x805020,%eax
  801270:	8b 40 4c             	mov    0x4c(%eax),%eax
  801273:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801277:	89 44 24 04          	mov    %eax,0x4(%esp)
  80127b:	c7 04 24 30 21 80 00 	movl   $0x802130,(%esp)
  801282:	e8 b2 ee ff ff       	call   800139 <cprintf>
  801287:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80128c:	eb 24                	jmp    8012b2 <write+0x85>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80128e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801291:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801296:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  80129a:	74 16                	je     8012b2 <write+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80129c:	8b 42 0c             	mov    0xc(%edx),%eax
  80129f:	8b 55 10             	mov    0x10(%ebp),%edx
  8012a2:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012ad:	89 0c 24             	mov    %ecx,(%esp)
  8012b0:	ff d0                	call   *%eax
}
  8012b2:	83 c4 24             	add    $0x24,%esp
  8012b5:	5b                   	pop    %ebx
  8012b6:	5d                   	pop    %ebp
  8012b7:	c3                   	ret    

008012b8 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
  8012bb:	53                   	push   %ebx
  8012bc:	83 ec 24             	sub    $0x24,%esp
  8012bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c9:	89 1c 24             	mov    %ebx,(%esp)
  8012cc:	e8 7d fd ff ff       	call   80104e <fd_lookup>
  8012d1:	85 c0                	test   %eax,%eax
  8012d3:	78 6d                	js     801342 <read+0x8a>
  8012d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012d8:	8b 10                	mov    (%eax),%edx
  8012da:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8012dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e1:	89 14 24             	mov    %edx,(%esp)
  8012e4:	e8 d9 fd ff ff       	call   8010c2 <dev_lookup>
  8012e9:	85 c0                	test   %eax,%eax
  8012eb:	78 55                	js     801342 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8012ed:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  8012f0:	8b 41 08             	mov    0x8(%ecx),%eax
  8012f3:	83 e0 03             	and    $0x3,%eax
  8012f6:	83 f8 01             	cmp    $0x1,%eax
  8012f9:	75 23                	jne    80131e <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  8012fb:	a1 20 50 80 00       	mov    0x805020,%eax
  801300:	8b 40 4c             	mov    0x4c(%eax),%eax
  801303:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801307:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130b:	c7 04 24 4d 21 80 00 	movl   $0x80214d,(%esp)
  801312:	e8 22 ee ff ff       	call   800139 <cprintf>
  801317:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80131c:	eb 24                	jmp    801342 <read+0x8a>
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80131e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801321:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801326:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  80132a:	74 16                	je     801342 <read+0x8a>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80132c:	8b 42 08             	mov    0x8(%edx),%eax
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

00801348 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801348:	55                   	push   %ebp
  801349:	89 e5                	mov    %esp,%ebp
  80134b:	57                   	push   %edi
  80134c:	56                   	push   %esi
  80134d:	53                   	push   %ebx
  80134e:	83 ec 0c             	sub    $0xc,%esp
  801351:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801354:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801357:	b8 00 00 00 00       	mov    $0x0,%eax
  80135c:	85 f6                	test   %esi,%esi
  80135e:	74 36                	je     801396 <readn+0x4e>
  801360:	bb 00 00 00 00       	mov    $0x0,%ebx
  801365:	ba 00 00 00 00       	mov    $0x0,%edx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80136a:	89 f0                	mov    %esi,%eax
  80136c:	29 d0                	sub    %edx,%eax
  80136e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801372:	8d 04 17             	lea    (%edi,%edx,1),%eax
  801375:	89 44 24 04          	mov    %eax,0x4(%esp)
  801379:	8b 45 08             	mov    0x8(%ebp),%eax
  80137c:	89 04 24             	mov    %eax,(%esp)
  80137f:	e8 34 ff ff ff       	call   8012b8 <read>
		if (m < 0)
  801384:	85 c0                	test   %eax,%eax
  801386:	78 0e                	js     801396 <readn+0x4e>
			return m;
		if (m == 0)
  801388:	85 c0                	test   %eax,%eax
  80138a:	74 08                	je     801394 <readn+0x4c>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80138c:	01 c3                	add    %eax,%ebx
  80138e:	89 da                	mov    %ebx,%edx
  801390:	39 f3                	cmp    %esi,%ebx
  801392:	72 d6                	jb     80136a <readn+0x22>
  801394:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801396:	83 c4 0c             	add    $0xc,%esp
  801399:	5b                   	pop    %ebx
  80139a:	5e                   	pop    %esi
  80139b:	5f                   	pop    %edi
  80139c:	5d                   	pop    %ebp
  80139d:	c3                   	ret    

0080139e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	83 ec 28             	sub    $0x28,%esp
  8013a4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013a7:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8013aa:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013ad:	89 34 24             	mov    %esi,(%esp)
  8013b0:	e8 1b fc ff ff       	call   800fd0 <fd2num>
  8013b5:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8013b8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013bc:	89 04 24             	mov    %eax,(%esp)
  8013bf:	e8 8a fc ff ff       	call   80104e <fd_lookup>
  8013c4:	89 c3                	mov    %eax,%ebx
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	78 05                	js     8013cf <fd_close+0x31>
  8013ca:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013cd:	74 0d                	je     8013dc <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8013cf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8013d3:	75 44                	jne    801419 <fd_close+0x7b>
  8013d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013da:	eb 3d                	jmp    801419 <fd_close+0x7b>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e3:	8b 06                	mov    (%esi),%eax
  8013e5:	89 04 24             	mov    %eax,(%esp)
  8013e8:	e8 d5 fc ff ff       	call   8010c2 <dev_lookup>
  8013ed:	89 c3                	mov    %eax,%ebx
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	78 16                	js     801409 <fd_close+0x6b>
		if (dev->dev_close)
  8013f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f6:	8b 40 10             	mov    0x10(%eax),%eax
  8013f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013fe:	85 c0                	test   %eax,%eax
  801400:	74 07                	je     801409 <fd_close+0x6b>
			r = (*dev->dev_close)(fd);
  801402:	89 34 24             	mov    %esi,(%esp)
  801405:	ff d0                	call   *%eax
  801407:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801409:	89 74 24 04          	mov    %esi,0x4(%esp)
  80140d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801414:	e8 d1 f9 ff ff       	call   800dea <sys_page_unmap>
	return r;
}
  801419:	89 d8                	mov    %ebx,%eax
  80141b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80141e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801421:	89 ec                	mov    %ebp,%esp
  801423:	5d                   	pop    %ebp
  801424:	c3                   	ret    

00801425 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80142b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80142e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801432:	8b 45 08             	mov    0x8(%ebp),%eax
  801435:	89 04 24             	mov    %eax,(%esp)
  801438:	e8 11 fc ff ff       	call   80104e <fd_lookup>
  80143d:	85 c0                	test   %eax,%eax
  80143f:	78 13                	js     801454 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801441:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801448:	00 
  801449:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80144c:	89 04 24             	mov    %eax,(%esp)
  80144f:	e8 4a ff ff ff       	call   80139e <fd_close>
}
  801454:	c9                   	leave  
  801455:	c3                   	ret    

00801456 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801456:	55                   	push   %ebp
  801457:	89 e5                	mov    %esp,%ebp
  801459:	83 ec 18             	sub    $0x18,%esp
  80145c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80145f:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801462:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801469:	00 
  80146a:	8b 45 08             	mov    0x8(%ebp),%eax
  80146d:	89 04 24             	mov    %eax,(%esp)
  801470:	e8 6a 03 00 00       	call   8017df <open>
  801475:	89 c6                	mov    %eax,%esi
  801477:	85 c0                	test   %eax,%eax
  801479:	78 1b                	js     801496 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  80147b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80147e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801482:	89 34 24             	mov    %esi,(%esp)
  801485:	e8 a3 fc ff ff       	call   80112d <fstat>
  80148a:	89 c3                	mov    %eax,%ebx
	close(fd);
  80148c:	89 34 24             	mov    %esi,(%esp)
  80148f:	e8 91 ff ff ff       	call   801425 <close>
  801494:	89 de                	mov    %ebx,%esi
	return r;
}
  801496:	89 f0                	mov    %esi,%eax
  801498:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80149b:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80149e:	89 ec                	mov    %ebp,%esp
  8014a0:	5d                   	pop    %ebp
  8014a1:	c3                   	ret    

008014a2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014a2:	55                   	push   %ebp
  8014a3:	89 e5                	mov    %esp,%ebp
  8014a5:	83 ec 38             	sub    $0x38,%esp
  8014a8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8014ab:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8014ae:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8014b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014be:	89 04 24             	mov    %eax,(%esp)
  8014c1:	e8 88 fb ff ff       	call   80104e <fd_lookup>
  8014c6:	89 c3                	mov    %eax,%ebx
  8014c8:	85 c0                	test   %eax,%eax
  8014ca:	0f 88 e1 00 00 00    	js     8015b1 <dup+0x10f>
		return r;
	close(newfdnum);
  8014d0:	89 3c 24             	mov    %edi,(%esp)
  8014d3:	e8 4d ff ff ff       	call   801425 <close>

	newfd = INDEX2FD(newfdnum);
  8014d8:	89 f8                	mov    %edi,%eax
  8014da:	c1 e0 0c             	shl    $0xc,%eax
  8014dd:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  8014e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e6:	89 04 24             	mov    %eax,(%esp)
  8014e9:	e8 f2 fa ff ff       	call   800fe0 <fd2data>
  8014ee:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8014f0:	89 34 24             	mov    %esi,(%esp)
  8014f3:	e8 e8 fa ff ff       	call   800fe0 <fd2data>
  8014f8:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  8014fb:	89 d8                	mov    %ebx,%eax
  8014fd:	c1 e8 16             	shr    $0x16,%eax
  801500:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801507:	a8 01                	test   $0x1,%al
  801509:	74 45                	je     801550 <dup+0xae>
  80150b:	89 da                	mov    %ebx,%edx
  80150d:	c1 ea 0c             	shr    $0xc,%edx
  801510:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801517:	a8 01                	test   $0x1,%al
  801519:	74 35                	je     801550 <dup+0xae>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  80151b:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801522:	25 07 0e 00 00       	and    $0xe07,%eax
  801527:	89 44 24 10          	mov    %eax,0x10(%esp)
  80152b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80152e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801532:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801539:	00 
  80153a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80153e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801545:	e8 fe f8 ff ff       	call   800e48 <sys_page_map>
  80154a:	89 c3                	mov    %eax,%ebx
  80154c:	85 c0                	test   %eax,%eax
  80154e:	78 3e                	js     80158e <dup+0xec>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  801550:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801553:	89 d0                	mov    %edx,%eax
  801555:	c1 e8 0c             	shr    $0xc,%eax
  801558:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80155f:	25 07 0e 00 00       	and    $0xe07,%eax
  801564:	89 44 24 10          	mov    %eax,0x10(%esp)
  801568:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80156c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801573:	00 
  801574:	89 54 24 04          	mov    %edx,0x4(%esp)
  801578:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80157f:	e8 c4 f8 ff ff       	call   800e48 <sys_page_map>
  801584:	89 c3                	mov    %eax,%ebx
  801586:	85 c0                	test   %eax,%eax
  801588:	78 04                	js     80158e <dup+0xec>
		goto err;
  80158a:	89 fb                	mov    %edi,%ebx
  80158c:	eb 23                	jmp    8015b1 <dup+0x10f>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80158e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801592:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801599:	e8 4c f8 ff ff       	call   800dea <sys_page_unmap>
	sys_page_unmap(0, nva);
  80159e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8015a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015ac:	e8 39 f8 ff ff       	call   800dea <sys_page_unmap>
	return r;
}
  8015b1:	89 d8                	mov    %ebx,%eax
  8015b3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8015b6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8015b9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015bc:	89 ec                	mov    %ebp,%esp
  8015be:	5d                   	pop    %ebp
  8015bf:	c3                   	ret    

008015c0 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8015c0:	55                   	push   %ebp
  8015c1:	89 e5                	mov    %esp,%ebp
  8015c3:	53                   	push   %ebx
  8015c4:	83 ec 04             	sub    $0x4,%esp
  8015c7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8015cc:	89 1c 24             	mov    %ebx,(%esp)
  8015cf:	e8 51 fe ff ff       	call   801425 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015d4:	83 c3 01             	add    $0x1,%ebx
  8015d7:	83 fb 20             	cmp    $0x20,%ebx
  8015da:	75 f0                	jne    8015cc <close_all+0xc>
		close(i);
}
  8015dc:	83 c4 04             	add    $0x4,%esp
  8015df:	5b                   	pop    %ebx
  8015e0:	5d                   	pop    %ebp
  8015e1:	c3                   	ret    
	...

008015e4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015e4:	55                   	push   %ebp
  8015e5:	89 e5                	mov    %esp,%ebp
  8015e7:	53                   	push   %ebx
  8015e8:	83 ec 14             	sub    $0x14,%esp
  8015eb:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015ed:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  8015f3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8015fa:	00 
  8015fb:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801602:	00 
  801603:	89 44 24 04          	mov    %eax,0x4(%esp)
  801607:	89 14 24             	mov    %edx,(%esp)
  80160a:	e8 31 03 00 00       	call   801940 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80160f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801616:	00 
  801617:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80161b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801622:	e8 cd 03 00 00       	call   8019f4 <ipc_recv>
}
  801627:	83 c4 14             	add    $0x14,%esp
  80162a:	5b                   	pop    %ebx
  80162b:	5d                   	pop    %ebp
  80162c:	c3                   	ret    

0080162d <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  80162d:	55                   	push   %ebp
  80162e:	89 e5                	mov    %esp,%ebp
  801630:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801633:	ba 00 00 00 00       	mov    $0x0,%edx
  801638:	b8 08 00 00 00       	mov    $0x8,%eax
  80163d:	e8 a2 ff ff ff       	call   8015e4 <fsipc>
}
  801642:	c9                   	leave  
  801643:	c3                   	ret    

00801644 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801644:	55                   	push   %ebp
  801645:	89 e5                	mov    %esp,%ebp
  801647:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80164a:	8b 45 08             	mov    0x8(%ebp),%eax
  80164d:	8b 40 0c             	mov    0xc(%eax),%eax
  801650:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.set_size.req_size = newsize;
  801655:	8b 45 0c             	mov    0xc(%ebp),%eax
  801658:	a3 04 30 80 00       	mov    %eax,0x803004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80165d:	ba 00 00 00 00       	mov    $0x0,%edx
  801662:	b8 02 00 00 00       	mov    $0x2,%eax
  801667:	e8 78 ff ff ff       	call   8015e4 <fsipc>
}
  80166c:	c9                   	leave  
  80166d:	c3                   	ret    

0080166e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801674:	8b 45 08             	mov    0x8(%ebp),%eax
  801677:	8b 40 0c             	mov    0xc(%eax),%eax
  80167a:	a3 00 30 80 00       	mov    %eax,0x803000
	return fsipc(FSREQ_FLUSH, NULL);
  80167f:	ba 00 00 00 00       	mov    $0x0,%edx
  801684:	b8 06 00 00 00       	mov    $0x6,%eax
  801689:	e8 56 ff ff ff       	call   8015e4 <fsipc>
}
  80168e:	c9                   	leave  
  80168f:	c3                   	ret    

00801690 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	53                   	push   %ebx
  801694:	83 ec 14             	sub    $0x14,%esp
  801697:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80169a:	8b 45 08             	mov    0x8(%ebp),%eax
  80169d:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a0:	a3 00 30 80 00       	mov    %eax,0x803000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8016af:	e8 30 ff ff ff       	call   8015e4 <fsipc>
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	78 2b                	js     8016e3 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016b8:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  8016bf:	00 
  8016c0:	89 1c 24             	mov    %ebx,(%esp)
  8016c3:	e8 d9 f0 ff ff       	call   8007a1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016c8:	a1 80 30 80 00       	mov    0x803080,%eax
  8016cd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016d3:	a1 84 30 80 00       	mov    0x803084,%eax
  8016d8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8016de:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8016e3:	83 c4 14             	add    $0x14,%esp
  8016e6:	5b                   	pop    %ebx
  8016e7:	5d                   	pop    %ebp
  8016e8:	c3                   	ret    

008016e9 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016e9:	55                   	push   %ebp
  8016ea:	89 e5                	mov    %esp,%ebp
  8016ec:	83 ec 18             	sub    $0x18,%esp
  8016ef:	8b 55 10             	mov    0x10(%ebp),%edx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	ssize_t writesize;
	size_t bufsize;
	fsipcbuf.write.req_fileid=fd->fd_file.id;
  8016f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f8:	a3 00 30 80 00       	mov    %eax,0x803000
	bufsize=sizeof(fsipcbuf.write.req_buf);
	if(n<bufsize)
  8016fd:	89 d0                	mov    %edx,%eax
  8016ff:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  801705:	76 05                	jbe    80170c <devfile_write+0x23>
  801707:	b8 f8 0f 00 00       	mov    $0xff8,%eax
		bufsize=n;	
	fsipcbuf.write.req_n=n;
  80170c:	89 15 04 30 80 00    	mov    %edx,0x803004
	memmove((void*)fsipcbuf.write.req_buf,buf,bufsize);
  801712:	89 44 24 08          	mov    %eax,0x8(%esp)
  801716:	8b 45 0c             	mov    0xc(%ebp),%eax
  801719:	89 44 24 04          	mov    %eax,0x4(%esp)
  80171d:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  801724:	e8 7f f2 ff ff       	call   8009a8 <memmove>
	writesize=(ssize_t)fsipc(FSREQ_WRITE,NULL);
  801729:	ba 00 00 00 00       	mov    $0x0,%edx
  80172e:	b8 04 00 00 00       	mov    $0x4,%eax
  801733:	e8 ac fe ff ff       	call   8015e4 <fsipc>
	return writesize;
	//panic("devfile_write not implemented");
}
  801738:	c9                   	leave  
  801739:	c3                   	ret    

0080173a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80173a:	55                   	push   %ebp
  80173b:	89 e5                	mov    %esp,%ebp
  80173d:	53                   	push   %ebx
  80173e:	83 ec 14             	sub    $0x14,%esp
	// system server.
	// LAB 5: Your code here
	ssize_t readsize;
	if(debug)
		cprintf("devfile_read:fileid=%x readsize=%x\n",fd->fd_file.id,n);
	fsipcbuf.read.req_fileid=fd->fd_file.id;
  801741:	8b 45 08             	mov    0x8(%ebp),%eax
  801744:	8b 40 0c             	mov    0xc(%eax),%eax
  801747:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.read.req_n=n;
  80174c:	8b 45 10             	mov    0x10(%ebp),%eax
  80174f:	a3 04 30 80 00       	mov    %eax,0x803004
	readsize=(ssize_t)fsipc(FSREQ_READ,&fsipcbuf);
  801754:	ba 00 30 80 00       	mov    $0x803000,%edx
  801759:	b8 03 00 00 00       	mov    $0x3,%eax
  80175e:	e8 81 fe ff ff       	call   8015e4 <fsipc>
  801763:	89 c3                	mov    %eax,%ebx
	cprintf("readsize=%d\n",readsize);
  801765:	89 44 24 04          	mov    %eax,0x4(%esp)
  801769:	c7 04 24 74 21 80 00 	movl   $0x802174,(%esp)
  801770:	e8 c4 e9 ff ff       	call   800139 <cprintf>
	if(debug)
		cprintf("devfile_read:buf1=%s\nbuf2=%s\n",(char*)&fsipcbuf,fsipcbuf.readRet.ret_buf);
	if(readsize>0)
  801775:	85 db                	test   %ebx,%ebx
  801777:	7e 17                	jle    801790 <devfile_read+0x56>
		memmove(buf,(void*)&fsipcbuf,(size_t)readsize);
  801779:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80177d:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801784:	00 
  801785:	8b 45 0c             	mov    0xc(%ebp),%eax
  801788:	89 04 24             	mov    %eax,(%esp)
  80178b:	e8 18 f2 ff ff       	call   8009a8 <memmove>
	//cprintf("readsize=%d",readsize);
	return readsize;
	//panic("devfile_read not implemented");
}
  801790:	89 d8                	mov    %ebx,%eax
  801792:	83 c4 14             	add    $0x14,%esp
  801795:	5b                   	pop    %ebx
  801796:	5d                   	pop    %ebp
  801797:	c3                   	ret    

00801798 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801798:	55                   	push   %ebp
  801799:	89 e5                	mov    %esp,%ebp
  80179b:	53                   	push   %ebx
  80179c:	83 ec 14             	sub    $0x14,%esp
  80179f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8017a2:	89 1c 24             	mov    %ebx,(%esp)
  8017a5:	e8 a6 ef ff ff       	call   800750 <strlen>
  8017aa:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  8017af:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017b4:	7f 21                	jg     8017d7 <remove+0x3f>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  8017b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017ba:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  8017c1:	e8 db ef ff ff       	call   8007a1 <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  8017c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017cb:	b8 07 00 00 00       	mov    $0x7,%eax
  8017d0:	e8 0f fe ff ff       	call   8015e4 <fsipc>
  8017d5:	89 c2                	mov    %eax,%edx
}
  8017d7:	89 d0                	mov    %edx,%eax
  8017d9:	83 c4 14             	add    $0x14,%esp
  8017dc:	5b                   	pop    %ebx
  8017dd:	5d                   	pop    %ebp
  8017de:	c3                   	ret    

008017df <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017df:	55                   	push   %ebp
  8017e0:	89 e5                	mov    %esp,%ebp
  8017e2:	53                   	push   %ebx
  8017e3:	83 ec 24             	sub    $0x24,%esp
	// file descriptor.

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;
	if((r=fd_alloc(&fd))<0){
  8017e6:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8017e9:	89 04 24             	mov    %eax,(%esp)
  8017ec:	e8 0a f8 ff ff       	call   800ffb <fd_alloc>
  8017f1:	89 c3                	mov    %eax,%ebx
  8017f3:	85 c0                	test   %eax,%eax
  8017f5:	79 18                	jns    80180f <open+0x30>
		fd_close(fd,0);
  8017f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017fe:	00 
  8017ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801802:	89 04 24             	mov    %eax,(%esp)
  801805:	e8 94 fb ff ff       	call   80139e <fd_close>
  80180a:	e9 b4 00 00 00       	jmp    8018c3 <open+0xe4>
		return r;
	}
	cprintf("open:fd=%x\n",fd);
  80180f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801812:	89 44 24 04          	mov    %eax,0x4(%esp)
  801816:	c7 04 24 81 21 80 00 	movl   $0x802181,(%esp)
  80181d:	e8 17 e9 ff ff       	call   800139 <cprintf>
	strcpy(fsipcbuf.open.req_path,path);
  801822:	8b 45 08             	mov    0x8(%ebp),%eax
  801825:	89 44 24 04          	mov    %eax,0x4(%esp)
  801829:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801830:	e8 6c ef ff ff       	call   8007a1 <strcpy>
	fsipcbuf.open.req_omode=mode;
  801835:	8b 45 0c             	mov    0xc(%ebp),%eax
  801838:	a3 00 34 80 00       	mov    %eax,0x803400
	if((r=fsipc(FSREQ_OPEN,(void*)fd))<0)
  80183d:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801840:	b8 01 00 00 00       	mov    $0x1,%eax
  801845:	e8 9a fd ff ff       	call   8015e4 <fsipc>
  80184a:	89 c3                	mov    %eax,%ebx
  80184c:	85 c0                	test   %eax,%eax
  80184e:	79 15                	jns    801865 <open+0x86>
	{
		fd_close(fd,1);
  801850:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801857:	00 
  801858:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80185b:	89 04 24             	mov    %eax,(%esp)
  80185e:	e8 3b fb ff ff       	call   80139e <fd_close>
  801863:	eb 5e                	jmp    8018c3 <open+0xe4>
		return r;	
	}
	if((r=sys_page_map(0,(void*)fd,0,(void*)fd,PTE_P | PTE_W | PTE_U))<0)
  801865:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801868:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80186f:	00 
  801870:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801874:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80187b:	00 
  80187c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801880:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801887:	e8 bc f5 ff ff       	call   800e48 <sys_page_map>
  80188c:	89 c3                	mov    %eax,%ebx
  80188e:	85 c0                	test   %eax,%eax
  801890:	79 15                	jns    8018a7 <open+0xc8>
	{
		fd_close(fd,1);
  801892:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801899:	00 
  80189a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80189d:	89 04 24             	mov    %eax,(%esp)
  8018a0:	e8 f9 fa ff ff       	call   80139e <fd_close>
  8018a5:	eb 1c                	jmp    8018c3 <open+0xe4>
		return r;
	}
	//INDEX2DATA(fd->fd_file.id);
	cprintf("fileid=%x\n",fd->fd_file.id);
  8018a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8018aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b1:	c7 04 24 8d 21 80 00 	movl   $0x80218d,(%esp)
  8018b8:	e8 7c e8 ff ff       	call   800139 <cprintf>
	return fd->fd_file.id;
  8018bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8018c0:	8b 58 0c             	mov    0xc(%eax),%ebx
	//panic("open not implemented");
}
  8018c3:	89 d8                	mov    %ebx,%eax
  8018c5:	83 c4 24             	add    $0x24,%esp
  8018c8:	5b                   	pop    %ebx
  8018c9:	5d                   	pop    %ebp
  8018ca:	c3                   	ret    
	...

008018cc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  8018cc:	55                   	push   %ebp
  8018cd:	89 e5                	mov    %esp,%ebp
  8018cf:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8018d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8018d5:	89 45 fc             	mov    %eax,-0x4(%ebp)

	// Print the panic message
	if (argv0)
  8018d8:	a1 24 50 80 00       	mov    0x805024,%eax
  8018dd:	85 c0                	test   %eax,%eax
  8018df:	74 10                	je     8018f1 <_panic+0x25>
		cprintf("%s: ", argv0);
  8018e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e5:	c7 04 24 98 21 80 00 	movl   $0x802198,(%esp)
  8018ec:	e8 48 e8 ff ff       	call   800139 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8018f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018ff:	a1 00 50 80 00       	mov    0x805000,%eax
  801904:	89 44 24 04          	mov    %eax,0x4(%esp)
  801908:	c7 04 24 9d 21 80 00 	movl   $0x80219d,(%esp)
  80190f:	e8 25 e8 ff ff       	call   800139 <cprintf>
	vcprintf(fmt, ap);
  801914:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801917:	89 44 24 04          	mov    %eax,0x4(%esp)
  80191b:	8b 45 10             	mov    0x10(%ebp),%eax
  80191e:	89 04 24             	mov    %eax,(%esp)
  801921:	e8 b2 e7 ff ff       	call   8000d8 <vcprintf>
	cprintf("\n");
  801926:	c7 04 24 7f 21 80 00 	movl   $0x80217f,(%esp)
  80192d:	e8 07 e8 ff ff       	call   800139 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801932:	cc                   	int3   
  801933:	eb fd                	jmp    801932 <_panic+0x66>
	...

00801940 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	57                   	push   %edi
  801944:	56                   	push   %esi
  801945:	53                   	push   %ebx
  801946:	83 ec 1c             	sub    $0x1c,%esp
  801949:	8b 75 08             	mov    0x8(%ebp),%esi
  80194c:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  80194f:	e8 e5 f5 ff ff       	call   800f39 <sys_getenvid>
  801954:	25 ff 03 00 00       	and    $0x3ff,%eax
  801959:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80195c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801961:	a3 20 50 80 00       	mov    %eax,0x805020
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  801966:	e8 ce f5 ff ff       	call   800f39 <sys_getenvid>
  80196b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801970:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801973:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801978:	a3 20 50 80 00       	mov    %eax,0x805020
		if(env->env_id==to_env){
  80197d:	8b 40 4c             	mov    0x4c(%eax),%eax
  801980:	39 f0                	cmp    %esi,%eax
  801982:	75 0e                	jne    801992 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  801984:	c7 04 24 b9 21 80 00 	movl   $0x8021b9,(%esp)
  80198b:	e8 a9 e7 ff ff       	call   800139 <cprintf>
  801990:	eb 5a                	jmp    8019ec <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  801992:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801996:	8b 45 10             	mov    0x10(%ebp),%eax
  801999:	89 44 24 08          	mov    %eax,0x8(%esp)
  80199d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a4:	89 34 24             	mov    %esi,(%esp)
  8019a7:	e8 ec f2 ff ff       	call   800c98 <sys_ipc_try_send>
  8019ac:	89 c3                	mov    %eax,%ebx
  8019ae:	85 c0                	test   %eax,%eax
  8019b0:	79 25                	jns    8019d7 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  8019b2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8019b5:	74 2b                	je     8019e2 <ipc_send+0xa2>
				panic("send error:%e",r);
  8019b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019bb:	c7 44 24 08 d5 21 80 	movl   $0x8021d5,0x8(%esp)
  8019c2:	00 
  8019c3:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8019ca:	00 
  8019cb:	c7 04 24 e3 21 80 00 	movl   $0x8021e3,(%esp)
  8019d2:	e8 f5 fe ff ff       	call   8018cc <_panic>
		}
			sys_yield();
  8019d7:	e8 29 f5 ff ff       	call   800f05 <sys_yield>
		
	}while(r!=0);
  8019dc:	85 db                	test   %ebx,%ebx
  8019de:	75 86                	jne    801966 <ipc_send+0x26>
  8019e0:	eb 0a                	jmp    8019ec <ipc_send+0xac>
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
		{	
			if(r!=-E_IPC_NOT_RECV)
				panic("send error:%e",r);
		}
			sys_yield();
  8019e2:	e8 1e f5 ff ff       	call   800f05 <sys_yield>
  8019e7:	e9 7a ff ff ff       	jmp    801966 <ipc_send+0x26>
		
	}while(r!=0);
	return;
	//panic("ipc_send not implemented");
}
  8019ec:	83 c4 1c             	add    $0x1c,%esp
  8019ef:	5b                   	pop    %ebx
  8019f0:	5e                   	pop    %esi
  8019f1:	5f                   	pop    %edi
  8019f2:	5d                   	pop    %ebp
  8019f3:	c3                   	ret    

008019f4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019f4:	55                   	push   %ebp
  8019f5:	89 e5                	mov    %esp,%ebp
  8019f7:	57                   	push   %edi
  8019f8:	56                   	push   %esi
  8019f9:	53                   	push   %ebx
  8019fa:	83 ec 0c             	sub    $0xc,%esp
  8019fd:	8b 75 08             	mov    0x8(%ebp),%esi
  801a00:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	void *dstva=NULL;
	if(pg)
		dstva=pg;
	env = &envs[ENVX(sys_getenvid())];
  801a03:	e8 31 f5 ff ff       	call   800f39 <sys_getenvid>
  801a08:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a0d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a10:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801a15:	a3 20 50 80 00       	mov    %eax,0x805020
	if(from_env_store&&(env->env_id==*from_env_store))
  801a1a:	85 f6                	test   %esi,%esi
  801a1c:	74 29                	je     801a47 <ipc_recv+0x53>
  801a1e:	8b 40 4c             	mov    0x4c(%eax),%eax
  801a21:	3b 06                	cmp    (%esi),%eax
  801a23:	75 22                	jne    801a47 <ipc_recv+0x53>
	{
		*from_env_store=0;
  801a25:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  801a2b:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("send:the reciver is sender\n");
  801a31:	c7 04 24 b9 21 80 00 	movl   $0x8021b9,(%esp)
  801a38:	e8 fc e6 ff ff       	call   800139 <cprintf>
  801a3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a42:	e9 8a 00 00 00       	jmp    801ad1 <ipc_recv+0xdd>
		return 0;
	}
	env = &envs[ENVX(sys_getenvid())];
  801a47:	e8 ed f4 ff ff       	call   800f39 <sys_getenvid>
  801a4c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a51:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a54:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801a59:	a3 20 50 80 00       	mov    %eax,0x805020
	if((r=sys_ipc_recv(dstva))<0)
  801a5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a61:	89 04 24             	mov    %eax,(%esp)
  801a64:	e8 d2 f1 ff ff       	call   800c3b <sys_ipc_recv>
  801a69:	89 c3                	mov    %eax,%ebx
  801a6b:	85 c0                	test   %eax,%eax
  801a6d:	79 1a                	jns    801a89 <ipc_recv+0x95>
	{
		*from_env_store=0;
  801a6f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  801a75:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("reciver failed\n");
  801a7b:	c7 04 24 ed 21 80 00 	movl   $0x8021ed,(%esp)
  801a82:	e8 b2 e6 ff ff       	call   800139 <cprintf>
  801a87:	eb 48                	jmp    801ad1 <ipc_recv+0xdd>
		return r;
	}
	else{//接收成功
		env = &envs[ENVX(sys_getenvid())];
  801a89:	e8 ab f4 ff ff       	call   800f39 <sys_getenvid>
  801a8e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a93:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a96:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801a9b:	a3 20 50 80 00       	mov    %eax,0x805020
		if(from_env_store)
  801aa0:	85 f6                	test   %esi,%esi
  801aa2:	74 05                	je     801aa9 <ipc_recv+0xb5>
			*from_env_store=env->env_ipc_from;	
  801aa4:	8b 40 74             	mov    0x74(%eax),%eax
  801aa7:	89 06                	mov    %eax,(%esi)
		if(perm_store)
  801aa9:	85 ff                	test   %edi,%edi
  801aab:	74 0a                	je     801ab7 <ipc_recv+0xc3>
			*perm_store=env->env_ipc_perm;
  801aad:	a1 20 50 80 00       	mov    0x805020,%eax
  801ab2:	8b 40 78             	mov    0x78(%eax),%eax
  801ab5:	89 07                	mov    %eax,(%edi)
		env = &envs[ENVX(sys_getenvid())];
  801ab7:	e8 7d f4 ff ff       	call   800f39 <sys_getenvid>
  801abc:	25 ff 03 00 00       	and    $0x3ff,%eax
  801ac1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ac4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ac9:	a3 20 50 80 00       	mov    %eax,0x805020
		return env->env_ipc_value;
  801ace:	8b 58 70             	mov    0x70(%eax),%ebx
	}
	//panic("ipc_recv not implemented");
	return 0;
}
  801ad1:	89 d8                	mov    %ebx,%eax
  801ad3:	83 c4 0c             	add    $0xc,%esp
  801ad6:	5b                   	pop    %ebx
  801ad7:	5e                   	pop    %esi
  801ad8:	5f                   	pop    %edi
  801ad9:	5d                   	pop    %ebp
  801ada:	c3                   	ret    
  801adb:	00 00                	add    %al,(%eax)
  801add:	00 00                	add    %al,(%eax)
	...

00801ae0 <__udivdi3>:
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	57                   	push   %edi
  801ae4:	56                   	push   %esi
  801ae5:	83 ec 18             	sub    $0x18,%esp
  801ae8:	8b 45 10             	mov    0x10(%ebp),%eax
  801aeb:	8b 55 14             	mov    0x14(%ebp),%edx
  801aee:	8b 75 0c             	mov    0xc(%ebp),%esi
  801af1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801af4:	89 c1                	mov    %eax,%ecx
  801af6:	8b 45 08             	mov    0x8(%ebp),%eax
  801af9:	85 d2                	test   %edx,%edx
  801afb:	89 d7                	mov    %edx,%edi
  801afd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b00:	75 1e                	jne    801b20 <__udivdi3+0x40>
  801b02:	39 f1                	cmp    %esi,%ecx
  801b04:	0f 86 8d 00 00 00    	jbe    801b97 <__udivdi3+0xb7>
  801b0a:	89 f2                	mov    %esi,%edx
  801b0c:	31 f6                	xor    %esi,%esi
  801b0e:	f7 f1                	div    %ecx
  801b10:	89 c1                	mov    %eax,%ecx
  801b12:	89 c8                	mov    %ecx,%eax
  801b14:	89 f2                	mov    %esi,%edx
  801b16:	83 c4 18             	add    $0x18,%esp
  801b19:	5e                   	pop    %esi
  801b1a:	5f                   	pop    %edi
  801b1b:	5d                   	pop    %ebp
  801b1c:	c3                   	ret    
  801b1d:	8d 76 00             	lea    0x0(%esi),%esi
  801b20:	39 f2                	cmp    %esi,%edx
  801b22:	0f 87 a8 00 00 00    	ja     801bd0 <__udivdi3+0xf0>
  801b28:	0f bd c2             	bsr    %edx,%eax
  801b2b:	83 f0 1f             	xor    $0x1f,%eax
  801b2e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801b31:	0f 84 89 00 00 00    	je     801bc0 <__udivdi3+0xe0>
  801b37:	b8 20 00 00 00       	mov    $0x20,%eax
  801b3c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b3f:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801b42:	89 c1                	mov    %eax,%ecx
  801b44:	d3 ea                	shr    %cl,%edx
  801b46:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  801b4a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801b4d:	89 f8                	mov    %edi,%eax
  801b4f:	8b 7d f4             	mov    -0xc(%ebp),%edi
  801b52:	d3 e0                	shl    %cl,%eax
  801b54:	09 c2                	or     %eax,%edx
  801b56:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b59:	d3 e7                	shl    %cl,%edi
  801b5b:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801b5f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801b62:	89 f2                	mov    %esi,%edx
  801b64:	d3 e8                	shr    %cl,%eax
  801b66:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  801b6a:	d3 e2                	shl    %cl,%edx
  801b6c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801b70:	09 d0                	or     %edx,%eax
  801b72:	d3 ee                	shr    %cl,%esi
  801b74:	89 f2                	mov    %esi,%edx
  801b76:	f7 75 e4             	divl   -0x1c(%ebp)
  801b79:	89 d1                	mov    %edx,%ecx
  801b7b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  801b7e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b81:	f7 e7                	mul    %edi
  801b83:	39 d1                	cmp    %edx,%ecx
  801b85:	89 c6                	mov    %eax,%esi
  801b87:	72 70                	jb     801bf9 <__udivdi3+0x119>
  801b89:	39 ca                	cmp    %ecx,%edx
  801b8b:	74 5f                	je     801bec <__udivdi3+0x10c>
  801b8d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801b90:	31 f6                	xor    %esi,%esi
  801b92:	e9 7b ff ff ff       	jmp    801b12 <__udivdi3+0x32>
  801b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b9a:	85 c0                	test   %eax,%eax
  801b9c:	75 0c                	jne    801baa <__udivdi3+0xca>
  801b9e:	b8 01 00 00 00       	mov    $0x1,%eax
  801ba3:	31 d2                	xor    %edx,%edx
  801ba5:	f7 75 f4             	divl   -0xc(%ebp)
  801ba8:	89 c1                	mov    %eax,%ecx
  801baa:	89 f0                	mov    %esi,%eax
  801bac:	89 fa                	mov    %edi,%edx
  801bae:	f7 f1                	div    %ecx
  801bb0:	89 c6                	mov    %eax,%esi
  801bb2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801bb5:	f7 f1                	div    %ecx
  801bb7:	89 c1                	mov    %eax,%ecx
  801bb9:	e9 54 ff ff ff       	jmp    801b12 <__udivdi3+0x32>
  801bbe:	66 90                	xchg   %ax,%ax
  801bc0:	39 d6                	cmp    %edx,%esi
  801bc2:	77 1c                	ja     801be0 <__udivdi3+0x100>
  801bc4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bc7:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  801bca:	73 14                	jae    801be0 <__udivdi3+0x100>
  801bcc:	8d 74 26 00          	lea    0x0(%esi),%esi
  801bd0:	31 c9                	xor    %ecx,%ecx
  801bd2:	31 f6                	xor    %esi,%esi
  801bd4:	e9 39 ff ff ff       	jmp    801b12 <__udivdi3+0x32>
  801bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  801be0:	b9 01 00 00 00       	mov    $0x1,%ecx
  801be5:	31 f6                	xor    %esi,%esi
  801be7:	e9 26 ff ff ff       	jmp    801b12 <__udivdi3+0x32>
  801bec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801bef:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  801bf3:	d3 e0                	shl    %cl,%eax
  801bf5:	39 c6                	cmp    %eax,%esi
  801bf7:	76 94                	jbe    801b8d <__udivdi3+0xad>
  801bf9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801bfc:	31 f6                	xor    %esi,%esi
  801bfe:	83 e9 01             	sub    $0x1,%ecx
  801c01:	e9 0c ff ff ff       	jmp    801b12 <__udivdi3+0x32>
	...

00801c10 <__umoddi3>:
  801c10:	55                   	push   %ebp
  801c11:	89 e5                	mov    %esp,%ebp
  801c13:	57                   	push   %edi
  801c14:	56                   	push   %esi
  801c15:	83 ec 30             	sub    $0x30,%esp
  801c18:	8b 45 10             	mov    0x10(%ebp),%eax
  801c1b:	8b 55 14             	mov    0x14(%ebp),%edx
  801c1e:	8b 75 08             	mov    0x8(%ebp),%esi
  801c21:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c24:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c27:	89 c1                	mov    %eax,%ecx
  801c29:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801c2c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801c2f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  801c36:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801c3d:	89 fa                	mov    %edi,%edx
  801c3f:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  801c42:	85 c0                	test   %eax,%eax
  801c44:	89 75 f0             	mov    %esi,-0x10(%ebp)
  801c47:	89 7d e0             	mov    %edi,-0x20(%ebp)
  801c4a:	75 14                	jne    801c60 <__umoddi3+0x50>
  801c4c:	39 f9                	cmp    %edi,%ecx
  801c4e:	76 60                	jbe    801cb0 <__umoddi3+0xa0>
  801c50:	89 f0                	mov    %esi,%eax
  801c52:	f7 f1                	div    %ecx
  801c54:	89 55 d0             	mov    %edx,-0x30(%ebp)
  801c57:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801c5e:	eb 10                	jmp    801c70 <__umoddi3+0x60>
  801c60:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801c63:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  801c66:	76 18                	jbe    801c80 <__umoddi3+0x70>
  801c68:	89 75 d0             	mov    %esi,-0x30(%ebp)
  801c6b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801c6e:	66 90                	xchg   %ax,%ax
  801c70:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801c73:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801c76:	83 c4 30             	add    $0x30,%esp
  801c79:	5e                   	pop    %esi
  801c7a:	5f                   	pop    %edi
  801c7b:	5d                   	pop    %ebp
  801c7c:	c3                   	ret    
  801c7d:	8d 76 00             	lea    0x0(%esi),%esi
  801c80:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
  801c84:	83 f0 1f             	xor    $0x1f,%eax
  801c87:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801c8a:	75 46                	jne    801cd2 <__umoddi3+0xc2>
  801c8c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801c8f:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  801c92:	0f 87 c9 00 00 00    	ja     801d61 <__umoddi3+0x151>
  801c98:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  801c9b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  801c9e:	0f 83 bd 00 00 00    	jae    801d61 <__umoddi3+0x151>
  801ca4:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801ca7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  801caa:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  801cad:	eb c1                	jmp    801c70 <__umoddi3+0x60>
  801caf:	90                   	nop    
  801cb0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801cb3:	85 c0                	test   %eax,%eax
  801cb5:	75 0c                	jne    801cc3 <__umoddi3+0xb3>
  801cb7:	b8 01 00 00 00       	mov    $0x1,%eax
  801cbc:	31 d2                	xor    %edx,%edx
  801cbe:	f7 75 ec             	divl   -0x14(%ebp)
  801cc1:	89 c1                	mov    %eax,%ecx
  801cc3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cc6:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801cc9:	f7 f1                	div    %ecx
  801ccb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cce:	f7 f1                	div    %ecx
  801cd0:	eb 82                	jmp    801c54 <__umoddi3+0x44>
  801cd2:	b8 20 00 00 00       	mov    $0x20,%eax
  801cd7:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801cda:	2b 45 d8             	sub    -0x28(%ebp),%eax
  801cdd:	8b 75 ec             	mov    -0x14(%ebp),%esi
  801ce0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ce3:	89 c1                	mov    %eax,%ecx
  801ce5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801ce8:	d3 ea                	shr    %cl,%edx
  801cea:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801ced:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  801cf1:	d3 e0                	shl    %cl,%eax
  801cf3:	09 c2                	or     %eax,%edx
  801cf5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cf8:	d3 e6                	shl    %cl,%esi
  801cfa:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  801cfe:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801d01:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801d04:	d3 e8                	shr    %cl,%eax
  801d06:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  801d0a:	d3 e2                	shl    %cl,%edx
  801d0c:	09 d0                	or     %edx,%eax
  801d0e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801d11:	d3 e7                	shl    %cl,%edi
  801d13:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  801d17:	d3 ea                	shr    %cl,%edx
  801d19:	f7 75 f4             	divl   -0xc(%ebp)
  801d1c:	89 55 cc             	mov    %edx,-0x34(%ebp)
  801d1f:	f7 e6                	mul    %esi
  801d21:	39 55 cc             	cmp    %edx,-0x34(%ebp)
  801d24:	72 53                	jb     801d79 <__umoddi3+0x169>
  801d26:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  801d29:	74 4a                	je     801d75 <__umoddi3+0x165>
  801d2b:	90                   	nop    
  801d2c:	8d 74 26 00          	lea    0x0(%esi),%esi
  801d30:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801d33:	29 c7                	sub    %eax,%edi
  801d35:	19 d1                	sbb    %edx,%ecx
  801d37:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801d3a:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  801d3e:	89 fa                	mov    %edi,%edx
  801d40:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801d43:	d3 ea                	shr    %cl,%edx
  801d45:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  801d49:	d3 e0                	shl    %cl,%eax
  801d4b:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  801d4f:	09 c2                	or     %eax,%edx
  801d51:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801d54:	89 55 d0             	mov    %edx,-0x30(%ebp)
  801d57:	d3 e8                	shr    %cl,%eax
  801d59:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801d5c:	e9 0f ff ff ff       	jmp    801c70 <__umoddi3+0x60>
  801d61:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801d64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d67:	2b 45 ec             	sub    -0x14(%ebp),%eax
  801d6a:	1b 55 e8             	sbb    -0x18(%ebp),%edx
  801d6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801d70:	e9 2f ff ff ff       	jmp    801ca4 <__umoddi3+0x94>
  801d75:	39 f8                	cmp    %edi,%eax
  801d77:	76 b7                	jbe    801d30 <__umoddi3+0x120>
  801d79:	29 f0                	sub    %esi,%eax
  801d7b:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801d7e:	eb b0                	jmp    801d30 <__umoddi3+0x120>
