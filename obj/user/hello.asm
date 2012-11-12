
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
  80003a:	c7 04 24 60 22 80 00 	movl   $0x802260,(%esp)
  800041:	e8 f3 00 00 00       	call   800139 <cprintf>
	cprintf("i am environment %08x\n", env->env_id);
  800046:	a1 3c 60 80 00       	mov    0x80603c,%eax
  80004b:	8b 40 4c             	mov    0x4c(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 6e 22 80 00 	movl   $0x80226e,(%esp)
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
  800072:	c7 05 3c 60 80 00 00 	movl   $0x0,0x80603c
  800079:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  80007c:	e8 ec 0e 00 00       	call   800f6d <sys_getenvid>
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
  8000c2:	e8 29 15 00 00       	call   8015f0 <close_all>
	sys_env_destroy(0);
  8000c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ce:	e8 ce 0e 00 00       	call   800fa1 <sys_env_destroy>
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
  80021b:	e8 a0 1d 00 00       	call   801fc0 <__udivdi3>
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
  80026d:	e8 7e 1e 00 00       	call   8020f0 <__umoddi3>
  800272:	89 74 24 04          	mov    %esi,0x4(%esp)
  800276:	0f be 80 9c 22 80 00 	movsbl 0x80229c(%eax),%eax
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
  80034e:	ff 24 85 e0 23 80 00 	jmp    *0x8023e0(,%eax,4)
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
  8003fd:	8b 14 85 40 25 80 00 	mov    0x802540(,%eax,4),%edx
  800404:	85 d2                	test   %edx,%edx
  800406:	75 23                	jne    80042b <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800408:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80040c:	c7 44 24 08 ad 22 80 	movl   $0x8022ad,0x8(%esp)
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
  80042f:	c7 44 24 08 82 26 80 	movl   $0x802682,0x8(%esp)
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
  800468:	c7 45 dc b6 22 80 00 	movl   $0x8022b6,-0x24(%ebp)
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

00800c3b <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	83 ec 0c             	sub    $0xc,%esp
  800c41:	89 1c 24             	mov    %ebx,(%esp)
  800c44:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c48:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800c51:	bf 00 00 00 00       	mov    $0x0,%edi
  800c56:	89 fa                	mov    %edi,%edx
  800c58:	89 f9                	mov    %edi,%ecx
  800c5a:	89 fb                	mov    %edi,%ebx
  800c5c:	89 fe                	mov    %edi,%esi
  800c5e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800c60:	8b 1c 24             	mov    (%esp),%ebx
  800c63:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c67:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c6b:	89 ec                	mov    %ebp,%esp
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	83 ec 28             	sub    $0x28,%esp
  800c75:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c78:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c7b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c7e:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c81:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c86:	bf 00 00 00 00       	mov    $0x0,%edi
  800c8b:	89 f9                	mov    %edi,%ecx
  800c8d:	89 fb                	mov    %edi,%ebx
  800c8f:	89 fe                	mov    %edi,%esi
  800c91:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800c93:	85 c0                	test   %eax,%eax
  800c95:	7e 28                	jle    800cbf <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c97:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c9b:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ca2:	00 
  800ca3:	c7 44 24 08 9f 25 80 	movl   $0x80259f,0x8(%esp)
  800caa:	00 
  800cab:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cb2:	00 
  800cb3:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  800cba:	e8 ed 10 00 00       	call   801dac <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cbf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cc2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cc5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cc8:	89 ec                	mov    %ebp,%esp
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	83 ec 0c             	sub    $0xc,%esp
  800cd2:	89 1c 24             	mov    %ebx,(%esp)
  800cd5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cd9:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800cdd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce6:	8b 7d 14             	mov    0x14(%ebp),%edi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce9:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cee:	be 00 00 00 00       	mov    $0x0,%esi
  800cf3:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cf5:	8b 1c 24             	mov    (%esp),%ebx
  800cf8:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cfc:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d00:	89 ec                	mov    %ebp,%esp
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	83 ec 28             	sub    $0x28,%esp
  800d0a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d0d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d10:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d13:	8b 55 08             	mov    0x8(%ebp),%edx
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d19:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d1e:	bf 00 00 00 00       	mov    $0x0,%edi
  800d23:	89 fb                	mov    %edi,%ebx
  800d25:	89 fe                	mov    %edi,%esi
  800d27:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800d29:	85 c0                	test   %eax,%eax
  800d2b:	7e 28                	jle    800d55 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d31:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d38:	00 
  800d39:	c7 44 24 08 9f 25 80 	movl   $0x80259f,0x8(%esp)
  800d40:	00 
  800d41:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d48:	00 
  800d49:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  800d50:	e8 57 10 00 00       	call   801dac <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d55:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d58:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d5b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d5e:	89 ec                	mov    %ebp,%esp
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    

00800d62 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	83 ec 28             	sub    $0x28,%esp
  800d68:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d6b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d6e:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d71:	8b 55 08             	mov    0x8(%ebp),%edx
  800d74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d77:	b8 09 00 00 00       	mov    $0x9,%eax
  800d7c:	bf 00 00 00 00       	mov    $0x0,%edi
  800d81:	89 fb                	mov    %edi,%ebx
  800d83:	89 fe                	mov    %edi,%esi
  800d85:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800d87:	85 c0                	test   %eax,%eax
  800d89:	7e 28                	jle    800db3 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d8f:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d96:	00 
  800d97:	c7 44 24 08 9f 25 80 	movl   $0x80259f,0x8(%esp)
  800d9e:	00 
  800d9f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da6:	00 
  800da7:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  800dae:	e8 f9 0f 00 00       	call   801dac <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800db3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800db6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800db9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dbc:	89 ec                	mov    %ebp,%esp
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	83 ec 28             	sub    $0x28,%esp
  800dc6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dc9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dcc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800dcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd5:	b8 08 00 00 00       	mov    $0x8,%eax
  800dda:	bf 00 00 00 00       	mov    $0x0,%edi
  800ddf:	89 fb                	mov    %edi,%ebx
  800de1:	89 fe                	mov    %edi,%esi
  800de3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800de5:	85 c0                	test   %eax,%eax
  800de7:	7e 28                	jle    800e11 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ded:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800df4:	00 
  800df5:	c7 44 24 08 9f 25 80 	movl   $0x80259f,0x8(%esp)
  800dfc:	00 
  800dfd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e04:	00 
  800e05:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  800e0c:	e8 9b 0f 00 00       	call   801dac <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e11:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e14:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e17:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e1a:	89 ec                	mov    %ebp,%esp
  800e1c:	5d                   	pop    %ebp
  800e1d:	c3                   	ret    

00800e1e <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800e1e:	55                   	push   %ebp
  800e1f:	89 e5                	mov    %esp,%ebp
  800e21:	83 ec 28             	sub    $0x28,%esp
  800e24:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e27:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e2a:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e33:	b8 06 00 00 00       	mov    $0x6,%eax
  800e38:	bf 00 00 00 00       	mov    $0x0,%edi
  800e3d:	89 fb                	mov    %edi,%ebx
  800e3f:	89 fe                	mov    %edi,%esi
  800e41:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800e43:	85 c0                	test   %eax,%eax
  800e45:	7e 28                	jle    800e6f <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e47:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e52:	00 
  800e53:	c7 44 24 08 9f 25 80 	movl   $0x80259f,0x8(%esp)
  800e5a:	00 
  800e5b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e62:	00 
  800e63:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  800e6a:	e8 3d 0f 00 00       	call   801dac <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e6f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e72:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e75:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e78:	89 ec                	mov    %ebp,%esp
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    

00800e7c <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	83 ec 28             	sub    $0x28,%esp
  800e82:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e85:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e88:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e94:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e97:	8b 75 18             	mov    0x18(%ebp),%esi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e9f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800ea1:	85 c0                	test   %eax,%eax
  800ea3:	7e 28                	jle    800ecd <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea9:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800eb0:	00 
  800eb1:	c7 44 24 08 9f 25 80 	movl   $0x80259f,0x8(%esp)
  800eb8:	00 
  800eb9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec0:	00 
  800ec1:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  800ec8:	e8 df 0e 00 00       	call   801dac <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ecd:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ed0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ed3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ed6:	89 ec                	mov    %ebp,%esp
  800ed8:	5d                   	pop    %ebp
  800ed9:	c3                   	ret    

00800eda <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	83 ec 28             	sub    $0x28,%esp
  800ee0:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ee3:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ee6:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ee9:	8b 55 08             	mov    0x8(%ebp),%edx
  800eec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef2:	b8 04 00 00 00       	mov    $0x4,%eax
  800ef7:	bf 00 00 00 00       	mov    $0x0,%edi
  800efc:	89 fe                	mov    %edi,%esi
  800efe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f00:	85 c0                	test   %eax,%eax
  800f02:	7e 28                	jle    800f2c <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f04:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f08:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f0f:	00 
  800f10:	c7 44 24 08 9f 25 80 	movl   $0x80259f,0x8(%esp)
  800f17:	00 
  800f18:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f1f:	00 
  800f20:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  800f27:	e8 80 0e 00 00       	call   801dac <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f2c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f2f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f32:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f35:	89 ec                	mov    %ebp,%esp
  800f37:	5d                   	pop    %ebp
  800f38:	c3                   	ret    

00800f39 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
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
  800f4a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f4f:	bf 00 00 00 00       	mov    $0x0,%edi
  800f54:	89 fa                	mov    %edi,%edx
  800f56:	89 f9                	mov    %edi,%ecx
  800f58:	89 fb                	mov    %edi,%ebx
  800f5a:	89 fe                	mov    %edi,%esi
  800f5c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f5e:	8b 1c 24             	mov    (%esp),%ebx
  800f61:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f65:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f69:	89 ec                	mov    %ebp,%esp
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    

00800f6d <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	83 ec 0c             	sub    $0xc,%esp
  800f73:	89 1c 24             	mov    %ebx,(%esp)
  800f76:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f7a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f7e:	b8 02 00 00 00       	mov    $0x2,%eax
  800f83:	bf 00 00 00 00       	mov    $0x0,%edi
  800f88:	89 fa                	mov    %edi,%edx
  800f8a:	89 f9                	mov    %edi,%ecx
  800f8c:	89 fb                	mov    %edi,%ebx
  800f8e:	89 fe                	mov    %edi,%esi
  800f90:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f92:	8b 1c 24             	mov    (%esp),%ebx
  800f95:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f99:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f9d:	89 ec                	mov    %ebp,%esp
  800f9f:	5d                   	pop    %ebp
  800fa0:	c3                   	ret    

00800fa1 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	83 ec 28             	sub    $0x28,%esp
  800fa7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800faa:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fad:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800fb0:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb3:	b8 03 00 00 00       	mov    $0x3,%eax
  800fb8:	bf 00 00 00 00       	mov    $0x0,%edi
  800fbd:	89 f9                	mov    %edi,%ecx
  800fbf:	89 fb                	mov    %edi,%ebx
  800fc1:	89 fe                	mov    %edi,%esi
  800fc3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	7e 28                	jle    800ff1 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fcd:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800fd4:	00 
  800fd5:	c7 44 24 08 9f 25 80 	movl   $0x80259f,0x8(%esp)
  800fdc:	00 
  800fdd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fe4:	00 
  800fe5:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  800fec:	e8 bb 0d 00 00       	call   801dac <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ff1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ff4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ff7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ffa:	89 ec                	mov    %ebp,%esp
  800ffc:	5d                   	pop    %ebp
  800ffd:	c3                   	ret    
	...

00801000 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	8b 45 08             	mov    0x8(%ebp),%eax
  801006:	05 00 00 00 30       	add    $0x30000000,%eax
  80100b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80100e:	5d                   	pop    %ebp
  80100f:	c3                   	ret    

00801010 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801016:	8b 45 08             	mov    0x8(%ebp),%eax
  801019:	89 04 24             	mov    %eax,(%esp)
  80101c:	e8 df ff ff ff       	call   801000 <fd2num>
  801021:	c1 e0 0c             	shl    $0xc,%eax
  801024:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801029:	c9                   	leave  
  80102a:	c3                   	ret    

0080102b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	53                   	push   %ebx
  80102f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801032:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  801037:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801039:	89 d0                	mov    %edx,%eax
  80103b:	c1 e8 16             	shr    $0x16,%eax
  80103e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801045:	a8 01                	test   $0x1,%al
  801047:	74 10                	je     801059 <fd_alloc+0x2e>
  801049:	89 d0                	mov    %edx,%eax
  80104b:	c1 e8 0c             	shr    $0xc,%eax
  80104e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801055:	a8 01                	test   $0x1,%al
  801057:	75 09                	jne    801062 <fd_alloc+0x37>
			*fd_store = fd;
  801059:	89 0b                	mov    %ecx,(%ebx)
  80105b:	b8 00 00 00 00       	mov    $0x0,%eax
  801060:	eb 19                	jmp    80107b <fd_alloc+0x50>
			return 0;
  801062:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801068:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  80106e:	75 c7                	jne    801037 <fd_alloc+0xc>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801070:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801076:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  80107b:	5b                   	pop    %ebx
  80107c:	5d                   	pop    %ebp
  80107d:	c3                   	ret    

0080107e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801081:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  801085:	77 38                	ja     8010bf <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801087:	8b 45 08             	mov    0x8(%ebp),%eax
  80108a:	c1 e0 0c             	shl    $0xc,%eax
  80108d:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  801093:	89 d0                	mov    %edx,%eax
  801095:	c1 e8 16             	shr    $0x16,%eax
  801098:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80109f:	a8 01                	test   $0x1,%al
  8010a1:	74 1c                	je     8010bf <fd_lookup+0x41>
  8010a3:	89 d0                	mov    %edx,%eax
  8010a5:	c1 e8 0c             	shr    $0xc,%eax
  8010a8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010af:	a8 01                	test   $0x1,%al
  8010b1:	74 0c                	je     8010bf <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b6:	89 10                	mov    %edx,(%eax)
  8010b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010bd:	eb 05                	jmp    8010c4 <fd_lookup+0x46>
	return 0;
  8010bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010c4:	5d                   	pop    %ebp
  8010c5:	c3                   	ret    

008010c6 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8010c6:	55                   	push   %ebp
  8010c7:	89 e5                	mov    %esp,%ebp
  8010c9:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010cc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8010cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d6:	89 04 24             	mov    %eax,(%esp)
  8010d9:	e8 a0 ff ff ff       	call   80107e <fd_lookup>
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	78 0e                	js     8010f0 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8010e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8010e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010e8:	89 50 04             	mov    %edx,0x4(%eax)
  8010eb:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8010f0:	c9                   	leave  
  8010f1:	c3                   	ret    

008010f2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	53                   	push   %ebx
  8010f6:	83 ec 14             	sub    $0x14,%esp
  8010f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8010ff:	ba 04 60 80 00       	mov    $0x806004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801104:	b8 00 00 00 00       	mov    $0x0,%eax
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801109:	39 0d 04 60 80 00    	cmp    %ecx,0x806004
  80110f:	75 11                	jne    801122 <dev_lookup+0x30>
  801111:	eb 04                	jmp    801117 <dev_lookup+0x25>
  801113:	39 0a                	cmp    %ecx,(%edx)
  801115:	75 0b                	jne    801122 <dev_lookup+0x30>
			*dev = devtab[i];
  801117:	89 13                	mov    %edx,(%ebx)
  801119:	b8 00 00 00 00       	mov    $0x0,%eax
  80111e:	66 90                	xchg   %ax,%ax
  801120:	eb 35                	jmp    801157 <dev_lookup+0x65>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801122:	83 c0 01             	add    $0x1,%eax
  801125:	8b 14 85 4c 26 80 00 	mov    0x80264c(,%eax,4),%edx
  80112c:	85 d2                	test   %edx,%edx
  80112e:	75 e3                	jne    801113 <dev_lookup+0x21>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  801130:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801135:	8b 40 4c             	mov    0x4c(%eax),%eax
  801138:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80113c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801140:	c7 04 24 cc 25 80 00 	movl   $0x8025cc,(%esp)
  801147:	e8 ed ef ff ff       	call   800139 <cprintf>
	*dev = 0;
  80114c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801152:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801157:	83 c4 14             	add    $0x14,%esp
  80115a:	5b                   	pop    %ebx
  80115b:	5d                   	pop    %ebp
  80115c:	c3                   	ret    

0080115d <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80115d:	55                   	push   %ebp
  80115e:	89 e5                	mov    %esp,%ebp
  801160:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801163:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801166:	89 44 24 04          	mov    %eax,0x4(%esp)
  80116a:	8b 45 08             	mov    0x8(%ebp),%eax
  80116d:	89 04 24             	mov    %eax,(%esp)
  801170:	e8 09 ff ff ff       	call   80107e <fd_lookup>
  801175:	89 c2                	mov    %eax,%edx
  801177:	85 c0                	test   %eax,%eax
  801179:	78 5a                	js     8011d5 <fstat+0x78>
  80117b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80117e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801182:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801185:	8b 00                	mov    (%eax),%eax
  801187:	89 04 24             	mov    %eax,(%esp)
  80118a:	e8 63 ff ff ff       	call   8010f2 <dev_lookup>
  80118f:	89 c2                	mov    %eax,%edx
  801191:	85 c0                	test   %eax,%eax
  801193:	78 40                	js     8011d5 <fstat+0x78>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801195:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  80119a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80119d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8011a1:	74 32                	je     8011d5 <fstat+0x78>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8011a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011a6:	c6 00 00             	movb   $0x0,(%eax)
	stat->st_size = 0;
  8011a9:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  8011b0:	00 00 00 
	stat->st_isdir = 0;
  8011b3:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
  8011ba:	00 00 00 
	stat->st_dev = dev;
  8011bd:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8011c0:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
	return (*dev->dev_stat)(fd, stat);
  8011c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ca:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011cd:	89 04 24             	mov    %eax,(%esp)
  8011d0:	ff 52 14             	call   *0x14(%edx)
  8011d3:	89 c2                	mov    %eax,%edx
}
  8011d5:	89 d0                	mov    %edx,%eax
  8011d7:	c9                   	leave  
  8011d8:	c3                   	ret    

008011d9 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
  8011dc:	53                   	push   %ebx
  8011dd:	83 ec 24             	sub    $0x24,%esp
  8011e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ea:	89 1c 24             	mov    %ebx,(%esp)
  8011ed:	e8 8c fe ff ff       	call   80107e <fd_lookup>
  8011f2:	85 c0                	test   %eax,%eax
  8011f4:	78 61                	js     801257 <ftruncate+0x7e>
  8011f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011f9:	8b 10                	mov    (%eax),%edx
  8011fb:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8011fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801202:	89 14 24             	mov    %edx,(%esp)
  801205:	e8 e8 fe ff ff       	call   8010f2 <dev_lookup>
  80120a:	85 c0                	test   %eax,%eax
  80120c:	78 49                	js     801257 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80120e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801211:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801215:	75 23                	jne    80123a <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801217:	a1 3c 60 80 00       	mov    0x80603c,%eax
  80121c:	8b 40 4c             	mov    0x4c(%eax),%eax
  80121f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801223:	89 44 24 04          	mov    %eax,0x4(%esp)
  801227:	c7 04 24 ec 25 80 00 	movl   $0x8025ec,(%esp)
  80122e:	e8 06 ef ff ff       	call   800139 <cprintf>
  801233:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801238:	eb 1d                	jmp    801257 <ftruncate+0x7e>
			env->env_id, fdnum); 
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80123a:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80123d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801242:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  801246:	74 0f                	je     801257 <ftruncate+0x7e>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801248:	8b 42 18             	mov    0x18(%edx),%eax
  80124b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80124e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801252:	89 0c 24             	mov    %ecx,(%esp)
  801255:	ff d0                	call   *%eax
}
  801257:	83 c4 24             	add    $0x24,%esp
  80125a:	5b                   	pop    %ebx
  80125b:	5d                   	pop    %ebp
  80125c:	c3                   	ret    

0080125d <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	53                   	push   %ebx
  801261:	83 ec 24             	sub    $0x24,%esp
  801264:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801267:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80126e:	89 1c 24             	mov    %ebx,(%esp)
  801271:	e8 08 fe ff ff       	call   80107e <fd_lookup>
  801276:	85 c0                	test   %eax,%eax
  801278:	78 68                	js     8012e2 <write+0x85>
  80127a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80127d:	8b 10                	mov    (%eax),%edx
  80127f:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801282:	89 44 24 04          	mov    %eax,0x4(%esp)
  801286:	89 14 24             	mov    %edx,(%esp)
  801289:	e8 64 fe ff ff       	call   8010f2 <dev_lookup>
  80128e:	85 c0                	test   %eax,%eax
  801290:	78 50                	js     8012e2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801292:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801295:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801299:	75 23                	jne    8012be <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  80129b:	a1 3c 60 80 00       	mov    0x80603c,%eax
  8012a0:	8b 40 4c             	mov    0x4c(%eax),%eax
  8012a3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ab:	c7 04 24 10 26 80 00 	movl   $0x802610,(%esp)
  8012b2:	e8 82 ee ff ff       	call   800139 <cprintf>
  8012b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012bc:	eb 24                	jmp    8012e2 <write+0x85>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012be:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8012c1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012c6:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  8012ca:	74 16                	je     8012e2 <write+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012cc:	8b 42 0c             	mov    0xc(%edx),%eax
  8012cf:	8b 55 10             	mov    0x10(%ebp),%edx
  8012d2:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012d9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012dd:	89 0c 24             	mov    %ecx,(%esp)
  8012e0:	ff d0                	call   *%eax
}
  8012e2:	83 c4 24             	add    $0x24,%esp
  8012e5:	5b                   	pop    %ebx
  8012e6:	5d                   	pop    %ebp
  8012e7:	c3                   	ret    

008012e8 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012e8:	55                   	push   %ebp
  8012e9:	89 e5                	mov    %esp,%ebp
  8012eb:	53                   	push   %ebx
  8012ec:	83 ec 24             	sub    $0x24,%esp
  8012ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f9:	89 1c 24             	mov    %ebx,(%esp)
  8012fc:	e8 7d fd ff ff       	call   80107e <fd_lookup>
  801301:	85 c0                	test   %eax,%eax
  801303:	78 6d                	js     801372 <read+0x8a>
  801305:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801308:	8b 10                	mov    (%eax),%edx
  80130a:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80130d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801311:	89 14 24             	mov    %edx,(%esp)
  801314:	e8 d9 fd ff ff       	call   8010f2 <dev_lookup>
  801319:	85 c0                	test   %eax,%eax
  80131b:	78 55                	js     801372 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80131d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801320:	8b 41 08             	mov    0x8(%ecx),%eax
  801323:	83 e0 03             	and    $0x3,%eax
  801326:	83 f8 01             	cmp    $0x1,%eax
  801329:	75 23                	jne    80134e <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  80132b:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801330:	8b 40 4c             	mov    0x4c(%eax),%eax
  801333:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801337:	89 44 24 04          	mov    %eax,0x4(%esp)
  80133b:	c7 04 24 2d 26 80 00 	movl   $0x80262d,(%esp)
  801342:	e8 f2 ed ff ff       	call   800139 <cprintf>
  801347:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80134c:	eb 24                	jmp    801372 <read+0x8a>
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80134e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801351:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801356:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  80135a:	74 16                	je     801372 <read+0x8a>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80135c:	8b 42 08             	mov    0x8(%edx),%eax
  80135f:	8b 55 10             	mov    0x10(%ebp),%edx
  801362:	89 54 24 08          	mov    %edx,0x8(%esp)
  801366:	8b 55 0c             	mov    0xc(%ebp),%edx
  801369:	89 54 24 04          	mov    %edx,0x4(%esp)
  80136d:	89 0c 24             	mov    %ecx,(%esp)
  801370:	ff d0                	call   *%eax
}
  801372:	83 c4 24             	add    $0x24,%esp
  801375:	5b                   	pop    %ebx
  801376:	5d                   	pop    %ebp
  801377:	c3                   	ret    

00801378 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
  80137b:	57                   	push   %edi
  80137c:	56                   	push   %esi
  80137d:	53                   	push   %ebx
  80137e:	83 ec 0c             	sub    $0xc,%esp
  801381:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801384:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801387:	b8 00 00 00 00       	mov    $0x0,%eax
  80138c:	85 f6                	test   %esi,%esi
  80138e:	74 36                	je     8013c6 <readn+0x4e>
  801390:	bb 00 00 00 00       	mov    $0x0,%ebx
  801395:	ba 00 00 00 00       	mov    $0x0,%edx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80139a:	89 f0                	mov    %esi,%eax
  80139c:	29 d0                	sub    %edx,%eax
  80139e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013a2:	8d 04 17             	lea    (%edi,%edx,1),%eax
  8013a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ac:	89 04 24             	mov    %eax,(%esp)
  8013af:	e8 34 ff ff ff       	call   8012e8 <read>
		if (m < 0)
  8013b4:	85 c0                	test   %eax,%eax
  8013b6:	78 0e                	js     8013c6 <readn+0x4e>
			return m;
		if (m == 0)
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	74 08                	je     8013c4 <readn+0x4c>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013bc:	01 c3                	add    %eax,%ebx
  8013be:	89 da                	mov    %ebx,%edx
  8013c0:	39 f3                	cmp    %esi,%ebx
  8013c2:	72 d6                	jb     80139a <readn+0x22>
  8013c4:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013c6:	83 c4 0c             	add    $0xc,%esp
  8013c9:	5b                   	pop    %ebx
  8013ca:	5e                   	pop    %esi
  8013cb:	5f                   	pop    %edi
  8013cc:	5d                   	pop    %ebp
  8013cd:	c3                   	ret    

008013ce <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	83 ec 28             	sub    $0x28,%esp
  8013d4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013d7:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8013da:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013dd:	89 34 24             	mov    %esi,(%esp)
  8013e0:	e8 1b fc ff ff       	call   801000 <fd2num>
  8013e5:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8013e8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013ec:	89 04 24             	mov    %eax,(%esp)
  8013ef:	e8 8a fc ff ff       	call   80107e <fd_lookup>
  8013f4:	89 c3                	mov    %eax,%ebx
  8013f6:	85 c0                	test   %eax,%eax
  8013f8:	78 05                	js     8013ff <fd_close+0x31>
  8013fa:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013fd:	74 0d                	je     80140c <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8013ff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801403:	75 44                	jne    801449 <fd_close+0x7b>
  801405:	bb 00 00 00 00       	mov    $0x0,%ebx
  80140a:	eb 3d                	jmp    801449 <fd_close+0x7b>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80140c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80140f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801413:	8b 06                	mov    (%esi),%eax
  801415:	89 04 24             	mov    %eax,(%esp)
  801418:	e8 d5 fc ff ff       	call   8010f2 <dev_lookup>
  80141d:	89 c3                	mov    %eax,%ebx
  80141f:	85 c0                	test   %eax,%eax
  801421:	78 16                	js     801439 <fd_close+0x6b>
		if (dev->dev_close)
  801423:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801426:	8b 40 10             	mov    0x10(%eax),%eax
  801429:	bb 00 00 00 00       	mov    $0x0,%ebx
  80142e:	85 c0                	test   %eax,%eax
  801430:	74 07                	je     801439 <fd_close+0x6b>
			r = (*dev->dev_close)(fd);
  801432:	89 34 24             	mov    %esi,(%esp)
  801435:	ff d0                	call   *%eax
  801437:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801439:	89 74 24 04          	mov    %esi,0x4(%esp)
  80143d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801444:	e8 d5 f9 ff ff       	call   800e1e <sys_page_unmap>
	return r;
}
  801449:	89 d8                	mov    %ebx,%eax
  80144b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80144e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801451:	89 ec                	mov    %ebp,%esp
  801453:	5d                   	pop    %ebp
  801454:	c3                   	ret    

00801455 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801455:	55                   	push   %ebp
  801456:	89 e5                	mov    %esp,%ebp
  801458:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80145b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80145e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801462:	8b 45 08             	mov    0x8(%ebp),%eax
  801465:	89 04 24             	mov    %eax,(%esp)
  801468:	e8 11 fc ff ff       	call   80107e <fd_lookup>
  80146d:	85 c0                	test   %eax,%eax
  80146f:	78 13                	js     801484 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801471:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801478:	00 
  801479:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80147c:	89 04 24             	mov    %eax,(%esp)
  80147f:	e8 4a ff ff ff       	call   8013ce <fd_close>
}
  801484:	c9                   	leave  
  801485:	c3                   	ret    

00801486 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801486:	55                   	push   %ebp
  801487:	89 e5                	mov    %esp,%ebp
  801489:	83 ec 18             	sub    $0x18,%esp
  80148c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80148f:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801492:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801499:	00 
  80149a:	8b 45 08             	mov    0x8(%ebp),%eax
  80149d:	89 04 24             	mov    %eax,(%esp)
  8014a0:	e8 5a 03 00 00       	call   8017ff <open>
  8014a5:	89 c6                	mov    %eax,%esi
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	78 1b                	js     8014c6 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8014ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b2:	89 34 24             	mov    %esi,(%esp)
  8014b5:	e8 a3 fc ff ff       	call   80115d <fstat>
  8014ba:	89 c3                	mov    %eax,%ebx
	close(fd);
  8014bc:	89 34 24             	mov    %esi,(%esp)
  8014bf:	e8 91 ff ff ff       	call   801455 <close>
  8014c4:	89 de                	mov    %ebx,%esi
	return r;
}
  8014c6:	89 f0                	mov    %esi,%eax
  8014c8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014cb:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8014ce:	89 ec                	mov    %ebp,%esp
  8014d0:	5d                   	pop    %ebp
  8014d1:	c3                   	ret    

008014d2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014d2:	55                   	push   %ebp
  8014d3:	89 e5                	mov    %esp,%ebp
  8014d5:	83 ec 38             	sub    $0x38,%esp
  8014d8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8014db:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8014de:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8014e1:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ee:	89 04 24             	mov    %eax,(%esp)
  8014f1:	e8 88 fb ff ff       	call   80107e <fd_lookup>
  8014f6:	89 c3                	mov    %eax,%ebx
  8014f8:	85 c0                	test   %eax,%eax
  8014fa:	0f 88 e1 00 00 00    	js     8015e1 <dup+0x10f>
		return r;
	close(newfdnum);
  801500:	89 3c 24             	mov    %edi,(%esp)
  801503:	e8 4d ff ff ff       	call   801455 <close>

	newfd = INDEX2FD(newfdnum);
  801508:	89 f8                	mov    %edi,%eax
  80150a:	c1 e0 0c             	shl    $0xc,%eax
  80150d:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  801513:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801516:	89 04 24             	mov    %eax,(%esp)
  801519:	e8 f2 fa ff ff       	call   801010 <fd2data>
  80151e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801520:	89 34 24             	mov    %esi,(%esp)
  801523:	e8 e8 fa ff ff       	call   801010 <fd2data>
  801528:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  80152b:	89 d8                	mov    %ebx,%eax
  80152d:	c1 e8 16             	shr    $0x16,%eax
  801530:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801537:	a8 01                	test   $0x1,%al
  801539:	74 45                	je     801580 <dup+0xae>
  80153b:	89 da                	mov    %ebx,%edx
  80153d:	c1 ea 0c             	shr    $0xc,%edx
  801540:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801547:	a8 01                	test   $0x1,%al
  801549:	74 35                	je     801580 <dup+0xae>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  80154b:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801552:	25 07 0e 00 00       	and    $0xe07,%eax
  801557:	89 44 24 10          	mov    %eax,0x10(%esp)
  80155b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80155e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801562:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801569:	00 
  80156a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80156e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801575:	e8 02 f9 ff ff       	call   800e7c <sys_page_map>
  80157a:	89 c3                	mov    %eax,%ebx
  80157c:	85 c0                	test   %eax,%eax
  80157e:	78 3e                	js     8015be <dup+0xec>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  801580:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801583:	89 d0                	mov    %edx,%eax
  801585:	c1 e8 0c             	shr    $0xc,%eax
  801588:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80158f:	25 07 0e 00 00       	and    $0xe07,%eax
  801594:	89 44 24 10          	mov    %eax,0x10(%esp)
  801598:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80159c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015a3:	00 
  8015a4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015af:	e8 c8 f8 ff ff       	call   800e7c <sys_page_map>
  8015b4:	89 c3                	mov    %eax,%ebx
  8015b6:	85 c0                	test   %eax,%eax
  8015b8:	78 04                	js     8015be <dup+0xec>
		goto err;
  8015ba:	89 fb                	mov    %edi,%ebx
  8015bc:	eb 23                	jmp    8015e1 <dup+0x10f>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015be:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015c9:	e8 50 f8 ff ff       	call   800e1e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8015d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015dc:	e8 3d f8 ff ff       	call   800e1e <sys_page_unmap>
	return r;
}
  8015e1:	89 d8                	mov    %ebx,%eax
  8015e3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8015e6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8015e9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015ec:	89 ec                	mov    %ebp,%esp
  8015ee:	5d                   	pop    %ebp
  8015ef:	c3                   	ret    

008015f0 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	53                   	push   %ebx
  8015f4:	83 ec 04             	sub    $0x4,%esp
  8015f7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8015fc:	89 1c 24             	mov    %ebx,(%esp)
  8015ff:	e8 51 fe ff ff       	call   801455 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801604:	83 c3 01             	add    $0x1,%ebx
  801607:	83 fb 20             	cmp    $0x20,%ebx
  80160a:	75 f0                	jne    8015fc <close_all+0xc>
		close(i);
}
  80160c:	83 c4 04             	add    $0x4,%esp
  80160f:	5b                   	pop    %ebx
  801610:	5d                   	pop    %ebp
  801611:	c3                   	ret    
	...

00801614 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	53                   	push   %ebx
  801618:	83 ec 14             	sub    $0x14,%esp
  80161b:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80161d:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  801623:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80162a:	00 
  80162b:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801632:	00 
  801633:	89 44 24 04          	mov    %eax,0x4(%esp)
  801637:	89 14 24             	mov    %edx,(%esp)
  80163a:	e8 e1 07 00 00       	call   801e20 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80163f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801646:	00 
  801647:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80164b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801652:	e8 7d 08 00 00       	call   801ed4 <ipc_recv>
}
  801657:	83 c4 14             	add    $0x14,%esp
  80165a:	5b                   	pop    %ebx
  80165b:	5d                   	pop    %ebp
  80165c:	c3                   	ret    

0080165d <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  80165d:	55                   	push   %ebp
  80165e:	89 e5                	mov    %esp,%ebp
  801660:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801663:	ba 00 00 00 00       	mov    $0x0,%edx
  801668:	b8 08 00 00 00       	mov    $0x8,%eax
  80166d:	e8 a2 ff ff ff       	call   801614 <fsipc>
}
  801672:	c9                   	leave  
  801673:	c3                   	ret    

00801674 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80167a:	8b 45 08             	mov    0x8(%ebp),%eax
  80167d:	8b 40 0c             	mov    0xc(%eax),%eax
  801680:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.set_size.req_size = newsize;
  801685:	8b 45 0c             	mov    0xc(%ebp),%eax
  801688:	a3 04 30 80 00       	mov    %eax,0x803004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80168d:	ba 00 00 00 00       	mov    $0x0,%edx
  801692:	b8 02 00 00 00       	mov    $0x2,%eax
  801697:	e8 78 ff ff ff       	call   801614 <fsipc>
}
  80169c:	c9                   	leave  
  80169d:	c3                   	ret    

0080169e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80169e:	55                   	push   %ebp
  80169f:	89 e5                	mov    %esp,%ebp
  8016a1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8016aa:	a3 00 30 80 00       	mov    %eax,0x803000
	return fsipc(FSREQ_FLUSH, NULL);
  8016af:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b4:	b8 06 00 00 00       	mov    $0x6,%eax
  8016b9:	e8 56 ff ff ff       	call   801614 <fsipc>
}
  8016be:	c9                   	leave  
  8016bf:	c3                   	ret    

008016c0 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	53                   	push   %ebx
  8016c4:	83 ec 14             	sub    $0x14,%esp
  8016c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d0:	a3 00 30 80 00       	mov    %eax,0x803000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016da:	b8 05 00 00 00       	mov    $0x5,%eax
  8016df:	e8 30 ff ff ff       	call   801614 <fsipc>
  8016e4:	85 c0                	test   %eax,%eax
  8016e6:	78 2b                	js     801713 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016e8:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  8016ef:	00 
  8016f0:	89 1c 24             	mov    %ebx,(%esp)
  8016f3:	e8 a9 f0 ff ff       	call   8007a1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016f8:	a1 80 30 80 00       	mov    0x803080,%eax
  8016fd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801703:	a1 84 30 80 00       	mov    0x803084,%eax
  801708:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  80170e:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801713:	83 c4 14             	add    $0x14,%esp
  801716:	5b                   	pop    %ebx
  801717:	5d                   	pop    %ebp
  801718:	c3                   	ret    

00801719 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801719:	55                   	push   %ebp
  80171a:	89 e5                	mov    %esp,%ebp
  80171c:	83 ec 18             	sub    $0x18,%esp
  80171f:	8b 55 10             	mov    0x10(%ebp),%edx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	ssize_t writesize;
	size_t bufsize;
	fsipcbuf.write.req_fileid=fd->fd_file.id;
  801722:	8b 45 08             	mov    0x8(%ebp),%eax
  801725:	8b 40 0c             	mov    0xc(%eax),%eax
  801728:	a3 00 30 80 00       	mov    %eax,0x803000
	bufsize=sizeof(fsipcbuf.write.req_buf);
	if(n<bufsize)
  80172d:	89 d0                	mov    %edx,%eax
  80172f:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  801735:	76 05                	jbe    80173c <devfile_write+0x23>
  801737:	b8 f8 0f 00 00       	mov    $0xff8,%eax
		bufsize=n;	
	fsipcbuf.write.req_n=n;
  80173c:	89 15 04 30 80 00    	mov    %edx,0x803004
	memmove((void*)fsipcbuf.write.req_buf,buf,bufsize);
  801742:	89 44 24 08          	mov    %eax,0x8(%esp)
  801746:	8b 45 0c             	mov    0xc(%ebp),%eax
  801749:	89 44 24 04          	mov    %eax,0x4(%esp)
  80174d:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  801754:	e8 4f f2 ff ff       	call   8009a8 <memmove>
	writesize=(ssize_t)fsipc(FSREQ_WRITE,NULL);
  801759:	ba 00 00 00 00       	mov    $0x0,%edx
  80175e:	b8 04 00 00 00       	mov    $0x4,%eax
  801763:	e8 ac fe ff ff       	call   801614 <fsipc>
	return writesize;
	//panic("devfile_write not implemented");
}
  801768:	c9                   	leave  
  801769:	c3                   	ret    

0080176a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	53                   	push   %ebx
  80176e:	83 ec 14             	sub    $0x14,%esp
	// system server.
	// LAB 5: Your code here
	ssize_t readsize;
	if(debug)
		cprintf("devfile_read:fileid=%x readsize=%x\n",fd->fd_file.id,n);
	fsipcbuf.read.req_fileid=fd->fd_file.id;
  801771:	8b 45 08             	mov    0x8(%ebp),%eax
  801774:	8b 40 0c             	mov    0xc(%eax),%eax
  801777:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.read.req_n=n;
  80177c:	8b 45 10             	mov    0x10(%ebp),%eax
  80177f:	a3 04 30 80 00       	mov    %eax,0x803004
	readsize=(ssize_t)fsipc(FSREQ_READ,&fsipcbuf);
  801784:	ba 00 30 80 00       	mov    $0x803000,%edx
  801789:	b8 03 00 00 00       	mov    $0x3,%eax
  80178e:	e8 81 fe ff ff       	call   801614 <fsipc>
  801793:	89 c3                	mov    %eax,%ebx
	//cprintf("readsize=%d\n",readsize);
	if(debug)
		cprintf("devfile_read:buf1=%s\nbuf2=%s\n",(char*)&fsipcbuf,fsipcbuf.readRet.ret_buf);
	if(readsize>0)
  801795:	85 c0                	test   %eax,%eax
  801797:	7e 17                	jle    8017b0 <devfile_read+0x46>
		memmove(buf,(void*)&fsipcbuf,(size_t)readsize);
  801799:	89 44 24 08          	mov    %eax,0x8(%esp)
  80179d:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  8017a4:	00 
  8017a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a8:	89 04 24             	mov    %eax,(%esp)
  8017ab:	e8 f8 f1 ff ff       	call   8009a8 <memmove>
	//cprintf("readsize=%d",readsize);
	return readsize;
	//panic("devfile_read not implemented");
}
  8017b0:	89 d8                	mov    %ebx,%eax
  8017b2:	83 c4 14             	add    $0x14,%esp
  8017b5:	5b                   	pop    %ebx
  8017b6:	5d                   	pop    %ebp
  8017b7:	c3                   	ret    

008017b8 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  8017b8:	55                   	push   %ebp
  8017b9:	89 e5                	mov    %esp,%ebp
  8017bb:	53                   	push   %ebx
  8017bc:	83 ec 14             	sub    $0x14,%esp
  8017bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8017c2:	89 1c 24             	mov    %ebx,(%esp)
  8017c5:	e8 86 ef ff ff       	call   800750 <strlen>
  8017ca:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  8017cf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017d4:	7f 21                	jg     8017f7 <remove+0x3f>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  8017d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017da:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  8017e1:	e8 bb ef ff ff       	call   8007a1 <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  8017e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017eb:	b8 07 00 00 00       	mov    $0x7,%eax
  8017f0:	e8 1f fe ff ff       	call   801614 <fsipc>
  8017f5:	89 c2                	mov    %eax,%edx
}
  8017f7:	89 d0                	mov    %edx,%eax
  8017f9:	83 c4 14             	add    $0x14,%esp
  8017fc:	5b                   	pop    %ebx
  8017fd:	5d                   	pop    %ebp
  8017fe:	c3                   	ret    

008017ff <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	56                   	push   %esi
  801803:	53                   	push   %ebx
  801804:	83 ec 30             	sub    $0x30,%esp

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;
	void *page;
	if((r=fd_alloc(&fd))<0){
  801807:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80180a:	89 04 24             	mov    %eax,(%esp)
  80180d:	e8 19 f8 ff ff       	call   80102b <fd_alloc>
  801812:	89 c3                	mov    %eax,%ebx
  801814:	85 c0                	test   %eax,%eax
  801816:	79 18                	jns    801830 <open+0x31>
		fd_close(fd,0);
  801818:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80181f:	00 
  801820:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801823:	89 04 24             	mov    %eax,(%esp)
  801826:	e8 a3 fb ff ff       	call   8013ce <fd_close>
  80182b:	e9 9f 00 00 00       	jmp    8018cf <open+0xd0>
		return r;
	}
	//cprintf("open:fd=%x\n",fd);
	strcpy(fsipcbuf.open.req_path,path);
  801830:	8b 45 08             	mov    0x8(%ebp),%eax
  801833:	89 44 24 04          	mov    %eax,0x4(%esp)
  801837:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  80183e:	e8 5e ef ff ff       	call   8007a1 <strcpy>
	fsipcbuf.open.req_omode=mode;
  801843:	8b 45 0c             	mov    0xc(%ebp),%eax
  801846:	a3 00 34 80 00       	mov    %eax,0x803400
	page=(void*)fd2data(fd);
  80184b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80184e:	89 04 24             	mov    %eax,(%esp)
  801851:	e8 ba f7 ff ff       	call   801010 <fd2data>
  801856:	89 c6                	mov    %eax,%esi
	if((r=fsipc(FSREQ_OPEN,(void*)fd))<0)
  801858:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80185b:	b8 01 00 00 00       	mov    $0x1,%eax
  801860:	e8 af fd ff ff       	call   801614 <fsipc>
  801865:	89 c3                	mov    %eax,%ebx
  801867:	85 c0                	test   %eax,%eax
  801869:	79 15                	jns    801880 <open+0x81>
	{
		fd_close(fd,1);
  80186b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801872:	00 
  801873:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801876:	89 04 24             	mov    %eax,(%esp)
  801879:	e8 50 fb ff ff       	call   8013ce <fd_close>
  80187e:	eb 4f                	jmp    8018cf <open+0xd0>
		return r;	
	}
	//cprintf("open:page=%x\n",page);
	if((r=sys_page_map(0,(void*)fd,0,(void*)page,PTE_P | PTE_W | PTE_U))<0)
  801880:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801887:	00 
  801888:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80188c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801893:	00 
  801894:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801897:	89 44 24 04          	mov    %eax,0x4(%esp)
  80189b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018a2:	e8 d5 f5 ff ff       	call   800e7c <sys_page_map>
  8018a7:	89 c3                	mov    %eax,%ebx
  8018a9:	85 c0                	test   %eax,%eax
  8018ab:	79 15                	jns    8018c2 <open+0xc3>
	{
		fd_close(fd,1);
  8018ad:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8018b4:	00 
  8018b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b8:	89 04 24             	mov    %eax,(%esp)
  8018bb:	e8 0e fb ff ff       	call   8013ce <fd_close>
  8018c0:	eb 0d                	jmp    8018cf <open+0xd0>
		return r;
	}
	//cprintf("open:fileid=%x\n",fd->fd_file.id);
	return fd2num(fd);
  8018c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018c5:	89 04 24             	mov    %eax,(%esp)
  8018c8:	e8 33 f7 ff ff       	call   801000 <fd2num>
  8018cd:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  8018cf:	89 d8                	mov    %ebx,%eax
  8018d1:	83 c4 30             	add    $0x30,%esp
  8018d4:	5b                   	pop    %ebx
  8018d5:	5e                   	pop    %esi
  8018d6:	5d                   	pop    %ebp
  8018d7:	c3                   	ret    
	...

008018e0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  8018e6:	c7 44 24 04 58 26 80 	movl   $0x802658,0x4(%esp)
  8018ed:	00 
  8018ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f1:	89 04 24             	mov    %eax,(%esp)
  8018f4:	e8 a8 ee ff ff       	call   8007a1 <strcpy>
	return 0;
}
  8018f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8018fe:	c9                   	leave  
  8018ff:	c3                   	ret    

00801900 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801900:	55                   	push   %ebp
  801901:	89 e5                	mov    %esp,%ebp
  801903:	83 ec 08             	sub    $0x8,%esp
	return nsipc_close(fd->fd_sock.sockid);
  801906:	8b 45 08             	mov    0x8(%ebp),%eax
  801909:	8b 40 0c             	mov    0xc(%eax),%eax
  80190c:	89 04 24             	mov    %eax,(%esp)
  80190f:	e8 9e 02 00 00       	call   801bb2 <nsipc_close>
}
  801914:	c9                   	leave  
  801915:	c3                   	ret    

00801916 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80191c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801923:	00 
  801924:	8b 45 10             	mov    0x10(%ebp),%eax
  801927:	89 44 24 08          	mov    %eax,0x8(%esp)
  80192b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801932:	8b 45 08             	mov    0x8(%ebp),%eax
  801935:	8b 40 0c             	mov    0xc(%eax),%eax
  801938:	89 04 24             	mov    %eax,(%esp)
  80193b:	e8 ae 02 00 00       	call   801bee <nsipc_send>
}
  801940:	c9                   	leave  
  801941:	c3                   	ret    

00801942 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801942:	55                   	push   %ebp
  801943:	89 e5                	mov    %esp,%ebp
  801945:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801948:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80194f:	00 
  801950:	8b 45 10             	mov    0x10(%ebp),%eax
  801953:	89 44 24 08          	mov    %eax,0x8(%esp)
  801957:	8b 45 0c             	mov    0xc(%ebp),%eax
  80195a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80195e:	8b 45 08             	mov    0x8(%ebp),%eax
  801961:	8b 40 0c             	mov    0xc(%eax),%eax
  801964:	89 04 24             	mov    %eax,(%esp)
  801967:	e8 f5 02 00 00       	call   801c61 <nsipc_recv>
}
  80196c:	c9                   	leave  
  80196d:	c3                   	ret    

0080196e <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  80196e:	55                   	push   %ebp
  80196f:	89 e5                	mov    %esp,%ebp
  801971:	56                   	push   %esi
  801972:	53                   	push   %ebx
  801973:	83 ec 20             	sub    $0x20,%esp
  801976:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801978:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197b:	89 04 24             	mov    %eax,(%esp)
  80197e:	e8 a8 f6 ff ff       	call   80102b <fd_alloc>
  801983:	89 c3                	mov    %eax,%ebx
  801985:	85 c0                	test   %eax,%eax
  801987:	78 21                	js     8019aa <alloc_sockfd+0x3c>
  801989:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801990:	00 
  801991:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801994:	89 44 24 04          	mov    %eax,0x4(%esp)
  801998:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80199f:	e8 36 f5 ff ff       	call   800eda <sys_page_alloc>
  8019a4:	89 c3                	mov    %eax,%ebx
  8019a6:	85 c0                	test   %eax,%eax
  8019a8:	79 0a                	jns    8019b4 <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U)) < 0) {
		nsipc_close(sockid);
  8019aa:	89 34 24             	mov    %esi,(%esp)
  8019ad:	e8 00 02 00 00       	call   801bb2 <nsipc_close>
  8019b2:	eb 28                	jmp    8019dc <alloc_sockfd+0x6e>
		return r;
	}

	sfd->fd_dev_id = devsock.dev_id;
  8019b4:	8b 15 20 60 80 00    	mov    0x806020,%edx
  8019ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019bd:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8019bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8019c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019cc:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8019cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d2:	89 04 24             	mov    %eax,(%esp)
  8019d5:	e8 26 f6 ff ff       	call   801000 <fd2num>
  8019da:	89 c3                	mov    %eax,%ebx
}
  8019dc:	89 d8                	mov    %ebx,%eax
  8019de:	83 c4 20             	add    $0x20,%esp
  8019e1:	5b                   	pop    %ebx
  8019e2:	5e                   	pop    %esi
  8019e3:	5d                   	pop    %ebp
  8019e4:	c3                   	ret    

008019e5 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8019e5:	55                   	push   %ebp
  8019e6:	89 e5                	mov    %esp,%ebp
  8019e8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8019eb:	8b 45 10             	mov    0x10(%ebp),%eax
  8019ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fc:	89 04 24             	mov    %eax,(%esp)
  8019ff:	e8 62 01 00 00       	call   801b66 <nsipc_socket>
  801a04:	85 c0                	test   %eax,%eax
  801a06:	78 05                	js     801a0d <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801a08:	e8 61 ff ff ff       	call   80196e <alloc_sockfd>
}
  801a0d:	c9                   	leave  
  801a0e:	66 90                	xchg   %ax,%ax
  801a10:	c3                   	ret    

00801a11 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a11:	55                   	push   %ebp
  801a12:	89 e5                	mov    %esp,%ebp
  801a14:	83 ec 18             	sub    $0x18,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a17:	8d 55 fc             	lea    -0x4(%ebp),%edx
  801a1a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a1e:	89 04 24             	mov    %eax,(%esp)
  801a21:	e8 58 f6 ff ff       	call   80107e <fd_lookup>
  801a26:	89 c2                	mov    %eax,%edx
  801a28:	85 c0                	test   %eax,%eax
  801a2a:	78 15                	js     801a41 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a2c:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  801a2f:	8b 01                	mov    (%ecx),%eax
  801a31:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  801a36:	3b 05 20 60 80 00    	cmp    0x806020,%eax
  801a3c:	75 03                	jne    801a41 <fd2sockid+0x30>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a3e:	8b 51 0c             	mov    0xc(%ecx),%edx
}
  801a41:	89 d0                	mov    %edx,%eax
  801a43:	c9                   	leave  
  801a44:	c3                   	ret    

00801a45 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4e:	e8 be ff ff ff       	call   801a11 <fd2sockid>
  801a53:	85 c0                	test   %eax,%eax
  801a55:	78 0f                	js     801a66 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801a57:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a5a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a5e:	89 04 24             	mov    %eax,(%esp)
  801a61:	e8 2a 01 00 00       	call   801b90 <nsipc_listen>
}
  801a66:	c9                   	leave  
  801a67:	c3                   	ret    

00801a68 <connect>:
	return nsipc_close(fd->fd_sock.sockid);
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a68:	55                   	push   %ebp
  801a69:	89 e5                	mov    %esp,%ebp
  801a6b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a71:	e8 9b ff ff ff       	call   801a11 <fd2sockid>
  801a76:	85 c0                	test   %eax,%eax
  801a78:	78 16                	js     801a90 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801a7a:	8b 55 10             	mov    0x10(%ebp),%edx
  801a7d:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a81:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a84:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a88:	89 04 24             	mov    %eax,(%esp)
  801a8b:	e8 51 02 00 00       	call   801ce1 <nsipc_connect>
}
  801a90:	c9                   	leave  
  801a91:	c3                   	ret    

00801a92 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801a92:	55                   	push   %ebp
  801a93:	89 e5                	mov    %esp,%ebp
  801a95:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a98:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9b:	e8 71 ff ff ff       	call   801a11 <fd2sockid>
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	78 0f                	js     801ab3 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801aa4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801aa7:	89 54 24 04          	mov    %edx,0x4(%esp)
  801aab:	89 04 24             	mov    %eax,(%esp)
  801aae:	e8 19 01 00 00       	call   801bcc <nsipc_shutdown>
}
  801ab3:	c9                   	leave  
  801ab4:	c3                   	ret    

00801ab5 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ab5:	55                   	push   %ebp
  801ab6:	89 e5                	mov    %esp,%ebp
  801ab8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801abb:	8b 45 08             	mov    0x8(%ebp),%eax
  801abe:	e8 4e ff ff ff       	call   801a11 <fd2sockid>
  801ac3:	85 c0                	test   %eax,%eax
  801ac5:	78 16                	js     801add <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801ac7:	8b 55 10             	mov    0x10(%ebp),%edx
  801aca:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ace:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ad1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ad5:	89 04 24             	mov    %eax,(%esp)
  801ad8:	e8 43 02 00 00       	call   801d20 <nsipc_bind>
}
  801add:	c9                   	leave  
  801ade:	c3                   	ret    

00801adf <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae8:	e8 24 ff ff ff       	call   801a11 <fd2sockid>
  801aed:	85 c0                	test   %eax,%eax
  801aef:	78 1f                	js     801b10 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801af1:	8b 55 10             	mov    0x10(%ebp),%edx
  801af4:	89 54 24 08          	mov    %edx,0x8(%esp)
  801af8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801afb:	89 54 24 04          	mov    %edx,0x4(%esp)
  801aff:	89 04 24             	mov    %eax,(%esp)
  801b02:	e8 58 02 00 00       	call   801d5f <nsipc_accept>
  801b07:	85 c0                	test   %eax,%eax
  801b09:	78 05                	js     801b10 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801b0b:	e8 5e fe ff ff       	call   80196e <alloc_sockfd>
}
  801b10:	c9                   	leave  
  801b11:	c3                   	ret    
	...

00801b20 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b26:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  801b2c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b33:	00 
  801b34:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801b3b:	00 
  801b3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b40:	89 14 24             	mov    %edx,(%esp)
  801b43:	e8 d8 02 00 00       	call   801e20 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801b48:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b4f:	00 
  801b50:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b57:	00 
  801b58:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b5f:	e8 70 03 00 00       	call   801ed4 <ipc_recv>
}
  801b64:	c9                   	leave  
  801b65:	c3                   	ret    

00801b66 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801b66:	55                   	push   %ebp
  801b67:	89 e5                	mov    %esp,%ebp
  801b69:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801b6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6f:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.socket.req_type = type;
  801b74:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b77:	a3 04 50 80 00       	mov    %eax,0x805004
	nsipcbuf.socket.req_protocol = protocol;
  801b7c:	8b 45 10             	mov    0x10(%ebp),%eax
  801b7f:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SOCKET);
  801b84:	b8 09 00 00 00       	mov    $0x9,%eax
  801b89:	e8 92 ff ff ff       	call   801b20 <nsipc>
}
  801b8e:	c9                   	leave  
  801b8f:	c3                   	ret    

00801b90 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801b96:	8b 45 08             	mov    0x8(%ebp),%eax
  801b99:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.listen.req_backlog = backlog;
  801b9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba1:	a3 04 50 80 00       	mov    %eax,0x805004
	return nsipc(NSREQ_LISTEN);
  801ba6:	b8 06 00 00 00       	mov    $0x6,%eax
  801bab:	e8 70 ff ff ff       	call   801b20 <nsipc>
}
  801bb0:	c9                   	leave  
  801bb1:	c3                   	ret    

00801bb2 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  801bb2:	55                   	push   %ebp
  801bb3:	89 e5                	mov    %esp,%ebp
  801bb5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801bb8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbb:	a3 00 50 80 00       	mov    %eax,0x805000
	return nsipc(NSREQ_CLOSE);
  801bc0:	b8 04 00 00 00       	mov    $0x4,%eax
  801bc5:	e8 56 ff ff ff       	call   801b20 <nsipc>
}
  801bca:	c9                   	leave  
  801bcb:	c3                   	ret    

00801bcc <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  801bcc:	55                   	push   %ebp
  801bcd:	89 e5                	mov    %esp,%ebp
  801bcf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801bd2:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd5:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.shutdown.req_how = how;
  801bda:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bdd:	a3 04 50 80 00       	mov    %eax,0x805004
	return nsipc(NSREQ_SHUTDOWN);
  801be2:	b8 03 00 00 00       	mov    $0x3,%eax
  801be7:	e8 34 ff ff ff       	call   801b20 <nsipc>
}
  801bec:	c9                   	leave  
  801bed:	c3                   	ret    

00801bee <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801bee:	55                   	push   %ebp
  801bef:	89 e5                	mov    %esp,%ebp
  801bf1:	53                   	push   %ebx
  801bf2:	83 ec 14             	sub    $0x14,%esp
  801bf5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfb:	a3 00 50 80 00       	mov    %eax,0x805000
	assert(size < 1600);
  801c00:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c06:	7e 24                	jle    801c2c <nsipc_send+0x3e>
  801c08:	c7 44 24 0c 64 26 80 	movl   $0x802664,0xc(%esp)
  801c0f:	00 
  801c10:	c7 44 24 08 70 26 80 	movl   $0x802670,0x8(%esp)
  801c17:	00 
  801c18:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  801c1f:	00 
  801c20:	c7 04 24 85 26 80 00 	movl   $0x802685,(%esp)
  801c27:	e8 80 01 00 00       	call   801dac <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c2c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c30:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c33:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c37:	c7 04 24 0c 50 80 00 	movl   $0x80500c,(%esp)
  801c3e:	e8 65 ed ff ff       	call   8009a8 <memmove>
	nsipcbuf.send.req_size = size;
  801c43:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	nsipcbuf.send.req_flags = flags;
  801c49:	8b 45 14             	mov    0x14(%ebp),%eax
  801c4c:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SEND);
  801c51:	b8 08 00 00 00       	mov    $0x8,%eax
  801c56:	e8 c5 fe ff ff       	call   801b20 <nsipc>
}
  801c5b:	83 c4 14             	add    $0x14,%esp
  801c5e:	5b                   	pop    %ebx
  801c5f:	5d                   	pop    %ebp
  801c60:	c3                   	ret    

00801c61 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801c61:	55                   	push   %ebp
  801c62:	89 e5                	mov    %esp,%ebp
  801c64:	56                   	push   %esi
  801c65:	53                   	push   %ebx
  801c66:	83 ec 10             	sub    $0x10,%esp
  801c69:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801c6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6f:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.recv.req_len = len;
  801c74:	89 35 04 50 80 00    	mov    %esi,0x805004
	nsipcbuf.recv.req_flags = flags;
  801c7a:	8b 45 14             	mov    0x14(%ebp),%eax
  801c7d:	a3 08 50 80 00       	mov    %eax,0x805008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801c82:	b8 07 00 00 00       	mov    $0x7,%eax
  801c87:	e8 94 fe ff ff       	call   801b20 <nsipc>
  801c8c:	89 c3                	mov    %eax,%ebx
  801c8e:	85 c0                	test   %eax,%eax
  801c90:	78 46                	js     801cd8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801c92:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801c97:	7f 04                	jg     801c9d <nsipc_recv+0x3c>
  801c99:	39 c6                	cmp    %eax,%esi
  801c9b:	7d 24                	jge    801cc1 <nsipc_recv+0x60>
  801c9d:	c7 44 24 0c 91 26 80 	movl   $0x802691,0xc(%esp)
  801ca4:	00 
  801ca5:	c7 44 24 08 70 26 80 	movl   $0x802670,0x8(%esp)
  801cac:	00 
  801cad:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  801cb4:	00 
  801cb5:	c7 04 24 85 26 80 00 	movl   $0x802685,(%esp)
  801cbc:	e8 eb 00 00 00       	call   801dac <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801cc1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cc5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801ccc:	00 
  801ccd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd0:	89 04 24             	mov    %eax,(%esp)
  801cd3:	e8 d0 ec ff ff       	call   8009a8 <memmove>
	}

	return r;
}
  801cd8:	89 d8                	mov    %ebx,%eax
  801cda:	83 c4 10             	add    $0x10,%esp
  801cdd:	5b                   	pop    %ebx
  801cde:	5e                   	pop    %esi
  801cdf:	5d                   	pop    %ebp
  801ce0:	c3                   	ret    

00801ce1 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ce1:	55                   	push   %ebp
  801ce2:	89 e5                	mov    %esp,%ebp
  801ce4:	53                   	push   %ebx
  801ce5:	83 ec 14             	sub    $0x14,%esp
  801ce8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cee:	a3 00 50 80 00       	mov    %eax,0x805000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801cf3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cf7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cfa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cfe:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  801d05:	e8 9e ec ff ff       	call   8009a8 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d0a:	89 1d 14 50 80 00    	mov    %ebx,0x805014
	return nsipc(NSREQ_CONNECT);
  801d10:	b8 05 00 00 00       	mov    $0x5,%eax
  801d15:	e8 06 fe ff ff       	call   801b20 <nsipc>
}
  801d1a:	83 c4 14             	add    $0x14,%esp
  801d1d:	5b                   	pop    %ebx
  801d1e:	5d                   	pop    %ebp
  801d1f:	c3                   	ret    

00801d20 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d20:	55                   	push   %ebp
  801d21:	89 e5                	mov    %esp,%ebp
  801d23:	53                   	push   %ebx
  801d24:	83 ec 14             	sub    $0x14,%esp
  801d27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2d:	a3 00 50 80 00       	mov    %eax,0x805000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d32:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d36:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d39:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d3d:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  801d44:	e8 5f ec ff ff       	call   8009a8 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d49:	89 1d 14 50 80 00    	mov    %ebx,0x805014
	return nsipc(NSREQ_BIND);
  801d4f:	b8 02 00 00 00       	mov    $0x2,%eax
  801d54:	e8 c7 fd ff ff       	call   801b20 <nsipc>
}
  801d59:	83 c4 14             	add    $0x14,%esp
  801d5c:	5b                   	pop    %ebx
  801d5d:	5d                   	pop    %ebp
  801d5e:	c3                   	ret    

00801d5f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d5f:	55                   	push   %ebp
  801d60:	89 e5                	mov    %esp,%ebp
  801d62:	53                   	push   %ebx
  801d63:	83 ec 14             	sub    $0x14,%esp
	int r;
	
	nsipcbuf.accept.req_s = s;
  801d66:	8b 45 08             	mov    0x8(%ebp),%eax
  801d69:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d6e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d73:	e8 a8 fd ff ff       	call   801b20 <nsipc>
  801d78:	89 c3                	mov    %eax,%ebx
  801d7a:	85 c0                	test   %eax,%eax
  801d7c:	78 26                	js     801da4 <nsipc_accept+0x45>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d7e:	a1 10 50 80 00       	mov    0x805010,%eax
  801d83:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d87:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801d8e:	00 
  801d8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d92:	89 04 24             	mov    %eax,(%esp)
  801d95:	e8 0e ec ff ff       	call   8009a8 <memmove>
		*addrlen = ret->ret_addrlen;
  801d9a:	a1 10 50 80 00       	mov    0x805010,%eax
  801d9f:	8b 55 10             	mov    0x10(%ebp),%edx
  801da2:	89 02                	mov    %eax,(%edx)
	}
	return r;
}
  801da4:	89 d8                	mov    %ebx,%eax
  801da6:	83 c4 14             	add    $0x14,%esp
  801da9:	5b                   	pop    %ebx
  801daa:	5d                   	pop    %ebp
  801dab:	c3                   	ret    

00801dac <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  801dac:	55                   	push   %ebp
  801dad:	89 e5                	mov    %esp,%ebp
  801daf:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  801db2:	8d 45 14             	lea    0x14(%ebp),%eax
  801db5:	89 45 fc             	mov    %eax,-0x4(%ebp)

	// Print the panic message
	if (argv0)
  801db8:	a1 40 60 80 00       	mov    0x806040,%eax
  801dbd:	85 c0                	test   %eax,%eax
  801dbf:	74 10                	je     801dd1 <_panic+0x25>
		cprintf("%s: ", argv0);
  801dc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dc5:	c7 04 24 a6 26 80 00 	movl   $0x8026a6,(%esp)
  801dcc:	e8 68 e3 ff ff       	call   800139 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  801dd1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dd8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ddf:	a1 00 60 80 00       	mov    0x806000,%eax
  801de4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801de8:	c7 04 24 ab 26 80 00 	movl   $0x8026ab,(%esp)
  801def:	e8 45 e3 ff ff       	call   800139 <cprintf>
	vcprintf(fmt, ap);
  801df4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801df7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dfb:	8b 45 10             	mov    0x10(%ebp),%eax
  801dfe:	89 04 24             	mov    %eax,(%esp)
  801e01:	e8 d2 e2 ff ff       	call   8000d8 <vcprintf>
	cprintf("\n");
  801e06:	c7 04 24 09 27 80 00 	movl   $0x802709,(%esp)
  801e0d:	e8 27 e3 ff ff       	call   800139 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e12:	cc                   	int3   
  801e13:	eb fd                	jmp    801e12 <_panic+0x66>
	...

00801e20 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e20:	55                   	push   %ebp
  801e21:	89 e5                	mov    %esp,%ebp
  801e23:	57                   	push   %edi
  801e24:	56                   	push   %esi
  801e25:	53                   	push   %ebx
  801e26:	83 ec 1c             	sub    $0x1c,%esp
  801e29:	8b 75 08             	mov    0x8(%ebp),%esi
  801e2c:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  801e2f:	e8 39 f1 ff ff       	call   800f6d <sys_getenvid>
  801e34:	25 ff 03 00 00       	and    $0x3ff,%eax
  801e39:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e3c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e41:	a3 3c 60 80 00       	mov    %eax,0x80603c
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  801e46:	e8 22 f1 ff ff       	call   800f6d <sys_getenvid>
  801e4b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801e50:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e53:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e58:	a3 3c 60 80 00       	mov    %eax,0x80603c
		if(env->env_id==to_env){
  801e5d:	8b 40 4c             	mov    0x4c(%eax),%eax
  801e60:	39 f0                	cmp    %esi,%eax
  801e62:	75 0e                	jne    801e72 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  801e64:	c7 04 24 c7 26 80 00 	movl   $0x8026c7,(%esp)
  801e6b:	e8 c9 e2 ff ff       	call   800139 <cprintf>
  801e70:	eb 5a                	jmp    801ecc <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  801e72:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e76:	8b 45 10             	mov    0x10(%ebp),%eax
  801e79:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e80:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e84:	89 34 24             	mov    %esi,(%esp)
  801e87:	e8 40 ee ff ff       	call   800ccc <sys_ipc_try_send>
  801e8c:	89 c3                	mov    %eax,%ebx
  801e8e:	85 c0                	test   %eax,%eax
  801e90:	79 25                	jns    801eb7 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  801e92:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e95:	74 2b                	je     801ec2 <ipc_send+0xa2>
				panic("send error:%e",r);
  801e97:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e9b:	c7 44 24 08 e3 26 80 	movl   $0x8026e3,0x8(%esp)
  801ea2:	00 
  801ea3:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  801eaa:	00 
  801eab:	c7 04 24 f1 26 80 00 	movl   $0x8026f1,(%esp)
  801eb2:	e8 f5 fe ff ff       	call   801dac <_panic>
		}
			sys_yield();
  801eb7:	e8 7d f0 ff ff       	call   800f39 <sys_yield>
		
	}while(r!=0);
  801ebc:	85 db                	test   %ebx,%ebx
  801ebe:	75 86                	jne    801e46 <ipc_send+0x26>
  801ec0:	eb 0a                	jmp    801ecc <ipc_send+0xac>
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
		{	
			if(r!=-E_IPC_NOT_RECV)
				panic("send error:%e",r);
		}
			sys_yield();
  801ec2:	e8 72 f0 ff ff       	call   800f39 <sys_yield>
  801ec7:	e9 7a ff ff ff       	jmp    801e46 <ipc_send+0x26>
		
	}while(r!=0);
	return;
	//panic("ipc_send not implemented");
}
  801ecc:	83 c4 1c             	add    $0x1c,%esp
  801ecf:	5b                   	pop    %ebx
  801ed0:	5e                   	pop    %esi
  801ed1:	5f                   	pop    %edi
  801ed2:	5d                   	pop    %ebp
  801ed3:	c3                   	ret    

00801ed4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ed4:	55                   	push   %ebp
  801ed5:	89 e5                	mov    %esp,%ebp
  801ed7:	57                   	push   %edi
  801ed8:	56                   	push   %esi
  801ed9:	53                   	push   %ebx
  801eda:	83 ec 0c             	sub    $0xc,%esp
  801edd:	8b 75 08             	mov    0x8(%ebp),%esi
  801ee0:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	void *dstva=NULL;
	if(pg)
		dstva=pg;
	env = &envs[ENVX(sys_getenvid())];
  801ee3:	e8 85 f0 ff ff       	call   800f6d <sys_getenvid>
  801ee8:	25 ff 03 00 00       	and    $0x3ff,%eax
  801eed:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ef0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ef5:	a3 3c 60 80 00       	mov    %eax,0x80603c
	if(from_env_store&&(env->env_id==*from_env_store))
  801efa:	85 f6                	test   %esi,%esi
  801efc:	74 29                	je     801f27 <ipc_recv+0x53>
  801efe:	8b 40 4c             	mov    0x4c(%eax),%eax
  801f01:	3b 06                	cmp    (%esi),%eax
  801f03:	75 22                	jne    801f27 <ipc_recv+0x53>
	{
		*from_env_store=0;
  801f05:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  801f0b:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("send:the reciver is sender\n");
  801f11:	c7 04 24 c7 26 80 00 	movl   $0x8026c7,(%esp)
  801f18:	e8 1c e2 ff ff       	call   800139 <cprintf>
  801f1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f22:	e9 8a 00 00 00       	jmp    801fb1 <ipc_recv+0xdd>
		return 0;
	}
	env = &envs[ENVX(sys_getenvid())];
  801f27:	e8 41 f0 ff ff       	call   800f6d <sys_getenvid>
  801f2c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801f31:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f34:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f39:	a3 3c 60 80 00       	mov    %eax,0x80603c
	if((r=sys_ipc_recv(dstva))<0)
  801f3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f41:	89 04 24             	mov    %eax,(%esp)
  801f44:	e8 26 ed ff ff       	call   800c6f <sys_ipc_recv>
  801f49:	89 c3                	mov    %eax,%ebx
  801f4b:	85 c0                	test   %eax,%eax
  801f4d:	79 1a                	jns    801f69 <ipc_recv+0x95>
	{
		*from_env_store=0;
  801f4f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  801f55:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("reciver failed\n");
  801f5b:	c7 04 24 fb 26 80 00 	movl   $0x8026fb,(%esp)
  801f62:	e8 d2 e1 ff ff       	call   800139 <cprintf>
  801f67:	eb 48                	jmp    801fb1 <ipc_recv+0xdd>
		return r;
	}
	else{//接收成功
		env = &envs[ENVX(sys_getenvid())];
  801f69:	e8 ff ef ff ff       	call   800f6d <sys_getenvid>
  801f6e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801f73:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f76:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f7b:	a3 3c 60 80 00       	mov    %eax,0x80603c
		if(from_env_store)
  801f80:	85 f6                	test   %esi,%esi
  801f82:	74 05                	je     801f89 <ipc_recv+0xb5>
			*from_env_store=env->env_ipc_from;	
  801f84:	8b 40 74             	mov    0x74(%eax),%eax
  801f87:	89 06                	mov    %eax,(%esi)
		if(perm_store)
  801f89:	85 ff                	test   %edi,%edi
  801f8b:	74 0a                	je     801f97 <ipc_recv+0xc3>
			*perm_store=env->env_ipc_perm;
  801f8d:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801f92:	8b 40 78             	mov    0x78(%eax),%eax
  801f95:	89 07                	mov    %eax,(%edi)
		env = &envs[ENVX(sys_getenvid())];
  801f97:	e8 d1 ef ff ff       	call   800f6d <sys_getenvid>
  801f9c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801fa1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fa4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fa9:	a3 3c 60 80 00       	mov    %eax,0x80603c
		return env->env_ipc_value;
  801fae:	8b 58 70             	mov    0x70(%eax),%ebx
	}
	//panic("ipc_recv not implemented");
	return 0;
}
  801fb1:	89 d8                	mov    %ebx,%eax
  801fb3:	83 c4 0c             	add    $0xc,%esp
  801fb6:	5b                   	pop    %ebx
  801fb7:	5e                   	pop    %esi
  801fb8:	5f                   	pop    %edi
  801fb9:	5d                   	pop    %ebp
  801fba:	c3                   	ret    
  801fbb:	00 00                	add    %al,(%eax)
  801fbd:	00 00                	add    %al,(%eax)
	...

00801fc0 <__udivdi3>:
  801fc0:	55                   	push   %ebp
  801fc1:	89 e5                	mov    %esp,%ebp
  801fc3:	57                   	push   %edi
  801fc4:	56                   	push   %esi
  801fc5:	83 ec 18             	sub    $0x18,%esp
  801fc8:	8b 45 10             	mov    0x10(%ebp),%eax
  801fcb:	8b 55 14             	mov    0x14(%ebp),%edx
  801fce:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fd1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801fd4:	89 c1                	mov    %eax,%ecx
  801fd6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd9:	85 d2                	test   %edx,%edx
  801fdb:	89 d7                	mov    %edx,%edi
  801fdd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801fe0:	75 1e                	jne    802000 <__udivdi3+0x40>
  801fe2:	39 f1                	cmp    %esi,%ecx
  801fe4:	0f 86 8d 00 00 00    	jbe    802077 <__udivdi3+0xb7>
  801fea:	89 f2                	mov    %esi,%edx
  801fec:	31 f6                	xor    %esi,%esi
  801fee:	f7 f1                	div    %ecx
  801ff0:	89 c1                	mov    %eax,%ecx
  801ff2:	89 c8                	mov    %ecx,%eax
  801ff4:	89 f2                	mov    %esi,%edx
  801ff6:	83 c4 18             	add    $0x18,%esp
  801ff9:	5e                   	pop    %esi
  801ffa:	5f                   	pop    %edi
  801ffb:	5d                   	pop    %ebp
  801ffc:	c3                   	ret    
  801ffd:	8d 76 00             	lea    0x0(%esi),%esi
  802000:	39 f2                	cmp    %esi,%edx
  802002:	0f 87 a8 00 00 00    	ja     8020b0 <__udivdi3+0xf0>
  802008:	0f bd c2             	bsr    %edx,%eax
  80200b:	83 f0 1f             	xor    $0x1f,%eax
  80200e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802011:	0f 84 89 00 00 00    	je     8020a0 <__udivdi3+0xe0>
  802017:	b8 20 00 00 00       	mov    $0x20,%eax
  80201c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80201f:	2b 45 e8             	sub    -0x18(%ebp),%eax
  802022:	89 c1                	mov    %eax,%ecx
  802024:	d3 ea                	shr    %cl,%edx
  802026:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  80202a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80202d:	89 f8                	mov    %edi,%eax
  80202f:	8b 7d f4             	mov    -0xc(%ebp),%edi
  802032:	d3 e0                	shl    %cl,%eax
  802034:	09 c2                	or     %eax,%edx
  802036:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802039:	d3 e7                	shl    %cl,%edi
  80203b:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80203f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802042:	89 f2                	mov    %esi,%edx
  802044:	d3 e8                	shr    %cl,%eax
  802046:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  80204a:	d3 e2                	shl    %cl,%edx
  80204c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802050:	09 d0                	or     %edx,%eax
  802052:	d3 ee                	shr    %cl,%esi
  802054:	89 f2                	mov    %esi,%edx
  802056:	f7 75 e4             	divl   -0x1c(%ebp)
  802059:	89 d1                	mov    %edx,%ecx
  80205b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80205e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802061:	f7 e7                	mul    %edi
  802063:	39 d1                	cmp    %edx,%ecx
  802065:	89 c6                	mov    %eax,%esi
  802067:	72 70                	jb     8020d9 <__udivdi3+0x119>
  802069:	39 ca                	cmp    %ecx,%edx
  80206b:	74 5f                	je     8020cc <__udivdi3+0x10c>
  80206d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802070:	31 f6                	xor    %esi,%esi
  802072:	e9 7b ff ff ff       	jmp    801ff2 <__udivdi3+0x32>
  802077:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80207a:	85 c0                	test   %eax,%eax
  80207c:	75 0c                	jne    80208a <__udivdi3+0xca>
  80207e:	b8 01 00 00 00       	mov    $0x1,%eax
  802083:	31 d2                	xor    %edx,%edx
  802085:	f7 75 f4             	divl   -0xc(%ebp)
  802088:	89 c1                	mov    %eax,%ecx
  80208a:	89 f0                	mov    %esi,%eax
  80208c:	89 fa                	mov    %edi,%edx
  80208e:	f7 f1                	div    %ecx
  802090:	89 c6                	mov    %eax,%esi
  802092:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802095:	f7 f1                	div    %ecx
  802097:	89 c1                	mov    %eax,%ecx
  802099:	e9 54 ff ff ff       	jmp    801ff2 <__udivdi3+0x32>
  80209e:	66 90                	xchg   %ax,%ax
  8020a0:	39 d6                	cmp    %edx,%esi
  8020a2:	77 1c                	ja     8020c0 <__udivdi3+0x100>
  8020a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020a7:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  8020aa:	73 14                	jae    8020c0 <__udivdi3+0x100>
  8020ac:	8d 74 26 00          	lea    0x0(%esi),%esi
  8020b0:	31 c9                	xor    %ecx,%ecx
  8020b2:	31 f6                	xor    %esi,%esi
  8020b4:	e9 39 ff ff ff       	jmp    801ff2 <__udivdi3+0x32>
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  8020c0:	b9 01 00 00 00       	mov    $0x1,%ecx
  8020c5:	31 f6                	xor    %esi,%esi
  8020c7:	e9 26 ff ff ff       	jmp    801ff2 <__udivdi3+0x32>
  8020cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8020cf:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  8020d3:	d3 e0                	shl    %cl,%eax
  8020d5:	39 c6                	cmp    %eax,%esi
  8020d7:	76 94                	jbe    80206d <__udivdi3+0xad>
  8020d9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8020dc:	31 f6                	xor    %esi,%esi
  8020de:	83 e9 01             	sub    $0x1,%ecx
  8020e1:	e9 0c ff ff ff       	jmp    801ff2 <__udivdi3+0x32>
	...

008020f0 <__umoddi3>:
  8020f0:	55                   	push   %ebp
  8020f1:	89 e5                	mov    %esp,%ebp
  8020f3:	57                   	push   %edi
  8020f4:	56                   	push   %esi
  8020f5:	83 ec 30             	sub    $0x30,%esp
  8020f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8020fb:	8b 55 14             	mov    0x14(%ebp),%edx
  8020fe:	8b 75 08             	mov    0x8(%ebp),%esi
  802101:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802104:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802107:	89 c1                	mov    %eax,%ecx
  802109:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80210c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80210f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  802116:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80211d:	89 fa                	mov    %edi,%edx
  80211f:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  802122:	85 c0                	test   %eax,%eax
  802124:	89 75 f0             	mov    %esi,-0x10(%ebp)
  802127:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80212a:	75 14                	jne    802140 <__umoddi3+0x50>
  80212c:	39 f9                	cmp    %edi,%ecx
  80212e:	76 60                	jbe    802190 <__umoddi3+0xa0>
  802130:	89 f0                	mov    %esi,%eax
  802132:	f7 f1                	div    %ecx
  802134:	89 55 d0             	mov    %edx,-0x30(%ebp)
  802137:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80213e:	eb 10                	jmp    802150 <__umoddi3+0x60>
  802140:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802143:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  802146:	76 18                	jbe    802160 <__umoddi3+0x70>
  802148:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80214b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80214e:	66 90                	xchg   %ax,%ax
  802150:	8b 45 d0             	mov    -0x30(%ebp),%eax
  802153:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  802156:	83 c4 30             	add    $0x30,%esp
  802159:	5e                   	pop    %esi
  80215a:	5f                   	pop    %edi
  80215b:	5d                   	pop    %ebp
  80215c:	c3                   	ret    
  80215d:	8d 76 00             	lea    0x0(%esi),%esi
  802160:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
  802164:	83 f0 1f             	xor    $0x1f,%eax
  802167:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80216a:	75 46                	jne    8021b2 <__umoddi3+0xc2>
  80216c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80216f:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  802172:	0f 87 c9 00 00 00    	ja     802241 <__umoddi3+0x151>
  802178:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  80217b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80217e:	0f 83 bd 00 00 00    	jae    802241 <__umoddi3+0x151>
  802184:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802187:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80218a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80218d:	eb c1                	jmp    802150 <__umoddi3+0x60>
  80218f:	90                   	nop    
  802190:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802193:	85 c0                	test   %eax,%eax
  802195:	75 0c                	jne    8021a3 <__umoddi3+0xb3>
  802197:	b8 01 00 00 00       	mov    $0x1,%eax
  80219c:	31 d2                	xor    %edx,%edx
  80219e:	f7 75 ec             	divl   -0x14(%ebp)
  8021a1:	89 c1                	mov    %eax,%ecx
  8021a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021a6:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8021a9:	f7 f1                	div    %ecx
  8021ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021ae:	f7 f1                	div    %ecx
  8021b0:	eb 82                	jmp    802134 <__umoddi3+0x44>
  8021b2:	b8 20 00 00 00       	mov    $0x20,%eax
  8021b7:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8021ba:	2b 45 d8             	sub    -0x28(%ebp),%eax
  8021bd:	8b 75 ec             	mov    -0x14(%ebp),%esi
  8021c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8021c3:	89 c1                	mov    %eax,%ecx
  8021c5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8021c8:	d3 ea                	shr    %cl,%edx
  8021ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8021cd:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8021d1:	d3 e0                	shl    %cl,%eax
  8021d3:	09 c2                	or     %eax,%edx
  8021d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021d8:	d3 e6                	shl    %cl,%esi
  8021da:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  8021de:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8021e1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8021e4:	d3 e8                	shr    %cl,%eax
  8021e6:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8021ea:	d3 e2                	shl    %cl,%edx
  8021ec:	09 d0                	or     %edx,%eax
  8021ee:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8021f1:	d3 e7                	shl    %cl,%edi
  8021f3:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  8021f7:	d3 ea                	shr    %cl,%edx
  8021f9:	f7 75 f4             	divl   -0xc(%ebp)
  8021fc:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8021ff:	f7 e6                	mul    %esi
  802201:	39 55 cc             	cmp    %edx,-0x34(%ebp)
  802204:	72 53                	jb     802259 <__umoddi3+0x169>
  802206:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  802209:	74 4a                	je     802255 <__umoddi3+0x165>
  80220b:	90                   	nop    
  80220c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802210:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  802213:	29 c7                	sub    %eax,%edi
  802215:	19 d1                	sbb    %edx,%ecx
  802217:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80221a:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  80221e:	89 fa                	mov    %edi,%edx
  802220:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802223:	d3 ea                	shr    %cl,%edx
  802225:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  802229:	d3 e0                	shl    %cl,%eax
  80222b:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  80222f:	09 c2                	or     %eax,%edx
  802231:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802234:	89 55 d0             	mov    %edx,-0x30(%ebp)
  802237:	d3 e8                	shr    %cl,%eax
  802239:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80223c:	e9 0f ff ff ff       	jmp    802150 <__umoddi3+0x60>
  802241:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802244:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802247:	2b 45 ec             	sub    -0x14(%ebp),%eax
  80224a:	1b 55 e8             	sbb    -0x18(%ebp),%edx
  80224d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802250:	e9 2f ff ff ff       	jmp    802184 <__umoddi3+0x94>
  802255:	39 f8                	cmp    %edi,%eax
  802257:	76 b7                	jbe    802210 <__umoddi3+0x120>
  802259:	29 f0                	sub    %esi,%eax
  80225b:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  80225e:	eb b0                	jmp    802210 <__umoddi3+0x120>
