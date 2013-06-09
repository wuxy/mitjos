
obj/user/primes:     file format elf32-i386

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
  80002c:	e8 17 01 00 00       	call   800148 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <primeproc>:
#include <inc/lib.h>

unsigned
primeproc(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800044:	00 
  800045:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80004c:	00 
  80004d:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  800050:	89 04 24             	mov    %eax,(%esp)
  800053:	e8 0c 17 00 00       	call   801764 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("%d ", p);
  80005a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005e:	c7 04 24 a0 29 80 00 	movl   $0x8029a0,(%esp)
  800065:	e8 23 02 00 00       	call   80028d <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  80006a:	e8 3a 15 00 00       	call   8015a9 <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 20                	jns    800095 <primeproc+0x61>
		panic("fork: %e", id);
  800075:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800079:	c7 44 24 08 dc 2d 80 	movl   $0x802ddc,0x8(%esp)
  800080:	00 
  800081:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800088:	00 
  800089:	c7 04 24 a4 29 80 00 	movl   $0x8029a4,(%esp)
  800090:	e8 2b 01 00 00       	call   8001c0 <_panic>
	if (id == 0)
  800095:	85 c0                	test   %eax,%eax
  800097:	74 a4                	je     80003d <primeproc+0x9>
  800099:	8d 7d f0             	lea    0xfffffff0(%ebp),%edi
		goto top;
	
	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  80009c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000a3:	00 
  8000a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000ab:	00 
  8000ac:	89 3c 24             	mov    %edi,(%esp)
  8000af:	e8 b0 16 00 00       	call   801764 <ipc_recv>
  8000b4:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000b6:	89 c2                	mov    %eax,%edx
  8000b8:	c1 fa 1f             	sar    $0x1f,%edx
  8000bb:	f7 fb                	idiv   %ebx
  8000bd:	85 d2                	test   %edx,%edx
  8000bf:	74 db                	je     80009c <primeproc+0x68>
			ipc_send(id, i, 0, 0);
  8000c1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000c8:	00 
  8000c9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000d0:	00 
  8000d1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8000d5:	89 34 24             	mov    %esi,(%esp)
  8000d8:	e8 d3 15 00 00       	call   8016b0 <ipc_send>
  8000dd:	eb bd                	jmp    80009c <primeproc+0x68>

008000df <umain>:
	}
}

void
umain(void)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	56                   	push   %esi
  8000e3:	53                   	push   %ebx
  8000e4:	83 ec 10             	sub    $0x10,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000e7:	e8 bd 14 00 00       	call   8015a9 <fork>
  8000ec:	89 c3                	mov    %eax,%ebx
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	79 20                	jns    800112 <umain+0x33>
		panic("fork: %e", id);
  8000f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f6:	c7 44 24 08 dc 2d 80 	movl   $0x802ddc,0x8(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800105:	00 
  800106:	c7 04 24 a4 29 80 00 	movl   $0x8029a4,(%esp)
  80010d:	e8 ae 00 00 00       	call   8001c0 <_panic>
	if (id == 0)
  800112:	be 02 00 00 00       	mov    $0x2,%esi
  800117:	85 c0                	test   %eax,%eax
  800119:	75 0a                	jne    800125 <umain+0x46>
		primeproc();
  80011b:	e8 14 ff ff ff       	call   800034 <primeproc>
  800120:	be 02 00 00 00       	mov    $0x2,%esi

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  800125:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80012c:	00 
  80012d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800134:	00 
  800135:	89 74 24 04          	mov    %esi,0x4(%esp)
  800139:	89 1c 24             	mov    %ebx,(%esp)
  80013c:	e8 6f 15 00 00       	call   8016b0 <ipc_send>
  800141:	83 c6 01             	add    $0x1,%esi
  800144:	eb df                	jmp    800125 <umain+0x46>
	...

00800148 <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 18             	sub    $0x18,%esp
  80014e:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  800151:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  800154:	8b 75 08             	mov    0x8(%ebp),%esi
  800157:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  80015a:	c7 05 3c 60 80 00 00 	movl   $0x0,0x80603c
  800161:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  800164:	e8 64 0f 00 00       	call   8010cd <sys_getenvid>
  800169:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800171:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800176:	a3 3c 60 80 00       	mov    %eax,0x80603c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80017b:	85 f6                	test   %esi,%esi
  80017d:	7e 07                	jle    800186 <libmain+0x3e>
		binaryname = argv[0];
  80017f:	8b 03                	mov    (%ebx),%eax
  800181:	a3 00 60 80 00       	mov    %eax,0x806000

	// call user main routine调用用户主例程
	umain(argc, argv);
  800186:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80018a:	89 34 24             	mov    %esi,(%esp)
  80018d:	e8 4d ff ff ff       	call   8000df <umain>

	// exit gracefully
	exit();
  800192:	e8 0d 00 00 00       	call   8001a4 <exit>
}
  800197:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  80019a:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  80019d:	89 ec                	mov    %ebp,%esp
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    
  8001a1:	00 00                	add    %al,(%eax)
	...

008001a4 <exit>:
#include <inc/lib.h>

void
exit(void)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001aa:	e8 97 1c 00 00       	call   801e46 <close_all>
	sys_env_destroy(0);
  8001af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001b6:	e8 46 0f 00 00       	call   801101 <sys_env_destroy>
}
  8001bb:	c9                   	leave  
  8001bc:	c3                   	ret    
  8001bd:	00 00                	add    %al,(%eax)
	...

008001c0 <_panic>:
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8001c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8001c9:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)

	// Print the panic message
	if (argv0)
  8001cc:	a1 40 60 80 00       	mov    0x806040,%eax
  8001d1:	85 c0                	test   %eax,%eax
  8001d3:	74 10                	je     8001e5 <_panic+0x25>
		cprintf("%s: ", argv0);
  8001d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d9:	c7 04 24 c9 29 80 00 	movl   $0x8029c9,(%esp)
  8001e0:	e8 a8 00 00 00       	call   80028d <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8001e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001f3:	a1 00 60 80 00       	mov    0x806000,%eax
  8001f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fc:	c7 04 24 ce 29 80 00 	movl   $0x8029ce,(%esp)
  800203:	e8 85 00 00 00       	call   80028d <cprintf>
	vcprintf(fmt, ap);
  800208:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  80020b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020f:	8b 45 10             	mov    0x10(%ebp),%eax
  800212:	89 04 24             	mov    %eax,(%esp)
  800215:	e8 12 00 00 00       	call   80022c <vcprintf>
	cprintf("\n");
  80021a:	c7 04 24 56 2e 80 00 	movl   $0x802e56,(%esp)
  800221:	e8 67 00 00 00       	call   80028d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800226:	cc                   	int3   
  800227:	eb fd                	jmp    800226 <_panic+0x66>
  800229:	00 00                	add    %al,(%eax)
	...

0080022c <vcprintf>:
}

int
vcprintf(const char *fmt, va_list ap)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800235:	c7 85 f8 fe ff ff 00 	movl   $0x0,0xfffffef8(%ebp)
  80023c:	00 00 00 
	b.cnt = 0;
  80023f:	c7 85 fc fe ff ff 00 	movl   $0x0,0xfffffefc(%ebp)
  800246:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800249:	8b 45 0c             	mov    0xc(%ebp),%eax
  80024c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800250:	8b 45 08             	mov    0x8(%ebp),%eax
  800253:	89 44 24 08          	mov    %eax,0x8(%esp)
  800257:	8d 85 f8 fe ff ff    	lea    0xfffffef8(%ebp),%eax
  80025d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800261:	c7 04 24 aa 02 80 00 	movl   $0x8002aa,(%esp)
  800268:	e8 c4 01 00 00       	call   800431 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026d:	8b 85 f8 fe ff ff    	mov    0xfffffef8(%ebp),%eax
  800273:	89 44 24 04          	mov    %eax,0x4(%esp)
  800277:	8d 85 00 ff ff ff    	lea    0xffffff00(%ebp),%eax
  80027d:	89 04 24             	mov    %eax,(%esp)
  800280:	e8 e3 0a 00 00       	call   800d68 <sys_cputs>
  800285:	8b 85 fc fe ff ff    	mov    0xfffffefc(%ebp),%eax

	return b.cnt;
}
  80028b:	c9                   	leave  
  80028c:	c3                   	ret    

0080028d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800293:	8d 45 0c             	lea    0xc(%ebp),%eax
  800296:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
	cnt = vcprintf(fmt, ap);
  800299:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029d:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a0:	89 04 24             	mov    %eax,(%esp)
  8002a3:	e8 84 ff ff ff       	call   80022c <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a8:	c9                   	leave  
  8002a9:	c3                   	ret    

008002aa <putch>:
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	53                   	push   %ebx
  8002ae:	83 ec 14             	sub    $0x14,%esp
  8002b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b4:	8b 03                	mov    (%ebx),%eax
  8002b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b9:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002bd:	83 c0 01             	add    $0x1,%eax
  8002c0:	89 03                	mov    %eax,(%ebx)
  8002c2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002c7:	75 19                	jne    8002e2 <putch+0x38>
  8002c9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002d0:	00 
  8002d1:	8d 43 08             	lea    0x8(%ebx),%eax
  8002d4:	89 04 24             	mov    %eax,(%esp)
  8002d7:	e8 8c 0a 00 00       	call   800d68 <sys_cputs>
  8002dc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002e2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
  8002e6:	83 c4 14             	add    $0x14,%esp
  8002e9:	5b                   	pop    %ebx
  8002ea:	5d                   	pop    %ebp
  8002eb:	c3                   	ret    
  8002ec:	00 00                	add    %al,(%eax)
	...

008002f0 <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
  8002f6:	83 ec 3c             	sub    $0x3c,%esp
  8002f9:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8002fc:	89 d7                	mov    %edx,%edi
  8002fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800301:	8b 55 0c             	mov    0xc(%ebp),%edx
  800304:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800307:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  80030a:	8b 55 10             	mov    0x10(%ebp),%edx
  80030d:	8b 45 14             	mov    0x14(%ebp),%eax
  800310:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800313:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  800316:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  80031d:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800320:	39 4d ec             	cmp    %ecx,0xffffffec(%ebp)
  800323:	72 11                	jb     800336 <printnum+0x46>
  800325:	8b 4d d8             	mov    0xffffffd8(%ebp),%ecx
  800328:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  80032b:	76 09                	jbe    800336 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80032d:	8d 58 ff             	lea    0xffffffff(%eax),%ebx
  800330:	85 db                	test   %ebx,%ebx
  800332:	7f 54                	jg     800388 <printnum+0x98>
  800334:	eb 61                	jmp    800397 <printnum+0xa7>
  800336:	89 74 24 10          	mov    %esi,0x10(%esp)
  80033a:	83 e8 01             	sub    $0x1,%eax
  80033d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800341:	89 54 24 08          	mov    %edx,0x8(%esp)
  800345:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800349:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80034d:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800350:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800353:	89 44 24 08          	mov    %eax,0x8(%esp)
  800357:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80035b:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  80035e:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800361:	89 14 24             	mov    %edx,(%esp)
  800364:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800368:	e8 73 23 00 00       	call   8026e0 <__udivdi3>
  80036d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800371:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800375:	89 04 24             	mov    %eax,(%esp)
  800378:	89 54 24 04          	mov    %edx,0x4(%esp)
  80037c:	89 fa                	mov    %edi,%edx
  80037e:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  800381:	e8 6a ff ff ff       	call   8002f0 <printnum>
  800386:	eb 0f                	jmp    800397 <printnum+0xa7>
			putch(padc, putdat);
  800388:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80038c:	89 34 24             	mov    %esi,(%esp)
  80038f:	ff 55 e4             	call   *0xffffffe4(%ebp)
  800392:	83 eb 01             	sub    $0x1,%ebx
  800395:	75 f1                	jne    800388 <printnum+0x98>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800397:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80039b:	8b 74 24 04          	mov    0x4(%esp),%esi
  80039f:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8003a2:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  8003a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003ad:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  8003b0:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  8003b3:	89 14 24             	mov    %edx,(%esp)
  8003b6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8003ba:	e8 51 24 00 00       	call   802810 <__umoddi3>
  8003bf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003c3:	0f be 80 ea 29 80 00 	movsbl 0x8029ea(%eax),%eax
  8003ca:	89 04 24             	mov    %eax,(%esp)
  8003cd:	ff 55 e4             	call   *0xffffffe4(%ebp)
}
  8003d0:	83 c4 3c             	add    $0x3c,%esp
  8003d3:	5b                   	pop    %ebx
  8003d4:	5e                   	pop    %esi
  8003d5:	5f                   	pop    %edi
  8003d6:	5d                   	pop    %ebp
  8003d7:	c3                   	ret    

008003d8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8003dd:	83 fa 01             	cmp    $0x1,%edx
  8003e0:	7e 0e                	jle    8003f0 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8003e2:	8b 10                	mov    (%eax),%edx
  8003e4:	8d 42 08             	lea    0x8(%edx),%eax
  8003e7:	89 01                	mov    %eax,(%ecx)
  8003e9:	8b 02                	mov    (%edx),%eax
  8003eb:	8b 52 04             	mov    0x4(%edx),%edx
  8003ee:	eb 22                	jmp    800412 <getuint+0x3a>
	else if (lflag)
  8003f0:	85 d2                	test   %edx,%edx
  8003f2:	74 10                	je     800404 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8003f4:	8b 10                	mov    (%eax),%edx
  8003f6:	8d 42 04             	lea    0x4(%edx),%eax
  8003f9:	89 01                	mov    %eax,(%ecx)
  8003fb:	8b 02                	mov    (%edx),%eax
  8003fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800402:	eb 0e                	jmp    800412 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800404:	8b 10                	mov    (%eax),%edx
  800406:	8d 42 04             	lea    0x4(%edx),%eax
  800409:	89 01                	mov    %eax,(%ecx)
  80040b:	8b 02                	mov    (%edx),%eax
  80040d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800412:	5d                   	pop    %ebp
  800413:	c3                   	ret    

00800414 <sprintputch>:

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
  800414:	55                   	push   %ebp
  800415:	89 e5                	mov    %esp,%ebp
  800417:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  80041a:	83 41 08 01          	addl   $0x1,0x8(%ecx)
	if (b->buf < b->ebuf)
  80041e:	8b 11                	mov    (%ecx),%edx
  800420:	3b 51 04             	cmp    0x4(%ecx),%edx
  800423:	73 0a                	jae    80042f <sprintputch+0x1b>
		*b->buf++ = ch;
  800425:	8b 45 08             	mov    0x8(%ebp),%eax
  800428:	88 02                	mov    %al,(%edx)
  80042a:	8d 42 01             	lea    0x1(%edx),%eax
  80042d:	89 01                	mov    %eax,(%ecx)
}
  80042f:	5d                   	pop    %ebp
  800430:	c3                   	ret    

00800431 <vprintfmt>:
  800431:	55                   	push   %ebp
  800432:	89 e5                	mov    %esp,%ebp
  800434:	57                   	push   %edi
  800435:	56                   	push   %esi
  800436:	53                   	push   %ebx
  800437:	83 ec 4c             	sub    $0x4c,%esp
  80043a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80043d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800440:	eb 03                	jmp    800445 <vprintfmt+0x14>
  800442:	8b 5d e8             	mov    0xffffffe8(%ebp),%ebx
  800445:	0f b6 03             	movzbl (%ebx),%eax
  800448:	83 c3 01             	add    $0x1,%ebx
  80044b:	3c 25                	cmp    $0x25,%al
  80044d:	74 30                	je     80047f <vprintfmt+0x4e>
  80044f:	84 c0                	test   %al,%al
  800451:	0f 84 a8 03 00 00    	je     8007ff <vprintfmt+0x3ce>
  800457:	0f b6 d0             	movzbl %al,%edx
  80045a:	eb 0a                	jmp    800466 <vprintfmt+0x35>
  80045c:	84 c0                	test   %al,%al
  80045e:	66 90                	xchg   %ax,%ax
  800460:	0f 84 99 03 00 00    	je     8007ff <vprintfmt+0x3ce>
  800466:	8b 45 0c             	mov    0xc(%ebp),%eax
  800469:	89 44 24 04          	mov    %eax,0x4(%esp)
  80046d:	89 14 24             	mov    %edx,(%esp)
  800470:	ff d7                	call   *%edi
  800472:	0f b6 03             	movzbl (%ebx),%eax
  800475:	0f b6 d0             	movzbl %al,%edx
  800478:	83 c3 01             	add    $0x1,%ebx
  80047b:	3c 25                	cmp    $0x25,%al
  80047d:	75 dd                	jne    80045c <vprintfmt+0x2b>
  80047f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800484:	c7 45 ec ff ff ff ff 	movl   $0xffffffff,0xffffffec(%ebp)
  80048b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  800492:	c7 45 dc 00 00 00 00 	movl   $0x0,0xffffffdc(%ebp)
  800499:	c6 45 e3 20          	movb   $0x20,0xffffffe3(%ebp)
  80049d:	eb 07                	jmp    8004a6 <vprintfmt+0x75>
  80049f:	c7 45 dc 01 00 00 00 	movl   $0x1,0xffffffdc(%ebp)
  8004a6:	0f b6 03             	movzbl (%ebx),%eax
  8004a9:	0f b6 d0             	movzbl %al,%edx
  8004ac:	83 c3 01             	add    $0x1,%ebx
  8004af:	83 e8 23             	sub    $0x23,%eax
  8004b2:	3c 55                	cmp    $0x55,%al
  8004b4:	0f 87 11 03 00 00    	ja     8007cb <vprintfmt+0x39a>
  8004ba:	0f b6 c0             	movzbl %al,%eax
  8004bd:	ff 24 85 20 2b 80 00 	jmp    *0x802b20(,%eax,4)
  8004c4:	c6 45 e3 30          	movb   $0x30,0xffffffe3(%ebp)
  8004c8:	eb dc                	jmp    8004a6 <vprintfmt+0x75>
  8004ca:	83 ea 30             	sub    $0x30,%edx
  8004cd:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  8004d0:	0f be 13             	movsbl (%ebx),%edx
  8004d3:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  8004d6:	83 f8 09             	cmp    $0x9,%eax
  8004d9:	76 08                	jbe    8004e3 <vprintfmt+0xb2>
  8004db:	eb 42                	jmp    80051f <vprintfmt+0xee>
  8004dd:	c6 45 e3 2d          	movb   $0x2d,0xffffffe3(%ebp)
  8004e1:	eb c3                	jmp    8004a6 <vprintfmt+0x75>
  8004e3:	83 c3 01             	add    $0x1,%ebx
  8004e6:	8b 75 e4             	mov    0xffffffe4(%ebp),%esi
  8004e9:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8004ec:	8d 44 42 d0          	lea    0xffffffd0(%edx,%eax,2),%eax
  8004f0:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8004f3:	0f be 13             	movsbl (%ebx),%edx
  8004f6:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  8004f9:	83 f8 09             	cmp    $0x9,%eax
  8004fc:	77 21                	ja     80051f <vprintfmt+0xee>
  8004fe:	eb e3                	jmp    8004e3 <vprintfmt+0xb2>
  800500:	8b 55 14             	mov    0x14(%ebp),%edx
  800503:	8d 42 04             	lea    0x4(%edx),%eax
  800506:	89 45 14             	mov    %eax,0x14(%ebp)
  800509:	8b 12                	mov    (%edx),%edx
  80050b:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  80050e:	eb 0f                	jmp    80051f <vprintfmt+0xee>
  800510:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800514:	79 90                	jns    8004a6 <vprintfmt+0x75>
  800516:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  80051d:	eb 87                	jmp    8004a6 <vprintfmt+0x75>
  80051f:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800523:	79 81                	jns    8004a6 <vprintfmt+0x75>
  800525:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  800528:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  80052b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  800532:	e9 6f ff ff ff       	jmp    8004a6 <vprintfmt+0x75>
  800537:	83 c1 01             	add    $0x1,%ecx
  80053a:	e9 67 ff ff ff       	jmp    8004a6 <vprintfmt+0x75>
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	8d 50 04             	lea    0x4(%eax),%edx
  800545:	89 55 14             	mov    %edx,0x14(%ebp)
  800548:	8b 55 0c             	mov    0xc(%ebp),%edx
  80054b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80054f:	8b 00                	mov    (%eax),%eax
  800551:	89 04 24             	mov    %eax,(%esp)
  800554:	ff d7                	call   *%edi
  800556:	e9 ea fe ff ff       	jmp    800445 <vprintfmt+0x14>
  80055b:	8b 55 14             	mov    0x14(%ebp),%edx
  80055e:	8d 42 04             	lea    0x4(%edx),%eax
  800561:	89 45 14             	mov    %eax,0x14(%ebp)
  800564:	8b 02                	mov    (%edx),%eax
  800566:	89 c2                	mov    %eax,%edx
  800568:	c1 fa 1f             	sar    $0x1f,%edx
  80056b:	31 d0                	xor    %edx,%eax
  80056d:	29 d0                	sub    %edx,%eax
  80056f:	83 f8 0f             	cmp    $0xf,%eax
  800572:	7f 0b                	jg     80057f <vprintfmt+0x14e>
  800574:	8b 14 85 80 2c 80 00 	mov    0x802c80(,%eax,4),%edx
  80057b:	85 d2                	test   %edx,%edx
  80057d:	75 20                	jne    80059f <vprintfmt+0x16e>
  80057f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800583:	c7 44 24 08 fb 29 80 	movl   $0x8029fb,0x8(%esp)
  80058a:	00 
  80058b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80058e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800592:	89 3c 24             	mov    %edi,(%esp)
  800595:	e8 f0 02 00 00       	call   80088a <printfmt>
  80059a:	e9 a6 fe ff ff       	jmp    800445 <vprintfmt+0x14>
  80059f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005a3:	c7 44 24 08 0a 2f 80 	movl   $0x802f0a,0x8(%esp)
  8005aa:	00 
  8005ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b2:	89 3c 24             	mov    %edi,(%esp)
  8005b5:	e8 d0 02 00 00       	call   80088a <printfmt>
  8005ba:	e9 86 fe ff ff       	jmp    800445 <vprintfmt+0x14>
  8005bf:	8b 75 ec             	mov    0xffffffec(%ebp),%esi
  8005c2:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  8005c5:	89 5d e8             	mov    %ebx,0xffffffe8(%ebp)
  8005c8:	8b 55 14             	mov    0x14(%ebp),%edx
  8005cb:	8d 42 04             	lea    0x4(%edx),%eax
  8005ce:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d1:	8b 12                	mov    (%edx),%edx
  8005d3:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  8005d6:	85 d2                	test   %edx,%edx
  8005d8:	75 07                	jne    8005e1 <vprintfmt+0x1b0>
  8005da:	c7 45 d8 04 2a 80 00 	movl   $0x802a04,0xffffffd8(%ebp)
  8005e1:	85 f6                	test   %esi,%esi
  8005e3:	7e 40                	jle    800625 <vprintfmt+0x1f4>
  8005e5:	80 7d e3 2d          	cmpb   $0x2d,0xffffffe3(%ebp)
  8005e9:	74 3a                	je     800625 <vprintfmt+0x1f4>
  8005eb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005ef:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  8005f2:	89 14 24             	mov    %edx,(%esp)
  8005f5:	e8 e6 02 00 00       	call   8008e0 <strnlen>
  8005fa:	29 c6                	sub    %eax,%esi
  8005fc:	89 75 ec             	mov    %esi,0xffffffec(%ebp)
  8005ff:	85 f6                	test   %esi,%esi
  800601:	7e 22                	jle    800625 <vprintfmt+0x1f4>
  800603:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  800607:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  80060a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80060d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800611:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  800614:	89 04 24             	mov    %eax,(%esp)
  800617:	ff d7                	call   *%edi
  800619:	83 ee 01             	sub    $0x1,%esi
  80061c:	75 ec                	jne    80060a <vprintfmt+0x1d9>
  80061e:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  800625:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800628:	0f b6 02             	movzbl (%edx),%eax
  80062b:	0f be d0             	movsbl %al,%edx
  80062e:	8b 75 d8             	mov    0xffffffd8(%ebp),%esi
  800631:	84 c0                	test   %al,%al
  800633:	75 40                	jne    800675 <vprintfmt+0x244>
  800635:	eb 4a                	jmp    800681 <vprintfmt+0x250>
  800637:	83 7d dc 00          	cmpl   $0x0,0xffffffdc(%ebp)
  80063b:	74 1a                	je     800657 <vprintfmt+0x226>
  80063d:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  800640:	83 f8 5e             	cmp    $0x5e,%eax
  800643:	76 12                	jbe    800657 <vprintfmt+0x226>
  800645:	8b 45 0c             	mov    0xc(%ebp),%eax
  800648:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800653:	ff d7                	call   *%edi
  800655:	eb 0c                	jmp    800663 <vprintfmt+0x232>
  800657:	8b 45 0c             	mov    0xc(%ebp),%eax
  80065a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065e:	89 14 24             	mov    %edx,(%esp)
  800661:	ff d7                	call   *%edi
  800663:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  800667:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80066b:	83 c6 01             	add    $0x1,%esi
  80066e:	84 c0                	test   %al,%al
  800670:	74 0f                	je     800681 <vprintfmt+0x250>
  800672:	0f be d0             	movsbl %al,%edx
  800675:	83 7d e4 00          	cmpl   $0x0,0xffffffe4(%ebp)
  800679:	78 bc                	js     800637 <vprintfmt+0x206>
  80067b:	83 6d e4 01          	subl   $0x1,0xffffffe4(%ebp)
  80067f:	79 b6                	jns    800637 <vprintfmt+0x206>
  800681:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800685:	0f 8e ba fd ff ff    	jle    800445 <vprintfmt+0x14>
  80068b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80068e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800692:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800699:	ff d7                	call   *%edi
  80069b:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  80069f:	0f 84 9d fd ff ff    	je     800442 <vprintfmt+0x11>
  8006a5:	eb e4                	jmp    80068b <vprintfmt+0x25a>
  8006a7:	83 f9 01             	cmp    $0x1,%ecx
  8006aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8006b0:	7e 10                	jle    8006c2 <vprintfmt+0x291>
  8006b2:	8b 55 14             	mov    0x14(%ebp),%edx
  8006b5:	8d 42 08             	lea    0x8(%edx),%eax
  8006b8:	89 45 14             	mov    %eax,0x14(%ebp)
  8006bb:	8b 02                	mov    (%edx),%eax
  8006bd:	8b 52 04             	mov    0x4(%edx),%edx
  8006c0:	eb 26                	jmp    8006e8 <vprintfmt+0x2b7>
  8006c2:	85 c9                	test   %ecx,%ecx
  8006c4:	74 12                	je     8006d8 <vprintfmt+0x2a7>
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8d 50 04             	lea    0x4(%eax),%edx
  8006cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cf:	8b 00                	mov    (%eax),%eax
  8006d1:	89 c2                	mov    %eax,%edx
  8006d3:	c1 fa 1f             	sar    $0x1f,%edx
  8006d6:	eb 10                	jmp    8006e8 <vprintfmt+0x2b7>
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	8d 50 04             	lea    0x4(%eax),%edx
  8006de:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e1:	8b 00                	mov    (%eax),%eax
  8006e3:	89 c2                	mov    %eax,%edx
  8006e5:	c1 fa 1f             	sar    $0x1f,%edx
  8006e8:	89 d1                	mov    %edx,%ecx
  8006ea:	89 c2                	mov    %eax,%edx
  8006ec:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  8006ef:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  8006f2:	be 0a 00 00 00       	mov    $0xa,%esi
  8006f7:	85 c9                	test   %ecx,%ecx
  8006f9:	0f 89 92 00 00 00    	jns    800791 <vprintfmt+0x360>
  8006ff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800702:	89 74 24 04          	mov    %esi,0x4(%esp)
  800706:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80070d:	ff d7                	call   *%edi
  80070f:	8b 55 d0             	mov    0xffffffd0(%ebp),%edx
  800712:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
  800715:	f7 da                	neg    %edx
  800717:	83 d1 00             	adc    $0x0,%ecx
  80071a:	f7 d9                	neg    %ecx
  80071c:	be 0a 00 00 00       	mov    $0xa,%esi
  800721:	eb 6e                	jmp    800791 <vprintfmt+0x360>
  800723:	8d 45 14             	lea    0x14(%ebp),%eax
  800726:	89 ca                	mov    %ecx,%edx
  800728:	e8 ab fc ff ff       	call   8003d8 <getuint>
  80072d:	89 d1                	mov    %edx,%ecx
  80072f:	89 c2                	mov    %eax,%edx
  800731:	be 0a 00 00 00       	mov    $0xa,%esi
  800736:	eb 59                	jmp    800791 <vprintfmt+0x360>
  800738:	8d 45 14             	lea    0x14(%ebp),%eax
  80073b:	89 ca                	mov    %ecx,%edx
  80073d:	e8 96 fc ff ff       	call   8003d8 <getuint>
  800742:	e9 fe fc ff ff       	jmp    800445 <vprintfmt+0x14>
  800747:	8b 45 0c             	mov    0xc(%ebp),%eax
  80074a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800755:	ff d7                	call   *%edi
  800757:	8b 55 0c             	mov    0xc(%ebp),%edx
  80075a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80075e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800765:	ff d7                	call   *%edi
  800767:	8b 55 14             	mov    0x14(%ebp),%edx
  80076a:	8d 42 04             	lea    0x4(%edx),%eax
  80076d:	89 45 14             	mov    %eax,0x14(%ebp)
  800770:	8b 12                	mov    (%edx),%edx
  800772:	b9 00 00 00 00       	mov    $0x0,%ecx
  800777:	be 10 00 00 00       	mov    $0x10,%esi
  80077c:	eb 13                	jmp    800791 <vprintfmt+0x360>
  80077e:	8d 45 14             	lea    0x14(%ebp),%eax
  800781:	89 ca                	mov    %ecx,%edx
  800783:	e8 50 fc ff ff       	call   8003d8 <getuint>
  800788:	89 d1                	mov    %edx,%ecx
  80078a:	89 c2                	mov    %eax,%edx
  80078c:	be 10 00 00 00       	mov    $0x10,%esi
  800791:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  800795:	89 44 24 10          	mov    %eax,0x10(%esp)
  800799:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  80079c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007a0:	89 74 24 08          	mov    %esi,0x8(%esp)
  8007a4:	89 14 24             	mov    %edx,(%esp)
  8007a7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ae:	89 f8                	mov    %edi,%eax
  8007b0:	e8 3b fb ff ff       	call   8002f0 <printnum>
  8007b5:	e9 8b fc ff ff       	jmp    800445 <vprintfmt+0x14>
  8007ba:	8b 75 0c             	mov    0xc(%ebp),%esi
  8007bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007c1:	89 14 24             	mov    %edx,(%esp)
  8007c4:	ff d7                	call   *%edi
  8007c6:	e9 7a fc ff ff       	jmp    800445 <vprintfmt+0x14>
  8007cb:	89 de                	mov    %ebx,%esi
  8007cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007db:	ff d7                	call   *%edi
  8007dd:	83 eb 01             	sub    $0x1,%ebx
  8007e0:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  8007e4:	0f 84 5b fc ff ff    	je     800445 <vprintfmt+0x14>
  8007ea:	8d 56 fd             	lea    0xfffffffd(%esi),%edx
  8007ed:	0f b6 02             	movzbl (%edx),%eax
  8007f0:	83 ea 01             	sub    $0x1,%edx
  8007f3:	3c 25                	cmp    $0x25,%al
  8007f5:	75 f6                	jne    8007ed <vprintfmt+0x3bc>
  8007f7:	8d 5a 02             	lea    0x2(%edx),%ebx
  8007fa:	e9 46 fc ff ff       	jmp    800445 <vprintfmt+0x14>
  8007ff:	83 c4 4c             	add    $0x4c,%esp
  800802:	5b                   	pop    %ebx
  800803:	5e                   	pop    %esi
  800804:	5f                   	pop    %edi
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	83 ec 28             	sub    $0x28,%esp
  80080d:	8b 55 08             	mov    0x8(%ebp),%edx
  800810:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800813:	85 d2                	test   %edx,%edx
  800815:	74 04                	je     80081b <vsnprintf+0x14>
  800817:	85 c0                	test   %eax,%eax
  800819:	7f 07                	jg     800822 <vsnprintf+0x1b>
  80081b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800820:	eb 3b                	jmp    80085d <vsnprintf+0x56>
  800822:	c7 45 fc 00 00 00 00 	movl   $0x0,0xfffffffc(%ebp)
  800829:	8d 44 02 ff          	lea    0xffffffff(%edx,%eax,1),%eax
  80082d:	89 45 f8             	mov    %eax,0xfffffff8(%ebp)
  800830:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800833:	8b 45 14             	mov    0x14(%ebp),%eax
  800836:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80083a:	8b 45 10             	mov    0x10(%ebp),%eax
  80083d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800841:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  800844:	89 44 24 04          	mov    %eax,0x4(%esp)
  800848:	c7 04 24 14 04 80 00 	movl   $0x800414,(%esp)
  80084f:	e8 dd fb ff ff       	call   800431 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800854:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  800857:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80085a:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
}
  80085d:	c9                   	leave  
  80085e:	c3                   	ret    

0080085f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800865:	8d 45 14             	lea    0x14(%ebp),%eax
  800868:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  80086b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80086f:	8b 45 10             	mov    0x10(%ebp),%eax
  800872:	89 44 24 08          	mov    %eax,0x8(%esp)
  800876:	8b 45 0c             	mov    0xc(%ebp),%eax
  800879:	89 44 24 04          	mov    %eax,0x4(%esp)
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	89 04 24             	mov    %eax,(%esp)
  800883:	e8 7f ff ff ff       	call   800807 <vsnprintf>
	va_end(ap);

	return rc;
}
  800888:	c9                   	leave  
  800889:	c3                   	ret    

0080088a <printfmt>:
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	83 ec 28             	sub    $0x28,%esp
  800890:	8d 45 14             	lea    0x14(%ebp),%eax
  800893:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
  800896:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80089a:	8b 45 10             	mov    0x10(%ebp),%eax
  80089d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ab:	89 04 24             	mov    %eax,(%esp)
  8008ae:	e8 7e fb ff ff       	call   800431 <vprintfmt>
  8008b3:	c9                   	leave  
  8008b4:	c3                   	ret    
	...

008008c0 <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cb:	80 3a 00             	cmpb   $0x0,(%edx)
  8008ce:	74 0e                	je     8008de <strlen+0x1e>
  8008d0:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008d5:	83 c0 01             	add    $0x1,%eax
  8008d8:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  8008dc:	75 f7                	jne    8008d5 <strlen+0x15>
	return n;
}
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e9:	85 d2                	test   %edx,%edx
  8008eb:	74 19                	je     800906 <strnlen+0x26>
  8008ed:	80 39 00             	cmpb   $0x0,(%ecx)
  8008f0:	74 14                	je     800906 <strnlen+0x26>
  8008f2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008f7:	83 c0 01             	add    $0x1,%eax
  8008fa:	39 d0                	cmp    %edx,%eax
  8008fc:	74 0d                	je     80090b <strnlen+0x2b>
  8008fe:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800902:	74 07                	je     80090b <strnlen+0x2b>
  800904:	eb f1                	jmp    8008f7 <strnlen+0x17>
  800906:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  80090b:	5d                   	pop    %ebp
  80090c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800910:	c3                   	ret    

00800911 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	53                   	push   %ebx
  800915:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800918:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091b:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80091d:	0f b6 01             	movzbl (%ecx),%eax
  800920:	88 02                	mov    %al,(%edx)
  800922:	83 c2 01             	add    $0x1,%edx
  800925:	83 c1 01             	add    $0x1,%ecx
  800928:	84 c0                	test   %al,%al
  80092a:	75 f1                	jne    80091d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80092c:	89 d8                	mov    %ebx,%eax
  80092e:	5b                   	pop    %ebx
  80092f:	5d                   	pop    %ebp
  800930:	c3                   	ret    

00800931 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	57                   	push   %edi
  800935:	56                   	push   %esi
  800936:	53                   	push   %ebx
  800937:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800940:	85 f6                	test   %esi,%esi
  800942:	74 1c                	je     800960 <strncpy+0x2f>
  800944:	89 fa                	mov    %edi,%edx
  800946:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  80094b:	0f b6 01             	movzbl (%ecx),%eax
  80094e:	88 02                	mov    %al,(%edx)
  800950:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800953:	80 39 01             	cmpb   $0x1,(%ecx)
  800956:	83 d9 ff             	sbb    $0xffffffff,%ecx
  800959:	83 c3 01             	add    $0x1,%ebx
  80095c:	39 f3                	cmp    %esi,%ebx
  80095e:	75 eb                	jne    80094b <strncpy+0x1a>
	}
	return ret;
}
  800960:	89 f8                	mov    %edi,%eax
  800962:	5b                   	pop    %ebx
  800963:	5e                   	pop    %esi
  800964:	5f                   	pop    %edi
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	56                   	push   %esi
  80096b:	53                   	push   %ebx
  80096c:	8b 75 08             	mov    0x8(%ebp),%esi
  80096f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800972:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800975:	89 f0                	mov    %esi,%eax
  800977:	85 d2                	test   %edx,%edx
  800979:	74 2c                	je     8009a7 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  80097b:	89 d3                	mov    %edx,%ebx
  80097d:	83 eb 01             	sub    $0x1,%ebx
  800980:	74 20                	je     8009a2 <strlcpy+0x3b>
  800982:	0f b6 11             	movzbl (%ecx),%edx
  800985:	84 d2                	test   %dl,%dl
  800987:	74 19                	je     8009a2 <strlcpy+0x3b>
  800989:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  80098b:	88 10                	mov    %dl,(%eax)
  80098d:	83 c0 01             	add    $0x1,%eax
  800990:	83 eb 01             	sub    $0x1,%ebx
  800993:	74 0f                	je     8009a4 <strlcpy+0x3d>
  800995:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  800999:	83 c1 01             	add    $0x1,%ecx
  80099c:	84 d2                	test   %dl,%dl
  80099e:	74 04                	je     8009a4 <strlcpy+0x3d>
  8009a0:	eb e9                	jmp    80098b <strlcpy+0x24>
  8009a2:	89 f0                	mov    %esi,%eax
		*dst = '\0';
  8009a4:	c6 00 00             	movb   $0x0,(%eax)
  8009a7:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8009a9:	5b                   	pop    %ebx
  8009aa:	5e                   	pop    %esi
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    

008009ad <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	57                   	push   %edi
  8009b1:	56                   	push   %esi
  8009b2:	53                   	push   %ebx
  8009b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8009b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b9:	8b 7d 10             	mov    0x10(%ebp),%edi
    int c;
    char *q = buf;

    if (buf_size <= 0)
  8009bc:	85 c9                	test   %ecx,%ecx
  8009be:	7e 30                	jle    8009f0 <pstrcpy+0x43>
        return;

    for(;;) {
        c = *str++;
  8009c0:	0f b6 07             	movzbl (%edi),%eax
        if (c == 0 || q >= buf + buf_size - 1)
  8009c3:	84 c0                	test   %al,%al
  8009c5:	74 26                	je     8009ed <pstrcpy+0x40>
  8009c7:	8d 74 0a ff          	lea    0xffffffff(%edx,%ecx,1),%esi
  8009cb:	0f be d8             	movsbl %al,%ebx
  8009ce:	89 f9                	mov    %edi,%ecx
  8009d0:	39 f2                	cmp    %esi,%edx
  8009d2:	72 09                	jb     8009dd <pstrcpy+0x30>
  8009d4:	eb 17                	jmp    8009ed <pstrcpy+0x40>
  8009d6:	83 c1 01             	add    $0x1,%ecx
  8009d9:	39 f2                	cmp    %esi,%edx
  8009db:	73 10                	jae    8009ed <pstrcpy+0x40>
            break;
        *q++ = c;
  8009dd:	88 1a                	mov    %bl,(%edx)
  8009df:	83 c2 01             	add    $0x1,%edx
  8009e2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  8009e6:	0f be d8             	movsbl %al,%ebx
  8009e9:	84 c0                	test   %al,%al
  8009eb:	75 e9                	jne    8009d6 <pstrcpy+0x29>
    }
    *q = '\0';
  8009ed:	c6 02 00             	movb   $0x0,(%edx)
}
  8009f0:	5b                   	pop    %ebx
  8009f1:	5e                   	pop    %esi
  8009f2:	5f                   	pop    %edi
  8009f3:	5d                   	pop    %ebp
  8009f4:	c3                   	ret    

008009f5 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8009fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  8009fe:	0f b6 02             	movzbl (%edx),%eax
  800a01:	84 c0                	test   %al,%al
  800a03:	74 16                	je     800a1b <strcmp+0x26>
  800a05:	3a 01                	cmp    (%ecx),%al
  800a07:	75 12                	jne    800a1b <strcmp+0x26>
		p++, q++;
  800a09:	83 c1 01             	add    $0x1,%ecx
  800a0c:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  800a10:	84 c0                	test   %al,%al
  800a12:	74 07                	je     800a1b <strcmp+0x26>
  800a14:	83 c2 01             	add    $0x1,%edx
  800a17:	3a 01                	cmp    (%ecx),%al
  800a19:	74 ee                	je     800a09 <strcmp+0x14>
  800a1b:	0f b6 c0             	movzbl %al,%eax
  800a1e:	0f b6 11             	movzbl (%ecx),%edx
  800a21:	29 d0                	sub    %edx,%eax
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a23:	5d                   	pop    %ebp
  800a24:	c3                   	ret    

00800a25 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	53                   	push   %ebx
  800a29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a2f:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800a32:	85 d2                	test   %edx,%edx
  800a34:	74 2d                	je     800a63 <strncmp+0x3e>
  800a36:	0f b6 01             	movzbl (%ecx),%eax
  800a39:	84 c0                	test   %al,%al
  800a3b:	74 1a                	je     800a57 <strncmp+0x32>
  800a3d:	3a 03                	cmp    (%ebx),%al
  800a3f:	75 16                	jne    800a57 <strncmp+0x32>
  800a41:	83 ea 01             	sub    $0x1,%edx
  800a44:	74 1d                	je     800a63 <strncmp+0x3e>
		n--, p++, q++;
  800a46:	83 c1 01             	add    $0x1,%ecx
  800a49:	83 c3 01             	add    $0x1,%ebx
  800a4c:	0f b6 01             	movzbl (%ecx),%eax
  800a4f:	84 c0                	test   %al,%al
  800a51:	74 04                	je     800a57 <strncmp+0x32>
  800a53:	3a 03                	cmp    (%ebx),%al
  800a55:	74 ea                	je     800a41 <strncmp+0x1c>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a57:	0f b6 11             	movzbl (%ecx),%edx
  800a5a:	0f b6 03             	movzbl (%ebx),%eax
  800a5d:	29 c2                	sub    %eax,%edx
  800a5f:	89 d0                	mov    %edx,%eax
  800a61:	eb 05                	jmp    800a68 <strncmp+0x43>
  800a63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a68:	5b                   	pop    %ebx
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a75:	0f b6 10             	movzbl (%eax),%edx
  800a78:	84 d2                	test   %dl,%dl
  800a7a:	74 16                	je     800a92 <strchr+0x27>
		if (*s == c)
  800a7c:	38 ca                	cmp    %cl,%dl
  800a7e:	75 06                	jne    800a86 <strchr+0x1b>
  800a80:	eb 15                	jmp    800a97 <strchr+0x2c>
  800a82:	38 ca                	cmp    %cl,%dl
  800a84:	74 11                	je     800a97 <strchr+0x2c>
  800a86:	83 c0 01             	add    $0x1,%eax
  800a89:	0f b6 10             	movzbl (%eax),%edx
  800a8c:	84 d2                	test   %dl,%dl
  800a8e:	66 90                	xchg   %ax,%ax
  800a90:	75 f0                	jne    800a82 <strchr+0x17>
  800a92:	b8 00 00 00 00       	mov    $0x0,%eax
			return (char *) s;
	return 0;
}
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    

00800a99 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa3:	0f b6 10             	movzbl (%eax),%edx
  800aa6:	84 d2                	test   %dl,%dl
  800aa8:	74 14                	je     800abe <strfind+0x25>
		if (*s == c)
  800aaa:	38 ca                	cmp    %cl,%dl
  800aac:	75 06                	jne    800ab4 <strfind+0x1b>
  800aae:	eb 0e                	jmp    800abe <strfind+0x25>
  800ab0:	38 ca                	cmp    %cl,%dl
  800ab2:	74 0a                	je     800abe <strfind+0x25>
  800ab4:	83 c0 01             	add    $0x1,%eax
  800ab7:	0f b6 10             	movzbl (%eax),%edx
  800aba:	84 d2                	test   %dl,%dl
  800abc:	75 f2                	jne    800ab0 <strfind+0x17>
			break;
	return (char *) s;
}
  800abe:	5d                   	pop    %ebp
  800abf:	90                   	nop    
  800ac0:	c3                   	ret    

00800ac1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	83 ec 08             	sub    $0x8,%esp
  800ac7:	89 1c 24             	mov    %ebx,(%esp)
  800aca:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ace:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ad1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800ad7:	85 db                	test   %ebx,%ebx
  800ad9:	74 32                	je     800b0d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800adb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ae1:	75 25                	jne    800b08 <memset+0x47>
  800ae3:	f6 c3 03             	test   $0x3,%bl
  800ae6:	75 20                	jne    800b08 <memset+0x47>
		c &= 0xFF;
  800ae8:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800aeb:	89 d0                	mov    %edx,%eax
  800aed:	c1 e0 18             	shl    $0x18,%eax
  800af0:	89 d1                	mov    %edx,%ecx
  800af2:	c1 e1 10             	shl    $0x10,%ecx
  800af5:	09 c8                	or     %ecx,%eax
  800af7:	09 d0                	or     %edx,%eax
  800af9:	c1 e2 08             	shl    $0x8,%edx
  800afc:	09 d0                	or     %edx,%eax
  800afe:	89 d9                	mov    %ebx,%ecx
  800b00:	c1 e9 02             	shr    $0x2,%ecx
  800b03:	fc                   	cld    
  800b04:	f3 ab                	rep stos %eax,%es:(%edi)
  800b06:	eb 05                	jmp    800b0d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b08:	89 d9                	mov    %ebx,%ecx
  800b0a:	fc                   	cld    
  800b0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b0d:	89 f8                	mov    %edi,%eax
  800b0f:	8b 1c 24             	mov    (%esp),%ebx
  800b12:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b16:	89 ec                	mov    %ebp,%esp
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	83 ec 08             	sub    $0x8,%esp
  800b20:	89 34 24             	mov    %esi,(%esp)
  800b23:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b27:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800b2d:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b30:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b32:	39 c6                	cmp    %eax,%esi
  800b34:	73 36                	jae    800b6c <memmove+0x52>
  800b36:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b39:	39 d0                	cmp    %edx,%eax
  800b3b:	73 2f                	jae    800b6c <memmove+0x52>
		s += n;
		d += n;
  800b3d:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b40:	f6 c2 03             	test   $0x3,%dl
  800b43:	75 1b                	jne    800b60 <memmove+0x46>
  800b45:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b4b:	75 13                	jne    800b60 <memmove+0x46>
  800b4d:	f6 c1 03             	test   $0x3,%cl
  800b50:	75 0e                	jne    800b60 <memmove+0x46>
			asm volatile("std; rep movsl\n"
  800b52:	8d 7e fc             	lea    0xfffffffc(%esi),%edi
  800b55:	8d 72 fc             	lea    0xfffffffc(%edx),%esi
  800b58:	c1 e9 02             	shr    $0x2,%ecx
  800b5b:	fd                   	std    
  800b5c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b5e:	eb 09                	jmp    800b69 <memmove+0x4f>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b60:	8d 7e ff             	lea    0xffffffff(%esi),%edi
  800b63:	8d 72 ff             	lea    0xffffffff(%edx),%esi
  800b66:	fd                   	std    
  800b67:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b69:	fc                   	cld    
  800b6a:	eb 21                	jmp    800b8d <memmove+0x73>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b6c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b72:	75 16                	jne    800b8a <memmove+0x70>
  800b74:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b7a:	75 0e                	jne    800b8a <memmove+0x70>
  800b7c:	f6 c1 03             	test   $0x3,%cl
  800b7f:	90                   	nop    
  800b80:	75 08                	jne    800b8a <memmove+0x70>
			asm volatile("cld; rep movsl\n"
  800b82:	c1 e9 02             	shr    $0x2,%ecx
  800b85:	fc                   	cld    
  800b86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b88:	eb 03                	jmp    800b8d <memmove+0x73>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b8a:	fc                   	cld    
  800b8b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b8d:	8b 34 24             	mov    (%esp),%esi
  800b90:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b94:	89 ec                	mov    %ebp,%esp
  800b96:	5d                   	pop    %ebp
  800b97:	c3                   	ret    

00800b98 <memcpy>:

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
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b9e:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ba5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bac:	8b 45 08             	mov    0x8(%ebp),%eax
  800baf:	89 04 24             	mov    %eax,(%esp)
  800bb2:	e8 63 ff ff ff       	call   800b1a <memmove>
}
  800bb7:	c9                   	leave  
  800bb8:	c3                   	ret    

00800bb9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	56                   	push   %esi
  800bbd:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bbe:	8b 75 10             	mov    0x10(%ebp),%esi
  800bc1:	83 ee 01             	sub    $0x1,%esi
  800bc4:	83 fe ff             	cmp    $0xffffffff,%esi
  800bc7:	74 38                	je     800c01 <memcmp+0x48>
  800bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcc:	8b 55 0c             	mov    0xc(%ebp),%edx
		if (*s1 != *s2)
  800bcf:	0f b6 18             	movzbl (%eax),%ebx
  800bd2:	0f b6 0a             	movzbl (%edx),%ecx
  800bd5:	38 cb                	cmp    %cl,%bl
  800bd7:	74 20                	je     800bf9 <memcmp+0x40>
  800bd9:	eb 12                	jmp    800bed <memcmp+0x34>
  800bdb:	0f b6 58 01          	movzbl 0x1(%eax),%ebx
  800bdf:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
  800be3:	83 c0 01             	add    $0x1,%eax
  800be6:	83 c2 01             	add    $0x1,%edx
  800be9:	38 cb                	cmp    %cl,%bl
  800beb:	74 0c                	je     800bf9 <memcmp+0x40>
			return (int) *s1 - (int) *s2;
  800bed:	0f b6 d3             	movzbl %bl,%edx
  800bf0:	0f b6 c1             	movzbl %cl,%eax
  800bf3:	29 c2                	sub    %eax,%edx
  800bf5:	89 d0                	mov    %edx,%eax
  800bf7:	eb 0d                	jmp    800c06 <memcmp+0x4d>
  800bf9:	83 ee 01             	sub    $0x1,%esi
  800bfc:	83 fe ff             	cmp    $0xffffffff,%esi
  800bff:	75 da                	jne    800bdb <memcmp+0x22>
  800c01:	b8 00 00 00 00       	mov    $0x0,%eax
		s1++, s2++;
	}

	return 0;
}
  800c06:	5b                   	pop    %ebx
  800c07:	5e                   	pop    %esi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	53                   	push   %ebx
  800c0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800c11:	89 da                	mov    %ebx,%edx
  800c13:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c16:	39 d3                	cmp    %edx,%ebx
  800c18:	73 1a                	jae    800c34 <memfind+0x2a>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c1a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
			break;
  800c1e:	89 d8                	mov    %ebx,%eax
  800c20:	38 0b                	cmp    %cl,(%ebx)
  800c22:	75 06                	jne    800c2a <memfind+0x20>
  800c24:	eb 0e                	jmp    800c34 <memfind+0x2a>
  800c26:	38 08                	cmp    %cl,(%eax)
  800c28:	74 0c                	je     800c36 <memfind+0x2c>
  800c2a:	83 c0 01             	add    $0x1,%eax
  800c2d:	39 d0                	cmp    %edx,%eax
  800c2f:	90                   	nop    
  800c30:	75 f4                	jne    800c26 <memfind+0x1c>
  800c32:	eb 02                	jmp    800c36 <memfind+0x2c>
  800c34:	89 d8                	mov    %ebx,%eax
	return (void *) s;
}
  800c36:	5b                   	pop    %ebx
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	53                   	push   %ebx
  800c3f:	83 ec 04             	sub    $0x4,%esp
  800c42:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c45:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c48:	0f b6 03             	movzbl (%ebx),%eax
  800c4b:	3c 20                	cmp    $0x20,%al
  800c4d:	74 04                	je     800c53 <strtol+0x1a>
  800c4f:	3c 09                	cmp    $0x9,%al
  800c51:	75 0e                	jne    800c61 <strtol+0x28>
		s++;
  800c53:	83 c3 01             	add    $0x1,%ebx
  800c56:	0f b6 03             	movzbl (%ebx),%eax
  800c59:	3c 20                	cmp    $0x20,%al
  800c5b:	74 f6                	je     800c53 <strtol+0x1a>
  800c5d:	3c 09                	cmp    $0x9,%al
  800c5f:	74 f2                	je     800c53 <strtol+0x1a>

	// plus/minus sign
	if (*s == '+')
  800c61:	3c 2b                	cmp    $0x2b,%al
  800c63:	75 0d                	jne    800c72 <strtol+0x39>
		s++;
  800c65:	83 c3 01             	add    $0x1,%ebx
  800c68:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800c6f:	90                   	nop    
  800c70:	eb 15                	jmp    800c87 <strtol+0x4e>
	else if (*s == '-')
  800c72:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800c79:	3c 2d                	cmp    $0x2d,%al
  800c7b:	75 0a                	jne    800c87 <strtol+0x4e>
		s++, neg = 1;
  800c7d:	83 c3 01             	add    $0x1,%ebx
  800c80:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c87:	85 f6                	test   %esi,%esi
  800c89:	0f 94 c0             	sete   %al
  800c8c:	84 c0                	test   %al,%al
  800c8e:	75 05                	jne    800c95 <strtol+0x5c>
  800c90:	83 fe 10             	cmp    $0x10,%esi
  800c93:	75 17                	jne    800cac <strtol+0x73>
  800c95:	80 3b 30             	cmpb   $0x30,(%ebx)
  800c98:	75 12                	jne    800cac <strtol+0x73>
  800c9a:	80 7b 01 78          	cmpb   $0x78,0x1(%ebx)
  800c9e:	66 90                	xchg   %ax,%ax
  800ca0:	75 0a                	jne    800cac <strtol+0x73>
		s += 2, base = 16;
  800ca2:	83 c3 02             	add    $0x2,%ebx
  800ca5:	be 10 00 00 00       	mov    $0x10,%esi
  800caa:	eb 1f                	jmp    800ccb <strtol+0x92>
	else if (base == 0 && s[0] == '0')
  800cac:	85 f6                	test   %esi,%esi
  800cae:	66 90                	xchg   %ax,%ax
  800cb0:	75 10                	jne    800cc2 <strtol+0x89>
  800cb2:	80 3b 30             	cmpb   $0x30,(%ebx)
  800cb5:	75 0b                	jne    800cc2 <strtol+0x89>
		s++, base = 8;
  800cb7:	83 c3 01             	add    $0x1,%ebx
  800cba:	66 be 08 00          	mov    $0x8,%si
  800cbe:	66 90                	xchg   %ax,%ax
  800cc0:	eb 09                	jmp    800ccb <strtol+0x92>
	else if (base == 0)
  800cc2:	84 c0                	test   %al,%al
  800cc4:	74 05                	je     800ccb <strtol+0x92>
  800cc6:	be 0a 00 00 00       	mov    $0xa,%esi
  800ccb:	bf 00 00 00 00       	mov    $0x0,%edi
		base = 10;

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cd0:	0f b6 13             	movzbl (%ebx),%edx
  800cd3:	89 d1                	mov    %edx,%ecx
  800cd5:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800cd8:	3c 09                	cmp    $0x9,%al
  800cda:	77 08                	ja     800ce4 <strtol+0xab>
			dig = *s - '0';
  800cdc:	0f be c2             	movsbl %dl,%eax
  800cdf:	8d 50 d0             	lea    0xffffffd0(%eax),%edx
  800ce2:	eb 1c                	jmp    800d00 <strtol+0xc7>
		else if (*s >= 'a' && *s <= 'z')
  800ce4:	8d 41 9f             	lea    0xffffff9f(%ecx),%eax
  800ce7:	3c 19                	cmp    $0x19,%al
  800ce9:	77 08                	ja     800cf3 <strtol+0xba>
			dig = *s - 'a' + 10;
  800ceb:	0f be c2             	movsbl %dl,%eax
  800cee:	8d 50 a9             	lea    0xffffffa9(%eax),%edx
  800cf1:	eb 0d                	jmp    800d00 <strtol+0xc7>
		else if (*s >= 'A' && *s <= 'Z')
  800cf3:	8d 41 bf             	lea    0xffffffbf(%ecx),%eax
  800cf6:	3c 19                	cmp    $0x19,%al
  800cf8:	77 17                	ja     800d11 <strtol+0xd8>
			dig = *s - 'A' + 10;
  800cfa:	0f be c2             	movsbl %dl,%eax
  800cfd:	8d 50 c9             	lea    0xffffffc9(%eax),%edx
		else
			break;
		if (dig >= base)
  800d00:	39 f2                	cmp    %esi,%edx
  800d02:	7d 0d                	jge    800d11 <strtol+0xd8>
			break;
		s++, val = (val * base) + dig;
  800d04:	83 c3 01             	add    $0x1,%ebx
  800d07:	89 f8                	mov    %edi,%eax
  800d09:	0f af c6             	imul   %esi,%eax
  800d0c:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800d0f:	eb bf                	jmp    800cd0 <strtol+0x97>
		// we don't properly detect overflow!
	}
  800d11:	89 f8                	mov    %edi,%eax

	if (endptr)
  800d13:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d17:	74 05                	je     800d1e <strtol+0xe5>
		*endptr = (char *) s;
  800d19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d1c:	89 1a                	mov    %ebx,(%edx)
	return (neg ? -val : val);
  800d1e:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800d22:	74 04                	je     800d28 <strtol+0xef>
  800d24:	89 c7                	mov    %eax,%edi
  800d26:	f7 df                	neg    %edi
}
  800d28:	89 f8                	mov    %edi,%eax
  800d2a:	83 c4 04             	add    $0x4,%esp
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    
	...

00800d34 <sys_cgetc>:
}

int
sys_cgetc(void)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	83 ec 0c             	sub    $0xc,%esp
  800d3a:	89 1c 24             	mov    %ebx,(%esp)
  800d3d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d41:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d45:	b8 01 00 00 00       	mov    $0x1,%eax
  800d4a:	bf 00 00 00 00       	mov    $0x0,%edi
  800d4f:	89 fa                	mov    %edi,%edx
  800d51:	89 f9                	mov    %edi,%ecx
  800d53:	89 fb                	mov    %edi,%ebx
  800d55:	89 fe                	mov    %edi,%esi
  800d57:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d59:	8b 1c 24             	mov    (%esp),%ebx
  800d5c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d60:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d64:	89 ec                	mov    %ebp,%esp
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <sys_cputs>:
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	83 ec 0c             	sub    $0xc,%esp
  800d6e:	89 1c 24             	mov    %ebx,(%esp)
  800d71:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d75:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7f:	bf 00 00 00 00       	mov    $0x0,%edi
  800d84:	89 f8                	mov    %edi,%eax
  800d86:	89 fb                	mov    %edi,%ebx
  800d88:	89 fe                	mov    %edi,%esi
  800d8a:	cd 30                	int    $0x30
  800d8c:	8b 1c 24             	mov    (%esp),%ebx
  800d8f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d93:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d97:	89 ec                	mov    %ebp,%esp
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <sys_time_msec>:

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
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	83 ec 0c             	sub    $0xc,%esp
  800da1:	89 1c 24             	mov    %ebx,(%esp)
  800da4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800da8:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800dac:	b8 0e 00 00 00       	mov    $0xe,%eax
  800db1:	bf 00 00 00 00       	mov    $0x0,%edi
  800db6:	89 fa                	mov    %edi,%edx
  800db8:	89 f9                	mov    %edi,%ecx
  800dba:	89 fb                	mov    %edi,%ebx
  800dbc:	89 fe                	mov    %edi,%esi
  800dbe:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dc0:	8b 1c 24             	mov    (%esp),%ebx
  800dc3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800dc7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800dcb:	89 ec                	mov    %ebp,%esp
  800dcd:	5d                   	pop    %ebp
  800dce:	c3                   	ret    

00800dcf <sys_ipc_recv>:
  800dcf:	55                   	push   %ebp
  800dd0:	89 e5                	mov    %esp,%ebp
  800dd2:	83 ec 28             	sub    $0x28,%esp
  800dd5:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800dd8:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800ddb:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800dde:	8b 55 08             	mov    0x8(%ebp),%edx
  800de1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800de6:	bf 00 00 00 00       	mov    $0x0,%edi
  800deb:	89 f9                	mov    %edi,%ecx
  800ded:	89 fb                	mov    %edi,%ebx
  800def:	89 fe                	mov    %edi,%esi
  800df1:	cd 30                	int    $0x30
  800df3:	85 c0                	test   %eax,%eax
  800df5:	7e 28                	jle    800e1f <sys_ipc_recv+0x50>
  800df7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dfb:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e02:	00 
  800e03:	c7 44 24 08 df 2c 80 	movl   $0x802cdf,0x8(%esp)
  800e0a:	00 
  800e0b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e12:	00 
  800e13:	c7 04 24 fc 2c 80 00 	movl   $0x802cfc,(%esp)
  800e1a:	e8 a1 f3 ff ff       	call   8001c0 <_panic>
  800e1f:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800e22:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800e25:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800e28:	89 ec                	mov    %ebp,%esp
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <sys_ipc_try_send>:
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	83 ec 0c             	sub    $0xc,%esp
  800e32:	89 1c 24             	mov    %ebx,(%esp)
  800e35:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e39:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e43:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e46:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e49:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e4e:	be 00 00 00 00       	mov    $0x0,%esi
  800e53:	cd 30                	int    $0x30
  800e55:	8b 1c 24             	mov    (%esp),%ebx
  800e58:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e5c:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e60:	89 ec                	mov    %ebp,%esp
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    

00800e64 <sys_env_set_pgfault_upcall>:
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	83 ec 28             	sub    $0x28,%esp
  800e6a:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800e6d:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800e70:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800e73:	8b 55 08             	mov    0x8(%ebp),%edx
  800e76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e79:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e7e:	bf 00 00 00 00       	mov    $0x0,%edi
  800e83:	89 fb                	mov    %edi,%ebx
  800e85:	89 fe                	mov    %edi,%esi
  800e87:	cd 30                	int    $0x30
  800e89:	85 c0                	test   %eax,%eax
  800e8b:	7e 28                	jle    800eb5 <sys_env_set_pgfault_upcall+0x51>
  800e8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e91:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e98:	00 
  800e99:	c7 44 24 08 df 2c 80 	movl   $0x802cdf,0x8(%esp)
  800ea0:	00 
  800ea1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea8:	00 
  800ea9:	c7 04 24 fc 2c 80 00 	movl   $0x802cfc,(%esp)
  800eb0:	e8 0b f3 ff ff       	call   8001c0 <_panic>
  800eb5:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800eb8:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800ebb:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800ebe:	89 ec                	mov    %ebp,%esp
  800ec0:	5d                   	pop    %ebp
  800ec1:	c3                   	ret    

00800ec2 <sys_env_set_trapframe>:
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
  800ec5:	83 ec 28             	sub    $0x28,%esp
  800ec8:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800ecb:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800ece:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800ed1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed7:	b8 09 00 00 00       	mov    $0x9,%eax
  800edc:	bf 00 00 00 00       	mov    $0x0,%edi
  800ee1:	89 fb                	mov    %edi,%ebx
  800ee3:	89 fe                	mov    %edi,%esi
  800ee5:	cd 30                	int    $0x30
  800ee7:	85 c0                	test   %eax,%eax
  800ee9:	7e 28                	jle    800f13 <sys_env_set_trapframe+0x51>
  800eeb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eef:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ef6:	00 
  800ef7:	c7 44 24 08 df 2c 80 	movl   $0x802cdf,0x8(%esp)
  800efe:	00 
  800eff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f06:	00 
  800f07:	c7 04 24 fc 2c 80 00 	movl   $0x802cfc,(%esp)
  800f0e:	e8 ad f2 ff ff       	call   8001c0 <_panic>
  800f13:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800f16:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800f19:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800f1c:	89 ec                	mov    %ebp,%esp
  800f1e:	5d                   	pop    %ebp
  800f1f:	c3                   	ret    

00800f20 <sys_env_set_status>:
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	83 ec 28             	sub    $0x28,%esp
  800f26:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800f29:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800f2c:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800f2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f35:	b8 08 00 00 00       	mov    $0x8,%eax
  800f3a:	bf 00 00 00 00       	mov    $0x0,%edi
  800f3f:	89 fb                	mov    %edi,%ebx
  800f41:	89 fe                	mov    %edi,%esi
  800f43:	cd 30                	int    $0x30
  800f45:	85 c0                	test   %eax,%eax
  800f47:	7e 28                	jle    800f71 <sys_env_set_status+0x51>
  800f49:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f4d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f54:	00 
  800f55:	c7 44 24 08 df 2c 80 	movl   $0x802cdf,0x8(%esp)
  800f5c:	00 
  800f5d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f64:	00 
  800f65:	c7 04 24 fc 2c 80 00 	movl   $0x802cfc,(%esp)
  800f6c:	e8 4f f2 ff ff       	call   8001c0 <_panic>
  800f71:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800f74:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800f77:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800f7a:	89 ec                	mov    %ebp,%esp
  800f7c:	5d                   	pop    %ebp
  800f7d:	c3                   	ret    

00800f7e <sys_page_unmap>:
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	83 ec 28             	sub    $0x28,%esp
  800f84:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800f87:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800f8a:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800f8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f93:	b8 06 00 00 00       	mov    $0x6,%eax
  800f98:	bf 00 00 00 00       	mov    $0x0,%edi
  800f9d:	89 fb                	mov    %edi,%ebx
  800f9f:	89 fe                	mov    %edi,%esi
  800fa1:	cd 30                	int    $0x30
  800fa3:	85 c0                	test   %eax,%eax
  800fa5:	7e 28                	jle    800fcf <sys_page_unmap+0x51>
  800fa7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fab:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800fb2:	00 
  800fb3:	c7 44 24 08 df 2c 80 	movl   $0x802cdf,0x8(%esp)
  800fba:	00 
  800fbb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fc2:	00 
  800fc3:	c7 04 24 fc 2c 80 00 	movl   $0x802cfc,(%esp)
  800fca:	e8 f1 f1 ff ff       	call   8001c0 <_panic>
  800fcf:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800fd2:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800fd5:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800fd8:	89 ec                	mov    %ebp,%esp
  800fda:	5d                   	pop    %ebp
  800fdb:	c3                   	ret    

00800fdc <sys_page_map>:
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	83 ec 28             	sub    $0x28,%esp
  800fe2:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800fe5:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800fe8:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800feb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ff4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ff7:	8b 75 18             	mov    0x18(%ebp),%esi
  800ffa:	b8 05 00 00 00       	mov    $0x5,%eax
  800fff:	cd 30                	int    $0x30
  801001:	85 c0                	test   %eax,%eax
  801003:	7e 28                	jle    80102d <sys_page_map+0x51>
  801005:	89 44 24 10          	mov    %eax,0x10(%esp)
  801009:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801010:	00 
  801011:	c7 44 24 08 df 2c 80 	movl   $0x802cdf,0x8(%esp)
  801018:	00 
  801019:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801020:	00 
  801021:	c7 04 24 fc 2c 80 00 	movl   $0x802cfc,(%esp)
  801028:	e8 93 f1 ff ff       	call   8001c0 <_panic>
  80102d:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801030:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801033:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801036:	89 ec                	mov    %ebp,%esp
  801038:	5d                   	pop    %ebp
  801039:	c3                   	ret    

0080103a <sys_page_alloc>:
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	83 ec 28             	sub    $0x28,%esp
  801040:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  801043:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  801046:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  801049:	8b 55 08             	mov    0x8(%ebp),%edx
  80104c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80104f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801052:	b8 04 00 00 00       	mov    $0x4,%eax
  801057:	bf 00 00 00 00       	mov    $0x0,%edi
  80105c:	89 fe                	mov    %edi,%esi
  80105e:	cd 30                	int    $0x30
  801060:	85 c0                	test   %eax,%eax
  801062:	7e 28                	jle    80108c <sys_page_alloc+0x52>
  801064:	89 44 24 10          	mov    %eax,0x10(%esp)
  801068:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80106f:	00 
  801070:	c7 44 24 08 df 2c 80 	movl   $0x802cdf,0x8(%esp)
  801077:	00 
  801078:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80107f:	00 
  801080:	c7 04 24 fc 2c 80 00 	movl   $0x802cfc,(%esp)
  801087:	e8 34 f1 ff ff       	call   8001c0 <_panic>
  80108c:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  80108f:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801092:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801095:	89 ec                	mov    %ebp,%esp
  801097:	5d                   	pop    %ebp
  801098:	c3                   	ret    

00801099 <sys_yield>:
  801099:	55                   	push   %ebp
  80109a:	89 e5                	mov    %esp,%ebp
  80109c:	83 ec 0c             	sub    $0xc,%esp
  80109f:	89 1c 24             	mov    %ebx,(%esp)
  8010a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010a6:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010aa:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010af:	bf 00 00 00 00       	mov    $0x0,%edi
  8010b4:	89 fa                	mov    %edi,%edx
  8010b6:	89 f9                	mov    %edi,%ecx
  8010b8:	89 fb                	mov    %edi,%ebx
  8010ba:	89 fe                	mov    %edi,%esi
  8010bc:	cd 30                	int    $0x30
  8010be:	8b 1c 24             	mov    (%esp),%ebx
  8010c1:	8b 74 24 04          	mov    0x4(%esp),%esi
  8010c5:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8010c9:	89 ec                	mov    %ebp,%esp
  8010cb:	5d                   	pop    %ebp
  8010cc:	c3                   	ret    

008010cd <sys_getenvid>:
  8010cd:	55                   	push   %ebp
  8010ce:	89 e5                	mov    %esp,%ebp
  8010d0:	83 ec 0c             	sub    $0xc,%esp
  8010d3:	89 1c 24             	mov    %ebx,(%esp)
  8010d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010da:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010de:	b8 02 00 00 00       	mov    $0x2,%eax
  8010e3:	bf 00 00 00 00       	mov    $0x0,%edi
  8010e8:	89 fa                	mov    %edi,%edx
  8010ea:	89 f9                	mov    %edi,%ecx
  8010ec:	89 fb                	mov    %edi,%ebx
  8010ee:	89 fe                	mov    %edi,%esi
  8010f0:	cd 30                	int    $0x30
  8010f2:	8b 1c 24             	mov    (%esp),%ebx
  8010f5:	8b 74 24 04          	mov    0x4(%esp),%esi
  8010f9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8010fd:	89 ec                	mov    %ebp,%esp
  8010ff:	5d                   	pop    %ebp
  801100:	c3                   	ret    

00801101 <sys_env_destroy>:
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	83 ec 28             	sub    $0x28,%esp
  801107:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  80110a:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  80110d:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  801110:	8b 55 08             	mov    0x8(%ebp),%edx
  801113:	b8 03 00 00 00       	mov    $0x3,%eax
  801118:	bf 00 00 00 00       	mov    $0x0,%edi
  80111d:	89 f9                	mov    %edi,%ecx
  80111f:	89 fb                	mov    %edi,%ebx
  801121:	89 fe                	mov    %edi,%esi
  801123:	cd 30                	int    $0x30
  801125:	85 c0                	test   %eax,%eax
  801127:	7e 28                	jle    801151 <sys_env_destroy+0x50>
  801129:	89 44 24 10          	mov    %eax,0x10(%esp)
  80112d:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801134:	00 
  801135:	c7 44 24 08 df 2c 80 	movl   $0x802cdf,0x8(%esp)
  80113c:	00 
  80113d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801144:	00 
  801145:	c7 04 24 fc 2c 80 00 	movl   $0x802cfc,(%esp)
  80114c:	e8 6f f0 ff ff       	call   8001c0 <_panic>
  801151:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801154:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801157:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  80115a:	89 ec                	mov    %ebp,%esp
  80115c:	5d                   	pop    %ebp
  80115d:	c3                   	ret    
	...

00801160 <duppage>:
// It is also OK to panic on error.
// 
static int
duppage(envid_t envid, unsigned pn)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	53                   	push   %ebx
  801164:	83 ec 14             	sub    $0x14,%esp
  801167:	89 c1                	mov    %eax,%ecx
	int r;

	// LAB 4: Your code here.
	pde_t *pde;
	pte_t *pte;
	void *addr=(void*)(pn*PGSIZE);
  801169:	89 d3                	mov    %edx,%ebx
  80116b:	c1 e3 0c             	shl    $0xc,%ebx
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
  80116e:	89 d8                	mov    %ebx,%eax
  801170:	c1 e8 16             	shr    $0x16,%eax
  801173:	f6 04 85 00 d0 7b ef 	testb  $0x1,0xef7bd000(,%eax,4)
  80117a:	01 
  80117b:	74 14                	je     801191 <duppage+0x31>
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else    panic("page table for pn page is not exist");
	if((*pte&PTE_W)||(*pte&PTE_COW))
  80117d:	89 d8                	mov    %ebx,%eax
  80117f:	c1 e8 0c             	shr    $0xc,%eax
  801182:	f7 04 85 00 00 40 ef 	testl  $0x802,0xef400000(,%eax,4)
  801189:	02 08 00 00 
  80118d:	75 1e                	jne    8011ad <duppage+0x4d>
  80118f:	eb 73                	jmp    801204 <duppage+0xa4>
  801191:	c7 44 24 08 0c 2d 80 	movl   $0x802d0c,0x8(%esp)
  801198:	00 
  801199:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
  8011a0:	00 
  8011a1:	c7 04 24 ca 2d 80 00 	movl   $0x802dca,(%esp)
  8011a8:	e8 13 f0 ff ff       	call   8001c0 <_panic>
	{
		if((r=sys_page_map(0,addr,envid,addr,PTE_COW|PTE_U))<0)
  8011ad:	c7 44 24 10 04 08 00 	movl   $0x804,0x10(%esp)
  8011b4:	00 
  8011b5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011c8:	e8 0f fe ff ff       	call   800fdc <sys_page_map>
  8011cd:	85 c0                	test   %eax,%eax
  8011cf:	78 60                	js     801231 <duppage+0xd1>
			return r;
		if((r=sys_page_map(0,addr,0,addr,PTE_COW|PTE_U))<0)//映射的时候注意env的id
  8011d1:	c7 44 24 10 04 08 00 	movl   $0x804,0x10(%esp)
  8011d8:	00 
  8011d9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011dd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011e4:	00 
  8011e5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011f0:	e8 e7 fd ff ff       	call   800fdc <sys_page_map>
  8011f5:	85 c0                	test   %eax,%eax
  8011f7:	0f 9f c2             	setg   %dl
  8011fa:	0f b6 d2             	movzbl %dl,%edx
  8011fd:	83 ea 01             	sub    $0x1,%edx
  801200:	21 d0                	and    %edx,%eax
  801202:	eb 2d                	jmp    801231 <duppage+0xd1>
                        return r;
	}
	else{	
		if((r=sys_page_map(0,addr,envid,addr,PTE_U|PTE_P))<0)
  801204:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80120b:	00 
  80120c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801210:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801214:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801218:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80121f:	e8 b8 fd ff ff       	call   800fdc <sys_page_map>
  801224:	85 c0                	test   %eax,%eax
  801226:	0f 9f c2             	setg   %dl
  801229:	0f b6 d2             	movzbl %dl,%edx
  80122c:	83 ea 01             	sub    $0x1,%edx
  80122f:	21 d0                	and    %edx,%eax
			return r;
	}
	//panic("duppage not implemented");
	return 0;
}
  801231:	83 c4 14             	add    $0x14,%esp
  801234:	5b                   	pop    %ebx
  801235:	5d                   	pop    %ebp
  801236:	c3                   	ret    

00801237 <sfork>:

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
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	57                   	push   %edi
  80123b:	56                   	push   %esi
  80123c:	53                   	push   %ebx
  80123d:	83 ec 1c             	sub    $0x1c,%esp
static __inline envid_t
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801240:	ba 07 00 00 00       	mov    $0x7,%edx
  801245:	89 d0                	mov    %edx,%eax
  801247:	cd 30                	int    $0x30
  801249:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
	int r;
	pde_t *pde;
	pte_t *pte;
	unsigned i;
	uint32_t addr;
	envid_t envid;
	envid = sys_exofork();//创建子环境
	if(envid < 0)
  80124c:	85 c0                	test   %eax,%eax
  80124e:	79 20                	jns    801270 <sfork+0x39>
		panic("sys_exofork: %e", envid);
  801250:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801254:	c7 44 24 08 d5 2d 80 	movl   $0x802dd5,0x8(%esp)
  80125b:	00 
  80125c:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  801263:	00 
  801264:	c7 04 24 ca 2d 80 00 	movl   $0x802dca,(%esp)
  80126b:	e8 50 ef ff ff       	call   8001c0 <_panic>
	if(envid==0)//子环境中
  801270:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  801274:	75 21                	jne    801297 <sfork+0x60>
	{
		env = &envs[ENVX(sys_getenvid())];
  801276:	e8 52 fe ff ff       	call   8010cd <sys_getenvid>
  80127b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801280:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801283:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801288:	a3 3c 60 80 00       	mov    %eax,0x80603c
  80128d:	b8 00 00 00 00       	mov    $0x0,%eax
  801292:	e9 83 01 00 00       	jmp    80141a <sfork+0x1e3>
		return 0;
	}
	else{//父环境中,注意：这里需要设置父环境的缺页异常栈，还需要设置子环境的缺页异常栈，
	//父子环境的页异常栈不共享？具体原因还得思考
		env = &envs[ENVX(sys_getenvid())];
  801297:	e8 31 fe ff ff       	call   8010cd <sys_getenvid>
  80129c:	25 ff 03 00 00       	and    $0x3ff,%eax
  8012a1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012a4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012a9:	a3 3c 60 80 00       	mov    %eax,0x80603c
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
  8012ae:	c7 04 24 22 14 80 00 	movl   $0x801422,(%esp)
  8012b5:	e8 6e 13 00 00       	call   802628 <set_pgfault_handler>
  8012ba:	be 00 00 00 00       	mov    $0x0,%esi
  8012bf:	bf 00 00 00 00       	mov    $0x0,%edi
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
		{
			addr=i*PGSIZE;
			pde =(pde_t*) &vpd[VPD(addr)];
  8012c4:	89 f8                	mov    %edi,%eax
  8012c6:	c1 e8 16             	shr    $0x16,%eax
  8012c9:	c1 e0 02             	shl    $0x2,%eax
			if(*pde&PTE_P)//这里只处理有物理页面映射的页表项
  8012cc:	f6 80 00 d0 7b ef 01 	testb  $0x1,0xef7bd000(%eax)
  8012d3:	0f 84 dc 00 00 00    	je     8013b5 <sfork+0x17e>
			{
				pte=(pte_t*)&vpt[VPN(addr)];
			}
			else    continue;
			if((i==(unsigned)VPN(USTACKTOP-PGSIZE))||(i==(unsigned)VPN(PFTEMP)))
  8012d9:	81 fe fd eb 0e 00    	cmp    $0xeebfd,%esi
  8012df:	74 08                	je     8012e9 <sfork+0xb2>
  8012e1:	81 fe ff 07 00 00    	cmp    $0x7ff,%esi
  8012e7:	75 17                	jne    801300 <sfork+0xc9>
								//特殊处理，用户层普通栈
			{	
				if((r=duppage(envid,i))<0)
  8012e9:	89 f2                	mov    %esi,%edx
  8012eb:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8012ee:	e8 6d fe ff ff       	call   801160 <duppage>
  8012f3:	85 c0                	test   %eax,%eax
  8012f5:	0f 89 ba 00 00 00    	jns    8013b5 <sfork+0x17e>
  8012fb:	e9 1a 01 00 00       	jmp    80141a <sfork+0x1e3>
  801300:	f6 80 00 d0 7b ef 01 	testb  $0x1,0xef7bd000(%eax)
  801307:	74 11                	je     80131a <sfork+0xe3>
  801309:	89 f8                	mov    %edi,%eax
  80130b:	c1 e8 0c             	shr    $0xc,%eax
  80130e:	f6 04 85 00 00 40 ef 	testb  $0x2,0xef400000(,%eax,4)
  801315:	02 
  801316:	75 1e                	jne    801336 <sfork+0xff>
  801318:	eb 74                	jmp    80138e <sfork+0x157>
  80131a:	c7 44 24 08 0c 2d 80 	movl   $0x802d0c,0x8(%esp)
  801321:	00 
  801322:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
  801329:	00 
  80132a:	c7 04 24 ca 2d 80 00 	movl   $0x802dca,(%esp)
  801331:	e8 8a ee ff ff       	call   8001c0 <_panic>
  801336:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
  80133d:	00 
  80133e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801342:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  801345:	89 44 24 08          	mov    %eax,0x8(%esp)
  801349:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80134d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801354:	e8 83 fc ff ff       	call   800fdc <sys_page_map>
  801359:	85 c0                	test   %eax,%eax
  80135b:	0f 88 b9 00 00 00    	js     80141a <sfork+0x1e3>
  801361:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
  801368:	00 
  801369:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80136d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801374:	00 
  801375:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801379:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801380:	e8 57 fc ff ff       	call   800fdc <sys_page_map>
  801385:	85 c0                	test   %eax,%eax
  801387:	79 2c                	jns    8013b5 <sfork+0x17e>
  801389:	e9 8c 00 00 00       	jmp    80141a <sfork+0x1e3>
  80138e:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801395:	00 
  801396:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80139a:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80139d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013ac:	e8 2b fc ff ff       	call   800fdc <sys_page_map>
  8013b1:	85 c0                	test   %eax,%eax
  8013b3:	78 65                	js     80141a <sfork+0x1e3>
  8013b5:	83 c6 01             	add    $0x1,%esi
  8013b8:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8013be:	81 fe 00 ec 0e 00    	cmp    $0xeec00,%esi
  8013c4:	0f 85 fa fe ff ff    	jne    8012c4 <sfork+0x8d>
					return r;
				continue;
			}
			if((r=sduppage(envid,i))<0)
				return r;
		}
		if((r=sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  8013ca:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013d1:	00 
  8013d2:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013d9:	ee 
  8013da:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8013dd:	89 04 24             	mov    %eax,(%esp)
  8013e0:	e8 55 fc ff ff       	call   80103a <sys_page_alloc>
  8013e5:	85 c0                	test   %eax,%eax
  8013e7:	78 31                	js     80141a <sfork+0x1e3>
                        return r;//设置子环境的缺页异常栈
		if((r=sys_env_set_pgfault_upcall(envid,(void*)_pgfault_upcall))<0)
  8013e9:	c7 44 24 04 ac 26 80 	movl   $0x8026ac,0x4(%esp)
  8013f0:	00 
  8013f1:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8013f4:	89 04 24             	mov    %eax,(%esp)
  8013f7:	e8 68 fa ff ff       	call   800e64 <sys_env_set_pgfault_upcall>
  8013fc:	85 c0                	test   %eax,%eax
  8013fe:	78 1a                	js     80141a <sfork+0x1e3>
			return r;//设置子环境的缺页异常处理入口点
		if((r=sys_env_set_status(envid,ENV_RUNNABLE))<0)
  801400:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801407:	00 
  801408:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80140b:	89 04 24             	mov    %eax,(%esp)
  80140e:	e8 0d fb ff ff       	call   800f20 <sys_env_set_status>
  801413:	85 c0                	test   %eax,%eax
  801415:	78 03                	js     80141a <sfork+0x1e3>
  801417:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
			return r;//设置子环境的状态为可运行
		return envid;
	}
	//panic("sfork not implemented");
	//return -E_INVAL;
}
  80141a:	83 c4 1c             	add    $0x1c,%esp
  80141d:	5b                   	pop    %ebx
  80141e:	5e                   	pop    %esi
  80141f:	5f                   	pop    %edi
  801420:	5d                   	pop    %ebp
  801421:	c3                   	ret    

00801422 <pgfault>:
  801422:	55                   	push   %ebp
  801423:	89 e5                	mov    %esp,%ebp
  801425:	56                   	push   %esi
  801426:	53                   	push   %ebx
  801427:	83 ec 20             	sub    $0x20,%esp
  80142a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80142d:	8b 71 04             	mov    0x4(%ecx),%esi
  801430:	8b 19                	mov    (%ecx),%ebx
  801432:	89 d8                	mov    %ebx,%eax
  801434:	c1 e8 16             	shr    $0x16,%eax
  801437:	c1 e0 02             	shl    $0x2,%eax
  80143a:	8d 90 00 d0 7b ef    	lea    0xef7bd000(%eax),%edx
  801440:	f6 80 00 d0 7b ef 01 	testb  $0x1,0xef7bd000(%eax)
  801447:	74 16                	je     80145f <pgfault+0x3d>
  801449:	89 d8                	mov    %ebx,%eax
  80144b:	c1 e8 0c             	shr    $0xc,%eax
  80144e:	8d 04 85 00 00 40 ef 	lea    0xef400000(,%eax,4),%eax
  801455:	f7 c6 02 00 00 00    	test   $0x2,%esi
  80145b:	75 3f                	jne    80149c <pgfault+0x7a>
  80145d:	eb 43                	jmp    8014a2 <pgfault+0x80>
  80145f:	8b 41 28             	mov    0x28(%ecx),%eax
  801462:	8b 12                	mov    (%edx),%edx
  801464:	89 44 24 10          	mov    %eax,0x10(%esp)
  801468:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80146c:	89 74 24 08          	mov    %esi,0x8(%esp)
  801470:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801474:	c7 04 24 30 2d 80 00 	movl   $0x802d30,(%esp)
  80147b:	e8 0d ee ff ff       	call   80028d <cprintf>
  801480:	c7 44 24 08 54 2d 80 	movl   $0x802d54,0x8(%esp)
  801487:	00 
  801488:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80148f:	00 
  801490:	c7 04 24 ca 2d 80 00 	movl   $0x802dca,(%esp)
  801497:	e8 24 ed ff ff       	call   8001c0 <_panic>
  80149c:	f6 40 01 08          	testb  $0x8,0x1(%eax)
  8014a0:	75 49                	jne    8014eb <pgfault+0xc9>
  8014a2:	8b 51 28             	mov    0x28(%ecx),%edx
  8014a5:	8b 08                	mov    (%eax),%ecx
  8014a7:	a1 3c 60 80 00       	mov    0x80603c,%eax
  8014ac:	8b 40 4c             	mov    0x4c(%eax),%eax
  8014af:	89 54 24 14          	mov    %edx,0x14(%esp)
  8014b3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8014b7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8014bb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c3:	c7 04 24 7c 2d 80 00 	movl   $0x802d7c,(%esp)
  8014ca:	e8 be ed ff ff       	call   80028d <cprintf>
  8014cf:	c7 44 24 08 e5 2d 80 	movl   $0x802de5,0x8(%esp)
  8014d6:	00 
  8014d7:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8014de:	00 
  8014df:	c7 04 24 ca 2d 80 00 	movl   $0x802dca,(%esp)
  8014e6:	e8 d5 ec ff ff       	call   8001c0 <_panic>
  8014eb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8014f2:	00 
  8014f3:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8014fa:	00 
  8014fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801502:	e8 33 fb ff ff       	call   80103a <sys_page_alloc>
  801507:	85 c0                	test   %eax,%eax
  801509:	79 20                	jns    80152b <pgfault+0x109>
  80150b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80150f:	c7 44 24 08 a8 2d 80 	movl   $0x802da8,0x8(%esp)
  801516:	00 
  801517:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  80151e:	00 
  80151f:	c7 04 24 ca 2d 80 00 	movl   $0x802dca,(%esp)
  801526:	e8 95 ec ff ff       	call   8001c0 <_panic>
  80152b:	89 de                	mov    %ebx,%esi
  80152d:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  801533:	89 f2                	mov    %esi,%edx
  801535:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  80153b:	89 c3                	mov    %eax,%ebx
  80153d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801543:	39 de                	cmp    %ebx,%esi
  801545:	73 13                	jae    80155a <pgfault+0x138>
  801547:	b9 00 f0 7f 00       	mov    $0x7ff000,%ecx
  80154c:	8b 02                	mov    (%edx),%eax
  80154e:	89 01                	mov    %eax,(%ecx)
  801550:	83 c1 04             	add    $0x4,%ecx
  801553:	83 c2 04             	add    $0x4,%edx
  801556:	39 d3                	cmp    %edx,%ebx
  801558:	77 f2                	ja     80154c <pgfault+0x12a>
  80155a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801561:	00 
  801562:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801566:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80156d:	00 
  80156e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801575:	00 
  801576:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80157d:	e8 5a fa ff ff       	call   800fdc <sys_page_map>
  801582:	85 c0                	test   %eax,%eax
  801584:	79 1c                	jns    8015a2 <pgfault+0x180>
  801586:	c7 44 24 08 00 2e 80 	movl   $0x802e00,0x8(%esp)
  80158d:	00 
  80158e:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801595:	00 
  801596:	c7 04 24 ca 2d 80 00 	movl   $0x802dca,(%esp)
  80159d:	e8 1e ec ff ff       	call   8001c0 <_panic>
  8015a2:	83 c4 20             	add    $0x20,%esp
  8015a5:	5b                   	pop    %ebx
  8015a6:	5e                   	pop    %esi
  8015a7:	5d                   	pop    %ebp
  8015a8:	c3                   	ret    

008015a9 <fork>:
  8015a9:	55                   	push   %ebp
  8015aa:	89 e5                	mov    %esp,%ebp
  8015ac:	56                   	push   %esi
  8015ad:	53                   	push   %ebx
  8015ae:	83 ec 10             	sub    $0x10,%esp
static __inline envid_t
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8015b1:	ba 07 00 00 00       	mov    $0x7,%edx
  8015b6:	89 d0                	mov    %edx,%eax
  8015b8:	cd 30                	int    $0x30
  8015ba:	89 c6                	mov    %eax,%esi
  8015bc:	85 c0                	test   %eax,%eax
  8015be:	79 20                	jns    8015e0 <fork+0x37>
  8015c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015c4:	c7 44 24 08 d5 2d 80 	movl   $0x802dd5,0x8(%esp)
  8015cb:	00 
  8015cc:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  8015d3:	00 
  8015d4:	c7 04 24 ca 2d 80 00 	movl   $0x802dca,(%esp)
  8015db:	e8 e0 eb ff ff       	call   8001c0 <_panic>
  8015e0:	85 c0                	test   %eax,%eax
  8015e2:	75 21                	jne    801605 <fork+0x5c>
  8015e4:	e8 e4 fa ff ff       	call   8010cd <sys_getenvid>
  8015e9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8015ee:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8015f1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8015f6:	a3 3c 60 80 00       	mov    %eax,0x80603c
  8015fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801600:	e9 9f 00 00 00       	jmp    8016a4 <fork+0xfb>
  801605:	c7 04 24 22 14 80 00 	movl   $0x801422,(%esp)
  80160c:	e8 17 10 00 00       	call   802628 <set_pgfault_handler>
  801611:	bb 00 00 00 00       	mov    $0x0,%ebx
  801616:	eb 08                	jmp    801620 <fork+0x77>
  801618:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  80161e:	74 3e                	je     80165e <fork+0xb5>
  801620:	89 da                	mov    %ebx,%edx
  801622:	c1 e2 0c             	shl    $0xc,%edx
  801625:	89 d0                	mov    %edx,%eax
  801627:	c1 e8 16             	shr    $0x16,%eax
  80162a:	f6 04 85 00 d0 7b ef 	testb  $0x1,0xef7bd000(,%eax,4)
  801631:	01 
  801632:	74 1f                	je     801653 <fork+0xaa>
  801634:	89 d0                	mov    %edx,%eax
  801636:	c1 e8 0c             	shr    $0xc,%eax
  801639:	f7 04 85 00 00 40 ef 	testl  $0x802,0xef400000(,%eax,4)
  801640:	02 08 00 00 
  801644:	74 0d                	je     801653 <fork+0xaa>
  801646:	89 da                	mov    %ebx,%edx
  801648:	89 f0                	mov    %esi,%eax
  80164a:	e8 11 fb ff ff       	call   801160 <duppage>
  80164f:	85 c0                	test   %eax,%eax
  801651:	78 51                	js     8016a4 <fork+0xfb>
  801653:	83 c3 01             	add    $0x1,%ebx
  801656:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  80165c:	75 ba                	jne    801618 <fork+0x6f>
  80165e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801665:	00 
  801666:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80166d:	ee 
  80166e:	89 34 24             	mov    %esi,(%esp)
  801671:	e8 c4 f9 ff ff       	call   80103a <sys_page_alloc>
  801676:	85 c0                	test   %eax,%eax
  801678:	78 2a                	js     8016a4 <fork+0xfb>
  80167a:	c7 44 24 04 ac 26 80 	movl   $0x8026ac,0x4(%esp)
  801681:	00 
  801682:	89 34 24             	mov    %esi,(%esp)
  801685:	e8 da f7 ff ff       	call   800e64 <sys_env_set_pgfault_upcall>
  80168a:	85 c0                	test   %eax,%eax
  80168c:	78 16                	js     8016a4 <fork+0xfb>
  80168e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801695:	00 
  801696:	89 34 24             	mov    %esi,(%esp)
  801699:	e8 82 f8 ff ff       	call   800f20 <sys_env_set_status>
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	78 02                	js     8016a4 <fork+0xfb>
  8016a2:	89 f0                	mov    %esi,%eax
  8016a4:	83 c4 10             	add    $0x10,%esp
  8016a7:	5b                   	pop    %ebx
  8016a8:	5e                   	pop    %esi
  8016a9:	5d                   	pop    %ebp
  8016aa:	c3                   	ret    
  8016ab:	00 00                	add    %al,(%eax)
  8016ad:	00 00                	add    %al,(%eax)
	...

008016b0 <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	57                   	push   %edi
  8016b4:	56                   	push   %esi
  8016b5:	53                   	push   %ebx
  8016b6:	83 ec 1c             	sub    $0x1c,%esp
  8016b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8016bc:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  8016bf:	e8 09 fa ff ff       	call   8010cd <sys_getenvid>
  8016c4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8016c9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8016cc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8016d1:	a3 3c 60 80 00       	mov    %eax,0x80603c
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  8016d6:	e8 f2 f9 ff ff       	call   8010cd <sys_getenvid>
  8016db:	25 ff 03 00 00       	and    $0x3ff,%eax
  8016e0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8016e3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8016e8:	a3 3c 60 80 00       	mov    %eax,0x80603c
		if(env->env_id==to_env){
  8016ed:	8b 40 4c             	mov    0x4c(%eax),%eax
  8016f0:	39 f0                	cmp    %esi,%eax
  8016f2:	75 0e                	jne    801702 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  8016f4:	c7 04 24 14 2e 80 00 	movl   $0x802e14,(%esp)
  8016fb:	e8 8d eb ff ff       	call   80028d <cprintf>
  801700:	eb 5a                	jmp    80175c <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  801702:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801706:	8b 45 10             	mov    0x10(%ebp),%eax
  801709:	89 44 24 08          	mov    %eax,0x8(%esp)
  80170d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801710:	89 44 24 04          	mov    %eax,0x4(%esp)
  801714:	89 34 24             	mov    %esi,(%esp)
  801717:	e8 10 f7 ff ff       	call   800e2c <sys_ipc_try_send>
  80171c:	89 c3                	mov    %eax,%ebx
  80171e:	85 c0                	test   %eax,%eax
  801720:	79 25                	jns    801747 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  801722:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801725:	74 2b                	je     801752 <ipc_send+0xa2>
				panic("send error:%e",r);
  801727:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80172b:	c7 44 24 08 30 2e 80 	movl   $0x802e30,0x8(%esp)
  801732:	00 
  801733:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80173a:	00 
  80173b:	c7 04 24 3e 2e 80 00 	movl   $0x802e3e,(%esp)
  801742:	e8 79 ea ff ff       	call   8001c0 <_panic>
		}
			sys_yield();
  801747:	e8 4d f9 ff ff       	call   801099 <sys_yield>
		
	}while(r!=0);
  80174c:	85 db                	test   %ebx,%ebx
  80174e:	75 86                	jne    8016d6 <ipc_send+0x26>
  801750:	eb 0a                	jmp    80175c <ipc_send+0xac>
  801752:	e8 42 f9 ff ff       	call   801099 <sys_yield>
  801757:	e9 7a ff ff ff       	jmp    8016d6 <ipc_send+0x26>
	return;
	//panic("ipc_send not implemented");
}
  80175c:	83 c4 1c             	add    $0x1c,%esp
  80175f:	5b                   	pop    %ebx
  801760:	5e                   	pop    %esi
  801761:	5f                   	pop    %edi
  801762:	5d                   	pop    %ebp
  801763:	c3                   	ret    

00801764 <ipc_recv>:
  801764:	55                   	push   %ebp
  801765:	89 e5                	mov    %esp,%ebp
  801767:	57                   	push   %edi
  801768:	56                   	push   %esi
  801769:	53                   	push   %ebx
  80176a:	83 ec 0c             	sub    $0xc,%esp
  80176d:	8b 75 08             	mov    0x8(%ebp),%esi
  801770:	8b 7d 10             	mov    0x10(%ebp),%edi
  801773:	e8 55 f9 ff ff       	call   8010cd <sys_getenvid>
  801778:	25 ff 03 00 00       	and    $0x3ff,%eax
  80177d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801780:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801785:	a3 3c 60 80 00       	mov    %eax,0x80603c
  80178a:	85 f6                	test   %esi,%esi
  80178c:	74 29                	je     8017b7 <ipc_recv+0x53>
  80178e:	8b 40 4c             	mov    0x4c(%eax),%eax
  801791:	3b 06                	cmp    (%esi),%eax
  801793:	75 22                	jne    8017b7 <ipc_recv+0x53>
  801795:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80179b:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8017a1:	c7 04 24 14 2e 80 00 	movl   $0x802e14,(%esp)
  8017a8:	e8 e0 ea ff ff       	call   80028d <cprintf>
  8017ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017b2:	e9 8a 00 00 00       	jmp    801841 <ipc_recv+0xdd>
  8017b7:	e8 11 f9 ff ff       	call   8010cd <sys_getenvid>
  8017bc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8017c1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8017c4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8017c9:	a3 3c 60 80 00       	mov    %eax,0x80603c
  8017ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d1:	89 04 24             	mov    %eax,(%esp)
  8017d4:	e8 f6 f5 ff ff       	call   800dcf <sys_ipc_recv>
  8017d9:	89 c3                	mov    %eax,%ebx
  8017db:	85 c0                	test   %eax,%eax
  8017dd:	79 1a                	jns    8017f9 <ipc_recv+0x95>
  8017df:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8017e5:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8017eb:	c7 04 24 48 2e 80 00 	movl   $0x802e48,(%esp)
  8017f2:	e8 96 ea ff ff       	call   80028d <cprintf>
  8017f7:	eb 48                	jmp    801841 <ipc_recv+0xdd>
  8017f9:	e8 cf f8 ff ff       	call   8010cd <sys_getenvid>
  8017fe:	25 ff 03 00 00       	and    $0x3ff,%eax
  801803:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801806:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80180b:	a3 3c 60 80 00       	mov    %eax,0x80603c
  801810:	85 f6                	test   %esi,%esi
  801812:	74 05                	je     801819 <ipc_recv+0xb5>
  801814:	8b 40 74             	mov    0x74(%eax),%eax
  801817:	89 06                	mov    %eax,(%esi)
  801819:	85 ff                	test   %edi,%edi
  80181b:	74 0a                	je     801827 <ipc_recv+0xc3>
  80181d:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801822:	8b 40 78             	mov    0x78(%eax),%eax
  801825:	89 07                	mov    %eax,(%edi)
  801827:	e8 a1 f8 ff ff       	call   8010cd <sys_getenvid>
  80182c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801831:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801834:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801839:	a3 3c 60 80 00       	mov    %eax,0x80603c
  80183e:	8b 58 70             	mov    0x70(%eax),%ebx
  801841:	89 d8                	mov    %ebx,%eax
  801843:	83 c4 0c             	add    $0xc,%esp
  801846:	5b                   	pop    %ebx
  801847:	5e                   	pop    %esi
  801848:	5f                   	pop    %edi
  801849:	5d                   	pop    %ebp
  80184a:	c3                   	ret    
  80184b:	00 00                	add    %al,(%eax)
  80184d:	00 00                	add    %al,(%eax)
	...

00801850 <fd2num>:
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	8b 45 08             	mov    0x8(%ebp),%eax
  801856:	05 00 00 00 30       	add    $0x30000000,%eax
  80185b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80185e:	5d                   	pop    %ebp
  80185f:	c3                   	ret    

00801860 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801860:	55                   	push   %ebp
  801861:	89 e5                	mov    %esp,%ebp
  801863:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801866:	8b 45 08             	mov    0x8(%ebp),%eax
  801869:	89 04 24             	mov    %eax,(%esp)
  80186c:	e8 df ff ff ff       	call   801850 <fd2num>
  801871:	c1 e0 0c             	shl    $0xc,%eax
  801874:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801879:	c9                   	leave  
  80187a:	c3                   	ret    

0080187b <fd_alloc>:

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
  80187b:	55                   	push   %ebp
  80187c:	89 e5                	mov    %esp,%ebp
  80187e:	53                   	push   %ebx
  80187f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801882:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  801887:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801889:	89 d0                	mov    %edx,%eax
  80188b:	c1 e8 16             	shr    $0x16,%eax
  80188e:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  801895:	a8 01                	test   $0x1,%al
  801897:	74 10                	je     8018a9 <fd_alloc+0x2e>
  801899:	89 d0                	mov    %edx,%eax
  80189b:	c1 e8 0c             	shr    $0xc,%eax
  80189e:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  8018a5:	a8 01                	test   $0x1,%al
  8018a7:	75 09                	jne    8018b2 <fd_alloc+0x37>
			*fd_store = fd;
  8018a9:	89 0b                	mov    %ecx,(%ebx)
  8018ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8018b0:	eb 19                	jmp    8018cb <fd_alloc+0x50>
			return 0;
  8018b2:	81 c2 00 10 00 00    	add    $0x1000,%edx
  8018b8:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  8018be:	75 c7                	jne    801887 <fd_alloc+0xc>
		}
	}
	*fd_store = 0;
  8018c0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8018c6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8018cb:	5b                   	pop    %ebx
  8018cc:	5d                   	pop    %ebp
  8018cd:	c3                   	ret    

008018ce <fd_lookup>:

// Check that fdnum is in range and mapped.
// If it is, set *fd_store to the fd page virtual address.
//
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8018ce:	55                   	push   %ebp
  8018cf:	89 e5                	mov    %esp,%ebp
  8018d1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8018d4:	83 f8 1f             	cmp    $0x1f,%eax
  8018d7:	77 35                	ja     80190e <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8018d9:	c1 e0 0c             	shl    $0xc,%eax
  8018dc:	8d 90 00 00 00 d0    	lea    0xd0000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  8018e2:	89 d0                	mov    %edx,%eax
  8018e4:	c1 e8 16             	shr    $0x16,%eax
  8018e7:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  8018ee:	a8 01                	test   $0x1,%al
  8018f0:	74 1c                	je     80190e <fd_lookup+0x40>
  8018f2:	89 d0                	mov    %edx,%eax
  8018f4:	c1 e8 0c             	shr    $0xc,%eax
  8018f7:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  8018fe:	a8 01                	test   $0x1,%al
  801900:	74 0c                	je     80190e <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801902:	8b 45 0c             	mov    0xc(%ebp),%eax
  801905:	89 10                	mov    %edx,(%eax)
  801907:	b8 00 00 00 00       	mov    $0x0,%eax
  80190c:	eb 05                	jmp    801913 <fd_lookup+0x45>
	return 0;
  80190e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801913:	5d                   	pop    %ebp
  801914:	c3                   	ret    

00801915 <seek>:

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
  801915:	55                   	push   %ebp
  801916:	89 e5                	mov    %esp,%ebp
  801918:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80191b:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  80191e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801922:	8b 45 08             	mov    0x8(%ebp),%eax
  801925:	89 04 24             	mov    %eax,(%esp)
  801928:	e8 a1 ff ff ff       	call   8018ce <fd_lookup>
  80192d:	85 c0                	test   %eax,%eax
  80192f:	78 0e                	js     80193f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801931:	8b 55 0c             	mov    0xc(%ebp),%edx
  801934:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  801937:	89 50 04             	mov    %edx,0x4(%eax)
  80193a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80193f:	c9                   	leave  
  801940:	c3                   	ret    

00801941 <dev_lookup>:
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	53                   	push   %ebx
  801945:	83 ec 14             	sub    $0x14,%esp
  801948:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80194b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80194e:	ba 04 60 80 00       	mov    $0x806004,%edx
  801953:	b8 00 00 00 00       	mov    $0x0,%eax
  801958:	39 0d 04 60 80 00    	cmp    %ecx,0x806004
  80195e:	75 12                	jne    801972 <dev_lookup+0x31>
  801960:	eb 04                	jmp    801966 <dev_lookup+0x25>
  801962:	39 0a                	cmp    %ecx,(%edx)
  801964:	75 0c                	jne    801972 <dev_lookup+0x31>
  801966:	89 13                	mov    %edx,(%ebx)
  801968:	b8 00 00 00 00       	mov    $0x0,%eax
  80196d:	8d 76 00             	lea    0x0(%esi),%esi
  801970:	eb 35                	jmp    8019a7 <dev_lookup+0x66>
  801972:	83 c0 01             	add    $0x1,%eax
  801975:	8b 14 85 d4 2e 80 00 	mov    0x802ed4(,%eax,4),%edx
  80197c:	85 d2                	test   %edx,%edx
  80197e:	75 e2                	jne    801962 <dev_lookup+0x21>
  801980:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801985:	8b 40 4c             	mov    0x4c(%eax),%eax
  801988:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80198c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801990:	c7 04 24 58 2e 80 00 	movl   $0x802e58,(%esp)
  801997:	e8 f1 e8 ff ff       	call   80028d <cprintf>
  80199c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8019a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019a7:	83 c4 14             	add    $0x14,%esp
  8019aa:	5b                   	pop    %ebx
  8019ab:	5d                   	pop    %ebp
  8019ac:	c3                   	ret    

008019ad <fstat>:

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
  8019ad:	55                   	push   %ebp
  8019ae:	89 e5                	mov    %esp,%ebp
  8019b0:	53                   	push   %ebx
  8019b1:	83 ec 24             	sub    $0x24,%esp
  8019b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019b7:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8019ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019be:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c1:	89 04 24             	mov    %eax,(%esp)
  8019c4:	e8 05 ff ff ff       	call   8018ce <fd_lookup>
  8019c9:	89 c2                	mov    %eax,%edx
  8019cb:	85 c0                	test   %eax,%eax
  8019cd:	78 57                	js     801a26 <fstat+0x79>
  8019cf:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  8019d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d6:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8019d9:	8b 00                	mov    (%eax),%eax
  8019db:	89 04 24             	mov    %eax,(%esp)
  8019de:	e8 5e ff ff ff       	call   801941 <dev_lookup>
  8019e3:	89 c2                	mov    %eax,%edx
  8019e5:	85 c0                	test   %eax,%eax
  8019e7:	78 3d                	js     801a26 <fstat+0x79>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8019e9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  8019ee:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
  8019f1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019f5:	74 2f                	je     801a26 <fstat+0x79>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019f7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019fa:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a01:	00 00 00 
	stat->st_isdir = 0;
  801a04:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a0b:	00 00 00 
	stat->st_dev = dev;
  801a0e:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801a11:	89 93 88 00 00 00    	mov    %edx,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a17:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a1b:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801a1e:	89 04 24             	mov    %eax,(%esp)
  801a21:	ff 52 14             	call   *0x14(%edx)
  801a24:	89 c2                	mov    %eax,%edx
}
  801a26:	89 d0                	mov    %edx,%eax
  801a28:	83 c4 24             	add    $0x24,%esp
  801a2b:	5b                   	pop    %ebx
  801a2c:	5d                   	pop    %ebp
  801a2d:	c3                   	ret    

00801a2e <ftruncate>:
  801a2e:	55                   	push   %ebp
  801a2f:	89 e5                	mov    %esp,%ebp
  801a31:	53                   	push   %ebx
  801a32:	83 ec 24             	sub    $0x24,%esp
  801a35:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a38:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  801a3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a3f:	89 1c 24             	mov    %ebx,(%esp)
  801a42:	e8 87 fe ff ff       	call   8018ce <fd_lookup>
  801a47:	85 c0                	test   %eax,%eax
  801a49:	78 61                	js     801aac <ftruncate+0x7e>
  801a4b:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801a4e:	8b 10                	mov    (%eax),%edx
  801a50:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801a53:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a57:	89 14 24             	mov    %edx,(%esp)
  801a5a:	e8 e2 fe ff ff       	call   801941 <dev_lookup>
  801a5f:	85 c0                	test   %eax,%eax
  801a61:	78 49                	js     801aac <ftruncate+0x7e>
  801a63:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  801a66:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801a6a:	75 23                	jne    801a8f <ftruncate+0x61>
  801a6c:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801a71:	8b 40 4c             	mov    0x4c(%eax),%eax
  801a74:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a78:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a7c:	c7 04 24 78 2e 80 00 	movl   $0x802e78,(%esp)
  801a83:	e8 05 e8 ff ff       	call   80028d <cprintf>
  801a88:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a8d:	eb 1d                	jmp    801aac <ftruncate+0x7e>
  801a8f:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801a92:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a97:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  801a9b:	74 0f                	je     801aac <ftruncate+0x7e>
  801a9d:	8b 52 18             	mov    0x18(%edx),%edx
  801aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa7:	89 0c 24             	mov    %ecx,(%esp)
  801aaa:	ff d2                	call   *%edx
  801aac:	83 c4 24             	add    $0x24,%esp
  801aaf:	5b                   	pop    %ebx
  801ab0:	5d                   	pop    %ebp
  801ab1:	c3                   	ret    

00801ab2 <write>:
  801ab2:	55                   	push   %ebp
  801ab3:	89 e5                	mov    %esp,%ebp
  801ab5:	53                   	push   %ebx
  801ab6:	83 ec 24             	sub    $0x24,%esp
  801ab9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801abc:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  801abf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac3:	89 1c 24             	mov    %ebx,(%esp)
  801ac6:	e8 03 fe ff ff       	call   8018ce <fd_lookup>
  801acb:	85 c0                	test   %eax,%eax
  801acd:	78 68                	js     801b37 <write+0x85>
  801acf:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801ad2:	8b 10                	mov    (%eax),%edx
  801ad4:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801ad7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801adb:	89 14 24             	mov    %edx,(%esp)
  801ade:	e8 5e fe ff ff       	call   801941 <dev_lookup>
  801ae3:	85 c0                	test   %eax,%eax
  801ae5:	78 50                	js     801b37 <write+0x85>
  801ae7:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  801aea:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801aee:	75 23                	jne    801b13 <write+0x61>
  801af0:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801af5:	8b 40 4c             	mov    0x4c(%eax),%eax
  801af8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801afc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b00:	c7 04 24 99 2e 80 00 	movl   $0x802e99,(%esp)
  801b07:	e8 81 e7 ff ff       	call   80028d <cprintf>
  801b0c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b11:	eb 24                	jmp    801b37 <write+0x85>
  801b13:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801b16:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b1b:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  801b1f:	74 16                	je     801b37 <write+0x85>
  801b21:	8b 42 0c             	mov    0xc(%edx),%eax
  801b24:	8b 55 10             	mov    0x10(%ebp),%edx
  801b27:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b2e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b32:	89 0c 24             	mov    %ecx,(%esp)
  801b35:	ff d0                	call   *%eax
  801b37:	83 c4 24             	add    $0x24,%esp
  801b3a:	5b                   	pop    %ebx
  801b3b:	5d                   	pop    %ebp
  801b3c:	c3                   	ret    

00801b3d <read>:
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	53                   	push   %ebx
  801b41:	83 ec 24             	sub    $0x24,%esp
  801b44:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b47:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  801b4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b4e:	89 1c 24             	mov    %ebx,(%esp)
  801b51:	e8 78 fd ff ff       	call   8018ce <fd_lookup>
  801b56:	85 c0                	test   %eax,%eax
  801b58:	78 6d                	js     801bc7 <read+0x8a>
  801b5a:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801b5d:	8b 10                	mov    (%eax),%edx
  801b5f:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801b62:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b66:	89 14 24             	mov    %edx,(%esp)
  801b69:	e8 d3 fd ff ff       	call   801941 <dev_lookup>
  801b6e:	85 c0                	test   %eax,%eax
  801b70:	78 55                	js     801bc7 <read+0x8a>
  801b72:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  801b75:	8b 41 08             	mov    0x8(%ecx),%eax
  801b78:	83 e0 03             	and    $0x3,%eax
  801b7b:	83 f8 01             	cmp    $0x1,%eax
  801b7e:	75 23                	jne    801ba3 <read+0x66>
  801b80:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801b85:	8b 40 4c             	mov    0x4c(%eax),%eax
  801b88:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b90:	c7 04 24 b6 2e 80 00 	movl   $0x802eb6,(%esp)
  801b97:	e8 f1 e6 ff ff       	call   80028d <cprintf>
  801b9c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ba1:	eb 24                	jmp    801bc7 <read+0x8a>
  801ba3:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801ba6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801bab:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  801baf:	74 16                	je     801bc7 <read+0x8a>
  801bb1:	8b 42 08             	mov    0x8(%edx),%eax
  801bb4:	8b 55 10             	mov    0x10(%ebp),%edx
  801bb7:	89 54 24 08          	mov    %edx,0x8(%esp)
  801bbb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bbe:	89 54 24 04          	mov    %edx,0x4(%esp)
  801bc2:	89 0c 24             	mov    %ecx,(%esp)
  801bc5:	ff d0                	call   *%eax
  801bc7:	83 c4 24             	add    $0x24,%esp
  801bca:	5b                   	pop    %ebx
  801bcb:	5d                   	pop    %ebp
  801bcc:	c3                   	ret    

00801bcd <readn>:
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
  801bd0:	57                   	push   %edi
  801bd1:	56                   	push   %esi
  801bd2:	53                   	push   %ebx
  801bd3:	83 ec 0c             	sub    $0xc,%esp
  801bd6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801bd9:	8b 75 10             	mov    0x10(%ebp),%esi
  801bdc:	b8 00 00 00 00       	mov    $0x0,%eax
  801be1:	85 f6                	test   %esi,%esi
  801be3:	74 36                	je     801c1b <readn+0x4e>
  801be5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bea:	ba 00 00 00 00       	mov    $0x0,%edx
  801bef:	89 f0                	mov    %esi,%eax
  801bf1:	29 d0                	sub    %edx,%eax
  801bf3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bf7:	8d 04 17             	lea    (%edi,%edx,1),%eax
  801bfa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bfe:	8b 45 08             	mov    0x8(%ebp),%eax
  801c01:	89 04 24             	mov    %eax,(%esp)
  801c04:	e8 34 ff ff ff       	call   801b3d <read>
  801c09:	85 c0                	test   %eax,%eax
  801c0b:	78 0e                	js     801c1b <readn+0x4e>
  801c0d:	85 c0                	test   %eax,%eax
  801c0f:	74 08                	je     801c19 <readn+0x4c>
  801c11:	01 c3                	add    %eax,%ebx
  801c13:	89 da                	mov    %ebx,%edx
  801c15:	39 f3                	cmp    %esi,%ebx
  801c17:	72 d6                	jb     801bef <readn+0x22>
  801c19:	89 d8                	mov    %ebx,%eax
  801c1b:	83 c4 0c             	add    $0xc,%esp
  801c1e:	5b                   	pop    %ebx
  801c1f:	5e                   	pop    %esi
  801c20:	5f                   	pop    %edi
  801c21:	5d                   	pop    %ebp
  801c22:	c3                   	ret    

00801c23 <fd_close>:
  801c23:	55                   	push   %ebp
  801c24:	89 e5                	mov    %esp,%ebp
  801c26:	83 ec 28             	sub    $0x28,%esp
  801c29:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  801c2c:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  801c2f:	8b 75 08             	mov    0x8(%ebp),%esi
  801c32:	89 34 24             	mov    %esi,(%esp)
  801c35:	e8 16 fc ff ff       	call   801850 <fd2num>
  801c3a:	8d 55 f4             	lea    0xfffffff4(%ebp),%edx
  801c3d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c41:	89 04 24             	mov    %eax,(%esp)
  801c44:	e8 85 fc ff ff       	call   8018ce <fd_lookup>
  801c49:	89 c3                	mov    %eax,%ebx
  801c4b:	85 c0                	test   %eax,%eax
  801c4d:	78 05                	js     801c54 <fd_close+0x31>
  801c4f:	3b 75 f4             	cmp    0xfffffff4(%ebp),%esi
  801c52:	74 0e                	je     801c62 <fd_close+0x3f>
  801c54:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801c58:	75 45                	jne    801c9f <fd_close+0x7c>
  801c5a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c5f:	90                   	nop    
  801c60:	eb 3d                	jmp    801c9f <fd_close+0x7c>
  801c62:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  801c65:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c69:	8b 06                	mov    (%esi),%eax
  801c6b:	89 04 24             	mov    %eax,(%esp)
  801c6e:	e8 ce fc ff ff       	call   801941 <dev_lookup>
  801c73:	89 c3                	mov    %eax,%ebx
  801c75:	85 c0                	test   %eax,%eax
  801c77:	78 16                	js     801c8f <fd_close+0x6c>
  801c79:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  801c7c:	8b 40 10             	mov    0x10(%eax),%eax
  801c7f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c84:	85 c0                	test   %eax,%eax
  801c86:	74 07                	je     801c8f <fd_close+0x6c>
  801c88:	89 34 24             	mov    %esi,(%esp)
  801c8b:	ff d0                	call   *%eax
  801c8d:	89 c3                	mov    %eax,%ebx
  801c8f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c93:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c9a:	e8 df f2 ff ff       	call   800f7e <sys_page_unmap>
  801c9f:	89 d8                	mov    %ebx,%eax
  801ca1:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  801ca4:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  801ca7:	89 ec                	mov    %ebp,%esp
  801ca9:	5d                   	pop    %ebp
  801caa:	c3                   	ret    

00801cab <close>:
  801cab:	55                   	push   %ebp
  801cac:	89 e5                	mov    %esp,%ebp
  801cae:	83 ec 18             	sub    $0x18,%esp
  801cb1:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  801cb4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cb8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbb:	89 04 24             	mov    %eax,(%esp)
  801cbe:	e8 0b fc ff ff       	call   8018ce <fd_lookup>
  801cc3:	85 c0                	test   %eax,%eax
  801cc5:	78 13                	js     801cda <close+0x2f>
  801cc7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801cce:	00 
  801ccf:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  801cd2:	89 04 24             	mov    %eax,(%esp)
  801cd5:	e8 49 ff ff ff       	call   801c23 <fd_close>
  801cda:	c9                   	leave  
  801cdb:	c3                   	ret    

00801cdc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801cdc:	55                   	push   %ebp
  801cdd:	89 e5                	mov    %esp,%ebp
  801cdf:	83 ec 18             	sub    $0x18,%esp
  801ce2:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  801ce5:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801ce8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801cef:	00 
  801cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf3:	89 04 24             	mov    %eax,(%esp)
  801cf6:	e8 58 03 00 00       	call   802053 <open>
  801cfb:	89 c6                	mov    %eax,%esi
  801cfd:	85 c0                	test   %eax,%eax
  801cff:	78 1b                	js     801d1c <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801d01:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d04:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d08:	89 34 24             	mov    %esi,(%esp)
  801d0b:	e8 9d fc ff ff       	call   8019ad <fstat>
  801d10:	89 c3                	mov    %eax,%ebx
	close(fd);
  801d12:	89 34 24             	mov    %esi,(%esp)
  801d15:	e8 91 ff ff ff       	call   801cab <close>
  801d1a:	89 de                	mov    %ebx,%esi
	return r;
}
  801d1c:	89 f0                	mov    %esi,%eax
  801d1e:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  801d21:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  801d24:	89 ec                	mov    %ebp,%esp
  801d26:	5d                   	pop    %ebp
  801d27:	c3                   	ret    

00801d28 <dup>:
  801d28:	55                   	push   %ebp
  801d29:	89 e5                	mov    %esp,%ebp
  801d2b:	83 ec 38             	sub    $0x38,%esp
  801d2e:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  801d31:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  801d34:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  801d37:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d3a:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  801d3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d41:	8b 45 08             	mov    0x8(%ebp),%eax
  801d44:	89 04 24             	mov    %eax,(%esp)
  801d47:	e8 82 fb ff ff       	call   8018ce <fd_lookup>
  801d4c:	89 c3                	mov    %eax,%ebx
  801d4e:	85 c0                	test   %eax,%eax
  801d50:	0f 88 e1 00 00 00    	js     801e37 <dup+0x10f>
  801d56:	89 3c 24             	mov    %edi,(%esp)
  801d59:	e8 4d ff ff ff       	call   801cab <close>
  801d5e:	89 f8                	mov    %edi,%eax
  801d60:	c1 e0 0c             	shl    $0xc,%eax
  801d63:	8d b0 00 00 00 d0    	lea    0xd0000000(%eax),%esi
  801d69:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  801d6c:	89 04 24             	mov    %eax,(%esp)
  801d6f:	e8 ec fa ff ff       	call   801860 <fd2data>
  801d74:	89 c3                	mov    %eax,%ebx
  801d76:	89 34 24             	mov    %esi,(%esp)
  801d79:	e8 e2 fa ff ff       	call   801860 <fd2data>
  801d7e:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  801d81:	89 d8                	mov    %ebx,%eax
  801d83:	c1 e8 16             	shr    $0x16,%eax
  801d86:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  801d8d:	a8 01                	test   $0x1,%al
  801d8f:	74 45                	je     801dd6 <dup+0xae>
  801d91:	89 da                	mov    %ebx,%edx
  801d93:	c1 ea 0c             	shr    $0xc,%edx
  801d96:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  801d9d:	a8 01                	test   $0x1,%al
  801d9f:	74 35                	je     801dd6 <dup+0xae>
  801da1:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  801da8:	25 07 0e 00 00       	and    $0xe07,%eax
  801dad:	89 44 24 10          	mov    %eax,0x10(%esp)
  801db1:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  801db4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801db8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801dbf:	00 
  801dc0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dc4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dcb:	e8 0c f2 ff ff       	call   800fdc <sys_page_map>
  801dd0:	89 c3                	mov    %eax,%ebx
  801dd2:	85 c0                	test   %eax,%eax
  801dd4:	78 3e                	js     801e14 <dup+0xec>
  801dd6:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  801dd9:	89 d0                	mov    %edx,%eax
  801ddb:	c1 e8 0c             	shr    $0xc,%eax
  801dde:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  801de5:	25 07 0e 00 00       	and    $0xe07,%eax
  801dea:	89 44 24 10          	mov    %eax,0x10(%esp)
  801dee:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801df2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801df9:	00 
  801dfa:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dfe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e05:	e8 d2 f1 ff ff       	call   800fdc <sys_page_map>
  801e0a:	89 c3                	mov    %eax,%ebx
  801e0c:	85 c0                	test   %eax,%eax
  801e0e:	78 04                	js     801e14 <dup+0xec>
  801e10:	89 fb                	mov    %edi,%ebx
  801e12:	eb 23                	jmp    801e37 <dup+0x10f>
  801e14:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e18:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e1f:	e8 5a f1 ff ff       	call   800f7e <sys_page_unmap>
  801e24:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  801e27:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e2b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e32:	e8 47 f1 ff ff       	call   800f7e <sys_page_unmap>
  801e37:	89 d8                	mov    %ebx,%eax
  801e39:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801e3c:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801e3f:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801e42:	89 ec                	mov    %ebp,%esp
  801e44:	5d                   	pop    %ebp
  801e45:	c3                   	ret    

00801e46 <close_all>:
  801e46:	55                   	push   %ebp
  801e47:	89 e5                	mov    %esp,%ebp
  801e49:	53                   	push   %ebx
  801e4a:	83 ec 04             	sub    $0x4,%esp
  801e4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e52:	89 1c 24             	mov    %ebx,(%esp)
  801e55:	e8 51 fe ff ff       	call   801cab <close>
  801e5a:	83 c3 01             	add    $0x1,%ebx
  801e5d:	83 fb 20             	cmp    $0x20,%ebx
  801e60:	75 f0                	jne    801e52 <close_all+0xc>
  801e62:	83 c4 04             	add    $0x4,%esp
  801e65:	5b                   	pop    %ebx
  801e66:	5d                   	pop    %ebp
  801e67:	c3                   	ret    

00801e68 <fsipc>:
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801e68:	55                   	push   %ebp
  801e69:	89 e5                	mov    %esp,%ebp
  801e6b:	53                   	push   %ebx
  801e6c:	83 ec 14             	sub    $0x14,%esp
  801e6f:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801e71:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  801e77:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801e7e:	00 
  801e7f:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801e86:	00 
  801e87:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e8b:	89 14 24             	mov    %edx,(%esp)
  801e8e:	e8 1d f8 ff ff       	call   8016b0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801e93:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e9a:	00 
  801e9b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e9f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ea6:	e8 b9 f8 ff ff       	call   801764 <ipc_recv>
}
  801eab:	83 c4 14             	add    $0x14,%esp
  801eae:	5b                   	pop    %ebx
  801eaf:	5d                   	pop    %ebp
  801eb0:	c3                   	ret    

00801eb1 <sync>:

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
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801eb7:	ba 00 00 00 00       	mov    $0x0,%edx
  801ebc:	b8 08 00 00 00       	mov    $0x8,%eax
  801ec1:	e8 a2 ff ff ff       	call   801e68 <fsipc>
}
  801ec6:	c9                   	leave  
  801ec7:	c3                   	ret    

00801ec8 <devfile_trunc>:
  801ec8:	55                   	push   %ebp
  801ec9:	89 e5                	mov    %esp,%ebp
  801ecb:	83 ec 08             	sub    $0x8,%esp
  801ece:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed1:	8b 40 0c             	mov    0xc(%eax),%eax
  801ed4:	a3 00 30 80 00       	mov    %eax,0x803000
  801ed9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801edc:	a3 04 30 80 00       	mov    %eax,0x803004
  801ee1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ee6:	b8 02 00 00 00       	mov    $0x2,%eax
  801eeb:	e8 78 ff ff ff       	call   801e68 <fsipc>
  801ef0:	c9                   	leave  
  801ef1:	c3                   	ret    

00801ef2 <devfile_flush>:
  801ef2:	55                   	push   %ebp
  801ef3:	89 e5                	mov    %esp,%ebp
  801ef5:	83 ec 08             	sub    $0x8,%esp
  801ef8:	8b 45 08             	mov    0x8(%ebp),%eax
  801efb:	8b 40 0c             	mov    0xc(%eax),%eax
  801efe:	a3 00 30 80 00       	mov    %eax,0x803000
  801f03:	ba 00 00 00 00       	mov    $0x0,%edx
  801f08:	b8 06 00 00 00       	mov    $0x6,%eax
  801f0d:	e8 56 ff ff ff       	call   801e68 <fsipc>
  801f12:	c9                   	leave  
  801f13:	c3                   	ret    

00801f14 <devfile_stat>:
  801f14:	55                   	push   %ebp
  801f15:	89 e5                	mov    %esp,%ebp
  801f17:	53                   	push   %ebx
  801f18:	83 ec 14             	sub    $0x14,%esp
  801f1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f21:	8b 40 0c             	mov    0xc(%eax),%eax
  801f24:	a3 00 30 80 00       	mov    %eax,0x803000
  801f29:	ba 00 00 00 00       	mov    $0x0,%edx
  801f2e:	b8 05 00 00 00       	mov    $0x5,%eax
  801f33:	e8 30 ff ff ff       	call   801e68 <fsipc>
  801f38:	85 c0                	test   %eax,%eax
  801f3a:	78 2b                	js     801f67 <devfile_stat+0x53>
  801f3c:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801f43:	00 
  801f44:	89 1c 24             	mov    %ebx,(%esp)
  801f47:	e8 c5 e9 ff ff       	call   800911 <strcpy>
  801f4c:	a1 80 30 80 00       	mov    0x803080,%eax
  801f51:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  801f57:	a1 84 30 80 00       	mov    0x803084,%eax
  801f5c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801f62:	b8 00 00 00 00       	mov    $0x0,%eax
  801f67:	83 c4 14             	add    $0x14,%esp
  801f6a:	5b                   	pop    %ebx
  801f6b:	5d                   	pop    %ebp
  801f6c:	c3                   	ret    

00801f6d <devfile_write>:
  801f6d:	55                   	push   %ebp
  801f6e:	89 e5                	mov    %esp,%ebp
  801f70:	83 ec 18             	sub    $0x18,%esp
  801f73:	8b 55 10             	mov    0x10(%ebp),%edx
  801f76:	8b 45 08             	mov    0x8(%ebp),%eax
  801f79:	8b 40 0c             	mov    0xc(%eax),%eax
  801f7c:	a3 00 30 80 00       	mov    %eax,0x803000
  801f81:	89 d0                	mov    %edx,%eax
  801f83:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  801f89:	76 05                	jbe    801f90 <devfile_write+0x23>
  801f8b:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801f90:	89 15 04 30 80 00    	mov    %edx,0x803004
  801f96:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa1:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  801fa8:	e8 6d eb ff ff       	call   800b1a <memmove>
  801fad:	ba 00 00 00 00       	mov    $0x0,%edx
  801fb2:	b8 04 00 00 00       	mov    $0x4,%eax
  801fb7:	e8 ac fe ff ff       	call   801e68 <fsipc>
  801fbc:	c9                   	leave  
  801fbd:	c3                   	ret    

00801fbe <devfile_read>:
  801fbe:	55                   	push   %ebp
  801fbf:	89 e5                	mov    %esp,%ebp
  801fc1:	53                   	push   %ebx
  801fc2:	83 ec 14             	sub    $0x14,%esp
  801fc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc8:	8b 40 0c             	mov    0xc(%eax),%eax
  801fcb:	a3 00 30 80 00       	mov    %eax,0x803000
  801fd0:	8b 45 10             	mov    0x10(%ebp),%eax
  801fd3:	a3 04 30 80 00       	mov    %eax,0x803004
  801fd8:	ba 00 30 80 00       	mov    $0x803000,%edx
  801fdd:	b8 03 00 00 00       	mov    $0x3,%eax
  801fe2:	e8 81 fe ff ff       	call   801e68 <fsipc>
  801fe7:	89 c3                	mov    %eax,%ebx
  801fe9:	85 c0                	test   %eax,%eax
  801feb:	7e 17                	jle    802004 <devfile_read+0x46>
  801fed:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ff1:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801ff8:	00 
  801ff9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ffc:	89 04 24             	mov    %eax,(%esp)
  801fff:	e8 16 eb ff ff       	call   800b1a <memmove>
  802004:	89 d8                	mov    %ebx,%eax
  802006:	83 c4 14             	add    $0x14,%esp
  802009:	5b                   	pop    %ebx
  80200a:	5d                   	pop    %ebp
  80200b:	c3                   	ret    

0080200c <remove>:
  80200c:	55                   	push   %ebp
  80200d:	89 e5                	mov    %esp,%ebp
  80200f:	53                   	push   %ebx
  802010:	83 ec 14             	sub    $0x14,%esp
  802013:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802016:	89 1c 24             	mov    %ebx,(%esp)
  802019:	e8 a2 e8 ff ff       	call   8008c0 <strlen>
  80201e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  802023:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802028:	7f 21                	jg     80204b <remove+0x3f>
  80202a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80202e:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  802035:	e8 d7 e8 ff ff       	call   800911 <strcpy>
  80203a:	ba 00 00 00 00       	mov    $0x0,%edx
  80203f:	b8 07 00 00 00       	mov    $0x7,%eax
  802044:	e8 1f fe ff ff       	call   801e68 <fsipc>
  802049:	89 c2                	mov    %eax,%edx
  80204b:	89 d0                	mov    %edx,%eax
  80204d:	83 c4 14             	add    $0x14,%esp
  802050:	5b                   	pop    %ebx
  802051:	5d                   	pop    %ebp
  802052:	c3                   	ret    

00802053 <open>:
  802053:	55                   	push   %ebp
  802054:	89 e5                	mov    %esp,%ebp
  802056:	56                   	push   %esi
  802057:	53                   	push   %ebx
  802058:	83 ec 30             	sub    $0x30,%esp
  80205b:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80205e:	89 04 24             	mov    %eax,(%esp)
  802061:	e8 15 f8 ff ff       	call   80187b <fd_alloc>
  802066:	89 c3                	mov    %eax,%ebx
  802068:	85 c0                	test   %eax,%eax
  80206a:	79 18                	jns    802084 <open+0x31>
  80206c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802073:	00 
  802074:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  802077:	89 04 24             	mov    %eax,(%esp)
  80207a:	e8 a4 fb ff ff       	call   801c23 <fd_close>
  80207f:	e9 9f 00 00 00       	jmp    802123 <open+0xd0>
  802084:	8b 45 08             	mov    0x8(%ebp),%eax
  802087:	89 44 24 04          	mov    %eax,0x4(%esp)
  80208b:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  802092:	e8 7a e8 ff ff       	call   800911 <strcpy>
  802097:	8b 45 0c             	mov    0xc(%ebp),%eax
  80209a:	a3 00 34 80 00       	mov    %eax,0x803400
  80209f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8020a2:	89 04 24             	mov    %eax,(%esp)
  8020a5:	e8 b6 f7 ff ff       	call   801860 <fd2data>
  8020aa:	89 c6                	mov    %eax,%esi
  8020ac:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  8020af:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b4:	e8 af fd ff ff       	call   801e68 <fsipc>
  8020b9:	89 c3                	mov    %eax,%ebx
  8020bb:	85 c0                	test   %eax,%eax
  8020bd:	79 15                	jns    8020d4 <open+0x81>
  8020bf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8020c6:	00 
  8020c7:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8020ca:	89 04 24             	mov    %eax,(%esp)
  8020cd:	e8 51 fb ff ff       	call   801c23 <fd_close>
  8020d2:	eb 4f                	jmp    802123 <open+0xd0>
  8020d4:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8020db:	00 
  8020dc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8020e0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8020e7:	00 
  8020e8:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8020eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020f6:	e8 e1 ee ff ff       	call   800fdc <sys_page_map>
  8020fb:	89 c3                	mov    %eax,%ebx
  8020fd:	85 c0                	test   %eax,%eax
  8020ff:	79 15                	jns    802116 <open+0xc3>
  802101:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802108:	00 
  802109:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80210c:	89 04 24             	mov    %eax,(%esp)
  80210f:	e8 0f fb ff ff       	call   801c23 <fd_close>
  802114:	eb 0d                	jmp    802123 <open+0xd0>
  802116:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  802119:	89 04 24             	mov    %eax,(%esp)
  80211c:	e8 2f f7 ff ff       	call   801850 <fd2num>
  802121:	89 c3                	mov    %eax,%ebx
  802123:	89 d8                	mov    %ebx,%eax
  802125:	83 c4 30             	add    $0x30,%esp
  802128:	5b                   	pop    %ebx
  802129:	5e                   	pop    %esi
  80212a:	5d                   	pop    %ebp
  80212b:	c3                   	ret    
  80212c:	00 00                	add    %al,(%eax)
	...

00802130 <devsock_stat>:
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802130:	55                   	push   %ebp
  802131:	89 e5                	mov    %esp,%ebp
  802133:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  802136:	c7 44 24 04 e0 2e 80 	movl   $0x802ee0,0x4(%esp)
  80213d:	00 
  80213e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802141:	89 04 24             	mov    %eax,(%esp)
  802144:	e8 c8 e7 ff ff       	call   800911 <strcpy>
	return 0;
}
  802149:	b8 00 00 00 00       	mov    $0x0,%eax
  80214e:	c9                   	leave  
  80214f:	c3                   	ret    

00802150 <devsock_close>:
  802150:	55                   	push   %ebp
  802151:	89 e5                	mov    %esp,%ebp
  802153:	83 ec 08             	sub    $0x8,%esp
  802156:	8b 45 08             	mov    0x8(%ebp),%eax
  802159:	8b 40 0c             	mov    0xc(%eax),%eax
  80215c:	89 04 24             	mov    %eax,(%esp)
  80215f:	e8 be 02 00 00       	call   802422 <nsipc_close>
  802164:	c9                   	leave  
  802165:	c3                   	ret    

00802166 <devsock_write>:
  802166:	55                   	push   %ebp
  802167:	89 e5                	mov    %esp,%ebp
  802169:	83 ec 18             	sub    $0x18,%esp
  80216c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802173:	00 
  802174:	8b 45 10             	mov    0x10(%ebp),%eax
  802177:	89 44 24 08          	mov    %eax,0x8(%esp)
  80217b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80217e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802182:	8b 45 08             	mov    0x8(%ebp),%eax
  802185:	8b 40 0c             	mov    0xc(%eax),%eax
  802188:	89 04 24             	mov    %eax,(%esp)
  80218b:	e8 ce 02 00 00       	call   80245e <nsipc_send>
  802190:	c9                   	leave  
  802191:	c3                   	ret    

00802192 <devsock_read>:
  802192:	55                   	push   %ebp
  802193:	89 e5                	mov    %esp,%ebp
  802195:	83 ec 18             	sub    $0x18,%esp
  802198:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80219f:	00 
  8021a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8021a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b1:	8b 40 0c             	mov    0xc(%eax),%eax
  8021b4:	89 04 24             	mov    %eax,(%esp)
  8021b7:	e8 15 03 00 00       	call   8024d1 <nsipc_recv>
  8021bc:	c9                   	leave  
  8021bd:	c3                   	ret    

008021be <alloc_sockfd>:
  8021be:	55                   	push   %ebp
  8021bf:	89 e5                	mov    %esp,%ebp
  8021c1:	56                   	push   %esi
  8021c2:	53                   	push   %ebx
  8021c3:	83 ec 20             	sub    $0x20,%esp
  8021c6:	89 c6                	mov    %eax,%esi
  8021c8:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8021cb:	89 04 24             	mov    %eax,(%esp)
  8021ce:	e8 a8 f6 ff ff       	call   80187b <fd_alloc>
  8021d3:	89 c3                	mov    %eax,%ebx
  8021d5:	85 c0                	test   %eax,%eax
  8021d7:	78 21                	js     8021fa <alloc_sockfd+0x3c>
  8021d9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8021e0:	00 
  8021e1:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8021e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021ef:	e8 46 ee ff ff       	call   80103a <sys_page_alloc>
  8021f4:	89 c3                	mov    %eax,%ebx
  8021f6:	85 c0                	test   %eax,%eax
  8021f8:	79 0a                	jns    802204 <alloc_sockfd+0x46>
  8021fa:	89 34 24             	mov    %esi,(%esp)
  8021fd:	e8 20 02 00 00       	call   802422 <nsipc_close>
  802202:	eb 28                	jmp    80222c <alloc_sockfd+0x6e>
  802204:	8b 15 20 60 80 00    	mov    0x806020,%edx
  80220a:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80220d:	89 10                	mov    %edx,(%eax)
  80220f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  802212:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
  802219:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80221c:	89 70 0c             	mov    %esi,0xc(%eax)
  80221f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  802222:	89 04 24             	mov    %eax,(%esp)
  802225:	e8 26 f6 ff ff       	call   801850 <fd2num>
  80222a:	89 c3                	mov    %eax,%ebx
  80222c:	89 d8                	mov    %ebx,%eax
  80222e:	83 c4 20             	add    $0x20,%esp
  802231:	5b                   	pop    %ebx
  802232:	5e                   	pop    %esi
  802233:	5d                   	pop    %ebp
  802234:	c3                   	ret    

00802235 <socket>:

int
socket(int domain, int type, int protocol)
{
  802235:	55                   	push   %ebp
  802236:	89 e5                	mov    %esp,%ebp
  802238:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80223b:	8b 45 10             	mov    0x10(%ebp),%eax
  80223e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802242:	8b 45 0c             	mov    0xc(%ebp),%eax
  802245:	89 44 24 04          	mov    %eax,0x4(%esp)
  802249:	8b 45 08             	mov    0x8(%ebp),%eax
  80224c:	89 04 24             	mov    %eax,(%esp)
  80224f:	e8 82 01 00 00       	call   8023d6 <nsipc_socket>
  802254:	85 c0                	test   %eax,%eax
  802256:	78 05                	js     80225d <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802258:	e8 61 ff ff ff       	call   8021be <alloc_sockfd>
}
  80225d:	c9                   	leave  
  80225e:	66 90                	xchg   %ax,%ax
  802260:	c3                   	ret    

00802261 <fd2sockid>:
  802261:	55                   	push   %ebp
  802262:	89 e5                	mov    %esp,%ebp
  802264:	83 ec 18             	sub    $0x18,%esp
  802267:	8d 55 fc             	lea    0xfffffffc(%ebp),%edx
  80226a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80226e:	89 04 24             	mov    %eax,(%esp)
  802271:	e8 58 f6 ff ff       	call   8018ce <fd_lookup>
  802276:	89 c2                	mov    %eax,%edx
  802278:	85 c0                	test   %eax,%eax
  80227a:	78 15                	js     802291 <fd2sockid+0x30>
  80227c:	8b 4d fc             	mov    0xfffffffc(%ebp),%ecx
  80227f:	8b 01                	mov    (%ecx),%eax
  802281:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  802286:	3b 05 20 60 80 00    	cmp    0x806020,%eax
  80228c:	75 03                	jne    802291 <fd2sockid+0x30>
  80228e:	8b 51 0c             	mov    0xc(%ecx),%edx
  802291:	89 d0                	mov    %edx,%eax
  802293:	c9                   	leave  
  802294:	c3                   	ret    

00802295 <listen>:
  802295:	55                   	push   %ebp
  802296:	89 e5                	mov    %esp,%ebp
  802298:	83 ec 08             	sub    $0x8,%esp
  80229b:	8b 45 08             	mov    0x8(%ebp),%eax
  80229e:	e8 be ff ff ff       	call   802261 <fd2sockid>
  8022a3:	89 c2                	mov    %eax,%edx
  8022a5:	85 c0                	test   %eax,%eax
  8022a7:	78 11                	js     8022ba <listen+0x25>
  8022a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022b0:	89 14 24             	mov    %edx,(%esp)
  8022b3:	e8 48 01 00 00       	call   802400 <nsipc_listen>
  8022b8:	89 c2                	mov    %eax,%edx
  8022ba:	89 d0                	mov    %edx,%eax
  8022bc:	c9                   	leave  
  8022bd:	c3                   	ret    

008022be <connect>:
  8022be:	55                   	push   %ebp
  8022bf:	89 e5                	mov    %esp,%ebp
  8022c1:	83 ec 18             	sub    $0x18,%esp
  8022c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8022c7:	e8 95 ff ff ff       	call   802261 <fd2sockid>
  8022cc:	89 c2                	mov    %eax,%edx
  8022ce:	85 c0                	test   %eax,%eax
  8022d0:	78 18                	js     8022ea <connect+0x2c>
  8022d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8022d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022e0:	89 14 24             	mov    %edx,(%esp)
  8022e3:	e8 71 02 00 00       	call   802559 <nsipc_connect>
  8022e8:	89 c2                	mov    %eax,%edx
  8022ea:	89 d0                	mov    %edx,%eax
  8022ec:	c9                   	leave  
  8022ed:	c3                   	ret    

008022ee <shutdown>:
  8022ee:	55                   	push   %ebp
  8022ef:	89 e5                	mov    %esp,%ebp
  8022f1:	83 ec 08             	sub    $0x8,%esp
  8022f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f7:	e8 65 ff ff ff       	call   802261 <fd2sockid>
  8022fc:	89 c2                	mov    %eax,%edx
  8022fe:	85 c0                	test   %eax,%eax
  802300:	78 11                	js     802313 <shutdown+0x25>
  802302:	8b 45 0c             	mov    0xc(%ebp),%eax
  802305:	89 44 24 04          	mov    %eax,0x4(%esp)
  802309:	89 14 24             	mov    %edx,(%esp)
  80230c:	e8 2b 01 00 00       	call   80243c <nsipc_shutdown>
  802311:	89 c2                	mov    %eax,%edx
  802313:	89 d0                	mov    %edx,%eax
  802315:	c9                   	leave  
  802316:	c3                   	ret    

00802317 <bind>:
  802317:	55                   	push   %ebp
  802318:	89 e5                	mov    %esp,%ebp
  80231a:	83 ec 18             	sub    $0x18,%esp
  80231d:	8b 45 08             	mov    0x8(%ebp),%eax
  802320:	e8 3c ff ff ff       	call   802261 <fd2sockid>
  802325:	89 c2                	mov    %eax,%edx
  802327:	85 c0                	test   %eax,%eax
  802329:	78 18                	js     802343 <bind+0x2c>
  80232b:	8b 45 10             	mov    0x10(%ebp),%eax
  80232e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802332:	8b 45 0c             	mov    0xc(%ebp),%eax
  802335:	89 44 24 04          	mov    %eax,0x4(%esp)
  802339:	89 14 24             	mov    %edx,(%esp)
  80233c:	e8 57 02 00 00       	call   802598 <nsipc_bind>
  802341:	89 c2                	mov    %eax,%edx
  802343:	89 d0                	mov    %edx,%eax
  802345:	c9                   	leave  
  802346:	c3                   	ret    

00802347 <accept>:
  802347:	55                   	push   %ebp
  802348:	89 e5                	mov    %esp,%ebp
  80234a:	83 ec 18             	sub    $0x18,%esp
  80234d:	8b 45 08             	mov    0x8(%ebp),%eax
  802350:	e8 0c ff ff ff       	call   802261 <fd2sockid>
  802355:	89 c2                	mov    %eax,%edx
  802357:	85 c0                	test   %eax,%eax
  802359:	78 23                	js     80237e <accept+0x37>
  80235b:	8b 45 10             	mov    0x10(%ebp),%eax
  80235e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802362:	8b 45 0c             	mov    0xc(%ebp),%eax
  802365:	89 44 24 04          	mov    %eax,0x4(%esp)
  802369:	89 14 24             	mov    %edx,(%esp)
  80236c:	e8 66 02 00 00       	call   8025d7 <nsipc_accept>
  802371:	89 c2                	mov    %eax,%edx
  802373:	85 c0                	test   %eax,%eax
  802375:	78 07                	js     80237e <accept+0x37>
  802377:	e8 42 fe ff ff       	call   8021be <alloc_sockfd>
  80237c:	89 c2                	mov    %eax,%edx
  80237e:	89 d0                	mov    %edx,%eax
  802380:	c9                   	leave  
  802381:	c3                   	ret    
	...

00802390 <nsipc>:
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802390:	55                   	push   %ebp
  802391:	89 e5                	mov    %esp,%ebp
  802393:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802396:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  80239c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8023a3:	00 
  8023a4:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8023ab:	00 
  8023ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023b0:	89 14 24             	mov    %edx,(%esp)
  8023b3:	e8 f8 f2 ff ff       	call   8016b0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8023b8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8023bf:	00 
  8023c0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8023c7:	00 
  8023c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023cf:	e8 90 f3 ff ff       	call   801764 <ipc_recv>
}
  8023d4:	c9                   	leave  
  8023d5:	c3                   	ret    

008023d6 <nsipc_socket>:

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
  8023d6:	55                   	push   %ebp
  8023d7:	89 e5                	mov    %esp,%ebp
  8023d9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8023dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8023df:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.socket.req_type = type;
  8023e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023e7:	a3 04 50 80 00       	mov    %eax,0x805004
	nsipcbuf.socket.req_protocol = protocol;
  8023ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8023ef:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SOCKET);
  8023f4:	b8 09 00 00 00       	mov    $0x9,%eax
  8023f9:	e8 92 ff ff ff       	call   802390 <nsipc>
}
  8023fe:	c9                   	leave  
  8023ff:	c3                   	ret    

00802400 <nsipc_listen>:
  802400:	55                   	push   %ebp
  802401:	89 e5                	mov    %esp,%ebp
  802403:	83 ec 08             	sub    $0x8,%esp
  802406:	8b 45 08             	mov    0x8(%ebp),%eax
  802409:	a3 00 50 80 00       	mov    %eax,0x805000
  80240e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802411:	a3 04 50 80 00       	mov    %eax,0x805004
  802416:	b8 06 00 00 00       	mov    $0x6,%eax
  80241b:	e8 70 ff ff ff       	call   802390 <nsipc>
  802420:	c9                   	leave  
  802421:	c3                   	ret    

00802422 <nsipc_close>:
  802422:	55                   	push   %ebp
  802423:	89 e5                	mov    %esp,%ebp
  802425:	83 ec 08             	sub    $0x8,%esp
  802428:	8b 45 08             	mov    0x8(%ebp),%eax
  80242b:	a3 00 50 80 00       	mov    %eax,0x805000
  802430:	b8 04 00 00 00       	mov    $0x4,%eax
  802435:	e8 56 ff ff ff       	call   802390 <nsipc>
  80243a:	c9                   	leave  
  80243b:	c3                   	ret    

0080243c <nsipc_shutdown>:
  80243c:	55                   	push   %ebp
  80243d:	89 e5                	mov    %esp,%ebp
  80243f:	83 ec 08             	sub    $0x8,%esp
  802442:	8b 45 08             	mov    0x8(%ebp),%eax
  802445:	a3 00 50 80 00       	mov    %eax,0x805000
  80244a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80244d:	a3 04 50 80 00       	mov    %eax,0x805004
  802452:	b8 03 00 00 00       	mov    $0x3,%eax
  802457:	e8 34 ff ff ff       	call   802390 <nsipc>
  80245c:	c9                   	leave  
  80245d:	c3                   	ret    

0080245e <nsipc_send>:
  80245e:	55                   	push   %ebp
  80245f:	89 e5                	mov    %esp,%ebp
  802461:	53                   	push   %ebx
  802462:	83 ec 14             	sub    $0x14,%esp
  802465:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802468:	8b 45 08             	mov    0x8(%ebp),%eax
  80246b:	a3 00 50 80 00       	mov    %eax,0x805000
  802470:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802476:	7e 24                	jle    80249c <nsipc_send+0x3e>
  802478:	c7 44 24 0c ec 2e 80 	movl   $0x802eec,0xc(%esp)
  80247f:	00 
  802480:	c7 44 24 08 f8 2e 80 	movl   $0x802ef8,0x8(%esp)
  802487:	00 
  802488:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  80248f:	00 
  802490:	c7 04 24 0d 2f 80 00 	movl   $0x802f0d,(%esp)
  802497:	e8 24 dd ff ff       	call   8001c0 <_panic>
  80249c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024a7:	c7 04 24 0c 50 80 00 	movl   $0x80500c,(%esp)
  8024ae:	e8 67 e6 ff ff       	call   800b1a <memmove>
  8024b3:	89 1d 04 50 80 00    	mov    %ebx,0x805004
  8024b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8024bc:	a3 08 50 80 00       	mov    %eax,0x805008
  8024c1:	b8 08 00 00 00       	mov    $0x8,%eax
  8024c6:	e8 c5 fe ff ff       	call   802390 <nsipc>
  8024cb:	83 c4 14             	add    $0x14,%esp
  8024ce:	5b                   	pop    %ebx
  8024cf:	5d                   	pop    %ebp
  8024d0:	c3                   	ret    

008024d1 <nsipc_recv>:
  8024d1:	55                   	push   %ebp
  8024d2:	89 e5                	mov    %esp,%ebp
  8024d4:	83 ec 18             	sub    $0x18,%esp
  8024d7:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  8024da:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  8024dd:	8b 75 10             	mov    0x10(%ebp),%esi
  8024e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8024e3:	a3 00 50 80 00       	mov    %eax,0x805000
  8024e8:	89 35 04 50 80 00    	mov    %esi,0x805004
  8024ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8024f1:	a3 08 50 80 00       	mov    %eax,0x805008
  8024f6:	b8 07 00 00 00       	mov    $0x7,%eax
  8024fb:	e8 90 fe ff ff       	call   802390 <nsipc>
  802500:	89 c3                	mov    %eax,%ebx
  802502:	85 c0                	test   %eax,%eax
  802504:	78 47                	js     80254d <nsipc_recv+0x7c>
  802506:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80250b:	7f 05                	jg     802512 <nsipc_recv+0x41>
  80250d:	39 c6                	cmp    %eax,%esi
  80250f:	90                   	nop    
  802510:	7d 24                	jge    802536 <nsipc_recv+0x65>
  802512:	c7 44 24 0c 19 2f 80 	movl   $0x802f19,0xc(%esp)
  802519:	00 
  80251a:	c7 44 24 08 f8 2e 80 	movl   $0x802ef8,0x8(%esp)
  802521:	00 
  802522:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  802529:	00 
  80252a:	c7 04 24 0d 2f 80 00 	movl   $0x802f0d,(%esp)
  802531:	e8 8a dc ff ff       	call   8001c0 <_panic>
  802536:	89 44 24 08          	mov    %eax,0x8(%esp)
  80253a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  802541:	00 
  802542:	8b 45 0c             	mov    0xc(%ebp),%eax
  802545:	89 04 24             	mov    %eax,(%esp)
  802548:	e8 cd e5 ff ff       	call   800b1a <memmove>
  80254d:	89 d8                	mov    %ebx,%eax
  80254f:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  802552:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  802555:	89 ec                	mov    %ebp,%esp
  802557:	5d                   	pop    %ebp
  802558:	c3                   	ret    

00802559 <nsipc_connect>:
  802559:	55                   	push   %ebp
  80255a:	89 e5                	mov    %esp,%ebp
  80255c:	53                   	push   %ebx
  80255d:	83 ec 14             	sub    $0x14,%esp
  802560:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802563:	8b 45 08             	mov    0x8(%ebp),%eax
  802566:	a3 00 50 80 00       	mov    %eax,0x805000
  80256b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80256f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802572:	89 44 24 04          	mov    %eax,0x4(%esp)
  802576:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  80257d:	e8 98 e5 ff ff       	call   800b1a <memmove>
  802582:	89 1d 14 50 80 00    	mov    %ebx,0x805014
  802588:	b8 05 00 00 00       	mov    $0x5,%eax
  80258d:	e8 fe fd ff ff       	call   802390 <nsipc>
  802592:	83 c4 14             	add    $0x14,%esp
  802595:	5b                   	pop    %ebx
  802596:	5d                   	pop    %ebp
  802597:	c3                   	ret    

00802598 <nsipc_bind>:
  802598:	55                   	push   %ebp
  802599:	89 e5                	mov    %esp,%ebp
  80259b:	53                   	push   %ebx
  80259c:	83 ec 14             	sub    $0x14,%esp
  80259f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8025a5:	a3 00 50 80 00       	mov    %eax,0x805000
  8025aa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025b5:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  8025bc:	e8 59 e5 ff ff       	call   800b1a <memmove>
  8025c1:	89 1d 14 50 80 00    	mov    %ebx,0x805014
  8025c7:	b8 02 00 00 00       	mov    $0x2,%eax
  8025cc:	e8 bf fd ff ff       	call   802390 <nsipc>
  8025d1:	83 c4 14             	add    $0x14,%esp
  8025d4:	5b                   	pop    %ebx
  8025d5:	5d                   	pop    %ebp
  8025d6:	c3                   	ret    

008025d7 <nsipc_accept>:
  8025d7:	55                   	push   %ebp
  8025d8:	89 e5                	mov    %esp,%ebp
  8025da:	53                   	push   %ebx
  8025db:	83 ec 14             	sub    $0x14,%esp
  8025de:	8b 45 08             	mov    0x8(%ebp),%eax
  8025e1:	a3 00 50 80 00       	mov    %eax,0x805000
  8025e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025eb:	e8 a0 fd ff ff       	call   802390 <nsipc>
  8025f0:	89 c3                	mov    %eax,%ebx
  8025f2:	85 c0                	test   %eax,%eax
  8025f4:	78 27                	js     80261d <nsipc_accept+0x46>
  8025f6:	a1 10 50 80 00       	mov    0x805010,%eax
  8025fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025ff:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  802606:	00 
  802607:	8b 45 0c             	mov    0xc(%ebp),%eax
  80260a:	89 04 24             	mov    %eax,(%esp)
  80260d:	e8 08 e5 ff ff       	call   800b1a <memmove>
  802612:	8b 15 10 50 80 00    	mov    0x805010,%edx
  802618:	8b 45 10             	mov    0x10(%ebp),%eax
  80261b:	89 10                	mov    %edx,(%eax)
  80261d:	89 d8                	mov    %ebx,%eax
  80261f:	83 c4 14             	add    $0x14,%esp
  802622:	5b                   	pop    %ebx
  802623:	5d                   	pop    %ebp
  802624:	c3                   	ret    
  802625:	00 00                	add    %al,(%eax)
	...

00802628 <set_pgfault_handler>:
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802628:	55                   	push   %ebp
  802629:	89 e5                	mov    %esp,%ebp
  80262b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80262e:	83 3d 44 60 80 00 00 	cmpl   $0x0,0x806044
  802635:	75 6a                	jne    8026a1 <set_pgfault_handler+0x79>
		// First time through!
		// LAB 4: Your code here.
		env=(struct Env*)&envs[ENVX(sys_getenvid())];
  802637:	e8 91 ea ff ff       	call   8010cd <sys_getenvid>
  80263c:	25 ff 03 00 00       	and    $0x3ff,%eax
  802641:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802644:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802649:	a3 3c 60 80 00       	mov    %eax,0x80603c
		if((r=sys_page_alloc(env->env_id,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  80264e:	8b 40 4c             	mov    0x4c(%eax),%eax
  802651:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802658:	00 
  802659:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802660:	ee 
  802661:	89 04 24             	mov    %eax,(%esp)
  802664:	e8 d1 e9 ff ff       	call   80103a <sys_page_alloc>
  802669:	85 c0                	test   %eax,%eax
  80266b:	79 1c                	jns    802689 <set_pgfault_handler+0x61>
		{
			panic("Alloc a page for an exception stack failed");
  80266d:	c7 44 24 08 30 2f 80 	movl   $0x802f30,0x8(%esp)
  802674:	00 
  802675:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80267c:	00 
  80267d:	c7 04 24 5c 2f 80 00 	movl   $0x802f5c,(%esp)
  802684:	e8 37 db ff ff       	call   8001c0 <_panic>
		}
		sys_env_set_pgfault_upcall(env->env_id,(void*)_pgfault_upcall);
  802689:	a1 3c 60 80 00       	mov    0x80603c,%eax
  80268e:	8b 40 4c             	mov    0x4c(%eax),%eax
  802691:	c7 44 24 04 ac 26 80 	movl   $0x8026ac,0x4(%esp)
  802698:	00 
  802699:	89 04 24             	mov    %eax,(%esp)
  80269c:	e8 c3 e7 ff ff       	call   800e64 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8026a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8026a4:	a3 44 60 80 00       	mov    %eax,0x806044
}
  8026a9:	c9                   	leave  
  8026aa:	c3                   	ret    
	...

008026ac <_pgfault_upcall>:
.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8026ac:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8026ad:	a1 44 60 80 00       	mov    0x806044,%eax
	call *%eax
  8026b2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8026b4:	83 c4 04             	add    $0x4,%esp
	
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
  8026b7:	8b 44 24 28          	mov    0x28(%esp),%eax
	pushl %eax
  8026bb:	50                   	push   %eax
	movl %esp,%eax
  8026bc:	89 e0                	mov    %esp,%eax
	movl 0x34(%eax),%esp  //切换到用户普通栈，压入utf_eip
  8026be:	8b 60 34             	mov    0x34(%eax),%esp
	pushl (%eax)
  8026c1:	ff 30                	pushl  (%eax)
	movl %eax,%esp	     //切到用户异常栈
  8026c3:	89 c4                	mov    %eax,%esp
	subl $0x4,0x34(%esp) //将utf->utf_esp减去4,指向返回地址,后面不能算术操作，就在这算
  8026c5:	83 6c 24 34 04       	subl   $0x4,0x34(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0xc,%esp     //恢复通用寄存器
  8026ca:	83 c4 0c             	add    $0xc,%esp
	popal
  8026cd:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp  //恢复eflags
  8026ce:	83 c4 04             	add    $0x4,%esp
	popfl          //在用户态，该指令能否修改eflags?可以的
  8026d1:	9d                   	popf   
		       //执行完这个指令后，不能进行算术任何算术运算哦，否则eflags里面的值不对
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp     //切换到用户普通栈，用户从异常处理退出后，需要继续使用该栈
  8026d2:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8026d3:	c3                   	ret    
	...

008026e0 <__udivdi3>:
  8026e0:	55                   	push   %ebp
  8026e1:	89 e5                	mov    %esp,%ebp
  8026e3:	57                   	push   %edi
  8026e4:	56                   	push   %esi
  8026e5:	83 ec 1c             	sub    $0x1c,%esp
  8026e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8026eb:	8b 55 14             	mov    0x14(%ebp),%edx
  8026ee:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8026f1:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  8026f4:	89 c1                	mov    %eax,%ecx
  8026f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8026f9:	85 d2                	test   %edx,%edx
  8026fb:	89 d6                	mov    %edx,%esi
  8026fd:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
  802700:	75 1e                	jne    802720 <__udivdi3+0x40>
  802702:	39 f9                	cmp    %edi,%ecx
  802704:	0f 86 8d 00 00 00    	jbe    802797 <__udivdi3+0xb7>
  80270a:	89 fa                	mov    %edi,%edx
  80270c:	f7 f1                	div    %ecx
  80270e:	89 c1                	mov    %eax,%ecx
  802710:	89 c8                	mov    %ecx,%eax
  802712:	89 f2                	mov    %esi,%edx
  802714:	83 c4 1c             	add    $0x1c,%esp
  802717:	5e                   	pop    %esi
  802718:	5f                   	pop    %edi
  802719:	5d                   	pop    %ebp
  80271a:	c3                   	ret    
  80271b:	90                   	nop    
  80271c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802720:	39 fa                	cmp    %edi,%edx
  802722:	0f 87 98 00 00 00    	ja     8027c0 <__udivdi3+0xe0>
  802728:	0f bd c2             	bsr    %edx,%eax
  80272b:	83 f0 1f             	xor    $0x1f,%eax
  80272e:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  802731:	74 7f                	je     8027b2 <__udivdi3+0xd2>
  802733:	b8 20 00 00 00       	mov    $0x20,%eax
  802738:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  80273b:	2b 45 e4             	sub    0xffffffe4(%ebp),%eax
  80273e:	89 c1                	mov    %eax,%ecx
  802740:	d3 ea                	shr    %cl,%edx
  802742:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802746:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  802749:	89 f0                	mov    %esi,%eax
  80274b:	d3 e0                	shl    %cl,%eax
  80274d:	09 c2                	or     %eax,%edx
  80274f:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802752:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  802755:	89 fa                	mov    %edi,%edx
  802757:	d3 e0                	shl    %cl,%eax
  802759:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  80275d:	89 45 f4             	mov    %eax,0xfffffff4(%ebp)
  802760:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802763:	d3 e8                	shr    %cl,%eax
  802765:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802769:	d3 e2                	shl    %cl,%edx
  80276b:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  80276f:	09 d0                	or     %edx,%eax
  802771:	d3 ef                	shr    %cl,%edi
  802773:	89 fa                	mov    %edi,%edx
  802775:	f7 75 e0             	divl   0xffffffe0(%ebp)
  802778:	89 d1                	mov    %edx,%ecx
  80277a:	89 c7                	mov    %eax,%edi
  80277c:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80277f:	f7 e7                	mul    %edi
  802781:	39 d1                	cmp    %edx,%ecx
  802783:	89 c6                	mov    %eax,%esi
  802785:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  802788:	72 6f                	jb     8027f9 <__udivdi3+0x119>
  80278a:	39 ca                	cmp    %ecx,%edx
  80278c:	74 5e                	je     8027ec <__udivdi3+0x10c>
  80278e:	89 f9                	mov    %edi,%ecx
  802790:	31 f6                	xor    %esi,%esi
  802792:	e9 79 ff ff ff       	jmp    802710 <__udivdi3+0x30>
  802797:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80279a:	85 c0                	test   %eax,%eax
  80279c:	74 32                	je     8027d0 <__udivdi3+0xf0>
  80279e:	89 f2                	mov    %esi,%edx
  8027a0:	89 f8                	mov    %edi,%eax
  8027a2:	f7 f1                	div    %ecx
  8027a4:	89 c6                	mov    %eax,%esi
  8027a6:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8027a9:	f7 f1                	div    %ecx
  8027ab:	89 c1                	mov    %eax,%ecx
  8027ad:	e9 5e ff ff ff       	jmp    802710 <__udivdi3+0x30>
  8027b2:	39 d7                	cmp    %edx,%edi
  8027b4:	77 2a                	ja     8027e0 <__udivdi3+0x100>
  8027b6:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  8027b9:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
  8027bc:	73 22                	jae    8027e0 <__udivdi3+0x100>
  8027be:	66 90                	xchg   %ax,%ax
  8027c0:	31 c9                	xor    %ecx,%ecx
  8027c2:	31 f6                	xor    %esi,%esi
  8027c4:	e9 47 ff ff ff       	jmp    802710 <__udivdi3+0x30>
  8027c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  8027d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8027d5:	31 d2                	xor    %edx,%edx
  8027d7:	f7 75 f0             	divl   0xfffffff0(%ebp)
  8027da:	89 c1                	mov    %eax,%ecx
  8027dc:	eb c0                	jmp    80279e <__udivdi3+0xbe>
  8027de:	66 90                	xchg   %ax,%ax
  8027e0:	b9 01 00 00 00       	mov    $0x1,%ecx
  8027e5:	31 f6                	xor    %esi,%esi
  8027e7:	e9 24 ff ff ff       	jmp    802710 <__udivdi3+0x30>
  8027ec:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8027ef:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8027f3:	d3 e0                	shl    %cl,%eax
  8027f5:	39 c6                	cmp    %eax,%esi
  8027f7:	76 95                	jbe    80278e <__udivdi3+0xae>
  8027f9:	8d 4f ff             	lea    0xffffffff(%edi),%ecx
  8027fc:	31 f6                	xor    %esi,%esi
  8027fe:	e9 0d ff ff ff       	jmp    802710 <__udivdi3+0x30>
	...

00802810 <__umoddi3>:
  802810:	55                   	push   %ebp
  802811:	89 e5                	mov    %esp,%ebp
  802813:	57                   	push   %edi
  802814:	56                   	push   %esi
  802815:	83 ec 30             	sub    $0x30,%esp
  802818:	8b 55 14             	mov    0x14(%ebp),%edx
  80281b:	8b 45 10             	mov    0x10(%ebp),%eax
  80281e:	8b 75 08             	mov    0x8(%ebp),%esi
  802821:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802824:	85 d2                	test   %edx,%edx
  802826:	c7 45 d0 00 00 00 00 	movl   $0x0,0xffffffd0(%ebp)
  80282d:	89 c1                	mov    %eax,%ecx
  80282f:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  802836:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  802839:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  80283c:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  80283f:	89 7d e0             	mov    %edi,0xffffffe0(%ebp)
  802842:	75 1c                	jne    802860 <__umoddi3+0x50>
  802844:	39 f8                	cmp    %edi,%eax
  802846:	89 fa                	mov    %edi,%edx
  802848:	0f 86 d4 00 00 00    	jbe    802922 <__umoddi3+0x112>
  80284e:	89 f0                	mov    %esi,%eax
  802850:	f7 f1                	div    %ecx
  802852:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802855:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  80285c:	eb 12                	jmp    802870 <__umoddi3+0x60>
  80285e:	66 90                	xchg   %ax,%ax
  802860:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802863:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  802866:	76 18                	jbe    802880 <__umoddi3+0x70>
  802868:	89 75 d0             	mov    %esi,0xffffffd0(%ebp)
  80286b:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  80286e:	66 90                	xchg   %ax,%ax
  802870:	8b 45 d0             	mov    0xffffffd0(%ebp),%eax
  802873:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  802876:	83 c4 30             	add    $0x30,%esp
  802879:	5e                   	pop    %esi
  80287a:	5f                   	pop    %edi
  80287b:	5d                   	pop    %ebp
  80287c:	c3                   	ret    
  80287d:	8d 76 00             	lea    0x0(%esi),%esi
  802880:	0f bd 45 e8          	bsr    0xffffffe8(%ebp),%eax
  802884:	83 f0 1f             	xor    $0x1f,%eax
  802887:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  80288a:	0f 84 c0 00 00 00    	je     802950 <__umoddi3+0x140>
  802890:	b8 20 00 00 00       	mov    $0x20,%eax
  802895:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  802898:	2b 45 dc             	sub    0xffffffdc(%ebp),%eax
  80289b:	8b 7d ec             	mov    0xffffffec(%ebp),%edi
  80289e:	8b 75 f0             	mov    0xfffffff0(%ebp),%esi
  8028a1:	89 c1                	mov    %eax,%ecx
  8028a3:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8028a6:	d3 ea                	shr    %cl,%edx
  8028a8:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8028ab:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  8028af:	d3 e0                	shl    %cl,%eax
  8028b1:	09 c2                	or     %eax,%edx
  8028b3:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8028b6:	d3 e7                	shl    %cl,%edi
  8028b8:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8028bc:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  8028bf:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  8028c2:	d3 e8                	shr    %cl,%eax
  8028c4:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  8028c8:	d3 e2                	shl    %cl,%edx
  8028ca:	09 d0                	or     %edx,%eax
  8028cc:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  8028cf:	d3 e6                	shl    %cl,%esi
  8028d1:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8028d5:	d3 ea                	shr    %cl,%edx
  8028d7:	f7 75 f4             	divl   0xfffffff4(%ebp)
  8028da:	89 55 cc             	mov    %edx,0xffffffcc(%ebp)
  8028dd:	f7 e7                	mul    %edi
  8028df:	39 55 cc             	cmp    %edx,0xffffffcc(%ebp)
  8028e2:	0f 82 a5 00 00 00    	jb     80298d <__umoddi3+0x17d>
  8028e8:	3b 55 cc             	cmp    0xffffffcc(%ebp),%edx
  8028eb:	0f 84 94 00 00 00    	je     802985 <__umoddi3+0x175>
  8028f1:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
  8028f4:	29 c6                	sub    %eax,%esi
  8028f6:	19 d1                	sbb    %edx,%ecx
  8028f8:	89 4d cc             	mov    %ecx,0xffffffcc(%ebp)
  8028fb:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  8028ff:	89 f2                	mov    %esi,%edx
  802901:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  802904:	d3 ea                	shr    %cl,%edx
  802906:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  80290a:	d3 e0                	shl    %cl,%eax
  80290c:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  802910:	09 c2                	or     %eax,%edx
  802912:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  802915:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802918:	d3 e8                	shr    %cl,%eax
  80291a:	89 45 d4             	mov    %eax,0xffffffd4(%ebp)
  80291d:	e9 4e ff ff ff       	jmp    802870 <__umoddi3+0x60>
  802922:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  802925:	85 c0                	test   %eax,%eax
  802927:	74 17                	je     802940 <__umoddi3+0x130>
  802929:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  80292c:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
  80292f:	f7 f1                	div    %ecx
  802931:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802934:	f7 f1                	div    %ecx
  802936:	e9 17 ff ff ff       	jmp    802852 <__umoddi3+0x42>
  80293b:	90                   	nop    
  80293c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802940:	b8 01 00 00 00       	mov    $0x1,%eax
  802945:	31 d2                	xor    %edx,%edx
  802947:	f7 75 ec             	divl   0xffffffec(%ebp)
  80294a:	89 c1                	mov    %eax,%ecx
  80294c:	eb db                	jmp    802929 <__umoddi3+0x119>
  80294e:	66 90                	xchg   %ax,%ax
  802950:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802953:	39 45 e0             	cmp    %eax,0xffffffe0(%ebp)
  802956:	77 19                	ja     802971 <__umoddi3+0x161>
  802958:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  80295b:	39 55 f0             	cmp    %edx,0xfffffff0(%ebp)
  80295e:	73 11                	jae    802971 <__umoddi3+0x161>
  802960:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  802963:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802966:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802969:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  80296c:	e9 ff fe ff ff       	jmp    802870 <__umoddi3+0x60>
  802971:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802974:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802977:	2b 45 ec             	sub    0xffffffec(%ebp),%eax
  80297a:	1b 4d e8             	sbb    0xffffffe8(%ebp),%ecx
  80297d:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  802980:	89 4d e0             	mov    %ecx,0xffffffe0(%ebp)
  802983:	eb db                	jmp    802960 <__umoddi3+0x150>
  802985:	39 f0                	cmp    %esi,%eax
  802987:	0f 86 64 ff ff ff    	jbe    8028f1 <__umoddi3+0xe1>
  80298d:	29 f8                	sub    %edi,%eax
  80298f:	1b 55 f4             	sbb    0xfffffff4(%ebp),%edx
  802992:	e9 5a ff ff ff       	jmp    8028f1 <__umoddi3+0xe1>
