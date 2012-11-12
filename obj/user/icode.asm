
obj/user/icode:     file format elf32-i386

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
  80003f:	c7 05 00 60 80 00 20 	movl   $0x802920,0x806000
  800046:	29 80 00 

	cprintf("icode startup\n");
  800049:	c7 04 24 26 29 80 00 	movl   $0x802926,(%esp)
  800050:	e8 4c 02 00 00       	call   8002a1 <cprintf>

	cprintf("icode: open /motd\n");
  800055:	c7 04 24 35 29 80 00 	movl   $0x802935,(%esp)
  80005c:	e8 40 02 00 00       	call   8002a1 <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  800061:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800068:	00 
  800069:	c7 04 24 48 29 80 00 	movl   $0x802948,(%esp)
  800070:	e8 ea 18 00 00       	call   80195f <open>
  800075:	89 c3                	mov    %eax,%ebx
  800077:	85 c0                	test   %eax,%eax
  800079:	79 20                	jns    80009b <umain+0x67>
		panic("icode: open /motd: %e", fd);
  80007b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80007f:	c7 44 24 08 4e 29 80 	movl   $0x80294e,0x8(%esp)
  800086:	00 
  800087:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008e:	00 
  80008f:	c7 04 24 64 29 80 00 	movl   $0x802964,(%esp)
  800096:	e8 39 01 00 00       	call   8001d4 <_panic>

	cprintf("icode: read /motd\n");
  80009b:	c7 04 24 71 29 80 00 	movl   $0x802971,(%esp)
  8000a2:	e8 fa 01 00 00       	call   8002a1 <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000a7:	8d b5 f7 fd ff ff    	lea    -0x209(%ebp),%esi
  8000ad:	eb 0c                	jmp    8000bb <umain+0x87>
		sys_cputs(buf, n);
  8000af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b3:	89 34 24             	mov    %esi,(%esp)
  8000b6:	e8 ad 0c 00 00       	call   800d68 <sys_cputs>
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000bb:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8000c2:	00 
  8000c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000c7:	89 1c 24             	mov    %ebx,(%esp)
  8000ca:	e8 79 13 00 00       	call   801448 <read>
  8000cf:	85 c0                	test   %eax,%eax
  8000d1:	7f dc                	jg     8000af <umain+0x7b>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000d3:	c7 04 24 84 29 80 00 	movl   $0x802984,(%esp)
  8000da:	e8 c2 01 00 00       	call   8002a1 <cprintf>
	close(fd);
  8000df:	89 1c 24             	mov    %ebx,(%esp)
  8000e2:	e8 ce 14 00 00       	call   8015b5 <close>

	cprintf("icode: spawn /init\n");
  8000e7:	c7 04 24 98 29 80 00 	movl   $0x802998,(%esp)
  8000ee:	e8 ae 01 00 00       	call   8002a1 <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000f3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8000fa:	00 
  8000fb:	c7 44 24 0c ac 29 80 	movl   $0x8029ac,0xc(%esp)
  800102:	00 
  800103:	c7 44 24 08 b5 29 80 	movl   $0x8029b5,0x8(%esp)
  80010a:	00 
  80010b:	c7 44 24 04 bf 29 80 	movl   $0x8029bf,0x4(%esp)
  800112:	00 
  800113:	c7 04 24 be 29 80 00 	movl   $0x8029be,(%esp)
  80011a:	e8 bb 1e 00 00       	call   801fda <spawnl>
  80011f:	85 c0                	test   %eax,%eax
  800121:	79 20                	jns    800143 <umain+0x10f>
		panic("icode: spawn /init: %e", r);
  800123:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800127:	c7 44 24 08 c4 29 80 	movl   $0x8029c4,0x8(%esp)
  80012e:	00 
  80012f:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800136:	00 
  800137:	c7 04 24 64 29 80 00 	movl   $0x802964,(%esp)
  80013e:	e8 91 00 00 00       	call   8001d4 <_panic>

	cprintf("icode: exiting\n");
  800143:	c7 04 24 db 29 80 00 	movl   $0x8029db,(%esp)
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
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	83 ec 18             	sub    $0x18,%esp
  800162:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800165:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800168:	8b 75 08             	mov    0x8(%ebp),%esi
  80016b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  80016e:	c7 05 3c 60 80 00 00 	movl   $0x0,0x80603c
  800175:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  800178:	e8 50 0f 00 00       	call   8010cd <sys_getenvid>
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

	// call user main routine
	umain(argc, argv);
  80019a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80019e:	89 34 24             	mov    %esi,(%esp)
  8001a1:	e8 8e fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8001a6:	e8 0d 00 00 00       	call   8001b8 <exit>
}
  8001ab:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8001ae:	8b 75 fc             	mov    -0x4(%ebp),%esi
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
  8001be:	e8 8d 15 00 00       	call   801750 <close_all>
	sys_env_destroy(0);
  8001c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ca:	e8 32 0f 00 00       	call   801101 <sys_env_destroy>
}
  8001cf:	c9                   	leave  
  8001d0:	c3                   	ret    
  8001d1:	00 00                	add    %al,(%eax)
	...

008001d4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
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
  8001dd:	89 45 fc             	mov    %eax,-0x4(%ebp)

	// Print the panic message
	if (argv0)
  8001e0:	a1 40 60 80 00       	mov    0x806040,%eax
  8001e5:	85 c0                	test   %eax,%eax
  8001e7:	74 10                	je     8001f9 <_panic+0x25>
		cprintf("%s: ", argv0);
  8001e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ed:	c7 04 24 02 2a 80 00 	movl   $0x802a02,(%esp)
  8001f4:	e8 a8 00 00 00       	call   8002a1 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8001f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800200:	8b 45 08             	mov    0x8(%ebp),%eax
  800203:	89 44 24 08          	mov    %eax,0x8(%esp)
  800207:	a1 00 60 80 00       	mov    0x806000,%eax
  80020c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800210:	c7 04 24 07 2a 80 00 	movl   $0x802a07,(%esp)
  800217:	e8 85 00 00 00       	call   8002a1 <cprintf>
	vcprintf(fmt, ap);
  80021c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80021f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800223:	8b 45 10             	mov    0x10(%ebp),%eax
  800226:	89 04 24             	mov    %eax,(%esp)
  800229:	e8 12 00 00 00       	call   800240 <vcprintf>
	cprintf("\n");
  80022e:	c7 04 24 03 2f 80 00 	movl   $0x802f03,(%esp)
  800235:	e8 67 00 00 00       	call   8002a1 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80023a:	cc                   	int3   
  80023b:	eb fd                	jmp    80023a <_panic+0x66>
  80023d:	00 00                	add    %al,(%eax)
	...

00800240 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800249:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  800250:	00 00 00 
	b.cnt = 0;
  800253:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  80025a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80025d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800260:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800264:	8b 45 08             	mov    0x8(%ebp),%eax
  800267:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800271:	89 44 24 04          	mov    %eax,0x4(%esp)
  800275:	c7 04 24 be 02 80 00 	movl   $0x8002be,(%esp)
  80027c:	e8 c4 01 00 00       	call   800445 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800281:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
  800287:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028b:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  800291:	89 04 24             	mov    %eax,(%esp)
  800294:	e8 cf 0a 00 00       	call   800d68 <sys_cputs>
  800299:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

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
  8002aa:	89 45 fc             	mov    %eax,-0x4(%ebp)
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
};


static void
putch(int ch, struct printbuf *b)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	53                   	push   %ebx
  8002c2:	83 ec 14             	sub    $0x14,%esp
  8002c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002c8:	8b 03                	mov    (%ebx),%eax
  8002ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cd:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002d1:	83 c0 01             	add    $0x1,%eax
  8002d4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002db:	75 19                	jne    8002f6 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8002dd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002e4:	00 
  8002e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8002e8:	89 04 24             	mov    %eax,(%esp)
  8002eb:	e8 78 0a 00 00       	call   800d68 <sys_cputs>
		b->idx = 0;
  8002f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002f6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002fa:	83 c4 14             	add    $0x14,%esp
  8002fd:	5b                   	pop    %ebx
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    

00800300 <printnum>:
 * using specified putch function and associated pointer putdat.
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
  800309:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80030c:	89 d7                	mov    %edx,%edi
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	8b 55 0c             	mov    0xc(%ebp),%edx
  800314:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800317:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80031a:	8b 55 10             	mov    0x10(%ebp),%edx
  80031d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800320:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800323:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  80032a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80032d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  800330:	72 14                	jb     800346 <printnum+0x46>
  800332:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800335:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800338:	76 0c                	jbe    800346 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80033d:	83 eb 01             	sub    $0x1,%ebx
  800340:	85 db                	test   %ebx,%ebx
  800342:	7f 57                	jg     80039b <printnum+0x9b>
  800344:	eb 64                	jmp    8003aa <printnum+0xaa>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800346:	89 74 24 10          	mov    %esi,0x10(%esp)
  80034a:	8b 45 14             	mov    0x14(%ebp),%eax
  80034d:	83 e8 01             	sub    $0x1,%eax
  800350:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800354:	89 54 24 08          	mov    %edx,0x8(%esp)
  800358:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80035c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800360:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800363:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800366:	89 44 24 08          	mov    %eax,0x8(%esp)
  80036a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80036e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800371:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800374:	89 04 24             	mov    %eax,(%esp)
  800377:	89 54 24 04          	mov    %edx,0x4(%esp)
  80037b:	e8 f0 22 00 00       	call   802670 <__udivdi3>
  800380:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800384:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800388:	89 04 24             	mov    %eax,(%esp)
  80038b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80038f:	89 fa                	mov    %edi,%edx
  800391:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800394:	e8 67 ff ff ff       	call   800300 <printnum>
  800399:	eb 0f                	jmp    8003aa <printnum+0xaa>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80039b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80039f:	89 34 24             	mov    %esi,(%esp)
  8003a2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a5:	83 eb 01             	sub    $0x1,%ebx
  8003a8:	75 f1                	jne    80039b <printnum+0x9b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003ae:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8003b5:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8003b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003bc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003c3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8003c6:	89 04 24             	mov    %eax,(%esp)
  8003c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003cd:	e8 ce 23 00 00       	call   8027a0 <__umoddi3>
  8003d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003d6:	0f be 80 23 2a 80 00 	movsbl 0x802a23(%eax),%eax
  8003dd:	89 04 24             	mov    %eax,(%esp)
  8003e0:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003e3:	83 c4 3c             	add    $0x3c,%esp
  8003e6:	5b                   	pop    %ebx
  8003e7:	5e                   	pop    %esi
  8003e8:	5f                   	pop    %edi
  8003e9:	5d                   	pop    %ebp
  8003ea:	c3                   	ret    

008003eb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003eb:	55                   	push   %ebp
  8003ec:	89 e5                	mov    %esp,%ebp
  8003ee:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8003f0:	83 fa 01             	cmp    $0x1,%edx
  8003f3:	7e 0e                	jle    800403 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8003f5:	8b 10                	mov    (%eax),%edx
  8003f7:	8d 42 08             	lea    0x8(%edx),%eax
  8003fa:	89 01                	mov    %eax,(%ecx)
  8003fc:	8b 02                	mov    (%edx),%eax
  8003fe:	8b 52 04             	mov    0x4(%edx),%edx
  800401:	eb 22                	jmp    800425 <getuint+0x3a>
	else if (lflag)
  800403:	85 d2                	test   %edx,%edx
  800405:	74 10                	je     800417 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800407:	8b 10                	mov    (%eax),%edx
  800409:	8d 42 04             	lea    0x4(%edx),%eax
  80040c:	89 01                	mov    %eax,(%ecx)
  80040e:	8b 02                	mov    (%edx),%eax
  800410:	ba 00 00 00 00       	mov    $0x0,%edx
  800415:	eb 0e                	jmp    800425 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800417:	8b 10                	mov    (%eax),%edx
  800419:	8d 42 04             	lea    0x4(%edx),%eax
  80041c:	89 01                	mov    %eax,(%ecx)
  80041e:	8b 02                	mov    (%edx),%eax
  800420:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800425:	5d                   	pop    %ebp
  800426:	c3                   	ret    

00800427 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  80042d:	83 42 08 01          	addl   $0x1,0x8(%edx)
	if (b->buf < b->ebuf)
  800431:	8b 02                	mov    (%edx),%eax
  800433:	3b 42 04             	cmp    0x4(%edx),%eax
  800436:	73 0b                	jae    800443 <sprintputch+0x1c>
		*b->buf++ = ch;
  800438:	0f b6 4d 08          	movzbl 0x8(%ebp),%ecx
  80043c:	88 08                	mov    %cl,(%eax)
  80043e:	83 c0 01             	add    $0x1,%eax
  800441:	89 02                	mov    %eax,(%edx)
}
  800443:	5d                   	pop    %ebp
  800444:	c3                   	ret    

00800445 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800445:	55                   	push   %ebp
  800446:	89 e5                	mov    %esp,%ebp
  800448:	57                   	push   %edi
  800449:	56                   	push   %esi
  80044a:	53                   	push   %ebx
  80044b:	83 ec 3c             	sub    $0x3c,%esp
  80044e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800451:	eb 18                	jmp    80046b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800453:	84 c0                	test   %al,%al
  800455:	0f 84 9f 03 00 00    	je     8007fa <vprintfmt+0x3b5>
				return;
			putch(ch, putdat);
  80045b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80045e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800462:	0f b6 c0             	movzbl %al,%eax
  800465:	89 04 24             	mov    %eax,(%esp)
  800468:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80046b:	0f b6 03             	movzbl (%ebx),%eax
  80046e:	83 c3 01             	add    $0x1,%ebx
  800471:	3c 25                	cmp    $0x25,%al
  800473:	75 de                	jne    800453 <vprintfmt+0xe>
  800475:	b9 00 00 00 00       	mov    $0x0,%ecx
  80047a:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
  800481:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800486:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80048d:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
  800491:	eb 07                	jmp    80049a <vprintfmt+0x55>
  800493:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049a:	0f b6 13             	movzbl (%ebx),%edx
  80049d:	83 c3 01             	add    $0x1,%ebx
  8004a0:	8d 42 dd             	lea    -0x23(%edx),%eax
  8004a3:	3c 55                	cmp    $0x55,%al
  8004a5:	0f 87 22 03 00 00    	ja     8007cd <vprintfmt+0x388>
  8004ab:	0f b6 c0             	movzbl %al,%eax
  8004ae:	ff 24 85 60 2b 80 00 	jmp    *0x802b60(,%eax,4)
  8004b5:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
  8004b9:	eb df                	jmp    80049a <vprintfmt+0x55>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004bb:	0f b6 c2             	movzbl %dl,%eax
  8004be:	8d 78 d0             	lea    -0x30(%eax),%edi
				ch = *fmt;
  8004c1:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  8004c4:	8d 42 d0             	lea    -0x30(%edx),%eax
  8004c7:	83 f8 09             	cmp    $0x9,%eax
  8004ca:	76 08                	jbe    8004d4 <vprintfmt+0x8f>
  8004cc:	eb 39                	jmp    800507 <vprintfmt+0xc2>
  8004ce:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
  8004d2:	eb c6                	jmp    80049a <vprintfmt+0x55>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004d4:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  8004d7:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  8004da:	8d 7c 42 d0          	lea    -0x30(%edx,%eax,2),%edi
				ch = *fmt;
  8004de:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  8004e1:	8d 42 d0             	lea    -0x30(%edx),%eax
  8004e4:	83 f8 09             	cmp    $0x9,%eax
  8004e7:	77 1e                	ja     800507 <vprintfmt+0xc2>
  8004e9:	eb e9                	jmp    8004d4 <vprintfmt+0x8f>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004eb:	8b 55 14             	mov    0x14(%ebp),%edx
  8004ee:	8d 42 04             	lea    0x4(%edx),%eax
  8004f1:	89 45 14             	mov    %eax,0x14(%ebp)
  8004f4:	8b 3a                	mov    (%edx),%edi
  8004f6:	eb 0f                	jmp    800507 <vprintfmt+0xc2>
			goto process_precision;

		case '.':
			if (width < 0)
  8004f8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8004fc:	79 9c                	jns    80049a <vprintfmt+0x55>
  8004fe:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800505:	eb 93                	jmp    80049a <vprintfmt+0x55>
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800507:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80050b:	90                   	nop    
  80050c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800510:	79 88                	jns    80049a <vprintfmt+0x55>
  800512:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800515:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80051a:	e9 7b ff ff ff       	jmp    80049a <vprintfmt+0x55>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80051f:	83 c1 01             	add    $0x1,%ecx
  800522:	e9 73 ff ff ff       	jmp    80049a <vprintfmt+0x55>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800527:	8b 45 14             	mov    0x14(%ebp),%eax
  80052a:	8d 50 04             	lea    0x4(%eax),%edx
  80052d:	89 55 14             	mov    %edx,0x14(%ebp)
  800530:	8b 55 0c             	mov    0xc(%ebp),%edx
  800533:	89 54 24 04          	mov    %edx,0x4(%esp)
  800537:	8b 00                	mov    (%eax),%eax
  800539:	89 04 24             	mov    %eax,(%esp)
  80053c:	ff 55 08             	call   *0x8(%ebp)
  80053f:	e9 27 ff ff ff       	jmp    80046b <vprintfmt+0x26>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800544:	8b 55 14             	mov    0x14(%ebp),%edx
  800547:	8d 42 04             	lea    0x4(%edx),%eax
  80054a:	89 45 14             	mov    %eax,0x14(%ebp)
  80054d:	8b 02                	mov    (%edx),%eax
  80054f:	89 c2                	mov    %eax,%edx
  800551:	c1 fa 1f             	sar    $0x1f,%edx
  800554:	31 d0                	xor    %edx,%eax
  800556:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800558:	83 f8 0f             	cmp    $0xf,%eax
  80055b:	7f 0b                	jg     800568 <vprintfmt+0x123>
  80055d:	8b 14 85 c0 2c 80 00 	mov    0x802cc0(,%eax,4),%edx
  800564:	85 d2                	test   %edx,%edx
  800566:	75 23                	jne    80058b <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800568:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80056c:	c7 44 24 08 34 2a 80 	movl   $0x802a34,0x8(%esp)
  800573:	00 
  800574:	8b 45 0c             	mov    0xc(%ebp),%eax
  800577:	89 44 24 04          	mov    %eax,0x4(%esp)
  80057b:	8b 55 08             	mov    0x8(%ebp),%edx
  80057e:	89 14 24             	mov    %edx,(%esp)
  800581:	e8 ff 02 00 00       	call   800885 <printfmt>
  800586:	e9 e0 fe ff ff       	jmp    80046b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80058b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80058f:	c7 44 24 08 00 2e 80 	movl   $0x802e00,0x8(%esp)
  800596:	00 
  800597:	8b 45 0c             	mov    0xc(%ebp),%eax
  80059a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059e:	8b 55 08             	mov    0x8(%ebp),%edx
  8005a1:	89 14 24             	mov    %edx,(%esp)
  8005a4:	e8 dc 02 00 00       	call   800885 <printfmt>
  8005a9:	e9 bd fe ff ff       	jmp    80046b <vprintfmt+0x26>
  8005ae:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8005b1:	89 f9                	mov    %edi,%ecx
  8005b3:	89 5d ec             	mov    %ebx,-0x14(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b6:	8b 55 14             	mov    0x14(%ebp),%edx
  8005b9:	8d 42 04             	lea    0x4(%edx),%eax
  8005bc:	89 45 14             	mov    %eax,0x14(%ebp)
  8005bf:	8b 12                	mov    (%edx),%edx
  8005c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c4:	85 d2                	test   %edx,%edx
  8005c6:	75 07                	jne    8005cf <vprintfmt+0x18a>
  8005c8:	c7 45 dc 3d 2a 80 00 	movl   $0x802a3d,-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8005cf:	85 f6                	test   %esi,%esi
  8005d1:	7e 41                	jle    800614 <vprintfmt+0x1cf>
  8005d3:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  8005d7:	74 3b                	je     800614 <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005e0:	89 04 24             	mov    %eax,(%esp)
  8005e3:	e8 e8 02 00 00       	call   8008d0 <strnlen>
  8005e8:	29 c6                	sub    %eax,%esi
  8005ea:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8005ed:	85 f6                	test   %esi,%esi
  8005ef:	7e 23                	jle    800614 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005f1:	0f be 55 eb          	movsbl -0x15(%ebp),%edx
  8005f5:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ff:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800602:	89 14 24             	mov    %edx,(%esp)
  800605:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800608:	83 ee 01             	sub    $0x1,%esi
  80060b:	75 eb                	jne    8005f8 <vprintfmt+0x1b3>
  80060d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800614:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800617:	0f b6 02             	movzbl (%edx),%eax
  80061a:	0f be d0             	movsbl %al,%edx
  80061d:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800620:	84 c0                	test   %al,%al
  800622:	75 42                	jne    800666 <vprintfmt+0x221>
  800624:	eb 49                	jmp    80066f <vprintfmt+0x22a>
				if (altflag && (ch < ' ' || ch > '~'))
  800626:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80062a:	74 1b                	je     800647 <vprintfmt+0x202>
  80062c:	8d 42 e0             	lea    -0x20(%edx),%eax
  80062f:	83 f8 5e             	cmp    $0x5e,%eax
  800632:	76 13                	jbe    800647 <vprintfmt+0x202>
					putch('?', putdat);
  800634:	8b 45 0c             	mov    0xc(%ebp),%eax
  800637:	89 44 24 04          	mov    %eax,0x4(%esp)
  80063b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800642:	ff 55 08             	call   *0x8(%ebp)
  800645:	eb 0d                	jmp    800654 <vprintfmt+0x20f>
				else
					putch(ch, putdat);
  800647:	8b 45 0c             	mov    0xc(%ebp),%eax
  80064a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064e:	89 14 24             	mov    %edx,(%esp)
  800651:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800654:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  800658:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80065c:	83 c6 01             	add    $0x1,%esi
  80065f:	84 c0                	test   %al,%al
  800661:	74 0c                	je     80066f <vprintfmt+0x22a>
  800663:	0f be d0             	movsbl %al,%edx
  800666:	85 ff                	test   %edi,%edi
  800668:	78 bc                	js     800626 <vprintfmt+0x1e1>
  80066a:	83 ef 01             	sub    $0x1,%edi
  80066d:	79 b7                	jns    800626 <vprintfmt+0x1e1>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80066f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800673:	0f 8e f2 fd ff ff    	jle    80046b <vprintfmt+0x26>
				putch(' ', putdat);
  800679:	8b 55 0c             	mov    0xc(%ebp),%edx
  80067c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800680:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800687:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80068a:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  80068e:	75 e9                	jne    800679 <vprintfmt+0x234>
  800690:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  800693:	e9 d3 fd ff ff       	jmp    80046b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800698:	83 f9 01             	cmp    $0x1,%ecx
  80069b:	90                   	nop    
  80069c:	8d 74 26 00          	lea    0x0(%esi),%esi
  8006a0:	7e 10                	jle    8006b2 <vprintfmt+0x26d>
		return va_arg(*ap, long long);
  8006a2:	8b 55 14             	mov    0x14(%ebp),%edx
  8006a5:	8d 42 08             	lea    0x8(%edx),%eax
  8006a8:	89 45 14             	mov    %eax,0x14(%ebp)
  8006ab:	8b 32                	mov    (%edx),%esi
  8006ad:	8b 7a 04             	mov    0x4(%edx),%edi
  8006b0:	eb 2a                	jmp    8006dc <vprintfmt+0x297>
	else if (lflag)
  8006b2:	85 c9                	test   %ecx,%ecx
  8006b4:	74 14                	je     8006ca <vprintfmt+0x285>
		return va_arg(*ap, long);
  8006b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b9:	8d 50 04             	lea    0x4(%eax),%edx
  8006bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bf:	8b 00                	mov    (%eax),%eax
  8006c1:	89 c6                	mov    %eax,%esi
  8006c3:	89 c7                	mov    %eax,%edi
  8006c5:	c1 ff 1f             	sar    $0x1f,%edi
  8006c8:	eb 12                	jmp    8006dc <vprintfmt+0x297>
	else
		return va_arg(*ap, int);
  8006ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cd:	8d 50 04             	lea    0x4(%eax),%edx
  8006d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d3:	8b 00                	mov    (%eax),%eax
  8006d5:	89 c6                	mov    %eax,%esi
  8006d7:	89 c7                	mov    %eax,%edi
  8006d9:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006dc:	89 f2                	mov    %esi,%edx
  8006de:	89 f9                	mov    %edi,%ecx
  8006e0:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
			if ((long long) num < 0) {
  8006e7:	85 ff                	test   %edi,%edi
  8006e9:	0f 89 9b 00 00 00    	jns    80078a <vprintfmt+0x345>
				putch('-', putdat);
  8006ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006fd:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800700:	89 f2                	mov    %esi,%edx
  800702:	89 f9                	mov    %edi,%ecx
  800704:	f7 da                	neg    %edx
  800706:	83 d1 00             	adc    $0x0,%ecx
  800709:	f7 d9                	neg    %ecx
  80070b:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  800712:	eb 76                	jmp    80078a <vprintfmt+0x345>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800714:	89 ca                	mov    %ecx,%edx
  800716:	8d 45 14             	lea    0x14(%ebp),%eax
  800719:	e8 cd fc ff ff       	call   8003eb <getuint>
  80071e:	89 d1                	mov    %edx,%ecx
  800720:	89 c2                	mov    %eax,%edx
  800722:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  800729:	eb 5f                	jmp    80078a <vprintfmt+0x345>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap,lflag);
  80072b:	89 ca                	mov    %ecx,%edx
  80072d:	8d 45 14             	lea    0x14(%ebp),%eax
  800730:	e8 b6 fc ff ff       	call   8003eb <getuint>
  800735:	e9 31 fd ff ff       	jmp    80046b <vprintfmt+0x26>
			base=8;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80073a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80073d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800741:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800748:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80074b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80074e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800752:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800759:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  80075c:	8b 55 14             	mov    0x14(%ebp),%edx
  80075f:	8d 42 04             	lea    0x4(%edx),%eax
  800762:	89 45 14             	mov    %eax,0x14(%ebp)
  800765:	8b 12                	mov    (%edx),%edx
  800767:	b9 00 00 00 00       	mov    $0x0,%ecx
  80076c:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  800773:	eb 15                	jmp    80078a <vprintfmt+0x345>
			base = 16;
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800775:	89 ca                	mov    %ecx,%edx
  800777:	8d 45 14             	lea    0x14(%ebp),%eax
  80077a:	e8 6c fc ff ff       	call   8003eb <getuint>
  80077f:	89 d1                	mov    %edx,%ecx
  800781:	89 c2                	mov    %eax,%edx
  800783:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80078a:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  80078e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800792:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800795:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800799:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80079c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a0:	89 14 24             	mov    %edx,(%esp)
  8007a3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ad:	e8 4e fb ff ff       	call   800300 <printnum>
  8007b2:	e9 b4 fc ff ff       	jmp    80046b <vprintfmt+0x26>
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ba:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007be:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007c5:	ff 55 08             	call   *0x8(%ebp)
  8007c8:	e9 9e fc ff ff       	jmp    80046b <vprintfmt+0x26>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007db:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007de:	83 eb 01             	sub    $0x1,%ebx
  8007e1:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8007e5:	0f 84 80 fc ff ff    	je     80046b <vprintfmt+0x26>
  8007eb:	83 eb 01             	sub    $0x1,%ebx
  8007ee:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8007f2:	0f 84 73 fc ff ff    	je     80046b <vprintfmt+0x26>
  8007f8:	eb f1                	jmp    8007eb <vprintfmt+0x3a6>
				/* do nothing */;
			break;
		}
	}
}
  8007fa:	83 c4 3c             	add    $0x3c,%esp
  8007fd:	5b                   	pop    %ebx
  8007fe:	5e                   	pop    %esi
  8007ff:	5f                   	pop    %edi
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	83 ec 28             	sub    $0x28,%esp
  800808:	8b 55 08             	mov    0x8(%ebp),%edx
  80080b:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80080e:	85 d2                	test   %edx,%edx
  800810:	74 04                	je     800816 <vsnprintf+0x14>
  800812:	85 c0                	test   %eax,%eax
  800814:	7f 07                	jg     80081d <vsnprintf+0x1b>
  800816:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80081b:	eb 3b                	jmp    800858 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80081d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800824:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
  800828:	89 45 f8             	mov    %eax,-0x8(%ebp)
  80082b:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80082e:	8b 45 14             	mov    0x14(%ebp),%eax
  800831:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800835:	8b 45 10             	mov    0x10(%ebp),%eax
  800838:	89 44 24 08          	mov    %eax,0x8(%esp)
  80083c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80083f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800843:	c7 04 24 27 04 80 00 	movl   $0x800427,(%esp)
  80084a:	e8 f6 fb ff ff       	call   800445 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80084f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800852:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800855:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800858:	c9                   	leave  
  800859:	c3                   	ret    

0080085a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800860:	8d 45 14             	lea    0x14(%ebp),%eax
  800863:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800866:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80086a:	8b 45 10             	mov    0x10(%ebp),%eax
  80086d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800871:	8b 45 0c             	mov    0xc(%ebp),%eax
  800874:	89 44 24 04          	mov    %eax,0x4(%esp)
  800878:	8b 45 08             	mov    0x8(%ebp),%eax
  80087b:	89 04 24             	mov    %eax,(%esp)
  80087e:	e8 7f ff ff ff       	call   800802 <vsnprintf>
	va_end(ap);

	return rc;
}
  800883:	c9                   	leave  
  800884:	c3                   	ret    

00800885 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  80088b:	8d 45 14             	lea    0x14(%ebp),%eax
  80088e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800891:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800895:	8b 45 10             	mov    0x10(%ebp),%eax
  800898:	89 44 24 08          	mov    %eax,0x8(%esp)
  80089c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a6:	89 04 24             	mov    %eax,(%esp)
  8008a9:	e8 97 fb ff ff       	call   800445 <vprintfmt>
	va_end(ap);
}
  8008ae:	c9                   	leave  
  8008af:	c3                   	ret    

008008b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bb:	80 3a 00             	cmpb   $0x0,(%edx)
  8008be:	74 0e                	je     8008ce <strlen+0x1e>
  8008c0:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008c5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c8:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  8008cc:	75 f7                	jne    8008c5 <strlen+0x15>
		n++;
	return n;
}
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    

008008d0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d9:	85 d2                	test   %edx,%edx
  8008db:	74 19                	je     8008f6 <strnlen+0x26>
  8008dd:	80 39 00             	cmpb   $0x0,(%ecx)
  8008e0:	74 14                	je     8008f6 <strnlen+0x26>
  8008e2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008e7:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ea:	39 d0                	cmp    %edx,%eax
  8008ec:	74 0d                	je     8008fb <strnlen+0x2b>
  8008ee:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  8008f2:	74 07                	je     8008fb <strnlen+0x2b>
  8008f4:	eb f1                	jmp    8008e7 <strnlen+0x17>
  8008f6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008fb:	5d                   	pop    %ebp
  8008fc:	8d 74 26 00          	lea    0x0(%esi),%esi
  800900:	c3                   	ret    

00800901 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	53                   	push   %ebx
  800905:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800908:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090b:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80090d:	0f b6 01             	movzbl (%ecx),%eax
  800910:	88 02                	mov    %al,(%edx)
  800912:	83 c2 01             	add    $0x1,%edx
  800915:	83 c1 01             	add    $0x1,%ecx
  800918:	84 c0                	test   %al,%al
  80091a:	75 f1                	jne    80090d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80091c:	89 d8                	mov    %ebx,%eax
  80091e:	5b                   	pop    %ebx
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	57                   	push   %edi
  800925:	56                   	push   %esi
  800926:	53                   	push   %ebx
  800927:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800930:	85 f6                	test   %esi,%esi
  800932:	74 1c                	je     800950 <strncpy+0x2f>
  800934:	89 fa                	mov    %edi,%edx
  800936:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  80093b:	0f b6 01             	movzbl (%ecx),%eax
  80093e:	88 02                	mov    %al,(%edx)
  800940:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800943:	80 39 01             	cmpb   $0x1,(%ecx)
  800946:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800949:	83 c3 01             	add    $0x1,%ebx
  80094c:	39 f3                	cmp    %esi,%ebx
  80094e:	75 eb                	jne    80093b <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800950:	89 f8                	mov    %edi,%eax
  800952:	5b                   	pop    %ebx
  800953:	5e                   	pop    %esi
  800954:	5f                   	pop    %edi
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	56                   	push   %esi
  80095b:	53                   	push   %ebx
  80095c:	8b 75 08             	mov    0x8(%ebp),%esi
  80095f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800962:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800965:	89 f0                	mov    %esi,%eax
  800967:	85 d2                	test   %edx,%edx
  800969:	74 2c                	je     800997 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  80096b:	89 d3                	mov    %edx,%ebx
  80096d:	83 eb 01             	sub    $0x1,%ebx
  800970:	74 20                	je     800992 <strlcpy+0x3b>
  800972:	0f b6 11             	movzbl (%ecx),%edx
  800975:	84 d2                	test   %dl,%dl
  800977:	74 19                	je     800992 <strlcpy+0x3b>
  800979:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  80097b:	88 10                	mov    %dl,(%eax)
  80097d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800980:	83 eb 01             	sub    $0x1,%ebx
  800983:	74 0f                	je     800994 <strlcpy+0x3d>
  800985:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  800989:	83 c1 01             	add    $0x1,%ecx
  80098c:	84 d2                	test   %dl,%dl
  80098e:	74 04                	je     800994 <strlcpy+0x3d>
  800990:	eb e9                	jmp    80097b <strlcpy+0x24>
  800992:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800994:	c6 00 00             	movb   $0x0,(%eax)
  800997:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800999:	5b                   	pop    %ebx
  80099a:	5e                   	pop    %esi
  80099b:	5d                   	pop    %ebp
  80099c:	c3                   	ret    

0080099d <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	56                   	push   %esi
  8009a1:	53                   	push   %ebx
  8009a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a8:	8b 55 10             	mov    0x10(%ebp),%edx
    int c;
    char *q = buf;

    if (buf_size <= 0)
  8009ab:	85 c0                	test   %eax,%eax
  8009ad:	7e 2e                	jle    8009dd <pstrcpy+0x40>
        return;

    for(;;) {
        c = *str++;
  8009af:	0f b6 0a             	movzbl (%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  8009b2:	84 c9                	test   %cl,%cl
  8009b4:	74 22                	je     8009d8 <pstrcpy+0x3b>
  8009b6:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  8009ba:	89 f0                	mov    %esi,%eax
  8009bc:	39 de                	cmp    %ebx,%esi
  8009be:	72 09                	jb     8009c9 <pstrcpy+0x2c>
  8009c0:	eb 16                	jmp    8009d8 <pstrcpy+0x3b>
  8009c2:	83 c2 01             	add    $0x1,%edx
  8009c5:	39 d8                	cmp    %ebx,%eax
  8009c7:	73 11                	jae    8009da <pstrcpy+0x3d>
            break;
        *q++ = c;
  8009c9:	88 08                	mov    %cl,(%eax)
  8009cb:	83 c0 01             	add    $0x1,%eax

    if (buf_size <= 0)
        return;

    for(;;) {
        c = *str++;
  8009ce:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  8009d2:	84 c9                	test   %cl,%cl
  8009d4:	75 ec                	jne    8009c2 <pstrcpy+0x25>
  8009d6:	eb 02                	jmp    8009da <pstrcpy+0x3d>
  8009d8:	89 f0                	mov    %esi,%eax
            break;
        *q++ = c;
    }
    *q = '\0';
  8009da:	c6 00 00             	movb   $0x0,(%eax)
}
  8009dd:	5b                   	pop    %ebx
  8009de:	5e                   	pop    %esi
  8009df:	5d                   	pop    %ebp
  8009e0:	c3                   	ret    

008009e1 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
  8009e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  8009ea:	0f b6 02             	movzbl (%edx),%eax
  8009ed:	84 c0                	test   %al,%al
  8009ef:	74 16                	je     800a07 <strcmp+0x26>
  8009f1:	3a 01                	cmp    (%ecx),%al
  8009f3:	75 12                	jne    800a07 <strcmp+0x26>
		p++, q++;
  8009f5:	83 c1 01             	add    $0x1,%ecx
    *q = '\0';
}
int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009f8:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  8009fc:	84 c0                	test   %al,%al
  8009fe:	74 07                	je     800a07 <strcmp+0x26>
  800a00:	83 c2 01             	add    $0x1,%edx
  800a03:	3a 01                	cmp    (%ecx),%al
  800a05:	74 ee                	je     8009f5 <strcmp+0x14>
  800a07:	0f b6 c0             	movzbl %al,%eax
  800a0a:	0f b6 11             	movzbl (%ecx),%edx
  800a0d:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	53                   	push   %ebx
  800a15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a18:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a1b:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800a1e:	85 d2                	test   %edx,%edx
  800a20:	74 2d                	je     800a4f <strncmp+0x3e>
  800a22:	0f b6 01             	movzbl (%ecx),%eax
  800a25:	84 c0                	test   %al,%al
  800a27:	74 1a                	je     800a43 <strncmp+0x32>
  800a29:	3a 03                	cmp    (%ebx),%al
  800a2b:	75 16                	jne    800a43 <strncmp+0x32>
  800a2d:	83 ea 01             	sub    $0x1,%edx
  800a30:	74 1d                	je     800a4f <strncmp+0x3e>
		n--, p++, q++;
  800a32:	83 c1 01             	add    $0x1,%ecx
  800a35:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a38:	0f b6 01             	movzbl (%ecx),%eax
  800a3b:	84 c0                	test   %al,%al
  800a3d:	74 04                	je     800a43 <strncmp+0x32>
  800a3f:	3a 03                	cmp    (%ebx),%al
  800a41:	74 ea                	je     800a2d <strncmp+0x1c>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a43:	0f b6 11             	movzbl (%ecx),%edx
  800a46:	0f b6 03             	movzbl (%ebx),%eax
  800a49:	29 c2                	sub    %eax,%edx
  800a4b:	89 d0                	mov    %edx,%eax
  800a4d:	eb 05                	jmp    800a54 <strncmp+0x43>
  800a4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a54:	5b                   	pop    %ebx
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    

00800a57 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a61:	0f b6 10             	movzbl (%eax),%edx
  800a64:	84 d2                	test   %dl,%dl
  800a66:	74 14                	je     800a7c <strchr+0x25>
		if (*s == c)
  800a68:	38 ca                	cmp    %cl,%dl
  800a6a:	75 06                	jne    800a72 <strchr+0x1b>
  800a6c:	eb 13                	jmp    800a81 <strchr+0x2a>
  800a6e:	38 ca                	cmp    %cl,%dl
  800a70:	74 0f                	je     800a81 <strchr+0x2a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a72:	83 c0 01             	add    $0x1,%eax
  800a75:	0f b6 10             	movzbl (%eax),%edx
  800a78:	84 d2                	test   %dl,%dl
  800a7a:	75 f2                	jne    800a6e <strchr+0x17>
  800a7c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	8b 45 08             	mov    0x8(%ebp),%eax
  800a89:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a8d:	0f b6 10             	movzbl (%eax),%edx
  800a90:	84 d2                	test   %dl,%dl
  800a92:	74 18                	je     800aac <strfind+0x29>
		if (*s == c)
  800a94:	38 ca                	cmp    %cl,%dl
  800a96:	75 0a                	jne    800aa2 <strfind+0x1f>
  800a98:	eb 12                	jmp    800aac <strfind+0x29>
  800a9a:	38 ca                	cmp    %cl,%dl
  800a9c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800aa0:	74 0a                	je     800aac <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aa2:	83 c0 01             	add    $0x1,%eax
  800aa5:	0f b6 10             	movzbl (%eax),%edx
  800aa8:	84 d2                	test   %dl,%dl
  800aaa:	75 ee                	jne    800a9a <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    

00800aae <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	83 ec 08             	sub    $0x8,%esp
  800ab4:	89 1c 24             	mov    %ebx,(%esp)
  800ab7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800abb:	8b 7d 08             	mov    0x8(%ebp),%edi
  800abe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800ac1:	85 db                	test   %ebx,%ebx
  800ac3:	74 36                	je     800afb <memset+0x4d>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ac5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800acb:	75 26                	jne    800af3 <memset+0x45>
  800acd:	f6 c3 03             	test   $0x3,%bl
  800ad0:	75 21                	jne    800af3 <memset+0x45>
		c &= 0xFF;
  800ad2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ad6:	89 d0                	mov    %edx,%eax
  800ad8:	c1 e0 18             	shl    $0x18,%eax
  800adb:	89 d1                	mov    %edx,%ecx
  800add:	c1 e1 10             	shl    $0x10,%ecx
  800ae0:	09 c8                	or     %ecx,%eax
  800ae2:	09 d0                	or     %edx,%eax
  800ae4:	c1 e2 08             	shl    $0x8,%edx
  800ae7:	09 d0                	or     %edx,%eax
  800ae9:	89 d9                	mov    %ebx,%ecx
  800aeb:	c1 e9 02             	shr    $0x2,%ecx
  800aee:	fc                   	cld    
  800aef:	f3 ab                	rep stos %eax,%es:(%edi)
  800af1:	eb 08                	jmp    800afb <memset+0x4d>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800af3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af6:	89 d9                	mov    %ebx,%ecx
  800af8:	fc                   	cld    
  800af9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800afb:	89 f8                	mov    %edi,%eax
  800afd:	8b 1c 24             	mov    (%esp),%ebx
  800b00:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b04:	89 ec                	mov    %ebp,%esp
  800b06:	5d                   	pop    %ebp
  800b07:	c3                   	ret    

00800b08 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	83 ec 08             	sub    $0x8,%esp
  800b0e:	89 34 24             	mov    %esi,(%esp)
  800b11:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b15:	8b 45 08             	mov    0x8(%ebp),%eax
  800b18:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800b1b:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b1e:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b20:	39 c6                	cmp    %eax,%esi
  800b22:	73 38                	jae    800b5c <memmove+0x54>
  800b24:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b27:	39 d0                	cmp    %edx,%eax
  800b29:	73 31                	jae    800b5c <memmove+0x54>
		s += n;
		d += n;
  800b2b:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b2e:	f6 c2 03             	test   $0x3,%dl
  800b31:	75 1d                	jne    800b50 <memmove+0x48>
  800b33:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b39:	75 15                	jne    800b50 <memmove+0x48>
  800b3b:	f6 c1 03             	test   $0x3,%cl
  800b3e:	66 90                	xchg   %ax,%ax
  800b40:	75 0e                	jne    800b50 <memmove+0x48>
			asm volatile("std; rep movsl\n"
  800b42:	8d 7e fc             	lea    -0x4(%esi),%edi
  800b45:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b48:	c1 e9 02             	shr    $0x2,%ecx
  800b4b:	fd                   	std    
  800b4c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b4e:	eb 09                	jmp    800b59 <memmove+0x51>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b50:	8d 7e ff             	lea    -0x1(%esi),%edi
  800b53:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b56:	fd                   	std    
  800b57:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b59:	fc                   	cld    
  800b5a:	eb 21                	jmp    800b7d <memmove+0x75>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b5c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b62:	75 16                	jne    800b7a <memmove+0x72>
  800b64:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b6a:	75 0e                	jne    800b7a <memmove+0x72>
  800b6c:	f6 c1 03             	test   $0x3,%cl
  800b6f:	90                   	nop    
  800b70:	75 08                	jne    800b7a <memmove+0x72>
			asm volatile("cld; rep movsl\n"
  800b72:	c1 e9 02             	shr    $0x2,%ecx
  800b75:	fc                   	cld    
  800b76:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b78:	eb 03                	jmp    800b7d <memmove+0x75>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b7a:	fc                   	cld    
  800b7b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b7d:	8b 34 24             	mov    (%esp),%esi
  800b80:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b84:	89 ec                	mov    %ebp,%esp
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    

00800b88 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b8e:	8b 45 10             	mov    0x10(%ebp),%eax
  800b91:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b95:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b98:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9f:	89 04 24             	mov    %eax,(%esp)
  800ba2:	e8 61 ff ff ff       	call   800b08 <memmove>
}
  800ba7:	c9                   	leave  
  800ba8:	c3                   	ret    

00800ba9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	57                   	push   %edi
  800bad:	56                   	push   %esi
  800bae:	53                   	push   %ebx
  800baf:	83 ec 04             	sub    $0x4,%esp
  800bb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bb8:	8b 55 10             	mov    0x10(%ebp),%edx
  800bbb:	83 ea 01             	sub    $0x1,%edx
  800bbe:	83 fa ff             	cmp    $0xffffffff,%edx
  800bc1:	74 47                	je     800c0a <memcmp+0x61>
		if (*s1 != *s2)
  800bc3:	0f b6 30             	movzbl (%eax),%esi
  800bc6:	0f b6 39             	movzbl (%ecx),%edi
			return (int) *s1 - (int) *s2;
  800bc9:	89 45 f0             	mov    %eax,-0x10(%ebp)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  800bcc:	89 f0                	mov    %esi,%eax
  800bce:	89 fb                	mov    %edi,%ebx
  800bd0:	38 d8                	cmp    %bl,%al
  800bd2:	74 2e                	je     800c02 <memcmp+0x59>
  800bd4:	eb 1c                	jmp    800bf2 <memcmp+0x49>
  800bd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bd9:	0f b6 70 01          	movzbl 0x1(%eax),%esi
  800bdd:	0f b6 79 01          	movzbl 0x1(%ecx),%edi
  800be1:	83 c0 01             	add    $0x1,%eax
  800be4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800be7:	83 c1 01             	add    $0x1,%ecx
  800bea:	89 f3                	mov    %esi,%ebx
  800bec:	89 f8                	mov    %edi,%eax
  800bee:	38 c3                	cmp    %al,%bl
  800bf0:	74 10                	je     800c02 <memcmp+0x59>
			return (int) *s1 - (int) *s2;
  800bf2:	89 f1                	mov    %esi,%ecx
  800bf4:	0f b6 d1             	movzbl %cl,%edx
  800bf7:	89 fb                	mov    %edi,%ebx
  800bf9:	0f b6 c3             	movzbl %bl,%eax
  800bfc:	29 c2                	sub    %eax,%edx
  800bfe:	89 d0                	mov    %edx,%eax
  800c00:	eb 0d                	jmp    800c0f <memcmp+0x66>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c02:	83 ea 01             	sub    $0x1,%edx
  800c05:	83 fa ff             	cmp    $0xffffffff,%edx
  800c08:	75 cc                	jne    800bd6 <memcmp+0x2d>
  800c0a:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800c0f:	83 c4 04             	add    $0x4,%esp
  800c12:	5b                   	pop    %ebx
  800c13:	5e                   	pop    %esi
  800c14:	5f                   	pop    %edi
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    

00800c17 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c1d:	89 c1                	mov    %eax,%ecx
  800c1f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
  800c22:	39 c8                	cmp    %ecx,%eax
  800c24:	73 15                	jae    800c3b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c26:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
  800c2a:	38 10                	cmp    %dl,(%eax)
  800c2c:	75 06                	jne    800c34 <memfind+0x1d>
  800c2e:	eb 0b                	jmp    800c3b <memfind+0x24>
  800c30:	38 10                	cmp    %dl,(%eax)
  800c32:	74 07                	je     800c3b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c34:	83 c0 01             	add    $0x1,%eax
  800c37:	39 c8                	cmp    %ecx,%eax
  800c39:	75 f5                	jne    800c30 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c3b:	5d                   	pop    %ebp
  800c3c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800c40:	c3                   	ret    

00800c41 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	57                   	push   %edi
  800c45:	56                   	push   %esi
  800c46:	53                   	push   %ebx
  800c47:	83 ec 04             	sub    $0x4,%esp
  800c4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c4d:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c50:	0f b6 01             	movzbl (%ecx),%eax
  800c53:	3c 20                	cmp    $0x20,%al
  800c55:	74 04                	je     800c5b <strtol+0x1a>
  800c57:	3c 09                	cmp    $0x9,%al
  800c59:	75 0e                	jne    800c69 <strtol+0x28>
		s++;
  800c5b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c5e:	0f b6 01             	movzbl (%ecx),%eax
  800c61:	3c 20                	cmp    $0x20,%al
  800c63:	74 f6                	je     800c5b <strtol+0x1a>
  800c65:	3c 09                	cmp    $0x9,%al
  800c67:	74 f2                	je     800c5b <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c69:	3c 2b                	cmp    $0x2b,%al
  800c6b:	75 0c                	jne    800c79 <strtol+0x38>
		s++;
  800c6d:	83 c1 01             	add    $0x1,%ecx
  800c70:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c77:	eb 15                	jmp    800c8e <strtol+0x4d>
	else if (*s == '-')
  800c79:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c80:	3c 2d                	cmp    $0x2d,%al
  800c82:	75 0a                	jne    800c8e <strtol+0x4d>
		s++, neg = 1;
  800c84:	83 c1 01             	add    $0x1,%ecx
  800c87:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c8e:	85 f6                	test   %esi,%esi
  800c90:	0f 94 c0             	sete   %al
  800c93:	74 05                	je     800c9a <strtol+0x59>
  800c95:	83 fe 10             	cmp    $0x10,%esi
  800c98:	75 18                	jne    800cb2 <strtol+0x71>
  800c9a:	80 39 30             	cmpb   $0x30,(%ecx)
  800c9d:	75 13                	jne    800cb2 <strtol+0x71>
  800c9f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ca3:	75 0d                	jne    800cb2 <strtol+0x71>
		s += 2, base = 16;
  800ca5:	83 c1 02             	add    $0x2,%ecx
  800ca8:	be 10 00 00 00       	mov    $0x10,%esi
  800cad:	8d 76 00             	lea    0x0(%esi),%esi
  800cb0:	eb 1b                	jmp    800ccd <strtol+0x8c>
	else if (base == 0 && s[0] == '0')
  800cb2:	85 f6                	test   %esi,%esi
  800cb4:	75 0e                	jne    800cc4 <strtol+0x83>
  800cb6:	80 39 30             	cmpb   $0x30,(%ecx)
  800cb9:	75 09                	jne    800cc4 <strtol+0x83>
		s++, base = 8;
  800cbb:	83 c1 01             	add    $0x1,%ecx
  800cbe:	66 be 08 00          	mov    $0x8,%si
  800cc2:	eb 09                	jmp    800ccd <strtol+0x8c>
	else if (base == 0)
  800cc4:	84 c0                	test   %al,%al
  800cc6:	74 05                	je     800ccd <strtol+0x8c>
  800cc8:	be 0a 00 00 00       	mov    $0xa,%esi
  800ccd:	bf 00 00 00 00       	mov    $0x0,%edi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cd2:	0f b6 11             	movzbl (%ecx),%edx
  800cd5:	89 d3                	mov    %edx,%ebx
  800cd7:	8d 42 d0             	lea    -0x30(%edx),%eax
  800cda:	3c 09                	cmp    $0x9,%al
  800cdc:	77 08                	ja     800ce6 <strtol+0xa5>
			dig = *s - '0';
  800cde:	0f be c2             	movsbl %dl,%eax
  800ce1:	8d 50 d0             	lea    -0x30(%eax),%edx
  800ce4:	eb 1c                	jmp    800d02 <strtol+0xc1>
		else if (*s >= 'a' && *s <= 'z')
  800ce6:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800ce9:	3c 19                	cmp    $0x19,%al
  800ceb:	77 08                	ja     800cf5 <strtol+0xb4>
			dig = *s - 'a' + 10;
  800ced:	0f be c2             	movsbl %dl,%eax
  800cf0:	8d 50 a9             	lea    -0x57(%eax),%edx
  800cf3:	eb 0d                	jmp    800d02 <strtol+0xc1>
		else if (*s >= 'A' && *s <= 'Z')
  800cf5:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800cf8:	3c 19                	cmp    $0x19,%al
  800cfa:	77 17                	ja     800d13 <strtol+0xd2>
			dig = *s - 'A' + 10;
  800cfc:	0f be c2             	movsbl %dl,%eax
  800cff:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800d02:	39 f2                	cmp    %esi,%edx
  800d04:	7d 0d                	jge    800d13 <strtol+0xd2>
			break;
		s++, val = (val * base) + dig;
  800d06:	83 c1 01             	add    $0x1,%ecx
  800d09:	89 f8                	mov    %edi,%eax
  800d0b:	0f af c6             	imul   %esi,%eax
  800d0e:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800d11:	eb bf                	jmp    800cd2 <strtol+0x91>
		// we don't properly detect overflow!
	}
  800d13:	89 f8                	mov    %edi,%eax

	if (endptr)
  800d15:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d19:	74 05                	je     800d20 <strtol+0xdf>
		*endptr = (char *) s;
  800d1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d1e:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800d20:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800d24:	74 04                	je     800d2a <strtol+0xe9>
  800d26:	89 c7                	mov    %eax,%edi
  800d28:	f7 df                	neg    %edi
}
  800d2a:	89 f8                	mov    %edi,%eax
  800d2c:	83 c4 04             	add    $0x4,%esp
  800d2f:	5b                   	pop    %ebx
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    

00800d34 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
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
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d45:	b8 01 00 00 00       	mov    $0x1,%eax
  800d4a:	bf 00 00 00 00       	mov    $0x0,%edi
  800d4f:	89 fa                	mov    %edi,%edx
  800d51:	89 f9                	mov    %edi,%ecx
  800d53:	89 fb                	mov    %edi,%ebx
  800d55:	89 fe                	mov    %edi,%esi
  800d57:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d59:	8b 1c 24             	mov    (%esp),%ebx
  800d5c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d60:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d64:	89 ec                	mov    %ebp,%esp
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	83 ec 0c             	sub    $0xc,%esp
  800d6e:	89 1c 24             	mov    %ebx,(%esp)
  800d71:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d75:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7f:	bf 00 00 00 00       	mov    $0x0,%edi
  800d84:	89 f8                	mov    %edi,%eax
  800d86:	89 fb                	mov    %edi,%ebx
  800d88:	89 fe                	mov    %edi,%esi
  800d8a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d8c:	8b 1c 24             	mov    (%esp),%ebx
  800d8f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d93:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d97:	89 ec                	mov    %ebp,%esp
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <sys_time_msec>:
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
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dac:	b8 0e 00 00 00       	mov    $0xe,%eax
  800db1:	bf 00 00 00 00       	mov    $0x0,%edi
  800db6:	89 fa                	mov    %edi,%edx
  800db8:	89 f9                	mov    %edi,%ecx
  800dba:	89 fb                	mov    %edi,%ebx
  800dbc:	89 fe                	mov    %edi,%esi
  800dbe:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dc0:	8b 1c 24             	mov    (%esp),%ebx
  800dc3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800dc7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800dcb:	89 ec                	mov    %ebp,%esp
  800dcd:	5d                   	pop    %ebp
  800dce:	c3                   	ret    

00800dcf <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800dcf:	55                   	push   %ebp
  800dd0:	89 e5                	mov    %esp,%ebp
  800dd2:	83 ec 28             	sub    $0x28,%esp
  800dd5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dd8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ddb:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800dde:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800de6:	bf 00 00 00 00       	mov    $0x0,%edi
  800deb:	89 f9                	mov    %edi,%ecx
  800ded:	89 fb                	mov    %edi,%ebx
  800def:	89 fe                	mov    %edi,%esi
  800df1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800df3:	85 c0                	test   %eax,%eax
  800df5:	7e 28                	jle    800e1f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dfb:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e02:	00 
  800e03:	c7 44 24 08 1f 2d 80 	movl   $0x802d1f,0x8(%esp)
  800e0a:	00 
  800e0b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e12:	00 
  800e13:	c7 04 24 3c 2d 80 00 	movl   $0x802d3c,(%esp)
  800e1a:	e8 b5 f3 ff ff       	call   8001d4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e1f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e22:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e25:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e28:	89 ec                	mov    %ebp,%esp
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
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
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e49:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e4e:	be 00 00 00 00       	mov    $0x0,%esi
  800e53:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e55:	8b 1c 24             	mov    (%esp),%ebx
  800e58:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e5c:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e60:	89 ec                	mov    %ebp,%esp
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    

00800e64 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	83 ec 28             	sub    $0x28,%esp
  800e6a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e6d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e70:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e73:	8b 55 08             	mov    0x8(%ebp),%edx
  800e76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e79:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e7e:	bf 00 00 00 00       	mov    $0x0,%edi
  800e83:	89 fb                	mov    %edi,%ebx
  800e85:	89 fe                	mov    %edi,%esi
  800e87:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800e89:	85 c0                	test   %eax,%eax
  800e8b:	7e 28                	jle    800eb5 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e91:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e98:	00 
  800e99:	c7 44 24 08 1f 2d 80 	movl   $0x802d1f,0x8(%esp)
  800ea0:	00 
  800ea1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea8:	00 
  800ea9:	c7 04 24 3c 2d 80 00 	movl   $0x802d3c,(%esp)
  800eb0:	e8 1f f3 ff ff       	call   8001d4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eb5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eb8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ebb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ebe:	89 ec                	mov    %ebp,%esp
  800ec0:	5d                   	pop    %ebp
  800ec1:	c3                   	ret    

00800ec2 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
  800ec5:	83 ec 28             	sub    $0x28,%esp
  800ec8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ecb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ece:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ed1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed7:	b8 09 00 00 00       	mov    $0x9,%eax
  800edc:	bf 00 00 00 00       	mov    $0x0,%edi
  800ee1:	89 fb                	mov    %edi,%ebx
  800ee3:	89 fe                	mov    %edi,%esi
  800ee5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800ee7:	85 c0                	test   %eax,%eax
  800ee9:	7e 28                	jle    800f13 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eeb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eef:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ef6:	00 
  800ef7:	c7 44 24 08 1f 2d 80 	movl   $0x802d1f,0x8(%esp)
  800efe:	00 
  800eff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f06:	00 
  800f07:	c7 04 24 3c 2d 80 00 	movl   $0x802d3c,(%esp)
  800f0e:	e8 c1 f2 ff ff       	call   8001d4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f13:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f16:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f19:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f1c:	89 ec                	mov    %ebp,%esp
  800f1e:	5d                   	pop    %ebp
  800f1f:	c3                   	ret    

00800f20 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	83 ec 28             	sub    $0x28,%esp
  800f26:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f29:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f2c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f35:	b8 08 00 00 00       	mov    $0x8,%eax
  800f3a:	bf 00 00 00 00       	mov    $0x0,%edi
  800f3f:	89 fb                	mov    %edi,%ebx
  800f41:	89 fe                	mov    %edi,%esi
  800f43:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f45:	85 c0                	test   %eax,%eax
  800f47:	7e 28                	jle    800f71 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f49:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f4d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f54:	00 
  800f55:	c7 44 24 08 1f 2d 80 	movl   $0x802d1f,0x8(%esp)
  800f5c:	00 
  800f5d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f64:	00 
  800f65:	c7 04 24 3c 2d 80 00 	movl   $0x802d3c,(%esp)
  800f6c:	e8 63 f2 ff ff       	call   8001d4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f71:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f74:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f77:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f7a:	89 ec                	mov    %ebp,%esp
  800f7c:	5d                   	pop    %ebp
  800f7d:	c3                   	ret    

00800f7e <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	83 ec 28             	sub    $0x28,%esp
  800f84:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f87:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f8a:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f93:	b8 06 00 00 00       	mov    $0x6,%eax
  800f98:	bf 00 00 00 00       	mov    $0x0,%edi
  800f9d:	89 fb                	mov    %edi,%ebx
  800f9f:	89 fe                	mov    %edi,%esi
  800fa1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800fa3:	85 c0                	test   %eax,%eax
  800fa5:	7e 28                	jle    800fcf <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fa7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fab:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800fb2:	00 
  800fb3:	c7 44 24 08 1f 2d 80 	movl   $0x802d1f,0x8(%esp)
  800fba:	00 
  800fbb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fc2:	00 
  800fc3:	c7 04 24 3c 2d 80 00 	movl   $0x802d3c,(%esp)
  800fca:	e8 05 f2 ff ff       	call   8001d4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fcf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fd2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fd5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fd8:	89 ec                	mov    %ebp,%esp
  800fda:	5d                   	pop    %ebp
  800fdb:	c3                   	ret    

00800fdc <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	83 ec 28             	sub    $0x28,%esp
  800fe2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fe5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fe8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800feb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ff4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ff7:	8b 75 18             	mov    0x18(%ebp),%esi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ffa:	b8 05 00 00 00       	mov    $0x5,%eax
  800fff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801001:	85 c0                	test   %eax,%eax
  801003:	7e 28                	jle    80102d <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801005:	89 44 24 10          	mov    %eax,0x10(%esp)
  801009:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801010:	00 
  801011:	c7 44 24 08 1f 2d 80 	movl   $0x802d1f,0x8(%esp)
  801018:	00 
  801019:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801020:	00 
  801021:	c7 04 24 3c 2d 80 00 	movl   $0x802d3c,(%esp)
  801028:	e8 a7 f1 ff ff       	call   8001d4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80102d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801030:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801033:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801036:	89 ec                	mov    %ebp,%esp
  801038:	5d                   	pop    %ebp
  801039:	c3                   	ret    

0080103a <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	83 ec 28             	sub    $0x28,%esp
  801040:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801043:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801046:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801049:	8b 55 08             	mov    0x8(%ebp),%edx
  80104c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80104f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801052:	b8 04 00 00 00       	mov    $0x4,%eax
  801057:	bf 00 00 00 00       	mov    $0x0,%edi
  80105c:	89 fe                	mov    %edi,%esi
  80105e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801060:	85 c0                	test   %eax,%eax
  801062:	7e 28                	jle    80108c <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  801064:	89 44 24 10          	mov    %eax,0x10(%esp)
  801068:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80106f:	00 
  801070:	c7 44 24 08 1f 2d 80 	movl   $0x802d1f,0x8(%esp)
  801077:	00 
  801078:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80107f:	00 
  801080:	c7 04 24 3c 2d 80 00 	movl   $0x802d3c,(%esp)
  801087:	e8 48 f1 ff ff       	call   8001d4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80108c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80108f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801092:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801095:	89 ec                	mov    %ebp,%esp
  801097:	5d                   	pop    %ebp
  801098:	c3                   	ret    

00801099 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  801099:	55                   	push   %ebp
  80109a:	89 e5                	mov    %esp,%ebp
  80109c:	83 ec 0c             	sub    $0xc,%esp
  80109f:	89 1c 24             	mov    %ebx,(%esp)
  8010a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010a6:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010aa:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010af:	bf 00 00 00 00       	mov    $0x0,%edi
  8010b4:	89 fa                	mov    %edi,%edx
  8010b6:	89 f9                	mov    %edi,%ecx
  8010b8:	89 fb                	mov    %edi,%ebx
  8010ba:	89 fe                	mov    %edi,%esi
  8010bc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010be:	8b 1c 24             	mov    (%esp),%ebx
  8010c1:	8b 74 24 04          	mov    0x4(%esp),%esi
  8010c5:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8010c9:	89 ec                	mov    %ebp,%esp
  8010cb:	5d                   	pop    %ebp
  8010cc:	c3                   	ret    

008010cd <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8010cd:	55                   	push   %ebp
  8010ce:	89 e5                	mov    %esp,%ebp
  8010d0:	83 ec 0c             	sub    $0xc,%esp
  8010d3:	89 1c 24             	mov    %ebx,(%esp)
  8010d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010da:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010de:	b8 02 00 00 00       	mov    $0x2,%eax
  8010e3:	bf 00 00 00 00       	mov    $0x0,%edi
  8010e8:	89 fa                	mov    %edi,%edx
  8010ea:	89 f9                	mov    %edi,%ecx
  8010ec:	89 fb                	mov    %edi,%ebx
  8010ee:	89 fe                	mov    %edi,%esi
  8010f0:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010f2:	8b 1c 24             	mov    (%esp),%ebx
  8010f5:	8b 74 24 04          	mov    0x4(%esp),%esi
  8010f9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8010fd:	89 ec                	mov    %ebp,%esp
  8010ff:	5d                   	pop    %ebp
  801100:	c3                   	ret    

00801101 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	83 ec 28             	sub    $0x28,%esp
  801107:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80110a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80110d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801110:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801113:	b8 03 00 00 00       	mov    $0x3,%eax
  801118:	bf 00 00 00 00       	mov    $0x0,%edi
  80111d:	89 f9                	mov    %edi,%ecx
  80111f:	89 fb                	mov    %edi,%ebx
  801121:	89 fe                	mov    %edi,%esi
  801123:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801125:	85 c0                	test   %eax,%eax
  801127:	7e 28                	jle    801151 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801129:	89 44 24 10          	mov    %eax,0x10(%esp)
  80112d:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801134:	00 
  801135:	c7 44 24 08 1f 2d 80 	movl   $0x802d1f,0x8(%esp)
  80113c:	00 
  80113d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801144:	00 
  801145:	c7 04 24 3c 2d 80 00 	movl   $0x802d3c,(%esp)
  80114c:	e8 83 f0 ff ff       	call   8001d4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801151:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801154:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801157:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80115a:	89 ec                	mov    %ebp,%esp
  80115c:	5d                   	pop    %ebp
  80115d:	c3                   	ret    
	...

00801160 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	8b 45 08             	mov    0x8(%ebp),%eax
  801166:	05 00 00 00 30       	add    $0x30000000,%eax
  80116b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80116e:	5d                   	pop    %ebp
  80116f:	c3                   	ret    

00801170 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801176:	8b 45 08             	mov    0x8(%ebp),%eax
  801179:	89 04 24             	mov    %eax,(%esp)
  80117c:	e8 df ff ff ff       	call   801160 <fd2num>
  801181:	c1 e0 0c             	shl    $0xc,%eax
  801184:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801189:	c9                   	leave  
  80118a:	c3                   	ret    

0080118b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80118b:	55                   	push   %ebp
  80118c:	89 e5                	mov    %esp,%ebp
  80118e:	53                   	push   %ebx
  80118f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801192:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  801197:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801199:	89 d0                	mov    %edx,%eax
  80119b:	c1 e8 16             	shr    $0x16,%eax
  80119e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011a5:	a8 01                	test   $0x1,%al
  8011a7:	74 10                	je     8011b9 <fd_alloc+0x2e>
  8011a9:	89 d0                	mov    %edx,%eax
  8011ab:	c1 e8 0c             	shr    $0xc,%eax
  8011ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011b5:	a8 01                	test   $0x1,%al
  8011b7:	75 09                	jne    8011c2 <fd_alloc+0x37>
			*fd_store = fd;
  8011b9:	89 0b                	mov    %ecx,(%ebx)
  8011bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c0:	eb 19                	jmp    8011db <fd_alloc+0x50>
			return 0;
  8011c2:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011c8:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  8011ce:	75 c7                	jne    801197 <fd_alloc+0xc>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011d0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8011d6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8011db:	5b                   	pop    %ebx
  8011dc:	5d                   	pop    %ebp
  8011dd:	c3                   	ret    

008011de <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011de:	55                   	push   %ebp
  8011df:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011e1:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  8011e5:	77 38                	ja     80121f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ea:	c1 e0 0c             	shl    $0xc,%eax
  8011ed:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  8011f3:	89 d0                	mov    %edx,%eax
  8011f5:	c1 e8 16             	shr    $0x16,%eax
  8011f8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011ff:	a8 01                	test   $0x1,%al
  801201:	74 1c                	je     80121f <fd_lookup+0x41>
  801203:	89 d0                	mov    %edx,%eax
  801205:	c1 e8 0c             	shr    $0xc,%eax
  801208:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80120f:	a8 01                	test   $0x1,%al
  801211:	74 0c                	je     80121f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801213:	8b 45 0c             	mov    0xc(%ebp),%eax
  801216:	89 10                	mov    %edx,(%eax)
  801218:	b8 00 00 00 00       	mov    $0x0,%eax
  80121d:	eb 05                	jmp    801224 <fd_lookup+0x46>
	return 0;
  80121f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801224:	5d                   	pop    %ebp
  801225:	c3                   	ret    

00801226 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801226:	55                   	push   %ebp
  801227:	89 e5                	mov    %esp,%ebp
  801229:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80122c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80122f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801233:	8b 45 08             	mov    0x8(%ebp),%eax
  801236:	89 04 24             	mov    %eax,(%esp)
  801239:	e8 a0 ff ff ff       	call   8011de <fd_lookup>
  80123e:	85 c0                	test   %eax,%eax
  801240:	78 0e                	js     801250 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801242:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801245:	8b 55 0c             	mov    0xc(%ebp),%edx
  801248:	89 50 04             	mov    %edx,0x4(%eax)
  80124b:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801250:	c9                   	leave  
  801251:	c3                   	ret    

00801252 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	53                   	push   %ebx
  801256:	83 ec 14             	sub    $0x14,%esp
  801259:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80125c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80125f:	ba 04 60 80 00       	mov    $0x806004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801264:	b8 00 00 00 00       	mov    $0x0,%eax
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801269:	39 0d 04 60 80 00    	cmp    %ecx,0x806004
  80126f:	75 11                	jne    801282 <dev_lookup+0x30>
  801271:	eb 04                	jmp    801277 <dev_lookup+0x25>
  801273:	39 0a                	cmp    %ecx,(%edx)
  801275:	75 0b                	jne    801282 <dev_lookup+0x30>
			*dev = devtab[i];
  801277:	89 13                	mov    %edx,(%ebx)
  801279:	b8 00 00 00 00       	mov    $0x0,%eax
  80127e:	66 90                	xchg   %ax,%ax
  801280:	eb 35                	jmp    8012b7 <dev_lookup+0x65>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801282:	83 c0 01             	add    $0x1,%eax
  801285:	8b 14 85 c8 2d 80 00 	mov    0x802dc8(,%eax,4),%edx
  80128c:	85 d2                	test   %edx,%edx
  80128e:	75 e3                	jne    801273 <dev_lookup+0x21>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  801290:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801295:	8b 40 4c             	mov    0x4c(%eax),%eax
  801298:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80129c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a0:	c7 04 24 4c 2d 80 00 	movl   $0x802d4c,(%esp)
  8012a7:	e8 f5 ef ff ff       	call   8002a1 <cprintf>
	*dev = 0;
  8012ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8012b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8012b7:	83 c4 14             	add    $0x14,%esp
  8012ba:	5b                   	pop    %ebx
  8012bb:	5d                   	pop    %ebp
  8012bc:	c3                   	ret    

008012bd <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
  8012c0:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c3:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8012c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8012cd:	89 04 24             	mov    %eax,(%esp)
  8012d0:	e8 09 ff ff ff       	call   8011de <fd_lookup>
  8012d5:	89 c2                	mov    %eax,%edx
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	78 5a                	js     801335 <fstat+0x78>
  8012db:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8012e5:	8b 00                	mov    (%eax),%eax
  8012e7:	89 04 24             	mov    %eax,(%esp)
  8012ea:	e8 63 ff ff ff       	call   801252 <dev_lookup>
  8012ef:	89 c2                	mov    %eax,%edx
  8012f1:	85 c0                	test   %eax,%eax
  8012f3:	78 40                	js     801335 <fstat+0x78>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8012f5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  8012fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012fd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801301:	74 32                	je     801335 <fstat+0x78>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801303:	8b 45 0c             	mov    0xc(%ebp),%eax
  801306:	c6 00 00             	movb   $0x0,(%eax)
	stat->st_size = 0;
  801309:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  801310:	00 00 00 
	stat->st_isdir = 0;
  801313:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
  80131a:	00 00 00 
	stat->st_dev = dev;
  80131d:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801320:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
	return (*dev->dev_stat)(fd, stat);
  801326:	89 44 24 04          	mov    %eax,0x4(%esp)
  80132a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80132d:	89 04 24             	mov    %eax,(%esp)
  801330:	ff 52 14             	call   *0x14(%edx)
  801333:	89 c2                	mov    %eax,%edx
}
  801335:	89 d0                	mov    %edx,%eax
  801337:	c9                   	leave  
  801338:	c3                   	ret    

00801339 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801339:	55                   	push   %ebp
  80133a:	89 e5                	mov    %esp,%ebp
  80133c:	53                   	push   %ebx
  80133d:	83 ec 24             	sub    $0x24,%esp
  801340:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801343:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801346:	89 44 24 04          	mov    %eax,0x4(%esp)
  80134a:	89 1c 24             	mov    %ebx,(%esp)
  80134d:	e8 8c fe ff ff       	call   8011de <fd_lookup>
  801352:	85 c0                	test   %eax,%eax
  801354:	78 61                	js     8013b7 <ftruncate+0x7e>
  801356:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801359:	8b 10                	mov    (%eax),%edx
  80135b:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80135e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801362:	89 14 24             	mov    %edx,(%esp)
  801365:	e8 e8 fe ff ff       	call   801252 <dev_lookup>
  80136a:	85 c0                	test   %eax,%eax
  80136c:	78 49                	js     8013b7 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80136e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801371:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801375:	75 23                	jne    80139a <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801377:	a1 3c 60 80 00       	mov    0x80603c,%eax
  80137c:	8b 40 4c             	mov    0x4c(%eax),%eax
  80137f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801383:	89 44 24 04          	mov    %eax,0x4(%esp)
  801387:	c7 04 24 6c 2d 80 00 	movl   $0x802d6c,(%esp)
  80138e:	e8 0e ef ff ff       	call   8002a1 <cprintf>
  801393:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801398:	eb 1d                	jmp    8013b7 <ftruncate+0x7e>
			env->env_id, fdnum); 
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80139a:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80139d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013a2:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  8013a6:	74 0f                	je     8013b7 <ftruncate+0x7e>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013a8:	8b 42 18             	mov    0x18(%edx),%eax
  8013ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013b2:	89 0c 24             	mov    %ecx,(%esp)
  8013b5:	ff d0                	call   *%eax
}
  8013b7:	83 c4 24             	add    $0x24,%esp
  8013ba:	5b                   	pop    %ebx
  8013bb:	5d                   	pop    %ebp
  8013bc:	c3                   	ret    

008013bd <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013bd:	55                   	push   %ebp
  8013be:	89 e5                	mov    %esp,%ebp
  8013c0:	53                   	push   %ebx
  8013c1:	83 ec 24             	sub    $0x24,%esp
  8013c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ce:	89 1c 24             	mov    %ebx,(%esp)
  8013d1:	e8 08 fe ff ff       	call   8011de <fd_lookup>
  8013d6:	85 c0                	test   %eax,%eax
  8013d8:	78 68                	js     801442 <write+0x85>
  8013da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013dd:	8b 10                	mov    (%eax),%edx
  8013df:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8013e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e6:	89 14 24             	mov    %edx,(%esp)
  8013e9:	e8 64 fe ff ff       	call   801252 <dev_lookup>
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	78 50                	js     801442 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013f2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  8013f5:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  8013f9:	75 23                	jne    80141e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  8013fb:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801400:	8b 40 4c             	mov    0x4c(%eax),%eax
  801403:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801407:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140b:	c7 04 24 8d 2d 80 00 	movl   $0x802d8d,(%esp)
  801412:	e8 8a ee ff ff       	call   8002a1 <cprintf>
  801417:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80141c:	eb 24                	jmp    801442 <write+0x85>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80141e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801421:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801426:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  80142a:	74 16                	je     801442 <write+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80142c:	8b 42 0c             	mov    0xc(%edx),%eax
  80142f:	8b 55 10             	mov    0x10(%ebp),%edx
  801432:	89 54 24 08          	mov    %edx,0x8(%esp)
  801436:	8b 55 0c             	mov    0xc(%ebp),%edx
  801439:	89 54 24 04          	mov    %edx,0x4(%esp)
  80143d:	89 0c 24             	mov    %ecx,(%esp)
  801440:	ff d0                	call   *%eax
}
  801442:	83 c4 24             	add    $0x24,%esp
  801445:	5b                   	pop    %ebx
  801446:	5d                   	pop    %ebp
  801447:	c3                   	ret    

00801448 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	53                   	push   %ebx
  80144c:	83 ec 24             	sub    $0x24,%esp
  80144f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801452:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801455:	89 44 24 04          	mov    %eax,0x4(%esp)
  801459:	89 1c 24             	mov    %ebx,(%esp)
  80145c:	e8 7d fd ff ff       	call   8011de <fd_lookup>
  801461:	85 c0                	test   %eax,%eax
  801463:	78 6d                	js     8014d2 <read+0x8a>
  801465:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801468:	8b 10                	mov    (%eax),%edx
  80146a:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80146d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801471:	89 14 24             	mov    %edx,(%esp)
  801474:	e8 d9 fd ff ff       	call   801252 <dev_lookup>
  801479:	85 c0                	test   %eax,%eax
  80147b:	78 55                	js     8014d2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80147d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801480:	8b 41 08             	mov    0x8(%ecx),%eax
  801483:	83 e0 03             	and    $0x3,%eax
  801486:	83 f8 01             	cmp    $0x1,%eax
  801489:	75 23                	jne    8014ae <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  80148b:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801490:	8b 40 4c             	mov    0x4c(%eax),%eax
  801493:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801497:	89 44 24 04          	mov    %eax,0x4(%esp)
  80149b:	c7 04 24 aa 2d 80 00 	movl   $0x802daa,(%esp)
  8014a2:	e8 fa ed ff ff       	call   8002a1 <cprintf>
  8014a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014ac:	eb 24                	jmp    8014d2 <read+0x8a>
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8014ae:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8014b1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014b6:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  8014ba:	74 16                	je     8014d2 <read+0x8a>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014bc:	8b 42 08             	mov    0x8(%edx),%eax
  8014bf:	8b 55 10             	mov    0x10(%ebp),%edx
  8014c2:	89 54 24 08          	mov    %edx,0x8(%esp)
  8014c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014cd:	89 0c 24             	mov    %ecx,(%esp)
  8014d0:	ff d0                	call   *%eax
}
  8014d2:	83 c4 24             	add    $0x24,%esp
  8014d5:	5b                   	pop    %ebx
  8014d6:	5d                   	pop    %ebp
  8014d7:	c3                   	ret    

008014d8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014d8:	55                   	push   %ebp
  8014d9:	89 e5                	mov    %esp,%ebp
  8014db:	57                   	push   %edi
  8014dc:	56                   	push   %esi
  8014dd:	53                   	push   %ebx
  8014de:	83 ec 0c             	sub    $0xc,%esp
  8014e1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8014e4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ec:	85 f6                	test   %esi,%esi
  8014ee:	74 36                	je     801526 <readn+0x4e>
  8014f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f5:	ba 00 00 00 00       	mov    $0x0,%edx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014fa:	89 f0                	mov    %esi,%eax
  8014fc:	29 d0                	sub    %edx,%eax
  8014fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801502:	8d 04 17             	lea    (%edi,%edx,1),%eax
  801505:	89 44 24 04          	mov    %eax,0x4(%esp)
  801509:	8b 45 08             	mov    0x8(%ebp),%eax
  80150c:	89 04 24             	mov    %eax,(%esp)
  80150f:	e8 34 ff ff ff       	call   801448 <read>
		if (m < 0)
  801514:	85 c0                	test   %eax,%eax
  801516:	78 0e                	js     801526 <readn+0x4e>
			return m;
		if (m == 0)
  801518:	85 c0                	test   %eax,%eax
  80151a:	74 08                	je     801524 <readn+0x4c>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80151c:	01 c3                	add    %eax,%ebx
  80151e:	89 da                	mov    %ebx,%edx
  801520:	39 f3                	cmp    %esi,%ebx
  801522:	72 d6                	jb     8014fa <readn+0x22>
  801524:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801526:	83 c4 0c             	add    $0xc,%esp
  801529:	5b                   	pop    %ebx
  80152a:	5e                   	pop    %esi
  80152b:	5f                   	pop    %edi
  80152c:	5d                   	pop    %ebp
  80152d:	c3                   	ret    

0080152e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80152e:	55                   	push   %ebp
  80152f:	89 e5                	mov    %esp,%ebp
  801531:	83 ec 28             	sub    $0x28,%esp
  801534:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801537:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80153a:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80153d:	89 34 24             	mov    %esi,(%esp)
  801540:	e8 1b fc ff ff       	call   801160 <fd2num>
  801545:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801548:	89 54 24 04          	mov    %edx,0x4(%esp)
  80154c:	89 04 24             	mov    %eax,(%esp)
  80154f:	e8 8a fc ff ff       	call   8011de <fd_lookup>
  801554:	89 c3                	mov    %eax,%ebx
  801556:	85 c0                	test   %eax,%eax
  801558:	78 05                	js     80155f <fd_close+0x31>
  80155a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80155d:	74 0d                	je     80156c <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80155f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801563:	75 44                	jne    8015a9 <fd_close+0x7b>
  801565:	bb 00 00 00 00       	mov    $0x0,%ebx
  80156a:	eb 3d                	jmp    8015a9 <fd_close+0x7b>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80156c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80156f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801573:	8b 06                	mov    (%esi),%eax
  801575:	89 04 24             	mov    %eax,(%esp)
  801578:	e8 d5 fc ff ff       	call   801252 <dev_lookup>
  80157d:	89 c3                	mov    %eax,%ebx
  80157f:	85 c0                	test   %eax,%eax
  801581:	78 16                	js     801599 <fd_close+0x6b>
		if (dev->dev_close)
  801583:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801586:	8b 40 10             	mov    0x10(%eax),%eax
  801589:	bb 00 00 00 00       	mov    $0x0,%ebx
  80158e:	85 c0                	test   %eax,%eax
  801590:	74 07                	je     801599 <fd_close+0x6b>
			r = (*dev->dev_close)(fd);
  801592:	89 34 24             	mov    %esi,(%esp)
  801595:	ff d0                	call   *%eax
  801597:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801599:	89 74 24 04          	mov    %esi,0x4(%esp)
  80159d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015a4:	e8 d5 f9 ff ff       	call   800f7e <sys_page_unmap>
	return r;
}
  8015a9:	89 d8                	mov    %ebx,%eax
  8015ab:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8015ae:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8015b1:	89 ec                	mov    %ebp,%esp
  8015b3:	5d                   	pop    %ebp
  8015b4:	c3                   	ret    

008015b5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015b5:	55                   	push   %ebp
  8015b6:	89 e5                	mov    %esp,%ebp
  8015b8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015bb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c5:	89 04 24             	mov    %eax,(%esp)
  8015c8:	e8 11 fc ff ff       	call   8011de <fd_lookup>
  8015cd:	85 c0                	test   %eax,%eax
  8015cf:	78 13                	js     8015e4 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8015d1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8015d8:	00 
  8015d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015dc:	89 04 24             	mov    %eax,(%esp)
  8015df:	e8 4a ff ff ff       	call   80152e <fd_close>
}
  8015e4:	c9                   	leave  
  8015e5:	c3                   	ret    

008015e6 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8015e6:	55                   	push   %ebp
  8015e7:	89 e5                	mov    %esp,%ebp
  8015e9:	83 ec 18             	sub    $0x18,%esp
  8015ec:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8015ef:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015f2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015f9:	00 
  8015fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fd:	89 04 24             	mov    %eax,(%esp)
  801600:	e8 5a 03 00 00       	call   80195f <open>
  801605:	89 c6                	mov    %eax,%esi
  801607:	85 c0                	test   %eax,%eax
  801609:	78 1b                	js     801626 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  80160b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80160e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801612:	89 34 24             	mov    %esi,(%esp)
  801615:	e8 a3 fc ff ff       	call   8012bd <fstat>
  80161a:	89 c3                	mov    %eax,%ebx
	close(fd);
  80161c:	89 34 24             	mov    %esi,(%esp)
  80161f:	e8 91 ff ff ff       	call   8015b5 <close>
  801624:	89 de                	mov    %ebx,%esi
	return r;
}
  801626:	89 f0                	mov    %esi,%eax
  801628:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80162b:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80162e:	89 ec                	mov    %ebp,%esp
  801630:	5d                   	pop    %ebp
  801631:	c3                   	ret    

00801632 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801632:	55                   	push   %ebp
  801633:	89 e5                	mov    %esp,%ebp
  801635:	83 ec 38             	sub    $0x38,%esp
  801638:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80163b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80163e:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801641:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801644:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801647:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164b:	8b 45 08             	mov    0x8(%ebp),%eax
  80164e:	89 04 24             	mov    %eax,(%esp)
  801651:	e8 88 fb ff ff       	call   8011de <fd_lookup>
  801656:	89 c3                	mov    %eax,%ebx
  801658:	85 c0                	test   %eax,%eax
  80165a:	0f 88 e1 00 00 00    	js     801741 <dup+0x10f>
		return r;
	close(newfdnum);
  801660:	89 3c 24             	mov    %edi,(%esp)
  801663:	e8 4d ff ff ff       	call   8015b5 <close>

	newfd = INDEX2FD(newfdnum);
  801668:	89 f8                	mov    %edi,%eax
  80166a:	c1 e0 0c             	shl    $0xc,%eax
  80166d:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  801673:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801676:	89 04 24             	mov    %eax,(%esp)
  801679:	e8 f2 fa ff ff       	call   801170 <fd2data>
  80167e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801680:	89 34 24             	mov    %esi,(%esp)
  801683:	e8 e8 fa ff ff       	call   801170 <fd2data>
  801688:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  80168b:	89 d8                	mov    %ebx,%eax
  80168d:	c1 e8 16             	shr    $0x16,%eax
  801690:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801697:	a8 01                	test   $0x1,%al
  801699:	74 45                	je     8016e0 <dup+0xae>
  80169b:	89 da                	mov    %ebx,%edx
  80169d:	c1 ea 0c             	shr    $0xc,%edx
  8016a0:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8016a7:	a8 01                	test   $0x1,%al
  8016a9:	74 35                	je     8016e0 <dup+0xae>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  8016ab:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8016b2:	25 07 0e 00 00       	and    $0xe07,%eax
  8016b7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016c2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016c9:	00 
  8016ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016d5:	e8 02 f9 ff ff       	call   800fdc <sys_page_map>
  8016da:	89 c3                	mov    %eax,%ebx
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	78 3e                	js     80171e <dup+0xec>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  8016e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016e3:	89 d0                	mov    %edx,%eax
  8016e5:	c1 e8 0c             	shr    $0xc,%eax
  8016e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016ef:	25 07 0e 00 00       	and    $0xe07,%eax
  8016f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016f8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8016fc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801703:	00 
  801704:	89 54 24 04          	mov    %edx,0x4(%esp)
  801708:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80170f:	e8 c8 f8 ff ff       	call   800fdc <sys_page_map>
  801714:	89 c3                	mov    %eax,%ebx
  801716:	85 c0                	test   %eax,%eax
  801718:	78 04                	js     80171e <dup+0xec>
		goto err;
  80171a:	89 fb                	mov    %edi,%ebx
  80171c:	eb 23                	jmp    801741 <dup+0x10f>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80171e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801722:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801729:	e8 50 f8 ff ff       	call   800f7e <sys_page_unmap>
	sys_page_unmap(0, nva);
  80172e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801731:	89 44 24 04          	mov    %eax,0x4(%esp)
  801735:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80173c:	e8 3d f8 ff ff       	call   800f7e <sys_page_unmap>
	return r;
}
  801741:	89 d8                	mov    %ebx,%eax
  801743:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801746:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801749:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80174c:	89 ec                	mov    %ebp,%esp
  80174e:	5d                   	pop    %ebp
  80174f:	c3                   	ret    

00801750 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801750:	55                   	push   %ebp
  801751:	89 e5                	mov    %esp,%ebp
  801753:	53                   	push   %ebx
  801754:	83 ec 04             	sub    $0x4,%esp
  801757:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  80175c:	89 1c 24             	mov    %ebx,(%esp)
  80175f:	e8 51 fe ff ff       	call   8015b5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801764:	83 c3 01             	add    $0x1,%ebx
  801767:	83 fb 20             	cmp    $0x20,%ebx
  80176a:	75 f0                	jne    80175c <close_all+0xc>
		close(i);
}
  80176c:	83 c4 04             	add    $0x4,%esp
  80176f:	5b                   	pop    %ebx
  801770:	5d                   	pop    %ebp
  801771:	c3                   	ret    
	...

00801774 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801774:	55                   	push   %ebp
  801775:	89 e5                	mov    %esp,%ebp
  801777:	53                   	push   %ebx
  801778:	83 ec 14             	sub    $0x14,%esp
  80177b:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80177d:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  801783:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80178a:	00 
  80178b:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801792:	00 
  801793:	89 44 24 04          	mov    %eax,0x4(%esp)
  801797:	89 14 24             	mov    %edx,(%esp)
  80179a:	e8 31 0d 00 00       	call   8024d0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80179f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017a6:	00 
  8017a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017b2:	e8 cd 0d 00 00       	call   802584 <ipc_recv>
}
  8017b7:	83 c4 14             	add    $0x14,%esp
  8017ba:	5b                   	pop    %ebx
  8017bb:	5d                   	pop    %ebp
  8017bc:	c3                   	ret    

008017bd <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c8:	b8 08 00 00 00       	mov    $0x8,%eax
  8017cd:	e8 a2 ff ff ff       	call   801774 <fsipc>
}
  8017d2:	c9                   	leave  
  8017d3:	c3                   	ret    

008017d4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017da:	8b 45 08             	mov    0x8(%ebp),%eax
  8017dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e0:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.set_size.req_size = newsize;
  8017e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e8:	a3 04 30 80 00       	mov    %eax,0x803004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f2:	b8 02 00 00 00       	mov    $0x2,%eax
  8017f7:	e8 78 ff ff ff       	call   801774 <fsipc>
}
  8017fc:	c9                   	leave  
  8017fd:	c3                   	ret    

008017fe <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017fe:	55                   	push   %ebp
  8017ff:	89 e5                	mov    %esp,%ebp
  801801:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801804:	8b 45 08             	mov    0x8(%ebp),%eax
  801807:	8b 40 0c             	mov    0xc(%eax),%eax
  80180a:	a3 00 30 80 00       	mov    %eax,0x803000
	return fsipc(FSREQ_FLUSH, NULL);
  80180f:	ba 00 00 00 00       	mov    $0x0,%edx
  801814:	b8 06 00 00 00       	mov    $0x6,%eax
  801819:	e8 56 ff ff ff       	call   801774 <fsipc>
}
  80181e:	c9                   	leave  
  80181f:	c3                   	ret    

00801820 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	53                   	push   %ebx
  801824:	83 ec 14             	sub    $0x14,%esp
  801827:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80182a:	8b 45 08             	mov    0x8(%ebp),%eax
  80182d:	8b 40 0c             	mov    0xc(%eax),%eax
  801830:	a3 00 30 80 00       	mov    %eax,0x803000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801835:	ba 00 00 00 00       	mov    $0x0,%edx
  80183a:	b8 05 00 00 00       	mov    $0x5,%eax
  80183f:	e8 30 ff ff ff       	call   801774 <fsipc>
  801844:	85 c0                	test   %eax,%eax
  801846:	78 2b                	js     801873 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801848:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  80184f:	00 
  801850:	89 1c 24             	mov    %ebx,(%esp)
  801853:	e8 a9 f0 ff ff       	call   800901 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801858:	a1 80 30 80 00       	mov    0x803080,%eax
  80185d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801863:	a1 84 30 80 00       	mov    0x803084,%eax
  801868:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  80186e:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801873:	83 c4 14             	add    $0x14,%esp
  801876:	5b                   	pop    %ebx
  801877:	5d                   	pop    %ebp
  801878:	c3                   	ret    

00801879 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	83 ec 18             	sub    $0x18,%esp
  80187f:	8b 55 10             	mov    0x10(%ebp),%edx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	ssize_t writesize;
	size_t bufsize;
	fsipcbuf.write.req_fileid=fd->fd_file.id;
  801882:	8b 45 08             	mov    0x8(%ebp),%eax
  801885:	8b 40 0c             	mov    0xc(%eax),%eax
  801888:	a3 00 30 80 00       	mov    %eax,0x803000
	bufsize=sizeof(fsipcbuf.write.req_buf);
	if(n<bufsize)
  80188d:	89 d0                	mov    %edx,%eax
  80188f:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  801895:	76 05                	jbe    80189c <devfile_write+0x23>
  801897:	b8 f8 0f 00 00       	mov    $0xff8,%eax
		bufsize=n;	
	fsipcbuf.write.req_n=n;
  80189c:	89 15 04 30 80 00    	mov    %edx,0x803004
	memmove((void*)fsipcbuf.write.req_buf,buf,bufsize);
  8018a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ad:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  8018b4:	e8 4f f2 ff ff       	call   800b08 <memmove>
	writesize=(ssize_t)fsipc(FSREQ_WRITE,NULL);
  8018b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018be:	b8 04 00 00 00       	mov    $0x4,%eax
  8018c3:	e8 ac fe ff ff       	call   801774 <fsipc>
	return writesize;
	//panic("devfile_write not implemented");
}
  8018c8:	c9                   	leave  
  8018c9:	c3                   	ret    

008018ca <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	53                   	push   %ebx
  8018ce:	83 ec 14             	sub    $0x14,%esp
	// system server.
	// LAB 5: Your code here
	ssize_t readsize;
	if(debug)
		cprintf("devfile_read:fileid=%x readsize=%x\n",fd->fd_file.id,n);
	fsipcbuf.read.req_fileid=fd->fd_file.id;
  8018d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d7:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.read.req_n=n;
  8018dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8018df:	a3 04 30 80 00       	mov    %eax,0x803004
	readsize=(ssize_t)fsipc(FSREQ_READ,&fsipcbuf);
  8018e4:	ba 00 30 80 00       	mov    $0x803000,%edx
  8018e9:	b8 03 00 00 00       	mov    $0x3,%eax
  8018ee:	e8 81 fe ff ff       	call   801774 <fsipc>
  8018f3:	89 c3                	mov    %eax,%ebx
	//cprintf("readsize=%d\n",readsize);
	if(debug)
		cprintf("devfile_read:buf1=%s\nbuf2=%s\n",(char*)&fsipcbuf,fsipcbuf.readRet.ret_buf);
	if(readsize>0)
  8018f5:	85 c0                	test   %eax,%eax
  8018f7:	7e 17                	jle    801910 <devfile_read+0x46>
		memmove(buf,(void*)&fsipcbuf,(size_t)readsize);
  8018f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018fd:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801904:	00 
  801905:	8b 45 0c             	mov    0xc(%ebp),%eax
  801908:	89 04 24             	mov    %eax,(%esp)
  80190b:	e8 f8 f1 ff ff       	call   800b08 <memmove>
	//cprintf("readsize=%d",readsize);
	return readsize;
	//panic("devfile_read not implemented");
}
  801910:	89 d8                	mov    %ebx,%eax
  801912:	83 c4 14             	add    $0x14,%esp
  801915:	5b                   	pop    %ebx
  801916:	5d                   	pop    %ebp
  801917:	c3                   	ret    

00801918 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801918:	55                   	push   %ebp
  801919:	89 e5                	mov    %esp,%ebp
  80191b:	53                   	push   %ebx
  80191c:	83 ec 14             	sub    $0x14,%esp
  80191f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801922:	89 1c 24             	mov    %ebx,(%esp)
  801925:	e8 86 ef ff ff       	call   8008b0 <strlen>
  80192a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  80192f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801934:	7f 21                	jg     801957 <remove+0x3f>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801936:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80193a:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801941:	e8 bb ef ff ff       	call   800901 <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801946:	ba 00 00 00 00       	mov    $0x0,%edx
  80194b:	b8 07 00 00 00       	mov    $0x7,%eax
  801950:	e8 1f fe ff ff       	call   801774 <fsipc>
  801955:	89 c2                	mov    %eax,%edx
}
  801957:	89 d0                	mov    %edx,%eax
  801959:	83 c4 14             	add    $0x14,%esp
  80195c:	5b                   	pop    %ebx
  80195d:	5d                   	pop    %ebp
  80195e:	c3                   	ret    

0080195f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80195f:	55                   	push   %ebp
  801960:	89 e5                	mov    %esp,%ebp
  801962:	56                   	push   %esi
  801963:	53                   	push   %ebx
  801964:	83 ec 30             	sub    $0x30,%esp

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;
	void *page;
	if((r=fd_alloc(&fd))<0){
  801967:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80196a:	89 04 24             	mov    %eax,(%esp)
  80196d:	e8 19 f8 ff ff       	call   80118b <fd_alloc>
  801972:	89 c3                	mov    %eax,%ebx
  801974:	85 c0                	test   %eax,%eax
  801976:	79 18                	jns    801990 <open+0x31>
		fd_close(fd,0);
  801978:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80197f:	00 
  801980:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801983:	89 04 24             	mov    %eax,(%esp)
  801986:	e8 a3 fb ff ff       	call   80152e <fd_close>
  80198b:	e9 9f 00 00 00       	jmp    801a2f <open+0xd0>
		return r;
	}
	//cprintf("open:fd=%x\n",fd);
	strcpy(fsipcbuf.open.req_path,path);
  801990:	8b 45 08             	mov    0x8(%ebp),%eax
  801993:	89 44 24 04          	mov    %eax,0x4(%esp)
  801997:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  80199e:	e8 5e ef ff ff       	call   800901 <strcpy>
	fsipcbuf.open.req_omode=mode;
  8019a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a6:	a3 00 34 80 00       	mov    %eax,0x803400
	page=(void*)fd2data(fd);
  8019ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ae:	89 04 24             	mov    %eax,(%esp)
  8019b1:	e8 ba f7 ff ff       	call   801170 <fd2data>
  8019b6:	89 c6                	mov    %eax,%esi
	if((r=fsipc(FSREQ_OPEN,(void*)fd))<0)
  8019b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019bb:	b8 01 00 00 00       	mov    $0x1,%eax
  8019c0:	e8 af fd ff ff       	call   801774 <fsipc>
  8019c5:	89 c3                	mov    %eax,%ebx
  8019c7:	85 c0                	test   %eax,%eax
  8019c9:	79 15                	jns    8019e0 <open+0x81>
	{
		fd_close(fd,1);
  8019cb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8019d2:	00 
  8019d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d6:	89 04 24             	mov    %eax,(%esp)
  8019d9:	e8 50 fb ff ff       	call   80152e <fd_close>
  8019de:	eb 4f                	jmp    801a2f <open+0xd0>
		return r;	
	}
	//cprintf("open:page=%x\n",page);
	if((r=sys_page_map(0,(void*)fd,0,(void*)page,PTE_P | PTE_W | PTE_U))<0)
  8019e0:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8019e7:	00 
  8019e8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8019ec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019f3:	00 
  8019f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a02:	e8 d5 f5 ff ff       	call   800fdc <sys_page_map>
  801a07:	89 c3                	mov    %eax,%ebx
  801a09:	85 c0                	test   %eax,%eax
  801a0b:	79 15                	jns    801a22 <open+0xc3>
	{
		fd_close(fd,1);
  801a0d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a14:	00 
  801a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a18:	89 04 24             	mov    %eax,(%esp)
  801a1b:	e8 0e fb ff ff       	call   80152e <fd_close>
  801a20:	eb 0d                	jmp    801a2f <open+0xd0>
		return r;
	}
	//cprintf("open:fileid=%x\n",fd->fd_file.id);
	return fd2num(fd);
  801a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a25:	89 04 24             	mov    %eax,(%esp)
  801a28:	e8 33 f7 ff ff       	call   801160 <fd2num>
  801a2d:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801a2f:	89 d8                	mov    %ebx,%eax
  801a31:	83 c4 30             	add    $0x30,%esp
  801a34:	5b                   	pop    %ebx
  801a35:	5e                   	pop    %esi
  801a36:	5d                   	pop    %ebp
  801a37:	c3                   	ret    

00801a38 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	57                   	push   %edi
  801a3c:	56                   	push   %esi
  801a3d:	53                   	push   %ebx
  801a3e:	81 ec 9c 02 00 00    	sub    $0x29c,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801a44:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a4b:	00 
  801a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4f:	89 04 24             	mov    %eax,(%esp)
  801a52:	e8 08 ff ff ff       	call   80195f <open>
  801a57:	89 85 a0 fd ff ff    	mov    %eax,-0x260(%ebp)
  801a5d:	89 85 9c fd ff ff    	mov    %eax,-0x264(%ebp)
  801a63:	85 c0                	test   %eax,%eax
  801a65:	0f 88 5e 05 00 00    	js     801fc9 <spawn+0x591>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (read(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801a6b:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801a72:	00 
  801a73:	8d 85 f4 fd ff ff    	lea    -0x20c(%ebp),%eax
  801a79:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a7d:	8b 95 a0 fd ff ff    	mov    -0x260(%ebp),%edx
  801a83:	89 14 24             	mov    %edx,(%esp)
  801a86:	e8 bd f9 ff ff       	call   801448 <read>
  801a8b:	3d 00 02 00 00       	cmp    $0x200,%eax
  801a90:	75 0c                	jne    801a9e <spawn+0x66>
  801a92:	81 bd f4 fd ff ff 7f 	cmpl   $0x464c457f,-0x20c(%ebp)
  801a99:	45 4c 46 
  801a9c:	74 3b                	je     801ad9 <spawn+0xa1>
	    || elf->e_magic != ELF_MAGIC) {
		close(fd);
  801a9e:	8b 8d a0 fd ff ff    	mov    -0x260(%ebp),%ecx
  801aa4:	89 0c 24             	mov    %ecx,(%esp)
  801aa7:	e8 09 fb ff ff       	call   8015b5 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801aac:	8b 85 f4 fd ff ff    	mov    -0x20c(%ebp),%eax
  801ab2:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801ab9:	46 
  801aba:	89 44 24 04          	mov    %eax,0x4(%esp)
  801abe:	c7 04 24 d4 2d 80 00 	movl   $0x802dd4,(%esp)
  801ac5:	e8 d7 e7 ff ff       	call   8002a1 <cprintf>
  801aca:	c7 85 9c fd ff ff f2 	movl   $0xfffffff2,-0x264(%ebp)
  801ad1:	ff ff ff 
  801ad4:	e9 f0 04 00 00       	jmp    801fc9 <spawn+0x591>
static __inline envid_t sys_exofork(void) __attribute__((always_inline));
static __inline envid_t
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801ad9:	ba 07 00 00 00       	mov    $0x7,%edx
  801ade:	89 d0                	mov    %edx,%eax
  801ae0:	cd 30                	int    $0x30
  801ae2:	89 85 9c fd ff ff    	mov    %eax,-0x264(%ebp)
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801ae8:	85 c0                	test   %eax,%eax
  801aea:	0f 88 d9 04 00 00    	js     801fc9 <spawn+0x591>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801af0:	25 ff 03 00 00       	and    $0x3ff,%eax
  801af5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801af8:	8d 95 b0 fd ff ff    	lea    -0x250(%ebp),%edx
  801afe:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b03:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
  801b0a:	00 
  801b0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b0f:	89 14 24             	mov    %edx,(%esp)
  801b12:	e8 71 f0 ff ff       	call   800b88 <memcpy>
	child_tf.tf_eip = elf->e_entry;
  801b17:	8b 85 0c fe ff ff    	mov    -0x1f4(%ebp),%eax
  801b1d:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801b23:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b26:	8b 02                	mov    (%edx),%eax
  801b28:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b2d:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801b34:	00 00 00 
  801b37:	85 c0                	test   %eax,%eax
  801b39:	75 11                	jne    801b4c <spawn+0x114>
  801b3b:	bf 00 00 00 00       	mov    $0x0,%edi
  801b40:	c7 85 84 fd ff ff 00 	movl   $0x0,-0x27c(%ebp)
  801b47:	00 00 00 
  801b4a:	eb 30                	jmp    801b7c <spawn+0x144>
		string_size += strlen(argv[argc]) + 1;
  801b4c:	89 04 24             	mov    %eax,(%esp)
  801b4f:	e8 5c ed ff ff       	call   8008b0 <strlen>
  801b54:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801b58:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  801b5f:	8b bd 7c fd ff ff    	mov    -0x284(%ebp),%edi
  801b65:	8d 0c bd 00 00 00 00 	lea    0x0(,%edi,4),%ecx
  801b6c:	89 8d 84 fd ff ff    	mov    %ecx,-0x27c(%ebp)
  801b72:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b75:	8b 04 ba             	mov    (%edx,%edi,4),%eax
  801b78:	85 c0                	test   %eax,%eax
  801b7a:	75 d0                	jne    801b4c <spawn+0x114>
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801b7c:	b8 00 10 40 00       	mov    $0x401000,%eax
  801b81:	89 c6                	mov    %eax,%esi
  801b83:	29 de                	sub    %ebx,%esi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801b85:	89 f2                	mov    %esi,%edx
  801b87:	83 e2 fc             	and    $0xfffffffc,%edx
  801b8a:	8b 8d 7c fd ff ff    	mov    -0x284(%ebp),%ecx
  801b90:	8d 04 8d 04 00 00 00 	lea    0x4(,%ecx,4),%eax
  801b97:	29 c2                	sub    %eax,%edx
  801b99:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  801b9f:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
	
	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801ba5:	89 d0                	mov    %edx,%eax
  801ba7:	83 e8 08             	sub    $0x8,%eax

	return child;

error:
	sys_env_destroy(child);
	close(fd);
  801baa:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
	
	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801baf:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801bb4:	0f 86 09 04 00 00    	jbe    801fc3 <spawn+0x58b>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801bba:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801bc1:	00 
  801bc2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801bc9:	00 
  801bca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bd1:	e8 64 f4 ff ff       	call   80103a <sys_page_alloc>
  801bd6:	89 c2                	mov    %eax,%edx
  801bd8:	85 c0                	test   %eax,%eax
  801bda:	0f 88 e3 03 00 00    	js     801fc3 <spawn+0x58b>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801be0:	83 bd 7c fd ff ff 00 	cmpl   $0x0,-0x284(%ebp)
  801be7:	7e 43                	jle    801c2c <spawn+0x1f4>
  801be9:	bb 00 00 00 00       	mov    $0x0,%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  801bee:	8d 86 00 d0 7f ee    	lea    -0x11803000(%esi),%eax
  801bf4:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801bfa:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  801bfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c00:	8b 04 99             	mov    (%ecx,%ebx,4),%eax
  801c03:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c07:	89 34 24             	mov    %esi,(%esp)
  801c0a:	e8 f2 ec ff ff       	call   800901 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801c0f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c12:	8b 04 9a             	mov    (%edx,%ebx,4),%eax
  801c15:	89 04 24             	mov    %eax,(%esp)
  801c18:	e8 93 ec ff ff       	call   8008b0 <strlen>
  801c1d:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801c21:	83 c3 01             	add    $0x1,%ebx
  801c24:	3b 9d 7c fd ff ff    	cmp    -0x284(%ebp),%ebx
  801c2a:	75 c2                	jne    801bee <spawn+0x1b6>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801c2c:	8b 8d 84 fd ff ff    	mov    -0x27c(%ebp),%ecx
  801c32:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801c38:	c7 04 01 00 00 00 00 	movl   $0x0,(%ecx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801c3f:	81 fe 00 10 40 00    	cmp    $0x401000,%esi
  801c45:	74 24                	je     801c6b <spawn+0x233>
  801c47:	c7 44 24 0c 60 2e 80 	movl   $0x802e60,0xc(%esp)
  801c4e:	00 
  801c4f:	c7 44 24 08 ee 2d 80 	movl   $0x802dee,0x8(%esp)
  801c56:	00 
  801c57:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
  801c5e:	00 
  801c5f:	c7 04 24 03 2e 80 00 	movl   $0x802e03,(%esp)
  801c66:	e8 69 e5 ff ff       	call   8001d4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801c6b:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801c71:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801c76:	8b 95 78 fd ff ff    	mov    -0x288(%ebp),%edx
  801c7c:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801c7f:	89 7a f8             	mov    %edi,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801c82:	89 d0                	mov    %edx,%eax
  801c84:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801c89:	89 85 ec fd ff ff    	mov    %eax,-0x214(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801c8f:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801c96:	00 
  801c97:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801c9e:	ee 
  801c9f:	8b 8d 9c fd ff ff    	mov    -0x264(%ebp),%ecx
  801ca5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ca9:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801cb0:	00 
  801cb1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cb8:	e8 1f f3 ff ff       	call   800fdc <sys_page_map>
  801cbd:	89 c3                	mov    %eax,%ebx
  801cbf:	85 c0                	test   %eax,%eax
  801cc1:	78 1a                	js     801cdd <spawn+0x2a5>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801cc3:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801cca:	00 
  801ccb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cd2:	e8 a7 f2 ff ff       	call   800f7e <sys_page_unmap>
  801cd7:	89 c3                	mov    %eax,%ebx
  801cd9:	85 c0                	test   %eax,%eax
  801cdb:	79 1f                	jns    801cfc <spawn+0x2c4>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801cdd:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ce4:	00 
  801ce5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cec:	e8 8d f2 ff ff       	call   800f7e <sys_page_unmap>
  801cf1:	89 9d 9c fd ff ff    	mov    %ebx,-0x264(%ebp)
  801cf7:	e9 cd 02 00 00       	jmp    801fc9 <spawn+0x591>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801cfc:	8b 85 10 fe ff ff    	mov    -0x1f0(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d02:	66 83 bd 20 fe ff ff 	cmpw   $0x0,-0x1e0(%ebp)
  801d09:	00 
  801d0a:	0f 84 0b 02 00 00    	je     801f1b <spawn+0x4e3>
  801d10:	8d 84 05 14 fe ff ff 	lea    -0x1ec(%ebp,%eax,1),%eax
  801d17:	89 85 98 fd ff ff    	mov    %eax,-0x268(%ebp)
  801d1d:	c7 85 70 fd ff ff 00 	movl   $0x0,-0x290(%ebp)
  801d24:	00 00 00 
		if (ph->p_type != ELF_PROG_LOAD)
  801d27:	8b 85 98 fd ff ff    	mov    -0x268(%ebp),%eax
  801d2d:	83 78 e0 01          	cmpl   $0x1,-0x20(%eax)
  801d31:	0f 85 c3 01 00 00    	jne    801efa <spawn+0x4c2>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801d37:	89 c2                	mov    %eax,%edx
  801d39:	8b 40 f8             	mov    -0x8(%eax),%eax
  801d3c:	83 e0 02             	and    $0x2,%eax
  801d3f:	83 f8 01             	cmp    $0x1,%eax
  801d42:	19 c9                	sbb    %ecx,%ecx
  801d44:	83 e1 fe             	and    $0xfffffffe,%ecx
  801d47:	83 c1 07             	add    $0x7,%ecx
  801d4a:	89 8d 74 fd ff ff    	mov    %ecx,-0x28c(%ebp)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz, 
  801d50:	8b 42 e4             	mov    -0x1c(%edx),%eax
  801d53:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801d59:	8b 52 f0             	mov    -0x10(%edx),%edx
  801d5c:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801d62:	8b 8d 98 fd ff ff    	mov    -0x268(%ebp),%ecx
  801d68:	8b 49 f4             	mov    -0xc(%ecx),%ecx
  801d6b:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  801d71:	8b 85 98 fd ff ff    	mov    -0x268(%ebp),%eax
  801d77:	8b 40 e8             	mov    -0x18(%eax),%eax
  801d7a:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801d80:	25 ff 0f 00 00       	and    $0xfff,%eax
  801d85:	74 1c                	je     801da3 <spawn+0x36b>
		va -= i;
  801d87:	29 85 94 fd ff ff    	sub    %eax,-0x26c(%ebp)
		memsz += i;
  801d8d:	01 c1                	add    %eax,%ecx
  801d8f:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
		filesz += i;
  801d95:	01 c2                	add    %eax,%edx
  801d97:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		fileoffset -= i;
  801d9d:	29 85 88 fd ff ff    	sub    %eax,-0x278(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801da3:	83 bd 90 fd ff ff 00 	cmpl   $0x0,-0x270(%ebp)
  801daa:	0f 84 4a 01 00 00    	je     801efa <spawn+0x4c2>
  801db0:	bf 00 00 00 00       	mov    $0x0,%edi
  801db5:	be 00 00 00 00       	mov    $0x0,%esi
		if (i >= filesz) {
  801dba:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  801dc0:	77 34                	ja     801df6 <spawn+0x3be>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801dc2:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801dc8:	8d 04 16             	lea    (%esi,%edx,1),%eax
  801dcb:	8b 8d 74 fd ff ff    	mov    -0x28c(%ebp),%ecx
  801dd1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dd5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd9:	8b 85 9c fd ff ff    	mov    -0x264(%ebp),%eax
  801ddf:	89 04 24             	mov    %eax,(%esp)
  801de2:	e8 53 f2 ff ff       	call   80103a <sys_page_alloc>
  801de7:	89 c3                	mov    %eax,%ebx
  801de9:	85 c0                	test   %eax,%eax
  801deb:	0f 89 f5 00 00 00    	jns    801ee6 <spawn+0x4ae>
  801df1:	e9 a9 01 00 00       	jmp    801f9f <spawn+0x567>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801df6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801dfd:	00 
  801dfe:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e05:	00 
  801e06:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e0d:	e8 28 f2 ff ff       	call   80103a <sys_page_alloc>
  801e12:	89 c3                	mov    %eax,%ebx
  801e14:	85 c0                	test   %eax,%eax
  801e16:	0f 88 83 01 00 00    	js     801f9f <spawn+0x567>
  801e1c:	8b 95 88 fd ff ff    	mov    -0x278(%ebp),%edx
  801e22:	8d 04 17             	lea    (%edi,%edx,1),%eax
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801e25:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e29:	8b 8d a0 fd ff ff    	mov    -0x260(%ebp),%ecx
  801e2f:	89 0c 24             	mov    %ecx,(%esp)
  801e32:	e8 ef f3 ff ff       	call   801226 <seek>
  801e37:	89 c3                	mov    %eax,%ebx
  801e39:	85 c0                	test   %eax,%eax
  801e3b:	0f 88 5e 01 00 00    	js     801f9f <spawn+0x567>
				return r;
			if ((r = read(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801e41:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801e47:	29 f0                	sub    %esi,%eax
  801e49:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801e4e:	76 05                	jbe    801e55 <spawn+0x41d>
  801e50:	b8 00 10 00 00       	mov    $0x1000,%eax
  801e55:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e59:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e60:	00 
  801e61:	8b 85 a0 fd ff ff    	mov    -0x260(%ebp),%eax
  801e67:	89 04 24             	mov    %eax,(%esp)
  801e6a:	e8 d9 f5 ff ff       	call   801448 <read>
  801e6f:	89 c3                	mov    %eax,%ebx
  801e71:	85 c0                	test   %eax,%eax
  801e73:	0f 88 26 01 00 00    	js     801f9f <spawn+0x567>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801e79:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801e7f:	8d 04 16             	lea    (%esi,%edx,1),%eax
  801e82:	8b 8d 74 fd ff ff    	mov    -0x28c(%ebp),%ecx
  801e88:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801e8c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e90:	8b 85 9c fd ff ff    	mov    -0x264(%ebp),%eax
  801e96:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e9a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ea1:	00 
  801ea2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ea9:	e8 2e f1 ff ff       	call   800fdc <sys_page_map>
  801eae:	85 c0                	test   %eax,%eax
  801eb0:	79 20                	jns    801ed2 <spawn+0x49a>
				panic("spawn: sys_page_map data: %e", r);
  801eb2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eb6:	c7 44 24 08 0f 2e 80 	movl   $0x802e0f,0x8(%esp)
  801ebd:	00 
  801ebe:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
  801ec5:	00 
  801ec6:	c7 04 24 03 2e 80 00 	movl   $0x802e03,(%esp)
  801ecd:	e8 02 e3 ff ff       	call   8001d4 <_panic>
			sys_page_unmap(0, UTEMP);
  801ed2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ed9:	00 
  801eda:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ee1:	e8 98 f0 ff ff       	call   800f7e <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801ee6:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801eec:	89 fe                	mov    %edi,%esi
  801eee:	39 bd 90 fd ff ff    	cmp    %edi,-0x270(%ebp)
  801ef4:	0f 87 c0 fe ff ff    	ja     801dba <spawn+0x382>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801efa:	83 85 70 fd ff ff 01 	addl   $0x1,-0x290(%ebp)
  801f01:	83 85 98 fd ff ff 20 	addl   $0x20,-0x268(%ebp)
  801f08:	0f b7 85 20 fe ff ff 	movzwl -0x1e0(%ebp),%eax
  801f0f:	3b 85 70 fd ff ff    	cmp    -0x290(%ebp),%eax
  801f15:	0f 8f 0c fe ff ff    	jg     801d27 <spawn+0x2ef>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz, 
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801f1b:	8b 95 a0 fd ff ff    	mov    -0x260(%ebp),%edx
  801f21:	89 14 24             	mov    %edx,(%esp)
  801f24:	e8 8c f6 ff ff       	call   8015b5 <close>
	fd = -1;

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801f29:	8d 85 b0 fd ff ff    	lea    -0x250(%ebp),%eax
  801f2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f33:	8b 8d 9c fd ff ff    	mov    -0x264(%ebp),%ecx
  801f39:	89 0c 24             	mov    %ecx,(%esp)
  801f3c:	e8 81 ef ff ff       	call   800ec2 <sys_env_set_trapframe>
  801f41:	85 c0                	test   %eax,%eax
  801f43:	79 20                	jns    801f65 <spawn+0x52d>
		panic("sys_env_set_trapframe: %e", r);
  801f45:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f49:	c7 44 24 08 2c 2e 80 	movl   $0x802e2c,0x8(%esp)
  801f50:	00 
  801f51:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801f58:	00 
  801f59:	c7 04 24 03 2e 80 00 	movl   $0x802e03,(%esp)
  801f60:	e8 6f e2 ff ff       	call   8001d4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801f65:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801f6c:	00 
  801f6d:	8b 85 9c fd ff ff    	mov    -0x264(%ebp),%eax
  801f73:	89 04 24             	mov    %eax,(%esp)
  801f76:	e8 a5 ef ff ff       	call   800f20 <sys_env_set_status>
  801f7b:	85 c0                	test   %eax,%eax
  801f7d:	79 4a                	jns    801fc9 <spawn+0x591>
		panic("sys_env_set_status: %e", r);
  801f7f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f83:	c7 44 24 08 46 2e 80 	movl   $0x802e46,0x8(%esp)
  801f8a:	00 
  801f8b:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  801f92:	00 
  801f93:	c7 04 24 03 2e 80 00 	movl   $0x802e03,(%esp)
  801f9a:	e8 35 e2 ff ff       	call   8001d4 <_panic>

	return child;

error:
	sys_env_destroy(child);
  801f9f:	8b 95 9c fd ff ff    	mov    -0x264(%ebp),%edx
  801fa5:	89 14 24             	mov    %edx,(%esp)
  801fa8:	e8 54 f1 ff ff       	call   801101 <sys_env_destroy>
	close(fd);
  801fad:	8b 8d a0 fd ff ff    	mov    -0x260(%ebp),%ecx
  801fb3:	89 0c 24             	mov    %ecx,(%esp)
  801fb6:	e8 fa f5 ff ff       	call   8015b5 <close>
  801fbb:	89 9d 9c fd ff ff    	mov    %ebx,-0x264(%ebp)
  801fc1:	eb 06                	jmp    801fc9 <spawn+0x591>
  801fc3:	89 95 9c fd ff ff    	mov    %edx,-0x264(%ebp)
	return r;
}
  801fc9:	8b 85 9c fd ff ff    	mov    -0x264(%ebp),%eax
  801fcf:	81 c4 9c 02 00 00    	add    $0x29c,%esp
  801fd5:	5b                   	pop    %ebx
  801fd6:	5e                   	pop    %esi
  801fd7:	5f                   	pop    %edi
  801fd8:	5d                   	pop    %ebp
  801fd9:	c3                   	ret    

00801fda <spawnl>:

// Spawn, taking command-line arguments array directly on the stack.
int
spawnl(const char *prog, const char *arg0, ...)
{
  801fda:	55                   	push   %ebp
  801fdb:	89 e5                	mov    %esp,%ebp
  801fdd:	83 ec 08             	sub    $0x8,%esp
	return spawn(prog, &arg0);
  801fe0:	8d 45 0c             	lea    0xc(%ebp),%eax
  801fe3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe7:	8b 45 08             	mov    0x8(%ebp),%eax
  801fea:	89 04 24             	mov    %eax,(%esp)
  801fed:	e8 46 fa ff ff       	call   801a38 <spawn>
}
  801ff2:	c9                   	leave  
  801ff3:	c3                   	ret    
	...

00802000 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802000:	55                   	push   %ebp
  802001:	89 e5                	mov    %esp,%ebp
  802003:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  802006:	c7 44 24 04 88 2e 80 	movl   $0x802e88,0x4(%esp)
  80200d:	00 
  80200e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802011:	89 04 24             	mov    %eax,(%esp)
  802014:	e8 e8 e8 ff ff       	call   800901 <strcpy>
	return 0;
}
  802019:	b8 00 00 00 00       	mov    $0x0,%eax
  80201e:	c9                   	leave  
  80201f:	c3                   	ret    

00802020 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	83 ec 08             	sub    $0x8,%esp
	return nsipc_close(fd->fd_sock.sockid);
  802026:	8b 45 08             	mov    0x8(%ebp),%eax
  802029:	8b 40 0c             	mov    0xc(%eax),%eax
  80202c:	89 04 24             	mov    %eax,(%esp)
  80202f:	e8 9e 02 00 00       	call   8022d2 <nsipc_close>
}
  802034:	c9                   	leave  
  802035:	c3                   	ret    

00802036 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802036:	55                   	push   %ebp
  802037:	89 e5                	mov    %esp,%ebp
  802039:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80203c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802043:	00 
  802044:	8b 45 10             	mov    0x10(%ebp),%eax
  802047:	89 44 24 08          	mov    %eax,0x8(%esp)
  80204b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80204e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802052:	8b 45 08             	mov    0x8(%ebp),%eax
  802055:	8b 40 0c             	mov    0xc(%eax),%eax
  802058:	89 04 24             	mov    %eax,(%esp)
  80205b:	e8 ae 02 00 00       	call   80230e <nsipc_send>
}
  802060:	c9                   	leave  
  802061:	c3                   	ret    

00802062 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  802062:	55                   	push   %ebp
  802063:	89 e5                	mov    %esp,%ebp
  802065:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802068:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80206f:	00 
  802070:	8b 45 10             	mov    0x10(%ebp),%eax
  802073:	89 44 24 08          	mov    %eax,0x8(%esp)
  802077:	8b 45 0c             	mov    0xc(%ebp),%eax
  80207a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80207e:	8b 45 08             	mov    0x8(%ebp),%eax
  802081:	8b 40 0c             	mov    0xc(%eax),%eax
  802084:	89 04 24             	mov    %eax,(%esp)
  802087:	e8 f5 02 00 00       	call   802381 <nsipc_recv>
}
  80208c:	c9                   	leave  
  80208d:	c3                   	ret    

0080208e <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  80208e:	55                   	push   %ebp
  80208f:	89 e5                	mov    %esp,%ebp
  802091:	56                   	push   %esi
  802092:	53                   	push   %ebx
  802093:	83 ec 20             	sub    $0x20,%esp
  802096:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802098:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80209b:	89 04 24             	mov    %eax,(%esp)
  80209e:	e8 e8 f0 ff ff       	call   80118b <fd_alloc>
  8020a3:	89 c3                	mov    %eax,%ebx
  8020a5:	85 c0                	test   %eax,%eax
  8020a7:	78 21                	js     8020ca <alloc_sockfd+0x3c>
  8020a9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8020b0:	00 
  8020b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020bf:	e8 76 ef ff ff       	call   80103a <sys_page_alloc>
  8020c4:	89 c3                	mov    %eax,%ebx
  8020c6:	85 c0                	test   %eax,%eax
  8020c8:	79 0a                	jns    8020d4 <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U)) < 0) {
		nsipc_close(sockid);
  8020ca:	89 34 24             	mov    %esi,(%esp)
  8020cd:	e8 00 02 00 00       	call   8022d2 <nsipc_close>
  8020d2:	eb 28                	jmp    8020fc <alloc_sockfd+0x6e>
		return r;
	}

	sfd->fd_dev_id = devsock.dev_id;
  8020d4:	8b 15 20 60 80 00    	mov    0x806020,%edx
  8020da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020dd:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8020df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8020e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ec:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8020ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f2:	89 04 24             	mov    %eax,(%esp)
  8020f5:	e8 66 f0 ff ff       	call   801160 <fd2num>
  8020fa:	89 c3                	mov    %eax,%ebx
}
  8020fc:	89 d8                	mov    %ebx,%eax
  8020fe:	83 c4 20             	add    $0x20,%esp
  802101:	5b                   	pop    %ebx
  802102:	5e                   	pop    %esi
  802103:	5d                   	pop    %ebp
  802104:	c3                   	ret    

00802105 <socket>:
	return 0;
}

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
  80211f:	e8 62 01 00 00       	call   802286 <nsipc_socket>
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
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802131:	55                   	push   %ebp
  802132:	89 e5                	mov    %esp,%ebp
  802134:	83 ec 18             	sub    $0x18,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802137:	8d 55 fc             	lea    -0x4(%ebp),%edx
  80213a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80213e:	89 04 24             	mov    %eax,(%esp)
  802141:	e8 98 f0 ff ff       	call   8011de <fd_lookup>
  802146:	89 c2                	mov    %eax,%edx
  802148:	85 c0                	test   %eax,%eax
  80214a:	78 15                	js     802161 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80214c:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  80214f:	8b 01                	mov    (%ecx),%eax
  802151:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  802156:	3b 05 20 60 80 00    	cmp    0x806020,%eax
  80215c:	75 03                	jne    802161 <fd2sockid+0x30>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80215e:	8b 51 0c             	mov    0xc(%ecx),%edx
}
  802161:	89 d0                	mov    %edx,%eax
  802163:	c9                   	leave  
  802164:	c3                   	ret    

00802165 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  802165:	55                   	push   %ebp
  802166:	89 e5                	mov    %esp,%ebp
  802168:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80216b:	8b 45 08             	mov    0x8(%ebp),%eax
  80216e:	e8 be ff ff ff       	call   802131 <fd2sockid>
  802173:	85 c0                	test   %eax,%eax
  802175:	78 0f                	js     802186 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802177:	8b 55 0c             	mov    0xc(%ebp),%edx
  80217a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80217e:	89 04 24             	mov    %eax,(%esp)
  802181:	e8 2a 01 00 00       	call   8022b0 <nsipc_listen>
}
  802186:	c9                   	leave  
  802187:	c3                   	ret    

00802188 <connect>:
	return nsipc_close(fd->fd_sock.sockid);
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802188:	55                   	push   %ebp
  802189:	89 e5                	mov    %esp,%ebp
  80218b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80218e:	8b 45 08             	mov    0x8(%ebp),%eax
  802191:	e8 9b ff ff ff       	call   802131 <fd2sockid>
  802196:	85 c0                	test   %eax,%eax
  802198:	78 16                	js     8021b0 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80219a:	8b 55 10             	mov    0x10(%ebp),%edx
  80219d:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021a4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021a8:	89 04 24             	mov    %eax,(%esp)
  8021ab:	e8 51 02 00 00       	call   802401 <nsipc_connect>
}
  8021b0:	c9                   	leave  
  8021b1:	c3                   	ret    

008021b2 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  8021b2:	55                   	push   %ebp
  8021b3:	89 e5                	mov    %esp,%ebp
  8021b5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021bb:	e8 71 ff ff ff       	call   802131 <fd2sockid>
  8021c0:	85 c0                	test   %eax,%eax
  8021c2:	78 0f                	js     8021d3 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8021c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021c7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021cb:	89 04 24             	mov    %eax,(%esp)
  8021ce:	e8 19 01 00 00       	call   8022ec <nsipc_shutdown>
}
  8021d3:	c9                   	leave  
  8021d4:	c3                   	ret    

008021d5 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8021d5:	55                   	push   %ebp
  8021d6:	89 e5                	mov    %esp,%ebp
  8021d8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021db:	8b 45 08             	mov    0x8(%ebp),%eax
  8021de:	e8 4e ff ff ff       	call   802131 <fd2sockid>
  8021e3:	85 c0                	test   %eax,%eax
  8021e5:	78 16                	js     8021fd <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  8021e7:	8b 55 10             	mov    0x10(%ebp),%edx
  8021ea:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021f5:	89 04 24             	mov    %eax,(%esp)
  8021f8:	e8 43 02 00 00       	call   802440 <nsipc_bind>
}
  8021fd:	c9                   	leave  
  8021fe:	c3                   	ret    

008021ff <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8021ff:	55                   	push   %ebp
  802200:	89 e5                	mov    %esp,%ebp
  802202:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802205:	8b 45 08             	mov    0x8(%ebp),%eax
  802208:	e8 24 ff ff ff       	call   802131 <fd2sockid>
  80220d:	85 c0                	test   %eax,%eax
  80220f:	78 1f                	js     802230 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802211:	8b 55 10             	mov    0x10(%ebp),%edx
  802214:	89 54 24 08          	mov    %edx,0x8(%esp)
  802218:	8b 55 0c             	mov    0xc(%ebp),%edx
  80221b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80221f:	89 04 24             	mov    %eax,(%esp)
  802222:	e8 58 02 00 00       	call   80247f <nsipc_accept>
  802227:	85 c0                	test   %eax,%eax
  802229:	78 05                	js     802230 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80222b:	e8 5e fe ff ff       	call   80208e <alloc_sockfd>
}
  802230:	c9                   	leave  
  802231:	c3                   	ret    
	...

00802240 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802240:	55                   	push   %ebp
  802241:	89 e5                	mov    %esp,%ebp
  802243:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802246:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  80224c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802253:	00 
  802254:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  80225b:	00 
  80225c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802260:	89 14 24             	mov    %edx,(%esp)
  802263:	e8 68 02 00 00       	call   8024d0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802268:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80226f:	00 
  802270:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802277:	00 
  802278:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80227f:	e8 00 03 00 00       	call   802584 <ipc_recv>
}
  802284:	c9                   	leave  
  802285:	c3                   	ret    

00802286 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  802286:	55                   	push   %ebp
  802287:	89 e5                	mov    %esp,%ebp
  802289:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80228c:	8b 45 08             	mov    0x8(%ebp),%eax
  80228f:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.socket.req_type = type;
  802294:	8b 45 0c             	mov    0xc(%ebp),%eax
  802297:	a3 04 50 80 00       	mov    %eax,0x805004
	nsipcbuf.socket.req_protocol = protocol;
  80229c:	8b 45 10             	mov    0x10(%ebp),%eax
  80229f:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SOCKET);
  8022a4:	b8 09 00 00 00       	mov    $0x9,%eax
  8022a9:	e8 92 ff ff ff       	call   802240 <nsipc>
}
  8022ae:	c9                   	leave  
  8022af:	c3                   	ret    

008022b0 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  8022b0:	55                   	push   %ebp
  8022b1:	89 e5                	mov    %esp,%ebp
  8022b3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8022b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b9:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.listen.req_backlog = backlog;
  8022be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022c1:	a3 04 50 80 00       	mov    %eax,0x805004
	return nsipc(NSREQ_LISTEN);
  8022c6:	b8 06 00 00 00       	mov    $0x6,%eax
  8022cb:	e8 70 ff ff ff       	call   802240 <nsipc>
}
  8022d0:	c9                   	leave  
  8022d1:	c3                   	ret    

008022d2 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  8022d2:	55                   	push   %ebp
  8022d3:	89 e5                	mov    %esp,%ebp
  8022d5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8022d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022db:	a3 00 50 80 00       	mov    %eax,0x805000
	return nsipc(NSREQ_CLOSE);
  8022e0:	b8 04 00 00 00       	mov    $0x4,%eax
  8022e5:	e8 56 ff ff ff       	call   802240 <nsipc>
}
  8022ea:	c9                   	leave  
  8022eb:	c3                   	ret    

008022ec <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  8022ec:	55                   	push   %ebp
  8022ed:	89 e5                	mov    %esp,%ebp
  8022ef:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8022f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f5:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.shutdown.req_how = how;
  8022fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022fd:	a3 04 50 80 00       	mov    %eax,0x805004
	return nsipc(NSREQ_SHUTDOWN);
  802302:	b8 03 00 00 00       	mov    $0x3,%eax
  802307:	e8 34 ff ff ff       	call   802240 <nsipc>
}
  80230c:	c9                   	leave  
  80230d:	c3                   	ret    

0080230e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80230e:	55                   	push   %ebp
  80230f:	89 e5                	mov    %esp,%ebp
  802311:	53                   	push   %ebx
  802312:	83 ec 14             	sub    $0x14,%esp
  802315:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802318:	8b 45 08             	mov    0x8(%ebp),%eax
  80231b:	a3 00 50 80 00       	mov    %eax,0x805000
	assert(size < 1600);
  802320:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802326:	7e 24                	jle    80234c <nsipc_send+0x3e>
  802328:	c7 44 24 0c 94 2e 80 	movl   $0x802e94,0xc(%esp)
  80232f:	00 
  802330:	c7 44 24 08 ee 2d 80 	movl   $0x802dee,0x8(%esp)
  802337:	00 
  802338:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  80233f:	00 
  802340:	c7 04 24 a0 2e 80 00 	movl   $0x802ea0,(%esp)
  802347:	e8 88 de ff ff       	call   8001d4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80234c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802350:	8b 45 0c             	mov    0xc(%ebp),%eax
  802353:	89 44 24 04          	mov    %eax,0x4(%esp)
  802357:	c7 04 24 0c 50 80 00 	movl   $0x80500c,(%esp)
  80235e:	e8 a5 e7 ff ff       	call   800b08 <memmove>
	nsipcbuf.send.req_size = size;
  802363:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	nsipcbuf.send.req_flags = flags;
  802369:	8b 45 14             	mov    0x14(%ebp),%eax
  80236c:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SEND);
  802371:	b8 08 00 00 00       	mov    $0x8,%eax
  802376:	e8 c5 fe ff ff       	call   802240 <nsipc>
}
  80237b:	83 c4 14             	add    $0x14,%esp
  80237e:	5b                   	pop    %ebx
  80237f:	5d                   	pop    %ebp
  802380:	c3                   	ret    

00802381 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802381:	55                   	push   %ebp
  802382:	89 e5                	mov    %esp,%ebp
  802384:	56                   	push   %esi
  802385:	53                   	push   %ebx
  802386:	83 ec 10             	sub    $0x10,%esp
  802389:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80238c:	8b 45 08             	mov    0x8(%ebp),%eax
  80238f:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.recv.req_len = len;
  802394:	89 35 04 50 80 00    	mov    %esi,0x805004
	nsipcbuf.recv.req_flags = flags;
  80239a:	8b 45 14             	mov    0x14(%ebp),%eax
  80239d:	a3 08 50 80 00       	mov    %eax,0x805008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8023a2:	b8 07 00 00 00       	mov    $0x7,%eax
  8023a7:	e8 94 fe ff ff       	call   802240 <nsipc>
  8023ac:	89 c3                	mov    %eax,%ebx
  8023ae:	85 c0                	test   %eax,%eax
  8023b0:	78 46                	js     8023f8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8023b2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8023b7:	7f 04                	jg     8023bd <nsipc_recv+0x3c>
  8023b9:	39 c6                	cmp    %eax,%esi
  8023bb:	7d 24                	jge    8023e1 <nsipc_recv+0x60>
  8023bd:	c7 44 24 0c ac 2e 80 	movl   $0x802eac,0xc(%esp)
  8023c4:	00 
  8023c5:	c7 44 24 08 ee 2d 80 	movl   $0x802dee,0x8(%esp)
  8023cc:	00 
  8023cd:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  8023d4:	00 
  8023d5:	c7 04 24 a0 2e 80 00 	movl   $0x802ea0,(%esp)
  8023dc:	e8 f3 dd ff ff       	call   8001d4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8023e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023e5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8023ec:	00 
  8023ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023f0:	89 04 24             	mov    %eax,(%esp)
  8023f3:	e8 10 e7 ff ff       	call   800b08 <memmove>
	}

	return r;
}
  8023f8:	89 d8                	mov    %ebx,%eax
  8023fa:	83 c4 10             	add    $0x10,%esp
  8023fd:	5b                   	pop    %ebx
  8023fe:	5e                   	pop    %esi
  8023ff:	5d                   	pop    %ebp
  802400:	c3                   	ret    

00802401 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802401:	55                   	push   %ebp
  802402:	89 e5                	mov    %esp,%ebp
  802404:	53                   	push   %ebx
  802405:	83 ec 14             	sub    $0x14,%esp
  802408:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80240b:	8b 45 08             	mov    0x8(%ebp),%eax
  80240e:	a3 00 50 80 00       	mov    %eax,0x805000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802413:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802417:	8b 45 0c             	mov    0xc(%ebp),%eax
  80241a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80241e:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  802425:	e8 de e6 ff ff       	call   800b08 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80242a:	89 1d 14 50 80 00    	mov    %ebx,0x805014
	return nsipc(NSREQ_CONNECT);
  802430:	b8 05 00 00 00       	mov    $0x5,%eax
  802435:	e8 06 fe ff ff       	call   802240 <nsipc>
}
  80243a:	83 c4 14             	add    $0x14,%esp
  80243d:	5b                   	pop    %ebx
  80243e:	5d                   	pop    %ebp
  80243f:	c3                   	ret    

00802440 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802440:	55                   	push   %ebp
  802441:	89 e5                	mov    %esp,%ebp
  802443:	53                   	push   %ebx
  802444:	83 ec 14             	sub    $0x14,%esp
  802447:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80244a:	8b 45 08             	mov    0x8(%ebp),%eax
  80244d:	a3 00 50 80 00       	mov    %eax,0x805000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802452:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802456:	8b 45 0c             	mov    0xc(%ebp),%eax
  802459:	89 44 24 04          	mov    %eax,0x4(%esp)
  80245d:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  802464:	e8 9f e6 ff ff       	call   800b08 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802469:	89 1d 14 50 80 00    	mov    %ebx,0x805014
	return nsipc(NSREQ_BIND);
  80246f:	b8 02 00 00 00       	mov    $0x2,%eax
  802474:	e8 c7 fd ff ff       	call   802240 <nsipc>
}
  802479:	83 c4 14             	add    $0x14,%esp
  80247c:	5b                   	pop    %ebx
  80247d:	5d                   	pop    %ebp
  80247e:	c3                   	ret    

0080247f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80247f:	55                   	push   %ebp
  802480:	89 e5                	mov    %esp,%ebp
  802482:	53                   	push   %ebx
  802483:	83 ec 14             	sub    $0x14,%esp
	int r;
	
	nsipcbuf.accept.req_s = s;
  802486:	8b 45 08             	mov    0x8(%ebp),%eax
  802489:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80248e:	b8 01 00 00 00       	mov    $0x1,%eax
  802493:	e8 a8 fd ff ff       	call   802240 <nsipc>
  802498:	89 c3                	mov    %eax,%ebx
  80249a:	85 c0                	test   %eax,%eax
  80249c:	78 26                	js     8024c4 <nsipc_accept+0x45>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80249e:	a1 10 50 80 00       	mov    0x805010,%eax
  8024a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024a7:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8024ae:	00 
  8024af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024b2:	89 04 24             	mov    %eax,(%esp)
  8024b5:	e8 4e e6 ff ff       	call   800b08 <memmove>
		*addrlen = ret->ret_addrlen;
  8024ba:	a1 10 50 80 00       	mov    0x805010,%eax
  8024bf:	8b 55 10             	mov    0x10(%ebp),%edx
  8024c2:	89 02                	mov    %eax,(%edx)
	}
	return r;
}
  8024c4:	89 d8                	mov    %ebx,%eax
  8024c6:	83 c4 14             	add    $0x14,%esp
  8024c9:	5b                   	pop    %ebx
  8024ca:	5d                   	pop    %ebp
  8024cb:	c3                   	ret    
  8024cc:	00 00                	add    %al,(%eax)
	...

008024d0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024d0:	55                   	push   %ebp
  8024d1:	89 e5                	mov    %esp,%ebp
  8024d3:	57                   	push   %edi
  8024d4:	56                   	push   %esi
  8024d5:	53                   	push   %ebx
  8024d6:	83 ec 1c             	sub    $0x1c,%esp
  8024d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8024dc:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  8024df:	e8 e9 eb ff ff       	call   8010cd <sys_getenvid>
  8024e4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8024e9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8024ec:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8024f1:	a3 3c 60 80 00       	mov    %eax,0x80603c
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  8024f6:	e8 d2 eb ff ff       	call   8010cd <sys_getenvid>
  8024fb:	25 ff 03 00 00       	and    $0x3ff,%eax
  802500:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802503:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802508:	a3 3c 60 80 00       	mov    %eax,0x80603c
		if(env->env_id==to_env){
  80250d:	8b 40 4c             	mov    0x4c(%eax),%eax
  802510:	39 f0                	cmp    %esi,%eax
  802512:	75 0e                	jne    802522 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  802514:	c7 04 24 c1 2e 80 00 	movl   $0x802ec1,(%esp)
  80251b:	e8 81 dd ff ff       	call   8002a1 <cprintf>
  802520:	eb 5a                	jmp    80257c <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  802522:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802526:	8b 45 10             	mov    0x10(%ebp),%eax
  802529:	89 44 24 08          	mov    %eax,0x8(%esp)
  80252d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802530:	89 44 24 04          	mov    %eax,0x4(%esp)
  802534:	89 34 24             	mov    %esi,(%esp)
  802537:	e8 f0 e8 ff ff       	call   800e2c <sys_ipc_try_send>
  80253c:	89 c3                	mov    %eax,%ebx
  80253e:	85 c0                	test   %eax,%eax
  802540:	79 25                	jns    802567 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  802542:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802545:	74 2b                	je     802572 <ipc_send+0xa2>
				panic("send error:%e",r);
  802547:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80254b:	c7 44 24 08 dd 2e 80 	movl   $0x802edd,0x8(%esp)
  802552:	00 
  802553:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80255a:	00 
  80255b:	c7 04 24 eb 2e 80 00 	movl   $0x802eeb,(%esp)
  802562:	e8 6d dc ff ff       	call   8001d4 <_panic>
		}
			sys_yield();
  802567:	e8 2d eb ff ff       	call   801099 <sys_yield>
		
	}while(r!=0);
  80256c:	85 db                	test   %ebx,%ebx
  80256e:	75 86                	jne    8024f6 <ipc_send+0x26>
  802570:	eb 0a                	jmp    80257c <ipc_send+0xac>
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
		{	
			if(r!=-E_IPC_NOT_RECV)
				panic("send error:%e",r);
		}
			sys_yield();
  802572:	e8 22 eb ff ff       	call   801099 <sys_yield>
  802577:	e9 7a ff ff ff       	jmp    8024f6 <ipc_send+0x26>
		
	}while(r!=0);
	return;
	//panic("ipc_send not implemented");
}
  80257c:	83 c4 1c             	add    $0x1c,%esp
  80257f:	5b                   	pop    %ebx
  802580:	5e                   	pop    %esi
  802581:	5f                   	pop    %edi
  802582:	5d                   	pop    %ebp
  802583:	c3                   	ret    

00802584 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802584:	55                   	push   %ebp
  802585:	89 e5                	mov    %esp,%ebp
  802587:	57                   	push   %edi
  802588:	56                   	push   %esi
  802589:	53                   	push   %ebx
  80258a:	83 ec 0c             	sub    $0xc,%esp
  80258d:	8b 75 08             	mov    0x8(%ebp),%esi
  802590:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	void *dstva=NULL;
	if(pg)
		dstva=pg;
	env = &envs[ENVX(sys_getenvid())];
  802593:	e8 35 eb ff ff       	call   8010cd <sys_getenvid>
  802598:	25 ff 03 00 00       	and    $0x3ff,%eax
  80259d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8025a0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8025a5:	a3 3c 60 80 00       	mov    %eax,0x80603c
	if(from_env_store&&(env->env_id==*from_env_store))
  8025aa:	85 f6                	test   %esi,%esi
  8025ac:	74 29                	je     8025d7 <ipc_recv+0x53>
  8025ae:	8b 40 4c             	mov    0x4c(%eax),%eax
  8025b1:	3b 06                	cmp    (%esi),%eax
  8025b3:	75 22                	jne    8025d7 <ipc_recv+0x53>
	{
		*from_env_store=0;
  8025b5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  8025bb:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("send:the reciver is sender\n");
  8025c1:	c7 04 24 c1 2e 80 00 	movl   $0x802ec1,(%esp)
  8025c8:	e8 d4 dc ff ff       	call   8002a1 <cprintf>
  8025cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8025d2:	e9 8a 00 00 00       	jmp    802661 <ipc_recv+0xdd>
		return 0;
	}
	env = &envs[ENVX(sys_getenvid())];
  8025d7:	e8 f1 ea ff ff       	call   8010cd <sys_getenvid>
  8025dc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8025e1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8025e4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8025e9:	a3 3c 60 80 00       	mov    %eax,0x80603c
	if((r=sys_ipc_recv(dstva))<0)
  8025ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025f1:	89 04 24             	mov    %eax,(%esp)
  8025f4:	e8 d6 e7 ff ff       	call   800dcf <sys_ipc_recv>
  8025f9:	89 c3                	mov    %eax,%ebx
  8025fb:	85 c0                	test   %eax,%eax
  8025fd:	79 1a                	jns    802619 <ipc_recv+0x95>
	{
		*from_env_store=0;
  8025ff:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  802605:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("reciver failed\n");
  80260b:	c7 04 24 f5 2e 80 00 	movl   $0x802ef5,(%esp)
  802612:	e8 8a dc ff ff       	call   8002a1 <cprintf>
  802617:	eb 48                	jmp    802661 <ipc_recv+0xdd>
		return r;
	}
	else{//接收成功
		env = &envs[ENVX(sys_getenvid())];
  802619:	e8 af ea ff ff       	call   8010cd <sys_getenvid>
  80261e:	25 ff 03 00 00       	and    $0x3ff,%eax
  802623:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802626:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80262b:	a3 3c 60 80 00       	mov    %eax,0x80603c
		if(from_env_store)
  802630:	85 f6                	test   %esi,%esi
  802632:	74 05                	je     802639 <ipc_recv+0xb5>
			*from_env_store=env->env_ipc_from;	
  802634:	8b 40 74             	mov    0x74(%eax),%eax
  802637:	89 06                	mov    %eax,(%esi)
		if(perm_store)
  802639:	85 ff                	test   %edi,%edi
  80263b:	74 0a                	je     802647 <ipc_recv+0xc3>
			*perm_store=env->env_ipc_perm;
  80263d:	a1 3c 60 80 00       	mov    0x80603c,%eax
  802642:	8b 40 78             	mov    0x78(%eax),%eax
  802645:	89 07                	mov    %eax,(%edi)
		env = &envs[ENVX(sys_getenvid())];
  802647:	e8 81 ea ff ff       	call   8010cd <sys_getenvid>
  80264c:	25 ff 03 00 00       	and    $0x3ff,%eax
  802651:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802654:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802659:	a3 3c 60 80 00       	mov    %eax,0x80603c
		return env->env_ipc_value;
  80265e:	8b 58 70             	mov    0x70(%eax),%ebx
	}
	//panic("ipc_recv not implemented");
	return 0;
}
  802661:	89 d8                	mov    %ebx,%eax
  802663:	83 c4 0c             	add    $0xc,%esp
  802666:	5b                   	pop    %ebx
  802667:	5e                   	pop    %esi
  802668:	5f                   	pop    %edi
  802669:	5d                   	pop    %ebp
  80266a:	c3                   	ret    
  80266b:	00 00                	add    %al,(%eax)
  80266d:	00 00                	add    %al,(%eax)
	...

00802670 <__udivdi3>:
  802670:	55                   	push   %ebp
  802671:	89 e5                	mov    %esp,%ebp
  802673:	57                   	push   %edi
  802674:	56                   	push   %esi
  802675:	83 ec 18             	sub    $0x18,%esp
  802678:	8b 45 10             	mov    0x10(%ebp),%eax
  80267b:	8b 55 14             	mov    0x14(%ebp),%edx
  80267e:	8b 75 0c             	mov    0xc(%ebp),%esi
  802681:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802684:	89 c1                	mov    %eax,%ecx
  802686:	8b 45 08             	mov    0x8(%ebp),%eax
  802689:	85 d2                	test   %edx,%edx
  80268b:	89 d7                	mov    %edx,%edi
  80268d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802690:	75 1e                	jne    8026b0 <__udivdi3+0x40>
  802692:	39 f1                	cmp    %esi,%ecx
  802694:	0f 86 8d 00 00 00    	jbe    802727 <__udivdi3+0xb7>
  80269a:	89 f2                	mov    %esi,%edx
  80269c:	31 f6                	xor    %esi,%esi
  80269e:	f7 f1                	div    %ecx
  8026a0:	89 c1                	mov    %eax,%ecx
  8026a2:	89 c8                	mov    %ecx,%eax
  8026a4:	89 f2                	mov    %esi,%edx
  8026a6:	83 c4 18             	add    $0x18,%esp
  8026a9:	5e                   	pop    %esi
  8026aa:	5f                   	pop    %edi
  8026ab:	5d                   	pop    %ebp
  8026ac:	c3                   	ret    
  8026ad:	8d 76 00             	lea    0x0(%esi),%esi
  8026b0:	39 f2                	cmp    %esi,%edx
  8026b2:	0f 87 a8 00 00 00    	ja     802760 <__udivdi3+0xf0>
  8026b8:	0f bd c2             	bsr    %edx,%eax
  8026bb:	83 f0 1f             	xor    $0x1f,%eax
  8026be:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8026c1:	0f 84 89 00 00 00    	je     802750 <__udivdi3+0xe0>
  8026c7:	b8 20 00 00 00       	mov    $0x20,%eax
  8026cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8026cf:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8026d2:	89 c1                	mov    %eax,%ecx
  8026d4:	d3 ea                	shr    %cl,%edx
  8026d6:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  8026da:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8026dd:	89 f8                	mov    %edi,%eax
  8026df:	8b 7d f4             	mov    -0xc(%ebp),%edi
  8026e2:	d3 e0                	shl    %cl,%eax
  8026e4:	09 c2                	or     %eax,%edx
  8026e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8026e9:	d3 e7                	shl    %cl,%edi
  8026eb:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026ef:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8026f2:	89 f2                	mov    %esi,%edx
  8026f4:	d3 e8                	shr    %cl,%eax
  8026f6:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  8026fa:	d3 e2                	shl    %cl,%edx
  8026fc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802700:	09 d0                	or     %edx,%eax
  802702:	d3 ee                	shr    %cl,%esi
  802704:	89 f2                	mov    %esi,%edx
  802706:	f7 75 e4             	divl   -0x1c(%ebp)
  802709:	89 d1                	mov    %edx,%ecx
  80270b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80270e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802711:	f7 e7                	mul    %edi
  802713:	39 d1                	cmp    %edx,%ecx
  802715:	89 c6                	mov    %eax,%esi
  802717:	72 70                	jb     802789 <__udivdi3+0x119>
  802719:	39 ca                	cmp    %ecx,%edx
  80271b:	74 5f                	je     80277c <__udivdi3+0x10c>
  80271d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802720:	31 f6                	xor    %esi,%esi
  802722:	e9 7b ff ff ff       	jmp    8026a2 <__udivdi3+0x32>
  802727:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80272a:	85 c0                	test   %eax,%eax
  80272c:	75 0c                	jne    80273a <__udivdi3+0xca>
  80272e:	b8 01 00 00 00       	mov    $0x1,%eax
  802733:	31 d2                	xor    %edx,%edx
  802735:	f7 75 f4             	divl   -0xc(%ebp)
  802738:	89 c1                	mov    %eax,%ecx
  80273a:	89 f0                	mov    %esi,%eax
  80273c:	89 fa                	mov    %edi,%edx
  80273e:	f7 f1                	div    %ecx
  802740:	89 c6                	mov    %eax,%esi
  802742:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802745:	f7 f1                	div    %ecx
  802747:	89 c1                	mov    %eax,%ecx
  802749:	e9 54 ff ff ff       	jmp    8026a2 <__udivdi3+0x32>
  80274e:	66 90                	xchg   %ax,%ax
  802750:	39 d6                	cmp    %edx,%esi
  802752:	77 1c                	ja     802770 <__udivdi3+0x100>
  802754:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802757:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  80275a:	73 14                	jae    802770 <__udivdi3+0x100>
  80275c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802760:	31 c9                	xor    %ecx,%ecx
  802762:	31 f6                	xor    %esi,%esi
  802764:	e9 39 ff ff ff       	jmp    8026a2 <__udivdi3+0x32>
  802769:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  802770:	b9 01 00 00 00       	mov    $0x1,%ecx
  802775:	31 f6                	xor    %esi,%esi
  802777:	e9 26 ff ff ff       	jmp    8026a2 <__udivdi3+0x32>
  80277c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80277f:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  802783:	d3 e0                	shl    %cl,%eax
  802785:	39 c6                	cmp    %eax,%esi
  802787:	76 94                	jbe    80271d <__udivdi3+0xad>
  802789:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80278c:	31 f6                	xor    %esi,%esi
  80278e:	83 e9 01             	sub    $0x1,%ecx
  802791:	e9 0c ff ff ff       	jmp    8026a2 <__udivdi3+0x32>
	...

008027a0 <__umoddi3>:
  8027a0:	55                   	push   %ebp
  8027a1:	89 e5                	mov    %esp,%ebp
  8027a3:	57                   	push   %edi
  8027a4:	56                   	push   %esi
  8027a5:	83 ec 30             	sub    $0x30,%esp
  8027a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8027ab:	8b 55 14             	mov    0x14(%ebp),%edx
  8027ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8027b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8027b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8027b7:	89 c1                	mov    %eax,%ecx
  8027b9:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8027bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8027bf:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8027c6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8027cd:	89 fa                	mov    %edi,%edx
  8027cf:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8027d2:	85 c0                	test   %eax,%eax
  8027d4:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8027d7:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8027da:	75 14                	jne    8027f0 <__umoddi3+0x50>
  8027dc:	39 f9                	cmp    %edi,%ecx
  8027de:	76 60                	jbe    802840 <__umoddi3+0xa0>
  8027e0:	89 f0                	mov    %esi,%eax
  8027e2:	f7 f1                	div    %ecx
  8027e4:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8027e7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8027ee:	eb 10                	jmp    802800 <__umoddi3+0x60>
  8027f0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8027f3:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  8027f6:	76 18                	jbe    802810 <__umoddi3+0x70>
  8027f8:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8027fb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8027fe:	66 90                	xchg   %ax,%ax
  802800:	8b 45 d0             	mov    -0x30(%ebp),%eax
  802803:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  802806:	83 c4 30             	add    $0x30,%esp
  802809:	5e                   	pop    %esi
  80280a:	5f                   	pop    %edi
  80280b:	5d                   	pop    %ebp
  80280c:	c3                   	ret    
  80280d:	8d 76 00             	lea    0x0(%esi),%esi
  802810:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
  802814:	83 f0 1f             	xor    $0x1f,%eax
  802817:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80281a:	75 46                	jne    802862 <__umoddi3+0xc2>
  80281c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80281f:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  802822:	0f 87 c9 00 00 00    	ja     8028f1 <__umoddi3+0x151>
  802828:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  80282b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80282e:	0f 83 bd 00 00 00    	jae    8028f1 <__umoddi3+0x151>
  802834:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802837:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80283a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80283d:	eb c1                	jmp    802800 <__umoddi3+0x60>
  80283f:	90                   	nop    
  802840:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802843:	85 c0                	test   %eax,%eax
  802845:	75 0c                	jne    802853 <__umoddi3+0xb3>
  802847:	b8 01 00 00 00       	mov    $0x1,%eax
  80284c:	31 d2                	xor    %edx,%edx
  80284e:	f7 75 ec             	divl   -0x14(%ebp)
  802851:	89 c1                	mov    %eax,%ecx
  802853:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802856:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802859:	f7 f1                	div    %ecx
  80285b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80285e:	f7 f1                	div    %ecx
  802860:	eb 82                	jmp    8027e4 <__umoddi3+0x44>
  802862:	b8 20 00 00 00       	mov    $0x20,%eax
  802867:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80286a:	2b 45 d8             	sub    -0x28(%ebp),%eax
  80286d:	8b 75 ec             	mov    -0x14(%ebp),%esi
  802870:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802873:	89 c1                	mov    %eax,%ecx
  802875:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802878:	d3 ea                	shr    %cl,%edx
  80287a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80287d:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  802881:	d3 e0                	shl    %cl,%eax
  802883:	09 c2                	or     %eax,%edx
  802885:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802888:	d3 e6                	shl    %cl,%esi
  80288a:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  80288e:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802891:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802894:	d3 e8                	shr    %cl,%eax
  802896:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  80289a:	d3 e2                	shl    %cl,%edx
  80289c:	09 d0                	or     %edx,%eax
  80289e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8028a1:	d3 e7                	shl    %cl,%edi
  8028a3:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  8028a7:	d3 ea                	shr    %cl,%edx
  8028a9:	f7 75 f4             	divl   -0xc(%ebp)
  8028ac:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8028af:	f7 e6                	mul    %esi
  8028b1:	39 55 cc             	cmp    %edx,-0x34(%ebp)
  8028b4:	72 53                	jb     802909 <__umoddi3+0x169>
  8028b6:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  8028b9:	74 4a                	je     802905 <__umoddi3+0x165>
  8028bb:	90                   	nop    
  8028bc:	8d 74 26 00          	lea    0x0(%esi),%esi
  8028c0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8028c3:	29 c7                	sub    %eax,%edi
  8028c5:	19 d1                	sbb    %edx,%ecx
  8028c7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8028ca:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8028ce:	89 fa                	mov    %edi,%edx
  8028d0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8028d3:	d3 ea                	shr    %cl,%edx
  8028d5:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  8028d9:	d3 e0                	shl    %cl,%eax
  8028db:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8028df:	09 c2                	or     %eax,%edx
  8028e1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8028e4:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8028e7:	d3 e8                	shr    %cl,%eax
  8028e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8028ec:	e9 0f ff ff ff       	jmp    802800 <__umoddi3+0x60>
  8028f1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8028f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8028f7:	2b 45 ec             	sub    -0x14(%ebp),%eax
  8028fa:	1b 55 e8             	sbb    -0x18(%ebp),%edx
  8028fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802900:	e9 2f ff ff ff       	jmp    802834 <__umoddi3+0x94>
  802905:	39 f8                	cmp    %edi,%eax
  802907:	76 b7                	jbe    8028c0 <__umoddi3+0x120>
  802909:	29 f0                	sub    %esi,%eax
  80290b:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  80290e:	eb b0                	jmp    8028c0 <__umoddi3+0x120>
