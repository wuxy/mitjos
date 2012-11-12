
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
  800077:	c7 04 24 60 23 80 00 	movl   $0x802360,(%esp)
  80007e:	e8 a2 01 00 00       	call   800225 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800083:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  800092:	e8 9d ff ff ff       	call   800034 <sum>
  800097:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  80009c:	74 1a                	je     8000b8 <umain+0x50>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  80009e:	c7 44 24 08 9e 98 0f 	movl   $0xf989e,0x8(%esp)
  8000a5:	00 
  8000a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000aa:	c7 04 24 c0 23 80 00 	movl   $0x8023c0,(%esp)
  8000b1:	e8 6f 01 00 00       	call   800225 <cprintf>
  8000b6:	eb 0c                	jmp    8000c4 <umain+0x5c>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000b8:	c7 04 24 6f 23 80 00 	movl   $0x80236f,(%esp)
  8000bf:	e8 61 01 00 00       	call   800225 <cprintf>
	if ((x = sum(bss, sizeof bss)) != 0)
  8000c4:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  8000cb:	00 
  8000cc:	c7 04 24 c0 77 80 00 	movl   $0x8077c0,(%esp)
  8000d3:	e8 5c ff ff ff       	call   800034 <sum>
  8000d8:	85 c0                	test   %eax,%eax
  8000da:	74 12                	je     8000ee <umain+0x86>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000e0:	c7 04 24 fc 23 80 00 	movl   $0x8023fc,(%esp)
  8000e7:	e8 39 01 00 00       	call   800225 <cprintf>
  8000ec:	eb 0c                	jmp    8000fa <umain+0x92>
	else
		cprintf("init: bss seems okay\n");
  8000ee:	c7 04 24 86 23 80 00 	movl   $0x802386,(%esp)
  8000f5:	e8 2b 01 00 00       	call   800225 <cprintf>

	cprintf("init: args:");
  8000fa:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  800101:	e8 1f 01 00 00       	call   800225 <cprintf>
	for (i = 0; i < argc; i++)
  800106:	85 f6                	test   %esi,%esi
  800108:	7e 1f                	jle    800129 <umain+0xc1>
  80010a:	bb 00 00 00 00       	mov    $0x0,%ebx
		cprintf(" '%s'", argv[i]);
  80010f:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  800112:	89 44 24 04          	mov    %eax,0x4(%esp)
  800116:	c7 04 24 a8 23 80 00 	movl   $0x8023a8,(%esp)
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
  800129:	c7 04 24 a9 28 80 00 	movl   $0x8028a9,(%esp)
  800130:	e8 f0 00 00 00       	call   800225 <cprintf>

	cprintf("init: exiting\n");
  800135:	c7 04 24 ae 23 80 00 	movl   $0x8023ae,(%esp)
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
  80015e:	c7 05 30 8f 80 00 00 	movl   $0x0,0x808f30
  800165:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  800168:	e8 f0 0e 00 00       	call   80105d <sys_getenvid>
  80016d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800172:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800175:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80017a:	a3 30 8f 80 00       	mov    %eax,0x808f30
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80017f:	85 f6                	test   %esi,%esi
  800181:	7e 07                	jle    80018a <libmain+0x3e>
		binaryname = argv[0];
  800183:	8b 03                	mov    (%ebx),%eax
  800185:	a3 70 77 80 00       	mov    %eax,0x807770

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
  8001ae:	e8 2d 15 00 00       	call   8016e0 <close_all>
	sys_env_destroy(0);
  8001b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ba:	e8 d2 0e 00 00       	call   801091 <sys_env_destroy>
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
  80030b:	e8 a0 1d 00 00       	call   8020b0 <__udivdi3>
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
  80035d:	e8 7e 1e 00 00       	call   8021e0 <__umoddi3>
  800362:	89 74 24 04          	mov    %esi,0x4(%esp)
  800366:	0f be 80 42 24 80 00 	movsbl 0x802442(%eax),%eax
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
  80043e:	ff 24 85 80 25 80 00 	jmp    *0x802580(,%eax,4)
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
  8004ed:	8b 14 85 e0 26 80 00 	mov    0x8026e0(,%eax,4),%edx
  8004f4:	85 d2                	test   %edx,%edx
  8004f6:	75 23                	jne    80051b <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004fc:	c7 44 24 08 53 24 80 	movl   $0x802453,0x8(%esp)
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
  80051f:	c7 44 24 08 22 28 80 	movl   $0x802822,0x8(%esp)
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
  800558:	c7 45 dc 5c 24 80 00 	movl   $0x80245c,-0x24(%ebp)
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

00800d2b <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	83 ec 0c             	sub    $0xc,%esp
  800d31:	89 1c 24             	mov    %ebx,(%esp)
  800d34:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d38:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d41:	bf 00 00 00 00       	mov    $0x0,%edi
  800d46:	89 fa                	mov    %edi,%edx
  800d48:	89 f9                	mov    %edi,%ecx
  800d4a:	89 fb                	mov    %edi,%ebx
  800d4c:	89 fe                	mov    %edi,%esi
  800d4e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d50:	8b 1c 24             	mov    (%esp),%ebx
  800d53:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d57:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d5b:	89 ec                	mov    %ebp,%esp
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	83 ec 28             	sub    $0x28,%esp
  800d65:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d68:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d6b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d6e:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d71:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d76:	bf 00 00 00 00       	mov    $0x0,%edi
  800d7b:	89 f9                	mov    %edi,%ecx
  800d7d:	89 fb                	mov    %edi,%ebx
  800d7f:	89 fe                	mov    %edi,%esi
  800d81:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800d83:	85 c0                	test   %eax,%eax
  800d85:	7e 28                	jle    800daf <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d87:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d8b:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d92:	00 
  800d93:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800d9a:	00 
  800d9b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da2:	00 
  800da3:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800daa:	e8 ed 10 00 00       	call   801e9c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800daf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800db2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800db5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800db8:	89 ec                	mov    %ebp,%esp
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    

00800dbc <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	83 ec 0c             	sub    $0xc,%esp
  800dc2:	89 1c 24             	mov    %ebx,(%esp)
  800dc5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dc9:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800dcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd6:	8b 7d 14             	mov    0x14(%ebp),%edi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd9:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dde:	be 00 00 00 00       	mov    $0x0,%esi
  800de3:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800de5:	8b 1c 24             	mov    (%esp),%ebx
  800de8:	8b 74 24 04          	mov    0x4(%esp),%esi
  800dec:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800df0:	89 ec                	mov    %ebp,%esp
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    

00800df4 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	83 ec 28             	sub    $0x28,%esp
  800dfa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dfd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e00:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e03:	8b 55 08             	mov    0x8(%ebp),%edx
  800e06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e09:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e0e:	bf 00 00 00 00       	mov    $0x0,%edi
  800e13:	89 fb                	mov    %edi,%ebx
  800e15:	89 fe                	mov    %edi,%esi
  800e17:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800e19:	85 c0                	test   %eax,%eax
  800e1b:	7e 28                	jle    800e45 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e21:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e28:	00 
  800e29:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800e30:	00 
  800e31:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e38:	00 
  800e39:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800e40:	e8 57 10 00 00       	call   801e9c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e45:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e48:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e4b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e4e:	89 ec                	mov    %ebp,%esp
  800e50:	5d                   	pop    %ebp
  800e51:	c3                   	ret    

00800e52 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e52:	55                   	push   %ebp
  800e53:	89 e5                	mov    %esp,%ebp
  800e55:	83 ec 28             	sub    $0x28,%esp
  800e58:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e5b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e5e:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e61:	8b 55 08             	mov    0x8(%ebp),%edx
  800e64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e67:	b8 09 00 00 00       	mov    $0x9,%eax
  800e6c:	bf 00 00 00 00       	mov    $0x0,%edi
  800e71:	89 fb                	mov    %edi,%ebx
  800e73:	89 fe                	mov    %edi,%esi
  800e75:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800e77:	85 c0                	test   %eax,%eax
  800e79:	7e 28                	jle    800ea3 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e7f:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e86:	00 
  800e87:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800e8e:	00 
  800e8f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e96:	00 
  800e97:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800e9e:	e8 f9 0f 00 00       	call   801e9c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ea3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ea6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eac:	89 ec                	mov    %ebp,%esp
  800eae:	5d                   	pop    %ebp
  800eaf:	c3                   	ret    

00800eb0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	83 ec 28             	sub    $0x28,%esp
  800eb6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eb9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ebc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ebf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec5:	b8 08 00 00 00       	mov    $0x8,%eax
  800eca:	bf 00 00 00 00       	mov    $0x0,%edi
  800ecf:	89 fb                	mov    %edi,%ebx
  800ed1:	89 fe                	mov    %edi,%esi
  800ed3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800ed5:	85 c0                	test   %eax,%eax
  800ed7:	7e 28                	jle    800f01 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800edd:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ee4:	00 
  800ee5:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800eec:	00 
  800eed:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef4:	00 
  800ef5:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800efc:	e8 9b 0f 00 00       	call   801e9c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f01:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f04:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f07:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f0a:	89 ec                	mov    %ebp,%esp
  800f0c:	5d                   	pop    %ebp
  800f0d:	c3                   	ret    

00800f0e <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800f0e:	55                   	push   %ebp
  800f0f:	89 e5                	mov    %esp,%ebp
  800f11:	83 ec 28             	sub    $0x28,%esp
  800f14:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f17:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f1a:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f23:	b8 06 00 00 00       	mov    $0x6,%eax
  800f28:	bf 00 00 00 00       	mov    $0x0,%edi
  800f2d:	89 fb                	mov    %edi,%ebx
  800f2f:	89 fe                	mov    %edi,%esi
  800f31:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f33:	85 c0                	test   %eax,%eax
  800f35:	7e 28                	jle    800f5f <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f37:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f3b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f42:	00 
  800f43:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800f4a:	00 
  800f4b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f52:	00 
  800f53:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800f5a:	e8 3d 0f 00 00       	call   801e9c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f5f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f62:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f65:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f68:	89 ec                	mov    %ebp,%esp
  800f6a:	5d                   	pop    %ebp
  800f6b:	c3                   	ret    

00800f6c <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	83 ec 28             	sub    $0x28,%esp
  800f72:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f75:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f78:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f81:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f84:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f87:	8b 75 18             	mov    0x18(%ebp),%esi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8a:	b8 05 00 00 00       	mov    $0x5,%eax
  800f8f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f91:	85 c0                	test   %eax,%eax
  800f93:	7e 28                	jle    800fbd <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f95:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f99:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800fa0:	00 
  800fa1:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800fa8:	00 
  800fa9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fb0:	00 
  800fb1:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800fb8:	e8 df 0e 00 00       	call   801e9c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fbd:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fc0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fc3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fc6:	89 ec                	mov    %ebp,%esp
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	83 ec 28             	sub    $0x28,%esp
  800fd0:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fd3:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fd6:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800fd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fdf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe2:	b8 04 00 00 00       	mov    $0x4,%eax
  800fe7:	bf 00 00 00 00       	mov    $0x0,%edi
  800fec:	89 fe                	mov    %edi,%esi
  800fee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800ff0:	85 c0                	test   %eax,%eax
  800ff2:	7e 28                	jle    80101c <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff8:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800fff:	00 
  801000:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  801007:	00 
  801008:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80100f:	00 
  801010:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  801017:	e8 80 0e 00 00       	call   801e9c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80101c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80101f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801022:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801025:	89 ec                	mov    %ebp,%esp
  801027:	5d                   	pop    %ebp
  801028:	c3                   	ret    

00801029 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
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
  80103a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80103f:	bf 00 00 00 00       	mov    $0x0,%edi
  801044:	89 fa                	mov    %edi,%edx
  801046:	89 f9                	mov    %edi,%ecx
  801048:	89 fb                	mov    %edi,%ebx
  80104a:	89 fe                	mov    %edi,%esi
  80104c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80104e:	8b 1c 24             	mov    (%esp),%ebx
  801051:	8b 74 24 04          	mov    0x4(%esp),%esi
  801055:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801059:	89 ec                	mov    %ebp,%esp
  80105b:	5d                   	pop    %ebp
  80105c:	c3                   	ret    

0080105d <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	83 ec 0c             	sub    $0xc,%esp
  801063:	89 1c 24             	mov    %ebx,(%esp)
  801066:	89 74 24 04          	mov    %esi,0x4(%esp)
  80106a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80106e:	b8 02 00 00 00       	mov    $0x2,%eax
  801073:	bf 00 00 00 00       	mov    $0x0,%edi
  801078:	89 fa                	mov    %edi,%edx
  80107a:	89 f9                	mov    %edi,%ecx
  80107c:	89 fb                	mov    %edi,%ebx
  80107e:	89 fe                	mov    %edi,%esi
  801080:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801082:	8b 1c 24             	mov    (%esp),%ebx
  801085:	8b 74 24 04          	mov    0x4(%esp),%esi
  801089:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80108d:	89 ec                	mov    %ebp,%esp
  80108f:	5d                   	pop    %ebp
  801090:	c3                   	ret    

00801091 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	83 ec 28             	sub    $0x28,%esp
  801097:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80109a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80109d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8010a0:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010a3:	b8 03 00 00 00       	mov    $0x3,%eax
  8010a8:	bf 00 00 00 00       	mov    $0x0,%edi
  8010ad:	89 f9                	mov    %edi,%ecx
  8010af:	89 fb                	mov    %edi,%ebx
  8010b1:	89 fe                	mov    %edi,%esi
  8010b3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8010b5:	85 c0                	test   %eax,%eax
  8010b7:	7e 28                	jle    8010e1 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010bd:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8010c4:	00 
  8010c5:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  8010cc:	00 
  8010cd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010d4:	00 
  8010d5:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  8010dc:	e8 bb 0d 00 00       	call   801e9c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010e1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010e4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010e7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010ea:	89 ec                	mov    %ebp,%esp
  8010ec:	5d                   	pop    %ebp
  8010ed:	c3                   	ret    
	...

008010f0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8010fb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8010fe:	5d                   	pop    %ebp
  8010ff:	c3                   	ret    

00801100 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801106:	8b 45 08             	mov    0x8(%ebp),%eax
  801109:	89 04 24             	mov    %eax,(%esp)
  80110c:	e8 df ff ff ff       	call   8010f0 <fd2num>
  801111:	c1 e0 0c             	shl    $0xc,%eax
  801114:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801119:	c9                   	leave  
  80111a:	c3                   	ret    

0080111b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	53                   	push   %ebx
  80111f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801122:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  801127:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801129:	89 d0                	mov    %edx,%eax
  80112b:	c1 e8 16             	shr    $0x16,%eax
  80112e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801135:	a8 01                	test   $0x1,%al
  801137:	74 10                	je     801149 <fd_alloc+0x2e>
  801139:	89 d0                	mov    %edx,%eax
  80113b:	c1 e8 0c             	shr    $0xc,%eax
  80113e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801145:	a8 01                	test   $0x1,%al
  801147:	75 09                	jne    801152 <fd_alloc+0x37>
			*fd_store = fd;
  801149:	89 0b                	mov    %ecx,(%ebx)
  80114b:	b8 00 00 00 00       	mov    $0x0,%eax
  801150:	eb 19                	jmp    80116b <fd_alloc+0x50>
			return 0;
  801152:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801158:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  80115e:	75 c7                	jne    801127 <fd_alloc+0xc>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801160:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801166:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  80116b:	5b                   	pop    %ebx
  80116c:	5d                   	pop    %ebp
  80116d:	c3                   	ret    

0080116e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801171:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  801175:	77 38                	ja     8011af <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801177:	8b 45 08             	mov    0x8(%ebp),%eax
  80117a:	c1 e0 0c             	shl    $0xc,%eax
  80117d:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  801183:	89 d0                	mov    %edx,%eax
  801185:	c1 e8 16             	shr    $0x16,%eax
  801188:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80118f:	a8 01                	test   $0x1,%al
  801191:	74 1c                	je     8011af <fd_lookup+0x41>
  801193:	89 d0                	mov    %edx,%eax
  801195:	c1 e8 0c             	shr    $0xc,%eax
  801198:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80119f:	a8 01                	test   $0x1,%al
  8011a1:	74 0c                	je     8011af <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011a6:	89 10                	mov    %edx,(%eax)
  8011a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ad:	eb 05                	jmp    8011b4 <fd_lookup+0x46>
	return 0;
  8011af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011b4:	5d                   	pop    %ebp
  8011b5:	c3                   	ret    

008011b6 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8011b6:	55                   	push   %ebp
  8011b7:	89 e5                	mov    %esp,%ebp
  8011b9:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011bc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c6:	89 04 24             	mov    %eax,(%esp)
  8011c9:	e8 a0 ff ff ff       	call   80116e <fd_lookup>
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	78 0e                	js     8011e0 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8011d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011d8:	89 50 04             	mov    %edx,0x4(%eax)
  8011db:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8011e0:	c9                   	leave  
  8011e1:	c3                   	ret    

008011e2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	53                   	push   %ebx
  8011e6:	83 ec 14             	sub    $0x14,%esp
  8011e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8011ef:	ba 74 77 80 00       	mov    $0x807774,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8011f4:	b8 00 00 00 00       	mov    $0x0,%eax
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8011f9:	39 0d 74 77 80 00    	cmp    %ecx,0x807774
  8011ff:	75 11                	jne    801212 <dev_lookup+0x30>
  801201:	eb 04                	jmp    801207 <dev_lookup+0x25>
  801203:	39 0a                	cmp    %ecx,(%edx)
  801205:	75 0b                	jne    801212 <dev_lookup+0x30>
			*dev = devtab[i];
  801207:	89 13                	mov    %edx,(%ebx)
  801209:	b8 00 00 00 00       	mov    $0x0,%eax
  80120e:	66 90                	xchg   %ax,%ax
  801210:	eb 35                	jmp    801247 <dev_lookup+0x65>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801212:	83 c0 01             	add    $0x1,%eax
  801215:	8b 14 85 ec 27 80 00 	mov    0x8027ec(,%eax,4),%edx
  80121c:	85 d2                	test   %edx,%edx
  80121e:	75 e3                	jne    801203 <dev_lookup+0x21>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  801220:	a1 30 8f 80 00       	mov    0x808f30,%eax
  801225:	8b 40 4c             	mov    0x4c(%eax),%eax
  801228:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80122c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801230:	c7 04 24 6c 27 80 00 	movl   $0x80276c,(%esp)
  801237:	e8 e9 ef ff ff       	call   800225 <cprintf>
	*dev = 0;
  80123c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801242:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801247:	83 c4 14             	add    $0x14,%esp
  80124a:	5b                   	pop    %ebx
  80124b:	5d                   	pop    %ebp
  80124c:	c3                   	ret    

0080124d <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80124d:	55                   	push   %ebp
  80124e:	89 e5                	mov    %esp,%ebp
  801250:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801253:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801256:	89 44 24 04          	mov    %eax,0x4(%esp)
  80125a:	8b 45 08             	mov    0x8(%ebp),%eax
  80125d:	89 04 24             	mov    %eax,(%esp)
  801260:	e8 09 ff ff ff       	call   80116e <fd_lookup>
  801265:	89 c2                	mov    %eax,%edx
  801267:	85 c0                	test   %eax,%eax
  801269:	78 5a                	js     8012c5 <fstat+0x78>
  80126b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80126e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801272:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801275:	8b 00                	mov    (%eax),%eax
  801277:	89 04 24             	mov    %eax,(%esp)
  80127a:	e8 63 ff ff ff       	call   8011e2 <dev_lookup>
  80127f:	89 c2                	mov    %eax,%edx
  801281:	85 c0                	test   %eax,%eax
  801283:	78 40                	js     8012c5 <fstat+0x78>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801285:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  80128a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80128d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801291:	74 32                	je     8012c5 <fstat+0x78>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801293:	8b 45 0c             	mov    0xc(%ebp),%eax
  801296:	c6 00 00             	movb   $0x0,(%eax)
	stat->st_size = 0;
  801299:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  8012a0:	00 00 00 
	stat->st_isdir = 0;
  8012a3:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
  8012aa:	00 00 00 
	stat->st_dev = dev;
  8012ad:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8012b0:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
	return (*dev->dev_stat)(fd, stat);
  8012b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8012bd:	89 04 24             	mov    %eax,(%esp)
  8012c0:	ff 52 14             	call   *0x14(%edx)
  8012c3:	89 c2                	mov    %eax,%edx
}
  8012c5:	89 d0                	mov    %edx,%eax
  8012c7:	c9                   	leave  
  8012c8:	c3                   	ret    

008012c9 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	53                   	push   %ebx
  8012cd:	83 ec 24             	sub    $0x24,%esp
  8012d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012da:	89 1c 24             	mov    %ebx,(%esp)
  8012dd:	e8 8c fe ff ff       	call   80116e <fd_lookup>
  8012e2:	85 c0                	test   %eax,%eax
  8012e4:	78 61                	js     801347 <ftruncate+0x7e>
  8012e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e9:	8b 10                	mov    (%eax),%edx
  8012eb:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8012ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f2:	89 14 24             	mov    %edx,(%esp)
  8012f5:	e8 e8 fe ff ff       	call   8011e2 <dev_lookup>
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	78 49                	js     801347 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012fe:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801301:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801305:	75 23                	jne    80132a <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801307:	a1 30 8f 80 00       	mov    0x808f30,%eax
  80130c:	8b 40 4c             	mov    0x4c(%eax),%eax
  80130f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801313:	89 44 24 04          	mov    %eax,0x4(%esp)
  801317:	c7 04 24 8c 27 80 00 	movl   $0x80278c,(%esp)
  80131e:	e8 02 ef ff ff       	call   800225 <cprintf>
  801323:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801328:	eb 1d                	jmp    801347 <ftruncate+0x7e>
			env->env_id, fdnum); 
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80132a:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80132d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801332:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  801336:	74 0f                	je     801347 <ftruncate+0x7e>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801338:	8b 42 18             	mov    0x18(%edx),%eax
  80133b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80133e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801342:	89 0c 24             	mov    %ecx,(%esp)
  801345:	ff d0                	call   *%eax
}
  801347:	83 c4 24             	add    $0x24,%esp
  80134a:	5b                   	pop    %ebx
  80134b:	5d                   	pop    %ebp
  80134c:	c3                   	ret    

0080134d <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80134d:	55                   	push   %ebp
  80134e:	89 e5                	mov    %esp,%ebp
  801350:	53                   	push   %ebx
  801351:	83 ec 24             	sub    $0x24,%esp
  801354:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801357:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135e:	89 1c 24             	mov    %ebx,(%esp)
  801361:	e8 08 fe ff ff       	call   80116e <fd_lookup>
  801366:	85 c0                	test   %eax,%eax
  801368:	78 68                	js     8013d2 <write+0x85>
  80136a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136d:	8b 10                	mov    (%eax),%edx
  80136f:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801372:	89 44 24 04          	mov    %eax,0x4(%esp)
  801376:	89 14 24             	mov    %edx,(%esp)
  801379:	e8 64 fe ff ff       	call   8011e2 <dev_lookup>
  80137e:	85 c0                	test   %eax,%eax
  801380:	78 50                	js     8013d2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801382:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801385:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801389:	75 23                	jne    8013ae <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  80138b:	a1 30 8f 80 00       	mov    0x808f30,%eax
  801390:	8b 40 4c             	mov    0x4c(%eax),%eax
  801393:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801397:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139b:	c7 04 24 b0 27 80 00 	movl   $0x8027b0,(%esp)
  8013a2:	e8 7e ee ff ff       	call   800225 <cprintf>
  8013a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013ac:	eb 24                	jmp    8013d2 <write+0x85>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013ae:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8013b1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013b6:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  8013ba:	74 16                	je     8013d2 <write+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013bc:	8b 42 0c             	mov    0xc(%edx),%eax
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

008013d8 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013d8:	55                   	push   %ebp
  8013d9:	89 e5                	mov    %esp,%ebp
  8013db:	53                   	push   %ebx
  8013dc:	83 ec 24             	sub    $0x24,%esp
  8013df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e9:	89 1c 24             	mov    %ebx,(%esp)
  8013ec:	e8 7d fd ff ff       	call   80116e <fd_lookup>
  8013f1:	85 c0                	test   %eax,%eax
  8013f3:	78 6d                	js     801462 <read+0x8a>
  8013f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f8:	8b 10                	mov    (%eax),%edx
  8013fa:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8013fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801401:	89 14 24             	mov    %edx,(%esp)
  801404:	e8 d9 fd ff ff       	call   8011e2 <dev_lookup>
  801409:	85 c0                	test   %eax,%eax
  80140b:	78 55                	js     801462 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80140d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801410:	8b 41 08             	mov    0x8(%ecx),%eax
  801413:	83 e0 03             	and    $0x3,%eax
  801416:	83 f8 01             	cmp    $0x1,%eax
  801419:	75 23                	jne    80143e <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  80141b:	a1 30 8f 80 00       	mov    0x808f30,%eax
  801420:	8b 40 4c             	mov    0x4c(%eax),%eax
  801423:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801427:	89 44 24 04          	mov    %eax,0x4(%esp)
  80142b:	c7 04 24 cd 27 80 00 	movl   $0x8027cd,(%esp)
  801432:	e8 ee ed ff ff       	call   800225 <cprintf>
  801437:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80143c:	eb 24                	jmp    801462 <read+0x8a>
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80143e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801441:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801446:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  80144a:	74 16                	je     801462 <read+0x8a>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80144c:	8b 42 08             	mov    0x8(%edx),%eax
  80144f:	8b 55 10             	mov    0x10(%ebp),%edx
  801452:	89 54 24 08          	mov    %edx,0x8(%esp)
  801456:	8b 55 0c             	mov    0xc(%ebp),%edx
  801459:	89 54 24 04          	mov    %edx,0x4(%esp)
  80145d:	89 0c 24             	mov    %ecx,(%esp)
  801460:	ff d0                	call   *%eax
}
  801462:	83 c4 24             	add    $0x24,%esp
  801465:	5b                   	pop    %ebx
  801466:	5d                   	pop    %ebp
  801467:	c3                   	ret    

00801468 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	57                   	push   %edi
  80146c:	56                   	push   %esi
  80146d:	53                   	push   %ebx
  80146e:	83 ec 0c             	sub    $0xc,%esp
  801471:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801474:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801477:	b8 00 00 00 00       	mov    $0x0,%eax
  80147c:	85 f6                	test   %esi,%esi
  80147e:	74 36                	je     8014b6 <readn+0x4e>
  801480:	bb 00 00 00 00       	mov    $0x0,%ebx
  801485:	ba 00 00 00 00       	mov    $0x0,%edx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80148a:	89 f0                	mov    %esi,%eax
  80148c:	29 d0                	sub    %edx,%eax
  80148e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801492:	8d 04 17             	lea    (%edi,%edx,1),%eax
  801495:	89 44 24 04          	mov    %eax,0x4(%esp)
  801499:	8b 45 08             	mov    0x8(%ebp),%eax
  80149c:	89 04 24             	mov    %eax,(%esp)
  80149f:	e8 34 ff ff ff       	call   8013d8 <read>
		if (m < 0)
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	78 0e                	js     8014b6 <readn+0x4e>
			return m;
		if (m == 0)
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	74 08                	je     8014b4 <readn+0x4c>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ac:	01 c3                	add    %eax,%ebx
  8014ae:	89 da                	mov    %ebx,%edx
  8014b0:	39 f3                	cmp    %esi,%ebx
  8014b2:	72 d6                	jb     80148a <readn+0x22>
  8014b4:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014b6:	83 c4 0c             	add    $0xc,%esp
  8014b9:	5b                   	pop    %ebx
  8014ba:	5e                   	pop    %esi
  8014bb:	5f                   	pop    %edi
  8014bc:	5d                   	pop    %ebp
  8014bd:	c3                   	ret    

008014be <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014be:	55                   	push   %ebp
  8014bf:	89 e5                	mov    %esp,%ebp
  8014c1:	83 ec 28             	sub    $0x28,%esp
  8014c4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8014c7:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8014ca:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014cd:	89 34 24             	mov    %esi,(%esp)
  8014d0:	e8 1b fc ff ff       	call   8010f0 <fd2num>
  8014d5:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8014d8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014dc:	89 04 24             	mov    %eax,(%esp)
  8014df:	e8 8a fc ff ff       	call   80116e <fd_lookup>
  8014e4:	89 c3                	mov    %eax,%ebx
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	78 05                	js     8014ef <fd_close+0x31>
  8014ea:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014ed:	74 0d                	je     8014fc <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8014ef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8014f3:	75 44                	jne    801539 <fd_close+0x7b>
  8014f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014fa:	eb 3d                	jmp    801539 <fd_close+0x7b>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801503:	8b 06                	mov    (%esi),%eax
  801505:	89 04 24             	mov    %eax,(%esp)
  801508:	e8 d5 fc ff ff       	call   8011e2 <dev_lookup>
  80150d:	89 c3                	mov    %eax,%ebx
  80150f:	85 c0                	test   %eax,%eax
  801511:	78 16                	js     801529 <fd_close+0x6b>
		if (dev->dev_close)
  801513:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801516:	8b 40 10             	mov    0x10(%eax),%eax
  801519:	bb 00 00 00 00       	mov    $0x0,%ebx
  80151e:	85 c0                	test   %eax,%eax
  801520:	74 07                	je     801529 <fd_close+0x6b>
			r = (*dev->dev_close)(fd);
  801522:	89 34 24             	mov    %esi,(%esp)
  801525:	ff d0                	call   *%eax
  801527:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801529:	89 74 24 04          	mov    %esi,0x4(%esp)
  80152d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801534:	e8 d5 f9 ff ff       	call   800f0e <sys_page_unmap>
	return r;
}
  801539:	89 d8                	mov    %ebx,%eax
  80153b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80153e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801541:	89 ec                	mov    %ebp,%esp
  801543:	5d                   	pop    %ebp
  801544:	c3                   	ret    

00801545 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801545:	55                   	push   %ebp
  801546:	89 e5                	mov    %esp,%ebp
  801548:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80154b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80154e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801552:	8b 45 08             	mov    0x8(%ebp),%eax
  801555:	89 04 24             	mov    %eax,(%esp)
  801558:	e8 11 fc ff ff       	call   80116e <fd_lookup>
  80155d:	85 c0                	test   %eax,%eax
  80155f:	78 13                	js     801574 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801561:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801568:	00 
  801569:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80156c:	89 04 24             	mov    %eax,(%esp)
  80156f:	e8 4a ff ff ff       	call   8014be <fd_close>
}
  801574:	c9                   	leave  
  801575:	c3                   	ret    

00801576 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801576:	55                   	push   %ebp
  801577:	89 e5                	mov    %esp,%ebp
  801579:	83 ec 18             	sub    $0x18,%esp
  80157c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80157f:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801582:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801589:	00 
  80158a:	8b 45 08             	mov    0x8(%ebp),%eax
  80158d:	89 04 24             	mov    %eax,(%esp)
  801590:	e8 5a 03 00 00       	call   8018ef <open>
  801595:	89 c6                	mov    %eax,%esi
  801597:	85 c0                	test   %eax,%eax
  801599:	78 1b                	js     8015b6 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  80159b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80159e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a2:	89 34 24             	mov    %esi,(%esp)
  8015a5:	e8 a3 fc ff ff       	call   80124d <fstat>
  8015aa:	89 c3                	mov    %eax,%ebx
	close(fd);
  8015ac:	89 34 24             	mov    %esi,(%esp)
  8015af:	e8 91 ff ff ff       	call   801545 <close>
  8015b4:	89 de                	mov    %ebx,%esi
	return r;
}
  8015b6:	89 f0                	mov    %esi,%eax
  8015b8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8015bb:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8015be:	89 ec                	mov    %ebp,%esp
  8015c0:	5d                   	pop    %ebp
  8015c1:	c3                   	ret    

008015c2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015c2:	55                   	push   %ebp
  8015c3:	89 e5                	mov    %esp,%ebp
  8015c5:	83 ec 38             	sub    $0x38,%esp
  8015c8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8015cb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8015ce:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8015d1:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015db:	8b 45 08             	mov    0x8(%ebp),%eax
  8015de:	89 04 24             	mov    %eax,(%esp)
  8015e1:	e8 88 fb ff ff       	call   80116e <fd_lookup>
  8015e6:	89 c3                	mov    %eax,%ebx
  8015e8:	85 c0                	test   %eax,%eax
  8015ea:	0f 88 e1 00 00 00    	js     8016d1 <dup+0x10f>
		return r;
	close(newfdnum);
  8015f0:	89 3c 24             	mov    %edi,(%esp)
  8015f3:	e8 4d ff ff ff       	call   801545 <close>

	newfd = INDEX2FD(newfdnum);
  8015f8:	89 f8                	mov    %edi,%eax
  8015fa:	c1 e0 0c             	shl    $0xc,%eax
  8015fd:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  801603:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801606:	89 04 24             	mov    %eax,(%esp)
  801609:	e8 f2 fa ff ff       	call   801100 <fd2data>
  80160e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801610:	89 34 24             	mov    %esi,(%esp)
  801613:	e8 e8 fa ff ff       	call   801100 <fd2data>
  801618:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  80161b:	89 d8                	mov    %ebx,%eax
  80161d:	c1 e8 16             	shr    $0x16,%eax
  801620:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801627:	a8 01                	test   $0x1,%al
  801629:	74 45                	je     801670 <dup+0xae>
  80162b:	89 da                	mov    %ebx,%edx
  80162d:	c1 ea 0c             	shr    $0xc,%edx
  801630:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801637:	a8 01                	test   $0x1,%al
  801639:	74 35                	je     801670 <dup+0xae>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  80163b:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801642:	25 07 0e 00 00       	and    $0xe07,%eax
  801647:	89 44 24 10          	mov    %eax,0x10(%esp)
  80164b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80164e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801652:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801659:	00 
  80165a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80165e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801665:	e8 02 f9 ff ff       	call   800f6c <sys_page_map>
  80166a:	89 c3                	mov    %eax,%ebx
  80166c:	85 c0                	test   %eax,%eax
  80166e:	78 3e                	js     8016ae <dup+0xec>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  801670:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801673:	89 d0                	mov    %edx,%eax
  801675:	c1 e8 0c             	shr    $0xc,%eax
  801678:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80167f:	25 07 0e 00 00       	and    $0xe07,%eax
  801684:	89 44 24 10          	mov    %eax,0x10(%esp)
  801688:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80168c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801693:	00 
  801694:	89 54 24 04          	mov    %edx,0x4(%esp)
  801698:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80169f:	e8 c8 f8 ff ff       	call   800f6c <sys_page_map>
  8016a4:	89 c3                	mov    %eax,%ebx
  8016a6:	85 c0                	test   %eax,%eax
  8016a8:	78 04                	js     8016ae <dup+0xec>
		goto err;
  8016aa:	89 fb                	mov    %edi,%ebx
  8016ac:	eb 23                	jmp    8016d1 <dup+0x10f>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016ae:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016b9:	e8 50 f8 ff ff       	call   800f0e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016be:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016cc:	e8 3d f8 ff ff       	call   800f0e <sys_page_unmap>
	return r;
}
  8016d1:	89 d8                	mov    %ebx,%eax
  8016d3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8016d6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8016d9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8016dc:	89 ec                	mov    %ebp,%esp
  8016de:	5d                   	pop    %ebp
  8016df:	c3                   	ret    

008016e0 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	53                   	push   %ebx
  8016e4:	83 ec 04             	sub    $0x4,%esp
  8016e7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8016ec:	89 1c 24             	mov    %ebx,(%esp)
  8016ef:	e8 51 fe ff ff       	call   801545 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016f4:	83 c3 01             	add    $0x1,%ebx
  8016f7:	83 fb 20             	cmp    $0x20,%ebx
  8016fa:	75 f0                	jne    8016ec <close_all+0xc>
		close(i);
}
  8016fc:	83 c4 04             	add    $0x4,%esp
  8016ff:	5b                   	pop    %ebx
  801700:	5d                   	pop    %ebp
  801701:	c3                   	ret    
	...

00801704 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	53                   	push   %ebx
  801708:	83 ec 14             	sub    $0x14,%esp
  80170b:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80170d:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  801713:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80171a:	00 
  80171b:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801722:	00 
  801723:	89 44 24 04          	mov    %eax,0x4(%esp)
  801727:	89 14 24             	mov    %edx,(%esp)
  80172a:	e8 e1 07 00 00       	call   801f10 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80172f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801736:	00 
  801737:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80173b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801742:	e8 7d 08 00 00       	call   801fc4 <ipc_recv>
}
  801747:	83 c4 14             	add    $0x14,%esp
  80174a:	5b                   	pop    %ebx
  80174b:	5d                   	pop    %ebp
  80174c:	c3                   	ret    

0080174d <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  80174d:	55                   	push   %ebp
  80174e:	89 e5                	mov    %esp,%ebp
  801750:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801753:	ba 00 00 00 00       	mov    $0x0,%edx
  801758:	b8 08 00 00 00       	mov    $0x8,%eax
  80175d:	e8 a2 ff ff ff       	call   801704 <fsipc>
}
  801762:	c9                   	leave  
  801763:	c3                   	ret    

00801764 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801764:	55                   	push   %ebp
  801765:	89 e5                	mov    %esp,%ebp
  801767:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80176a:	8b 45 08             	mov    0x8(%ebp),%eax
  80176d:	8b 40 0c             	mov    0xc(%eax),%eax
  801770:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.set_size.req_size = newsize;
  801775:	8b 45 0c             	mov    0xc(%ebp),%eax
  801778:	a3 04 30 80 00       	mov    %eax,0x803004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80177d:	ba 00 00 00 00       	mov    $0x0,%edx
  801782:	b8 02 00 00 00       	mov    $0x2,%eax
  801787:	e8 78 ff ff ff       	call   801704 <fsipc>
}
  80178c:	c9                   	leave  
  80178d:	c3                   	ret    

0080178e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801794:	8b 45 08             	mov    0x8(%ebp),%eax
  801797:	8b 40 0c             	mov    0xc(%eax),%eax
  80179a:	a3 00 30 80 00       	mov    %eax,0x803000
	return fsipc(FSREQ_FLUSH, NULL);
  80179f:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a4:	b8 06 00 00 00       	mov    $0x6,%eax
  8017a9:	e8 56 ff ff ff       	call   801704 <fsipc>
}
  8017ae:	c9                   	leave  
  8017af:	c3                   	ret    

008017b0 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	53                   	push   %ebx
  8017b4:	83 ec 14             	sub    $0x14,%esp
  8017b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c0:	a3 00 30 80 00       	mov    %eax,0x803000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ca:	b8 05 00 00 00       	mov    $0x5,%eax
  8017cf:	e8 30 ff ff ff       	call   801704 <fsipc>
  8017d4:	85 c0                	test   %eax,%eax
  8017d6:	78 2b                	js     801803 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017d8:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  8017df:	00 
  8017e0:	89 1c 24             	mov    %ebx,(%esp)
  8017e3:	e8 a9 f0 ff ff       	call   800891 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017e8:	a1 80 30 80 00       	mov    0x803080,%eax
  8017ed:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017f3:	a1 84 30 80 00       	mov    0x803084,%eax
  8017f8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8017fe:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801803:	83 c4 14             	add    $0x14,%esp
  801806:	5b                   	pop    %ebx
  801807:	5d                   	pop    %ebp
  801808:	c3                   	ret    

00801809 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801809:	55                   	push   %ebp
  80180a:	89 e5                	mov    %esp,%ebp
  80180c:	83 ec 18             	sub    $0x18,%esp
  80180f:	8b 55 10             	mov    0x10(%ebp),%edx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	ssize_t writesize;
	size_t bufsize;
	fsipcbuf.write.req_fileid=fd->fd_file.id;
  801812:	8b 45 08             	mov    0x8(%ebp),%eax
  801815:	8b 40 0c             	mov    0xc(%eax),%eax
  801818:	a3 00 30 80 00       	mov    %eax,0x803000
	bufsize=sizeof(fsipcbuf.write.req_buf);
	if(n<bufsize)
  80181d:	89 d0                	mov    %edx,%eax
  80181f:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  801825:	76 05                	jbe    80182c <devfile_write+0x23>
  801827:	b8 f8 0f 00 00       	mov    $0xff8,%eax
		bufsize=n;	
	fsipcbuf.write.req_n=n;
  80182c:	89 15 04 30 80 00    	mov    %edx,0x803004
	memmove((void*)fsipcbuf.write.req_buf,buf,bufsize);
  801832:	89 44 24 08          	mov    %eax,0x8(%esp)
  801836:	8b 45 0c             	mov    0xc(%ebp),%eax
  801839:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183d:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  801844:	e8 4f f2 ff ff       	call   800a98 <memmove>
	writesize=(ssize_t)fsipc(FSREQ_WRITE,NULL);
  801849:	ba 00 00 00 00       	mov    $0x0,%edx
  80184e:	b8 04 00 00 00       	mov    $0x4,%eax
  801853:	e8 ac fe ff ff       	call   801704 <fsipc>
	return writesize;
	//panic("devfile_write not implemented");
}
  801858:	c9                   	leave  
  801859:	c3                   	ret    

0080185a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80185a:	55                   	push   %ebp
  80185b:	89 e5                	mov    %esp,%ebp
  80185d:	53                   	push   %ebx
  80185e:	83 ec 14             	sub    $0x14,%esp
	// system server.
	// LAB 5: Your code here
	ssize_t readsize;
	if(debug)
		cprintf("devfile_read:fileid=%x readsize=%x\n",fd->fd_file.id,n);
	fsipcbuf.read.req_fileid=fd->fd_file.id;
  801861:	8b 45 08             	mov    0x8(%ebp),%eax
  801864:	8b 40 0c             	mov    0xc(%eax),%eax
  801867:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.read.req_n=n;
  80186c:	8b 45 10             	mov    0x10(%ebp),%eax
  80186f:	a3 04 30 80 00       	mov    %eax,0x803004
	readsize=(ssize_t)fsipc(FSREQ_READ,&fsipcbuf);
  801874:	ba 00 30 80 00       	mov    $0x803000,%edx
  801879:	b8 03 00 00 00       	mov    $0x3,%eax
  80187e:	e8 81 fe ff ff       	call   801704 <fsipc>
  801883:	89 c3                	mov    %eax,%ebx
	//cprintf("readsize=%d\n",readsize);
	if(debug)
		cprintf("devfile_read:buf1=%s\nbuf2=%s\n",(char*)&fsipcbuf,fsipcbuf.readRet.ret_buf);
	if(readsize>0)
  801885:	85 c0                	test   %eax,%eax
  801887:	7e 17                	jle    8018a0 <devfile_read+0x46>
		memmove(buf,(void*)&fsipcbuf,(size_t)readsize);
  801889:	89 44 24 08          	mov    %eax,0x8(%esp)
  80188d:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801894:	00 
  801895:	8b 45 0c             	mov    0xc(%ebp),%eax
  801898:	89 04 24             	mov    %eax,(%esp)
  80189b:	e8 f8 f1 ff ff       	call   800a98 <memmove>
	//cprintf("readsize=%d",readsize);
	return readsize;
	//panic("devfile_read not implemented");
}
  8018a0:	89 d8                	mov    %ebx,%eax
  8018a2:	83 c4 14             	add    $0x14,%esp
  8018a5:	5b                   	pop    %ebx
  8018a6:	5d                   	pop    %ebp
  8018a7:	c3                   	ret    

008018a8 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  8018a8:	55                   	push   %ebp
  8018a9:	89 e5                	mov    %esp,%ebp
  8018ab:	53                   	push   %ebx
  8018ac:	83 ec 14             	sub    $0x14,%esp
  8018af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8018b2:	89 1c 24             	mov    %ebx,(%esp)
  8018b5:	e8 86 ef ff ff       	call   800840 <strlen>
  8018ba:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  8018bf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018c4:	7f 21                	jg     8018e7 <remove+0x3f>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  8018c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018ca:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  8018d1:	e8 bb ef ff ff       	call   800891 <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  8018d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018db:	b8 07 00 00 00       	mov    $0x7,%eax
  8018e0:	e8 1f fe ff ff       	call   801704 <fsipc>
  8018e5:	89 c2                	mov    %eax,%edx
}
  8018e7:	89 d0                	mov    %edx,%eax
  8018e9:	83 c4 14             	add    $0x14,%esp
  8018ec:	5b                   	pop    %ebx
  8018ed:	5d                   	pop    %ebp
  8018ee:	c3                   	ret    

008018ef <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018ef:	55                   	push   %ebp
  8018f0:	89 e5                	mov    %esp,%ebp
  8018f2:	56                   	push   %esi
  8018f3:	53                   	push   %ebx
  8018f4:	83 ec 30             	sub    $0x30,%esp

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;
	void *page;
	if((r=fd_alloc(&fd))<0){
  8018f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018fa:	89 04 24             	mov    %eax,(%esp)
  8018fd:	e8 19 f8 ff ff       	call   80111b <fd_alloc>
  801902:	89 c3                	mov    %eax,%ebx
  801904:	85 c0                	test   %eax,%eax
  801906:	79 18                	jns    801920 <open+0x31>
		fd_close(fd,0);
  801908:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80190f:	00 
  801910:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801913:	89 04 24             	mov    %eax,(%esp)
  801916:	e8 a3 fb ff ff       	call   8014be <fd_close>
  80191b:	e9 9f 00 00 00       	jmp    8019bf <open+0xd0>
		return r;
	}
	//cprintf("open:fd=%x\n",fd);
	strcpy(fsipcbuf.open.req_path,path);
  801920:	8b 45 08             	mov    0x8(%ebp),%eax
  801923:	89 44 24 04          	mov    %eax,0x4(%esp)
  801927:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  80192e:	e8 5e ef ff ff       	call   800891 <strcpy>
	fsipcbuf.open.req_omode=mode;
  801933:	8b 45 0c             	mov    0xc(%ebp),%eax
  801936:	a3 00 34 80 00       	mov    %eax,0x803400
	page=(void*)fd2data(fd);
  80193b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80193e:	89 04 24             	mov    %eax,(%esp)
  801941:	e8 ba f7 ff ff       	call   801100 <fd2data>
  801946:	89 c6                	mov    %eax,%esi
	if((r=fsipc(FSREQ_OPEN,(void*)fd))<0)
  801948:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80194b:	b8 01 00 00 00       	mov    $0x1,%eax
  801950:	e8 af fd ff ff       	call   801704 <fsipc>
  801955:	89 c3                	mov    %eax,%ebx
  801957:	85 c0                	test   %eax,%eax
  801959:	79 15                	jns    801970 <open+0x81>
	{
		fd_close(fd,1);
  80195b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801962:	00 
  801963:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801966:	89 04 24             	mov    %eax,(%esp)
  801969:	e8 50 fb ff ff       	call   8014be <fd_close>
  80196e:	eb 4f                	jmp    8019bf <open+0xd0>
		return r;	
	}
	//cprintf("open:page=%x\n",page);
	if((r=sys_page_map(0,(void*)fd,0,(void*)page,PTE_P | PTE_W | PTE_U))<0)
  801970:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801977:	00 
  801978:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80197c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801983:	00 
  801984:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801987:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801992:	e8 d5 f5 ff ff       	call   800f6c <sys_page_map>
  801997:	89 c3                	mov    %eax,%ebx
  801999:	85 c0                	test   %eax,%eax
  80199b:	79 15                	jns    8019b2 <open+0xc3>
	{
		fd_close(fd,1);
  80199d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8019a4:	00 
  8019a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a8:	89 04 24             	mov    %eax,(%esp)
  8019ab:	e8 0e fb ff ff       	call   8014be <fd_close>
  8019b0:	eb 0d                	jmp    8019bf <open+0xd0>
		return r;
	}
	//cprintf("open:fileid=%x\n",fd->fd_file.id);
	return fd2num(fd);
  8019b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b5:	89 04 24             	mov    %eax,(%esp)
  8019b8:	e8 33 f7 ff ff       	call   8010f0 <fd2num>
  8019bd:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  8019bf:	89 d8                	mov    %ebx,%eax
  8019c1:	83 c4 30             	add    $0x30,%esp
  8019c4:	5b                   	pop    %ebx
  8019c5:	5e                   	pop    %esi
  8019c6:	5d                   	pop    %ebp
  8019c7:	c3                   	ret    
	...

008019d0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  8019d6:	c7 44 24 04 f8 27 80 	movl   $0x8027f8,0x4(%esp)
  8019dd:	00 
  8019de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e1:	89 04 24             	mov    %eax,(%esp)
  8019e4:	e8 a8 ee ff ff       	call   800891 <strcpy>
	return 0;
}
  8019e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ee:	c9                   	leave  
  8019ef:	c3                   	ret    

008019f0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8019f0:	55                   	push   %ebp
  8019f1:	89 e5                	mov    %esp,%ebp
  8019f3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_close(fd->fd_sock.sockid);
  8019f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f9:	8b 40 0c             	mov    0xc(%eax),%eax
  8019fc:	89 04 24             	mov    %eax,(%esp)
  8019ff:	e8 9e 02 00 00       	call   801ca2 <nsipc_close>
}
  801a04:	c9                   	leave  
  801a05:	c3                   	ret    

00801a06 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a06:	55                   	push   %ebp
  801a07:	89 e5                	mov    %esp,%ebp
  801a09:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a0c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801a13:	00 
  801a14:	8b 45 10             	mov    0x10(%ebp),%eax
  801a17:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a22:	8b 45 08             	mov    0x8(%ebp),%eax
  801a25:	8b 40 0c             	mov    0xc(%eax),%eax
  801a28:	89 04 24             	mov    %eax,(%esp)
  801a2b:	e8 ae 02 00 00       	call   801cde <nsipc_send>
}
  801a30:	c9                   	leave  
  801a31:	c3                   	ret    

00801a32 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a32:	55                   	push   %ebp
  801a33:	89 e5                	mov    %esp,%ebp
  801a35:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a38:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801a3f:	00 
  801a40:	8b 45 10             	mov    0x10(%ebp),%eax
  801a43:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a47:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a51:	8b 40 0c             	mov    0xc(%eax),%eax
  801a54:	89 04 24             	mov    %eax,(%esp)
  801a57:	e8 f5 02 00 00       	call   801d51 <nsipc_recv>
}
  801a5c:	c9                   	leave  
  801a5d:	c3                   	ret    

00801a5e <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801a5e:	55                   	push   %ebp
  801a5f:	89 e5                	mov    %esp,%ebp
  801a61:	56                   	push   %esi
  801a62:	53                   	push   %ebx
  801a63:	83 ec 20             	sub    $0x20,%esp
  801a66:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a6b:	89 04 24             	mov    %eax,(%esp)
  801a6e:	e8 a8 f6 ff ff       	call   80111b <fd_alloc>
  801a73:	89 c3                	mov    %eax,%ebx
  801a75:	85 c0                	test   %eax,%eax
  801a77:	78 21                	js     801a9a <alloc_sockfd+0x3c>
  801a79:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801a80:	00 
  801a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a84:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a88:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a8f:	e8 36 f5 ff ff       	call   800fca <sys_page_alloc>
  801a94:	89 c3                	mov    %eax,%ebx
  801a96:	85 c0                	test   %eax,%eax
  801a98:	79 0a                	jns    801aa4 <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U)) < 0) {
		nsipc_close(sockid);
  801a9a:	89 34 24             	mov    %esi,(%esp)
  801a9d:	e8 00 02 00 00       	call   801ca2 <nsipc_close>
  801aa2:	eb 28                	jmp    801acc <alloc_sockfd+0x6e>
		return r;
	}

	sfd->fd_dev_id = devsock.dev_id;
  801aa4:	8b 15 90 77 80 00    	mov    0x807790,%edx
  801aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aad:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801abc:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac2:	89 04 24             	mov    %eax,(%esp)
  801ac5:	e8 26 f6 ff ff       	call   8010f0 <fd2num>
  801aca:	89 c3                	mov    %eax,%ebx
}
  801acc:	89 d8                	mov    %ebx,%eax
  801ace:	83 c4 20             	add    $0x20,%esp
  801ad1:	5b                   	pop    %ebx
  801ad2:	5e                   	pop    %esi
  801ad3:	5d                   	pop    %ebp
  801ad4:	c3                   	ret    

00801ad5 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801ad5:	55                   	push   %ebp
  801ad6:	89 e5                	mov    %esp,%ebp
  801ad8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801adb:	8b 45 10             	mov    0x10(%ebp),%eax
  801ade:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ae2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  801aec:	89 04 24             	mov    %eax,(%esp)
  801aef:	e8 62 01 00 00       	call   801c56 <nsipc_socket>
  801af4:	85 c0                	test   %eax,%eax
  801af6:	78 05                	js     801afd <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801af8:	e8 61 ff ff ff       	call   801a5e <alloc_sockfd>
}
  801afd:	c9                   	leave  
  801afe:	66 90                	xchg   %ax,%ax
  801b00:	c3                   	ret    

00801b01 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801b01:	55                   	push   %ebp
  801b02:	89 e5                	mov    %esp,%ebp
  801b04:	83 ec 18             	sub    $0x18,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b07:	8d 55 fc             	lea    -0x4(%ebp),%edx
  801b0a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b0e:	89 04 24             	mov    %eax,(%esp)
  801b11:	e8 58 f6 ff ff       	call   80116e <fd_lookup>
  801b16:	89 c2                	mov    %eax,%edx
  801b18:	85 c0                	test   %eax,%eax
  801b1a:	78 15                	js     801b31 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b1c:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  801b1f:	8b 01                	mov    (%ecx),%eax
  801b21:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  801b26:	3b 05 90 77 80 00    	cmp    0x807790,%eax
  801b2c:	75 03                	jne    801b31 <fd2sockid+0x30>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b2e:	8b 51 0c             	mov    0xc(%ecx),%edx
}
  801b31:	89 d0                	mov    %edx,%eax
  801b33:	c9                   	leave  
  801b34:	c3                   	ret    

00801b35 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3e:	e8 be ff ff ff       	call   801b01 <fd2sockid>
  801b43:	85 c0                	test   %eax,%eax
  801b45:	78 0f                	js     801b56 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b47:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b4a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b4e:	89 04 24             	mov    %eax,(%esp)
  801b51:	e8 2a 01 00 00       	call   801c80 <nsipc_listen>
}
  801b56:	c9                   	leave  
  801b57:	c3                   	ret    

00801b58 <connect>:
	return nsipc_close(fd->fd_sock.sockid);
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b61:	e8 9b ff ff ff       	call   801b01 <fd2sockid>
  801b66:	85 c0                	test   %eax,%eax
  801b68:	78 16                	js     801b80 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801b6a:	8b 55 10             	mov    0x10(%ebp),%edx
  801b6d:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b71:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b74:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b78:	89 04 24             	mov    %eax,(%esp)
  801b7b:	e8 51 02 00 00       	call   801dd1 <nsipc_connect>
}
  801b80:	c9                   	leave  
  801b81:	c3                   	ret    

00801b82 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801b82:	55                   	push   %ebp
  801b83:	89 e5                	mov    %esp,%ebp
  801b85:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b88:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8b:	e8 71 ff ff ff       	call   801b01 <fd2sockid>
  801b90:	85 c0                	test   %eax,%eax
  801b92:	78 0f                	js     801ba3 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b94:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b97:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b9b:	89 04 24             	mov    %eax,(%esp)
  801b9e:	e8 19 01 00 00       	call   801cbc <nsipc_shutdown>
}
  801ba3:	c9                   	leave  
  801ba4:	c3                   	ret    

00801ba5 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ba5:	55                   	push   %ebp
  801ba6:	89 e5                	mov    %esp,%ebp
  801ba8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bab:	8b 45 08             	mov    0x8(%ebp),%eax
  801bae:	e8 4e ff ff ff       	call   801b01 <fd2sockid>
  801bb3:	85 c0                	test   %eax,%eax
  801bb5:	78 16                	js     801bcd <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801bb7:	8b 55 10             	mov    0x10(%ebp),%edx
  801bba:	89 54 24 08          	mov    %edx,0x8(%esp)
  801bbe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bc1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801bc5:	89 04 24             	mov    %eax,(%esp)
  801bc8:	e8 43 02 00 00       	call   801e10 <nsipc_bind>
}
  801bcd:	c9                   	leave  
  801bce:	c3                   	ret    

00801bcf <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bcf:	55                   	push   %ebp
  801bd0:	89 e5                	mov    %esp,%ebp
  801bd2:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bd5:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd8:	e8 24 ff ff ff       	call   801b01 <fd2sockid>
  801bdd:	85 c0                	test   %eax,%eax
  801bdf:	78 1f                	js     801c00 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801be1:	8b 55 10             	mov    0x10(%ebp),%edx
  801be4:	89 54 24 08          	mov    %edx,0x8(%esp)
  801be8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801beb:	89 54 24 04          	mov    %edx,0x4(%esp)
  801bef:	89 04 24             	mov    %eax,(%esp)
  801bf2:	e8 58 02 00 00       	call   801e4f <nsipc_accept>
  801bf7:	85 c0                	test   %eax,%eax
  801bf9:	78 05                	js     801c00 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801bfb:	e8 5e fe ff ff       	call   801a5e <alloc_sockfd>
}
  801c00:	c9                   	leave  
  801c01:	c3                   	ret    
	...

00801c10 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c10:	55                   	push   %ebp
  801c11:	89 e5                	mov    %esp,%ebp
  801c13:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c16:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  801c1c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c23:	00 
  801c24:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801c2b:	00 
  801c2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c30:	89 14 24             	mov    %edx,(%esp)
  801c33:	e8 d8 02 00 00       	call   801f10 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c38:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c3f:	00 
  801c40:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c47:	00 
  801c48:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c4f:	e8 70 03 00 00       	call   801fc4 <ipc_recv>
}
  801c54:	c9                   	leave  
  801c55:	c3                   	ret    

00801c56 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5f:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.socket.req_type = type;
  801c64:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c67:	a3 04 50 80 00       	mov    %eax,0x805004
	nsipcbuf.socket.req_protocol = protocol;
  801c6c:	8b 45 10             	mov    0x10(%ebp),%eax
  801c6f:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SOCKET);
  801c74:	b8 09 00 00 00       	mov    $0x9,%eax
  801c79:	e8 92 ff ff ff       	call   801c10 <nsipc>
}
  801c7e:	c9                   	leave  
  801c7f:	c3                   	ret    

00801c80 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  801c80:	55                   	push   %ebp
  801c81:	89 e5                	mov    %esp,%ebp
  801c83:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c86:	8b 45 08             	mov    0x8(%ebp),%eax
  801c89:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.listen.req_backlog = backlog;
  801c8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c91:	a3 04 50 80 00       	mov    %eax,0x805004
	return nsipc(NSREQ_LISTEN);
  801c96:	b8 06 00 00 00       	mov    $0x6,%eax
  801c9b:	e8 70 ff ff ff       	call   801c10 <nsipc>
}
  801ca0:	c9                   	leave  
  801ca1:	c3                   	ret    

00801ca2 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  801ca2:	55                   	push   %ebp
  801ca3:	89 e5                	mov    %esp,%ebp
  801ca5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ca8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cab:	a3 00 50 80 00       	mov    %eax,0x805000
	return nsipc(NSREQ_CLOSE);
  801cb0:	b8 04 00 00 00       	mov    $0x4,%eax
  801cb5:	e8 56 ff ff ff       	call   801c10 <nsipc>
}
  801cba:	c9                   	leave  
  801cbb:	c3                   	ret    

00801cbc <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  801cbc:	55                   	push   %ebp
  801cbd:	89 e5                	mov    %esp,%ebp
  801cbf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801cc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc5:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.shutdown.req_how = how;
  801cca:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ccd:	a3 04 50 80 00       	mov    %eax,0x805004
	return nsipc(NSREQ_SHUTDOWN);
  801cd2:	b8 03 00 00 00       	mov    $0x3,%eax
  801cd7:	e8 34 ff ff ff       	call   801c10 <nsipc>
}
  801cdc:	c9                   	leave  
  801cdd:	c3                   	ret    

00801cde <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801cde:	55                   	push   %ebp
  801cdf:	89 e5                	mov    %esp,%ebp
  801ce1:	53                   	push   %ebx
  801ce2:	83 ec 14             	sub    $0x14,%esp
  801ce5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801ce8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ceb:	a3 00 50 80 00       	mov    %eax,0x805000
	assert(size < 1600);
  801cf0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801cf6:	7e 24                	jle    801d1c <nsipc_send+0x3e>
  801cf8:	c7 44 24 0c 04 28 80 	movl   $0x802804,0xc(%esp)
  801cff:	00 
  801d00:	c7 44 24 08 10 28 80 	movl   $0x802810,0x8(%esp)
  801d07:	00 
  801d08:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  801d0f:	00 
  801d10:	c7 04 24 25 28 80 00 	movl   $0x802825,(%esp)
  801d17:	e8 80 01 00 00       	call   801e9c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d1c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d20:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d23:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d27:	c7 04 24 0c 50 80 00 	movl   $0x80500c,(%esp)
  801d2e:	e8 65 ed ff ff       	call   800a98 <memmove>
	nsipcbuf.send.req_size = size;
  801d33:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	nsipcbuf.send.req_flags = flags;
  801d39:	8b 45 14             	mov    0x14(%ebp),%eax
  801d3c:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SEND);
  801d41:	b8 08 00 00 00       	mov    $0x8,%eax
  801d46:	e8 c5 fe ff ff       	call   801c10 <nsipc>
}
  801d4b:	83 c4 14             	add    $0x14,%esp
  801d4e:	5b                   	pop    %ebx
  801d4f:	5d                   	pop    %ebp
  801d50:	c3                   	ret    

00801d51 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d51:	55                   	push   %ebp
  801d52:	89 e5                	mov    %esp,%ebp
  801d54:	56                   	push   %esi
  801d55:	53                   	push   %ebx
  801d56:	83 ec 10             	sub    $0x10,%esp
  801d59:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5f:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.recv.req_len = len;
  801d64:	89 35 04 50 80 00    	mov    %esi,0x805004
	nsipcbuf.recv.req_flags = flags;
  801d6a:	8b 45 14             	mov    0x14(%ebp),%eax
  801d6d:	a3 08 50 80 00       	mov    %eax,0x805008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d72:	b8 07 00 00 00       	mov    $0x7,%eax
  801d77:	e8 94 fe ff ff       	call   801c10 <nsipc>
  801d7c:	89 c3                	mov    %eax,%ebx
  801d7e:	85 c0                	test   %eax,%eax
  801d80:	78 46                	js     801dc8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801d82:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d87:	7f 04                	jg     801d8d <nsipc_recv+0x3c>
  801d89:	39 c6                	cmp    %eax,%esi
  801d8b:	7d 24                	jge    801db1 <nsipc_recv+0x60>
  801d8d:	c7 44 24 0c 31 28 80 	movl   $0x802831,0xc(%esp)
  801d94:	00 
  801d95:	c7 44 24 08 10 28 80 	movl   $0x802810,0x8(%esp)
  801d9c:	00 
  801d9d:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  801da4:	00 
  801da5:	c7 04 24 25 28 80 00 	movl   $0x802825,(%esp)
  801dac:	e8 eb 00 00 00       	call   801e9c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801db1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801db5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801dbc:	00 
  801dbd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc0:	89 04 24             	mov    %eax,(%esp)
  801dc3:	e8 d0 ec ff ff       	call   800a98 <memmove>
	}

	return r;
}
  801dc8:	89 d8                	mov    %ebx,%eax
  801dca:	83 c4 10             	add    $0x10,%esp
  801dcd:	5b                   	pop    %ebx
  801dce:	5e                   	pop    %esi
  801dcf:	5d                   	pop    %ebp
  801dd0:	c3                   	ret    

00801dd1 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801dd1:	55                   	push   %ebp
  801dd2:	89 e5                	mov    %esp,%ebp
  801dd4:	53                   	push   %ebx
  801dd5:	83 ec 14             	sub    $0x14,%esp
  801dd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801ddb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dde:	a3 00 50 80 00       	mov    %eax,0x805000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801de3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801de7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dea:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dee:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  801df5:	e8 9e ec ff ff       	call   800a98 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801dfa:	89 1d 14 50 80 00    	mov    %ebx,0x805014
	return nsipc(NSREQ_CONNECT);
  801e00:	b8 05 00 00 00       	mov    $0x5,%eax
  801e05:	e8 06 fe ff ff       	call   801c10 <nsipc>
}
  801e0a:	83 c4 14             	add    $0x14,%esp
  801e0d:	5b                   	pop    %ebx
  801e0e:	5d                   	pop    %ebp
  801e0f:	c3                   	ret    

00801e10 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	53                   	push   %ebx
  801e14:	83 ec 14             	sub    $0x14,%esp
  801e17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1d:	a3 00 50 80 00       	mov    %eax,0x805000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801e22:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e26:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e29:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e2d:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  801e34:	e8 5f ec ff ff       	call   800a98 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801e39:	89 1d 14 50 80 00    	mov    %ebx,0x805014
	return nsipc(NSREQ_BIND);
  801e3f:	b8 02 00 00 00       	mov    $0x2,%eax
  801e44:	e8 c7 fd ff ff       	call   801c10 <nsipc>
}
  801e49:	83 c4 14             	add    $0x14,%esp
  801e4c:	5b                   	pop    %ebx
  801e4d:	5d                   	pop    %ebp
  801e4e:	c3                   	ret    

00801e4f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e4f:	55                   	push   %ebp
  801e50:	89 e5                	mov    %esp,%ebp
  801e52:	53                   	push   %ebx
  801e53:	83 ec 14             	sub    $0x14,%esp
	int r;
	
	nsipcbuf.accept.req_s = s;
  801e56:	8b 45 08             	mov    0x8(%ebp),%eax
  801e59:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e5e:	b8 01 00 00 00       	mov    $0x1,%eax
  801e63:	e8 a8 fd ff ff       	call   801c10 <nsipc>
  801e68:	89 c3                	mov    %eax,%ebx
  801e6a:	85 c0                	test   %eax,%eax
  801e6c:	78 26                	js     801e94 <nsipc_accept+0x45>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801e6e:	a1 10 50 80 00       	mov    0x805010,%eax
  801e73:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e77:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801e7e:	00 
  801e7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e82:	89 04 24             	mov    %eax,(%esp)
  801e85:	e8 0e ec ff ff       	call   800a98 <memmove>
		*addrlen = ret->ret_addrlen;
  801e8a:	a1 10 50 80 00       	mov    0x805010,%eax
  801e8f:	8b 55 10             	mov    0x10(%ebp),%edx
  801e92:	89 02                	mov    %eax,(%edx)
	}
	return r;
}
  801e94:	89 d8                	mov    %ebx,%eax
  801e96:	83 c4 14             	add    $0x14,%esp
  801e99:	5b                   	pop    %ebx
  801e9a:	5d                   	pop    %ebp
  801e9b:	c3                   	ret    

00801e9c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  801e9c:	55                   	push   %ebp
  801e9d:	89 e5                	mov    %esp,%ebp
  801e9f:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  801ea2:	8d 45 14             	lea    0x14(%ebp),%eax
  801ea5:	89 45 fc             	mov    %eax,-0x4(%ebp)

	// Print the panic message
	if (argv0)
  801ea8:	a1 34 8f 80 00       	mov    0x808f34,%eax
  801ead:	85 c0                	test   %eax,%eax
  801eaf:	74 10                	je     801ec1 <_panic+0x25>
		cprintf("%s: ", argv0);
  801eb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb5:	c7 04 24 46 28 80 00 	movl   $0x802846,(%esp)
  801ebc:	e8 64 e3 ff ff       	call   800225 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  801ec1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ec8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ecb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ecf:	a1 70 77 80 00       	mov    0x807770,%eax
  801ed4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed8:	c7 04 24 4b 28 80 00 	movl   $0x80284b,(%esp)
  801edf:	e8 41 e3 ff ff       	call   800225 <cprintf>
	vcprintf(fmt, ap);
  801ee4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801ee7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eeb:	8b 45 10             	mov    0x10(%ebp),%eax
  801eee:	89 04 24             	mov    %eax,(%esp)
  801ef1:	e8 ce e2 ff ff       	call   8001c4 <vcprintf>
	cprintf("\n");
  801ef6:	c7 04 24 a9 28 80 00 	movl   $0x8028a9,(%esp)
  801efd:	e8 23 e3 ff ff       	call   800225 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f02:	cc                   	int3   
  801f03:	eb fd                	jmp    801f02 <_panic+0x66>
	...

00801f10 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f10:	55                   	push   %ebp
  801f11:	89 e5                	mov    %esp,%ebp
  801f13:	57                   	push   %edi
  801f14:	56                   	push   %esi
  801f15:	53                   	push   %ebx
  801f16:	83 ec 1c             	sub    $0x1c,%esp
  801f19:	8b 75 08             	mov    0x8(%ebp),%esi
  801f1c:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  801f1f:	e8 39 f1 ff ff       	call   80105d <sys_getenvid>
  801f24:	25 ff 03 00 00       	and    $0x3ff,%eax
  801f29:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f2c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f31:	a3 30 8f 80 00       	mov    %eax,0x808f30
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  801f36:	e8 22 f1 ff ff       	call   80105d <sys_getenvid>
  801f3b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801f40:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f43:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f48:	a3 30 8f 80 00       	mov    %eax,0x808f30
		if(env->env_id==to_env){
  801f4d:	8b 40 4c             	mov    0x4c(%eax),%eax
  801f50:	39 f0                	cmp    %esi,%eax
  801f52:	75 0e                	jne    801f62 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  801f54:	c7 04 24 67 28 80 00 	movl   $0x802867,(%esp)
  801f5b:	e8 c5 e2 ff ff       	call   800225 <cprintf>
  801f60:	eb 5a                	jmp    801fbc <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  801f62:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f66:	8b 45 10             	mov    0x10(%ebp),%eax
  801f69:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f70:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f74:	89 34 24             	mov    %esi,(%esp)
  801f77:	e8 40 ee ff ff       	call   800dbc <sys_ipc_try_send>
  801f7c:	89 c3                	mov    %eax,%ebx
  801f7e:	85 c0                	test   %eax,%eax
  801f80:	79 25                	jns    801fa7 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  801f82:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f85:	74 2b                	je     801fb2 <ipc_send+0xa2>
				panic("send error:%e",r);
  801f87:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f8b:	c7 44 24 08 83 28 80 	movl   $0x802883,0x8(%esp)
  801f92:	00 
  801f93:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  801f9a:	00 
  801f9b:	c7 04 24 91 28 80 00 	movl   $0x802891,(%esp)
  801fa2:	e8 f5 fe ff ff       	call   801e9c <_panic>
		}
			sys_yield();
  801fa7:	e8 7d f0 ff ff       	call   801029 <sys_yield>
		
	}while(r!=0);
  801fac:	85 db                	test   %ebx,%ebx
  801fae:	75 86                	jne    801f36 <ipc_send+0x26>
  801fb0:	eb 0a                	jmp    801fbc <ipc_send+0xac>
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
		{	
			if(r!=-E_IPC_NOT_RECV)
				panic("send error:%e",r);
		}
			sys_yield();
  801fb2:	e8 72 f0 ff ff       	call   801029 <sys_yield>
  801fb7:	e9 7a ff ff ff       	jmp    801f36 <ipc_send+0x26>
		
	}while(r!=0);
	return;
	//panic("ipc_send not implemented");
}
  801fbc:	83 c4 1c             	add    $0x1c,%esp
  801fbf:	5b                   	pop    %ebx
  801fc0:	5e                   	pop    %esi
  801fc1:	5f                   	pop    %edi
  801fc2:	5d                   	pop    %ebp
  801fc3:	c3                   	ret    

00801fc4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fc4:	55                   	push   %ebp
  801fc5:	89 e5                	mov    %esp,%ebp
  801fc7:	57                   	push   %edi
  801fc8:	56                   	push   %esi
  801fc9:	53                   	push   %ebx
  801fca:	83 ec 0c             	sub    $0xc,%esp
  801fcd:	8b 75 08             	mov    0x8(%ebp),%esi
  801fd0:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	void *dstva=NULL;
	if(pg)
		dstva=pg;
	env = &envs[ENVX(sys_getenvid())];
  801fd3:	e8 85 f0 ff ff       	call   80105d <sys_getenvid>
  801fd8:	25 ff 03 00 00       	and    $0x3ff,%eax
  801fdd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fe0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fe5:	a3 30 8f 80 00       	mov    %eax,0x808f30
	if(from_env_store&&(env->env_id==*from_env_store))
  801fea:	85 f6                	test   %esi,%esi
  801fec:	74 29                	je     802017 <ipc_recv+0x53>
  801fee:	8b 40 4c             	mov    0x4c(%eax),%eax
  801ff1:	3b 06                	cmp    (%esi),%eax
  801ff3:	75 22                	jne    802017 <ipc_recv+0x53>
	{
		*from_env_store=0;
  801ff5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  801ffb:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("send:the reciver is sender\n");
  802001:	c7 04 24 67 28 80 00 	movl   $0x802867,(%esp)
  802008:	e8 18 e2 ff ff       	call   800225 <cprintf>
  80200d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802012:	e9 8a 00 00 00       	jmp    8020a1 <ipc_recv+0xdd>
		return 0;
	}
	env = &envs[ENVX(sys_getenvid())];
  802017:	e8 41 f0 ff ff       	call   80105d <sys_getenvid>
  80201c:	25 ff 03 00 00       	and    $0x3ff,%eax
  802021:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802024:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802029:	a3 30 8f 80 00       	mov    %eax,0x808f30
	if((r=sys_ipc_recv(dstva))<0)
  80202e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802031:	89 04 24             	mov    %eax,(%esp)
  802034:	e8 26 ed ff ff       	call   800d5f <sys_ipc_recv>
  802039:	89 c3                	mov    %eax,%ebx
  80203b:	85 c0                	test   %eax,%eax
  80203d:	79 1a                	jns    802059 <ipc_recv+0x95>
	{
		*from_env_store=0;
  80203f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  802045:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("reciver failed\n");
  80204b:	c7 04 24 9b 28 80 00 	movl   $0x80289b,(%esp)
  802052:	e8 ce e1 ff ff       	call   800225 <cprintf>
  802057:	eb 48                	jmp    8020a1 <ipc_recv+0xdd>
		return r;
	}
	else{//接收成功
		env = &envs[ENVX(sys_getenvid())];
  802059:	e8 ff ef ff ff       	call   80105d <sys_getenvid>
  80205e:	25 ff 03 00 00       	and    $0x3ff,%eax
  802063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80206b:	a3 30 8f 80 00       	mov    %eax,0x808f30
		if(from_env_store)
  802070:	85 f6                	test   %esi,%esi
  802072:	74 05                	je     802079 <ipc_recv+0xb5>
			*from_env_store=env->env_ipc_from;	
  802074:	8b 40 74             	mov    0x74(%eax),%eax
  802077:	89 06                	mov    %eax,(%esi)
		if(perm_store)
  802079:	85 ff                	test   %edi,%edi
  80207b:	74 0a                	je     802087 <ipc_recv+0xc3>
			*perm_store=env->env_ipc_perm;
  80207d:	a1 30 8f 80 00       	mov    0x808f30,%eax
  802082:	8b 40 78             	mov    0x78(%eax),%eax
  802085:	89 07                	mov    %eax,(%edi)
		env = &envs[ENVX(sys_getenvid())];
  802087:	e8 d1 ef ff ff       	call   80105d <sys_getenvid>
  80208c:	25 ff 03 00 00       	and    $0x3ff,%eax
  802091:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802094:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802099:	a3 30 8f 80 00       	mov    %eax,0x808f30
		return env->env_ipc_value;
  80209e:	8b 58 70             	mov    0x70(%eax),%ebx
	}
	//panic("ipc_recv not implemented");
	return 0;
}
  8020a1:	89 d8                	mov    %ebx,%eax
  8020a3:	83 c4 0c             	add    $0xc,%esp
  8020a6:	5b                   	pop    %ebx
  8020a7:	5e                   	pop    %esi
  8020a8:	5f                   	pop    %edi
  8020a9:	5d                   	pop    %ebp
  8020aa:	c3                   	ret    
  8020ab:	00 00                	add    %al,(%eax)
  8020ad:	00 00                	add    %al,(%eax)
	...

008020b0 <__udivdi3>:
  8020b0:	55                   	push   %ebp
  8020b1:	89 e5                	mov    %esp,%ebp
  8020b3:	57                   	push   %edi
  8020b4:	56                   	push   %esi
  8020b5:	83 ec 18             	sub    $0x18,%esp
  8020b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8020bb:	8b 55 14             	mov    0x14(%ebp),%edx
  8020be:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8020c4:	89 c1                	mov    %eax,%ecx
  8020c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c9:	85 d2                	test   %edx,%edx
  8020cb:	89 d7                	mov    %edx,%edi
  8020cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020d0:	75 1e                	jne    8020f0 <__udivdi3+0x40>
  8020d2:	39 f1                	cmp    %esi,%ecx
  8020d4:	0f 86 8d 00 00 00    	jbe    802167 <__udivdi3+0xb7>
  8020da:	89 f2                	mov    %esi,%edx
  8020dc:	31 f6                	xor    %esi,%esi
  8020de:	f7 f1                	div    %ecx
  8020e0:	89 c1                	mov    %eax,%ecx
  8020e2:	89 c8                	mov    %ecx,%eax
  8020e4:	89 f2                	mov    %esi,%edx
  8020e6:	83 c4 18             	add    $0x18,%esp
  8020e9:	5e                   	pop    %esi
  8020ea:	5f                   	pop    %edi
  8020eb:	5d                   	pop    %ebp
  8020ec:	c3                   	ret    
  8020ed:	8d 76 00             	lea    0x0(%esi),%esi
  8020f0:	39 f2                	cmp    %esi,%edx
  8020f2:	0f 87 a8 00 00 00    	ja     8021a0 <__udivdi3+0xf0>
  8020f8:	0f bd c2             	bsr    %edx,%eax
  8020fb:	83 f0 1f             	xor    $0x1f,%eax
  8020fe:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802101:	0f 84 89 00 00 00    	je     802190 <__udivdi3+0xe0>
  802107:	b8 20 00 00 00       	mov    $0x20,%eax
  80210c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80210f:	2b 45 e8             	sub    -0x18(%ebp),%eax
  802112:	89 c1                	mov    %eax,%ecx
  802114:	d3 ea                	shr    %cl,%edx
  802116:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  80211a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80211d:	89 f8                	mov    %edi,%eax
  80211f:	8b 7d f4             	mov    -0xc(%ebp),%edi
  802122:	d3 e0                	shl    %cl,%eax
  802124:	09 c2                	or     %eax,%edx
  802126:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802129:	d3 e7                	shl    %cl,%edi
  80212b:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80212f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802132:	89 f2                	mov    %esi,%edx
  802134:	d3 e8                	shr    %cl,%eax
  802136:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  80213a:	d3 e2                	shl    %cl,%edx
  80213c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802140:	09 d0                	or     %edx,%eax
  802142:	d3 ee                	shr    %cl,%esi
  802144:	89 f2                	mov    %esi,%edx
  802146:	f7 75 e4             	divl   -0x1c(%ebp)
  802149:	89 d1                	mov    %edx,%ecx
  80214b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80214e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802151:	f7 e7                	mul    %edi
  802153:	39 d1                	cmp    %edx,%ecx
  802155:	89 c6                	mov    %eax,%esi
  802157:	72 70                	jb     8021c9 <__udivdi3+0x119>
  802159:	39 ca                	cmp    %ecx,%edx
  80215b:	74 5f                	je     8021bc <__udivdi3+0x10c>
  80215d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802160:	31 f6                	xor    %esi,%esi
  802162:	e9 7b ff ff ff       	jmp    8020e2 <__udivdi3+0x32>
  802167:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80216a:	85 c0                	test   %eax,%eax
  80216c:	75 0c                	jne    80217a <__udivdi3+0xca>
  80216e:	b8 01 00 00 00       	mov    $0x1,%eax
  802173:	31 d2                	xor    %edx,%edx
  802175:	f7 75 f4             	divl   -0xc(%ebp)
  802178:	89 c1                	mov    %eax,%ecx
  80217a:	89 f0                	mov    %esi,%eax
  80217c:	89 fa                	mov    %edi,%edx
  80217e:	f7 f1                	div    %ecx
  802180:	89 c6                	mov    %eax,%esi
  802182:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802185:	f7 f1                	div    %ecx
  802187:	89 c1                	mov    %eax,%ecx
  802189:	e9 54 ff ff ff       	jmp    8020e2 <__udivdi3+0x32>
  80218e:	66 90                	xchg   %ax,%ax
  802190:	39 d6                	cmp    %edx,%esi
  802192:	77 1c                	ja     8021b0 <__udivdi3+0x100>
  802194:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802197:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  80219a:	73 14                	jae    8021b0 <__udivdi3+0x100>
  80219c:	8d 74 26 00          	lea    0x0(%esi),%esi
  8021a0:	31 c9                	xor    %ecx,%ecx
  8021a2:	31 f6                	xor    %esi,%esi
  8021a4:	e9 39 ff ff ff       	jmp    8020e2 <__udivdi3+0x32>
  8021a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  8021b0:	b9 01 00 00 00       	mov    $0x1,%ecx
  8021b5:	31 f6                	xor    %esi,%esi
  8021b7:	e9 26 ff ff ff       	jmp    8020e2 <__udivdi3+0x32>
  8021bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8021bf:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  8021c3:	d3 e0                	shl    %cl,%eax
  8021c5:	39 c6                	cmp    %eax,%esi
  8021c7:	76 94                	jbe    80215d <__udivdi3+0xad>
  8021c9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8021cc:	31 f6                	xor    %esi,%esi
  8021ce:	83 e9 01             	sub    $0x1,%ecx
  8021d1:	e9 0c ff ff ff       	jmp    8020e2 <__udivdi3+0x32>
	...

008021e0 <__umoddi3>:
  8021e0:	55                   	push   %ebp
  8021e1:	89 e5                	mov    %esp,%ebp
  8021e3:	57                   	push   %edi
  8021e4:	56                   	push   %esi
  8021e5:	83 ec 30             	sub    $0x30,%esp
  8021e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8021eb:	8b 55 14             	mov    0x14(%ebp),%edx
  8021ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8021f1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8021f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8021f7:	89 c1                	mov    %eax,%ecx
  8021f9:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8021fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8021ff:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  802206:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80220d:	89 fa                	mov    %edi,%edx
  80220f:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  802212:	85 c0                	test   %eax,%eax
  802214:	89 75 f0             	mov    %esi,-0x10(%ebp)
  802217:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80221a:	75 14                	jne    802230 <__umoddi3+0x50>
  80221c:	39 f9                	cmp    %edi,%ecx
  80221e:	76 60                	jbe    802280 <__umoddi3+0xa0>
  802220:	89 f0                	mov    %esi,%eax
  802222:	f7 f1                	div    %ecx
  802224:	89 55 d0             	mov    %edx,-0x30(%ebp)
  802227:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80222e:	eb 10                	jmp    802240 <__umoddi3+0x60>
  802230:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802233:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  802236:	76 18                	jbe    802250 <__umoddi3+0x70>
  802238:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80223b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80223e:	66 90                	xchg   %ax,%ax
  802240:	8b 45 d0             	mov    -0x30(%ebp),%eax
  802243:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  802246:	83 c4 30             	add    $0x30,%esp
  802249:	5e                   	pop    %esi
  80224a:	5f                   	pop    %edi
  80224b:	5d                   	pop    %ebp
  80224c:	c3                   	ret    
  80224d:	8d 76 00             	lea    0x0(%esi),%esi
  802250:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
  802254:	83 f0 1f             	xor    $0x1f,%eax
  802257:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80225a:	75 46                	jne    8022a2 <__umoddi3+0xc2>
  80225c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80225f:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  802262:	0f 87 c9 00 00 00    	ja     802331 <__umoddi3+0x151>
  802268:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  80226b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80226e:	0f 83 bd 00 00 00    	jae    802331 <__umoddi3+0x151>
  802274:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802277:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80227a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80227d:	eb c1                	jmp    802240 <__umoddi3+0x60>
  80227f:	90                   	nop    
  802280:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802283:	85 c0                	test   %eax,%eax
  802285:	75 0c                	jne    802293 <__umoddi3+0xb3>
  802287:	b8 01 00 00 00       	mov    $0x1,%eax
  80228c:	31 d2                	xor    %edx,%edx
  80228e:	f7 75 ec             	divl   -0x14(%ebp)
  802291:	89 c1                	mov    %eax,%ecx
  802293:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802296:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802299:	f7 f1                	div    %ecx
  80229b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80229e:	f7 f1                	div    %ecx
  8022a0:	eb 82                	jmp    802224 <__umoddi3+0x44>
  8022a2:	b8 20 00 00 00       	mov    $0x20,%eax
  8022a7:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8022aa:	2b 45 d8             	sub    -0x28(%ebp),%eax
  8022ad:	8b 75 ec             	mov    -0x14(%ebp),%esi
  8022b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8022b3:	89 c1                	mov    %eax,%ecx
  8022b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8022b8:	d3 ea                	shr    %cl,%edx
  8022ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8022bd:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8022c1:	d3 e0                	shl    %cl,%eax
  8022c3:	09 c2                	or     %eax,%edx
  8022c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022c8:	d3 e6                	shl    %cl,%esi
  8022ca:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  8022ce:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8022d1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8022d4:	d3 e8                	shr    %cl,%eax
  8022d6:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8022da:	d3 e2                	shl    %cl,%edx
  8022dc:	09 d0                	or     %edx,%eax
  8022de:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8022e1:	d3 e7                	shl    %cl,%edi
  8022e3:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  8022e7:	d3 ea                	shr    %cl,%edx
  8022e9:	f7 75 f4             	divl   -0xc(%ebp)
  8022ec:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8022ef:	f7 e6                	mul    %esi
  8022f1:	39 55 cc             	cmp    %edx,-0x34(%ebp)
  8022f4:	72 53                	jb     802349 <__umoddi3+0x169>
  8022f6:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  8022f9:	74 4a                	je     802345 <__umoddi3+0x165>
  8022fb:	90                   	nop    
  8022fc:	8d 74 26 00          	lea    0x0(%esi),%esi
  802300:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  802303:	29 c7                	sub    %eax,%edi
  802305:	19 d1                	sbb    %edx,%ecx
  802307:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80230a:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  80230e:	89 fa                	mov    %edi,%edx
  802310:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802313:	d3 ea                	shr    %cl,%edx
  802315:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  802319:	d3 e0                	shl    %cl,%eax
  80231b:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  80231f:	09 c2                	or     %eax,%edx
  802321:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802324:	89 55 d0             	mov    %edx,-0x30(%ebp)
  802327:	d3 e8                	shr    %cl,%eax
  802329:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80232c:	e9 0f ff ff ff       	jmp    802240 <__umoddi3+0x60>
  802331:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802334:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802337:	2b 45 ec             	sub    -0x14(%ebp),%eax
  80233a:	1b 55 e8             	sbb    -0x18(%ebp),%edx
  80233d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802340:	e9 2f ff ff ff       	jmp    802274 <__umoddi3+0x94>
  802345:	39 f8                	cmp    %edi,%eax
  802347:	76 b7                	jbe    802300 <__umoddi3+0x120>
  802349:	29 f0                	sub    %esi,%eax
  80234b:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  80234e:	eb b0                	jmp    802300 <__umoddi3+0x120>
