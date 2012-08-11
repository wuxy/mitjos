
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
  80003f:	c7 05 00 50 80 00 40 	movl   $0x802440,0x805000
  800046:	24 80 00 

	cprintf("icode startup\n");
  800049:	c7 04 24 46 24 80 00 	movl   $0x802446,(%esp)
  800050:	e8 4c 02 00 00       	call   8002a1 <cprintf>

	cprintf("icode: open /motd\n");
  800055:	c7 04 24 55 24 80 00 	movl   $0x802455,(%esp)
  80005c:	e8 40 02 00 00       	call   8002a1 <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  800061:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800068:	00 
  800069:	c7 04 24 68 24 80 00 	movl   $0x802468,(%esp)
  800070:	e8 ca 18 00 00       	call   80193f <open>
  800075:	89 c3                	mov    %eax,%ebx
  800077:	85 c0                	test   %eax,%eax
  800079:	79 20                	jns    80009b <umain+0x67>
		panic("icode: open /motd: %e", fd);
  80007b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80007f:	c7 44 24 08 6e 24 80 	movl   $0x80246e,0x8(%esp)
  800086:	00 
  800087:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008e:	00 
  80008f:	c7 04 24 84 24 80 00 	movl   $0x802484,(%esp)
  800096:	e8 39 01 00 00       	call   8001d4 <_panic>

	cprintf("icode: read /motd\n");
  80009b:	c7 04 24 91 24 80 00 	movl   $0x802491,(%esp)
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
  8000ca:	e8 49 13 00 00       	call   801418 <read>
  8000cf:	85 c0                	test   %eax,%eax
  8000d1:	7f dc                	jg     8000af <umain+0x7b>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000d3:	c7 04 24 a4 24 80 00 	movl   $0x8024a4,(%esp)
  8000da:	e8 c2 01 00 00       	call   8002a1 <cprintf>
	close(fd);
  8000df:	89 1c 24             	mov    %ebx,(%esp)
  8000e2:	e8 9e 14 00 00       	call   801585 <close>

	cprintf("icode: spawn /init\n");
  8000e7:	c7 04 24 b8 24 80 00 	movl   $0x8024b8,(%esp)
  8000ee:	e8 ae 01 00 00       	call   8002a1 <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000f3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8000fa:	00 
  8000fb:	c7 44 24 0c cc 24 80 	movl   $0x8024cc,0xc(%esp)
  800102:	00 
  800103:	c7 44 24 08 d5 24 80 	movl   $0x8024d5,0x8(%esp)
  80010a:	00 
  80010b:	c7 44 24 04 df 24 80 	movl   $0x8024df,0x4(%esp)
  800112:	00 
  800113:	c7 04 24 de 24 80 00 	movl   $0x8024de,(%esp)
  80011a:	e8 af 1e 00 00       	call   801fce <spawnl>
  80011f:	85 c0                	test   %eax,%eax
  800121:	79 20                	jns    800143 <umain+0x10f>
		panic("icode: spawn /init: %e", r);
  800123:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800127:	c7 44 24 08 e4 24 80 	movl   $0x8024e4,0x8(%esp)
  80012e:	00 
  80012f:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800136:	00 
  800137:	c7 04 24 84 24 80 00 	movl   $0x802484,(%esp)
  80013e:	e8 91 00 00 00       	call   8001d4 <_panic>

	cprintf("icode: exiting\n");
  800143:	c7 04 24 fb 24 80 00 	movl   $0x8024fb,(%esp)
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
  80016e:	c7 05 20 50 80 00 00 	movl   $0x0,0x805020
  800175:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  800178:	e8 1c 0f 00 00       	call   801099 <sys_getenvid>
  80017d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800182:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800185:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80018a:	a3 20 50 80 00       	mov    %eax,0x805020
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80018f:	85 f6                	test   %esi,%esi
  800191:	7e 07                	jle    80019a <libmain+0x3e>
		binaryname = argv[0];
  800193:	8b 03                	mov    (%ebx),%eax
  800195:	a3 00 50 80 00       	mov    %eax,0x805000

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
  8001be:	e8 5d 15 00 00       	call   801720 <close_all>
	sys_env_destroy(0);
  8001c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ca:	e8 fe 0e 00 00       	call   8010cd <sys_env_destroy>
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
  8001e0:	a1 24 50 80 00       	mov    0x805024,%eax
  8001e5:	85 c0                	test   %eax,%eax
  8001e7:	74 10                	je     8001f9 <_panic+0x25>
		cprintf("%s: ", argv0);
  8001e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ed:	c7 04 24 22 25 80 00 	movl   $0x802522,(%esp)
  8001f4:	e8 a8 00 00 00       	call   8002a1 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8001f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800200:	8b 45 08             	mov    0x8(%ebp),%eax
  800203:	89 44 24 08          	mov    %eax,0x8(%esp)
  800207:	a1 00 50 80 00       	mov    0x805000,%eax
  80020c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800210:	c7 04 24 27 25 80 00 	movl   $0x802527,(%esp)
  800217:	e8 85 00 00 00       	call   8002a1 <cprintf>
	vcprintf(fmt, ap);
  80021c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80021f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800223:	8b 45 10             	mov    0x10(%ebp),%eax
  800226:	89 04 24             	mov    %eax,(%esp)
  800229:	e8 12 00 00 00       	call   800240 <vcprintf>
	cprintf("\n");
  80022e:	c7 04 24 fb 28 80 00 	movl   $0x8028fb,(%esp)
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
  80037b:	e8 10 1e 00 00       	call   802190 <__udivdi3>
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
  8003cd:	e8 ee 1e 00 00       	call   8022c0 <__umoddi3>
  8003d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003d6:	0f be 80 43 25 80 00 	movsbl 0x802543(%eax),%eax
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
  8004ae:	ff 24 85 80 26 80 00 	jmp    *0x802680(,%eax,4)
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
  80055d:	8b 14 85 e0 27 80 00 	mov    0x8027e0(,%eax,4),%edx
  800564:	85 d2                	test   %edx,%edx
  800566:	75 23                	jne    80058b <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800568:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80056c:	c7 44 24 08 54 25 80 	movl   $0x802554,0x8(%esp)
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
  80058f:	c7 44 24 08 40 29 80 	movl   $0x802940,0x8(%esp)
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
  8005c8:	c7 45 dc 5d 25 80 00 	movl   $0x80255d,-0x24(%ebp)
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

00800d9b <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	83 ec 28             	sub    $0x28,%esp
  800da1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800da4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800da7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800daa:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dad:	b8 0d 00 00 00       	mov    $0xd,%eax
  800db2:	bf 00 00 00 00       	mov    $0x0,%edi
  800db7:	89 f9                	mov    %edi,%ecx
  800db9:	89 fb                	mov    %edi,%ebx
  800dbb:	89 fe                	mov    %edi,%esi
  800dbd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	7e 28                	jle    800deb <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc7:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800dce:	00 
  800dcf:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800dd6:	00 
  800dd7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dde:	00 
  800ddf:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800de6:	e8 e9 f3 ff ff       	call   8001d4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800deb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dee:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800df1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800df4:	89 ec                	mov    %ebp,%esp
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    

00800df8 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	83 ec 0c             	sub    $0xc,%esp
  800dfe:	89 1c 24             	mov    %ebx,(%esp)
  800e01:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e05:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e09:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e12:	8b 7d 14             	mov    0x14(%ebp),%edi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e15:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e1a:	be 00 00 00 00       	mov    $0x0,%esi
  800e1f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e21:	8b 1c 24             	mov    (%esp),%ebx
  800e24:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e28:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e2c:	89 ec                	mov    %ebp,%esp
  800e2e:	5d                   	pop    %ebp
  800e2f:	c3                   	ret    

00800e30 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
  800e33:	83 ec 28             	sub    $0x28,%esp
  800e36:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e39:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e3c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e45:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e4a:	bf 00 00 00 00       	mov    $0x0,%edi
  800e4f:	89 fb                	mov    %edi,%ebx
  800e51:	89 fe                	mov    %edi,%esi
  800e53:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800e55:	85 c0                	test   %eax,%eax
  800e57:	7e 28                	jle    800e81 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e59:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e5d:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e64:	00 
  800e65:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800e6c:	00 
  800e6d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e74:	00 
  800e75:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800e7c:	e8 53 f3 ff ff       	call   8001d4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e81:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e84:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e87:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e8a:	89 ec                	mov    %ebp,%esp
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	83 ec 28             	sub    $0x28,%esp
  800e94:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e97:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e9a:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea3:	b8 09 00 00 00       	mov    $0x9,%eax
  800ea8:	bf 00 00 00 00       	mov    $0x0,%edi
  800ead:	89 fb                	mov    %edi,%ebx
  800eaf:	89 fe                	mov    %edi,%esi
  800eb1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800eb3:	85 c0                	test   %eax,%eax
  800eb5:	7e 28                	jle    800edf <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ebb:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ec2:	00 
  800ec3:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800eca:	00 
  800ecb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed2:	00 
  800ed3:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800eda:	e8 f5 f2 ff ff       	call   8001d4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800edf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ee2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ee5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ee8:	89 ec                	mov    %ebp,%esp
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    

00800eec <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	83 ec 28             	sub    $0x28,%esp
  800ef2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ef5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ef8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800efb:	8b 55 08             	mov    0x8(%ebp),%edx
  800efe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f01:	b8 08 00 00 00       	mov    $0x8,%eax
  800f06:	bf 00 00 00 00       	mov    $0x0,%edi
  800f0b:	89 fb                	mov    %edi,%ebx
  800f0d:	89 fe                	mov    %edi,%esi
  800f0f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f11:	85 c0                	test   %eax,%eax
  800f13:	7e 28                	jle    800f3d <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f15:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f19:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f20:	00 
  800f21:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800f28:	00 
  800f29:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f30:	00 
  800f31:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800f38:	e8 97 f2 ff ff       	call   8001d4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f3d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f40:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f43:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f46:	89 ec                	mov    %ebp,%esp
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    

00800f4a <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	83 ec 28             	sub    $0x28,%esp
  800f50:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f53:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f56:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f59:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f5f:	b8 06 00 00 00       	mov    $0x6,%eax
  800f64:	bf 00 00 00 00       	mov    $0x0,%edi
  800f69:	89 fb                	mov    %edi,%ebx
  800f6b:	89 fe                	mov    %edi,%esi
  800f6d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	7e 28                	jle    800f9b <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f73:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f77:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f7e:	00 
  800f7f:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800f86:	00 
  800f87:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f8e:	00 
  800f8f:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800f96:	e8 39 f2 ff ff       	call   8001d4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f9b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f9e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fa1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fa4:	89 ec                	mov    %ebp,%esp
  800fa6:	5d                   	pop    %ebp
  800fa7:	c3                   	ret    

00800fa8 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	83 ec 28             	sub    $0x28,%esp
  800fae:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fb1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fb4:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800fb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800fba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fc0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fc3:	8b 75 18             	mov    0x18(%ebp),%esi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc6:	b8 05 00 00 00       	mov    $0x5,%eax
  800fcb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	7e 28                	jle    800ff9 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd5:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800fdc:	00 
  800fdd:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800fe4:	00 
  800fe5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fec:	00 
  800fed:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800ff4:	e8 db f1 ff ff       	call   8001d4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ff9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ffc:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fff:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801002:	89 ec                	mov    %ebp,%esp
  801004:	5d                   	pop    %ebp
  801005:	c3                   	ret    

00801006 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801006:	55                   	push   %ebp
  801007:	89 e5                	mov    %esp,%ebp
  801009:	83 ec 28             	sub    $0x28,%esp
  80100c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80100f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801012:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801015:	8b 55 08             	mov    0x8(%ebp),%edx
  801018:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80101b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80101e:	b8 04 00 00 00       	mov    $0x4,%eax
  801023:	bf 00 00 00 00       	mov    $0x0,%edi
  801028:	89 fe                	mov    %edi,%esi
  80102a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  80102c:	85 c0                	test   %eax,%eax
  80102e:	7e 28                	jle    801058 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  801030:	89 44 24 10          	mov    %eax,0x10(%esp)
  801034:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80103b:	00 
  80103c:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  801043:	00 
  801044:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80104b:	00 
  80104c:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  801053:	e8 7c f1 ff ff       	call   8001d4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801058:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80105b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80105e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801061:	89 ec                	mov    %ebp,%esp
  801063:	5d                   	pop    %ebp
  801064:	c3                   	ret    

00801065 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  801065:	55                   	push   %ebp
  801066:	89 e5                	mov    %esp,%ebp
  801068:	83 ec 0c             	sub    $0xc,%esp
  80106b:	89 1c 24             	mov    %ebx,(%esp)
  80106e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801072:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801076:	b8 0b 00 00 00       	mov    $0xb,%eax
  80107b:	bf 00 00 00 00       	mov    $0x0,%edi
  801080:	89 fa                	mov    %edi,%edx
  801082:	89 f9                	mov    %edi,%ecx
  801084:	89 fb                	mov    %edi,%ebx
  801086:	89 fe                	mov    %edi,%esi
  801088:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80108a:	8b 1c 24             	mov    (%esp),%ebx
  80108d:	8b 74 24 04          	mov    0x4(%esp),%esi
  801091:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801095:	89 ec                	mov    %ebp,%esp
  801097:	5d                   	pop    %ebp
  801098:	c3                   	ret    

00801099 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
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
  8010aa:	b8 02 00 00 00       	mov    $0x2,%eax
  8010af:	bf 00 00 00 00       	mov    $0x0,%edi
  8010b4:	89 fa                	mov    %edi,%edx
  8010b6:	89 f9                	mov    %edi,%ecx
  8010b8:	89 fb                	mov    %edi,%ebx
  8010ba:	89 fe                	mov    %edi,%esi
  8010bc:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010be:	8b 1c 24             	mov    (%esp),%ebx
  8010c1:	8b 74 24 04          	mov    0x4(%esp),%esi
  8010c5:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8010c9:	89 ec                	mov    %ebp,%esp
  8010cb:	5d                   	pop    %ebp
  8010cc:	c3                   	ret    

008010cd <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8010cd:	55                   	push   %ebp
  8010ce:	89 e5                	mov    %esp,%ebp
  8010d0:	83 ec 28             	sub    $0x28,%esp
  8010d3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010d6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010d9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8010dc:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010df:	b8 03 00 00 00       	mov    $0x3,%eax
  8010e4:	bf 00 00 00 00       	mov    $0x0,%edi
  8010e9:	89 f9                	mov    %edi,%ecx
  8010eb:	89 fb                	mov    %edi,%ebx
  8010ed:	89 fe                	mov    %edi,%esi
  8010ef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8010f1:	85 c0                	test   %eax,%eax
  8010f3:	7e 28                	jle    80111d <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010f5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010f9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801100:	00 
  801101:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  801108:	00 
  801109:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801110:	00 
  801111:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  801118:	e8 b7 f0 ff ff       	call   8001d4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80111d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801120:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801123:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801126:	89 ec                	mov    %ebp,%esp
  801128:	5d                   	pop    %ebp
  801129:	c3                   	ret    
  80112a:	00 00                	add    %al,(%eax)
  80112c:	00 00                	add    %al,(%eax)
	...

00801130 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801130:	55                   	push   %ebp
  801131:	89 e5                	mov    %esp,%ebp
  801133:	8b 45 08             	mov    0x8(%ebp),%eax
  801136:	05 00 00 00 30       	add    $0x30000000,%eax
  80113b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80113e:	5d                   	pop    %ebp
  80113f:	c3                   	ret    

00801140 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801146:	8b 45 08             	mov    0x8(%ebp),%eax
  801149:	89 04 24             	mov    %eax,(%esp)
  80114c:	e8 df ff ff ff       	call   801130 <fd2num>
  801151:	c1 e0 0c             	shl    $0xc,%eax
  801154:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801159:	c9                   	leave  
  80115a:	c3                   	ret    

0080115b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80115b:	55                   	push   %ebp
  80115c:	89 e5                	mov    %esp,%ebp
  80115e:	53                   	push   %ebx
  80115f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801162:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  801167:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801169:	89 d0                	mov    %edx,%eax
  80116b:	c1 e8 16             	shr    $0x16,%eax
  80116e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801175:	a8 01                	test   $0x1,%al
  801177:	74 10                	je     801189 <fd_alloc+0x2e>
  801179:	89 d0                	mov    %edx,%eax
  80117b:	c1 e8 0c             	shr    $0xc,%eax
  80117e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801185:	a8 01                	test   $0x1,%al
  801187:	75 09                	jne    801192 <fd_alloc+0x37>
			*fd_store = fd;
  801189:	89 0b                	mov    %ecx,(%ebx)
  80118b:	b8 00 00 00 00       	mov    $0x0,%eax
  801190:	eb 19                	jmp    8011ab <fd_alloc+0x50>
			return 0;
  801192:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801198:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  80119e:	75 c7                	jne    801167 <fd_alloc+0xc>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8011a6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8011ab:	5b                   	pop    %ebx
  8011ac:	5d                   	pop    %ebp
  8011ad:	c3                   	ret    

008011ae <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011ae:	55                   	push   %ebp
  8011af:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011b1:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  8011b5:	77 38                	ja     8011ef <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ba:	c1 e0 0c             	shl    $0xc,%eax
  8011bd:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  8011c3:	89 d0                	mov    %edx,%eax
  8011c5:	c1 e8 16             	shr    $0x16,%eax
  8011c8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011cf:	a8 01                	test   $0x1,%al
  8011d1:	74 1c                	je     8011ef <fd_lookup+0x41>
  8011d3:	89 d0                	mov    %edx,%eax
  8011d5:	c1 e8 0c             	shr    $0xc,%eax
  8011d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011df:	a8 01                	test   $0x1,%al
  8011e1:	74 0c                	je     8011ef <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011e6:	89 10                	mov    %edx,(%eax)
  8011e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ed:	eb 05                	jmp    8011f4 <fd_lookup+0x46>
	return 0;
  8011ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011f4:	5d                   	pop    %ebp
  8011f5:	c3                   	ret    

008011f6 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8011f6:	55                   	push   %ebp
  8011f7:	89 e5                	mov    %esp,%ebp
  8011f9:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011fc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801203:	8b 45 08             	mov    0x8(%ebp),%eax
  801206:	89 04 24             	mov    %eax,(%esp)
  801209:	e8 a0 ff ff ff       	call   8011ae <fd_lookup>
  80120e:	85 c0                	test   %eax,%eax
  801210:	78 0e                	js     801220 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801212:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801215:	8b 55 0c             	mov    0xc(%ebp),%edx
  801218:	89 50 04             	mov    %edx,0x4(%eax)
  80121b:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801220:	c9                   	leave  
  801221:	c3                   	ret    

00801222 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801222:	55                   	push   %ebp
  801223:	89 e5                	mov    %esp,%ebp
  801225:	53                   	push   %ebx
  801226:	83 ec 14             	sub    $0x14,%esp
  801229:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80122c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80122f:	ba 04 50 80 00       	mov    $0x805004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801234:	b8 00 00 00 00       	mov    $0x0,%eax
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801239:	39 0d 04 50 80 00    	cmp    %ecx,0x805004
  80123f:	75 11                	jne    801252 <dev_lookup+0x30>
  801241:	eb 04                	jmp    801247 <dev_lookup+0x25>
  801243:	39 0a                	cmp    %ecx,(%edx)
  801245:	75 0b                	jne    801252 <dev_lookup+0x30>
			*dev = devtab[i];
  801247:	89 13                	mov    %edx,(%ebx)
  801249:	b8 00 00 00 00       	mov    $0x0,%eax
  80124e:	66 90                	xchg   %ax,%ax
  801250:	eb 35                	jmp    801287 <dev_lookup+0x65>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801252:	83 c0 01             	add    $0x1,%eax
  801255:	8b 14 85 e8 28 80 00 	mov    0x8028e8(,%eax,4),%edx
  80125c:	85 d2                	test   %edx,%edx
  80125e:	75 e3                	jne    801243 <dev_lookup+0x21>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  801260:	a1 20 50 80 00       	mov    0x805020,%eax
  801265:	8b 40 4c             	mov    0x4c(%eax),%eax
  801268:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80126c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801270:	c7 04 24 6c 28 80 00 	movl   $0x80286c,(%esp)
  801277:	e8 25 f0 ff ff       	call   8002a1 <cprintf>
	*dev = 0;
  80127c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801282:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801287:	83 c4 14             	add    $0x14,%esp
  80128a:	5b                   	pop    %ebx
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    

0080128d <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801293:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801296:	89 44 24 04          	mov    %eax,0x4(%esp)
  80129a:	8b 45 08             	mov    0x8(%ebp),%eax
  80129d:	89 04 24             	mov    %eax,(%esp)
  8012a0:	e8 09 ff ff ff       	call   8011ae <fd_lookup>
  8012a5:	89 c2                	mov    %eax,%edx
  8012a7:	85 c0                	test   %eax,%eax
  8012a9:	78 5a                	js     801305 <fstat+0x78>
  8012ab:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8012b5:	8b 00                	mov    (%eax),%eax
  8012b7:	89 04 24             	mov    %eax,(%esp)
  8012ba:	e8 63 ff ff ff       	call   801222 <dev_lookup>
  8012bf:	89 c2                	mov    %eax,%edx
  8012c1:	85 c0                	test   %eax,%eax
  8012c3:	78 40                	js     801305 <fstat+0x78>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8012c5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  8012ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012cd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012d1:	74 32                	je     801305 <fstat+0x78>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012d6:	c6 00 00             	movb   $0x0,(%eax)
	stat->st_size = 0;
  8012d9:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  8012e0:	00 00 00 
	stat->st_isdir = 0;
  8012e3:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
  8012ea:	00 00 00 
	stat->st_dev = dev;
  8012ed:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8012f0:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
	return (*dev->dev_stat)(fd, stat);
  8012f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8012fd:	89 04 24             	mov    %eax,(%esp)
  801300:	ff 52 14             	call   *0x14(%edx)
  801303:	89 c2                	mov    %eax,%edx
}
  801305:	89 d0                	mov    %edx,%eax
  801307:	c9                   	leave  
  801308:	c3                   	ret    

00801309 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801309:	55                   	push   %ebp
  80130a:	89 e5                	mov    %esp,%ebp
  80130c:	53                   	push   %ebx
  80130d:	83 ec 24             	sub    $0x24,%esp
  801310:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801313:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801316:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131a:	89 1c 24             	mov    %ebx,(%esp)
  80131d:	e8 8c fe ff ff       	call   8011ae <fd_lookup>
  801322:	85 c0                	test   %eax,%eax
  801324:	78 61                	js     801387 <ftruncate+0x7e>
  801326:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801329:	8b 10                	mov    (%eax),%edx
  80132b:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80132e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801332:	89 14 24             	mov    %edx,(%esp)
  801335:	e8 e8 fe ff ff       	call   801222 <dev_lookup>
  80133a:	85 c0                	test   %eax,%eax
  80133c:	78 49                	js     801387 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80133e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801341:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801345:	75 23                	jne    80136a <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801347:	a1 20 50 80 00       	mov    0x805020,%eax
  80134c:	8b 40 4c             	mov    0x4c(%eax),%eax
  80134f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801353:	89 44 24 04          	mov    %eax,0x4(%esp)
  801357:	c7 04 24 8c 28 80 00 	movl   $0x80288c,(%esp)
  80135e:	e8 3e ef ff ff       	call   8002a1 <cprintf>
  801363:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801368:	eb 1d                	jmp    801387 <ftruncate+0x7e>
			env->env_id, fdnum); 
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80136a:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80136d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801372:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  801376:	74 0f                	je     801387 <ftruncate+0x7e>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801378:	8b 42 18             	mov    0x18(%edx),%eax
  80137b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80137e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801382:	89 0c 24             	mov    %ecx,(%esp)
  801385:	ff d0                	call   *%eax
}
  801387:	83 c4 24             	add    $0x24,%esp
  80138a:	5b                   	pop    %ebx
  80138b:	5d                   	pop    %ebp
  80138c:	c3                   	ret    

0080138d <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80138d:	55                   	push   %ebp
  80138e:	89 e5                	mov    %esp,%ebp
  801390:	53                   	push   %ebx
  801391:	83 ec 24             	sub    $0x24,%esp
  801394:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801397:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139e:	89 1c 24             	mov    %ebx,(%esp)
  8013a1:	e8 08 fe ff ff       	call   8011ae <fd_lookup>
  8013a6:	85 c0                	test   %eax,%eax
  8013a8:	78 68                	js     801412 <write+0x85>
  8013aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ad:	8b 10                	mov    (%eax),%edx
  8013af:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8013b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b6:	89 14 24             	mov    %edx,(%esp)
  8013b9:	e8 64 fe ff ff       	call   801222 <dev_lookup>
  8013be:	85 c0                	test   %eax,%eax
  8013c0:	78 50                	js     801412 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013c2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  8013c5:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  8013c9:	75 23                	jne    8013ee <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  8013cb:	a1 20 50 80 00       	mov    0x805020,%eax
  8013d0:	8b 40 4c             	mov    0x4c(%eax),%eax
  8013d3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013db:	c7 04 24 ad 28 80 00 	movl   $0x8028ad,(%esp)
  8013e2:	e8 ba ee ff ff       	call   8002a1 <cprintf>
  8013e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013ec:	eb 24                	jmp    801412 <write+0x85>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013ee:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8013f1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013f6:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  8013fa:	74 16                	je     801412 <write+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013fc:	8b 42 0c             	mov    0xc(%edx),%eax
  8013ff:	8b 55 10             	mov    0x10(%ebp),%edx
  801402:	89 54 24 08          	mov    %edx,0x8(%esp)
  801406:	8b 55 0c             	mov    0xc(%ebp),%edx
  801409:	89 54 24 04          	mov    %edx,0x4(%esp)
  80140d:	89 0c 24             	mov    %ecx,(%esp)
  801410:	ff d0                	call   *%eax
}
  801412:	83 c4 24             	add    $0x24,%esp
  801415:	5b                   	pop    %ebx
  801416:	5d                   	pop    %ebp
  801417:	c3                   	ret    

00801418 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801418:	55                   	push   %ebp
  801419:	89 e5                	mov    %esp,%ebp
  80141b:	53                   	push   %ebx
  80141c:	83 ec 24             	sub    $0x24,%esp
  80141f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801422:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801425:	89 44 24 04          	mov    %eax,0x4(%esp)
  801429:	89 1c 24             	mov    %ebx,(%esp)
  80142c:	e8 7d fd ff ff       	call   8011ae <fd_lookup>
  801431:	85 c0                	test   %eax,%eax
  801433:	78 6d                	js     8014a2 <read+0x8a>
  801435:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801438:	8b 10                	mov    (%eax),%edx
  80143a:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80143d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801441:	89 14 24             	mov    %edx,(%esp)
  801444:	e8 d9 fd ff ff       	call   801222 <dev_lookup>
  801449:	85 c0                	test   %eax,%eax
  80144b:	78 55                	js     8014a2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80144d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801450:	8b 41 08             	mov    0x8(%ecx),%eax
  801453:	83 e0 03             	and    $0x3,%eax
  801456:	83 f8 01             	cmp    $0x1,%eax
  801459:	75 23                	jne    80147e <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  80145b:	a1 20 50 80 00       	mov    0x805020,%eax
  801460:	8b 40 4c             	mov    0x4c(%eax),%eax
  801463:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801467:	89 44 24 04          	mov    %eax,0x4(%esp)
  80146b:	c7 04 24 ca 28 80 00 	movl   $0x8028ca,(%esp)
  801472:	e8 2a ee ff ff       	call   8002a1 <cprintf>
  801477:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80147c:	eb 24                	jmp    8014a2 <read+0x8a>
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80147e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801481:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801486:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  80148a:	74 16                	je     8014a2 <read+0x8a>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80148c:	8b 42 08             	mov    0x8(%edx),%eax
  80148f:	8b 55 10             	mov    0x10(%ebp),%edx
  801492:	89 54 24 08          	mov    %edx,0x8(%esp)
  801496:	8b 55 0c             	mov    0xc(%ebp),%edx
  801499:	89 54 24 04          	mov    %edx,0x4(%esp)
  80149d:	89 0c 24             	mov    %ecx,(%esp)
  8014a0:	ff d0                	call   *%eax
}
  8014a2:	83 c4 24             	add    $0x24,%esp
  8014a5:	5b                   	pop    %ebx
  8014a6:	5d                   	pop    %ebp
  8014a7:	c3                   	ret    

008014a8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014a8:	55                   	push   %ebp
  8014a9:	89 e5                	mov    %esp,%ebp
  8014ab:	57                   	push   %edi
  8014ac:	56                   	push   %esi
  8014ad:	53                   	push   %ebx
  8014ae:	83 ec 0c             	sub    $0xc,%esp
  8014b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8014b4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8014bc:	85 f6                	test   %esi,%esi
  8014be:	74 36                	je     8014f6 <readn+0x4e>
  8014c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014c5:	ba 00 00 00 00       	mov    $0x0,%edx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014ca:	89 f0                	mov    %esi,%eax
  8014cc:	29 d0                	sub    %edx,%eax
  8014ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014d2:	8d 04 17             	lea    (%edi,%edx,1),%eax
  8014d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014dc:	89 04 24             	mov    %eax,(%esp)
  8014df:	e8 34 ff ff ff       	call   801418 <read>
		if (m < 0)
  8014e4:	85 c0                	test   %eax,%eax
  8014e6:	78 0e                	js     8014f6 <readn+0x4e>
			return m;
		if (m == 0)
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	74 08                	je     8014f4 <readn+0x4c>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ec:	01 c3                	add    %eax,%ebx
  8014ee:	89 da                	mov    %ebx,%edx
  8014f0:	39 f3                	cmp    %esi,%ebx
  8014f2:	72 d6                	jb     8014ca <readn+0x22>
  8014f4:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014f6:	83 c4 0c             	add    $0xc,%esp
  8014f9:	5b                   	pop    %ebx
  8014fa:	5e                   	pop    %esi
  8014fb:	5f                   	pop    %edi
  8014fc:	5d                   	pop    %ebp
  8014fd:	c3                   	ret    

008014fe <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	83 ec 28             	sub    $0x28,%esp
  801504:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801507:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80150a:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80150d:	89 34 24             	mov    %esi,(%esp)
  801510:	e8 1b fc ff ff       	call   801130 <fd2num>
  801515:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801518:	89 54 24 04          	mov    %edx,0x4(%esp)
  80151c:	89 04 24             	mov    %eax,(%esp)
  80151f:	e8 8a fc ff ff       	call   8011ae <fd_lookup>
  801524:	89 c3                	mov    %eax,%ebx
  801526:	85 c0                	test   %eax,%eax
  801528:	78 05                	js     80152f <fd_close+0x31>
  80152a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80152d:	74 0d                	je     80153c <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80152f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801533:	75 44                	jne    801579 <fd_close+0x7b>
  801535:	bb 00 00 00 00       	mov    $0x0,%ebx
  80153a:	eb 3d                	jmp    801579 <fd_close+0x7b>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80153c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801543:	8b 06                	mov    (%esi),%eax
  801545:	89 04 24             	mov    %eax,(%esp)
  801548:	e8 d5 fc ff ff       	call   801222 <dev_lookup>
  80154d:	89 c3                	mov    %eax,%ebx
  80154f:	85 c0                	test   %eax,%eax
  801551:	78 16                	js     801569 <fd_close+0x6b>
		if (dev->dev_close)
  801553:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801556:	8b 40 10             	mov    0x10(%eax),%eax
  801559:	bb 00 00 00 00       	mov    $0x0,%ebx
  80155e:	85 c0                	test   %eax,%eax
  801560:	74 07                	je     801569 <fd_close+0x6b>
			r = (*dev->dev_close)(fd);
  801562:	89 34 24             	mov    %esi,(%esp)
  801565:	ff d0                	call   *%eax
  801567:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801569:	89 74 24 04          	mov    %esi,0x4(%esp)
  80156d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801574:	e8 d1 f9 ff ff       	call   800f4a <sys_page_unmap>
	return r;
}
  801579:	89 d8                	mov    %ebx,%eax
  80157b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80157e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801581:	89 ec                	mov    %ebp,%esp
  801583:	5d                   	pop    %ebp
  801584:	c3                   	ret    

00801585 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801585:	55                   	push   %ebp
  801586:	89 e5                	mov    %esp,%ebp
  801588:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80158b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80158e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801592:	8b 45 08             	mov    0x8(%ebp),%eax
  801595:	89 04 24             	mov    %eax,(%esp)
  801598:	e8 11 fc ff ff       	call   8011ae <fd_lookup>
  80159d:	85 c0                	test   %eax,%eax
  80159f:	78 13                	js     8015b4 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8015a1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8015a8:	00 
  8015a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015ac:	89 04 24             	mov    %eax,(%esp)
  8015af:	e8 4a ff ff ff       	call   8014fe <fd_close>
}
  8015b4:	c9                   	leave  
  8015b5:	c3                   	ret    

008015b6 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8015b6:	55                   	push   %ebp
  8015b7:	89 e5                	mov    %esp,%ebp
  8015b9:	83 ec 18             	sub    $0x18,%esp
  8015bc:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8015bf:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015c2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015c9:	00 
  8015ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8015cd:	89 04 24             	mov    %eax,(%esp)
  8015d0:	e8 6a 03 00 00       	call   80193f <open>
  8015d5:	89 c6                	mov    %eax,%esi
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	78 1b                	js     8015f6 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8015db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e2:	89 34 24             	mov    %esi,(%esp)
  8015e5:	e8 a3 fc ff ff       	call   80128d <fstat>
  8015ea:	89 c3                	mov    %eax,%ebx
	close(fd);
  8015ec:	89 34 24             	mov    %esi,(%esp)
  8015ef:	e8 91 ff ff ff       	call   801585 <close>
  8015f4:	89 de                	mov    %ebx,%esi
	return r;
}
  8015f6:	89 f0                	mov    %esi,%eax
  8015f8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8015fb:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8015fe:	89 ec                	mov    %ebp,%esp
  801600:	5d                   	pop    %ebp
  801601:	c3                   	ret    

00801602 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801602:	55                   	push   %ebp
  801603:	89 e5                	mov    %esp,%ebp
  801605:	83 ec 38             	sub    $0x38,%esp
  801608:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80160b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80160e:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801611:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801614:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801617:	89 44 24 04          	mov    %eax,0x4(%esp)
  80161b:	8b 45 08             	mov    0x8(%ebp),%eax
  80161e:	89 04 24             	mov    %eax,(%esp)
  801621:	e8 88 fb ff ff       	call   8011ae <fd_lookup>
  801626:	89 c3                	mov    %eax,%ebx
  801628:	85 c0                	test   %eax,%eax
  80162a:	0f 88 e1 00 00 00    	js     801711 <dup+0x10f>
		return r;
	close(newfdnum);
  801630:	89 3c 24             	mov    %edi,(%esp)
  801633:	e8 4d ff ff ff       	call   801585 <close>

	newfd = INDEX2FD(newfdnum);
  801638:	89 f8                	mov    %edi,%eax
  80163a:	c1 e0 0c             	shl    $0xc,%eax
  80163d:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  801643:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801646:	89 04 24             	mov    %eax,(%esp)
  801649:	e8 f2 fa ff ff       	call   801140 <fd2data>
  80164e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801650:	89 34 24             	mov    %esi,(%esp)
  801653:	e8 e8 fa ff ff       	call   801140 <fd2data>
  801658:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  80165b:	89 d8                	mov    %ebx,%eax
  80165d:	c1 e8 16             	shr    $0x16,%eax
  801660:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801667:	a8 01                	test   $0x1,%al
  801669:	74 45                	je     8016b0 <dup+0xae>
  80166b:	89 da                	mov    %ebx,%edx
  80166d:	c1 ea 0c             	shr    $0xc,%edx
  801670:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801677:	a8 01                	test   $0x1,%al
  801679:	74 35                	je     8016b0 <dup+0xae>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  80167b:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801682:	25 07 0e 00 00       	and    $0xe07,%eax
  801687:	89 44 24 10          	mov    %eax,0x10(%esp)
  80168b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80168e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801692:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801699:	00 
  80169a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80169e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016a5:	e8 fe f8 ff ff       	call   800fa8 <sys_page_map>
  8016aa:	89 c3                	mov    %eax,%ebx
  8016ac:	85 c0                	test   %eax,%eax
  8016ae:	78 3e                	js     8016ee <dup+0xec>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  8016b0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016b3:	89 d0                	mov    %edx,%eax
  8016b5:	c1 e8 0c             	shr    $0xc,%eax
  8016b8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016bf:	25 07 0e 00 00       	and    $0xe07,%eax
  8016c4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016c8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8016cc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016d3:	00 
  8016d4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8016d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016df:	e8 c4 f8 ff ff       	call   800fa8 <sys_page_map>
  8016e4:	89 c3                	mov    %eax,%ebx
  8016e6:	85 c0                	test   %eax,%eax
  8016e8:	78 04                	js     8016ee <dup+0xec>
		goto err;
  8016ea:	89 fb                	mov    %edi,%ebx
  8016ec:	eb 23                	jmp    801711 <dup+0x10f>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016ee:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016f9:	e8 4c f8 ff ff       	call   800f4a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801701:	89 44 24 04          	mov    %eax,0x4(%esp)
  801705:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80170c:	e8 39 f8 ff ff       	call   800f4a <sys_page_unmap>
	return r;
}
  801711:	89 d8                	mov    %ebx,%eax
  801713:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801716:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801719:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80171c:	89 ec                	mov    %ebp,%esp
  80171e:	5d                   	pop    %ebp
  80171f:	c3                   	ret    

00801720 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	53                   	push   %ebx
  801724:	83 ec 04             	sub    $0x4,%esp
  801727:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  80172c:	89 1c 24             	mov    %ebx,(%esp)
  80172f:	e8 51 fe ff ff       	call   801585 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801734:	83 c3 01             	add    $0x1,%ebx
  801737:	83 fb 20             	cmp    $0x20,%ebx
  80173a:	75 f0                	jne    80172c <close_all+0xc>
		close(i);
}
  80173c:	83 c4 04             	add    $0x4,%esp
  80173f:	5b                   	pop    %ebx
  801740:	5d                   	pop    %ebp
  801741:	c3                   	ret    
	...

00801744 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	53                   	push   %ebx
  801748:	83 ec 14             	sub    $0x14,%esp
  80174b:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80174d:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  801753:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80175a:	00 
  80175b:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801762:	00 
  801763:	89 44 24 04          	mov    %eax,0x4(%esp)
  801767:	89 14 24             	mov    %edx,(%esp)
  80176a:	e8 81 08 00 00       	call   801ff0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80176f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801776:	00 
  801777:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80177b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801782:	e8 1d 09 00 00       	call   8020a4 <ipc_recv>
}
  801787:	83 c4 14             	add    $0x14,%esp
  80178a:	5b                   	pop    %ebx
  80178b:	5d                   	pop    %ebp
  80178c:	c3                   	ret    

0080178d <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  80178d:	55                   	push   %ebp
  80178e:	89 e5                	mov    %esp,%ebp
  801790:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801793:	ba 00 00 00 00       	mov    $0x0,%edx
  801798:	b8 08 00 00 00       	mov    $0x8,%eax
  80179d:	e8 a2 ff ff ff       	call   801744 <fsipc>
}
  8017a2:	c9                   	leave  
  8017a3:	c3                   	ret    

008017a4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017a4:	55                   	push   %ebp
  8017a5:	89 e5                	mov    %esp,%ebp
  8017a7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b0:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.set_size.req_size = newsize;
  8017b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b8:	a3 04 30 80 00       	mov    %eax,0x803004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c2:	b8 02 00 00 00       	mov    $0x2,%eax
  8017c7:	e8 78 ff ff ff       	call   801744 <fsipc>
}
  8017cc:	c9                   	leave  
  8017cd:	c3                   	ret    

008017ce <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8017da:	a3 00 30 80 00       	mov    %eax,0x803000
	return fsipc(FSREQ_FLUSH, NULL);
  8017df:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e4:	b8 06 00 00 00       	mov    $0x6,%eax
  8017e9:	e8 56 ff ff ff       	call   801744 <fsipc>
}
  8017ee:	c9                   	leave  
  8017ef:	c3                   	ret    

008017f0 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	53                   	push   %ebx
  8017f4:	83 ec 14             	sub    $0x14,%esp
  8017f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801800:	a3 00 30 80 00       	mov    %eax,0x803000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801805:	ba 00 00 00 00       	mov    $0x0,%edx
  80180a:	b8 05 00 00 00       	mov    $0x5,%eax
  80180f:	e8 30 ff ff ff       	call   801744 <fsipc>
  801814:	85 c0                	test   %eax,%eax
  801816:	78 2b                	js     801843 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801818:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  80181f:	00 
  801820:	89 1c 24             	mov    %ebx,(%esp)
  801823:	e8 d9 f0 ff ff       	call   800901 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801828:	a1 80 30 80 00       	mov    0x803080,%eax
  80182d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801833:	a1 84 30 80 00       	mov    0x803084,%eax
  801838:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  80183e:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801843:	83 c4 14             	add    $0x14,%esp
  801846:	5b                   	pop    %ebx
  801847:	5d                   	pop    %ebp
  801848:	c3                   	ret    

00801849 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801849:	55                   	push   %ebp
  80184a:	89 e5                	mov    %esp,%ebp
  80184c:	83 ec 18             	sub    $0x18,%esp
  80184f:	8b 55 10             	mov    0x10(%ebp),%edx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	ssize_t writesize;
	size_t bufsize;
	fsipcbuf.write.req_fileid=fd->fd_file.id;
  801852:	8b 45 08             	mov    0x8(%ebp),%eax
  801855:	8b 40 0c             	mov    0xc(%eax),%eax
  801858:	a3 00 30 80 00       	mov    %eax,0x803000
	bufsize=sizeof(fsipcbuf.write.req_buf);
	if(n<bufsize)
  80185d:	89 d0                	mov    %edx,%eax
  80185f:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  801865:	76 05                	jbe    80186c <devfile_write+0x23>
  801867:	b8 f8 0f 00 00       	mov    $0xff8,%eax
		bufsize=n;	
	fsipcbuf.write.req_n=n;
  80186c:	89 15 04 30 80 00    	mov    %edx,0x803004
	memmove((void*)fsipcbuf.write.req_buf,buf,bufsize);
  801872:	89 44 24 08          	mov    %eax,0x8(%esp)
  801876:	8b 45 0c             	mov    0xc(%ebp),%eax
  801879:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187d:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  801884:	e8 7f f2 ff ff       	call   800b08 <memmove>
	writesize=(ssize_t)fsipc(FSREQ_WRITE,NULL);
  801889:	ba 00 00 00 00       	mov    $0x0,%edx
  80188e:	b8 04 00 00 00       	mov    $0x4,%eax
  801893:	e8 ac fe ff ff       	call   801744 <fsipc>
	return writesize;
	//panic("devfile_write not implemented");
}
  801898:	c9                   	leave  
  801899:	c3                   	ret    

0080189a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80189a:	55                   	push   %ebp
  80189b:	89 e5                	mov    %esp,%ebp
  80189d:	53                   	push   %ebx
  80189e:	83 ec 14             	sub    $0x14,%esp
	// system server.
	// LAB 5: Your code here
	ssize_t readsize;
	if(debug)
		cprintf("devfile_read:fileid=%x readsize=%x\n",fd->fd_file.id,n);
	fsipcbuf.read.req_fileid=fd->fd_file.id;
  8018a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a4:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a7:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.read.req_n=n;
  8018ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8018af:	a3 04 30 80 00       	mov    %eax,0x803004
	readsize=(ssize_t)fsipc(FSREQ_READ,&fsipcbuf);
  8018b4:	ba 00 30 80 00       	mov    $0x803000,%edx
  8018b9:	b8 03 00 00 00       	mov    $0x3,%eax
  8018be:	e8 81 fe ff ff       	call   801744 <fsipc>
  8018c3:	89 c3                	mov    %eax,%ebx
	cprintf("readsize=%d\n",readsize);
  8018c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c9:	c7 04 24 f0 28 80 00 	movl   $0x8028f0,(%esp)
  8018d0:	e8 cc e9 ff ff       	call   8002a1 <cprintf>
	if(debug)
		cprintf("devfile_read:buf1=%s\nbuf2=%s\n",(char*)&fsipcbuf,fsipcbuf.readRet.ret_buf);
	if(readsize>0)
  8018d5:	85 db                	test   %ebx,%ebx
  8018d7:	7e 17                	jle    8018f0 <devfile_read+0x56>
		memmove(buf,(void*)&fsipcbuf,(size_t)readsize);
  8018d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018dd:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  8018e4:	00 
  8018e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e8:	89 04 24             	mov    %eax,(%esp)
  8018eb:	e8 18 f2 ff ff       	call   800b08 <memmove>
	//cprintf("readsize=%d",readsize);
	return readsize;
	//panic("devfile_read not implemented");
}
  8018f0:	89 d8                	mov    %ebx,%eax
  8018f2:	83 c4 14             	add    $0x14,%esp
  8018f5:	5b                   	pop    %ebx
  8018f6:	5d                   	pop    %ebp
  8018f7:	c3                   	ret    

008018f8 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  8018f8:	55                   	push   %ebp
  8018f9:	89 e5                	mov    %esp,%ebp
  8018fb:	53                   	push   %ebx
  8018fc:	83 ec 14             	sub    $0x14,%esp
  8018ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801902:	89 1c 24             	mov    %ebx,(%esp)
  801905:	e8 a6 ef ff ff       	call   8008b0 <strlen>
  80190a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  80190f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801914:	7f 21                	jg     801937 <remove+0x3f>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801916:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80191a:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801921:	e8 db ef ff ff       	call   800901 <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801926:	ba 00 00 00 00       	mov    $0x0,%edx
  80192b:	b8 07 00 00 00       	mov    $0x7,%eax
  801930:	e8 0f fe ff ff       	call   801744 <fsipc>
  801935:	89 c2                	mov    %eax,%edx
}
  801937:	89 d0                	mov    %edx,%eax
  801939:	83 c4 14             	add    $0x14,%esp
  80193c:	5b                   	pop    %ebx
  80193d:	5d                   	pop    %ebp
  80193e:	c3                   	ret    

0080193f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80193f:	55                   	push   %ebp
  801940:	89 e5                	mov    %esp,%ebp
  801942:	53                   	push   %ebx
  801943:	83 ec 24             	sub    $0x24,%esp
	// file descriptor.

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;
	if((r=fd_alloc(&fd))<0){
  801946:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801949:	89 04 24             	mov    %eax,(%esp)
  80194c:	e8 0a f8 ff ff       	call   80115b <fd_alloc>
  801951:	89 c3                	mov    %eax,%ebx
  801953:	85 c0                	test   %eax,%eax
  801955:	79 18                	jns    80196f <open+0x30>
		fd_close(fd,0);
  801957:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80195e:	00 
  80195f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801962:	89 04 24             	mov    %eax,(%esp)
  801965:	e8 94 fb ff ff       	call   8014fe <fd_close>
  80196a:	e9 b4 00 00 00       	jmp    801a23 <open+0xe4>
		return r;
	}
	cprintf("open:fd=%x\n",fd);
  80196f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801972:	89 44 24 04          	mov    %eax,0x4(%esp)
  801976:	c7 04 24 fd 28 80 00 	movl   $0x8028fd,(%esp)
  80197d:	e8 1f e9 ff ff       	call   8002a1 <cprintf>
	strcpy(fsipcbuf.open.req_path,path);
  801982:	8b 45 08             	mov    0x8(%ebp),%eax
  801985:	89 44 24 04          	mov    %eax,0x4(%esp)
  801989:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801990:	e8 6c ef ff ff       	call   800901 <strcpy>
	fsipcbuf.open.req_omode=mode;
  801995:	8b 45 0c             	mov    0xc(%ebp),%eax
  801998:	a3 00 34 80 00       	mov    %eax,0x803400
	if((r=fsipc(FSREQ_OPEN,(void*)fd))<0)
  80199d:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8019a0:	b8 01 00 00 00       	mov    $0x1,%eax
  8019a5:	e8 9a fd ff ff       	call   801744 <fsipc>
  8019aa:	89 c3                	mov    %eax,%ebx
  8019ac:	85 c0                	test   %eax,%eax
  8019ae:	79 15                	jns    8019c5 <open+0x86>
	{
		fd_close(fd,1);
  8019b0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8019b7:	00 
  8019b8:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8019bb:	89 04 24             	mov    %eax,(%esp)
  8019be:	e8 3b fb ff ff       	call   8014fe <fd_close>
  8019c3:	eb 5e                	jmp    801a23 <open+0xe4>
		return r;	
	}
	if((r=sys_page_map(0,(void*)fd,0,(void*)fd,PTE_P | PTE_W | PTE_U))<0)
  8019c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8019c8:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8019cf:	00 
  8019d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019db:	00 
  8019dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019e7:	e8 bc f5 ff ff       	call   800fa8 <sys_page_map>
  8019ec:	89 c3                	mov    %eax,%ebx
  8019ee:	85 c0                	test   %eax,%eax
  8019f0:	79 15                	jns    801a07 <open+0xc8>
	{
		fd_close(fd,1);
  8019f2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8019f9:	00 
  8019fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8019fd:	89 04 24             	mov    %eax,(%esp)
  801a00:	e8 f9 fa ff ff       	call   8014fe <fd_close>
  801a05:	eb 1c                	jmp    801a23 <open+0xe4>
		return r;
	}
	//INDEX2DATA(fd->fd_file.id);
	cprintf("fileid=%x\n",fd->fd_file.id);
  801a07:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801a0a:	8b 40 0c             	mov    0xc(%eax),%eax
  801a0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a11:	c7 04 24 09 29 80 00 	movl   $0x802909,(%esp)
  801a18:	e8 84 e8 ff ff       	call   8002a1 <cprintf>
	return fd->fd_file.id;
  801a1d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801a20:	8b 58 0c             	mov    0xc(%eax),%ebx
	//panic("open not implemented");
}
  801a23:	89 d8                	mov    %ebx,%eax
  801a25:	83 c4 24             	add    $0x24,%esp
  801a28:	5b                   	pop    %ebx
  801a29:	5d                   	pop    %ebp
  801a2a:	c3                   	ret    
	...

00801a2c <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801a2c:	55                   	push   %ebp
  801a2d:	89 e5                	mov    %esp,%ebp
  801a2f:	57                   	push   %edi
  801a30:	56                   	push   %esi
  801a31:	53                   	push   %ebx
  801a32:	81 ec 9c 02 00 00    	sub    $0x29c,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801a38:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a3f:	00 
  801a40:	8b 45 08             	mov    0x8(%ebp),%eax
  801a43:	89 04 24             	mov    %eax,(%esp)
  801a46:	e8 f4 fe ff ff       	call   80193f <open>
  801a4b:	89 85 a0 fd ff ff    	mov    %eax,-0x260(%ebp)
  801a51:	89 85 9c fd ff ff    	mov    %eax,-0x264(%ebp)
  801a57:	85 c0                	test   %eax,%eax
  801a59:	0f 88 5e 05 00 00    	js     801fbd <spawn+0x591>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (read(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801a5f:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801a66:	00 
  801a67:	8d 85 f4 fd ff ff    	lea    -0x20c(%ebp),%eax
  801a6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a71:	8b 95 a0 fd ff ff    	mov    -0x260(%ebp),%edx
  801a77:	89 14 24             	mov    %edx,(%esp)
  801a7a:	e8 99 f9 ff ff       	call   801418 <read>
  801a7f:	3d 00 02 00 00       	cmp    $0x200,%eax
  801a84:	75 0c                	jne    801a92 <spawn+0x66>
  801a86:	81 bd f4 fd ff ff 7f 	cmpl   $0x464c457f,-0x20c(%ebp)
  801a8d:	45 4c 46 
  801a90:	74 3b                	je     801acd <spawn+0xa1>
	    || elf->e_magic != ELF_MAGIC) {
		close(fd);
  801a92:	8b 8d a0 fd ff ff    	mov    -0x260(%ebp),%ecx
  801a98:	89 0c 24             	mov    %ecx,(%esp)
  801a9b:	e8 e5 fa ff ff       	call   801585 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801aa0:	8b 85 f4 fd ff ff    	mov    -0x20c(%ebp),%eax
  801aa6:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801aad:	46 
  801aae:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab2:	c7 04 24 14 29 80 00 	movl   $0x802914,(%esp)
  801ab9:	e8 e3 e7 ff ff       	call   8002a1 <cprintf>
  801abe:	c7 85 9c fd ff ff f2 	movl   $0xfffffff2,-0x264(%ebp)
  801ac5:	ff ff ff 
  801ac8:	e9 f0 04 00 00       	jmp    801fbd <spawn+0x591>
static __inline envid_t sys_exofork(void) __attribute__((always_inline));
static __inline envid_t
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801acd:	ba 07 00 00 00       	mov    $0x7,%edx
  801ad2:	89 d0                	mov    %edx,%eax
  801ad4:	cd 30                	int    $0x30
  801ad6:	89 85 9c fd ff ff    	mov    %eax,-0x264(%ebp)
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801adc:	85 c0                	test   %eax,%eax
  801ade:	0f 88 d9 04 00 00    	js     801fbd <spawn+0x591>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801ae4:	25 ff 03 00 00       	and    $0x3ff,%eax
  801ae9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801aec:	8d 95 b0 fd ff ff    	lea    -0x250(%ebp),%edx
  801af2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801af7:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
  801afe:	00 
  801aff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b03:	89 14 24             	mov    %edx,(%esp)
  801b06:	e8 7d f0 ff ff       	call   800b88 <memcpy>
	child_tf.tf_eip = elf->e_entry;
  801b0b:	8b 85 0c fe ff ff    	mov    -0x1f4(%ebp),%eax
  801b11:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801b17:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b1a:	8b 02                	mov    (%edx),%eax
  801b1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b21:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801b28:	00 00 00 
  801b2b:	85 c0                	test   %eax,%eax
  801b2d:	75 11                	jne    801b40 <spawn+0x114>
  801b2f:	bf 00 00 00 00       	mov    $0x0,%edi
  801b34:	c7 85 84 fd ff ff 00 	movl   $0x0,-0x27c(%ebp)
  801b3b:	00 00 00 
  801b3e:	eb 30                	jmp    801b70 <spawn+0x144>
		string_size += strlen(argv[argc]) + 1;
  801b40:	89 04 24             	mov    %eax,(%esp)
  801b43:	e8 68 ed ff ff       	call   8008b0 <strlen>
  801b48:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801b4c:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  801b53:	8b bd 7c fd ff ff    	mov    -0x284(%ebp),%edi
  801b59:	8d 0c bd 00 00 00 00 	lea    0x0(,%edi,4),%ecx
  801b60:	89 8d 84 fd ff ff    	mov    %ecx,-0x27c(%ebp)
  801b66:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b69:	8b 04 ba             	mov    (%edx,%edi,4),%eax
  801b6c:	85 c0                	test   %eax,%eax
  801b6e:	75 d0                	jne    801b40 <spawn+0x114>
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801b70:	b8 00 10 40 00       	mov    $0x401000,%eax
  801b75:	89 c6                	mov    %eax,%esi
  801b77:	29 de                	sub    %ebx,%esi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801b79:	89 f2                	mov    %esi,%edx
  801b7b:	83 e2 fc             	and    $0xfffffffc,%edx
  801b7e:	8b 8d 7c fd ff ff    	mov    -0x284(%ebp),%ecx
  801b84:	8d 04 8d 04 00 00 00 	lea    0x4(,%ecx,4),%eax
  801b8b:	29 c2                	sub    %eax,%edx
  801b8d:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  801b93:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
	
	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801b99:	89 d0                	mov    %edx,%eax
  801b9b:	83 e8 08             	sub    $0x8,%eax

	return child;

error:
	sys_env_destroy(child);
	close(fd);
  801b9e:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
	
	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801ba3:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801ba8:	0f 86 09 04 00 00    	jbe    801fb7 <spawn+0x58b>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801bae:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801bb5:	00 
  801bb6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801bbd:	00 
  801bbe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bc5:	e8 3c f4 ff ff       	call   801006 <sys_page_alloc>
  801bca:	89 c2                	mov    %eax,%edx
  801bcc:	85 c0                	test   %eax,%eax
  801bce:	0f 88 e3 03 00 00    	js     801fb7 <spawn+0x58b>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801bd4:	83 bd 7c fd ff ff 00 	cmpl   $0x0,-0x284(%ebp)
  801bdb:	7e 43                	jle    801c20 <spawn+0x1f4>
  801bdd:	bb 00 00 00 00       	mov    $0x0,%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  801be2:	8d 86 00 d0 7f ee    	lea    -0x11803000(%esi),%eax
  801be8:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801bee:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  801bf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bf4:	8b 04 99             	mov    (%ecx,%ebx,4),%eax
  801bf7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bfb:	89 34 24             	mov    %esi,(%esp)
  801bfe:	e8 fe ec ff ff       	call   800901 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801c03:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c06:	8b 04 9a             	mov    (%edx,%ebx,4),%eax
  801c09:	89 04 24             	mov    %eax,(%esp)
  801c0c:	e8 9f ec ff ff       	call   8008b0 <strlen>
  801c11:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801c15:	83 c3 01             	add    $0x1,%ebx
  801c18:	3b 9d 7c fd ff ff    	cmp    -0x284(%ebp),%ebx
  801c1e:	75 c2                	jne    801be2 <spawn+0x1b6>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801c20:	8b 8d 84 fd ff ff    	mov    -0x27c(%ebp),%ecx
  801c26:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801c2c:	c7 04 01 00 00 00 00 	movl   $0x0,(%ecx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801c33:	81 fe 00 10 40 00    	cmp    $0x401000,%esi
  801c39:	74 24                	je     801c5f <spawn+0x233>
  801c3b:	c7 44 24 0c a0 29 80 	movl   $0x8029a0,0xc(%esp)
  801c42:	00 
  801c43:	c7 44 24 08 2e 29 80 	movl   $0x80292e,0x8(%esp)
  801c4a:	00 
  801c4b:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
  801c52:	00 
  801c53:	c7 04 24 43 29 80 00 	movl   $0x802943,(%esp)
  801c5a:	e8 75 e5 ff ff       	call   8001d4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801c5f:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801c65:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801c6a:	8b 95 78 fd ff ff    	mov    -0x288(%ebp),%edx
  801c70:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801c73:	89 7a f8             	mov    %edi,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801c76:	89 d0                	mov    %edx,%eax
  801c78:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801c7d:	89 85 ec fd ff ff    	mov    %eax,-0x214(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801c83:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801c8a:	00 
  801c8b:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801c92:	ee 
  801c93:	8b 8d 9c fd ff ff    	mov    -0x264(%ebp),%ecx
  801c99:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c9d:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ca4:	00 
  801ca5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cac:	e8 f7 f2 ff ff       	call   800fa8 <sys_page_map>
  801cb1:	89 c3                	mov    %eax,%ebx
  801cb3:	85 c0                	test   %eax,%eax
  801cb5:	78 1a                	js     801cd1 <spawn+0x2a5>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801cb7:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801cbe:	00 
  801cbf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cc6:	e8 7f f2 ff ff       	call   800f4a <sys_page_unmap>
  801ccb:	89 c3                	mov    %eax,%ebx
  801ccd:	85 c0                	test   %eax,%eax
  801ccf:	79 1f                	jns    801cf0 <spawn+0x2c4>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801cd1:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801cd8:	00 
  801cd9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ce0:	e8 65 f2 ff ff       	call   800f4a <sys_page_unmap>
  801ce5:	89 9d 9c fd ff ff    	mov    %ebx,-0x264(%ebp)
  801ceb:	e9 cd 02 00 00       	jmp    801fbd <spawn+0x591>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801cf0:	8b 85 10 fe ff ff    	mov    -0x1f0(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801cf6:	66 83 bd 20 fe ff ff 	cmpw   $0x0,-0x1e0(%ebp)
  801cfd:	00 
  801cfe:	0f 84 0b 02 00 00    	je     801f0f <spawn+0x4e3>
  801d04:	8d 84 05 14 fe ff ff 	lea    -0x1ec(%ebp,%eax,1),%eax
  801d0b:	89 85 98 fd ff ff    	mov    %eax,-0x268(%ebp)
  801d11:	c7 85 70 fd ff ff 00 	movl   $0x0,-0x290(%ebp)
  801d18:	00 00 00 
		if (ph->p_type != ELF_PROG_LOAD)
  801d1b:	8b 85 98 fd ff ff    	mov    -0x268(%ebp),%eax
  801d21:	83 78 e0 01          	cmpl   $0x1,-0x20(%eax)
  801d25:	0f 85 c3 01 00 00    	jne    801eee <spawn+0x4c2>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801d2b:	89 c2                	mov    %eax,%edx
  801d2d:	8b 40 f8             	mov    -0x8(%eax),%eax
  801d30:	83 e0 02             	and    $0x2,%eax
  801d33:	83 f8 01             	cmp    $0x1,%eax
  801d36:	19 c9                	sbb    %ecx,%ecx
  801d38:	83 e1 fe             	and    $0xfffffffe,%ecx
  801d3b:	83 c1 07             	add    $0x7,%ecx
  801d3e:	89 8d 74 fd ff ff    	mov    %ecx,-0x28c(%ebp)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz, 
  801d44:	8b 42 e4             	mov    -0x1c(%edx),%eax
  801d47:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801d4d:	8b 52 f0             	mov    -0x10(%edx),%edx
  801d50:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801d56:	8b 8d 98 fd ff ff    	mov    -0x268(%ebp),%ecx
  801d5c:	8b 49 f4             	mov    -0xc(%ecx),%ecx
  801d5f:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  801d65:	8b 85 98 fd ff ff    	mov    -0x268(%ebp),%eax
  801d6b:	8b 40 e8             	mov    -0x18(%eax),%eax
  801d6e:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801d74:	25 ff 0f 00 00       	and    $0xfff,%eax
  801d79:	74 1c                	je     801d97 <spawn+0x36b>
		va -= i;
  801d7b:	29 85 94 fd ff ff    	sub    %eax,-0x26c(%ebp)
		memsz += i;
  801d81:	01 c1                	add    %eax,%ecx
  801d83:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
		filesz += i;
  801d89:	01 c2                	add    %eax,%edx
  801d8b:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		fileoffset -= i;
  801d91:	29 85 88 fd ff ff    	sub    %eax,-0x278(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801d97:	83 bd 90 fd ff ff 00 	cmpl   $0x0,-0x270(%ebp)
  801d9e:	0f 84 4a 01 00 00    	je     801eee <spawn+0x4c2>
  801da4:	bf 00 00 00 00       	mov    $0x0,%edi
  801da9:	be 00 00 00 00       	mov    $0x0,%esi
		if (i >= filesz) {
  801dae:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  801db4:	77 34                	ja     801dea <spawn+0x3be>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801db6:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801dbc:	8d 04 16             	lea    (%esi,%edx,1),%eax
  801dbf:	8b 8d 74 fd ff ff    	mov    -0x28c(%ebp),%ecx
  801dc5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dc9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dcd:	8b 85 9c fd ff ff    	mov    -0x264(%ebp),%eax
  801dd3:	89 04 24             	mov    %eax,(%esp)
  801dd6:	e8 2b f2 ff ff       	call   801006 <sys_page_alloc>
  801ddb:	89 c3                	mov    %eax,%ebx
  801ddd:	85 c0                	test   %eax,%eax
  801ddf:	0f 89 f5 00 00 00    	jns    801eda <spawn+0x4ae>
  801de5:	e9 a9 01 00 00       	jmp    801f93 <spawn+0x567>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801dea:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801df1:	00 
  801df2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801df9:	00 
  801dfa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e01:	e8 00 f2 ff ff       	call   801006 <sys_page_alloc>
  801e06:	89 c3                	mov    %eax,%ebx
  801e08:	85 c0                	test   %eax,%eax
  801e0a:	0f 88 83 01 00 00    	js     801f93 <spawn+0x567>
  801e10:	8b 95 88 fd ff ff    	mov    -0x278(%ebp),%edx
  801e16:	8d 04 17             	lea    (%edi,%edx,1),%eax
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801e19:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e1d:	8b 8d a0 fd ff ff    	mov    -0x260(%ebp),%ecx
  801e23:	89 0c 24             	mov    %ecx,(%esp)
  801e26:	e8 cb f3 ff ff       	call   8011f6 <seek>
  801e2b:	89 c3                	mov    %eax,%ebx
  801e2d:	85 c0                	test   %eax,%eax
  801e2f:	0f 88 5e 01 00 00    	js     801f93 <spawn+0x567>
				return r;
			if ((r = read(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801e35:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801e3b:	29 f0                	sub    %esi,%eax
  801e3d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801e42:	76 05                	jbe    801e49 <spawn+0x41d>
  801e44:	b8 00 10 00 00       	mov    $0x1000,%eax
  801e49:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e4d:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e54:	00 
  801e55:	8b 85 a0 fd ff ff    	mov    -0x260(%ebp),%eax
  801e5b:	89 04 24             	mov    %eax,(%esp)
  801e5e:	e8 b5 f5 ff ff       	call   801418 <read>
  801e63:	89 c3                	mov    %eax,%ebx
  801e65:	85 c0                	test   %eax,%eax
  801e67:	0f 88 26 01 00 00    	js     801f93 <spawn+0x567>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801e6d:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801e73:	8d 04 16             	lea    (%esi,%edx,1),%eax
  801e76:	8b 8d 74 fd ff ff    	mov    -0x28c(%ebp),%ecx
  801e7c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801e80:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e84:	8b 85 9c fd ff ff    	mov    -0x264(%ebp),%eax
  801e8a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e8e:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e95:	00 
  801e96:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e9d:	e8 06 f1 ff ff       	call   800fa8 <sys_page_map>
  801ea2:	85 c0                	test   %eax,%eax
  801ea4:	79 20                	jns    801ec6 <spawn+0x49a>
				panic("spawn: sys_page_map data: %e", r);
  801ea6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eaa:	c7 44 24 08 4f 29 80 	movl   $0x80294f,0x8(%esp)
  801eb1:	00 
  801eb2:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
  801eb9:	00 
  801eba:	c7 04 24 43 29 80 00 	movl   $0x802943,(%esp)
  801ec1:	e8 0e e3 ff ff       	call   8001d4 <_panic>
			sys_page_unmap(0, UTEMP);
  801ec6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ecd:	00 
  801ece:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ed5:	e8 70 f0 ff ff       	call   800f4a <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801eda:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801ee0:	89 fe                	mov    %edi,%esi
  801ee2:	39 bd 90 fd ff ff    	cmp    %edi,-0x270(%ebp)
  801ee8:	0f 87 c0 fe ff ff    	ja     801dae <spawn+0x382>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801eee:	83 85 70 fd ff ff 01 	addl   $0x1,-0x290(%ebp)
  801ef5:	83 85 98 fd ff ff 20 	addl   $0x20,-0x268(%ebp)
  801efc:	0f b7 85 20 fe ff ff 	movzwl -0x1e0(%ebp),%eax
  801f03:	3b 85 70 fd ff ff    	cmp    -0x290(%ebp),%eax
  801f09:	0f 8f 0c fe ff ff    	jg     801d1b <spawn+0x2ef>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz, 
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801f0f:	8b 95 a0 fd ff ff    	mov    -0x260(%ebp),%edx
  801f15:	89 14 24             	mov    %edx,(%esp)
  801f18:	e8 68 f6 ff ff       	call   801585 <close>
	fd = -1;

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801f1d:	8d 85 b0 fd ff ff    	lea    -0x250(%ebp),%eax
  801f23:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f27:	8b 8d 9c fd ff ff    	mov    -0x264(%ebp),%ecx
  801f2d:	89 0c 24             	mov    %ecx,(%esp)
  801f30:	e8 59 ef ff ff       	call   800e8e <sys_env_set_trapframe>
  801f35:	85 c0                	test   %eax,%eax
  801f37:	79 20                	jns    801f59 <spawn+0x52d>
		panic("sys_env_set_trapframe: %e", r);
  801f39:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f3d:	c7 44 24 08 6c 29 80 	movl   $0x80296c,0x8(%esp)
  801f44:	00 
  801f45:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801f4c:	00 
  801f4d:	c7 04 24 43 29 80 00 	movl   $0x802943,(%esp)
  801f54:	e8 7b e2 ff ff       	call   8001d4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801f59:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801f60:	00 
  801f61:	8b 85 9c fd ff ff    	mov    -0x264(%ebp),%eax
  801f67:	89 04 24             	mov    %eax,(%esp)
  801f6a:	e8 7d ef ff ff       	call   800eec <sys_env_set_status>
  801f6f:	85 c0                	test   %eax,%eax
  801f71:	79 4a                	jns    801fbd <spawn+0x591>
		panic("sys_env_set_status: %e", r);
  801f73:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f77:	c7 44 24 08 86 29 80 	movl   $0x802986,0x8(%esp)
  801f7e:	00 
  801f7f:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  801f86:	00 
  801f87:	c7 04 24 43 29 80 00 	movl   $0x802943,(%esp)
  801f8e:	e8 41 e2 ff ff       	call   8001d4 <_panic>

	return child;

error:
	sys_env_destroy(child);
  801f93:	8b 95 9c fd ff ff    	mov    -0x264(%ebp),%edx
  801f99:	89 14 24             	mov    %edx,(%esp)
  801f9c:	e8 2c f1 ff ff       	call   8010cd <sys_env_destroy>
	close(fd);
  801fa1:	8b 8d a0 fd ff ff    	mov    -0x260(%ebp),%ecx
  801fa7:	89 0c 24             	mov    %ecx,(%esp)
  801faa:	e8 d6 f5 ff ff       	call   801585 <close>
  801faf:	89 9d 9c fd ff ff    	mov    %ebx,-0x264(%ebp)
  801fb5:	eb 06                	jmp    801fbd <spawn+0x591>
  801fb7:	89 95 9c fd ff ff    	mov    %edx,-0x264(%ebp)
	return r;
}
  801fbd:	8b 85 9c fd ff ff    	mov    -0x264(%ebp),%eax
  801fc3:	81 c4 9c 02 00 00    	add    $0x29c,%esp
  801fc9:	5b                   	pop    %ebx
  801fca:	5e                   	pop    %esi
  801fcb:	5f                   	pop    %edi
  801fcc:	5d                   	pop    %ebp
  801fcd:	c3                   	ret    

00801fce <spawnl>:

// Spawn, taking command-line arguments array directly on the stack.
int
spawnl(const char *prog, const char *arg0, ...)
{
  801fce:	55                   	push   %ebp
  801fcf:	89 e5                	mov    %esp,%ebp
  801fd1:	83 ec 08             	sub    $0x8,%esp
	return spawn(prog, &arg0);
  801fd4:	8d 45 0c             	lea    0xc(%ebp),%eax
  801fd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fde:	89 04 24             	mov    %eax,(%esp)
  801fe1:	e8 46 fa ff ff       	call   801a2c <spawn>
}
  801fe6:	c9                   	leave  
  801fe7:	c3                   	ret    
	...

00801ff0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	57                   	push   %edi
  801ff4:	56                   	push   %esi
  801ff5:	53                   	push   %ebx
  801ff6:	83 ec 1c             	sub    $0x1c,%esp
  801ff9:	8b 75 08             	mov    0x8(%ebp),%esi
  801ffc:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  801fff:	e8 95 f0 ff ff       	call   801099 <sys_getenvid>
  802004:	25 ff 03 00 00       	and    $0x3ff,%eax
  802009:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80200c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802011:	a3 20 50 80 00       	mov    %eax,0x805020
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  802016:	e8 7e f0 ff ff       	call   801099 <sys_getenvid>
  80201b:	25 ff 03 00 00       	and    $0x3ff,%eax
  802020:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802023:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802028:	a3 20 50 80 00       	mov    %eax,0x805020
		if(env->env_id==to_env){
  80202d:	8b 40 4c             	mov    0x4c(%eax),%eax
  802030:	39 f0                	cmp    %esi,%eax
  802032:	75 0e                	jne    802042 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  802034:	c7 04 24 c8 29 80 00 	movl   $0x8029c8,(%esp)
  80203b:	e8 61 e2 ff ff       	call   8002a1 <cprintf>
  802040:	eb 5a                	jmp    80209c <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  802042:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802046:	8b 45 10             	mov    0x10(%ebp),%eax
  802049:	89 44 24 08          	mov    %eax,0x8(%esp)
  80204d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802050:	89 44 24 04          	mov    %eax,0x4(%esp)
  802054:	89 34 24             	mov    %esi,(%esp)
  802057:	e8 9c ed ff ff       	call   800df8 <sys_ipc_try_send>
  80205c:	89 c3                	mov    %eax,%ebx
  80205e:	85 c0                	test   %eax,%eax
  802060:	79 25                	jns    802087 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  802062:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802065:	74 2b                	je     802092 <ipc_send+0xa2>
				panic("send error:%e",r);
  802067:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80206b:	c7 44 24 08 e4 29 80 	movl   $0x8029e4,0x8(%esp)
  802072:	00 
  802073:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80207a:	00 
  80207b:	c7 04 24 f2 29 80 00 	movl   $0x8029f2,(%esp)
  802082:	e8 4d e1 ff ff       	call   8001d4 <_panic>
		}
			sys_yield();
  802087:	e8 d9 ef ff ff       	call   801065 <sys_yield>
		
	}while(r!=0);
  80208c:	85 db                	test   %ebx,%ebx
  80208e:	75 86                	jne    802016 <ipc_send+0x26>
  802090:	eb 0a                	jmp    80209c <ipc_send+0xac>
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
		{	
			if(r!=-E_IPC_NOT_RECV)
				panic("send error:%e",r);
		}
			sys_yield();
  802092:	e8 ce ef ff ff       	call   801065 <sys_yield>
  802097:	e9 7a ff ff ff       	jmp    802016 <ipc_send+0x26>
		
	}while(r!=0);
	return;
	//panic("ipc_send not implemented");
}
  80209c:	83 c4 1c             	add    $0x1c,%esp
  80209f:	5b                   	pop    %ebx
  8020a0:	5e                   	pop    %esi
  8020a1:	5f                   	pop    %edi
  8020a2:	5d                   	pop    %ebp
  8020a3:	c3                   	ret    

008020a4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020a4:	55                   	push   %ebp
  8020a5:	89 e5                	mov    %esp,%ebp
  8020a7:	57                   	push   %edi
  8020a8:	56                   	push   %esi
  8020a9:	53                   	push   %ebx
  8020aa:	83 ec 0c             	sub    $0xc,%esp
  8020ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8020b0:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	void *dstva=NULL;
	if(pg)
		dstva=pg;
	env = &envs[ENVX(sys_getenvid())];
  8020b3:	e8 e1 ef ff ff       	call   801099 <sys_getenvid>
  8020b8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8020bd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020c0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020c5:	a3 20 50 80 00       	mov    %eax,0x805020
	if(from_env_store&&(env->env_id==*from_env_store))
  8020ca:	85 f6                	test   %esi,%esi
  8020cc:	74 29                	je     8020f7 <ipc_recv+0x53>
  8020ce:	8b 40 4c             	mov    0x4c(%eax),%eax
  8020d1:	3b 06                	cmp    (%esi),%eax
  8020d3:	75 22                	jne    8020f7 <ipc_recv+0x53>
	{
		*from_env_store=0;
  8020d5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  8020db:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("send:the reciver is sender\n");
  8020e1:	c7 04 24 c8 29 80 00 	movl   $0x8029c8,(%esp)
  8020e8:	e8 b4 e1 ff ff       	call   8002a1 <cprintf>
  8020ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020f2:	e9 8a 00 00 00       	jmp    802181 <ipc_recv+0xdd>
		return 0;
	}
	env = &envs[ENVX(sys_getenvid())];
  8020f7:	e8 9d ef ff ff       	call   801099 <sys_getenvid>
  8020fc:	25 ff 03 00 00       	and    $0x3ff,%eax
  802101:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802104:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802109:	a3 20 50 80 00       	mov    %eax,0x805020
	if((r=sys_ipc_recv(dstva))<0)
  80210e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802111:	89 04 24             	mov    %eax,(%esp)
  802114:	e8 82 ec ff ff       	call   800d9b <sys_ipc_recv>
  802119:	89 c3                	mov    %eax,%ebx
  80211b:	85 c0                	test   %eax,%eax
  80211d:	79 1a                	jns    802139 <ipc_recv+0x95>
	{
		*from_env_store=0;
  80211f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  802125:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("reciver failed\n");
  80212b:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  802132:	e8 6a e1 ff ff       	call   8002a1 <cprintf>
  802137:	eb 48                	jmp    802181 <ipc_recv+0xdd>
		return r;
	}
	else{//接收成功
		env = &envs[ENVX(sys_getenvid())];
  802139:	e8 5b ef ff ff       	call   801099 <sys_getenvid>
  80213e:	25 ff 03 00 00       	and    $0x3ff,%eax
  802143:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802146:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80214b:	a3 20 50 80 00       	mov    %eax,0x805020
		if(from_env_store)
  802150:	85 f6                	test   %esi,%esi
  802152:	74 05                	je     802159 <ipc_recv+0xb5>
			*from_env_store=env->env_ipc_from;	
  802154:	8b 40 74             	mov    0x74(%eax),%eax
  802157:	89 06                	mov    %eax,(%esi)
		if(perm_store)
  802159:	85 ff                	test   %edi,%edi
  80215b:	74 0a                	je     802167 <ipc_recv+0xc3>
			*perm_store=env->env_ipc_perm;
  80215d:	a1 20 50 80 00       	mov    0x805020,%eax
  802162:	8b 40 78             	mov    0x78(%eax),%eax
  802165:	89 07                	mov    %eax,(%edi)
		env = &envs[ENVX(sys_getenvid())];
  802167:	e8 2d ef ff ff       	call   801099 <sys_getenvid>
  80216c:	25 ff 03 00 00       	and    $0x3ff,%eax
  802171:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802174:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802179:	a3 20 50 80 00       	mov    %eax,0x805020
		return env->env_ipc_value;
  80217e:	8b 58 70             	mov    0x70(%eax),%ebx
	}
	//panic("ipc_recv not implemented");
	return 0;
}
  802181:	89 d8                	mov    %ebx,%eax
  802183:	83 c4 0c             	add    $0xc,%esp
  802186:	5b                   	pop    %ebx
  802187:	5e                   	pop    %esi
  802188:	5f                   	pop    %edi
  802189:	5d                   	pop    %ebp
  80218a:	c3                   	ret    
  80218b:	00 00                	add    %al,(%eax)
  80218d:	00 00                	add    %al,(%eax)
	...

00802190 <__udivdi3>:
  802190:	55                   	push   %ebp
  802191:	89 e5                	mov    %esp,%ebp
  802193:	57                   	push   %edi
  802194:	56                   	push   %esi
  802195:	83 ec 18             	sub    $0x18,%esp
  802198:	8b 45 10             	mov    0x10(%ebp),%eax
  80219b:	8b 55 14             	mov    0x14(%ebp),%edx
  80219e:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8021a4:	89 c1                	mov    %eax,%ecx
  8021a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a9:	85 d2                	test   %edx,%edx
  8021ab:	89 d7                	mov    %edx,%edi
  8021ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8021b0:	75 1e                	jne    8021d0 <__udivdi3+0x40>
  8021b2:	39 f1                	cmp    %esi,%ecx
  8021b4:	0f 86 8d 00 00 00    	jbe    802247 <__udivdi3+0xb7>
  8021ba:	89 f2                	mov    %esi,%edx
  8021bc:	31 f6                	xor    %esi,%esi
  8021be:	f7 f1                	div    %ecx
  8021c0:	89 c1                	mov    %eax,%ecx
  8021c2:	89 c8                	mov    %ecx,%eax
  8021c4:	89 f2                	mov    %esi,%edx
  8021c6:	83 c4 18             	add    $0x18,%esp
  8021c9:	5e                   	pop    %esi
  8021ca:	5f                   	pop    %edi
  8021cb:	5d                   	pop    %ebp
  8021cc:	c3                   	ret    
  8021cd:	8d 76 00             	lea    0x0(%esi),%esi
  8021d0:	39 f2                	cmp    %esi,%edx
  8021d2:	0f 87 a8 00 00 00    	ja     802280 <__udivdi3+0xf0>
  8021d8:	0f bd c2             	bsr    %edx,%eax
  8021db:	83 f0 1f             	xor    $0x1f,%eax
  8021de:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8021e1:	0f 84 89 00 00 00    	je     802270 <__udivdi3+0xe0>
  8021e7:	b8 20 00 00 00       	mov    $0x20,%eax
  8021ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021ef:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8021f2:	89 c1                	mov    %eax,%ecx
  8021f4:	d3 ea                	shr    %cl,%edx
  8021f6:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  8021fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8021fd:	89 f8                	mov    %edi,%eax
  8021ff:	8b 7d f4             	mov    -0xc(%ebp),%edi
  802202:	d3 e0                	shl    %cl,%eax
  802204:	09 c2                	or     %eax,%edx
  802206:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802209:	d3 e7                	shl    %cl,%edi
  80220b:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80220f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802212:	89 f2                	mov    %esi,%edx
  802214:	d3 e8                	shr    %cl,%eax
  802216:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  80221a:	d3 e2                	shl    %cl,%edx
  80221c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802220:	09 d0                	or     %edx,%eax
  802222:	d3 ee                	shr    %cl,%esi
  802224:	89 f2                	mov    %esi,%edx
  802226:	f7 75 e4             	divl   -0x1c(%ebp)
  802229:	89 d1                	mov    %edx,%ecx
  80222b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80222e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802231:	f7 e7                	mul    %edi
  802233:	39 d1                	cmp    %edx,%ecx
  802235:	89 c6                	mov    %eax,%esi
  802237:	72 70                	jb     8022a9 <__udivdi3+0x119>
  802239:	39 ca                	cmp    %ecx,%edx
  80223b:	74 5f                	je     80229c <__udivdi3+0x10c>
  80223d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802240:	31 f6                	xor    %esi,%esi
  802242:	e9 7b ff ff ff       	jmp    8021c2 <__udivdi3+0x32>
  802247:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80224a:	85 c0                	test   %eax,%eax
  80224c:	75 0c                	jne    80225a <__udivdi3+0xca>
  80224e:	b8 01 00 00 00       	mov    $0x1,%eax
  802253:	31 d2                	xor    %edx,%edx
  802255:	f7 75 f4             	divl   -0xc(%ebp)
  802258:	89 c1                	mov    %eax,%ecx
  80225a:	89 f0                	mov    %esi,%eax
  80225c:	89 fa                	mov    %edi,%edx
  80225e:	f7 f1                	div    %ecx
  802260:	89 c6                	mov    %eax,%esi
  802262:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802265:	f7 f1                	div    %ecx
  802267:	89 c1                	mov    %eax,%ecx
  802269:	e9 54 ff ff ff       	jmp    8021c2 <__udivdi3+0x32>
  80226e:	66 90                	xchg   %ax,%ax
  802270:	39 d6                	cmp    %edx,%esi
  802272:	77 1c                	ja     802290 <__udivdi3+0x100>
  802274:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802277:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  80227a:	73 14                	jae    802290 <__udivdi3+0x100>
  80227c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802280:	31 c9                	xor    %ecx,%ecx
  802282:	31 f6                	xor    %esi,%esi
  802284:	e9 39 ff ff ff       	jmp    8021c2 <__udivdi3+0x32>
  802289:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  802290:	b9 01 00 00 00       	mov    $0x1,%ecx
  802295:	31 f6                	xor    %esi,%esi
  802297:	e9 26 ff ff ff       	jmp    8021c2 <__udivdi3+0x32>
  80229c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80229f:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  8022a3:	d3 e0                	shl    %cl,%eax
  8022a5:	39 c6                	cmp    %eax,%esi
  8022a7:	76 94                	jbe    80223d <__udivdi3+0xad>
  8022a9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8022ac:	31 f6                	xor    %esi,%esi
  8022ae:	83 e9 01             	sub    $0x1,%ecx
  8022b1:	e9 0c ff ff ff       	jmp    8021c2 <__udivdi3+0x32>
	...

008022c0 <__umoddi3>:
  8022c0:	55                   	push   %ebp
  8022c1:	89 e5                	mov    %esp,%ebp
  8022c3:	57                   	push   %edi
  8022c4:	56                   	push   %esi
  8022c5:	83 ec 30             	sub    $0x30,%esp
  8022c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8022cb:	8b 55 14             	mov    0x14(%ebp),%edx
  8022ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8022d1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8022d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8022d7:	89 c1                	mov    %eax,%ecx
  8022d9:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8022dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8022df:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8022e6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8022ed:	89 fa                	mov    %edi,%edx
  8022ef:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8022f2:	85 c0                	test   %eax,%eax
  8022f4:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8022f7:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8022fa:	75 14                	jne    802310 <__umoddi3+0x50>
  8022fc:	39 f9                	cmp    %edi,%ecx
  8022fe:	76 60                	jbe    802360 <__umoddi3+0xa0>
  802300:	89 f0                	mov    %esi,%eax
  802302:	f7 f1                	div    %ecx
  802304:	89 55 d0             	mov    %edx,-0x30(%ebp)
  802307:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80230e:	eb 10                	jmp    802320 <__umoddi3+0x60>
  802310:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802313:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  802316:	76 18                	jbe    802330 <__umoddi3+0x70>
  802318:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80231b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80231e:	66 90                	xchg   %ax,%ax
  802320:	8b 45 d0             	mov    -0x30(%ebp),%eax
  802323:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  802326:	83 c4 30             	add    $0x30,%esp
  802329:	5e                   	pop    %esi
  80232a:	5f                   	pop    %edi
  80232b:	5d                   	pop    %ebp
  80232c:	c3                   	ret    
  80232d:	8d 76 00             	lea    0x0(%esi),%esi
  802330:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
  802334:	83 f0 1f             	xor    $0x1f,%eax
  802337:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80233a:	75 46                	jne    802382 <__umoddi3+0xc2>
  80233c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80233f:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  802342:	0f 87 c9 00 00 00    	ja     802411 <__umoddi3+0x151>
  802348:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  80234b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80234e:	0f 83 bd 00 00 00    	jae    802411 <__umoddi3+0x151>
  802354:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802357:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80235a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80235d:	eb c1                	jmp    802320 <__umoddi3+0x60>
  80235f:	90                   	nop    
  802360:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802363:	85 c0                	test   %eax,%eax
  802365:	75 0c                	jne    802373 <__umoddi3+0xb3>
  802367:	b8 01 00 00 00       	mov    $0x1,%eax
  80236c:	31 d2                	xor    %edx,%edx
  80236e:	f7 75 ec             	divl   -0x14(%ebp)
  802371:	89 c1                	mov    %eax,%ecx
  802373:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802376:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802379:	f7 f1                	div    %ecx
  80237b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80237e:	f7 f1                	div    %ecx
  802380:	eb 82                	jmp    802304 <__umoddi3+0x44>
  802382:	b8 20 00 00 00       	mov    $0x20,%eax
  802387:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80238a:	2b 45 d8             	sub    -0x28(%ebp),%eax
  80238d:	8b 75 ec             	mov    -0x14(%ebp),%esi
  802390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802393:	89 c1                	mov    %eax,%ecx
  802395:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802398:	d3 ea                	shr    %cl,%edx
  80239a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80239d:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8023a1:	d3 e0                	shl    %cl,%eax
  8023a3:	09 c2                	or     %eax,%edx
  8023a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023a8:	d3 e6                	shl    %cl,%esi
  8023aa:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  8023ae:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8023b1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8023b4:	d3 e8                	shr    %cl,%eax
  8023b6:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8023ba:	d3 e2                	shl    %cl,%edx
  8023bc:	09 d0                	or     %edx,%eax
  8023be:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8023c1:	d3 e7                	shl    %cl,%edi
  8023c3:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  8023c7:	d3 ea                	shr    %cl,%edx
  8023c9:	f7 75 f4             	divl   -0xc(%ebp)
  8023cc:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8023cf:	f7 e6                	mul    %esi
  8023d1:	39 55 cc             	cmp    %edx,-0x34(%ebp)
  8023d4:	72 53                	jb     802429 <__umoddi3+0x169>
  8023d6:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  8023d9:	74 4a                	je     802425 <__umoddi3+0x165>
  8023db:	90                   	nop    
  8023dc:	8d 74 26 00          	lea    0x0(%esi),%esi
  8023e0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8023e3:	29 c7                	sub    %eax,%edi
  8023e5:	19 d1                	sbb    %edx,%ecx
  8023e7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8023ea:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8023ee:	89 fa                	mov    %edi,%edx
  8023f0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8023f3:	d3 ea                	shr    %cl,%edx
  8023f5:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  8023f9:	d3 e0                	shl    %cl,%eax
  8023fb:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8023ff:	09 c2                	or     %eax,%edx
  802401:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802404:	89 55 d0             	mov    %edx,-0x30(%ebp)
  802407:	d3 e8                	shr    %cl,%eax
  802409:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80240c:	e9 0f ff ff ff       	jmp    802320 <__umoddi3+0x60>
  802411:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802414:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802417:	2b 45 ec             	sub    -0x14(%ebp),%eax
  80241a:	1b 55 e8             	sbb    -0x18(%ebp),%edx
  80241d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802420:	e9 2f ff ff ff       	jmp    802354 <__umoddi3+0x94>
  802425:	39 f8                	cmp    %edi,%eax
  802427:	76 b7                	jbe    8023e0 <__umoddi3+0x120>
  802429:	29 f0                	sub    %esi,%eax
  80242b:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  80242e:	eb b0                	jmp    8023e0 <__umoddi3+0x120>
