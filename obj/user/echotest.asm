
obj/user/echotest:     file format elf32-i386

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
  80003e:	c7 04 24 60 27 80 00 	movl   $0x802760,(%esp)
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
	int sock;
	struct sockaddr_in echoserver;
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;
	
	cprintf("Connecting to:\n");
  80005a:	c7 04 24 64 27 80 00 	movl   $0x802764,(%esp)
  800061:	e8 63 02 00 00       	call   8002c9 <cprintf>
	cprintf("\tip address %s = %x\n", IPADDR, inet_addr(IPADDR));
  800066:	c7 04 24 74 27 80 00 	movl   $0x802774,(%esp)
  80006d:	e8 e6 23 00 00       	call   802458 <inet_addr>
  800072:	89 44 24 08          	mov    %eax,0x8(%esp)
  800076:	c7 44 24 04 74 27 80 	movl   $0x802774,0x4(%esp)
  80007d:	00 
  80007e:	c7 04 24 7e 27 80 00 	movl   $0x80277e,(%esp)
  800085:	e8 3f 02 00 00       	call   8002c9 <cprintf>
	
	// Create the TCP socket
	if ((sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  80008a:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800099:	00 
  80009a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8000a1:	e8 df 1a 00 00       	call   801b85 <socket>
  8000a6:	89 45 c0             	mov    %eax,0xffffffc0(%ebp)
  8000a9:	85 c0                	test   %eax,%eax
  8000ab:	79 0a                	jns    8000b7 <umain+0x66>
		die("Failed to create socket");
  8000ad:	b8 93 27 80 00       	mov    $0x802793,%eax
  8000b2:	e8 7d ff ff ff       	call   800034 <die>
	
	cprintf("opened socket\n");
  8000b7:	c7 04 24 ab 27 80 00 	movl   $0x8027ab,(%esp)
  8000be:	e8 06 02 00 00       	call   8002c9 <cprintf>
	
	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  8000c3:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  8000ca:	00 
  8000cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000d2:	00 
  8000d3:	8d 5d e4             	lea    0xffffffe4(%ebp),%ebx
  8000d6:	89 1c 24             	mov    %ebx,(%esp)
  8000d9:	e8 23 0a 00 00       	call   800b01 <memset>
	echoserver.sin_family = AF_INET;                  // Internet/IP
  8000de:	c6 45 e5 02          	movb   $0x2,0xffffffe5(%ebp)
	echoserver.sin_addr.s_addr = inet_addr(IPADDR);   // IP address
  8000e2:	c7 04 24 74 27 80 00 	movl   $0x802774,(%esp)
  8000e9:	e8 6a 23 00 00       	call   802458 <inet_addr>
  8000ee:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
	echoserver.sin_port = htons(PORT);		  // server port
  8000f1:	c7 04 24 10 27 00 00 	movl   $0x2710,(%esp)
  8000f8:	e8 42 21 00 00       	call   80223f <htons>
  8000fd:	66 89 45 e6          	mov    %ax,0xffffffe6(%ebp)
	
	cprintf("trying to connect to server\n");
  800101:	c7 04 24 ba 27 80 00 	movl   $0x8027ba,(%esp)
  800108:	e8 bc 01 00 00       	call   8002c9 <cprintf>
	
	// Establish connection
	if (connect(sock, (struct sockaddr *) &echoserver, sizeof(echoserver)) < 0)
  80010d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  800114:	00 
  800115:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800119:	8b 45 c0             	mov    0xffffffc0(%ebp),%eax
  80011c:	89 04 24             	mov    %eax,(%esp)
  80011f:	e8 ea 1a 00 00       	call   801c0e <connect>
  800124:	85 c0                	test   %eax,%eax
  800126:	79 0a                	jns    800132 <umain+0xe1>
		die("Failed to connect with server");
  800128:	b8 d7 27 80 00       	mov    $0x8027d7,%eax
  80012d:	e8 02 ff ff ff       	call   800034 <die>
	
	cprintf("connected to server\n");
  800132:	c7 04 24 f5 27 80 00 	movl   $0x8027f5,(%esp)
  800139:	e8 8b 01 00 00       	call   8002c9 <cprintf>
	
	// Send the word to the server
	echolen = strlen(msg);
  80013e:	a1 00 60 80 00       	mov    0x806000,%eax
  800143:	89 04 24             	mov    %eax,(%esp)
  800146:	e8 b5 07 00 00       	call   800900 <strlen>
  80014b:	89 c7                	mov    %eax,%edi
  80014d:	89 c3                	mov    %eax,%ebx
	if (write(sock, msg, echolen) != echolen)
  80014f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800153:	a1 00 60 80 00       	mov    0x806000,%eax
  800158:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015c:	8b 45 c0             	mov    0xffffffc0(%ebp),%eax
  80015f:	89 04 24             	mov    %eax,(%esp)
  800162:	e8 9b 12 00 00       	call   801402 <write>
  800167:	39 f8                	cmp    %edi,%eax
  800169:	74 0a                	je     800175 <umain+0x124>
		die("Mismatch in number of sent bytes");
  80016b:	b8 24 28 80 00       	mov    $0x802824,%eax
  800170:	e8 bf fe ff ff       	call   800034 <die>
	
	// Receive the word back from the server
	cprintf("Received: \n");
  800175:	c7 04 24 0a 28 80 00 	movl   $0x80280a,(%esp)
  80017c:	e8 48 01 00 00       	call   8002c9 <cprintf>
	while (received < echolen) {
  800181:	85 db                	test   %ebx,%ebx
  800183:	74 45                	je     8001ca <umain+0x179>
  800185:	be 00 00 00 00       	mov    $0x0,%esi
		int bytes = 0;
		if ((bytes = read(sock, buffer, BUFFSIZE-1)) < 1) {
  80018a:	c7 44 24 08 1f 00 00 	movl   $0x1f,0x8(%esp)
  800191:	00 
  800192:	8d 45 c4             	lea    0xffffffc4(%ebp),%eax
  800195:	89 44 24 04          	mov    %eax,0x4(%esp)
  800199:	8b 45 c0             	mov    0xffffffc0(%ebp),%eax
  80019c:	89 04 24             	mov    %eax,(%esp)
  80019f:	e8 e9 12 00 00       	call   80148d <read>
  8001a4:	89 c3                	mov    %eax,%ebx
  8001a6:	85 c0                	test   %eax,%eax
  8001a8:	7f 0a                	jg     8001b4 <umain+0x163>
			die("Failed to receive bytes from server");
  8001aa:	b8 48 28 80 00       	mov    $0x802848,%eax
  8001af:	e8 80 fe ff ff       	call   800034 <die>
		}
		received += bytes;
  8001b4:	01 de                	add    %ebx,%esi
		buffer[bytes] = '\0';        // Assure null terminated string
  8001b6:	c6 44 1d c4 00       	movb   $0x0,0xffffffc4(%ebp,%ebx,1)
		cprintf(buffer);
  8001bb:	8d 45 c4             	lea    0xffffffc4(%ebp),%eax
  8001be:	89 04 24             	mov    %eax,(%esp)
  8001c1:	e8 03 01 00 00       	call   8002c9 <cprintf>
  8001c6:	39 f7                	cmp    %esi,%edi
  8001c8:	77 c0                	ja     80018a <umain+0x139>
	}
	cprintf("\n");
  8001ca:	c7 04 24 14 28 80 00 	movl   $0x802814,(%esp)
  8001d1:	e8 f3 00 00 00       	call   8002c9 <cprintf>
	
	close(sock);
  8001d6:	8b 45 c0             	mov    0xffffffc0(%ebp),%eax
  8001d9:	89 04 24             	mov    %eax,(%esp)
  8001dc:	e8 1a 14 00 00       	call   8015fb <close>
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
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	83 ec 18             	sub    $0x18,%esp
  8001f6:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  8001f9:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  8001fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8001ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  800202:	c7 05 50 60 80 00 00 	movl   $0x0,0x806050
  800209:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  80020c:	e8 fc 0e 00 00       	call   80110d <sys_getenvid>
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

	// call user main routine调用用户主例程
	umain(argc, argv);
  80022e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800232:	89 34 24             	mov    %esi,(%esp)
  800235:	e8 17 fe ff ff       	call   800051 <umain>

	// exit gracefully
	exit();
  80023a:	e8 0d 00 00 00       	call   80024c <exit>
}
  80023f:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  800242:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
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
  800252:	e8 3f 15 00 00       	call   801796 <close_all>
	sys_env_destroy(0);
  800257:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80025e:	e8 de 0e 00 00       	call   801141 <sys_env_destroy>
}
  800263:	c9                   	leave  
  800264:	c3                   	ret    
  800265:	00 00                	add    %al,(%eax)
	...

00800268 <vcprintf>:
}

int
vcprintf(const char *fmt, va_list ap)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800271:	c7 85 f8 fe ff ff 00 	movl   $0x0,0xfffffef8(%ebp)
  800278:	00 00 00 
	b.cnt = 0;
  80027b:	c7 85 fc fe ff ff 00 	movl   $0x0,0xfffffefc(%ebp)
  800282:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800285:	8b 45 0c             	mov    0xc(%ebp),%eax
  800288:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80028c:	8b 45 08             	mov    0x8(%ebp),%eax
  80028f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800293:	8d 85 f8 fe ff ff    	lea    0xfffffef8(%ebp),%eax
  800299:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029d:	c7 04 24 e6 02 80 00 	movl   $0x8002e6,(%esp)
  8002a4:	e8 c8 01 00 00       	call   800471 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002a9:	8b 85 f8 fe ff ff    	mov    0xfffffef8(%ebp),%eax
  8002af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b3:	8d 85 00 ff ff ff    	lea    0xffffff00(%ebp),%eax
  8002b9:	89 04 24             	mov    %eax,(%esp)
  8002bc:	e8 e7 0a 00 00       	call   800da8 <sys_cputs>
  8002c1:	8b 85 fc fe ff ff    	mov    0xfffffefc(%ebp),%eax

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
  8002d2:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
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
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	53                   	push   %ebx
  8002ea:	83 ec 14             	sub    $0x14,%esp
  8002ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f0:	8b 03                	mov    (%ebx),%eax
  8002f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f5:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002f9:	83 c0 01             	add    $0x1,%eax
  8002fc:	89 03                	mov    %eax,(%ebx)
  8002fe:	3d ff 00 00 00       	cmp    $0xff,%eax
  800303:	75 19                	jne    80031e <putch+0x38>
  800305:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80030c:	00 
  80030d:	8d 43 08             	lea    0x8(%ebx),%eax
  800310:	89 04 24             	mov    %eax,(%esp)
  800313:	e8 90 0a 00 00       	call   800da8 <sys_cputs>
  800318:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80031e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
  800322:	83 c4 14             	add    $0x14,%esp
  800325:	5b                   	pop    %ebx
  800326:	5d                   	pop    %ebp
  800327:	c3                   	ret    
	...

00800330 <printnum>:
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
  800339:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  80033c:	89 d7                	mov    %edx,%edi
  80033e:	8b 45 08             	mov    0x8(%ebp),%eax
  800341:	8b 55 0c             	mov    0xc(%ebp),%edx
  800344:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800347:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  80034a:	8b 55 10             	mov    0x10(%ebp),%edx
  80034d:	8b 45 14             	mov    0x14(%ebp),%eax
  800350:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800353:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  800356:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  80035d:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800360:	39 4d ec             	cmp    %ecx,0xffffffec(%ebp)
  800363:	72 11                	jb     800376 <printnum+0x46>
  800365:	8b 4d d8             	mov    0xffffffd8(%ebp),%ecx
  800368:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  80036b:	76 09                	jbe    800376 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80036d:	8d 58 ff             	lea    0xffffffff(%eax),%ebx
  800370:	85 db                	test   %ebx,%ebx
  800372:	7f 54                	jg     8003c8 <printnum+0x98>
  800374:	eb 61                	jmp    8003d7 <printnum+0xa7>
  800376:	89 74 24 10          	mov    %esi,0x10(%esp)
  80037a:	83 e8 01             	sub    $0x1,%eax
  80037d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800381:	89 54 24 08          	mov    %edx,0x8(%esp)
  800385:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800389:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80038d:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800390:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800393:	89 44 24 08          	mov    %eax,0x8(%esp)
  800397:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80039b:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  80039e:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  8003a1:	89 14 24             	mov    %edx,(%esp)
  8003a4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8003a8:	e8 e3 20 00 00       	call   802490 <__udivdi3>
  8003ad:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003b1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003b5:	89 04 24             	mov    %eax,(%esp)
  8003b8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003bc:	89 fa                	mov    %edi,%edx
  8003be:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  8003c1:	e8 6a ff ff ff       	call   800330 <printnum>
  8003c6:	eb 0f                	jmp    8003d7 <printnum+0xa7>
			putch(padc, putdat);
  8003c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003cc:	89 34 24             	mov    %esi,(%esp)
  8003cf:	ff 55 e4             	call   *0xffffffe4(%ebp)
  8003d2:	83 eb 01             	sub    $0x1,%ebx
  8003d5:	75 f1                	jne    8003c8 <printnum+0x98>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003d7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003db:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003df:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8003e2:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  8003e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003e9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003ed:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  8003f0:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  8003f3:	89 14 24             	mov    %edx,(%esp)
  8003f6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8003fa:	e8 c1 21 00 00       	call   8025c0 <__umoddi3>
  8003ff:	89 74 24 04          	mov    %esi,0x4(%esp)
  800403:	0f be 80 83 28 80 00 	movsbl 0x802883(%eax),%eax
  80040a:	89 04 24             	mov    %eax,(%esp)
  80040d:	ff 55 e4             	call   *0xffffffe4(%ebp)
}
  800410:	83 c4 3c             	add    $0x3c,%esp
  800413:	5b                   	pop    %ebx
  800414:	5e                   	pop    %esi
  800415:	5f                   	pop    %edi
  800416:	5d                   	pop    %ebp
  800417:	c3                   	ret    

00800418 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800418:	55                   	push   %ebp
  800419:	89 e5                	mov    %esp,%ebp
  80041b:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  80041d:	83 fa 01             	cmp    $0x1,%edx
  800420:	7e 0e                	jle    800430 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  800422:	8b 10                	mov    (%eax),%edx
  800424:	8d 42 08             	lea    0x8(%edx),%eax
  800427:	89 01                	mov    %eax,(%ecx)
  800429:	8b 02                	mov    (%edx),%eax
  80042b:	8b 52 04             	mov    0x4(%edx),%edx
  80042e:	eb 22                	jmp    800452 <getuint+0x3a>
	else if (lflag)
  800430:	85 d2                	test   %edx,%edx
  800432:	74 10                	je     800444 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800434:	8b 10                	mov    (%eax),%edx
  800436:	8d 42 04             	lea    0x4(%edx),%eax
  800439:	89 01                	mov    %eax,(%ecx)
  80043b:	8b 02                	mov    (%edx),%eax
  80043d:	ba 00 00 00 00       	mov    $0x0,%edx
  800442:	eb 0e                	jmp    800452 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800444:	8b 10                	mov    (%eax),%edx
  800446:	8d 42 04             	lea    0x4(%edx),%eax
  800449:	89 01                	mov    %eax,(%ecx)
  80044b:	8b 02                	mov    (%edx),%eax
  80044d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800452:	5d                   	pop    %ebp
  800453:	c3                   	ret    

00800454 <sprintputch>:

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
  800454:	55                   	push   %ebp
  800455:	89 e5                	mov    %esp,%ebp
  800457:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  80045a:	83 41 08 01          	addl   $0x1,0x8(%ecx)
	if (b->buf < b->ebuf)
  80045e:	8b 11                	mov    (%ecx),%edx
  800460:	3b 51 04             	cmp    0x4(%ecx),%edx
  800463:	73 0a                	jae    80046f <sprintputch+0x1b>
		*b->buf++ = ch;
  800465:	8b 45 08             	mov    0x8(%ebp),%eax
  800468:	88 02                	mov    %al,(%edx)
  80046a:	8d 42 01             	lea    0x1(%edx),%eax
  80046d:	89 01                	mov    %eax,(%ecx)
}
  80046f:	5d                   	pop    %ebp
  800470:	c3                   	ret    

00800471 <vprintfmt>:
  800471:	55                   	push   %ebp
  800472:	89 e5                	mov    %esp,%ebp
  800474:	57                   	push   %edi
  800475:	56                   	push   %esi
  800476:	53                   	push   %ebx
  800477:	83 ec 4c             	sub    $0x4c,%esp
  80047a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80047d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800480:	eb 03                	jmp    800485 <vprintfmt+0x14>
  800482:	8b 5d e8             	mov    0xffffffe8(%ebp),%ebx
  800485:	0f b6 03             	movzbl (%ebx),%eax
  800488:	83 c3 01             	add    $0x1,%ebx
  80048b:	3c 25                	cmp    $0x25,%al
  80048d:	74 30                	je     8004bf <vprintfmt+0x4e>
  80048f:	84 c0                	test   %al,%al
  800491:	0f 84 a8 03 00 00    	je     80083f <vprintfmt+0x3ce>
  800497:	0f b6 d0             	movzbl %al,%edx
  80049a:	eb 0a                	jmp    8004a6 <vprintfmt+0x35>
  80049c:	84 c0                	test   %al,%al
  80049e:	66 90                	xchg   %ax,%ax
  8004a0:	0f 84 99 03 00 00    	je     80083f <vprintfmt+0x3ce>
  8004a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ad:	89 14 24             	mov    %edx,(%esp)
  8004b0:	ff d7                	call   *%edi
  8004b2:	0f b6 03             	movzbl (%ebx),%eax
  8004b5:	0f b6 d0             	movzbl %al,%edx
  8004b8:	83 c3 01             	add    $0x1,%ebx
  8004bb:	3c 25                	cmp    $0x25,%al
  8004bd:	75 dd                	jne    80049c <vprintfmt+0x2b>
  8004bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004c4:	c7 45 ec ff ff ff ff 	movl   $0xffffffff,0xffffffec(%ebp)
  8004cb:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  8004d2:	c7 45 dc 00 00 00 00 	movl   $0x0,0xffffffdc(%ebp)
  8004d9:	c6 45 e3 20          	movb   $0x20,0xffffffe3(%ebp)
  8004dd:	eb 07                	jmp    8004e6 <vprintfmt+0x75>
  8004df:	c7 45 dc 01 00 00 00 	movl   $0x1,0xffffffdc(%ebp)
  8004e6:	0f b6 03             	movzbl (%ebx),%eax
  8004e9:	0f b6 d0             	movzbl %al,%edx
  8004ec:	83 c3 01             	add    $0x1,%ebx
  8004ef:	83 e8 23             	sub    $0x23,%eax
  8004f2:	3c 55                	cmp    $0x55,%al
  8004f4:	0f 87 11 03 00 00    	ja     80080b <vprintfmt+0x39a>
  8004fa:	0f b6 c0             	movzbl %al,%eax
  8004fd:	ff 24 85 c0 29 80 00 	jmp    *0x8029c0(,%eax,4)
  800504:	c6 45 e3 30          	movb   $0x30,0xffffffe3(%ebp)
  800508:	eb dc                	jmp    8004e6 <vprintfmt+0x75>
  80050a:	83 ea 30             	sub    $0x30,%edx
  80050d:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  800510:	0f be 13             	movsbl (%ebx),%edx
  800513:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800516:	83 f8 09             	cmp    $0x9,%eax
  800519:	76 08                	jbe    800523 <vprintfmt+0xb2>
  80051b:	eb 42                	jmp    80055f <vprintfmt+0xee>
  80051d:	c6 45 e3 2d          	movb   $0x2d,0xffffffe3(%ebp)
  800521:	eb c3                	jmp    8004e6 <vprintfmt+0x75>
  800523:	83 c3 01             	add    $0x1,%ebx
  800526:	8b 75 e4             	mov    0xffffffe4(%ebp),%esi
  800529:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  80052c:	8d 44 42 d0          	lea    0xffffffd0(%edx,%eax,2),%eax
  800530:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  800533:	0f be 13             	movsbl (%ebx),%edx
  800536:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800539:	83 f8 09             	cmp    $0x9,%eax
  80053c:	77 21                	ja     80055f <vprintfmt+0xee>
  80053e:	eb e3                	jmp    800523 <vprintfmt+0xb2>
  800540:	8b 55 14             	mov    0x14(%ebp),%edx
  800543:	8d 42 04             	lea    0x4(%edx),%eax
  800546:	89 45 14             	mov    %eax,0x14(%ebp)
  800549:	8b 12                	mov    (%edx),%edx
  80054b:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  80054e:	eb 0f                	jmp    80055f <vprintfmt+0xee>
  800550:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800554:	79 90                	jns    8004e6 <vprintfmt+0x75>
  800556:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  80055d:	eb 87                	jmp    8004e6 <vprintfmt+0x75>
  80055f:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800563:	79 81                	jns    8004e6 <vprintfmt+0x75>
  800565:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  800568:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  80056b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  800572:	e9 6f ff ff ff       	jmp    8004e6 <vprintfmt+0x75>
  800577:	83 c1 01             	add    $0x1,%ecx
  80057a:	e9 67 ff ff ff       	jmp    8004e6 <vprintfmt+0x75>
  80057f:	8b 45 14             	mov    0x14(%ebp),%eax
  800582:	8d 50 04             	lea    0x4(%eax),%edx
  800585:	89 55 14             	mov    %edx,0x14(%ebp)
  800588:	8b 55 0c             	mov    0xc(%ebp),%edx
  80058b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80058f:	8b 00                	mov    (%eax),%eax
  800591:	89 04 24             	mov    %eax,(%esp)
  800594:	ff d7                	call   *%edi
  800596:	e9 ea fe ff ff       	jmp    800485 <vprintfmt+0x14>
  80059b:	8b 55 14             	mov    0x14(%ebp),%edx
  80059e:	8d 42 04             	lea    0x4(%edx),%eax
  8005a1:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a4:	8b 02                	mov    (%edx),%eax
  8005a6:	89 c2                	mov    %eax,%edx
  8005a8:	c1 fa 1f             	sar    $0x1f,%edx
  8005ab:	31 d0                	xor    %edx,%eax
  8005ad:	29 d0                	sub    %edx,%eax
  8005af:	83 f8 0f             	cmp    $0xf,%eax
  8005b2:	7f 0b                	jg     8005bf <vprintfmt+0x14e>
  8005b4:	8b 14 85 20 2b 80 00 	mov    0x802b20(,%eax,4),%edx
  8005bb:	85 d2                	test   %edx,%edx
  8005bd:	75 20                	jne    8005df <vprintfmt+0x16e>
  8005bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005c3:	c7 44 24 08 94 28 80 	movl   $0x802894,0x8(%esp)
  8005ca:	00 
  8005cb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d2:	89 3c 24             	mov    %edi,(%esp)
  8005d5:	e8 f0 02 00 00       	call   8008ca <printfmt>
  8005da:	e9 a6 fe ff ff       	jmp    800485 <vprintfmt+0x14>
  8005df:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005e3:	c7 44 24 08 62 2c 80 	movl   $0x802c62,0x8(%esp)
  8005ea:	00 
  8005eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f2:	89 3c 24             	mov    %edi,(%esp)
  8005f5:	e8 d0 02 00 00       	call   8008ca <printfmt>
  8005fa:	e9 86 fe ff ff       	jmp    800485 <vprintfmt+0x14>
  8005ff:	8b 75 ec             	mov    0xffffffec(%ebp),%esi
  800602:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  800605:	89 5d e8             	mov    %ebx,0xffffffe8(%ebp)
  800608:	8b 55 14             	mov    0x14(%ebp),%edx
  80060b:	8d 42 04             	lea    0x4(%edx),%eax
  80060e:	89 45 14             	mov    %eax,0x14(%ebp)
  800611:	8b 12                	mov    (%edx),%edx
  800613:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  800616:	85 d2                	test   %edx,%edx
  800618:	75 07                	jne    800621 <vprintfmt+0x1b0>
  80061a:	c7 45 d8 9d 28 80 00 	movl   $0x80289d,0xffffffd8(%ebp)
  800621:	85 f6                	test   %esi,%esi
  800623:	7e 40                	jle    800665 <vprintfmt+0x1f4>
  800625:	80 7d e3 2d          	cmpb   $0x2d,0xffffffe3(%ebp)
  800629:	74 3a                	je     800665 <vprintfmt+0x1f4>
  80062b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80062f:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800632:	89 14 24             	mov    %edx,(%esp)
  800635:	e8 e6 02 00 00       	call   800920 <strnlen>
  80063a:	29 c6                	sub    %eax,%esi
  80063c:	89 75 ec             	mov    %esi,0xffffffec(%ebp)
  80063f:	85 f6                	test   %esi,%esi
  800641:	7e 22                	jle    800665 <vprintfmt+0x1f4>
  800643:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  800647:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  80064a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80064d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800651:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  800654:	89 04 24             	mov    %eax,(%esp)
  800657:	ff d7                	call   *%edi
  800659:	83 ee 01             	sub    $0x1,%esi
  80065c:	75 ec                	jne    80064a <vprintfmt+0x1d9>
  80065e:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  800665:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800668:	0f b6 02             	movzbl (%edx),%eax
  80066b:	0f be d0             	movsbl %al,%edx
  80066e:	8b 75 d8             	mov    0xffffffd8(%ebp),%esi
  800671:	84 c0                	test   %al,%al
  800673:	75 40                	jne    8006b5 <vprintfmt+0x244>
  800675:	eb 4a                	jmp    8006c1 <vprintfmt+0x250>
  800677:	83 7d dc 00          	cmpl   $0x0,0xffffffdc(%ebp)
  80067b:	74 1a                	je     800697 <vprintfmt+0x226>
  80067d:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  800680:	83 f8 5e             	cmp    $0x5e,%eax
  800683:	76 12                	jbe    800697 <vprintfmt+0x226>
  800685:	8b 45 0c             	mov    0xc(%ebp),%eax
  800688:	89 44 24 04          	mov    %eax,0x4(%esp)
  80068c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800693:	ff d7                	call   *%edi
  800695:	eb 0c                	jmp    8006a3 <vprintfmt+0x232>
  800697:	8b 45 0c             	mov    0xc(%ebp),%eax
  80069a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069e:	89 14 24             	mov    %edx,(%esp)
  8006a1:	ff d7                	call   *%edi
  8006a3:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  8006a7:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8006ab:	83 c6 01             	add    $0x1,%esi
  8006ae:	84 c0                	test   %al,%al
  8006b0:	74 0f                	je     8006c1 <vprintfmt+0x250>
  8006b2:	0f be d0             	movsbl %al,%edx
  8006b5:	83 7d e4 00          	cmpl   $0x0,0xffffffe4(%ebp)
  8006b9:	78 bc                	js     800677 <vprintfmt+0x206>
  8006bb:	83 6d e4 01          	subl   $0x1,0xffffffe4(%ebp)
  8006bf:	79 b6                	jns    800677 <vprintfmt+0x206>
  8006c1:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  8006c5:	0f 8e ba fd ff ff    	jle    800485 <vprintfmt+0x14>
  8006cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006d2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006d9:	ff d7                	call   *%edi
  8006db:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  8006df:	0f 84 9d fd ff ff    	je     800482 <vprintfmt+0x11>
  8006e5:	eb e4                	jmp    8006cb <vprintfmt+0x25a>
  8006e7:	83 f9 01             	cmp    $0x1,%ecx
  8006ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8006f0:	7e 10                	jle    800702 <vprintfmt+0x291>
  8006f2:	8b 55 14             	mov    0x14(%ebp),%edx
  8006f5:	8d 42 08             	lea    0x8(%edx),%eax
  8006f8:	89 45 14             	mov    %eax,0x14(%ebp)
  8006fb:	8b 02                	mov    (%edx),%eax
  8006fd:	8b 52 04             	mov    0x4(%edx),%edx
  800700:	eb 26                	jmp    800728 <vprintfmt+0x2b7>
  800702:	85 c9                	test   %ecx,%ecx
  800704:	74 12                	je     800718 <vprintfmt+0x2a7>
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8d 50 04             	lea    0x4(%eax),%edx
  80070c:	89 55 14             	mov    %edx,0x14(%ebp)
  80070f:	8b 00                	mov    (%eax),%eax
  800711:	89 c2                	mov    %eax,%edx
  800713:	c1 fa 1f             	sar    $0x1f,%edx
  800716:	eb 10                	jmp    800728 <vprintfmt+0x2b7>
  800718:	8b 45 14             	mov    0x14(%ebp),%eax
  80071b:	8d 50 04             	lea    0x4(%eax),%edx
  80071e:	89 55 14             	mov    %edx,0x14(%ebp)
  800721:	8b 00                	mov    (%eax),%eax
  800723:	89 c2                	mov    %eax,%edx
  800725:	c1 fa 1f             	sar    $0x1f,%edx
  800728:	89 d1                	mov    %edx,%ecx
  80072a:	89 c2                	mov    %eax,%edx
  80072c:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  80072f:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  800732:	be 0a 00 00 00       	mov    $0xa,%esi
  800737:	85 c9                	test   %ecx,%ecx
  800739:	0f 89 92 00 00 00    	jns    8007d1 <vprintfmt+0x360>
  80073f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800742:	89 74 24 04          	mov    %esi,0x4(%esp)
  800746:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80074d:	ff d7                	call   *%edi
  80074f:	8b 55 d0             	mov    0xffffffd0(%ebp),%edx
  800752:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
  800755:	f7 da                	neg    %edx
  800757:	83 d1 00             	adc    $0x0,%ecx
  80075a:	f7 d9                	neg    %ecx
  80075c:	be 0a 00 00 00       	mov    $0xa,%esi
  800761:	eb 6e                	jmp    8007d1 <vprintfmt+0x360>
  800763:	8d 45 14             	lea    0x14(%ebp),%eax
  800766:	89 ca                	mov    %ecx,%edx
  800768:	e8 ab fc ff ff       	call   800418 <getuint>
  80076d:	89 d1                	mov    %edx,%ecx
  80076f:	89 c2                	mov    %eax,%edx
  800771:	be 0a 00 00 00       	mov    $0xa,%esi
  800776:	eb 59                	jmp    8007d1 <vprintfmt+0x360>
  800778:	8d 45 14             	lea    0x14(%ebp),%eax
  80077b:	89 ca                	mov    %ecx,%edx
  80077d:	e8 96 fc ff ff       	call   800418 <getuint>
  800782:	e9 fe fc ff ff       	jmp    800485 <vprintfmt+0x14>
  800787:	8b 45 0c             	mov    0xc(%ebp),%eax
  80078a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800795:	ff d7                	call   *%edi
  800797:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80079e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007a5:	ff d7                	call   *%edi
  8007a7:	8b 55 14             	mov    0x14(%ebp),%edx
  8007aa:	8d 42 04             	lea    0x4(%edx),%eax
  8007ad:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b0:	8b 12                	mov    (%edx),%edx
  8007b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b7:	be 10 00 00 00       	mov    $0x10,%esi
  8007bc:	eb 13                	jmp    8007d1 <vprintfmt+0x360>
  8007be:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c1:	89 ca                	mov    %ecx,%edx
  8007c3:	e8 50 fc ff ff       	call   800418 <getuint>
  8007c8:	89 d1                	mov    %edx,%ecx
  8007ca:	89 c2                	mov    %eax,%edx
  8007cc:	be 10 00 00 00       	mov    $0x10,%esi
  8007d1:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  8007d5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007d9:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  8007dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e0:	89 74 24 08          	mov    %esi,0x8(%esp)
  8007e4:	89 14 24             	mov    %edx,(%esp)
  8007e7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ee:	89 f8                	mov    %edi,%eax
  8007f0:	e8 3b fb ff ff       	call   800330 <printnum>
  8007f5:	e9 8b fc ff ff       	jmp    800485 <vprintfmt+0x14>
  8007fa:	8b 75 0c             	mov    0xc(%ebp),%esi
  8007fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  800801:	89 14 24             	mov    %edx,(%esp)
  800804:	ff d7                	call   *%edi
  800806:	e9 7a fc ff ff       	jmp    800485 <vprintfmt+0x14>
  80080b:	89 de                	mov    %ebx,%esi
  80080d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800810:	89 44 24 04          	mov    %eax,0x4(%esp)
  800814:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80081b:	ff d7                	call   *%edi
  80081d:	83 eb 01             	sub    $0x1,%ebx
  800820:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  800824:	0f 84 5b fc ff ff    	je     800485 <vprintfmt+0x14>
  80082a:	8d 56 fd             	lea    0xfffffffd(%esi),%edx
  80082d:	0f b6 02             	movzbl (%edx),%eax
  800830:	83 ea 01             	sub    $0x1,%edx
  800833:	3c 25                	cmp    $0x25,%al
  800835:	75 f6                	jne    80082d <vprintfmt+0x3bc>
  800837:	8d 5a 02             	lea    0x2(%edx),%ebx
  80083a:	e9 46 fc ff ff       	jmp    800485 <vprintfmt+0x14>
  80083f:	83 c4 4c             	add    $0x4c,%esp
  800842:	5b                   	pop    %ebx
  800843:	5e                   	pop    %esi
  800844:	5f                   	pop    %edi
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	83 ec 28             	sub    $0x28,%esp
  80084d:	8b 55 08             	mov    0x8(%ebp),%edx
  800850:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800853:	85 d2                	test   %edx,%edx
  800855:	74 04                	je     80085b <vsnprintf+0x14>
  800857:	85 c0                	test   %eax,%eax
  800859:	7f 07                	jg     800862 <vsnprintf+0x1b>
  80085b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800860:	eb 3b                	jmp    80089d <vsnprintf+0x56>
  800862:	c7 45 fc 00 00 00 00 	movl   $0x0,0xfffffffc(%ebp)
  800869:	8d 44 02 ff          	lea    0xffffffff(%edx,%eax,1),%eax
  80086d:	89 45 f8             	mov    %eax,0xfffffff8(%ebp)
  800870:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800873:	8b 45 14             	mov    0x14(%ebp),%eax
  800876:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80087a:	8b 45 10             	mov    0x10(%ebp),%eax
  80087d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800881:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  800884:	89 44 24 04          	mov    %eax,0x4(%esp)
  800888:	c7 04 24 54 04 80 00 	movl   $0x800454,(%esp)
  80088f:	e8 dd fb ff ff       	call   800471 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800894:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  800897:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80089a:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
}
  80089d:	c9                   	leave  
  80089e:	c3                   	ret    

0080089f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008a5:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a8:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8008ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008af:	8b 45 10             	mov    0x10(%ebp),%eax
  8008b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c0:	89 04 24             	mov    %eax,(%esp)
  8008c3:	e8 7f ff ff ff       	call   800847 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008c8:	c9                   	leave  
  8008c9:	c3                   	ret    

008008ca <printfmt>:
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	83 ec 28             	sub    $0x28,%esp
  8008d0:	8d 45 14             	lea    0x14(%ebp),%eax
  8008d3:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
  8008d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008da:	8b 45 10             	mov    0x10(%ebp),%eax
  8008dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008eb:	89 04 24             	mov    %eax,(%esp)
  8008ee:	e8 7e fb ff ff       	call   800471 <vprintfmt>
  8008f3:	c9                   	leave  
  8008f4:	c3                   	ret    
	...

00800900 <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800906:	b8 00 00 00 00       	mov    $0x0,%eax
  80090b:	80 3a 00             	cmpb   $0x0,(%edx)
  80090e:	74 0e                	je     80091e <strlen+0x1e>
  800910:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800915:	83 c0 01             	add    $0x1,%eax
  800918:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  80091c:	75 f7                	jne    800915 <strlen+0x15>
	return n;
}
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800926:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800929:	85 d2                	test   %edx,%edx
  80092b:	74 19                	je     800946 <strnlen+0x26>
  80092d:	80 39 00             	cmpb   $0x0,(%ecx)
  800930:	74 14                	je     800946 <strnlen+0x26>
  800932:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800937:	83 c0 01             	add    $0x1,%eax
  80093a:	39 d0                	cmp    %edx,%eax
  80093c:	74 0d                	je     80094b <strnlen+0x2b>
  80093e:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800942:	74 07                	je     80094b <strnlen+0x2b>
  800944:	eb f1                	jmp    800937 <strnlen+0x17>
  800946:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  80094b:	5d                   	pop    %ebp
  80094c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800950:	c3                   	ret    

00800951 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	53                   	push   %ebx
  800955:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800958:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80095b:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80095d:	0f b6 01             	movzbl (%ecx),%eax
  800960:	88 02                	mov    %al,(%edx)
  800962:	83 c2 01             	add    $0x1,%edx
  800965:	83 c1 01             	add    $0x1,%ecx
  800968:	84 c0                	test   %al,%al
  80096a:	75 f1                	jne    80095d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80096c:	89 d8                	mov    %ebx,%eax
  80096e:	5b                   	pop    %ebx
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    

00800971 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	57                   	push   %edi
  800975:	56                   	push   %esi
  800976:	53                   	push   %ebx
  800977:	8b 7d 08             	mov    0x8(%ebp),%edi
  80097a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80097d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800980:	85 f6                	test   %esi,%esi
  800982:	74 1c                	je     8009a0 <strncpy+0x2f>
  800984:	89 fa                	mov    %edi,%edx
  800986:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  80098b:	0f b6 01             	movzbl (%ecx),%eax
  80098e:	88 02                	mov    %al,(%edx)
  800990:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800993:	80 39 01             	cmpb   $0x1,(%ecx)
  800996:	83 d9 ff             	sbb    $0xffffffff,%ecx
  800999:	83 c3 01             	add    $0x1,%ebx
  80099c:	39 f3                	cmp    %esi,%ebx
  80099e:	75 eb                	jne    80098b <strncpy+0x1a>
	}
	return ret;
}
  8009a0:	89 f8                	mov    %edi,%eax
  8009a2:	5b                   	pop    %ebx
  8009a3:	5e                   	pop    %esi
  8009a4:	5f                   	pop    %edi
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    

008009a7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	56                   	push   %esi
  8009ab:	53                   	push   %ebx
  8009ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8009af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b2:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009b5:	89 f0                	mov    %esi,%eax
  8009b7:	85 d2                	test   %edx,%edx
  8009b9:	74 2c                	je     8009e7 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  8009bb:	89 d3                	mov    %edx,%ebx
  8009bd:	83 eb 01             	sub    $0x1,%ebx
  8009c0:	74 20                	je     8009e2 <strlcpy+0x3b>
  8009c2:	0f b6 11             	movzbl (%ecx),%edx
  8009c5:	84 d2                	test   %dl,%dl
  8009c7:	74 19                	je     8009e2 <strlcpy+0x3b>
  8009c9:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  8009cb:	88 10                	mov    %dl,(%eax)
  8009cd:	83 c0 01             	add    $0x1,%eax
  8009d0:	83 eb 01             	sub    $0x1,%ebx
  8009d3:	74 0f                	je     8009e4 <strlcpy+0x3d>
  8009d5:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  8009d9:	83 c1 01             	add    $0x1,%ecx
  8009dc:	84 d2                	test   %dl,%dl
  8009de:	74 04                	je     8009e4 <strlcpy+0x3d>
  8009e0:	eb e9                	jmp    8009cb <strlcpy+0x24>
  8009e2:	89 f0                	mov    %esi,%eax
		*dst = '\0';
  8009e4:	c6 00 00             	movb   $0x0,(%eax)
  8009e7:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8009e9:	5b                   	pop    %ebx
  8009ea:	5e                   	pop    %esi
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    

008009ed <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	57                   	push   %edi
  8009f1:	56                   	push   %esi
  8009f2:	53                   	push   %ebx
  8009f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009f9:	8b 7d 10             	mov    0x10(%ebp),%edi
    int c;
    char *q = buf;

    if (buf_size <= 0)
  8009fc:	85 c9                	test   %ecx,%ecx
  8009fe:	7e 30                	jle    800a30 <pstrcpy+0x43>
        return;

    for(;;) {
        c = *str++;
  800a00:	0f b6 07             	movzbl (%edi),%eax
        if (c == 0 || q >= buf + buf_size - 1)
  800a03:	84 c0                	test   %al,%al
  800a05:	74 26                	je     800a2d <pstrcpy+0x40>
  800a07:	8d 74 0a ff          	lea    0xffffffff(%edx,%ecx,1),%esi
  800a0b:	0f be d8             	movsbl %al,%ebx
  800a0e:	89 f9                	mov    %edi,%ecx
  800a10:	39 f2                	cmp    %esi,%edx
  800a12:	72 09                	jb     800a1d <pstrcpy+0x30>
  800a14:	eb 17                	jmp    800a2d <pstrcpy+0x40>
  800a16:	83 c1 01             	add    $0x1,%ecx
  800a19:	39 f2                	cmp    %esi,%edx
  800a1b:	73 10                	jae    800a2d <pstrcpy+0x40>
            break;
        *q++ = c;
  800a1d:	88 1a                	mov    %bl,(%edx)
  800a1f:	83 c2 01             	add    $0x1,%edx
  800a22:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800a26:	0f be d8             	movsbl %al,%ebx
  800a29:	84 c0                	test   %al,%al
  800a2b:	75 e9                	jne    800a16 <pstrcpy+0x29>
    }
    *q = '\0';
  800a2d:	c6 02 00             	movb   $0x0,(%edx)
}
  800a30:	5b                   	pop    %ebx
  800a31:	5e                   	pop    %esi
  800a32:	5f                   	pop    %edi
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  800a3e:	0f b6 02             	movzbl (%edx),%eax
  800a41:	84 c0                	test   %al,%al
  800a43:	74 16                	je     800a5b <strcmp+0x26>
  800a45:	3a 01                	cmp    (%ecx),%al
  800a47:	75 12                	jne    800a5b <strcmp+0x26>
		p++, q++;
  800a49:	83 c1 01             	add    $0x1,%ecx
  800a4c:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  800a50:	84 c0                	test   %al,%al
  800a52:	74 07                	je     800a5b <strcmp+0x26>
  800a54:	83 c2 01             	add    $0x1,%edx
  800a57:	3a 01                	cmp    (%ecx),%al
  800a59:	74 ee                	je     800a49 <strcmp+0x14>
  800a5b:	0f b6 c0             	movzbl %al,%eax
  800a5e:	0f b6 11             	movzbl (%ecx),%edx
  800a61:	29 d0                	sub    %edx,%eax
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	53                   	push   %ebx
  800a69:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a6f:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800a72:	85 d2                	test   %edx,%edx
  800a74:	74 2d                	je     800aa3 <strncmp+0x3e>
  800a76:	0f b6 01             	movzbl (%ecx),%eax
  800a79:	84 c0                	test   %al,%al
  800a7b:	74 1a                	je     800a97 <strncmp+0x32>
  800a7d:	3a 03                	cmp    (%ebx),%al
  800a7f:	75 16                	jne    800a97 <strncmp+0x32>
  800a81:	83 ea 01             	sub    $0x1,%edx
  800a84:	74 1d                	je     800aa3 <strncmp+0x3e>
		n--, p++, q++;
  800a86:	83 c1 01             	add    $0x1,%ecx
  800a89:	83 c3 01             	add    $0x1,%ebx
  800a8c:	0f b6 01             	movzbl (%ecx),%eax
  800a8f:	84 c0                	test   %al,%al
  800a91:	74 04                	je     800a97 <strncmp+0x32>
  800a93:	3a 03                	cmp    (%ebx),%al
  800a95:	74 ea                	je     800a81 <strncmp+0x1c>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a97:	0f b6 11             	movzbl (%ecx),%edx
  800a9a:	0f b6 03             	movzbl (%ebx),%eax
  800a9d:	29 c2                	sub    %eax,%edx
  800a9f:	89 d0                	mov    %edx,%eax
  800aa1:	eb 05                	jmp    800aa8 <strncmp+0x43>
  800aa3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa8:	5b                   	pop    %ebx
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ab5:	0f b6 10             	movzbl (%eax),%edx
  800ab8:	84 d2                	test   %dl,%dl
  800aba:	74 16                	je     800ad2 <strchr+0x27>
		if (*s == c)
  800abc:	38 ca                	cmp    %cl,%dl
  800abe:	75 06                	jne    800ac6 <strchr+0x1b>
  800ac0:	eb 15                	jmp    800ad7 <strchr+0x2c>
  800ac2:	38 ca                	cmp    %cl,%dl
  800ac4:	74 11                	je     800ad7 <strchr+0x2c>
  800ac6:	83 c0 01             	add    $0x1,%eax
  800ac9:	0f b6 10             	movzbl (%eax),%edx
  800acc:	84 d2                	test   %dl,%dl
  800ace:	66 90                	xchg   %ax,%ax
  800ad0:	75 f0                	jne    800ac2 <strchr+0x17>
  800ad2:	b8 00 00 00 00       	mov    $0x0,%eax
			return (char *) s;
	return 0;
}
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	8b 45 08             	mov    0x8(%ebp),%eax
  800adf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ae3:	0f b6 10             	movzbl (%eax),%edx
  800ae6:	84 d2                	test   %dl,%dl
  800ae8:	74 14                	je     800afe <strfind+0x25>
		if (*s == c)
  800aea:	38 ca                	cmp    %cl,%dl
  800aec:	75 06                	jne    800af4 <strfind+0x1b>
  800aee:	eb 0e                	jmp    800afe <strfind+0x25>
  800af0:	38 ca                	cmp    %cl,%dl
  800af2:	74 0a                	je     800afe <strfind+0x25>
  800af4:	83 c0 01             	add    $0x1,%eax
  800af7:	0f b6 10             	movzbl (%eax),%edx
  800afa:	84 d2                	test   %dl,%dl
  800afc:	75 f2                	jne    800af0 <strfind+0x17>
			break;
	return (char *) s;
}
  800afe:	5d                   	pop    %ebp
  800aff:	90                   	nop    
  800b00:	c3                   	ret    

00800b01 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	83 ec 08             	sub    $0x8,%esp
  800b07:	89 1c 24             	mov    %ebx,(%esp)
  800b0a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b0e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b14:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800b17:	85 db                	test   %ebx,%ebx
  800b19:	74 32                	je     800b4d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b1b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b21:	75 25                	jne    800b48 <memset+0x47>
  800b23:	f6 c3 03             	test   $0x3,%bl
  800b26:	75 20                	jne    800b48 <memset+0x47>
		c &= 0xFF;
  800b28:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b2b:	89 d0                	mov    %edx,%eax
  800b2d:	c1 e0 18             	shl    $0x18,%eax
  800b30:	89 d1                	mov    %edx,%ecx
  800b32:	c1 e1 10             	shl    $0x10,%ecx
  800b35:	09 c8                	or     %ecx,%eax
  800b37:	09 d0                	or     %edx,%eax
  800b39:	c1 e2 08             	shl    $0x8,%edx
  800b3c:	09 d0                	or     %edx,%eax
  800b3e:	89 d9                	mov    %ebx,%ecx
  800b40:	c1 e9 02             	shr    $0x2,%ecx
  800b43:	fc                   	cld    
  800b44:	f3 ab                	rep stos %eax,%es:(%edi)
  800b46:	eb 05                	jmp    800b4d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b48:	89 d9                	mov    %ebx,%ecx
  800b4a:	fc                   	cld    
  800b4b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b4d:	89 f8                	mov    %edi,%eax
  800b4f:	8b 1c 24             	mov    (%esp),%ebx
  800b52:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b56:	89 ec                	mov    %ebp,%esp
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	83 ec 08             	sub    $0x8,%esp
  800b60:	89 34 24             	mov    %esi,(%esp)
  800b63:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b67:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800b6d:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b70:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b72:	39 c6                	cmp    %eax,%esi
  800b74:	73 36                	jae    800bac <memmove+0x52>
  800b76:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b79:	39 d0                	cmp    %edx,%eax
  800b7b:	73 2f                	jae    800bac <memmove+0x52>
		s += n;
		d += n;
  800b7d:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b80:	f6 c2 03             	test   $0x3,%dl
  800b83:	75 1b                	jne    800ba0 <memmove+0x46>
  800b85:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b8b:	75 13                	jne    800ba0 <memmove+0x46>
  800b8d:	f6 c1 03             	test   $0x3,%cl
  800b90:	75 0e                	jne    800ba0 <memmove+0x46>
			asm volatile("std; rep movsl\n"
  800b92:	8d 7e fc             	lea    0xfffffffc(%esi),%edi
  800b95:	8d 72 fc             	lea    0xfffffffc(%edx),%esi
  800b98:	c1 e9 02             	shr    $0x2,%ecx
  800b9b:	fd                   	std    
  800b9c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b9e:	eb 09                	jmp    800ba9 <memmove+0x4f>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ba0:	8d 7e ff             	lea    0xffffffff(%esi),%edi
  800ba3:	8d 72 ff             	lea    0xffffffff(%edx),%esi
  800ba6:	fd                   	std    
  800ba7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ba9:	fc                   	cld    
  800baa:	eb 21                	jmp    800bcd <memmove+0x73>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bac:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bb2:	75 16                	jne    800bca <memmove+0x70>
  800bb4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bba:	75 0e                	jne    800bca <memmove+0x70>
  800bbc:	f6 c1 03             	test   $0x3,%cl
  800bbf:	90                   	nop    
  800bc0:	75 08                	jne    800bca <memmove+0x70>
			asm volatile("cld; rep movsl\n"
  800bc2:	c1 e9 02             	shr    $0x2,%ecx
  800bc5:	fc                   	cld    
  800bc6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bc8:	eb 03                	jmp    800bcd <memmove+0x73>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bca:	fc                   	cld    
  800bcb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bcd:	8b 34 24             	mov    (%esp),%esi
  800bd0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800bd4:	89 ec                	mov    %ebp,%esp
  800bd6:	5d                   	pop    %ebp
  800bd7:	c3                   	ret    

00800bd8 <memcpy>:

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
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bde:	8b 45 10             	mov    0x10(%ebp),%eax
  800be1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800be5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bec:	8b 45 08             	mov    0x8(%ebp),%eax
  800bef:	89 04 24             	mov    %eax,(%esp)
  800bf2:	e8 63 ff ff ff       	call   800b5a <memmove>
}
  800bf7:	c9                   	leave  
  800bf8:	c3                   	ret    

00800bf9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	56                   	push   %esi
  800bfd:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bfe:	8b 75 10             	mov    0x10(%ebp),%esi
  800c01:	83 ee 01             	sub    $0x1,%esi
  800c04:	83 fe ff             	cmp    $0xffffffff,%esi
  800c07:	74 38                	je     800c41 <memcmp+0x48>
  800c09:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0c:	8b 55 0c             	mov    0xc(%ebp),%edx
		if (*s1 != *s2)
  800c0f:	0f b6 18             	movzbl (%eax),%ebx
  800c12:	0f b6 0a             	movzbl (%edx),%ecx
  800c15:	38 cb                	cmp    %cl,%bl
  800c17:	74 20                	je     800c39 <memcmp+0x40>
  800c19:	eb 12                	jmp    800c2d <memcmp+0x34>
  800c1b:	0f b6 58 01          	movzbl 0x1(%eax),%ebx
  800c1f:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
  800c23:	83 c0 01             	add    $0x1,%eax
  800c26:	83 c2 01             	add    $0x1,%edx
  800c29:	38 cb                	cmp    %cl,%bl
  800c2b:	74 0c                	je     800c39 <memcmp+0x40>
			return (int) *s1 - (int) *s2;
  800c2d:	0f b6 d3             	movzbl %bl,%edx
  800c30:	0f b6 c1             	movzbl %cl,%eax
  800c33:	29 c2                	sub    %eax,%edx
  800c35:	89 d0                	mov    %edx,%eax
  800c37:	eb 0d                	jmp    800c46 <memcmp+0x4d>
  800c39:	83 ee 01             	sub    $0x1,%esi
  800c3c:	83 fe ff             	cmp    $0xffffffff,%esi
  800c3f:	75 da                	jne    800c1b <memcmp+0x22>
  800c41:	b8 00 00 00 00       	mov    $0x0,%eax
		s1++, s2++;
	}

	return 0;
}
  800c46:	5b                   	pop    %ebx
  800c47:	5e                   	pop    %esi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	53                   	push   %ebx
  800c4e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800c51:	89 da                	mov    %ebx,%edx
  800c53:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c56:	39 d3                	cmp    %edx,%ebx
  800c58:	73 1a                	jae    800c74 <memfind+0x2a>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c5a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
			break;
  800c5e:	89 d8                	mov    %ebx,%eax
  800c60:	38 0b                	cmp    %cl,(%ebx)
  800c62:	75 06                	jne    800c6a <memfind+0x20>
  800c64:	eb 0e                	jmp    800c74 <memfind+0x2a>
  800c66:	38 08                	cmp    %cl,(%eax)
  800c68:	74 0c                	je     800c76 <memfind+0x2c>
  800c6a:	83 c0 01             	add    $0x1,%eax
  800c6d:	39 d0                	cmp    %edx,%eax
  800c6f:	90                   	nop    
  800c70:	75 f4                	jne    800c66 <memfind+0x1c>
  800c72:	eb 02                	jmp    800c76 <memfind+0x2c>
  800c74:	89 d8                	mov    %ebx,%eax
	return (void *) s;
}
  800c76:	5b                   	pop    %ebx
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	57                   	push   %edi
  800c7d:	56                   	push   %esi
  800c7e:	53                   	push   %ebx
  800c7f:	83 ec 04             	sub    $0x4,%esp
  800c82:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c85:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c88:	0f b6 03             	movzbl (%ebx),%eax
  800c8b:	3c 20                	cmp    $0x20,%al
  800c8d:	74 04                	je     800c93 <strtol+0x1a>
  800c8f:	3c 09                	cmp    $0x9,%al
  800c91:	75 0e                	jne    800ca1 <strtol+0x28>
		s++;
  800c93:	83 c3 01             	add    $0x1,%ebx
  800c96:	0f b6 03             	movzbl (%ebx),%eax
  800c99:	3c 20                	cmp    $0x20,%al
  800c9b:	74 f6                	je     800c93 <strtol+0x1a>
  800c9d:	3c 09                	cmp    $0x9,%al
  800c9f:	74 f2                	je     800c93 <strtol+0x1a>

	// plus/minus sign
	if (*s == '+')
  800ca1:	3c 2b                	cmp    $0x2b,%al
  800ca3:	75 0d                	jne    800cb2 <strtol+0x39>
		s++;
  800ca5:	83 c3 01             	add    $0x1,%ebx
  800ca8:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800caf:	90                   	nop    
  800cb0:	eb 15                	jmp    800cc7 <strtol+0x4e>
	else if (*s == '-')
  800cb2:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800cb9:	3c 2d                	cmp    $0x2d,%al
  800cbb:	75 0a                	jne    800cc7 <strtol+0x4e>
		s++, neg = 1;
  800cbd:	83 c3 01             	add    $0x1,%ebx
  800cc0:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cc7:	85 f6                	test   %esi,%esi
  800cc9:	0f 94 c0             	sete   %al
  800ccc:	84 c0                	test   %al,%al
  800cce:	75 05                	jne    800cd5 <strtol+0x5c>
  800cd0:	83 fe 10             	cmp    $0x10,%esi
  800cd3:	75 17                	jne    800cec <strtol+0x73>
  800cd5:	80 3b 30             	cmpb   $0x30,(%ebx)
  800cd8:	75 12                	jne    800cec <strtol+0x73>
  800cda:	80 7b 01 78          	cmpb   $0x78,0x1(%ebx)
  800cde:	66 90                	xchg   %ax,%ax
  800ce0:	75 0a                	jne    800cec <strtol+0x73>
		s += 2, base = 16;
  800ce2:	83 c3 02             	add    $0x2,%ebx
  800ce5:	be 10 00 00 00       	mov    $0x10,%esi
  800cea:	eb 1f                	jmp    800d0b <strtol+0x92>
	else if (base == 0 && s[0] == '0')
  800cec:	85 f6                	test   %esi,%esi
  800cee:	66 90                	xchg   %ax,%ax
  800cf0:	75 10                	jne    800d02 <strtol+0x89>
  800cf2:	80 3b 30             	cmpb   $0x30,(%ebx)
  800cf5:	75 0b                	jne    800d02 <strtol+0x89>
		s++, base = 8;
  800cf7:	83 c3 01             	add    $0x1,%ebx
  800cfa:	66 be 08 00          	mov    $0x8,%si
  800cfe:	66 90                	xchg   %ax,%ax
  800d00:	eb 09                	jmp    800d0b <strtol+0x92>
	else if (base == 0)
  800d02:	84 c0                	test   %al,%al
  800d04:	74 05                	je     800d0b <strtol+0x92>
  800d06:	be 0a 00 00 00       	mov    $0xa,%esi
  800d0b:	bf 00 00 00 00       	mov    $0x0,%edi
		base = 10;

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d10:	0f b6 13             	movzbl (%ebx),%edx
  800d13:	89 d1                	mov    %edx,%ecx
  800d15:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800d18:	3c 09                	cmp    $0x9,%al
  800d1a:	77 08                	ja     800d24 <strtol+0xab>
			dig = *s - '0';
  800d1c:	0f be c2             	movsbl %dl,%eax
  800d1f:	8d 50 d0             	lea    0xffffffd0(%eax),%edx
  800d22:	eb 1c                	jmp    800d40 <strtol+0xc7>
		else if (*s >= 'a' && *s <= 'z')
  800d24:	8d 41 9f             	lea    0xffffff9f(%ecx),%eax
  800d27:	3c 19                	cmp    $0x19,%al
  800d29:	77 08                	ja     800d33 <strtol+0xba>
			dig = *s - 'a' + 10;
  800d2b:	0f be c2             	movsbl %dl,%eax
  800d2e:	8d 50 a9             	lea    0xffffffa9(%eax),%edx
  800d31:	eb 0d                	jmp    800d40 <strtol+0xc7>
		else if (*s >= 'A' && *s <= 'Z')
  800d33:	8d 41 bf             	lea    0xffffffbf(%ecx),%eax
  800d36:	3c 19                	cmp    $0x19,%al
  800d38:	77 17                	ja     800d51 <strtol+0xd8>
			dig = *s - 'A' + 10;
  800d3a:	0f be c2             	movsbl %dl,%eax
  800d3d:	8d 50 c9             	lea    0xffffffc9(%eax),%edx
		else
			break;
		if (dig >= base)
  800d40:	39 f2                	cmp    %esi,%edx
  800d42:	7d 0d                	jge    800d51 <strtol+0xd8>
			break;
		s++, val = (val * base) + dig;
  800d44:	83 c3 01             	add    $0x1,%ebx
  800d47:	89 f8                	mov    %edi,%eax
  800d49:	0f af c6             	imul   %esi,%eax
  800d4c:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800d4f:	eb bf                	jmp    800d10 <strtol+0x97>
		// we don't properly detect overflow!
	}
  800d51:	89 f8                	mov    %edi,%eax

	if (endptr)
  800d53:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d57:	74 05                	je     800d5e <strtol+0xe5>
		*endptr = (char *) s;
  800d59:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d5c:	89 1a                	mov    %ebx,(%edx)
	return (neg ? -val : val);
  800d5e:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800d62:	74 04                	je     800d68 <strtol+0xef>
  800d64:	89 c7                	mov    %eax,%edi
  800d66:	f7 df                	neg    %edi
}
  800d68:	89 f8                	mov    %edi,%eax
  800d6a:	83 c4 04             	add    $0x4,%esp
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    
	...

00800d74 <sys_cgetc>:
}

int
sys_cgetc(void)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	83 ec 0c             	sub    $0xc,%esp
  800d7a:	89 1c 24             	mov    %ebx,(%esp)
  800d7d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d81:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d85:	b8 01 00 00 00       	mov    $0x1,%eax
  800d8a:	bf 00 00 00 00       	mov    $0x0,%edi
  800d8f:	89 fa                	mov    %edi,%edx
  800d91:	89 f9                	mov    %edi,%ecx
  800d93:	89 fb                	mov    %edi,%ebx
  800d95:	89 fe                	mov    %edi,%esi
  800d97:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d99:	8b 1c 24             	mov    (%esp),%ebx
  800d9c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800da0:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800da4:	89 ec                	mov    %ebp,%esp
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    

00800da8 <sys_cputs>:
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	83 ec 0c             	sub    $0xc,%esp
  800dae:	89 1c 24             	mov    %ebx,(%esp)
  800db1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800db5:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800db9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbf:	bf 00 00 00 00       	mov    $0x0,%edi
  800dc4:	89 f8                	mov    %edi,%eax
  800dc6:	89 fb                	mov    %edi,%ebx
  800dc8:	89 fe                	mov    %edi,%esi
  800dca:	cd 30                	int    $0x30
  800dcc:	8b 1c 24             	mov    (%esp),%ebx
  800dcf:	8b 74 24 04          	mov    0x4(%esp),%esi
  800dd3:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800dd7:	89 ec                	mov    %ebp,%esp
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    

00800ddb <sys_time_msec>:

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
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	83 ec 0c             	sub    $0xc,%esp
  800de1:	89 1c 24             	mov    %ebx,(%esp)
  800de4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800de8:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800dec:	b8 0e 00 00 00       	mov    $0xe,%eax
  800df1:	bf 00 00 00 00       	mov    $0x0,%edi
  800df6:	89 fa                	mov    %edi,%edx
  800df8:	89 f9                	mov    %edi,%ecx
  800dfa:	89 fb                	mov    %edi,%ebx
  800dfc:	89 fe                	mov    %edi,%esi
  800dfe:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e00:	8b 1c 24             	mov    (%esp),%ebx
  800e03:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e07:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e0b:	89 ec                	mov    %ebp,%esp
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <sys_ipc_recv>:
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	83 ec 28             	sub    $0x28,%esp
  800e15:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800e18:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800e1b:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800e1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e21:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e26:	bf 00 00 00 00       	mov    $0x0,%edi
  800e2b:	89 f9                	mov    %edi,%ecx
  800e2d:	89 fb                	mov    %edi,%ebx
  800e2f:	89 fe                	mov    %edi,%esi
  800e31:	cd 30                	int    $0x30
  800e33:	85 c0                	test   %eax,%eax
  800e35:	7e 28                	jle    800e5f <sys_ipc_recv+0x50>
  800e37:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3b:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e42:	00 
  800e43:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  800e4a:	00 
  800e4b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e52:	00 
  800e53:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  800e5a:	e8 19 11 00 00       	call   801f78 <_panic>
  800e5f:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800e62:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800e65:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800e68:	89 ec                	mov    %ebp,%esp
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    

00800e6c <sys_ipc_try_send>:
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	83 ec 0c             	sub    $0xc,%esp
  800e72:	89 1c 24             	mov    %ebx,(%esp)
  800e75:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e79:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e83:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e86:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e89:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e8e:	be 00 00 00 00       	mov    $0x0,%esi
  800e93:	cd 30                	int    $0x30
  800e95:	8b 1c 24             	mov    (%esp),%ebx
  800e98:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e9c:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ea0:	89 ec                	mov    %ebp,%esp
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    

00800ea4 <sys_env_set_pgfault_upcall>:
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	83 ec 28             	sub    $0x28,%esp
  800eaa:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800ead:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800eb0:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800eb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ebe:	bf 00 00 00 00       	mov    $0x0,%edi
  800ec3:	89 fb                	mov    %edi,%ebx
  800ec5:	89 fe                	mov    %edi,%esi
  800ec7:	cd 30                	int    $0x30
  800ec9:	85 c0                	test   %eax,%eax
  800ecb:	7e 28                	jle    800ef5 <sys_env_set_pgfault_upcall+0x51>
  800ecd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed1:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ed8:	00 
  800ed9:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  800ee0:	00 
  800ee1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee8:	00 
  800ee9:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  800ef0:	e8 83 10 00 00       	call   801f78 <_panic>
  800ef5:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800ef8:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800efb:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800efe:	89 ec                	mov    %ebp,%esp
  800f00:	5d                   	pop    %ebp
  800f01:	c3                   	ret    

00800f02 <sys_env_set_trapframe>:
  800f02:	55                   	push   %ebp
  800f03:	89 e5                	mov    %esp,%ebp
  800f05:	83 ec 28             	sub    $0x28,%esp
  800f08:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800f0b:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800f0e:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800f11:	8b 55 08             	mov    0x8(%ebp),%edx
  800f14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f17:	b8 09 00 00 00       	mov    $0x9,%eax
  800f1c:	bf 00 00 00 00       	mov    $0x0,%edi
  800f21:	89 fb                	mov    %edi,%ebx
  800f23:	89 fe                	mov    %edi,%esi
  800f25:	cd 30                	int    $0x30
  800f27:	85 c0                	test   %eax,%eax
  800f29:	7e 28                	jle    800f53 <sys_env_set_trapframe+0x51>
  800f2b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f2f:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f36:	00 
  800f37:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  800f3e:	00 
  800f3f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f46:	00 
  800f47:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  800f4e:	e8 25 10 00 00       	call   801f78 <_panic>
  800f53:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800f56:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800f59:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800f5c:	89 ec                	mov    %ebp,%esp
  800f5e:	5d                   	pop    %ebp
  800f5f:	c3                   	ret    

00800f60 <sys_env_set_status>:
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	83 ec 28             	sub    $0x28,%esp
  800f66:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800f69:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800f6c:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800f6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f75:	b8 08 00 00 00       	mov    $0x8,%eax
  800f7a:	bf 00 00 00 00       	mov    $0x0,%edi
  800f7f:	89 fb                	mov    %edi,%ebx
  800f81:	89 fe                	mov    %edi,%esi
  800f83:	cd 30                	int    $0x30
  800f85:	85 c0                	test   %eax,%eax
  800f87:	7e 28                	jle    800fb1 <sys_env_set_status+0x51>
  800f89:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f8d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f94:	00 
  800f95:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  800f9c:	00 
  800f9d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa4:	00 
  800fa5:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  800fac:	e8 c7 0f 00 00       	call   801f78 <_panic>
  800fb1:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800fb4:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800fb7:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800fba:	89 ec                	mov    %ebp,%esp
  800fbc:	5d                   	pop    %ebp
  800fbd:	c3                   	ret    

00800fbe <sys_page_unmap>:
  800fbe:	55                   	push   %ebp
  800fbf:	89 e5                	mov    %esp,%ebp
  800fc1:	83 ec 28             	sub    $0x28,%esp
  800fc4:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800fc7:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800fca:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800fcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd3:	b8 06 00 00 00       	mov    $0x6,%eax
  800fd8:	bf 00 00 00 00       	mov    $0x0,%edi
  800fdd:	89 fb                	mov    %edi,%ebx
  800fdf:	89 fe                	mov    %edi,%esi
  800fe1:	cd 30                	int    $0x30
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	7e 28                	jle    80100f <sys_page_unmap+0x51>
  800fe7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800feb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ff2:	00 
  800ff3:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  800ffa:	00 
  800ffb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801002:	00 
  801003:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  80100a:	e8 69 0f 00 00       	call   801f78 <_panic>
  80100f:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801012:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801015:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801018:	89 ec                	mov    %ebp,%esp
  80101a:	5d                   	pop    %ebp
  80101b:	c3                   	ret    

0080101c <sys_page_map>:
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	83 ec 28             	sub    $0x28,%esp
  801022:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  801025:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  801028:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  80102b:	8b 55 08             	mov    0x8(%ebp),%edx
  80102e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801031:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801034:	8b 7d 14             	mov    0x14(%ebp),%edi
  801037:	8b 75 18             	mov    0x18(%ebp),%esi
  80103a:	b8 05 00 00 00       	mov    $0x5,%eax
  80103f:	cd 30                	int    $0x30
  801041:	85 c0                	test   %eax,%eax
  801043:	7e 28                	jle    80106d <sys_page_map+0x51>
  801045:	89 44 24 10          	mov    %eax,0x10(%esp)
  801049:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801050:	00 
  801051:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  801058:	00 
  801059:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801060:	00 
  801061:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  801068:	e8 0b 0f 00 00       	call   801f78 <_panic>
  80106d:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801070:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801073:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801076:	89 ec                	mov    %ebp,%esp
  801078:	5d                   	pop    %ebp
  801079:	c3                   	ret    

0080107a <sys_page_alloc>:
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
  80107d:	83 ec 28             	sub    $0x28,%esp
  801080:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  801083:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  801086:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  801089:	8b 55 08             	mov    0x8(%ebp),%edx
  80108c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80108f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801092:	b8 04 00 00 00       	mov    $0x4,%eax
  801097:	bf 00 00 00 00       	mov    $0x0,%edi
  80109c:	89 fe                	mov    %edi,%esi
  80109e:	cd 30                	int    $0x30
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	7e 28                	jle    8010cc <sys_page_alloc+0x52>
  8010a4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010a8:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8010af:	00 
  8010b0:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  8010b7:	00 
  8010b8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010bf:	00 
  8010c0:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  8010c7:	e8 ac 0e 00 00       	call   801f78 <_panic>
  8010cc:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  8010cf:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  8010d2:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  8010d5:	89 ec                	mov    %ebp,%esp
  8010d7:	5d                   	pop    %ebp
  8010d8:	c3                   	ret    

008010d9 <sys_yield>:
  8010d9:	55                   	push   %ebp
  8010da:	89 e5                	mov    %esp,%ebp
  8010dc:	83 ec 0c             	sub    $0xc,%esp
  8010df:	89 1c 24             	mov    %ebx,(%esp)
  8010e2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010e6:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010ea:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010ef:	bf 00 00 00 00       	mov    $0x0,%edi
  8010f4:	89 fa                	mov    %edi,%edx
  8010f6:	89 f9                	mov    %edi,%ecx
  8010f8:	89 fb                	mov    %edi,%ebx
  8010fa:	89 fe                	mov    %edi,%esi
  8010fc:	cd 30                	int    $0x30
  8010fe:	8b 1c 24             	mov    (%esp),%ebx
  801101:	8b 74 24 04          	mov    0x4(%esp),%esi
  801105:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801109:	89 ec                	mov    %ebp,%esp
  80110b:	5d                   	pop    %ebp
  80110c:	c3                   	ret    

0080110d <sys_getenvid>:
  80110d:	55                   	push   %ebp
  80110e:	89 e5                	mov    %esp,%ebp
  801110:	83 ec 0c             	sub    $0xc,%esp
  801113:	89 1c 24             	mov    %ebx,(%esp)
  801116:	89 74 24 04          	mov    %esi,0x4(%esp)
  80111a:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80111e:	b8 02 00 00 00       	mov    $0x2,%eax
  801123:	bf 00 00 00 00       	mov    $0x0,%edi
  801128:	89 fa                	mov    %edi,%edx
  80112a:	89 f9                	mov    %edi,%ecx
  80112c:	89 fb                	mov    %edi,%ebx
  80112e:	89 fe                	mov    %edi,%esi
  801130:	cd 30                	int    $0x30
  801132:	8b 1c 24             	mov    (%esp),%ebx
  801135:	8b 74 24 04          	mov    0x4(%esp),%esi
  801139:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80113d:	89 ec                	mov    %ebp,%esp
  80113f:	5d                   	pop    %ebp
  801140:	c3                   	ret    

00801141 <sys_env_destroy>:
  801141:	55                   	push   %ebp
  801142:	89 e5                	mov    %esp,%ebp
  801144:	83 ec 28             	sub    $0x28,%esp
  801147:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  80114a:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  80114d:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  801150:	8b 55 08             	mov    0x8(%ebp),%edx
  801153:	b8 03 00 00 00       	mov    $0x3,%eax
  801158:	bf 00 00 00 00       	mov    $0x0,%edi
  80115d:	89 f9                	mov    %edi,%ecx
  80115f:	89 fb                	mov    %edi,%ebx
  801161:	89 fe                	mov    %edi,%esi
  801163:	cd 30                	int    $0x30
  801165:	85 c0                	test   %eax,%eax
  801167:	7e 28                	jle    801191 <sys_env_destroy+0x50>
  801169:	89 44 24 10          	mov    %eax,0x10(%esp)
  80116d:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801174:	00 
  801175:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  80117c:	00 
  80117d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801184:	00 
  801185:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  80118c:	e8 e7 0d 00 00       	call   801f78 <_panic>
  801191:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801194:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801197:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  80119a:	89 ec                	mov    %ebp,%esp
  80119c:	5d                   	pop    %ebp
  80119d:	c3                   	ret    
	...

008011a0 <fd2num>:
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011ab:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8011ae:	5d                   	pop    %ebp
  8011af:	c3                   	ret    

008011b0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
  8011b3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8011b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b9:	89 04 24             	mov    %eax,(%esp)
  8011bc:	e8 df ff ff ff       	call   8011a0 <fd2num>
  8011c1:	c1 e0 0c             	shl    $0xc,%eax
  8011c4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011c9:	c9                   	leave  
  8011ca:	c3                   	ret    

008011cb <fd_alloc>:

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
  8011cb:	55                   	push   %ebp
  8011cc:	89 e5                	mov    %esp,%ebp
  8011ce:	53                   	push   %ebx
  8011cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8011d2:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  8011d7:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  8011d9:	89 d0                	mov    %edx,%eax
  8011db:	c1 e8 16             	shr    $0x16,%eax
  8011de:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  8011e5:	a8 01                	test   $0x1,%al
  8011e7:	74 10                	je     8011f9 <fd_alloc+0x2e>
  8011e9:	89 d0                	mov    %edx,%eax
  8011eb:	c1 e8 0c             	shr    $0xc,%eax
  8011ee:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  8011f5:	a8 01                	test   $0x1,%al
  8011f7:	75 09                	jne    801202 <fd_alloc+0x37>
			*fd_store = fd;
  8011f9:	89 0b                	mov    %ecx,(%ebx)
  8011fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801200:	eb 19                	jmp    80121b <fd_alloc+0x50>
			return 0;
  801202:	81 c2 00 10 00 00    	add    $0x1000,%edx
  801208:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  80120e:	75 c7                	jne    8011d7 <fd_alloc+0xc>
		}
	}
	*fd_store = 0;
  801210:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801216:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  80121b:	5b                   	pop    %ebx
  80121c:	5d                   	pop    %ebp
  80121d:	c3                   	ret    

0080121e <fd_lookup>:

// Check that fdnum is in range and mapped.
// If it is, set *fd_store to the fd page virtual address.
//
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80121e:	55                   	push   %ebp
  80121f:	89 e5                	mov    %esp,%ebp
  801221:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801224:	83 f8 1f             	cmp    $0x1f,%eax
  801227:	77 35                	ja     80125e <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801229:	c1 e0 0c             	shl    $0xc,%eax
  80122c:	8d 90 00 00 00 d0    	lea    0xd0000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  801232:	89 d0                	mov    %edx,%eax
  801234:	c1 e8 16             	shr    $0x16,%eax
  801237:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  80123e:	a8 01                	test   $0x1,%al
  801240:	74 1c                	je     80125e <fd_lookup+0x40>
  801242:	89 d0                	mov    %edx,%eax
  801244:	c1 e8 0c             	shr    $0xc,%eax
  801247:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  80124e:	a8 01                	test   $0x1,%al
  801250:	74 0c                	je     80125e <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801252:	8b 45 0c             	mov    0xc(%ebp),%eax
  801255:	89 10                	mov    %edx,(%eax)
  801257:	b8 00 00 00 00       	mov    $0x0,%eax
  80125c:	eb 05                	jmp    801263 <fd_lookup+0x45>
	return 0;
  80125e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801263:	5d                   	pop    %ebp
  801264:	c3                   	ret    

00801265 <seek>:

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
  801265:	55                   	push   %ebp
  801266:	89 e5                	mov    %esp,%ebp
  801268:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80126b:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  80126e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801272:	8b 45 08             	mov    0x8(%ebp),%eax
  801275:	89 04 24             	mov    %eax,(%esp)
  801278:	e8 a1 ff ff ff       	call   80121e <fd_lookup>
  80127d:	85 c0                	test   %eax,%eax
  80127f:	78 0e                	js     80128f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801281:	8b 55 0c             	mov    0xc(%ebp),%edx
  801284:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  801287:	89 50 04             	mov    %edx,0x4(%eax)
  80128a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80128f:	c9                   	leave  
  801290:	c3                   	ret    

00801291 <dev_lookup>:
  801291:	55                   	push   %ebp
  801292:	89 e5                	mov    %esp,%ebp
  801294:	53                   	push   %ebx
  801295:	83 ec 14             	sub    $0x14,%esp
  801298:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80129b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80129e:	ba 08 60 80 00       	mov    $0x806008,%edx
  8012a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a8:	39 0d 08 60 80 00    	cmp    %ecx,0x806008
  8012ae:	75 12                	jne    8012c2 <dev_lookup+0x31>
  8012b0:	eb 04                	jmp    8012b6 <dev_lookup+0x25>
  8012b2:	39 0a                	cmp    %ecx,(%edx)
  8012b4:	75 0c                	jne    8012c2 <dev_lookup+0x31>
  8012b6:	89 13                	mov    %edx,(%ebx)
  8012b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012bd:	8d 76 00             	lea    0x0(%esi),%esi
  8012c0:	eb 35                	jmp    8012f7 <dev_lookup+0x66>
  8012c2:	83 c0 01             	add    $0x1,%eax
  8012c5:	8b 14 85 2c 2c 80 00 	mov    0x802c2c(,%eax,4),%edx
  8012cc:	85 d2                	test   %edx,%edx
  8012ce:	75 e2                	jne    8012b2 <dev_lookup+0x21>
  8012d0:	a1 50 60 80 00       	mov    0x806050,%eax
  8012d5:	8b 40 4c             	mov    0x4c(%eax),%eax
  8012d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e0:	c7 04 24 ac 2b 80 00 	movl   $0x802bac,(%esp)
  8012e7:	e8 dd ef ff ff       	call   8002c9 <cprintf>
  8012ec:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8012f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f7:	83 c4 14             	add    $0x14,%esp
  8012fa:	5b                   	pop    %ebx
  8012fb:	5d                   	pop    %ebp
  8012fc:	c3                   	ret    

008012fd <fstat>:

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
  8012fd:	55                   	push   %ebp
  8012fe:	89 e5                	mov    %esp,%ebp
  801300:	53                   	push   %ebx
  801301:	83 ec 24             	sub    $0x24,%esp
  801304:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801307:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80130a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130e:	8b 45 08             	mov    0x8(%ebp),%eax
  801311:	89 04 24             	mov    %eax,(%esp)
  801314:	e8 05 ff ff ff       	call   80121e <fd_lookup>
  801319:	89 c2                	mov    %eax,%edx
  80131b:	85 c0                	test   %eax,%eax
  80131d:	78 57                	js     801376 <fstat+0x79>
  80131f:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801322:	89 44 24 04          	mov    %eax,0x4(%esp)
  801326:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801329:	8b 00                	mov    (%eax),%eax
  80132b:	89 04 24             	mov    %eax,(%esp)
  80132e:	e8 5e ff ff ff       	call   801291 <dev_lookup>
  801333:	89 c2                	mov    %eax,%edx
  801335:	85 c0                	test   %eax,%eax
  801337:	78 3d                	js     801376 <fstat+0x79>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801339:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  80133e:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
  801341:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801345:	74 2f                	je     801376 <fstat+0x79>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801347:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80134a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801351:	00 00 00 
	stat->st_isdir = 0;
  801354:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80135b:	00 00 00 
	stat->st_dev = dev;
  80135e:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801361:	89 93 88 00 00 00    	mov    %edx,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801367:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80136b:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80136e:	89 04 24             	mov    %eax,(%esp)
  801371:	ff 52 14             	call   *0x14(%edx)
  801374:	89 c2                	mov    %eax,%edx
}
  801376:	89 d0                	mov    %edx,%eax
  801378:	83 c4 24             	add    $0x24,%esp
  80137b:	5b                   	pop    %ebx
  80137c:	5d                   	pop    %ebp
  80137d:	c3                   	ret    

0080137e <ftruncate>:
  80137e:	55                   	push   %ebp
  80137f:	89 e5                	mov    %esp,%ebp
  801381:	53                   	push   %ebx
  801382:	83 ec 24             	sub    $0x24,%esp
  801385:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801388:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80138b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80138f:	89 1c 24             	mov    %ebx,(%esp)
  801392:	e8 87 fe ff ff       	call   80121e <fd_lookup>
  801397:	85 c0                	test   %eax,%eax
  801399:	78 61                	js     8013fc <ftruncate+0x7e>
  80139b:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80139e:	8b 10                	mov    (%eax),%edx
  8013a0:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  8013a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a7:	89 14 24             	mov    %edx,(%esp)
  8013aa:	e8 e2 fe ff ff       	call   801291 <dev_lookup>
  8013af:	85 c0                	test   %eax,%eax
  8013b1:	78 49                	js     8013fc <ftruncate+0x7e>
  8013b3:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  8013b6:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  8013ba:	75 23                	jne    8013df <ftruncate+0x61>
  8013bc:	a1 50 60 80 00       	mov    0x806050,%eax
  8013c1:	8b 40 4c             	mov    0x4c(%eax),%eax
  8013c4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013cc:	c7 04 24 cc 2b 80 00 	movl   $0x802bcc,(%esp)
  8013d3:	e8 f1 ee ff ff       	call   8002c9 <cprintf>
  8013d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013dd:	eb 1d                	jmp    8013fc <ftruncate+0x7e>
  8013df:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  8013e2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013e7:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  8013eb:	74 0f                	je     8013fc <ftruncate+0x7e>
  8013ed:	8b 52 18             	mov    0x18(%edx),%edx
  8013f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f7:	89 0c 24             	mov    %ecx,(%esp)
  8013fa:	ff d2                	call   *%edx
  8013fc:	83 c4 24             	add    $0x24,%esp
  8013ff:	5b                   	pop    %ebx
  801400:	5d                   	pop    %ebp
  801401:	c3                   	ret    

00801402 <write>:
  801402:	55                   	push   %ebp
  801403:	89 e5                	mov    %esp,%ebp
  801405:	53                   	push   %ebx
  801406:	83 ec 24             	sub    $0x24,%esp
  801409:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80140c:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80140f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801413:	89 1c 24             	mov    %ebx,(%esp)
  801416:	e8 03 fe ff ff       	call   80121e <fd_lookup>
  80141b:	85 c0                	test   %eax,%eax
  80141d:	78 68                	js     801487 <write+0x85>
  80141f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801422:	8b 10                	mov    (%eax),%edx
  801424:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801427:	89 44 24 04          	mov    %eax,0x4(%esp)
  80142b:	89 14 24             	mov    %edx,(%esp)
  80142e:	e8 5e fe ff ff       	call   801291 <dev_lookup>
  801433:	85 c0                	test   %eax,%eax
  801435:	78 50                	js     801487 <write+0x85>
  801437:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  80143a:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  80143e:	75 23                	jne    801463 <write+0x61>
  801440:	a1 50 60 80 00       	mov    0x806050,%eax
  801445:	8b 40 4c             	mov    0x4c(%eax),%eax
  801448:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80144c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801450:	c7 04 24 f0 2b 80 00 	movl   $0x802bf0,(%esp)
  801457:	e8 6d ee ff ff       	call   8002c9 <cprintf>
  80145c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801461:	eb 24                	jmp    801487 <write+0x85>
  801463:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801466:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80146b:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  80146f:	74 16                	je     801487 <write+0x85>
  801471:	8b 42 0c             	mov    0xc(%edx),%eax
  801474:	8b 55 10             	mov    0x10(%ebp),%edx
  801477:	89 54 24 08          	mov    %edx,0x8(%esp)
  80147b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80147e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801482:	89 0c 24             	mov    %ecx,(%esp)
  801485:	ff d0                	call   *%eax
  801487:	83 c4 24             	add    $0x24,%esp
  80148a:	5b                   	pop    %ebx
  80148b:	5d                   	pop    %ebp
  80148c:	c3                   	ret    

0080148d <read>:
  80148d:	55                   	push   %ebp
  80148e:	89 e5                	mov    %esp,%ebp
  801490:	53                   	push   %ebx
  801491:	83 ec 24             	sub    $0x24,%esp
  801494:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801497:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80149a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80149e:	89 1c 24             	mov    %ebx,(%esp)
  8014a1:	e8 78 fd ff ff       	call   80121e <fd_lookup>
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	78 6d                	js     801517 <read+0x8a>
  8014aa:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8014ad:	8b 10                	mov    (%eax),%edx
  8014af:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  8014b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b6:	89 14 24             	mov    %edx,(%esp)
  8014b9:	e8 d3 fd ff ff       	call   801291 <dev_lookup>
  8014be:	85 c0                	test   %eax,%eax
  8014c0:	78 55                	js     801517 <read+0x8a>
  8014c2:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  8014c5:	8b 41 08             	mov    0x8(%ecx),%eax
  8014c8:	83 e0 03             	and    $0x3,%eax
  8014cb:	83 f8 01             	cmp    $0x1,%eax
  8014ce:	75 23                	jne    8014f3 <read+0x66>
  8014d0:	a1 50 60 80 00       	mov    0x806050,%eax
  8014d5:	8b 40 4c             	mov    0x4c(%eax),%eax
  8014d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e0:	c7 04 24 0d 2c 80 00 	movl   $0x802c0d,(%esp)
  8014e7:	e8 dd ed ff ff       	call   8002c9 <cprintf>
  8014ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014f1:	eb 24                	jmp    801517 <read+0x8a>
  8014f3:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  8014f6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014fb:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  8014ff:	74 16                	je     801517 <read+0x8a>
  801501:	8b 42 08             	mov    0x8(%edx),%eax
  801504:	8b 55 10             	mov    0x10(%ebp),%edx
  801507:	89 54 24 08          	mov    %edx,0x8(%esp)
  80150b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80150e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801512:	89 0c 24             	mov    %ecx,(%esp)
  801515:	ff d0                	call   *%eax
  801517:	83 c4 24             	add    $0x24,%esp
  80151a:	5b                   	pop    %ebx
  80151b:	5d                   	pop    %ebp
  80151c:	c3                   	ret    

0080151d <readn>:
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	57                   	push   %edi
  801521:	56                   	push   %esi
  801522:	53                   	push   %ebx
  801523:	83 ec 0c             	sub    $0xc,%esp
  801526:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801529:	8b 75 10             	mov    0x10(%ebp),%esi
  80152c:	b8 00 00 00 00       	mov    $0x0,%eax
  801531:	85 f6                	test   %esi,%esi
  801533:	74 36                	je     80156b <readn+0x4e>
  801535:	bb 00 00 00 00       	mov    $0x0,%ebx
  80153a:	ba 00 00 00 00       	mov    $0x0,%edx
  80153f:	89 f0                	mov    %esi,%eax
  801541:	29 d0                	sub    %edx,%eax
  801543:	89 44 24 08          	mov    %eax,0x8(%esp)
  801547:	8d 04 17             	lea    (%edi,%edx,1),%eax
  80154a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80154e:	8b 45 08             	mov    0x8(%ebp),%eax
  801551:	89 04 24             	mov    %eax,(%esp)
  801554:	e8 34 ff ff ff       	call   80148d <read>
  801559:	85 c0                	test   %eax,%eax
  80155b:	78 0e                	js     80156b <readn+0x4e>
  80155d:	85 c0                	test   %eax,%eax
  80155f:	74 08                	je     801569 <readn+0x4c>
  801561:	01 c3                	add    %eax,%ebx
  801563:	89 da                	mov    %ebx,%edx
  801565:	39 f3                	cmp    %esi,%ebx
  801567:	72 d6                	jb     80153f <readn+0x22>
  801569:	89 d8                	mov    %ebx,%eax
  80156b:	83 c4 0c             	add    $0xc,%esp
  80156e:	5b                   	pop    %ebx
  80156f:	5e                   	pop    %esi
  801570:	5f                   	pop    %edi
  801571:	5d                   	pop    %ebp
  801572:	c3                   	ret    

00801573 <fd_close>:
  801573:	55                   	push   %ebp
  801574:	89 e5                	mov    %esp,%ebp
  801576:	83 ec 28             	sub    $0x28,%esp
  801579:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  80157c:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  80157f:	8b 75 08             	mov    0x8(%ebp),%esi
  801582:	89 34 24             	mov    %esi,(%esp)
  801585:	e8 16 fc ff ff       	call   8011a0 <fd2num>
  80158a:	8d 55 f4             	lea    0xfffffff4(%ebp),%edx
  80158d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801591:	89 04 24             	mov    %eax,(%esp)
  801594:	e8 85 fc ff ff       	call   80121e <fd_lookup>
  801599:	89 c3                	mov    %eax,%ebx
  80159b:	85 c0                	test   %eax,%eax
  80159d:	78 05                	js     8015a4 <fd_close+0x31>
  80159f:	3b 75 f4             	cmp    0xfffffff4(%ebp),%esi
  8015a2:	74 0e                	je     8015b2 <fd_close+0x3f>
  8015a4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8015a8:	75 45                	jne    8015ef <fd_close+0x7c>
  8015aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015af:	90                   	nop    
  8015b0:	eb 3d                	jmp    8015ef <fd_close+0x7c>
  8015b2:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  8015b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b9:	8b 06                	mov    (%esi),%eax
  8015bb:	89 04 24             	mov    %eax,(%esp)
  8015be:	e8 ce fc ff ff       	call   801291 <dev_lookup>
  8015c3:	89 c3                	mov    %eax,%ebx
  8015c5:	85 c0                	test   %eax,%eax
  8015c7:	78 16                	js     8015df <fd_close+0x6c>
  8015c9:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8015cc:	8b 40 10             	mov    0x10(%eax),%eax
  8015cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	74 07                	je     8015df <fd_close+0x6c>
  8015d8:	89 34 24             	mov    %esi,(%esp)
  8015db:	ff d0                	call   *%eax
  8015dd:	89 c3                	mov    %eax,%ebx
  8015df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015ea:	e8 cf f9 ff ff       	call   800fbe <sys_page_unmap>
  8015ef:	89 d8                	mov    %ebx,%eax
  8015f1:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  8015f4:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  8015f7:	89 ec                	mov    %ebp,%esp
  8015f9:	5d                   	pop    %ebp
  8015fa:	c3                   	ret    

008015fb <close>:
  8015fb:	55                   	push   %ebp
  8015fc:	89 e5                	mov    %esp,%ebp
  8015fe:	83 ec 18             	sub    $0x18,%esp
  801601:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  801604:	89 44 24 04          	mov    %eax,0x4(%esp)
  801608:	8b 45 08             	mov    0x8(%ebp),%eax
  80160b:	89 04 24             	mov    %eax,(%esp)
  80160e:	e8 0b fc ff ff       	call   80121e <fd_lookup>
  801613:	85 c0                	test   %eax,%eax
  801615:	78 13                	js     80162a <close+0x2f>
  801617:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80161e:	00 
  80161f:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  801622:	89 04 24             	mov    %eax,(%esp)
  801625:	e8 49 ff ff ff       	call   801573 <fd_close>
  80162a:	c9                   	leave  
  80162b:	c3                   	ret    

0080162c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80162c:	55                   	push   %ebp
  80162d:	89 e5                	mov    %esp,%ebp
  80162f:	83 ec 18             	sub    $0x18,%esp
  801632:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  801635:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801638:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80163f:	00 
  801640:	8b 45 08             	mov    0x8(%ebp),%eax
  801643:	89 04 24             	mov    %eax,(%esp)
  801646:	e8 58 03 00 00       	call   8019a3 <open>
  80164b:	89 c6                	mov    %eax,%esi
  80164d:	85 c0                	test   %eax,%eax
  80164f:	78 1b                	js     80166c <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801651:	8b 45 0c             	mov    0xc(%ebp),%eax
  801654:	89 44 24 04          	mov    %eax,0x4(%esp)
  801658:	89 34 24             	mov    %esi,(%esp)
  80165b:	e8 9d fc ff ff       	call   8012fd <fstat>
  801660:	89 c3                	mov    %eax,%ebx
	close(fd);
  801662:	89 34 24             	mov    %esi,(%esp)
  801665:	e8 91 ff ff ff       	call   8015fb <close>
  80166a:	89 de                	mov    %ebx,%esi
	return r;
}
  80166c:	89 f0                	mov    %esi,%eax
  80166e:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  801671:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  801674:	89 ec                	mov    %ebp,%esp
  801676:	5d                   	pop    %ebp
  801677:	c3                   	ret    

00801678 <dup>:
  801678:	55                   	push   %ebp
  801679:	89 e5                	mov    %esp,%ebp
  80167b:	83 ec 38             	sub    $0x38,%esp
  80167e:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  801681:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  801684:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  801687:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80168a:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  80168d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801691:	8b 45 08             	mov    0x8(%ebp),%eax
  801694:	89 04 24             	mov    %eax,(%esp)
  801697:	e8 82 fb ff ff       	call   80121e <fd_lookup>
  80169c:	89 c3                	mov    %eax,%ebx
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	0f 88 e1 00 00 00    	js     801787 <dup+0x10f>
  8016a6:	89 3c 24             	mov    %edi,(%esp)
  8016a9:	e8 4d ff ff ff       	call   8015fb <close>
  8016ae:	89 f8                	mov    %edi,%eax
  8016b0:	c1 e0 0c             	shl    $0xc,%eax
  8016b3:	8d b0 00 00 00 d0    	lea    0xd0000000(%eax),%esi
  8016b9:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8016bc:	89 04 24             	mov    %eax,(%esp)
  8016bf:	e8 ec fa ff ff       	call   8011b0 <fd2data>
  8016c4:	89 c3                	mov    %eax,%ebx
  8016c6:	89 34 24             	mov    %esi,(%esp)
  8016c9:	e8 e2 fa ff ff       	call   8011b0 <fd2data>
  8016ce:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  8016d1:	89 d8                	mov    %ebx,%eax
  8016d3:	c1 e8 16             	shr    $0x16,%eax
  8016d6:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  8016dd:	a8 01                	test   $0x1,%al
  8016df:	74 45                	je     801726 <dup+0xae>
  8016e1:	89 da                	mov    %ebx,%edx
  8016e3:	c1 ea 0c             	shr    $0xc,%edx
  8016e6:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  8016ed:	a8 01                	test   $0x1,%al
  8016ef:	74 35                	je     801726 <dup+0xae>
  8016f1:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  8016f8:	25 07 0e 00 00       	and    $0xe07,%eax
  8016fd:	89 44 24 10          	mov    %eax,0x10(%esp)
  801701:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  801704:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801708:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80170f:	00 
  801710:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801714:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80171b:	e8 fc f8 ff ff       	call   80101c <sys_page_map>
  801720:	89 c3                	mov    %eax,%ebx
  801722:	85 c0                	test   %eax,%eax
  801724:	78 3e                	js     801764 <dup+0xec>
  801726:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  801729:	89 d0                	mov    %edx,%eax
  80172b:	c1 e8 0c             	shr    $0xc,%eax
  80172e:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  801735:	25 07 0e 00 00       	and    $0xe07,%eax
  80173a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80173e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801742:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801749:	00 
  80174a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80174e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801755:	e8 c2 f8 ff ff       	call   80101c <sys_page_map>
  80175a:	89 c3                	mov    %eax,%ebx
  80175c:	85 c0                	test   %eax,%eax
  80175e:	78 04                	js     801764 <dup+0xec>
  801760:	89 fb                	mov    %edi,%ebx
  801762:	eb 23                	jmp    801787 <dup+0x10f>
  801764:	89 74 24 04          	mov    %esi,0x4(%esp)
  801768:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80176f:	e8 4a f8 ff ff       	call   800fbe <sys_page_unmap>
  801774:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  801777:	89 44 24 04          	mov    %eax,0x4(%esp)
  80177b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801782:	e8 37 f8 ff ff       	call   800fbe <sys_page_unmap>
  801787:	89 d8                	mov    %ebx,%eax
  801789:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  80178c:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  80178f:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801792:	89 ec                	mov    %ebp,%esp
  801794:	5d                   	pop    %ebp
  801795:	c3                   	ret    

00801796 <close_all>:
  801796:	55                   	push   %ebp
  801797:	89 e5                	mov    %esp,%ebp
  801799:	53                   	push   %ebx
  80179a:	83 ec 04             	sub    $0x4,%esp
  80179d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017a2:	89 1c 24             	mov    %ebx,(%esp)
  8017a5:	e8 51 fe ff ff       	call   8015fb <close>
  8017aa:	83 c3 01             	add    $0x1,%ebx
  8017ad:	83 fb 20             	cmp    $0x20,%ebx
  8017b0:	75 f0                	jne    8017a2 <close_all+0xc>
  8017b2:	83 c4 04             	add    $0x4,%esp
  8017b5:	5b                   	pop    %ebx
  8017b6:	5d                   	pop    %ebp
  8017b7:	c3                   	ret    

008017b8 <fsipc>:
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017b8:	55                   	push   %ebp
  8017b9:	89 e5                	mov    %esp,%ebp
  8017bb:	53                   	push   %ebx
  8017bc:	83 ec 14             	sub    $0x14,%esp
  8017bf:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017c1:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  8017c7:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8017ce:	00 
  8017cf:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  8017d6:	00 
  8017d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017db:	89 14 24             	mov    %edx,(%esp)
  8017de:	e8 0d 08 00 00       	call   801ff0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017e3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017ea:	00 
  8017eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017f6:	e8 a9 08 00 00       	call   8020a4 <ipc_recv>
}
  8017fb:	83 c4 14             	add    $0x14,%esp
  8017fe:	5b                   	pop    %ebx
  8017ff:	5d                   	pop    %ebp
  801800:	c3                   	ret    

00801801 <sync>:

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
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801807:	ba 00 00 00 00       	mov    $0x0,%edx
  80180c:	b8 08 00 00 00       	mov    $0x8,%eax
  801811:	e8 a2 ff ff ff       	call   8017b8 <fsipc>
}
  801816:	c9                   	leave  
  801817:	c3                   	ret    

00801818 <devfile_trunc>:
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
  80181b:	83 ec 08             	sub    $0x8,%esp
  80181e:	8b 45 08             	mov    0x8(%ebp),%eax
  801821:	8b 40 0c             	mov    0xc(%eax),%eax
  801824:	a3 00 30 80 00       	mov    %eax,0x803000
  801829:	8b 45 0c             	mov    0xc(%ebp),%eax
  80182c:	a3 04 30 80 00       	mov    %eax,0x803004
  801831:	ba 00 00 00 00       	mov    $0x0,%edx
  801836:	b8 02 00 00 00       	mov    $0x2,%eax
  80183b:	e8 78 ff ff ff       	call   8017b8 <fsipc>
  801840:	c9                   	leave  
  801841:	c3                   	ret    

00801842 <devfile_flush>:
  801842:	55                   	push   %ebp
  801843:	89 e5                	mov    %esp,%ebp
  801845:	83 ec 08             	sub    $0x8,%esp
  801848:	8b 45 08             	mov    0x8(%ebp),%eax
  80184b:	8b 40 0c             	mov    0xc(%eax),%eax
  80184e:	a3 00 30 80 00       	mov    %eax,0x803000
  801853:	ba 00 00 00 00       	mov    $0x0,%edx
  801858:	b8 06 00 00 00       	mov    $0x6,%eax
  80185d:	e8 56 ff ff ff       	call   8017b8 <fsipc>
  801862:	c9                   	leave  
  801863:	c3                   	ret    

00801864 <devfile_stat>:
  801864:	55                   	push   %ebp
  801865:	89 e5                	mov    %esp,%ebp
  801867:	53                   	push   %ebx
  801868:	83 ec 14             	sub    $0x14,%esp
  80186b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80186e:	8b 45 08             	mov    0x8(%ebp),%eax
  801871:	8b 40 0c             	mov    0xc(%eax),%eax
  801874:	a3 00 30 80 00       	mov    %eax,0x803000
  801879:	ba 00 00 00 00       	mov    $0x0,%edx
  80187e:	b8 05 00 00 00       	mov    $0x5,%eax
  801883:	e8 30 ff ff ff       	call   8017b8 <fsipc>
  801888:	85 c0                	test   %eax,%eax
  80188a:	78 2b                	js     8018b7 <devfile_stat+0x53>
  80188c:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801893:	00 
  801894:	89 1c 24             	mov    %ebx,(%esp)
  801897:	e8 b5 f0 ff ff       	call   800951 <strcpy>
  80189c:	a1 80 30 80 00       	mov    0x803080,%eax
  8018a1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  8018a7:	a1 84 30 80 00       	mov    0x803084,%eax
  8018ac:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8018b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8018b7:	83 c4 14             	add    $0x14,%esp
  8018ba:	5b                   	pop    %ebx
  8018bb:	5d                   	pop    %ebp
  8018bc:	c3                   	ret    

008018bd <devfile_write>:
  8018bd:	55                   	push   %ebp
  8018be:	89 e5                	mov    %esp,%ebp
  8018c0:	83 ec 18             	sub    $0x18,%esp
  8018c3:	8b 55 10             	mov    0x10(%ebp),%edx
  8018c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8018cc:	a3 00 30 80 00       	mov    %eax,0x803000
  8018d1:	89 d0                	mov    %edx,%eax
  8018d3:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  8018d9:	76 05                	jbe    8018e0 <devfile_write+0x23>
  8018db:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  8018e0:	89 15 04 30 80 00    	mov    %edx,0x803004
  8018e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f1:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  8018f8:	e8 5d f2 ff ff       	call   800b5a <memmove>
  8018fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801902:	b8 04 00 00 00       	mov    $0x4,%eax
  801907:	e8 ac fe ff ff       	call   8017b8 <fsipc>
  80190c:	c9                   	leave  
  80190d:	c3                   	ret    

0080190e <devfile_read>:
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	53                   	push   %ebx
  801912:	83 ec 14             	sub    $0x14,%esp
  801915:	8b 45 08             	mov    0x8(%ebp),%eax
  801918:	8b 40 0c             	mov    0xc(%eax),%eax
  80191b:	a3 00 30 80 00       	mov    %eax,0x803000
  801920:	8b 45 10             	mov    0x10(%ebp),%eax
  801923:	a3 04 30 80 00       	mov    %eax,0x803004
  801928:	ba 00 30 80 00       	mov    $0x803000,%edx
  80192d:	b8 03 00 00 00       	mov    $0x3,%eax
  801932:	e8 81 fe ff ff       	call   8017b8 <fsipc>
  801937:	89 c3                	mov    %eax,%ebx
  801939:	85 c0                	test   %eax,%eax
  80193b:	7e 17                	jle    801954 <devfile_read+0x46>
  80193d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801941:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801948:	00 
  801949:	8b 45 0c             	mov    0xc(%ebp),%eax
  80194c:	89 04 24             	mov    %eax,(%esp)
  80194f:	e8 06 f2 ff ff       	call   800b5a <memmove>
  801954:	89 d8                	mov    %ebx,%eax
  801956:	83 c4 14             	add    $0x14,%esp
  801959:	5b                   	pop    %ebx
  80195a:	5d                   	pop    %ebp
  80195b:	c3                   	ret    

0080195c <remove>:
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	53                   	push   %ebx
  801960:	83 ec 14             	sub    $0x14,%esp
  801963:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801966:	89 1c 24             	mov    %ebx,(%esp)
  801969:	e8 92 ef ff ff       	call   800900 <strlen>
  80196e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  801973:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801978:	7f 21                	jg     80199b <remove+0x3f>
  80197a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80197e:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801985:	e8 c7 ef ff ff       	call   800951 <strcpy>
  80198a:	ba 00 00 00 00       	mov    $0x0,%edx
  80198f:	b8 07 00 00 00       	mov    $0x7,%eax
  801994:	e8 1f fe ff ff       	call   8017b8 <fsipc>
  801999:	89 c2                	mov    %eax,%edx
  80199b:	89 d0                	mov    %edx,%eax
  80199d:	83 c4 14             	add    $0x14,%esp
  8019a0:	5b                   	pop    %ebx
  8019a1:	5d                   	pop    %ebp
  8019a2:	c3                   	ret    

008019a3 <open>:
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
  8019a6:	56                   	push   %esi
  8019a7:	53                   	push   %ebx
  8019a8:	83 ec 30             	sub    $0x30,%esp
  8019ab:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8019ae:	89 04 24             	mov    %eax,(%esp)
  8019b1:	e8 15 f8 ff ff       	call   8011cb <fd_alloc>
  8019b6:	89 c3                	mov    %eax,%ebx
  8019b8:	85 c0                	test   %eax,%eax
  8019ba:	79 18                	jns    8019d4 <open+0x31>
  8019bc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019c3:	00 
  8019c4:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8019c7:	89 04 24             	mov    %eax,(%esp)
  8019ca:	e8 a4 fb ff ff       	call   801573 <fd_close>
  8019cf:	e9 9f 00 00 00       	jmp    801a73 <open+0xd0>
  8019d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019db:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  8019e2:	e8 6a ef ff ff       	call   800951 <strcpy>
  8019e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ea:	a3 00 34 80 00       	mov    %eax,0x803400
  8019ef:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8019f2:	89 04 24             	mov    %eax,(%esp)
  8019f5:	e8 b6 f7 ff ff       	call   8011b0 <fd2data>
  8019fa:	89 c6                	mov    %eax,%esi
  8019fc:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  8019ff:	b8 01 00 00 00       	mov    $0x1,%eax
  801a04:	e8 af fd ff ff       	call   8017b8 <fsipc>
  801a09:	89 c3                	mov    %eax,%ebx
  801a0b:	85 c0                	test   %eax,%eax
  801a0d:	79 15                	jns    801a24 <open+0x81>
  801a0f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a16:	00 
  801a17:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801a1a:	89 04 24             	mov    %eax,(%esp)
  801a1d:	e8 51 fb ff ff       	call   801573 <fd_close>
  801a22:	eb 4f                	jmp    801a73 <open+0xd0>
  801a24:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801a2b:	00 
  801a2c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801a30:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a37:	00 
  801a38:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801a3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a3f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a46:	e8 d1 f5 ff ff       	call   80101c <sys_page_map>
  801a4b:	89 c3                	mov    %eax,%ebx
  801a4d:	85 c0                	test   %eax,%eax
  801a4f:	79 15                	jns    801a66 <open+0xc3>
  801a51:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a58:	00 
  801a59:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801a5c:	89 04 24             	mov    %eax,(%esp)
  801a5f:	e8 0f fb ff ff       	call   801573 <fd_close>
  801a64:	eb 0d                	jmp    801a73 <open+0xd0>
  801a66:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801a69:	89 04 24             	mov    %eax,(%esp)
  801a6c:	e8 2f f7 ff ff       	call   8011a0 <fd2num>
  801a71:	89 c3                	mov    %eax,%ebx
  801a73:	89 d8                	mov    %ebx,%eax
  801a75:	83 c4 30             	add    $0x30,%esp
  801a78:	5b                   	pop    %ebx
  801a79:	5e                   	pop    %esi
  801a7a:	5d                   	pop    %ebp
  801a7b:	c3                   	ret    
  801a7c:	00 00                	add    %al,(%eax)
	...

00801a80 <devsock_stat>:
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  801a86:	c7 44 24 04 38 2c 80 	movl   $0x802c38,0x4(%esp)
  801a8d:	00 
  801a8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a91:	89 04 24             	mov    %eax,(%esp)
  801a94:	e8 b8 ee ff ff       	call   800951 <strcpy>
	return 0;
}
  801a99:	b8 00 00 00 00       	mov    $0x0,%eax
  801a9e:	c9                   	leave  
  801a9f:	c3                   	ret    

00801aa0 <devsock_close>:
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	83 ec 08             	sub    $0x8,%esp
  801aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa9:	8b 40 0c             	mov    0xc(%eax),%eax
  801aac:	89 04 24             	mov    %eax,(%esp)
  801aaf:	e8 be 02 00 00       	call   801d72 <nsipc_close>
  801ab4:	c9                   	leave  
  801ab5:	c3                   	ret    

00801ab6 <devsock_write>:
  801ab6:	55                   	push   %ebp
  801ab7:	89 e5                	mov    %esp,%ebp
  801ab9:	83 ec 18             	sub    $0x18,%esp
  801abc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801ac3:	00 
  801ac4:	8b 45 10             	mov    0x10(%ebp),%eax
  801ac7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801acb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ace:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad5:	8b 40 0c             	mov    0xc(%eax),%eax
  801ad8:	89 04 24             	mov    %eax,(%esp)
  801adb:	e8 ce 02 00 00       	call   801dae <nsipc_send>
  801ae0:	c9                   	leave  
  801ae1:	c3                   	ret    

00801ae2 <devsock_read>:
  801ae2:	55                   	push   %ebp
  801ae3:	89 e5                	mov    %esp,%ebp
  801ae5:	83 ec 18             	sub    $0x18,%esp
  801ae8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801aef:	00 
  801af0:	8b 45 10             	mov    0x10(%ebp),%eax
  801af3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801af7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801afa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801afe:	8b 45 08             	mov    0x8(%ebp),%eax
  801b01:	8b 40 0c             	mov    0xc(%eax),%eax
  801b04:	89 04 24             	mov    %eax,(%esp)
  801b07:	e8 15 03 00 00       	call   801e21 <nsipc_recv>
  801b0c:	c9                   	leave  
  801b0d:	c3                   	ret    

00801b0e <alloc_sockfd>:
  801b0e:	55                   	push   %ebp
  801b0f:	89 e5                	mov    %esp,%ebp
  801b11:	56                   	push   %esi
  801b12:	53                   	push   %ebx
  801b13:	83 ec 20             	sub    $0x20,%esp
  801b16:	89 c6                	mov    %eax,%esi
  801b18:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  801b1b:	89 04 24             	mov    %eax,(%esp)
  801b1e:	e8 a8 f6 ff ff       	call   8011cb <fd_alloc>
  801b23:	89 c3                	mov    %eax,%ebx
  801b25:	85 c0                	test   %eax,%eax
  801b27:	78 21                	js     801b4a <alloc_sockfd+0x3c>
  801b29:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801b30:	00 
  801b31:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801b34:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b38:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b3f:	e8 36 f5 ff ff       	call   80107a <sys_page_alloc>
  801b44:	89 c3                	mov    %eax,%ebx
  801b46:	85 c0                	test   %eax,%eax
  801b48:	79 0a                	jns    801b54 <alloc_sockfd+0x46>
  801b4a:	89 34 24             	mov    %esi,(%esp)
  801b4d:	e8 20 02 00 00       	call   801d72 <nsipc_close>
  801b52:	eb 28                	jmp    801b7c <alloc_sockfd+0x6e>
  801b54:	8b 15 24 60 80 00    	mov    0x806024,%edx
  801b5a:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801b5d:	89 10                	mov    %edx,(%eax)
  801b5f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801b62:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
  801b69:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801b6c:	89 70 0c             	mov    %esi,0xc(%eax)
  801b6f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801b72:	89 04 24             	mov    %eax,(%esp)
  801b75:	e8 26 f6 ff ff       	call   8011a0 <fd2num>
  801b7a:	89 c3                	mov    %eax,%ebx
  801b7c:	89 d8                	mov    %ebx,%eax
  801b7e:	83 c4 20             	add    $0x20,%esp
  801b81:	5b                   	pop    %ebx
  801b82:	5e                   	pop    %esi
  801b83:	5d                   	pop    %ebp
  801b84:	c3                   	ret    

00801b85 <socket>:

int
socket(int domain, int type, int protocol)
{
  801b85:	55                   	push   %ebp
  801b86:	89 e5                	mov    %esp,%ebp
  801b88:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b8b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b8e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b92:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b95:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b99:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9c:	89 04 24             	mov    %eax,(%esp)
  801b9f:	e8 82 01 00 00       	call   801d26 <nsipc_socket>
  801ba4:	85 c0                	test   %eax,%eax
  801ba6:	78 05                	js     801bad <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801ba8:	e8 61 ff ff ff       	call   801b0e <alloc_sockfd>
}
  801bad:	c9                   	leave  
  801bae:	66 90                	xchg   %ax,%ax
  801bb0:	c3                   	ret    

00801bb1 <fd2sockid>:
  801bb1:	55                   	push   %ebp
  801bb2:	89 e5                	mov    %esp,%ebp
  801bb4:	83 ec 18             	sub    $0x18,%esp
  801bb7:	8d 55 fc             	lea    0xfffffffc(%ebp),%edx
  801bba:	89 54 24 04          	mov    %edx,0x4(%esp)
  801bbe:	89 04 24             	mov    %eax,(%esp)
  801bc1:	e8 58 f6 ff ff       	call   80121e <fd_lookup>
  801bc6:	89 c2                	mov    %eax,%edx
  801bc8:	85 c0                	test   %eax,%eax
  801bca:	78 15                	js     801be1 <fd2sockid+0x30>
  801bcc:	8b 4d fc             	mov    0xfffffffc(%ebp),%ecx
  801bcf:	8b 01                	mov    (%ecx),%eax
  801bd1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  801bd6:	3b 05 24 60 80 00    	cmp    0x806024,%eax
  801bdc:	75 03                	jne    801be1 <fd2sockid+0x30>
  801bde:	8b 51 0c             	mov    0xc(%ecx),%edx
  801be1:	89 d0                	mov    %edx,%eax
  801be3:	c9                   	leave  
  801be4:	c3                   	ret    

00801be5 <listen>:
  801be5:	55                   	push   %ebp
  801be6:	89 e5                	mov    %esp,%ebp
  801be8:	83 ec 08             	sub    $0x8,%esp
  801beb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bee:	e8 be ff ff ff       	call   801bb1 <fd2sockid>
  801bf3:	89 c2                	mov    %eax,%edx
  801bf5:	85 c0                	test   %eax,%eax
  801bf7:	78 11                	js     801c0a <listen+0x25>
  801bf9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bfc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c00:	89 14 24             	mov    %edx,(%esp)
  801c03:	e8 48 01 00 00       	call   801d50 <nsipc_listen>
  801c08:	89 c2                	mov    %eax,%edx
  801c0a:	89 d0                	mov    %edx,%eax
  801c0c:	c9                   	leave  
  801c0d:	c3                   	ret    

00801c0e <connect>:
  801c0e:	55                   	push   %ebp
  801c0f:	89 e5                	mov    %esp,%ebp
  801c11:	83 ec 18             	sub    $0x18,%esp
  801c14:	8b 45 08             	mov    0x8(%ebp),%eax
  801c17:	e8 95 ff ff ff       	call   801bb1 <fd2sockid>
  801c1c:	89 c2                	mov    %eax,%edx
  801c1e:	85 c0                	test   %eax,%eax
  801c20:	78 18                	js     801c3a <connect+0x2c>
  801c22:	8b 45 10             	mov    0x10(%ebp),%eax
  801c25:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c29:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c30:	89 14 24             	mov    %edx,(%esp)
  801c33:	e8 71 02 00 00       	call   801ea9 <nsipc_connect>
  801c38:	89 c2                	mov    %eax,%edx
  801c3a:	89 d0                	mov    %edx,%eax
  801c3c:	c9                   	leave  
  801c3d:	c3                   	ret    

00801c3e <shutdown>:
  801c3e:	55                   	push   %ebp
  801c3f:	89 e5                	mov    %esp,%ebp
  801c41:	83 ec 08             	sub    $0x8,%esp
  801c44:	8b 45 08             	mov    0x8(%ebp),%eax
  801c47:	e8 65 ff ff ff       	call   801bb1 <fd2sockid>
  801c4c:	89 c2                	mov    %eax,%edx
  801c4e:	85 c0                	test   %eax,%eax
  801c50:	78 11                	js     801c63 <shutdown+0x25>
  801c52:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c55:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c59:	89 14 24             	mov    %edx,(%esp)
  801c5c:	e8 2b 01 00 00       	call   801d8c <nsipc_shutdown>
  801c61:	89 c2                	mov    %eax,%edx
  801c63:	89 d0                	mov    %edx,%eax
  801c65:	c9                   	leave  
  801c66:	c3                   	ret    

00801c67 <bind>:
  801c67:	55                   	push   %ebp
  801c68:	89 e5                	mov    %esp,%ebp
  801c6a:	83 ec 18             	sub    $0x18,%esp
  801c6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c70:	e8 3c ff ff ff       	call   801bb1 <fd2sockid>
  801c75:	89 c2                	mov    %eax,%edx
  801c77:	85 c0                	test   %eax,%eax
  801c79:	78 18                	js     801c93 <bind+0x2c>
  801c7b:	8b 45 10             	mov    0x10(%ebp),%eax
  801c7e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c82:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c85:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c89:	89 14 24             	mov    %edx,(%esp)
  801c8c:	e8 57 02 00 00       	call   801ee8 <nsipc_bind>
  801c91:	89 c2                	mov    %eax,%edx
  801c93:	89 d0                	mov    %edx,%eax
  801c95:	c9                   	leave  
  801c96:	c3                   	ret    

00801c97 <accept>:
  801c97:	55                   	push   %ebp
  801c98:	89 e5                	mov    %esp,%ebp
  801c9a:	83 ec 18             	sub    $0x18,%esp
  801c9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca0:	e8 0c ff ff ff       	call   801bb1 <fd2sockid>
  801ca5:	89 c2                	mov    %eax,%edx
  801ca7:	85 c0                	test   %eax,%eax
  801ca9:	78 23                	js     801cce <accept+0x37>
  801cab:	8b 45 10             	mov    0x10(%ebp),%eax
  801cae:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cb9:	89 14 24             	mov    %edx,(%esp)
  801cbc:	e8 66 02 00 00       	call   801f27 <nsipc_accept>
  801cc1:	89 c2                	mov    %eax,%edx
  801cc3:	85 c0                	test   %eax,%eax
  801cc5:	78 07                	js     801cce <accept+0x37>
  801cc7:	e8 42 fe ff ff       	call   801b0e <alloc_sockfd>
  801ccc:	89 c2                	mov    %eax,%edx
  801cce:	89 d0                	mov    %edx,%eax
  801cd0:	c9                   	leave  
  801cd1:	c3                   	ret    
	...

00801ce0 <nsipc>:
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ce6:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  801cec:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801cf3:	00 
  801cf4:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801cfb:	00 
  801cfc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d00:	89 14 24             	mov    %edx,(%esp)
  801d03:	e8 e8 02 00 00       	call   801ff0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d08:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d0f:	00 
  801d10:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d17:	00 
  801d18:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d1f:	e8 80 03 00 00       	call   8020a4 <ipc_recv>
}
  801d24:	c9                   	leave  
  801d25:	c3                   	ret    

00801d26 <nsipc_socket>:

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
  801d26:	55                   	push   %ebp
  801d27:	89 e5                	mov    %esp,%ebp
  801d29:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2f:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.socket.req_type = type;
  801d34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d37:	a3 04 50 80 00       	mov    %eax,0x805004
	nsipcbuf.socket.req_protocol = protocol;
  801d3c:	8b 45 10             	mov    0x10(%ebp),%eax
  801d3f:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SOCKET);
  801d44:	b8 09 00 00 00       	mov    $0x9,%eax
  801d49:	e8 92 ff ff ff       	call   801ce0 <nsipc>
}
  801d4e:	c9                   	leave  
  801d4f:	c3                   	ret    

00801d50 <nsipc_listen>:
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
  801d53:	83 ec 08             	sub    $0x8,%esp
  801d56:	8b 45 08             	mov    0x8(%ebp),%eax
  801d59:	a3 00 50 80 00       	mov    %eax,0x805000
  801d5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d61:	a3 04 50 80 00       	mov    %eax,0x805004
  801d66:	b8 06 00 00 00       	mov    $0x6,%eax
  801d6b:	e8 70 ff ff ff       	call   801ce0 <nsipc>
  801d70:	c9                   	leave  
  801d71:	c3                   	ret    

00801d72 <nsipc_close>:
  801d72:	55                   	push   %ebp
  801d73:	89 e5                	mov    %esp,%ebp
  801d75:	83 ec 08             	sub    $0x8,%esp
  801d78:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7b:	a3 00 50 80 00       	mov    %eax,0x805000
  801d80:	b8 04 00 00 00       	mov    $0x4,%eax
  801d85:	e8 56 ff ff ff       	call   801ce0 <nsipc>
  801d8a:	c9                   	leave  
  801d8b:	c3                   	ret    

00801d8c <nsipc_shutdown>:
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	83 ec 08             	sub    $0x8,%esp
  801d92:	8b 45 08             	mov    0x8(%ebp),%eax
  801d95:	a3 00 50 80 00       	mov    %eax,0x805000
  801d9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d9d:	a3 04 50 80 00       	mov    %eax,0x805004
  801da2:	b8 03 00 00 00       	mov    $0x3,%eax
  801da7:	e8 34 ff ff ff       	call   801ce0 <nsipc>
  801dac:	c9                   	leave  
  801dad:	c3                   	ret    

00801dae <nsipc_send>:
  801dae:	55                   	push   %ebp
  801daf:	89 e5                	mov    %esp,%ebp
  801db1:	53                   	push   %ebx
  801db2:	83 ec 14             	sub    $0x14,%esp
  801db5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801db8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbb:	a3 00 50 80 00       	mov    %eax,0x805000
  801dc0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801dc6:	7e 24                	jle    801dec <nsipc_send+0x3e>
  801dc8:	c7 44 24 0c 44 2c 80 	movl   $0x802c44,0xc(%esp)
  801dcf:	00 
  801dd0:	c7 44 24 08 50 2c 80 	movl   $0x802c50,0x8(%esp)
  801dd7:	00 
  801dd8:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  801ddf:	00 
  801de0:	c7 04 24 65 2c 80 00 	movl   $0x802c65,(%esp)
  801de7:	e8 8c 01 00 00       	call   801f78 <_panic>
  801dec:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801df0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801df7:	c7 04 24 0c 50 80 00 	movl   $0x80500c,(%esp)
  801dfe:	e8 57 ed ff ff       	call   800b5a <memmove>
  801e03:	89 1d 04 50 80 00    	mov    %ebx,0x805004
  801e09:	8b 45 14             	mov    0x14(%ebp),%eax
  801e0c:	a3 08 50 80 00       	mov    %eax,0x805008
  801e11:	b8 08 00 00 00       	mov    $0x8,%eax
  801e16:	e8 c5 fe ff ff       	call   801ce0 <nsipc>
  801e1b:	83 c4 14             	add    $0x14,%esp
  801e1e:	5b                   	pop    %ebx
  801e1f:	5d                   	pop    %ebp
  801e20:	c3                   	ret    

00801e21 <nsipc_recv>:
  801e21:	55                   	push   %ebp
  801e22:	89 e5                	mov    %esp,%ebp
  801e24:	83 ec 18             	sub    $0x18,%esp
  801e27:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  801e2a:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  801e2d:	8b 75 10             	mov    0x10(%ebp),%esi
  801e30:	8b 45 08             	mov    0x8(%ebp),%eax
  801e33:	a3 00 50 80 00       	mov    %eax,0x805000
  801e38:	89 35 04 50 80 00    	mov    %esi,0x805004
  801e3e:	8b 45 14             	mov    0x14(%ebp),%eax
  801e41:	a3 08 50 80 00       	mov    %eax,0x805008
  801e46:	b8 07 00 00 00       	mov    $0x7,%eax
  801e4b:	e8 90 fe ff ff       	call   801ce0 <nsipc>
  801e50:	89 c3                	mov    %eax,%ebx
  801e52:	85 c0                	test   %eax,%eax
  801e54:	78 47                	js     801e9d <nsipc_recv+0x7c>
  801e56:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e5b:	7f 05                	jg     801e62 <nsipc_recv+0x41>
  801e5d:	39 c6                	cmp    %eax,%esi
  801e5f:	90                   	nop    
  801e60:	7d 24                	jge    801e86 <nsipc_recv+0x65>
  801e62:	c7 44 24 0c 71 2c 80 	movl   $0x802c71,0xc(%esp)
  801e69:	00 
  801e6a:	c7 44 24 08 50 2c 80 	movl   $0x802c50,0x8(%esp)
  801e71:	00 
  801e72:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  801e79:	00 
  801e7a:	c7 04 24 65 2c 80 00 	movl   $0x802c65,(%esp)
  801e81:	e8 f2 00 00 00       	call   801f78 <_panic>
  801e86:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e8a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801e91:	00 
  801e92:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e95:	89 04 24             	mov    %eax,(%esp)
  801e98:	e8 bd ec ff ff       	call   800b5a <memmove>
  801e9d:	89 d8                	mov    %ebx,%eax
  801e9f:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  801ea2:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  801ea5:	89 ec                	mov    %ebp,%esp
  801ea7:	5d                   	pop    %ebp
  801ea8:	c3                   	ret    

00801ea9 <nsipc_connect>:
  801ea9:	55                   	push   %ebp
  801eaa:	89 e5                	mov    %esp,%ebp
  801eac:	53                   	push   %ebx
  801ead:	83 ec 14             	sub    $0x14,%esp
  801eb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801eb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb6:	a3 00 50 80 00       	mov    %eax,0x805000
  801ebb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ebf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec6:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  801ecd:	e8 88 ec ff ff       	call   800b5a <memmove>
  801ed2:	89 1d 14 50 80 00    	mov    %ebx,0x805014
  801ed8:	b8 05 00 00 00       	mov    $0x5,%eax
  801edd:	e8 fe fd ff ff       	call   801ce0 <nsipc>
  801ee2:	83 c4 14             	add    $0x14,%esp
  801ee5:	5b                   	pop    %ebx
  801ee6:	5d                   	pop    %ebp
  801ee7:	c3                   	ret    

00801ee8 <nsipc_bind>:
  801ee8:	55                   	push   %ebp
  801ee9:	89 e5                	mov    %esp,%ebp
  801eeb:	53                   	push   %ebx
  801eec:	83 ec 14             	sub    $0x14,%esp
  801eef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ef2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef5:	a3 00 50 80 00       	mov    %eax,0x805000
  801efa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801efe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f01:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f05:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  801f0c:	e8 49 ec ff ff       	call   800b5a <memmove>
  801f11:	89 1d 14 50 80 00    	mov    %ebx,0x805014
  801f17:	b8 02 00 00 00       	mov    $0x2,%eax
  801f1c:	e8 bf fd ff ff       	call   801ce0 <nsipc>
  801f21:	83 c4 14             	add    $0x14,%esp
  801f24:	5b                   	pop    %ebx
  801f25:	5d                   	pop    %ebp
  801f26:	c3                   	ret    

00801f27 <nsipc_accept>:
  801f27:	55                   	push   %ebp
  801f28:	89 e5                	mov    %esp,%ebp
  801f2a:	53                   	push   %ebx
  801f2b:	83 ec 14             	sub    $0x14,%esp
  801f2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f31:	a3 00 50 80 00       	mov    %eax,0x805000
  801f36:	b8 01 00 00 00       	mov    $0x1,%eax
  801f3b:	e8 a0 fd ff ff       	call   801ce0 <nsipc>
  801f40:	89 c3                	mov    %eax,%ebx
  801f42:	85 c0                	test   %eax,%eax
  801f44:	78 27                	js     801f6d <nsipc_accept+0x46>
  801f46:	a1 10 50 80 00       	mov    0x805010,%eax
  801f4b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f4f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801f56:	00 
  801f57:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f5a:	89 04 24             	mov    %eax,(%esp)
  801f5d:	e8 f8 eb ff ff       	call   800b5a <memmove>
  801f62:	8b 15 10 50 80 00    	mov    0x805010,%edx
  801f68:	8b 45 10             	mov    0x10(%ebp),%eax
  801f6b:	89 10                	mov    %edx,(%eax)
  801f6d:	89 d8                	mov    %ebx,%eax
  801f6f:	83 c4 14             	add    $0x14,%esp
  801f72:	5b                   	pop    %ebx
  801f73:	5d                   	pop    %ebp
  801f74:	c3                   	ret    
  801f75:	00 00                	add    %al,(%eax)
	...

00801f78 <_panic>:
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  801f78:	55                   	push   %ebp
  801f79:	89 e5                	mov    %esp,%ebp
  801f7b:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  801f7e:	8d 45 14             	lea    0x14(%ebp),%eax
  801f81:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)

	// Print the panic message
	if (argv0)
  801f84:	a1 54 60 80 00       	mov    0x806054,%eax
  801f89:	85 c0                	test   %eax,%eax
  801f8b:	74 10                	je     801f9d <_panic+0x25>
		cprintf("%s: ", argv0);
  801f8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f91:	c7 04 24 86 2c 80 00 	movl   $0x802c86,(%esp)
  801f98:	e8 2c e3 ff ff       	call   8002c9 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  801f9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fa0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fa4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fab:	a1 04 60 80 00       	mov    0x806004,%eax
  801fb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fb4:	c7 04 24 8b 2c 80 00 	movl   $0x802c8b,(%esp)
  801fbb:	e8 09 e3 ff ff       	call   8002c9 <cprintf>
	vcprintf(fmt, ap);
  801fc0:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  801fc3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fc7:	8b 45 10             	mov    0x10(%ebp),%eax
  801fca:	89 04 24             	mov    %eax,(%esp)
  801fcd:	e8 96 e2 ff ff       	call   800268 <vcprintf>
	cprintf("\n");
  801fd2:	c7 04 24 14 28 80 00 	movl   $0x802814,(%esp)
  801fd9:	e8 eb e2 ff ff       	call   8002c9 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801fde:	cc                   	int3   
  801fdf:	eb fd                	jmp    801fde <_panic+0x66>
	...

00801ff0 <ipc_send>:
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
  801fff:	e8 09 f1 ff ff       	call   80110d <sys_getenvid>
  802004:	25 ff 03 00 00       	and    $0x3ff,%eax
  802009:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80200c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802011:	a3 50 60 80 00       	mov    %eax,0x806050
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  802016:	e8 f2 f0 ff ff       	call   80110d <sys_getenvid>
  80201b:	25 ff 03 00 00       	and    $0x3ff,%eax
  802020:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802023:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802028:	a3 50 60 80 00       	mov    %eax,0x806050
		if(env->env_id==to_env){
  80202d:	8b 40 4c             	mov    0x4c(%eax),%eax
  802030:	39 f0                	cmp    %esi,%eax
  802032:	75 0e                	jne    802042 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  802034:	c7 04 24 a7 2c 80 00 	movl   $0x802ca7,(%esp)
  80203b:	e8 89 e2 ff ff       	call   8002c9 <cprintf>
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
  802057:	e8 10 ee ff ff       	call   800e6c <sys_ipc_try_send>
  80205c:	89 c3                	mov    %eax,%ebx
  80205e:	85 c0                	test   %eax,%eax
  802060:	79 25                	jns    802087 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  802062:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802065:	74 2b                	je     802092 <ipc_send+0xa2>
				panic("send error:%e",r);
  802067:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80206b:	c7 44 24 08 c3 2c 80 	movl   $0x802cc3,0x8(%esp)
  802072:	00 
  802073:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80207a:	00 
  80207b:	c7 04 24 d1 2c 80 00 	movl   $0x802cd1,(%esp)
  802082:	e8 f1 fe ff ff       	call   801f78 <_panic>
		}
			sys_yield();
  802087:	e8 4d f0 ff ff       	call   8010d9 <sys_yield>
		
	}while(r!=0);
  80208c:	85 db                	test   %ebx,%ebx
  80208e:	75 86                	jne    802016 <ipc_send+0x26>
  802090:	eb 0a                	jmp    80209c <ipc_send+0xac>
  802092:	e8 42 f0 ff ff       	call   8010d9 <sys_yield>
  802097:	e9 7a ff ff ff       	jmp    802016 <ipc_send+0x26>
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
  8020a4:	55                   	push   %ebp
  8020a5:	89 e5                	mov    %esp,%ebp
  8020a7:	57                   	push   %edi
  8020a8:	56                   	push   %esi
  8020a9:	53                   	push   %ebx
  8020aa:	83 ec 0c             	sub    $0xc,%esp
  8020ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8020b0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8020b3:	e8 55 f0 ff ff       	call   80110d <sys_getenvid>
  8020b8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8020bd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020c0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020c5:	a3 50 60 80 00       	mov    %eax,0x806050
  8020ca:	85 f6                	test   %esi,%esi
  8020cc:	74 29                	je     8020f7 <ipc_recv+0x53>
  8020ce:	8b 40 4c             	mov    0x4c(%eax),%eax
  8020d1:	3b 06                	cmp    (%esi),%eax
  8020d3:	75 22                	jne    8020f7 <ipc_recv+0x53>
  8020d5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8020db:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8020e1:	c7 04 24 a7 2c 80 00 	movl   $0x802ca7,(%esp)
  8020e8:	e8 dc e1 ff ff       	call   8002c9 <cprintf>
  8020ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020f2:	e9 8a 00 00 00       	jmp    802181 <ipc_recv+0xdd>
  8020f7:	e8 11 f0 ff ff       	call   80110d <sys_getenvid>
  8020fc:	25 ff 03 00 00       	and    $0x3ff,%eax
  802101:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802104:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802109:	a3 50 60 80 00       	mov    %eax,0x806050
  80210e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802111:	89 04 24             	mov    %eax,(%esp)
  802114:	e8 f6 ec ff ff       	call   800e0f <sys_ipc_recv>
  802119:	89 c3                	mov    %eax,%ebx
  80211b:	85 c0                	test   %eax,%eax
  80211d:	79 1a                	jns    802139 <ipc_recv+0x95>
  80211f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802125:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  80212b:	c7 04 24 db 2c 80 00 	movl   $0x802cdb,(%esp)
  802132:	e8 92 e1 ff ff       	call   8002c9 <cprintf>
  802137:	eb 48                	jmp    802181 <ipc_recv+0xdd>
  802139:	e8 cf ef ff ff       	call   80110d <sys_getenvid>
  80213e:	25 ff 03 00 00       	and    $0x3ff,%eax
  802143:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802146:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80214b:	a3 50 60 80 00       	mov    %eax,0x806050
  802150:	85 f6                	test   %esi,%esi
  802152:	74 05                	je     802159 <ipc_recv+0xb5>
  802154:	8b 40 74             	mov    0x74(%eax),%eax
  802157:	89 06                	mov    %eax,(%esi)
  802159:	85 ff                	test   %edi,%edi
  80215b:	74 0a                	je     802167 <ipc_recv+0xc3>
  80215d:	a1 50 60 80 00       	mov    0x806050,%eax
  802162:	8b 40 78             	mov    0x78(%eax),%eax
  802165:	89 07                	mov    %eax,(%edi)
  802167:	e8 a1 ef ff ff       	call   80110d <sys_getenvid>
  80216c:	25 ff 03 00 00       	and    $0x3ff,%eax
  802171:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802174:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802179:	a3 50 60 80 00       	mov    %eax,0x806050
  80217e:	8b 58 70             	mov    0x70(%eax),%ebx
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

00802190 <inet_ntoa>:
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  802190:	55                   	push   %ebp
  802191:	89 e5                	mov    %esp,%ebp
  802193:	57                   	push   %edi
  802194:	56                   	push   %esi
  802195:	53                   	push   %ebx
  802196:	83 ec 18             	sub    $0x18,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  802199:	8b 45 08             	mov    0x8(%ebp),%eax
  80219c:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  char inv[3];
  char *rp;
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  80219f:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  8021a2:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  8021a5:	be 00 00 00 00       	mov    $0x0,%esi
  8021aa:	bf 40 60 80 00       	mov    $0x806040,%edi
  8021af:	c6 45 e3 00          	movb   $0x0,0xffffffe3(%ebp)
  8021b3:	eb 02                	jmp    8021b7 <inet_ntoa+0x27>
  8021b5:	89 c6                	mov    %eax,%esi
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  8021b7:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  8021ba:	0f b6 0a             	movzbl (%edx),%ecx
      *ap /= (u8_t)10;
  8021bd:	b8 cd ff ff ff       	mov    $0xffffffcd,%eax
  8021c2:	f6 e1                	mul    %cl
  8021c4:	89 c2                	mov    %eax,%edx
  8021c6:	66 c1 ea 08          	shr    $0x8,%dx
  8021ca:	c0 ea 03             	shr    $0x3,%dl
  8021cd:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  8021d0:	88 10                	mov    %dl,(%eax)
      inv[i++] = '0' + rem;
  8021d2:	89 f0                	mov    %esi,%eax
  8021d4:	0f b6 d8             	movzbl %al,%ebx
  8021d7:	8d 04 92             	lea    (%edx,%edx,4),%eax
  8021da:	01 c0                	add    %eax,%eax
  8021dc:	28 c1                	sub    %al,%cl
  8021de:	83 c1 30             	add    $0x30,%ecx
  8021e1:	88 4c 1d ed          	mov    %cl,0xffffffed(%ebp,%ebx,1)
  8021e5:	8d 46 01             	lea    0x1(%esi),%eax
    } while(*ap);
  8021e8:	84 d2                	test   %dl,%dl
  8021ea:	75 c9                	jne    8021b5 <inet_ntoa+0x25>
    while(i--)
  8021ec:	89 f1                	mov    %esi,%ecx
  8021ee:	80 f9 ff             	cmp    $0xff,%cl
  8021f1:	74 20                	je     802213 <inet_ntoa+0x83>
  8021f3:	89 fa                	mov    %edi,%edx
      *rp++ = inv[i];
  8021f5:	0f b6 c1             	movzbl %cl,%eax
  8021f8:	0f b6 44 05 ed       	movzbl 0xffffffed(%ebp,%eax,1),%eax
  8021fd:	88 02                	mov    %al,(%edx)
  8021ff:	83 c2 01             	add    $0x1,%edx
  802202:	83 e9 01             	sub    $0x1,%ecx
  802205:	80 f9 ff             	cmp    $0xff,%cl
  802208:	75 eb                	jne    8021f5 <inet_ntoa+0x65>
  80220a:	89 f2                	mov    %esi,%edx
  80220c:	0f b6 c2             	movzbl %dl,%eax
  80220f:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
    *rp++ = '.';
  802213:	c6 07 2e             	movb   $0x2e,(%edi)
  802216:	83 c7 01             	add    $0x1,%edi
  802219:	80 45 e3 01          	addb   $0x1,0xffffffe3(%ebp)
  80221d:	80 7d e3 03          	cmpb   $0x3,0xffffffe3(%ebp)
  802221:	77 0b                	ja     80222e <inet_ntoa+0x9e>
    ap++;
  802223:	83 45 dc 01          	addl   $0x1,0xffffffdc(%ebp)
  802227:	b8 00 00 00 00       	mov    $0x0,%eax
  80222c:	eb 87                	jmp    8021b5 <inet_ntoa+0x25>
  }
  *--rp = 0;
  80222e:	c6 47 ff 00          	movb   $0x0,0xffffffff(%edi)
  return str;
}
  802232:	b8 40 60 80 00       	mov    $0x806040,%eax
  802237:	83 c4 18             	add    $0x18,%esp
  80223a:	5b                   	pop    %ebx
  80223b:	5e                   	pop    %esi
  80223c:	5f                   	pop    %edi
  80223d:	5d                   	pop    %ebp
  80223e:	c3                   	ret    

0080223f <htons>:

/**
 * These are reference implementations of the byte swapping functions.
 * Again with the aim of being simple, correct and fully portable.
 * Byte swapping is the second thing you would want to optimize. You will
 * need to port it to your architecture and in your cc.h:
 * 
 * #define LWIP_PLATFORM_BYTESWAP 1
 * #define LWIP_PLATFORM_HTONS(x) <your_htons>
 * #define LWIP_PLATFORM_HTONL(x) <your_htonl>
 *
 * Note ntohs() and ntohl() are merely references to the htonx counterparts.
 */

#if (LWIP_PLATFORM_BYTESWAP == 0) && (BYTE_ORDER == LITTLE_ENDIAN)

/**
 * Convert an u16_t from host- to network byte order.
 *
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  80223f:	55                   	push   %ebp
  802240:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  802242:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  802246:	89 c2                	mov    %eax,%edx
  802248:	c1 ea 08             	shr    $0x8,%edx
  80224b:	c1 e0 08             	shl    $0x8,%eax
  80224e:	09 d0                	or     %edx,%eax
  802250:	0f b7 c0             	movzwl %ax,%eax
}
  802253:	5d                   	pop    %ebp
  802254:	c3                   	ret    

00802255 <ntohs>:

/**
 * Convert an u16_t from network- to host byte order.
 *
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  802255:	55                   	push   %ebp
  802256:	89 e5                	mov    %esp,%ebp
  802258:	83 ec 04             	sub    $0x4,%esp
  return htons(n);
  80225b:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80225f:	89 04 24             	mov    %eax,(%esp)
  802262:	e8 d8 ff ff ff       	call   80223f <htons>
  802267:	0f b7 c0             	movzwl %ax,%eax
}
  80226a:	c9                   	leave  
  80226b:	c3                   	ret    

0080226c <htonl>:

/**
 * Convert an u32_t from host- to network byte order.
 *
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  80226c:	55                   	push   %ebp
  80226d:	89 e5                	mov    %esp,%ebp
  80226f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802272:	89 c8                	mov    %ecx,%eax
  802274:	25 00 ff 00 00       	and    $0xff00,%eax
  802279:	c1 e0 08             	shl    $0x8,%eax
  80227c:	89 ca                	mov    %ecx,%edx
  80227e:	c1 e2 18             	shl    $0x18,%edx
  802281:	09 d0                	or     %edx,%eax
  802283:	89 ca                	mov    %ecx,%edx
  802285:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  80228b:	c1 ea 08             	shr    $0x8,%edx
  80228e:	09 d0                	or     %edx,%eax
  802290:	c1 e9 18             	shr    $0x18,%ecx
  802293:	09 c8                	or     %ecx,%eax
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  802295:	5d                   	pop    %ebp
  802296:	c3                   	ret    

00802297 <inet_aton>:
  802297:	55                   	push   %ebp
  802298:	89 e5                	mov    %esp,%ebp
  80229a:	57                   	push   %edi
  80229b:	56                   	push   %esi
  80229c:	53                   	push   %ebx
  80229d:	83 ec 1c             	sub    $0x1c,%esp
  8022a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8022a3:	0f be 0b             	movsbl (%ebx),%ecx
  8022a6:	8d 41 d0             	lea    0xffffffd0(%ecx),%eax
  8022a9:	3c 09                	cmp    $0x9,%al
  8022ab:	0f 87 9a 01 00 00    	ja     80244b <inet_aton+0x1b4>
  8022b1:	8d 45 e4             	lea    0xffffffe4(%ebp),%eax
  8022b4:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  8022b7:	be 0a 00 00 00       	mov    $0xa,%esi
  8022bc:	83 f9 30             	cmp    $0x30,%ecx
  8022bf:	75 20                	jne    8022e1 <inet_aton+0x4a>
  8022c1:	83 c3 01             	add    $0x1,%ebx
  8022c4:	0f be 0b             	movsbl (%ebx),%ecx
  8022c7:	83 f9 78             	cmp    $0x78,%ecx
  8022ca:	74 0a                	je     8022d6 <inet_aton+0x3f>
  8022cc:	be 08 00 00 00       	mov    $0x8,%esi
  8022d1:	83 f9 58             	cmp    $0x58,%ecx
  8022d4:	75 0b                	jne    8022e1 <inet_aton+0x4a>
  8022d6:	83 c3 01             	add    $0x1,%ebx
  8022d9:	0f be 0b             	movsbl (%ebx),%ecx
  8022dc:	be 10 00 00 00       	mov    $0x10,%esi
  8022e1:	bf 00 00 00 00       	mov    $0x0,%edi
  8022e6:	89 ca                	mov    %ecx,%edx
  8022e8:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  8022eb:	3c 09                	cmp    $0x9,%al
  8022ed:	77 11                	ja     802300 <inet_aton+0x69>
  8022ef:	89 f8                	mov    %edi,%eax
  8022f1:	0f af c6             	imul   %esi,%eax
  8022f4:	8d 7c 08 d0          	lea    0xffffffd0(%eax,%ecx,1),%edi
  8022f8:	83 c3 01             	add    $0x1,%ebx
  8022fb:	0f be 0b             	movsbl (%ebx),%ecx
  8022fe:	eb e6                	jmp    8022e6 <inet_aton+0x4f>
  802300:	83 fe 10             	cmp    $0x10,%esi
  802303:	75 30                	jne    802335 <inet_aton+0x9e>
  802305:	8d 42 9f             	lea    0xffffff9f(%edx),%eax
  802308:	88 45 df             	mov    %al,0xffffffdf(%ebp)
  80230b:	3c 05                	cmp    $0x5,%al
  80230d:	76 07                	jbe    802316 <inet_aton+0x7f>
  80230f:	8d 42 bf             	lea    0xffffffbf(%edx),%eax
  802312:	3c 05                	cmp    $0x5,%al
  802314:	77 1f                	ja     802335 <inet_aton+0x9e>
  802316:	80 7d df 1a          	cmpb   $0x1a,0xffffffdf(%ebp)
  80231a:	19 c0                	sbb    %eax,%eax
  80231c:	83 e0 20             	and    $0x20,%eax
  80231f:	29 c1                	sub    %eax,%ecx
  802321:	8d 41 c9             	lea    0xffffffc9(%ecx),%eax
  802324:	89 fa                	mov    %edi,%edx
  802326:	c1 e2 04             	shl    $0x4,%edx
  802329:	89 c7                	mov    %eax,%edi
  80232b:	09 d7                	or     %edx,%edi
  80232d:	83 c3 01             	add    $0x1,%ebx
  802330:	0f be 0b             	movsbl (%ebx),%ecx
  802333:	eb b1                	jmp    8022e6 <inet_aton+0x4f>
  802335:	83 f9 2e             	cmp    $0x2e,%ecx
  802338:	75 2d                	jne    802367 <inet_aton+0xd0>
  80233a:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  80233d:	3b 45 e0             	cmp    0xffffffe0(%ebp),%eax
  802340:	0f 86 05 01 00 00    	jbe    80244b <inet_aton+0x1b4>
  802346:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  802349:	89 3a                	mov    %edi,(%edx)
  80234b:	83 c3 01             	add    $0x1,%ebx
  80234e:	0f be 0b             	movsbl (%ebx),%ecx
  802351:	8d 41 d0             	lea    0xffffffd0(%ecx),%eax
  802354:	3c 09                	cmp    $0x9,%al
  802356:	0f 87 ef 00 00 00    	ja     80244b <inet_aton+0x1b4>
  80235c:	83 c2 04             	add    $0x4,%edx
  80235f:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  802362:	e9 50 ff ff ff       	jmp    8022b7 <inet_aton+0x20>
  802367:	89 fb                	mov    %edi,%ebx
  802369:	85 c9                	test   %ecx,%ecx
  80236b:	74 2e                	je     80239b <inet_aton+0x104>
  80236d:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  802370:	3c 5f                	cmp    $0x5f,%al
  802372:	0f 87 d3 00 00 00    	ja     80244b <inet_aton+0x1b4>
  802378:	83 f9 20             	cmp    $0x20,%ecx
  80237b:	74 1e                	je     80239b <inet_aton+0x104>
  80237d:	83 f9 0c             	cmp    $0xc,%ecx
  802380:	74 19                	je     80239b <inet_aton+0x104>
  802382:	83 f9 0a             	cmp    $0xa,%ecx
  802385:	74 14                	je     80239b <inet_aton+0x104>
  802387:	83 f9 0d             	cmp    $0xd,%ecx
  80238a:	74 0f                	je     80239b <inet_aton+0x104>
  80238c:	83 f9 09             	cmp    $0x9,%ecx
  80238f:	90                   	nop    
  802390:	74 09                	je     80239b <inet_aton+0x104>
  802392:	83 f9 0b             	cmp    $0xb,%ecx
  802395:	0f 85 b0 00 00 00    	jne    80244b <inet_aton+0x1b4>
  80239b:	8d 45 e4             	lea    0xffffffe4(%ebp),%eax
  80239e:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  8023a1:	29 c2                	sub    %eax,%edx
  8023a3:	89 d0                	mov    %edx,%eax
  8023a5:	c1 f8 02             	sar    $0x2,%eax
  8023a8:	83 c0 01             	add    $0x1,%eax
  8023ab:	83 f8 02             	cmp    $0x2,%eax
  8023ae:	74 24                	je     8023d4 <inet_aton+0x13d>
  8023b0:	83 f8 02             	cmp    $0x2,%eax
  8023b3:	7f 0d                	jg     8023c2 <inet_aton+0x12b>
  8023b5:	85 c0                	test   %eax,%eax
  8023b7:	0f 84 8e 00 00 00    	je     80244b <inet_aton+0x1b4>
  8023bd:	8d 76 00             	lea    0x0(%esi),%esi
  8023c0:	eb 6a                	jmp    80242c <inet_aton+0x195>
  8023c2:	83 f8 03             	cmp    $0x3,%eax
  8023c5:	74 27                	je     8023ee <inet_aton+0x157>
  8023c7:	83 f8 04             	cmp    $0x4,%eax
  8023ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023d0:	75 5a                	jne    80242c <inet_aton+0x195>
  8023d2:	eb 36                	jmp    80240a <inet_aton+0x173>
  8023d4:	81 fb ff ff ff 00    	cmp    $0xffffff,%ebx
  8023da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023e0:	77 69                	ja     80244b <inet_aton+0x1b4>
  8023e2:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  8023e5:	c1 e0 18             	shl    $0x18,%eax
  8023e8:	89 df                	mov    %ebx,%edi
  8023ea:	09 c7                	or     %eax,%edi
  8023ec:	eb 3e                	jmp    80242c <inet_aton+0x195>
  8023ee:	81 fb ff ff 00 00    	cmp    $0xffff,%ebx
  8023f4:	77 55                	ja     80244b <inet_aton+0x1b4>
  8023f6:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
  8023f9:	c1 e2 10             	shl    $0x10,%edx
  8023fc:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  8023ff:	c1 e0 18             	shl    $0x18,%eax
  802402:	09 c2                	or     %eax,%edx
  802404:	89 d7                	mov    %edx,%edi
  802406:	09 df                	or     %ebx,%edi
  802408:	eb 22                	jmp    80242c <inet_aton+0x195>
  80240a:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
  802410:	77 39                	ja     80244b <inet_aton+0x1b4>
  802412:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802415:	c1 e0 10             	shl    $0x10,%eax
  802418:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  80241b:	c1 e2 18             	shl    $0x18,%edx
  80241e:	09 d0                	or     %edx,%eax
  802420:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  802423:	c1 e2 08             	shl    $0x8,%edx
  802426:	09 d0                	or     %edx,%eax
  802428:	89 c7                	mov    %eax,%edi
  80242a:	09 df                	or     %ebx,%edi
  80242c:	b8 01 00 00 00       	mov    $0x1,%eax
  802431:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802435:	74 19                	je     802450 <inet_aton+0x1b9>
  802437:	89 3c 24             	mov    %edi,(%esp)
  80243a:	e8 2d fe ff ff       	call   80226c <htonl>
  80243f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802442:	89 02                	mov    %eax,(%edx)
  802444:	b8 01 00 00 00       	mov    $0x1,%eax
  802449:	eb 05                	jmp    802450 <inet_aton+0x1b9>
  80244b:	b8 00 00 00 00       	mov    $0x0,%eax
  802450:	83 c4 1c             	add    $0x1c,%esp
  802453:	5b                   	pop    %ebx
  802454:	5e                   	pop    %esi
  802455:	5f                   	pop    %edi
  802456:	5d                   	pop    %ebp
  802457:	c3                   	ret    

00802458 <inet_addr>:
  802458:	55                   	push   %ebp
  802459:	89 e5                	mov    %esp,%ebp
  80245b:	83 ec 18             	sub    $0x18,%esp
  80245e:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  802461:	89 44 24 04          	mov    %eax,0x4(%esp)
  802465:	8b 45 08             	mov    0x8(%ebp),%eax
  802468:	89 04 24             	mov    %eax,(%esp)
  80246b:	e8 27 fe ff ff       	call   802297 <inet_aton>
  802470:	83 f8 01             	cmp    $0x1,%eax
  802473:	19 c0                	sbb    %eax,%eax
  802475:	0b 45 fc             	or     0xfffffffc(%ebp),%eax
  802478:	c9                   	leave  
  802479:	c3                   	ret    

0080247a <ntohl>:

/**
 * Convert an u32_t from network- to host byte order.
 *
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  80247a:	55                   	push   %ebp
  80247b:	89 e5                	mov    %esp,%ebp
  80247d:	83 ec 04             	sub    $0x4,%esp
  return htonl(n);
  802480:	8b 45 08             	mov    0x8(%ebp),%eax
  802483:	89 04 24             	mov    %eax,(%esp)
  802486:	e8 e1 fd ff ff       	call   80226c <htonl>
}
  80248b:	c9                   	leave  
  80248c:	c3                   	ret    
  80248d:	00 00                	add    %al,(%eax)
	...

00802490 <__udivdi3>:
  802490:	55                   	push   %ebp
  802491:	89 e5                	mov    %esp,%ebp
  802493:	57                   	push   %edi
  802494:	56                   	push   %esi
  802495:	83 ec 1c             	sub    $0x1c,%esp
  802498:	8b 45 10             	mov    0x10(%ebp),%eax
  80249b:	8b 55 14             	mov    0x14(%ebp),%edx
  80249e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8024a1:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  8024a4:	89 c1                	mov    %eax,%ecx
  8024a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8024a9:	85 d2                	test   %edx,%edx
  8024ab:	89 d6                	mov    %edx,%esi
  8024ad:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
  8024b0:	75 1e                	jne    8024d0 <__udivdi3+0x40>
  8024b2:	39 f9                	cmp    %edi,%ecx
  8024b4:	0f 86 8d 00 00 00    	jbe    802547 <__udivdi3+0xb7>
  8024ba:	89 fa                	mov    %edi,%edx
  8024bc:	f7 f1                	div    %ecx
  8024be:	89 c1                	mov    %eax,%ecx
  8024c0:	89 c8                	mov    %ecx,%eax
  8024c2:	89 f2                	mov    %esi,%edx
  8024c4:	83 c4 1c             	add    $0x1c,%esp
  8024c7:	5e                   	pop    %esi
  8024c8:	5f                   	pop    %edi
  8024c9:	5d                   	pop    %ebp
  8024ca:	c3                   	ret    
  8024cb:	90                   	nop    
  8024cc:	8d 74 26 00          	lea    0x0(%esi),%esi
  8024d0:	39 fa                	cmp    %edi,%edx
  8024d2:	0f 87 98 00 00 00    	ja     802570 <__udivdi3+0xe0>
  8024d8:	0f bd c2             	bsr    %edx,%eax
  8024db:	83 f0 1f             	xor    $0x1f,%eax
  8024de:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8024e1:	74 7f                	je     802562 <__udivdi3+0xd2>
  8024e3:	b8 20 00 00 00       	mov    $0x20,%eax
  8024e8:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  8024eb:	2b 45 e4             	sub    0xffffffe4(%ebp),%eax
  8024ee:	89 c1                	mov    %eax,%ecx
  8024f0:	d3 ea                	shr    %cl,%edx
  8024f2:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8024f6:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  8024f9:	89 f0                	mov    %esi,%eax
  8024fb:	d3 e0                	shl    %cl,%eax
  8024fd:	09 c2                	or     %eax,%edx
  8024ff:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802502:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  802505:	89 fa                	mov    %edi,%edx
  802507:	d3 e0                	shl    %cl,%eax
  802509:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  80250d:	89 45 f4             	mov    %eax,0xfffffff4(%ebp)
  802510:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802513:	d3 e8                	shr    %cl,%eax
  802515:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802519:	d3 e2                	shl    %cl,%edx
  80251b:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  80251f:	09 d0                	or     %edx,%eax
  802521:	d3 ef                	shr    %cl,%edi
  802523:	89 fa                	mov    %edi,%edx
  802525:	f7 75 e0             	divl   0xffffffe0(%ebp)
  802528:	89 d1                	mov    %edx,%ecx
  80252a:	89 c7                	mov    %eax,%edi
  80252c:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80252f:	f7 e7                	mul    %edi
  802531:	39 d1                	cmp    %edx,%ecx
  802533:	89 c6                	mov    %eax,%esi
  802535:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  802538:	72 6f                	jb     8025a9 <__udivdi3+0x119>
  80253a:	39 ca                	cmp    %ecx,%edx
  80253c:	74 5e                	je     80259c <__udivdi3+0x10c>
  80253e:	89 f9                	mov    %edi,%ecx
  802540:	31 f6                	xor    %esi,%esi
  802542:	e9 79 ff ff ff       	jmp    8024c0 <__udivdi3+0x30>
  802547:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80254a:	85 c0                	test   %eax,%eax
  80254c:	74 32                	je     802580 <__udivdi3+0xf0>
  80254e:	89 f2                	mov    %esi,%edx
  802550:	89 f8                	mov    %edi,%eax
  802552:	f7 f1                	div    %ecx
  802554:	89 c6                	mov    %eax,%esi
  802556:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802559:	f7 f1                	div    %ecx
  80255b:	89 c1                	mov    %eax,%ecx
  80255d:	e9 5e ff ff ff       	jmp    8024c0 <__udivdi3+0x30>
  802562:	39 d7                	cmp    %edx,%edi
  802564:	77 2a                	ja     802590 <__udivdi3+0x100>
  802566:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  802569:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
  80256c:	73 22                	jae    802590 <__udivdi3+0x100>
  80256e:	66 90                	xchg   %ax,%ax
  802570:	31 c9                	xor    %ecx,%ecx
  802572:	31 f6                	xor    %esi,%esi
  802574:	e9 47 ff ff ff       	jmp    8024c0 <__udivdi3+0x30>
  802579:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  802580:	b8 01 00 00 00       	mov    $0x1,%eax
  802585:	31 d2                	xor    %edx,%edx
  802587:	f7 75 f0             	divl   0xfffffff0(%ebp)
  80258a:	89 c1                	mov    %eax,%ecx
  80258c:	eb c0                	jmp    80254e <__udivdi3+0xbe>
  80258e:	66 90                	xchg   %ax,%ax
  802590:	b9 01 00 00 00       	mov    $0x1,%ecx
  802595:	31 f6                	xor    %esi,%esi
  802597:	e9 24 ff ff ff       	jmp    8024c0 <__udivdi3+0x30>
  80259c:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  80259f:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8025a3:	d3 e0                	shl    %cl,%eax
  8025a5:	39 c6                	cmp    %eax,%esi
  8025a7:	76 95                	jbe    80253e <__udivdi3+0xae>
  8025a9:	8d 4f ff             	lea    0xffffffff(%edi),%ecx
  8025ac:	31 f6                	xor    %esi,%esi
  8025ae:	e9 0d ff ff ff       	jmp    8024c0 <__udivdi3+0x30>
	...

008025c0 <__umoddi3>:
  8025c0:	55                   	push   %ebp
  8025c1:	89 e5                	mov    %esp,%ebp
  8025c3:	57                   	push   %edi
  8025c4:	56                   	push   %esi
  8025c5:	83 ec 30             	sub    $0x30,%esp
  8025c8:	8b 55 14             	mov    0x14(%ebp),%edx
  8025cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8025ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8025d1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8025d4:	85 d2                	test   %edx,%edx
  8025d6:	c7 45 d0 00 00 00 00 	movl   $0x0,0xffffffd0(%ebp)
  8025dd:	89 c1                	mov    %eax,%ecx
  8025df:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  8025e6:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  8025e9:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  8025ec:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  8025ef:	89 7d e0             	mov    %edi,0xffffffe0(%ebp)
  8025f2:	75 1c                	jne    802610 <__umoddi3+0x50>
  8025f4:	39 f8                	cmp    %edi,%eax
  8025f6:	89 fa                	mov    %edi,%edx
  8025f8:	0f 86 d4 00 00 00    	jbe    8026d2 <__umoddi3+0x112>
  8025fe:	89 f0                	mov    %esi,%eax
  802600:	f7 f1                	div    %ecx
  802602:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802605:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  80260c:	eb 12                	jmp    802620 <__umoddi3+0x60>
  80260e:	66 90                	xchg   %ax,%ax
  802610:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802613:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  802616:	76 18                	jbe    802630 <__umoddi3+0x70>
  802618:	89 75 d0             	mov    %esi,0xffffffd0(%ebp)
  80261b:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  80261e:	66 90                	xchg   %ax,%ax
  802620:	8b 45 d0             	mov    0xffffffd0(%ebp),%eax
  802623:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  802626:	83 c4 30             	add    $0x30,%esp
  802629:	5e                   	pop    %esi
  80262a:	5f                   	pop    %edi
  80262b:	5d                   	pop    %ebp
  80262c:	c3                   	ret    
  80262d:	8d 76 00             	lea    0x0(%esi),%esi
  802630:	0f bd 45 e8          	bsr    0xffffffe8(%ebp),%eax
  802634:	83 f0 1f             	xor    $0x1f,%eax
  802637:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  80263a:	0f 84 c0 00 00 00    	je     802700 <__umoddi3+0x140>
  802640:	b8 20 00 00 00       	mov    $0x20,%eax
  802645:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  802648:	2b 45 dc             	sub    0xffffffdc(%ebp),%eax
  80264b:	8b 7d ec             	mov    0xffffffec(%ebp),%edi
  80264e:	8b 75 f0             	mov    0xfffffff0(%ebp),%esi
  802651:	89 c1                	mov    %eax,%ecx
  802653:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  802656:	d3 ea                	shr    %cl,%edx
  802658:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  80265b:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  80265f:	d3 e0                	shl    %cl,%eax
  802661:	09 c2                	or     %eax,%edx
  802663:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802666:	d3 e7                	shl    %cl,%edi
  802668:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  80266c:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  80266f:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  802672:	d3 e8                	shr    %cl,%eax
  802674:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  802678:	d3 e2                	shl    %cl,%edx
  80267a:	09 d0                	or     %edx,%eax
  80267c:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  80267f:	d3 e6                	shl    %cl,%esi
  802681:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802685:	d3 ea                	shr    %cl,%edx
  802687:	f7 75 f4             	divl   0xfffffff4(%ebp)
  80268a:	89 55 cc             	mov    %edx,0xffffffcc(%ebp)
  80268d:	f7 e7                	mul    %edi
  80268f:	39 55 cc             	cmp    %edx,0xffffffcc(%ebp)
  802692:	0f 82 a5 00 00 00    	jb     80273d <__umoddi3+0x17d>
  802698:	3b 55 cc             	cmp    0xffffffcc(%ebp),%edx
  80269b:	0f 84 94 00 00 00    	je     802735 <__umoddi3+0x175>
  8026a1:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
  8026a4:	29 c6                	sub    %eax,%esi
  8026a6:	19 d1                	sbb    %edx,%ecx
  8026a8:	89 4d cc             	mov    %ecx,0xffffffcc(%ebp)
  8026ab:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  8026af:	89 f2                	mov    %esi,%edx
  8026b1:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  8026b4:	d3 ea                	shr    %cl,%edx
  8026b6:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8026ba:	d3 e0                	shl    %cl,%eax
  8026bc:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  8026c0:	09 c2                	or     %eax,%edx
  8026c2:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  8026c5:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  8026c8:	d3 e8                	shr    %cl,%eax
  8026ca:	89 45 d4             	mov    %eax,0xffffffd4(%ebp)
  8026cd:	e9 4e ff ff ff       	jmp    802620 <__umoddi3+0x60>
  8026d2:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  8026d5:	85 c0                	test   %eax,%eax
  8026d7:	74 17                	je     8026f0 <__umoddi3+0x130>
  8026d9:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  8026dc:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
  8026df:	f7 f1                	div    %ecx
  8026e1:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8026e4:	f7 f1                	div    %ecx
  8026e6:	e9 17 ff ff ff       	jmp    802602 <__umoddi3+0x42>
  8026eb:	90                   	nop    
  8026ec:	8d 74 26 00          	lea    0x0(%esi),%esi
  8026f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8026f5:	31 d2                	xor    %edx,%edx
  8026f7:	f7 75 ec             	divl   0xffffffec(%ebp)
  8026fa:	89 c1                	mov    %eax,%ecx
  8026fc:	eb db                	jmp    8026d9 <__umoddi3+0x119>
  8026fe:	66 90                	xchg   %ax,%ax
  802700:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802703:	39 45 e0             	cmp    %eax,0xffffffe0(%ebp)
  802706:	77 19                	ja     802721 <__umoddi3+0x161>
  802708:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  80270b:	39 55 f0             	cmp    %edx,0xfffffff0(%ebp)
  80270e:	73 11                	jae    802721 <__umoddi3+0x161>
  802710:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  802713:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802716:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802719:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  80271c:	e9 ff fe ff ff       	jmp    802620 <__umoddi3+0x60>
  802721:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802724:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802727:	2b 45 ec             	sub    0xffffffec(%ebp),%eax
  80272a:	1b 4d e8             	sbb    0xffffffe8(%ebp),%ecx
  80272d:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  802730:	89 4d e0             	mov    %ecx,0xffffffe0(%ebp)
  802733:	eb db                	jmp    802710 <__umoddi3+0x150>
  802735:	39 f0                	cmp    %esi,%eax
  802737:	0f 86 64 ff ff ff    	jbe    8026a1 <__umoddi3+0xe1>
  80273d:	29 f8                	sub    %edi,%eax
  80273f:	1b 55 f4             	sbb    0xfffffff4(%ebp),%edx
  802742:	e9 5a ff ff ff       	jmp    8026a1 <__umoddi3+0xe1>
