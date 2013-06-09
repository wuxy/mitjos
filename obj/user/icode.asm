
obj/user/icode:     file format elf32-i386

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
  80002c:	e8 2b 01 00 00       	call   80015c <libmain>
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
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 30 02 00 00    	sub    $0x230,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003f:	c7 05 00 60 80 00 60 	movl   $0x802960,0x806000
  800046:	29 80 00 

	cprintf("icode startup\n");
  800049:	c7 04 24 66 29 80 00 	movl   $0x802966,(%esp)
  800050:	e8 4c 02 00 00       	call   8002a1 <cprintf>

	cprintf("icode: open /motd\n");
  800055:	c7 04 24 75 29 80 00 	movl   $0x802975,(%esp)
  80005c:	e8 40 02 00 00       	call   8002a1 <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  800061:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800068:	00 
  800069:	c7 04 24 88 29 80 00 	movl   $0x802988,(%esp)
  800070:	e8 fe 18 00 00       	call   801973 <open>
  800075:	89 c3                	mov    %eax,%ebx
  800077:	85 c0                	test   %eax,%eax
  800079:	79 20                	jns    80009b <umain+0x67>
		panic("icode: open /motd: %e", fd);
  80007b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80007f:	c7 44 24 08 8e 29 80 	movl   $0x80298e,0x8(%esp)
  800086:	00 
  800087:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008e:	00 
  80008f:	c7 04 24 a4 29 80 00 	movl   $0x8029a4,(%esp)
  800096:	e8 39 01 00 00       	call   8001d4 <_panic>

	cprintf("icode: read /motd\n");
  80009b:	c7 04 24 b1 29 80 00 	movl   $0x8029b1,(%esp)
  8000a2:	e8 fa 01 00 00       	call   8002a1 <cprintf>
  8000a7:	8d b5 f7 fd ff ff    	lea    0xfffffdf7(%ebp),%esi
  8000ad:	eb 0c                	jmp    8000bb <umain+0x87>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
  8000af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b3:	89 34 24             	mov    %esi,(%esp)
  8000b6:	e8 bd 0c 00 00       	call   800d78 <sys_cputs>
  8000bb:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8000c2:	00 
  8000c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000c7:	89 1c 24             	mov    %ebx,(%esp)
  8000ca:	e8 8e 13 00 00       	call   80145d <read>
  8000cf:	85 c0                	test   %eax,%eax
  8000d1:	7f dc                	jg     8000af <umain+0x7b>

	cprintf("icode: close /motd\n");
  8000d3:	c7 04 24 c4 29 80 00 	movl   $0x8029c4,(%esp)
  8000da:	e8 c2 01 00 00       	call   8002a1 <cprintf>
	close(fd);
  8000df:	89 1c 24             	mov    %ebx,(%esp)
  8000e2:	e8 e4 14 00 00       	call   8015cb <close>

	cprintf("icode: spawn /init\n");
  8000e7:	c7 04 24 d8 29 80 00 	movl   $0x8029d8,(%esp)
  8000ee:	e8 ae 01 00 00       	call   8002a1 <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000f3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8000fa:	00 
  8000fb:	c7 44 24 0c ec 29 80 	movl   $0x8029ec,0xc(%esp)
  800102:	00 
  800103:	c7 44 24 08 f5 29 80 	movl   $0x8029f5,0x8(%esp)
  80010a:	00 
  80010b:	c7 44 24 04 ff 29 80 	movl   $0x8029ff,0x4(%esp)
  800112:	00 
  800113:	c7 04 24 fe 29 80 00 	movl   $0x8029fe,(%esp)
  80011a:	e8 ba 1e 00 00       	call   801fd9 <spawnl>
  80011f:	85 c0                	test   %eax,%eax
  800121:	79 20                	jns    800143 <umain+0x10f>
		panic("icode: spawn /init: %e", r);
  800123:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800127:	c7 44 24 08 04 2a 80 	movl   $0x802a04,0x8(%esp)
  80012e:	00 
  80012f:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800136:	00 
  800137:	c7 04 24 a4 29 80 00 	movl   $0x8029a4,(%esp)
  80013e:	e8 91 00 00 00       	call   8001d4 <_panic>

	cprintf("icode: exiting\n");
  800143:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  80014a:	e8 52 01 00 00       	call   8002a1 <cprintf>
}
  80014f:	81 c4 30 02 00 00    	add    $0x230,%esp
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5d                   	pop    %ebp
  800158:	c3                   	ret    
  800159:	00 00                	add    %al,(%eax)
	...

0080015c <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	83 ec 18             	sub    $0x18,%esp
  800162:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  800165:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  800168:	8b 75 08             	mov    0x8(%ebp),%esi
  80016b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  80016e:	c7 05 3c 60 80 00 00 	movl   $0x0,0x80603c
  800175:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  800178:	e8 60 0f 00 00       	call   8010dd <sys_getenvid>
  80017d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800182:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800185:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80018a:	a3 3c 60 80 00       	mov    %eax,0x80603c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80018f:	85 f6                	test   %esi,%esi
  800191:	7e 07                	jle    80019a <libmain+0x3e>
		binaryname = argv[0];
  800193:	8b 03                	mov    (%ebx),%eax
  800195:	a3 00 60 80 00       	mov    %eax,0x806000

	// call user main routine调用用户主例程
	umain(argc, argv);
  80019a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80019e:	89 34 24             	mov    %esi,(%esp)
  8001a1:	e8 8e fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8001a6:	e8 0d 00 00 00       	call   8001b8 <exit>
}
  8001ab:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  8001ae:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  8001b1:	89 ec                	mov    %ebp,%esp
  8001b3:	5d                   	pop    %ebp
  8001b4:	c3                   	ret    
  8001b5:	00 00                	add    %al,(%eax)
	...

008001b8 <exit>:
#include <inc/lib.h>

void
exit(void)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001be:	e8 a3 15 00 00       	call   801766 <close_all>
	sys_env_destroy(0);
  8001c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ca:	e8 42 0f 00 00       	call   801111 <sys_env_destroy>
}
  8001cf:	c9                   	leave  
  8001d0:	c3                   	ret    
  8001d1:	00 00                	add    %al,(%eax)
	...

008001d4 <_panic>:
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8001da:	8d 45 14             	lea    0x14(%ebp),%eax
  8001dd:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)

	// Print the panic message
	if (argv0)
  8001e0:	a1 40 60 80 00       	mov    0x806040,%eax
  8001e5:	85 c0                	test   %eax,%eax
  8001e7:	74 10                	je     8001f9 <_panic+0x25>
		cprintf("%s: ", argv0);
  8001e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ed:	c7 04 24 42 2a 80 00 	movl   $0x802a42,(%esp)
  8001f4:	e8 a8 00 00 00       	call   8002a1 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8001f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800200:	8b 45 08             	mov    0x8(%ebp),%eax
  800203:	89 44 24 08          	mov    %eax,0x8(%esp)
  800207:	a1 00 60 80 00       	mov    0x806000,%eax
  80020c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800210:	c7 04 24 47 2a 80 00 	movl   $0x802a47,(%esp)
  800217:	e8 85 00 00 00       	call   8002a1 <cprintf>
	vcprintf(fmt, ap);
  80021c:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  80021f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800223:	8b 45 10             	mov    0x10(%ebp),%eax
  800226:	89 04 24             	mov    %eax,(%esp)
  800229:	e8 12 00 00 00       	call   800240 <vcprintf>
	cprintf("\n");
  80022e:	c7 04 24 43 2f 80 00 	movl   $0x802f43,(%esp)
  800235:	e8 67 00 00 00       	call   8002a1 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80023a:	cc                   	int3   
  80023b:	eb fd                	jmp    80023a <_panic+0x66>
  80023d:	00 00                	add    %al,(%eax)
	...

00800240 <vcprintf>:
}

int
vcprintf(const char *fmt, va_list ap)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800249:	c7 85 f8 fe ff ff 00 	movl   $0x0,0xfffffef8(%ebp)
  800250:	00 00 00 
	b.cnt = 0;
  800253:	c7 85 fc fe ff ff 00 	movl   $0x0,0xfffffefc(%ebp)
  80025a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80025d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800260:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800264:	8b 45 08             	mov    0x8(%ebp),%eax
  800267:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026b:	8d 85 f8 fe ff ff    	lea    0xfffffef8(%ebp),%eax
  800271:	89 44 24 04          	mov    %eax,0x4(%esp)
  800275:	c7 04 24 be 02 80 00 	movl   $0x8002be,(%esp)
  80027c:	e8 c0 01 00 00       	call   800441 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800281:	8b 85 f8 fe ff ff    	mov    0xfffffef8(%ebp),%eax
  800287:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028b:	8d 85 00 ff ff ff    	lea    0xffffff00(%ebp),%eax
  800291:	89 04 24             	mov    %eax,(%esp)
  800294:	e8 df 0a 00 00       	call   800d78 <sys_cputs>
  800299:	8b 85 fc fe ff ff    	mov    0xfffffefc(%ebp),%eax

	return b.cnt;
}
  80029f:	c9                   	leave  
  8002a0:	c3                   	ret    

008002a1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002a7:	8d 45 0c             	lea    0xc(%ebp),%eax
  8002aa:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
	cnt = vcprintf(fmt, ap);
  8002ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b4:	89 04 24             	mov    %eax,(%esp)
  8002b7:	e8 84 ff ff ff       	call   800240 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <putch>:
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	53                   	push   %ebx
  8002c2:	83 ec 14             	sub    $0x14,%esp
  8002c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002c8:	8b 03                	mov    (%ebx),%eax
  8002ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cd:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002d1:	83 c0 01             	add    $0x1,%eax
  8002d4:	89 03                	mov    %eax,(%ebx)
  8002d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002db:	75 19                	jne    8002f6 <putch+0x38>
  8002dd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002e4:	00 
  8002e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8002e8:	89 04 24             	mov    %eax,(%esp)
  8002eb:	e8 88 0a 00 00       	call   800d78 <sys_cputs>
  8002f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002f6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
  8002fa:	83 c4 14             	add    $0x14,%esp
  8002fd:	5b                   	pop    %ebx
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    

00800300 <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	57                   	push   %edi
  800304:	56                   	push   %esi
  800305:	53                   	push   %ebx
  800306:	83 ec 3c             	sub    $0x3c,%esp
  800309:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  80030c:	89 d7                	mov    %edx,%edi
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	8b 55 0c             	mov    0xc(%ebp),%edx
  800314:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800317:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  80031a:	8b 55 10             	mov    0x10(%ebp),%edx
  80031d:	8b 45 14             	mov    0x14(%ebp),%eax
  800320:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800323:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  800326:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  80032d:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800330:	39 4d ec             	cmp    %ecx,0xffffffec(%ebp)
  800333:	72 11                	jb     800346 <printnum+0x46>
  800335:	8b 4d d8             	mov    0xffffffd8(%ebp),%ecx
  800338:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  80033b:	76 09                	jbe    800346 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033d:	8d 58 ff             	lea    0xffffffff(%eax),%ebx
  800340:	85 db                	test   %ebx,%ebx
  800342:	7f 54                	jg     800398 <printnum+0x98>
  800344:	eb 61                	jmp    8003a7 <printnum+0xa7>
  800346:	89 74 24 10          	mov    %esi,0x10(%esp)
  80034a:	83 e8 01             	sub    $0x1,%eax
  80034d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800351:	89 54 24 08          	mov    %edx,0x8(%esp)
  800355:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800359:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80035d:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800360:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800363:	89 44 24 08          	mov    %eax,0x8(%esp)
  800367:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80036b:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  80036e:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800371:	89 14 24             	mov    %edx,(%esp)
  800374:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800378:	e8 23 23 00 00       	call   8026a0 <__udivdi3>
  80037d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800381:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800385:	89 04 24             	mov    %eax,(%esp)
  800388:	89 54 24 04          	mov    %edx,0x4(%esp)
  80038c:	89 fa                	mov    %edi,%edx
  80038e:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  800391:	e8 6a ff ff ff       	call   800300 <printnum>
  800396:	eb 0f                	jmp    8003a7 <printnum+0xa7>
			putch(padc, putdat);
  800398:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80039c:	89 34 24             	mov    %esi,(%esp)
  80039f:	ff 55 e4             	call   *0xffffffe4(%ebp)
  8003a2:	83 eb 01             	sub    $0x1,%ebx
  8003a5:	75 f1                	jne    800398 <printnum+0x98>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003ab:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003af:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8003b2:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  8003b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003b9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003bd:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  8003c0:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  8003c3:	89 14 24             	mov    %edx,(%esp)
  8003c6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8003ca:	e8 01 24 00 00       	call   8027d0 <__umoddi3>
  8003cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003d3:	0f be 80 63 2a 80 00 	movsbl 0x802a63(%eax),%eax
  8003da:	89 04 24             	mov    %eax,(%esp)
  8003dd:	ff 55 e4             	call   *0xffffffe4(%ebp)
}
  8003e0:	83 c4 3c             	add    $0x3c,%esp
  8003e3:	5b                   	pop    %ebx
  8003e4:	5e                   	pop    %esi
  8003e5:	5f                   	pop    %edi
  8003e6:	5d                   	pop    %ebp
  8003e7:	c3                   	ret    

008003e8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8003ed:	83 fa 01             	cmp    $0x1,%edx
  8003f0:	7e 0e                	jle    800400 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8003f2:	8b 10                	mov    (%eax),%edx
  8003f4:	8d 42 08             	lea    0x8(%edx),%eax
  8003f7:	89 01                	mov    %eax,(%ecx)
  8003f9:	8b 02                	mov    (%edx),%eax
  8003fb:	8b 52 04             	mov    0x4(%edx),%edx
  8003fe:	eb 22                	jmp    800422 <getuint+0x3a>
	else if (lflag)
  800400:	85 d2                	test   %edx,%edx
  800402:	74 10                	je     800414 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800404:	8b 10                	mov    (%eax),%edx
  800406:	8d 42 04             	lea    0x4(%edx),%eax
  800409:	89 01                	mov    %eax,(%ecx)
  80040b:	8b 02                	mov    (%edx),%eax
  80040d:	ba 00 00 00 00       	mov    $0x0,%edx
  800412:	eb 0e                	jmp    800422 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800414:	8b 10                	mov    (%eax),%edx
  800416:	8d 42 04             	lea    0x4(%edx),%eax
  800419:	89 01                	mov    %eax,(%ecx)
  80041b:	8b 02                	mov    (%edx),%eax
  80041d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800422:	5d                   	pop    %ebp
  800423:	c3                   	ret    

00800424 <sprintputch>:

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
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  80042a:	83 41 08 01          	addl   $0x1,0x8(%ecx)
	if (b->buf < b->ebuf)
  80042e:	8b 11                	mov    (%ecx),%edx
  800430:	3b 51 04             	cmp    0x4(%ecx),%edx
  800433:	73 0a                	jae    80043f <sprintputch+0x1b>
		*b->buf++ = ch;
  800435:	8b 45 08             	mov    0x8(%ebp),%eax
  800438:	88 02                	mov    %al,(%edx)
  80043a:	8d 42 01             	lea    0x1(%edx),%eax
  80043d:	89 01                	mov    %eax,(%ecx)
}
  80043f:	5d                   	pop    %ebp
  800440:	c3                   	ret    

00800441 <vprintfmt>:
  800441:	55                   	push   %ebp
  800442:	89 e5                	mov    %esp,%ebp
  800444:	57                   	push   %edi
  800445:	56                   	push   %esi
  800446:	53                   	push   %ebx
  800447:	83 ec 4c             	sub    $0x4c,%esp
  80044a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80044d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800450:	eb 03                	jmp    800455 <vprintfmt+0x14>
  800452:	8b 5d e8             	mov    0xffffffe8(%ebp),%ebx
  800455:	0f b6 03             	movzbl (%ebx),%eax
  800458:	83 c3 01             	add    $0x1,%ebx
  80045b:	3c 25                	cmp    $0x25,%al
  80045d:	74 30                	je     80048f <vprintfmt+0x4e>
  80045f:	84 c0                	test   %al,%al
  800461:	0f 84 a8 03 00 00    	je     80080f <vprintfmt+0x3ce>
  800467:	0f b6 d0             	movzbl %al,%edx
  80046a:	eb 0a                	jmp    800476 <vprintfmt+0x35>
  80046c:	84 c0                	test   %al,%al
  80046e:	66 90                	xchg   %ax,%ax
  800470:	0f 84 99 03 00 00    	je     80080f <vprintfmt+0x3ce>
  800476:	8b 45 0c             	mov    0xc(%ebp),%eax
  800479:	89 44 24 04          	mov    %eax,0x4(%esp)
  80047d:	89 14 24             	mov    %edx,(%esp)
  800480:	ff d7                	call   *%edi
  800482:	0f b6 03             	movzbl (%ebx),%eax
  800485:	0f b6 d0             	movzbl %al,%edx
  800488:	83 c3 01             	add    $0x1,%ebx
  80048b:	3c 25                	cmp    $0x25,%al
  80048d:	75 dd                	jne    80046c <vprintfmt+0x2b>
  80048f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800494:	c7 45 ec ff ff ff ff 	movl   $0xffffffff,0xffffffec(%ebp)
  80049b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  8004a2:	c7 45 dc 00 00 00 00 	movl   $0x0,0xffffffdc(%ebp)
  8004a9:	c6 45 e3 20          	movb   $0x20,0xffffffe3(%ebp)
  8004ad:	eb 07                	jmp    8004b6 <vprintfmt+0x75>
  8004af:	c7 45 dc 01 00 00 00 	movl   $0x1,0xffffffdc(%ebp)
  8004b6:	0f b6 03             	movzbl (%ebx),%eax
  8004b9:	0f b6 d0             	movzbl %al,%edx
  8004bc:	83 c3 01             	add    $0x1,%ebx
  8004bf:	83 e8 23             	sub    $0x23,%eax
  8004c2:	3c 55                	cmp    $0x55,%al
  8004c4:	0f 87 11 03 00 00    	ja     8007db <vprintfmt+0x39a>
  8004ca:	0f b6 c0             	movzbl %al,%eax
  8004cd:	ff 24 85 a0 2b 80 00 	jmp    *0x802ba0(,%eax,4)
  8004d4:	c6 45 e3 30          	movb   $0x30,0xffffffe3(%ebp)
  8004d8:	eb dc                	jmp    8004b6 <vprintfmt+0x75>
  8004da:	83 ea 30             	sub    $0x30,%edx
  8004dd:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  8004e0:	0f be 13             	movsbl (%ebx),%edx
  8004e3:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  8004e6:	83 f8 09             	cmp    $0x9,%eax
  8004e9:	76 08                	jbe    8004f3 <vprintfmt+0xb2>
  8004eb:	eb 42                	jmp    80052f <vprintfmt+0xee>
  8004ed:	c6 45 e3 2d          	movb   $0x2d,0xffffffe3(%ebp)
  8004f1:	eb c3                	jmp    8004b6 <vprintfmt+0x75>
  8004f3:	83 c3 01             	add    $0x1,%ebx
  8004f6:	8b 75 e4             	mov    0xffffffe4(%ebp),%esi
  8004f9:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8004fc:	8d 44 42 d0          	lea    0xffffffd0(%edx,%eax,2),%eax
  800500:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  800503:	0f be 13             	movsbl (%ebx),%edx
  800506:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800509:	83 f8 09             	cmp    $0x9,%eax
  80050c:	77 21                	ja     80052f <vprintfmt+0xee>
  80050e:	eb e3                	jmp    8004f3 <vprintfmt+0xb2>
  800510:	8b 55 14             	mov    0x14(%ebp),%edx
  800513:	8d 42 04             	lea    0x4(%edx),%eax
  800516:	89 45 14             	mov    %eax,0x14(%ebp)
  800519:	8b 12                	mov    (%edx),%edx
  80051b:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  80051e:	eb 0f                	jmp    80052f <vprintfmt+0xee>
  800520:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800524:	79 90                	jns    8004b6 <vprintfmt+0x75>
  800526:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  80052d:	eb 87                	jmp    8004b6 <vprintfmt+0x75>
  80052f:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800533:	79 81                	jns    8004b6 <vprintfmt+0x75>
  800535:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  800538:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  80053b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  800542:	e9 6f ff ff ff       	jmp    8004b6 <vprintfmt+0x75>
  800547:	83 c1 01             	add    $0x1,%ecx
  80054a:	e9 67 ff ff ff       	jmp    8004b6 <vprintfmt+0x75>
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8d 50 04             	lea    0x4(%eax),%edx
  800555:	89 55 14             	mov    %edx,0x14(%ebp)
  800558:	8b 55 0c             	mov    0xc(%ebp),%edx
  80055b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80055f:	8b 00                	mov    (%eax),%eax
  800561:	89 04 24             	mov    %eax,(%esp)
  800564:	ff d7                	call   *%edi
  800566:	e9 ea fe ff ff       	jmp    800455 <vprintfmt+0x14>
  80056b:	8b 55 14             	mov    0x14(%ebp),%edx
  80056e:	8d 42 04             	lea    0x4(%edx),%eax
  800571:	89 45 14             	mov    %eax,0x14(%ebp)
  800574:	8b 02                	mov    (%edx),%eax
  800576:	89 c2                	mov    %eax,%edx
  800578:	c1 fa 1f             	sar    $0x1f,%edx
  80057b:	31 d0                	xor    %edx,%eax
  80057d:	29 d0                	sub    %edx,%eax
  80057f:	83 f8 0f             	cmp    $0xf,%eax
  800582:	7f 0b                	jg     80058f <vprintfmt+0x14e>
  800584:	8b 14 85 00 2d 80 00 	mov    0x802d00(,%eax,4),%edx
  80058b:	85 d2                	test   %edx,%edx
  80058d:	75 20                	jne    8005af <vprintfmt+0x16e>
  80058f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800593:	c7 44 24 08 74 2a 80 	movl   $0x802a74,0x8(%esp)
  80059a:	00 
  80059b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80059e:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005a2:	89 3c 24             	mov    %edi,(%esp)
  8005a5:	e8 f0 02 00 00       	call   80089a <printfmt>
  8005aa:	e9 a6 fe ff ff       	jmp    800455 <vprintfmt+0x14>
  8005af:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005b3:	c7 44 24 08 40 2e 80 	movl   $0x802e40,0x8(%esp)
  8005ba:	00 
  8005bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c2:	89 3c 24             	mov    %edi,(%esp)
  8005c5:	e8 d0 02 00 00       	call   80089a <printfmt>
  8005ca:	e9 86 fe ff ff       	jmp    800455 <vprintfmt+0x14>
  8005cf:	8b 75 ec             	mov    0xffffffec(%ebp),%esi
  8005d2:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  8005d5:	89 5d e8             	mov    %ebx,0xffffffe8(%ebp)
  8005d8:	8b 55 14             	mov    0x14(%ebp),%edx
  8005db:	8d 42 04             	lea    0x4(%edx),%eax
  8005de:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e1:	8b 12                	mov    (%edx),%edx
  8005e3:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  8005e6:	85 d2                	test   %edx,%edx
  8005e8:	75 07                	jne    8005f1 <vprintfmt+0x1b0>
  8005ea:	c7 45 d8 7d 2a 80 00 	movl   $0x802a7d,0xffffffd8(%ebp)
  8005f1:	85 f6                	test   %esi,%esi
  8005f3:	7e 40                	jle    800635 <vprintfmt+0x1f4>
  8005f5:	80 7d e3 2d          	cmpb   $0x2d,0xffffffe3(%ebp)
  8005f9:	74 3a                	je     800635 <vprintfmt+0x1f4>
  8005fb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005ff:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800602:	89 14 24             	mov    %edx,(%esp)
  800605:	e8 e6 02 00 00       	call   8008f0 <strnlen>
  80060a:	29 c6                	sub    %eax,%esi
  80060c:	89 75 ec             	mov    %esi,0xffffffec(%ebp)
  80060f:	85 f6                	test   %esi,%esi
  800611:	7e 22                	jle    800635 <vprintfmt+0x1f4>
  800613:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  800617:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  80061a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80061d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800621:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  800624:	89 04 24             	mov    %eax,(%esp)
  800627:	ff d7                	call   *%edi
  800629:	83 ee 01             	sub    $0x1,%esi
  80062c:	75 ec                	jne    80061a <vprintfmt+0x1d9>
  80062e:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  800635:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800638:	0f b6 02             	movzbl (%edx),%eax
  80063b:	0f be d0             	movsbl %al,%edx
  80063e:	8b 75 d8             	mov    0xffffffd8(%ebp),%esi
  800641:	84 c0                	test   %al,%al
  800643:	75 40                	jne    800685 <vprintfmt+0x244>
  800645:	eb 4a                	jmp    800691 <vprintfmt+0x250>
  800647:	83 7d dc 00          	cmpl   $0x0,0xffffffdc(%ebp)
  80064b:	74 1a                	je     800667 <vprintfmt+0x226>
  80064d:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  800650:	83 f8 5e             	cmp    $0x5e,%eax
  800653:	76 12                	jbe    800667 <vprintfmt+0x226>
  800655:	8b 45 0c             	mov    0xc(%ebp),%eax
  800658:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800663:	ff d7                	call   *%edi
  800665:	eb 0c                	jmp    800673 <vprintfmt+0x232>
  800667:	8b 45 0c             	mov    0xc(%ebp),%eax
  80066a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066e:	89 14 24             	mov    %edx,(%esp)
  800671:	ff d7                	call   *%edi
  800673:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  800677:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80067b:	83 c6 01             	add    $0x1,%esi
  80067e:	84 c0                	test   %al,%al
  800680:	74 0f                	je     800691 <vprintfmt+0x250>
  800682:	0f be d0             	movsbl %al,%edx
  800685:	83 7d e4 00          	cmpl   $0x0,0xffffffe4(%ebp)
  800689:	78 bc                	js     800647 <vprintfmt+0x206>
  80068b:	83 6d e4 01          	subl   $0x1,0xffffffe4(%ebp)
  80068f:	79 b6                	jns    800647 <vprintfmt+0x206>
  800691:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800695:	0f 8e ba fd ff ff    	jle    800455 <vprintfmt+0x14>
  80069b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80069e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006a2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006a9:	ff d7                	call   *%edi
  8006ab:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  8006af:	0f 84 9d fd ff ff    	je     800452 <vprintfmt+0x11>
  8006b5:	eb e4                	jmp    80069b <vprintfmt+0x25a>
  8006b7:	83 f9 01             	cmp    $0x1,%ecx
  8006ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8006c0:	7e 10                	jle    8006d2 <vprintfmt+0x291>
  8006c2:	8b 55 14             	mov    0x14(%ebp),%edx
  8006c5:	8d 42 08             	lea    0x8(%edx),%eax
  8006c8:	89 45 14             	mov    %eax,0x14(%ebp)
  8006cb:	8b 02                	mov    (%edx),%eax
  8006cd:	8b 52 04             	mov    0x4(%edx),%edx
  8006d0:	eb 26                	jmp    8006f8 <vprintfmt+0x2b7>
  8006d2:	85 c9                	test   %ecx,%ecx
  8006d4:	74 12                	je     8006e8 <vprintfmt+0x2a7>
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8d 50 04             	lea    0x4(%eax),%edx
  8006dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006df:	8b 00                	mov    (%eax),%eax
  8006e1:	89 c2                	mov    %eax,%edx
  8006e3:	c1 fa 1f             	sar    $0x1f,%edx
  8006e6:	eb 10                	jmp    8006f8 <vprintfmt+0x2b7>
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8d 50 04             	lea    0x4(%eax),%edx
  8006ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f1:	8b 00                	mov    (%eax),%eax
  8006f3:	89 c2                	mov    %eax,%edx
  8006f5:	c1 fa 1f             	sar    $0x1f,%edx
  8006f8:	89 d1                	mov    %edx,%ecx
  8006fa:	89 c2                	mov    %eax,%edx
  8006fc:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  8006ff:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  800702:	be 0a 00 00 00       	mov    $0xa,%esi
  800707:	85 c9                	test   %ecx,%ecx
  800709:	0f 89 92 00 00 00    	jns    8007a1 <vprintfmt+0x360>
  80070f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800712:	89 74 24 04          	mov    %esi,0x4(%esp)
  800716:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80071d:	ff d7                	call   *%edi
  80071f:	8b 55 d0             	mov    0xffffffd0(%ebp),%edx
  800722:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
  800725:	f7 da                	neg    %edx
  800727:	83 d1 00             	adc    $0x0,%ecx
  80072a:	f7 d9                	neg    %ecx
  80072c:	be 0a 00 00 00       	mov    $0xa,%esi
  800731:	eb 6e                	jmp    8007a1 <vprintfmt+0x360>
  800733:	8d 45 14             	lea    0x14(%ebp),%eax
  800736:	89 ca                	mov    %ecx,%edx
  800738:	e8 ab fc ff ff       	call   8003e8 <getuint>
  80073d:	89 d1                	mov    %edx,%ecx
  80073f:	89 c2                	mov    %eax,%edx
  800741:	be 0a 00 00 00       	mov    $0xa,%esi
  800746:	eb 59                	jmp    8007a1 <vprintfmt+0x360>
  800748:	8d 45 14             	lea    0x14(%ebp),%eax
  80074b:	89 ca                	mov    %ecx,%edx
  80074d:	e8 96 fc ff ff       	call   8003e8 <getuint>
  800752:	e9 fe fc ff ff       	jmp    800455 <vprintfmt+0x14>
  800757:	8b 45 0c             	mov    0xc(%ebp),%eax
  80075a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800765:	ff d7                	call   *%edi
  800767:	8b 55 0c             	mov    0xc(%ebp),%edx
  80076a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80076e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800775:	ff d7                	call   *%edi
  800777:	8b 55 14             	mov    0x14(%ebp),%edx
  80077a:	8d 42 04             	lea    0x4(%edx),%eax
  80077d:	89 45 14             	mov    %eax,0x14(%ebp)
  800780:	8b 12                	mov    (%edx),%edx
  800782:	b9 00 00 00 00       	mov    $0x0,%ecx
  800787:	be 10 00 00 00       	mov    $0x10,%esi
  80078c:	eb 13                	jmp    8007a1 <vprintfmt+0x360>
  80078e:	8d 45 14             	lea    0x14(%ebp),%eax
  800791:	89 ca                	mov    %ecx,%edx
  800793:	e8 50 fc ff ff       	call   8003e8 <getuint>
  800798:	89 d1                	mov    %edx,%ecx
  80079a:	89 c2                	mov    %eax,%edx
  80079c:	be 10 00 00 00       	mov    $0x10,%esi
  8007a1:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  8007a5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007a9:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  8007ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007b0:	89 74 24 08          	mov    %esi,0x8(%esp)
  8007b4:	89 14 24             	mov    %edx,(%esp)
  8007b7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007be:	89 f8                	mov    %edi,%eax
  8007c0:	e8 3b fb ff ff       	call   800300 <printnum>
  8007c5:	e9 8b fc ff ff       	jmp    800455 <vprintfmt+0x14>
  8007ca:	8b 75 0c             	mov    0xc(%ebp),%esi
  8007cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007d1:	89 14 24             	mov    %edx,(%esp)
  8007d4:	ff d7                	call   *%edi
  8007d6:	e9 7a fc ff ff       	jmp    800455 <vprintfmt+0x14>
  8007db:	89 de                	mov    %ebx,%esi
  8007dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007eb:	ff d7                	call   *%edi
  8007ed:	83 eb 01             	sub    $0x1,%ebx
  8007f0:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  8007f4:	0f 84 5b fc ff ff    	je     800455 <vprintfmt+0x14>
  8007fa:	8d 56 fd             	lea    0xfffffffd(%esi),%edx
  8007fd:	0f b6 02             	movzbl (%edx),%eax
  800800:	83 ea 01             	sub    $0x1,%edx
  800803:	3c 25                	cmp    $0x25,%al
  800805:	75 f6                	jne    8007fd <vprintfmt+0x3bc>
  800807:	8d 5a 02             	lea    0x2(%edx),%ebx
  80080a:	e9 46 fc ff ff       	jmp    800455 <vprintfmt+0x14>
  80080f:	83 c4 4c             	add    $0x4c,%esp
  800812:	5b                   	pop    %ebx
  800813:	5e                   	pop    %esi
  800814:	5f                   	pop    %edi
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	83 ec 28             	sub    $0x28,%esp
  80081d:	8b 55 08             	mov    0x8(%ebp),%edx
  800820:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800823:	85 d2                	test   %edx,%edx
  800825:	74 04                	je     80082b <vsnprintf+0x14>
  800827:	85 c0                	test   %eax,%eax
  800829:	7f 07                	jg     800832 <vsnprintf+0x1b>
  80082b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800830:	eb 3b                	jmp    80086d <vsnprintf+0x56>
  800832:	c7 45 fc 00 00 00 00 	movl   $0x0,0xfffffffc(%ebp)
  800839:	8d 44 02 ff          	lea    0xffffffff(%edx,%eax,1),%eax
  80083d:	89 45 f8             	mov    %eax,0xfffffff8(%ebp)
  800840:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800843:	8b 45 14             	mov    0x14(%ebp),%eax
  800846:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80084a:	8b 45 10             	mov    0x10(%ebp),%eax
  80084d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800851:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  800854:	89 44 24 04          	mov    %eax,0x4(%esp)
  800858:	c7 04 24 24 04 80 00 	movl   $0x800424,(%esp)
  80085f:	e8 dd fb ff ff       	call   800441 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800864:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  800867:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80086a:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
}
  80086d:	c9                   	leave  
  80086e:	c3                   	ret    

0080086f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800875:	8d 45 14             	lea    0x14(%ebp),%eax
  800878:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  80087b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80087f:	8b 45 10             	mov    0x10(%ebp),%eax
  800882:	89 44 24 08          	mov    %eax,0x8(%esp)
  800886:	8b 45 0c             	mov    0xc(%ebp),%eax
  800889:	89 44 24 04          	mov    %eax,0x4(%esp)
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	89 04 24             	mov    %eax,(%esp)
  800893:	e8 7f ff ff ff       	call   800817 <vsnprintf>
	va_end(ap);

	return rc;
}
  800898:	c9                   	leave  
  800899:	c3                   	ret    

0080089a <printfmt>:
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	83 ec 28             	sub    $0x28,%esp
  8008a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a3:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
  8008a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bb:	89 04 24             	mov    %eax,(%esp)
  8008be:	e8 7e fb ff ff       	call   800441 <vprintfmt>
  8008c3:	c9                   	leave  
  8008c4:	c3                   	ret    
	...

008008d0 <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008db:	80 3a 00             	cmpb   $0x0,(%edx)
  8008de:	74 0e                	je     8008ee <strlen+0x1e>
  8008e0:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008e5:	83 c0 01             	add    $0x1,%eax
  8008e8:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  8008ec:	75 f7                	jne    8008e5 <strlen+0x15>
	return n;
}
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008f9:	85 d2                	test   %edx,%edx
  8008fb:	74 19                	je     800916 <strnlen+0x26>
  8008fd:	80 39 00             	cmpb   $0x0,(%ecx)
  800900:	74 14                	je     800916 <strnlen+0x26>
  800902:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800907:	83 c0 01             	add    $0x1,%eax
  80090a:	39 d0                	cmp    %edx,%eax
  80090c:	74 0d                	je     80091b <strnlen+0x2b>
  80090e:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800912:	74 07                	je     80091b <strnlen+0x2b>
  800914:	eb f1                	jmp    800907 <strnlen+0x17>
  800916:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  80091b:	5d                   	pop    %ebp
  80091c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800920:	c3                   	ret    

00800921 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	53                   	push   %ebx
  800925:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800928:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092b:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80092d:	0f b6 01             	movzbl (%ecx),%eax
  800930:	88 02                	mov    %al,(%edx)
  800932:	83 c2 01             	add    $0x1,%edx
  800935:	83 c1 01             	add    $0x1,%ecx
  800938:	84 c0                	test   %al,%al
  80093a:	75 f1                	jne    80092d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80093c:	89 d8                	mov    %ebx,%eax
  80093e:	5b                   	pop    %ebx
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	57                   	push   %edi
  800945:	56                   	push   %esi
  800946:	53                   	push   %ebx
  800947:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80094d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800950:	85 f6                	test   %esi,%esi
  800952:	74 1c                	je     800970 <strncpy+0x2f>
  800954:	89 fa                	mov    %edi,%edx
  800956:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  80095b:	0f b6 01             	movzbl (%ecx),%eax
  80095e:	88 02                	mov    %al,(%edx)
  800960:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800963:	80 39 01             	cmpb   $0x1,(%ecx)
  800966:	83 d9 ff             	sbb    $0xffffffff,%ecx
  800969:	83 c3 01             	add    $0x1,%ebx
  80096c:	39 f3                	cmp    %esi,%ebx
  80096e:	75 eb                	jne    80095b <strncpy+0x1a>
	}
	return ret;
}
  800970:	89 f8                	mov    %edi,%eax
  800972:	5b                   	pop    %ebx
  800973:	5e                   	pop    %esi
  800974:	5f                   	pop    %edi
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	56                   	push   %esi
  80097b:	53                   	push   %ebx
  80097c:	8b 75 08             	mov    0x8(%ebp),%esi
  80097f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800982:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800985:	89 f0                	mov    %esi,%eax
  800987:	85 d2                	test   %edx,%edx
  800989:	74 2c                	je     8009b7 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  80098b:	89 d3                	mov    %edx,%ebx
  80098d:	83 eb 01             	sub    $0x1,%ebx
  800990:	74 20                	je     8009b2 <strlcpy+0x3b>
  800992:	0f b6 11             	movzbl (%ecx),%edx
  800995:	84 d2                	test   %dl,%dl
  800997:	74 19                	je     8009b2 <strlcpy+0x3b>
  800999:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  80099b:	88 10                	mov    %dl,(%eax)
  80099d:	83 c0 01             	add    $0x1,%eax
  8009a0:	83 eb 01             	sub    $0x1,%ebx
  8009a3:	74 0f                	je     8009b4 <strlcpy+0x3d>
  8009a5:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  8009a9:	83 c1 01             	add    $0x1,%ecx
  8009ac:	84 d2                	test   %dl,%dl
  8009ae:	74 04                	je     8009b4 <strlcpy+0x3d>
  8009b0:	eb e9                	jmp    80099b <strlcpy+0x24>
  8009b2:	89 f0                	mov    %esi,%eax
		*dst = '\0';
  8009b4:	c6 00 00             	movb   $0x0,(%eax)
  8009b7:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8009b9:	5b                   	pop    %ebx
  8009ba:	5e                   	pop    %esi
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	57                   	push   %edi
  8009c1:	56                   	push   %esi
  8009c2:	53                   	push   %ebx
  8009c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8009c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c9:	8b 7d 10             	mov    0x10(%ebp),%edi
    int c;
    char *q = buf;

    if (buf_size <= 0)
  8009cc:	85 c9                	test   %ecx,%ecx
  8009ce:	7e 30                	jle    800a00 <pstrcpy+0x43>
        return;

    for(;;) {
        c = *str++;
  8009d0:	0f b6 07             	movzbl (%edi),%eax
        if (c == 0 || q >= buf + buf_size - 1)
  8009d3:	84 c0                	test   %al,%al
  8009d5:	74 26                	je     8009fd <pstrcpy+0x40>
  8009d7:	8d 74 0a ff          	lea    0xffffffff(%edx,%ecx,1),%esi
  8009db:	0f be d8             	movsbl %al,%ebx
  8009de:	89 f9                	mov    %edi,%ecx
  8009e0:	39 f2                	cmp    %esi,%edx
  8009e2:	72 09                	jb     8009ed <pstrcpy+0x30>
  8009e4:	eb 17                	jmp    8009fd <pstrcpy+0x40>
  8009e6:	83 c1 01             	add    $0x1,%ecx
  8009e9:	39 f2                	cmp    %esi,%edx
  8009eb:	73 10                	jae    8009fd <pstrcpy+0x40>
            break;
        *q++ = c;
  8009ed:	88 1a                	mov    %bl,(%edx)
  8009ef:	83 c2 01             	add    $0x1,%edx
  8009f2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  8009f6:	0f be d8             	movsbl %al,%ebx
  8009f9:	84 c0                	test   %al,%al
  8009fb:	75 e9                	jne    8009e6 <pstrcpy+0x29>
    }
    *q = '\0';
  8009fd:	c6 02 00             	movb   $0x0,(%edx)
}
  800a00:	5b                   	pop    %ebx
  800a01:	5e                   	pop    %esi
  800a02:	5f                   	pop    %edi
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	8b 55 08             	mov    0x8(%ebp),%edx
  800a0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  800a0e:	0f b6 02             	movzbl (%edx),%eax
  800a11:	84 c0                	test   %al,%al
  800a13:	74 16                	je     800a2b <strcmp+0x26>
  800a15:	3a 01                	cmp    (%ecx),%al
  800a17:	75 12                	jne    800a2b <strcmp+0x26>
		p++, q++;
  800a19:	83 c1 01             	add    $0x1,%ecx
  800a1c:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  800a20:	84 c0                	test   %al,%al
  800a22:	74 07                	je     800a2b <strcmp+0x26>
  800a24:	83 c2 01             	add    $0x1,%edx
  800a27:	3a 01                	cmp    (%ecx),%al
  800a29:	74 ee                	je     800a19 <strcmp+0x14>
  800a2b:	0f b6 c0             	movzbl %al,%eax
  800a2e:	0f b6 11             	movzbl (%ecx),%edx
  800a31:	29 d0                	sub    %edx,%eax
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	53                   	push   %ebx
  800a39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a3f:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800a42:	85 d2                	test   %edx,%edx
  800a44:	74 2d                	je     800a73 <strncmp+0x3e>
  800a46:	0f b6 01             	movzbl (%ecx),%eax
  800a49:	84 c0                	test   %al,%al
  800a4b:	74 1a                	je     800a67 <strncmp+0x32>
  800a4d:	3a 03                	cmp    (%ebx),%al
  800a4f:	75 16                	jne    800a67 <strncmp+0x32>
  800a51:	83 ea 01             	sub    $0x1,%edx
  800a54:	74 1d                	je     800a73 <strncmp+0x3e>
		n--, p++, q++;
  800a56:	83 c1 01             	add    $0x1,%ecx
  800a59:	83 c3 01             	add    $0x1,%ebx
  800a5c:	0f b6 01             	movzbl (%ecx),%eax
  800a5f:	84 c0                	test   %al,%al
  800a61:	74 04                	je     800a67 <strncmp+0x32>
  800a63:	3a 03                	cmp    (%ebx),%al
  800a65:	74 ea                	je     800a51 <strncmp+0x1c>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a67:	0f b6 11             	movzbl (%ecx),%edx
  800a6a:	0f b6 03             	movzbl (%ebx),%eax
  800a6d:	29 c2                	sub    %eax,%edx
  800a6f:	89 d0                	mov    %edx,%eax
  800a71:	eb 05                	jmp    800a78 <strncmp+0x43>
  800a73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a78:	5b                   	pop    %ebx
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a81:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a85:	0f b6 10             	movzbl (%eax),%edx
  800a88:	84 d2                	test   %dl,%dl
  800a8a:	74 16                	je     800aa2 <strchr+0x27>
		if (*s == c)
  800a8c:	38 ca                	cmp    %cl,%dl
  800a8e:	75 06                	jne    800a96 <strchr+0x1b>
  800a90:	eb 15                	jmp    800aa7 <strchr+0x2c>
  800a92:	38 ca                	cmp    %cl,%dl
  800a94:	74 11                	je     800aa7 <strchr+0x2c>
  800a96:	83 c0 01             	add    $0x1,%eax
  800a99:	0f b6 10             	movzbl (%eax),%edx
  800a9c:	84 d2                	test   %dl,%dl
  800a9e:	66 90                	xchg   %ax,%ax
  800aa0:	75 f0                	jne    800a92 <strchr+0x17>
  800aa2:	b8 00 00 00 00       	mov    $0x0,%eax
			return (char *) s;
	return 0;
}
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ab3:	0f b6 10             	movzbl (%eax),%edx
  800ab6:	84 d2                	test   %dl,%dl
  800ab8:	74 14                	je     800ace <strfind+0x25>
		if (*s == c)
  800aba:	38 ca                	cmp    %cl,%dl
  800abc:	75 06                	jne    800ac4 <strfind+0x1b>
  800abe:	eb 0e                	jmp    800ace <strfind+0x25>
  800ac0:	38 ca                	cmp    %cl,%dl
  800ac2:	74 0a                	je     800ace <strfind+0x25>
  800ac4:	83 c0 01             	add    $0x1,%eax
  800ac7:	0f b6 10             	movzbl (%eax),%edx
  800aca:	84 d2                	test   %dl,%dl
  800acc:	75 f2                	jne    800ac0 <strfind+0x17>
			break;
	return (char *) s;
}
  800ace:	5d                   	pop    %ebp
  800acf:	90                   	nop    
  800ad0:	c3                   	ret    

00800ad1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	83 ec 08             	sub    $0x8,%esp
  800ad7:	89 1c 24             	mov    %ebx,(%esp)
  800ada:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ade:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ae1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800ae7:	85 db                	test   %ebx,%ebx
  800ae9:	74 32                	je     800b1d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aeb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800af1:	75 25                	jne    800b18 <memset+0x47>
  800af3:	f6 c3 03             	test   $0x3,%bl
  800af6:	75 20                	jne    800b18 <memset+0x47>
		c &= 0xFF;
  800af8:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800afb:	89 d0                	mov    %edx,%eax
  800afd:	c1 e0 18             	shl    $0x18,%eax
  800b00:	89 d1                	mov    %edx,%ecx
  800b02:	c1 e1 10             	shl    $0x10,%ecx
  800b05:	09 c8                	or     %ecx,%eax
  800b07:	09 d0                	or     %edx,%eax
  800b09:	c1 e2 08             	shl    $0x8,%edx
  800b0c:	09 d0                	or     %edx,%eax
  800b0e:	89 d9                	mov    %ebx,%ecx
  800b10:	c1 e9 02             	shr    $0x2,%ecx
  800b13:	fc                   	cld    
  800b14:	f3 ab                	rep stos %eax,%es:(%edi)
  800b16:	eb 05                	jmp    800b1d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b18:	89 d9                	mov    %ebx,%ecx
  800b1a:	fc                   	cld    
  800b1b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b1d:	89 f8                	mov    %edi,%eax
  800b1f:	8b 1c 24             	mov    (%esp),%ebx
  800b22:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b26:	89 ec                	mov    %ebp,%esp
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    

00800b2a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	83 ec 08             	sub    $0x8,%esp
  800b30:	89 34 24             	mov    %esi,(%esp)
  800b33:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b37:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800b3d:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b40:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b42:	39 c6                	cmp    %eax,%esi
  800b44:	73 36                	jae    800b7c <memmove+0x52>
  800b46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b49:	39 d0                	cmp    %edx,%eax
  800b4b:	73 2f                	jae    800b7c <memmove+0x52>
		s += n;
		d += n;
  800b4d:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b50:	f6 c2 03             	test   $0x3,%dl
  800b53:	75 1b                	jne    800b70 <memmove+0x46>
  800b55:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b5b:	75 13                	jne    800b70 <memmove+0x46>
  800b5d:	f6 c1 03             	test   $0x3,%cl
  800b60:	75 0e                	jne    800b70 <memmove+0x46>
			asm volatile("std; rep movsl\n"
  800b62:	8d 7e fc             	lea    0xfffffffc(%esi),%edi
  800b65:	8d 72 fc             	lea    0xfffffffc(%edx),%esi
  800b68:	c1 e9 02             	shr    $0x2,%ecx
  800b6b:	fd                   	std    
  800b6c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b6e:	eb 09                	jmp    800b79 <memmove+0x4f>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b70:	8d 7e ff             	lea    0xffffffff(%esi),%edi
  800b73:	8d 72 ff             	lea    0xffffffff(%edx),%esi
  800b76:	fd                   	std    
  800b77:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b79:	fc                   	cld    
  800b7a:	eb 21                	jmp    800b9d <memmove+0x73>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b7c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b82:	75 16                	jne    800b9a <memmove+0x70>
  800b84:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b8a:	75 0e                	jne    800b9a <memmove+0x70>
  800b8c:	f6 c1 03             	test   $0x3,%cl
  800b8f:	90                   	nop    
  800b90:	75 08                	jne    800b9a <memmove+0x70>
			asm volatile("cld; rep movsl\n"
  800b92:	c1 e9 02             	shr    $0x2,%ecx
  800b95:	fc                   	cld    
  800b96:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b98:	eb 03                	jmp    800b9d <memmove+0x73>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b9a:	fc                   	cld    
  800b9b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b9d:	8b 34 24             	mov    (%esp),%esi
  800ba0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ba4:	89 ec                	mov    %ebp,%esp
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    

00800ba8 <memcpy>:

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
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bae:	8b 45 10             	mov    0x10(%ebp),%eax
  800bb1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bb5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbf:	89 04 24             	mov    %eax,(%esp)
  800bc2:	e8 63 ff ff ff       	call   800b2a <memmove>
}
  800bc7:	c9                   	leave  
  800bc8:	c3                   	ret    

00800bc9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	56                   	push   %esi
  800bcd:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bce:	8b 75 10             	mov    0x10(%ebp),%esi
  800bd1:	83 ee 01             	sub    $0x1,%esi
  800bd4:	83 fe ff             	cmp    $0xffffffff,%esi
  800bd7:	74 38                	je     800c11 <memcmp+0x48>
  800bd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdc:	8b 55 0c             	mov    0xc(%ebp),%edx
		if (*s1 != *s2)
  800bdf:	0f b6 18             	movzbl (%eax),%ebx
  800be2:	0f b6 0a             	movzbl (%edx),%ecx
  800be5:	38 cb                	cmp    %cl,%bl
  800be7:	74 20                	je     800c09 <memcmp+0x40>
  800be9:	eb 12                	jmp    800bfd <memcmp+0x34>
  800beb:	0f b6 58 01          	movzbl 0x1(%eax),%ebx
  800bef:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
  800bf3:	83 c0 01             	add    $0x1,%eax
  800bf6:	83 c2 01             	add    $0x1,%edx
  800bf9:	38 cb                	cmp    %cl,%bl
  800bfb:	74 0c                	je     800c09 <memcmp+0x40>
			return (int) *s1 - (int) *s2;
  800bfd:	0f b6 d3             	movzbl %bl,%edx
  800c00:	0f b6 c1             	movzbl %cl,%eax
  800c03:	29 c2                	sub    %eax,%edx
  800c05:	89 d0                	mov    %edx,%eax
  800c07:	eb 0d                	jmp    800c16 <memcmp+0x4d>
  800c09:	83 ee 01             	sub    $0x1,%esi
  800c0c:	83 fe ff             	cmp    $0xffffffff,%esi
  800c0f:	75 da                	jne    800beb <memcmp+0x22>
  800c11:	b8 00 00 00 00       	mov    $0x0,%eax
		s1++, s2++;
	}

	return 0;
}
  800c16:	5b                   	pop    %ebx
  800c17:	5e                   	pop    %esi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	53                   	push   %ebx
  800c1e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800c21:	89 da                	mov    %ebx,%edx
  800c23:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c26:	39 d3                	cmp    %edx,%ebx
  800c28:	73 1a                	jae    800c44 <memfind+0x2a>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c2a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
			break;
  800c2e:	89 d8                	mov    %ebx,%eax
  800c30:	38 0b                	cmp    %cl,(%ebx)
  800c32:	75 06                	jne    800c3a <memfind+0x20>
  800c34:	eb 0e                	jmp    800c44 <memfind+0x2a>
  800c36:	38 08                	cmp    %cl,(%eax)
  800c38:	74 0c                	je     800c46 <memfind+0x2c>
  800c3a:	83 c0 01             	add    $0x1,%eax
  800c3d:	39 d0                	cmp    %edx,%eax
  800c3f:	90                   	nop    
  800c40:	75 f4                	jne    800c36 <memfind+0x1c>
  800c42:	eb 02                	jmp    800c46 <memfind+0x2c>
  800c44:	89 d8                	mov    %ebx,%eax
	return (void *) s;
}
  800c46:	5b                   	pop    %ebx
  800c47:	5d                   	pop    %ebp
  800c48:	c3                   	ret    

00800c49 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	57                   	push   %edi
  800c4d:	56                   	push   %esi
  800c4e:	53                   	push   %ebx
  800c4f:	83 ec 04             	sub    $0x4,%esp
  800c52:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c55:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c58:	0f b6 03             	movzbl (%ebx),%eax
  800c5b:	3c 20                	cmp    $0x20,%al
  800c5d:	74 04                	je     800c63 <strtol+0x1a>
  800c5f:	3c 09                	cmp    $0x9,%al
  800c61:	75 0e                	jne    800c71 <strtol+0x28>
		s++;
  800c63:	83 c3 01             	add    $0x1,%ebx
  800c66:	0f b6 03             	movzbl (%ebx),%eax
  800c69:	3c 20                	cmp    $0x20,%al
  800c6b:	74 f6                	je     800c63 <strtol+0x1a>
  800c6d:	3c 09                	cmp    $0x9,%al
  800c6f:	74 f2                	je     800c63 <strtol+0x1a>

	// plus/minus sign
	if (*s == '+')
  800c71:	3c 2b                	cmp    $0x2b,%al
  800c73:	75 0d                	jne    800c82 <strtol+0x39>
		s++;
  800c75:	83 c3 01             	add    $0x1,%ebx
  800c78:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800c7f:	90                   	nop    
  800c80:	eb 15                	jmp    800c97 <strtol+0x4e>
	else if (*s == '-')
  800c82:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800c89:	3c 2d                	cmp    $0x2d,%al
  800c8b:	75 0a                	jne    800c97 <strtol+0x4e>
		s++, neg = 1;
  800c8d:	83 c3 01             	add    $0x1,%ebx
  800c90:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c97:	85 f6                	test   %esi,%esi
  800c99:	0f 94 c0             	sete   %al
  800c9c:	84 c0                	test   %al,%al
  800c9e:	75 05                	jne    800ca5 <strtol+0x5c>
  800ca0:	83 fe 10             	cmp    $0x10,%esi
  800ca3:	75 17                	jne    800cbc <strtol+0x73>
  800ca5:	80 3b 30             	cmpb   $0x30,(%ebx)
  800ca8:	75 12                	jne    800cbc <strtol+0x73>
  800caa:	80 7b 01 78          	cmpb   $0x78,0x1(%ebx)
  800cae:	66 90                	xchg   %ax,%ax
  800cb0:	75 0a                	jne    800cbc <strtol+0x73>
		s += 2, base = 16;
  800cb2:	83 c3 02             	add    $0x2,%ebx
  800cb5:	be 10 00 00 00       	mov    $0x10,%esi
  800cba:	eb 1f                	jmp    800cdb <strtol+0x92>
	else if (base == 0 && s[0] == '0')
  800cbc:	85 f6                	test   %esi,%esi
  800cbe:	66 90                	xchg   %ax,%ax
  800cc0:	75 10                	jne    800cd2 <strtol+0x89>
  800cc2:	80 3b 30             	cmpb   $0x30,(%ebx)
  800cc5:	75 0b                	jne    800cd2 <strtol+0x89>
		s++, base = 8;
  800cc7:	83 c3 01             	add    $0x1,%ebx
  800cca:	66 be 08 00          	mov    $0x8,%si
  800cce:	66 90                	xchg   %ax,%ax
  800cd0:	eb 09                	jmp    800cdb <strtol+0x92>
	else if (base == 0)
  800cd2:	84 c0                	test   %al,%al
  800cd4:	74 05                	je     800cdb <strtol+0x92>
  800cd6:	be 0a 00 00 00       	mov    $0xa,%esi
  800cdb:	bf 00 00 00 00       	mov    $0x0,%edi
		base = 10;

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ce0:	0f b6 13             	movzbl (%ebx),%edx
  800ce3:	89 d1                	mov    %edx,%ecx
  800ce5:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800ce8:	3c 09                	cmp    $0x9,%al
  800cea:	77 08                	ja     800cf4 <strtol+0xab>
			dig = *s - '0';
  800cec:	0f be c2             	movsbl %dl,%eax
  800cef:	8d 50 d0             	lea    0xffffffd0(%eax),%edx
  800cf2:	eb 1c                	jmp    800d10 <strtol+0xc7>
		else if (*s >= 'a' && *s <= 'z')
  800cf4:	8d 41 9f             	lea    0xffffff9f(%ecx),%eax
  800cf7:	3c 19                	cmp    $0x19,%al
  800cf9:	77 08                	ja     800d03 <strtol+0xba>
			dig = *s - 'a' + 10;
  800cfb:	0f be c2             	movsbl %dl,%eax
  800cfe:	8d 50 a9             	lea    0xffffffa9(%eax),%edx
  800d01:	eb 0d                	jmp    800d10 <strtol+0xc7>
		else if (*s >= 'A' && *s <= 'Z')
  800d03:	8d 41 bf             	lea    0xffffffbf(%ecx),%eax
  800d06:	3c 19                	cmp    $0x19,%al
  800d08:	77 17                	ja     800d21 <strtol+0xd8>
			dig = *s - 'A' + 10;
  800d0a:	0f be c2             	movsbl %dl,%eax
  800d0d:	8d 50 c9             	lea    0xffffffc9(%eax),%edx
		else
			break;
		if (dig >= base)
  800d10:	39 f2                	cmp    %esi,%edx
  800d12:	7d 0d                	jge    800d21 <strtol+0xd8>
			break;
		s++, val = (val * base) + dig;
  800d14:	83 c3 01             	add    $0x1,%ebx
  800d17:	89 f8                	mov    %edi,%eax
  800d19:	0f af c6             	imul   %esi,%eax
  800d1c:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800d1f:	eb bf                	jmp    800ce0 <strtol+0x97>
		// we don't properly detect overflow!
	}
  800d21:	89 f8                	mov    %edi,%eax

	if (endptr)
  800d23:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d27:	74 05                	je     800d2e <strtol+0xe5>
		*endptr = (char *) s;
  800d29:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d2c:	89 1a                	mov    %ebx,(%edx)
	return (neg ? -val : val);
  800d2e:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800d32:	74 04                	je     800d38 <strtol+0xef>
  800d34:	89 c7                	mov    %eax,%edi
  800d36:	f7 df                	neg    %edi
}
  800d38:	89 f8                	mov    %edi,%eax
  800d3a:	83 c4 04             	add    $0x4,%esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    
	...

00800d44 <sys_cgetc>:
}

int
sys_cgetc(void)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	83 ec 0c             	sub    $0xc,%esp
  800d4a:	89 1c 24             	mov    %ebx,(%esp)
  800d4d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d51:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d55:	b8 01 00 00 00       	mov    $0x1,%eax
  800d5a:	bf 00 00 00 00       	mov    $0x0,%edi
  800d5f:	89 fa                	mov    %edi,%edx
  800d61:	89 f9                	mov    %edi,%ecx
  800d63:	89 fb                	mov    %edi,%ebx
  800d65:	89 fe                	mov    %edi,%esi
  800d67:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d69:	8b 1c 24             	mov    (%esp),%ebx
  800d6c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d70:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d74:	89 ec                	mov    %ebp,%esp
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <sys_cputs>:
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	83 ec 0c             	sub    $0xc,%esp
  800d7e:	89 1c 24             	mov    %ebx,(%esp)
  800d81:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d85:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d89:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8f:	bf 00 00 00 00       	mov    $0x0,%edi
  800d94:	89 f8                	mov    %edi,%eax
  800d96:	89 fb                	mov    %edi,%ebx
  800d98:	89 fe                	mov    %edi,%esi
  800d9a:	cd 30                	int    $0x30
  800d9c:	8b 1c 24             	mov    (%esp),%ebx
  800d9f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800da3:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800da7:	89 ec                	mov    %ebp,%esp
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <sys_time_msec>:

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
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	83 ec 0c             	sub    $0xc,%esp
  800db1:	89 1c 24             	mov    %ebx,(%esp)
  800db4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800db8:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800dbc:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dc1:	bf 00 00 00 00       	mov    $0x0,%edi
  800dc6:	89 fa                	mov    %edi,%edx
  800dc8:	89 f9                	mov    %edi,%ecx
  800dca:	89 fb                	mov    %edi,%ebx
  800dcc:	89 fe                	mov    %edi,%esi
  800dce:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dd0:	8b 1c 24             	mov    (%esp),%ebx
  800dd3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800dd7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ddb:	89 ec                	mov    %ebp,%esp
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    

00800ddf <sys_ipc_recv>:
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	83 ec 28             	sub    $0x28,%esp
  800de5:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800de8:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800deb:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800dee:	8b 55 08             	mov    0x8(%ebp),%edx
  800df1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800df6:	bf 00 00 00 00       	mov    $0x0,%edi
  800dfb:	89 f9                	mov    %edi,%ecx
  800dfd:	89 fb                	mov    %edi,%ebx
  800dff:	89 fe                	mov    %edi,%esi
  800e01:	cd 30                	int    $0x30
  800e03:	85 c0                	test   %eax,%eax
  800e05:	7e 28                	jle    800e2f <sys_ipc_recv+0x50>
  800e07:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e0b:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e12:	00 
  800e13:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  800e1a:	00 
  800e1b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e22:	00 
  800e23:	c7 04 24 7c 2d 80 00 	movl   $0x802d7c,(%esp)
  800e2a:	e8 a5 f3 ff ff       	call   8001d4 <_panic>
  800e2f:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800e32:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800e35:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800e38:	89 ec                	mov    %ebp,%esp
  800e3a:	5d                   	pop    %ebp
  800e3b:	c3                   	ret    

00800e3c <sys_ipc_try_send>:
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	83 ec 0c             	sub    $0xc,%esp
  800e42:	89 1c 24             	mov    %ebx,(%esp)
  800e45:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e49:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e53:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e56:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e59:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e5e:	be 00 00 00 00       	mov    $0x0,%esi
  800e63:	cd 30                	int    $0x30
  800e65:	8b 1c 24             	mov    (%esp),%ebx
  800e68:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e6c:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e70:	89 ec                	mov    %ebp,%esp
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    

00800e74 <sys_env_set_pgfault_upcall>:
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	83 ec 28             	sub    $0x28,%esp
  800e7a:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800e7d:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800e80:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800e83:	8b 55 08             	mov    0x8(%ebp),%edx
  800e86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e89:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e8e:	bf 00 00 00 00       	mov    $0x0,%edi
  800e93:	89 fb                	mov    %edi,%ebx
  800e95:	89 fe                	mov    %edi,%esi
  800e97:	cd 30                	int    $0x30
  800e99:	85 c0                	test   %eax,%eax
  800e9b:	7e 28                	jle    800ec5 <sys_env_set_pgfault_upcall+0x51>
  800e9d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea1:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ea8:	00 
  800ea9:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  800eb0:	00 
  800eb1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eb8:	00 
  800eb9:	c7 04 24 7c 2d 80 00 	movl   $0x802d7c,(%esp)
  800ec0:	e8 0f f3 ff ff       	call   8001d4 <_panic>
  800ec5:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800ec8:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800ecb:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800ece:	89 ec                	mov    %ebp,%esp
  800ed0:	5d                   	pop    %ebp
  800ed1:	c3                   	ret    

00800ed2 <sys_env_set_trapframe>:
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	83 ec 28             	sub    $0x28,%esp
  800ed8:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800edb:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800ede:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800ee1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee7:	b8 09 00 00 00       	mov    $0x9,%eax
  800eec:	bf 00 00 00 00       	mov    $0x0,%edi
  800ef1:	89 fb                	mov    %edi,%ebx
  800ef3:	89 fe                	mov    %edi,%esi
  800ef5:	cd 30                	int    $0x30
  800ef7:	85 c0                	test   %eax,%eax
  800ef9:	7e 28                	jle    800f23 <sys_env_set_trapframe+0x51>
  800efb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eff:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f06:	00 
  800f07:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  800f0e:	00 
  800f0f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f16:	00 
  800f17:	c7 04 24 7c 2d 80 00 	movl   $0x802d7c,(%esp)
  800f1e:	e8 b1 f2 ff ff       	call   8001d4 <_panic>
  800f23:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800f26:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800f29:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800f2c:	89 ec                	mov    %ebp,%esp
  800f2e:	5d                   	pop    %ebp
  800f2f:	c3                   	ret    

00800f30 <sys_env_set_status>:
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	83 ec 28             	sub    $0x28,%esp
  800f36:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800f39:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800f3c:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800f3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f45:	b8 08 00 00 00       	mov    $0x8,%eax
  800f4a:	bf 00 00 00 00       	mov    $0x0,%edi
  800f4f:	89 fb                	mov    %edi,%ebx
  800f51:	89 fe                	mov    %edi,%esi
  800f53:	cd 30                	int    $0x30
  800f55:	85 c0                	test   %eax,%eax
  800f57:	7e 28                	jle    800f81 <sys_env_set_status+0x51>
  800f59:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f5d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f64:	00 
  800f65:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  800f6c:	00 
  800f6d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f74:	00 
  800f75:	c7 04 24 7c 2d 80 00 	movl   $0x802d7c,(%esp)
  800f7c:	e8 53 f2 ff ff       	call   8001d4 <_panic>
  800f81:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800f84:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800f87:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800f8a:	89 ec                	mov    %ebp,%esp
  800f8c:	5d                   	pop    %ebp
  800f8d:	c3                   	ret    

00800f8e <sys_page_unmap>:
  800f8e:	55                   	push   %ebp
  800f8f:	89 e5                	mov    %esp,%ebp
  800f91:	83 ec 28             	sub    $0x28,%esp
  800f94:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800f97:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800f9a:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800f9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa3:	b8 06 00 00 00       	mov    $0x6,%eax
  800fa8:	bf 00 00 00 00       	mov    $0x0,%edi
  800fad:	89 fb                	mov    %edi,%ebx
  800faf:	89 fe                	mov    %edi,%esi
  800fb1:	cd 30                	int    $0x30
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	7e 28                	jle    800fdf <sys_page_unmap+0x51>
  800fb7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fbb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800fc2:	00 
  800fc3:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  800fca:	00 
  800fcb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fd2:	00 
  800fd3:	c7 04 24 7c 2d 80 00 	movl   $0x802d7c,(%esp)
  800fda:	e8 f5 f1 ff ff       	call   8001d4 <_panic>
  800fdf:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800fe2:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800fe5:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800fe8:	89 ec                	mov    %ebp,%esp
  800fea:	5d                   	pop    %ebp
  800feb:	c3                   	ret    

00800fec <sys_page_map>:
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	83 ec 28             	sub    $0x28,%esp
  800ff2:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800ff5:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800ff8:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800ffb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801001:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801004:	8b 7d 14             	mov    0x14(%ebp),%edi
  801007:	8b 75 18             	mov    0x18(%ebp),%esi
  80100a:	b8 05 00 00 00       	mov    $0x5,%eax
  80100f:	cd 30                	int    $0x30
  801011:	85 c0                	test   %eax,%eax
  801013:	7e 28                	jle    80103d <sys_page_map+0x51>
  801015:	89 44 24 10          	mov    %eax,0x10(%esp)
  801019:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801020:	00 
  801021:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  801028:	00 
  801029:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801030:	00 
  801031:	c7 04 24 7c 2d 80 00 	movl   $0x802d7c,(%esp)
  801038:	e8 97 f1 ff ff       	call   8001d4 <_panic>
  80103d:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801040:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801043:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801046:	89 ec                	mov    %ebp,%esp
  801048:	5d                   	pop    %ebp
  801049:	c3                   	ret    

0080104a <sys_page_alloc>:
  80104a:	55                   	push   %ebp
  80104b:	89 e5                	mov    %esp,%ebp
  80104d:	83 ec 28             	sub    $0x28,%esp
  801050:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  801053:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  801056:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  801059:	8b 55 08             	mov    0x8(%ebp),%edx
  80105c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80105f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801062:	b8 04 00 00 00       	mov    $0x4,%eax
  801067:	bf 00 00 00 00       	mov    $0x0,%edi
  80106c:	89 fe                	mov    %edi,%esi
  80106e:	cd 30                	int    $0x30
  801070:	85 c0                	test   %eax,%eax
  801072:	7e 28                	jle    80109c <sys_page_alloc+0x52>
  801074:	89 44 24 10          	mov    %eax,0x10(%esp)
  801078:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80107f:	00 
  801080:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  801087:	00 
  801088:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80108f:	00 
  801090:	c7 04 24 7c 2d 80 00 	movl   $0x802d7c,(%esp)
  801097:	e8 38 f1 ff ff       	call   8001d4 <_panic>
  80109c:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  80109f:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  8010a2:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  8010a5:	89 ec                	mov    %ebp,%esp
  8010a7:	5d                   	pop    %ebp
  8010a8:	c3                   	ret    

008010a9 <sys_yield>:
  8010a9:	55                   	push   %ebp
  8010aa:	89 e5                	mov    %esp,%ebp
  8010ac:	83 ec 0c             	sub    $0xc,%esp
  8010af:	89 1c 24             	mov    %ebx,(%esp)
  8010b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010b6:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010ba:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010bf:	bf 00 00 00 00       	mov    $0x0,%edi
  8010c4:	89 fa                	mov    %edi,%edx
  8010c6:	89 f9                	mov    %edi,%ecx
  8010c8:	89 fb                	mov    %edi,%ebx
  8010ca:	89 fe                	mov    %edi,%esi
  8010cc:	cd 30                	int    $0x30
  8010ce:	8b 1c 24             	mov    (%esp),%ebx
  8010d1:	8b 74 24 04          	mov    0x4(%esp),%esi
  8010d5:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8010d9:	89 ec                	mov    %ebp,%esp
  8010db:	5d                   	pop    %ebp
  8010dc:	c3                   	ret    

008010dd <sys_getenvid>:
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	83 ec 0c             	sub    $0xc,%esp
  8010e3:	89 1c 24             	mov    %ebx,(%esp)
  8010e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010ea:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010ee:	b8 02 00 00 00       	mov    $0x2,%eax
  8010f3:	bf 00 00 00 00       	mov    $0x0,%edi
  8010f8:	89 fa                	mov    %edi,%edx
  8010fa:	89 f9                	mov    %edi,%ecx
  8010fc:	89 fb                	mov    %edi,%ebx
  8010fe:	89 fe                	mov    %edi,%esi
  801100:	cd 30                	int    $0x30
  801102:	8b 1c 24             	mov    (%esp),%ebx
  801105:	8b 74 24 04          	mov    0x4(%esp),%esi
  801109:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80110d:	89 ec                	mov    %ebp,%esp
  80110f:	5d                   	pop    %ebp
  801110:	c3                   	ret    

00801111 <sys_env_destroy>:
  801111:	55                   	push   %ebp
  801112:	89 e5                	mov    %esp,%ebp
  801114:	83 ec 28             	sub    $0x28,%esp
  801117:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  80111a:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  80111d:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  801120:	8b 55 08             	mov    0x8(%ebp),%edx
  801123:	b8 03 00 00 00       	mov    $0x3,%eax
  801128:	bf 00 00 00 00       	mov    $0x0,%edi
  80112d:	89 f9                	mov    %edi,%ecx
  80112f:	89 fb                	mov    %edi,%ebx
  801131:	89 fe                	mov    %edi,%esi
  801133:	cd 30                	int    $0x30
  801135:	85 c0                	test   %eax,%eax
  801137:	7e 28                	jle    801161 <sys_env_destroy+0x50>
  801139:	89 44 24 10          	mov    %eax,0x10(%esp)
  80113d:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801144:	00 
  801145:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  80114c:	00 
  80114d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801154:	00 
  801155:	c7 04 24 7c 2d 80 00 	movl   $0x802d7c,(%esp)
  80115c:	e8 73 f0 ff ff       	call   8001d4 <_panic>
  801161:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801164:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801167:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  80116a:	89 ec                	mov    %ebp,%esp
  80116c:	5d                   	pop    %ebp
  80116d:	c3                   	ret    
	...

00801170 <fd2num>:
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	8b 45 08             	mov    0x8(%ebp),%eax
  801176:	05 00 00 00 30       	add    $0x30000000,%eax
  80117b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80117e:	5d                   	pop    %ebp
  80117f:	c3                   	ret    

00801180 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801186:	8b 45 08             	mov    0x8(%ebp),%eax
  801189:	89 04 24             	mov    %eax,(%esp)
  80118c:	e8 df ff ff ff       	call   801170 <fd2num>
  801191:	c1 e0 0c             	shl    $0xc,%eax
  801194:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801199:	c9                   	leave  
  80119a:	c3                   	ret    

0080119b <fd_alloc>:

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
  80119b:	55                   	push   %ebp
  80119c:	89 e5                	mov    %esp,%ebp
  80119e:	53                   	push   %ebx
  80119f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8011a2:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  8011a7:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  8011a9:	89 d0                	mov    %edx,%eax
  8011ab:	c1 e8 16             	shr    $0x16,%eax
  8011ae:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  8011b5:	a8 01                	test   $0x1,%al
  8011b7:	74 10                	je     8011c9 <fd_alloc+0x2e>
  8011b9:	89 d0                	mov    %edx,%eax
  8011bb:	c1 e8 0c             	shr    $0xc,%eax
  8011be:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  8011c5:	a8 01                	test   $0x1,%al
  8011c7:	75 09                	jne    8011d2 <fd_alloc+0x37>
			*fd_store = fd;
  8011c9:	89 0b                	mov    %ecx,(%ebx)
  8011cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d0:	eb 19                	jmp    8011eb <fd_alloc+0x50>
			return 0;
  8011d2:	81 c2 00 10 00 00    	add    $0x1000,%edx
  8011d8:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  8011de:	75 c7                	jne    8011a7 <fd_alloc+0xc>
		}
	}
	*fd_store = 0;
  8011e0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8011e6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8011eb:	5b                   	pop    %ebx
  8011ec:	5d                   	pop    %ebp
  8011ed:	c3                   	ret    

008011ee <fd_lookup>:

// Check that fdnum is in range and mapped.
// If it is, set *fd_store to the fd page virtual address.
//
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011ee:	55                   	push   %ebp
  8011ef:	89 e5                	mov    %esp,%ebp
  8011f1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011f4:	83 f8 1f             	cmp    $0x1f,%eax
  8011f7:	77 35                	ja     80122e <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011f9:	c1 e0 0c             	shl    $0xc,%eax
  8011fc:	8d 90 00 00 00 d0    	lea    0xd0000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  801202:	89 d0                	mov    %edx,%eax
  801204:	c1 e8 16             	shr    $0x16,%eax
  801207:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  80120e:	a8 01                	test   $0x1,%al
  801210:	74 1c                	je     80122e <fd_lookup+0x40>
  801212:	89 d0                	mov    %edx,%eax
  801214:	c1 e8 0c             	shr    $0xc,%eax
  801217:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  80121e:	a8 01                	test   $0x1,%al
  801220:	74 0c                	je     80122e <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801222:	8b 45 0c             	mov    0xc(%ebp),%eax
  801225:	89 10                	mov    %edx,(%eax)
  801227:	b8 00 00 00 00       	mov    $0x0,%eax
  80122c:	eb 05                	jmp    801233 <fd_lookup+0x45>
	return 0;
  80122e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801233:	5d                   	pop    %ebp
  801234:	c3                   	ret    

00801235 <seek>:

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
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
  801238:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80123b:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  80123e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801242:	8b 45 08             	mov    0x8(%ebp),%eax
  801245:	89 04 24             	mov    %eax,(%esp)
  801248:	e8 a1 ff ff ff       	call   8011ee <fd_lookup>
  80124d:	85 c0                	test   %eax,%eax
  80124f:	78 0e                	js     80125f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801251:	8b 55 0c             	mov    0xc(%ebp),%edx
  801254:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  801257:	89 50 04             	mov    %edx,0x4(%eax)
  80125a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80125f:	c9                   	leave  
  801260:	c3                   	ret    

00801261 <dev_lookup>:
  801261:	55                   	push   %ebp
  801262:	89 e5                	mov    %esp,%ebp
  801264:	53                   	push   %ebx
  801265:	83 ec 14             	sub    $0x14,%esp
  801268:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80126b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80126e:	ba 04 60 80 00       	mov    $0x806004,%edx
  801273:	b8 00 00 00 00       	mov    $0x0,%eax
  801278:	39 0d 04 60 80 00    	cmp    %ecx,0x806004
  80127e:	75 12                	jne    801292 <dev_lookup+0x31>
  801280:	eb 04                	jmp    801286 <dev_lookup+0x25>
  801282:	39 0a                	cmp    %ecx,(%edx)
  801284:	75 0c                	jne    801292 <dev_lookup+0x31>
  801286:	89 13                	mov    %edx,(%ebx)
  801288:	b8 00 00 00 00       	mov    $0x0,%eax
  80128d:	8d 76 00             	lea    0x0(%esi),%esi
  801290:	eb 35                	jmp    8012c7 <dev_lookup+0x66>
  801292:	83 c0 01             	add    $0x1,%eax
  801295:	8b 14 85 08 2e 80 00 	mov    0x802e08(,%eax,4),%edx
  80129c:	85 d2                	test   %edx,%edx
  80129e:	75 e2                	jne    801282 <dev_lookup+0x21>
  8012a0:	a1 3c 60 80 00       	mov    0x80603c,%eax
  8012a5:	8b 40 4c             	mov    0x4c(%eax),%eax
  8012a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b0:	c7 04 24 8c 2d 80 00 	movl   $0x802d8c,(%esp)
  8012b7:	e8 e5 ef ff ff       	call   8002a1 <cprintf>
  8012bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8012c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c7:	83 c4 14             	add    $0x14,%esp
  8012ca:	5b                   	pop    %ebx
  8012cb:	5d                   	pop    %ebp
  8012cc:	c3                   	ret    

008012cd <fstat>:

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
  8012cd:	55                   	push   %ebp
  8012ce:	89 e5                	mov    %esp,%ebp
  8012d0:	53                   	push   %ebx
  8012d1:	83 ec 24             	sub    $0x24,%esp
  8012d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d7:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8012da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012de:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e1:	89 04 24             	mov    %eax,(%esp)
  8012e4:	e8 05 ff ff ff       	call   8011ee <fd_lookup>
  8012e9:	89 c2                	mov    %eax,%edx
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	78 57                	js     801346 <fstat+0x79>
  8012ef:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  8012f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f6:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8012f9:	8b 00                	mov    (%eax),%eax
  8012fb:	89 04 24             	mov    %eax,(%esp)
  8012fe:	e8 5e ff ff ff       	call   801261 <dev_lookup>
  801303:	89 c2                	mov    %eax,%edx
  801305:	85 c0                	test   %eax,%eax
  801307:	78 3d                	js     801346 <fstat+0x79>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801309:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  80130e:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
  801311:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801315:	74 2f                	je     801346 <fstat+0x79>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801317:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80131a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801321:	00 00 00 
	stat->st_isdir = 0;
  801324:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80132b:	00 00 00 
	stat->st_dev = dev;
  80132e:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801331:	89 93 88 00 00 00    	mov    %edx,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801337:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80133b:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80133e:	89 04 24             	mov    %eax,(%esp)
  801341:	ff 52 14             	call   *0x14(%edx)
  801344:	89 c2                	mov    %eax,%edx
}
  801346:	89 d0                	mov    %edx,%eax
  801348:	83 c4 24             	add    $0x24,%esp
  80134b:	5b                   	pop    %ebx
  80134c:	5d                   	pop    %ebp
  80134d:	c3                   	ret    

0080134e <ftruncate>:
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
  801351:	53                   	push   %ebx
  801352:	83 ec 24             	sub    $0x24,%esp
  801355:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801358:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80135b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135f:	89 1c 24             	mov    %ebx,(%esp)
  801362:	e8 87 fe ff ff       	call   8011ee <fd_lookup>
  801367:	85 c0                	test   %eax,%eax
  801369:	78 61                	js     8013cc <ftruncate+0x7e>
  80136b:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80136e:	8b 10                	mov    (%eax),%edx
  801370:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801373:	89 44 24 04          	mov    %eax,0x4(%esp)
  801377:	89 14 24             	mov    %edx,(%esp)
  80137a:	e8 e2 fe ff ff       	call   801261 <dev_lookup>
  80137f:	85 c0                	test   %eax,%eax
  801381:	78 49                	js     8013cc <ftruncate+0x7e>
  801383:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  801386:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  80138a:	75 23                	jne    8013af <ftruncate+0x61>
  80138c:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801391:	8b 40 4c             	mov    0x4c(%eax),%eax
  801394:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801398:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139c:	c7 04 24 ac 2d 80 00 	movl   $0x802dac,(%esp)
  8013a3:	e8 f9 ee ff ff       	call   8002a1 <cprintf>
  8013a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013ad:	eb 1d                	jmp    8013cc <ftruncate+0x7e>
  8013af:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  8013b2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013b7:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  8013bb:	74 0f                	je     8013cc <ftruncate+0x7e>
  8013bd:	8b 52 18             	mov    0x18(%edx),%edx
  8013c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c7:	89 0c 24             	mov    %ecx,(%esp)
  8013ca:	ff d2                	call   *%edx
  8013cc:	83 c4 24             	add    $0x24,%esp
  8013cf:	5b                   	pop    %ebx
  8013d0:	5d                   	pop    %ebp
  8013d1:	c3                   	ret    

008013d2 <write>:
  8013d2:	55                   	push   %ebp
  8013d3:	89 e5                	mov    %esp,%ebp
  8013d5:	53                   	push   %ebx
  8013d6:	83 ec 24             	sub    $0x24,%esp
  8013d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8013dc:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8013df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e3:	89 1c 24             	mov    %ebx,(%esp)
  8013e6:	e8 03 fe ff ff       	call   8011ee <fd_lookup>
  8013eb:	85 c0                	test   %eax,%eax
  8013ed:	78 68                	js     801457 <write+0x85>
  8013ef:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8013f2:	8b 10                	mov    (%eax),%edx
  8013f4:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  8013f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013fb:	89 14 24             	mov    %edx,(%esp)
  8013fe:	e8 5e fe ff ff       	call   801261 <dev_lookup>
  801403:	85 c0                	test   %eax,%eax
  801405:	78 50                	js     801457 <write+0x85>
  801407:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  80140a:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  80140e:	75 23                	jne    801433 <write+0x61>
  801410:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801415:	8b 40 4c             	mov    0x4c(%eax),%eax
  801418:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80141c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801420:	c7 04 24 cd 2d 80 00 	movl   $0x802dcd,(%esp)
  801427:	e8 75 ee ff ff       	call   8002a1 <cprintf>
  80142c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801431:	eb 24                	jmp    801457 <write+0x85>
  801433:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801436:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80143b:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  80143f:	74 16                	je     801457 <write+0x85>
  801441:	8b 42 0c             	mov    0xc(%edx),%eax
  801444:	8b 55 10             	mov    0x10(%ebp),%edx
  801447:	89 54 24 08          	mov    %edx,0x8(%esp)
  80144b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80144e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801452:	89 0c 24             	mov    %ecx,(%esp)
  801455:	ff d0                	call   *%eax
  801457:	83 c4 24             	add    $0x24,%esp
  80145a:	5b                   	pop    %ebx
  80145b:	5d                   	pop    %ebp
  80145c:	c3                   	ret    

0080145d <read>:
  80145d:	55                   	push   %ebp
  80145e:	89 e5                	mov    %esp,%ebp
  801460:	53                   	push   %ebx
  801461:	83 ec 24             	sub    $0x24,%esp
  801464:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801467:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80146a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80146e:	89 1c 24             	mov    %ebx,(%esp)
  801471:	e8 78 fd ff ff       	call   8011ee <fd_lookup>
  801476:	85 c0                	test   %eax,%eax
  801478:	78 6d                	js     8014e7 <read+0x8a>
  80147a:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80147d:	8b 10                	mov    (%eax),%edx
  80147f:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801482:	89 44 24 04          	mov    %eax,0x4(%esp)
  801486:	89 14 24             	mov    %edx,(%esp)
  801489:	e8 d3 fd ff ff       	call   801261 <dev_lookup>
  80148e:	85 c0                	test   %eax,%eax
  801490:	78 55                	js     8014e7 <read+0x8a>
  801492:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  801495:	8b 41 08             	mov    0x8(%ecx),%eax
  801498:	83 e0 03             	and    $0x3,%eax
  80149b:	83 f8 01             	cmp    $0x1,%eax
  80149e:	75 23                	jne    8014c3 <read+0x66>
  8014a0:	a1 3c 60 80 00       	mov    0x80603c,%eax
  8014a5:	8b 40 4c             	mov    0x4c(%eax),%eax
  8014a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b0:	c7 04 24 ea 2d 80 00 	movl   $0x802dea,(%esp)
  8014b7:	e8 e5 ed ff ff       	call   8002a1 <cprintf>
  8014bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014c1:	eb 24                	jmp    8014e7 <read+0x8a>
  8014c3:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  8014c6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014cb:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  8014cf:	74 16                	je     8014e7 <read+0x8a>
  8014d1:	8b 42 08             	mov    0x8(%edx),%eax
  8014d4:	8b 55 10             	mov    0x10(%ebp),%edx
  8014d7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8014db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014de:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014e2:	89 0c 24             	mov    %ecx,(%esp)
  8014e5:	ff d0                	call   *%eax
  8014e7:	83 c4 24             	add    $0x24,%esp
  8014ea:	5b                   	pop    %ebx
  8014eb:	5d                   	pop    %ebp
  8014ec:	c3                   	ret    

008014ed <readn>:
  8014ed:	55                   	push   %ebp
  8014ee:	89 e5                	mov    %esp,%ebp
  8014f0:	57                   	push   %edi
  8014f1:	56                   	push   %esi
  8014f2:	53                   	push   %ebx
  8014f3:	83 ec 0c             	sub    $0xc,%esp
  8014f6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8014f9:	8b 75 10             	mov    0x10(%ebp),%esi
  8014fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801501:	85 f6                	test   %esi,%esi
  801503:	74 36                	je     80153b <readn+0x4e>
  801505:	bb 00 00 00 00       	mov    $0x0,%ebx
  80150a:	ba 00 00 00 00       	mov    $0x0,%edx
  80150f:	89 f0                	mov    %esi,%eax
  801511:	29 d0                	sub    %edx,%eax
  801513:	89 44 24 08          	mov    %eax,0x8(%esp)
  801517:	8d 04 17             	lea    (%edi,%edx,1),%eax
  80151a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80151e:	8b 45 08             	mov    0x8(%ebp),%eax
  801521:	89 04 24             	mov    %eax,(%esp)
  801524:	e8 34 ff ff ff       	call   80145d <read>
  801529:	85 c0                	test   %eax,%eax
  80152b:	78 0e                	js     80153b <readn+0x4e>
  80152d:	85 c0                	test   %eax,%eax
  80152f:	74 08                	je     801539 <readn+0x4c>
  801531:	01 c3                	add    %eax,%ebx
  801533:	89 da                	mov    %ebx,%edx
  801535:	39 f3                	cmp    %esi,%ebx
  801537:	72 d6                	jb     80150f <readn+0x22>
  801539:	89 d8                	mov    %ebx,%eax
  80153b:	83 c4 0c             	add    $0xc,%esp
  80153e:	5b                   	pop    %ebx
  80153f:	5e                   	pop    %esi
  801540:	5f                   	pop    %edi
  801541:	5d                   	pop    %ebp
  801542:	c3                   	ret    

00801543 <fd_close>:
  801543:	55                   	push   %ebp
  801544:	89 e5                	mov    %esp,%ebp
  801546:	83 ec 28             	sub    $0x28,%esp
  801549:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  80154c:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  80154f:	8b 75 08             	mov    0x8(%ebp),%esi
  801552:	89 34 24             	mov    %esi,(%esp)
  801555:	e8 16 fc ff ff       	call   801170 <fd2num>
  80155a:	8d 55 f4             	lea    0xfffffff4(%ebp),%edx
  80155d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801561:	89 04 24             	mov    %eax,(%esp)
  801564:	e8 85 fc ff ff       	call   8011ee <fd_lookup>
  801569:	89 c3                	mov    %eax,%ebx
  80156b:	85 c0                	test   %eax,%eax
  80156d:	78 05                	js     801574 <fd_close+0x31>
  80156f:	3b 75 f4             	cmp    0xfffffff4(%ebp),%esi
  801572:	74 0e                	je     801582 <fd_close+0x3f>
  801574:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801578:	75 45                	jne    8015bf <fd_close+0x7c>
  80157a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80157f:	90                   	nop    
  801580:	eb 3d                	jmp    8015bf <fd_close+0x7c>
  801582:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  801585:	89 44 24 04          	mov    %eax,0x4(%esp)
  801589:	8b 06                	mov    (%esi),%eax
  80158b:	89 04 24             	mov    %eax,(%esp)
  80158e:	e8 ce fc ff ff       	call   801261 <dev_lookup>
  801593:	89 c3                	mov    %eax,%ebx
  801595:	85 c0                	test   %eax,%eax
  801597:	78 16                	js     8015af <fd_close+0x6c>
  801599:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80159c:	8b 40 10             	mov    0x10(%eax),%eax
  80159f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015a4:	85 c0                	test   %eax,%eax
  8015a6:	74 07                	je     8015af <fd_close+0x6c>
  8015a8:	89 34 24             	mov    %esi,(%esp)
  8015ab:	ff d0                	call   *%eax
  8015ad:	89 c3                	mov    %eax,%ebx
  8015af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015ba:	e8 cf f9 ff ff       	call   800f8e <sys_page_unmap>
  8015bf:	89 d8                	mov    %ebx,%eax
  8015c1:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  8015c4:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  8015c7:	89 ec                	mov    %ebp,%esp
  8015c9:	5d                   	pop    %ebp
  8015ca:	c3                   	ret    

008015cb <close>:
  8015cb:	55                   	push   %ebp
  8015cc:	89 e5                	mov    %esp,%ebp
  8015ce:	83 ec 18             	sub    $0x18,%esp
  8015d1:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  8015d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015db:	89 04 24             	mov    %eax,(%esp)
  8015de:	e8 0b fc ff ff       	call   8011ee <fd_lookup>
  8015e3:	85 c0                	test   %eax,%eax
  8015e5:	78 13                	js     8015fa <close+0x2f>
  8015e7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8015ee:	00 
  8015ef:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  8015f2:	89 04 24             	mov    %eax,(%esp)
  8015f5:	e8 49 ff ff ff       	call   801543 <fd_close>
  8015fa:	c9                   	leave  
  8015fb:	c3                   	ret    

008015fc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015fc:	55                   	push   %ebp
  8015fd:	89 e5                	mov    %esp,%ebp
  8015ff:	83 ec 18             	sub    $0x18,%esp
  801602:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  801605:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801608:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80160f:	00 
  801610:	8b 45 08             	mov    0x8(%ebp),%eax
  801613:	89 04 24             	mov    %eax,(%esp)
  801616:	e8 58 03 00 00       	call   801973 <open>
  80161b:	89 c6                	mov    %eax,%esi
  80161d:	85 c0                	test   %eax,%eax
  80161f:	78 1b                	js     80163c <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801621:	8b 45 0c             	mov    0xc(%ebp),%eax
  801624:	89 44 24 04          	mov    %eax,0x4(%esp)
  801628:	89 34 24             	mov    %esi,(%esp)
  80162b:	e8 9d fc ff ff       	call   8012cd <fstat>
  801630:	89 c3                	mov    %eax,%ebx
	close(fd);
  801632:	89 34 24             	mov    %esi,(%esp)
  801635:	e8 91 ff ff ff       	call   8015cb <close>
  80163a:	89 de                	mov    %ebx,%esi
	return r;
}
  80163c:	89 f0                	mov    %esi,%eax
  80163e:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  801641:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  801644:	89 ec                	mov    %ebp,%esp
  801646:	5d                   	pop    %ebp
  801647:	c3                   	ret    

00801648 <dup>:
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	83 ec 38             	sub    $0x38,%esp
  80164e:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  801651:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  801654:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  801657:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80165a:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  80165d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801661:	8b 45 08             	mov    0x8(%ebp),%eax
  801664:	89 04 24             	mov    %eax,(%esp)
  801667:	e8 82 fb ff ff       	call   8011ee <fd_lookup>
  80166c:	89 c3                	mov    %eax,%ebx
  80166e:	85 c0                	test   %eax,%eax
  801670:	0f 88 e1 00 00 00    	js     801757 <dup+0x10f>
  801676:	89 3c 24             	mov    %edi,(%esp)
  801679:	e8 4d ff ff ff       	call   8015cb <close>
  80167e:	89 f8                	mov    %edi,%eax
  801680:	c1 e0 0c             	shl    $0xc,%eax
  801683:	8d b0 00 00 00 d0    	lea    0xd0000000(%eax),%esi
  801689:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80168c:	89 04 24             	mov    %eax,(%esp)
  80168f:	e8 ec fa ff ff       	call   801180 <fd2data>
  801694:	89 c3                	mov    %eax,%ebx
  801696:	89 34 24             	mov    %esi,(%esp)
  801699:	e8 e2 fa ff ff       	call   801180 <fd2data>
  80169e:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  8016a1:	89 d8                	mov    %ebx,%eax
  8016a3:	c1 e8 16             	shr    $0x16,%eax
  8016a6:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  8016ad:	a8 01                	test   $0x1,%al
  8016af:	74 45                	je     8016f6 <dup+0xae>
  8016b1:	89 da                	mov    %ebx,%edx
  8016b3:	c1 ea 0c             	shr    $0xc,%edx
  8016b6:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  8016bd:	a8 01                	test   $0x1,%al
  8016bf:	74 35                	je     8016f6 <dup+0xae>
  8016c1:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  8016c8:	25 07 0e 00 00       	and    $0xe07,%eax
  8016cd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016d1:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  8016d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016d8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016df:	00 
  8016e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016eb:	e8 fc f8 ff ff       	call   800fec <sys_page_map>
  8016f0:	89 c3                	mov    %eax,%ebx
  8016f2:	85 c0                	test   %eax,%eax
  8016f4:	78 3e                	js     801734 <dup+0xec>
  8016f6:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  8016f9:	89 d0                	mov    %edx,%eax
  8016fb:	c1 e8 0c             	shr    $0xc,%eax
  8016fe:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  801705:	25 07 0e 00 00       	and    $0xe07,%eax
  80170a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80170e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801712:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801719:	00 
  80171a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80171e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801725:	e8 c2 f8 ff ff       	call   800fec <sys_page_map>
  80172a:	89 c3                	mov    %eax,%ebx
  80172c:	85 c0                	test   %eax,%eax
  80172e:	78 04                	js     801734 <dup+0xec>
  801730:	89 fb                	mov    %edi,%ebx
  801732:	eb 23                	jmp    801757 <dup+0x10f>
  801734:	89 74 24 04          	mov    %esi,0x4(%esp)
  801738:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80173f:	e8 4a f8 ff ff       	call   800f8e <sys_page_unmap>
  801744:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  801747:	89 44 24 04          	mov    %eax,0x4(%esp)
  80174b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801752:	e8 37 f8 ff ff       	call   800f8e <sys_page_unmap>
  801757:	89 d8                	mov    %ebx,%eax
  801759:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  80175c:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  80175f:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801762:	89 ec                	mov    %ebp,%esp
  801764:	5d                   	pop    %ebp
  801765:	c3                   	ret    

00801766 <close_all>:
  801766:	55                   	push   %ebp
  801767:	89 e5                	mov    %esp,%ebp
  801769:	53                   	push   %ebx
  80176a:	83 ec 04             	sub    $0x4,%esp
  80176d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801772:	89 1c 24             	mov    %ebx,(%esp)
  801775:	e8 51 fe ff ff       	call   8015cb <close>
  80177a:	83 c3 01             	add    $0x1,%ebx
  80177d:	83 fb 20             	cmp    $0x20,%ebx
  801780:	75 f0                	jne    801772 <close_all+0xc>
  801782:	83 c4 04             	add    $0x4,%esp
  801785:	5b                   	pop    %ebx
  801786:	5d                   	pop    %ebp
  801787:	c3                   	ret    

00801788 <fsipc>:
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801788:	55                   	push   %ebp
  801789:	89 e5                	mov    %esp,%ebp
  80178b:	53                   	push   %ebx
  80178c:	83 ec 14             	sub    $0x14,%esp
  80178f:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801791:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  801797:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80179e:	00 
  80179f:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  8017a6:	00 
  8017a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ab:	89 14 24             	mov    %edx,(%esp)
  8017ae:	e8 4d 0d 00 00       	call   802500 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017b3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017ba:	00 
  8017bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017c6:	e8 e9 0d 00 00       	call   8025b4 <ipc_recv>
}
  8017cb:	83 c4 14             	add    $0x14,%esp
  8017ce:	5b                   	pop    %ebx
  8017cf:	5d                   	pop    %ebp
  8017d0:	c3                   	ret    

008017d1 <sync>:

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
  8017d1:	55                   	push   %ebp
  8017d2:	89 e5                	mov    %esp,%ebp
  8017d4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017dc:	b8 08 00 00 00       	mov    $0x8,%eax
  8017e1:	e8 a2 ff ff ff       	call   801788 <fsipc>
}
  8017e6:	c9                   	leave  
  8017e7:	c3                   	ret    

008017e8 <devfile_trunc>:
  8017e8:	55                   	push   %ebp
  8017e9:	89 e5                	mov    %esp,%ebp
  8017eb:	83 ec 08             	sub    $0x8,%esp
  8017ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f1:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f4:	a3 00 30 80 00       	mov    %eax,0x803000
  8017f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017fc:	a3 04 30 80 00       	mov    %eax,0x803004
  801801:	ba 00 00 00 00       	mov    $0x0,%edx
  801806:	b8 02 00 00 00       	mov    $0x2,%eax
  80180b:	e8 78 ff ff ff       	call   801788 <fsipc>
  801810:	c9                   	leave  
  801811:	c3                   	ret    

00801812 <devfile_flush>:
  801812:	55                   	push   %ebp
  801813:	89 e5                	mov    %esp,%ebp
  801815:	83 ec 08             	sub    $0x8,%esp
  801818:	8b 45 08             	mov    0x8(%ebp),%eax
  80181b:	8b 40 0c             	mov    0xc(%eax),%eax
  80181e:	a3 00 30 80 00       	mov    %eax,0x803000
  801823:	ba 00 00 00 00       	mov    $0x0,%edx
  801828:	b8 06 00 00 00       	mov    $0x6,%eax
  80182d:	e8 56 ff ff ff       	call   801788 <fsipc>
  801832:	c9                   	leave  
  801833:	c3                   	ret    

00801834 <devfile_stat>:
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	53                   	push   %ebx
  801838:	83 ec 14             	sub    $0x14,%esp
  80183b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80183e:	8b 45 08             	mov    0x8(%ebp),%eax
  801841:	8b 40 0c             	mov    0xc(%eax),%eax
  801844:	a3 00 30 80 00       	mov    %eax,0x803000
  801849:	ba 00 00 00 00       	mov    $0x0,%edx
  80184e:	b8 05 00 00 00       	mov    $0x5,%eax
  801853:	e8 30 ff ff ff       	call   801788 <fsipc>
  801858:	85 c0                	test   %eax,%eax
  80185a:	78 2b                	js     801887 <devfile_stat+0x53>
  80185c:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801863:	00 
  801864:	89 1c 24             	mov    %ebx,(%esp)
  801867:	e8 b5 f0 ff ff       	call   800921 <strcpy>
  80186c:	a1 80 30 80 00       	mov    0x803080,%eax
  801871:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  801877:	a1 84 30 80 00       	mov    0x803084,%eax
  80187c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801882:	b8 00 00 00 00       	mov    $0x0,%eax
  801887:	83 c4 14             	add    $0x14,%esp
  80188a:	5b                   	pop    %ebx
  80188b:	5d                   	pop    %ebp
  80188c:	c3                   	ret    

0080188d <devfile_write>:
  80188d:	55                   	push   %ebp
  80188e:	89 e5                	mov    %esp,%ebp
  801890:	83 ec 18             	sub    $0x18,%esp
  801893:	8b 55 10             	mov    0x10(%ebp),%edx
  801896:	8b 45 08             	mov    0x8(%ebp),%eax
  801899:	8b 40 0c             	mov    0xc(%eax),%eax
  80189c:	a3 00 30 80 00       	mov    %eax,0x803000
  8018a1:	89 d0                	mov    %edx,%eax
  8018a3:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  8018a9:	76 05                	jbe    8018b0 <devfile_write+0x23>
  8018ab:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  8018b0:	89 15 04 30 80 00    	mov    %edx,0x803004
  8018b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c1:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  8018c8:	e8 5d f2 ff ff       	call   800b2a <memmove>
  8018cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d2:	b8 04 00 00 00       	mov    $0x4,%eax
  8018d7:	e8 ac fe ff ff       	call   801788 <fsipc>
  8018dc:	c9                   	leave  
  8018dd:	c3                   	ret    

008018de <devfile_read>:
  8018de:	55                   	push   %ebp
  8018df:	89 e5                	mov    %esp,%ebp
  8018e1:	53                   	push   %ebx
  8018e2:	83 ec 14             	sub    $0x14,%esp
  8018e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018eb:	a3 00 30 80 00       	mov    %eax,0x803000
  8018f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8018f3:	a3 04 30 80 00       	mov    %eax,0x803004
  8018f8:	ba 00 30 80 00       	mov    $0x803000,%edx
  8018fd:	b8 03 00 00 00       	mov    $0x3,%eax
  801902:	e8 81 fe ff ff       	call   801788 <fsipc>
  801907:	89 c3                	mov    %eax,%ebx
  801909:	85 c0                	test   %eax,%eax
  80190b:	7e 17                	jle    801924 <devfile_read+0x46>
  80190d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801911:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801918:	00 
  801919:	8b 45 0c             	mov    0xc(%ebp),%eax
  80191c:	89 04 24             	mov    %eax,(%esp)
  80191f:	e8 06 f2 ff ff       	call   800b2a <memmove>
  801924:	89 d8                	mov    %ebx,%eax
  801926:	83 c4 14             	add    $0x14,%esp
  801929:	5b                   	pop    %ebx
  80192a:	5d                   	pop    %ebp
  80192b:	c3                   	ret    

0080192c <remove>:
  80192c:	55                   	push   %ebp
  80192d:	89 e5                	mov    %esp,%ebp
  80192f:	53                   	push   %ebx
  801930:	83 ec 14             	sub    $0x14,%esp
  801933:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801936:	89 1c 24             	mov    %ebx,(%esp)
  801939:	e8 92 ef ff ff       	call   8008d0 <strlen>
  80193e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  801943:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801948:	7f 21                	jg     80196b <remove+0x3f>
  80194a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80194e:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801955:	e8 c7 ef ff ff       	call   800921 <strcpy>
  80195a:	ba 00 00 00 00       	mov    $0x0,%edx
  80195f:	b8 07 00 00 00       	mov    $0x7,%eax
  801964:	e8 1f fe ff ff       	call   801788 <fsipc>
  801969:	89 c2                	mov    %eax,%edx
  80196b:	89 d0                	mov    %edx,%eax
  80196d:	83 c4 14             	add    $0x14,%esp
  801970:	5b                   	pop    %ebx
  801971:	5d                   	pop    %ebp
  801972:	c3                   	ret    

00801973 <open>:
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	56                   	push   %esi
  801977:	53                   	push   %ebx
  801978:	83 ec 30             	sub    $0x30,%esp
  80197b:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80197e:	89 04 24             	mov    %eax,(%esp)
  801981:	e8 15 f8 ff ff       	call   80119b <fd_alloc>
  801986:	89 c3                	mov    %eax,%ebx
  801988:	85 c0                	test   %eax,%eax
  80198a:	79 18                	jns    8019a4 <open+0x31>
  80198c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801993:	00 
  801994:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801997:	89 04 24             	mov    %eax,(%esp)
  80199a:	e8 a4 fb ff ff       	call   801543 <fd_close>
  80199f:	e9 9f 00 00 00       	jmp    801a43 <open+0xd0>
  8019a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ab:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  8019b2:	e8 6a ef ff ff       	call   800921 <strcpy>
  8019b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ba:	a3 00 34 80 00       	mov    %eax,0x803400
  8019bf:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8019c2:	89 04 24             	mov    %eax,(%esp)
  8019c5:	e8 b6 f7 ff ff       	call   801180 <fd2data>
  8019ca:	89 c6                	mov    %eax,%esi
  8019cc:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  8019cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8019d4:	e8 af fd ff ff       	call   801788 <fsipc>
  8019d9:	89 c3                	mov    %eax,%ebx
  8019db:	85 c0                	test   %eax,%eax
  8019dd:	79 15                	jns    8019f4 <open+0x81>
  8019df:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8019e6:	00 
  8019e7:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8019ea:	89 04 24             	mov    %eax,(%esp)
  8019ed:	e8 51 fb ff ff       	call   801543 <fd_close>
  8019f2:	eb 4f                	jmp    801a43 <open+0xd0>
  8019f4:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8019fb:	00 
  8019fc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801a00:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a07:	00 
  801a08:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a16:	e8 d1 f5 ff ff       	call   800fec <sys_page_map>
  801a1b:	89 c3                	mov    %eax,%ebx
  801a1d:	85 c0                	test   %eax,%eax
  801a1f:	79 15                	jns    801a36 <open+0xc3>
  801a21:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a28:	00 
  801a29:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801a2c:	89 04 24             	mov    %eax,(%esp)
  801a2f:	e8 0f fb ff ff       	call   801543 <fd_close>
  801a34:	eb 0d                	jmp    801a43 <open+0xd0>
  801a36:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801a39:	89 04 24             	mov    %eax,(%esp)
  801a3c:	e8 2f f7 ff ff       	call   801170 <fd2num>
  801a41:	89 c3                	mov    %eax,%ebx
  801a43:	89 d8                	mov    %ebx,%eax
  801a45:	83 c4 30             	add    $0x30,%esp
  801a48:	5b                   	pop    %ebx
  801a49:	5e                   	pop    %esi
  801a4a:	5d                   	pop    %ebp
  801a4b:	c3                   	ret    

00801a4c <spawn>:
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801a4c:	55                   	push   %ebp
  801a4d:	89 e5                	mov    %esp,%ebp
  801a4f:	57                   	push   %edi
  801a50:	56                   	push   %esi
  801a51:	53                   	push   %ebx
  801a52:	81 ec 9c 02 00 00    	sub    $0x29c,%esp
	unsigned char elf_buf[512];
	struct Trapframe child_tf;
	envid_t child;

	int fd, i, r;
	struct Elf *elf;
	struct Proghdr *ph;
	int perm;

	// This code follows this procedure:
	//
	//   - Open the program file.
	//
	//   - Read the ELF header, as you have before, and sanity check its
	//     magic number.  (Check out your load_icode!)
	//
	//   - Use sys_exofork() to create a new environment.
	//
	//   - Set child_tf to an initial struct Trapframe for the child.
	//
	//   - Call the init_stack() function above to set up
	//     the initial stack page for the child environment.
	//
	//   - Map all of the program's segments that are of p_type
	//     ELF_PROG_LOAD into the new environment's address space.
	//     Use the p_flags field in the Proghdr for each segment
	//     to determine how to map the segment:
	//
	//	* If the ELF flags do not include ELF_PROG_FLAG_WRITE,
	//	  then the segment contains text and read-only data.
	//	  Use read_map() to read the contents of this segment,
	//	  and map the pages it returns directly into the child
	//        so that multiple instances of the same program
	//	  will share the same copy of the program text.
	//        Be sure to map the program text read-only in the child.
	//        Read_map is like read but returns a pointer to the data in
	//        *blk rather than copying the data into another buffer.
	//
	//	* If the ELF segment flags DO include ELF_PROG_FLAG_WRITE,
	//	  then the segment contains read/write data and bss.
	//	  As with load_icode() in Lab 3, such an ELF segment
	//	  occupies p_memsz bytes in memory, but only the FIRST
	//	  p_filesz bytes of the segment are actually loaded
	//	  from the executable file - you must clear the rest to zero.
	//        For each page to be mapped for a read/write segment,
	//        allocate a page in the parent temporarily at UTEMP,
	//        read() the appropriate portion of the file into that page
	//	  and/or use memset() to zero non-loaded portions.
	//	  (You can avoid calling memset(), if you like, if
	//	  page_alloc() returns zeroed pages already.)
	//        Then insert the page mapping into the child.
	//        Look at init_stack() for inspiration.
	//        Be sure you understand why you can't use read_map() here.
	//
	//     Note: None of the segment addresses or lengths above
	//     are guaranteed to be page-aligned, so you must deal with
	//     these non-page-aligned values appropriately.
	//     The ELF linker does, however, guarantee that no two segments
	//     will overlap on the same page; and it guarantees that
	//     PGOFF(ph->p_offset) == PGOFF(ph->p_va).
	//
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801a58:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a5f:	00 
  801a60:	8b 45 08             	mov    0x8(%ebp),%eax
  801a63:	89 04 24             	mov    %eax,(%esp)
  801a66:	e8 08 ff ff ff       	call   801973 <open>
  801a6b:	89 85 a0 fd ff ff    	mov    %eax,0xfffffda0(%ebp)
  801a71:	89 85 9c fd ff ff    	mov    %eax,0xfffffd9c(%ebp)
  801a77:	85 c0                	test   %eax,%eax
  801a79:	0f 88 49 05 00 00    	js     801fc8 <spawn+0x57c>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (read(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801a7f:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801a86:	00 
  801a87:	8d 85 f4 fd ff ff    	lea    0xfffffdf4(%ebp),%eax
  801a8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a91:	8b 95 a0 fd ff ff    	mov    0xfffffda0(%ebp),%edx
  801a97:	89 14 24             	mov    %edx,(%esp)
  801a9a:	e8 be f9 ff ff       	call   80145d <read>
  801a9f:	3d 00 02 00 00       	cmp    $0x200,%eax
  801aa4:	75 0c                	jne    801ab2 <spawn+0x66>
  801aa6:	81 bd f4 fd ff ff 7f 	cmpl   $0x464c457f,0xfffffdf4(%ebp)
  801aad:	45 4c 46 
  801ab0:	74 3b                	je     801aed <spawn+0xa1>
	    || elf->e_magic != ELF_MAGIC) {
		close(fd);
  801ab2:	8b 8d a0 fd ff ff    	mov    0xfffffda0(%ebp),%ecx
  801ab8:	89 0c 24             	mov    %ecx,(%esp)
  801abb:	e8 0b fb ff ff       	call   8015cb <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801ac0:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801ac7:	46 
  801ac8:	8b 85 f4 fd ff ff    	mov    0xfffffdf4(%ebp),%eax
  801ace:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad2:	c7 04 24 14 2e 80 00 	movl   $0x802e14,(%esp)
  801ad9:	e8 c3 e7 ff ff       	call   8002a1 <cprintf>
  801ade:	c7 85 9c fd ff ff f2 	movl   $0xfffffff2,0xfffffd9c(%ebp)
  801ae5:	ff ff ff 
  801ae8:	e9 db 04 00 00       	jmp    801fc8 <spawn+0x57c>
static __inline envid_t
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801aed:	ba 07 00 00 00       	mov    $0x7,%edx
  801af2:	89 d0                	mov    %edx,%eax
  801af4:	cd 30                	int    $0x30
  801af6:	89 85 9c fd ff ff    	mov    %eax,0xfffffd9c(%ebp)
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801afc:	85 c0                	test   %eax,%eax
  801afe:	0f 88 c4 04 00 00    	js     801fc8 <spawn+0x57c>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801b04:	25 ff 03 00 00       	and    $0x3ff,%eax
  801b09:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b0c:	8d 95 b0 fd ff ff    	lea    0xfffffdb0(%ebp),%edx
  801b12:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b17:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
  801b1e:	00 
  801b1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b23:	89 14 24             	mov    %edx,(%esp)
  801b26:	e8 7d f0 ff ff       	call   800ba8 <memcpy>
	child_tf.tf_eip = elf->e_entry;
  801b2b:	8b 85 0c fe ff ff    	mov    0xfffffe0c(%ebp),%eax
  801b31:	89 85 e0 fd ff ff    	mov    %eax,0xfffffde0(%ebp)

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz, 
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
	fd = -1;

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}

// Spawn, taking command-line arguments array directly on the stack.
int
spawnl(const char *prog, const char *arg0, ...)
{
	return spawn(prog, &arg0);
}


// Set up the initial stack page for the new child process with envid 'child'
// using the arguments array pointed to by 'argv',
// which is a null-terminated array of pointers to null-terminated strings.
//
// On success, returns 0 and sets *init_esp
// to the initial stack pointer with which the child should start.
// Returns < 0 on failure.
static int
init_stack(envid_t child, const char **argv, uintptr_t *init_esp)
{
	size_t string_size;
	int argc, i, r;
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801b37:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b3a:	8b 02                	mov    (%edx),%eax
  801b3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b41:	bf 00 00 00 00       	mov    $0x0,%edi
  801b46:	85 c0                	test   %eax,%eax
  801b48:	75 16                	jne    801b60 <spawn+0x114>
  801b4a:	c7 85 84 fd ff ff 00 	movl   $0x0,0xfffffd84(%ebp)
  801b51:	00 00 00 
  801b54:	c7 85 80 fd ff ff 00 	movl   $0x0,0xfffffd80(%ebp)
  801b5b:	00 00 00 
  801b5e:	eb 2a                	jmp    801b8a <spawn+0x13e>
		string_size += strlen(argv[argc]) + 1;
  801b60:	89 04 24             	mov    %eax,(%esp)
  801b63:	e8 68 ed ff ff       	call   8008d0 <strlen>
  801b68:	8d 5c 03 01          	lea    0x1(%ebx,%eax,1),%ebx
  801b6c:	83 c7 01             	add    $0x1,%edi
  801b6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b72:	8b 04 b9             	mov    (%ecx,%edi,4),%eax
  801b75:	85 c0                	test   %eax,%eax
  801b77:	75 e7                	jne    801b60 <spawn+0x114>
  801b79:	89 bd 84 fd ff ff    	mov    %edi,0xfffffd84(%ebp)
  801b7f:	89 f8                	mov    %edi,%eax
  801b81:	c1 e0 02             	shl    $0x2,%eax
  801b84:	89 85 80 fd ff ff    	mov    %eax,0xfffffd80(%ebp)

	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801b8a:	b8 00 10 40 00       	mov    $0x401000,%eax
  801b8f:	89 c6                	mov    %eax,%esi
  801b91:	29 de                	sub    %ebx,%esi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801b93:	89 f0                	mov    %esi,%eax
  801b95:	83 e0 fc             	and    $0xfffffffc,%eax
  801b98:	83 e8 04             	sub    $0x4,%eax
  801b9b:	8d 14 bd 00 00 00 00 	lea    0x0(,%edi,4),%edx
  801ba2:	29 d0                	sub    %edx,%eax
  801ba4:	89 85 7c fd ff ff    	mov    %eax,0xfffffd7c(%ebp)
	
	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801baa:	83 e8 08             	sub    $0x8,%eax
  801bad:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
  801bb2:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801bb7:	0f 86 d3 03 00 00    	jbe    801f90 <spawn+0x544>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801bbd:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801bc4:	00 
  801bc5:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801bcc:	00 
  801bcd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bd4:	e8 71 f4 ff ff       	call   80104a <sys_page_alloc>
  801bd9:	89 c2                	mov    %eax,%edx
  801bdb:	85 c0                	test   %eax,%eax
  801bdd:	0f 88 ad 03 00 00    	js     801f90 <spawn+0x544>
		return r;


	//	* Initialize 'argv_store[i]' to point to argument string i,
	//	  for all 0 <= i < argc.
	//	  Also, copy the argument strings from 'argv' into the
	//	  newly-allocated stack page.
	//
	//	* Set 'argv_store[argc]' to 0 to null-terminate the args array.
	//
	//	* Push two more words onto the child's stack below 'args',
	//	  containing the argc and argv parameters to be passed
	//	  to the child's umain() function.
	//	  argv should be below argc on the stack.
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801be3:	85 ff                	test   %edi,%edi
  801be5:	7e 3f                	jle    801c26 <spawn+0x1da>
  801be7:	bb 00 00 00 00       	mov    $0x0,%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  801bec:	8d 86 00 d0 7f ee    	lea    0xee7fd000(%esi),%eax
  801bf2:	8b 95 7c fd ff ff    	mov    0xfffffd7c(%ebp),%edx
  801bf8:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  801bfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bfe:	8b 04 99             	mov    (%ecx,%ebx,4),%eax
  801c01:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c05:	89 34 24             	mov    %esi,(%esp)
  801c08:	e8 14 ed ff ff       	call   800921 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801c0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c10:	8b 04 9a             	mov    (%edx,%ebx,4),%eax
  801c13:	89 04 24             	mov    %eax,(%esp)
  801c16:	e8 b5 ec ff ff       	call   8008d0 <strlen>
  801c1b:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
  801c1f:	83 c3 01             	add    $0x1,%ebx
  801c22:	39 fb                	cmp    %edi,%ebx
  801c24:	75 c6                	jne    801bec <spawn+0x1a0>
	}
	argv_store[argc] = 0;
  801c26:	8b 8d 80 fd ff ff    	mov    0xfffffd80(%ebp),%ecx
  801c2c:	8b 85 7c fd ff ff    	mov    0xfffffd7c(%ebp),%eax
  801c32:	c7 04 01 00 00 00 00 	movl   $0x0,(%ecx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801c39:	81 fe 00 10 40 00    	cmp    $0x401000,%esi
  801c3f:	74 24                	je     801c65 <spawn+0x219>
  801c41:	c7 44 24 0c a0 2e 80 	movl   $0x802ea0,0xc(%esp)
  801c48:	00 
  801c49:	c7 44 24 08 2e 2e 80 	movl   $0x802e2e,0x8(%esp)
  801c50:	00 
  801c51:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
  801c58:	00 
  801c59:	c7 04 24 43 2e 80 00 	movl   $0x802e43,(%esp)
  801c60:	e8 6f e5 ff ff       	call   8001d4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801c65:	8b 85 7c fd ff ff    	mov    0xfffffd7c(%ebp),%eax
  801c6b:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801c70:	8b 95 7c fd ff ff    	mov    0xfffffd7c(%ebp),%edx
  801c76:	89 42 fc             	mov    %eax,0xfffffffc(%edx)
	argv_store[-2] = argc;
  801c79:	8b 8d 84 fd ff ff    	mov    0xfffffd84(%ebp),%ecx
  801c7f:	89 4a f8             	mov    %ecx,0xfffffff8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801c82:	89 d0                	mov    %edx,%eax
  801c84:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801c89:	89 85 ec fd ff ff    	mov    %eax,0xfffffdec(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801c8f:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801c96:	00 
  801c97:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801c9e:	ee 
  801c9f:	8b 85 9c fd ff ff    	mov    0xfffffd9c(%ebp),%eax
  801ca5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ca9:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801cb0:	00 
  801cb1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cb8:	e8 2f f3 ff ff       	call   800fec <sys_page_map>
  801cbd:	89 c3                	mov    %eax,%ebx
  801cbf:	85 c0                	test   %eax,%eax
  801cc1:	78 1e                	js     801ce1 <spawn+0x295>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801cc3:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801cca:	00 
  801ccb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cd2:	e8 b7 f2 ff ff       	call   800f8e <sys_page_unmap>
  801cd7:	89 c3                	mov    %eax,%ebx
  801cd9:	85 c0                	test   %eax,%eax
  801cdb:	0f 89 b7 02 00 00    	jns    801f98 <spawn+0x54c>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801ce1:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ce8:	00 
  801ce9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cf0:	e8 99 f2 ff ff       	call   800f8e <sys_page_unmap>
  801cf5:	89 9d 9c fd ff ff    	mov    %ebx,0xfffffd9c(%ebp)
  801cfb:	e9 c8 02 00 00       	jmp    801fc8 <spawn+0x57c>
  801d00:	8b 95 98 fd ff ff    	mov    0xfffffd98(%ebp),%edx
  801d06:	83 7a e0 01          	cmpl   $0x1,0xffffffe0(%edx)
  801d0a:	0f 85 b7 01 00 00    	jne    801ec7 <spawn+0x47b>
  801d10:	8b 42 f8             	mov    0xfffffff8(%edx),%eax
  801d13:	83 e0 02             	and    $0x2,%eax
  801d16:	83 f8 01             	cmp    $0x1,%eax
  801d19:	19 c9                	sbb    %ecx,%ecx
  801d1b:	83 e1 fe             	and    $0xfffffffe,%ecx
  801d1e:	83 c1 07             	add    $0x7,%ecx
  801d21:	89 8d 78 fd ff ff    	mov    %ecx,0xfffffd78(%ebp)
  801d27:	8b 42 e4             	mov    0xffffffe4(%edx),%eax
  801d2a:	89 85 88 fd ff ff    	mov    %eax,0xfffffd88(%ebp)
  801d30:	8b 4a f0             	mov    0xfffffff0(%edx),%ecx
  801d33:	89 8d 8c fd ff ff    	mov    %ecx,0xfffffd8c(%ebp)
  801d39:	8b 42 f4             	mov    0xfffffff4(%edx),%eax
  801d3c:	89 85 90 fd ff ff    	mov    %eax,0xfffffd90(%ebp)
  801d42:	8b 52 e8             	mov    0xffffffe8(%edx),%edx
  801d45:	89 95 94 fd ff ff    	mov    %edx,0xfffffd94(%ebp)
	return r;
}

static int
map_segment(envid_t child, uintptr_t va, size_t memsz, 
	int fd, size_t filesz, off_t fileoffset, int perm)
{
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801d4b:	89 d0                	mov    %edx,%eax
  801d4d:	25 ff 0f 00 00       	and    $0xfff,%eax
  801d52:	74 1c                	je     801d70 <spawn+0x324>
		va -= i;
  801d54:	29 c2                	sub    %eax,%edx
  801d56:	89 95 94 fd ff ff    	mov    %edx,0xfffffd94(%ebp)
		memsz += i;
  801d5c:	01 85 90 fd ff ff    	add    %eax,0xfffffd90(%ebp)
		filesz += i;
  801d62:	01 c1                	add    %eax,%ecx
  801d64:	89 8d 8c fd ff ff    	mov    %ecx,0xfffffd8c(%ebp)
		fileoffset -= i;
  801d6a:	29 85 88 fd ff ff    	sub    %eax,0xfffffd88(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801d70:	83 bd 90 fd ff ff 00 	cmpl   $0x0,0xfffffd90(%ebp)
  801d77:	0f 84 4a 01 00 00    	je     801ec7 <spawn+0x47b>
  801d7d:	bf 00 00 00 00       	mov    $0x0,%edi
  801d82:	be 00 00 00 00       	mov    $0x0,%esi
		if (i >= filesz) {
  801d87:	39 b5 8c fd ff ff    	cmp    %esi,0xfffffd8c(%ebp)
  801d8d:	77 34                	ja     801dc3 <spawn+0x377>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801d8f:	8b 95 78 fd ff ff    	mov    0xfffffd78(%ebp),%edx
  801d95:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d99:	8b 8d 94 fd ff ff    	mov    0xfffffd94(%ebp),%ecx
  801d9f:	8d 04 0e             	lea    (%esi,%ecx,1),%eax
  801da2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801da6:	8b 85 9c fd ff ff    	mov    0xfffffd9c(%ebp),%eax
  801dac:	89 04 24             	mov    %eax,(%esp)
  801daf:	e8 96 f2 ff ff       	call   80104a <sys_page_alloc>
  801db4:	89 c3                	mov    %eax,%ebx
  801db6:	85 c0                	test   %eax,%eax
  801db8:	0f 89 f5 00 00 00    	jns    801eb3 <spawn+0x467>
  801dbe:	e9 a9 01 00 00       	jmp    801f6c <spawn+0x520>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801dc3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801dca:	00 
  801dcb:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801dd2:	00 
  801dd3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dda:	e8 6b f2 ff ff       	call   80104a <sys_page_alloc>
  801ddf:	89 c3                	mov    %eax,%ebx
  801de1:	85 c0                	test   %eax,%eax
  801de3:	0f 88 83 01 00 00    	js     801f6c <spawn+0x520>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801de9:	8b 95 88 fd ff ff    	mov    0xfffffd88(%ebp),%edx
  801def:	8d 04 17             	lea    (%edi,%edx,1),%eax
  801df2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801df6:	8b 8d a0 fd ff ff    	mov    0xfffffda0(%ebp),%ecx
  801dfc:	89 0c 24             	mov    %ecx,(%esp)
  801dff:	e8 31 f4 ff ff       	call   801235 <seek>
  801e04:	89 c3                	mov    %eax,%ebx
  801e06:	85 c0                	test   %eax,%eax
  801e08:	0f 88 5e 01 00 00    	js     801f6c <spawn+0x520>
				return r;
			if ((r = read(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801e0e:	8b 85 8c fd ff ff    	mov    0xfffffd8c(%ebp),%eax
  801e14:	29 f0                	sub    %esi,%eax
  801e16:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801e1b:	76 05                	jbe    801e22 <spawn+0x3d6>
  801e1d:	b8 00 10 00 00       	mov    $0x1000,%eax
  801e22:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e26:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e2d:	00 
  801e2e:	8b 85 a0 fd ff ff    	mov    0xfffffda0(%ebp),%eax
  801e34:	89 04 24             	mov    %eax,(%esp)
  801e37:	e8 21 f6 ff ff       	call   80145d <read>
  801e3c:	89 c3                	mov    %eax,%ebx
  801e3e:	85 c0                	test   %eax,%eax
  801e40:	0f 88 26 01 00 00    	js     801f6c <spawn+0x520>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801e46:	8b 95 78 fd ff ff    	mov    0xfffffd78(%ebp),%edx
  801e4c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801e50:	8b 8d 94 fd ff ff    	mov    0xfffffd94(%ebp),%ecx
  801e56:	8d 04 0e             	lea    (%esi,%ecx,1),%eax
  801e59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e5d:	8b 85 9c fd ff ff    	mov    0xfffffd9c(%ebp),%eax
  801e63:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e67:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e6e:	00 
  801e6f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e76:	e8 71 f1 ff ff       	call   800fec <sys_page_map>
  801e7b:	85 c0                	test   %eax,%eax
  801e7d:	79 20                	jns    801e9f <spawn+0x453>
				panic("spawn: sys_page_map data: %e", r);
  801e7f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e83:	c7 44 24 08 4f 2e 80 	movl   $0x802e4f,0x8(%esp)
  801e8a:	00 
  801e8b:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
  801e92:	00 
  801e93:	c7 04 24 43 2e 80 00 	movl   $0x802e43,(%esp)
  801e9a:	e8 35 e3 ff ff       	call   8001d4 <_panic>
			sys_page_unmap(0, UTEMP);
  801e9f:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ea6:	00 
  801ea7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eae:	e8 db f0 ff ff       	call   800f8e <sys_page_unmap>
  801eb3:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801eb9:	89 fe                	mov    %edi,%esi
  801ebb:	39 bd 90 fd ff ff    	cmp    %edi,0xfffffd90(%ebp)
  801ec1:	0f 87 c0 fe ff ff    	ja     801d87 <spawn+0x33b>
  801ec7:	83 85 74 fd ff ff 01 	addl   $0x1,0xfffffd74(%ebp)
  801ece:	83 85 98 fd ff ff 20 	addl   $0x20,0xfffffd98(%ebp)
  801ed5:	0f b7 85 20 fe ff ff 	movzwl 0xfffffe20(%ebp),%eax
  801edc:	3b 85 74 fd ff ff    	cmp    0xfffffd74(%ebp),%eax
  801ee2:	0f 8f 18 fe ff ff    	jg     801d00 <spawn+0x2b4>
  801ee8:	8b 95 a0 fd ff ff    	mov    0xfffffda0(%ebp),%edx
  801eee:	89 14 24             	mov    %edx,(%esp)
  801ef1:	e8 d5 f6 ff ff       	call   8015cb <close>
  801ef6:	8d 85 b0 fd ff ff    	lea    0xfffffdb0(%ebp),%eax
  801efc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f00:	8b 8d 9c fd ff ff    	mov    0xfffffd9c(%ebp),%ecx
  801f06:	89 0c 24             	mov    %ecx,(%esp)
  801f09:	e8 c4 ef ff ff       	call   800ed2 <sys_env_set_trapframe>
  801f0e:	85 c0                	test   %eax,%eax
  801f10:	79 20                	jns    801f32 <spawn+0x4e6>
  801f12:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f16:	c7 44 24 08 6c 2e 80 	movl   $0x802e6c,0x8(%esp)
  801f1d:	00 
  801f1e:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801f25:	00 
  801f26:	c7 04 24 43 2e 80 00 	movl   $0x802e43,(%esp)
  801f2d:	e8 a2 e2 ff ff       	call   8001d4 <_panic>
  801f32:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801f39:	00 
  801f3a:	8b 85 9c fd ff ff    	mov    0xfffffd9c(%ebp),%eax
  801f40:	89 04 24             	mov    %eax,(%esp)
  801f43:	e8 e8 ef ff ff       	call   800f30 <sys_env_set_status>
  801f48:	85 c0                	test   %eax,%eax
  801f4a:	79 7c                	jns    801fc8 <spawn+0x57c>
  801f4c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f50:	c7 44 24 08 86 2e 80 	movl   $0x802e86,0x8(%esp)
  801f57:	00 
  801f58:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  801f5f:	00 
  801f60:	c7 04 24 43 2e 80 00 	movl   $0x802e43,(%esp)
  801f67:	e8 68 e2 ff ff       	call   8001d4 <_panic>
  801f6c:	8b 95 9c fd ff ff    	mov    0xfffffd9c(%ebp),%edx
  801f72:	89 14 24             	mov    %edx,(%esp)
  801f75:	e8 97 f1 ff ff       	call   801111 <sys_env_destroy>
  801f7a:	8b 8d a0 fd ff ff    	mov    0xfffffda0(%ebp),%ecx
  801f80:	89 0c 24             	mov    %ecx,(%esp)
  801f83:	e8 43 f6 ff ff       	call   8015cb <close>
  801f88:	89 9d 9c fd ff ff    	mov    %ebx,0xfffffd9c(%ebp)
  801f8e:	eb 38                	jmp    801fc8 <spawn+0x57c>
  801f90:	89 95 9c fd ff ff    	mov    %edx,0xfffffd9c(%ebp)
  801f96:	eb 30                	jmp    801fc8 <spawn+0x57c>
  801f98:	8b 85 10 fe ff ff    	mov    0xfffffe10(%ebp),%eax
  801f9e:	8d 84 05 14 fe ff ff 	lea    0xfffffe14(%ebp,%eax,1),%eax
  801fa5:	89 85 98 fd ff ff    	mov    %eax,0xfffffd98(%ebp)
  801fab:	c7 85 74 fd ff ff 00 	movl   $0x0,0xfffffd74(%ebp)
  801fb2:	00 00 00 
  801fb5:	66 83 bd 20 fe ff ff 	cmpw   $0x0,0xfffffe20(%ebp)
  801fbc:	00 
  801fbd:	0f 85 3d fd ff ff    	jne    801d00 <spawn+0x2b4>
  801fc3:	e9 20 ff ff ff       	jmp    801ee8 <spawn+0x49c>
  801fc8:	8b 85 9c fd ff ff    	mov    0xfffffd9c(%ebp),%eax
  801fce:	81 c4 9c 02 00 00    	add    $0x29c,%esp
  801fd4:	5b                   	pop    %ebx
  801fd5:	5e                   	pop    %esi
  801fd6:	5f                   	pop    %edi
  801fd7:	5d                   	pop    %ebp
  801fd8:	c3                   	ret    

00801fd9 <spawnl>:
  801fd9:	55                   	push   %ebp
  801fda:	89 e5                	mov    %esp,%ebp
  801fdc:	83 ec 08             	sub    $0x8,%esp
  801fdf:	8d 45 0c             	lea    0xc(%ebp),%eax
  801fe2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe9:	89 04 24             	mov    %eax,(%esp)
  801fec:	e8 5b fa ff ff       	call   801a4c <spawn>
  801ff1:	c9                   	leave  
  801ff2:	c3                   	ret    
	...

00802000 <devsock_stat>:
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802000:	55                   	push   %ebp
  802001:	89 e5                	mov    %esp,%ebp
  802003:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  802006:	c7 44 24 04 c8 2e 80 	movl   $0x802ec8,0x4(%esp)
  80200d:	00 
  80200e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802011:	89 04 24             	mov    %eax,(%esp)
  802014:	e8 08 e9 ff ff       	call   800921 <strcpy>
	return 0;
}
  802019:	b8 00 00 00 00       	mov    $0x0,%eax
  80201e:	c9                   	leave  
  80201f:	c3                   	ret    

00802020 <devsock_close>:
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	83 ec 08             	sub    $0x8,%esp
  802026:	8b 45 08             	mov    0x8(%ebp),%eax
  802029:	8b 40 0c             	mov    0xc(%eax),%eax
  80202c:	89 04 24             	mov    %eax,(%esp)
  80202f:	e8 be 02 00 00       	call   8022f2 <nsipc_close>
  802034:	c9                   	leave  
  802035:	c3                   	ret    

00802036 <devsock_write>:
  802036:	55                   	push   %ebp
  802037:	89 e5                	mov    %esp,%ebp
  802039:	83 ec 18             	sub    $0x18,%esp
  80203c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802043:	00 
  802044:	8b 45 10             	mov    0x10(%ebp),%eax
  802047:	89 44 24 08          	mov    %eax,0x8(%esp)
  80204b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80204e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802052:	8b 45 08             	mov    0x8(%ebp),%eax
  802055:	8b 40 0c             	mov    0xc(%eax),%eax
  802058:	89 04 24             	mov    %eax,(%esp)
  80205b:	e8 ce 02 00 00       	call   80232e <nsipc_send>
  802060:	c9                   	leave  
  802061:	c3                   	ret    

00802062 <devsock_read>:
  802062:	55                   	push   %ebp
  802063:	89 e5                	mov    %esp,%ebp
  802065:	83 ec 18             	sub    $0x18,%esp
  802068:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80206f:	00 
  802070:	8b 45 10             	mov    0x10(%ebp),%eax
  802073:	89 44 24 08          	mov    %eax,0x8(%esp)
  802077:	8b 45 0c             	mov    0xc(%ebp),%eax
  80207a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80207e:	8b 45 08             	mov    0x8(%ebp),%eax
  802081:	8b 40 0c             	mov    0xc(%eax),%eax
  802084:	89 04 24             	mov    %eax,(%esp)
  802087:	e8 15 03 00 00       	call   8023a1 <nsipc_recv>
  80208c:	c9                   	leave  
  80208d:	c3                   	ret    

0080208e <alloc_sockfd>:
  80208e:	55                   	push   %ebp
  80208f:	89 e5                	mov    %esp,%ebp
  802091:	56                   	push   %esi
  802092:	53                   	push   %ebx
  802093:	83 ec 20             	sub    $0x20,%esp
  802096:	89 c6                	mov    %eax,%esi
  802098:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80209b:	89 04 24             	mov    %eax,(%esp)
  80209e:	e8 f8 f0 ff ff       	call   80119b <fd_alloc>
  8020a3:	89 c3                	mov    %eax,%ebx
  8020a5:	85 c0                	test   %eax,%eax
  8020a7:	78 21                	js     8020ca <alloc_sockfd+0x3c>
  8020a9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8020b0:	00 
  8020b1:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8020b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020bf:	e8 86 ef ff ff       	call   80104a <sys_page_alloc>
  8020c4:	89 c3                	mov    %eax,%ebx
  8020c6:	85 c0                	test   %eax,%eax
  8020c8:	79 0a                	jns    8020d4 <alloc_sockfd+0x46>
  8020ca:	89 34 24             	mov    %esi,(%esp)
  8020cd:	e8 20 02 00 00       	call   8022f2 <nsipc_close>
  8020d2:	eb 28                	jmp    8020fc <alloc_sockfd+0x6e>
  8020d4:	8b 15 20 60 80 00    	mov    0x806020,%edx
  8020da:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8020dd:	89 10                	mov    %edx,(%eax)
  8020df:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8020e2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
  8020e9:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8020ec:	89 70 0c             	mov    %esi,0xc(%eax)
  8020ef:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8020f2:	89 04 24             	mov    %eax,(%esp)
  8020f5:	e8 76 f0 ff ff       	call   801170 <fd2num>
  8020fa:	89 c3                	mov    %eax,%ebx
  8020fc:	89 d8                	mov    %ebx,%eax
  8020fe:	83 c4 20             	add    $0x20,%esp
  802101:	5b                   	pop    %ebx
  802102:	5e                   	pop    %esi
  802103:	5d                   	pop    %ebp
  802104:	c3                   	ret    

00802105 <socket>:

int
socket(int domain, int type, int protocol)
{
  802105:	55                   	push   %ebp
  802106:	89 e5                	mov    %esp,%ebp
  802108:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80210b:	8b 45 10             	mov    0x10(%ebp),%eax
  80210e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802112:	8b 45 0c             	mov    0xc(%ebp),%eax
  802115:	89 44 24 04          	mov    %eax,0x4(%esp)
  802119:	8b 45 08             	mov    0x8(%ebp),%eax
  80211c:	89 04 24             	mov    %eax,(%esp)
  80211f:	e8 82 01 00 00       	call   8022a6 <nsipc_socket>
  802124:	85 c0                	test   %eax,%eax
  802126:	78 05                	js     80212d <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802128:	e8 61 ff ff ff       	call   80208e <alloc_sockfd>
}
  80212d:	c9                   	leave  
  80212e:	66 90                	xchg   %ax,%ax
  802130:	c3                   	ret    

00802131 <fd2sockid>:
  802131:	55                   	push   %ebp
  802132:	89 e5                	mov    %esp,%ebp
  802134:	83 ec 18             	sub    $0x18,%esp
  802137:	8d 55 fc             	lea    0xfffffffc(%ebp),%edx
  80213a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80213e:	89 04 24             	mov    %eax,(%esp)
  802141:	e8 a8 f0 ff ff       	call   8011ee <fd_lookup>
  802146:	89 c2                	mov    %eax,%edx
  802148:	85 c0                	test   %eax,%eax
  80214a:	78 15                	js     802161 <fd2sockid+0x30>
  80214c:	8b 4d fc             	mov    0xfffffffc(%ebp),%ecx
  80214f:	8b 01                	mov    (%ecx),%eax
  802151:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  802156:	3b 05 20 60 80 00    	cmp    0x806020,%eax
  80215c:	75 03                	jne    802161 <fd2sockid+0x30>
  80215e:	8b 51 0c             	mov    0xc(%ecx),%edx
  802161:	89 d0                	mov    %edx,%eax
  802163:	c9                   	leave  
  802164:	c3                   	ret    

00802165 <listen>:
  802165:	55                   	push   %ebp
  802166:	89 e5                	mov    %esp,%ebp
  802168:	83 ec 08             	sub    $0x8,%esp
  80216b:	8b 45 08             	mov    0x8(%ebp),%eax
  80216e:	e8 be ff ff ff       	call   802131 <fd2sockid>
  802173:	89 c2                	mov    %eax,%edx
  802175:	85 c0                	test   %eax,%eax
  802177:	78 11                	js     80218a <listen+0x25>
  802179:	8b 45 0c             	mov    0xc(%ebp),%eax
  80217c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802180:	89 14 24             	mov    %edx,(%esp)
  802183:	e8 48 01 00 00       	call   8022d0 <nsipc_listen>
  802188:	89 c2                	mov    %eax,%edx
  80218a:	89 d0                	mov    %edx,%eax
  80218c:	c9                   	leave  
  80218d:	c3                   	ret    

0080218e <connect>:
  80218e:	55                   	push   %ebp
  80218f:	89 e5                	mov    %esp,%ebp
  802191:	83 ec 18             	sub    $0x18,%esp
  802194:	8b 45 08             	mov    0x8(%ebp),%eax
  802197:	e8 95 ff ff ff       	call   802131 <fd2sockid>
  80219c:	89 c2                	mov    %eax,%edx
  80219e:	85 c0                	test   %eax,%eax
  8021a0:	78 18                	js     8021ba <connect+0x2c>
  8021a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8021a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021b0:	89 14 24             	mov    %edx,(%esp)
  8021b3:	e8 71 02 00 00       	call   802429 <nsipc_connect>
  8021b8:	89 c2                	mov    %eax,%edx
  8021ba:	89 d0                	mov    %edx,%eax
  8021bc:	c9                   	leave  
  8021bd:	c3                   	ret    

008021be <shutdown>:
  8021be:	55                   	push   %ebp
  8021bf:	89 e5                	mov    %esp,%ebp
  8021c1:	83 ec 08             	sub    $0x8,%esp
  8021c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8021c7:	e8 65 ff ff ff       	call   802131 <fd2sockid>
  8021cc:	89 c2                	mov    %eax,%edx
  8021ce:	85 c0                	test   %eax,%eax
  8021d0:	78 11                	js     8021e3 <shutdown+0x25>
  8021d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021d9:	89 14 24             	mov    %edx,(%esp)
  8021dc:	e8 2b 01 00 00       	call   80230c <nsipc_shutdown>
  8021e1:	89 c2                	mov    %eax,%edx
  8021e3:	89 d0                	mov    %edx,%eax
  8021e5:	c9                   	leave  
  8021e6:	c3                   	ret    

008021e7 <bind>:
  8021e7:	55                   	push   %ebp
  8021e8:	89 e5                	mov    %esp,%ebp
  8021ea:	83 ec 18             	sub    $0x18,%esp
  8021ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f0:	e8 3c ff ff ff       	call   802131 <fd2sockid>
  8021f5:	89 c2                	mov    %eax,%edx
  8021f7:	85 c0                	test   %eax,%eax
  8021f9:	78 18                	js     802213 <bind+0x2c>
  8021fb:	8b 45 10             	mov    0x10(%ebp),%eax
  8021fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  802202:	8b 45 0c             	mov    0xc(%ebp),%eax
  802205:	89 44 24 04          	mov    %eax,0x4(%esp)
  802209:	89 14 24             	mov    %edx,(%esp)
  80220c:	e8 57 02 00 00       	call   802468 <nsipc_bind>
  802211:	89 c2                	mov    %eax,%edx
  802213:	89 d0                	mov    %edx,%eax
  802215:	c9                   	leave  
  802216:	c3                   	ret    

00802217 <accept>:
  802217:	55                   	push   %ebp
  802218:	89 e5                	mov    %esp,%ebp
  80221a:	83 ec 18             	sub    $0x18,%esp
  80221d:	8b 45 08             	mov    0x8(%ebp),%eax
  802220:	e8 0c ff ff ff       	call   802131 <fd2sockid>
  802225:	89 c2                	mov    %eax,%edx
  802227:	85 c0                	test   %eax,%eax
  802229:	78 23                	js     80224e <accept+0x37>
  80222b:	8b 45 10             	mov    0x10(%ebp),%eax
  80222e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802232:	8b 45 0c             	mov    0xc(%ebp),%eax
  802235:	89 44 24 04          	mov    %eax,0x4(%esp)
  802239:	89 14 24             	mov    %edx,(%esp)
  80223c:	e8 66 02 00 00       	call   8024a7 <nsipc_accept>
  802241:	89 c2                	mov    %eax,%edx
  802243:	85 c0                	test   %eax,%eax
  802245:	78 07                	js     80224e <accept+0x37>
  802247:	e8 42 fe ff ff       	call   80208e <alloc_sockfd>
  80224c:	89 c2                	mov    %eax,%edx
  80224e:	89 d0                	mov    %edx,%eax
  802250:	c9                   	leave  
  802251:	c3                   	ret    
	...

00802260 <nsipc>:
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802260:	55                   	push   %ebp
  802261:	89 e5                	mov    %esp,%ebp
  802263:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802266:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  80226c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802273:	00 
  802274:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  80227b:	00 
  80227c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802280:	89 14 24             	mov    %edx,(%esp)
  802283:	e8 78 02 00 00       	call   802500 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802288:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80228f:	00 
  802290:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802297:	00 
  802298:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80229f:	e8 10 03 00 00       	call   8025b4 <ipc_recv>
}
  8022a4:	c9                   	leave  
  8022a5:	c3                   	ret    

008022a6 <nsipc_socket>:

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
  8022a6:	55                   	push   %ebp
  8022a7:	89 e5                	mov    %esp,%ebp
  8022a9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8022ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8022af:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.socket.req_type = type;
  8022b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022b7:	a3 04 50 80 00       	mov    %eax,0x805004
	nsipcbuf.socket.req_protocol = protocol;
  8022bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8022bf:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SOCKET);
  8022c4:	b8 09 00 00 00       	mov    $0x9,%eax
  8022c9:	e8 92 ff ff ff       	call   802260 <nsipc>
}
  8022ce:	c9                   	leave  
  8022cf:	c3                   	ret    

008022d0 <nsipc_listen>:
  8022d0:	55                   	push   %ebp
  8022d1:	89 e5                	mov    %esp,%ebp
  8022d3:	83 ec 08             	sub    $0x8,%esp
  8022d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8022d9:	a3 00 50 80 00       	mov    %eax,0x805000
  8022de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022e1:	a3 04 50 80 00       	mov    %eax,0x805004
  8022e6:	b8 06 00 00 00       	mov    $0x6,%eax
  8022eb:	e8 70 ff ff ff       	call   802260 <nsipc>
  8022f0:	c9                   	leave  
  8022f1:	c3                   	ret    

008022f2 <nsipc_close>:
  8022f2:	55                   	push   %ebp
  8022f3:	89 e5                	mov    %esp,%ebp
  8022f5:	83 ec 08             	sub    $0x8,%esp
  8022f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022fb:	a3 00 50 80 00       	mov    %eax,0x805000
  802300:	b8 04 00 00 00       	mov    $0x4,%eax
  802305:	e8 56 ff ff ff       	call   802260 <nsipc>
  80230a:	c9                   	leave  
  80230b:	c3                   	ret    

0080230c <nsipc_shutdown>:
  80230c:	55                   	push   %ebp
  80230d:	89 e5                	mov    %esp,%ebp
  80230f:	83 ec 08             	sub    $0x8,%esp
  802312:	8b 45 08             	mov    0x8(%ebp),%eax
  802315:	a3 00 50 80 00       	mov    %eax,0x805000
  80231a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80231d:	a3 04 50 80 00       	mov    %eax,0x805004
  802322:	b8 03 00 00 00       	mov    $0x3,%eax
  802327:	e8 34 ff ff ff       	call   802260 <nsipc>
  80232c:	c9                   	leave  
  80232d:	c3                   	ret    

0080232e <nsipc_send>:
  80232e:	55                   	push   %ebp
  80232f:	89 e5                	mov    %esp,%ebp
  802331:	53                   	push   %ebx
  802332:	83 ec 14             	sub    $0x14,%esp
  802335:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802338:	8b 45 08             	mov    0x8(%ebp),%eax
  80233b:	a3 00 50 80 00       	mov    %eax,0x805000
  802340:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802346:	7e 24                	jle    80236c <nsipc_send+0x3e>
  802348:	c7 44 24 0c d4 2e 80 	movl   $0x802ed4,0xc(%esp)
  80234f:	00 
  802350:	c7 44 24 08 2e 2e 80 	movl   $0x802e2e,0x8(%esp)
  802357:	00 
  802358:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  80235f:	00 
  802360:	c7 04 24 e0 2e 80 00 	movl   $0x802ee0,(%esp)
  802367:	e8 68 de ff ff       	call   8001d4 <_panic>
  80236c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802370:	8b 45 0c             	mov    0xc(%ebp),%eax
  802373:	89 44 24 04          	mov    %eax,0x4(%esp)
  802377:	c7 04 24 0c 50 80 00 	movl   $0x80500c,(%esp)
  80237e:	e8 a7 e7 ff ff       	call   800b2a <memmove>
  802383:	89 1d 04 50 80 00    	mov    %ebx,0x805004
  802389:	8b 45 14             	mov    0x14(%ebp),%eax
  80238c:	a3 08 50 80 00       	mov    %eax,0x805008
  802391:	b8 08 00 00 00       	mov    $0x8,%eax
  802396:	e8 c5 fe ff ff       	call   802260 <nsipc>
  80239b:	83 c4 14             	add    $0x14,%esp
  80239e:	5b                   	pop    %ebx
  80239f:	5d                   	pop    %ebp
  8023a0:	c3                   	ret    

008023a1 <nsipc_recv>:
  8023a1:	55                   	push   %ebp
  8023a2:	89 e5                	mov    %esp,%ebp
  8023a4:	83 ec 18             	sub    $0x18,%esp
  8023a7:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  8023aa:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  8023ad:	8b 75 10             	mov    0x10(%ebp),%esi
  8023b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8023b3:	a3 00 50 80 00       	mov    %eax,0x805000
  8023b8:	89 35 04 50 80 00    	mov    %esi,0x805004
  8023be:	8b 45 14             	mov    0x14(%ebp),%eax
  8023c1:	a3 08 50 80 00       	mov    %eax,0x805008
  8023c6:	b8 07 00 00 00       	mov    $0x7,%eax
  8023cb:	e8 90 fe ff ff       	call   802260 <nsipc>
  8023d0:	89 c3                	mov    %eax,%ebx
  8023d2:	85 c0                	test   %eax,%eax
  8023d4:	78 47                	js     80241d <nsipc_recv+0x7c>
  8023d6:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8023db:	7f 05                	jg     8023e2 <nsipc_recv+0x41>
  8023dd:	39 c6                	cmp    %eax,%esi
  8023df:	90                   	nop    
  8023e0:	7d 24                	jge    802406 <nsipc_recv+0x65>
  8023e2:	c7 44 24 0c ec 2e 80 	movl   $0x802eec,0xc(%esp)
  8023e9:	00 
  8023ea:	c7 44 24 08 2e 2e 80 	movl   $0x802e2e,0x8(%esp)
  8023f1:	00 
  8023f2:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  8023f9:	00 
  8023fa:	c7 04 24 e0 2e 80 00 	movl   $0x802ee0,(%esp)
  802401:	e8 ce dd ff ff       	call   8001d4 <_panic>
  802406:	89 44 24 08          	mov    %eax,0x8(%esp)
  80240a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  802411:	00 
  802412:	8b 45 0c             	mov    0xc(%ebp),%eax
  802415:	89 04 24             	mov    %eax,(%esp)
  802418:	e8 0d e7 ff ff       	call   800b2a <memmove>
  80241d:	89 d8                	mov    %ebx,%eax
  80241f:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  802422:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  802425:	89 ec                	mov    %ebp,%esp
  802427:	5d                   	pop    %ebp
  802428:	c3                   	ret    

00802429 <nsipc_connect>:
  802429:	55                   	push   %ebp
  80242a:	89 e5                	mov    %esp,%ebp
  80242c:	53                   	push   %ebx
  80242d:	83 ec 14             	sub    $0x14,%esp
  802430:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802433:	8b 45 08             	mov    0x8(%ebp),%eax
  802436:	a3 00 50 80 00       	mov    %eax,0x805000
  80243b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80243f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802442:	89 44 24 04          	mov    %eax,0x4(%esp)
  802446:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  80244d:	e8 d8 e6 ff ff       	call   800b2a <memmove>
  802452:	89 1d 14 50 80 00    	mov    %ebx,0x805014
  802458:	b8 05 00 00 00       	mov    $0x5,%eax
  80245d:	e8 fe fd ff ff       	call   802260 <nsipc>
  802462:	83 c4 14             	add    $0x14,%esp
  802465:	5b                   	pop    %ebx
  802466:	5d                   	pop    %ebp
  802467:	c3                   	ret    

00802468 <nsipc_bind>:
  802468:	55                   	push   %ebp
  802469:	89 e5                	mov    %esp,%ebp
  80246b:	53                   	push   %ebx
  80246c:	83 ec 14             	sub    $0x14,%esp
  80246f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802472:	8b 45 08             	mov    0x8(%ebp),%eax
  802475:	a3 00 50 80 00       	mov    %eax,0x805000
  80247a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80247e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802481:	89 44 24 04          	mov    %eax,0x4(%esp)
  802485:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  80248c:	e8 99 e6 ff ff       	call   800b2a <memmove>
  802491:	89 1d 14 50 80 00    	mov    %ebx,0x805014
  802497:	b8 02 00 00 00       	mov    $0x2,%eax
  80249c:	e8 bf fd ff ff       	call   802260 <nsipc>
  8024a1:	83 c4 14             	add    $0x14,%esp
  8024a4:	5b                   	pop    %ebx
  8024a5:	5d                   	pop    %ebp
  8024a6:	c3                   	ret    

008024a7 <nsipc_accept>:
  8024a7:	55                   	push   %ebp
  8024a8:	89 e5                	mov    %esp,%ebp
  8024aa:	53                   	push   %ebx
  8024ab:	83 ec 14             	sub    $0x14,%esp
  8024ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8024b1:	a3 00 50 80 00       	mov    %eax,0x805000
  8024b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024bb:	e8 a0 fd ff ff       	call   802260 <nsipc>
  8024c0:	89 c3                	mov    %eax,%ebx
  8024c2:	85 c0                	test   %eax,%eax
  8024c4:	78 27                	js     8024ed <nsipc_accept+0x46>
  8024c6:	a1 10 50 80 00       	mov    0x805010,%eax
  8024cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024cf:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8024d6:	00 
  8024d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024da:	89 04 24             	mov    %eax,(%esp)
  8024dd:	e8 48 e6 ff ff       	call   800b2a <memmove>
  8024e2:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8024e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8024eb:	89 10                	mov    %edx,(%eax)
  8024ed:	89 d8                	mov    %ebx,%eax
  8024ef:	83 c4 14             	add    $0x14,%esp
  8024f2:	5b                   	pop    %ebx
  8024f3:	5d                   	pop    %ebp
  8024f4:	c3                   	ret    
	...

00802500 <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802500:	55                   	push   %ebp
  802501:	89 e5                	mov    %esp,%ebp
  802503:	57                   	push   %edi
  802504:	56                   	push   %esi
  802505:	53                   	push   %ebx
  802506:	83 ec 1c             	sub    $0x1c,%esp
  802509:	8b 75 08             	mov    0x8(%ebp),%esi
  80250c:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  80250f:	e8 c9 eb ff ff       	call   8010dd <sys_getenvid>
  802514:	25 ff 03 00 00       	and    $0x3ff,%eax
  802519:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80251c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802521:	a3 3c 60 80 00       	mov    %eax,0x80603c
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  802526:	e8 b2 eb ff ff       	call   8010dd <sys_getenvid>
  80252b:	25 ff 03 00 00       	and    $0x3ff,%eax
  802530:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802533:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802538:	a3 3c 60 80 00       	mov    %eax,0x80603c
		if(env->env_id==to_env){
  80253d:	8b 40 4c             	mov    0x4c(%eax),%eax
  802540:	39 f0                	cmp    %esi,%eax
  802542:	75 0e                	jne    802552 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  802544:	c7 04 24 01 2f 80 00 	movl   $0x802f01,(%esp)
  80254b:	e8 51 dd ff ff       	call   8002a1 <cprintf>
  802550:	eb 5a                	jmp    8025ac <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  802552:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802556:	8b 45 10             	mov    0x10(%ebp),%eax
  802559:	89 44 24 08          	mov    %eax,0x8(%esp)
  80255d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802560:	89 44 24 04          	mov    %eax,0x4(%esp)
  802564:	89 34 24             	mov    %esi,(%esp)
  802567:	e8 d0 e8 ff ff       	call   800e3c <sys_ipc_try_send>
  80256c:	89 c3                	mov    %eax,%ebx
  80256e:	85 c0                	test   %eax,%eax
  802570:	79 25                	jns    802597 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  802572:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802575:	74 2b                	je     8025a2 <ipc_send+0xa2>
				panic("send error:%e",r);
  802577:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80257b:	c7 44 24 08 1d 2f 80 	movl   $0x802f1d,0x8(%esp)
  802582:	00 
  802583:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80258a:	00 
  80258b:	c7 04 24 2b 2f 80 00 	movl   $0x802f2b,(%esp)
  802592:	e8 3d dc ff ff       	call   8001d4 <_panic>
		}
			sys_yield();
  802597:	e8 0d eb ff ff       	call   8010a9 <sys_yield>
		
	}while(r!=0);
  80259c:	85 db                	test   %ebx,%ebx
  80259e:	75 86                	jne    802526 <ipc_send+0x26>
  8025a0:	eb 0a                	jmp    8025ac <ipc_send+0xac>
  8025a2:	e8 02 eb ff ff       	call   8010a9 <sys_yield>
  8025a7:	e9 7a ff ff ff       	jmp    802526 <ipc_send+0x26>
	return;
	//panic("ipc_send not implemented");
}
  8025ac:	83 c4 1c             	add    $0x1c,%esp
  8025af:	5b                   	pop    %ebx
  8025b0:	5e                   	pop    %esi
  8025b1:	5f                   	pop    %edi
  8025b2:	5d                   	pop    %ebp
  8025b3:	c3                   	ret    

008025b4 <ipc_recv>:
  8025b4:	55                   	push   %ebp
  8025b5:	89 e5                	mov    %esp,%ebp
  8025b7:	57                   	push   %edi
  8025b8:	56                   	push   %esi
  8025b9:	53                   	push   %ebx
  8025ba:	83 ec 0c             	sub    $0xc,%esp
  8025bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8025c0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8025c3:	e8 15 eb ff ff       	call   8010dd <sys_getenvid>
  8025c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8025cd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8025d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8025d5:	a3 3c 60 80 00       	mov    %eax,0x80603c
  8025da:	85 f6                	test   %esi,%esi
  8025dc:	74 29                	je     802607 <ipc_recv+0x53>
  8025de:	8b 40 4c             	mov    0x4c(%eax),%eax
  8025e1:	3b 06                	cmp    (%esi),%eax
  8025e3:	75 22                	jne    802607 <ipc_recv+0x53>
  8025e5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8025eb:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8025f1:	c7 04 24 01 2f 80 00 	movl   $0x802f01,(%esp)
  8025f8:	e8 a4 dc ff ff       	call   8002a1 <cprintf>
  8025fd:	bb 00 00 00 00       	mov    $0x0,%ebx
  802602:	e9 8a 00 00 00       	jmp    802691 <ipc_recv+0xdd>
  802607:	e8 d1 ea ff ff       	call   8010dd <sys_getenvid>
  80260c:	25 ff 03 00 00       	and    $0x3ff,%eax
  802611:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802614:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802619:	a3 3c 60 80 00       	mov    %eax,0x80603c
  80261e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802621:	89 04 24             	mov    %eax,(%esp)
  802624:	e8 b6 e7 ff ff       	call   800ddf <sys_ipc_recv>
  802629:	89 c3                	mov    %eax,%ebx
  80262b:	85 c0                	test   %eax,%eax
  80262d:	79 1a                	jns    802649 <ipc_recv+0x95>
  80262f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802635:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  80263b:	c7 04 24 35 2f 80 00 	movl   $0x802f35,(%esp)
  802642:	e8 5a dc ff ff       	call   8002a1 <cprintf>
  802647:	eb 48                	jmp    802691 <ipc_recv+0xdd>
  802649:	e8 8f ea ff ff       	call   8010dd <sys_getenvid>
  80264e:	25 ff 03 00 00       	and    $0x3ff,%eax
  802653:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802656:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80265b:	a3 3c 60 80 00       	mov    %eax,0x80603c
  802660:	85 f6                	test   %esi,%esi
  802662:	74 05                	je     802669 <ipc_recv+0xb5>
  802664:	8b 40 74             	mov    0x74(%eax),%eax
  802667:	89 06                	mov    %eax,(%esi)
  802669:	85 ff                	test   %edi,%edi
  80266b:	74 0a                	je     802677 <ipc_recv+0xc3>
  80266d:	a1 3c 60 80 00       	mov    0x80603c,%eax
  802672:	8b 40 78             	mov    0x78(%eax),%eax
  802675:	89 07                	mov    %eax,(%edi)
  802677:	e8 61 ea ff ff       	call   8010dd <sys_getenvid>
  80267c:	25 ff 03 00 00       	and    $0x3ff,%eax
  802681:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802684:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802689:	a3 3c 60 80 00       	mov    %eax,0x80603c
  80268e:	8b 58 70             	mov    0x70(%eax),%ebx
  802691:	89 d8                	mov    %ebx,%eax
  802693:	83 c4 0c             	add    $0xc,%esp
  802696:	5b                   	pop    %ebx
  802697:	5e                   	pop    %esi
  802698:	5f                   	pop    %edi
  802699:	5d                   	pop    %ebp
  80269a:	c3                   	ret    
  80269b:	00 00                	add    %al,(%eax)
  80269d:	00 00                	add    %al,(%eax)
	...

008026a0 <__udivdi3>:
  8026a0:	55                   	push   %ebp
  8026a1:	89 e5                	mov    %esp,%ebp
  8026a3:	57                   	push   %edi
  8026a4:	56                   	push   %esi
  8026a5:	83 ec 1c             	sub    $0x1c,%esp
  8026a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8026ab:	8b 55 14             	mov    0x14(%ebp),%edx
  8026ae:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8026b1:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  8026b4:	89 c1                	mov    %eax,%ecx
  8026b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8026b9:	85 d2                	test   %edx,%edx
  8026bb:	89 d6                	mov    %edx,%esi
  8026bd:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
  8026c0:	75 1e                	jne    8026e0 <__udivdi3+0x40>
  8026c2:	39 f9                	cmp    %edi,%ecx
  8026c4:	0f 86 8d 00 00 00    	jbe    802757 <__udivdi3+0xb7>
  8026ca:	89 fa                	mov    %edi,%edx
  8026cc:	f7 f1                	div    %ecx
  8026ce:	89 c1                	mov    %eax,%ecx
  8026d0:	89 c8                	mov    %ecx,%eax
  8026d2:	89 f2                	mov    %esi,%edx
  8026d4:	83 c4 1c             	add    $0x1c,%esp
  8026d7:	5e                   	pop    %esi
  8026d8:	5f                   	pop    %edi
  8026d9:	5d                   	pop    %ebp
  8026da:	c3                   	ret    
  8026db:	90                   	nop    
  8026dc:	8d 74 26 00          	lea    0x0(%esi),%esi
  8026e0:	39 fa                	cmp    %edi,%edx
  8026e2:	0f 87 98 00 00 00    	ja     802780 <__udivdi3+0xe0>
  8026e8:	0f bd c2             	bsr    %edx,%eax
  8026eb:	83 f0 1f             	xor    $0x1f,%eax
  8026ee:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8026f1:	74 7f                	je     802772 <__udivdi3+0xd2>
  8026f3:	b8 20 00 00 00       	mov    $0x20,%eax
  8026f8:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  8026fb:	2b 45 e4             	sub    0xffffffe4(%ebp),%eax
  8026fe:	89 c1                	mov    %eax,%ecx
  802700:	d3 ea                	shr    %cl,%edx
  802702:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802706:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  802709:	89 f0                	mov    %esi,%eax
  80270b:	d3 e0                	shl    %cl,%eax
  80270d:	09 c2                	or     %eax,%edx
  80270f:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802712:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  802715:	89 fa                	mov    %edi,%edx
  802717:	d3 e0                	shl    %cl,%eax
  802719:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  80271d:	89 45 f4             	mov    %eax,0xfffffff4(%ebp)
  802720:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802723:	d3 e8                	shr    %cl,%eax
  802725:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802729:	d3 e2                	shl    %cl,%edx
  80272b:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  80272f:	09 d0                	or     %edx,%eax
  802731:	d3 ef                	shr    %cl,%edi
  802733:	89 fa                	mov    %edi,%edx
  802735:	f7 75 e0             	divl   0xffffffe0(%ebp)
  802738:	89 d1                	mov    %edx,%ecx
  80273a:	89 c7                	mov    %eax,%edi
  80273c:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80273f:	f7 e7                	mul    %edi
  802741:	39 d1                	cmp    %edx,%ecx
  802743:	89 c6                	mov    %eax,%esi
  802745:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  802748:	72 6f                	jb     8027b9 <__udivdi3+0x119>
  80274a:	39 ca                	cmp    %ecx,%edx
  80274c:	74 5e                	je     8027ac <__udivdi3+0x10c>
  80274e:	89 f9                	mov    %edi,%ecx
  802750:	31 f6                	xor    %esi,%esi
  802752:	e9 79 ff ff ff       	jmp    8026d0 <__udivdi3+0x30>
  802757:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80275a:	85 c0                	test   %eax,%eax
  80275c:	74 32                	je     802790 <__udivdi3+0xf0>
  80275e:	89 f2                	mov    %esi,%edx
  802760:	89 f8                	mov    %edi,%eax
  802762:	f7 f1                	div    %ecx
  802764:	89 c6                	mov    %eax,%esi
  802766:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802769:	f7 f1                	div    %ecx
  80276b:	89 c1                	mov    %eax,%ecx
  80276d:	e9 5e ff ff ff       	jmp    8026d0 <__udivdi3+0x30>
  802772:	39 d7                	cmp    %edx,%edi
  802774:	77 2a                	ja     8027a0 <__udivdi3+0x100>
  802776:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  802779:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
  80277c:	73 22                	jae    8027a0 <__udivdi3+0x100>
  80277e:	66 90                	xchg   %ax,%ax
  802780:	31 c9                	xor    %ecx,%ecx
  802782:	31 f6                	xor    %esi,%esi
  802784:	e9 47 ff ff ff       	jmp    8026d0 <__udivdi3+0x30>
  802789:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  802790:	b8 01 00 00 00       	mov    $0x1,%eax
  802795:	31 d2                	xor    %edx,%edx
  802797:	f7 75 f0             	divl   0xfffffff0(%ebp)
  80279a:	89 c1                	mov    %eax,%ecx
  80279c:	eb c0                	jmp    80275e <__udivdi3+0xbe>
  80279e:	66 90                	xchg   %ax,%ax
  8027a0:	b9 01 00 00 00       	mov    $0x1,%ecx
  8027a5:	31 f6                	xor    %esi,%esi
  8027a7:	e9 24 ff ff ff       	jmp    8026d0 <__udivdi3+0x30>
  8027ac:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8027af:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8027b3:	d3 e0                	shl    %cl,%eax
  8027b5:	39 c6                	cmp    %eax,%esi
  8027b7:	76 95                	jbe    80274e <__udivdi3+0xae>
  8027b9:	8d 4f ff             	lea    0xffffffff(%edi),%ecx
  8027bc:	31 f6                	xor    %esi,%esi
  8027be:	e9 0d ff ff ff       	jmp    8026d0 <__udivdi3+0x30>
	...

008027d0 <__umoddi3>:
  8027d0:	55                   	push   %ebp
  8027d1:	89 e5                	mov    %esp,%ebp
  8027d3:	57                   	push   %edi
  8027d4:	56                   	push   %esi
  8027d5:	83 ec 30             	sub    $0x30,%esp
  8027d8:	8b 55 14             	mov    0x14(%ebp),%edx
  8027db:	8b 45 10             	mov    0x10(%ebp),%eax
  8027de:	8b 75 08             	mov    0x8(%ebp),%esi
  8027e1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8027e4:	85 d2                	test   %edx,%edx
  8027e6:	c7 45 d0 00 00 00 00 	movl   $0x0,0xffffffd0(%ebp)
  8027ed:	89 c1                	mov    %eax,%ecx
  8027ef:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  8027f6:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  8027f9:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  8027fc:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  8027ff:	89 7d e0             	mov    %edi,0xffffffe0(%ebp)
  802802:	75 1c                	jne    802820 <__umoddi3+0x50>
  802804:	39 f8                	cmp    %edi,%eax
  802806:	89 fa                	mov    %edi,%edx
  802808:	0f 86 d4 00 00 00    	jbe    8028e2 <__umoddi3+0x112>
  80280e:	89 f0                	mov    %esi,%eax
  802810:	f7 f1                	div    %ecx
  802812:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802815:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  80281c:	eb 12                	jmp    802830 <__umoddi3+0x60>
  80281e:	66 90                	xchg   %ax,%ax
  802820:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802823:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  802826:	76 18                	jbe    802840 <__umoddi3+0x70>
  802828:	89 75 d0             	mov    %esi,0xffffffd0(%ebp)
  80282b:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  80282e:	66 90                	xchg   %ax,%ax
  802830:	8b 45 d0             	mov    0xffffffd0(%ebp),%eax
  802833:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  802836:	83 c4 30             	add    $0x30,%esp
  802839:	5e                   	pop    %esi
  80283a:	5f                   	pop    %edi
  80283b:	5d                   	pop    %ebp
  80283c:	c3                   	ret    
  80283d:	8d 76 00             	lea    0x0(%esi),%esi
  802840:	0f bd 45 e8          	bsr    0xffffffe8(%ebp),%eax
  802844:	83 f0 1f             	xor    $0x1f,%eax
  802847:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  80284a:	0f 84 c0 00 00 00    	je     802910 <__umoddi3+0x140>
  802850:	b8 20 00 00 00       	mov    $0x20,%eax
  802855:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  802858:	2b 45 dc             	sub    0xffffffdc(%ebp),%eax
  80285b:	8b 7d ec             	mov    0xffffffec(%ebp),%edi
  80285e:	8b 75 f0             	mov    0xfffffff0(%ebp),%esi
  802861:	89 c1                	mov    %eax,%ecx
  802863:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  802866:	d3 ea                	shr    %cl,%edx
  802868:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  80286b:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  80286f:	d3 e0                	shl    %cl,%eax
  802871:	09 c2                	or     %eax,%edx
  802873:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802876:	d3 e7                	shl    %cl,%edi
  802878:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  80287c:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  80287f:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  802882:	d3 e8                	shr    %cl,%eax
  802884:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  802888:	d3 e2                	shl    %cl,%edx
  80288a:	09 d0                	or     %edx,%eax
  80288c:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  80288f:	d3 e6                	shl    %cl,%esi
  802891:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802895:	d3 ea                	shr    %cl,%edx
  802897:	f7 75 f4             	divl   0xfffffff4(%ebp)
  80289a:	89 55 cc             	mov    %edx,0xffffffcc(%ebp)
  80289d:	f7 e7                	mul    %edi
  80289f:	39 55 cc             	cmp    %edx,0xffffffcc(%ebp)
  8028a2:	0f 82 a5 00 00 00    	jb     80294d <__umoddi3+0x17d>
  8028a8:	3b 55 cc             	cmp    0xffffffcc(%ebp),%edx
  8028ab:	0f 84 94 00 00 00    	je     802945 <__umoddi3+0x175>
  8028b1:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
  8028b4:	29 c6                	sub    %eax,%esi
  8028b6:	19 d1                	sbb    %edx,%ecx
  8028b8:	89 4d cc             	mov    %ecx,0xffffffcc(%ebp)
  8028bb:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  8028bf:	89 f2                	mov    %esi,%edx
  8028c1:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  8028c4:	d3 ea                	shr    %cl,%edx
  8028c6:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8028ca:	d3 e0                	shl    %cl,%eax
  8028cc:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  8028d0:	09 c2                	or     %eax,%edx
  8028d2:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  8028d5:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  8028d8:	d3 e8                	shr    %cl,%eax
  8028da:	89 45 d4             	mov    %eax,0xffffffd4(%ebp)
  8028dd:	e9 4e ff ff ff       	jmp    802830 <__umoddi3+0x60>
  8028e2:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  8028e5:	85 c0                	test   %eax,%eax
  8028e7:	74 17                	je     802900 <__umoddi3+0x130>
  8028e9:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  8028ec:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
  8028ef:	f7 f1                	div    %ecx
  8028f1:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8028f4:	f7 f1                	div    %ecx
  8028f6:	e9 17 ff ff ff       	jmp    802812 <__umoddi3+0x42>
  8028fb:	90                   	nop    
  8028fc:	8d 74 26 00          	lea    0x0(%esi),%esi
  802900:	b8 01 00 00 00       	mov    $0x1,%eax
  802905:	31 d2                	xor    %edx,%edx
  802907:	f7 75 ec             	divl   0xffffffec(%ebp)
  80290a:	89 c1                	mov    %eax,%ecx
  80290c:	eb db                	jmp    8028e9 <__umoddi3+0x119>
  80290e:	66 90                	xchg   %ax,%ax
  802910:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802913:	39 45 e0             	cmp    %eax,0xffffffe0(%ebp)
  802916:	77 19                	ja     802931 <__umoddi3+0x161>
  802918:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  80291b:	39 55 f0             	cmp    %edx,0xfffffff0(%ebp)
  80291e:	73 11                	jae    802931 <__umoddi3+0x161>
  802920:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  802923:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802926:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802929:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  80292c:	e9 ff fe ff ff       	jmp    802830 <__umoddi3+0x60>
  802931:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802934:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802937:	2b 45 ec             	sub    0xffffffec(%ebp),%eax
  80293a:	1b 4d e8             	sbb    0xffffffe8(%ebp),%ecx
  80293d:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  802940:	89 4d e0             	mov    %ecx,0xffffffe0(%ebp)
  802943:	eb db                	jmp    802920 <__umoddi3+0x150>
  802945:	39 f0                	cmp    %esi,%eax
  802947:	0f 86 64 ff ff ff    	jbe    8028b1 <__umoddi3+0xe1>
  80294d:	29 f8                	sub    %edi,%eax
  80294f:	1b 55 f4             	sbb    0xfffffff4(%ebp),%edx
  802952:	e9 5a ff ff ff       	jmp    8028b1 <__umoddi3+0xe1>
