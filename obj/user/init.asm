
obj/user/init:     file format elf32-i386

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
  80002c:	e8 1b 01 00 00       	call   80014c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	8b 75 08             	mov    0x8(%ebp),%esi
  80003c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
	for (i = 0; i < n; i++)
  80003f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800044:	85 db                	test   %ebx,%ebx
  800046:	7e 1a                	jle    800062 <sum+0x2e>
  800048:	ba 00 00 00 00       	mov    $0x0,%edx
  80004d:	b9 00 00 00 00       	mov    $0x0,%ecx
		tot ^= i * s[i];
  800052:	0f be 04 32          	movsbl (%edx,%esi,1),%eax
  800056:	0f af c2             	imul   %edx,%eax
  800059:	31 c1                	xor    %eax,%ecx

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  80005b:	83 c2 01             	add    $0x1,%edx
  80005e:	39 da                	cmp    %ebx,%edx
  800060:	75 f0                	jne    800052 <sum+0x1e>
		tot ^= i * s[i];
	return tot;
}
  800062:	89 c8                	mov    %ecx,%eax
  800064:	5b                   	pop    %ebx
  800065:	5e                   	pop    %esi
  800066:	5d                   	pop    %ebp
  800067:	c3                   	ret    

00800068 <umain>:
		
void
umain(int argc, char **argv)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	57                   	push   %edi
  80006c:	56                   	push   %esi
  80006d:	53                   	push   %ebx
  80006e:	83 ec 0c             	sub    $0xc,%esp
  800071:	8b 75 08             	mov    0x8(%ebp),%esi
  800074:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r, x, want;

	cprintf("init: running\n");
  800077:	c7 04 24 80 1e 80 00 	movl   $0x801e80,(%esp)
  80007e:	e8 a2 01 00 00       	call   800225 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800083:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800092:	e8 9d ff ff ff       	call   800034 <sum>
  800097:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  80009c:	74 1a                	je     8000b8 <umain+0x50>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  80009e:	c7 44 24 08 9e 98 0f 	movl   $0xf989e,0x8(%esp)
  8000a5:	00 
  8000a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000aa:	c7 04 24 e0 1e 80 00 	movl   $0x801ee0,(%esp)
  8000b1:	e8 6f 01 00 00       	call   800225 <cprintf>
  8000b6:	eb 0c                	jmp    8000c4 <umain+0x5c>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000b8:	c7 04 24 8f 1e 80 00 	movl   $0x801e8f,(%esp)
  8000bf:	e8 61 01 00 00       	call   800225 <cprintf>
	if ((x = sum(bss, sizeof bss)) != 0)
  8000c4:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  8000cb:	00 
  8000cc:	c7 04 24 a0 67 80 00 	movl   $0x8067a0,(%esp)
  8000d3:	e8 5c ff ff ff       	call   800034 <sum>
  8000d8:	85 c0                	test   %eax,%eax
  8000da:	74 12                	je     8000ee <umain+0x86>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000e0:	c7 04 24 1c 1f 80 00 	movl   $0x801f1c,(%esp)
  8000e7:	e8 39 01 00 00       	call   800225 <cprintf>
  8000ec:	eb 0c                	jmp    8000fa <umain+0x92>
	else
		cprintf("init: bss seems okay\n");
  8000ee:	c7 04 24 a6 1e 80 00 	movl   $0x801ea6,(%esp)
  8000f5:	e8 2b 01 00 00       	call   800225 <cprintf>

	cprintf("init: args:");
  8000fa:	c7 04 24 bc 1e 80 00 	movl   $0x801ebc,(%esp)
  800101:	e8 1f 01 00 00       	call   800225 <cprintf>
	for (i = 0; i < argc; i++)
  800106:	85 f6                	test   %esi,%esi
  800108:	7e 1f                	jle    800129 <umain+0xc1>
  80010a:	bb 00 00 00 00       	mov    $0x0,%ebx
		cprintf(" '%s'", argv[i]);
  80010f:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  800112:	89 44 24 04          	mov    %eax,0x4(%esp)
  800116:	c7 04 24 c8 1e 80 00 	movl   $0x801ec8,(%esp)
  80011d:	e8 03 01 00 00       	call   800225 <cprintf>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
	else
		cprintf("init: bss seems okay\n");

	cprintf("init: args:");
	for (i = 0; i < argc; i++)
  800122:	83 c3 01             	add    $0x1,%ebx
  800125:	39 f3                	cmp    %esi,%ebx
  800127:	75 e6                	jne    80010f <umain+0xa7>
		cprintf(" '%s'", argv[i]);
	cprintf("\n");
  800129:	c7 04 24 1f 23 80 00 	movl   $0x80231f,(%esp)
  800130:	e8 f0 00 00 00       	call   800225 <cprintf>

	cprintf("init: exiting\n");
  800135:	c7 04 24 ce 1e 80 00 	movl   $0x801ece,(%esp)
  80013c:	e8 e4 00 00 00       	call   800225 <cprintf>
}
  800141:	83 c4 0c             	add    $0xc,%esp
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    
  800149:	00 00                	add    %al,(%eax)
	...

0080014c <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
  800152:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800155:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800158:	8b 75 08             	mov    0x8(%ebp),%esi
  80015b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  80015e:	c7 05 10 7f 80 00 00 	movl   $0x0,0x807f10
  800165:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  800168:	e8 bc 0e 00 00       	call   801029 <sys_getenvid>
  80016d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800172:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800175:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80017a:	a3 10 7f 80 00       	mov    %eax,0x807f10
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80017f:	85 f6                	test   %esi,%esi
  800181:	7e 07                	jle    80018a <libmain+0x3e>
		binaryname = argv[0];
  800183:	8b 03                	mov    (%ebx),%eax
  800185:	a3 70 67 80 00       	mov    %eax,0x806770

	// call user main routine
	umain(argc, argv);
  80018a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80018e:	89 34 24             	mov    %esi,(%esp)
  800191:	e8 d2 fe ff ff       	call   800068 <umain>

	// exit gracefully
	exit();
  800196:	e8 0d 00 00 00       	call   8001a8 <exit>
}
  80019b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80019e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8001a1:	89 ec                	mov    %ebp,%esp
  8001a3:	5d                   	pop    %ebp
  8001a4:	c3                   	ret    
  8001a5:	00 00                	add    %al,(%eax)
	...

008001a8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001ae:	e8 fd 14 00 00       	call   8016b0 <close_all>
	sys_env_destroy(0);
  8001b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ba:	e8 9e 0e 00 00       	call   80105d <sys_env_destroy>
}
  8001bf:	c9                   	leave  
  8001c0:	c3                   	ret    
  8001c1:	00 00                	add    %al,(%eax)
	...

008001c4 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001cd:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  8001d4:	00 00 00 
	b.cnt = 0;
  8001d7:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  8001de:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ef:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f9:	c7 04 24 42 02 80 00 	movl   $0x800242,(%esp)
  800200:	e8 d0 01 00 00       	call   8003d5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800205:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
  80020b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020f:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  800215:	89 04 24             	mov    %eax,(%esp)
  800218:	e8 db 0a 00 00       	call   800cf8 <sys_cputs>
  80021d:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  800223:	c9                   	leave  
  800224:	c3                   	ret    

00800225 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022b:	8d 45 0c             	lea    0xc(%ebp),%eax
  80022e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800231:	89 44 24 04          	mov    %eax,0x4(%esp)
  800235:	8b 45 08             	mov    0x8(%ebp),%eax
  800238:	89 04 24             	mov    %eax,(%esp)
  80023b:	e8 84 ff ff ff       	call   8001c4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800240:	c9                   	leave  
  800241:	c3                   	ret    

00800242 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800242:	55                   	push   %ebp
  800243:	89 e5                	mov    %esp,%ebp
  800245:	53                   	push   %ebx
  800246:	83 ec 14             	sub    $0x14,%esp
  800249:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80024c:	8b 03                	mov    (%ebx),%eax
  80024e:	8b 55 08             	mov    0x8(%ebp),%edx
  800251:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800255:	83 c0 01             	add    $0x1,%eax
  800258:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80025a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80025f:	75 19                	jne    80027a <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800261:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800268:	00 
  800269:	8d 43 08             	lea    0x8(%ebx),%eax
  80026c:	89 04 24             	mov    %eax,(%esp)
  80026f:	e8 84 0a 00 00       	call   800cf8 <sys_cputs>
		b->idx = 0;
  800274:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80027a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80027e:	83 c4 14             	add    $0x14,%esp
  800281:	5b                   	pop    %ebx
  800282:	5d                   	pop    %ebp
  800283:	c3                   	ret    
	...

00800290 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	57                   	push   %edi
  800294:	56                   	push   %esi
  800295:	53                   	push   %ebx
  800296:	83 ec 3c             	sub    $0x3c,%esp
  800299:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80029c:	89 d7                	mov    %edx,%edi
  80029e:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002aa:	8b 55 10             	mov    0x10(%ebp),%edx
  8002ad:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b0:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8002b3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  8002ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002bd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  8002c0:	72 14                	jb     8002d6 <printnum+0x46>
  8002c2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002c5:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  8002c8:	76 0c                	jbe    8002d6 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ca:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002cd:	83 eb 01             	sub    $0x1,%ebx
  8002d0:	85 db                	test   %ebx,%ebx
  8002d2:	7f 57                	jg     80032b <printnum+0x9b>
  8002d4:	eb 64                	jmp    80033a <printnum+0xaa>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d6:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002da:	8b 45 14             	mov    0x14(%ebp),%eax
  8002dd:	83 e8 01             	sub    $0x1,%eax
  8002e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002e4:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002e8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002ec:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8002f3:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8002f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002fa:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002fe:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800301:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800304:	89 04 24             	mov    %eax,(%esp)
  800307:	89 54 24 04          	mov    %edx,0x4(%esp)
  80030b:	e8 c0 18 00 00       	call   801bd0 <__udivdi3>
  800310:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800314:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800318:	89 04 24             	mov    %eax,(%esp)
  80031b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80031f:	89 fa                	mov    %edi,%edx
  800321:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800324:	e8 67 ff ff ff       	call   800290 <printnum>
  800329:	eb 0f                	jmp    80033a <printnum+0xaa>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80032f:	89 34 24             	mov    %esi,(%esp)
  800332:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800335:	83 eb 01             	sub    $0x1,%ebx
  800338:	75 f1                	jne    80032b <printnum+0x9b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80033a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80033e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800342:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800345:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800348:	89 44 24 08          	mov    %eax,0x8(%esp)
  80034c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800350:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800353:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800356:	89 04 24             	mov    %eax,(%esp)
  800359:	89 54 24 04          	mov    %edx,0x4(%esp)
  80035d:	e8 9e 19 00 00       	call   801d00 <__umoddi3>
  800362:	89 74 24 04          	mov    %esi,0x4(%esp)
  800366:	0f be 80 62 1f 80 00 	movsbl 0x801f62(%eax),%eax
  80036d:	89 04 24             	mov    %eax,(%esp)
  800370:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800373:	83 c4 3c             	add    $0x3c,%esp
  800376:	5b                   	pop    %ebx
  800377:	5e                   	pop    %esi
  800378:	5f                   	pop    %edi
  800379:	5d                   	pop    %ebp
  80037a:	c3                   	ret    

0080037b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800380:	83 fa 01             	cmp    $0x1,%edx
  800383:	7e 0e                	jle    800393 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  800385:	8b 10                	mov    (%eax),%edx
  800387:	8d 42 08             	lea    0x8(%edx),%eax
  80038a:	89 01                	mov    %eax,(%ecx)
  80038c:	8b 02                	mov    (%edx),%eax
  80038e:	8b 52 04             	mov    0x4(%edx),%edx
  800391:	eb 22                	jmp    8003b5 <getuint+0x3a>
	else if (lflag)
  800393:	85 d2                	test   %edx,%edx
  800395:	74 10                	je     8003a7 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800397:	8b 10                	mov    (%eax),%edx
  800399:	8d 42 04             	lea    0x4(%edx),%eax
  80039c:	89 01                	mov    %eax,(%ecx)
  80039e:	8b 02                	mov    (%edx),%eax
  8003a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a5:	eb 0e                	jmp    8003b5 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  8003a7:	8b 10                	mov    (%eax),%edx
  8003a9:	8d 42 04             	lea    0x4(%edx),%eax
  8003ac:	89 01                	mov    %eax,(%ecx)
  8003ae:	8b 02                	mov    (%edx),%eax
  8003b0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003b5:	5d                   	pop    %ebp
  8003b6:	c3                   	ret    

008003b7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  8003bd:	83 42 08 01          	addl   $0x1,0x8(%edx)
	if (b->buf < b->ebuf)
  8003c1:	8b 02                	mov    (%edx),%eax
  8003c3:	3b 42 04             	cmp    0x4(%edx),%eax
  8003c6:	73 0b                	jae    8003d3 <sprintputch+0x1c>
		*b->buf++ = ch;
  8003c8:	0f b6 4d 08          	movzbl 0x8(%ebp),%ecx
  8003cc:	88 08                	mov    %cl,(%eax)
  8003ce:	83 c0 01             	add    $0x1,%eax
  8003d1:	89 02                	mov    %eax,(%edx)
}
  8003d3:	5d                   	pop    %ebp
  8003d4:	c3                   	ret    

008003d5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003d5:	55                   	push   %ebp
  8003d6:	89 e5                	mov    %esp,%ebp
  8003d8:	57                   	push   %edi
  8003d9:	56                   	push   %esi
  8003da:	53                   	push   %ebx
  8003db:	83 ec 3c             	sub    $0x3c,%esp
  8003de:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003e1:	eb 18                	jmp    8003fb <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003e3:	84 c0                	test   %al,%al
  8003e5:	0f 84 9f 03 00 00    	je     80078a <vprintfmt+0x3b5>
				return;
			putch(ch, putdat);
  8003eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003f2:	0f b6 c0             	movzbl %al,%eax
  8003f5:	89 04 24             	mov    %eax,(%esp)
  8003f8:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003fb:	0f b6 03             	movzbl (%ebx),%eax
  8003fe:	83 c3 01             	add    $0x1,%ebx
  800401:	3c 25                	cmp    $0x25,%al
  800403:	75 de                	jne    8003e3 <vprintfmt+0xe>
  800405:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040a:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
  800411:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800416:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80041d:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
  800421:	eb 07                	jmp    80042a <vprintfmt+0x55>
  800423:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	0f b6 13             	movzbl (%ebx),%edx
  80042d:	83 c3 01             	add    $0x1,%ebx
  800430:	8d 42 dd             	lea    -0x23(%edx),%eax
  800433:	3c 55                	cmp    $0x55,%al
  800435:	0f 87 22 03 00 00    	ja     80075d <vprintfmt+0x388>
  80043b:	0f b6 c0             	movzbl %al,%eax
  80043e:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
  800445:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
  800449:	eb df                	jmp    80042a <vprintfmt+0x55>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80044b:	0f b6 c2             	movzbl %dl,%eax
  80044e:	8d 78 d0             	lea    -0x30(%eax),%edi
				ch = *fmt;
  800451:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800454:	8d 42 d0             	lea    -0x30(%edx),%eax
  800457:	83 f8 09             	cmp    $0x9,%eax
  80045a:	76 08                	jbe    800464 <vprintfmt+0x8f>
  80045c:	eb 39                	jmp    800497 <vprintfmt+0xc2>
  80045e:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
  800462:	eb c6                	jmp    80042a <vprintfmt+0x55>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800464:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800467:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  80046a:	8d 7c 42 d0          	lea    -0x30(%edx,%eax,2),%edi
				ch = *fmt;
  80046e:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800471:	8d 42 d0             	lea    -0x30(%edx),%eax
  800474:	83 f8 09             	cmp    $0x9,%eax
  800477:	77 1e                	ja     800497 <vprintfmt+0xc2>
  800479:	eb e9                	jmp    800464 <vprintfmt+0x8f>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80047b:	8b 55 14             	mov    0x14(%ebp),%edx
  80047e:	8d 42 04             	lea    0x4(%edx),%eax
  800481:	89 45 14             	mov    %eax,0x14(%ebp)
  800484:	8b 3a                	mov    (%edx),%edi
  800486:	eb 0f                	jmp    800497 <vprintfmt+0xc2>
			goto process_precision;

		case '.':
			if (width < 0)
  800488:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80048c:	79 9c                	jns    80042a <vprintfmt+0x55>
  80048e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800495:	eb 93                	jmp    80042a <vprintfmt+0x55>
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800497:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80049b:	90                   	nop    
  80049c:	8d 74 26 00          	lea    0x0(%esi),%esi
  8004a0:	79 88                	jns    80042a <vprintfmt+0x55>
  8004a2:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8004a5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8004aa:	e9 7b ff ff ff       	jmp    80042a <vprintfmt+0x55>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004af:	83 c1 01             	add    $0x1,%ecx
  8004b2:	e9 73 ff ff ff       	jmp    80042a <vprintfmt+0x55>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ba:	8d 50 04             	lea    0x4(%eax),%edx
  8004bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004c7:	8b 00                	mov    (%eax),%eax
  8004c9:	89 04 24             	mov    %eax,(%esp)
  8004cc:	ff 55 08             	call   *0x8(%ebp)
  8004cf:	e9 27 ff ff ff       	jmp    8003fb <vprintfmt+0x26>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004d4:	8b 55 14             	mov    0x14(%ebp),%edx
  8004d7:	8d 42 04             	lea    0x4(%edx),%eax
  8004da:	89 45 14             	mov    %eax,0x14(%ebp)
  8004dd:	8b 02                	mov    (%edx),%eax
  8004df:	89 c2                	mov    %eax,%edx
  8004e1:	c1 fa 1f             	sar    $0x1f,%edx
  8004e4:	31 d0                	xor    %edx,%eax
  8004e6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8004e8:	83 f8 0f             	cmp    $0xf,%eax
  8004eb:	7f 0b                	jg     8004f8 <vprintfmt+0x123>
  8004ed:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  8004f4:	85 d2                	test   %edx,%edx
  8004f6:	75 23                	jne    80051b <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004fc:	c7 44 24 08 73 1f 80 	movl   $0x801f73,0x8(%esp)
  800503:	00 
  800504:	8b 45 0c             	mov    0xc(%ebp),%eax
  800507:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050b:	8b 55 08             	mov    0x8(%ebp),%edx
  80050e:	89 14 24             	mov    %edx,(%esp)
  800511:	e8 ff 02 00 00       	call   800815 <printfmt>
  800516:	e9 e0 fe ff ff       	jmp    8003fb <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80051b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80051f:	c7 44 24 08 7c 1f 80 	movl   $0x801f7c,0x8(%esp)
  800526:	00 
  800527:	8b 45 0c             	mov    0xc(%ebp),%eax
  80052a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052e:	8b 55 08             	mov    0x8(%ebp),%edx
  800531:	89 14 24             	mov    %edx,(%esp)
  800534:	e8 dc 02 00 00       	call   800815 <printfmt>
  800539:	e9 bd fe ff ff       	jmp    8003fb <vprintfmt+0x26>
  80053e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800541:	89 f9                	mov    %edi,%ecx
  800543:	89 5d ec             	mov    %ebx,-0x14(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800546:	8b 55 14             	mov    0x14(%ebp),%edx
  800549:	8d 42 04             	lea    0x4(%edx),%eax
  80054c:	89 45 14             	mov    %eax,0x14(%ebp)
  80054f:	8b 12                	mov    (%edx),%edx
  800551:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800554:	85 d2                	test   %edx,%edx
  800556:	75 07                	jne    80055f <vprintfmt+0x18a>
  800558:	c7 45 dc 7f 1f 80 00 	movl   $0x801f7f,-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80055f:	85 f6                	test   %esi,%esi
  800561:	7e 41                	jle    8005a4 <vprintfmt+0x1cf>
  800563:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  800567:	74 3b                	je     8005a4 <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
  800569:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80056d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800570:	89 04 24             	mov    %eax,(%esp)
  800573:	e8 e8 02 00 00       	call   800860 <strnlen>
  800578:	29 c6                	sub    %eax,%esi
  80057a:	89 75 f0             	mov    %esi,-0x10(%ebp)
  80057d:	85 f6                	test   %esi,%esi
  80057f:	7e 23                	jle    8005a4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800581:	0f be 55 eb          	movsbl -0x15(%ebp),%edx
  800585:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800588:	8b 45 0c             	mov    0xc(%ebp),%eax
  80058b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800592:	89 14 24             	mov    %edx,(%esp)
  800595:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800598:	83 ee 01             	sub    $0x1,%esi
  80059b:	75 eb                	jne    800588 <vprintfmt+0x1b3>
  80059d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005a7:	0f b6 02             	movzbl (%edx),%eax
  8005aa:	0f be d0             	movsbl %al,%edx
  8005ad:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005b0:	84 c0                	test   %al,%al
  8005b2:	75 42                	jne    8005f6 <vprintfmt+0x221>
  8005b4:	eb 49                	jmp    8005ff <vprintfmt+0x22a>
				if (altflag && (ch < ' ' || ch > '~'))
  8005b6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ba:	74 1b                	je     8005d7 <vprintfmt+0x202>
  8005bc:	8d 42 e0             	lea    -0x20(%edx),%eax
  8005bf:	83 f8 5e             	cmp    $0x5e,%eax
  8005c2:	76 13                	jbe    8005d7 <vprintfmt+0x202>
					putch('?', putdat);
  8005c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005cb:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005d2:	ff 55 08             	call   *0x8(%ebp)
  8005d5:	eb 0d                	jmp    8005e4 <vprintfmt+0x20f>
				else
					putch(ch, putdat);
  8005d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005de:	89 14 24             	mov    %edx,(%esp)
  8005e1:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e4:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  8005e8:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8005ec:	83 c6 01             	add    $0x1,%esi
  8005ef:	84 c0                	test   %al,%al
  8005f1:	74 0c                	je     8005ff <vprintfmt+0x22a>
  8005f3:	0f be d0             	movsbl %al,%edx
  8005f6:	85 ff                	test   %edi,%edi
  8005f8:	78 bc                	js     8005b6 <vprintfmt+0x1e1>
  8005fa:	83 ef 01             	sub    $0x1,%edi
  8005fd:	79 b7                	jns    8005b6 <vprintfmt+0x1e1>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ff:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800603:	0f 8e f2 fd ff ff    	jle    8003fb <vprintfmt+0x26>
				putch(' ', putdat);
  800609:	8b 55 0c             	mov    0xc(%ebp),%edx
  80060c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800610:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800617:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80061a:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  80061e:	75 e9                	jne    800609 <vprintfmt+0x234>
  800620:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  800623:	e9 d3 fd ff ff       	jmp    8003fb <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800628:	83 f9 01             	cmp    $0x1,%ecx
  80062b:	90                   	nop    
  80062c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800630:	7e 10                	jle    800642 <vprintfmt+0x26d>
		return va_arg(*ap, long long);
  800632:	8b 55 14             	mov    0x14(%ebp),%edx
  800635:	8d 42 08             	lea    0x8(%edx),%eax
  800638:	89 45 14             	mov    %eax,0x14(%ebp)
  80063b:	8b 32                	mov    (%edx),%esi
  80063d:	8b 7a 04             	mov    0x4(%edx),%edi
  800640:	eb 2a                	jmp    80066c <vprintfmt+0x297>
	else if (lflag)
  800642:	85 c9                	test   %ecx,%ecx
  800644:	74 14                	je     80065a <vprintfmt+0x285>
		return va_arg(*ap, long);
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8d 50 04             	lea    0x4(%eax),%edx
  80064c:	89 55 14             	mov    %edx,0x14(%ebp)
  80064f:	8b 00                	mov    (%eax),%eax
  800651:	89 c6                	mov    %eax,%esi
  800653:	89 c7                	mov    %eax,%edi
  800655:	c1 ff 1f             	sar    $0x1f,%edi
  800658:	eb 12                	jmp    80066c <vprintfmt+0x297>
	else
		return va_arg(*ap, int);
  80065a:	8b 45 14             	mov    0x14(%ebp),%eax
  80065d:	8d 50 04             	lea    0x4(%eax),%edx
  800660:	89 55 14             	mov    %edx,0x14(%ebp)
  800663:	8b 00                	mov    (%eax),%eax
  800665:	89 c6                	mov    %eax,%esi
  800667:	89 c7                	mov    %eax,%edi
  800669:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80066c:	89 f2                	mov    %esi,%edx
  80066e:	89 f9                	mov    %edi,%ecx
  800670:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
			if ((long long) num < 0) {
  800677:	85 ff                	test   %edi,%edi
  800679:	0f 89 9b 00 00 00    	jns    80071a <vprintfmt+0x345>
				putch('-', putdat);
  80067f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800682:	89 44 24 04          	mov    %eax,0x4(%esp)
  800686:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80068d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800690:	89 f2                	mov    %esi,%edx
  800692:	89 f9                	mov    %edi,%ecx
  800694:	f7 da                	neg    %edx
  800696:	83 d1 00             	adc    $0x0,%ecx
  800699:	f7 d9                	neg    %ecx
  80069b:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  8006a2:	eb 76                	jmp    80071a <vprintfmt+0x345>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006a4:	89 ca                	mov    %ecx,%edx
  8006a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a9:	e8 cd fc ff ff       	call   80037b <getuint>
  8006ae:	89 d1                	mov    %edx,%ecx
  8006b0:	89 c2                	mov    %eax,%edx
  8006b2:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  8006b9:	eb 5f                	jmp    80071a <vprintfmt+0x345>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap,lflag);
  8006bb:	89 ca                	mov    %ecx,%edx
  8006bd:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c0:	e8 b6 fc ff ff       	call   80037b <getuint>
  8006c5:	e9 31 fd ff ff       	jmp    8003fb <vprintfmt+0x26>
			base=8;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006d1:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006d8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e2:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006e9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8006ec:	8b 55 14             	mov    0x14(%ebp),%edx
  8006ef:	8d 42 04             	lea    0x4(%edx),%eax
  8006f2:	89 45 14             	mov    %eax,0x14(%ebp)
  8006f5:	8b 12                	mov    (%edx),%edx
  8006f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006fc:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  800703:	eb 15                	jmp    80071a <vprintfmt+0x345>
			base = 16;
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800705:	89 ca                	mov    %ecx,%edx
  800707:	8d 45 14             	lea    0x14(%ebp),%eax
  80070a:	e8 6c fc ff ff       	call   80037b <getuint>
  80070f:	89 d1                	mov    %edx,%ecx
  800711:	89 c2                	mov    %eax,%edx
  800713:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80071a:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  80071e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800722:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800725:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800729:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80072c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800730:	89 14 24             	mov    %edx,(%esp)
  800733:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800737:	8b 55 0c             	mov    0xc(%ebp),%edx
  80073a:	8b 45 08             	mov    0x8(%ebp),%eax
  80073d:	e8 4e fb ff ff       	call   800290 <printnum>
  800742:	e9 b4 fc ff ff       	jmp    8003fb <vprintfmt+0x26>
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800747:	8b 55 0c             	mov    0xc(%ebp),%edx
  80074a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80074e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800755:	ff 55 08             	call   *0x8(%ebp)
  800758:	e9 9e fc ff ff       	jmp    8003fb <vprintfmt+0x26>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80075d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800760:	89 44 24 04          	mov    %eax,0x4(%esp)
  800764:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80076b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80076e:	83 eb 01             	sub    $0x1,%ebx
  800771:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800775:	0f 84 80 fc ff ff    	je     8003fb <vprintfmt+0x26>
  80077b:	83 eb 01             	sub    $0x1,%ebx
  80077e:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800782:	0f 84 73 fc ff ff    	je     8003fb <vprintfmt+0x26>
  800788:	eb f1                	jmp    80077b <vprintfmt+0x3a6>
				/* do nothing */;
			break;
		}
	}
}
  80078a:	83 c4 3c             	add    $0x3c,%esp
  80078d:	5b                   	pop    %ebx
  80078e:	5e                   	pop    %esi
  80078f:	5f                   	pop    %edi
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	83 ec 28             	sub    $0x28,%esp
  800798:	8b 55 08             	mov    0x8(%ebp),%edx
  80079b:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80079e:	85 d2                	test   %edx,%edx
  8007a0:	74 04                	je     8007a6 <vsnprintf+0x14>
  8007a2:	85 c0                	test   %eax,%eax
  8007a4:	7f 07                	jg     8007ad <vsnprintf+0x1b>
  8007a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ab:	eb 3b                	jmp    8007e8 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ad:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8007b4:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
  8007b8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  8007bb:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007be:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d3:	c7 04 24 b7 03 80 00 	movl   $0x8003b7,(%esp)
  8007da:	e8 f6 fb ff ff       	call   8003d5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007e2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8007e8:	c9                   	leave  
  8007e9:	c3                   	ret    

008007ea <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007f0:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f3:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8007f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8007fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800801:	8b 45 0c             	mov    0xc(%ebp),%eax
  800804:	89 44 24 04          	mov    %eax,0x4(%esp)
  800808:	8b 45 08             	mov    0x8(%ebp),%eax
  80080b:	89 04 24             	mov    %eax,(%esp)
  80080e:	e8 7f ff ff ff       	call   800792 <vsnprintf>
	va_end(ap);

	return rc;
}
  800813:	c9                   	leave  
  800814:	c3                   	ret    

00800815 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  80081b:	8d 45 14             	lea    0x14(%ebp),%eax
  80081e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800821:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800825:	8b 45 10             	mov    0x10(%ebp),%eax
  800828:	89 44 24 08          	mov    %eax,0x8(%esp)
  80082c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80082f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800833:	8b 45 08             	mov    0x8(%ebp),%eax
  800836:	89 04 24             	mov    %eax,(%esp)
  800839:	e8 97 fb ff ff       	call   8003d5 <vprintfmt>
	va_end(ap);
}
  80083e:	c9                   	leave  
  80083f:	c3                   	ret    

00800840 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800846:	b8 00 00 00 00       	mov    $0x0,%eax
  80084b:	80 3a 00             	cmpb   $0x0,(%edx)
  80084e:	74 0e                	je     80085e <strlen+0x1e>
  800850:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800855:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800858:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  80085c:	75 f7                	jne    800855 <strlen+0x15>
		n++;
	return n;
}
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800866:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800869:	85 d2                	test   %edx,%edx
  80086b:	74 19                	je     800886 <strnlen+0x26>
  80086d:	80 39 00             	cmpb   $0x0,(%ecx)
  800870:	74 14                	je     800886 <strnlen+0x26>
  800872:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800877:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087a:	39 d0                	cmp    %edx,%eax
  80087c:	74 0d                	je     80088b <strnlen+0x2b>
  80087e:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800882:	74 07                	je     80088b <strnlen+0x2b>
  800884:	eb f1                	jmp    800877 <strnlen+0x17>
  800886:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80088b:	5d                   	pop    %ebp
  80088c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800890:	c3                   	ret    

00800891 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	53                   	push   %ebx
  800895:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800898:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80089b:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80089d:	0f b6 01             	movzbl (%ecx),%eax
  8008a0:	88 02                	mov    %al,(%edx)
  8008a2:	83 c2 01             	add    $0x1,%edx
  8008a5:	83 c1 01             	add    $0x1,%ecx
  8008a8:	84 c0                	test   %al,%al
  8008aa:	75 f1                	jne    80089d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008ac:	89 d8                	mov    %ebx,%eax
  8008ae:	5b                   	pop    %ebx
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	57                   	push   %edi
  8008b5:	56                   	push   %esi
  8008b6:	53                   	push   %ebx
  8008b7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008bd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c0:	85 f6                	test   %esi,%esi
  8008c2:	74 1c                	je     8008e0 <strncpy+0x2f>
  8008c4:	89 fa                	mov    %edi,%edx
  8008c6:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  8008cb:	0f b6 01             	movzbl (%ecx),%eax
  8008ce:	88 02                	mov    %al,(%edx)
  8008d0:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d3:	80 39 01             	cmpb   $0x1,(%ecx)
  8008d6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d9:	83 c3 01             	add    $0x1,%ebx
  8008dc:	39 f3                	cmp    %esi,%ebx
  8008de:	75 eb                	jne    8008cb <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008e0:	89 f8                	mov    %edi,%eax
  8008e2:	5b                   	pop    %ebx
  8008e3:	5e                   	pop    %esi
  8008e4:	5f                   	pop    %edi
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	56                   	push   %esi
  8008eb:	53                   	push   %ebx
  8008ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f2:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f5:	89 f0                	mov    %esi,%eax
  8008f7:	85 d2                	test   %edx,%edx
  8008f9:	74 2c                	je     800927 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  8008fb:	89 d3                	mov    %edx,%ebx
  8008fd:	83 eb 01             	sub    $0x1,%ebx
  800900:	74 20                	je     800922 <strlcpy+0x3b>
  800902:	0f b6 11             	movzbl (%ecx),%edx
  800905:	84 d2                	test   %dl,%dl
  800907:	74 19                	je     800922 <strlcpy+0x3b>
  800909:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  80090b:	88 10                	mov    %dl,(%eax)
  80090d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800910:	83 eb 01             	sub    $0x1,%ebx
  800913:	74 0f                	je     800924 <strlcpy+0x3d>
  800915:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  800919:	83 c1 01             	add    $0x1,%ecx
  80091c:	84 d2                	test   %dl,%dl
  80091e:	74 04                	je     800924 <strlcpy+0x3d>
  800920:	eb e9                	jmp    80090b <strlcpy+0x24>
  800922:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800924:	c6 00 00             	movb   $0x0,(%eax)
  800927:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800929:	5b                   	pop    %ebx
  80092a:	5e                   	pop    %esi
  80092b:	5d                   	pop    %ebp
  80092c:	c3                   	ret    

0080092d <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	56                   	push   %esi
  800931:	53                   	push   %ebx
  800932:	8b 75 08             	mov    0x8(%ebp),%esi
  800935:	8b 45 0c             	mov    0xc(%ebp),%eax
  800938:	8b 55 10             	mov    0x10(%ebp),%edx
    int c;
    char *q = buf;

    if (buf_size <= 0)
  80093b:	85 c0                	test   %eax,%eax
  80093d:	7e 2e                	jle    80096d <pstrcpy+0x40>
        return;

    for(;;) {
        c = *str++;
  80093f:	0f b6 0a             	movzbl (%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  800942:	84 c9                	test   %cl,%cl
  800944:	74 22                	je     800968 <pstrcpy+0x3b>
  800946:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  80094a:	89 f0                	mov    %esi,%eax
  80094c:	39 de                	cmp    %ebx,%esi
  80094e:	72 09                	jb     800959 <pstrcpy+0x2c>
  800950:	eb 16                	jmp    800968 <pstrcpy+0x3b>
  800952:	83 c2 01             	add    $0x1,%edx
  800955:	39 d8                	cmp    %ebx,%eax
  800957:	73 11                	jae    80096a <pstrcpy+0x3d>
            break;
        *q++ = c;
  800959:	88 08                	mov    %cl,(%eax)
  80095b:	83 c0 01             	add    $0x1,%eax

    if (buf_size <= 0)
        return;

    for(;;) {
        c = *str++;
  80095e:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  800962:	84 c9                	test   %cl,%cl
  800964:	75 ec                	jne    800952 <pstrcpy+0x25>
  800966:	eb 02                	jmp    80096a <pstrcpy+0x3d>
  800968:	89 f0                	mov    %esi,%eax
            break;
        *q++ = c;
    }
    *q = '\0';
  80096a:	c6 00 00             	movb   $0x0,(%eax)
}
  80096d:	5b                   	pop    %ebx
  80096e:	5e                   	pop    %esi
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    

00800971 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	8b 55 08             	mov    0x8(%ebp),%edx
  800977:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  80097a:	0f b6 02             	movzbl (%edx),%eax
  80097d:	84 c0                	test   %al,%al
  80097f:	74 16                	je     800997 <strcmp+0x26>
  800981:	3a 01                	cmp    (%ecx),%al
  800983:	75 12                	jne    800997 <strcmp+0x26>
		p++, q++;
  800985:	83 c1 01             	add    $0x1,%ecx
    *q = '\0';
}
int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800988:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  80098c:	84 c0                	test   %al,%al
  80098e:	74 07                	je     800997 <strcmp+0x26>
  800990:	83 c2 01             	add    $0x1,%edx
  800993:	3a 01                	cmp    (%ecx),%al
  800995:	74 ee                	je     800985 <strcmp+0x14>
  800997:	0f b6 c0             	movzbl %al,%eax
  80099a:	0f b6 11             	movzbl (%ecx),%edx
  80099d:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	53                   	push   %ebx
  8009a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009ab:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8009ae:	85 d2                	test   %edx,%edx
  8009b0:	74 2d                	je     8009df <strncmp+0x3e>
  8009b2:	0f b6 01             	movzbl (%ecx),%eax
  8009b5:	84 c0                	test   %al,%al
  8009b7:	74 1a                	je     8009d3 <strncmp+0x32>
  8009b9:	3a 03                	cmp    (%ebx),%al
  8009bb:	75 16                	jne    8009d3 <strncmp+0x32>
  8009bd:	83 ea 01             	sub    $0x1,%edx
  8009c0:	74 1d                	je     8009df <strncmp+0x3e>
		n--, p++, q++;
  8009c2:	83 c1 01             	add    $0x1,%ecx
  8009c5:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009c8:	0f b6 01             	movzbl (%ecx),%eax
  8009cb:	84 c0                	test   %al,%al
  8009cd:	74 04                	je     8009d3 <strncmp+0x32>
  8009cf:	3a 03                	cmp    (%ebx),%al
  8009d1:	74 ea                	je     8009bd <strncmp+0x1c>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d3:	0f b6 11             	movzbl (%ecx),%edx
  8009d6:	0f b6 03             	movzbl (%ebx),%eax
  8009d9:	29 c2                	sub    %eax,%edx
  8009db:	89 d0                	mov    %edx,%eax
  8009dd:	eb 05                	jmp    8009e4 <strncmp+0x43>
  8009df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e4:	5b                   	pop    %ebx
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ed:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f1:	0f b6 10             	movzbl (%eax),%edx
  8009f4:	84 d2                	test   %dl,%dl
  8009f6:	74 14                	je     800a0c <strchr+0x25>
		if (*s == c)
  8009f8:	38 ca                	cmp    %cl,%dl
  8009fa:	75 06                	jne    800a02 <strchr+0x1b>
  8009fc:	eb 13                	jmp    800a11 <strchr+0x2a>
  8009fe:	38 ca                	cmp    %cl,%dl
  800a00:	74 0f                	je     800a11 <strchr+0x2a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a02:	83 c0 01             	add    $0x1,%eax
  800a05:	0f b6 10             	movzbl (%eax),%edx
  800a08:	84 d2                	test   %dl,%dl
  800a0a:	75 f2                	jne    8009fe <strchr+0x17>
  800a0c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a11:	5d                   	pop    %ebp
  800a12:	c3                   	ret    

00800a13 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	8b 45 08             	mov    0x8(%ebp),%eax
  800a19:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a1d:	0f b6 10             	movzbl (%eax),%edx
  800a20:	84 d2                	test   %dl,%dl
  800a22:	74 18                	je     800a3c <strfind+0x29>
		if (*s == c)
  800a24:	38 ca                	cmp    %cl,%dl
  800a26:	75 0a                	jne    800a32 <strfind+0x1f>
  800a28:	eb 12                	jmp    800a3c <strfind+0x29>
  800a2a:	38 ca                	cmp    %cl,%dl
  800a2c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800a30:	74 0a                	je     800a3c <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a32:	83 c0 01             	add    $0x1,%eax
  800a35:	0f b6 10             	movzbl (%eax),%edx
  800a38:	84 d2                	test   %dl,%dl
  800a3a:	75 ee                	jne    800a2a <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    

00800a3e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	83 ec 08             	sub    $0x8,%esp
  800a44:	89 1c 24             	mov    %ebx,(%esp)
  800a47:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a4b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800a51:	85 db                	test   %ebx,%ebx
  800a53:	74 36                	je     800a8b <memset+0x4d>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a55:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a5b:	75 26                	jne    800a83 <memset+0x45>
  800a5d:	f6 c3 03             	test   $0x3,%bl
  800a60:	75 21                	jne    800a83 <memset+0x45>
		c &= 0xFF;
  800a62:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a66:	89 d0                	mov    %edx,%eax
  800a68:	c1 e0 18             	shl    $0x18,%eax
  800a6b:	89 d1                	mov    %edx,%ecx
  800a6d:	c1 e1 10             	shl    $0x10,%ecx
  800a70:	09 c8                	or     %ecx,%eax
  800a72:	09 d0                	or     %edx,%eax
  800a74:	c1 e2 08             	shl    $0x8,%edx
  800a77:	09 d0                	or     %edx,%eax
  800a79:	89 d9                	mov    %ebx,%ecx
  800a7b:	c1 e9 02             	shr    $0x2,%ecx
  800a7e:	fc                   	cld    
  800a7f:	f3 ab                	rep stos %eax,%es:(%edi)
  800a81:	eb 08                	jmp    800a8b <memset+0x4d>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a86:	89 d9                	mov    %ebx,%ecx
  800a88:	fc                   	cld    
  800a89:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a8b:	89 f8                	mov    %edi,%eax
  800a8d:	8b 1c 24             	mov    (%esp),%ebx
  800a90:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800a94:	89 ec                	mov    %ebp,%esp
  800a96:	5d                   	pop    %ebp
  800a97:	c3                   	ret    

00800a98 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	83 ec 08             	sub    $0x8,%esp
  800a9e:	89 34 24             	mov    %esi,(%esp)
  800aa1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aa5:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800aab:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800aae:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800ab0:	39 c6                	cmp    %eax,%esi
  800ab2:	73 38                	jae    800aec <memmove+0x54>
  800ab4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ab7:	39 d0                	cmp    %edx,%eax
  800ab9:	73 31                	jae    800aec <memmove+0x54>
		s += n;
		d += n;
  800abb:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800abe:	f6 c2 03             	test   $0x3,%dl
  800ac1:	75 1d                	jne    800ae0 <memmove+0x48>
  800ac3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ac9:	75 15                	jne    800ae0 <memmove+0x48>
  800acb:	f6 c1 03             	test   $0x3,%cl
  800ace:	66 90                	xchg   %ax,%ax
  800ad0:	75 0e                	jne    800ae0 <memmove+0x48>
			asm volatile("std; rep movsl\n"
  800ad2:	8d 7e fc             	lea    -0x4(%esi),%edi
  800ad5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ad8:	c1 e9 02             	shr    $0x2,%ecx
  800adb:	fd                   	std    
  800adc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ade:	eb 09                	jmp    800ae9 <memmove+0x51>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ae0:	8d 7e ff             	lea    -0x1(%esi),%edi
  800ae3:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ae6:	fd                   	std    
  800ae7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ae9:	fc                   	cld    
  800aea:	eb 21                	jmp    800b0d <memmove+0x75>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aec:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800af2:	75 16                	jne    800b0a <memmove+0x72>
  800af4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800afa:	75 0e                	jne    800b0a <memmove+0x72>
  800afc:	f6 c1 03             	test   $0x3,%cl
  800aff:	90                   	nop    
  800b00:	75 08                	jne    800b0a <memmove+0x72>
			asm volatile("cld; rep movsl\n"
  800b02:	c1 e9 02             	shr    $0x2,%ecx
  800b05:	fc                   	cld    
  800b06:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b08:	eb 03                	jmp    800b0d <memmove+0x75>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b0a:	fc                   	cld    
  800b0b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b0d:	8b 34 24             	mov    (%esp),%esi
  800b10:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b14:	89 ec                	mov    %ebp,%esp
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b1e:	8b 45 10             	mov    0x10(%ebp),%eax
  800b21:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b25:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b28:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2f:	89 04 24             	mov    %eax,(%esp)
  800b32:	e8 61 ff ff ff       	call   800a98 <memmove>
}
  800b37:	c9                   	leave  
  800b38:	c3                   	ret    

00800b39 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
  800b3f:	83 ec 04             	sub    $0x4,%esp
  800b42:	8b 45 08             	mov    0x8(%ebp),%eax
  800b45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b48:	8b 55 10             	mov    0x10(%ebp),%edx
  800b4b:	83 ea 01             	sub    $0x1,%edx
  800b4e:	83 fa ff             	cmp    $0xffffffff,%edx
  800b51:	74 47                	je     800b9a <memcmp+0x61>
		if (*s1 != *s2)
  800b53:	0f b6 30             	movzbl (%eax),%esi
  800b56:	0f b6 39             	movzbl (%ecx),%edi
			return (int) *s1 - (int) *s2;
  800b59:	89 45 f0             	mov    %eax,-0x10(%ebp)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  800b5c:	89 f0                	mov    %esi,%eax
  800b5e:	89 fb                	mov    %edi,%ebx
  800b60:	38 d8                	cmp    %bl,%al
  800b62:	74 2e                	je     800b92 <memcmp+0x59>
  800b64:	eb 1c                	jmp    800b82 <memcmp+0x49>
  800b66:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b69:	0f b6 70 01          	movzbl 0x1(%eax),%esi
  800b6d:	0f b6 79 01          	movzbl 0x1(%ecx),%edi
  800b71:	83 c0 01             	add    $0x1,%eax
  800b74:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b77:	83 c1 01             	add    $0x1,%ecx
  800b7a:	89 f3                	mov    %esi,%ebx
  800b7c:	89 f8                	mov    %edi,%eax
  800b7e:	38 c3                	cmp    %al,%bl
  800b80:	74 10                	je     800b92 <memcmp+0x59>
			return (int) *s1 - (int) *s2;
  800b82:	89 f1                	mov    %esi,%ecx
  800b84:	0f b6 d1             	movzbl %cl,%edx
  800b87:	89 fb                	mov    %edi,%ebx
  800b89:	0f b6 c3             	movzbl %bl,%eax
  800b8c:	29 c2                	sub    %eax,%edx
  800b8e:	89 d0                	mov    %edx,%eax
  800b90:	eb 0d                	jmp    800b9f <memcmp+0x66>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b92:	83 ea 01             	sub    $0x1,%edx
  800b95:	83 fa ff             	cmp    $0xffffffff,%edx
  800b98:	75 cc                	jne    800b66 <memcmp+0x2d>
  800b9a:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b9f:	83 c4 04             	add    $0x4,%esp
  800ba2:	5b                   	pop    %ebx
  800ba3:	5e                   	pop    %esi
  800ba4:	5f                   	pop    %edi
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bad:	89 c1                	mov    %eax,%ecx
  800baf:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
  800bb2:	39 c8                	cmp    %ecx,%eax
  800bb4:	73 15                	jae    800bcb <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bb6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
  800bba:	38 10                	cmp    %dl,(%eax)
  800bbc:	75 06                	jne    800bc4 <memfind+0x1d>
  800bbe:	eb 0b                	jmp    800bcb <memfind+0x24>
  800bc0:	38 10                	cmp    %dl,(%eax)
  800bc2:	74 07                	je     800bcb <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bc4:	83 c0 01             	add    $0x1,%eax
  800bc7:	39 c8                	cmp    %ecx,%eax
  800bc9:	75 f5                	jne    800bc0 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bcb:	5d                   	pop    %ebp
  800bcc:	8d 74 26 00          	lea    0x0(%esi),%esi
  800bd0:	c3                   	ret    

00800bd1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	57                   	push   %edi
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
  800bd7:	83 ec 04             	sub    $0x4,%esp
  800bda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bdd:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be0:	0f b6 01             	movzbl (%ecx),%eax
  800be3:	3c 20                	cmp    $0x20,%al
  800be5:	74 04                	je     800beb <strtol+0x1a>
  800be7:	3c 09                	cmp    $0x9,%al
  800be9:	75 0e                	jne    800bf9 <strtol+0x28>
		s++;
  800beb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bee:	0f b6 01             	movzbl (%ecx),%eax
  800bf1:	3c 20                	cmp    $0x20,%al
  800bf3:	74 f6                	je     800beb <strtol+0x1a>
  800bf5:	3c 09                	cmp    $0x9,%al
  800bf7:	74 f2                	je     800beb <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bf9:	3c 2b                	cmp    $0x2b,%al
  800bfb:	75 0c                	jne    800c09 <strtol+0x38>
		s++;
  800bfd:	83 c1 01             	add    $0x1,%ecx
  800c00:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c07:	eb 15                	jmp    800c1e <strtol+0x4d>
	else if (*s == '-')
  800c09:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c10:	3c 2d                	cmp    $0x2d,%al
  800c12:	75 0a                	jne    800c1e <strtol+0x4d>
		s++, neg = 1;
  800c14:	83 c1 01             	add    $0x1,%ecx
  800c17:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c1e:	85 f6                	test   %esi,%esi
  800c20:	0f 94 c0             	sete   %al
  800c23:	74 05                	je     800c2a <strtol+0x59>
  800c25:	83 fe 10             	cmp    $0x10,%esi
  800c28:	75 18                	jne    800c42 <strtol+0x71>
  800c2a:	80 39 30             	cmpb   $0x30,(%ecx)
  800c2d:	75 13                	jne    800c42 <strtol+0x71>
  800c2f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c33:	75 0d                	jne    800c42 <strtol+0x71>
		s += 2, base = 16;
  800c35:	83 c1 02             	add    $0x2,%ecx
  800c38:	be 10 00 00 00       	mov    $0x10,%esi
  800c3d:	8d 76 00             	lea    0x0(%esi),%esi
  800c40:	eb 1b                	jmp    800c5d <strtol+0x8c>
	else if (base == 0 && s[0] == '0')
  800c42:	85 f6                	test   %esi,%esi
  800c44:	75 0e                	jne    800c54 <strtol+0x83>
  800c46:	80 39 30             	cmpb   $0x30,(%ecx)
  800c49:	75 09                	jne    800c54 <strtol+0x83>
		s++, base = 8;
  800c4b:	83 c1 01             	add    $0x1,%ecx
  800c4e:	66 be 08 00          	mov    $0x8,%si
  800c52:	eb 09                	jmp    800c5d <strtol+0x8c>
	else if (base == 0)
  800c54:	84 c0                	test   %al,%al
  800c56:	74 05                	je     800c5d <strtol+0x8c>
  800c58:	be 0a 00 00 00       	mov    $0xa,%esi
  800c5d:	bf 00 00 00 00       	mov    $0x0,%edi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c62:	0f b6 11             	movzbl (%ecx),%edx
  800c65:	89 d3                	mov    %edx,%ebx
  800c67:	8d 42 d0             	lea    -0x30(%edx),%eax
  800c6a:	3c 09                	cmp    $0x9,%al
  800c6c:	77 08                	ja     800c76 <strtol+0xa5>
			dig = *s - '0';
  800c6e:	0f be c2             	movsbl %dl,%eax
  800c71:	8d 50 d0             	lea    -0x30(%eax),%edx
  800c74:	eb 1c                	jmp    800c92 <strtol+0xc1>
		else if (*s >= 'a' && *s <= 'z')
  800c76:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800c79:	3c 19                	cmp    $0x19,%al
  800c7b:	77 08                	ja     800c85 <strtol+0xb4>
			dig = *s - 'a' + 10;
  800c7d:	0f be c2             	movsbl %dl,%eax
  800c80:	8d 50 a9             	lea    -0x57(%eax),%edx
  800c83:	eb 0d                	jmp    800c92 <strtol+0xc1>
		else if (*s >= 'A' && *s <= 'Z')
  800c85:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800c88:	3c 19                	cmp    $0x19,%al
  800c8a:	77 17                	ja     800ca3 <strtol+0xd2>
			dig = *s - 'A' + 10;
  800c8c:	0f be c2             	movsbl %dl,%eax
  800c8f:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800c92:	39 f2                	cmp    %esi,%edx
  800c94:	7d 0d                	jge    800ca3 <strtol+0xd2>
			break;
		s++, val = (val * base) + dig;
  800c96:	83 c1 01             	add    $0x1,%ecx
  800c99:	89 f8                	mov    %edi,%eax
  800c9b:	0f af c6             	imul   %esi,%eax
  800c9e:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800ca1:	eb bf                	jmp    800c62 <strtol+0x91>
		// we don't properly detect overflow!
	}
  800ca3:	89 f8                	mov    %edi,%eax

	if (endptr)
  800ca5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ca9:	74 05                	je     800cb0 <strtol+0xdf>
		*endptr = (char *) s;
  800cab:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cae:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800cb0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800cb4:	74 04                	je     800cba <strtol+0xe9>
  800cb6:	89 c7                	mov    %eax,%edi
  800cb8:	f7 df                	neg    %edi
}
  800cba:	89 f8                	mov    %edi,%eax
  800cbc:	83 c4 04             	add    $0x4,%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	83 ec 0c             	sub    $0xc,%esp
  800cca:	89 1c 24             	mov    %ebx,(%esp)
  800ccd:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cd1:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd5:	b8 01 00 00 00       	mov    $0x1,%eax
  800cda:	bf 00 00 00 00       	mov    $0x0,%edi
  800cdf:	89 fa                	mov    %edi,%edx
  800ce1:	89 f9                	mov    %edi,%ecx
  800ce3:	89 fb                	mov    %edi,%ebx
  800ce5:	89 fe                	mov    %edi,%esi
  800ce7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ce9:	8b 1c 24             	mov    (%esp),%ebx
  800cec:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cf0:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cf4:	89 ec                	mov    %ebp,%esp
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    

00800cf8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	83 ec 0c             	sub    $0xc,%esp
  800cfe:	89 1c 24             	mov    %ebx,(%esp)
  800d01:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d05:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d09:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0f:	bf 00 00 00 00       	mov    $0x0,%edi
  800d14:	89 f8                	mov    %edi,%eax
  800d16:	89 fb                	mov    %edi,%ebx
  800d18:	89 fe                	mov    %edi,%esi
  800d1a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d1c:	8b 1c 24             	mov    (%esp),%ebx
  800d1f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d23:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d27:	89 ec                	mov    %ebp,%esp
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    

00800d2b <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	83 ec 28             	sub    $0x28,%esp
  800d31:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d34:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d37:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d3a:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d42:	bf 00 00 00 00       	mov    $0x0,%edi
  800d47:	89 f9                	mov    %edi,%ecx
  800d49:	89 fb                	mov    %edi,%ebx
  800d4b:	89 fe                	mov    %edi,%esi
  800d4d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	7e 28                	jle    800d7b <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d53:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d57:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d5e:	00 
  800d5f:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  800d66:	00 
  800d67:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d6e:	00 
  800d6f:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  800d76:	e8 41 0c 00 00       	call   8019bc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d7b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d7e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d81:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d84:	89 ec                	mov    %ebp,%esp
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	83 ec 0c             	sub    $0xc,%esp
  800d8e:	89 1c 24             	mov    %ebx,(%esp)
  800d91:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d95:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d99:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da2:	8b 7d 14             	mov    0x14(%ebp),%edi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800daa:	be 00 00 00 00       	mov    $0x0,%esi
  800daf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db1:	8b 1c 24             	mov    (%esp),%ebx
  800db4:	8b 74 24 04          	mov    0x4(%esp),%esi
  800db8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800dbc:	89 ec                	mov    %ebp,%esp
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800dd5:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800de7:	7e 28                	jle    800e11 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ded:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800df4:	00 
  800df5:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  800dfc:	00 
  800dfd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e04:	00 
  800e05:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  800e0c:	e8 ab 0b 00 00       	call   8019bc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e11:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e14:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e17:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e1a:	89 ec                	mov    %ebp,%esp
  800e1c:	5d                   	pop    %ebp
  800e1d:	c3                   	ret    

00800e1e <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800e33:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800e45:	7e 28                	jle    800e6f <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e47:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4b:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e52:	00 
  800e53:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  800e5a:	00 
  800e5b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e62:	00 
  800e63:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  800e6a:	e8 4d 0b 00 00       	call   8019bc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e6f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e72:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e75:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e78:	89 ec                	mov    %ebp,%esp
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    

00800e7c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	83 ec 28             	sub    $0x28,%esp
  800e82:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e85:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e88:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e91:	b8 08 00 00 00       	mov    $0x8,%eax
  800e96:	bf 00 00 00 00       	mov    $0x0,%edi
  800e9b:	89 fb                	mov    %edi,%ebx
  800e9d:	89 fe                	mov    %edi,%esi
  800e9f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800ea1:	85 c0                	test   %eax,%eax
  800ea3:	7e 28                	jle    800ecd <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea9:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800eb0:	00 
  800eb1:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  800eb8:	00 
  800eb9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec0:	00 
  800ec1:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  800ec8:	e8 ef 0a 00 00       	call   8019bc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ecd:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ed0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ed3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ed6:	89 ec                	mov    %ebp,%esp
  800ed8:	5d                   	pop    %ebp
  800ed9:	c3                   	ret    

00800eda <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	83 ec 28             	sub    $0x28,%esp
  800ee0:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ee3:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ee6:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ee9:	8b 55 08             	mov    0x8(%ebp),%edx
  800eec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eef:	b8 06 00 00 00       	mov    $0x6,%eax
  800ef4:	bf 00 00 00 00       	mov    $0x0,%edi
  800ef9:	89 fb                	mov    %edi,%ebx
  800efb:	89 fe                	mov    %edi,%esi
  800efd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800eff:	85 c0                	test   %eax,%eax
  800f01:	7e 28                	jle    800f2b <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f03:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f07:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f0e:	00 
  800f0f:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  800f16:	00 
  800f17:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f1e:	00 
  800f1f:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  800f26:	e8 91 0a 00 00       	call   8019bc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f2b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f2e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f31:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f34:	89 ec                	mov    %ebp,%esp
  800f36:	5d                   	pop    %ebp
  800f37:	c3                   	ret    

00800f38 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	83 ec 28             	sub    $0x28,%esp
  800f3e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f41:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f44:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f47:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f50:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f53:	8b 75 18             	mov    0x18(%ebp),%esi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f56:	b8 05 00 00 00       	mov    $0x5,%eax
  800f5b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	7e 28                	jle    800f89 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f61:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f65:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f6c:	00 
  800f6d:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  800f74:	00 
  800f75:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f7c:	00 
  800f7d:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  800f84:	e8 33 0a 00 00       	call   8019bc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f89:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f8c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f8f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f92:	89 ec                	mov    %ebp,%esp
  800f94:	5d                   	pop    %ebp
  800f95:	c3                   	ret    

00800f96 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f96:	55                   	push   %ebp
  800f97:	89 e5                	mov    %esp,%ebp
  800f99:	83 ec 28             	sub    $0x28,%esp
  800f9c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f9f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fa2:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800fa5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fae:	b8 04 00 00 00       	mov    $0x4,%eax
  800fb3:	bf 00 00 00 00       	mov    $0x0,%edi
  800fb8:	89 fe                	mov    %edi,%esi
  800fba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800fbc:	85 c0                	test   %eax,%eax
  800fbe:	7e 28                	jle    800fe8 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fc4:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800fcb:	00 
  800fcc:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  800fd3:	00 
  800fd4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fdb:	00 
  800fdc:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  800fe3:	e8 d4 09 00 00       	call   8019bc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fe8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800feb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fee:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ff1:	89 ec                	mov    %ebp,%esp
  800ff3:	5d                   	pop    %ebp
  800ff4:	c3                   	ret    

00800ff5 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	83 ec 0c             	sub    $0xc,%esp
  800ffb:	89 1c 24             	mov    %ebx,(%esp)
  800ffe:	89 74 24 04          	mov    %esi,0x4(%esp)
  801002:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801006:	b8 0b 00 00 00       	mov    $0xb,%eax
  80100b:	bf 00 00 00 00       	mov    $0x0,%edi
  801010:	89 fa                	mov    %edi,%edx
  801012:	89 f9                	mov    %edi,%ecx
  801014:	89 fb                	mov    %edi,%ebx
  801016:	89 fe                	mov    %edi,%esi
  801018:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80101a:	8b 1c 24             	mov    (%esp),%ebx
  80101d:	8b 74 24 04          	mov    0x4(%esp),%esi
  801021:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801025:	89 ec                	mov    %ebp,%esp
  801027:	5d                   	pop    %ebp
  801028:	c3                   	ret    

00801029 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801029:	55                   	push   %ebp
  80102a:	89 e5                	mov    %esp,%ebp
  80102c:	83 ec 0c             	sub    $0xc,%esp
  80102f:	89 1c 24             	mov    %ebx,(%esp)
  801032:	89 74 24 04          	mov    %esi,0x4(%esp)
  801036:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103a:	b8 02 00 00 00       	mov    $0x2,%eax
  80103f:	bf 00 00 00 00       	mov    $0x0,%edi
  801044:	89 fa                	mov    %edi,%edx
  801046:	89 f9                	mov    %edi,%ecx
  801048:	89 fb                	mov    %edi,%ebx
  80104a:	89 fe                	mov    %edi,%esi
  80104c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80104e:	8b 1c 24             	mov    (%esp),%ebx
  801051:	8b 74 24 04          	mov    0x4(%esp),%esi
  801055:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801059:	89 ec                	mov    %ebp,%esp
  80105b:	5d                   	pop    %ebp
  80105c:	c3                   	ret    

0080105d <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	83 ec 28             	sub    $0x28,%esp
  801063:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801066:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801069:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80106c:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80106f:	b8 03 00 00 00       	mov    $0x3,%eax
  801074:	bf 00 00 00 00       	mov    $0x0,%edi
  801079:	89 f9                	mov    %edi,%ecx
  80107b:	89 fb                	mov    %edi,%ebx
  80107d:	89 fe                	mov    %edi,%esi
  80107f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801081:	85 c0                	test   %eax,%eax
  801083:	7e 28                	jle    8010ad <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801085:	89 44 24 10          	mov    %eax,0x10(%esp)
  801089:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801090:	00 
  801091:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  801098:	00 
  801099:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010a0:	00 
  8010a1:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  8010a8:	e8 0f 09 00 00       	call   8019bc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010ad:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010b0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010b3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010b6:	89 ec                	mov    %ebp,%esp
  8010b8:	5d                   	pop    %ebp
  8010b9:	c3                   	ret    
  8010ba:	00 00                	add    %al,(%eax)
  8010bc:	00 00                	add    %al,(%eax)
	...

008010c0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010c0:	55                   	push   %ebp
  8010c1:	89 e5                	mov    %esp,%ebp
  8010c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c6:	05 00 00 00 30       	add    $0x30000000,%eax
  8010cb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8010ce:	5d                   	pop    %ebp
  8010cf:	c3                   	ret    

008010d0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8010d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d9:	89 04 24             	mov    %eax,(%esp)
  8010dc:	e8 df ff ff ff       	call   8010c0 <fd2num>
  8010e1:	c1 e0 0c             	shl    $0xc,%eax
  8010e4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010e9:	c9                   	leave  
  8010ea:	c3                   	ret    

008010eb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010eb:	55                   	push   %ebp
  8010ec:	89 e5                	mov    %esp,%ebp
  8010ee:	53                   	push   %ebx
  8010ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8010f2:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  8010f7:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  8010f9:	89 d0                	mov    %edx,%eax
  8010fb:	c1 e8 16             	shr    $0x16,%eax
  8010fe:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801105:	a8 01                	test   $0x1,%al
  801107:	74 10                	je     801119 <fd_alloc+0x2e>
  801109:	89 d0                	mov    %edx,%eax
  80110b:	c1 e8 0c             	shr    $0xc,%eax
  80110e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801115:	a8 01                	test   $0x1,%al
  801117:	75 09                	jne    801122 <fd_alloc+0x37>
			*fd_store = fd;
  801119:	89 0b                	mov    %ecx,(%ebx)
  80111b:	b8 00 00 00 00       	mov    $0x0,%eax
  801120:	eb 19                	jmp    80113b <fd_alloc+0x50>
			return 0;
  801122:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801128:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  80112e:	75 c7                	jne    8010f7 <fd_alloc+0xc>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801130:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801136:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  80113b:	5b                   	pop    %ebx
  80113c:	5d                   	pop    %ebp
  80113d:	c3                   	ret    

0080113e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801141:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  801145:	77 38                	ja     80117f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801147:	8b 45 08             	mov    0x8(%ebp),%eax
  80114a:	c1 e0 0c             	shl    $0xc,%eax
  80114d:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  801153:	89 d0                	mov    %edx,%eax
  801155:	c1 e8 16             	shr    $0x16,%eax
  801158:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80115f:	a8 01                	test   $0x1,%al
  801161:	74 1c                	je     80117f <fd_lookup+0x41>
  801163:	89 d0                	mov    %edx,%eax
  801165:	c1 e8 0c             	shr    $0xc,%eax
  801168:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80116f:	a8 01                	test   $0x1,%al
  801171:	74 0c                	je     80117f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801173:	8b 45 0c             	mov    0xc(%ebp),%eax
  801176:	89 10                	mov    %edx,(%eax)
  801178:	b8 00 00 00 00       	mov    $0x0,%eax
  80117d:	eb 05                	jmp    801184 <fd_lookup+0x46>
	return 0;
  80117f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801184:	5d                   	pop    %ebp
  801185:	c3                   	ret    

00801186 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801186:	55                   	push   %ebp
  801187:	89 e5                	mov    %esp,%ebp
  801189:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80118c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80118f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801193:	8b 45 08             	mov    0x8(%ebp),%eax
  801196:	89 04 24             	mov    %eax,(%esp)
  801199:	e8 a0 ff ff ff       	call   80113e <fd_lookup>
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	78 0e                	js     8011b0 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8011a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a8:	89 50 04             	mov    %edx,0x4(%eax)
  8011ab:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8011b0:	c9                   	leave  
  8011b1:	c3                   	ret    

008011b2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011b2:	55                   	push   %ebp
  8011b3:	89 e5                	mov    %esp,%ebp
  8011b5:	53                   	push   %ebx
  8011b6:	83 ec 14             	sub    $0x14,%esp
  8011b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8011bf:	ba 74 67 80 00       	mov    $0x806774,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8011c4:	b8 00 00 00 00       	mov    $0x0,%eax
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8011c9:	39 0d 74 67 80 00    	cmp    %ecx,0x806774
  8011cf:	75 11                	jne    8011e2 <dev_lookup+0x30>
  8011d1:	eb 04                	jmp    8011d7 <dev_lookup+0x25>
  8011d3:	39 0a                	cmp    %ecx,(%edx)
  8011d5:	75 0b                	jne    8011e2 <dev_lookup+0x30>
			*dev = devtab[i];
  8011d7:	89 13                	mov    %edx,(%ebx)
  8011d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011de:	66 90                	xchg   %ax,%ax
  8011e0:	eb 35                	jmp    801217 <dev_lookup+0x65>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011e2:	83 c0 01             	add    $0x1,%eax
  8011e5:	8b 14 85 0c 23 80 00 	mov    0x80230c(,%eax,4),%edx
  8011ec:	85 d2                	test   %edx,%edx
  8011ee:	75 e3                	jne    8011d3 <dev_lookup+0x21>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  8011f0:	a1 10 7f 80 00       	mov    0x807f10,%eax
  8011f5:	8b 40 4c             	mov    0x4c(%eax),%eax
  8011f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801200:	c7 04 24 8c 22 80 00 	movl   $0x80228c,(%esp)
  801207:	e8 19 f0 ff ff       	call   800225 <cprintf>
	*dev = 0;
  80120c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801212:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801217:	83 c4 14             	add    $0x14,%esp
  80121a:	5b                   	pop    %ebx
  80121b:	5d                   	pop    %ebp
  80121c:	c3                   	ret    

0080121d <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80121d:	55                   	push   %ebp
  80121e:	89 e5                	mov    %esp,%ebp
  801220:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801223:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801226:	89 44 24 04          	mov    %eax,0x4(%esp)
  80122a:	8b 45 08             	mov    0x8(%ebp),%eax
  80122d:	89 04 24             	mov    %eax,(%esp)
  801230:	e8 09 ff ff ff       	call   80113e <fd_lookup>
  801235:	89 c2                	mov    %eax,%edx
  801237:	85 c0                	test   %eax,%eax
  801239:	78 5a                	js     801295 <fstat+0x78>
  80123b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80123e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801242:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801245:	8b 00                	mov    (%eax),%eax
  801247:	89 04 24             	mov    %eax,(%esp)
  80124a:	e8 63 ff ff ff       	call   8011b2 <dev_lookup>
  80124f:	89 c2                	mov    %eax,%edx
  801251:	85 c0                	test   %eax,%eax
  801253:	78 40                	js     801295 <fstat+0x78>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801255:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  80125a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80125d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801261:	74 32                	je     801295 <fstat+0x78>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801263:	8b 45 0c             	mov    0xc(%ebp),%eax
  801266:	c6 00 00             	movb   $0x0,(%eax)
	stat->st_size = 0;
  801269:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  801270:	00 00 00 
	stat->st_isdir = 0;
  801273:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
  80127a:	00 00 00 
	stat->st_dev = dev;
  80127d:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801280:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
	return (*dev->dev_stat)(fd, stat);
  801286:	89 44 24 04          	mov    %eax,0x4(%esp)
  80128a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80128d:	89 04 24             	mov    %eax,(%esp)
  801290:	ff 52 14             	call   *0x14(%edx)
  801293:	89 c2                	mov    %eax,%edx
}
  801295:	89 d0                	mov    %edx,%eax
  801297:	c9                   	leave  
  801298:	c3                   	ret    

00801299 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801299:	55                   	push   %ebp
  80129a:	89 e5                	mov    %esp,%ebp
  80129c:	53                   	push   %ebx
  80129d:	83 ec 24             	sub    $0x24,%esp
  8012a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012aa:	89 1c 24             	mov    %ebx,(%esp)
  8012ad:	e8 8c fe ff ff       	call   80113e <fd_lookup>
  8012b2:	85 c0                	test   %eax,%eax
  8012b4:	78 61                	js     801317 <ftruncate+0x7e>
  8012b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b9:	8b 10                	mov    (%eax),%edx
  8012bb:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8012be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c2:	89 14 24             	mov    %edx,(%esp)
  8012c5:	e8 e8 fe ff ff       	call   8011b2 <dev_lookup>
  8012ca:	85 c0                	test   %eax,%eax
  8012cc:	78 49                	js     801317 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012ce:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  8012d1:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  8012d5:	75 23                	jne    8012fa <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012d7:	a1 10 7f 80 00       	mov    0x807f10,%eax
  8012dc:	8b 40 4c             	mov    0x4c(%eax),%eax
  8012df:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e7:	c7 04 24 ac 22 80 00 	movl   $0x8022ac,(%esp)
  8012ee:	e8 32 ef ff ff       	call   800225 <cprintf>
  8012f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f8:	eb 1d                	jmp    801317 <ftruncate+0x7e>
			env->env_id, fdnum); 
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8012fa:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8012fd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801302:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  801306:	74 0f                	je     801317 <ftruncate+0x7e>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801308:	8b 42 18             	mov    0x18(%edx),%eax
  80130b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80130e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801312:	89 0c 24             	mov    %ecx,(%esp)
  801315:	ff d0                	call   *%eax
}
  801317:	83 c4 24             	add    $0x24,%esp
  80131a:	5b                   	pop    %ebx
  80131b:	5d                   	pop    %ebp
  80131c:	c3                   	ret    

0080131d <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80131d:	55                   	push   %ebp
  80131e:	89 e5                	mov    %esp,%ebp
  801320:	53                   	push   %ebx
  801321:	83 ec 24             	sub    $0x24,%esp
  801324:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801327:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80132e:	89 1c 24             	mov    %ebx,(%esp)
  801331:	e8 08 fe ff ff       	call   80113e <fd_lookup>
  801336:	85 c0                	test   %eax,%eax
  801338:	78 68                	js     8013a2 <write+0x85>
  80133a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80133d:	8b 10                	mov    (%eax),%edx
  80133f:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801342:	89 44 24 04          	mov    %eax,0x4(%esp)
  801346:	89 14 24             	mov    %edx,(%esp)
  801349:	e8 64 fe ff ff       	call   8011b2 <dev_lookup>
  80134e:	85 c0                	test   %eax,%eax
  801350:	78 50                	js     8013a2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801352:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801355:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801359:	75 23                	jne    80137e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  80135b:	a1 10 7f 80 00       	mov    0x807f10,%eax
  801360:	8b 40 4c             	mov    0x4c(%eax),%eax
  801363:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801367:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136b:	c7 04 24 d0 22 80 00 	movl   $0x8022d0,(%esp)
  801372:	e8 ae ee ff ff       	call   800225 <cprintf>
  801377:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80137c:	eb 24                	jmp    8013a2 <write+0x85>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80137e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801381:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801386:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  80138a:	74 16                	je     8013a2 <write+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80138c:	8b 42 0c             	mov    0xc(%edx),%eax
  80138f:	8b 55 10             	mov    0x10(%ebp),%edx
  801392:	89 54 24 08          	mov    %edx,0x8(%esp)
  801396:	8b 55 0c             	mov    0xc(%ebp),%edx
  801399:	89 54 24 04          	mov    %edx,0x4(%esp)
  80139d:	89 0c 24             	mov    %ecx,(%esp)
  8013a0:	ff d0                	call   *%eax
}
  8013a2:	83 c4 24             	add    $0x24,%esp
  8013a5:	5b                   	pop    %ebx
  8013a6:	5d                   	pop    %ebp
  8013a7:	c3                   	ret    

008013a8 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013a8:	55                   	push   %ebp
  8013a9:	89 e5                	mov    %esp,%ebp
  8013ab:	53                   	push   %ebx
  8013ac:	83 ec 24             	sub    $0x24,%esp
  8013af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b9:	89 1c 24             	mov    %ebx,(%esp)
  8013bc:	e8 7d fd ff ff       	call   80113e <fd_lookup>
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	78 6d                	js     801432 <read+0x8a>
  8013c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c8:	8b 10                	mov    (%eax),%edx
  8013ca:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8013cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d1:	89 14 24             	mov    %edx,(%esp)
  8013d4:	e8 d9 fd ff ff       	call   8011b2 <dev_lookup>
  8013d9:	85 c0                	test   %eax,%eax
  8013db:	78 55                	js     801432 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013dd:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  8013e0:	8b 41 08             	mov    0x8(%ecx),%eax
  8013e3:	83 e0 03             	and    $0x3,%eax
  8013e6:	83 f8 01             	cmp    $0x1,%eax
  8013e9:	75 23                	jne    80140e <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  8013eb:	a1 10 7f 80 00       	mov    0x807f10,%eax
  8013f0:	8b 40 4c             	mov    0x4c(%eax),%eax
  8013f3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013fb:	c7 04 24 ed 22 80 00 	movl   $0x8022ed,(%esp)
  801402:	e8 1e ee ff ff       	call   800225 <cprintf>
  801407:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80140c:	eb 24                	jmp    801432 <read+0x8a>
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80140e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801411:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801416:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  80141a:	74 16                	je     801432 <read+0x8a>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80141c:	8b 42 08             	mov    0x8(%edx),%eax
  80141f:	8b 55 10             	mov    0x10(%ebp),%edx
  801422:	89 54 24 08          	mov    %edx,0x8(%esp)
  801426:	8b 55 0c             	mov    0xc(%ebp),%edx
  801429:	89 54 24 04          	mov    %edx,0x4(%esp)
  80142d:	89 0c 24             	mov    %ecx,(%esp)
  801430:	ff d0                	call   *%eax
}
  801432:	83 c4 24             	add    $0x24,%esp
  801435:	5b                   	pop    %ebx
  801436:	5d                   	pop    %ebp
  801437:	c3                   	ret    

00801438 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801438:	55                   	push   %ebp
  801439:	89 e5                	mov    %esp,%ebp
  80143b:	57                   	push   %edi
  80143c:	56                   	push   %esi
  80143d:	53                   	push   %ebx
  80143e:	83 ec 0c             	sub    $0xc,%esp
  801441:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801444:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801447:	b8 00 00 00 00       	mov    $0x0,%eax
  80144c:	85 f6                	test   %esi,%esi
  80144e:	74 36                	je     801486 <readn+0x4e>
  801450:	bb 00 00 00 00       	mov    $0x0,%ebx
  801455:	ba 00 00 00 00       	mov    $0x0,%edx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80145a:	89 f0                	mov    %esi,%eax
  80145c:	29 d0                	sub    %edx,%eax
  80145e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801462:	8d 04 17             	lea    (%edi,%edx,1),%eax
  801465:	89 44 24 04          	mov    %eax,0x4(%esp)
  801469:	8b 45 08             	mov    0x8(%ebp),%eax
  80146c:	89 04 24             	mov    %eax,(%esp)
  80146f:	e8 34 ff ff ff       	call   8013a8 <read>
		if (m < 0)
  801474:	85 c0                	test   %eax,%eax
  801476:	78 0e                	js     801486 <readn+0x4e>
			return m;
		if (m == 0)
  801478:	85 c0                	test   %eax,%eax
  80147a:	74 08                	je     801484 <readn+0x4c>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80147c:	01 c3                	add    %eax,%ebx
  80147e:	89 da                	mov    %ebx,%edx
  801480:	39 f3                	cmp    %esi,%ebx
  801482:	72 d6                	jb     80145a <readn+0x22>
  801484:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801486:	83 c4 0c             	add    $0xc,%esp
  801489:	5b                   	pop    %ebx
  80148a:	5e                   	pop    %esi
  80148b:	5f                   	pop    %edi
  80148c:	5d                   	pop    %ebp
  80148d:	c3                   	ret    

0080148e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
  801491:	83 ec 28             	sub    $0x28,%esp
  801494:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801497:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80149a:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80149d:	89 34 24             	mov    %esi,(%esp)
  8014a0:	e8 1b fc ff ff       	call   8010c0 <fd2num>
  8014a5:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8014a8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014ac:	89 04 24             	mov    %eax,(%esp)
  8014af:	e8 8a fc ff ff       	call   80113e <fd_lookup>
  8014b4:	89 c3                	mov    %eax,%ebx
  8014b6:	85 c0                	test   %eax,%eax
  8014b8:	78 05                	js     8014bf <fd_close+0x31>
  8014ba:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014bd:	74 0d                	je     8014cc <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8014bf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8014c3:	75 44                	jne    801509 <fd_close+0x7b>
  8014c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014ca:	eb 3d                	jmp    801509 <fd_close+0x7b>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d3:	8b 06                	mov    (%esi),%eax
  8014d5:	89 04 24             	mov    %eax,(%esp)
  8014d8:	e8 d5 fc ff ff       	call   8011b2 <dev_lookup>
  8014dd:	89 c3                	mov    %eax,%ebx
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	78 16                	js     8014f9 <fd_close+0x6b>
		if (dev->dev_close)
  8014e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e6:	8b 40 10             	mov    0x10(%eax),%eax
  8014e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014ee:	85 c0                	test   %eax,%eax
  8014f0:	74 07                	je     8014f9 <fd_close+0x6b>
			r = (*dev->dev_close)(fd);
  8014f2:	89 34 24             	mov    %esi,(%esp)
  8014f5:	ff d0                	call   *%eax
  8014f7:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801504:	e8 d1 f9 ff ff       	call   800eda <sys_page_unmap>
	return r;
}
  801509:	89 d8                	mov    %ebx,%eax
  80150b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80150e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801511:	89 ec                	mov    %ebp,%esp
  801513:	5d                   	pop    %ebp
  801514:	c3                   	ret    

00801515 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80151b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80151e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801522:	8b 45 08             	mov    0x8(%ebp),%eax
  801525:	89 04 24             	mov    %eax,(%esp)
  801528:	e8 11 fc ff ff       	call   80113e <fd_lookup>
  80152d:	85 c0                	test   %eax,%eax
  80152f:	78 13                	js     801544 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801531:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801538:	00 
  801539:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80153c:	89 04 24             	mov    %eax,(%esp)
  80153f:	e8 4a ff ff ff       	call   80148e <fd_close>
}
  801544:	c9                   	leave  
  801545:	c3                   	ret    

00801546 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801546:	55                   	push   %ebp
  801547:	89 e5                	mov    %esp,%ebp
  801549:	83 ec 18             	sub    $0x18,%esp
  80154c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80154f:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801552:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801559:	00 
  80155a:	8b 45 08             	mov    0x8(%ebp),%eax
  80155d:	89 04 24             	mov    %eax,(%esp)
  801560:	e8 6a 03 00 00       	call   8018cf <open>
  801565:	89 c6                	mov    %eax,%esi
  801567:	85 c0                	test   %eax,%eax
  801569:	78 1b                	js     801586 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  80156b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80156e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801572:	89 34 24             	mov    %esi,(%esp)
  801575:	e8 a3 fc ff ff       	call   80121d <fstat>
  80157a:	89 c3                	mov    %eax,%ebx
	close(fd);
  80157c:	89 34 24             	mov    %esi,(%esp)
  80157f:	e8 91 ff ff ff       	call   801515 <close>
  801584:	89 de                	mov    %ebx,%esi
	return r;
}
  801586:	89 f0                	mov    %esi,%eax
  801588:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80158b:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80158e:	89 ec                	mov    %ebp,%esp
  801590:	5d                   	pop    %ebp
  801591:	c3                   	ret    

00801592 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801592:	55                   	push   %ebp
  801593:	89 e5                	mov    %esp,%ebp
  801595:	83 ec 38             	sub    $0x38,%esp
  801598:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80159b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80159e:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8015a1:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ae:	89 04 24             	mov    %eax,(%esp)
  8015b1:	e8 88 fb ff ff       	call   80113e <fd_lookup>
  8015b6:	89 c3                	mov    %eax,%ebx
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	0f 88 e1 00 00 00    	js     8016a1 <dup+0x10f>
		return r;
	close(newfdnum);
  8015c0:	89 3c 24             	mov    %edi,(%esp)
  8015c3:	e8 4d ff ff ff       	call   801515 <close>

	newfd = INDEX2FD(newfdnum);
  8015c8:	89 f8                	mov    %edi,%eax
  8015ca:	c1 e0 0c             	shl    $0xc,%eax
  8015cd:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  8015d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d6:	89 04 24             	mov    %eax,(%esp)
  8015d9:	e8 f2 fa ff ff       	call   8010d0 <fd2data>
  8015de:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015e0:	89 34 24             	mov    %esi,(%esp)
  8015e3:	e8 e8 fa ff ff       	call   8010d0 <fd2data>
  8015e8:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  8015eb:	89 d8                	mov    %ebx,%eax
  8015ed:	c1 e8 16             	shr    $0x16,%eax
  8015f0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015f7:	a8 01                	test   $0x1,%al
  8015f9:	74 45                	je     801640 <dup+0xae>
  8015fb:	89 da                	mov    %ebx,%edx
  8015fd:	c1 ea 0c             	shr    $0xc,%edx
  801600:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801607:	a8 01                	test   $0x1,%al
  801609:	74 35                	je     801640 <dup+0xae>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  80160b:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801612:	25 07 0e 00 00       	and    $0xe07,%eax
  801617:	89 44 24 10          	mov    %eax,0x10(%esp)
  80161b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80161e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801622:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801629:	00 
  80162a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80162e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801635:	e8 fe f8 ff ff       	call   800f38 <sys_page_map>
  80163a:	89 c3                	mov    %eax,%ebx
  80163c:	85 c0                	test   %eax,%eax
  80163e:	78 3e                	js     80167e <dup+0xec>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  801640:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801643:	89 d0                	mov    %edx,%eax
  801645:	c1 e8 0c             	shr    $0xc,%eax
  801648:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80164f:	25 07 0e 00 00       	and    $0xe07,%eax
  801654:	89 44 24 10          	mov    %eax,0x10(%esp)
  801658:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80165c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801663:	00 
  801664:	89 54 24 04          	mov    %edx,0x4(%esp)
  801668:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80166f:	e8 c4 f8 ff ff       	call   800f38 <sys_page_map>
  801674:	89 c3                	mov    %eax,%ebx
  801676:	85 c0                	test   %eax,%eax
  801678:	78 04                	js     80167e <dup+0xec>
		goto err;
  80167a:	89 fb                	mov    %edi,%ebx
  80167c:	eb 23                	jmp    8016a1 <dup+0x10f>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80167e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801682:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801689:	e8 4c f8 ff ff       	call   800eda <sys_page_unmap>
	sys_page_unmap(0, nva);
  80168e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801691:	89 44 24 04          	mov    %eax,0x4(%esp)
  801695:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80169c:	e8 39 f8 ff ff       	call   800eda <sys_page_unmap>
	return r;
}
  8016a1:	89 d8                	mov    %ebx,%eax
  8016a3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8016a6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8016a9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8016ac:	89 ec                	mov    %ebp,%esp
  8016ae:	5d                   	pop    %ebp
  8016af:	c3                   	ret    

008016b0 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	53                   	push   %ebx
  8016b4:	83 ec 04             	sub    $0x4,%esp
  8016b7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8016bc:	89 1c 24             	mov    %ebx,(%esp)
  8016bf:	e8 51 fe ff ff       	call   801515 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016c4:	83 c3 01             	add    $0x1,%ebx
  8016c7:	83 fb 20             	cmp    $0x20,%ebx
  8016ca:	75 f0                	jne    8016bc <close_all+0xc>
		close(i);
}
  8016cc:	83 c4 04             	add    $0x4,%esp
  8016cf:	5b                   	pop    %ebx
  8016d0:	5d                   	pop    %ebp
  8016d1:	c3                   	ret    
	...

008016d4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	53                   	push   %ebx
  8016d8:	83 ec 14             	sub    $0x14,%esp
  8016db:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016dd:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  8016e3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8016ea:	00 
  8016eb:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  8016f2:	00 
  8016f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f7:	89 14 24             	mov    %edx,(%esp)
  8016fa:	e8 31 03 00 00       	call   801a30 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016ff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801706:	00 
  801707:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80170b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801712:	e8 cd 03 00 00       	call   801ae4 <ipc_recv>
}
  801717:	83 c4 14             	add    $0x14,%esp
  80171a:	5b                   	pop    %ebx
  80171b:	5d                   	pop    %ebp
  80171c:	c3                   	ret    

0080171d <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801723:	ba 00 00 00 00       	mov    $0x0,%edx
  801728:	b8 08 00 00 00       	mov    $0x8,%eax
  80172d:	e8 a2 ff ff ff       	call   8016d4 <fsipc>
}
  801732:	c9                   	leave  
  801733:	c3                   	ret    

00801734 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80173a:	8b 45 08             	mov    0x8(%ebp),%eax
  80173d:	8b 40 0c             	mov    0xc(%eax),%eax
  801740:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.set_size.req_size = newsize;
  801745:	8b 45 0c             	mov    0xc(%ebp),%eax
  801748:	a3 04 30 80 00       	mov    %eax,0x803004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80174d:	ba 00 00 00 00       	mov    $0x0,%edx
  801752:	b8 02 00 00 00       	mov    $0x2,%eax
  801757:	e8 78 ff ff ff       	call   8016d4 <fsipc>
}
  80175c:	c9                   	leave  
  80175d:	c3                   	ret    

0080175e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80175e:	55                   	push   %ebp
  80175f:	89 e5                	mov    %esp,%ebp
  801761:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801764:	8b 45 08             	mov    0x8(%ebp),%eax
  801767:	8b 40 0c             	mov    0xc(%eax),%eax
  80176a:	a3 00 30 80 00       	mov    %eax,0x803000
	return fsipc(FSREQ_FLUSH, NULL);
  80176f:	ba 00 00 00 00       	mov    $0x0,%edx
  801774:	b8 06 00 00 00       	mov    $0x6,%eax
  801779:	e8 56 ff ff ff       	call   8016d4 <fsipc>
}
  80177e:	c9                   	leave  
  80177f:	c3                   	ret    

00801780 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	53                   	push   %ebx
  801784:	83 ec 14             	sub    $0x14,%esp
  801787:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80178a:	8b 45 08             	mov    0x8(%ebp),%eax
  80178d:	8b 40 0c             	mov    0xc(%eax),%eax
  801790:	a3 00 30 80 00       	mov    %eax,0x803000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801795:	ba 00 00 00 00       	mov    $0x0,%edx
  80179a:	b8 05 00 00 00       	mov    $0x5,%eax
  80179f:	e8 30 ff ff ff       	call   8016d4 <fsipc>
  8017a4:	85 c0                	test   %eax,%eax
  8017a6:	78 2b                	js     8017d3 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017a8:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  8017af:	00 
  8017b0:	89 1c 24             	mov    %ebx,(%esp)
  8017b3:	e8 d9 f0 ff ff       	call   800891 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017b8:	a1 80 30 80 00       	mov    0x803080,%eax
  8017bd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017c3:	a1 84 30 80 00       	mov    0x803084,%eax
  8017c8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8017ce:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8017d3:	83 c4 14             	add    $0x14,%esp
  8017d6:	5b                   	pop    %ebx
  8017d7:	5d                   	pop    %ebp
  8017d8:	c3                   	ret    

008017d9 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	83 ec 18             	sub    $0x18,%esp
  8017df:	8b 55 10             	mov    0x10(%ebp),%edx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	ssize_t writesize;
	size_t bufsize;
	fsipcbuf.write.req_fileid=fd->fd_file.id;
  8017e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e8:	a3 00 30 80 00       	mov    %eax,0x803000
	bufsize=sizeof(fsipcbuf.write.req_buf);
	if(n<bufsize)
  8017ed:	89 d0                	mov    %edx,%eax
  8017ef:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  8017f5:	76 05                	jbe    8017fc <devfile_write+0x23>
  8017f7:	b8 f8 0f 00 00       	mov    $0xff8,%eax
		bufsize=n;	
	fsipcbuf.write.req_n=n;
  8017fc:	89 15 04 30 80 00    	mov    %edx,0x803004
	memmove((void*)fsipcbuf.write.req_buf,buf,bufsize);
  801802:	89 44 24 08          	mov    %eax,0x8(%esp)
  801806:	8b 45 0c             	mov    0xc(%ebp),%eax
  801809:	89 44 24 04          	mov    %eax,0x4(%esp)
  80180d:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  801814:	e8 7f f2 ff ff       	call   800a98 <memmove>
	writesize=(ssize_t)fsipc(FSREQ_WRITE,NULL);
  801819:	ba 00 00 00 00       	mov    $0x0,%edx
  80181e:	b8 04 00 00 00       	mov    $0x4,%eax
  801823:	e8 ac fe ff ff       	call   8016d4 <fsipc>
	return writesize;
	//panic("devfile_write not implemented");
}
  801828:	c9                   	leave  
  801829:	c3                   	ret    

0080182a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80182a:	55                   	push   %ebp
  80182b:	89 e5                	mov    %esp,%ebp
  80182d:	53                   	push   %ebx
  80182e:	83 ec 14             	sub    $0x14,%esp
	// system server.
	// LAB 5: Your code here
	ssize_t readsize;
	if(debug)
		cprintf("devfile_read:fileid=%x readsize=%x\n",fd->fd_file.id,n);
	fsipcbuf.read.req_fileid=fd->fd_file.id;
  801831:	8b 45 08             	mov    0x8(%ebp),%eax
  801834:	8b 40 0c             	mov    0xc(%eax),%eax
  801837:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.read.req_n=n;
  80183c:	8b 45 10             	mov    0x10(%ebp),%eax
  80183f:	a3 04 30 80 00       	mov    %eax,0x803004
	readsize=(ssize_t)fsipc(FSREQ_READ,&fsipcbuf);
  801844:	ba 00 30 80 00       	mov    $0x803000,%edx
  801849:	b8 03 00 00 00       	mov    $0x3,%eax
  80184e:	e8 81 fe ff ff       	call   8016d4 <fsipc>
  801853:	89 c3                	mov    %eax,%ebx
	cprintf("readsize=%d\n",readsize);
  801855:	89 44 24 04          	mov    %eax,0x4(%esp)
  801859:	c7 04 24 14 23 80 00 	movl   $0x802314,(%esp)
  801860:	e8 c0 e9 ff ff       	call   800225 <cprintf>
	if(debug)
		cprintf("devfile_read:buf1=%s\nbuf2=%s\n",(char*)&fsipcbuf,fsipcbuf.readRet.ret_buf);
	if(readsize>0)
  801865:	85 db                	test   %ebx,%ebx
  801867:	7e 17                	jle    801880 <devfile_read+0x56>
		memmove(buf,(void*)&fsipcbuf,(size_t)readsize);
  801869:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80186d:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801874:	00 
  801875:	8b 45 0c             	mov    0xc(%ebp),%eax
  801878:	89 04 24             	mov    %eax,(%esp)
  80187b:	e8 18 f2 ff ff       	call   800a98 <memmove>
	//cprintf("readsize=%d",readsize);
	return readsize;
	//panic("devfile_read not implemented");
}
  801880:	89 d8                	mov    %ebx,%eax
  801882:	83 c4 14             	add    $0x14,%esp
  801885:	5b                   	pop    %ebx
  801886:	5d                   	pop    %ebp
  801887:	c3                   	ret    

00801888 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801888:	55                   	push   %ebp
  801889:	89 e5                	mov    %esp,%ebp
  80188b:	53                   	push   %ebx
  80188c:	83 ec 14             	sub    $0x14,%esp
  80188f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801892:	89 1c 24             	mov    %ebx,(%esp)
  801895:	e8 a6 ef ff ff       	call   800840 <strlen>
  80189a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  80189f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018a4:	7f 21                	jg     8018c7 <remove+0x3f>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  8018a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018aa:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  8018b1:	e8 db ef ff ff       	call   800891 <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  8018b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018bb:	b8 07 00 00 00       	mov    $0x7,%eax
  8018c0:	e8 0f fe ff ff       	call   8016d4 <fsipc>
  8018c5:	89 c2                	mov    %eax,%edx
}
  8018c7:	89 d0                	mov    %edx,%eax
  8018c9:	83 c4 14             	add    $0x14,%esp
  8018cc:	5b                   	pop    %ebx
  8018cd:	5d                   	pop    %ebp
  8018ce:	c3                   	ret    

008018cf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	53                   	push   %ebx
  8018d3:	83 ec 24             	sub    $0x24,%esp
	// file descriptor.

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;
	if((r=fd_alloc(&fd))<0){
  8018d6:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8018d9:	89 04 24             	mov    %eax,(%esp)
  8018dc:	e8 0a f8 ff ff       	call   8010eb <fd_alloc>
  8018e1:	89 c3                	mov    %eax,%ebx
  8018e3:	85 c0                	test   %eax,%eax
  8018e5:	79 18                	jns    8018ff <open+0x30>
		fd_close(fd,0);
  8018e7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8018ee:	00 
  8018ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8018f2:	89 04 24             	mov    %eax,(%esp)
  8018f5:	e8 94 fb ff ff       	call   80148e <fd_close>
  8018fa:	e9 b4 00 00 00       	jmp    8019b3 <open+0xe4>
		return r;
	}
	cprintf("open:fd=%x\n",fd);
  8018ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801902:	89 44 24 04          	mov    %eax,0x4(%esp)
  801906:	c7 04 24 21 23 80 00 	movl   $0x802321,(%esp)
  80190d:	e8 13 e9 ff ff       	call   800225 <cprintf>
	strcpy(fsipcbuf.open.req_path,path);
  801912:	8b 45 08             	mov    0x8(%ebp),%eax
  801915:	89 44 24 04          	mov    %eax,0x4(%esp)
  801919:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801920:	e8 6c ef ff ff       	call   800891 <strcpy>
	fsipcbuf.open.req_omode=mode;
  801925:	8b 45 0c             	mov    0xc(%ebp),%eax
  801928:	a3 00 34 80 00       	mov    %eax,0x803400
	if((r=fsipc(FSREQ_OPEN,(void*)fd))<0)
  80192d:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801930:	b8 01 00 00 00       	mov    $0x1,%eax
  801935:	e8 9a fd ff ff       	call   8016d4 <fsipc>
  80193a:	89 c3                	mov    %eax,%ebx
  80193c:	85 c0                	test   %eax,%eax
  80193e:	79 15                	jns    801955 <open+0x86>
	{
		fd_close(fd,1);
  801940:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801947:	00 
  801948:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80194b:	89 04 24             	mov    %eax,(%esp)
  80194e:	e8 3b fb ff ff       	call   80148e <fd_close>
  801953:	eb 5e                	jmp    8019b3 <open+0xe4>
		return r;	
	}
	if((r=sys_page_map(0,(void*)fd,0,(void*)fd,PTE_P | PTE_W | PTE_U))<0)
  801955:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801958:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80195f:	00 
  801960:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801964:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80196b:	00 
  80196c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801970:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801977:	e8 bc f5 ff ff       	call   800f38 <sys_page_map>
  80197c:	89 c3                	mov    %eax,%ebx
  80197e:	85 c0                	test   %eax,%eax
  801980:	79 15                	jns    801997 <open+0xc8>
	{
		fd_close(fd,1);
  801982:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801989:	00 
  80198a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80198d:	89 04 24             	mov    %eax,(%esp)
  801990:	e8 f9 fa ff ff       	call   80148e <fd_close>
  801995:	eb 1c                	jmp    8019b3 <open+0xe4>
		return r;
	}
	//INDEX2DATA(fd->fd_file.id);
	cprintf("fileid=%x\n",fd->fd_file.id);
  801997:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80199a:	8b 40 0c             	mov    0xc(%eax),%eax
  80199d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a1:	c7 04 24 2d 23 80 00 	movl   $0x80232d,(%esp)
  8019a8:	e8 78 e8 ff ff       	call   800225 <cprintf>
	return fd->fd_file.id;
  8019ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8019b0:	8b 58 0c             	mov    0xc(%eax),%ebx
	//panic("open not implemented");
}
  8019b3:	89 d8                	mov    %ebx,%eax
  8019b5:	83 c4 24             	add    $0x24,%esp
  8019b8:	5b                   	pop    %ebx
  8019b9:	5d                   	pop    %ebp
  8019ba:	c3                   	ret    
	...

008019bc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
  8019bf:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8019c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8019c5:	89 45 fc             	mov    %eax,-0x4(%ebp)

	// Print the panic message
	if (argv0)
  8019c8:	a1 14 7f 80 00       	mov    0x807f14,%eax
  8019cd:	85 c0                	test   %eax,%eax
  8019cf:	74 10                	je     8019e1 <_panic+0x25>
		cprintf("%s: ", argv0);
  8019d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d5:	c7 04 24 38 23 80 00 	movl   $0x802338,(%esp)
  8019dc:	e8 44 e8 ff ff       	call   800225 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8019e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019ef:	a1 70 67 80 00       	mov    0x806770,%eax
  8019f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f8:	c7 04 24 3d 23 80 00 	movl   $0x80233d,(%esp)
  8019ff:	e8 21 e8 ff ff       	call   800225 <cprintf>
	vcprintf(fmt, ap);
  801a04:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801a07:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a0b:	8b 45 10             	mov    0x10(%ebp),%eax
  801a0e:	89 04 24             	mov    %eax,(%esp)
  801a11:	e8 ae e7 ff ff       	call   8001c4 <vcprintf>
	cprintf("\n");
  801a16:	c7 04 24 1f 23 80 00 	movl   $0x80231f,(%esp)
  801a1d:	e8 03 e8 ff ff       	call   800225 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a22:	cc                   	int3   
  801a23:	eb fd                	jmp    801a22 <_panic+0x66>
	...

00801a30 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
  801a33:	57                   	push   %edi
  801a34:	56                   	push   %esi
  801a35:	53                   	push   %ebx
  801a36:	83 ec 1c             	sub    $0x1c,%esp
  801a39:	8b 75 08             	mov    0x8(%ebp),%esi
  801a3c:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  801a3f:	e8 e5 f5 ff ff       	call   801029 <sys_getenvid>
  801a44:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a49:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a4c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801a51:	a3 10 7f 80 00       	mov    %eax,0x807f10
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  801a56:	e8 ce f5 ff ff       	call   801029 <sys_getenvid>
  801a5b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a60:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a63:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801a68:	a3 10 7f 80 00       	mov    %eax,0x807f10
		if(env->env_id==to_env){
  801a6d:	8b 40 4c             	mov    0x4c(%eax),%eax
  801a70:	39 f0                	cmp    %esi,%eax
  801a72:	75 0e                	jne    801a82 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  801a74:	c7 04 24 59 23 80 00 	movl   $0x802359,(%esp)
  801a7b:	e8 a5 e7 ff ff       	call   800225 <cprintf>
  801a80:	eb 5a                	jmp    801adc <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  801a82:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a86:	8b 45 10             	mov    0x10(%ebp),%eax
  801a89:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a90:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a94:	89 34 24             	mov    %esi,(%esp)
  801a97:	e8 ec f2 ff ff       	call   800d88 <sys_ipc_try_send>
  801a9c:	89 c3                	mov    %eax,%ebx
  801a9e:	85 c0                	test   %eax,%eax
  801aa0:	79 25                	jns    801ac7 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  801aa2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aa5:	74 2b                	je     801ad2 <ipc_send+0xa2>
				panic("send error:%e",r);
  801aa7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801aab:	c7 44 24 08 75 23 80 	movl   $0x802375,0x8(%esp)
  801ab2:	00 
  801ab3:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  801aba:	00 
  801abb:	c7 04 24 83 23 80 00 	movl   $0x802383,(%esp)
  801ac2:	e8 f5 fe ff ff       	call   8019bc <_panic>
		}
			sys_yield();
  801ac7:	e8 29 f5 ff ff       	call   800ff5 <sys_yield>
		
	}while(r!=0);
  801acc:	85 db                	test   %ebx,%ebx
  801ace:	75 86                	jne    801a56 <ipc_send+0x26>
  801ad0:	eb 0a                	jmp    801adc <ipc_send+0xac>
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
		{	
			if(r!=-E_IPC_NOT_RECV)
				panic("send error:%e",r);
		}
			sys_yield();
  801ad2:	e8 1e f5 ff ff       	call   800ff5 <sys_yield>
  801ad7:	e9 7a ff ff ff       	jmp    801a56 <ipc_send+0x26>
		
	}while(r!=0);
	return;
	//panic("ipc_send not implemented");
}
  801adc:	83 c4 1c             	add    $0x1c,%esp
  801adf:	5b                   	pop    %ebx
  801ae0:	5e                   	pop    %esi
  801ae1:	5f                   	pop    %edi
  801ae2:	5d                   	pop    %ebp
  801ae3:	c3                   	ret    

00801ae4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	57                   	push   %edi
  801ae8:	56                   	push   %esi
  801ae9:	53                   	push   %ebx
  801aea:	83 ec 0c             	sub    $0xc,%esp
  801aed:	8b 75 08             	mov    0x8(%ebp),%esi
  801af0:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	void *dstva=NULL;
	if(pg)
		dstva=pg;
	env = &envs[ENVX(sys_getenvid())];
  801af3:	e8 31 f5 ff ff       	call   801029 <sys_getenvid>
  801af8:	25 ff 03 00 00       	and    $0x3ff,%eax
  801afd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b00:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b05:	a3 10 7f 80 00       	mov    %eax,0x807f10
	if(from_env_store&&(env->env_id==*from_env_store))
  801b0a:	85 f6                	test   %esi,%esi
  801b0c:	74 29                	je     801b37 <ipc_recv+0x53>
  801b0e:	8b 40 4c             	mov    0x4c(%eax),%eax
  801b11:	3b 06                	cmp    (%esi),%eax
  801b13:	75 22                	jne    801b37 <ipc_recv+0x53>
	{
		*from_env_store=0;
  801b15:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  801b1b:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("send:the reciver is sender\n");
  801b21:	c7 04 24 59 23 80 00 	movl   $0x802359,(%esp)
  801b28:	e8 f8 e6 ff ff       	call   800225 <cprintf>
  801b2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b32:	e9 8a 00 00 00       	jmp    801bc1 <ipc_recv+0xdd>
		return 0;
	}
	env = &envs[ENVX(sys_getenvid())];
  801b37:	e8 ed f4 ff ff       	call   801029 <sys_getenvid>
  801b3c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801b41:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b44:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b49:	a3 10 7f 80 00       	mov    %eax,0x807f10
	if((r=sys_ipc_recv(dstva))<0)
  801b4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b51:	89 04 24             	mov    %eax,(%esp)
  801b54:	e8 d2 f1 ff ff       	call   800d2b <sys_ipc_recv>
  801b59:	89 c3                	mov    %eax,%ebx
  801b5b:	85 c0                	test   %eax,%eax
  801b5d:	79 1a                	jns    801b79 <ipc_recv+0x95>
	{
		*from_env_store=0;
  801b5f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  801b65:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("reciver failed\n");
  801b6b:	c7 04 24 8d 23 80 00 	movl   $0x80238d,(%esp)
  801b72:	e8 ae e6 ff ff       	call   800225 <cprintf>
  801b77:	eb 48                	jmp    801bc1 <ipc_recv+0xdd>
		return r;
	}
	else{//接收成功
		env = &envs[ENVX(sys_getenvid())];
  801b79:	e8 ab f4 ff ff       	call   801029 <sys_getenvid>
  801b7e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801b83:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b86:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b8b:	a3 10 7f 80 00       	mov    %eax,0x807f10
		if(from_env_store)
  801b90:	85 f6                	test   %esi,%esi
  801b92:	74 05                	je     801b99 <ipc_recv+0xb5>
			*from_env_store=env->env_ipc_from;	
  801b94:	8b 40 74             	mov    0x74(%eax),%eax
  801b97:	89 06                	mov    %eax,(%esi)
		if(perm_store)
  801b99:	85 ff                	test   %edi,%edi
  801b9b:	74 0a                	je     801ba7 <ipc_recv+0xc3>
			*perm_store=env->env_ipc_perm;
  801b9d:	a1 10 7f 80 00       	mov    0x807f10,%eax
  801ba2:	8b 40 78             	mov    0x78(%eax),%eax
  801ba5:	89 07                	mov    %eax,(%edi)
		env = &envs[ENVX(sys_getenvid())];
  801ba7:	e8 7d f4 ff ff       	call   801029 <sys_getenvid>
  801bac:	25 ff 03 00 00       	and    $0x3ff,%eax
  801bb1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bb4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bb9:	a3 10 7f 80 00       	mov    %eax,0x807f10
		return env->env_ipc_value;
  801bbe:	8b 58 70             	mov    0x70(%eax),%ebx
	}
	//panic("ipc_recv not implemented");
	return 0;
}
  801bc1:	89 d8                	mov    %ebx,%eax
  801bc3:	83 c4 0c             	add    $0xc,%esp
  801bc6:	5b                   	pop    %ebx
  801bc7:	5e                   	pop    %esi
  801bc8:	5f                   	pop    %edi
  801bc9:	5d                   	pop    %ebp
  801bca:	c3                   	ret    
  801bcb:	00 00                	add    %al,(%eax)
  801bcd:	00 00                	add    %al,(%eax)
	...

00801bd0 <__udivdi3>:
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
  801bd3:	57                   	push   %edi
  801bd4:	56                   	push   %esi
  801bd5:	83 ec 18             	sub    $0x18,%esp
  801bd8:	8b 45 10             	mov    0x10(%ebp),%eax
  801bdb:	8b 55 14             	mov    0x14(%ebp),%edx
  801bde:	8b 75 0c             	mov    0xc(%ebp),%esi
  801be1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801be4:	89 c1                	mov    %eax,%ecx
  801be6:	8b 45 08             	mov    0x8(%ebp),%eax
  801be9:	85 d2                	test   %edx,%edx
  801beb:	89 d7                	mov    %edx,%edi
  801bed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801bf0:	75 1e                	jne    801c10 <__udivdi3+0x40>
  801bf2:	39 f1                	cmp    %esi,%ecx
  801bf4:	0f 86 8d 00 00 00    	jbe    801c87 <__udivdi3+0xb7>
  801bfa:	89 f2                	mov    %esi,%edx
  801bfc:	31 f6                	xor    %esi,%esi
  801bfe:	f7 f1                	div    %ecx
  801c00:	89 c1                	mov    %eax,%ecx
  801c02:	89 c8                	mov    %ecx,%eax
  801c04:	89 f2                	mov    %esi,%edx
  801c06:	83 c4 18             	add    $0x18,%esp
  801c09:	5e                   	pop    %esi
  801c0a:	5f                   	pop    %edi
  801c0b:	5d                   	pop    %ebp
  801c0c:	c3                   	ret    
  801c0d:	8d 76 00             	lea    0x0(%esi),%esi
  801c10:	39 f2                	cmp    %esi,%edx
  801c12:	0f 87 a8 00 00 00    	ja     801cc0 <__udivdi3+0xf0>
  801c18:	0f bd c2             	bsr    %edx,%eax
  801c1b:	83 f0 1f             	xor    $0x1f,%eax
  801c1e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801c21:	0f 84 89 00 00 00    	je     801cb0 <__udivdi3+0xe0>
  801c27:	b8 20 00 00 00       	mov    $0x20,%eax
  801c2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c2f:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801c32:	89 c1                	mov    %eax,%ecx
  801c34:	d3 ea                	shr    %cl,%edx
  801c36:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  801c3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801c3d:	89 f8                	mov    %edi,%eax
  801c3f:	8b 7d f4             	mov    -0xc(%ebp),%edi
  801c42:	d3 e0                	shl    %cl,%eax
  801c44:	09 c2                	or     %eax,%edx
  801c46:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801c49:	d3 e7                	shl    %cl,%edi
  801c4b:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c4f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801c52:	89 f2                	mov    %esi,%edx
  801c54:	d3 e8                	shr    %cl,%eax
  801c56:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  801c5a:	d3 e2                	shl    %cl,%edx
  801c5c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c60:	09 d0                	or     %edx,%eax
  801c62:	d3 ee                	shr    %cl,%esi
  801c64:	89 f2                	mov    %esi,%edx
  801c66:	f7 75 e4             	divl   -0x1c(%ebp)
  801c69:	89 d1                	mov    %edx,%ecx
  801c6b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  801c6e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c71:	f7 e7                	mul    %edi
  801c73:	39 d1                	cmp    %edx,%ecx
  801c75:	89 c6                	mov    %eax,%esi
  801c77:	72 70                	jb     801ce9 <__udivdi3+0x119>
  801c79:	39 ca                	cmp    %ecx,%edx
  801c7b:	74 5f                	je     801cdc <__udivdi3+0x10c>
  801c7d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801c80:	31 f6                	xor    %esi,%esi
  801c82:	e9 7b ff ff ff       	jmp    801c02 <__udivdi3+0x32>
  801c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c8a:	85 c0                	test   %eax,%eax
  801c8c:	75 0c                	jne    801c9a <__udivdi3+0xca>
  801c8e:	b8 01 00 00 00       	mov    $0x1,%eax
  801c93:	31 d2                	xor    %edx,%edx
  801c95:	f7 75 f4             	divl   -0xc(%ebp)
  801c98:	89 c1                	mov    %eax,%ecx
  801c9a:	89 f0                	mov    %esi,%eax
  801c9c:	89 fa                	mov    %edi,%edx
  801c9e:	f7 f1                	div    %ecx
  801ca0:	89 c6                	mov    %eax,%esi
  801ca2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ca5:	f7 f1                	div    %ecx
  801ca7:	89 c1                	mov    %eax,%ecx
  801ca9:	e9 54 ff ff ff       	jmp    801c02 <__udivdi3+0x32>
  801cae:	66 90                	xchg   %ax,%ax
  801cb0:	39 d6                	cmp    %edx,%esi
  801cb2:	77 1c                	ja     801cd0 <__udivdi3+0x100>
  801cb4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cb7:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  801cba:	73 14                	jae    801cd0 <__udivdi3+0x100>
  801cbc:	8d 74 26 00          	lea    0x0(%esi),%esi
  801cc0:	31 c9                	xor    %ecx,%ecx
  801cc2:	31 f6                	xor    %esi,%esi
  801cc4:	e9 39 ff ff ff       	jmp    801c02 <__udivdi3+0x32>
  801cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  801cd0:	b9 01 00 00 00       	mov    $0x1,%ecx
  801cd5:	31 f6                	xor    %esi,%esi
  801cd7:	e9 26 ff ff ff       	jmp    801c02 <__udivdi3+0x32>
  801cdc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801cdf:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  801ce3:	d3 e0                	shl    %cl,%eax
  801ce5:	39 c6                	cmp    %eax,%esi
  801ce7:	76 94                	jbe    801c7d <__udivdi3+0xad>
  801ce9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801cec:	31 f6                	xor    %esi,%esi
  801cee:	83 e9 01             	sub    $0x1,%ecx
  801cf1:	e9 0c ff ff ff       	jmp    801c02 <__udivdi3+0x32>
	...

00801d00 <__umoddi3>:
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
  801d03:	57                   	push   %edi
  801d04:	56                   	push   %esi
  801d05:	83 ec 30             	sub    $0x30,%esp
  801d08:	8b 45 10             	mov    0x10(%ebp),%eax
  801d0b:	8b 55 14             	mov    0x14(%ebp),%edx
  801d0e:	8b 75 08             	mov    0x8(%ebp),%esi
  801d11:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d14:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801d17:	89 c1                	mov    %eax,%ecx
  801d19:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801d1c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d1f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  801d26:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801d2d:	89 fa                	mov    %edi,%edx
  801d2f:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  801d32:	85 c0                	test   %eax,%eax
  801d34:	89 75 f0             	mov    %esi,-0x10(%ebp)
  801d37:	89 7d e0             	mov    %edi,-0x20(%ebp)
  801d3a:	75 14                	jne    801d50 <__umoddi3+0x50>
  801d3c:	39 f9                	cmp    %edi,%ecx
  801d3e:	76 60                	jbe    801da0 <__umoddi3+0xa0>
  801d40:	89 f0                	mov    %esi,%eax
  801d42:	f7 f1                	div    %ecx
  801d44:	89 55 d0             	mov    %edx,-0x30(%ebp)
  801d47:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801d4e:	eb 10                	jmp    801d60 <__umoddi3+0x60>
  801d50:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801d53:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  801d56:	76 18                	jbe    801d70 <__umoddi3+0x70>
  801d58:	89 75 d0             	mov    %esi,-0x30(%ebp)
  801d5b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801d5e:	66 90                	xchg   %ax,%ax
  801d60:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801d63:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801d66:	83 c4 30             	add    $0x30,%esp
  801d69:	5e                   	pop    %esi
  801d6a:	5f                   	pop    %edi
  801d6b:	5d                   	pop    %ebp
  801d6c:	c3                   	ret    
  801d6d:	8d 76 00             	lea    0x0(%esi),%esi
  801d70:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
  801d74:	83 f0 1f             	xor    $0x1f,%eax
  801d77:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801d7a:	75 46                	jne    801dc2 <__umoddi3+0xc2>
  801d7c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d7f:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  801d82:	0f 87 c9 00 00 00    	ja     801e51 <__umoddi3+0x151>
  801d88:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  801d8b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  801d8e:	0f 83 bd 00 00 00    	jae    801e51 <__umoddi3+0x151>
  801d94:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801d97:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  801d9a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  801d9d:	eb c1                	jmp    801d60 <__umoddi3+0x60>
  801d9f:	90                   	nop    
  801da0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801da3:	85 c0                	test   %eax,%eax
  801da5:	75 0c                	jne    801db3 <__umoddi3+0xb3>
  801da7:	b8 01 00 00 00       	mov    $0x1,%eax
  801dac:	31 d2                	xor    %edx,%edx
  801dae:	f7 75 ec             	divl   -0x14(%ebp)
  801db1:	89 c1                	mov    %eax,%ecx
  801db3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801db6:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801db9:	f7 f1                	div    %ecx
  801dbb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dbe:	f7 f1                	div    %ecx
  801dc0:	eb 82                	jmp    801d44 <__umoddi3+0x44>
  801dc2:	b8 20 00 00 00       	mov    $0x20,%eax
  801dc7:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801dca:	2b 45 d8             	sub    -0x28(%ebp),%eax
  801dcd:	8b 75 ec             	mov    -0x14(%ebp),%esi
  801dd0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801dd3:	89 c1                	mov    %eax,%ecx
  801dd5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801dd8:	d3 ea                	shr    %cl,%edx
  801dda:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801ddd:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  801de1:	d3 e0                	shl    %cl,%eax
  801de3:	09 c2                	or     %eax,%edx
  801de5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801de8:	d3 e6                	shl    %cl,%esi
  801dea:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  801dee:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801df1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801df4:	d3 e8                	shr    %cl,%eax
  801df6:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  801dfa:	d3 e2                	shl    %cl,%edx
  801dfc:	09 d0                	or     %edx,%eax
  801dfe:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801e01:	d3 e7                	shl    %cl,%edi
  801e03:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  801e07:	d3 ea                	shr    %cl,%edx
  801e09:	f7 75 f4             	divl   -0xc(%ebp)
  801e0c:	89 55 cc             	mov    %edx,-0x34(%ebp)
  801e0f:	f7 e6                	mul    %esi
  801e11:	39 55 cc             	cmp    %edx,-0x34(%ebp)
  801e14:	72 53                	jb     801e69 <__umoddi3+0x169>
  801e16:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  801e19:	74 4a                	je     801e65 <__umoddi3+0x165>
  801e1b:	90                   	nop    
  801e1c:	8d 74 26 00          	lea    0x0(%esi),%esi
  801e20:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801e23:	29 c7                	sub    %eax,%edi
  801e25:	19 d1                	sbb    %edx,%ecx
  801e27:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801e2a:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  801e2e:	89 fa                	mov    %edi,%edx
  801e30:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801e33:	d3 ea                	shr    %cl,%edx
  801e35:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  801e39:	d3 e0                	shl    %cl,%eax
  801e3b:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  801e3f:	09 c2                	or     %eax,%edx
  801e41:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801e44:	89 55 d0             	mov    %edx,-0x30(%ebp)
  801e47:	d3 e8                	shr    %cl,%eax
  801e49:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801e4c:	e9 0f ff ff ff       	jmp    801d60 <__umoddi3+0x60>
  801e51:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801e54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e57:	2b 45 ec             	sub    -0x14(%ebp),%eax
  801e5a:	1b 55 e8             	sbb    -0x18(%ebp),%edx
  801e5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801e60:	e9 2f ff ff ff       	jmp    801d94 <__umoddi3+0x94>
  801e65:	39 f8                	cmp    %edi,%eax
  801e67:	76 b7                	jbe    801e20 <__umoddi3+0x120>
  801e69:	29 f0                	sub    %esi,%eax
  801e6b:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801e6e:	eb b0                	jmp    801e20 <__umoddi3+0x120>
