
obj/user/init:     file format elf32-i386

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
  80005b:	83 c2 01             	add    $0x1,%edx
  80005e:	39 da                	cmp    %ebx,%edx
  800060:	75 f0                	jne    800052 <sum+0x1e>
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
  800077:	c7 04 24 c0 23 80 00 	movl   $0x8023c0,(%esp)
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
  8000aa:	c7 04 24 20 24 80 00 	movl   $0x802420,(%esp)
  8000b1:	e8 6f 01 00 00       	call   800225 <cprintf>
  8000b6:	eb 0c                	jmp    8000c4 <umain+0x5c>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000b8:	c7 04 24 cf 23 80 00 	movl   $0x8023cf,(%esp)
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
  8000e0:	c7 04 24 5c 24 80 00 	movl   $0x80245c,(%esp)
  8000e7:	e8 39 01 00 00       	call   800225 <cprintf>
  8000ec:	eb 0c                	jmp    8000fa <umain+0x92>
	else
		cprintf("init: bss seems okay\n");
  8000ee:	c7 04 24 e6 23 80 00 	movl   $0x8023e6,(%esp)
  8000f5:	e8 2b 01 00 00       	call   800225 <cprintf>

	cprintf("init: args:");
  8000fa:	c7 04 24 fc 23 80 00 	movl   $0x8023fc,(%esp)
  800101:	e8 1f 01 00 00       	call   800225 <cprintf>
	for (i = 0; i < argc; i++)
  800106:	85 f6                	test   %esi,%esi
  800108:	7e 1f                	jle    800129 <umain+0xc1>
  80010a:	bb 00 00 00 00       	mov    $0x0,%ebx
		cprintf(" '%s'", argv[i]);
  80010f:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  800112:	89 44 24 04          	mov    %eax,0x4(%esp)
  800116:	c7 04 24 08 24 80 00 	movl   $0x802408,(%esp)
  80011d:	e8 03 01 00 00       	call   800225 <cprintf>
  800122:	83 c3 01             	add    $0x1,%ebx
  800125:	39 f3                	cmp    %esi,%ebx
  800127:	75 e6                	jne    80010f <umain+0xa7>
	cprintf("\n");
  800129:	c7 04 24 09 29 80 00 	movl   $0x802909,(%esp)
  800130:	e8 f0 00 00 00       	call   800225 <cprintf>

	cprintf("init: exiting\n");
  800135:	c7 04 24 0e 24 80 00 	movl   $0x80240e,(%esp)
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
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
  800152:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  800155:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  800158:	8b 75 08             	mov    0x8(%ebp),%esi
  80015b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  80015e:	c7 05 30 8f 80 00 00 	movl   $0x0,0x808f30
  800165:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  800168:	e8 00 0f 00 00       	call   80106d <sys_getenvid>
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

	// call user main routine调用用户主例程
	umain(argc, argv);
  80018a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80018e:	89 34 24             	mov    %esi,(%esp)
  800191:	e8 d2 fe ff ff       	call   800068 <umain>

	// exit gracefully
	exit();
  800196:	e8 0d 00 00 00       	call   8001a8 <exit>
}
  80019b:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  80019e:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
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
  8001ae:	e8 43 15 00 00       	call   8016f6 <close_all>
	sys_env_destroy(0);
  8001b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ba:	e8 e2 0e 00 00       	call   8010a1 <sys_env_destroy>
}
  8001bf:	c9                   	leave  
  8001c0:	c3                   	ret    
  8001c1:	00 00                	add    %al,(%eax)
	...

008001c4 <vcprintf>:
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001cd:	c7 85 f8 fe ff ff 00 	movl   $0x0,0xfffffef8(%ebp)
  8001d4:	00 00 00 
	b.cnt = 0;
  8001d7:	c7 85 fc fe ff ff 00 	movl   $0x0,0xfffffefc(%ebp)
  8001de:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ef:	8d 85 f8 fe ff ff    	lea    0xfffffef8(%ebp),%eax
  8001f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f9:	c7 04 24 42 02 80 00 	movl   $0x800242,(%esp)
  800200:	e8 cc 01 00 00       	call   8003d1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800205:	8b 85 f8 fe ff ff    	mov    0xfffffef8(%ebp),%eax
  80020b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020f:	8d 85 00 ff ff ff    	lea    0xffffff00(%ebp),%eax
  800215:	89 04 24             	mov    %eax,(%esp)
  800218:	e8 eb 0a 00 00       	call   800d08 <sys_cputs>
  80021d:	8b 85 fc fe ff ff    	mov    0xfffffefc(%ebp),%eax

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
  80022e:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
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
  800242:	55                   	push   %ebp
  800243:	89 e5                	mov    %esp,%ebp
  800245:	53                   	push   %ebx
  800246:	83 ec 14             	sub    $0x14,%esp
  800249:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80024c:	8b 03                	mov    (%ebx),%eax
  80024e:	8b 55 08             	mov    0x8(%ebp),%edx
  800251:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800255:	83 c0 01             	add    $0x1,%eax
  800258:	89 03                	mov    %eax,(%ebx)
  80025a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80025f:	75 19                	jne    80027a <putch+0x38>
  800261:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800268:	00 
  800269:	8d 43 08             	lea    0x8(%ebx),%eax
  80026c:	89 04 24             	mov    %eax,(%esp)
  80026f:	e8 94 0a 00 00       	call   800d08 <sys_cputs>
  800274:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80027a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
  80027e:	83 c4 14             	add    $0x14,%esp
  800281:	5b                   	pop    %ebx
  800282:	5d                   	pop    %ebp
  800283:	c3                   	ret    
	...

00800290 <printnum>:
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
  800299:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  80029c:	89 d7                	mov    %edx,%edi
  80029e:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a4:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  8002a7:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  8002aa:	8b 55 10             	mov    0x10(%ebp),%edx
  8002ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8002b0:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b3:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  8002b6:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  8002bd:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  8002c0:	39 4d ec             	cmp    %ecx,0xffffffec(%ebp)
  8002c3:	72 11                	jb     8002d6 <printnum+0x46>
  8002c5:	8b 4d d8             	mov    0xffffffd8(%ebp),%ecx
  8002c8:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  8002cb:	76 09                	jbe    8002d6 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002cd:	8d 58 ff             	lea    0xffffffff(%eax),%ebx
  8002d0:	85 db                	test   %ebx,%ebx
  8002d2:	7f 54                	jg     800328 <printnum+0x98>
  8002d4:	eb 61                	jmp    800337 <printnum+0xa7>
  8002d6:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002da:	83 e8 01             	sub    $0x1,%eax
  8002dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002e1:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002e5:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002e9:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002ed:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8002f0:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  8002f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002fb:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  8002fe:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800301:	89 14 24             	mov    %edx,(%esp)
  800304:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800308:	e8 e3 1d 00 00       	call   8020f0 <__udivdi3>
  80030d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800311:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800315:	89 04 24             	mov    %eax,(%esp)
  800318:	89 54 24 04          	mov    %edx,0x4(%esp)
  80031c:	89 fa                	mov    %edi,%edx
  80031e:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  800321:	e8 6a ff ff ff       	call   800290 <printnum>
  800326:	eb 0f                	jmp    800337 <printnum+0xa7>
			putch(padc, putdat);
  800328:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80032c:	89 34 24             	mov    %esi,(%esp)
  80032f:	ff 55 e4             	call   *0xffffffe4(%ebp)
  800332:	83 eb 01             	sub    $0x1,%ebx
  800335:	75 f1                	jne    800328 <printnum+0x98>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800337:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80033b:	8b 74 24 04          	mov    0x4(%esp),%esi
  80033f:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800342:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800345:	89 44 24 08          	mov    %eax,0x8(%esp)
  800349:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80034d:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800350:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800353:	89 14 24             	mov    %edx,(%esp)
  800356:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80035a:	e8 c1 1e 00 00       	call   802220 <__umoddi3>
  80035f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800363:	0f be 80 a2 24 80 00 	movsbl 0x8024a2(%eax),%eax
  80036a:	89 04 24             	mov    %eax,(%esp)
  80036d:	ff 55 e4             	call   *0xffffffe4(%ebp)
}
  800370:	83 c4 3c             	add    $0x3c,%esp
  800373:	5b                   	pop    %ebx
  800374:	5e                   	pop    %esi
  800375:	5f                   	pop    %edi
  800376:	5d                   	pop    %ebp
  800377:	c3                   	ret    

00800378 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  80037d:	83 fa 01             	cmp    $0x1,%edx
  800380:	7e 0e                	jle    800390 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  800382:	8b 10                	mov    (%eax),%edx
  800384:	8d 42 08             	lea    0x8(%edx),%eax
  800387:	89 01                	mov    %eax,(%ecx)
  800389:	8b 02                	mov    (%edx),%eax
  80038b:	8b 52 04             	mov    0x4(%edx),%edx
  80038e:	eb 22                	jmp    8003b2 <getuint+0x3a>
	else if (lflag)
  800390:	85 d2                	test   %edx,%edx
  800392:	74 10                	je     8003a4 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800394:	8b 10                	mov    (%eax),%edx
  800396:	8d 42 04             	lea    0x4(%edx),%eax
  800399:	89 01                	mov    %eax,(%ecx)
  80039b:	8b 02                	mov    (%edx),%eax
  80039d:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a2:	eb 0e                	jmp    8003b2 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  8003a4:	8b 10                	mov    (%eax),%edx
  8003a6:	8d 42 04             	lea    0x4(%edx),%eax
  8003a9:	89 01                	mov    %eax,(%ecx)
  8003ab:	8b 02                	mov    (%edx),%eax
  8003ad:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003b2:	5d                   	pop    %ebp
  8003b3:	c3                   	ret    

008003b4 <sprintputch>:

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
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
  8003b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  8003ba:	83 41 08 01          	addl   $0x1,0x8(%ecx)
	if (b->buf < b->ebuf)
  8003be:	8b 11                	mov    (%ecx),%edx
  8003c0:	3b 51 04             	cmp    0x4(%ecx),%edx
  8003c3:	73 0a                	jae    8003cf <sprintputch+0x1b>
		*b->buf++ = ch;
  8003c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c8:	88 02                	mov    %al,(%edx)
  8003ca:	8d 42 01             	lea    0x1(%edx),%eax
  8003cd:	89 01                	mov    %eax,(%ecx)
}
  8003cf:	5d                   	pop    %ebp
  8003d0:	c3                   	ret    

008003d1 <vprintfmt>:
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	57                   	push   %edi
  8003d5:	56                   	push   %esi
  8003d6:	53                   	push   %ebx
  8003d7:	83 ec 4c             	sub    $0x4c,%esp
  8003da:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003e0:	eb 03                	jmp    8003e5 <vprintfmt+0x14>
  8003e2:	8b 5d e8             	mov    0xffffffe8(%ebp),%ebx
  8003e5:	0f b6 03             	movzbl (%ebx),%eax
  8003e8:	83 c3 01             	add    $0x1,%ebx
  8003eb:	3c 25                	cmp    $0x25,%al
  8003ed:	74 30                	je     80041f <vprintfmt+0x4e>
  8003ef:	84 c0                	test   %al,%al
  8003f1:	0f 84 a8 03 00 00    	je     80079f <vprintfmt+0x3ce>
  8003f7:	0f b6 d0             	movzbl %al,%edx
  8003fa:	eb 0a                	jmp    800406 <vprintfmt+0x35>
  8003fc:	84 c0                	test   %al,%al
  8003fe:	66 90                	xchg   %ax,%ax
  800400:	0f 84 99 03 00 00    	je     80079f <vprintfmt+0x3ce>
  800406:	8b 45 0c             	mov    0xc(%ebp),%eax
  800409:	89 44 24 04          	mov    %eax,0x4(%esp)
  80040d:	89 14 24             	mov    %edx,(%esp)
  800410:	ff d7                	call   *%edi
  800412:	0f b6 03             	movzbl (%ebx),%eax
  800415:	0f b6 d0             	movzbl %al,%edx
  800418:	83 c3 01             	add    $0x1,%ebx
  80041b:	3c 25                	cmp    $0x25,%al
  80041d:	75 dd                	jne    8003fc <vprintfmt+0x2b>
  80041f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800424:	c7 45 ec ff ff ff ff 	movl   $0xffffffff,0xffffffec(%ebp)
  80042b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  800432:	c7 45 dc 00 00 00 00 	movl   $0x0,0xffffffdc(%ebp)
  800439:	c6 45 e3 20          	movb   $0x20,0xffffffe3(%ebp)
  80043d:	eb 07                	jmp    800446 <vprintfmt+0x75>
  80043f:	c7 45 dc 01 00 00 00 	movl   $0x1,0xffffffdc(%ebp)
  800446:	0f b6 03             	movzbl (%ebx),%eax
  800449:	0f b6 d0             	movzbl %al,%edx
  80044c:	83 c3 01             	add    $0x1,%ebx
  80044f:	83 e8 23             	sub    $0x23,%eax
  800452:	3c 55                	cmp    $0x55,%al
  800454:	0f 87 11 03 00 00    	ja     80076b <vprintfmt+0x39a>
  80045a:	0f b6 c0             	movzbl %al,%eax
  80045d:	ff 24 85 e0 25 80 00 	jmp    *0x8025e0(,%eax,4)
  800464:	c6 45 e3 30          	movb   $0x30,0xffffffe3(%ebp)
  800468:	eb dc                	jmp    800446 <vprintfmt+0x75>
  80046a:	83 ea 30             	sub    $0x30,%edx
  80046d:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  800470:	0f be 13             	movsbl (%ebx),%edx
  800473:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800476:	83 f8 09             	cmp    $0x9,%eax
  800479:	76 08                	jbe    800483 <vprintfmt+0xb2>
  80047b:	eb 42                	jmp    8004bf <vprintfmt+0xee>
  80047d:	c6 45 e3 2d          	movb   $0x2d,0xffffffe3(%ebp)
  800481:	eb c3                	jmp    800446 <vprintfmt+0x75>
  800483:	83 c3 01             	add    $0x1,%ebx
  800486:	8b 75 e4             	mov    0xffffffe4(%ebp),%esi
  800489:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  80048c:	8d 44 42 d0          	lea    0xffffffd0(%edx,%eax,2),%eax
  800490:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  800493:	0f be 13             	movsbl (%ebx),%edx
  800496:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800499:	83 f8 09             	cmp    $0x9,%eax
  80049c:	77 21                	ja     8004bf <vprintfmt+0xee>
  80049e:	eb e3                	jmp    800483 <vprintfmt+0xb2>
  8004a0:	8b 55 14             	mov    0x14(%ebp),%edx
  8004a3:	8d 42 04             	lea    0x4(%edx),%eax
  8004a6:	89 45 14             	mov    %eax,0x14(%ebp)
  8004a9:	8b 12                	mov    (%edx),%edx
  8004ab:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  8004ae:	eb 0f                	jmp    8004bf <vprintfmt+0xee>
  8004b0:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  8004b4:	79 90                	jns    800446 <vprintfmt+0x75>
  8004b6:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  8004bd:	eb 87                	jmp    800446 <vprintfmt+0x75>
  8004bf:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  8004c3:	79 81                	jns    800446 <vprintfmt+0x75>
  8004c5:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  8004c8:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  8004cb:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  8004d2:	e9 6f ff ff ff       	jmp    800446 <vprintfmt+0x75>
  8004d7:	83 c1 01             	add    $0x1,%ecx
  8004da:	e9 67 ff ff ff       	jmp    800446 <vprintfmt+0x75>
  8004df:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e2:	8d 50 04             	lea    0x4(%eax),%edx
  8004e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004ef:	8b 00                	mov    (%eax),%eax
  8004f1:	89 04 24             	mov    %eax,(%esp)
  8004f4:	ff d7                	call   *%edi
  8004f6:	e9 ea fe ff ff       	jmp    8003e5 <vprintfmt+0x14>
  8004fb:	8b 55 14             	mov    0x14(%ebp),%edx
  8004fe:	8d 42 04             	lea    0x4(%edx),%eax
  800501:	89 45 14             	mov    %eax,0x14(%ebp)
  800504:	8b 02                	mov    (%edx),%eax
  800506:	89 c2                	mov    %eax,%edx
  800508:	c1 fa 1f             	sar    $0x1f,%edx
  80050b:	31 d0                	xor    %edx,%eax
  80050d:	29 d0                	sub    %edx,%eax
  80050f:	83 f8 0f             	cmp    $0xf,%eax
  800512:	7f 0b                	jg     80051f <vprintfmt+0x14e>
  800514:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  80051b:	85 d2                	test   %edx,%edx
  80051d:	75 20                	jne    80053f <vprintfmt+0x16e>
  80051f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800523:	c7 44 24 08 b3 24 80 	movl   $0x8024b3,0x8(%esp)
  80052a:	00 
  80052b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80052e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800532:	89 3c 24             	mov    %edi,(%esp)
  800535:	e8 f0 02 00 00       	call   80082a <printfmt>
  80053a:	e9 a6 fe ff ff       	jmp    8003e5 <vprintfmt+0x14>
  80053f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800543:	c7 44 24 08 82 28 80 	movl   $0x802882,0x8(%esp)
  80054a:	00 
  80054b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80054e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800552:	89 3c 24             	mov    %edi,(%esp)
  800555:	e8 d0 02 00 00       	call   80082a <printfmt>
  80055a:	e9 86 fe ff ff       	jmp    8003e5 <vprintfmt+0x14>
  80055f:	8b 75 ec             	mov    0xffffffec(%ebp),%esi
  800562:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  800565:	89 5d e8             	mov    %ebx,0xffffffe8(%ebp)
  800568:	8b 55 14             	mov    0x14(%ebp),%edx
  80056b:	8d 42 04             	lea    0x4(%edx),%eax
  80056e:	89 45 14             	mov    %eax,0x14(%ebp)
  800571:	8b 12                	mov    (%edx),%edx
  800573:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  800576:	85 d2                	test   %edx,%edx
  800578:	75 07                	jne    800581 <vprintfmt+0x1b0>
  80057a:	c7 45 d8 bc 24 80 00 	movl   $0x8024bc,0xffffffd8(%ebp)
  800581:	85 f6                	test   %esi,%esi
  800583:	7e 40                	jle    8005c5 <vprintfmt+0x1f4>
  800585:	80 7d e3 2d          	cmpb   $0x2d,0xffffffe3(%ebp)
  800589:	74 3a                	je     8005c5 <vprintfmt+0x1f4>
  80058b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80058f:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800592:	89 14 24             	mov    %edx,(%esp)
  800595:	e8 e6 02 00 00       	call   800880 <strnlen>
  80059a:	29 c6                	sub    %eax,%esi
  80059c:	89 75 ec             	mov    %esi,0xffffffec(%ebp)
  80059f:	85 f6                	test   %esi,%esi
  8005a1:	7e 22                	jle    8005c5 <vprintfmt+0x1f4>
  8005a3:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  8005a7:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  8005aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005b1:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  8005b4:	89 04 24             	mov    %eax,(%esp)
  8005b7:	ff d7                	call   *%edi
  8005b9:	83 ee 01             	sub    $0x1,%esi
  8005bc:	75 ec                	jne    8005aa <vprintfmt+0x1d9>
  8005be:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  8005c5:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  8005c8:	0f b6 02             	movzbl (%edx),%eax
  8005cb:	0f be d0             	movsbl %al,%edx
  8005ce:	8b 75 d8             	mov    0xffffffd8(%ebp),%esi
  8005d1:	84 c0                	test   %al,%al
  8005d3:	75 40                	jne    800615 <vprintfmt+0x244>
  8005d5:	eb 4a                	jmp    800621 <vprintfmt+0x250>
  8005d7:	83 7d dc 00          	cmpl   $0x0,0xffffffdc(%ebp)
  8005db:	74 1a                	je     8005f7 <vprintfmt+0x226>
  8005dd:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  8005e0:	83 f8 5e             	cmp    $0x5e,%eax
  8005e3:	76 12                	jbe    8005f7 <vprintfmt+0x226>
  8005e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ec:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005f3:	ff d7                	call   *%edi
  8005f5:	eb 0c                	jmp    800603 <vprintfmt+0x232>
  8005f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005fe:	89 14 24             	mov    %edx,(%esp)
  800601:	ff d7                	call   *%edi
  800603:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  800607:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80060b:	83 c6 01             	add    $0x1,%esi
  80060e:	84 c0                	test   %al,%al
  800610:	74 0f                	je     800621 <vprintfmt+0x250>
  800612:	0f be d0             	movsbl %al,%edx
  800615:	83 7d e4 00          	cmpl   $0x0,0xffffffe4(%ebp)
  800619:	78 bc                	js     8005d7 <vprintfmt+0x206>
  80061b:	83 6d e4 01          	subl   $0x1,0xffffffe4(%ebp)
  80061f:	79 b6                	jns    8005d7 <vprintfmt+0x206>
  800621:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800625:	0f 8e ba fd ff ff    	jle    8003e5 <vprintfmt+0x14>
  80062b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80062e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800632:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800639:	ff d7                	call   *%edi
  80063b:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  80063f:	0f 84 9d fd ff ff    	je     8003e2 <vprintfmt+0x11>
  800645:	eb e4                	jmp    80062b <vprintfmt+0x25a>
  800647:	83 f9 01             	cmp    $0x1,%ecx
  80064a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800650:	7e 10                	jle    800662 <vprintfmt+0x291>
  800652:	8b 55 14             	mov    0x14(%ebp),%edx
  800655:	8d 42 08             	lea    0x8(%edx),%eax
  800658:	89 45 14             	mov    %eax,0x14(%ebp)
  80065b:	8b 02                	mov    (%edx),%eax
  80065d:	8b 52 04             	mov    0x4(%edx),%edx
  800660:	eb 26                	jmp    800688 <vprintfmt+0x2b7>
  800662:	85 c9                	test   %ecx,%ecx
  800664:	74 12                	je     800678 <vprintfmt+0x2a7>
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8d 50 04             	lea    0x4(%eax),%edx
  80066c:	89 55 14             	mov    %edx,0x14(%ebp)
  80066f:	8b 00                	mov    (%eax),%eax
  800671:	89 c2                	mov    %eax,%edx
  800673:	c1 fa 1f             	sar    $0x1f,%edx
  800676:	eb 10                	jmp    800688 <vprintfmt+0x2b7>
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8d 50 04             	lea    0x4(%eax),%edx
  80067e:	89 55 14             	mov    %edx,0x14(%ebp)
  800681:	8b 00                	mov    (%eax),%eax
  800683:	89 c2                	mov    %eax,%edx
  800685:	c1 fa 1f             	sar    $0x1f,%edx
  800688:	89 d1                	mov    %edx,%ecx
  80068a:	89 c2                	mov    %eax,%edx
  80068c:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  80068f:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  800692:	be 0a 00 00 00       	mov    $0xa,%esi
  800697:	85 c9                	test   %ecx,%ecx
  800699:	0f 89 92 00 00 00    	jns    800731 <vprintfmt+0x360>
  80069f:	8b 75 0c             	mov    0xc(%ebp),%esi
  8006a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006a6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006ad:	ff d7                	call   *%edi
  8006af:	8b 55 d0             	mov    0xffffffd0(%ebp),%edx
  8006b2:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
  8006b5:	f7 da                	neg    %edx
  8006b7:	83 d1 00             	adc    $0x0,%ecx
  8006ba:	f7 d9                	neg    %ecx
  8006bc:	be 0a 00 00 00       	mov    $0xa,%esi
  8006c1:	eb 6e                	jmp    800731 <vprintfmt+0x360>
  8006c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c6:	89 ca                	mov    %ecx,%edx
  8006c8:	e8 ab fc ff ff       	call   800378 <getuint>
  8006cd:	89 d1                	mov    %edx,%ecx
  8006cf:	89 c2                	mov    %eax,%edx
  8006d1:	be 0a 00 00 00       	mov    $0xa,%esi
  8006d6:	eb 59                	jmp    800731 <vprintfmt+0x360>
  8006d8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006db:	89 ca                	mov    %ecx,%edx
  8006dd:	e8 96 fc ff ff       	call   800378 <getuint>
  8006e2:	e9 fe fc ff ff       	jmp    8003e5 <vprintfmt+0x14>
  8006e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ee:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006f5:	ff d7                	call   *%edi
  8006f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006fa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006fe:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800705:	ff d7                	call   *%edi
  800707:	8b 55 14             	mov    0x14(%ebp),%edx
  80070a:	8d 42 04             	lea    0x4(%edx),%eax
  80070d:	89 45 14             	mov    %eax,0x14(%ebp)
  800710:	8b 12                	mov    (%edx),%edx
  800712:	b9 00 00 00 00       	mov    $0x0,%ecx
  800717:	be 10 00 00 00       	mov    $0x10,%esi
  80071c:	eb 13                	jmp    800731 <vprintfmt+0x360>
  80071e:	8d 45 14             	lea    0x14(%ebp),%eax
  800721:	89 ca                	mov    %ecx,%edx
  800723:	e8 50 fc ff ff       	call   800378 <getuint>
  800728:	89 d1                	mov    %edx,%ecx
  80072a:	89 c2                	mov    %eax,%edx
  80072c:	be 10 00 00 00       	mov    $0x10,%esi
  800731:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  800735:	89 44 24 10          	mov    %eax,0x10(%esp)
  800739:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  80073c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800740:	89 74 24 08          	mov    %esi,0x8(%esp)
  800744:	89 14 24             	mov    %edx,(%esp)
  800747:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80074b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80074e:	89 f8                	mov    %edi,%eax
  800750:	e8 3b fb ff ff       	call   800290 <printnum>
  800755:	e9 8b fc ff ff       	jmp    8003e5 <vprintfmt+0x14>
  80075a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80075d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800761:	89 14 24             	mov    %edx,(%esp)
  800764:	ff d7                	call   *%edi
  800766:	e9 7a fc ff ff       	jmp    8003e5 <vprintfmt+0x14>
  80076b:	89 de                	mov    %ebx,%esi
  80076d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800770:	89 44 24 04          	mov    %eax,0x4(%esp)
  800774:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80077b:	ff d7                	call   *%edi
  80077d:	83 eb 01             	sub    $0x1,%ebx
  800780:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  800784:	0f 84 5b fc ff ff    	je     8003e5 <vprintfmt+0x14>
  80078a:	8d 56 fd             	lea    0xfffffffd(%esi),%edx
  80078d:	0f b6 02             	movzbl (%edx),%eax
  800790:	83 ea 01             	sub    $0x1,%edx
  800793:	3c 25                	cmp    $0x25,%al
  800795:	75 f6                	jne    80078d <vprintfmt+0x3bc>
  800797:	8d 5a 02             	lea    0x2(%edx),%ebx
  80079a:	e9 46 fc ff ff       	jmp    8003e5 <vprintfmt+0x14>
  80079f:	83 c4 4c             	add    $0x4c,%esp
  8007a2:	5b                   	pop    %ebx
  8007a3:	5e                   	pop    %esi
  8007a4:	5f                   	pop    %edi
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	83 ec 28             	sub    $0x28,%esp
  8007ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8007b0:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8007b3:	85 d2                	test   %edx,%edx
  8007b5:	74 04                	je     8007bb <vsnprintf+0x14>
  8007b7:	85 c0                	test   %eax,%eax
  8007b9:	7f 07                	jg     8007c2 <vsnprintf+0x1b>
  8007bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007c0:	eb 3b                	jmp    8007fd <vsnprintf+0x56>
  8007c2:	c7 45 fc 00 00 00 00 	movl   $0x0,0xfffffffc(%ebp)
  8007c9:	8d 44 02 ff          	lea    0xffffffff(%edx,%eax,1),%eax
  8007cd:	89 45 f8             	mov    %eax,0xfffffff8(%ebp)
  8007d0:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007da:	8b 45 10             	mov    0x10(%ebp),%eax
  8007dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e1:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8007e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e8:	c7 04 24 b4 03 80 00 	movl   $0x8003b4,(%esp)
  8007ef:	e8 dd fb ff ff       	call   8003d1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f4:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8007f7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007fa:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
}
  8007fd:	c9                   	leave  
  8007fe:	c3                   	ret    

008007ff <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800805:	8d 45 14             	lea    0x14(%ebp),%eax
  800808:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  80080b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80080f:	8b 45 10             	mov    0x10(%ebp),%eax
  800812:	89 44 24 08          	mov    %eax,0x8(%esp)
  800816:	8b 45 0c             	mov    0xc(%ebp),%eax
  800819:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081d:	8b 45 08             	mov    0x8(%ebp),%eax
  800820:	89 04 24             	mov    %eax,(%esp)
  800823:	e8 7f ff ff ff       	call   8007a7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800828:	c9                   	leave  
  800829:	c3                   	ret    

0080082a <printfmt>:
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	83 ec 28             	sub    $0x28,%esp
  800830:	8d 45 14             	lea    0x14(%ebp),%eax
  800833:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
  800836:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80083a:	8b 45 10             	mov    0x10(%ebp),%eax
  80083d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800841:	8b 45 0c             	mov    0xc(%ebp),%eax
  800844:	89 44 24 04          	mov    %eax,0x4(%esp)
  800848:	8b 45 08             	mov    0x8(%ebp),%eax
  80084b:	89 04 24             	mov    %eax,(%esp)
  80084e:	e8 7e fb ff ff       	call   8003d1 <vprintfmt>
  800853:	c9                   	leave  
  800854:	c3                   	ret    
	...

00800860 <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800866:	b8 00 00 00 00       	mov    $0x0,%eax
  80086b:	80 3a 00             	cmpb   $0x0,(%edx)
  80086e:	74 0e                	je     80087e <strlen+0x1e>
  800870:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800875:	83 c0 01             	add    $0x1,%eax
  800878:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  80087c:	75 f7                	jne    800875 <strlen+0x15>
	return n;
}
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800886:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800889:	85 d2                	test   %edx,%edx
  80088b:	74 19                	je     8008a6 <strnlen+0x26>
  80088d:	80 39 00             	cmpb   $0x0,(%ecx)
  800890:	74 14                	je     8008a6 <strnlen+0x26>
  800892:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800897:	83 c0 01             	add    $0x1,%eax
  80089a:	39 d0                	cmp    %edx,%eax
  80089c:	74 0d                	je     8008ab <strnlen+0x2b>
  80089e:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  8008a2:	74 07                	je     8008ab <strnlen+0x2b>
  8008a4:	eb f1                	jmp    800897 <strnlen+0x17>
  8008a6:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  8008ab:	5d                   	pop    %ebp
  8008ac:	8d 74 26 00          	lea    0x0(%esi),%esi
  8008b0:	c3                   	ret    

008008b1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	53                   	push   %ebx
  8008b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008bb:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008bd:	0f b6 01             	movzbl (%ecx),%eax
  8008c0:	88 02                	mov    %al,(%edx)
  8008c2:	83 c2 01             	add    $0x1,%edx
  8008c5:	83 c1 01             	add    $0x1,%ecx
  8008c8:	84 c0                	test   %al,%al
  8008ca:	75 f1                	jne    8008bd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008cc:	89 d8                	mov    %ebx,%eax
  8008ce:	5b                   	pop    %ebx
  8008cf:	5d                   	pop    %ebp
  8008d0:	c3                   	ret    

008008d1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	57                   	push   %edi
  8008d5:	56                   	push   %esi
  8008d6:	53                   	push   %ebx
  8008d7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008dd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e0:	85 f6                	test   %esi,%esi
  8008e2:	74 1c                	je     800900 <strncpy+0x2f>
  8008e4:	89 fa                	mov    %edi,%edx
  8008e6:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  8008eb:	0f b6 01             	movzbl (%ecx),%eax
  8008ee:	88 02                	mov    %al,(%edx)
  8008f0:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f3:	80 39 01             	cmpb   $0x1,(%ecx)
  8008f6:	83 d9 ff             	sbb    $0xffffffff,%ecx
  8008f9:	83 c3 01             	add    $0x1,%ebx
  8008fc:	39 f3                	cmp    %esi,%ebx
  8008fe:	75 eb                	jne    8008eb <strncpy+0x1a>
	}
	return ret;
}
  800900:	89 f8                	mov    %edi,%eax
  800902:	5b                   	pop    %ebx
  800903:	5e                   	pop    %esi
  800904:	5f                   	pop    %edi
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	56                   	push   %esi
  80090b:	53                   	push   %ebx
  80090c:	8b 75 08             	mov    0x8(%ebp),%esi
  80090f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800912:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800915:	89 f0                	mov    %esi,%eax
  800917:	85 d2                	test   %edx,%edx
  800919:	74 2c                	je     800947 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  80091b:	89 d3                	mov    %edx,%ebx
  80091d:	83 eb 01             	sub    $0x1,%ebx
  800920:	74 20                	je     800942 <strlcpy+0x3b>
  800922:	0f b6 11             	movzbl (%ecx),%edx
  800925:	84 d2                	test   %dl,%dl
  800927:	74 19                	je     800942 <strlcpy+0x3b>
  800929:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  80092b:	88 10                	mov    %dl,(%eax)
  80092d:	83 c0 01             	add    $0x1,%eax
  800930:	83 eb 01             	sub    $0x1,%ebx
  800933:	74 0f                	je     800944 <strlcpy+0x3d>
  800935:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  800939:	83 c1 01             	add    $0x1,%ecx
  80093c:	84 d2                	test   %dl,%dl
  80093e:	74 04                	je     800944 <strlcpy+0x3d>
  800940:	eb e9                	jmp    80092b <strlcpy+0x24>
  800942:	89 f0                	mov    %esi,%eax
		*dst = '\0';
  800944:	c6 00 00             	movb   $0x0,(%eax)
  800947:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800949:	5b                   	pop    %ebx
  80094a:	5e                   	pop    %esi
  80094b:	5d                   	pop    %ebp
  80094c:	c3                   	ret    

0080094d <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	57                   	push   %edi
  800951:	56                   	push   %esi
  800952:	53                   	push   %ebx
  800953:	8b 55 08             	mov    0x8(%ebp),%edx
  800956:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800959:	8b 7d 10             	mov    0x10(%ebp),%edi
    int c;
    char *q = buf;

    if (buf_size <= 0)
  80095c:	85 c9                	test   %ecx,%ecx
  80095e:	7e 30                	jle    800990 <pstrcpy+0x43>
        return;

    for(;;) {
        c = *str++;
  800960:	0f b6 07             	movzbl (%edi),%eax
        if (c == 0 || q >= buf + buf_size - 1)
  800963:	84 c0                	test   %al,%al
  800965:	74 26                	je     80098d <pstrcpy+0x40>
  800967:	8d 74 0a ff          	lea    0xffffffff(%edx,%ecx,1),%esi
  80096b:	0f be d8             	movsbl %al,%ebx
  80096e:	89 f9                	mov    %edi,%ecx
  800970:	39 f2                	cmp    %esi,%edx
  800972:	72 09                	jb     80097d <pstrcpy+0x30>
  800974:	eb 17                	jmp    80098d <pstrcpy+0x40>
  800976:	83 c1 01             	add    $0x1,%ecx
  800979:	39 f2                	cmp    %esi,%edx
  80097b:	73 10                	jae    80098d <pstrcpy+0x40>
            break;
        *q++ = c;
  80097d:	88 1a                	mov    %bl,(%edx)
  80097f:	83 c2 01             	add    $0x1,%edx
  800982:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800986:	0f be d8             	movsbl %al,%ebx
  800989:	84 c0                	test   %al,%al
  80098b:	75 e9                	jne    800976 <pstrcpy+0x29>
    }
    *q = '\0';
  80098d:	c6 02 00             	movb   $0x0,(%edx)
}
  800990:	5b                   	pop    %ebx
  800991:	5e                   	pop    %esi
  800992:	5f                   	pop    %edi
  800993:	5d                   	pop    %ebp
  800994:	c3                   	ret    

00800995 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	8b 55 08             	mov    0x8(%ebp),%edx
  80099b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  80099e:	0f b6 02             	movzbl (%edx),%eax
  8009a1:	84 c0                	test   %al,%al
  8009a3:	74 16                	je     8009bb <strcmp+0x26>
  8009a5:	3a 01                	cmp    (%ecx),%al
  8009a7:	75 12                	jne    8009bb <strcmp+0x26>
		p++, q++;
  8009a9:	83 c1 01             	add    $0x1,%ecx
  8009ac:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  8009b0:	84 c0                	test   %al,%al
  8009b2:	74 07                	je     8009bb <strcmp+0x26>
  8009b4:	83 c2 01             	add    $0x1,%edx
  8009b7:	3a 01                	cmp    (%ecx),%al
  8009b9:	74 ee                	je     8009a9 <strcmp+0x14>
  8009bb:	0f b6 c0             	movzbl %al,%eax
  8009be:	0f b6 11             	movzbl (%ecx),%edx
  8009c1:	29 d0                	sub    %edx,%eax
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	53                   	push   %ebx
  8009c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009cf:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8009d2:	85 d2                	test   %edx,%edx
  8009d4:	74 2d                	je     800a03 <strncmp+0x3e>
  8009d6:	0f b6 01             	movzbl (%ecx),%eax
  8009d9:	84 c0                	test   %al,%al
  8009db:	74 1a                	je     8009f7 <strncmp+0x32>
  8009dd:	3a 03                	cmp    (%ebx),%al
  8009df:	75 16                	jne    8009f7 <strncmp+0x32>
  8009e1:	83 ea 01             	sub    $0x1,%edx
  8009e4:	74 1d                	je     800a03 <strncmp+0x3e>
		n--, p++, q++;
  8009e6:	83 c1 01             	add    $0x1,%ecx
  8009e9:	83 c3 01             	add    $0x1,%ebx
  8009ec:	0f b6 01             	movzbl (%ecx),%eax
  8009ef:	84 c0                	test   %al,%al
  8009f1:	74 04                	je     8009f7 <strncmp+0x32>
  8009f3:	3a 03                	cmp    (%ebx),%al
  8009f5:	74 ea                	je     8009e1 <strncmp+0x1c>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f7:	0f b6 11             	movzbl (%ecx),%edx
  8009fa:	0f b6 03             	movzbl (%ebx),%eax
  8009fd:	29 c2                	sub    %eax,%edx
  8009ff:	89 d0                	mov    %edx,%eax
  800a01:	eb 05                	jmp    800a08 <strncmp+0x43>
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a08:	5b                   	pop    %ebx
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a15:	0f b6 10             	movzbl (%eax),%edx
  800a18:	84 d2                	test   %dl,%dl
  800a1a:	74 16                	je     800a32 <strchr+0x27>
		if (*s == c)
  800a1c:	38 ca                	cmp    %cl,%dl
  800a1e:	75 06                	jne    800a26 <strchr+0x1b>
  800a20:	eb 15                	jmp    800a37 <strchr+0x2c>
  800a22:	38 ca                	cmp    %cl,%dl
  800a24:	74 11                	je     800a37 <strchr+0x2c>
  800a26:	83 c0 01             	add    $0x1,%eax
  800a29:	0f b6 10             	movzbl (%eax),%edx
  800a2c:	84 d2                	test   %dl,%dl
  800a2e:	66 90                	xchg   %ax,%ax
  800a30:	75 f0                	jne    800a22 <strchr+0x17>
  800a32:	b8 00 00 00 00       	mov    $0x0,%eax
			return (char *) s;
	return 0;
}
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    

00800a39 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a43:	0f b6 10             	movzbl (%eax),%edx
  800a46:	84 d2                	test   %dl,%dl
  800a48:	74 14                	je     800a5e <strfind+0x25>
		if (*s == c)
  800a4a:	38 ca                	cmp    %cl,%dl
  800a4c:	75 06                	jne    800a54 <strfind+0x1b>
  800a4e:	eb 0e                	jmp    800a5e <strfind+0x25>
  800a50:	38 ca                	cmp    %cl,%dl
  800a52:	74 0a                	je     800a5e <strfind+0x25>
  800a54:	83 c0 01             	add    $0x1,%eax
  800a57:	0f b6 10             	movzbl (%eax),%edx
  800a5a:	84 d2                	test   %dl,%dl
  800a5c:	75 f2                	jne    800a50 <strfind+0x17>
			break;
	return (char *) s;
}
  800a5e:	5d                   	pop    %ebp
  800a5f:	90                   	nop    
  800a60:	c3                   	ret    

00800a61 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	83 ec 08             	sub    $0x8,%esp
  800a67:	89 1c 24             	mov    %ebx,(%esp)
  800a6a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a6e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a74:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800a77:	85 db                	test   %ebx,%ebx
  800a79:	74 32                	je     800aad <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a7b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a81:	75 25                	jne    800aa8 <memset+0x47>
  800a83:	f6 c3 03             	test   $0x3,%bl
  800a86:	75 20                	jne    800aa8 <memset+0x47>
		c &= 0xFF;
  800a88:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a8b:	89 d0                	mov    %edx,%eax
  800a8d:	c1 e0 18             	shl    $0x18,%eax
  800a90:	89 d1                	mov    %edx,%ecx
  800a92:	c1 e1 10             	shl    $0x10,%ecx
  800a95:	09 c8                	or     %ecx,%eax
  800a97:	09 d0                	or     %edx,%eax
  800a99:	c1 e2 08             	shl    $0x8,%edx
  800a9c:	09 d0                	or     %edx,%eax
  800a9e:	89 d9                	mov    %ebx,%ecx
  800aa0:	c1 e9 02             	shr    $0x2,%ecx
  800aa3:	fc                   	cld    
  800aa4:	f3 ab                	rep stos %eax,%es:(%edi)
  800aa6:	eb 05                	jmp    800aad <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aa8:	89 d9                	mov    %ebx,%ecx
  800aaa:	fc                   	cld    
  800aab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aad:	89 f8                	mov    %edi,%eax
  800aaf:	8b 1c 24             	mov    (%esp),%ebx
  800ab2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ab6:	89 ec                	mov    %ebp,%esp
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	83 ec 08             	sub    $0x8,%esp
  800ac0:	89 34 24             	mov    %esi,(%esp)
  800ac3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aca:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800acd:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800ad0:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800ad2:	39 c6                	cmp    %eax,%esi
  800ad4:	73 36                	jae    800b0c <memmove+0x52>
  800ad6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ad9:	39 d0                	cmp    %edx,%eax
  800adb:	73 2f                	jae    800b0c <memmove+0x52>
		s += n;
		d += n;
  800add:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae0:	f6 c2 03             	test   $0x3,%dl
  800ae3:	75 1b                	jne    800b00 <memmove+0x46>
  800ae5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aeb:	75 13                	jne    800b00 <memmove+0x46>
  800aed:	f6 c1 03             	test   $0x3,%cl
  800af0:	75 0e                	jne    800b00 <memmove+0x46>
			asm volatile("std; rep movsl\n"
  800af2:	8d 7e fc             	lea    0xfffffffc(%esi),%edi
  800af5:	8d 72 fc             	lea    0xfffffffc(%edx),%esi
  800af8:	c1 e9 02             	shr    $0x2,%ecx
  800afb:	fd                   	std    
  800afc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800afe:	eb 09                	jmp    800b09 <memmove+0x4f>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b00:	8d 7e ff             	lea    0xffffffff(%esi),%edi
  800b03:	8d 72 ff             	lea    0xffffffff(%edx),%esi
  800b06:	fd                   	std    
  800b07:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b09:	fc                   	cld    
  800b0a:	eb 21                	jmp    800b2d <memmove+0x73>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b0c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b12:	75 16                	jne    800b2a <memmove+0x70>
  800b14:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b1a:	75 0e                	jne    800b2a <memmove+0x70>
  800b1c:	f6 c1 03             	test   $0x3,%cl
  800b1f:	90                   	nop    
  800b20:	75 08                	jne    800b2a <memmove+0x70>
			asm volatile("cld; rep movsl\n"
  800b22:	c1 e9 02             	shr    $0x2,%ecx
  800b25:	fc                   	cld    
  800b26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b28:	eb 03                	jmp    800b2d <memmove+0x73>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b2a:	fc                   	cld    
  800b2b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b2d:	8b 34 24             	mov    (%esp),%esi
  800b30:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b34:	89 ec                	mov    %ebp,%esp
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <memcpy>:

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
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b3e:	8b 45 10             	mov    0x10(%ebp),%eax
  800b41:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b45:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b48:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4f:	89 04 24             	mov    %eax,(%esp)
  800b52:	e8 63 ff ff ff       	call   800aba <memmove>
}
  800b57:	c9                   	leave  
  800b58:	c3                   	ret    

00800b59 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5e:	8b 75 10             	mov    0x10(%ebp),%esi
  800b61:	83 ee 01             	sub    $0x1,%esi
  800b64:	83 fe ff             	cmp    $0xffffffff,%esi
  800b67:	74 38                	je     800ba1 <memcmp+0x48>
  800b69:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6c:	8b 55 0c             	mov    0xc(%ebp),%edx
		if (*s1 != *s2)
  800b6f:	0f b6 18             	movzbl (%eax),%ebx
  800b72:	0f b6 0a             	movzbl (%edx),%ecx
  800b75:	38 cb                	cmp    %cl,%bl
  800b77:	74 20                	je     800b99 <memcmp+0x40>
  800b79:	eb 12                	jmp    800b8d <memcmp+0x34>
  800b7b:	0f b6 58 01          	movzbl 0x1(%eax),%ebx
  800b7f:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
  800b83:	83 c0 01             	add    $0x1,%eax
  800b86:	83 c2 01             	add    $0x1,%edx
  800b89:	38 cb                	cmp    %cl,%bl
  800b8b:	74 0c                	je     800b99 <memcmp+0x40>
			return (int) *s1 - (int) *s2;
  800b8d:	0f b6 d3             	movzbl %bl,%edx
  800b90:	0f b6 c1             	movzbl %cl,%eax
  800b93:	29 c2                	sub    %eax,%edx
  800b95:	89 d0                	mov    %edx,%eax
  800b97:	eb 0d                	jmp    800ba6 <memcmp+0x4d>
  800b99:	83 ee 01             	sub    $0x1,%esi
  800b9c:	83 fe ff             	cmp    $0xffffffff,%esi
  800b9f:	75 da                	jne    800b7b <memcmp+0x22>
  800ba1:	b8 00 00 00 00       	mov    $0x0,%eax
		s1++, s2++;
	}

	return 0;
}
  800ba6:	5b                   	pop    %ebx
  800ba7:	5e                   	pop    %esi
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	53                   	push   %ebx
  800bae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800bb1:	89 da                	mov    %ebx,%edx
  800bb3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bb6:	39 d3                	cmp    %edx,%ebx
  800bb8:	73 1a                	jae    800bd4 <memfind+0x2a>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bba:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
			break;
  800bbe:	89 d8                	mov    %ebx,%eax
  800bc0:	38 0b                	cmp    %cl,(%ebx)
  800bc2:	75 06                	jne    800bca <memfind+0x20>
  800bc4:	eb 0e                	jmp    800bd4 <memfind+0x2a>
  800bc6:	38 08                	cmp    %cl,(%eax)
  800bc8:	74 0c                	je     800bd6 <memfind+0x2c>
  800bca:	83 c0 01             	add    $0x1,%eax
  800bcd:	39 d0                	cmp    %edx,%eax
  800bcf:	90                   	nop    
  800bd0:	75 f4                	jne    800bc6 <memfind+0x1c>
  800bd2:	eb 02                	jmp    800bd6 <memfind+0x2c>
  800bd4:	89 d8                	mov    %ebx,%eax
	return (void *) s;
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
  800bdf:	83 ec 04             	sub    $0x4,%esp
  800be2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800be5:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be8:	0f b6 03             	movzbl (%ebx),%eax
  800beb:	3c 20                	cmp    $0x20,%al
  800bed:	74 04                	je     800bf3 <strtol+0x1a>
  800bef:	3c 09                	cmp    $0x9,%al
  800bf1:	75 0e                	jne    800c01 <strtol+0x28>
		s++;
  800bf3:	83 c3 01             	add    $0x1,%ebx
  800bf6:	0f b6 03             	movzbl (%ebx),%eax
  800bf9:	3c 20                	cmp    $0x20,%al
  800bfb:	74 f6                	je     800bf3 <strtol+0x1a>
  800bfd:	3c 09                	cmp    $0x9,%al
  800bff:	74 f2                	je     800bf3 <strtol+0x1a>

	// plus/minus sign
	if (*s == '+')
  800c01:	3c 2b                	cmp    $0x2b,%al
  800c03:	75 0d                	jne    800c12 <strtol+0x39>
		s++;
  800c05:	83 c3 01             	add    $0x1,%ebx
  800c08:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800c0f:	90                   	nop    
  800c10:	eb 15                	jmp    800c27 <strtol+0x4e>
	else if (*s == '-')
  800c12:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800c19:	3c 2d                	cmp    $0x2d,%al
  800c1b:	75 0a                	jne    800c27 <strtol+0x4e>
		s++, neg = 1;
  800c1d:	83 c3 01             	add    $0x1,%ebx
  800c20:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c27:	85 f6                	test   %esi,%esi
  800c29:	0f 94 c0             	sete   %al
  800c2c:	84 c0                	test   %al,%al
  800c2e:	75 05                	jne    800c35 <strtol+0x5c>
  800c30:	83 fe 10             	cmp    $0x10,%esi
  800c33:	75 17                	jne    800c4c <strtol+0x73>
  800c35:	80 3b 30             	cmpb   $0x30,(%ebx)
  800c38:	75 12                	jne    800c4c <strtol+0x73>
  800c3a:	80 7b 01 78          	cmpb   $0x78,0x1(%ebx)
  800c3e:	66 90                	xchg   %ax,%ax
  800c40:	75 0a                	jne    800c4c <strtol+0x73>
		s += 2, base = 16;
  800c42:	83 c3 02             	add    $0x2,%ebx
  800c45:	be 10 00 00 00       	mov    $0x10,%esi
  800c4a:	eb 1f                	jmp    800c6b <strtol+0x92>
	else if (base == 0 && s[0] == '0')
  800c4c:	85 f6                	test   %esi,%esi
  800c4e:	66 90                	xchg   %ax,%ax
  800c50:	75 10                	jne    800c62 <strtol+0x89>
  800c52:	80 3b 30             	cmpb   $0x30,(%ebx)
  800c55:	75 0b                	jne    800c62 <strtol+0x89>
		s++, base = 8;
  800c57:	83 c3 01             	add    $0x1,%ebx
  800c5a:	66 be 08 00          	mov    $0x8,%si
  800c5e:	66 90                	xchg   %ax,%ax
  800c60:	eb 09                	jmp    800c6b <strtol+0x92>
	else if (base == 0)
  800c62:	84 c0                	test   %al,%al
  800c64:	74 05                	je     800c6b <strtol+0x92>
  800c66:	be 0a 00 00 00       	mov    $0xa,%esi
  800c6b:	bf 00 00 00 00       	mov    $0x0,%edi
		base = 10;

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c70:	0f b6 13             	movzbl (%ebx),%edx
  800c73:	89 d1                	mov    %edx,%ecx
  800c75:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800c78:	3c 09                	cmp    $0x9,%al
  800c7a:	77 08                	ja     800c84 <strtol+0xab>
			dig = *s - '0';
  800c7c:	0f be c2             	movsbl %dl,%eax
  800c7f:	8d 50 d0             	lea    0xffffffd0(%eax),%edx
  800c82:	eb 1c                	jmp    800ca0 <strtol+0xc7>
		else if (*s >= 'a' && *s <= 'z')
  800c84:	8d 41 9f             	lea    0xffffff9f(%ecx),%eax
  800c87:	3c 19                	cmp    $0x19,%al
  800c89:	77 08                	ja     800c93 <strtol+0xba>
			dig = *s - 'a' + 10;
  800c8b:	0f be c2             	movsbl %dl,%eax
  800c8e:	8d 50 a9             	lea    0xffffffa9(%eax),%edx
  800c91:	eb 0d                	jmp    800ca0 <strtol+0xc7>
		else if (*s >= 'A' && *s <= 'Z')
  800c93:	8d 41 bf             	lea    0xffffffbf(%ecx),%eax
  800c96:	3c 19                	cmp    $0x19,%al
  800c98:	77 17                	ja     800cb1 <strtol+0xd8>
			dig = *s - 'A' + 10;
  800c9a:	0f be c2             	movsbl %dl,%eax
  800c9d:	8d 50 c9             	lea    0xffffffc9(%eax),%edx
		else
			break;
		if (dig >= base)
  800ca0:	39 f2                	cmp    %esi,%edx
  800ca2:	7d 0d                	jge    800cb1 <strtol+0xd8>
			break;
		s++, val = (val * base) + dig;
  800ca4:	83 c3 01             	add    $0x1,%ebx
  800ca7:	89 f8                	mov    %edi,%eax
  800ca9:	0f af c6             	imul   %esi,%eax
  800cac:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800caf:	eb bf                	jmp    800c70 <strtol+0x97>
		// we don't properly detect overflow!
	}
  800cb1:	89 f8                	mov    %edi,%eax

	if (endptr)
  800cb3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cb7:	74 05                	je     800cbe <strtol+0xe5>
		*endptr = (char *) s;
  800cb9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cbc:	89 1a                	mov    %ebx,(%edx)
	return (neg ? -val : val);
  800cbe:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800cc2:	74 04                	je     800cc8 <strtol+0xef>
  800cc4:	89 c7                	mov    %eax,%edi
  800cc6:	f7 df                	neg    %edi
}
  800cc8:	89 f8                	mov    %edi,%eax
  800cca:	83 c4 04             	add    $0x4,%esp
  800ccd:	5b                   	pop    %ebx
  800cce:	5e                   	pop    %esi
  800ccf:	5f                   	pop    %edi
  800cd0:	5d                   	pop    %ebp
  800cd1:	c3                   	ret    
	...

00800cd4 <sys_cgetc>:
}

int
sys_cgetc(void)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	83 ec 0c             	sub    $0xc,%esp
  800cda:	89 1c 24             	mov    %ebx,(%esp)
  800cdd:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ce1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ce5:	b8 01 00 00 00       	mov    $0x1,%eax
  800cea:	bf 00 00 00 00       	mov    $0x0,%edi
  800cef:	89 fa                	mov    %edi,%edx
  800cf1:	89 f9                	mov    %edi,%ecx
  800cf3:	89 fb                	mov    %edi,%ebx
  800cf5:	89 fe                	mov    %edi,%esi
  800cf7:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cf9:	8b 1c 24             	mov    (%esp),%ebx
  800cfc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d00:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d04:	89 ec                	mov    %ebp,%esp
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <sys_cputs>:
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	83 ec 0c             	sub    $0xc,%esp
  800d0e:	89 1c 24             	mov    %ebx,(%esp)
  800d11:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d15:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1f:	bf 00 00 00 00       	mov    $0x0,%edi
  800d24:	89 f8                	mov    %edi,%eax
  800d26:	89 fb                	mov    %edi,%ebx
  800d28:	89 fe                	mov    %edi,%esi
  800d2a:	cd 30                	int    $0x30
  800d2c:	8b 1c 24             	mov    (%esp),%ebx
  800d2f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d33:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d37:	89 ec                	mov    %ebp,%esp
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <sys_time_msec>:

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
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	83 ec 0c             	sub    $0xc,%esp
  800d41:	89 1c 24             	mov    %ebx,(%esp)
  800d44:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d48:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d4c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d51:	bf 00 00 00 00       	mov    $0x0,%edi
  800d56:	89 fa                	mov    %edi,%edx
  800d58:	89 f9                	mov    %edi,%ecx
  800d5a:	89 fb                	mov    %edi,%ebx
  800d5c:	89 fe                	mov    %edi,%esi
  800d5e:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d60:	8b 1c 24             	mov    (%esp),%ebx
  800d63:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d67:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d6b:	89 ec                	mov    %ebp,%esp
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    

00800d6f <sys_ipc_recv>:
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	83 ec 28             	sub    $0x28,%esp
  800d75:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800d78:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800d7b:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800d7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d81:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d86:	bf 00 00 00 00       	mov    $0x0,%edi
  800d8b:	89 f9                	mov    %edi,%ecx
  800d8d:	89 fb                	mov    %edi,%ebx
  800d8f:	89 fe                	mov    %edi,%esi
  800d91:	cd 30                	int    $0x30
  800d93:	85 c0                	test   %eax,%eax
  800d95:	7e 28                	jle    800dbf <sys_ipc_recv+0x50>
  800d97:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d9b:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800da2:	00 
  800da3:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  800daa:	00 
  800dab:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db2:	00 
  800db3:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  800dba:	e8 19 11 00 00       	call   801ed8 <_panic>
  800dbf:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800dc2:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800dc5:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800dc8:	89 ec                	mov    %ebp,%esp
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <sys_ipc_try_send>:
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	83 ec 0c             	sub    $0xc,%esp
  800dd2:	89 1c 24             	mov    %ebx,(%esp)
  800dd5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dd9:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ddd:	8b 55 08             	mov    0x8(%ebp),%edx
  800de0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de9:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dee:	be 00 00 00 00       	mov    $0x0,%esi
  800df3:	cd 30                	int    $0x30
  800df5:	8b 1c 24             	mov    (%esp),%ebx
  800df8:	8b 74 24 04          	mov    0x4(%esp),%esi
  800dfc:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e00:	89 ec                	mov    %ebp,%esp
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <sys_env_set_pgfault_upcall>:
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	83 ec 28             	sub    $0x28,%esp
  800e0a:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800e0d:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800e10:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800e13:	8b 55 08             	mov    0x8(%ebp),%edx
  800e16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e19:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e1e:	bf 00 00 00 00       	mov    $0x0,%edi
  800e23:	89 fb                	mov    %edi,%ebx
  800e25:	89 fe                	mov    %edi,%esi
  800e27:	cd 30                	int    $0x30
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	7e 28                	jle    800e55 <sys_env_set_pgfault_upcall+0x51>
  800e2d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e31:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e38:	00 
  800e39:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  800e40:	00 
  800e41:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e48:	00 
  800e49:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  800e50:	e8 83 10 00 00       	call   801ed8 <_panic>
  800e55:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800e58:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800e5b:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800e5e:	89 ec                	mov    %ebp,%esp
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    

00800e62 <sys_env_set_trapframe>:
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	83 ec 28             	sub    $0x28,%esp
  800e68:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800e6b:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800e6e:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800e71:	8b 55 08             	mov    0x8(%ebp),%edx
  800e74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e77:	b8 09 00 00 00       	mov    $0x9,%eax
  800e7c:	bf 00 00 00 00       	mov    $0x0,%edi
  800e81:	89 fb                	mov    %edi,%ebx
  800e83:	89 fe                	mov    %edi,%esi
  800e85:	cd 30                	int    $0x30
  800e87:	85 c0                	test   %eax,%eax
  800e89:	7e 28                	jle    800eb3 <sys_env_set_trapframe+0x51>
  800e8b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e8f:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e96:	00 
  800e97:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  800e9e:	00 
  800e9f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea6:	00 
  800ea7:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  800eae:	e8 25 10 00 00       	call   801ed8 <_panic>
  800eb3:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800eb6:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800eb9:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800ebc:	89 ec                	mov    %ebp,%esp
  800ebe:	5d                   	pop    %ebp
  800ebf:	c3                   	ret    

00800ec0 <sys_env_set_status>:
  800ec0:	55                   	push   %ebp
  800ec1:	89 e5                	mov    %esp,%ebp
  800ec3:	83 ec 28             	sub    $0x28,%esp
  800ec6:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800ec9:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800ecc:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800ecf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed5:	b8 08 00 00 00       	mov    $0x8,%eax
  800eda:	bf 00 00 00 00       	mov    $0x0,%edi
  800edf:	89 fb                	mov    %edi,%ebx
  800ee1:	89 fe                	mov    %edi,%esi
  800ee3:	cd 30                	int    $0x30
  800ee5:	85 c0                	test   %eax,%eax
  800ee7:	7e 28                	jle    800f11 <sys_env_set_status+0x51>
  800ee9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eed:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ef4:	00 
  800ef5:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  800efc:	00 
  800efd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f04:	00 
  800f05:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  800f0c:	e8 c7 0f 00 00       	call   801ed8 <_panic>
  800f11:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800f14:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800f17:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800f1a:	89 ec                	mov    %ebp,%esp
  800f1c:	5d                   	pop    %ebp
  800f1d:	c3                   	ret    

00800f1e <sys_page_unmap>:
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	83 ec 28             	sub    $0x28,%esp
  800f24:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800f27:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800f2a:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800f2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f33:	b8 06 00 00 00       	mov    $0x6,%eax
  800f38:	bf 00 00 00 00       	mov    $0x0,%edi
  800f3d:	89 fb                	mov    %edi,%ebx
  800f3f:	89 fe                	mov    %edi,%esi
  800f41:	cd 30                	int    $0x30
  800f43:	85 c0                	test   %eax,%eax
  800f45:	7e 28                	jle    800f6f <sys_page_unmap+0x51>
  800f47:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f4b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f52:	00 
  800f53:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  800f5a:	00 
  800f5b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f62:	00 
  800f63:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  800f6a:	e8 69 0f 00 00       	call   801ed8 <_panic>
  800f6f:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800f72:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800f75:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800f78:	89 ec                	mov    %ebp,%esp
  800f7a:	5d                   	pop    %ebp
  800f7b:	c3                   	ret    

00800f7c <sys_page_map>:
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	83 ec 28             	sub    $0x28,%esp
  800f82:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800f85:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800f88:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800f8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f94:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f97:	8b 75 18             	mov    0x18(%ebp),%esi
  800f9a:	b8 05 00 00 00       	mov    $0x5,%eax
  800f9f:	cd 30                	int    $0x30
  800fa1:	85 c0                	test   %eax,%eax
  800fa3:	7e 28                	jle    800fcd <sys_page_map+0x51>
  800fa5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fa9:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800fb0:	00 
  800fb1:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  800fb8:	00 
  800fb9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fc0:	00 
  800fc1:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  800fc8:	e8 0b 0f 00 00       	call   801ed8 <_panic>
  800fcd:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800fd0:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800fd3:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800fd6:	89 ec                	mov    %ebp,%esp
  800fd8:	5d                   	pop    %ebp
  800fd9:	c3                   	ret    

00800fda <sys_page_alloc>:
  800fda:	55                   	push   %ebp
  800fdb:	89 e5                	mov    %esp,%ebp
  800fdd:	83 ec 28             	sub    $0x28,%esp
  800fe0:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800fe3:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800fe6:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800fe9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ff2:	b8 04 00 00 00       	mov    $0x4,%eax
  800ff7:	bf 00 00 00 00       	mov    $0x0,%edi
  800ffc:	89 fe                	mov    %edi,%esi
  800ffe:	cd 30                	int    $0x30
  801000:	85 c0                	test   %eax,%eax
  801002:	7e 28                	jle    80102c <sys_page_alloc+0x52>
  801004:	89 44 24 10          	mov    %eax,0x10(%esp)
  801008:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80100f:	00 
  801010:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  801017:	00 
  801018:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80101f:	00 
  801020:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  801027:	e8 ac 0e 00 00       	call   801ed8 <_panic>
  80102c:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  80102f:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801032:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801035:	89 ec                	mov    %ebp,%esp
  801037:	5d                   	pop    %ebp
  801038:	c3                   	ret    

00801039 <sys_yield>:
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	83 ec 0c             	sub    $0xc,%esp
  80103f:	89 1c 24             	mov    %ebx,(%esp)
  801042:	89 74 24 04          	mov    %esi,0x4(%esp)
  801046:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80104a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80104f:	bf 00 00 00 00       	mov    $0x0,%edi
  801054:	89 fa                	mov    %edi,%edx
  801056:	89 f9                	mov    %edi,%ecx
  801058:	89 fb                	mov    %edi,%ebx
  80105a:	89 fe                	mov    %edi,%esi
  80105c:	cd 30                	int    $0x30
  80105e:	8b 1c 24             	mov    (%esp),%ebx
  801061:	8b 74 24 04          	mov    0x4(%esp),%esi
  801065:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801069:	89 ec                	mov    %ebp,%esp
  80106b:	5d                   	pop    %ebp
  80106c:	c3                   	ret    

0080106d <sys_getenvid>:
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
  801070:	83 ec 0c             	sub    $0xc,%esp
  801073:	89 1c 24             	mov    %ebx,(%esp)
  801076:	89 74 24 04          	mov    %esi,0x4(%esp)
  80107a:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80107e:	b8 02 00 00 00       	mov    $0x2,%eax
  801083:	bf 00 00 00 00       	mov    $0x0,%edi
  801088:	89 fa                	mov    %edi,%edx
  80108a:	89 f9                	mov    %edi,%ecx
  80108c:	89 fb                	mov    %edi,%ebx
  80108e:	89 fe                	mov    %edi,%esi
  801090:	cd 30                	int    $0x30
  801092:	8b 1c 24             	mov    (%esp),%ebx
  801095:	8b 74 24 04          	mov    0x4(%esp),%esi
  801099:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80109d:	89 ec                	mov    %ebp,%esp
  80109f:	5d                   	pop    %ebp
  8010a0:	c3                   	ret    

008010a1 <sys_env_destroy>:
  8010a1:	55                   	push   %ebp
  8010a2:	89 e5                	mov    %esp,%ebp
  8010a4:	83 ec 28             	sub    $0x28,%esp
  8010a7:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  8010aa:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  8010ad:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  8010b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b3:	b8 03 00 00 00       	mov    $0x3,%eax
  8010b8:	bf 00 00 00 00       	mov    $0x0,%edi
  8010bd:	89 f9                	mov    %edi,%ecx
  8010bf:	89 fb                	mov    %edi,%ebx
  8010c1:	89 fe                	mov    %edi,%esi
  8010c3:	cd 30                	int    $0x30
  8010c5:	85 c0                	test   %eax,%eax
  8010c7:	7e 28                	jle    8010f1 <sys_env_destroy+0x50>
  8010c9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010cd:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8010d4:	00 
  8010d5:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  8010dc:	00 
  8010dd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010e4:	00 
  8010e5:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  8010ec:	e8 e7 0d 00 00       	call   801ed8 <_panic>
  8010f1:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  8010f4:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  8010f7:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  8010fa:	89 ec                	mov    %ebp,%esp
  8010fc:	5d                   	pop    %ebp
  8010fd:	c3                   	ret    
	...

00801100 <fd2num>:
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	8b 45 08             	mov    0x8(%ebp),%eax
  801106:	05 00 00 00 30       	add    $0x30000000,%eax
  80110b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80110e:	5d                   	pop    %ebp
  80110f:	c3                   	ret    

00801110 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801116:	8b 45 08             	mov    0x8(%ebp),%eax
  801119:	89 04 24             	mov    %eax,(%esp)
  80111c:	e8 df ff ff ff       	call   801100 <fd2num>
  801121:	c1 e0 0c             	shl    $0xc,%eax
  801124:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801129:	c9                   	leave  
  80112a:	c3                   	ret    

0080112b <fd_alloc>:

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
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
  80112e:	53                   	push   %ebx
  80112f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801132:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  801137:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801139:	89 d0                	mov    %edx,%eax
  80113b:	c1 e8 16             	shr    $0x16,%eax
  80113e:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  801145:	a8 01                	test   $0x1,%al
  801147:	74 10                	je     801159 <fd_alloc+0x2e>
  801149:	89 d0                	mov    %edx,%eax
  80114b:	c1 e8 0c             	shr    $0xc,%eax
  80114e:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  801155:	a8 01                	test   $0x1,%al
  801157:	75 09                	jne    801162 <fd_alloc+0x37>
			*fd_store = fd;
  801159:	89 0b                	mov    %ecx,(%ebx)
  80115b:	b8 00 00 00 00       	mov    $0x0,%eax
  801160:	eb 19                	jmp    80117b <fd_alloc+0x50>
			return 0;
  801162:	81 c2 00 10 00 00    	add    $0x1000,%edx
  801168:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  80116e:	75 c7                	jne    801137 <fd_alloc+0xc>
		}
	}
	*fd_store = 0;
  801170:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801176:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  80117b:	5b                   	pop    %ebx
  80117c:	5d                   	pop    %ebp
  80117d:	c3                   	ret    

0080117e <fd_lookup>:

// Check that fdnum is in range and mapped.
// If it is, set *fd_store to the fd page virtual address.
//
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
  801181:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801184:	83 f8 1f             	cmp    $0x1f,%eax
  801187:	77 35                	ja     8011be <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801189:	c1 e0 0c             	shl    $0xc,%eax
  80118c:	8d 90 00 00 00 d0    	lea    0xd0000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  801192:	89 d0                	mov    %edx,%eax
  801194:	c1 e8 16             	shr    $0x16,%eax
  801197:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  80119e:	a8 01                	test   $0x1,%al
  8011a0:	74 1c                	je     8011be <fd_lookup+0x40>
  8011a2:	89 d0                	mov    %edx,%eax
  8011a4:	c1 e8 0c             	shr    $0xc,%eax
  8011a7:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  8011ae:	a8 01                	test   $0x1,%al
  8011b0:	74 0c                	je     8011be <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011b5:	89 10                	mov    %edx,(%eax)
  8011b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011bc:	eb 05                	jmp    8011c3 <fd_lookup+0x45>
	return 0;
  8011be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011c3:	5d                   	pop    %ebp
  8011c4:	c3                   	ret    

008011c5 <seek>:

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
  8011c5:	55                   	push   %ebp
  8011c6:	89 e5                	mov    %esp,%ebp
  8011c8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011cb:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  8011ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d5:	89 04 24             	mov    %eax,(%esp)
  8011d8:	e8 a1 ff ff ff       	call   80117e <fd_lookup>
  8011dd:	85 c0                	test   %eax,%eax
  8011df:	78 0e                	js     8011ef <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8011e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e4:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  8011e7:	89 50 04             	mov    %edx,0x4(%eax)
  8011ea:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8011ef:	c9                   	leave  
  8011f0:	c3                   	ret    

008011f1 <dev_lookup>:
  8011f1:	55                   	push   %ebp
  8011f2:	89 e5                	mov    %esp,%ebp
  8011f4:	53                   	push   %ebx
  8011f5:	83 ec 14             	sub    $0x14,%esp
  8011f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011fe:	ba 74 77 80 00       	mov    $0x807774,%edx
  801203:	b8 00 00 00 00       	mov    $0x0,%eax
  801208:	39 0d 74 77 80 00    	cmp    %ecx,0x807774
  80120e:	75 12                	jne    801222 <dev_lookup+0x31>
  801210:	eb 04                	jmp    801216 <dev_lookup+0x25>
  801212:	39 0a                	cmp    %ecx,(%edx)
  801214:	75 0c                	jne    801222 <dev_lookup+0x31>
  801216:	89 13                	mov    %edx,(%ebx)
  801218:	b8 00 00 00 00       	mov    $0x0,%eax
  80121d:	8d 76 00             	lea    0x0(%esi),%esi
  801220:	eb 35                	jmp    801257 <dev_lookup+0x66>
  801222:	83 c0 01             	add    $0x1,%eax
  801225:	8b 14 85 4c 28 80 00 	mov    0x80284c(,%eax,4),%edx
  80122c:	85 d2                	test   %edx,%edx
  80122e:	75 e2                	jne    801212 <dev_lookup+0x21>
  801230:	a1 30 8f 80 00       	mov    0x808f30,%eax
  801235:	8b 40 4c             	mov    0x4c(%eax),%eax
  801238:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80123c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801240:	c7 04 24 cc 27 80 00 	movl   $0x8027cc,(%esp)
  801247:	e8 d9 ef ff ff       	call   800225 <cprintf>
  80124c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801252:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801257:	83 c4 14             	add    $0x14,%esp
  80125a:	5b                   	pop    %ebx
  80125b:	5d                   	pop    %ebp
  80125c:	c3                   	ret    

0080125d <fstat>:

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
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	53                   	push   %ebx
  801261:	83 ec 24             	sub    $0x24,%esp
  801264:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801267:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80126a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80126e:	8b 45 08             	mov    0x8(%ebp),%eax
  801271:	89 04 24             	mov    %eax,(%esp)
  801274:	e8 05 ff ff ff       	call   80117e <fd_lookup>
  801279:	89 c2                	mov    %eax,%edx
  80127b:	85 c0                	test   %eax,%eax
  80127d:	78 57                	js     8012d6 <fstat+0x79>
  80127f:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801282:	89 44 24 04          	mov    %eax,0x4(%esp)
  801286:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801289:	8b 00                	mov    (%eax),%eax
  80128b:	89 04 24             	mov    %eax,(%esp)
  80128e:	e8 5e ff ff ff       	call   8011f1 <dev_lookup>
  801293:	89 c2                	mov    %eax,%edx
  801295:	85 c0                	test   %eax,%eax
  801297:	78 3d                	js     8012d6 <fstat+0x79>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801299:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  80129e:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
  8012a1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012a5:	74 2f                	je     8012d6 <fstat+0x79>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012a7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012aa:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012b1:	00 00 00 
	stat->st_isdir = 0;
  8012b4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012bb:	00 00 00 
	stat->st_dev = dev;
  8012be:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  8012c1:	89 93 88 00 00 00    	mov    %edx,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012cb:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8012ce:	89 04 24             	mov    %eax,(%esp)
  8012d1:	ff 52 14             	call   *0x14(%edx)
  8012d4:	89 c2                	mov    %eax,%edx
}
  8012d6:	89 d0                	mov    %edx,%eax
  8012d8:	83 c4 24             	add    $0x24,%esp
  8012db:	5b                   	pop    %ebx
  8012dc:	5d                   	pop    %ebp
  8012dd:	c3                   	ret    

008012de <ftruncate>:
  8012de:	55                   	push   %ebp
  8012df:	89 e5                	mov    %esp,%ebp
  8012e1:	53                   	push   %ebx
  8012e2:	83 ec 24             	sub    $0x24,%esp
  8012e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012e8:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8012eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ef:	89 1c 24             	mov    %ebx,(%esp)
  8012f2:	e8 87 fe ff ff       	call   80117e <fd_lookup>
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	78 61                	js     80135c <ftruncate+0x7e>
  8012fb:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8012fe:	8b 10                	mov    (%eax),%edx
  801300:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801303:	89 44 24 04          	mov    %eax,0x4(%esp)
  801307:	89 14 24             	mov    %edx,(%esp)
  80130a:	e8 e2 fe ff ff       	call   8011f1 <dev_lookup>
  80130f:	85 c0                	test   %eax,%eax
  801311:	78 49                	js     80135c <ftruncate+0x7e>
  801313:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  801316:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  80131a:	75 23                	jne    80133f <ftruncate+0x61>
  80131c:	a1 30 8f 80 00       	mov    0x808f30,%eax
  801321:	8b 40 4c             	mov    0x4c(%eax),%eax
  801324:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801328:	89 44 24 04          	mov    %eax,0x4(%esp)
  80132c:	c7 04 24 ec 27 80 00 	movl   $0x8027ec,(%esp)
  801333:	e8 ed ee ff ff       	call   800225 <cprintf>
  801338:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80133d:	eb 1d                	jmp    80135c <ftruncate+0x7e>
  80133f:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801342:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801347:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  80134b:	74 0f                	je     80135c <ftruncate+0x7e>
  80134d:	8b 52 18             	mov    0x18(%edx),%edx
  801350:	8b 45 0c             	mov    0xc(%ebp),%eax
  801353:	89 44 24 04          	mov    %eax,0x4(%esp)
  801357:	89 0c 24             	mov    %ecx,(%esp)
  80135a:	ff d2                	call   *%edx
  80135c:	83 c4 24             	add    $0x24,%esp
  80135f:	5b                   	pop    %ebx
  801360:	5d                   	pop    %ebp
  801361:	c3                   	ret    

00801362 <write>:
  801362:	55                   	push   %ebp
  801363:	89 e5                	mov    %esp,%ebp
  801365:	53                   	push   %ebx
  801366:	83 ec 24             	sub    $0x24,%esp
  801369:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80136c:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80136f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801373:	89 1c 24             	mov    %ebx,(%esp)
  801376:	e8 03 fe ff ff       	call   80117e <fd_lookup>
  80137b:	85 c0                	test   %eax,%eax
  80137d:	78 68                	js     8013e7 <write+0x85>
  80137f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801382:	8b 10                	mov    (%eax),%edx
  801384:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801387:	89 44 24 04          	mov    %eax,0x4(%esp)
  80138b:	89 14 24             	mov    %edx,(%esp)
  80138e:	e8 5e fe ff ff       	call   8011f1 <dev_lookup>
  801393:	85 c0                	test   %eax,%eax
  801395:	78 50                	js     8013e7 <write+0x85>
  801397:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  80139a:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  80139e:	75 23                	jne    8013c3 <write+0x61>
  8013a0:	a1 30 8f 80 00       	mov    0x808f30,%eax
  8013a5:	8b 40 4c             	mov    0x4c(%eax),%eax
  8013a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b0:	c7 04 24 10 28 80 00 	movl   $0x802810,(%esp)
  8013b7:	e8 69 ee ff ff       	call   800225 <cprintf>
  8013bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013c1:	eb 24                	jmp    8013e7 <write+0x85>
  8013c3:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  8013c6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013cb:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  8013cf:	74 16                	je     8013e7 <write+0x85>
  8013d1:	8b 42 0c             	mov    0xc(%edx),%eax
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

008013ed <read>:
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
  8013f0:	53                   	push   %ebx
  8013f1:	83 ec 24             	sub    $0x24,%esp
  8013f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8013f7:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8013fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013fe:	89 1c 24             	mov    %ebx,(%esp)
  801401:	e8 78 fd ff ff       	call   80117e <fd_lookup>
  801406:	85 c0                	test   %eax,%eax
  801408:	78 6d                	js     801477 <read+0x8a>
  80140a:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80140d:	8b 10                	mov    (%eax),%edx
  80140f:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801412:	89 44 24 04          	mov    %eax,0x4(%esp)
  801416:	89 14 24             	mov    %edx,(%esp)
  801419:	e8 d3 fd ff ff       	call   8011f1 <dev_lookup>
  80141e:	85 c0                	test   %eax,%eax
  801420:	78 55                	js     801477 <read+0x8a>
  801422:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  801425:	8b 41 08             	mov    0x8(%ecx),%eax
  801428:	83 e0 03             	and    $0x3,%eax
  80142b:	83 f8 01             	cmp    $0x1,%eax
  80142e:	75 23                	jne    801453 <read+0x66>
  801430:	a1 30 8f 80 00       	mov    0x808f30,%eax
  801435:	8b 40 4c             	mov    0x4c(%eax),%eax
  801438:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80143c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801440:	c7 04 24 2d 28 80 00 	movl   $0x80282d,(%esp)
  801447:	e8 d9 ed ff ff       	call   800225 <cprintf>
  80144c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801451:	eb 24                	jmp    801477 <read+0x8a>
  801453:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801456:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80145b:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  80145f:	74 16                	je     801477 <read+0x8a>
  801461:	8b 42 08             	mov    0x8(%edx),%eax
  801464:	8b 55 10             	mov    0x10(%ebp),%edx
  801467:	89 54 24 08          	mov    %edx,0x8(%esp)
  80146b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80146e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801472:	89 0c 24             	mov    %ecx,(%esp)
  801475:	ff d0                	call   *%eax
  801477:	83 c4 24             	add    $0x24,%esp
  80147a:	5b                   	pop    %ebx
  80147b:	5d                   	pop    %ebp
  80147c:	c3                   	ret    

0080147d <readn>:
  80147d:	55                   	push   %ebp
  80147e:	89 e5                	mov    %esp,%ebp
  801480:	57                   	push   %edi
  801481:	56                   	push   %esi
  801482:	53                   	push   %ebx
  801483:	83 ec 0c             	sub    $0xc,%esp
  801486:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801489:	8b 75 10             	mov    0x10(%ebp),%esi
  80148c:	b8 00 00 00 00       	mov    $0x0,%eax
  801491:	85 f6                	test   %esi,%esi
  801493:	74 36                	je     8014cb <readn+0x4e>
  801495:	bb 00 00 00 00       	mov    $0x0,%ebx
  80149a:	ba 00 00 00 00       	mov    $0x0,%edx
  80149f:	89 f0                	mov    %esi,%eax
  8014a1:	29 d0                	sub    %edx,%eax
  8014a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014a7:	8d 04 17             	lea    (%edi,%edx,1),%eax
  8014aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b1:	89 04 24             	mov    %eax,(%esp)
  8014b4:	e8 34 ff ff ff       	call   8013ed <read>
  8014b9:	85 c0                	test   %eax,%eax
  8014bb:	78 0e                	js     8014cb <readn+0x4e>
  8014bd:	85 c0                	test   %eax,%eax
  8014bf:	74 08                	je     8014c9 <readn+0x4c>
  8014c1:	01 c3                	add    %eax,%ebx
  8014c3:	89 da                	mov    %ebx,%edx
  8014c5:	39 f3                	cmp    %esi,%ebx
  8014c7:	72 d6                	jb     80149f <readn+0x22>
  8014c9:	89 d8                	mov    %ebx,%eax
  8014cb:	83 c4 0c             	add    $0xc,%esp
  8014ce:	5b                   	pop    %ebx
  8014cf:	5e                   	pop    %esi
  8014d0:	5f                   	pop    %edi
  8014d1:	5d                   	pop    %ebp
  8014d2:	c3                   	ret    

008014d3 <fd_close>:
  8014d3:	55                   	push   %ebp
  8014d4:	89 e5                	mov    %esp,%ebp
  8014d6:	83 ec 28             	sub    $0x28,%esp
  8014d9:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  8014dc:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  8014df:	8b 75 08             	mov    0x8(%ebp),%esi
  8014e2:	89 34 24             	mov    %esi,(%esp)
  8014e5:	e8 16 fc ff ff       	call   801100 <fd2num>
  8014ea:	8d 55 f4             	lea    0xfffffff4(%ebp),%edx
  8014ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014f1:	89 04 24             	mov    %eax,(%esp)
  8014f4:	e8 85 fc ff ff       	call   80117e <fd_lookup>
  8014f9:	89 c3                	mov    %eax,%ebx
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	78 05                	js     801504 <fd_close+0x31>
  8014ff:	3b 75 f4             	cmp    0xfffffff4(%ebp),%esi
  801502:	74 0e                	je     801512 <fd_close+0x3f>
  801504:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801508:	75 45                	jne    80154f <fd_close+0x7c>
  80150a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80150f:	90                   	nop    
  801510:	eb 3d                	jmp    80154f <fd_close+0x7c>
  801512:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  801515:	89 44 24 04          	mov    %eax,0x4(%esp)
  801519:	8b 06                	mov    (%esi),%eax
  80151b:	89 04 24             	mov    %eax,(%esp)
  80151e:	e8 ce fc ff ff       	call   8011f1 <dev_lookup>
  801523:	89 c3                	mov    %eax,%ebx
  801525:	85 c0                	test   %eax,%eax
  801527:	78 16                	js     80153f <fd_close+0x6c>
  801529:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80152c:	8b 40 10             	mov    0x10(%eax),%eax
  80152f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801534:	85 c0                	test   %eax,%eax
  801536:	74 07                	je     80153f <fd_close+0x6c>
  801538:	89 34 24             	mov    %esi,(%esp)
  80153b:	ff d0                	call   *%eax
  80153d:	89 c3                	mov    %eax,%ebx
  80153f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801543:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80154a:	e8 cf f9 ff ff       	call   800f1e <sys_page_unmap>
  80154f:	89 d8                	mov    %ebx,%eax
  801551:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  801554:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  801557:	89 ec                	mov    %ebp,%esp
  801559:	5d                   	pop    %ebp
  80155a:	c3                   	ret    

0080155b <close>:
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	83 ec 18             	sub    $0x18,%esp
  801561:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  801564:	89 44 24 04          	mov    %eax,0x4(%esp)
  801568:	8b 45 08             	mov    0x8(%ebp),%eax
  80156b:	89 04 24             	mov    %eax,(%esp)
  80156e:	e8 0b fc ff ff       	call   80117e <fd_lookup>
  801573:	85 c0                	test   %eax,%eax
  801575:	78 13                	js     80158a <close+0x2f>
  801577:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80157e:	00 
  80157f:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  801582:	89 04 24             	mov    %eax,(%esp)
  801585:	e8 49 ff ff ff       	call   8014d3 <fd_close>
  80158a:	c9                   	leave  
  80158b:	c3                   	ret    

0080158c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	83 ec 18             	sub    $0x18,%esp
  801592:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  801595:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801598:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80159f:	00 
  8015a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a3:	89 04 24             	mov    %eax,(%esp)
  8015a6:	e8 58 03 00 00       	call   801903 <open>
  8015ab:	89 c6                	mov    %eax,%esi
  8015ad:	85 c0                	test   %eax,%eax
  8015af:	78 1b                	js     8015cc <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8015b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b8:	89 34 24             	mov    %esi,(%esp)
  8015bb:	e8 9d fc ff ff       	call   80125d <fstat>
  8015c0:	89 c3                	mov    %eax,%ebx
	close(fd);
  8015c2:	89 34 24             	mov    %esi,(%esp)
  8015c5:	e8 91 ff ff ff       	call   80155b <close>
  8015ca:	89 de                	mov    %ebx,%esi
	return r;
}
  8015cc:	89 f0                	mov    %esi,%eax
  8015ce:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  8015d1:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  8015d4:	89 ec                	mov    %ebp,%esp
  8015d6:	5d                   	pop    %ebp
  8015d7:	c3                   	ret    

008015d8 <dup>:
  8015d8:	55                   	push   %ebp
  8015d9:	89 e5                	mov    %esp,%ebp
  8015db:	83 ec 38             	sub    $0x38,%esp
  8015de:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  8015e1:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  8015e4:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  8015e7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8015ea:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  8015ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f4:	89 04 24             	mov    %eax,(%esp)
  8015f7:	e8 82 fb ff ff       	call   80117e <fd_lookup>
  8015fc:	89 c3                	mov    %eax,%ebx
  8015fe:	85 c0                	test   %eax,%eax
  801600:	0f 88 e1 00 00 00    	js     8016e7 <dup+0x10f>
  801606:	89 3c 24             	mov    %edi,(%esp)
  801609:	e8 4d ff ff ff       	call   80155b <close>
  80160e:	89 f8                	mov    %edi,%eax
  801610:	c1 e0 0c             	shl    $0xc,%eax
  801613:	8d b0 00 00 00 d0    	lea    0xd0000000(%eax),%esi
  801619:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80161c:	89 04 24             	mov    %eax,(%esp)
  80161f:	e8 ec fa ff ff       	call   801110 <fd2data>
  801624:	89 c3                	mov    %eax,%ebx
  801626:	89 34 24             	mov    %esi,(%esp)
  801629:	e8 e2 fa ff ff       	call   801110 <fd2data>
  80162e:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  801631:	89 d8                	mov    %ebx,%eax
  801633:	c1 e8 16             	shr    $0x16,%eax
  801636:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  80163d:	a8 01                	test   $0x1,%al
  80163f:	74 45                	je     801686 <dup+0xae>
  801641:	89 da                	mov    %ebx,%edx
  801643:	c1 ea 0c             	shr    $0xc,%edx
  801646:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  80164d:	a8 01                	test   $0x1,%al
  80164f:	74 35                	je     801686 <dup+0xae>
  801651:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  801658:	25 07 0e 00 00       	and    $0xe07,%eax
  80165d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801661:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  801664:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801668:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80166f:	00 
  801670:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801674:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80167b:	e8 fc f8 ff ff       	call   800f7c <sys_page_map>
  801680:	89 c3                	mov    %eax,%ebx
  801682:	85 c0                	test   %eax,%eax
  801684:	78 3e                	js     8016c4 <dup+0xec>
  801686:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  801689:	89 d0                	mov    %edx,%eax
  80168b:	c1 e8 0c             	shr    $0xc,%eax
  80168e:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  801695:	25 07 0e 00 00       	and    $0xe07,%eax
  80169a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80169e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8016a2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016a9:	00 
  8016aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8016ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016b5:	e8 c2 f8 ff ff       	call   800f7c <sys_page_map>
  8016ba:	89 c3                	mov    %eax,%ebx
  8016bc:	85 c0                	test   %eax,%eax
  8016be:	78 04                	js     8016c4 <dup+0xec>
  8016c0:	89 fb                	mov    %edi,%ebx
  8016c2:	eb 23                	jmp    8016e7 <dup+0x10f>
  8016c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016cf:	e8 4a f8 ff ff       	call   800f1e <sys_page_unmap>
  8016d4:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  8016d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016e2:	e8 37 f8 ff ff       	call   800f1e <sys_page_unmap>
  8016e7:	89 d8                	mov    %ebx,%eax
  8016e9:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  8016ec:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  8016ef:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  8016f2:	89 ec                	mov    %ebp,%esp
  8016f4:	5d                   	pop    %ebp
  8016f5:	c3                   	ret    

008016f6 <close_all>:
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	53                   	push   %ebx
  8016fa:	83 ec 04             	sub    $0x4,%esp
  8016fd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801702:	89 1c 24             	mov    %ebx,(%esp)
  801705:	e8 51 fe ff ff       	call   80155b <close>
  80170a:	83 c3 01             	add    $0x1,%ebx
  80170d:	83 fb 20             	cmp    $0x20,%ebx
  801710:	75 f0                	jne    801702 <close_all+0xc>
  801712:	83 c4 04             	add    $0x4,%esp
  801715:	5b                   	pop    %ebx
  801716:	5d                   	pop    %ebp
  801717:	c3                   	ret    

00801718 <fsipc>:
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	53                   	push   %ebx
  80171c:	83 ec 14             	sub    $0x14,%esp
  80171f:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801721:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  801727:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80172e:	00 
  80172f:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801736:	00 
  801737:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173b:	89 14 24             	mov    %edx,(%esp)
  80173e:	e8 0d 08 00 00       	call   801f50 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801743:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80174a:	00 
  80174b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80174f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801756:	e8 a9 08 00 00       	call   802004 <ipc_recv>
}
  80175b:	83 c4 14             	add    $0x14,%esp
  80175e:	5b                   	pop    %ebx
  80175f:	5d                   	pop    %ebp
  801760:	c3                   	ret    

00801761 <sync>:

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
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801767:	ba 00 00 00 00       	mov    $0x0,%edx
  80176c:	b8 08 00 00 00       	mov    $0x8,%eax
  801771:	e8 a2 ff ff ff       	call   801718 <fsipc>
}
  801776:	c9                   	leave  
  801777:	c3                   	ret    

00801778 <devfile_trunc>:
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	83 ec 08             	sub    $0x8,%esp
  80177e:	8b 45 08             	mov    0x8(%ebp),%eax
  801781:	8b 40 0c             	mov    0xc(%eax),%eax
  801784:	a3 00 30 80 00       	mov    %eax,0x803000
  801789:	8b 45 0c             	mov    0xc(%ebp),%eax
  80178c:	a3 04 30 80 00       	mov    %eax,0x803004
  801791:	ba 00 00 00 00       	mov    $0x0,%edx
  801796:	b8 02 00 00 00       	mov    $0x2,%eax
  80179b:	e8 78 ff ff ff       	call   801718 <fsipc>
  8017a0:	c9                   	leave  
  8017a1:	c3                   	ret    

008017a2 <devfile_flush>:
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	83 ec 08             	sub    $0x8,%esp
  8017a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ae:	a3 00 30 80 00       	mov    %eax,0x803000
  8017b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b8:	b8 06 00 00 00       	mov    $0x6,%eax
  8017bd:	e8 56 ff ff ff       	call   801718 <fsipc>
  8017c2:	c9                   	leave  
  8017c3:	c3                   	ret    

008017c4 <devfile_stat>:
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	53                   	push   %ebx
  8017c8:	83 ec 14             	sub    $0x14,%esp
  8017cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d4:	a3 00 30 80 00       	mov    %eax,0x803000
  8017d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017de:	b8 05 00 00 00       	mov    $0x5,%eax
  8017e3:	e8 30 ff ff ff       	call   801718 <fsipc>
  8017e8:	85 c0                	test   %eax,%eax
  8017ea:	78 2b                	js     801817 <devfile_stat+0x53>
  8017ec:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  8017f3:	00 
  8017f4:	89 1c 24             	mov    %ebx,(%esp)
  8017f7:	e8 b5 f0 ff ff       	call   8008b1 <strcpy>
  8017fc:	a1 80 30 80 00       	mov    0x803080,%eax
  801801:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  801807:	a1 84 30 80 00       	mov    0x803084,%eax
  80180c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801812:	b8 00 00 00 00       	mov    $0x0,%eax
  801817:	83 c4 14             	add    $0x14,%esp
  80181a:	5b                   	pop    %ebx
  80181b:	5d                   	pop    %ebp
  80181c:	c3                   	ret    

0080181d <devfile_write>:
  80181d:	55                   	push   %ebp
  80181e:	89 e5                	mov    %esp,%ebp
  801820:	83 ec 18             	sub    $0x18,%esp
  801823:	8b 55 10             	mov    0x10(%ebp),%edx
  801826:	8b 45 08             	mov    0x8(%ebp),%eax
  801829:	8b 40 0c             	mov    0xc(%eax),%eax
  80182c:	a3 00 30 80 00       	mov    %eax,0x803000
  801831:	89 d0                	mov    %edx,%eax
  801833:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  801839:	76 05                	jbe    801840 <devfile_write+0x23>
  80183b:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801840:	89 15 04 30 80 00    	mov    %edx,0x803004
  801846:	89 44 24 08          	mov    %eax,0x8(%esp)
  80184a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801851:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  801858:	e8 5d f2 ff ff       	call   800aba <memmove>
  80185d:	ba 00 00 00 00       	mov    $0x0,%edx
  801862:	b8 04 00 00 00       	mov    $0x4,%eax
  801867:	e8 ac fe ff ff       	call   801718 <fsipc>
  80186c:	c9                   	leave  
  80186d:	c3                   	ret    

0080186e <devfile_read>:
  80186e:	55                   	push   %ebp
  80186f:	89 e5                	mov    %esp,%ebp
  801871:	53                   	push   %ebx
  801872:	83 ec 14             	sub    $0x14,%esp
  801875:	8b 45 08             	mov    0x8(%ebp),%eax
  801878:	8b 40 0c             	mov    0xc(%eax),%eax
  80187b:	a3 00 30 80 00       	mov    %eax,0x803000
  801880:	8b 45 10             	mov    0x10(%ebp),%eax
  801883:	a3 04 30 80 00       	mov    %eax,0x803004
  801888:	ba 00 30 80 00       	mov    $0x803000,%edx
  80188d:	b8 03 00 00 00       	mov    $0x3,%eax
  801892:	e8 81 fe ff ff       	call   801718 <fsipc>
  801897:	89 c3                	mov    %eax,%ebx
  801899:	85 c0                	test   %eax,%eax
  80189b:	7e 17                	jle    8018b4 <devfile_read+0x46>
  80189d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018a1:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  8018a8:	00 
  8018a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ac:	89 04 24             	mov    %eax,(%esp)
  8018af:	e8 06 f2 ff ff       	call   800aba <memmove>
  8018b4:	89 d8                	mov    %ebx,%eax
  8018b6:	83 c4 14             	add    $0x14,%esp
  8018b9:	5b                   	pop    %ebx
  8018ba:	5d                   	pop    %ebp
  8018bb:	c3                   	ret    

008018bc <remove>:
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	53                   	push   %ebx
  8018c0:	83 ec 14             	sub    $0x14,%esp
  8018c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8018c6:	89 1c 24             	mov    %ebx,(%esp)
  8018c9:	e8 92 ef ff ff       	call   800860 <strlen>
  8018ce:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  8018d3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018d8:	7f 21                	jg     8018fb <remove+0x3f>
  8018da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018de:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  8018e5:	e8 c7 ef ff ff       	call   8008b1 <strcpy>
  8018ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ef:	b8 07 00 00 00       	mov    $0x7,%eax
  8018f4:	e8 1f fe ff ff       	call   801718 <fsipc>
  8018f9:	89 c2                	mov    %eax,%edx
  8018fb:	89 d0                	mov    %edx,%eax
  8018fd:	83 c4 14             	add    $0x14,%esp
  801900:	5b                   	pop    %ebx
  801901:	5d                   	pop    %ebp
  801902:	c3                   	ret    

00801903 <open>:
  801903:	55                   	push   %ebp
  801904:	89 e5                	mov    %esp,%ebp
  801906:	56                   	push   %esi
  801907:	53                   	push   %ebx
  801908:	83 ec 30             	sub    $0x30,%esp
  80190b:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80190e:	89 04 24             	mov    %eax,(%esp)
  801911:	e8 15 f8 ff ff       	call   80112b <fd_alloc>
  801916:	89 c3                	mov    %eax,%ebx
  801918:	85 c0                	test   %eax,%eax
  80191a:	79 18                	jns    801934 <open+0x31>
  80191c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801923:	00 
  801924:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801927:	89 04 24             	mov    %eax,(%esp)
  80192a:	e8 a4 fb ff ff       	call   8014d3 <fd_close>
  80192f:	e9 9f 00 00 00       	jmp    8019d3 <open+0xd0>
  801934:	8b 45 08             	mov    0x8(%ebp),%eax
  801937:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193b:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801942:	e8 6a ef ff ff       	call   8008b1 <strcpy>
  801947:	8b 45 0c             	mov    0xc(%ebp),%eax
  80194a:	a3 00 34 80 00       	mov    %eax,0x803400
  80194f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801952:	89 04 24             	mov    %eax,(%esp)
  801955:	e8 b6 f7 ff ff       	call   801110 <fd2data>
  80195a:	89 c6                	mov    %eax,%esi
  80195c:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  80195f:	b8 01 00 00 00       	mov    $0x1,%eax
  801964:	e8 af fd ff ff       	call   801718 <fsipc>
  801969:	89 c3                	mov    %eax,%ebx
  80196b:	85 c0                	test   %eax,%eax
  80196d:	79 15                	jns    801984 <open+0x81>
  80196f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801976:	00 
  801977:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80197a:	89 04 24             	mov    %eax,(%esp)
  80197d:	e8 51 fb ff ff       	call   8014d3 <fd_close>
  801982:	eb 4f                	jmp    8019d3 <open+0xd0>
  801984:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80198b:	00 
  80198c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801990:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801997:	00 
  801998:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80199b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019a6:	e8 d1 f5 ff ff       	call   800f7c <sys_page_map>
  8019ab:	89 c3                	mov    %eax,%ebx
  8019ad:	85 c0                	test   %eax,%eax
  8019af:	79 15                	jns    8019c6 <open+0xc3>
  8019b1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8019b8:	00 
  8019b9:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8019bc:	89 04 24             	mov    %eax,(%esp)
  8019bf:	e8 0f fb ff ff       	call   8014d3 <fd_close>
  8019c4:	eb 0d                	jmp    8019d3 <open+0xd0>
  8019c6:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8019c9:	89 04 24             	mov    %eax,(%esp)
  8019cc:	e8 2f f7 ff ff       	call   801100 <fd2num>
  8019d1:	89 c3                	mov    %eax,%ebx
  8019d3:	89 d8                	mov    %ebx,%eax
  8019d5:	83 c4 30             	add    $0x30,%esp
  8019d8:	5b                   	pop    %ebx
  8019d9:	5e                   	pop    %esi
  8019da:	5d                   	pop    %ebp
  8019db:	c3                   	ret    
  8019dc:	00 00                	add    %al,(%eax)
	...

008019e0 <devsock_stat>:
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
  8019e3:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  8019e6:	c7 44 24 04 58 28 80 	movl   $0x802858,0x4(%esp)
  8019ed:	00 
  8019ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f1:	89 04 24             	mov    %eax,(%esp)
  8019f4:	e8 b8 ee ff ff       	call   8008b1 <strcpy>
	return 0;
}
  8019f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8019fe:	c9                   	leave  
  8019ff:	c3                   	ret    

00801a00 <devsock_close>:
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	83 ec 08             	sub    $0x8,%esp
  801a06:	8b 45 08             	mov    0x8(%ebp),%eax
  801a09:	8b 40 0c             	mov    0xc(%eax),%eax
  801a0c:	89 04 24             	mov    %eax,(%esp)
  801a0f:	e8 be 02 00 00       	call   801cd2 <nsipc_close>
  801a14:	c9                   	leave  
  801a15:	c3                   	ret    

00801a16 <devsock_write>:
  801a16:	55                   	push   %ebp
  801a17:	89 e5                	mov    %esp,%ebp
  801a19:	83 ec 18             	sub    $0x18,%esp
  801a1c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801a23:	00 
  801a24:	8b 45 10             	mov    0x10(%ebp),%eax
  801a27:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a32:	8b 45 08             	mov    0x8(%ebp),%eax
  801a35:	8b 40 0c             	mov    0xc(%eax),%eax
  801a38:	89 04 24             	mov    %eax,(%esp)
  801a3b:	e8 ce 02 00 00       	call   801d0e <nsipc_send>
  801a40:	c9                   	leave  
  801a41:	c3                   	ret    

00801a42 <devsock_read>:
  801a42:	55                   	push   %ebp
  801a43:	89 e5                	mov    %esp,%ebp
  801a45:	83 ec 18             	sub    $0x18,%esp
  801a48:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801a4f:	00 
  801a50:	8b 45 10             	mov    0x10(%ebp),%eax
  801a53:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a57:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a61:	8b 40 0c             	mov    0xc(%eax),%eax
  801a64:	89 04 24             	mov    %eax,(%esp)
  801a67:	e8 15 03 00 00       	call   801d81 <nsipc_recv>
  801a6c:	c9                   	leave  
  801a6d:	c3                   	ret    

00801a6e <alloc_sockfd>:
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	56                   	push   %esi
  801a72:	53                   	push   %ebx
  801a73:	83 ec 20             	sub    $0x20,%esp
  801a76:	89 c6                	mov    %eax,%esi
  801a78:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  801a7b:	89 04 24             	mov    %eax,(%esp)
  801a7e:	e8 a8 f6 ff ff       	call   80112b <fd_alloc>
  801a83:	89 c3                	mov    %eax,%ebx
  801a85:	85 c0                	test   %eax,%eax
  801a87:	78 21                	js     801aaa <alloc_sockfd+0x3c>
  801a89:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801a90:	00 
  801a91:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801a94:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a98:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a9f:	e8 36 f5 ff ff       	call   800fda <sys_page_alloc>
  801aa4:	89 c3                	mov    %eax,%ebx
  801aa6:	85 c0                	test   %eax,%eax
  801aa8:	79 0a                	jns    801ab4 <alloc_sockfd+0x46>
  801aaa:	89 34 24             	mov    %esi,(%esp)
  801aad:	e8 20 02 00 00       	call   801cd2 <nsipc_close>
  801ab2:	eb 28                	jmp    801adc <alloc_sockfd+0x6e>
  801ab4:	8b 15 90 77 80 00    	mov    0x807790,%edx
  801aba:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801abd:	89 10                	mov    %edx,(%eax)
  801abf:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801ac2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
  801ac9:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801acc:	89 70 0c             	mov    %esi,0xc(%eax)
  801acf:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801ad2:	89 04 24             	mov    %eax,(%esp)
  801ad5:	e8 26 f6 ff ff       	call   801100 <fd2num>
  801ada:	89 c3                	mov    %eax,%ebx
  801adc:	89 d8                	mov    %ebx,%eax
  801ade:	83 c4 20             	add    $0x20,%esp
  801ae1:	5b                   	pop    %ebx
  801ae2:	5e                   	pop    %esi
  801ae3:	5d                   	pop    %ebp
  801ae4:	c3                   	ret    

00801ae5 <socket>:

int
socket(int domain, int type, int protocol)
{
  801ae5:	55                   	push   %ebp
  801ae6:	89 e5                	mov    %esp,%ebp
  801ae8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801aeb:	8b 45 10             	mov    0x10(%ebp),%eax
  801aee:	89 44 24 08          	mov    %eax,0x8(%esp)
  801af2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af9:	8b 45 08             	mov    0x8(%ebp),%eax
  801afc:	89 04 24             	mov    %eax,(%esp)
  801aff:	e8 82 01 00 00       	call   801c86 <nsipc_socket>
  801b04:	85 c0                	test   %eax,%eax
  801b06:	78 05                	js     801b0d <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801b08:	e8 61 ff ff ff       	call   801a6e <alloc_sockfd>
}
  801b0d:	c9                   	leave  
  801b0e:	66 90                	xchg   %ax,%ax
  801b10:	c3                   	ret    

00801b11 <fd2sockid>:
  801b11:	55                   	push   %ebp
  801b12:	89 e5                	mov    %esp,%ebp
  801b14:	83 ec 18             	sub    $0x18,%esp
  801b17:	8d 55 fc             	lea    0xfffffffc(%ebp),%edx
  801b1a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b1e:	89 04 24             	mov    %eax,(%esp)
  801b21:	e8 58 f6 ff ff       	call   80117e <fd_lookup>
  801b26:	89 c2                	mov    %eax,%edx
  801b28:	85 c0                	test   %eax,%eax
  801b2a:	78 15                	js     801b41 <fd2sockid+0x30>
  801b2c:	8b 4d fc             	mov    0xfffffffc(%ebp),%ecx
  801b2f:	8b 01                	mov    (%ecx),%eax
  801b31:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  801b36:	3b 05 90 77 80 00    	cmp    0x807790,%eax
  801b3c:	75 03                	jne    801b41 <fd2sockid+0x30>
  801b3e:	8b 51 0c             	mov    0xc(%ecx),%edx
  801b41:	89 d0                	mov    %edx,%eax
  801b43:	c9                   	leave  
  801b44:	c3                   	ret    

00801b45 <listen>:
  801b45:	55                   	push   %ebp
  801b46:	89 e5                	mov    %esp,%ebp
  801b48:	83 ec 08             	sub    $0x8,%esp
  801b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4e:	e8 be ff ff ff       	call   801b11 <fd2sockid>
  801b53:	89 c2                	mov    %eax,%edx
  801b55:	85 c0                	test   %eax,%eax
  801b57:	78 11                	js     801b6a <listen+0x25>
  801b59:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b60:	89 14 24             	mov    %edx,(%esp)
  801b63:	e8 48 01 00 00       	call   801cb0 <nsipc_listen>
  801b68:	89 c2                	mov    %eax,%edx
  801b6a:	89 d0                	mov    %edx,%eax
  801b6c:	c9                   	leave  
  801b6d:	c3                   	ret    

00801b6e <connect>:
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	83 ec 18             	sub    $0x18,%esp
  801b74:	8b 45 08             	mov    0x8(%ebp),%eax
  801b77:	e8 95 ff ff ff       	call   801b11 <fd2sockid>
  801b7c:	89 c2                	mov    %eax,%edx
  801b7e:	85 c0                	test   %eax,%eax
  801b80:	78 18                	js     801b9a <connect+0x2c>
  801b82:	8b 45 10             	mov    0x10(%ebp),%eax
  801b85:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b89:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b90:	89 14 24             	mov    %edx,(%esp)
  801b93:	e8 71 02 00 00       	call   801e09 <nsipc_connect>
  801b98:	89 c2                	mov    %eax,%edx
  801b9a:	89 d0                	mov    %edx,%eax
  801b9c:	c9                   	leave  
  801b9d:	c3                   	ret    

00801b9e <shutdown>:
  801b9e:	55                   	push   %ebp
  801b9f:	89 e5                	mov    %esp,%ebp
  801ba1:	83 ec 08             	sub    $0x8,%esp
  801ba4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba7:	e8 65 ff ff ff       	call   801b11 <fd2sockid>
  801bac:	89 c2                	mov    %eax,%edx
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	78 11                	js     801bc3 <shutdown+0x25>
  801bb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb9:	89 14 24             	mov    %edx,(%esp)
  801bbc:	e8 2b 01 00 00       	call   801cec <nsipc_shutdown>
  801bc1:	89 c2                	mov    %eax,%edx
  801bc3:	89 d0                	mov    %edx,%eax
  801bc5:	c9                   	leave  
  801bc6:	c3                   	ret    

00801bc7 <bind>:
  801bc7:	55                   	push   %ebp
  801bc8:	89 e5                	mov    %esp,%ebp
  801bca:	83 ec 18             	sub    $0x18,%esp
  801bcd:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd0:	e8 3c ff ff ff       	call   801b11 <fd2sockid>
  801bd5:	89 c2                	mov    %eax,%edx
  801bd7:	85 c0                	test   %eax,%eax
  801bd9:	78 18                	js     801bf3 <bind+0x2c>
  801bdb:	8b 45 10             	mov    0x10(%ebp),%eax
  801bde:	89 44 24 08          	mov    %eax,0x8(%esp)
  801be2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be9:	89 14 24             	mov    %edx,(%esp)
  801bec:	e8 57 02 00 00       	call   801e48 <nsipc_bind>
  801bf1:	89 c2                	mov    %eax,%edx
  801bf3:	89 d0                	mov    %edx,%eax
  801bf5:	c9                   	leave  
  801bf6:	c3                   	ret    

00801bf7 <accept>:
  801bf7:	55                   	push   %ebp
  801bf8:	89 e5                	mov    %esp,%ebp
  801bfa:	83 ec 18             	sub    $0x18,%esp
  801bfd:	8b 45 08             	mov    0x8(%ebp),%eax
  801c00:	e8 0c ff ff ff       	call   801b11 <fd2sockid>
  801c05:	89 c2                	mov    %eax,%edx
  801c07:	85 c0                	test   %eax,%eax
  801c09:	78 23                	js     801c2e <accept+0x37>
  801c0b:	8b 45 10             	mov    0x10(%ebp),%eax
  801c0e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c12:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c15:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c19:	89 14 24             	mov    %edx,(%esp)
  801c1c:	e8 66 02 00 00       	call   801e87 <nsipc_accept>
  801c21:	89 c2                	mov    %eax,%edx
  801c23:	85 c0                	test   %eax,%eax
  801c25:	78 07                	js     801c2e <accept+0x37>
  801c27:	e8 42 fe ff ff       	call   801a6e <alloc_sockfd>
  801c2c:	89 c2                	mov    %eax,%edx
  801c2e:	89 d0                	mov    %edx,%eax
  801c30:	c9                   	leave  
  801c31:	c3                   	ret    
	...

00801c40 <nsipc>:
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c46:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  801c4c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c53:	00 
  801c54:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801c5b:	00 
  801c5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c60:	89 14 24             	mov    %edx,(%esp)
  801c63:	e8 e8 02 00 00       	call   801f50 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c68:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c6f:	00 
  801c70:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c77:	00 
  801c78:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c7f:	e8 80 03 00 00       	call   802004 <ipc_recv>
}
  801c84:	c9                   	leave  
  801c85:	c3                   	ret    

00801c86 <nsipc_socket>:

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
  801c86:	55                   	push   %ebp
  801c87:	89 e5                	mov    %esp,%ebp
  801c89:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8f:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.socket.req_type = type;
  801c94:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c97:	a3 04 50 80 00       	mov    %eax,0x805004
	nsipcbuf.socket.req_protocol = protocol;
  801c9c:	8b 45 10             	mov    0x10(%ebp),%eax
  801c9f:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SOCKET);
  801ca4:	b8 09 00 00 00       	mov    $0x9,%eax
  801ca9:	e8 92 ff ff ff       	call   801c40 <nsipc>
}
  801cae:	c9                   	leave  
  801caf:	c3                   	ret    

00801cb0 <nsipc_listen>:
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	83 ec 08             	sub    $0x8,%esp
  801cb6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb9:	a3 00 50 80 00       	mov    %eax,0x805000
  801cbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc1:	a3 04 50 80 00       	mov    %eax,0x805004
  801cc6:	b8 06 00 00 00       	mov    $0x6,%eax
  801ccb:	e8 70 ff ff ff       	call   801c40 <nsipc>
  801cd0:	c9                   	leave  
  801cd1:	c3                   	ret    

00801cd2 <nsipc_close>:
  801cd2:	55                   	push   %ebp
  801cd3:	89 e5                	mov    %esp,%ebp
  801cd5:	83 ec 08             	sub    $0x8,%esp
  801cd8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdb:	a3 00 50 80 00       	mov    %eax,0x805000
  801ce0:	b8 04 00 00 00       	mov    $0x4,%eax
  801ce5:	e8 56 ff ff ff       	call   801c40 <nsipc>
  801cea:	c9                   	leave  
  801ceb:	c3                   	ret    

00801cec <nsipc_shutdown>:
  801cec:	55                   	push   %ebp
  801ced:	89 e5                	mov    %esp,%ebp
  801cef:	83 ec 08             	sub    $0x8,%esp
  801cf2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf5:	a3 00 50 80 00       	mov    %eax,0x805000
  801cfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cfd:	a3 04 50 80 00       	mov    %eax,0x805004
  801d02:	b8 03 00 00 00       	mov    $0x3,%eax
  801d07:	e8 34 ff ff ff       	call   801c40 <nsipc>
  801d0c:	c9                   	leave  
  801d0d:	c3                   	ret    

00801d0e <nsipc_send>:
  801d0e:	55                   	push   %ebp
  801d0f:	89 e5                	mov    %esp,%ebp
  801d11:	53                   	push   %ebx
  801d12:	83 ec 14             	sub    $0x14,%esp
  801d15:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d18:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1b:	a3 00 50 80 00       	mov    %eax,0x805000
  801d20:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d26:	7e 24                	jle    801d4c <nsipc_send+0x3e>
  801d28:	c7 44 24 0c 64 28 80 	movl   $0x802864,0xc(%esp)
  801d2f:	00 
  801d30:	c7 44 24 08 70 28 80 	movl   $0x802870,0x8(%esp)
  801d37:	00 
  801d38:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  801d3f:	00 
  801d40:	c7 04 24 85 28 80 00 	movl   $0x802885,(%esp)
  801d47:	e8 8c 01 00 00       	call   801ed8 <_panic>
  801d4c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d50:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d53:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d57:	c7 04 24 0c 50 80 00 	movl   $0x80500c,(%esp)
  801d5e:	e8 57 ed ff ff       	call   800aba <memmove>
  801d63:	89 1d 04 50 80 00    	mov    %ebx,0x805004
  801d69:	8b 45 14             	mov    0x14(%ebp),%eax
  801d6c:	a3 08 50 80 00       	mov    %eax,0x805008
  801d71:	b8 08 00 00 00       	mov    $0x8,%eax
  801d76:	e8 c5 fe ff ff       	call   801c40 <nsipc>
  801d7b:	83 c4 14             	add    $0x14,%esp
  801d7e:	5b                   	pop    %ebx
  801d7f:	5d                   	pop    %ebp
  801d80:	c3                   	ret    

00801d81 <nsipc_recv>:
  801d81:	55                   	push   %ebp
  801d82:	89 e5                	mov    %esp,%ebp
  801d84:	83 ec 18             	sub    $0x18,%esp
  801d87:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  801d8a:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  801d8d:	8b 75 10             	mov    0x10(%ebp),%esi
  801d90:	8b 45 08             	mov    0x8(%ebp),%eax
  801d93:	a3 00 50 80 00       	mov    %eax,0x805000
  801d98:	89 35 04 50 80 00    	mov    %esi,0x805004
  801d9e:	8b 45 14             	mov    0x14(%ebp),%eax
  801da1:	a3 08 50 80 00       	mov    %eax,0x805008
  801da6:	b8 07 00 00 00       	mov    $0x7,%eax
  801dab:	e8 90 fe ff ff       	call   801c40 <nsipc>
  801db0:	89 c3                	mov    %eax,%ebx
  801db2:	85 c0                	test   %eax,%eax
  801db4:	78 47                	js     801dfd <nsipc_recv+0x7c>
  801db6:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801dbb:	7f 05                	jg     801dc2 <nsipc_recv+0x41>
  801dbd:	39 c6                	cmp    %eax,%esi
  801dbf:	90                   	nop    
  801dc0:	7d 24                	jge    801de6 <nsipc_recv+0x65>
  801dc2:	c7 44 24 0c 91 28 80 	movl   $0x802891,0xc(%esp)
  801dc9:	00 
  801dca:	c7 44 24 08 70 28 80 	movl   $0x802870,0x8(%esp)
  801dd1:	00 
  801dd2:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  801dd9:	00 
  801dda:	c7 04 24 85 28 80 00 	movl   $0x802885,(%esp)
  801de1:	e8 f2 00 00 00       	call   801ed8 <_panic>
  801de6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dea:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801df1:	00 
  801df2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df5:	89 04 24             	mov    %eax,(%esp)
  801df8:	e8 bd ec ff ff       	call   800aba <memmove>
  801dfd:	89 d8                	mov    %ebx,%eax
  801dff:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  801e02:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  801e05:	89 ec                	mov    %ebp,%esp
  801e07:	5d                   	pop    %ebp
  801e08:	c3                   	ret    

00801e09 <nsipc_connect>:
  801e09:	55                   	push   %ebp
  801e0a:	89 e5                	mov    %esp,%ebp
  801e0c:	53                   	push   %ebx
  801e0d:	83 ec 14             	sub    $0x14,%esp
  801e10:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e13:	8b 45 08             	mov    0x8(%ebp),%eax
  801e16:	a3 00 50 80 00       	mov    %eax,0x805000
  801e1b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e22:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e26:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  801e2d:	e8 88 ec ff ff       	call   800aba <memmove>
  801e32:	89 1d 14 50 80 00    	mov    %ebx,0x805014
  801e38:	b8 05 00 00 00       	mov    $0x5,%eax
  801e3d:	e8 fe fd ff ff       	call   801c40 <nsipc>
  801e42:	83 c4 14             	add    $0x14,%esp
  801e45:	5b                   	pop    %ebx
  801e46:	5d                   	pop    %ebp
  801e47:	c3                   	ret    

00801e48 <nsipc_bind>:
  801e48:	55                   	push   %ebp
  801e49:	89 e5                	mov    %esp,%ebp
  801e4b:	53                   	push   %ebx
  801e4c:	83 ec 14             	sub    $0x14,%esp
  801e4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e52:	8b 45 08             	mov    0x8(%ebp),%eax
  801e55:	a3 00 50 80 00       	mov    %eax,0x805000
  801e5a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e61:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e65:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  801e6c:	e8 49 ec ff ff       	call   800aba <memmove>
  801e71:	89 1d 14 50 80 00    	mov    %ebx,0x805014
  801e77:	b8 02 00 00 00       	mov    $0x2,%eax
  801e7c:	e8 bf fd ff ff       	call   801c40 <nsipc>
  801e81:	83 c4 14             	add    $0x14,%esp
  801e84:	5b                   	pop    %ebx
  801e85:	5d                   	pop    %ebp
  801e86:	c3                   	ret    

00801e87 <nsipc_accept>:
  801e87:	55                   	push   %ebp
  801e88:	89 e5                	mov    %esp,%ebp
  801e8a:	53                   	push   %ebx
  801e8b:	83 ec 14             	sub    $0x14,%esp
  801e8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e91:	a3 00 50 80 00       	mov    %eax,0x805000
  801e96:	b8 01 00 00 00       	mov    $0x1,%eax
  801e9b:	e8 a0 fd ff ff       	call   801c40 <nsipc>
  801ea0:	89 c3                	mov    %eax,%ebx
  801ea2:	85 c0                	test   %eax,%eax
  801ea4:	78 27                	js     801ecd <nsipc_accept+0x46>
  801ea6:	a1 10 50 80 00       	mov    0x805010,%eax
  801eab:	89 44 24 08          	mov    %eax,0x8(%esp)
  801eaf:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801eb6:	00 
  801eb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eba:	89 04 24             	mov    %eax,(%esp)
  801ebd:	e8 f8 eb ff ff       	call   800aba <memmove>
  801ec2:	8b 15 10 50 80 00    	mov    0x805010,%edx
  801ec8:	8b 45 10             	mov    0x10(%ebp),%eax
  801ecb:	89 10                	mov    %edx,(%eax)
  801ecd:	89 d8                	mov    %ebx,%eax
  801ecf:	83 c4 14             	add    $0x14,%esp
  801ed2:	5b                   	pop    %ebx
  801ed3:	5d                   	pop    %ebp
  801ed4:	c3                   	ret    
  801ed5:	00 00                	add    %al,(%eax)
	...

00801ed8 <_panic>:
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  801ed8:	55                   	push   %ebp
  801ed9:	89 e5                	mov    %esp,%ebp
  801edb:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  801ede:	8d 45 14             	lea    0x14(%ebp),%eax
  801ee1:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)

	// Print the panic message
	if (argv0)
  801ee4:	a1 34 8f 80 00       	mov    0x808f34,%eax
  801ee9:	85 c0                	test   %eax,%eax
  801eeb:	74 10                	je     801efd <_panic+0x25>
		cprintf("%s: ", argv0);
  801eed:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ef1:	c7 04 24 a6 28 80 00 	movl   $0x8028a6,(%esp)
  801ef8:	e8 28 e3 ff ff       	call   800225 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  801efd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f00:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f04:	8b 45 08             	mov    0x8(%ebp),%eax
  801f07:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f0b:	a1 70 77 80 00       	mov    0x807770,%eax
  801f10:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f14:	c7 04 24 ab 28 80 00 	movl   $0x8028ab,(%esp)
  801f1b:	e8 05 e3 ff ff       	call   800225 <cprintf>
	vcprintf(fmt, ap);
  801f20:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  801f23:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f27:	8b 45 10             	mov    0x10(%ebp),%eax
  801f2a:	89 04 24             	mov    %eax,(%esp)
  801f2d:	e8 92 e2 ff ff       	call   8001c4 <vcprintf>
	cprintf("\n");
  801f32:	c7 04 24 09 29 80 00 	movl   $0x802909,(%esp)
  801f39:	e8 e7 e2 ff ff       	call   800225 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f3e:	cc                   	int3   
  801f3f:	eb fd                	jmp    801f3e <_panic+0x66>
	...

00801f50 <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f50:	55                   	push   %ebp
  801f51:	89 e5                	mov    %esp,%ebp
  801f53:	57                   	push   %edi
  801f54:	56                   	push   %esi
  801f55:	53                   	push   %ebx
  801f56:	83 ec 1c             	sub    $0x1c,%esp
  801f59:	8b 75 08             	mov    0x8(%ebp),%esi
  801f5c:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  801f5f:	e8 09 f1 ff ff       	call   80106d <sys_getenvid>
  801f64:	25 ff 03 00 00       	and    $0x3ff,%eax
  801f69:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f6c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f71:	a3 30 8f 80 00       	mov    %eax,0x808f30
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  801f76:	e8 f2 f0 ff ff       	call   80106d <sys_getenvid>
  801f7b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801f80:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f83:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f88:	a3 30 8f 80 00       	mov    %eax,0x808f30
		if(env->env_id==to_env){
  801f8d:	8b 40 4c             	mov    0x4c(%eax),%eax
  801f90:	39 f0                	cmp    %esi,%eax
  801f92:	75 0e                	jne    801fa2 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  801f94:	c7 04 24 c7 28 80 00 	movl   $0x8028c7,(%esp)
  801f9b:	e8 85 e2 ff ff       	call   800225 <cprintf>
  801fa0:	eb 5a                	jmp    801ffc <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  801fa2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801fa6:	8b 45 10             	mov    0x10(%ebp),%eax
  801fa9:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fad:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fb4:	89 34 24             	mov    %esi,(%esp)
  801fb7:	e8 10 ee ff ff       	call   800dcc <sys_ipc_try_send>
  801fbc:	89 c3                	mov    %eax,%ebx
  801fbe:	85 c0                	test   %eax,%eax
  801fc0:	79 25                	jns    801fe7 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  801fc2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fc5:	74 2b                	je     801ff2 <ipc_send+0xa2>
				panic("send error:%e",r);
  801fc7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fcb:	c7 44 24 08 e3 28 80 	movl   $0x8028e3,0x8(%esp)
  801fd2:	00 
  801fd3:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  801fda:	00 
  801fdb:	c7 04 24 f1 28 80 00 	movl   $0x8028f1,(%esp)
  801fe2:	e8 f1 fe ff ff       	call   801ed8 <_panic>
		}
			sys_yield();
  801fe7:	e8 4d f0 ff ff       	call   801039 <sys_yield>
		
	}while(r!=0);
  801fec:	85 db                	test   %ebx,%ebx
  801fee:	75 86                	jne    801f76 <ipc_send+0x26>
  801ff0:	eb 0a                	jmp    801ffc <ipc_send+0xac>
  801ff2:	e8 42 f0 ff ff       	call   801039 <sys_yield>
  801ff7:	e9 7a ff ff ff       	jmp    801f76 <ipc_send+0x26>
	return;
	//panic("ipc_send not implemented");
}
  801ffc:	83 c4 1c             	add    $0x1c,%esp
  801fff:	5b                   	pop    %ebx
  802000:	5e                   	pop    %esi
  802001:	5f                   	pop    %edi
  802002:	5d                   	pop    %ebp
  802003:	c3                   	ret    

00802004 <ipc_recv>:
  802004:	55                   	push   %ebp
  802005:	89 e5                	mov    %esp,%ebp
  802007:	57                   	push   %edi
  802008:	56                   	push   %esi
  802009:	53                   	push   %ebx
  80200a:	83 ec 0c             	sub    $0xc,%esp
  80200d:	8b 75 08             	mov    0x8(%ebp),%esi
  802010:	8b 7d 10             	mov    0x10(%ebp),%edi
  802013:	e8 55 f0 ff ff       	call   80106d <sys_getenvid>
  802018:	25 ff 03 00 00       	and    $0x3ff,%eax
  80201d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802020:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802025:	a3 30 8f 80 00       	mov    %eax,0x808f30
  80202a:	85 f6                	test   %esi,%esi
  80202c:	74 29                	je     802057 <ipc_recv+0x53>
  80202e:	8b 40 4c             	mov    0x4c(%eax),%eax
  802031:	3b 06                	cmp    (%esi),%eax
  802033:	75 22                	jne    802057 <ipc_recv+0x53>
  802035:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80203b:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  802041:	c7 04 24 c7 28 80 00 	movl   $0x8028c7,(%esp)
  802048:	e8 d8 e1 ff ff       	call   800225 <cprintf>
  80204d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802052:	e9 8a 00 00 00       	jmp    8020e1 <ipc_recv+0xdd>
  802057:	e8 11 f0 ff ff       	call   80106d <sys_getenvid>
  80205c:	25 ff 03 00 00       	and    $0x3ff,%eax
  802061:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802064:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802069:	a3 30 8f 80 00       	mov    %eax,0x808f30
  80206e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802071:	89 04 24             	mov    %eax,(%esp)
  802074:	e8 f6 ec ff ff       	call   800d6f <sys_ipc_recv>
  802079:	89 c3                	mov    %eax,%ebx
  80207b:	85 c0                	test   %eax,%eax
  80207d:	79 1a                	jns    802099 <ipc_recv+0x95>
  80207f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802085:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  80208b:	c7 04 24 fb 28 80 00 	movl   $0x8028fb,(%esp)
  802092:	e8 8e e1 ff ff       	call   800225 <cprintf>
  802097:	eb 48                	jmp    8020e1 <ipc_recv+0xdd>
  802099:	e8 cf ef ff ff       	call   80106d <sys_getenvid>
  80209e:	25 ff 03 00 00       	and    $0x3ff,%eax
  8020a3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020a6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020ab:	a3 30 8f 80 00       	mov    %eax,0x808f30
  8020b0:	85 f6                	test   %esi,%esi
  8020b2:	74 05                	je     8020b9 <ipc_recv+0xb5>
  8020b4:	8b 40 74             	mov    0x74(%eax),%eax
  8020b7:	89 06                	mov    %eax,(%esi)
  8020b9:	85 ff                	test   %edi,%edi
  8020bb:	74 0a                	je     8020c7 <ipc_recv+0xc3>
  8020bd:	a1 30 8f 80 00       	mov    0x808f30,%eax
  8020c2:	8b 40 78             	mov    0x78(%eax),%eax
  8020c5:	89 07                	mov    %eax,(%edi)
  8020c7:	e8 a1 ef ff ff       	call   80106d <sys_getenvid>
  8020cc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8020d1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020d4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020d9:	a3 30 8f 80 00       	mov    %eax,0x808f30
  8020de:	8b 58 70             	mov    0x70(%eax),%ebx
  8020e1:	89 d8                	mov    %ebx,%eax
  8020e3:	83 c4 0c             	add    $0xc,%esp
  8020e6:	5b                   	pop    %ebx
  8020e7:	5e                   	pop    %esi
  8020e8:	5f                   	pop    %edi
  8020e9:	5d                   	pop    %ebp
  8020ea:	c3                   	ret    
  8020eb:	00 00                	add    %al,(%eax)
  8020ed:	00 00                	add    %al,(%eax)
	...

008020f0 <__udivdi3>:
  8020f0:	55                   	push   %ebp
  8020f1:	89 e5                	mov    %esp,%ebp
  8020f3:	57                   	push   %edi
  8020f4:	56                   	push   %esi
  8020f5:	83 ec 1c             	sub    $0x1c,%esp
  8020f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8020fb:	8b 55 14             	mov    0x14(%ebp),%edx
  8020fe:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802101:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  802104:	89 c1                	mov    %eax,%ecx
  802106:	8b 45 08             	mov    0x8(%ebp),%eax
  802109:	85 d2                	test   %edx,%edx
  80210b:	89 d6                	mov    %edx,%esi
  80210d:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
  802110:	75 1e                	jne    802130 <__udivdi3+0x40>
  802112:	39 f9                	cmp    %edi,%ecx
  802114:	0f 86 8d 00 00 00    	jbe    8021a7 <__udivdi3+0xb7>
  80211a:	89 fa                	mov    %edi,%edx
  80211c:	f7 f1                	div    %ecx
  80211e:	89 c1                	mov    %eax,%ecx
  802120:	89 c8                	mov    %ecx,%eax
  802122:	89 f2                	mov    %esi,%edx
  802124:	83 c4 1c             	add    $0x1c,%esp
  802127:	5e                   	pop    %esi
  802128:	5f                   	pop    %edi
  802129:	5d                   	pop    %ebp
  80212a:	c3                   	ret    
  80212b:	90                   	nop    
  80212c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802130:	39 fa                	cmp    %edi,%edx
  802132:	0f 87 98 00 00 00    	ja     8021d0 <__udivdi3+0xe0>
  802138:	0f bd c2             	bsr    %edx,%eax
  80213b:	83 f0 1f             	xor    $0x1f,%eax
  80213e:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  802141:	74 7f                	je     8021c2 <__udivdi3+0xd2>
  802143:	b8 20 00 00 00       	mov    $0x20,%eax
  802148:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  80214b:	2b 45 e4             	sub    0xffffffe4(%ebp),%eax
  80214e:	89 c1                	mov    %eax,%ecx
  802150:	d3 ea                	shr    %cl,%edx
  802152:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802156:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  802159:	89 f0                	mov    %esi,%eax
  80215b:	d3 e0                	shl    %cl,%eax
  80215d:	09 c2                	or     %eax,%edx
  80215f:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802162:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  802165:	89 fa                	mov    %edi,%edx
  802167:	d3 e0                	shl    %cl,%eax
  802169:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  80216d:	89 45 f4             	mov    %eax,0xfffffff4(%ebp)
  802170:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802173:	d3 e8                	shr    %cl,%eax
  802175:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802179:	d3 e2                	shl    %cl,%edx
  80217b:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  80217f:	09 d0                	or     %edx,%eax
  802181:	d3 ef                	shr    %cl,%edi
  802183:	89 fa                	mov    %edi,%edx
  802185:	f7 75 e0             	divl   0xffffffe0(%ebp)
  802188:	89 d1                	mov    %edx,%ecx
  80218a:	89 c7                	mov    %eax,%edi
  80218c:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80218f:	f7 e7                	mul    %edi
  802191:	39 d1                	cmp    %edx,%ecx
  802193:	89 c6                	mov    %eax,%esi
  802195:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  802198:	72 6f                	jb     802209 <__udivdi3+0x119>
  80219a:	39 ca                	cmp    %ecx,%edx
  80219c:	74 5e                	je     8021fc <__udivdi3+0x10c>
  80219e:	89 f9                	mov    %edi,%ecx
  8021a0:	31 f6                	xor    %esi,%esi
  8021a2:	e9 79 ff ff ff       	jmp    802120 <__udivdi3+0x30>
  8021a7:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8021aa:	85 c0                	test   %eax,%eax
  8021ac:	74 32                	je     8021e0 <__udivdi3+0xf0>
  8021ae:	89 f2                	mov    %esi,%edx
  8021b0:	89 f8                	mov    %edi,%eax
  8021b2:	f7 f1                	div    %ecx
  8021b4:	89 c6                	mov    %eax,%esi
  8021b6:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8021b9:	f7 f1                	div    %ecx
  8021bb:	89 c1                	mov    %eax,%ecx
  8021bd:	e9 5e ff ff ff       	jmp    802120 <__udivdi3+0x30>
  8021c2:	39 d7                	cmp    %edx,%edi
  8021c4:	77 2a                	ja     8021f0 <__udivdi3+0x100>
  8021c6:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  8021c9:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
  8021cc:	73 22                	jae    8021f0 <__udivdi3+0x100>
  8021ce:	66 90                	xchg   %ax,%ax
  8021d0:	31 c9                	xor    %ecx,%ecx
  8021d2:	31 f6                	xor    %esi,%esi
  8021d4:	e9 47 ff ff ff       	jmp    802120 <__udivdi3+0x30>
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  8021e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8021e5:	31 d2                	xor    %edx,%edx
  8021e7:	f7 75 f0             	divl   0xfffffff0(%ebp)
  8021ea:	89 c1                	mov    %eax,%ecx
  8021ec:	eb c0                	jmp    8021ae <__udivdi3+0xbe>
  8021ee:	66 90                	xchg   %ax,%ax
  8021f0:	b9 01 00 00 00       	mov    $0x1,%ecx
  8021f5:	31 f6                	xor    %esi,%esi
  8021f7:	e9 24 ff ff ff       	jmp    802120 <__udivdi3+0x30>
  8021fc:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8021ff:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802203:	d3 e0                	shl    %cl,%eax
  802205:	39 c6                	cmp    %eax,%esi
  802207:	76 95                	jbe    80219e <__udivdi3+0xae>
  802209:	8d 4f ff             	lea    0xffffffff(%edi),%ecx
  80220c:	31 f6                	xor    %esi,%esi
  80220e:	e9 0d ff ff ff       	jmp    802120 <__udivdi3+0x30>
	...

00802220 <__umoddi3>:
  802220:	55                   	push   %ebp
  802221:	89 e5                	mov    %esp,%ebp
  802223:	57                   	push   %edi
  802224:	56                   	push   %esi
  802225:	83 ec 30             	sub    $0x30,%esp
  802228:	8b 55 14             	mov    0x14(%ebp),%edx
  80222b:	8b 45 10             	mov    0x10(%ebp),%eax
  80222e:	8b 75 08             	mov    0x8(%ebp),%esi
  802231:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802234:	85 d2                	test   %edx,%edx
  802236:	c7 45 d0 00 00 00 00 	movl   $0x0,0xffffffd0(%ebp)
  80223d:	89 c1                	mov    %eax,%ecx
  80223f:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  802246:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  802249:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  80224c:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  80224f:	89 7d e0             	mov    %edi,0xffffffe0(%ebp)
  802252:	75 1c                	jne    802270 <__umoddi3+0x50>
  802254:	39 f8                	cmp    %edi,%eax
  802256:	89 fa                	mov    %edi,%edx
  802258:	0f 86 d4 00 00 00    	jbe    802332 <__umoddi3+0x112>
  80225e:	89 f0                	mov    %esi,%eax
  802260:	f7 f1                	div    %ecx
  802262:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802265:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  80226c:	eb 12                	jmp    802280 <__umoddi3+0x60>
  80226e:	66 90                	xchg   %ax,%ax
  802270:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802273:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  802276:	76 18                	jbe    802290 <__umoddi3+0x70>
  802278:	89 75 d0             	mov    %esi,0xffffffd0(%ebp)
  80227b:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  80227e:	66 90                	xchg   %ax,%ax
  802280:	8b 45 d0             	mov    0xffffffd0(%ebp),%eax
  802283:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  802286:	83 c4 30             	add    $0x30,%esp
  802289:	5e                   	pop    %esi
  80228a:	5f                   	pop    %edi
  80228b:	5d                   	pop    %ebp
  80228c:	c3                   	ret    
  80228d:	8d 76 00             	lea    0x0(%esi),%esi
  802290:	0f bd 45 e8          	bsr    0xffffffe8(%ebp),%eax
  802294:	83 f0 1f             	xor    $0x1f,%eax
  802297:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  80229a:	0f 84 c0 00 00 00    	je     802360 <__umoddi3+0x140>
  8022a0:	b8 20 00 00 00       	mov    $0x20,%eax
  8022a5:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  8022a8:	2b 45 dc             	sub    0xffffffdc(%ebp),%eax
  8022ab:	8b 7d ec             	mov    0xffffffec(%ebp),%edi
  8022ae:	8b 75 f0             	mov    0xfffffff0(%ebp),%esi
  8022b1:	89 c1                	mov    %eax,%ecx
  8022b3:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8022b6:	d3 ea                	shr    %cl,%edx
  8022b8:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8022bb:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  8022bf:	d3 e0                	shl    %cl,%eax
  8022c1:	09 c2                	or     %eax,%edx
  8022c3:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8022c6:	d3 e7                	shl    %cl,%edi
  8022c8:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8022cc:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  8022cf:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  8022d2:	d3 e8                	shr    %cl,%eax
  8022d4:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  8022d8:	d3 e2                	shl    %cl,%edx
  8022da:	09 d0                	or     %edx,%eax
  8022dc:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  8022df:	d3 e6                	shl    %cl,%esi
  8022e1:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8022e5:	d3 ea                	shr    %cl,%edx
  8022e7:	f7 75 f4             	divl   0xfffffff4(%ebp)
  8022ea:	89 55 cc             	mov    %edx,0xffffffcc(%ebp)
  8022ed:	f7 e7                	mul    %edi
  8022ef:	39 55 cc             	cmp    %edx,0xffffffcc(%ebp)
  8022f2:	0f 82 a5 00 00 00    	jb     80239d <__umoddi3+0x17d>
  8022f8:	3b 55 cc             	cmp    0xffffffcc(%ebp),%edx
  8022fb:	0f 84 94 00 00 00    	je     802395 <__umoddi3+0x175>
  802301:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
  802304:	29 c6                	sub    %eax,%esi
  802306:	19 d1                	sbb    %edx,%ecx
  802308:	89 4d cc             	mov    %ecx,0xffffffcc(%ebp)
  80230b:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  80230f:	89 f2                	mov    %esi,%edx
  802311:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  802314:	d3 ea                	shr    %cl,%edx
  802316:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  80231a:	d3 e0                	shl    %cl,%eax
  80231c:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  802320:	09 c2                	or     %eax,%edx
  802322:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  802325:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802328:	d3 e8                	shr    %cl,%eax
  80232a:	89 45 d4             	mov    %eax,0xffffffd4(%ebp)
  80232d:	e9 4e ff ff ff       	jmp    802280 <__umoddi3+0x60>
  802332:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  802335:	85 c0                	test   %eax,%eax
  802337:	74 17                	je     802350 <__umoddi3+0x130>
  802339:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  80233c:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
  80233f:	f7 f1                	div    %ecx
  802341:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802344:	f7 f1                	div    %ecx
  802346:	e9 17 ff ff ff       	jmp    802262 <__umoddi3+0x42>
  80234b:	90                   	nop    
  80234c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802350:	b8 01 00 00 00       	mov    $0x1,%eax
  802355:	31 d2                	xor    %edx,%edx
  802357:	f7 75 ec             	divl   0xffffffec(%ebp)
  80235a:	89 c1                	mov    %eax,%ecx
  80235c:	eb db                	jmp    802339 <__umoddi3+0x119>
  80235e:	66 90                	xchg   %ax,%ax
  802360:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802363:	39 45 e0             	cmp    %eax,0xffffffe0(%ebp)
  802366:	77 19                	ja     802381 <__umoddi3+0x161>
  802368:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  80236b:	39 55 f0             	cmp    %edx,0xfffffff0(%ebp)
  80236e:	73 11                	jae    802381 <__umoddi3+0x161>
  802370:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  802373:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802376:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802379:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  80237c:	e9 ff fe ff ff       	jmp    802280 <__umoddi3+0x60>
  802381:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802384:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802387:	2b 45 ec             	sub    0xffffffec(%ebp),%eax
  80238a:	1b 4d e8             	sbb    0xffffffe8(%ebp),%ecx
  80238d:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  802390:	89 4d e0             	mov    %ecx,0xffffffe0(%ebp)
  802393:	eb db                	jmp    802370 <__umoddi3+0x150>
  802395:	39 f0                	cmp    %esi,%eax
  802397:	0f 86 64 ff ff ff    	jbe    802301 <__umoddi3+0xe1>
  80239d:	29 f8                	sub    %edi,%eax
  80239f:	1b 55 f4             	sbb    0xfffffff4(%ebp),%edx
  8023a2:	e9 5a ff ff ff       	jmp    802301 <__umoddi3+0xe1>
