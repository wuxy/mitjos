
obj/user/echotest:     file format elf32-i386

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
  80002c:	e8 bf 01 00 00       	call   8001f0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <die>:

char *msg = "Hello world!\n";

static void
die(char *m) 
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 08             	sub    $0x8,%esp
	cprintf("%s\n", m);
  80003a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80003e:	c7 04 24 20 27 80 00 	movl   $0x802720,(%esp)
  800045:	e8 7f 02 00 00       	call   8002c9 <cprintf>
	exit();
  80004a:	e8 fd 01 00 00       	call   80024c <exit>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    

00800051 <umain>:

int umain(void) 
{
  800051:	55                   	push   %ebp
  800052:	89 e5                	mov    %esp,%ebp
  800054:	57                   	push   %edi
  800055:	56                   	push   %esi
  800056:	53                   	push   %ebx
  800057:	83 ec 4c             	sub    $0x4c,%esp
	struct sockaddr_in echoserver;
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;
	
	cprintf("Connecting to:\n");
  80005a:	c7 04 24 24 27 80 00 	movl   $0x802724,(%esp)
  800061:	e8 63 02 00 00       	call   8002c9 <cprintf>
	cprintf("\tip address %s = %x\n", IPADDR, inet_addr(IPADDR));
  800066:	c7 04 24 34 27 80 00 	movl   $0x802734,(%esp)
  80006d:	e8 cc 23 00 00       	call   80243e <inet_addr>
  800072:	89 44 24 08          	mov    %eax,0x8(%esp)
  800076:	c7 44 24 04 34 27 80 	movl   $0x802734,0x4(%esp)
  80007d:	00 
  80007e:	c7 04 24 3e 27 80 00 	movl   $0x80273e,(%esp)
  800085:	e8 3f 02 00 00       	call   8002c9 <cprintf>
	
	// Create the TCP socket
	if ((sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  80008a:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800099:	00 
  80009a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8000a1:	e8 cf 1a 00 00       	call   801b75 <socket>
  8000a6:	89 45 c0             	mov    %eax,-0x40(%ebp)
  8000a9:	85 c0                	test   %eax,%eax
  8000ab:	79 0a                	jns    8000b7 <umain+0x66>
		die("Failed to create socket");
  8000ad:	b8 53 27 80 00       	mov    $0x802753,%eax
  8000b2:	e8 7d ff ff ff       	call   800034 <die>
	
	cprintf("opened socket\n");
  8000b7:	c7 04 24 6b 27 80 00 	movl   $0x80276b,(%esp)
  8000be:	e8 06 02 00 00       	call   8002c9 <cprintf>
	
	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  8000c3:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  8000ca:	00 
  8000cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000d2:	00 
  8000d3:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  8000d6:	89 1c 24             	mov    %ebx,(%esp)
  8000d9:	e8 00 0a 00 00       	call   800ade <memset>
	echoserver.sin_family = AF_INET;                  // Internet/IP
  8000de:	c6 45 e5 02          	movb   $0x2,-0x1b(%ebp)
	echoserver.sin_addr.s_addr = inet_addr(IPADDR);   // IP address
  8000e2:	c7 04 24 34 27 80 00 	movl   $0x802734,(%esp)
  8000e9:	e8 50 23 00 00       	call   80243e <inet_addr>
  8000ee:	89 45 e8             	mov    %eax,-0x18(%ebp)
	echoserver.sin_port = htons(PORT);		  // server port
  8000f1:	c7 04 24 10 27 00 00 	movl   $0x2710,(%esp)
  8000f8:	e8 02 21 00 00       	call   8021ff <htons>
  8000fd:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
	
	cprintf("trying to connect to server\n");
  800101:	c7 04 24 7a 27 80 00 	movl   $0x80277a,(%esp)
  800108:	e8 bc 01 00 00       	call   8002c9 <cprintf>
	
	// Establish connection
	if (connect(sock, (struct sockaddr *) &echoserver, sizeof(echoserver)) < 0)
  80010d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  800114:	00 
  800115:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800119:	8b 45 c0             	mov    -0x40(%ebp),%eax
  80011c:	89 04 24             	mov    %eax,(%esp)
  80011f:	e8 d4 1a 00 00       	call   801bf8 <connect>
  800124:	85 c0                	test   %eax,%eax
  800126:	79 0a                	jns    800132 <umain+0xe1>
		die("Failed to connect with server");
  800128:	b8 97 27 80 00       	mov    $0x802797,%eax
  80012d:	e8 02 ff ff ff       	call   800034 <die>
	
	cprintf("connected to server\n");
  800132:	c7 04 24 b5 27 80 00 	movl   $0x8027b5,(%esp)
  800139:	e8 8b 01 00 00       	call   8002c9 <cprintf>
	
	// Send the word to the server
	echolen = strlen(msg);
  80013e:	a1 00 60 80 00       	mov    0x806000,%eax
  800143:	89 04 24             	mov    %eax,(%esp)
  800146:	e8 95 07 00 00       	call   8008e0 <strlen>
  80014b:	89 c7                	mov    %eax,%edi
  80014d:	89 c3                	mov    %eax,%ebx
	if (write(sock, msg, echolen) != echolen)
  80014f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800153:	a1 00 60 80 00       	mov    0x806000,%eax
  800158:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015c:	8b 45 c0             	mov    -0x40(%ebp),%eax
  80015f:	89 04 24             	mov    %eax,(%esp)
  800162:	e8 86 12 00 00       	call   8013ed <write>
  800167:	39 f8                	cmp    %edi,%eax
  800169:	74 0a                	je     800175 <umain+0x124>
		die("Mismatch in number of sent bytes");
  80016b:	b8 e4 27 80 00       	mov    $0x8027e4,%eax
  800170:	e8 bf fe ff ff       	call   800034 <die>
	
	// Receive the word back from the server
	cprintf("Received: \n");
  800175:	c7 04 24 ca 27 80 00 	movl   $0x8027ca,(%esp)
  80017c:	e8 48 01 00 00       	call   8002c9 <cprintf>
	while (received < echolen) {
  800181:	85 db                	test   %ebx,%ebx
  800183:	74 45                	je     8001ca <umain+0x179>
  800185:	be 00 00 00 00       	mov    $0x0,%esi
		int bytes = 0;
		if ((bytes = read(sock, buffer, BUFFSIZE-1)) < 1) {
  80018a:	c7 44 24 08 1f 00 00 	movl   $0x1f,0x8(%esp)
  800191:	00 
  800192:	8d 45 c4             	lea    -0x3c(%ebp),%eax
  800195:	89 44 24 04          	mov    %eax,0x4(%esp)
  800199:	8b 45 c0             	mov    -0x40(%ebp),%eax
  80019c:	89 04 24             	mov    %eax,(%esp)
  80019f:	e8 d4 12 00 00       	call   801478 <read>
  8001a4:	89 c3                	mov    %eax,%ebx
  8001a6:	85 c0                	test   %eax,%eax
  8001a8:	7f 0a                	jg     8001b4 <umain+0x163>
			die("Failed to receive bytes from server");
  8001aa:	b8 08 28 80 00       	mov    $0x802808,%eax
  8001af:	e8 80 fe ff ff       	call   800034 <die>
		}
		received += bytes;
  8001b4:	01 de                	add    %ebx,%esi
		buffer[bytes] = '\0';        // Assure null terminated string
  8001b6:	c6 44 1d c4 00       	movb   $0x0,-0x3c(%ebp,%ebx,1)
		cprintf(buffer);
  8001bb:	8d 45 c4             	lea    -0x3c(%ebp),%eax
  8001be:	89 04 24             	mov    %eax,(%esp)
  8001c1:	e8 03 01 00 00       	call   8002c9 <cprintf>
	if (write(sock, msg, echolen) != echolen)
		die("Mismatch in number of sent bytes");
	
	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
  8001c6:	39 f7                	cmp    %esi,%edi
  8001c8:	77 c0                	ja     80018a <umain+0x139>
		}
		received += bytes;
		buffer[bytes] = '\0';        // Assure null terminated string
		cprintf(buffer);
	}
	cprintf("\n");
  8001ca:	c7 04 24 d4 27 80 00 	movl   $0x8027d4,(%esp)
  8001d1:	e8 f3 00 00 00       	call   8002c9 <cprintf>
	
	close(sock);
  8001d6:	8b 45 c0             	mov    -0x40(%ebp),%eax
  8001d9:	89 04 24             	mov    %eax,(%esp)
  8001dc:	e8 04 14 00 00       	call   8015e5 <close>
	return 0;
}
  8001e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8001e6:	83 c4 4c             	add    $0x4c,%esp
  8001e9:	5b                   	pop    %ebx
  8001ea:	5e                   	pop    %esi
  8001eb:	5f                   	pop    %edi
  8001ec:	5d                   	pop    %ebp
  8001ed:	c3                   	ret    
	...

008001f0 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	83 ec 18             	sub    $0x18,%esp
  8001f6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8001f9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8001fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8001ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  800202:	c7 05 50 60 80 00 00 	movl   $0x0,0x806050
  800209:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  80020c:	e8 ec 0e 00 00       	call   8010fd <sys_getenvid>
  800211:	25 ff 03 00 00       	and    $0x3ff,%eax
  800216:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800219:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80021e:	a3 50 60 80 00       	mov    %eax,0x806050
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800223:	85 f6                	test   %esi,%esi
  800225:	7e 07                	jle    80022e <libmain+0x3e>
		binaryname = argv[0];
  800227:	8b 03                	mov    (%ebx),%eax
  800229:	a3 04 60 80 00       	mov    %eax,0x806004

	// call user main routine
	umain(argc, argv);
  80022e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800232:	89 34 24             	mov    %esi,(%esp)
  800235:	e8 17 fe ff ff       	call   800051 <umain>

	// exit gracefully
	exit();
  80023a:	e8 0d 00 00 00       	call   80024c <exit>
}
  80023f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800242:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800245:	89 ec                	mov    %ebp,%esp
  800247:	5d                   	pop    %ebp
  800248:	c3                   	ret    
  800249:	00 00                	add    %al,(%eax)
	...

0080024c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800252:	e8 29 15 00 00       	call   801780 <close_all>
	sys_env_destroy(0);
  800257:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80025e:	e8 ce 0e 00 00       	call   801131 <sys_env_destroy>
}
  800263:	c9                   	leave  
  800264:	c3                   	ret    
  800265:	00 00                	add    %al,(%eax)
	...

00800268 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800271:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  800278:	00 00 00 
	b.cnt = 0;
  80027b:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  800282:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800285:	8b 45 0c             	mov    0xc(%ebp),%eax
  800288:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80028c:	8b 45 08             	mov    0x8(%ebp),%eax
  80028f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800293:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800299:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029d:	c7 04 24 e6 02 80 00 	movl   $0x8002e6,(%esp)
  8002a4:	e8 cc 01 00 00       	call   800475 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002a9:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
  8002af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b3:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  8002b9:	89 04 24             	mov    %eax,(%esp)
  8002bc:	e8 d7 0a 00 00       	call   800d98 <sys_cputs>
  8002c1:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  8002c7:	c9                   	leave  
  8002c8:	c3                   	ret    

008002c9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002cf:	8d 45 0c             	lea    0xc(%ebp),%eax
  8002d2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  8002d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002dc:	89 04 24             	mov    %eax,(%esp)
  8002df:	e8 84 ff ff ff       	call   800268 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002e4:	c9                   	leave  
  8002e5:	c3                   	ret    

008002e6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	53                   	push   %ebx
  8002ea:	83 ec 14             	sub    $0x14,%esp
  8002ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002f0:	8b 03                	mov    (%ebx),%eax
  8002f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f5:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002f9:	83 c0 01             	add    $0x1,%eax
  8002fc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002fe:	3d ff 00 00 00       	cmp    $0xff,%eax
  800303:	75 19                	jne    80031e <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800305:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80030c:	00 
  80030d:	8d 43 08             	lea    0x8(%ebx),%eax
  800310:	89 04 24             	mov    %eax,(%esp)
  800313:	e8 80 0a 00 00       	call   800d98 <sys_cputs>
		b->idx = 0;
  800318:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80031e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800322:	83 c4 14             	add    $0x14,%esp
  800325:	5b                   	pop    %ebx
  800326:	5d                   	pop    %ebp
  800327:	c3                   	ret    
	...

00800330 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	57                   	push   %edi
  800334:	56                   	push   %esi
  800335:	53                   	push   %ebx
  800336:	83 ec 3c             	sub    $0x3c,%esp
  800339:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80033c:	89 d7                	mov    %edx,%edi
  80033e:	8b 45 08             	mov    0x8(%ebp),%eax
  800341:	8b 55 0c             	mov    0xc(%ebp),%edx
  800344:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800347:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80034a:	8b 55 10             	mov    0x10(%ebp),%edx
  80034d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800350:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800353:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  80035a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80035d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  800360:	72 14                	jb     800376 <printnum+0x46>
  800362:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800365:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800368:	76 0c                	jbe    800376 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80036a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80036d:	83 eb 01             	sub    $0x1,%ebx
  800370:	85 db                	test   %ebx,%ebx
  800372:	7f 57                	jg     8003cb <printnum+0x9b>
  800374:	eb 64                	jmp    8003da <printnum+0xaa>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800376:	89 74 24 10          	mov    %esi,0x10(%esp)
  80037a:	8b 45 14             	mov    0x14(%ebp),%eax
  80037d:	83 e8 01             	sub    $0x1,%eax
  800380:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800384:	89 54 24 08          	mov    %edx,0x8(%esp)
  800388:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80038c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800390:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800393:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800396:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80039e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003a1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8003a4:	89 04 24             	mov    %eax,(%esp)
  8003a7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003ab:	e8 d0 20 00 00       	call   802480 <__udivdi3>
  8003b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003b4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003b8:	89 04 24             	mov    %eax,(%esp)
  8003bb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003bf:	89 fa                	mov    %edi,%edx
  8003c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003c4:	e8 67 ff ff ff       	call   800330 <printnum>
  8003c9:	eb 0f                	jmp    8003da <printnum+0xaa>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003cb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003cf:	89 34 24             	mov    %esi,(%esp)
  8003d2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003d5:	83 eb 01             	sub    $0x1,%ebx
  8003d8:	75 f1                	jne    8003cb <printnum+0x9b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003de:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8003e5:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8003e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ec:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003f3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8003f6:	89 04 24             	mov    %eax,(%esp)
  8003f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003fd:	e8 ae 21 00 00       	call   8025b0 <__umoddi3>
  800402:	89 74 24 04          	mov    %esi,0x4(%esp)
  800406:	0f be 80 43 28 80 00 	movsbl 0x802843(%eax),%eax
  80040d:	89 04 24             	mov    %eax,(%esp)
  800410:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800413:	83 c4 3c             	add    $0x3c,%esp
  800416:	5b                   	pop    %ebx
  800417:	5e                   	pop    %esi
  800418:	5f                   	pop    %edi
  800419:	5d                   	pop    %ebp
  80041a:	c3                   	ret    

0080041b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80041b:	55                   	push   %ebp
  80041c:	89 e5                	mov    %esp,%ebp
  80041e:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800420:	83 fa 01             	cmp    $0x1,%edx
  800423:	7e 0e                	jle    800433 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  800425:	8b 10                	mov    (%eax),%edx
  800427:	8d 42 08             	lea    0x8(%edx),%eax
  80042a:	89 01                	mov    %eax,(%ecx)
  80042c:	8b 02                	mov    (%edx),%eax
  80042e:	8b 52 04             	mov    0x4(%edx),%edx
  800431:	eb 22                	jmp    800455 <getuint+0x3a>
	else if (lflag)
  800433:	85 d2                	test   %edx,%edx
  800435:	74 10                	je     800447 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800437:	8b 10                	mov    (%eax),%edx
  800439:	8d 42 04             	lea    0x4(%edx),%eax
  80043c:	89 01                	mov    %eax,(%ecx)
  80043e:	8b 02                	mov    (%edx),%eax
  800440:	ba 00 00 00 00       	mov    $0x0,%edx
  800445:	eb 0e                	jmp    800455 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800447:	8b 10                	mov    (%eax),%edx
  800449:	8d 42 04             	lea    0x4(%edx),%eax
  80044c:	89 01                	mov    %eax,(%ecx)
  80044e:	8b 02                	mov    (%edx),%eax
  800450:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800455:	5d                   	pop    %ebp
  800456:	c3                   	ret    

00800457 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800457:	55                   	push   %ebp
  800458:	89 e5                	mov    %esp,%ebp
  80045a:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  80045d:	83 42 08 01          	addl   $0x1,0x8(%edx)
	if (b->buf < b->ebuf)
  800461:	8b 02                	mov    (%edx),%eax
  800463:	3b 42 04             	cmp    0x4(%edx),%eax
  800466:	73 0b                	jae    800473 <sprintputch+0x1c>
		*b->buf++ = ch;
  800468:	0f b6 4d 08          	movzbl 0x8(%ebp),%ecx
  80046c:	88 08                	mov    %cl,(%eax)
  80046e:	83 c0 01             	add    $0x1,%eax
  800471:	89 02                	mov    %eax,(%edx)
}
  800473:	5d                   	pop    %ebp
  800474:	c3                   	ret    

00800475 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800475:	55                   	push   %ebp
  800476:	89 e5                	mov    %esp,%ebp
  800478:	57                   	push   %edi
  800479:	56                   	push   %esi
  80047a:	53                   	push   %ebx
  80047b:	83 ec 3c             	sub    $0x3c,%esp
  80047e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800481:	eb 18                	jmp    80049b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800483:	84 c0                	test   %al,%al
  800485:	0f 84 9f 03 00 00    	je     80082a <vprintfmt+0x3b5>
				return;
			putch(ch, putdat);
  80048b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80048e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800492:	0f b6 c0             	movzbl %al,%eax
  800495:	89 04 24             	mov    %eax,(%esp)
  800498:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80049b:	0f b6 03             	movzbl (%ebx),%eax
  80049e:	83 c3 01             	add    $0x1,%ebx
  8004a1:	3c 25                	cmp    $0x25,%al
  8004a3:	75 de                	jne    800483 <vprintfmt+0xe>
  8004a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004aa:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
  8004b1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8004b6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004bd:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
  8004c1:	eb 07                	jmp    8004ca <vprintfmt+0x55>
  8004c3:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ca:	0f b6 13             	movzbl (%ebx),%edx
  8004cd:	83 c3 01             	add    $0x1,%ebx
  8004d0:	8d 42 dd             	lea    -0x23(%edx),%eax
  8004d3:	3c 55                	cmp    $0x55,%al
  8004d5:	0f 87 22 03 00 00    	ja     8007fd <vprintfmt+0x388>
  8004db:	0f b6 c0             	movzbl %al,%eax
  8004de:	ff 24 85 80 29 80 00 	jmp    *0x802980(,%eax,4)
  8004e5:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
  8004e9:	eb df                	jmp    8004ca <vprintfmt+0x55>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004eb:	0f b6 c2             	movzbl %dl,%eax
  8004ee:	8d 78 d0             	lea    -0x30(%eax),%edi
				ch = *fmt;
  8004f1:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  8004f4:	8d 42 d0             	lea    -0x30(%edx),%eax
  8004f7:	83 f8 09             	cmp    $0x9,%eax
  8004fa:	76 08                	jbe    800504 <vprintfmt+0x8f>
  8004fc:	eb 39                	jmp    800537 <vprintfmt+0xc2>
  8004fe:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
  800502:	eb c6                	jmp    8004ca <vprintfmt+0x55>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800504:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800507:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  80050a:	8d 7c 42 d0          	lea    -0x30(%edx,%eax,2),%edi
				ch = *fmt;
  80050e:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800511:	8d 42 d0             	lea    -0x30(%edx),%eax
  800514:	83 f8 09             	cmp    $0x9,%eax
  800517:	77 1e                	ja     800537 <vprintfmt+0xc2>
  800519:	eb e9                	jmp    800504 <vprintfmt+0x8f>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80051b:	8b 55 14             	mov    0x14(%ebp),%edx
  80051e:	8d 42 04             	lea    0x4(%edx),%eax
  800521:	89 45 14             	mov    %eax,0x14(%ebp)
  800524:	8b 3a                	mov    (%edx),%edi
  800526:	eb 0f                	jmp    800537 <vprintfmt+0xc2>
			goto process_precision;

		case '.':
			if (width < 0)
  800528:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80052c:	79 9c                	jns    8004ca <vprintfmt+0x55>
  80052e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800535:	eb 93                	jmp    8004ca <vprintfmt+0x55>
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800537:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80053b:	90                   	nop    
  80053c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800540:	79 88                	jns    8004ca <vprintfmt+0x55>
  800542:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800545:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80054a:	e9 7b ff ff ff       	jmp    8004ca <vprintfmt+0x55>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80054f:	83 c1 01             	add    $0x1,%ecx
  800552:	e9 73 ff ff ff       	jmp    8004ca <vprintfmt+0x55>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	8d 50 04             	lea    0x4(%eax),%edx
  80055d:	89 55 14             	mov    %edx,0x14(%ebp)
  800560:	8b 55 0c             	mov    0xc(%ebp),%edx
  800563:	89 54 24 04          	mov    %edx,0x4(%esp)
  800567:	8b 00                	mov    (%eax),%eax
  800569:	89 04 24             	mov    %eax,(%esp)
  80056c:	ff 55 08             	call   *0x8(%ebp)
  80056f:	e9 27 ff ff ff       	jmp    80049b <vprintfmt+0x26>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800574:	8b 55 14             	mov    0x14(%ebp),%edx
  800577:	8d 42 04             	lea    0x4(%edx),%eax
  80057a:	89 45 14             	mov    %eax,0x14(%ebp)
  80057d:	8b 02                	mov    (%edx),%eax
  80057f:	89 c2                	mov    %eax,%edx
  800581:	c1 fa 1f             	sar    $0x1f,%edx
  800584:	31 d0                	xor    %edx,%eax
  800586:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800588:	83 f8 0f             	cmp    $0xf,%eax
  80058b:	7f 0b                	jg     800598 <vprintfmt+0x123>
  80058d:	8b 14 85 e0 2a 80 00 	mov    0x802ae0(,%eax,4),%edx
  800594:	85 d2                	test   %edx,%edx
  800596:	75 23                	jne    8005bb <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800598:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80059c:	c7 44 24 08 54 28 80 	movl   $0x802854,0x8(%esp)
  8005a3:	00 
  8005a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8005ae:	89 14 24             	mov    %edx,(%esp)
  8005b1:	e8 ff 02 00 00       	call   8008b5 <printfmt>
  8005b6:	e9 e0 fe ff ff       	jmp    80049b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005bb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005bf:	c7 44 24 08 22 2c 80 	movl   $0x802c22,0x8(%esp)
  8005c6:	00 
  8005c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8005d1:	89 14 24             	mov    %edx,(%esp)
  8005d4:	e8 dc 02 00 00       	call   8008b5 <printfmt>
  8005d9:	e9 bd fe ff ff       	jmp    80049b <vprintfmt+0x26>
  8005de:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8005e1:	89 f9                	mov    %edi,%ecx
  8005e3:	89 5d ec             	mov    %ebx,-0x14(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005e6:	8b 55 14             	mov    0x14(%ebp),%edx
  8005e9:	8d 42 04             	lea    0x4(%edx),%eax
  8005ec:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ef:	8b 12                	mov    (%edx),%edx
  8005f1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f4:	85 d2                	test   %edx,%edx
  8005f6:	75 07                	jne    8005ff <vprintfmt+0x18a>
  8005f8:	c7 45 dc 5d 28 80 00 	movl   $0x80285d,-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8005ff:	85 f6                	test   %esi,%esi
  800601:	7e 41                	jle    800644 <vprintfmt+0x1cf>
  800603:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  800607:	74 3b                	je     800644 <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
  800609:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80060d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800610:	89 04 24             	mov    %eax,(%esp)
  800613:	e8 e8 02 00 00       	call   800900 <strnlen>
  800618:	29 c6                	sub    %eax,%esi
  80061a:	89 75 f0             	mov    %esi,-0x10(%ebp)
  80061d:	85 f6                	test   %esi,%esi
  80061f:	7e 23                	jle    800644 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800621:	0f be 55 eb          	movsbl -0x15(%ebp),%edx
  800625:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800628:	8b 45 0c             	mov    0xc(%ebp),%eax
  80062b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800632:	89 14 24             	mov    %edx,(%esp)
  800635:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800638:	83 ee 01             	sub    $0x1,%esi
  80063b:	75 eb                	jne    800628 <vprintfmt+0x1b3>
  80063d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800644:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800647:	0f b6 02             	movzbl (%edx),%eax
  80064a:	0f be d0             	movsbl %al,%edx
  80064d:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800650:	84 c0                	test   %al,%al
  800652:	75 42                	jne    800696 <vprintfmt+0x221>
  800654:	eb 49                	jmp    80069f <vprintfmt+0x22a>
				if (altflag && (ch < ' ' || ch > '~'))
  800656:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80065a:	74 1b                	je     800677 <vprintfmt+0x202>
  80065c:	8d 42 e0             	lea    -0x20(%edx),%eax
  80065f:	83 f8 5e             	cmp    $0x5e,%eax
  800662:	76 13                	jbe    800677 <vprintfmt+0x202>
					putch('?', putdat);
  800664:	8b 45 0c             	mov    0xc(%ebp),%eax
  800667:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800672:	ff 55 08             	call   *0x8(%ebp)
  800675:	eb 0d                	jmp    800684 <vprintfmt+0x20f>
				else
					putch(ch, putdat);
  800677:	8b 45 0c             	mov    0xc(%ebp),%eax
  80067a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80067e:	89 14 24             	mov    %edx,(%esp)
  800681:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800684:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  800688:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80068c:	83 c6 01             	add    $0x1,%esi
  80068f:	84 c0                	test   %al,%al
  800691:	74 0c                	je     80069f <vprintfmt+0x22a>
  800693:	0f be d0             	movsbl %al,%edx
  800696:	85 ff                	test   %edi,%edi
  800698:	78 bc                	js     800656 <vprintfmt+0x1e1>
  80069a:	83 ef 01             	sub    $0x1,%edi
  80069d:	79 b7                	jns    800656 <vprintfmt+0x1e1>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80069f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8006a3:	0f 8e f2 fd ff ff    	jle    80049b <vprintfmt+0x26>
				putch(' ', putdat);
  8006a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006b0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006b7:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ba:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  8006be:	75 e9                	jne    8006a9 <vprintfmt+0x234>
  8006c0:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  8006c3:	e9 d3 fd ff ff       	jmp    80049b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006c8:	83 f9 01             	cmp    $0x1,%ecx
  8006cb:	90                   	nop    
  8006cc:	8d 74 26 00          	lea    0x0(%esi),%esi
  8006d0:	7e 10                	jle    8006e2 <vprintfmt+0x26d>
		return va_arg(*ap, long long);
  8006d2:	8b 55 14             	mov    0x14(%ebp),%edx
  8006d5:	8d 42 08             	lea    0x8(%edx),%eax
  8006d8:	89 45 14             	mov    %eax,0x14(%ebp)
  8006db:	8b 32                	mov    (%edx),%esi
  8006dd:	8b 7a 04             	mov    0x4(%edx),%edi
  8006e0:	eb 2a                	jmp    80070c <vprintfmt+0x297>
	else if (lflag)
  8006e2:	85 c9                	test   %ecx,%ecx
  8006e4:	74 14                	je     8006fa <vprintfmt+0x285>
		return va_arg(*ap, long);
  8006e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ef:	8b 00                	mov    (%eax),%eax
  8006f1:	89 c6                	mov    %eax,%esi
  8006f3:	89 c7                	mov    %eax,%edi
  8006f5:	c1 ff 1f             	sar    $0x1f,%edi
  8006f8:	eb 12                	jmp    80070c <vprintfmt+0x297>
	else
		return va_arg(*ap, int);
  8006fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fd:	8d 50 04             	lea    0x4(%eax),%edx
  800700:	89 55 14             	mov    %edx,0x14(%ebp)
  800703:	8b 00                	mov    (%eax),%eax
  800705:	89 c6                	mov    %eax,%esi
  800707:	89 c7                	mov    %eax,%edi
  800709:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80070c:	89 f2                	mov    %esi,%edx
  80070e:	89 f9                	mov    %edi,%ecx
  800710:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
			if ((long long) num < 0) {
  800717:	85 ff                	test   %edi,%edi
  800719:	0f 89 9b 00 00 00    	jns    8007ba <vprintfmt+0x345>
				putch('-', putdat);
  80071f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800722:	89 44 24 04          	mov    %eax,0x4(%esp)
  800726:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80072d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800730:	89 f2                	mov    %esi,%edx
  800732:	89 f9                	mov    %edi,%ecx
  800734:	f7 da                	neg    %edx
  800736:	83 d1 00             	adc    $0x0,%ecx
  800739:	f7 d9                	neg    %ecx
  80073b:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  800742:	eb 76                	jmp    8007ba <vprintfmt+0x345>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800744:	89 ca                	mov    %ecx,%edx
  800746:	8d 45 14             	lea    0x14(%ebp),%eax
  800749:	e8 cd fc ff ff       	call   80041b <getuint>
  80074e:	89 d1                	mov    %edx,%ecx
  800750:	89 c2                	mov    %eax,%edx
  800752:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  800759:	eb 5f                	jmp    8007ba <vprintfmt+0x345>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap,lflag);
  80075b:	89 ca                	mov    %ecx,%edx
  80075d:	8d 45 14             	lea    0x14(%ebp),%eax
  800760:	e8 b6 fc ff ff       	call   80041b <getuint>
  800765:	e9 31 fd ff ff       	jmp    80049b <vprintfmt+0x26>
			base=8;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80076a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80076d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800771:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800778:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80077b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80077e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800782:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800789:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  80078c:	8b 55 14             	mov    0x14(%ebp),%edx
  80078f:	8d 42 04             	lea    0x4(%edx),%eax
  800792:	89 45 14             	mov    %eax,0x14(%ebp)
  800795:	8b 12                	mov    (%edx),%edx
  800797:	b9 00 00 00 00       	mov    $0x0,%ecx
  80079c:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  8007a3:	eb 15                	jmp    8007ba <vprintfmt+0x345>
			base = 16;
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007a5:	89 ca                	mov    %ecx,%edx
  8007a7:	8d 45 14             	lea    0x14(%ebp),%eax
  8007aa:	e8 6c fc ff ff       	call   80041b <getuint>
  8007af:	89 d1                	mov    %edx,%ecx
  8007b1:	89 c2                	mov    %eax,%edx
  8007b3:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007ba:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  8007be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d0:	89 14 24             	mov    %edx,(%esp)
  8007d3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007da:	8b 45 08             	mov    0x8(%ebp),%eax
  8007dd:	e8 4e fb ff ff       	call   800330 <printnum>
  8007e2:	e9 b4 fc ff ff       	jmp    80049b <vprintfmt+0x26>
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ea:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007ee:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007f5:	ff 55 08             	call   *0x8(%ebp)
  8007f8:	e9 9e fc ff ff       	jmp    80049b <vprintfmt+0x26>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800800:	89 44 24 04          	mov    %eax,0x4(%esp)
  800804:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80080b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80080e:	83 eb 01             	sub    $0x1,%ebx
  800811:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800815:	0f 84 80 fc ff ff    	je     80049b <vprintfmt+0x26>
  80081b:	83 eb 01             	sub    $0x1,%ebx
  80081e:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800822:	0f 84 73 fc ff ff    	je     80049b <vprintfmt+0x26>
  800828:	eb f1                	jmp    80081b <vprintfmt+0x3a6>
				/* do nothing */;
			break;
		}
	}
}
  80082a:	83 c4 3c             	add    $0x3c,%esp
  80082d:	5b                   	pop    %ebx
  80082e:	5e                   	pop    %esi
  80082f:	5f                   	pop    %edi
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	83 ec 28             	sub    $0x28,%esp
  800838:	8b 55 08             	mov    0x8(%ebp),%edx
  80083b:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80083e:	85 d2                	test   %edx,%edx
  800840:	74 04                	je     800846 <vsnprintf+0x14>
  800842:	85 c0                	test   %eax,%eax
  800844:	7f 07                	jg     80084d <vsnprintf+0x1b>
  800846:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80084b:	eb 3b                	jmp    800888 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80084d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800854:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
  800858:	89 45 f8             	mov    %eax,-0x8(%ebp)
  80085b:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80085e:	8b 45 14             	mov    0x14(%ebp),%eax
  800861:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800865:	8b 45 10             	mov    0x10(%ebp),%eax
  800868:	89 44 24 08          	mov    %eax,0x8(%esp)
  80086c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80086f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800873:	c7 04 24 57 04 80 00 	movl   $0x800457,(%esp)
  80087a:	e8 f6 fb ff ff       	call   800475 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80087f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800882:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800885:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800888:	c9                   	leave  
  800889:	c3                   	ret    

0080088a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800890:	8d 45 14             	lea    0x14(%ebp),%eax
  800893:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800896:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80089a:	8b 45 10             	mov    0x10(%ebp),%eax
  80089d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ab:	89 04 24             	mov    %eax,(%esp)
  8008ae:	e8 7f ff ff ff       	call   800832 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008b3:	c9                   	leave  
  8008b4:	c3                   	ret    

008008b5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8008bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8008be:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8008c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8008c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d6:	89 04 24             	mov    %eax,(%esp)
  8008d9:	e8 97 fb ff ff       	call   800475 <vprintfmt>
	va_end(ap);
}
  8008de:	c9                   	leave  
  8008df:	c3                   	ret    

008008e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008eb:	80 3a 00             	cmpb   $0x0,(%edx)
  8008ee:	74 0e                	je     8008fe <strlen+0x1e>
  8008f0:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008f5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f8:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  8008fc:	75 f7                	jne    8008f5 <strlen+0x15>
		n++;
	return n;
}
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800906:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800909:	85 d2                	test   %edx,%edx
  80090b:	74 19                	je     800926 <strnlen+0x26>
  80090d:	80 39 00             	cmpb   $0x0,(%ecx)
  800910:	74 14                	je     800926 <strnlen+0x26>
  800912:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800917:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80091a:	39 d0                	cmp    %edx,%eax
  80091c:	74 0d                	je     80092b <strnlen+0x2b>
  80091e:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800922:	74 07                	je     80092b <strnlen+0x2b>
  800924:	eb f1                	jmp    800917 <strnlen+0x17>
  800926:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80092b:	5d                   	pop    %ebp
  80092c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800930:	c3                   	ret    

00800931 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	53                   	push   %ebx
  800935:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800938:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093b:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80093d:	0f b6 01             	movzbl (%ecx),%eax
  800940:	88 02                	mov    %al,(%edx)
  800942:	83 c2 01             	add    $0x1,%edx
  800945:	83 c1 01             	add    $0x1,%ecx
  800948:	84 c0                	test   %al,%al
  80094a:	75 f1                	jne    80093d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80094c:	89 d8                	mov    %ebx,%eax
  80094e:	5b                   	pop    %ebx
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	57                   	push   %edi
  800955:	56                   	push   %esi
  800956:	53                   	push   %ebx
  800957:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80095d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800960:	85 f6                	test   %esi,%esi
  800962:	74 1c                	je     800980 <strncpy+0x2f>
  800964:	89 fa                	mov    %edi,%edx
  800966:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  80096b:	0f b6 01             	movzbl (%ecx),%eax
  80096e:	88 02                	mov    %al,(%edx)
  800970:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800973:	80 39 01             	cmpb   $0x1,(%ecx)
  800976:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800979:	83 c3 01             	add    $0x1,%ebx
  80097c:	39 f3                	cmp    %esi,%ebx
  80097e:	75 eb                	jne    80096b <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800980:	89 f8                	mov    %edi,%eax
  800982:	5b                   	pop    %ebx
  800983:	5e                   	pop    %esi
  800984:	5f                   	pop    %edi
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	56                   	push   %esi
  80098b:	53                   	push   %ebx
  80098c:	8b 75 08             	mov    0x8(%ebp),%esi
  80098f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800992:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800995:	89 f0                	mov    %esi,%eax
  800997:	85 d2                	test   %edx,%edx
  800999:	74 2c                	je     8009c7 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  80099b:	89 d3                	mov    %edx,%ebx
  80099d:	83 eb 01             	sub    $0x1,%ebx
  8009a0:	74 20                	je     8009c2 <strlcpy+0x3b>
  8009a2:	0f b6 11             	movzbl (%ecx),%edx
  8009a5:	84 d2                	test   %dl,%dl
  8009a7:	74 19                	je     8009c2 <strlcpy+0x3b>
  8009a9:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  8009ab:	88 10                	mov    %dl,(%eax)
  8009ad:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009b0:	83 eb 01             	sub    $0x1,%ebx
  8009b3:	74 0f                	je     8009c4 <strlcpy+0x3d>
  8009b5:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  8009b9:	83 c1 01             	add    $0x1,%ecx
  8009bc:	84 d2                	test   %dl,%dl
  8009be:	74 04                	je     8009c4 <strlcpy+0x3d>
  8009c0:	eb e9                	jmp    8009ab <strlcpy+0x24>
  8009c2:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009c4:	c6 00 00             	movb   $0x0,(%eax)
  8009c7:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8009c9:	5b                   	pop    %ebx
  8009ca:	5e                   	pop    %esi
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	56                   	push   %esi
  8009d1:	53                   	push   %ebx
  8009d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8009d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d8:	8b 55 10             	mov    0x10(%ebp),%edx
    int c;
    char *q = buf;

    if (buf_size <= 0)
  8009db:	85 c0                	test   %eax,%eax
  8009dd:	7e 2e                	jle    800a0d <pstrcpy+0x40>
        return;

    for(;;) {
        c = *str++;
  8009df:	0f b6 0a             	movzbl (%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  8009e2:	84 c9                	test   %cl,%cl
  8009e4:	74 22                	je     800a08 <pstrcpy+0x3b>
  8009e6:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  8009ea:	89 f0                	mov    %esi,%eax
  8009ec:	39 de                	cmp    %ebx,%esi
  8009ee:	72 09                	jb     8009f9 <pstrcpy+0x2c>
  8009f0:	eb 16                	jmp    800a08 <pstrcpy+0x3b>
  8009f2:	83 c2 01             	add    $0x1,%edx
  8009f5:	39 d8                	cmp    %ebx,%eax
  8009f7:	73 11                	jae    800a0a <pstrcpy+0x3d>
            break;
        *q++ = c;
  8009f9:	88 08                	mov    %cl,(%eax)
  8009fb:	83 c0 01             	add    $0x1,%eax

    if (buf_size <= 0)
        return;

    for(;;) {
        c = *str++;
  8009fe:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  800a02:	84 c9                	test   %cl,%cl
  800a04:	75 ec                	jne    8009f2 <pstrcpy+0x25>
  800a06:	eb 02                	jmp    800a0a <pstrcpy+0x3d>
  800a08:	89 f0                	mov    %esi,%eax
            break;
        *q++ = c;
    }
    *q = '\0';
  800a0a:	c6 00 00             	movb   $0x0,(%eax)
}
  800a0d:	5b                   	pop    %ebx
  800a0e:	5e                   	pop    %esi
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	8b 55 08             	mov    0x8(%ebp),%edx
  800a17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  800a1a:	0f b6 02             	movzbl (%edx),%eax
  800a1d:	84 c0                	test   %al,%al
  800a1f:	74 16                	je     800a37 <strcmp+0x26>
  800a21:	3a 01                	cmp    (%ecx),%al
  800a23:	75 12                	jne    800a37 <strcmp+0x26>
		p++, q++;
  800a25:	83 c1 01             	add    $0x1,%ecx
    *q = '\0';
}
int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a28:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  800a2c:	84 c0                	test   %al,%al
  800a2e:	74 07                	je     800a37 <strcmp+0x26>
  800a30:	83 c2 01             	add    $0x1,%edx
  800a33:	3a 01                	cmp    (%ecx),%al
  800a35:	74 ee                	je     800a25 <strcmp+0x14>
  800a37:	0f b6 c0             	movzbl %al,%eax
  800a3a:	0f b6 11             	movzbl (%ecx),%edx
  800a3d:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	53                   	push   %ebx
  800a45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a48:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a4b:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800a4e:	85 d2                	test   %edx,%edx
  800a50:	74 2d                	je     800a7f <strncmp+0x3e>
  800a52:	0f b6 01             	movzbl (%ecx),%eax
  800a55:	84 c0                	test   %al,%al
  800a57:	74 1a                	je     800a73 <strncmp+0x32>
  800a59:	3a 03                	cmp    (%ebx),%al
  800a5b:	75 16                	jne    800a73 <strncmp+0x32>
  800a5d:	83 ea 01             	sub    $0x1,%edx
  800a60:	74 1d                	je     800a7f <strncmp+0x3e>
		n--, p++, q++;
  800a62:	83 c1 01             	add    $0x1,%ecx
  800a65:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a68:	0f b6 01             	movzbl (%ecx),%eax
  800a6b:	84 c0                	test   %al,%al
  800a6d:	74 04                	je     800a73 <strncmp+0x32>
  800a6f:	3a 03                	cmp    (%ebx),%al
  800a71:	74 ea                	je     800a5d <strncmp+0x1c>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a73:	0f b6 11             	movzbl (%ecx),%edx
  800a76:	0f b6 03             	movzbl (%ebx),%eax
  800a79:	29 c2                	sub    %eax,%edx
  800a7b:	89 d0                	mov    %edx,%eax
  800a7d:	eb 05                	jmp    800a84 <strncmp+0x43>
  800a7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a84:	5b                   	pop    %ebx
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a91:	0f b6 10             	movzbl (%eax),%edx
  800a94:	84 d2                	test   %dl,%dl
  800a96:	74 14                	je     800aac <strchr+0x25>
		if (*s == c)
  800a98:	38 ca                	cmp    %cl,%dl
  800a9a:	75 06                	jne    800aa2 <strchr+0x1b>
  800a9c:	eb 13                	jmp    800ab1 <strchr+0x2a>
  800a9e:	38 ca                	cmp    %cl,%dl
  800aa0:	74 0f                	je     800ab1 <strchr+0x2a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aa2:	83 c0 01             	add    $0x1,%eax
  800aa5:	0f b6 10             	movzbl (%eax),%edx
  800aa8:	84 d2                	test   %dl,%dl
  800aaa:	75 f2                	jne    800a9e <strchr+0x17>
  800aac:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800ab1:	5d                   	pop    %ebp
  800ab2:	c3                   	ret    

00800ab3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800abd:	0f b6 10             	movzbl (%eax),%edx
  800ac0:	84 d2                	test   %dl,%dl
  800ac2:	74 18                	je     800adc <strfind+0x29>
		if (*s == c)
  800ac4:	38 ca                	cmp    %cl,%dl
  800ac6:	75 0a                	jne    800ad2 <strfind+0x1f>
  800ac8:	eb 12                	jmp    800adc <strfind+0x29>
  800aca:	38 ca                	cmp    %cl,%dl
  800acc:	8d 74 26 00          	lea    0x0(%esi),%esi
  800ad0:	74 0a                	je     800adc <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ad2:	83 c0 01             	add    $0x1,%eax
  800ad5:	0f b6 10             	movzbl (%eax),%edx
  800ad8:	84 d2                	test   %dl,%dl
  800ada:	75 ee                	jne    800aca <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	83 ec 08             	sub    $0x8,%esp
  800ae4:	89 1c 24             	mov    %ebx,(%esp)
  800ae7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aeb:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800af1:	85 db                	test   %ebx,%ebx
  800af3:	74 36                	je     800b2b <memset+0x4d>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800af5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800afb:	75 26                	jne    800b23 <memset+0x45>
  800afd:	f6 c3 03             	test   $0x3,%bl
  800b00:	75 21                	jne    800b23 <memset+0x45>
		c &= 0xFF;
  800b02:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b06:	89 d0                	mov    %edx,%eax
  800b08:	c1 e0 18             	shl    $0x18,%eax
  800b0b:	89 d1                	mov    %edx,%ecx
  800b0d:	c1 e1 10             	shl    $0x10,%ecx
  800b10:	09 c8                	or     %ecx,%eax
  800b12:	09 d0                	or     %edx,%eax
  800b14:	c1 e2 08             	shl    $0x8,%edx
  800b17:	09 d0                	or     %edx,%eax
  800b19:	89 d9                	mov    %ebx,%ecx
  800b1b:	c1 e9 02             	shr    $0x2,%ecx
  800b1e:	fc                   	cld    
  800b1f:	f3 ab                	rep stos %eax,%es:(%edi)
  800b21:	eb 08                	jmp    800b2b <memset+0x4d>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b26:	89 d9                	mov    %ebx,%ecx
  800b28:	fc                   	cld    
  800b29:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b2b:	89 f8                	mov    %edi,%eax
  800b2d:	8b 1c 24             	mov    (%esp),%ebx
  800b30:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b34:	89 ec                	mov    %ebp,%esp
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	83 ec 08             	sub    $0x8,%esp
  800b3e:	89 34 24             	mov    %esi,(%esp)
  800b41:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b45:	8b 45 08             	mov    0x8(%ebp),%eax
  800b48:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800b4b:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b4e:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b50:	39 c6                	cmp    %eax,%esi
  800b52:	73 38                	jae    800b8c <memmove+0x54>
  800b54:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b57:	39 d0                	cmp    %edx,%eax
  800b59:	73 31                	jae    800b8c <memmove+0x54>
		s += n;
		d += n;
  800b5b:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b5e:	f6 c2 03             	test   $0x3,%dl
  800b61:	75 1d                	jne    800b80 <memmove+0x48>
  800b63:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b69:	75 15                	jne    800b80 <memmove+0x48>
  800b6b:	f6 c1 03             	test   $0x3,%cl
  800b6e:	66 90                	xchg   %ax,%ax
  800b70:	75 0e                	jne    800b80 <memmove+0x48>
			asm volatile("std; rep movsl\n"
  800b72:	8d 7e fc             	lea    -0x4(%esi),%edi
  800b75:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b78:	c1 e9 02             	shr    $0x2,%ecx
  800b7b:	fd                   	std    
  800b7c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b7e:	eb 09                	jmp    800b89 <memmove+0x51>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b80:	8d 7e ff             	lea    -0x1(%esi),%edi
  800b83:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b86:	fd                   	std    
  800b87:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b89:	fc                   	cld    
  800b8a:	eb 21                	jmp    800bad <memmove+0x75>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b8c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b92:	75 16                	jne    800baa <memmove+0x72>
  800b94:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b9a:	75 0e                	jne    800baa <memmove+0x72>
  800b9c:	f6 c1 03             	test   $0x3,%cl
  800b9f:	90                   	nop    
  800ba0:	75 08                	jne    800baa <memmove+0x72>
			asm volatile("cld; rep movsl\n"
  800ba2:	c1 e9 02             	shr    $0x2,%ecx
  800ba5:	fc                   	cld    
  800ba6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba8:	eb 03                	jmp    800bad <memmove+0x75>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800baa:	fc                   	cld    
  800bab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bad:	8b 34 24             	mov    (%esp),%esi
  800bb0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800bb4:	89 ec                	mov    %ebp,%esp
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bbe:	8b 45 10             	mov    0x10(%ebp),%eax
  800bc1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bc5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bcc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcf:	89 04 24             	mov    %eax,(%esp)
  800bd2:	e8 61 ff ff ff       	call   800b38 <memmove>
}
  800bd7:	c9                   	leave  
  800bd8:	c3                   	ret    

00800bd9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
  800bdf:	83 ec 04             	sub    $0x4,%esp
  800be2:	8b 45 08             	mov    0x8(%ebp),%eax
  800be5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be8:	8b 55 10             	mov    0x10(%ebp),%edx
  800beb:	83 ea 01             	sub    $0x1,%edx
  800bee:	83 fa ff             	cmp    $0xffffffff,%edx
  800bf1:	74 47                	je     800c3a <memcmp+0x61>
		if (*s1 != *s2)
  800bf3:	0f b6 30             	movzbl (%eax),%esi
  800bf6:	0f b6 39             	movzbl (%ecx),%edi
			return (int) *s1 - (int) *s2;
  800bf9:	89 45 f0             	mov    %eax,-0x10(%ebp)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  800bfc:	89 f0                	mov    %esi,%eax
  800bfe:	89 fb                	mov    %edi,%ebx
  800c00:	38 d8                	cmp    %bl,%al
  800c02:	74 2e                	je     800c32 <memcmp+0x59>
  800c04:	eb 1c                	jmp    800c22 <memcmp+0x49>
  800c06:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c09:	0f b6 70 01          	movzbl 0x1(%eax),%esi
  800c0d:	0f b6 79 01          	movzbl 0x1(%ecx),%edi
  800c11:	83 c0 01             	add    $0x1,%eax
  800c14:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c17:	83 c1 01             	add    $0x1,%ecx
  800c1a:	89 f3                	mov    %esi,%ebx
  800c1c:	89 f8                	mov    %edi,%eax
  800c1e:	38 c3                	cmp    %al,%bl
  800c20:	74 10                	je     800c32 <memcmp+0x59>
			return (int) *s1 - (int) *s2;
  800c22:	89 f1                	mov    %esi,%ecx
  800c24:	0f b6 d1             	movzbl %cl,%edx
  800c27:	89 fb                	mov    %edi,%ebx
  800c29:	0f b6 c3             	movzbl %bl,%eax
  800c2c:	29 c2                	sub    %eax,%edx
  800c2e:	89 d0                	mov    %edx,%eax
  800c30:	eb 0d                	jmp    800c3f <memcmp+0x66>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c32:	83 ea 01             	sub    $0x1,%edx
  800c35:	83 fa ff             	cmp    $0xffffffff,%edx
  800c38:	75 cc                	jne    800c06 <memcmp+0x2d>
  800c3a:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800c3f:	83 c4 04             	add    $0x4,%esp
  800c42:	5b                   	pop    %ebx
  800c43:	5e                   	pop    %esi
  800c44:	5f                   	pop    %edi
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c4d:	89 c1                	mov    %eax,%ecx
  800c4f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
  800c52:	39 c8                	cmp    %ecx,%eax
  800c54:	73 15                	jae    800c6b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c56:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
  800c5a:	38 10                	cmp    %dl,(%eax)
  800c5c:	75 06                	jne    800c64 <memfind+0x1d>
  800c5e:	eb 0b                	jmp    800c6b <memfind+0x24>
  800c60:	38 10                	cmp    %dl,(%eax)
  800c62:	74 07                	je     800c6b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c64:	83 c0 01             	add    $0x1,%eax
  800c67:	39 c8                	cmp    %ecx,%eax
  800c69:	75 f5                	jne    800c60 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c6b:	5d                   	pop    %ebp
  800c6c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800c70:	c3                   	ret    

00800c71 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	57                   	push   %edi
  800c75:	56                   	push   %esi
  800c76:	53                   	push   %ebx
  800c77:	83 ec 04             	sub    $0x4,%esp
  800c7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c7d:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c80:	0f b6 01             	movzbl (%ecx),%eax
  800c83:	3c 20                	cmp    $0x20,%al
  800c85:	74 04                	je     800c8b <strtol+0x1a>
  800c87:	3c 09                	cmp    $0x9,%al
  800c89:	75 0e                	jne    800c99 <strtol+0x28>
		s++;
  800c8b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c8e:	0f b6 01             	movzbl (%ecx),%eax
  800c91:	3c 20                	cmp    $0x20,%al
  800c93:	74 f6                	je     800c8b <strtol+0x1a>
  800c95:	3c 09                	cmp    $0x9,%al
  800c97:	74 f2                	je     800c8b <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c99:	3c 2b                	cmp    $0x2b,%al
  800c9b:	75 0c                	jne    800ca9 <strtol+0x38>
		s++;
  800c9d:	83 c1 01             	add    $0x1,%ecx
  800ca0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ca7:	eb 15                	jmp    800cbe <strtol+0x4d>
	else if (*s == '-')
  800ca9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800cb0:	3c 2d                	cmp    $0x2d,%al
  800cb2:	75 0a                	jne    800cbe <strtol+0x4d>
		s++, neg = 1;
  800cb4:	83 c1 01             	add    $0x1,%ecx
  800cb7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cbe:	85 f6                	test   %esi,%esi
  800cc0:	0f 94 c0             	sete   %al
  800cc3:	74 05                	je     800cca <strtol+0x59>
  800cc5:	83 fe 10             	cmp    $0x10,%esi
  800cc8:	75 18                	jne    800ce2 <strtol+0x71>
  800cca:	80 39 30             	cmpb   $0x30,(%ecx)
  800ccd:	75 13                	jne    800ce2 <strtol+0x71>
  800ccf:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cd3:	75 0d                	jne    800ce2 <strtol+0x71>
		s += 2, base = 16;
  800cd5:	83 c1 02             	add    $0x2,%ecx
  800cd8:	be 10 00 00 00       	mov    $0x10,%esi
  800cdd:	8d 76 00             	lea    0x0(%esi),%esi
  800ce0:	eb 1b                	jmp    800cfd <strtol+0x8c>
	else if (base == 0 && s[0] == '0')
  800ce2:	85 f6                	test   %esi,%esi
  800ce4:	75 0e                	jne    800cf4 <strtol+0x83>
  800ce6:	80 39 30             	cmpb   $0x30,(%ecx)
  800ce9:	75 09                	jne    800cf4 <strtol+0x83>
		s++, base = 8;
  800ceb:	83 c1 01             	add    $0x1,%ecx
  800cee:	66 be 08 00          	mov    $0x8,%si
  800cf2:	eb 09                	jmp    800cfd <strtol+0x8c>
	else if (base == 0)
  800cf4:	84 c0                	test   %al,%al
  800cf6:	74 05                	je     800cfd <strtol+0x8c>
  800cf8:	be 0a 00 00 00       	mov    $0xa,%esi
  800cfd:	bf 00 00 00 00       	mov    $0x0,%edi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d02:	0f b6 11             	movzbl (%ecx),%edx
  800d05:	89 d3                	mov    %edx,%ebx
  800d07:	8d 42 d0             	lea    -0x30(%edx),%eax
  800d0a:	3c 09                	cmp    $0x9,%al
  800d0c:	77 08                	ja     800d16 <strtol+0xa5>
			dig = *s - '0';
  800d0e:	0f be c2             	movsbl %dl,%eax
  800d11:	8d 50 d0             	lea    -0x30(%eax),%edx
  800d14:	eb 1c                	jmp    800d32 <strtol+0xc1>
		else if (*s >= 'a' && *s <= 'z')
  800d16:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800d19:	3c 19                	cmp    $0x19,%al
  800d1b:	77 08                	ja     800d25 <strtol+0xb4>
			dig = *s - 'a' + 10;
  800d1d:	0f be c2             	movsbl %dl,%eax
  800d20:	8d 50 a9             	lea    -0x57(%eax),%edx
  800d23:	eb 0d                	jmp    800d32 <strtol+0xc1>
		else if (*s >= 'A' && *s <= 'Z')
  800d25:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800d28:	3c 19                	cmp    $0x19,%al
  800d2a:	77 17                	ja     800d43 <strtol+0xd2>
			dig = *s - 'A' + 10;
  800d2c:	0f be c2             	movsbl %dl,%eax
  800d2f:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800d32:	39 f2                	cmp    %esi,%edx
  800d34:	7d 0d                	jge    800d43 <strtol+0xd2>
			break;
		s++, val = (val * base) + dig;
  800d36:	83 c1 01             	add    $0x1,%ecx
  800d39:	89 f8                	mov    %edi,%eax
  800d3b:	0f af c6             	imul   %esi,%eax
  800d3e:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800d41:	eb bf                	jmp    800d02 <strtol+0x91>
		// we don't properly detect overflow!
	}
  800d43:	89 f8                	mov    %edi,%eax

	if (endptr)
  800d45:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d49:	74 05                	je     800d50 <strtol+0xdf>
		*endptr = (char *) s;
  800d4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d4e:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800d50:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800d54:	74 04                	je     800d5a <strtol+0xe9>
  800d56:	89 c7                	mov    %eax,%edi
  800d58:	f7 df                	neg    %edi
}
  800d5a:	89 f8                	mov    %edi,%eax
  800d5c:	83 c4 04             	add    $0x4,%esp
  800d5f:	5b                   	pop    %ebx
  800d60:	5e                   	pop    %esi
  800d61:	5f                   	pop    %edi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	83 ec 0c             	sub    $0xc,%esp
  800d6a:	89 1c 24             	mov    %ebx,(%esp)
  800d6d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d71:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d75:	b8 01 00 00 00       	mov    $0x1,%eax
  800d7a:	bf 00 00 00 00       	mov    $0x0,%edi
  800d7f:	89 fa                	mov    %edi,%edx
  800d81:	89 f9                	mov    %edi,%ecx
  800d83:	89 fb                	mov    %edi,%ebx
  800d85:	89 fe                	mov    %edi,%esi
  800d87:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d89:	8b 1c 24             	mov    (%esp),%ebx
  800d8c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d90:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d94:	89 ec                	mov    %ebp,%esp
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    

00800d98 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	83 ec 0c             	sub    $0xc,%esp
  800d9e:	89 1c 24             	mov    %ebx,(%esp)
  800da1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800da5:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800da9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daf:	bf 00 00 00 00       	mov    $0x0,%edi
  800db4:	89 f8                	mov    %edi,%eax
  800db6:	89 fb                	mov    %edi,%ebx
  800db8:	89 fe                	mov    %edi,%esi
  800dba:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800dbc:	8b 1c 24             	mov    (%esp),%ebx
  800dbf:	8b 74 24 04          	mov    0x4(%esp),%esi
  800dc3:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800dc7:	89 ec                	mov    %ebp,%esp
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    

00800dcb <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	83 ec 0c             	sub    $0xc,%esp
  800dd1:	89 1c 24             	mov    %ebx,(%esp)
  800dd4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dd8:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddc:	b8 0e 00 00 00       	mov    $0xe,%eax
  800de1:	bf 00 00 00 00       	mov    $0x0,%edi
  800de6:	89 fa                	mov    %edi,%edx
  800de8:	89 f9                	mov    %edi,%ecx
  800dea:	89 fb                	mov    %edi,%ebx
  800dec:	89 fe                	mov    %edi,%esi
  800dee:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800df0:	8b 1c 24             	mov    (%esp),%ebx
  800df3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800df7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800dfb:	89 ec                	mov    %ebp,%esp
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    

00800dff <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	83 ec 28             	sub    $0x28,%esp
  800e05:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e08:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e0b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e0e:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e11:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e16:	bf 00 00 00 00       	mov    $0x0,%edi
  800e1b:	89 f9                	mov    %edi,%ecx
  800e1d:	89 fb                	mov    %edi,%ebx
  800e1f:	89 fe                	mov    %edi,%esi
  800e21:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800e23:	85 c0                	test   %eax,%eax
  800e25:	7e 28                	jle    800e4f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e27:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e2b:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e32:	00 
  800e33:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  800e3a:	00 
  800e3b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e42:	00 
  800e43:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  800e4a:	e8 ed 10 00 00       	call   801f3c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e4f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e52:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e55:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e58:	89 ec                	mov    %ebp,%esp
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    

00800e5c <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	83 ec 0c             	sub    $0xc,%esp
  800e62:	89 1c 24             	mov    %ebx,(%esp)
  800e65:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e69:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e73:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e76:	8b 7d 14             	mov    0x14(%ebp),%edi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e79:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e7e:	be 00 00 00 00       	mov    $0x0,%esi
  800e83:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e85:	8b 1c 24             	mov    (%esp),%ebx
  800e88:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e8c:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e90:	89 ec                	mov    %ebp,%esp
  800e92:	5d                   	pop    %ebp
  800e93:	c3                   	ret    

00800e94 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	83 ec 28             	sub    $0x28,%esp
  800e9a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e9d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ea0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ea3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eae:	bf 00 00 00 00       	mov    $0x0,%edi
  800eb3:	89 fb                	mov    %edi,%ebx
  800eb5:	89 fe                	mov    %edi,%esi
  800eb7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800eb9:	85 c0                	test   %eax,%eax
  800ebb:	7e 28                	jle    800ee5 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec1:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ec8:	00 
  800ec9:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  800ed0:	00 
  800ed1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed8:	00 
  800ed9:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  800ee0:	e8 57 10 00 00       	call   801f3c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ee5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ee8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eeb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eee:	89 ec                	mov    %ebp,%esp
  800ef0:	5d                   	pop    %ebp
  800ef1:	c3                   	ret    

00800ef2 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
  800ef5:	83 ec 28             	sub    $0x28,%esp
  800ef8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800efb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800efe:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f01:	8b 55 08             	mov    0x8(%ebp),%edx
  800f04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f07:	b8 09 00 00 00       	mov    $0x9,%eax
  800f0c:	bf 00 00 00 00       	mov    $0x0,%edi
  800f11:	89 fb                	mov    %edi,%ebx
  800f13:	89 fe                	mov    %edi,%esi
  800f15:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f17:	85 c0                	test   %eax,%eax
  800f19:	7e 28                	jle    800f43 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1f:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f26:	00 
  800f27:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  800f2e:	00 
  800f2f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f36:	00 
  800f37:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  800f3e:	e8 f9 0f 00 00       	call   801f3c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f43:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f46:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f49:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f4c:	89 ec                	mov    %ebp,%esp
  800f4e:	5d                   	pop    %ebp
  800f4f:	c3                   	ret    

00800f50 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f50:	55                   	push   %ebp
  800f51:	89 e5                	mov    %esp,%ebp
  800f53:	83 ec 28             	sub    $0x28,%esp
  800f56:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f59:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f5c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f65:	b8 08 00 00 00       	mov    $0x8,%eax
  800f6a:	bf 00 00 00 00       	mov    $0x0,%edi
  800f6f:	89 fb                	mov    %edi,%ebx
  800f71:	89 fe                	mov    %edi,%esi
  800f73:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f75:	85 c0                	test   %eax,%eax
  800f77:	7e 28                	jle    800fa1 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f79:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f7d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f84:	00 
  800f85:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  800f8c:	00 
  800f8d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f94:	00 
  800f95:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  800f9c:	e8 9b 0f 00 00       	call   801f3c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fa1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fa4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fa7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800faa:	89 ec                	mov    %ebp,%esp
  800fac:	5d                   	pop    %ebp
  800fad:	c3                   	ret    

00800fae <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800fae:	55                   	push   %ebp
  800faf:	89 e5                	mov    %esp,%ebp
  800fb1:	83 ec 28             	sub    $0x28,%esp
  800fb4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fb7:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fba:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800fbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc3:	b8 06 00 00 00       	mov    $0x6,%eax
  800fc8:	bf 00 00 00 00       	mov    $0x0,%edi
  800fcd:	89 fb                	mov    %edi,%ebx
  800fcf:	89 fe                	mov    %edi,%esi
  800fd1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800fd3:	85 c0                	test   %eax,%eax
  800fd5:	7e 28                	jle    800fff <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fdb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800fe2:	00 
  800fe3:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  800fea:	00 
  800feb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ff2:	00 
  800ff3:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  800ffa:	e8 3d 0f 00 00       	call   801f3c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fff:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801002:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801005:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801008:	89 ec                	mov    %ebp,%esp
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    

0080100c <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	83 ec 28             	sub    $0x28,%esp
  801012:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801015:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801018:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80101b:	8b 55 08             	mov    0x8(%ebp),%edx
  80101e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801021:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801024:	8b 7d 14             	mov    0x14(%ebp),%edi
  801027:	8b 75 18             	mov    0x18(%ebp),%esi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80102a:	b8 05 00 00 00       	mov    $0x5,%eax
  80102f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801031:	85 c0                	test   %eax,%eax
  801033:	7e 28                	jle    80105d <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801035:	89 44 24 10          	mov    %eax,0x10(%esp)
  801039:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801040:	00 
  801041:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  801048:	00 
  801049:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801050:	00 
  801051:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  801058:	e8 df 0e 00 00       	call   801f3c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80105d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801060:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801063:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801066:	89 ec                	mov    %ebp,%esp
  801068:	5d                   	pop    %ebp
  801069:	c3                   	ret    

0080106a <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80106a:	55                   	push   %ebp
  80106b:	89 e5                	mov    %esp,%ebp
  80106d:	83 ec 28             	sub    $0x28,%esp
  801070:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801073:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801076:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801079:	8b 55 08             	mov    0x8(%ebp),%edx
  80107c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80107f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801082:	b8 04 00 00 00       	mov    $0x4,%eax
  801087:	bf 00 00 00 00       	mov    $0x0,%edi
  80108c:	89 fe                	mov    %edi,%esi
  80108e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801090:	85 c0                	test   %eax,%eax
  801092:	7e 28                	jle    8010bc <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  801094:	89 44 24 10          	mov    %eax,0x10(%esp)
  801098:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80109f:	00 
  8010a0:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  8010a7:	00 
  8010a8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010af:	00 
  8010b0:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  8010b7:	e8 80 0e 00 00       	call   801f3c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010bc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010bf:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010c2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010c5:	89 ec                	mov    %ebp,%esp
  8010c7:	5d                   	pop    %ebp
  8010c8:	c3                   	ret    

008010c9 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  8010c9:	55                   	push   %ebp
  8010ca:	89 e5                	mov    %esp,%ebp
  8010cc:	83 ec 0c             	sub    $0xc,%esp
  8010cf:	89 1c 24             	mov    %ebx,(%esp)
  8010d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010d6:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010da:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010df:	bf 00 00 00 00       	mov    $0x0,%edi
  8010e4:	89 fa                	mov    %edi,%edx
  8010e6:	89 f9                	mov    %edi,%ecx
  8010e8:	89 fb                	mov    %edi,%ebx
  8010ea:	89 fe                	mov    %edi,%esi
  8010ec:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010ee:	8b 1c 24             	mov    (%esp),%ebx
  8010f1:	8b 74 24 04          	mov    0x4(%esp),%esi
  8010f5:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8010f9:	89 ec                	mov    %ebp,%esp
  8010fb:	5d                   	pop    %ebp
  8010fc:	c3                   	ret    

008010fd <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8010fd:	55                   	push   %ebp
  8010fe:	89 e5                	mov    %esp,%ebp
  801100:	83 ec 0c             	sub    $0xc,%esp
  801103:	89 1c 24             	mov    %ebx,(%esp)
  801106:	89 74 24 04          	mov    %esi,0x4(%esp)
  80110a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80110e:	b8 02 00 00 00       	mov    $0x2,%eax
  801113:	bf 00 00 00 00       	mov    $0x0,%edi
  801118:	89 fa                	mov    %edi,%edx
  80111a:	89 f9                	mov    %edi,%ecx
  80111c:	89 fb                	mov    %edi,%ebx
  80111e:	89 fe                	mov    %edi,%esi
  801120:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801122:	8b 1c 24             	mov    (%esp),%ebx
  801125:	8b 74 24 04          	mov    0x4(%esp),%esi
  801129:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80112d:	89 ec                	mov    %ebp,%esp
  80112f:	5d                   	pop    %ebp
  801130:	c3                   	ret    

00801131 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
  801134:	83 ec 28             	sub    $0x28,%esp
  801137:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80113a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80113d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801140:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801143:	b8 03 00 00 00       	mov    $0x3,%eax
  801148:	bf 00 00 00 00       	mov    $0x0,%edi
  80114d:	89 f9                	mov    %edi,%ecx
  80114f:	89 fb                	mov    %edi,%ebx
  801151:	89 fe                	mov    %edi,%esi
  801153:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801155:	85 c0                	test   %eax,%eax
  801157:	7e 28                	jle    801181 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801159:	89 44 24 10          	mov    %eax,0x10(%esp)
  80115d:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801164:	00 
  801165:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  80116c:	00 
  80116d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801174:	00 
  801175:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  80117c:	e8 bb 0d 00 00       	call   801f3c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801181:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801184:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801187:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80118a:	89 ec                	mov    %ebp,%esp
  80118c:	5d                   	pop    %ebp
  80118d:	c3                   	ret    
	...

00801190 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	8b 45 08             	mov    0x8(%ebp),%eax
  801196:	05 00 00 00 30       	add    $0x30000000,%eax
  80119b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80119e:	5d                   	pop    %ebp
  80119f:	c3                   	ret    

008011a0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8011a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a9:	89 04 24             	mov    %eax,(%esp)
  8011ac:	e8 df ff ff ff       	call   801190 <fd2num>
  8011b1:	c1 e0 0c             	shl    $0xc,%eax
  8011b4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011b9:	c9                   	leave  
  8011ba:	c3                   	ret    

008011bb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011bb:	55                   	push   %ebp
  8011bc:	89 e5                	mov    %esp,%ebp
  8011be:	53                   	push   %ebx
  8011bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8011c2:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  8011c7:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  8011c9:	89 d0                	mov    %edx,%eax
  8011cb:	c1 e8 16             	shr    $0x16,%eax
  8011ce:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011d5:	a8 01                	test   $0x1,%al
  8011d7:	74 10                	je     8011e9 <fd_alloc+0x2e>
  8011d9:	89 d0                	mov    %edx,%eax
  8011db:	c1 e8 0c             	shr    $0xc,%eax
  8011de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011e5:	a8 01                	test   $0x1,%al
  8011e7:	75 09                	jne    8011f2 <fd_alloc+0x37>
			*fd_store = fd;
  8011e9:	89 0b                	mov    %ecx,(%ebx)
  8011eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f0:	eb 19                	jmp    80120b <fd_alloc+0x50>
			return 0;
  8011f2:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011f8:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  8011fe:	75 c7                	jne    8011c7 <fd_alloc+0xc>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801200:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801206:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  80120b:	5b                   	pop    %ebx
  80120c:	5d                   	pop    %ebp
  80120d:	c3                   	ret    

0080120e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801211:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  801215:	77 38                	ja     80124f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801217:	8b 45 08             	mov    0x8(%ebp),%eax
  80121a:	c1 e0 0c             	shl    $0xc,%eax
  80121d:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  801223:	89 d0                	mov    %edx,%eax
  801225:	c1 e8 16             	shr    $0x16,%eax
  801228:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80122f:	a8 01                	test   $0x1,%al
  801231:	74 1c                	je     80124f <fd_lookup+0x41>
  801233:	89 d0                	mov    %edx,%eax
  801235:	c1 e8 0c             	shr    $0xc,%eax
  801238:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80123f:	a8 01                	test   $0x1,%al
  801241:	74 0c                	je     80124f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801243:	8b 45 0c             	mov    0xc(%ebp),%eax
  801246:	89 10                	mov    %edx,(%eax)
  801248:	b8 00 00 00 00       	mov    $0x0,%eax
  80124d:	eb 05                	jmp    801254 <fd_lookup+0x46>
	return 0;
  80124f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801254:	5d                   	pop    %ebp
  801255:	c3                   	ret    

00801256 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
  801259:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80125c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80125f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801263:	8b 45 08             	mov    0x8(%ebp),%eax
  801266:	89 04 24             	mov    %eax,(%esp)
  801269:	e8 a0 ff ff ff       	call   80120e <fd_lookup>
  80126e:	85 c0                	test   %eax,%eax
  801270:	78 0e                	js     801280 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801272:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801275:	8b 55 0c             	mov    0xc(%ebp),%edx
  801278:	89 50 04             	mov    %edx,0x4(%eax)
  80127b:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801280:	c9                   	leave  
  801281:	c3                   	ret    

00801282 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
  801285:	53                   	push   %ebx
  801286:	83 ec 14             	sub    $0x14,%esp
  801289:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80128c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80128f:	ba 08 60 80 00       	mov    $0x806008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801294:	b8 00 00 00 00       	mov    $0x0,%eax
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801299:	39 0d 08 60 80 00    	cmp    %ecx,0x806008
  80129f:	75 11                	jne    8012b2 <dev_lookup+0x30>
  8012a1:	eb 04                	jmp    8012a7 <dev_lookup+0x25>
  8012a3:	39 0a                	cmp    %ecx,(%edx)
  8012a5:	75 0b                	jne    8012b2 <dev_lookup+0x30>
			*dev = devtab[i];
  8012a7:	89 13                	mov    %edx,(%ebx)
  8012a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ae:	66 90                	xchg   %ax,%ax
  8012b0:	eb 35                	jmp    8012e7 <dev_lookup+0x65>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012b2:	83 c0 01             	add    $0x1,%eax
  8012b5:	8b 14 85 ec 2b 80 00 	mov    0x802bec(,%eax,4),%edx
  8012bc:	85 d2                	test   %edx,%edx
  8012be:	75 e3                	jne    8012a3 <dev_lookup+0x21>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  8012c0:	a1 50 60 80 00       	mov    0x806050,%eax
  8012c5:	8b 40 4c             	mov    0x4c(%eax),%eax
  8012c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d0:	c7 04 24 6c 2b 80 00 	movl   $0x802b6c,(%esp)
  8012d7:	e8 ed ef ff ff       	call   8002c9 <cprintf>
	*dev = 0;
  8012dc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8012e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8012e7:	83 c4 14             	add    $0x14,%esp
  8012ea:	5b                   	pop    %ebx
  8012eb:	5d                   	pop    %ebp
  8012ec:	c3                   	ret    

008012ed <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8012ed:	55                   	push   %ebp
  8012ee:	89 e5                	mov    %esp,%ebp
  8012f0:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f3:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8012f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8012fd:	89 04 24             	mov    %eax,(%esp)
  801300:	e8 09 ff ff ff       	call   80120e <fd_lookup>
  801305:	89 c2                	mov    %eax,%edx
  801307:	85 c0                	test   %eax,%eax
  801309:	78 5a                	js     801365 <fstat+0x78>
  80130b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80130e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801312:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801315:	8b 00                	mov    (%eax),%eax
  801317:	89 04 24             	mov    %eax,(%esp)
  80131a:	e8 63 ff ff ff       	call   801282 <dev_lookup>
  80131f:	89 c2                	mov    %eax,%edx
  801321:	85 c0                	test   %eax,%eax
  801323:	78 40                	js     801365 <fstat+0x78>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801325:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  80132a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80132d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801331:	74 32                	je     801365 <fstat+0x78>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801333:	8b 45 0c             	mov    0xc(%ebp),%eax
  801336:	c6 00 00             	movb   $0x0,(%eax)
	stat->st_size = 0;
  801339:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  801340:	00 00 00 
	stat->st_isdir = 0;
  801343:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
  80134a:	00 00 00 
	stat->st_dev = dev;
  80134d:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801350:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
	return (*dev->dev_stat)(fd, stat);
  801356:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80135d:	89 04 24             	mov    %eax,(%esp)
  801360:	ff 52 14             	call   *0x14(%edx)
  801363:	89 c2                	mov    %eax,%edx
}
  801365:	89 d0                	mov    %edx,%eax
  801367:	c9                   	leave  
  801368:	c3                   	ret    

00801369 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801369:	55                   	push   %ebp
  80136a:	89 e5                	mov    %esp,%ebp
  80136c:	53                   	push   %ebx
  80136d:	83 ec 24             	sub    $0x24,%esp
  801370:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801373:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801376:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137a:	89 1c 24             	mov    %ebx,(%esp)
  80137d:	e8 8c fe ff ff       	call   80120e <fd_lookup>
  801382:	85 c0                	test   %eax,%eax
  801384:	78 61                	js     8013e7 <ftruncate+0x7e>
  801386:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801389:	8b 10                	mov    (%eax),%edx
  80138b:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80138e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801392:	89 14 24             	mov    %edx,(%esp)
  801395:	e8 e8 fe ff ff       	call   801282 <dev_lookup>
  80139a:	85 c0                	test   %eax,%eax
  80139c:	78 49                	js     8013e7 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80139e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  8013a1:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  8013a5:	75 23                	jne    8013ca <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013a7:	a1 50 60 80 00       	mov    0x806050,%eax
  8013ac:	8b 40 4c             	mov    0x4c(%eax),%eax
  8013af:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b7:	c7 04 24 8c 2b 80 00 	movl   $0x802b8c,(%esp)
  8013be:	e8 06 ef ff ff       	call   8002c9 <cprintf>
  8013c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013c8:	eb 1d                	jmp    8013e7 <ftruncate+0x7e>
			env->env_id, fdnum); 
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8013ca:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8013cd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013d2:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  8013d6:	74 0f                	je     8013e7 <ftruncate+0x7e>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013d8:	8b 42 18             	mov    0x18(%edx),%eax
  8013db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013de:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013e2:	89 0c 24             	mov    %ecx,(%esp)
  8013e5:	ff d0                	call   *%eax
}
  8013e7:	83 c4 24             	add    $0x24,%esp
  8013ea:	5b                   	pop    %ebx
  8013eb:	5d                   	pop    %ebp
  8013ec:	c3                   	ret    

008013ed <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
  8013f0:	53                   	push   %ebx
  8013f1:	83 ec 24             	sub    $0x24,%esp
  8013f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013fe:	89 1c 24             	mov    %ebx,(%esp)
  801401:	e8 08 fe ff ff       	call   80120e <fd_lookup>
  801406:	85 c0                	test   %eax,%eax
  801408:	78 68                	js     801472 <write+0x85>
  80140a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80140d:	8b 10                	mov    (%eax),%edx
  80140f:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801412:	89 44 24 04          	mov    %eax,0x4(%esp)
  801416:	89 14 24             	mov    %edx,(%esp)
  801419:	e8 64 fe ff ff       	call   801282 <dev_lookup>
  80141e:	85 c0                	test   %eax,%eax
  801420:	78 50                	js     801472 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801422:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801425:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801429:	75 23                	jne    80144e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  80142b:	a1 50 60 80 00       	mov    0x806050,%eax
  801430:	8b 40 4c             	mov    0x4c(%eax),%eax
  801433:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801437:	89 44 24 04          	mov    %eax,0x4(%esp)
  80143b:	c7 04 24 b0 2b 80 00 	movl   $0x802bb0,(%esp)
  801442:	e8 82 ee ff ff       	call   8002c9 <cprintf>
  801447:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80144c:	eb 24                	jmp    801472 <write+0x85>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80144e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801451:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801456:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  80145a:	74 16                	je     801472 <write+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80145c:	8b 42 0c             	mov    0xc(%edx),%eax
  80145f:	8b 55 10             	mov    0x10(%ebp),%edx
  801462:	89 54 24 08          	mov    %edx,0x8(%esp)
  801466:	8b 55 0c             	mov    0xc(%ebp),%edx
  801469:	89 54 24 04          	mov    %edx,0x4(%esp)
  80146d:	89 0c 24             	mov    %ecx,(%esp)
  801470:	ff d0                	call   *%eax
}
  801472:	83 c4 24             	add    $0x24,%esp
  801475:	5b                   	pop    %ebx
  801476:	5d                   	pop    %ebp
  801477:	c3                   	ret    

00801478 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801478:	55                   	push   %ebp
  801479:	89 e5                	mov    %esp,%ebp
  80147b:	53                   	push   %ebx
  80147c:	83 ec 24             	sub    $0x24,%esp
  80147f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801482:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801485:	89 44 24 04          	mov    %eax,0x4(%esp)
  801489:	89 1c 24             	mov    %ebx,(%esp)
  80148c:	e8 7d fd ff ff       	call   80120e <fd_lookup>
  801491:	85 c0                	test   %eax,%eax
  801493:	78 6d                	js     801502 <read+0x8a>
  801495:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801498:	8b 10                	mov    (%eax),%edx
  80149a:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80149d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a1:	89 14 24             	mov    %edx,(%esp)
  8014a4:	e8 d9 fd ff ff       	call   801282 <dev_lookup>
  8014a9:	85 c0                	test   %eax,%eax
  8014ab:	78 55                	js     801502 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014ad:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  8014b0:	8b 41 08             	mov    0x8(%ecx),%eax
  8014b3:	83 e0 03             	and    $0x3,%eax
  8014b6:	83 f8 01             	cmp    $0x1,%eax
  8014b9:	75 23                	jne    8014de <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  8014bb:	a1 50 60 80 00       	mov    0x806050,%eax
  8014c0:	8b 40 4c             	mov    0x4c(%eax),%eax
  8014c3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014cb:	c7 04 24 cd 2b 80 00 	movl   $0x802bcd,(%esp)
  8014d2:	e8 f2 ed ff ff       	call   8002c9 <cprintf>
  8014d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014dc:	eb 24                	jmp    801502 <read+0x8a>
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8014de:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8014e1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014e6:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  8014ea:	74 16                	je     801502 <read+0x8a>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014ec:	8b 42 08             	mov    0x8(%edx),%eax
  8014ef:	8b 55 10             	mov    0x10(%ebp),%edx
  8014f2:	89 54 24 08          	mov    %edx,0x8(%esp)
  8014f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014fd:	89 0c 24             	mov    %ecx,(%esp)
  801500:	ff d0                	call   *%eax
}
  801502:	83 c4 24             	add    $0x24,%esp
  801505:	5b                   	pop    %ebx
  801506:	5d                   	pop    %ebp
  801507:	c3                   	ret    

00801508 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801508:	55                   	push   %ebp
  801509:	89 e5                	mov    %esp,%ebp
  80150b:	57                   	push   %edi
  80150c:	56                   	push   %esi
  80150d:	53                   	push   %ebx
  80150e:	83 ec 0c             	sub    $0xc,%esp
  801511:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801514:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801517:	b8 00 00 00 00       	mov    $0x0,%eax
  80151c:	85 f6                	test   %esi,%esi
  80151e:	74 36                	je     801556 <readn+0x4e>
  801520:	bb 00 00 00 00       	mov    $0x0,%ebx
  801525:	ba 00 00 00 00       	mov    $0x0,%edx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80152a:	89 f0                	mov    %esi,%eax
  80152c:	29 d0                	sub    %edx,%eax
  80152e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801532:	8d 04 17             	lea    (%edi,%edx,1),%eax
  801535:	89 44 24 04          	mov    %eax,0x4(%esp)
  801539:	8b 45 08             	mov    0x8(%ebp),%eax
  80153c:	89 04 24             	mov    %eax,(%esp)
  80153f:	e8 34 ff ff ff       	call   801478 <read>
		if (m < 0)
  801544:	85 c0                	test   %eax,%eax
  801546:	78 0e                	js     801556 <readn+0x4e>
			return m;
		if (m == 0)
  801548:	85 c0                	test   %eax,%eax
  80154a:	74 08                	je     801554 <readn+0x4c>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80154c:	01 c3                	add    %eax,%ebx
  80154e:	89 da                	mov    %ebx,%edx
  801550:	39 f3                	cmp    %esi,%ebx
  801552:	72 d6                	jb     80152a <readn+0x22>
  801554:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801556:	83 c4 0c             	add    $0xc,%esp
  801559:	5b                   	pop    %ebx
  80155a:	5e                   	pop    %esi
  80155b:	5f                   	pop    %edi
  80155c:	5d                   	pop    %ebp
  80155d:	c3                   	ret    

0080155e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80155e:	55                   	push   %ebp
  80155f:	89 e5                	mov    %esp,%ebp
  801561:	83 ec 28             	sub    $0x28,%esp
  801564:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801567:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80156a:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80156d:	89 34 24             	mov    %esi,(%esp)
  801570:	e8 1b fc ff ff       	call   801190 <fd2num>
  801575:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801578:	89 54 24 04          	mov    %edx,0x4(%esp)
  80157c:	89 04 24             	mov    %eax,(%esp)
  80157f:	e8 8a fc ff ff       	call   80120e <fd_lookup>
  801584:	89 c3                	mov    %eax,%ebx
  801586:	85 c0                	test   %eax,%eax
  801588:	78 05                	js     80158f <fd_close+0x31>
  80158a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80158d:	74 0d                	je     80159c <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80158f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801593:	75 44                	jne    8015d9 <fd_close+0x7b>
  801595:	bb 00 00 00 00       	mov    $0x0,%ebx
  80159a:	eb 3d                	jmp    8015d9 <fd_close+0x7b>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80159c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80159f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a3:	8b 06                	mov    (%esi),%eax
  8015a5:	89 04 24             	mov    %eax,(%esp)
  8015a8:	e8 d5 fc ff ff       	call   801282 <dev_lookup>
  8015ad:	89 c3                	mov    %eax,%ebx
  8015af:	85 c0                	test   %eax,%eax
  8015b1:	78 16                	js     8015c9 <fd_close+0x6b>
		if (dev->dev_close)
  8015b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b6:	8b 40 10             	mov    0x10(%eax),%eax
  8015b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015be:	85 c0                	test   %eax,%eax
  8015c0:	74 07                	je     8015c9 <fd_close+0x6b>
			r = (*dev->dev_close)(fd);
  8015c2:	89 34 24             	mov    %esi,(%esp)
  8015c5:	ff d0                	call   *%eax
  8015c7:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015c9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015d4:	e8 d5 f9 ff ff       	call   800fae <sys_page_unmap>
	return r;
}
  8015d9:	89 d8                	mov    %ebx,%eax
  8015db:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8015de:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8015e1:	89 ec                	mov    %ebp,%esp
  8015e3:	5d                   	pop    %ebp
  8015e4:	c3                   	ret    

008015e5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015e5:	55                   	push   %ebp
  8015e6:	89 e5                	mov    %esp,%ebp
  8015e8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015eb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f5:	89 04 24             	mov    %eax,(%esp)
  8015f8:	e8 11 fc ff ff       	call   80120e <fd_lookup>
  8015fd:	85 c0                	test   %eax,%eax
  8015ff:	78 13                	js     801614 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801601:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801608:	00 
  801609:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80160c:	89 04 24             	mov    %eax,(%esp)
  80160f:	e8 4a ff ff ff       	call   80155e <fd_close>
}
  801614:	c9                   	leave  
  801615:	c3                   	ret    

00801616 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	83 ec 18             	sub    $0x18,%esp
  80161c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80161f:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801622:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801629:	00 
  80162a:	8b 45 08             	mov    0x8(%ebp),%eax
  80162d:	89 04 24             	mov    %eax,(%esp)
  801630:	e8 5a 03 00 00       	call   80198f <open>
  801635:	89 c6                	mov    %eax,%esi
  801637:	85 c0                	test   %eax,%eax
  801639:	78 1b                	js     801656 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  80163b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80163e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801642:	89 34 24             	mov    %esi,(%esp)
  801645:	e8 a3 fc ff ff       	call   8012ed <fstat>
  80164a:	89 c3                	mov    %eax,%ebx
	close(fd);
  80164c:	89 34 24             	mov    %esi,(%esp)
  80164f:	e8 91 ff ff ff       	call   8015e5 <close>
  801654:	89 de                	mov    %ebx,%esi
	return r;
}
  801656:	89 f0                	mov    %esi,%eax
  801658:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80165b:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80165e:	89 ec                	mov    %ebp,%esp
  801660:	5d                   	pop    %ebp
  801661:	c3                   	ret    

00801662 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801662:	55                   	push   %ebp
  801663:	89 e5                	mov    %esp,%ebp
  801665:	83 ec 38             	sub    $0x38,%esp
  801668:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80166b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80166e:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801671:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801674:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801677:	89 44 24 04          	mov    %eax,0x4(%esp)
  80167b:	8b 45 08             	mov    0x8(%ebp),%eax
  80167e:	89 04 24             	mov    %eax,(%esp)
  801681:	e8 88 fb ff ff       	call   80120e <fd_lookup>
  801686:	89 c3                	mov    %eax,%ebx
  801688:	85 c0                	test   %eax,%eax
  80168a:	0f 88 e1 00 00 00    	js     801771 <dup+0x10f>
		return r;
	close(newfdnum);
  801690:	89 3c 24             	mov    %edi,(%esp)
  801693:	e8 4d ff ff ff       	call   8015e5 <close>

	newfd = INDEX2FD(newfdnum);
  801698:	89 f8                	mov    %edi,%eax
  80169a:	c1 e0 0c             	shl    $0xc,%eax
  80169d:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  8016a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a6:	89 04 24             	mov    %eax,(%esp)
  8016a9:	e8 f2 fa ff ff       	call   8011a0 <fd2data>
  8016ae:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8016b0:	89 34 24             	mov    %esi,(%esp)
  8016b3:	e8 e8 fa ff ff       	call   8011a0 <fd2data>
  8016b8:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  8016bb:	89 d8                	mov    %ebx,%eax
  8016bd:	c1 e8 16             	shr    $0x16,%eax
  8016c0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016c7:	a8 01                	test   $0x1,%al
  8016c9:	74 45                	je     801710 <dup+0xae>
  8016cb:	89 da                	mov    %ebx,%edx
  8016cd:	c1 ea 0c             	shr    $0xc,%edx
  8016d0:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8016d7:	a8 01                	test   $0x1,%al
  8016d9:	74 35                	je     801710 <dup+0xae>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  8016db:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8016e2:	25 07 0e 00 00       	and    $0xe07,%eax
  8016e7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016f2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016f9:	00 
  8016fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801705:	e8 02 f9 ff ff       	call   80100c <sys_page_map>
  80170a:	89 c3                	mov    %eax,%ebx
  80170c:	85 c0                	test   %eax,%eax
  80170e:	78 3e                	js     80174e <dup+0xec>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  801710:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801713:	89 d0                	mov    %edx,%eax
  801715:	c1 e8 0c             	shr    $0xc,%eax
  801718:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80171f:	25 07 0e 00 00       	and    $0xe07,%eax
  801724:	89 44 24 10          	mov    %eax,0x10(%esp)
  801728:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80172c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801733:	00 
  801734:	89 54 24 04          	mov    %edx,0x4(%esp)
  801738:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80173f:	e8 c8 f8 ff ff       	call   80100c <sys_page_map>
  801744:	89 c3                	mov    %eax,%ebx
  801746:	85 c0                	test   %eax,%eax
  801748:	78 04                	js     80174e <dup+0xec>
		goto err;
  80174a:	89 fb                	mov    %edi,%ebx
  80174c:	eb 23                	jmp    801771 <dup+0x10f>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80174e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801752:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801759:	e8 50 f8 ff ff       	call   800fae <sys_page_unmap>
	sys_page_unmap(0, nva);
  80175e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801761:	89 44 24 04          	mov    %eax,0x4(%esp)
  801765:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80176c:	e8 3d f8 ff ff       	call   800fae <sys_page_unmap>
	return r;
}
  801771:	89 d8                	mov    %ebx,%eax
  801773:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801776:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801779:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80177c:	89 ec                	mov    %ebp,%esp
  80177e:	5d                   	pop    %ebp
  80177f:	c3                   	ret    

00801780 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	53                   	push   %ebx
  801784:	83 ec 04             	sub    $0x4,%esp
  801787:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  80178c:	89 1c 24             	mov    %ebx,(%esp)
  80178f:	e8 51 fe ff ff       	call   8015e5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801794:	83 c3 01             	add    $0x1,%ebx
  801797:	83 fb 20             	cmp    $0x20,%ebx
  80179a:	75 f0                	jne    80178c <close_all+0xc>
		close(i);
}
  80179c:	83 c4 04             	add    $0x4,%esp
  80179f:	5b                   	pop    %ebx
  8017a0:	5d                   	pop    %ebp
  8017a1:	c3                   	ret    
	...

008017a4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017a4:	55                   	push   %ebp
  8017a5:	89 e5                	mov    %esp,%ebp
  8017a7:	53                   	push   %ebx
  8017a8:	83 ec 14             	sub    $0x14,%esp
  8017ab:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017ad:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  8017b3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8017ba:	00 
  8017bb:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  8017c2:	00 
  8017c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c7:	89 14 24             	mov    %edx,(%esp)
  8017ca:	e8 e1 07 00 00       	call   801fb0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017cf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017d6:	00 
  8017d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017e2:	e8 7d 08 00 00       	call   802064 <ipc_recv>
}
  8017e7:	83 c4 14             	add    $0x14,%esp
  8017ea:	5b                   	pop    %ebx
  8017eb:	5d                   	pop    %ebp
  8017ec:	c3                   	ret    

008017ed <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  8017ed:	55                   	push   %ebp
  8017ee:	89 e5                	mov    %esp,%ebp
  8017f0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f8:	b8 08 00 00 00       	mov    $0x8,%eax
  8017fd:	e8 a2 ff ff ff       	call   8017a4 <fsipc>
}
  801802:	c9                   	leave  
  801803:	c3                   	ret    

00801804 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80180a:	8b 45 08             	mov    0x8(%ebp),%eax
  80180d:	8b 40 0c             	mov    0xc(%eax),%eax
  801810:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.set_size.req_size = newsize;
  801815:	8b 45 0c             	mov    0xc(%ebp),%eax
  801818:	a3 04 30 80 00       	mov    %eax,0x803004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80181d:	ba 00 00 00 00       	mov    $0x0,%edx
  801822:	b8 02 00 00 00       	mov    $0x2,%eax
  801827:	e8 78 ff ff ff       	call   8017a4 <fsipc>
}
  80182c:	c9                   	leave  
  80182d:	c3                   	ret    

0080182e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801834:	8b 45 08             	mov    0x8(%ebp),%eax
  801837:	8b 40 0c             	mov    0xc(%eax),%eax
  80183a:	a3 00 30 80 00       	mov    %eax,0x803000
	return fsipc(FSREQ_FLUSH, NULL);
  80183f:	ba 00 00 00 00       	mov    $0x0,%edx
  801844:	b8 06 00 00 00       	mov    $0x6,%eax
  801849:	e8 56 ff ff ff       	call   8017a4 <fsipc>
}
  80184e:	c9                   	leave  
  80184f:	c3                   	ret    

00801850 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	53                   	push   %ebx
  801854:	83 ec 14             	sub    $0x14,%esp
  801857:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80185a:	8b 45 08             	mov    0x8(%ebp),%eax
  80185d:	8b 40 0c             	mov    0xc(%eax),%eax
  801860:	a3 00 30 80 00       	mov    %eax,0x803000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801865:	ba 00 00 00 00       	mov    $0x0,%edx
  80186a:	b8 05 00 00 00       	mov    $0x5,%eax
  80186f:	e8 30 ff ff ff       	call   8017a4 <fsipc>
  801874:	85 c0                	test   %eax,%eax
  801876:	78 2b                	js     8018a3 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801878:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  80187f:	00 
  801880:	89 1c 24             	mov    %ebx,(%esp)
  801883:	e8 a9 f0 ff ff       	call   800931 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801888:	a1 80 30 80 00       	mov    0x803080,%eax
  80188d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801893:	a1 84 30 80 00       	mov    0x803084,%eax
  801898:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  80189e:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8018a3:	83 c4 14             	add    $0x14,%esp
  8018a6:	5b                   	pop    %ebx
  8018a7:	5d                   	pop    %ebp
  8018a8:	c3                   	ret    

008018a9 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018a9:	55                   	push   %ebp
  8018aa:	89 e5                	mov    %esp,%ebp
  8018ac:	83 ec 18             	sub    $0x18,%esp
  8018af:	8b 55 10             	mov    0x10(%ebp),%edx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	ssize_t writesize;
	size_t bufsize;
	fsipcbuf.write.req_fileid=fd->fd_file.id;
  8018b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b8:	a3 00 30 80 00       	mov    %eax,0x803000
	bufsize=sizeof(fsipcbuf.write.req_buf);
	if(n<bufsize)
  8018bd:	89 d0                	mov    %edx,%eax
  8018bf:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  8018c5:	76 05                	jbe    8018cc <devfile_write+0x23>
  8018c7:	b8 f8 0f 00 00       	mov    $0xff8,%eax
		bufsize=n;	
	fsipcbuf.write.req_n=n;
  8018cc:	89 15 04 30 80 00    	mov    %edx,0x803004
	memmove((void*)fsipcbuf.write.req_buf,buf,bufsize);
  8018d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018dd:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  8018e4:	e8 4f f2 ff ff       	call   800b38 <memmove>
	writesize=(ssize_t)fsipc(FSREQ_WRITE,NULL);
  8018e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ee:	b8 04 00 00 00       	mov    $0x4,%eax
  8018f3:	e8 ac fe ff ff       	call   8017a4 <fsipc>
	return writesize;
	//panic("devfile_write not implemented");
}
  8018f8:	c9                   	leave  
  8018f9:	c3                   	ret    

008018fa <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018fa:	55                   	push   %ebp
  8018fb:	89 e5                	mov    %esp,%ebp
  8018fd:	53                   	push   %ebx
  8018fe:	83 ec 14             	sub    $0x14,%esp
	// system server.
	// LAB 5: Your code here
	ssize_t readsize;
	if(debug)
		cprintf("devfile_read:fileid=%x readsize=%x\n",fd->fd_file.id,n);
	fsipcbuf.read.req_fileid=fd->fd_file.id;
  801901:	8b 45 08             	mov    0x8(%ebp),%eax
  801904:	8b 40 0c             	mov    0xc(%eax),%eax
  801907:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.read.req_n=n;
  80190c:	8b 45 10             	mov    0x10(%ebp),%eax
  80190f:	a3 04 30 80 00       	mov    %eax,0x803004
	readsize=(ssize_t)fsipc(FSREQ_READ,&fsipcbuf);
  801914:	ba 00 30 80 00       	mov    $0x803000,%edx
  801919:	b8 03 00 00 00       	mov    $0x3,%eax
  80191e:	e8 81 fe ff ff       	call   8017a4 <fsipc>
  801923:	89 c3                	mov    %eax,%ebx
	//cprintf("readsize=%d\n",readsize);
	if(debug)
		cprintf("devfile_read:buf1=%s\nbuf2=%s\n",(char*)&fsipcbuf,fsipcbuf.readRet.ret_buf);
	if(readsize>0)
  801925:	85 c0                	test   %eax,%eax
  801927:	7e 17                	jle    801940 <devfile_read+0x46>
		memmove(buf,(void*)&fsipcbuf,(size_t)readsize);
  801929:	89 44 24 08          	mov    %eax,0x8(%esp)
  80192d:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801934:	00 
  801935:	8b 45 0c             	mov    0xc(%ebp),%eax
  801938:	89 04 24             	mov    %eax,(%esp)
  80193b:	e8 f8 f1 ff ff       	call   800b38 <memmove>
	//cprintf("readsize=%d",readsize);
	return readsize;
	//panic("devfile_read not implemented");
}
  801940:	89 d8                	mov    %ebx,%eax
  801942:	83 c4 14             	add    $0x14,%esp
  801945:	5b                   	pop    %ebx
  801946:	5d                   	pop    %ebp
  801947:	c3                   	ret    

00801948 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	53                   	push   %ebx
  80194c:	83 ec 14             	sub    $0x14,%esp
  80194f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801952:	89 1c 24             	mov    %ebx,(%esp)
  801955:	e8 86 ef ff ff       	call   8008e0 <strlen>
  80195a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  80195f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801964:	7f 21                	jg     801987 <remove+0x3f>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801966:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80196a:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801971:	e8 bb ef ff ff       	call   800931 <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801976:	ba 00 00 00 00       	mov    $0x0,%edx
  80197b:	b8 07 00 00 00       	mov    $0x7,%eax
  801980:	e8 1f fe ff ff       	call   8017a4 <fsipc>
  801985:	89 c2                	mov    %eax,%edx
}
  801987:	89 d0                	mov    %edx,%eax
  801989:	83 c4 14             	add    $0x14,%esp
  80198c:	5b                   	pop    %ebx
  80198d:	5d                   	pop    %ebp
  80198e:	c3                   	ret    

0080198f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80198f:	55                   	push   %ebp
  801990:	89 e5                	mov    %esp,%ebp
  801992:	56                   	push   %esi
  801993:	53                   	push   %ebx
  801994:	83 ec 30             	sub    $0x30,%esp

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;
	void *page;
	if((r=fd_alloc(&fd))<0){
  801997:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80199a:	89 04 24             	mov    %eax,(%esp)
  80199d:	e8 19 f8 ff ff       	call   8011bb <fd_alloc>
  8019a2:	89 c3                	mov    %eax,%ebx
  8019a4:	85 c0                	test   %eax,%eax
  8019a6:	79 18                	jns    8019c0 <open+0x31>
		fd_close(fd,0);
  8019a8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019af:	00 
  8019b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b3:	89 04 24             	mov    %eax,(%esp)
  8019b6:	e8 a3 fb ff ff       	call   80155e <fd_close>
  8019bb:	e9 9f 00 00 00       	jmp    801a5f <open+0xd0>
		return r;
	}
	//cprintf("open:fd=%x\n",fd);
	strcpy(fsipcbuf.open.req_path,path);
  8019c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c7:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  8019ce:	e8 5e ef ff ff       	call   800931 <strcpy>
	fsipcbuf.open.req_omode=mode;
  8019d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d6:	a3 00 34 80 00       	mov    %eax,0x803400
	page=(void*)fd2data(fd);
  8019db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019de:	89 04 24             	mov    %eax,(%esp)
  8019e1:	e8 ba f7 ff ff       	call   8011a0 <fd2data>
  8019e6:	89 c6                	mov    %eax,%esi
	if((r=fsipc(FSREQ_OPEN,(void*)fd))<0)
  8019e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019eb:	b8 01 00 00 00       	mov    $0x1,%eax
  8019f0:	e8 af fd ff ff       	call   8017a4 <fsipc>
  8019f5:	89 c3                	mov    %eax,%ebx
  8019f7:	85 c0                	test   %eax,%eax
  8019f9:	79 15                	jns    801a10 <open+0x81>
	{
		fd_close(fd,1);
  8019fb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a02:	00 
  801a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a06:	89 04 24             	mov    %eax,(%esp)
  801a09:	e8 50 fb ff ff       	call   80155e <fd_close>
  801a0e:	eb 4f                	jmp    801a5f <open+0xd0>
		return r;	
	}
	//cprintf("open:page=%x\n",page);
	if((r=sys_page_map(0,(void*)fd,0,(void*)page,PTE_P | PTE_W | PTE_U))<0)
  801a10:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801a17:	00 
  801a18:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801a1c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a23:	00 
  801a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a27:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a2b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a32:	e8 d5 f5 ff ff       	call   80100c <sys_page_map>
  801a37:	89 c3                	mov    %eax,%ebx
  801a39:	85 c0                	test   %eax,%eax
  801a3b:	79 15                	jns    801a52 <open+0xc3>
	{
		fd_close(fd,1);
  801a3d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a44:	00 
  801a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a48:	89 04 24             	mov    %eax,(%esp)
  801a4b:	e8 0e fb ff ff       	call   80155e <fd_close>
  801a50:	eb 0d                	jmp    801a5f <open+0xd0>
		return r;
	}
	//cprintf("open:fileid=%x\n",fd->fd_file.id);
	return fd2num(fd);
  801a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a55:	89 04 24             	mov    %eax,(%esp)
  801a58:	e8 33 f7 ff ff       	call   801190 <fd2num>
  801a5d:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801a5f:	89 d8                	mov    %ebx,%eax
  801a61:	83 c4 30             	add    $0x30,%esp
  801a64:	5b                   	pop    %ebx
  801a65:	5e                   	pop    %esi
  801a66:	5d                   	pop    %ebp
  801a67:	c3                   	ret    
	...

00801a70 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  801a76:	c7 44 24 04 f8 2b 80 	movl   $0x802bf8,0x4(%esp)
  801a7d:	00 
  801a7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a81:	89 04 24             	mov    %eax,(%esp)
  801a84:	e8 a8 ee ff ff       	call   800931 <strcpy>
	return 0;
}
  801a89:	b8 00 00 00 00       	mov    $0x0,%eax
  801a8e:	c9                   	leave  
  801a8f:	c3                   	ret    

00801a90 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	83 ec 08             	sub    $0x8,%esp
	return nsipc_close(fd->fd_sock.sockid);
  801a96:	8b 45 08             	mov    0x8(%ebp),%eax
  801a99:	8b 40 0c             	mov    0xc(%eax),%eax
  801a9c:	89 04 24             	mov    %eax,(%esp)
  801a9f:	e8 9e 02 00 00       	call   801d42 <nsipc_close>
}
  801aa4:	c9                   	leave  
  801aa5:	c3                   	ret    

00801aa6 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801aa6:	55                   	push   %ebp
  801aa7:	89 e5                	mov    %esp,%ebp
  801aa9:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801aac:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801ab3:	00 
  801ab4:	8b 45 10             	mov    0x10(%ebp),%eax
  801ab7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801abb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801abe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac5:	8b 40 0c             	mov    0xc(%eax),%eax
  801ac8:	89 04 24             	mov    %eax,(%esp)
  801acb:	e8 ae 02 00 00       	call   801d7e <nsipc_send>
}
  801ad0:	c9                   	leave  
  801ad1:	c3                   	ret    

00801ad2 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801ad2:	55                   	push   %ebp
  801ad3:	89 e5                	mov    %esp,%ebp
  801ad5:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ad8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801adf:	00 
  801ae0:	8b 45 10             	mov    0x10(%ebp),%eax
  801ae3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ae7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aea:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aee:	8b 45 08             	mov    0x8(%ebp),%eax
  801af1:	8b 40 0c             	mov    0xc(%eax),%eax
  801af4:	89 04 24             	mov    %eax,(%esp)
  801af7:	e8 f5 02 00 00       	call   801df1 <nsipc_recv>
}
  801afc:	c9                   	leave  
  801afd:	c3                   	ret    

00801afe <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801afe:	55                   	push   %ebp
  801aff:	89 e5                	mov    %esp,%ebp
  801b01:	56                   	push   %esi
  801b02:	53                   	push   %ebx
  801b03:	83 ec 20             	sub    $0x20,%esp
  801b06:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b0b:	89 04 24             	mov    %eax,(%esp)
  801b0e:	e8 a8 f6 ff ff       	call   8011bb <fd_alloc>
  801b13:	89 c3                	mov    %eax,%ebx
  801b15:	85 c0                	test   %eax,%eax
  801b17:	78 21                	js     801b3a <alloc_sockfd+0x3c>
  801b19:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801b20:	00 
  801b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b24:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b28:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b2f:	e8 36 f5 ff ff       	call   80106a <sys_page_alloc>
  801b34:	89 c3                	mov    %eax,%ebx
  801b36:	85 c0                	test   %eax,%eax
  801b38:	79 0a                	jns    801b44 <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U)) < 0) {
		nsipc_close(sockid);
  801b3a:	89 34 24             	mov    %esi,(%esp)
  801b3d:	e8 00 02 00 00       	call   801d42 <nsipc_close>
  801b42:	eb 28                	jmp    801b6c <alloc_sockfd+0x6e>
		return r;
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b44:	8b 15 24 60 80 00    	mov    0x806024,%edx
  801b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b4d:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b52:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b62:	89 04 24             	mov    %eax,(%esp)
  801b65:	e8 26 f6 ff ff       	call   801190 <fd2num>
  801b6a:	89 c3                	mov    %eax,%ebx
}
  801b6c:	89 d8                	mov    %ebx,%eax
  801b6e:	83 c4 20             	add    $0x20,%esp
  801b71:	5b                   	pop    %ebx
  801b72:	5e                   	pop    %esi
  801b73:	5d                   	pop    %ebp
  801b74:	c3                   	ret    

00801b75 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b75:	55                   	push   %ebp
  801b76:	89 e5                	mov    %esp,%ebp
  801b78:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b7b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b7e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b82:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b85:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b89:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8c:	89 04 24             	mov    %eax,(%esp)
  801b8f:	e8 62 01 00 00       	call   801cf6 <nsipc_socket>
  801b94:	85 c0                	test   %eax,%eax
  801b96:	78 05                	js     801b9d <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801b98:	e8 61 ff ff ff       	call   801afe <alloc_sockfd>
}
  801b9d:	c9                   	leave  
  801b9e:	66 90                	xchg   %ax,%ax
  801ba0:	c3                   	ret    

00801ba1 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801ba1:	55                   	push   %ebp
  801ba2:	89 e5                	mov    %esp,%ebp
  801ba4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801ba7:	8d 55 fc             	lea    -0x4(%ebp),%edx
  801baa:	89 54 24 04          	mov    %edx,0x4(%esp)
  801bae:	89 04 24             	mov    %eax,(%esp)
  801bb1:	e8 58 f6 ff ff       	call   80120e <fd_lookup>
  801bb6:	89 c2                	mov    %eax,%edx
  801bb8:	85 c0                	test   %eax,%eax
  801bba:	78 15                	js     801bd1 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801bbc:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  801bbf:	8b 01                	mov    (%ecx),%eax
  801bc1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  801bc6:	3b 05 24 60 80 00    	cmp    0x806024,%eax
  801bcc:	75 03                	jne    801bd1 <fd2sockid+0x30>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801bce:	8b 51 0c             	mov    0xc(%ecx),%edx
}
  801bd1:	89 d0                	mov    %edx,%eax
  801bd3:	c9                   	leave  
  801bd4:	c3                   	ret    

00801bd5 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  801bd5:	55                   	push   %ebp
  801bd6:	89 e5                	mov    %esp,%ebp
  801bd8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bde:	e8 be ff ff ff       	call   801ba1 <fd2sockid>
  801be3:	85 c0                	test   %eax,%eax
  801be5:	78 0f                	js     801bf6 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801be7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bea:	89 54 24 04          	mov    %edx,0x4(%esp)
  801bee:	89 04 24             	mov    %eax,(%esp)
  801bf1:	e8 2a 01 00 00       	call   801d20 <nsipc_listen>
}
  801bf6:	c9                   	leave  
  801bf7:	c3                   	ret    

00801bf8 <connect>:
	return nsipc_close(fd->fd_sock.sockid);
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bfe:	8b 45 08             	mov    0x8(%ebp),%eax
  801c01:	e8 9b ff ff ff       	call   801ba1 <fd2sockid>
  801c06:	85 c0                	test   %eax,%eax
  801c08:	78 16                	js     801c20 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801c0a:	8b 55 10             	mov    0x10(%ebp),%edx
  801c0d:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c11:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c14:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c18:	89 04 24             	mov    %eax,(%esp)
  801c1b:	e8 51 02 00 00       	call   801e71 <nsipc_connect>
}
  801c20:	c9                   	leave  
  801c21:	c3                   	ret    

00801c22 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801c22:	55                   	push   %ebp
  801c23:	89 e5                	mov    %esp,%ebp
  801c25:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c28:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2b:	e8 71 ff ff ff       	call   801ba1 <fd2sockid>
  801c30:	85 c0                	test   %eax,%eax
  801c32:	78 0f                	js     801c43 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801c34:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c37:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c3b:	89 04 24             	mov    %eax,(%esp)
  801c3e:	e8 19 01 00 00       	call   801d5c <nsipc_shutdown>
}
  801c43:	c9                   	leave  
  801c44:	c3                   	ret    

00801c45 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c45:	55                   	push   %ebp
  801c46:	89 e5                	mov    %esp,%ebp
  801c48:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4e:	e8 4e ff ff ff       	call   801ba1 <fd2sockid>
  801c53:	85 c0                	test   %eax,%eax
  801c55:	78 16                	js     801c6d <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801c57:	8b 55 10             	mov    0x10(%ebp),%edx
  801c5a:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c61:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c65:	89 04 24             	mov    %eax,(%esp)
  801c68:	e8 43 02 00 00       	call   801eb0 <nsipc_bind>
}
  801c6d:	c9                   	leave  
  801c6e:	c3                   	ret    

00801c6f <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c6f:	55                   	push   %ebp
  801c70:	89 e5                	mov    %esp,%ebp
  801c72:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c75:	8b 45 08             	mov    0x8(%ebp),%eax
  801c78:	e8 24 ff ff ff       	call   801ba1 <fd2sockid>
  801c7d:	85 c0                	test   %eax,%eax
  801c7f:	78 1f                	js     801ca0 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c81:	8b 55 10             	mov    0x10(%ebp),%edx
  801c84:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c88:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c8b:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c8f:	89 04 24             	mov    %eax,(%esp)
  801c92:	e8 58 02 00 00       	call   801eef <nsipc_accept>
  801c97:	85 c0                	test   %eax,%eax
  801c99:	78 05                	js     801ca0 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801c9b:	e8 5e fe ff ff       	call   801afe <alloc_sockfd>
}
  801ca0:	c9                   	leave  
  801ca1:	c3                   	ret    
	...

00801cb0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801cb6:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  801cbc:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801cc3:	00 
  801cc4:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801ccb:	00 
  801ccc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cd0:	89 14 24             	mov    %edx,(%esp)
  801cd3:	e8 d8 02 00 00       	call   801fb0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801cd8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cdf:	00 
  801ce0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ce7:	00 
  801ce8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cef:	e8 70 03 00 00       	call   802064 <ipc_recv>
}
  801cf4:	c9                   	leave  
  801cf5:	c3                   	ret    

00801cf6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801cf6:	55                   	push   %ebp
  801cf7:	89 e5                	mov    %esp,%ebp
  801cf9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801cfc:	8b 45 08             	mov    0x8(%ebp),%eax
  801cff:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.socket.req_type = type;
  801d04:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d07:	a3 04 50 80 00       	mov    %eax,0x805004
	nsipcbuf.socket.req_protocol = protocol;
  801d0c:	8b 45 10             	mov    0x10(%ebp),%eax
  801d0f:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SOCKET);
  801d14:	b8 09 00 00 00       	mov    $0x9,%eax
  801d19:	e8 92 ff ff ff       	call   801cb0 <nsipc>
}
  801d1e:	c9                   	leave  
  801d1f:	c3                   	ret    

00801d20 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  801d20:	55                   	push   %ebp
  801d21:	89 e5                	mov    %esp,%ebp
  801d23:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d26:	8b 45 08             	mov    0x8(%ebp),%eax
  801d29:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.listen.req_backlog = backlog;
  801d2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d31:	a3 04 50 80 00       	mov    %eax,0x805004
	return nsipc(NSREQ_LISTEN);
  801d36:	b8 06 00 00 00       	mov    $0x6,%eax
  801d3b:	e8 70 ff ff ff       	call   801cb0 <nsipc>
}
  801d40:	c9                   	leave  
  801d41:	c3                   	ret    

00801d42 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  801d42:	55                   	push   %ebp
  801d43:	89 e5                	mov    %esp,%ebp
  801d45:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d48:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4b:	a3 00 50 80 00       	mov    %eax,0x805000
	return nsipc(NSREQ_CLOSE);
  801d50:	b8 04 00 00 00       	mov    $0x4,%eax
  801d55:	e8 56 ff ff ff       	call   801cb0 <nsipc>
}
  801d5a:	c9                   	leave  
  801d5b:	c3                   	ret    

00801d5c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  801d5c:	55                   	push   %ebp
  801d5d:	89 e5                	mov    %esp,%ebp
  801d5f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d62:	8b 45 08             	mov    0x8(%ebp),%eax
  801d65:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.shutdown.req_how = how;
  801d6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d6d:	a3 04 50 80 00       	mov    %eax,0x805004
	return nsipc(NSREQ_SHUTDOWN);
  801d72:	b8 03 00 00 00       	mov    $0x3,%eax
  801d77:	e8 34 ff ff ff       	call   801cb0 <nsipc>
}
  801d7c:	c9                   	leave  
  801d7d:	c3                   	ret    

00801d7e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d7e:	55                   	push   %ebp
  801d7f:	89 e5                	mov    %esp,%ebp
  801d81:	53                   	push   %ebx
  801d82:	83 ec 14             	sub    $0x14,%esp
  801d85:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d88:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8b:	a3 00 50 80 00       	mov    %eax,0x805000
	assert(size < 1600);
  801d90:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d96:	7e 24                	jle    801dbc <nsipc_send+0x3e>
  801d98:	c7 44 24 0c 04 2c 80 	movl   $0x802c04,0xc(%esp)
  801d9f:	00 
  801da0:	c7 44 24 08 10 2c 80 	movl   $0x802c10,0x8(%esp)
  801da7:	00 
  801da8:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  801daf:	00 
  801db0:	c7 04 24 25 2c 80 00 	movl   $0x802c25,(%esp)
  801db7:	e8 80 01 00 00       	call   801f3c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801dbc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dc0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dc7:	c7 04 24 0c 50 80 00 	movl   $0x80500c,(%esp)
  801dce:	e8 65 ed ff ff       	call   800b38 <memmove>
	nsipcbuf.send.req_size = size;
  801dd3:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	nsipcbuf.send.req_flags = flags;
  801dd9:	8b 45 14             	mov    0x14(%ebp),%eax
  801ddc:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SEND);
  801de1:	b8 08 00 00 00       	mov    $0x8,%eax
  801de6:	e8 c5 fe ff ff       	call   801cb0 <nsipc>
}
  801deb:	83 c4 14             	add    $0x14,%esp
  801dee:	5b                   	pop    %ebx
  801def:	5d                   	pop    %ebp
  801df0:	c3                   	ret    

00801df1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801df1:	55                   	push   %ebp
  801df2:	89 e5                	mov    %esp,%ebp
  801df4:	56                   	push   %esi
  801df5:	53                   	push   %ebx
  801df6:	83 ec 10             	sub    $0x10,%esp
  801df9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801dfc:	8b 45 08             	mov    0x8(%ebp),%eax
  801dff:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.recv.req_len = len;
  801e04:	89 35 04 50 80 00    	mov    %esi,0x805004
	nsipcbuf.recv.req_flags = flags;
  801e0a:	8b 45 14             	mov    0x14(%ebp),%eax
  801e0d:	a3 08 50 80 00       	mov    %eax,0x805008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e12:	b8 07 00 00 00       	mov    $0x7,%eax
  801e17:	e8 94 fe ff ff       	call   801cb0 <nsipc>
  801e1c:	89 c3                	mov    %eax,%ebx
  801e1e:	85 c0                	test   %eax,%eax
  801e20:	78 46                	js     801e68 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801e22:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e27:	7f 04                	jg     801e2d <nsipc_recv+0x3c>
  801e29:	39 c6                	cmp    %eax,%esi
  801e2b:	7d 24                	jge    801e51 <nsipc_recv+0x60>
  801e2d:	c7 44 24 0c 31 2c 80 	movl   $0x802c31,0xc(%esp)
  801e34:	00 
  801e35:	c7 44 24 08 10 2c 80 	movl   $0x802c10,0x8(%esp)
  801e3c:	00 
  801e3d:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  801e44:	00 
  801e45:	c7 04 24 25 2c 80 00 	movl   $0x802c25,(%esp)
  801e4c:	e8 eb 00 00 00       	call   801f3c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e51:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e55:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801e5c:	00 
  801e5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e60:	89 04 24             	mov    %eax,(%esp)
  801e63:	e8 d0 ec ff ff       	call   800b38 <memmove>
	}

	return r;
}
  801e68:	89 d8                	mov    %ebx,%eax
  801e6a:	83 c4 10             	add    $0x10,%esp
  801e6d:	5b                   	pop    %ebx
  801e6e:	5e                   	pop    %esi
  801e6f:	5d                   	pop    %ebp
  801e70:	c3                   	ret    

00801e71 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e71:	55                   	push   %ebp
  801e72:	89 e5                	mov    %esp,%ebp
  801e74:	53                   	push   %ebx
  801e75:	83 ec 14             	sub    $0x14,%esp
  801e78:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801e7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7e:	a3 00 50 80 00       	mov    %eax,0x805000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801e83:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e87:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e8e:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  801e95:	e8 9e ec ff ff       	call   800b38 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801e9a:	89 1d 14 50 80 00    	mov    %ebx,0x805014
	return nsipc(NSREQ_CONNECT);
  801ea0:	b8 05 00 00 00       	mov    $0x5,%eax
  801ea5:	e8 06 fe ff ff       	call   801cb0 <nsipc>
}
  801eaa:	83 c4 14             	add    $0x14,%esp
  801ead:	5b                   	pop    %ebx
  801eae:	5d                   	pop    %ebp
  801eaf:	c3                   	ret    

00801eb0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801eb0:	55                   	push   %ebp
  801eb1:	89 e5                	mov    %esp,%ebp
  801eb3:	53                   	push   %ebx
  801eb4:	83 ec 14             	sub    $0x14,%esp
  801eb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801eba:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebd:	a3 00 50 80 00       	mov    %eax,0x805000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801ec2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ec6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ecd:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  801ed4:	e8 5f ec ff ff       	call   800b38 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801ed9:	89 1d 14 50 80 00    	mov    %ebx,0x805014
	return nsipc(NSREQ_BIND);
  801edf:	b8 02 00 00 00       	mov    $0x2,%eax
  801ee4:	e8 c7 fd ff ff       	call   801cb0 <nsipc>
}
  801ee9:	83 c4 14             	add    $0x14,%esp
  801eec:	5b                   	pop    %ebx
  801eed:	5d                   	pop    %ebp
  801eee:	c3                   	ret    

00801eef <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801eef:	55                   	push   %ebp
  801ef0:	89 e5                	mov    %esp,%ebp
  801ef2:	53                   	push   %ebx
  801ef3:	83 ec 14             	sub    $0x14,%esp
	int r;
	
	nsipcbuf.accept.req_s = s;
  801ef6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801efe:	b8 01 00 00 00       	mov    $0x1,%eax
  801f03:	e8 a8 fd ff ff       	call   801cb0 <nsipc>
  801f08:	89 c3                	mov    %eax,%ebx
  801f0a:	85 c0                	test   %eax,%eax
  801f0c:	78 26                	js     801f34 <nsipc_accept+0x45>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f0e:	a1 10 50 80 00       	mov    0x805010,%eax
  801f13:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f17:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801f1e:	00 
  801f1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f22:	89 04 24             	mov    %eax,(%esp)
  801f25:	e8 0e ec ff ff       	call   800b38 <memmove>
		*addrlen = ret->ret_addrlen;
  801f2a:	a1 10 50 80 00       	mov    0x805010,%eax
  801f2f:	8b 55 10             	mov    0x10(%ebp),%edx
  801f32:	89 02                	mov    %eax,(%edx)
	}
	return r;
}
  801f34:	89 d8                	mov    %ebx,%eax
  801f36:	83 c4 14             	add    $0x14,%esp
  801f39:	5b                   	pop    %ebx
  801f3a:	5d                   	pop    %ebp
  801f3b:	c3                   	ret    

00801f3c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  801f3c:	55                   	push   %ebp
  801f3d:	89 e5                	mov    %esp,%ebp
  801f3f:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  801f42:	8d 45 14             	lea    0x14(%ebp),%eax
  801f45:	89 45 fc             	mov    %eax,-0x4(%ebp)

	// Print the panic message
	if (argv0)
  801f48:	a1 54 60 80 00       	mov    0x806054,%eax
  801f4d:	85 c0                	test   %eax,%eax
  801f4f:	74 10                	je     801f61 <_panic+0x25>
		cprintf("%s: ", argv0);
  801f51:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f55:	c7 04 24 46 2c 80 00 	movl   $0x802c46,(%esp)
  801f5c:	e8 68 e3 ff ff       	call   8002c9 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  801f61:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f64:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f68:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f6f:	a1 04 60 80 00       	mov    0x806004,%eax
  801f74:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f78:	c7 04 24 4b 2c 80 00 	movl   $0x802c4b,(%esp)
  801f7f:	e8 45 e3 ff ff       	call   8002c9 <cprintf>
	vcprintf(fmt, ap);
  801f84:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801f87:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f8b:	8b 45 10             	mov    0x10(%ebp),%eax
  801f8e:	89 04 24             	mov    %eax,(%esp)
  801f91:	e8 d2 e2 ff ff       	call   800268 <vcprintf>
	cprintf("\n");
  801f96:	c7 04 24 d4 27 80 00 	movl   $0x8027d4,(%esp)
  801f9d:	e8 27 e3 ff ff       	call   8002c9 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801fa2:	cc                   	int3   
  801fa3:	eb fd                	jmp    801fa2 <_panic+0x66>
	...

00801fb0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fb0:	55                   	push   %ebp
  801fb1:	89 e5                	mov    %esp,%ebp
  801fb3:	57                   	push   %edi
  801fb4:	56                   	push   %esi
  801fb5:	53                   	push   %ebx
  801fb6:	83 ec 1c             	sub    $0x1c,%esp
  801fb9:	8b 75 08             	mov    0x8(%ebp),%esi
  801fbc:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  801fbf:	e8 39 f1 ff ff       	call   8010fd <sys_getenvid>
  801fc4:	25 ff 03 00 00       	and    $0x3ff,%eax
  801fc9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fcc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fd1:	a3 50 60 80 00       	mov    %eax,0x806050
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  801fd6:	e8 22 f1 ff ff       	call   8010fd <sys_getenvid>
  801fdb:	25 ff 03 00 00       	and    $0x3ff,%eax
  801fe0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fe3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fe8:	a3 50 60 80 00       	mov    %eax,0x806050
		if(env->env_id==to_env){
  801fed:	8b 40 4c             	mov    0x4c(%eax),%eax
  801ff0:	39 f0                	cmp    %esi,%eax
  801ff2:	75 0e                	jne    802002 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  801ff4:	c7 04 24 67 2c 80 00 	movl   $0x802c67,(%esp)
  801ffb:	e8 c9 e2 ff ff       	call   8002c9 <cprintf>
  802000:	eb 5a                	jmp    80205c <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  802002:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802006:	8b 45 10             	mov    0x10(%ebp),%eax
  802009:	89 44 24 08          	mov    %eax,0x8(%esp)
  80200d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802010:	89 44 24 04          	mov    %eax,0x4(%esp)
  802014:	89 34 24             	mov    %esi,(%esp)
  802017:	e8 40 ee ff ff       	call   800e5c <sys_ipc_try_send>
  80201c:	89 c3                	mov    %eax,%ebx
  80201e:	85 c0                	test   %eax,%eax
  802020:	79 25                	jns    802047 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  802022:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802025:	74 2b                	je     802052 <ipc_send+0xa2>
				panic("send error:%e",r);
  802027:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80202b:	c7 44 24 08 83 2c 80 	movl   $0x802c83,0x8(%esp)
  802032:	00 
  802033:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80203a:	00 
  80203b:	c7 04 24 91 2c 80 00 	movl   $0x802c91,(%esp)
  802042:	e8 f5 fe ff ff       	call   801f3c <_panic>
		}
			sys_yield();
  802047:	e8 7d f0 ff ff       	call   8010c9 <sys_yield>
		
	}while(r!=0);
  80204c:	85 db                	test   %ebx,%ebx
  80204e:	75 86                	jne    801fd6 <ipc_send+0x26>
  802050:	eb 0a                	jmp    80205c <ipc_send+0xac>
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
		{	
			if(r!=-E_IPC_NOT_RECV)
				panic("send error:%e",r);
		}
			sys_yield();
  802052:	e8 72 f0 ff ff       	call   8010c9 <sys_yield>
  802057:	e9 7a ff ff ff       	jmp    801fd6 <ipc_send+0x26>
		
	}while(r!=0);
	return;
	//panic("ipc_send not implemented");
}
  80205c:	83 c4 1c             	add    $0x1c,%esp
  80205f:	5b                   	pop    %ebx
  802060:	5e                   	pop    %esi
  802061:	5f                   	pop    %edi
  802062:	5d                   	pop    %ebp
  802063:	c3                   	ret    

00802064 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802064:	55                   	push   %ebp
  802065:	89 e5                	mov    %esp,%ebp
  802067:	57                   	push   %edi
  802068:	56                   	push   %esi
  802069:	53                   	push   %ebx
  80206a:	83 ec 0c             	sub    $0xc,%esp
  80206d:	8b 75 08             	mov    0x8(%ebp),%esi
  802070:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	void *dstva=NULL;
	if(pg)
		dstva=pg;
	env = &envs[ENVX(sys_getenvid())];
  802073:	e8 85 f0 ff ff       	call   8010fd <sys_getenvid>
  802078:	25 ff 03 00 00       	and    $0x3ff,%eax
  80207d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802080:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802085:	a3 50 60 80 00       	mov    %eax,0x806050
	if(from_env_store&&(env->env_id==*from_env_store))
  80208a:	85 f6                	test   %esi,%esi
  80208c:	74 29                	je     8020b7 <ipc_recv+0x53>
  80208e:	8b 40 4c             	mov    0x4c(%eax),%eax
  802091:	3b 06                	cmp    (%esi),%eax
  802093:	75 22                	jne    8020b7 <ipc_recv+0x53>
	{
		*from_env_store=0;
  802095:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  80209b:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("send:the reciver is sender\n");
  8020a1:	c7 04 24 67 2c 80 00 	movl   $0x802c67,(%esp)
  8020a8:	e8 1c e2 ff ff       	call   8002c9 <cprintf>
  8020ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020b2:	e9 8a 00 00 00       	jmp    802141 <ipc_recv+0xdd>
		return 0;
	}
	env = &envs[ENVX(sys_getenvid())];
  8020b7:	e8 41 f0 ff ff       	call   8010fd <sys_getenvid>
  8020bc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8020c1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020c4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020c9:	a3 50 60 80 00       	mov    %eax,0x806050
	if((r=sys_ipc_recv(dstva))<0)
  8020ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d1:	89 04 24             	mov    %eax,(%esp)
  8020d4:	e8 26 ed ff ff       	call   800dff <sys_ipc_recv>
  8020d9:	89 c3                	mov    %eax,%ebx
  8020db:	85 c0                	test   %eax,%eax
  8020dd:	79 1a                	jns    8020f9 <ipc_recv+0x95>
	{
		*from_env_store=0;
  8020df:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  8020e5:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("reciver failed\n");
  8020eb:	c7 04 24 9b 2c 80 00 	movl   $0x802c9b,(%esp)
  8020f2:	e8 d2 e1 ff ff       	call   8002c9 <cprintf>
  8020f7:	eb 48                	jmp    802141 <ipc_recv+0xdd>
		return r;
	}
	else{//接收成功
		env = &envs[ENVX(sys_getenvid())];
  8020f9:	e8 ff ef ff ff       	call   8010fd <sys_getenvid>
  8020fe:	25 ff 03 00 00       	and    $0x3ff,%eax
  802103:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802106:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80210b:	a3 50 60 80 00       	mov    %eax,0x806050
		if(from_env_store)
  802110:	85 f6                	test   %esi,%esi
  802112:	74 05                	je     802119 <ipc_recv+0xb5>
			*from_env_store=env->env_ipc_from;	
  802114:	8b 40 74             	mov    0x74(%eax),%eax
  802117:	89 06                	mov    %eax,(%esi)
		if(perm_store)
  802119:	85 ff                	test   %edi,%edi
  80211b:	74 0a                	je     802127 <ipc_recv+0xc3>
			*perm_store=env->env_ipc_perm;
  80211d:	a1 50 60 80 00       	mov    0x806050,%eax
  802122:	8b 40 78             	mov    0x78(%eax),%eax
  802125:	89 07                	mov    %eax,(%edi)
		env = &envs[ENVX(sys_getenvid())];
  802127:	e8 d1 ef ff ff       	call   8010fd <sys_getenvid>
  80212c:	25 ff 03 00 00       	and    $0x3ff,%eax
  802131:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802134:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802139:	a3 50 60 80 00       	mov    %eax,0x806050
		return env->env_ipc_value;
  80213e:	8b 58 70             	mov    0x70(%eax),%ebx
	}
	//panic("ipc_recv not implemented");
	return 0;
}
  802141:	89 d8                	mov    %ebx,%eax
  802143:	83 c4 0c             	add    $0xc,%esp
  802146:	5b                   	pop    %ebx
  802147:	5e                   	pop    %esi
  802148:	5f                   	pop    %edi
  802149:	5d                   	pop    %ebp
  80214a:	c3                   	ret    
  80214b:	00 00                	add    %al,(%eax)
  80214d:	00 00                	add    %al,(%eax)
	...

00802150 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  802150:	55                   	push   %ebp
  802151:	89 e5                	mov    %esp,%ebp
  802153:	57                   	push   %edi
  802154:	56                   	push   %esi
  802155:	53                   	push   %ebx
  802156:	83 ec 18             	sub    $0x18,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  802159:	8b 45 08             	mov    0x8(%ebp),%eax
  80215c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  80215f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802162:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802165:	be 00 00 00 00       	mov    $0x0,%esi
  80216a:	bf 40 60 80 00       	mov    $0x806040,%edi
  80216f:	c6 45 e3 00          	movb   $0x0,-0x1d(%ebp)
  802173:	eb 02                	jmp    802177 <inet_ntoa+0x27>
  for(n = 0; n < 4; n++) {
  802175:	89 c6                	mov    %eax,%esi
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  802177:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80217a:	0f b6 0a             	movzbl (%edx),%ecx
      *ap /= (u8_t)10;
  80217d:	b8 cd ff ff ff       	mov    $0xffffffcd,%eax
  802182:	f6 e1                	mul    %cl
  802184:	89 c2                	mov    %eax,%edx
  802186:	66 c1 ea 08          	shr    $0x8,%dx
  80218a:	c0 ea 03             	shr    $0x3,%dl
  80218d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  802190:	88 10                	mov    %dl,(%eax)
      inv[i++] = '0' + rem;
  802192:	89 f0                	mov    %esi,%eax
  802194:	0f b6 d8             	movzbl %al,%ebx
  802197:	8d 04 92             	lea    (%edx,%edx,4),%eax
  80219a:	01 c0                	add    %eax,%eax
  80219c:	28 c1                	sub    %al,%cl
  80219e:	83 c1 30             	add    $0x30,%ecx
  8021a1:	88 4c 1d ed          	mov    %cl,-0x13(%ebp,%ebx,1)
  8021a5:	8d 46 01             	lea    0x1(%esi),%eax
    } while(*ap);
  8021a8:	84 d2                	test   %dl,%dl
  8021aa:	75 c9                	jne    802175 <inet_ntoa+0x25>
    while(i--)
  8021ac:	89 f1                	mov    %esi,%ecx
  8021ae:	80 f9 ff             	cmp    $0xff,%cl
  8021b1:	74 20                	je     8021d3 <inet_ntoa+0x83>
  8021b3:	89 fa                	mov    %edi,%edx
      *rp++ = inv[i];
  8021b5:	0f b6 c1             	movzbl %cl,%eax
  8021b8:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  8021bd:	88 02                	mov    %al,(%edx)
  8021bf:	83 c2 01             	add    $0x1,%edx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  8021c2:	83 e9 01             	sub    $0x1,%ecx
  8021c5:	80 f9 ff             	cmp    $0xff,%cl
  8021c8:	75 eb                	jne    8021b5 <inet_ntoa+0x65>
  8021ca:	89 f2                	mov    %esi,%edx
  8021cc:	0f b6 c2             	movzbl %dl,%eax
  8021cf:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
      *rp++ = inv[i];
    *rp++ = '.';
  8021d3:	c6 07 2e             	movb   $0x2e,(%edi)
  8021d6:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  8021d9:	80 45 e3 01          	addb   $0x1,-0x1d(%ebp)
  8021dd:	80 7d e3 03          	cmpb   $0x3,-0x1d(%ebp)
  8021e1:	77 0b                	ja     8021ee <inet_ntoa+0x9e>
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  8021e3:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  8021e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8021ec:	eb 87                	jmp    802175 <inet_ntoa+0x25>
  }
  *--rp = 0;
  8021ee:	c6 47 ff 00          	movb   $0x0,-0x1(%edi)
  return str;
}
  8021f2:	b8 40 60 80 00       	mov    $0x806040,%eax
  8021f7:	83 c4 18             	add    $0x18,%esp
  8021fa:	5b                   	pop    %ebx
  8021fb:	5e                   	pop    %esi
  8021fc:	5f                   	pop    %edi
  8021fd:	5d                   	pop    %ebp
  8021fe:	c3                   	ret    

008021ff <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  8021ff:	55                   	push   %ebp
  802200:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  802202:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  802206:	89 c2                	mov    %eax,%edx
  802208:	c1 ea 08             	shr    $0x8,%edx
  80220b:	c1 e0 08             	shl    $0x8,%eax
  80220e:	09 d0                	or     %edx,%eax
  802210:	0f b7 c0             	movzwl %ax,%eax
}
  802213:	5d                   	pop    %ebp
  802214:	c3                   	ret    

00802215 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  802215:	55                   	push   %ebp
  802216:	89 e5                	mov    %esp,%ebp
  802218:	83 ec 04             	sub    $0x4,%esp
  return htons(n);
  80221b:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80221f:	89 04 24             	mov    %eax,(%esp)
  802222:	e8 d8 ff ff ff       	call   8021ff <htons>
  802227:	0f b7 c0             	movzwl %ax,%eax
}
  80222a:	c9                   	leave  
  80222b:	c3                   	ret    

0080222c <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  80222c:	55                   	push   %ebp
  80222d:	89 e5                	mov    %esp,%ebp
  80222f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802232:	89 c8                	mov    %ecx,%eax
  802234:	25 00 ff 00 00       	and    $0xff00,%eax
  802239:	c1 e0 08             	shl    $0x8,%eax
  80223c:	89 ca                	mov    %ecx,%edx
  80223e:	c1 e2 18             	shl    $0x18,%edx
  802241:	09 d0                	or     %edx,%eax
  802243:	89 ca                	mov    %ecx,%edx
  802245:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  80224b:	c1 ea 08             	shr    $0x8,%edx
  80224e:	09 d0                	or     %edx,%eax
  802250:	c1 e9 18             	shr    $0x18,%ecx
  802253:	09 c8                	or     %ecx,%eax
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  802255:	5d                   	pop    %ebp
  802256:	c3                   	ret    

00802257 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  802257:	55                   	push   %ebp
  802258:	89 e5                	mov    %esp,%ebp
  80225a:	57                   	push   %edi
  80225b:	56                   	push   %esi
  80225c:	53                   	push   %ebx
  80225d:	83 ec 24             	sub    $0x24,%esp
  802260:	8b 55 08             	mov    0x8(%ebp),%edx
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  802263:	0f be 32             	movsbl (%edx),%esi
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  802266:	8d 46 d0             	lea    -0x30(%esi),%eax
  802269:	3c 09                	cmp    $0x9,%al
  80226b:	0f 87 c0 01 00 00    	ja     802431 <inet_aton+0x1da>
  802271:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802274:	89 45 e0             	mov    %eax,-0x20(%ebp)
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  802277:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80227a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     */
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
  80227d:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
  802284:	83 fe 30             	cmp    $0x30,%esi
  802287:	75 24                	jne    8022ad <inet_aton+0x56>
      c = *++cp;
  802289:	83 c2 01             	add    $0x1,%edx
  80228c:	0f be 32             	movsbl (%edx),%esi
      if (c == 'x' || c == 'X') {
  80228f:	83 fe 78             	cmp    $0x78,%esi
  802292:	74 0c                	je     8022a0 <inet_aton+0x49>
  802294:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  80229b:	83 fe 58             	cmp    $0x58,%esi
  80229e:	75 0d                	jne    8022ad <inet_aton+0x56>
        base = 16;
        c = *++cp;
  8022a0:	83 c2 01             	add    $0x1,%edx
  8022a3:	0f be 32             	movsbl (%edx),%esi
  8022a6:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
  8022ad:	8d 5a 01             	lea    0x1(%edx),%ebx
  8022b0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8022b7:	eb 03                	jmp    8022bc <inet_aton+0x65>
  8022b9:	83 c3 01             	add    $0x1,%ebx
  8022bc:	8d 7b ff             	lea    -0x1(%ebx),%edi
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  8022bf:	89 f1                	mov    %esi,%ecx
  8022c1:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8022c4:	3c 09                	cmp    $0x9,%al
  8022c6:	77 13                	ja     8022db <inet_aton+0x84>
        val = (val * base) + (int)(c - '0');
  8022c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8022cb:	0f af 45 d8          	imul   -0x28(%ebp),%eax
  8022cf:	8d 74 06 d0          	lea    -0x30(%esi,%eax,1),%esi
  8022d3:	89 75 d8             	mov    %esi,-0x28(%ebp)
        c = *++cp;
  8022d6:	0f be 33             	movsbl (%ebx),%esi
  8022d9:	eb de                	jmp    8022b9 <inet_aton+0x62>
      } else if (base == 16 && isxdigit(c)) {
  8022db:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  8022df:	75 2c                	jne    80230d <inet_aton+0xb6>
  8022e1:	8d 51 9f             	lea    -0x61(%ecx),%edx
  8022e4:	80 fa 05             	cmp    $0x5,%dl
  8022e7:	76 07                	jbe    8022f0 <inet_aton+0x99>
  8022e9:	8d 41 bf             	lea    -0x41(%ecx),%eax
  8022ec:	3c 05                	cmp    $0x5,%al
  8022ee:	77 1d                	ja     80230d <inet_aton+0xb6>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  8022f0:	80 fa 1a             	cmp    $0x1a,%dl
  8022f3:	19 c0                	sbb    %eax,%eax
  8022f5:	83 e0 20             	and    $0x20,%eax
  8022f8:	29 c6                	sub    %eax,%esi
  8022fa:	8d 46 c9             	lea    -0x37(%esi),%eax
  8022fd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  802300:	c1 e2 04             	shl    $0x4,%edx
  802303:	09 d0                	or     %edx,%eax
  802305:	89 45 d8             	mov    %eax,-0x28(%ebp)
        c = *++cp;
  802308:	0f be 33             	movsbl (%ebx),%esi
  80230b:	eb ac                	jmp    8022b9 <inet_aton+0x62>
      } else
        break;
    }
    if (c == '.') {
  80230d:	83 fe 2e             	cmp    $0x2e,%esi
  802310:	75 2c                	jne    80233e <inet_aton+0xe7>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  802312:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802315:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  802318:	0f 86 13 01 00 00    	jbe    802431 <inet_aton+0x1da>
        return (0);
      *pp++ = val;
  80231e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802321:	89 02                	mov    %eax,(%edx)
      c = *++cp;
  802323:	8d 57 01             	lea    0x1(%edi),%edx
  802326:	0f be 77 01          	movsbl 0x1(%edi),%esi
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  80232a:	8d 46 d0             	lea    -0x30(%esi),%eax
  80232d:	3c 09                	cmp    $0x9,%al
  80232f:	0f 87 fc 00 00 00    	ja     802431 <inet_aton+0x1da>
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
      *pp++ = val;
  802335:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
  802339:	e9 3f ff ff ff       	jmp    80227d <inet_aton+0x26>
  80233e:	8b 5d d8             	mov    -0x28(%ebp),%ebx
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  802341:	85 f6                	test   %esi,%esi
  802343:	74 36                	je     80237b <inet_aton+0x124>
  802345:	80 f9 1f             	cmp    $0x1f,%cl
  802348:	0f 86 e3 00 00 00    	jbe    802431 <inet_aton+0x1da>
  80234e:	89 f2                	mov    %esi,%edx
  802350:	84 d2                	test   %dl,%dl
  802352:	0f 88 d9 00 00 00    	js     802431 <inet_aton+0x1da>
  802358:	83 fe 20             	cmp    $0x20,%esi
  80235b:	74 1e                	je     80237b <inet_aton+0x124>
  80235d:	83 fe 0c             	cmp    $0xc,%esi
  802360:	74 19                	je     80237b <inet_aton+0x124>
  802362:	83 fe 0a             	cmp    $0xa,%esi
  802365:	74 14                	je     80237b <inet_aton+0x124>
  802367:	83 fe 0d             	cmp    $0xd,%esi
  80236a:	74 0f                	je     80237b <inet_aton+0x124>
  80236c:	83 fe 09             	cmp    $0x9,%esi
  80236f:	90                   	nop    
  802370:	74 09                	je     80237b <inet_aton+0x124>
  802372:	83 fe 0b             	cmp    $0xb,%esi
  802375:	0f 85 b6 00 00 00    	jne    802431 <inet_aton+0x1da>
    return (0);
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  80237b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  switch (n) {
  80237e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802381:	29 c2                	sub    %eax,%edx
  802383:	89 d0                	mov    %edx,%eax
  802385:	c1 f8 02             	sar    $0x2,%eax
  802388:	83 c0 01             	add    $0x1,%eax
  80238b:	83 f8 02             	cmp    $0x2,%eax
  80238e:	74 24                	je     8023b4 <inet_aton+0x15d>
  802390:	83 f8 02             	cmp    $0x2,%eax
  802393:	7f 0d                	jg     8023a2 <inet_aton+0x14b>
  802395:	85 c0                	test   %eax,%eax
  802397:	0f 84 94 00 00 00    	je     802431 <inet_aton+0x1da>
  80239d:	8d 76 00             	lea    0x0(%esi),%esi
  8023a0:	eb 6d                	jmp    80240f <inet_aton+0x1b8>
  8023a2:	83 f8 03             	cmp    $0x3,%eax
  8023a5:	74 28                	je     8023cf <inet_aton+0x178>
  8023a7:	83 f8 04             	cmp    $0x4,%eax
  8023aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023b0:	75 5d                	jne    80240f <inet_aton+0x1b8>
  8023b2:	eb 38                	jmp    8023ec <inet_aton+0x195>

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  8023b4:	81 fb ff ff ff 00    	cmp    $0xffffff,%ebx
  8023ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023c0:	77 6f                	ja     802431 <inet_aton+0x1da>
      return (0);
    val |= parts[0] << 24;
  8023c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023c5:	c1 e0 18             	shl    $0x18,%eax
  8023c8:	09 c3                	or     %eax,%ebx
  8023ca:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8023cd:	eb 40                	jmp    80240f <inet_aton+0x1b8>
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  8023cf:	81 fb ff ff 00 00    	cmp    $0xffff,%ebx
  8023d5:	77 5a                	ja     802431 <inet_aton+0x1da>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  8023d7:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8023da:	c1 e2 10             	shl    $0x10,%edx
  8023dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023e0:	c1 e0 18             	shl    $0x18,%eax
  8023e3:	09 c2                	or     %eax,%edx
  8023e5:	09 da                	or     %ebx,%edx
  8023e7:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8023ea:	eb 23                	jmp    80240f <inet_aton+0x1b8>
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  8023ec:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
  8023f2:	77 3d                	ja     802431 <inet_aton+0x1da>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  8023f4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8023f7:	c1 e0 10             	shl    $0x10,%eax
  8023fa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8023fd:	c1 e2 18             	shl    $0x18,%edx
  802400:	09 d0                	or     %edx,%eax
  802402:	8b 55 ec             	mov    -0x14(%ebp),%edx
  802405:	c1 e2 08             	shl    $0x8,%edx
  802408:	09 d0                	or     %edx,%eax
  80240a:	09 d8                	or     %ebx,%eax
  80240c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    break;
  }
  if (addr)
  80240f:	b8 01 00 00 00       	mov    $0x1,%eax
  802414:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802418:	74 1c                	je     802436 <inet_aton+0x1df>
    addr->s_addr = htonl(val);
  80241a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80241d:	89 04 24             	mov    %eax,(%esp)
  802420:	e8 07 fe ff ff       	call   80222c <htonl>
  802425:	8b 55 0c             	mov    0xc(%ebp),%edx
  802428:	89 02                	mov    %eax,(%edx)
  80242a:	b8 01 00 00 00       	mov    $0x1,%eax
  80242f:	eb 05                	jmp    802436 <inet_aton+0x1df>
  802431:	b8 00 00 00 00       	mov    $0x0,%eax
  return (1);
}
  802436:	83 c4 24             	add    $0x24,%esp
  802439:	5b                   	pop    %ebx
  80243a:	5e                   	pop    %esi
  80243b:	5f                   	pop    %edi
  80243c:	5d                   	pop    %ebp
  80243d:	c3                   	ret    

0080243e <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  80243e:	55                   	push   %ebp
  80243f:	89 e5                	mov    %esp,%ebp
  802441:	83 ec 18             	sub    $0x18,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  802444:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802447:	89 44 24 04          	mov    %eax,0x4(%esp)
  80244b:	8b 45 08             	mov    0x8(%ebp),%eax
  80244e:	89 04 24             	mov    %eax,(%esp)
  802451:	e8 01 fe ff ff       	call   802257 <inet_aton>
  802456:	83 f8 01             	cmp    $0x1,%eax
  802459:	19 c0                	sbb    %eax,%eax
  80245b:	0b 45 fc             	or     -0x4(%ebp),%eax
    return (val.s_addr);
  }
  return (INADDR_NONE);
}
  80245e:	c9                   	leave  
  80245f:	c3                   	ret    

00802460 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  802460:	55                   	push   %ebp
  802461:	89 e5                	mov    %esp,%ebp
  802463:	83 ec 04             	sub    $0x4,%esp
  return htonl(n);
  802466:	8b 45 08             	mov    0x8(%ebp),%eax
  802469:	89 04 24             	mov    %eax,(%esp)
  80246c:	e8 bb fd ff ff       	call   80222c <htonl>
}
  802471:	c9                   	leave  
  802472:	c3                   	ret    
	...

00802480 <__udivdi3>:
  802480:	55                   	push   %ebp
  802481:	89 e5                	mov    %esp,%ebp
  802483:	57                   	push   %edi
  802484:	56                   	push   %esi
  802485:	83 ec 18             	sub    $0x18,%esp
  802488:	8b 45 10             	mov    0x10(%ebp),%eax
  80248b:	8b 55 14             	mov    0x14(%ebp),%edx
  80248e:	8b 75 0c             	mov    0xc(%ebp),%esi
  802491:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802494:	89 c1                	mov    %eax,%ecx
  802496:	8b 45 08             	mov    0x8(%ebp),%eax
  802499:	85 d2                	test   %edx,%edx
  80249b:	89 d7                	mov    %edx,%edi
  80249d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8024a0:	75 1e                	jne    8024c0 <__udivdi3+0x40>
  8024a2:	39 f1                	cmp    %esi,%ecx
  8024a4:	0f 86 8d 00 00 00    	jbe    802537 <__udivdi3+0xb7>
  8024aa:	89 f2                	mov    %esi,%edx
  8024ac:	31 f6                	xor    %esi,%esi
  8024ae:	f7 f1                	div    %ecx
  8024b0:	89 c1                	mov    %eax,%ecx
  8024b2:	89 c8                	mov    %ecx,%eax
  8024b4:	89 f2                	mov    %esi,%edx
  8024b6:	83 c4 18             	add    $0x18,%esp
  8024b9:	5e                   	pop    %esi
  8024ba:	5f                   	pop    %edi
  8024bb:	5d                   	pop    %ebp
  8024bc:	c3                   	ret    
  8024bd:	8d 76 00             	lea    0x0(%esi),%esi
  8024c0:	39 f2                	cmp    %esi,%edx
  8024c2:	0f 87 a8 00 00 00    	ja     802570 <__udivdi3+0xf0>
  8024c8:	0f bd c2             	bsr    %edx,%eax
  8024cb:	83 f0 1f             	xor    $0x1f,%eax
  8024ce:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8024d1:	0f 84 89 00 00 00    	je     802560 <__udivdi3+0xe0>
  8024d7:	b8 20 00 00 00       	mov    $0x20,%eax
  8024dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8024df:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8024e2:	89 c1                	mov    %eax,%ecx
  8024e4:	d3 ea                	shr    %cl,%edx
  8024e6:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  8024ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8024ed:	89 f8                	mov    %edi,%eax
  8024ef:	8b 7d f4             	mov    -0xc(%ebp),%edi
  8024f2:	d3 e0                	shl    %cl,%eax
  8024f4:	09 c2                	or     %eax,%edx
  8024f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8024f9:	d3 e7                	shl    %cl,%edi
  8024fb:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8024ff:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802502:	89 f2                	mov    %esi,%edx
  802504:	d3 e8                	shr    %cl,%eax
  802506:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  80250a:	d3 e2                	shl    %cl,%edx
  80250c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802510:	09 d0                	or     %edx,%eax
  802512:	d3 ee                	shr    %cl,%esi
  802514:	89 f2                	mov    %esi,%edx
  802516:	f7 75 e4             	divl   -0x1c(%ebp)
  802519:	89 d1                	mov    %edx,%ecx
  80251b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80251e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802521:	f7 e7                	mul    %edi
  802523:	39 d1                	cmp    %edx,%ecx
  802525:	89 c6                	mov    %eax,%esi
  802527:	72 70                	jb     802599 <__udivdi3+0x119>
  802529:	39 ca                	cmp    %ecx,%edx
  80252b:	74 5f                	je     80258c <__udivdi3+0x10c>
  80252d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802530:	31 f6                	xor    %esi,%esi
  802532:	e9 7b ff ff ff       	jmp    8024b2 <__udivdi3+0x32>
  802537:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80253a:	85 c0                	test   %eax,%eax
  80253c:	75 0c                	jne    80254a <__udivdi3+0xca>
  80253e:	b8 01 00 00 00       	mov    $0x1,%eax
  802543:	31 d2                	xor    %edx,%edx
  802545:	f7 75 f4             	divl   -0xc(%ebp)
  802548:	89 c1                	mov    %eax,%ecx
  80254a:	89 f0                	mov    %esi,%eax
  80254c:	89 fa                	mov    %edi,%edx
  80254e:	f7 f1                	div    %ecx
  802550:	89 c6                	mov    %eax,%esi
  802552:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802555:	f7 f1                	div    %ecx
  802557:	89 c1                	mov    %eax,%ecx
  802559:	e9 54 ff ff ff       	jmp    8024b2 <__udivdi3+0x32>
  80255e:	66 90                	xchg   %ax,%ax
  802560:	39 d6                	cmp    %edx,%esi
  802562:	77 1c                	ja     802580 <__udivdi3+0x100>
  802564:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802567:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  80256a:	73 14                	jae    802580 <__udivdi3+0x100>
  80256c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802570:	31 c9                	xor    %ecx,%ecx
  802572:	31 f6                	xor    %esi,%esi
  802574:	e9 39 ff ff ff       	jmp    8024b2 <__udivdi3+0x32>
  802579:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  802580:	b9 01 00 00 00       	mov    $0x1,%ecx
  802585:	31 f6                	xor    %esi,%esi
  802587:	e9 26 ff ff ff       	jmp    8024b2 <__udivdi3+0x32>
  80258c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80258f:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  802593:	d3 e0                	shl    %cl,%eax
  802595:	39 c6                	cmp    %eax,%esi
  802597:	76 94                	jbe    80252d <__udivdi3+0xad>
  802599:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80259c:	31 f6                	xor    %esi,%esi
  80259e:	83 e9 01             	sub    $0x1,%ecx
  8025a1:	e9 0c ff ff ff       	jmp    8024b2 <__udivdi3+0x32>
	...

008025b0 <__umoddi3>:
  8025b0:	55                   	push   %ebp
  8025b1:	89 e5                	mov    %esp,%ebp
  8025b3:	57                   	push   %edi
  8025b4:	56                   	push   %esi
  8025b5:	83 ec 30             	sub    $0x30,%esp
  8025b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8025bb:	8b 55 14             	mov    0x14(%ebp),%edx
  8025be:	8b 75 08             	mov    0x8(%ebp),%esi
  8025c1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8025c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8025c7:	89 c1                	mov    %eax,%ecx
  8025c9:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8025cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8025cf:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8025d6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8025dd:	89 fa                	mov    %edi,%edx
  8025df:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8025e2:	85 c0                	test   %eax,%eax
  8025e4:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8025e7:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8025ea:	75 14                	jne    802600 <__umoddi3+0x50>
  8025ec:	39 f9                	cmp    %edi,%ecx
  8025ee:	76 60                	jbe    802650 <__umoddi3+0xa0>
  8025f0:	89 f0                	mov    %esi,%eax
  8025f2:	f7 f1                	div    %ecx
  8025f4:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8025f7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8025fe:	eb 10                	jmp    802610 <__umoddi3+0x60>
  802600:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802603:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  802606:	76 18                	jbe    802620 <__umoddi3+0x70>
  802608:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80260b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80260e:	66 90                	xchg   %ax,%ax
  802610:	8b 45 d0             	mov    -0x30(%ebp),%eax
  802613:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  802616:	83 c4 30             	add    $0x30,%esp
  802619:	5e                   	pop    %esi
  80261a:	5f                   	pop    %edi
  80261b:	5d                   	pop    %ebp
  80261c:	c3                   	ret    
  80261d:	8d 76 00             	lea    0x0(%esi),%esi
  802620:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
  802624:	83 f0 1f             	xor    $0x1f,%eax
  802627:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80262a:	75 46                	jne    802672 <__umoddi3+0xc2>
  80262c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80262f:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  802632:	0f 87 c9 00 00 00    	ja     802701 <__umoddi3+0x151>
  802638:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  80263b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80263e:	0f 83 bd 00 00 00    	jae    802701 <__umoddi3+0x151>
  802644:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802647:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80264a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80264d:	eb c1                	jmp    802610 <__umoddi3+0x60>
  80264f:	90                   	nop    
  802650:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802653:	85 c0                	test   %eax,%eax
  802655:	75 0c                	jne    802663 <__umoddi3+0xb3>
  802657:	b8 01 00 00 00       	mov    $0x1,%eax
  80265c:	31 d2                	xor    %edx,%edx
  80265e:	f7 75 ec             	divl   -0x14(%ebp)
  802661:	89 c1                	mov    %eax,%ecx
  802663:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802666:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802669:	f7 f1                	div    %ecx
  80266b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80266e:	f7 f1                	div    %ecx
  802670:	eb 82                	jmp    8025f4 <__umoddi3+0x44>
  802672:	b8 20 00 00 00       	mov    $0x20,%eax
  802677:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80267a:	2b 45 d8             	sub    -0x28(%ebp),%eax
  80267d:	8b 75 ec             	mov    -0x14(%ebp),%esi
  802680:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802683:	89 c1                	mov    %eax,%ecx
  802685:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802688:	d3 ea                	shr    %cl,%edx
  80268a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80268d:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  802691:	d3 e0                	shl    %cl,%eax
  802693:	09 c2                	or     %eax,%edx
  802695:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802698:	d3 e6                	shl    %cl,%esi
  80269a:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  80269e:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8026a1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8026a4:	d3 e8                	shr    %cl,%eax
  8026a6:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8026aa:	d3 e2                	shl    %cl,%edx
  8026ac:	09 d0                	or     %edx,%eax
  8026ae:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8026b1:	d3 e7                	shl    %cl,%edi
  8026b3:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  8026b7:	d3 ea                	shr    %cl,%edx
  8026b9:	f7 75 f4             	divl   -0xc(%ebp)
  8026bc:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8026bf:	f7 e6                	mul    %esi
  8026c1:	39 55 cc             	cmp    %edx,-0x34(%ebp)
  8026c4:	72 53                	jb     802719 <__umoddi3+0x169>
  8026c6:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  8026c9:	74 4a                	je     802715 <__umoddi3+0x165>
  8026cb:	90                   	nop    
  8026cc:	8d 74 26 00          	lea    0x0(%esi),%esi
  8026d0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8026d3:	29 c7                	sub    %eax,%edi
  8026d5:	19 d1                	sbb    %edx,%ecx
  8026d7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8026da:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8026de:	89 fa                	mov    %edi,%edx
  8026e0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8026e3:	d3 ea                	shr    %cl,%edx
  8026e5:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  8026e9:	d3 e0                	shl    %cl,%eax
  8026eb:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8026ef:	09 c2                	or     %eax,%edx
  8026f1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8026f4:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8026f7:	d3 e8                	shr    %cl,%eax
  8026f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8026fc:	e9 0f ff ff ff       	jmp    802610 <__umoddi3+0x60>
  802701:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802704:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802707:	2b 45 ec             	sub    -0x14(%ebp),%eax
  80270a:	1b 55 e8             	sbb    -0x18(%ebp),%edx
  80270d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802710:	e9 2f ff ff ff       	jmp    802644 <__umoddi3+0x94>
  802715:	39 f8                	cmp    %edi,%eax
  802717:	76 b7                	jbe    8026d0 <__umoddi3+0x120>
  802719:	29 f0                	sub    %esi,%eax
  80271b:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  80271e:	eb b0                	jmp    8026d0 <__umoddi3+0x120>
