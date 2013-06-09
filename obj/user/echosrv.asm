
obj/user/echosrv:     file format elf32-i386

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
  80002c:	e8 ef 01 00 00       	call   800220 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <die>:
#define MAXPENDING 5    // Max connection requests

static void
die(char *m)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 08             	sub    $0x8,%esp
	cprintf("%s\n", m);
  800046:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004a:	c7 04 24 d0 27 80 00 	movl   $0x8027d0,(%esp)
  800051:	e8 a3 02 00 00       	call   8002f9 <cprintf>
	exit();
  800056:	e8 21 02 00 00       	call   80027c <exit>
}
  80005b:	c9                   	leave  
  80005c:	c3                   	ret    

0080005d <handle_client>:

void
handle_client(int sock)
{
  80005d:	55                   	push   %ebp
  80005e:	89 e5                	mov    %esp,%ebp
  800060:	56                   	push   %esi
  800061:	53                   	push   %ebx
  800062:	83 ec 30             	sub    $0x30,%esp
  800065:	8b 75 08             	mov    0x8(%ebp),%esi
	char buffer[BUFFSIZE];
	int received = -1;
	// Receive message
	if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  800068:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
  80006f:	00 
  800070:	8d 45 d8             	lea    0xffffffd8(%ebp),%eax
  800073:	89 44 24 04          	mov    %eax,0x4(%esp)
  800077:	89 34 24             	mov    %esi,(%esp)
  80007a:	e8 3e 14 00 00       	call   8014bd <read>
  80007f:	89 c3                	mov    %eax,%ebx
  800081:	85 c0                	test   %eax,%eax
  800083:	78 06                	js     80008b <handle_client+0x2e>
		die("Failed to receive initial bytes from client");

	// Send bytes and check for more incoming data in loop
	while (received > 0) {
  800085:	85 c0                	test   %eax,%eax
  800087:	7f 1a                	jg     8000a3 <handle_client+0x46>
  800089:	eb 5a                	jmp    8000e5 <handle_client+0x88>
  80008b:	b8 d4 27 80 00       	mov    $0x8027d4,%eax
  800090:	e8 ab ff ff ff       	call   800040 <die>
  800095:	eb 4e                	jmp    8000e5 <handle_client+0x88>
		// Send back received data
		if (write(sock, buffer, received) != received)
			die("Failed to send bytes to client");

		// Check for more data
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
			die("Failed to receive additional bytes from client");
  800097:	b8 20 28 80 00       	mov    $0x802820,%eax
  80009c:	e8 9f ff ff ff       	call   800040 <die>
  8000a1:	eb 42                	jmp    8000e5 <handle_client+0x88>
  8000a3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000a7:	8d 45 d8             	lea    0xffffffd8(%ebp),%eax
  8000aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ae:	89 34 24             	mov    %esi,(%esp)
  8000b1:	e8 7c 13 00 00       	call   801432 <write>
  8000b6:	39 d8                	cmp    %ebx,%eax
  8000b8:	74 0a                	je     8000c4 <handle_client+0x67>
  8000ba:	b8 00 28 80 00       	mov    $0x802800,%eax
  8000bf:	e8 7c ff ff ff       	call   800040 <die>
  8000c4:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
  8000cb:	00 
  8000cc:	8d 45 d8             	lea    0xffffffd8(%ebp),%eax
  8000cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d3:	89 34 24             	mov    %esi,(%esp)
  8000d6:	e8 e2 13 00 00       	call   8014bd <read>
  8000db:	89 c3                	mov    %eax,%ebx
  8000dd:	85 c0                	test   %eax,%eax
  8000df:	78 b6                	js     800097 <handle_client+0x3a>
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	7f be                	jg     8000a3 <handle_client+0x46>
	}
	close(sock);
  8000e5:	89 34 24             	mov    %esi,(%esp)
  8000e8:	e8 3e 15 00 00       	call   80162b <close>
}
  8000ed:	83 c4 30             	add    $0x30,%esp
  8000f0:	5b                   	pop    %ebx
  8000f1:	5e                   	pop    %esi
  8000f2:	5d                   	pop    %ebp
  8000f3:	c3                   	ret    

008000f4 <umain>:

int
umain(void)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	57                   	push   %edi
  8000f8:	56                   	push   %esi
  8000f9:	53                   	push   %ebx
  8000fa:	83 ec 3c             	sub    $0x3c,%esp
	int serversock, clientsock;
	struct sockaddr_in echoserver, echoclient;
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  8000fd:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  800104:	00 
  800105:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80010c:	00 
  80010d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800114:	e8 9c 1a 00 00       	call   801bb5 <socket>
  800119:	89 c6                	mov    %eax,%esi
  80011b:	85 c0                	test   %eax,%eax
  80011d:	79 0a                	jns    800129 <umain+0x35>
		die("Failed to create socket");
  80011f:	b8 80 27 80 00       	mov    $0x802780,%eax
  800124:	e8 17 ff ff ff       	call   800040 <die>

	cprintf("opened socket\n");
  800129:	c7 04 24 98 27 80 00 	movl   $0x802798,(%esp)
  800130:	e8 c4 01 00 00       	call   8002f9 <cprintf>

	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  800135:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  80013c:	00 
  80013d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800144:	00 
  800145:	8d 5d e4             	lea    0xffffffe4(%ebp),%ebx
  800148:	89 1c 24             	mov    %ebx,(%esp)
  80014b:	e8 e1 09 00 00       	call   800b31 <memset>
	echoserver.sin_family = AF_INET;                  // Internet/IP
  800150:	c6 45 e5 02          	movb   $0x2,0xffffffe5(%ebp)
	echoserver.sin_addr.s_addr = htonl(INADDR_ANY);   // IP address
  800154:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80015b:	e8 3c 21 00 00       	call   80229c <htonl>
  800160:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
	echoserver.sin_port = htons(PORT);		  // server port
  800163:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80016a:	e8 00 21 00 00       	call   80226f <htons>
  80016f:	66 89 45 e6          	mov    %ax,0xffffffe6(%ebp)

	cprintf("trying to bind\n");
  800173:	c7 04 24 a7 27 80 00 	movl   $0x8027a7,(%esp)
  80017a:	e8 7a 01 00 00       	call   8002f9 <cprintf>

	// Bind the server socket
	if (bind(serversock, (struct sockaddr *) &echoserver,
  80017f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  800186:	00 
  800187:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80018b:	89 34 24             	mov    %esi,(%esp)
  80018e:	e8 04 1b 00 00       	call   801c97 <bind>
  800193:	85 c0                	test   %eax,%eax
  800195:	79 0a                	jns    8001a1 <umain+0xad>
		 sizeof(echoserver)) < 0) {
		die("Failed to bind the server socket");
  800197:	b8 50 28 80 00       	mov    $0x802850,%eax
  80019c:	e8 9f fe ff ff       	call   800040 <die>
	}

	// Listen on the server socket
	if (listen(serversock, MAXPENDING) < 0)
  8001a1:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  8001a8:	00 
  8001a9:	89 34 24             	mov    %esi,(%esp)
  8001ac:	e8 64 1a 00 00       	call   801c15 <listen>
  8001b1:	85 c0                	test   %eax,%eax
  8001b3:	79 0a                	jns    8001bf <umain+0xcb>
		die("Failed to listen on server socket");
  8001b5:	b8 74 28 80 00       	mov    $0x802874,%eax
  8001ba:	e8 81 fe ff ff       	call   800040 <die>

	cprintf("bound\n");
  8001bf:	c7 04 24 b7 27 80 00 	movl   $0x8027b7,(%esp)
  8001c6:	e8 2e 01 00 00       	call   8002f9 <cprintf>
  8001cb:	8d 7d d4             	lea    0xffffffd4(%ebp),%edi

	// Run until canceled
	while (1) {
		unsigned int clientlen = sizeof(echoclient);
  8001ce:	c7 45 d0 10 00 00 00 	movl   $0x10,0xffffffd0(%ebp)
		// Wait for client connection
		if ((clientsock =
  8001d5:	8d 45 d0             	lea    0xffffffd0(%ebp),%eax
  8001d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8001e0:	89 34 24             	mov    %esi,(%esp)
  8001e3:	e8 df 1a 00 00       	call   801cc7 <accept>
  8001e8:	89 c3                	mov    %eax,%ebx
  8001ea:	85 c0                	test   %eax,%eax
  8001ec:	79 0a                	jns    8001f8 <umain+0x104>
		     accept(serversock, (struct sockaddr *) &echoclient,
			    &clientlen)) < 0) {
			die("Failed to accept client connection");
  8001ee:	b8 98 28 80 00       	mov    $0x802898,%eax
  8001f3:	e8 48 fe ff ff       	call   800040 <die>
		}
		cprintf("Client connected: %s\n", inet_ntoa(echoclient.sin_addr));
  8001f8:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  8001fb:	89 04 24             	mov    %eax,(%esp)
  8001fe:	e8 bd 1f 00 00       	call   8021c0 <inet_ntoa>
  800203:	89 44 24 04          	mov    %eax,0x4(%esp)
  800207:	c7 04 24 be 27 80 00 	movl   $0x8027be,(%esp)
  80020e:	e8 e6 00 00 00       	call   8002f9 <cprintf>
		handle_client(clientsock);
  800213:	89 1c 24             	mov    %ebx,(%esp)
  800216:	e8 42 fe ff ff       	call   80005d <handle_client>
  80021b:	eb b1                	jmp    8001ce <umain+0xda>
  80021d:	00 00                	add    %al,(%eax)
	...

00800220 <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	83 ec 18             	sub    $0x18,%esp
  800226:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  800229:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  80022c:	8b 75 08             	mov    0x8(%ebp),%esi
  80022f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  800232:	c7 05 4c 60 80 00 00 	movl   $0x0,0x80604c
  800239:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  80023c:	e8 fc 0e 00 00       	call   80113d <sys_getenvid>
  800241:	25 ff 03 00 00       	and    $0x3ff,%eax
  800246:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800249:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80024e:	a3 4c 60 80 00       	mov    %eax,0x80604c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800253:	85 f6                	test   %esi,%esi
  800255:	7e 07                	jle    80025e <libmain+0x3e>
		binaryname = argv[0];
  800257:	8b 03                	mov    (%ebx),%eax
  800259:	a3 00 60 80 00       	mov    %eax,0x806000

	// call user main routine调用用户主例程
	umain(argc, argv);
  80025e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800262:	89 34 24             	mov    %esi,(%esp)
  800265:	e8 8a fe ff ff       	call   8000f4 <umain>

	// exit gracefully
	exit();
  80026a:	e8 0d 00 00 00       	call   80027c <exit>
}
  80026f:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  800272:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  800275:	89 ec                	mov    %ebp,%esp
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    
  800279:	00 00                	add    %al,(%eax)
	...

0080027c <exit>:
#include <inc/lib.h>

void
exit(void)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800282:	e8 3f 15 00 00       	call   8017c6 <close_all>
	sys_env_destroy(0);
  800287:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80028e:	e8 de 0e 00 00       	call   801171 <sys_env_destroy>
}
  800293:	c9                   	leave  
  800294:	c3                   	ret    
  800295:	00 00                	add    %al,(%eax)
	...

00800298 <vcprintf>:
}

int
vcprintf(const char *fmt, va_list ap)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002a1:	c7 85 f8 fe ff ff 00 	movl   $0x0,0xfffffef8(%ebp)
  8002a8:	00 00 00 
	b.cnt = 0;
  8002ab:	c7 85 fc fe ff ff 00 	movl   $0x0,0xfffffefc(%ebp)
  8002b2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c3:	8d 85 f8 fe ff ff    	lea    0xfffffef8(%ebp),%eax
  8002c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cd:	c7 04 24 16 03 80 00 	movl   $0x800316,(%esp)
  8002d4:	e8 c8 01 00 00       	call   8004a1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002d9:	8b 85 f8 fe ff ff    	mov    0xfffffef8(%ebp),%eax
  8002df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e3:	8d 85 00 ff ff ff    	lea    0xffffff00(%ebp),%eax
  8002e9:	89 04 24             	mov    %eax,(%esp)
  8002ec:	e8 e7 0a 00 00       	call   800dd8 <sys_cputs>
  8002f1:	8b 85 fc fe ff ff    	mov    0xfffffefc(%ebp),%eax

	return b.cnt;
}
  8002f7:	c9                   	leave  
  8002f8:	c3                   	ret    

008002f9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002f9:	55                   	push   %ebp
  8002fa:	89 e5                	mov    %esp,%ebp
  8002fc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002ff:	8d 45 0c             	lea    0xc(%ebp),%eax
  800302:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
	cnt = vcprintf(fmt, ap);
  800305:	89 44 24 04          	mov    %eax,0x4(%esp)
  800309:	8b 45 08             	mov    0x8(%ebp),%eax
  80030c:	89 04 24             	mov    %eax,(%esp)
  80030f:	e8 84 ff ff ff       	call   800298 <vcprintf>
	va_end(ap);

	return cnt;
}
  800314:	c9                   	leave  
  800315:	c3                   	ret    

00800316 <putch>:
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	53                   	push   %ebx
  80031a:	83 ec 14             	sub    $0x14,%esp
  80031d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800320:	8b 03                	mov    (%ebx),%eax
  800322:	8b 55 08             	mov    0x8(%ebp),%edx
  800325:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800329:	83 c0 01             	add    $0x1,%eax
  80032c:	89 03                	mov    %eax,(%ebx)
  80032e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800333:	75 19                	jne    80034e <putch+0x38>
  800335:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80033c:	00 
  80033d:	8d 43 08             	lea    0x8(%ebx),%eax
  800340:	89 04 24             	mov    %eax,(%esp)
  800343:	e8 90 0a 00 00       	call   800dd8 <sys_cputs>
  800348:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80034e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
  800352:	83 c4 14             	add    $0x14,%esp
  800355:	5b                   	pop    %ebx
  800356:	5d                   	pop    %ebp
  800357:	c3                   	ret    
	...

00800360 <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	57                   	push   %edi
  800364:	56                   	push   %esi
  800365:	53                   	push   %ebx
  800366:	83 ec 3c             	sub    $0x3c,%esp
  800369:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  80036c:	89 d7                	mov    %edx,%edi
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	8b 55 0c             	mov    0xc(%ebp),%edx
  800374:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800377:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  80037a:	8b 55 10             	mov    0x10(%ebp),%edx
  80037d:	8b 45 14             	mov    0x14(%ebp),%eax
  800380:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800383:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  800386:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  80038d:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800390:	39 4d ec             	cmp    %ecx,0xffffffec(%ebp)
  800393:	72 11                	jb     8003a6 <printnum+0x46>
  800395:	8b 4d d8             	mov    0xffffffd8(%ebp),%ecx
  800398:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  80039b:	76 09                	jbe    8003a6 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80039d:	8d 58 ff             	lea    0xffffffff(%eax),%ebx
  8003a0:	85 db                	test   %ebx,%ebx
  8003a2:	7f 54                	jg     8003f8 <printnum+0x98>
  8003a4:	eb 61                	jmp    800407 <printnum+0xa7>
  8003a6:	89 74 24 10          	mov    %esi,0x10(%esp)
  8003aa:	83 e8 01             	sub    $0x1,%eax
  8003ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003b1:	89 54 24 08          	mov    %edx,0x8(%esp)
  8003b5:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8003b9:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8003bd:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8003c0:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  8003c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003c7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003cb:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  8003ce:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  8003d1:	89 14 24             	mov    %edx,(%esp)
  8003d4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8003d8:	e8 e3 20 00 00       	call   8024c0 <__udivdi3>
  8003dd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003e1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003e5:	89 04 24             	mov    %eax,(%esp)
  8003e8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003ec:	89 fa                	mov    %edi,%edx
  8003ee:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  8003f1:	e8 6a ff ff ff       	call   800360 <printnum>
  8003f6:	eb 0f                	jmp    800407 <printnum+0xa7>
			putch(padc, putdat);
  8003f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003fc:	89 34 24             	mov    %esi,(%esp)
  8003ff:	ff 55 e4             	call   *0xffffffe4(%ebp)
  800402:	83 eb 01             	sub    $0x1,%ebx
  800405:	75 f1                	jne    8003f8 <printnum+0x98>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800407:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80040b:	8b 74 24 04          	mov    0x4(%esp),%esi
  80040f:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800412:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800415:	89 44 24 08          	mov    %eax,0x8(%esp)
  800419:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80041d:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800420:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800423:	89 14 24             	mov    %edx,(%esp)
  800426:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80042a:	e8 c1 21 00 00       	call   8025f0 <__umoddi3>
  80042f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800433:	0f be 80 d2 28 80 00 	movsbl 0x8028d2(%eax),%eax
  80043a:	89 04 24             	mov    %eax,(%esp)
  80043d:	ff 55 e4             	call   *0xffffffe4(%ebp)
}
  800440:	83 c4 3c             	add    $0x3c,%esp
  800443:	5b                   	pop    %ebx
  800444:	5e                   	pop    %esi
  800445:	5f                   	pop    %edi
  800446:	5d                   	pop    %ebp
  800447:	c3                   	ret    

00800448 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
  80044b:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  80044d:	83 fa 01             	cmp    $0x1,%edx
  800450:	7e 0e                	jle    800460 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  800452:	8b 10                	mov    (%eax),%edx
  800454:	8d 42 08             	lea    0x8(%edx),%eax
  800457:	89 01                	mov    %eax,(%ecx)
  800459:	8b 02                	mov    (%edx),%eax
  80045b:	8b 52 04             	mov    0x4(%edx),%edx
  80045e:	eb 22                	jmp    800482 <getuint+0x3a>
	else if (lflag)
  800460:	85 d2                	test   %edx,%edx
  800462:	74 10                	je     800474 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800464:	8b 10                	mov    (%eax),%edx
  800466:	8d 42 04             	lea    0x4(%edx),%eax
  800469:	89 01                	mov    %eax,(%ecx)
  80046b:	8b 02                	mov    (%edx),%eax
  80046d:	ba 00 00 00 00       	mov    $0x0,%edx
  800472:	eb 0e                	jmp    800482 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800474:	8b 10                	mov    (%eax),%edx
  800476:	8d 42 04             	lea    0x4(%edx),%eax
  800479:	89 01                	mov    %eax,(%ecx)
  80047b:	8b 02                	mov    (%edx),%eax
  80047d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800482:	5d                   	pop    %ebp
  800483:	c3                   	ret    

00800484 <sprintputch>:

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
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  80048a:	83 41 08 01          	addl   $0x1,0x8(%ecx)
	if (b->buf < b->ebuf)
  80048e:	8b 11                	mov    (%ecx),%edx
  800490:	3b 51 04             	cmp    0x4(%ecx),%edx
  800493:	73 0a                	jae    80049f <sprintputch+0x1b>
		*b->buf++ = ch;
  800495:	8b 45 08             	mov    0x8(%ebp),%eax
  800498:	88 02                	mov    %al,(%edx)
  80049a:	8d 42 01             	lea    0x1(%edx),%eax
  80049d:	89 01                	mov    %eax,(%ecx)
}
  80049f:	5d                   	pop    %ebp
  8004a0:	c3                   	ret    

008004a1 <vprintfmt>:
  8004a1:	55                   	push   %ebp
  8004a2:	89 e5                	mov    %esp,%ebp
  8004a4:	57                   	push   %edi
  8004a5:	56                   	push   %esi
  8004a6:	53                   	push   %ebx
  8004a7:	83 ec 4c             	sub    $0x4c,%esp
  8004aa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004b0:	eb 03                	jmp    8004b5 <vprintfmt+0x14>
  8004b2:	8b 5d e8             	mov    0xffffffe8(%ebp),%ebx
  8004b5:	0f b6 03             	movzbl (%ebx),%eax
  8004b8:	83 c3 01             	add    $0x1,%ebx
  8004bb:	3c 25                	cmp    $0x25,%al
  8004bd:	74 30                	je     8004ef <vprintfmt+0x4e>
  8004bf:	84 c0                	test   %al,%al
  8004c1:	0f 84 a8 03 00 00    	je     80086f <vprintfmt+0x3ce>
  8004c7:	0f b6 d0             	movzbl %al,%edx
  8004ca:	eb 0a                	jmp    8004d6 <vprintfmt+0x35>
  8004cc:	84 c0                	test   %al,%al
  8004ce:	66 90                	xchg   %ax,%ax
  8004d0:	0f 84 99 03 00 00    	je     80086f <vprintfmt+0x3ce>
  8004d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004dd:	89 14 24             	mov    %edx,(%esp)
  8004e0:	ff d7                	call   *%edi
  8004e2:	0f b6 03             	movzbl (%ebx),%eax
  8004e5:	0f b6 d0             	movzbl %al,%edx
  8004e8:	83 c3 01             	add    $0x1,%ebx
  8004eb:	3c 25                	cmp    $0x25,%al
  8004ed:	75 dd                	jne    8004cc <vprintfmt+0x2b>
  8004ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004f4:	c7 45 ec ff ff ff ff 	movl   $0xffffffff,0xffffffec(%ebp)
  8004fb:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  800502:	c7 45 dc 00 00 00 00 	movl   $0x0,0xffffffdc(%ebp)
  800509:	c6 45 e3 20          	movb   $0x20,0xffffffe3(%ebp)
  80050d:	eb 07                	jmp    800516 <vprintfmt+0x75>
  80050f:	c7 45 dc 01 00 00 00 	movl   $0x1,0xffffffdc(%ebp)
  800516:	0f b6 03             	movzbl (%ebx),%eax
  800519:	0f b6 d0             	movzbl %al,%edx
  80051c:	83 c3 01             	add    $0x1,%ebx
  80051f:	83 e8 23             	sub    $0x23,%eax
  800522:	3c 55                	cmp    $0x55,%al
  800524:	0f 87 11 03 00 00    	ja     80083b <vprintfmt+0x39a>
  80052a:	0f b6 c0             	movzbl %al,%eax
  80052d:	ff 24 85 20 2a 80 00 	jmp    *0x802a20(,%eax,4)
  800534:	c6 45 e3 30          	movb   $0x30,0xffffffe3(%ebp)
  800538:	eb dc                	jmp    800516 <vprintfmt+0x75>
  80053a:	83 ea 30             	sub    $0x30,%edx
  80053d:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  800540:	0f be 13             	movsbl (%ebx),%edx
  800543:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800546:	83 f8 09             	cmp    $0x9,%eax
  800549:	76 08                	jbe    800553 <vprintfmt+0xb2>
  80054b:	eb 42                	jmp    80058f <vprintfmt+0xee>
  80054d:	c6 45 e3 2d          	movb   $0x2d,0xffffffe3(%ebp)
  800551:	eb c3                	jmp    800516 <vprintfmt+0x75>
  800553:	83 c3 01             	add    $0x1,%ebx
  800556:	8b 75 e4             	mov    0xffffffe4(%ebp),%esi
  800559:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  80055c:	8d 44 42 d0          	lea    0xffffffd0(%edx,%eax,2),%eax
  800560:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  800563:	0f be 13             	movsbl (%ebx),%edx
  800566:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800569:	83 f8 09             	cmp    $0x9,%eax
  80056c:	77 21                	ja     80058f <vprintfmt+0xee>
  80056e:	eb e3                	jmp    800553 <vprintfmt+0xb2>
  800570:	8b 55 14             	mov    0x14(%ebp),%edx
  800573:	8d 42 04             	lea    0x4(%edx),%eax
  800576:	89 45 14             	mov    %eax,0x14(%ebp)
  800579:	8b 12                	mov    (%edx),%edx
  80057b:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  80057e:	eb 0f                	jmp    80058f <vprintfmt+0xee>
  800580:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800584:	79 90                	jns    800516 <vprintfmt+0x75>
  800586:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  80058d:	eb 87                	jmp    800516 <vprintfmt+0x75>
  80058f:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800593:	79 81                	jns    800516 <vprintfmt+0x75>
  800595:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  800598:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  80059b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  8005a2:	e9 6f ff ff ff       	jmp    800516 <vprintfmt+0x75>
  8005a7:	83 c1 01             	add    $0x1,%ecx
  8005aa:	e9 67 ff ff ff       	jmp    800516 <vprintfmt+0x75>
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	8d 50 04             	lea    0x4(%eax),%edx
  8005b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005bb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005bf:	8b 00                	mov    (%eax),%eax
  8005c1:	89 04 24             	mov    %eax,(%esp)
  8005c4:	ff d7                	call   *%edi
  8005c6:	e9 ea fe ff ff       	jmp    8004b5 <vprintfmt+0x14>
  8005cb:	8b 55 14             	mov    0x14(%ebp),%edx
  8005ce:	8d 42 04             	lea    0x4(%edx),%eax
  8005d1:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d4:	8b 02                	mov    (%edx),%eax
  8005d6:	89 c2                	mov    %eax,%edx
  8005d8:	c1 fa 1f             	sar    $0x1f,%edx
  8005db:	31 d0                	xor    %edx,%eax
  8005dd:	29 d0                	sub    %edx,%eax
  8005df:	83 f8 0f             	cmp    $0xf,%eax
  8005e2:	7f 0b                	jg     8005ef <vprintfmt+0x14e>
  8005e4:	8b 14 85 80 2b 80 00 	mov    0x802b80(,%eax,4),%edx
  8005eb:	85 d2                	test   %edx,%edx
  8005ed:	75 20                	jne    80060f <vprintfmt+0x16e>
  8005ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005f3:	c7 44 24 08 e3 28 80 	movl   $0x8028e3,0x8(%esp)
  8005fa:	00 
  8005fb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005fe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800602:	89 3c 24             	mov    %edi,(%esp)
  800605:	e8 f0 02 00 00       	call   8008fa <printfmt>
  80060a:	e9 a6 fe ff ff       	jmp    8004b5 <vprintfmt+0x14>
  80060f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800613:	c7 44 24 08 c2 2c 80 	movl   $0x802cc2,0x8(%esp)
  80061a:	00 
  80061b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80061e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800622:	89 3c 24             	mov    %edi,(%esp)
  800625:	e8 d0 02 00 00       	call   8008fa <printfmt>
  80062a:	e9 86 fe ff ff       	jmp    8004b5 <vprintfmt+0x14>
  80062f:	8b 75 ec             	mov    0xffffffec(%ebp),%esi
  800632:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  800635:	89 5d e8             	mov    %ebx,0xffffffe8(%ebp)
  800638:	8b 55 14             	mov    0x14(%ebp),%edx
  80063b:	8d 42 04             	lea    0x4(%edx),%eax
  80063e:	89 45 14             	mov    %eax,0x14(%ebp)
  800641:	8b 12                	mov    (%edx),%edx
  800643:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  800646:	85 d2                	test   %edx,%edx
  800648:	75 07                	jne    800651 <vprintfmt+0x1b0>
  80064a:	c7 45 d8 ec 28 80 00 	movl   $0x8028ec,0xffffffd8(%ebp)
  800651:	85 f6                	test   %esi,%esi
  800653:	7e 40                	jle    800695 <vprintfmt+0x1f4>
  800655:	80 7d e3 2d          	cmpb   $0x2d,0xffffffe3(%ebp)
  800659:	74 3a                	je     800695 <vprintfmt+0x1f4>
  80065b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80065f:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800662:	89 14 24             	mov    %edx,(%esp)
  800665:	e8 e6 02 00 00       	call   800950 <strnlen>
  80066a:	29 c6                	sub    %eax,%esi
  80066c:	89 75 ec             	mov    %esi,0xffffffec(%ebp)
  80066f:	85 f6                	test   %esi,%esi
  800671:	7e 22                	jle    800695 <vprintfmt+0x1f4>
  800673:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  800677:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  80067a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80067d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800681:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  800684:	89 04 24             	mov    %eax,(%esp)
  800687:	ff d7                	call   *%edi
  800689:	83 ee 01             	sub    $0x1,%esi
  80068c:	75 ec                	jne    80067a <vprintfmt+0x1d9>
  80068e:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  800695:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800698:	0f b6 02             	movzbl (%edx),%eax
  80069b:	0f be d0             	movsbl %al,%edx
  80069e:	8b 75 d8             	mov    0xffffffd8(%ebp),%esi
  8006a1:	84 c0                	test   %al,%al
  8006a3:	75 40                	jne    8006e5 <vprintfmt+0x244>
  8006a5:	eb 4a                	jmp    8006f1 <vprintfmt+0x250>
  8006a7:	83 7d dc 00          	cmpl   $0x0,0xffffffdc(%ebp)
  8006ab:	74 1a                	je     8006c7 <vprintfmt+0x226>
  8006ad:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  8006b0:	83 f8 5e             	cmp    $0x5e,%eax
  8006b3:	76 12                	jbe    8006c7 <vprintfmt+0x226>
  8006b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006bc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006c3:	ff d7                	call   *%edi
  8006c5:	eb 0c                	jmp    8006d3 <vprintfmt+0x232>
  8006c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ce:	89 14 24             	mov    %edx,(%esp)
  8006d1:	ff d7                	call   *%edi
  8006d3:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  8006d7:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8006db:	83 c6 01             	add    $0x1,%esi
  8006de:	84 c0                	test   %al,%al
  8006e0:	74 0f                	je     8006f1 <vprintfmt+0x250>
  8006e2:	0f be d0             	movsbl %al,%edx
  8006e5:	83 7d e4 00          	cmpl   $0x0,0xffffffe4(%ebp)
  8006e9:	78 bc                	js     8006a7 <vprintfmt+0x206>
  8006eb:	83 6d e4 01          	subl   $0x1,0xffffffe4(%ebp)
  8006ef:	79 b6                	jns    8006a7 <vprintfmt+0x206>
  8006f1:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  8006f5:	0f 8e ba fd ff ff    	jle    8004b5 <vprintfmt+0x14>
  8006fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  800702:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800709:	ff d7                	call   *%edi
  80070b:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  80070f:	0f 84 9d fd ff ff    	je     8004b2 <vprintfmt+0x11>
  800715:	eb e4                	jmp    8006fb <vprintfmt+0x25a>
  800717:	83 f9 01             	cmp    $0x1,%ecx
  80071a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800720:	7e 10                	jle    800732 <vprintfmt+0x291>
  800722:	8b 55 14             	mov    0x14(%ebp),%edx
  800725:	8d 42 08             	lea    0x8(%edx),%eax
  800728:	89 45 14             	mov    %eax,0x14(%ebp)
  80072b:	8b 02                	mov    (%edx),%eax
  80072d:	8b 52 04             	mov    0x4(%edx),%edx
  800730:	eb 26                	jmp    800758 <vprintfmt+0x2b7>
  800732:	85 c9                	test   %ecx,%ecx
  800734:	74 12                	je     800748 <vprintfmt+0x2a7>
  800736:	8b 45 14             	mov    0x14(%ebp),%eax
  800739:	8d 50 04             	lea    0x4(%eax),%edx
  80073c:	89 55 14             	mov    %edx,0x14(%ebp)
  80073f:	8b 00                	mov    (%eax),%eax
  800741:	89 c2                	mov    %eax,%edx
  800743:	c1 fa 1f             	sar    $0x1f,%edx
  800746:	eb 10                	jmp    800758 <vprintfmt+0x2b7>
  800748:	8b 45 14             	mov    0x14(%ebp),%eax
  80074b:	8d 50 04             	lea    0x4(%eax),%edx
  80074e:	89 55 14             	mov    %edx,0x14(%ebp)
  800751:	8b 00                	mov    (%eax),%eax
  800753:	89 c2                	mov    %eax,%edx
  800755:	c1 fa 1f             	sar    $0x1f,%edx
  800758:	89 d1                	mov    %edx,%ecx
  80075a:	89 c2                	mov    %eax,%edx
  80075c:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  80075f:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  800762:	be 0a 00 00 00       	mov    $0xa,%esi
  800767:	85 c9                	test   %ecx,%ecx
  800769:	0f 89 92 00 00 00    	jns    800801 <vprintfmt+0x360>
  80076f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800772:	89 74 24 04          	mov    %esi,0x4(%esp)
  800776:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80077d:	ff d7                	call   *%edi
  80077f:	8b 55 d0             	mov    0xffffffd0(%ebp),%edx
  800782:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
  800785:	f7 da                	neg    %edx
  800787:	83 d1 00             	adc    $0x0,%ecx
  80078a:	f7 d9                	neg    %ecx
  80078c:	be 0a 00 00 00       	mov    $0xa,%esi
  800791:	eb 6e                	jmp    800801 <vprintfmt+0x360>
  800793:	8d 45 14             	lea    0x14(%ebp),%eax
  800796:	89 ca                	mov    %ecx,%edx
  800798:	e8 ab fc ff ff       	call   800448 <getuint>
  80079d:	89 d1                	mov    %edx,%ecx
  80079f:	89 c2                	mov    %eax,%edx
  8007a1:	be 0a 00 00 00       	mov    $0xa,%esi
  8007a6:	eb 59                	jmp    800801 <vprintfmt+0x360>
  8007a8:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ab:	89 ca                	mov    %ecx,%edx
  8007ad:	e8 96 fc ff ff       	call   800448 <getuint>
  8007b2:	e9 fe fc ff ff       	jmp    8004b5 <vprintfmt+0x14>
  8007b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007be:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007c5:	ff d7                	call   *%edi
  8007c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ca:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007ce:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007d5:	ff d7                	call   *%edi
  8007d7:	8b 55 14             	mov    0x14(%ebp),%edx
  8007da:	8d 42 04             	lea    0x4(%edx),%eax
  8007dd:	89 45 14             	mov    %eax,0x14(%ebp)
  8007e0:	8b 12                	mov    (%edx),%edx
  8007e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007e7:	be 10 00 00 00       	mov    $0x10,%esi
  8007ec:	eb 13                	jmp    800801 <vprintfmt+0x360>
  8007ee:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f1:	89 ca                	mov    %ecx,%edx
  8007f3:	e8 50 fc ff ff       	call   800448 <getuint>
  8007f8:	89 d1                	mov    %edx,%ecx
  8007fa:	89 c2                	mov    %eax,%edx
  8007fc:	be 10 00 00 00       	mov    $0x10,%esi
  800801:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  800805:	89 44 24 10          	mov    %eax,0x10(%esp)
  800809:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  80080c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800810:	89 74 24 08          	mov    %esi,0x8(%esp)
  800814:	89 14 24             	mov    %edx,(%esp)
  800817:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80081b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081e:	89 f8                	mov    %edi,%eax
  800820:	e8 3b fb ff ff       	call   800360 <printnum>
  800825:	e9 8b fc ff ff       	jmp    8004b5 <vprintfmt+0x14>
  80082a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80082d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800831:	89 14 24             	mov    %edx,(%esp)
  800834:	ff d7                	call   *%edi
  800836:	e9 7a fc ff ff       	jmp    8004b5 <vprintfmt+0x14>
  80083b:	89 de                	mov    %ebx,%esi
  80083d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800840:	89 44 24 04          	mov    %eax,0x4(%esp)
  800844:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80084b:	ff d7                	call   *%edi
  80084d:	83 eb 01             	sub    $0x1,%ebx
  800850:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  800854:	0f 84 5b fc ff ff    	je     8004b5 <vprintfmt+0x14>
  80085a:	8d 56 fd             	lea    0xfffffffd(%esi),%edx
  80085d:	0f b6 02             	movzbl (%edx),%eax
  800860:	83 ea 01             	sub    $0x1,%edx
  800863:	3c 25                	cmp    $0x25,%al
  800865:	75 f6                	jne    80085d <vprintfmt+0x3bc>
  800867:	8d 5a 02             	lea    0x2(%edx),%ebx
  80086a:	e9 46 fc ff ff       	jmp    8004b5 <vprintfmt+0x14>
  80086f:	83 c4 4c             	add    $0x4c,%esp
  800872:	5b                   	pop    %ebx
  800873:	5e                   	pop    %esi
  800874:	5f                   	pop    %edi
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	83 ec 28             	sub    $0x28,%esp
  80087d:	8b 55 08             	mov    0x8(%ebp),%edx
  800880:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800883:	85 d2                	test   %edx,%edx
  800885:	74 04                	je     80088b <vsnprintf+0x14>
  800887:	85 c0                	test   %eax,%eax
  800889:	7f 07                	jg     800892 <vsnprintf+0x1b>
  80088b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800890:	eb 3b                	jmp    8008cd <vsnprintf+0x56>
  800892:	c7 45 fc 00 00 00 00 	movl   $0x0,0xfffffffc(%ebp)
  800899:	8d 44 02 ff          	lea    0xffffffff(%edx,%eax,1),%eax
  80089d:	89 45 f8             	mov    %eax,0xfffffff8(%ebp)
  8008a0:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008b1:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8008b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b8:	c7 04 24 84 04 80 00 	movl   $0x800484,(%esp)
  8008bf:	e8 dd fb ff ff       	call   8004a1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c4:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8008c7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008ca:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
}
  8008cd:	c9                   	leave  
  8008ce:	c3                   	ret    

008008cf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008d5:	8d 45 14             	lea    0x14(%ebp),%eax
  8008d8:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8008db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008df:	8b 45 10             	mov    0x10(%ebp),%eax
  8008e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f0:	89 04 24             	mov    %eax,(%esp)
  8008f3:	e8 7f ff ff ff       	call   800877 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008f8:	c9                   	leave  
  8008f9:	c3                   	ret    

008008fa <printfmt>:
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	83 ec 28             	sub    $0x28,%esp
  800900:	8d 45 14             	lea    0x14(%ebp),%eax
  800903:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
  800906:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80090a:	8b 45 10             	mov    0x10(%ebp),%eax
  80090d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800911:	8b 45 0c             	mov    0xc(%ebp),%eax
  800914:	89 44 24 04          	mov    %eax,0x4(%esp)
  800918:	8b 45 08             	mov    0x8(%ebp),%eax
  80091b:	89 04 24             	mov    %eax,(%esp)
  80091e:	e8 7e fb ff ff       	call   8004a1 <vprintfmt>
  800923:	c9                   	leave  
  800924:	c3                   	ret    
	...

00800930 <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800936:	b8 00 00 00 00       	mov    $0x0,%eax
  80093b:	80 3a 00             	cmpb   $0x0,(%edx)
  80093e:	74 0e                	je     80094e <strlen+0x1e>
  800940:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800945:	83 c0 01             	add    $0x1,%eax
  800948:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  80094c:	75 f7                	jne    800945 <strlen+0x15>
	return n;
}
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800956:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800959:	85 d2                	test   %edx,%edx
  80095b:	74 19                	je     800976 <strnlen+0x26>
  80095d:	80 39 00             	cmpb   $0x0,(%ecx)
  800960:	74 14                	je     800976 <strnlen+0x26>
  800962:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800967:	83 c0 01             	add    $0x1,%eax
  80096a:	39 d0                	cmp    %edx,%eax
  80096c:	74 0d                	je     80097b <strnlen+0x2b>
  80096e:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800972:	74 07                	je     80097b <strnlen+0x2b>
  800974:	eb f1                	jmp    800967 <strnlen+0x17>
  800976:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  80097b:	5d                   	pop    %ebp
  80097c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800980:	c3                   	ret    

00800981 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	53                   	push   %ebx
  800985:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800988:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80098b:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80098d:	0f b6 01             	movzbl (%ecx),%eax
  800990:	88 02                	mov    %al,(%edx)
  800992:	83 c2 01             	add    $0x1,%edx
  800995:	83 c1 01             	add    $0x1,%ecx
  800998:	84 c0                	test   %al,%al
  80099a:	75 f1                	jne    80098d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80099c:	89 d8                	mov    %ebx,%eax
  80099e:	5b                   	pop    %ebx
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	57                   	push   %edi
  8009a5:	56                   	push   %esi
  8009a6:	53                   	push   %ebx
  8009a7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ad:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b0:	85 f6                	test   %esi,%esi
  8009b2:	74 1c                	je     8009d0 <strncpy+0x2f>
  8009b4:	89 fa                	mov    %edi,%edx
  8009b6:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  8009bb:	0f b6 01             	movzbl (%ecx),%eax
  8009be:	88 02                	mov    %al,(%edx)
  8009c0:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009c3:	80 39 01             	cmpb   $0x1,(%ecx)
  8009c6:	83 d9 ff             	sbb    $0xffffffff,%ecx
  8009c9:	83 c3 01             	add    $0x1,%ebx
  8009cc:	39 f3                	cmp    %esi,%ebx
  8009ce:	75 eb                	jne    8009bb <strncpy+0x1a>
	}
	return ret;
}
  8009d0:	89 f8                	mov    %edi,%eax
  8009d2:	5b                   	pop    %ebx
  8009d3:	5e                   	pop    %esi
  8009d4:	5f                   	pop    %edi
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	56                   	push   %esi
  8009db:	53                   	push   %ebx
  8009dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8009df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e2:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009e5:	89 f0                	mov    %esi,%eax
  8009e7:	85 d2                	test   %edx,%edx
  8009e9:	74 2c                	je     800a17 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  8009eb:	89 d3                	mov    %edx,%ebx
  8009ed:	83 eb 01             	sub    $0x1,%ebx
  8009f0:	74 20                	je     800a12 <strlcpy+0x3b>
  8009f2:	0f b6 11             	movzbl (%ecx),%edx
  8009f5:	84 d2                	test   %dl,%dl
  8009f7:	74 19                	je     800a12 <strlcpy+0x3b>
  8009f9:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  8009fb:	88 10                	mov    %dl,(%eax)
  8009fd:	83 c0 01             	add    $0x1,%eax
  800a00:	83 eb 01             	sub    $0x1,%ebx
  800a03:	74 0f                	je     800a14 <strlcpy+0x3d>
  800a05:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  800a09:	83 c1 01             	add    $0x1,%ecx
  800a0c:	84 d2                	test   %dl,%dl
  800a0e:	74 04                	je     800a14 <strlcpy+0x3d>
  800a10:	eb e9                	jmp    8009fb <strlcpy+0x24>
  800a12:	89 f0                	mov    %esi,%eax
		*dst = '\0';
  800a14:	c6 00 00             	movb   $0x0,(%eax)
  800a17:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800a19:	5b                   	pop    %ebx
  800a1a:	5e                   	pop    %esi
  800a1b:	5d                   	pop    %ebp
  800a1c:	c3                   	ret    

00800a1d <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	57                   	push   %edi
  800a21:	56                   	push   %esi
  800a22:	53                   	push   %ebx
  800a23:	8b 55 08             	mov    0x8(%ebp),%edx
  800a26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a29:	8b 7d 10             	mov    0x10(%ebp),%edi
    int c;
    char *q = buf;

    if (buf_size <= 0)
  800a2c:	85 c9                	test   %ecx,%ecx
  800a2e:	7e 30                	jle    800a60 <pstrcpy+0x43>
        return;

    for(;;) {
        c = *str++;
  800a30:	0f b6 07             	movzbl (%edi),%eax
        if (c == 0 || q >= buf + buf_size - 1)
  800a33:	84 c0                	test   %al,%al
  800a35:	74 26                	je     800a5d <pstrcpy+0x40>
  800a37:	8d 74 0a ff          	lea    0xffffffff(%edx,%ecx,1),%esi
  800a3b:	0f be d8             	movsbl %al,%ebx
  800a3e:	89 f9                	mov    %edi,%ecx
  800a40:	39 f2                	cmp    %esi,%edx
  800a42:	72 09                	jb     800a4d <pstrcpy+0x30>
  800a44:	eb 17                	jmp    800a5d <pstrcpy+0x40>
  800a46:	83 c1 01             	add    $0x1,%ecx
  800a49:	39 f2                	cmp    %esi,%edx
  800a4b:	73 10                	jae    800a5d <pstrcpy+0x40>
            break;
        *q++ = c;
  800a4d:	88 1a                	mov    %bl,(%edx)
  800a4f:	83 c2 01             	add    $0x1,%edx
  800a52:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800a56:	0f be d8             	movsbl %al,%ebx
  800a59:	84 c0                	test   %al,%al
  800a5b:	75 e9                	jne    800a46 <pstrcpy+0x29>
    }
    *q = '\0';
  800a5d:	c6 02 00             	movb   $0x0,(%edx)
}
  800a60:	5b                   	pop    %ebx
  800a61:	5e                   	pop    %esi
  800a62:	5f                   	pop    %edi
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  800a6e:	0f b6 02             	movzbl (%edx),%eax
  800a71:	84 c0                	test   %al,%al
  800a73:	74 16                	je     800a8b <strcmp+0x26>
  800a75:	3a 01                	cmp    (%ecx),%al
  800a77:	75 12                	jne    800a8b <strcmp+0x26>
		p++, q++;
  800a79:	83 c1 01             	add    $0x1,%ecx
  800a7c:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  800a80:	84 c0                	test   %al,%al
  800a82:	74 07                	je     800a8b <strcmp+0x26>
  800a84:	83 c2 01             	add    $0x1,%edx
  800a87:	3a 01                	cmp    (%ecx),%al
  800a89:	74 ee                	je     800a79 <strcmp+0x14>
  800a8b:	0f b6 c0             	movzbl %al,%eax
  800a8e:	0f b6 11             	movzbl (%ecx),%edx
  800a91:	29 d0                	sub    %edx,%eax
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a93:	5d                   	pop    %ebp
  800a94:	c3                   	ret    

00800a95 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	53                   	push   %ebx
  800a99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a9c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a9f:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800aa2:	85 d2                	test   %edx,%edx
  800aa4:	74 2d                	je     800ad3 <strncmp+0x3e>
  800aa6:	0f b6 01             	movzbl (%ecx),%eax
  800aa9:	84 c0                	test   %al,%al
  800aab:	74 1a                	je     800ac7 <strncmp+0x32>
  800aad:	3a 03                	cmp    (%ebx),%al
  800aaf:	75 16                	jne    800ac7 <strncmp+0x32>
  800ab1:	83 ea 01             	sub    $0x1,%edx
  800ab4:	74 1d                	je     800ad3 <strncmp+0x3e>
		n--, p++, q++;
  800ab6:	83 c1 01             	add    $0x1,%ecx
  800ab9:	83 c3 01             	add    $0x1,%ebx
  800abc:	0f b6 01             	movzbl (%ecx),%eax
  800abf:	84 c0                	test   %al,%al
  800ac1:	74 04                	je     800ac7 <strncmp+0x32>
  800ac3:	3a 03                	cmp    (%ebx),%al
  800ac5:	74 ea                	je     800ab1 <strncmp+0x1c>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac7:	0f b6 11             	movzbl (%ecx),%edx
  800aca:	0f b6 03             	movzbl (%ebx),%eax
  800acd:	29 c2                	sub    %eax,%edx
  800acf:	89 d0                	mov    %edx,%eax
  800ad1:	eb 05                	jmp    800ad8 <strncmp+0x43>
  800ad3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad8:	5b                   	pop    %ebx
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ae5:	0f b6 10             	movzbl (%eax),%edx
  800ae8:	84 d2                	test   %dl,%dl
  800aea:	74 16                	je     800b02 <strchr+0x27>
		if (*s == c)
  800aec:	38 ca                	cmp    %cl,%dl
  800aee:	75 06                	jne    800af6 <strchr+0x1b>
  800af0:	eb 15                	jmp    800b07 <strchr+0x2c>
  800af2:	38 ca                	cmp    %cl,%dl
  800af4:	74 11                	je     800b07 <strchr+0x2c>
  800af6:	83 c0 01             	add    $0x1,%eax
  800af9:	0f b6 10             	movzbl (%eax),%edx
  800afc:	84 d2                	test   %dl,%dl
  800afe:	66 90                	xchg   %ax,%ax
  800b00:	75 f0                	jne    800af2 <strchr+0x17>
  800b02:	b8 00 00 00 00       	mov    $0x0,%eax
			return (char *) s;
	return 0;
}
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    

00800b09 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b13:	0f b6 10             	movzbl (%eax),%edx
  800b16:	84 d2                	test   %dl,%dl
  800b18:	74 14                	je     800b2e <strfind+0x25>
		if (*s == c)
  800b1a:	38 ca                	cmp    %cl,%dl
  800b1c:	75 06                	jne    800b24 <strfind+0x1b>
  800b1e:	eb 0e                	jmp    800b2e <strfind+0x25>
  800b20:	38 ca                	cmp    %cl,%dl
  800b22:	74 0a                	je     800b2e <strfind+0x25>
  800b24:	83 c0 01             	add    $0x1,%eax
  800b27:	0f b6 10             	movzbl (%eax),%edx
  800b2a:	84 d2                	test   %dl,%dl
  800b2c:	75 f2                	jne    800b20 <strfind+0x17>
			break;
	return (char *) s;
}
  800b2e:	5d                   	pop    %ebp
  800b2f:	90                   	nop    
  800b30:	c3                   	ret    

00800b31 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	83 ec 08             	sub    $0x8,%esp
  800b37:	89 1c 24             	mov    %ebx,(%esp)
  800b3a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b3e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b41:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b44:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800b47:	85 db                	test   %ebx,%ebx
  800b49:	74 32                	je     800b7d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b4b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b51:	75 25                	jne    800b78 <memset+0x47>
  800b53:	f6 c3 03             	test   $0x3,%bl
  800b56:	75 20                	jne    800b78 <memset+0x47>
		c &= 0xFF;
  800b58:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b5b:	89 d0                	mov    %edx,%eax
  800b5d:	c1 e0 18             	shl    $0x18,%eax
  800b60:	89 d1                	mov    %edx,%ecx
  800b62:	c1 e1 10             	shl    $0x10,%ecx
  800b65:	09 c8                	or     %ecx,%eax
  800b67:	09 d0                	or     %edx,%eax
  800b69:	c1 e2 08             	shl    $0x8,%edx
  800b6c:	09 d0                	or     %edx,%eax
  800b6e:	89 d9                	mov    %ebx,%ecx
  800b70:	c1 e9 02             	shr    $0x2,%ecx
  800b73:	fc                   	cld    
  800b74:	f3 ab                	rep stos %eax,%es:(%edi)
  800b76:	eb 05                	jmp    800b7d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b78:	89 d9                	mov    %ebx,%ecx
  800b7a:	fc                   	cld    
  800b7b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b7d:	89 f8                	mov    %edi,%eax
  800b7f:	8b 1c 24             	mov    (%esp),%ebx
  800b82:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b86:	89 ec                	mov    %ebp,%esp
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	83 ec 08             	sub    $0x8,%esp
  800b90:	89 34 24             	mov    %esi,(%esp)
  800b93:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b97:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800b9d:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800ba0:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800ba2:	39 c6                	cmp    %eax,%esi
  800ba4:	73 36                	jae    800bdc <memmove+0x52>
  800ba6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ba9:	39 d0                	cmp    %edx,%eax
  800bab:	73 2f                	jae    800bdc <memmove+0x52>
		s += n;
		d += n;
  800bad:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb0:	f6 c2 03             	test   $0x3,%dl
  800bb3:	75 1b                	jne    800bd0 <memmove+0x46>
  800bb5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bbb:	75 13                	jne    800bd0 <memmove+0x46>
  800bbd:	f6 c1 03             	test   $0x3,%cl
  800bc0:	75 0e                	jne    800bd0 <memmove+0x46>
			asm volatile("std; rep movsl\n"
  800bc2:	8d 7e fc             	lea    0xfffffffc(%esi),%edi
  800bc5:	8d 72 fc             	lea    0xfffffffc(%edx),%esi
  800bc8:	c1 e9 02             	shr    $0x2,%ecx
  800bcb:	fd                   	std    
  800bcc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bce:	eb 09                	jmp    800bd9 <memmove+0x4f>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bd0:	8d 7e ff             	lea    0xffffffff(%esi),%edi
  800bd3:	8d 72 ff             	lea    0xffffffff(%edx),%esi
  800bd6:	fd                   	std    
  800bd7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bd9:	fc                   	cld    
  800bda:	eb 21                	jmp    800bfd <memmove+0x73>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bdc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800be2:	75 16                	jne    800bfa <memmove+0x70>
  800be4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bea:	75 0e                	jne    800bfa <memmove+0x70>
  800bec:	f6 c1 03             	test   $0x3,%cl
  800bef:	90                   	nop    
  800bf0:	75 08                	jne    800bfa <memmove+0x70>
			asm volatile("cld; rep movsl\n"
  800bf2:	c1 e9 02             	shr    $0x2,%ecx
  800bf5:	fc                   	cld    
  800bf6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bf8:	eb 03                	jmp    800bfd <memmove+0x73>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bfa:	fc                   	cld    
  800bfb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bfd:	8b 34 24             	mov    (%esp),%esi
  800c00:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c04:	89 ec                	mov    %ebp,%esp
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <memcpy>:

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
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c0e:	8b 45 10             	mov    0x10(%ebp),%eax
  800c11:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c18:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1f:	89 04 24             	mov    %eax,(%esp)
  800c22:	e8 63 ff ff ff       	call   800b8a <memmove>
}
  800c27:	c9                   	leave  
  800c28:	c3                   	ret    

00800c29 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	56                   	push   %esi
  800c2d:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c2e:	8b 75 10             	mov    0x10(%ebp),%esi
  800c31:	83 ee 01             	sub    $0x1,%esi
  800c34:	83 fe ff             	cmp    $0xffffffff,%esi
  800c37:	74 38                	je     800c71 <memcmp+0x48>
  800c39:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3c:	8b 55 0c             	mov    0xc(%ebp),%edx
		if (*s1 != *s2)
  800c3f:	0f b6 18             	movzbl (%eax),%ebx
  800c42:	0f b6 0a             	movzbl (%edx),%ecx
  800c45:	38 cb                	cmp    %cl,%bl
  800c47:	74 20                	je     800c69 <memcmp+0x40>
  800c49:	eb 12                	jmp    800c5d <memcmp+0x34>
  800c4b:	0f b6 58 01          	movzbl 0x1(%eax),%ebx
  800c4f:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
  800c53:	83 c0 01             	add    $0x1,%eax
  800c56:	83 c2 01             	add    $0x1,%edx
  800c59:	38 cb                	cmp    %cl,%bl
  800c5b:	74 0c                	je     800c69 <memcmp+0x40>
			return (int) *s1 - (int) *s2;
  800c5d:	0f b6 d3             	movzbl %bl,%edx
  800c60:	0f b6 c1             	movzbl %cl,%eax
  800c63:	29 c2                	sub    %eax,%edx
  800c65:	89 d0                	mov    %edx,%eax
  800c67:	eb 0d                	jmp    800c76 <memcmp+0x4d>
  800c69:	83 ee 01             	sub    $0x1,%esi
  800c6c:	83 fe ff             	cmp    $0xffffffff,%esi
  800c6f:	75 da                	jne    800c4b <memcmp+0x22>
  800c71:	b8 00 00 00 00       	mov    $0x0,%eax
		s1++, s2++;
	}

	return 0;
}
  800c76:	5b                   	pop    %ebx
  800c77:	5e                   	pop    %esi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	53                   	push   %ebx
  800c7e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800c81:	89 da                	mov    %ebx,%edx
  800c83:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c86:	39 d3                	cmp    %edx,%ebx
  800c88:	73 1a                	jae    800ca4 <memfind+0x2a>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c8a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
			break;
  800c8e:	89 d8                	mov    %ebx,%eax
  800c90:	38 0b                	cmp    %cl,(%ebx)
  800c92:	75 06                	jne    800c9a <memfind+0x20>
  800c94:	eb 0e                	jmp    800ca4 <memfind+0x2a>
  800c96:	38 08                	cmp    %cl,(%eax)
  800c98:	74 0c                	je     800ca6 <memfind+0x2c>
  800c9a:	83 c0 01             	add    $0x1,%eax
  800c9d:	39 d0                	cmp    %edx,%eax
  800c9f:	90                   	nop    
  800ca0:	75 f4                	jne    800c96 <memfind+0x1c>
  800ca2:	eb 02                	jmp    800ca6 <memfind+0x2c>
  800ca4:	89 d8                	mov    %ebx,%eax
	return (void *) s;
}
  800ca6:	5b                   	pop    %ebx
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    

00800ca9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	57                   	push   %edi
  800cad:	56                   	push   %esi
  800cae:	53                   	push   %ebx
  800caf:	83 ec 04             	sub    $0x4,%esp
  800cb2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cb5:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cb8:	0f b6 03             	movzbl (%ebx),%eax
  800cbb:	3c 20                	cmp    $0x20,%al
  800cbd:	74 04                	je     800cc3 <strtol+0x1a>
  800cbf:	3c 09                	cmp    $0x9,%al
  800cc1:	75 0e                	jne    800cd1 <strtol+0x28>
		s++;
  800cc3:	83 c3 01             	add    $0x1,%ebx
  800cc6:	0f b6 03             	movzbl (%ebx),%eax
  800cc9:	3c 20                	cmp    $0x20,%al
  800ccb:	74 f6                	je     800cc3 <strtol+0x1a>
  800ccd:	3c 09                	cmp    $0x9,%al
  800ccf:	74 f2                	je     800cc3 <strtol+0x1a>

	// plus/minus sign
	if (*s == '+')
  800cd1:	3c 2b                	cmp    $0x2b,%al
  800cd3:	75 0d                	jne    800ce2 <strtol+0x39>
		s++;
  800cd5:	83 c3 01             	add    $0x1,%ebx
  800cd8:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800cdf:	90                   	nop    
  800ce0:	eb 15                	jmp    800cf7 <strtol+0x4e>
	else if (*s == '-')
  800ce2:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800ce9:	3c 2d                	cmp    $0x2d,%al
  800ceb:	75 0a                	jne    800cf7 <strtol+0x4e>
		s++, neg = 1;
  800ced:	83 c3 01             	add    $0x1,%ebx
  800cf0:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cf7:	85 f6                	test   %esi,%esi
  800cf9:	0f 94 c0             	sete   %al
  800cfc:	84 c0                	test   %al,%al
  800cfe:	75 05                	jne    800d05 <strtol+0x5c>
  800d00:	83 fe 10             	cmp    $0x10,%esi
  800d03:	75 17                	jne    800d1c <strtol+0x73>
  800d05:	80 3b 30             	cmpb   $0x30,(%ebx)
  800d08:	75 12                	jne    800d1c <strtol+0x73>
  800d0a:	80 7b 01 78          	cmpb   $0x78,0x1(%ebx)
  800d0e:	66 90                	xchg   %ax,%ax
  800d10:	75 0a                	jne    800d1c <strtol+0x73>
		s += 2, base = 16;
  800d12:	83 c3 02             	add    $0x2,%ebx
  800d15:	be 10 00 00 00       	mov    $0x10,%esi
  800d1a:	eb 1f                	jmp    800d3b <strtol+0x92>
	else if (base == 0 && s[0] == '0')
  800d1c:	85 f6                	test   %esi,%esi
  800d1e:	66 90                	xchg   %ax,%ax
  800d20:	75 10                	jne    800d32 <strtol+0x89>
  800d22:	80 3b 30             	cmpb   $0x30,(%ebx)
  800d25:	75 0b                	jne    800d32 <strtol+0x89>
		s++, base = 8;
  800d27:	83 c3 01             	add    $0x1,%ebx
  800d2a:	66 be 08 00          	mov    $0x8,%si
  800d2e:	66 90                	xchg   %ax,%ax
  800d30:	eb 09                	jmp    800d3b <strtol+0x92>
	else if (base == 0)
  800d32:	84 c0                	test   %al,%al
  800d34:	74 05                	je     800d3b <strtol+0x92>
  800d36:	be 0a 00 00 00       	mov    $0xa,%esi
  800d3b:	bf 00 00 00 00       	mov    $0x0,%edi
		base = 10;

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d40:	0f b6 13             	movzbl (%ebx),%edx
  800d43:	89 d1                	mov    %edx,%ecx
  800d45:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800d48:	3c 09                	cmp    $0x9,%al
  800d4a:	77 08                	ja     800d54 <strtol+0xab>
			dig = *s - '0';
  800d4c:	0f be c2             	movsbl %dl,%eax
  800d4f:	8d 50 d0             	lea    0xffffffd0(%eax),%edx
  800d52:	eb 1c                	jmp    800d70 <strtol+0xc7>
		else if (*s >= 'a' && *s <= 'z')
  800d54:	8d 41 9f             	lea    0xffffff9f(%ecx),%eax
  800d57:	3c 19                	cmp    $0x19,%al
  800d59:	77 08                	ja     800d63 <strtol+0xba>
			dig = *s - 'a' + 10;
  800d5b:	0f be c2             	movsbl %dl,%eax
  800d5e:	8d 50 a9             	lea    0xffffffa9(%eax),%edx
  800d61:	eb 0d                	jmp    800d70 <strtol+0xc7>
		else if (*s >= 'A' && *s <= 'Z')
  800d63:	8d 41 bf             	lea    0xffffffbf(%ecx),%eax
  800d66:	3c 19                	cmp    $0x19,%al
  800d68:	77 17                	ja     800d81 <strtol+0xd8>
			dig = *s - 'A' + 10;
  800d6a:	0f be c2             	movsbl %dl,%eax
  800d6d:	8d 50 c9             	lea    0xffffffc9(%eax),%edx
		else
			break;
		if (dig >= base)
  800d70:	39 f2                	cmp    %esi,%edx
  800d72:	7d 0d                	jge    800d81 <strtol+0xd8>
			break;
		s++, val = (val * base) + dig;
  800d74:	83 c3 01             	add    $0x1,%ebx
  800d77:	89 f8                	mov    %edi,%eax
  800d79:	0f af c6             	imul   %esi,%eax
  800d7c:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800d7f:	eb bf                	jmp    800d40 <strtol+0x97>
		// we don't properly detect overflow!
	}
  800d81:	89 f8                	mov    %edi,%eax

	if (endptr)
  800d83:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d87:	74 05                	je     800d8e <strtol+0xe5>
		*endptr = (char *) s;
  800d89:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d8c:	89 1a                	mov    %ebx,(%edx)
	return (neg ? -val : val);
  800d8e:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800d92:	74 04                	je     800d98 <strtol+0xef>
  800d94:	89 c7                	mov    %eax,%edi
  800d96:	f7 df                	neg    %edi
}
  800d98:	89 f8                	mov    %edi,%eax
  800d9a:	83 c4 04             	add    $0x4,%esp
  800d9d:	5b                   	pop    %ebx
  800d9e:	5e                   	pop    %esi
  800d9f:	5f                   	pop    %edi
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    
	...

00800da4 <sys_cgetc>:
}

int
sys_cgetc(void)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	83 ec 0c             	sub    $0xc,%esp
  800daa:	89 1c 24             	mov    %ebx,(%esp)
  800dad:	89 74 24 04          	mov    %esi,0x4(%esp)
  800db1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800db5:	b8 01 00 00 00       	mov    $0x1,%eax
  800dba:	bf 00 00 00 00       	mov    $0x0,%edi
  800dbf:	89 fa                	mov    %edi,%edx
  800dc1:	89 f9                	mov    %edi,%ecx
  800dc3:	89 fb                	mov    %edi,%ebx
  800dc5:	89 fe                	mov    %edi,%esi
  800dc7:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800dc9:	8b 1c 24             	mov    (%esp),%ebx
  800dcc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800dd0:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800dd4:	89 ec                	mov    %ebp,%esp
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    

00800dd8 <sys_cputs>:
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	83 ec 0c             	sub    $0xc,%esp
  800dde:	89 1c 24             	mov    %ebx,(%esp)
  800de1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800de5:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800de9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800def:	bf 00 00 00 00       	mov    $0x0,%edi
  800df4:	89 f8                	mov    %edi,%eax
  800df6:	89 fb                	mov    %edi,%ebx
  800df8:	89 fe                	mov    %edi,%esi
  800dfa:	cd 30                	int    $0x30
  800dfc:	8b 1c 24             	mov    (%esp),%ebx
  800dff:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e03:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e07:	89 ec                	mov    %ebp,%esp
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    

00800e0b <sys_time_msec>:

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
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	83 ec 0c             	sub    $0xc,%esp
  800e11:	89 1c 24             	mov    %ebx,(%esp)
  800e14:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e18:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e1c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e21:	bf 00 00 00 00       	mov    $0x0,%edi
  800e26:	89 fa                	mov    %edi,%edx
  800e28:	89 f9                	mov    %edi,%ecx
  800e2a:	89 fb                	mov    %edi,%ebx
  800e2c:	89 fe                	mov    %edi,%esi
  800e2e:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e30:	8b 1c 24             	mov    (%esp),%ebx
  800e33:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e37:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e3b:	89 ec                	mov    %ebp,%esp
  800e3d:	5d                   	pop    %ebp
  800e3e:	c3                   	ret    

00800e3f <sys_ipc_recv>:
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	83 ec 28             	sub    $0x28,%esp
  800e45:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800e48:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800e4b:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800e4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e51:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e56:	bf 00 00 00 00       	mov    $0x0,%edi
  800e5b:	89 f9                	mov    %edi,%ecx
  800e5d:	89 fb                	mov    %edi,%ebx
  800e5f:	89 fe                	mov    %edi,%esi
  800e61:	cd 30                	int    $0x30
  800e63:	85 c0                	test   %eax,%eax
  800e65:	7e 28                	jle    800e8f <sys_ipc_recv+0x50>
  800e67:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e6b:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e72:	00 
  800e73:	c7 44 24 08 df 2b 80 	movl   $0x802bdf,0x8(%esp)
  800e7a:	00 
  800e7b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e82:	00 
  800e83:	c7 04 24 fc 2b 80 00 	movl   $0x802bfc,(%esp)
  800e8a:	e8 19 11 00 00       	call   801fa8 <_panic>
  800e8f:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800e92:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800e95:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800e98:	89 ec                	mov    %ebp,%esp
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <sys_ipc_try_send>:
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	83 ec 0c             	sub    $0xc,%esp
  800ea2:	89 1c 24             	mov    %ebx,(%esp)
  800ea5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ea9:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ead:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eb9:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ebe:	be 00 00 00 00       	mov    $0x0,%esi
  800ec3:	cd 30                	int    $0x30
  800ec5:	8b 1c 24             	mov    (%esp),%ebx
  800ec8:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ecc:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ed0:	89 ec                	mov    %ebp,%esp
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    

00800ed4 <sys_env_set_pgfault_upcall>:
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	83 ec 28             	sub    $0x28,%esp
  800eda:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800edd:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800ee0:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800ee3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eee:	bf 00 00 00 00       	mov    $0x0,%edi
  800ef3:	89 fb                	mov    %edi,%ebx
  800ef5:	89 fe                	mov    %edi,%esi
  800ef7:	cd 30                	int    $0x30
  800ef9:	85 c0                	test   %eax,%eax
  800efb:	7e 28                	jle    800f25 <sys_env_set_pgfault_upcall+0x51>
  800efd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f01:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f08:	00 
  800f09:	c7 44 24 08 df 2b 80 	movl   $0x802bdf,0x8(%esp)
  800f10:	00 
  800f11:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f18:	00 
  800f19:	c7 04 24 fc 2b 80 00 	movl   $0x802bfc,(%esp)
  800f20:	e8 83 10 00 00       	call   801fa8 <_panic>
  800f25:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800f28:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800f2b:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800f2e:	89 ec                	mov    %ebp,%esp
  800f30:	5d                   	pop    %ebp
  800f31:	c3                   	ret    

00800f32 <sys_env_set_trapframe>:
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	83 ec 28             	sub    $0x28,%esp
  800f38:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800f3b:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800f3e:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800f41:	8b 55 08             	mov    0x8(%ebp),%edx
  800f44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f47:	b8 09 00 00 00       	mov    $0x9,%eax
  800f4c:	bf 00 00 00 00       	mov    $0x0,%edi
  800f51:	89 fb                	mov    %edi,%ebx
  800f53:	89 fe                	mov    %edi,%esi
  800f55:	cd 30                	int    $0x30
  800f57:	85 c0                	test   %eax,%eax
  800f59:	7e 28                	jle    800f83 <sys_env_set_trapframe+0x51>
  800f5b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f5f:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f66:	00 
  800f67:	c7 44 24 08 df 2b 80 	movl   $0x802bdf,0x8(%esp)
  800f6e:	00 
  800f6f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f76:	00 
  800f77:	c7 04 24 fc 2b 80 00 	movl   $0x802bfc,(%esp)
  800f7e:	e8 25 10 00 00       	call   801fa8 <_panic>
  800f83:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800f86:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800f89:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800f8c:	89 ec                	mov    %ebp,%esp
  800f8e:	5d                   	pop    %ebp
  800f8f:	c3                   	ret    

00800f90 <sys_env_set_status>:
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	83 ec 28             	sub    $0x28,%esp
  800f96:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800f99:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800f9c:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800f9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa5:	b8 08 00 00 00       	mov    $0x8,%eax
  800faa:	bf 00 00 00 00       	mov    $0x0,%edi
  800faf:	89 fb                	mov    %edi,%ebx
  800fb1:	89 fe                	mov    %edi,%esi
  800fb3:	cd 30                	int    $0x30
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	7e 28                	jle    800fe1 <sys_env_set_status+0x51>
  800fb9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fbd:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800fc4:	00 
  800fc5:	c7 44 24 08 df 2b 80 	movl   $0x802bdf,0x8(%esp)
  800fcc:	00 
  800fcd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fd4:	00 
  800fd5:	c7 04 24 fc 2b 80 00 	movl   $0x802bfc,(%esp)
  800fdc:	e8 c7 0f 00 00       	call   801fa8 <_panic>
  800fe1:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800fe4:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800fe7:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800fea:	89 ec                	mov    %ebp,%esp
  800fec:	5d                   	pop    %ebp
  800fed:	c3                   	ret    

00800fee <sys_page_unmap>:
  800fee:	55                   	push   %ebp
  800fef:	89 e5                	mov    %esp,%ebp
  800ff1:	83 ec 28             	sub    $0x28,%esp
  800ff4:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800ff7:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800ffa:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800ffd:	8b 55 08             	mov    0x8(%ebp),%edx
  801000:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801003:	b8 06 00 00 00       	mov    $0x6,%eax
  801008:	bf 00 00 00 00       	mov    $0x0,%edi
  80100d:	89 fb                	mov    %edi,%ebx
  80100f:	89 fe                	mov    %edi,%esi
  801011:	cd 30                	int    $0x30
  801013:	85 c0                	test   %eax,%eax
  801015:	7e 28                	jle    80103f <sys_page_unmap+0x51>
  801017:	89 44 24 10          	mov    %eax,0x10(%esp)
  80101b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801022:	00 
  801023:	c7 44 24 08 df 2b 80 	movl   $0x802bdf,0x8(%esp)
  80102a:	00 
  80102b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801032:	00 
  801033:	c7 04 24 fc 2b 80 00 	movl   $0x802bfc,(%esp)
  80103a:	e8 69 0f 00 00       	call   801fa8 <_panic>
  80103f:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801042:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801045:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801048:	89 ec                	mov    %ebp,%esp
  80104a:	5d                   	pop    %ebp
  80104b:	c3                   	ret    

0080104c <sys_page_map>:
  80104c:	55                   	push   %ebp
  80104d:	89 e5                	mov    %esp,%ebp
  80104f:	83 ec 28             	sub    $0x28,%esp
  801052:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  801055:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  801058:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  80105b:	8b 55 08             	mov    0x8(%ebp),%edx
  80105e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801061:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801064:	8b 7d 14             	mov    0x14(%ebp),%edi
  801067:	8b 75 18             	mov    0x18(%ebp),%esi
  80106a:	b8 05 00 00 00       	mov    $0x5,%eax
  80106f:	cd 30                	int    $0x30
  801071:	85 c0                	test   %eax,%eax
  801073:	7e 28                	jle    80109d <sys_page_map+0x51>
  801075:	89 44 24 10          	mov    %eax,0x10(%esp)
  801079:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801080:	00 
  801081:	c7 44 24 08 df 2b 80 	movl   $0x802bdf,0x8(%esp)
  801088:	00 
  801089:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801090:	00 
  801091:	c7 04 24 fc 2b 80 00 	movl   $0x802bfc,(%esp)
  801098:	e8 0b 0f 00 00       	call   801fa8 <_panic>
  80109d:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  8010a0:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  8010a3:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  8010a6:	89 ec                	mov    %ebp,%esp
  8010a8:	5d                   	pop    %ebp
  8010a9:	c3                   	ret    

008010aa <sys_page_alloc>:
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
  8010ad:	83 ec 28             	sub    $0x28,%esp
  8010b0:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  8010b3:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  8010b6:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  8010b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010c2:	b8 04 00 00 00       	mov    $0x4,%eax
  8010c7:	bf 00 00 00 00       	mov    $0x0,%edi
  8010cc:	89 fe                	mov    %edi,%esi
  8010ce:	cd 30                	int    $0x30
  8010d0:	85 c0                	test   %eax,%eax
  8010d2:	7e 28                	jle    8010fc <sys_page_alloc+0x52>
  8010d4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010d8:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8010df:	00 
  8010e0:	c7 44 24 08 df 2b 80 	movl   $0x802bdf,0x8(%esp)
  8010e7:	00 
  8010e8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010ef:	00 
  8010f0:	c7 04 24 fc 2b 80 00 	movl   $0x802bfc,(%esp)
  8010f7:	e8 ac 0e 00 00       	call   801fa8 <_panic>
  8010fc:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  8010ff:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801102:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801105:	89 ec                	mov    %ebp,%esp
  801107:	5d                   	pop    %ebp
  801108:	c3                   	ret    

00801109 <sys_yield>:
  801109:	55                   	push   %ebp
  80110a:	89 e5                	mov    %esp,%ebp
  80110c:	83 ec 0c             	sub    $0xc,%esp
  80110f:	89 1c 24             	mov    %ebx,(%esp)
  801112:	89 74 24 04          	mov    %esi,0x4(%esp)
  801116:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80111a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80111f:	bf 00 00 00 00       	mov    $0x0,%edi
  801124:	89 fa                	mov    %edi,%edx
  801126:	89 f9                	mov    %edi,%ecx
  801128:	89 fb                	mov    %edi,%ebx
  80112a:	89 fe                	mov    %edi,%esi
  80112c:	cd 30                	int    $0x30
  80112e:	8b 1c 24             	mov    (%esp),%ebx
  801131:	8b 74 24 04          	mov    0x4(%esp),%esi
  801135:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801139:	89 ec                	mov    %ebp,%esp
  80113b:	5d                   	pop    %ebp
  80113c:	c3                   	ret    

0080113d <sys_getenvid>:
  80113d:	55                   	push   %ebp
  80113e:	89 e5                	mov    %esp,%ebp
  801140:	83 ec 0c             	sub    $0xc,%esp
  801143:	89 1c 24             	mov    %ebx,(%esp)
  801146:	89 74 24 04          	mov    %esi,0x4(%esp)
  80114a:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80114e:	b8 02 00 00 00       	mov    $0x2,%eax
  801153:	bf 00 00 00 00       	mov    $0x0,%edi
  801158:	89 fa                	mov    %edi,%edx
  80115a:	89 f9                	mov    %edi,%ecx
  80115c:	89 fb                	mov    %edi,%ebx
  80115e:	89 fe                	mov    %edi,%esi
  801160:	cd 30                	int    $0x30
  801162:	8b 1c 24             	mov    (%esp),%ebx
  801165:	8b 74 24 04          	mov    0x4(%esp),%esi
  801169:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80116d:	89 ec                	mov    %ebp,%esp
  80116f:	5d                   	pop    %ebp
  801170:	c3                   	ret    

00801171 <sys_env_destroy>:
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	83 ec 28             	sub    $0x28,%esp
  801177:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  80117a:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  80117d:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  801180:	8b 55 08             	mov    0x8(%ebp),%edx
  801183:	b8 03 00 00 00       	mov    $0x3,%eax
  801188:	bf 00 00 00 00       	mov    $0x0,%edi
  80118d:	89 f9                	mov    %edi,%ecx
  80118f:	89 fb                	mov    %edi,%ebx
  801191:	89 fe                	mov    %edi,%esi
  801193:	cd 30                	int    $0x30
  801195:	85 c0                	test   %eax,%eax
  801197:	7e 28                	jle    8011c1 <sys_env_destroy+0x50>
  801199:	89 44 24 10          	mov    %eax,0x10(%esp)
  80119d:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8011a4:	00 
  8011a5:	c7 44 24 08 df 2b 80 	movl   $0x802bdf,0x8(%esp)
  8011ac:	00 
  8011ad:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011b4:	00 
  8011b5:	c7 04 24 fc 2b 80 00 	movl   $0x802bfc,(%esp)
  8011bc:	e8 e7 0d 00 00       	call   801fa8 <_panic>
  8011c1:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  8011c4:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  8011c7:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  8011ca:	89 ec                	mov    %ebp,%esp
  8011cc:	5d                   	pop    %ebp
  8011cd:	c3                   	ret    
	...

008011d0 <fd2num>:
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
  8011d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011db:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8011de:	5d                   	pop    %ebp
  8011df:	c3                   	ret    

008011e0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8011e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e9:	89 04 24             	mov    %eax,(%esp)
  8011ec:	e8 df ff ff ff       	call   8011d0 <fd2num>
  8011f1:	c1 e0 0c             	shl    $0xc,%eax
  8011f4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011f9:	c9                   	leave  
  8011fa:	c3                   	ret    

008011fb <fd_alloc>:

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
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	53                   	push   %ebx
  8011ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801202:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  801207:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801209:	89 d0                	mov    %edx,%eax
  80120b:	c1 e8 16             	shr    $0x16,%eax
  80120e:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  801215:	a8 01                	test   $0x1,%al
  801217:	74 10                	je     801229 <fd_alloc+0x2e>
  801219:	89 d0                	mov    %edx,%eax
  80121b:	c1 e8 0c             	shr    $0xc,%eax
  80121e:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  801225:	a8 01                	test   $0x1,%al
  801227:	75 09                	jne    801232 <fd_alloc+0x37>
			*fd_store = fd;
  801229:	89 0b                	mov    %ecx,(%ebx)
  80122b:	b8 00 00 00 00       	mov    $0x0,%eax
  801230:	eb 19                	jmp    80124b <fd_alloc+0x50>
			return 0;
  801232:	81 c2 00 10 00 00    	add    $0x1000,%edx
  801238:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  80123e:	75 c7                	jne    801207 <fd_alloc+0xc>
		}
	}
	*fd_store = 0;
  801240:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801246:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  80124b:	5b                   	pop    %ebx
  80124c:	5d                   	pop    %ebp
  80124d:	c3                   	ret    

0080124e <fd_lookup>:

// Check that fdnum is in range and mapped.
// If it is, set *fd_store to the fd page virtual address.
//
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80124e:	55                   	push   %ebp
  80124f:	89 e5                	mov    %esp,%ebp
  801251:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801254:	83 f8 1f             	cmp    $0x1f,%eax
  801257:	77 35                	ja     80128e <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801259:	c1 e0 0c             	shl    $0xc,%eax
  80125c:	8d 90 00 00 00 d0    	lea    0xd0000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  801262:	89 d0                	mov    %edx,%eax
  801264:	c1 e8 16             	shr    $0x16,%eax
  801267:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  80126e:	a8 01                	test   $0x1,%al
  801270:	74 1c                	je     80128e <fd_lookup+0x40>
  801272:	89 d0                	mov    %edx,%eax
  801274:	c1 e8 0c             	shr    $0xc,%eax
  801277:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  80127e:	a8 01                	test   $0x1,%al
  801280:	74 0c                	je     80128e <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801282:	8b 45 0c             	mov    0xc(%ebp),%eax
  801285:	89 10                	mov    %edx,(%eax)
  801287:	b8 00 00 00 00       	mov    $0x0,%eax
  80128c:	eb 05                	jmp    801293 <fd_lookup+0x45>
	return 0;
  80128e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801293:	5d                   	pop    %ebp
  801294:	c3                   	ret    

00801295 <seek>:

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
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80129b:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  80129e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a5:	89 04 24             	mov    %eax,(%esp)
  8012a8:	e8 a1 ff ff ff       	call   80124e <fd_lookup>
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	78 0e                	js     8012bf <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8012b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b4:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  8012b7:	89 50 04             	mov    %edx,0x4(%eax)
  8012ba:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8012bf:	c9                   	leave  
  8012c0:	c3                   	ret    

008012c1 <dev_lookup>:
  8012c1:	55                   	push   %ebp
  8012c2:	89 e5                	mov    %esp,%ebp
  8012c4:	53                   	push   %ebx
  8012c5:	83 ec 14             	sub    $0x14,%esp
  8012c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012ce:	ba 04 60 80 00       	mov    $0x806004,%edx
  8012d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d8:	39 0d 04 60 80 00    	cmp    %ecx,0x806004
  8012de:	75 12                	jne    8012f2 <dev_lookup+0x31>
  8012e0:	eb 04                	jmp    8012e6 <dev_lookup+0x25>
  8012e2:	39 0a                	cmp    %ecx,(%edx)
  8012e4:	75 0c                	jne    8012f2 <dev_lookup+0x31>
  8012e6:	89 13                	mov    %edx,(%ebx)
  8012e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ed:	8d 76 00             	lea    0x0(%esi),%esi
  8012f0:	eb 35                	jmp    801327 <dev_lookup+0x66>
  8012f2:	83 c0 01             	add    $0x1,%eax
  8012f5:	8b 14 85 8c 2c 80 00 	mov    0x802c8c(,%eax,4),%edx
  8012fc:	85 d2                	test   %edx,%edx
  8012fe:	75 e2                	jne    8012e2 <dev_lookup+0x21>
  801300:	a1 4c 60 80 00       	mov    0x80604c,%eax
  801305:	8b 40 4c             	mov    0x4c(%eax),%eax
  801308:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80130c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801310:	c7 04 24 0c 2c 80 00 	movl   $0x802c0c,(%esp)
  801317:	e8 dd ef ff ff       	call   8002f9 <cprintf>
  80131c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801322:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801327:	83 c4 14             	add    $0x14,%esp
  80132a:	5b                   	pop    %ebx
  80132b:	5d                   	pop    %ebp
  80132c:	c3                   	ret    

0080132d <fstat>:

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
  80132d:	55                   	push   %ebp
  80132e:	89 e5                	mov    %esp,%ebp
  801330:	53                   	push   %ebx
  801331:	83 ec 24             	sub    $0x24,%esp
  801334:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801337:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80133a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80133e:	8b 45 08             	mov    0x8(%ebp),%eax
  801341:	89 04 24             	mov    %eax,(%esp)
  801344:	e8 05 ff ff ff       	call   80124e <fd_lookup>
  801349:	89 c2                	mov    %eax,%edx
  80134b:	85 c0                	test   %eax,%eax
  80134d:	78 57                	js     8013a6 <fstat+0x79>
  80134f:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801352:	89 44 24 04          	mov    %eax,0x4(%esp)
  801356:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801359:	8b 00                	mov    (%eax),%eax
  80135b:	89 04 24             	mov    %eax,(%esp)
  80135e:	e8 5e ff ff ff       	call   8012c1 <dev_lookup>
  801363:	89 c2                	mov    %eax,%edx
  801365:	85 c0                	test   %eax,%eax
  801367:	78 3d                	js     8013a6 <fstat+0x79>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801369:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  80136e:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
  801371:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801375:	74 2f                	je     8013a6 <fstat+0x79>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801377:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80137a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801381:	00 00 00 
	stat->st_isdir = 0;
  801384:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80138b:	00 00 00 
	stat->st_dev = dev;
  80138e:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801391:	89 93 88 00 00 00    	mov    %edx,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801397:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80139b:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80139e:	89 04 24             	mov    %eax,(%esp)
  8013a1:	ff 52 14             	call   *0x14(%edx)
  8013a4:	89 c2                	mov    %eax,%edx
}
  8013a6:	89 d0                	mov    %edx,%eax
  8013a8:	83 c4 24             	add    $0x24,%esp
  8013ab:	5b                   	pop    %ebx
  8013ac:	5d                   	pop    %ebp
  8013ad:	c3                   	ret    

008013ae <ftruncate>:
  8013ae:	55                   	push   %ebp
  8013af:	89 e5                	mov    %esp,%ebp
  8013b1:	53                   	push   %ebx
  8013b2:	83 ec 24             	sub    $0x24,%esp
  8013b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8013b8:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8013bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013bf:	89 1c 24             	mov    %ebx,(%esp)
  8013c2:	e8 87 fe ff ff       	call   80124e <fd_lookup>
  8013c7:	85 c0                	test   %eax,%eax
  8013c9:	78 61                	js     80142c <ftruncate+0x7e>
  8013cb:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8013ce:	8b 10                	mov    (%eax),%edx
  8013d0:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  8013d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d7:	89 14 24             	mov    %edx,(%esp)
  8013da:	e8 e2 fe ff ff       	call   8012c1 <dev_lookup>
  8013df:	85 c0                	test   %eax,%eax
  8013e1:	78 49                	js     80142c <ftruncate+0x7e>
  8013e3:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  8013e6:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  8013ea:	75 23                	jne    80140f <ftruncate+0x61>
  8013ec:	a1 4c 60 80 00       	mov    0x80604c,%eax
  8013f1:	8b 40 4c             	mov    0x4c(%eax),%eax
  8013f4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013fc:	c7 04 24 2c 2c 80 00 	movl   $0x802c2c,(%esp)
  801403:	e8 f1 ee ff ff       	call   8002f9 <cprintf>
  801408:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80140d:	eb 1d                	jmp    80142c <ftruncate+0x7e>
  80140f:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801412:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801417:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  80141b:	74 0f                	je     80142c <ftruncate+0x7e>
  80141d:	8b 52 18             	mov    0x18(%edx),%edx
  801420:	8b 45 0c             	mov    0xc(%ebp),%eax
  801423:	89 44 24 04          	mov    %eax,0x4(%esp)
  801427:	89 0c 24             	mov    %ecx,(%esp)
  80142a:	ff d2                	call   *%edx
  80142c:	83 c4 24             	add    $0x24,%esp
  80142f:	5b                   	pop    %ebx
  801430:	5d                   	pop    %ebp
  801431:	c3                   	ret    

00801432 <write>:
  801432:	55                   	push   %ebp
  801433:	89 e5                	mov    %esp,%ebp
  801435:	53                   	push   %ebx
  801436:	83 ec 24             	sub    $0x24,%esp
  801439:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80143c:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80143f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801443:	89 1c 24             	mov    %ebx,(%esp)
  801446:	e8 03 fe ff ff       	call   80124e <fd_lookup>
  80144b:	85 c0                	test   %eax,%eax
  80144d:	78 68                	js     8014b7 <write+0x85>
  80144f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801452:	8b 10                	mov    (%eax),%edx
  801454:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801457:	89 44 24 04          	mov    %eax,0x4(%esp)
  80145b:	89 14 24             	mov    %edx,(%esp)
  80145e:	e8 5e fe ff ff       	call   8012c1 <dev_lookup>
  801463:	85 c0                	test   %eax,%eax
  801465:	78 50                	js     8014b7 <write+0x85>
  801467:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  80146a:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  80146e:	75 23                	jne    801493 <write+0x61>
  801470:	a1 4c 60 80 00       	mov    0x80604c,%eax
  801475:	8b 40 4c             	mov    0x4c(%eax),%eax
  801478:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80147c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801480:	c7 04 24 50 2c 80 00 	movl   $0x802c50,(%esp)
  801487:	e8 6d ee ff ff       	call   8002f9 <cprintf>
  80148c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801491:	eb 24                	jmp    8014b7 <write+0x85>
  801493:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801496:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80149b:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  80149f:	74 16                	je     8014b7 <write+0x85>
  8014a1:	8b 42 0c             	mov    0xc(%edx),%eax
  8014a4:	8b 55 10             	mov    0x10(%ebp),%edx
  8014a7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8014ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014b2:	89 0c 24             	mov    %ecx,(%esp)
  8014b5:	ff d0                	call   *%eax
  8014b7:	83 c4 24             	add    $0x24,%esp
  8014ba:	5b                   	pop    %ebx
  8014bb:	5d                   	pop    %ebp
  8014bc:	c3                   	ret    

008014bd <read>:
  8014bd:	55                   	push   %ebp
  8014be:	89 e5                	mov    %esp,%ebp
  8014c0:	53                   	push   %ebx
  8014c1:	83 ec 24             	sub    $0x24,%esp
  8014c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8014c7:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8014ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ce:	89 1c 24             	mov    %ebx,(%esp)
  8014d1:	e8 78 fd ff ff       	call   80124e <fd_lookup>
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	78 6d                	js     801547 <read+0x8a>
  8014da:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8014dd:	8b 10                	mov    (%eax),%edx
  8014df:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  8014e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e6:	89 14 24             	mov    %edx,(%esp)
  8014e9:	e8 d3 fd ff ff       	call   8012c1 <dev_lookup>
  8014ee:	85 c0                	test   %eax,%eax
  8014f0:	78 55                	js     801547 <read+0x8a>
  8014f2:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  8014f5:	8b 41 08             	mov    0x8(%ecx),%eax
  8014f8:	83 e0 03             	and    $0x3,%eax
  8014fb:	83 f8 01             	cmp    $0x1,%eax
  8014fe:	75 23                	jne    801523 <read+0x66>
  801500:	a1 4c 60 80 00       	mov    0x80604c,%eax
  801505:	8b 40 4c             	mov    0x4c(%eax),%eax
  801508:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80150c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801510:	c7 04 24 6d 2c 80 00 	movl   $0x802c6d,(%esp)
  801517:	e8 dd ed ff ff       	call   8002f9 <cprintf>
  80151c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801521:	eb 24                	jmp    801547 <read+0x8a>
  801523:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801526:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80152b:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  80152f:	74 16                	je     801547 <read+0x8a>
  801531:	8b 42 08             	mov    0x8(%edx),%eax
  801534:	8b 55 10             	mov    0x10(%ebp),%edx
  801537:	89 54 24 08          	mov    %edx,0x8(%esp)
  80153b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80153e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801542:	89 0c 24             	mov    %ecx,(%esp)
  801545:	ff d0                	call   *%eax
  801547:	83 c4 24             	add    $0x24,%esp
  80154a:	5b                   	pop    %ebx
  80154b:	5d                   	pop    %ebp
  80154c:	c3                   	ret    

0080154d <readn>:
  80154d:	55                   	push   %ebp
  80154e:	89 e5                	mov    %esp,%ebp
  801550:	57                   	push   %edi
  801551:	56                   	push   %esi
  801552:	53                   	push   %ebx
  801553:	83 ec 0c             	sub    $0xc,%esp
  801556:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801559:	8b 75 10             	mov    0x10(%ebp),%esi
  80155c:	b8 00 00 00 00       	mov    $0x0,%eax
  801561:	85 f6                	test   %esi,%esi
  801563:	74 36                	je     80159b <readn+0x4e>
  801565:	bb 00 00 00 00       	mov    $0x0,%ebx
  80156a:	ba 00 00 00 00       	mov    $0x0,%edx
  80156f:	89 f0                	mov    %esi,%eax
  801571:	29 d0                	sub    %edx,%eax
  801573:	89 44 24 08          	mov    %eax,0x8(%esp)
  801577:	8d 04 17             	lea    (%edi,%edx,1),%eax
  80157a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80157e:	8b 45 08             	mov    0x8(%ebp),%eax
  801581:	89 04 24             	mov    %eax,(%esp)
  801584:	e8 34 ff ff ff       	call   8014bd <read>
  801589:	85 c0                	test   %eax,%eax
  80158b:	78 0e                	js     80159b <readn+0x4e>
  80158d:	85 c0                	test   %eax,%eax
  80158f:	74 08                	je     801599 <readn+0x4c>
  801591:	01 c3                	add    %eax,%ebx
  801593:	89 da                	mov    %ebx,%edx
  801595:	39 f3                	cmp    %esi,%ebx
  801597:	72 d6                	jb     80156f <readn+0x22>
  801599:	89 d8                	mov    %ebx,%eax
  80159b:	83 c4 0c             	add    $0xc,%esp
  80159e:	5b                   	pop    %ebx
  80159f:	5e                   	pop    %esi
  8015a0:	5f                   	pop    %edi
  8015a1:	5d                   	pop    %ebp
  8015a2:	c3                   	ret    

008015a3 <fd_close>:
  8015a3:	55                   	push   %ebp
  8015a4:	89 e5                	mov    %esp,%ebp
  8015a6:	83 ec 28             	sub    $0x28,%esp
  8015a9:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  8015ac:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  8015af:	8b 75 08             	mov    0x8(%ebp),%esi
  8015b2:	89 34 24             	mov    %esi,(%esp)
  8015b5:	e8 16 fc ff ff       	call   8011d0 <fd2num>
  8015ba:	8d 55 f4             	lea    0xfffffff4(%ebp),%edx
  8015bd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015c1:	89 04 24             	mov    %eax,(%esp)
  8015c4:	e8 85 fc ff ff       	call   80124e <fd_lookup>
  8015c9:	89 c3                	mov    %eax,%ebx
  8015cb:	85 c0                	test   %eax,%eax
  8015cd:	78 05                	js     8015d4 <fd_close+0x31>
  8015cf:	3b 75 f4             	cmp    0xfffffff4(%ebp),%esi
  8015d2:	74 0e                	je     8015e2 <fd_close+0x3f>
  8015d4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8015d8:	75 45                	jne    80161f <fd_close+0x7c>
  8015da:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015df:	90                   	nop    
  8015e0:	eb 3d                	jmp    80161f <fd_close+0x7c>
  8015e2:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  8015e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e9:	8b 06                	mov    (%esi),%eax
  8015eb:	89 04 24             	mov    %eax,(%esp)
  8015ee:	e8 ce fc ff ff       	call   8012c1 <dev_lookup>
  8015f3:	89 c3                	mov    %eax,%ebx
  8015f5:	85 c0                	test   %eax,%eax
  8015f7:	78 16                	js     80160f <fd_close+0x6c>
  8015f9:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8015fc:	8b 40 10             	mov    0x10(%eax),%eax
  8015ff:	bb 00 00 00 00       	mov    $0x0,%ebx
  801604:	85 c0                	test   %eax,%eax
  801606:	74 07                	je     80160f <fd_close+0x6c>
  801608:	89 34 24             	mov    %esi,(%esp)
  80160b:	ff d0                	call   *%eax
  80160d:	89 c3                	mov    %eax,%ebx
  80160f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801613:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80161a:	e8 cf f9 ff ff       	call   800fee <sys_page_unmap>
  80161f:	89 d8                	mov    %ebx,%eax
  801621:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  801624:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  801627:	89 ec                	mov    %ebp,%esp
  801629:	5d                   	pop    %ebp
  80162a:	c3                   	ret    

0080162b <close>:
  80162b:	55                   	push   %ebp
  80162c:	89 e5                	mov    %esp,%ebp
  80162e:	83 ec 18             	sub    $0x18,%esp
  801631:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  801634:	89 44 24 04          	mov    %eax,0x4(%esp)
  801638:	8b 45 08             	mov    0x8(%ebp),%eax
  80163b:	89 04 24             	mov    %eax,(%esp)
  80163e:	e8 0b fc ff ff       	call   80124e <fd_lookup>
  801643:	85 c0                	test   %eax,%eax
  801645:	78 13                	js     80165a <close+0x2f>
  801647:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80164e:	00 
  80164f:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  801652:	89 04 24             	mov    %eax,(%esp)
  801655:	e8 49 ff ff ff       	call   8015a3 <fd_close>
  80165a:	c9                   	leave  
  80165b:	c3                   	ret    

0080165c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	83 ec 18             	sub    $0x18,%esp
  801662:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  801665:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801668:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80166f:	00 
  801670:	8b 45 08             	mov    0x8(%ebp),%eax
  801673:	89 04 24             	mov    %eax,(%esp)
  801676:	e8 58 03 00 00       	call   8019d3 <open>
  80167b:	89 c6                	mov    %eax,%esi
  80167d:	85 c0                	test   %eax,%eax
  80167f:	78 1b                	js     80169c <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801681:	8b 45 0c             	mov    0xc(%ebp),%eax
  801684:	89 44 24 04          	mov    %eax,0x4(%esp)
  801688:	89 34 24             	mov    %esi,(%esp)
  80168b:	e8 9d fc ff ff       	call   80132d <fstat>
  801690:	89 c3                	mov    %eax,%ebx
	close(fd);
  801692:	89 34 24             	mov    %esi,(%esp)
  801695:	e8 91 ff ff ff       	call   80162b <close>
  80169a:	89 de                	mov    %ebx,%esi
	return r;
}
  80169c:	89 f0                	mov    %esi,%eax
  80169e:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  8016a1:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  8016a4:	89 ec                	mov    %ebp,%esp
  8016a6:	5d                   	pop    %ebp
  8016a7:	c3                   	ret    

008016a8 <dup>:
  8016a8:	55                   	push   %ebp
  8016a9:	89 e5                	mov    %esp,%ebp
  8016ab:	83 ec 38             	sub    $0x38,%esp
  8016ae:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  8016b1:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  8016b4:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  8016b7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8016ba:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  8016bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c4:	89 04 24             	mov    %eax,(%esp)
  8016c7:	e8 82 fb ff ff       	call   80124e <fd_lookup>
  8016cc:	89 c3                	mov    %eax,%ebx
  8016ce:	85 c0                	test   %eax,%eax
  8016d0:	0f 88 e1 00 00 00    	js     8017b7 <dup+0x10f>
  8016d6:	89 3c 24             	mov    %edi,(%esp)
  8016d9:	e8 4d ff ff ff       	call   80162b <close>
  8016de:	89 f8                	mov    %edi,%eax
  8016e0:	c1 e0 0c             	shl    $0xc,%eax
  8016e3:	8d b0 00 00 00 d0    	lea    0xd0000000(%eax),%esi
  8016e9:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8016ec:	89 04 24             	mov    %eax,(%esp)
  8016ef:	e8 ec fa ff ff       	call   8011e0 <fd2data>
  8016f4:	89 c3                	mov    %eax,%ebx
  8016f6:	89 34 24             	mov    %esi,(%esp)
  8016f9:	e8 e2 fa ff ff       	call   8011e0 <fd2data>
  8016fe:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  801701:	89 d8                	mov    %ebx,%eax
  801703:	c1 e8 16             	shr    $0x16,%eax
  801706:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  80170d:	a8 01                	test   $0x1,%al
  80170f:	74 45                	je     801756 <dup+0xae>
  801711:	89 da                	mov    %ebx,%edx
  801713:	c1 ea 0c             	shr    $0xc,%edx
  801716:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  80171d:	a8 01                	test   $0x1,%al
  80171f:	74 35                	je     801756 <dup+0xae>
  801721:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  801728:	25 07 0e 00 00       	and    $0xe07,%eax
  80172d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801731:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  801734:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801738:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80173f:	00 
  801740:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801744:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80174b:	e8 fc f8 ff ff       	call   80104c <sys_page_map>
  801750:	89 c3                	mov    %eax,%ebx
  801752:	85 c0                	test   %eax,%eax
  801754:	78 3e                	js     801794 <dup+0xec>
  801756:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  801759:	89 d0                	mov    %edx,%eax
  80175b:	c1 e8 0c             	shr    $0xc,%eax
  80175e:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  801765:	25 07 0e 00 00       	and    $0xe07,%eax
  80176a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80176e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801772:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801779:	00 
  80177a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80177e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801785:	e8 c2 f8 ff ff       	call   80104c <sys_page_map>
  80178a:	89 c3                	mov    %eax,%ebx
  80178c:	85 c0                	test   %eax,%eax
  80178e:	78 04                	js     801794 <dup+0xec>
  801790:	89 fb                	mov    %edi,%ebx
  801792:	eb 23                	jmp    8017b7 <dup+0x10f>
  801794:	89 74 24 04          	mov    %esi,0x4(%esp)
  801798:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80179f:	e8 4a f8 ff ff       	call   800fee <sys_page_unmap>
  8017a4:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  8017a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017b2:	e8 37 f8 ff ff       	call   800fee <sys_page_unmap>
  8017b7:	89 d8                	mov    %ebx,%eax
  8017b9:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  8017bc:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  8017bf:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  8017c2:	89 ec                	mov    %ebp,%esp
  8017c4:	5d                   	pop    %ebp
  8017c5:	c3                   	ret    

008017c6 <close_all>:
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	53                   	push   %ebx
  8017ca:	83 ec 04             	sub    $0x4,%esp
  8017cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017d2:	89 1c 24             	mov    %ebx,(%esp)
  8017d5:	e8 51 fe ff ff       	call   80162b <close>
  8017da:	83 c3 01             	add    $0x1,%ebx
  8017dd:	83 fb 20             	cmp    $0x20,%ebx
  8017e0:	75 f0                	jne    8017d2 <close_all+0xc>
  8017e2:	83 c4 04             	add    $0x4,%esp
  8017e5:	5b                   	pop    %ebx
  8017e6:	5d                   	pop    %ebp
  8017e7:	c3                   	ret    

008017e8 <fsipc>:
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017e8:	55                   	push   %ebp
  8017e9:	89 e5                	mov    %esp,%ebp
  8017eb:	53                   	push   %ebx
  8017ec:	83 ec 14             	sub    $0x14,%esp
  8017ef:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017f1:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  8017f7:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8017fe:	00 
  8017ff:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801806:	00 
  801807:	89 44 24 04          	mov    %eax,0x4(%esp)
  80180b:	89 14 24             	mov    %edx,(%esp)
  80180e:	e8 0d 08 00 00       	call   802020 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801813:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80181a:	00 
  80181b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80181f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801826:	e8 a9 08 00 00       	call   8020d4 <ipc_recv>
}
  80182b:	83 c4 14             	add    $0x14,%esp
  80182e:	5b                   	pop    %ebx
  80182f:	5d                   	pop    %ebp
  801830:	c3                   	ret    

00801831 <sync>:

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
  801831:	55                   	push   %ebp
  801832:	89 e5                	mov    %esp,%ebp
  801834:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801837:	ba 00 00 00 00       	mov    $0x0,%edx
  80183c:	b8 08 00 00 00       	mov    $0x8,%eax
  801841:	e8 a2 ff ff ff       	call   8017e8 <fsipc>
}
  801846:	c9                   	leave  
  801847:	c3                   	ret    

00801848 <devfile_trunc>:
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	83 ec 08             	sub    $0x8,%esp
  80184e:	8b 45 08             	mov    0x8(%ebp),%eax
  801851:	8b 40 0c             	mov    0xc(%eax),%eax
  801854:	a3 00 30 80 00       	mov    %eax,0x803000
  801859:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185c:	a3 04 30 80 00       	mov    %eax,0x803004
  801861:	ba 00 00 00 00       	mov    $0x0,%edx
  801866:	b8 02 00 00 00       	mov    $0x2,%eax
  80186b:	e8 78 ff ff ff       	call   8017e8 <fsipc>
  801870:	c9                   	leave  
  801871:	c3                   	ret    

00801872 <devfile_flush>:
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	83 ec 08             	sub    $0x8,%esp
  801878:	8b 45 08             	mov    0x8(%ebp),%eax
  80187b:	8b 40 0c             	mov    0xc(%eax),%eax
  80187e:	a3 00 30 80 00       	mov    %eax,0x803000
  801883:	ba 00 00 00 00       	mov    $0x0,%edx
  801888:	b8 06 00 00 00       	mov    $0x6,%eax
  80188d:	e8 56 ff ff ff       	call   8017e8 <fsipc>
  801892:	c9                   	leave  
  801893:	c3                   	ret    

00801894 <devfile_stat>:
  801894:	55                   	push   %ebp
  801895:	89 e5                	mov    %esp,%ebp
  801897:	53                   	push   %ebx
  801898:	83 ec 14             	sub    $0x14,%esp
  80189b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80189e:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a1:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a4:	a3 00 30 80 00       	mov    %eax,0x803000
  8018a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ae:	b8 05 00 00 00       	mov    $0x5,%eax
  8018b3:	e8 30 ff ff ff       	call   8017e8 <fsipc>
  8018b8:	85 c0                	test   %eax,%eax
  8018ba:	78 2b                	js     8018e7 <devfile_stat+0x53>
  8018bc:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  8018c3:	00 
  8018c4:	89 1c 24             	mov    %ebx,(%esp)
  8018c7:	e8 b5 f0 ff ff       	call   800981 <strcpy>
  8018cc:	a1 80 30 80 00       	mov    0x803080,%eax
  8018d1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  8018d7:	a1 84 30 80 00       	mov    0x803084,%eax
  8018dc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8018e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e7:	83 c4 14             	add    $0x14,%esp
  8018ea:	5b                   	pop    %ebx
  8018eb:	5d                   	pop    %ebp
  8018ec:	c3                   	ret    

008018ed <devfile_write>:
  8018ed:	55                   	push   %ebp
  8018ee:	89 e5                	mov    %esp,%ebp
  8018f0:	83 ec 18             	sub    $0x18,%esp
  8018f3:	8b 55 10             	mov    0x10(%ebp),%edx
  8018f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f9:	8b 40 0c             	mov    0xc(%eax),%eax
  8018fc:	a3 00 30 80 00       	mov    %eax,0x803000
  801901:	89 d0                	mov    %edx,%eax
  801903:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  801909:	76 05                	jbe    801910 <devfile_write+0x23>
  80190b:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801910:	89 15 04 30 80 00    	mov    %edx,0x803004
  801916:	89 44 24 08          	mov    %eax,0x8(%esp)
  80191a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80191d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801921:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  801928:	e8 5d f2 ff ff       	call   800b8a <memmove>
  80192d:	ba 00 00 00 00       	mov    $0x0,%edx
  801932:	b8 04 00 00 00       	mov    $0x4,%eax
  801937:	e8 ac fe ff ff       	call   8017e8 <fsipc>
  80193c:	c9                   	leave  
  80193d:	c3                   	ret    

0080193e <devfile_read>:
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
  801941:	53                   	push   %ebx
  801942:	83 ec 14             	sub    $0x14,%esp
  801945:	8b 45 08             	mov    0x8(%ebp),%eax
  801948:	8b 40 0c             	mov    0xc(%eax),%eax
  80194b:	a3 00 30 80 00       	mov    %eax,0x803000
  801950:	8b 45 10             	mov    0x10(%ebp),%eax
  801953:	a3 04 30 80 00       	mov    %eax,0x803004
  801958:	ba 00 30 80 00       	mov    $0x803000,%edx
  80195d:	b8 03 00 00 00       	mov    $0x3,%eax
  801962:	e8 81 fe ff ff       	call   8017e8 <fsipc>
  801967:	89 c3                	mov    %eax,%ebx
  801969:	85 c0                	test   %eax,%eax
  80196b:	7e 17                	jle    801984 <devfile_read+0x46>
  80196d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801971:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801978:	00 
  801979:	8b 45 0c             	mov    0xc(%ebp),%eax
  80197c:	89 04 24             	mov    %eax,(%esp)
  80197f:	e8 06 f2 ff ff       	call   800b8a <memmove>
  801984:	89 d8                	mov    %ebx,%eax
  801986:	83 c4 14             	add    $0x14,%esp
  801989:	5b                   	pop    %ebx
  80198a:	5d                   	pop    %ebp
  80198b:	c3                   	ret    

0080198c <remove>:
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
  80198f:	53                   	push   %ebx
  801990:	83 ec 14             	sub    $0x14,%esp
  801993:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801996:	89 1c 24             	mov    %ebx,(%esp)
  801999:	e8 92 ef ff ff       	call   800930 <strlen>
  80199e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  8019a3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019a8:	7f 21                	jg     8019cb <remove+0x3f>
  8019aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019ae:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  8019b5:	e8 c7 ef ff ff       	call   800981 <strcpy>
  8019ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8019bf:	b8 07 00 00 00       	mov    $0x7,%eax
  8019c4:	e8 1f fe ff ff       	call   8017e8 <fsipc>
  8019c9:	89 c2                	mov    %eax,%edx
  8019cb:	89 d0                	mov    %edx,%eax
  8019cd:	83 c4 14             	add    $0x14,%esp
  8019d0:	5b                   	pop    %ebx
  8019d1:	5d                   	pop    %ebp
  8019d2:	c3                   	ret    

008019d3 <open>:
  8019d3:	55                   	push   %ebp
  8019d4:	89 e5                	mov    %esp,%ebp
  8019d6:	56                   	push   %esi
  8019d7:	53                   	push   %ebx
  8019d8:	83 ec 30             	sub    $0x30,%esp
  8019db:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8019de:	89 04 24             	mov    %eax,(%esp)
  8019e1:	e8 15 f8 ff ff       	call   8011fb <fd_alloc>
  8019e6:	89 c3                	mov    %eax,%ebx
  8019e8:	85 c0                	test   %eax,%eax
  8019ea:	79 18                	jns    801a04 <open+0x31>
  8019ec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019f3:	00 
  8019f4:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8019f7:	89 04 24             	mov    %eax,(%esp)
  8019fa:	e8 a4 fb ff ff       	call   8015a3 <fd_close>
  8019ff:	e9 9f 00 00 00       	jmp    801aa3 <open+0xd0>
  801a04:	8b 45 08             	mov    0x8(%ebp),%eax
  801a07:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a0b:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801a12:	e8 6a ef ff ff       	call   800981 <strcpy>
  801a17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1a:	a3 00 34 80 00       	mov    %eax,0x803400
  801a1f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801a22:	89 04 24             	mov    %eax,(%esp)
  801a25:	e8 b6 f7 ff ff       	call   8011e0 <fd2data>
  801a2a:	89 c6                	mov    %eax,%esi
  801a2c:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  801a2f:	b8 01 00 00 00       	mov    $0x1,%eax
  801a34:	e8 af fd ff ff       	call   8017e8 <fsipc>
  801a39:	89 c3                	mov    %eax,%ebx
  801a3b:	85 c0                	test   %eax,%eax
  801a3d:	79 15                	jns    801a54 <open+0x81>
  801a3f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a46:	00 
  801a47:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801a4a:	89 04 24             	mov    %eax,(%esp)
  801a4d:	e8 51 fb ff ff       	call   8015a3 <fd_close>
  801a52:	eb 4f                	jmp    801aa3 <open+0xd0>
  801a54:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801a5b:	00 
  801a5c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801a60:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a67:	00 
  801a68:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801a6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a6f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a76:	e8 d1 f5 ff ff       	call   80104c <sys_page_map>
  801a7b:	89 c3                	mov    %eax,%ebx
  801a7d:	85 c0                	test   %eax,%eax
  801a7f:	79 15                	jns    801a96 <open+0xc3>
  801a81:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a88:	00 
  801a89:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801a8c:	89 04 24             	mov    %eax,(%esp)
  801a8f:	e8 0f fb ff ff       	call   8015a3 <fd_close>
  801a94:	eb 0d                	jmp    801aa3 <open+0xd0>
  801a96:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801a99:	89 04 24             	mov    %eax,(%esp)
  801a9c:	e8 2f f7 ff ff       	call   8011d0 <fd2num>
  801aa1:	89 c3                	mov    %eax,%ebx
  801aa3:	89 d8                	mov    %ebx,%eax
  801aa5:	83 c4 30             	add    $0x30,%esp
  801aa8:	5b                   	pop    %ebx
  801aa9:	5e                   	pop    %esi
  801aaa:	5d                   	pop    %ebp
  801aab:	c3                   	ret    
  801aac:	00 00                	add    %al,(%eax)
	...

00801ab0 <devsock_stat>:
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ab0:	55                   	push   %ebp
  801ab1:	89 e5                	mov    %esp,%ebp
  801ab3:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  801ab6:	c7 44 24 04 98 2c 80 	movl   $0x802c98,0x4(%esp)
  801abd:	00 
  801abe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac1:	89 04 24             	mov    %eax,(%esp)
  801ac4:	e8 b8 ee ff ff       	call   800981 <strcpy>
	return 0;
}
  801ac9:	b8 00 00 00 00       	mov    $0x0,%eax
  801ace:	c9                   	leave  
  801acf:	c3                   	ret    

00801ad0 <devsock_close>:
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	83 ec 08             	sub    $0x8,%esp
  801ad6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad9:	8b 40 0c             	mov    0xc(%eax),%eax
  801adc:	89 04 24             	mov    %eax,(%esp)
  801adf:	e8 be 02 00 00       	call   801da2 <nsipc_close>
  801ae4:	c9                   	leave  
  801ae5:	c3                   	ret    

00801ae6 <devsock_write>:
  801ae6:	55                   	push   %ebp
  801ae7:	89 e5                	mov    %esp,%ebp
  801ae9:	83 ec 18             	sub    $0x18,%esp
  801aec:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801af3:	00 
  801af4:	8b 45 10             	mov    0x10(%ebp),%eax
  801af7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801afb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801afe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b02:	8b 45 08             	mov    0x8(%ebp),%eax
  801b05:	8b 40 0c             	mov    0xc(%eax),%eax
  801b08:	89 04 24             	mov    %eax,(%esp)
  801b0b:	e8 ce 02 00 00       	call   801dde <nsipc_send>
  801b10:	c9                   	leave  
  801b11:	c3                   	ret    

00801b12 <devsock_read>:
  801b12:	55                   	push   %ebp
  801b13:	89 e5                	mov    %esp,%ebp
  801b15:	83 ec 18             	sub    $0x18,%esp
  801b18:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801b1f:	00 
  801b20:	8b 45 10             	mov    0x10(%ebp),%eax
  801b23:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b27:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b31:	8b 40 0c             	mov    0xc(%eax),%eax
  801b34:	89 04 24             	mov    %eax,(%esp)
  801b37:	e8 15 03 00 00       	call   801e51 <nsipc_recv>
  801b3c:	c9                   	leave  
  801b3d:	c3                   	ret    

00801b3e <alloc_sockfd>:
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	56                   	push   %esi
  801b42:	53                   	push   %ebx
  801b43:	83 ec 20             	sub    $0x20,%esp
  801b46:	89 c6                	mov    %eax,%esi
  801b48:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  801b4b:	89 04 24             	mov    %eax,(%esp)
  801b4e:	e8 a8 f6 ff ff       	call   8011fb <fd_alloc>
  801b53:	89 c3                	mov    %eax,%ebx
  801b55:	85 c0                	test   %eax,%eax
  801b57:	78 21                	js     801b7a <alloc_sockfd+0x3c>
  801b59:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801b60:	00 
  801b61:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801b64:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b68:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b6f:	e8 36 f5 ff ff       	call   8010aa <sys_page_alloc>
  801b74:	89 c3                	mov    %eax,%ebx
  801b76:	85 c0                	test   %eax,%eax
  801b78:	79 0a                	jns    801b84 <alloc_sockfd+0x46>
  801b7a:	89 34 24             	mov    %esi,(%esp)
  801b7d:	e8 20 02 00 00       	call   801da2 <nsipc_close>
  801b82:	eb 28                	jmp    801bac <alloc_sockfd+0x6e>
  801b84:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801b8a:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801b8d:	89 10                	mov    %edx,(%eax)
  801b8f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801b92:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
  801b99:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801b9c:	89 70 0c             	mov    %esi,0xc(%eax)
  801b9f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801ba2:	89 04 24             	mov    %eax,(%esp)
  801ba5:	e8 26 f6 ff ff       	call   8011d0 <fd2num>
  801baa:	89 c3                	mov    %eax,%ebx
  801bac:	89 d8                	mov    %ebx,%eax
  801bae:	83 c4 20             	add    $0x20,%esp
  801bb1:	5b                   	pop    %ebx
  801bb2:	5e                   	pop    %esi
  801bb3:	5d                   	pop    %ebp
  801bb4:	c3                   	ret    

00801bb5 <socket>:

int
socket(int domain, int type, int protocol)
{
  801bb5:	55                   	push   %ebp
  801bb6:	89 e5                	mov    %esp,%ebp
  801bb8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bbb:	8b 45 10             	mov    0x10(%ebp),%eax
  801bbe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bc5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcc:	89 04 24             	mov    %eax,(%esp)
  801bcf:	e8 82 01 00 00       	call   801d56 <nsipc_socket>
  801bd4:	85 c0                	test   %eax,%eax
  801bd6:	78 05                	js     801bdd <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801bd8:	e8 61 ff ff ff       	call   801b3e <alloc_sockfd>
}
  801bdd:	c9                   	leave  
  801bde:	66 90                	xchg   %ax,%ax
  801be0:	c3                   	ret    

00801be1 <fd2sockid>:
  801be1:	55                   	push   %ebp
  801be2:	89 e5                	mov    %esp,%ebp
  801be4:	83 ec 18             	sub    $0x18,%esp
  801be7:	8d 55 fc             	lea    0xfffffffc(%ebp),%edx
  801bea:	89 54 24 04          	mov    %edx,0x4(%esp)
  801bee:	89 04 24             	mov    %eax,(%esp)
  801bf1:	e8 58 f6 ff ff       	call   80124e <fd_lookup>
  801bf6:	89 c2                	mov    %eax,%edx
  801bf8:	85 c0                	test   %eax,%eax
  801bfa:	78 15                	js     801c11 <fd2sockid+0x30>
  801bfc:	8b 4d fc             	mov    0xfffffffc(%ebp),%ecx
  801bff:	8b 01                	mov    (%ecx),%eax
  801c01:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  801c06:	3b 05 20 60 80 00    	cmp    0x806020,%eax
  801c0c:	75 03                	jne    801c11 <fd2sockid+0x30>
  801c0e:	8b 51 0c             	mov    0xc(%ecx),%edx
  801c11:	89 d0                	mov    %edx,%eax
  801c13:	c9                   	leave  
  801c14:	c3                   	ret    

00801c15 <listen>:
  801c15:	55                   	push   %ebp
  801c16:	89 e5                	mov    %esp,%ebp
  801c18:	83 ec 08             	sub    $0x8,%esp
  801c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1e:	e8 be ff ff ff       	call   801be1 <fd2sockid>
  801c23:	89 c2                	mov    %eax,%edx
  801c25:	85 c0                	test   %eax,%eax
  801c27:	78 11                	js     801c3a <listen+0x25>
  801c29:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c30:	89 14 24             	mov    %edx,(%esp)
  801c33:	e8 48 01 00 00       	call   801d80 <nsipc_listen>
  801c38:	89 c2                	mov    %eax,%edx
  801c3a:	89 d0                	mov    %edx,%eax
  801c3c:	c9                   	leave  
  801c3d:	c3                   	ret    

00801c3e <connect>:
  801c3e:	55                   	push   %ebp
  801c3f:	89 e5                	mov    %esp,%ebp
  801c41:	83 ec 18             	sub    $0x18,%esp
  801c44:	8b 45 08             	mov    0x8(%ebp),%eax
  801c47:	e8 95 ff ff ff       	call   801be1 <fd2sockid>
  801c4c:	89 c2                	mov    %eax,%edx
  801c4e:	85 c0                	test   %eax,%eax
  801c50:	78 18                	js     801c6a <connect+0x2c>
  801c52:	8b 45 10             	mov    0x10(%ebp),%eax
  801c55:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c59:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c60:	89 14 24             	mov    %edx,(%esp)
  801c63:	e8 71 02 00 00       	call   801ed9 <nsipc_connect>
  801c68:	89 c2                	mov    %eax,%edx
  801c6a:	89 d0                	mov    %edx,%eax
  801c6c:	c9                   	leave  
  801c6d:	c3                   	ret    

00801c6e <shutdown>:
  801c6e:	55                   	push   %ebp
  801c6f:	89 e5                	mov    %esp,%ebp
  801c71:	83 ec 08             	sub    $0x8,%esp
  801c74:	8b 45 08             	mov    0x8(%ebp),%eax
  801c77:	e8 65 ff ff ff       	call   801be1 <fd2sockid>
  801c7c:	89 c2                	mov    %eax,%edx
  801c7e:	85 c0                	test   %eax,%eax
  801c80:	78 11                	js     801c93 <shutdown+0x25>
  801c82:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c85:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c89:	89 14 24             	mov    %edx,(%esp)
  801c8c:	e8 2b 01 00 00       	call   801dbc <nsipc_shutdown>
  801c91:	89 c2                	mov    %eax,%edx
  801c93:	89 d0                	mov    %edx,%eax
  801c95:	c9                   	leave  
  801c96:	c3                   	ret    

00801c97 <bind>:
  801c97:	55                   	push   %ebp
  801c98:	89 e5                	mov    %esp,%ebp
  801c9a:	83 ec 18             	sub    $0x18,%esp
  801c9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca0:	e8 3c ff ff ff       	call   801be1 <fd2sockid>
  801ca5:	89 c2                	mov    %eax,%edx
  801ca7:	85 c0                	test   %eax,%eax
  801ca9:	78 18                	js     801cc3 <bind+0x2c>
  801cab:	8b 45 10             	mov    0x10(%ebp),%eax
  801cae:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cb9:	89 14 24             	mov    %edx,(%esp)
  801cbc:	e8 57 02 00 00       	call   801f18 <nsipc_bind>
  801cc1:	89 c2                	mov    %eax,%edx
  801cc3:	89 d0                	mov    %edx,%eax
  801cc5:	c9                   	leave  
  801cc6:	c3                   	ret    

00801cc7 <accept>:
  801cc7:	55                   	push   %ebp
  801cc8:	89 e5                	mov    %esp,%ebp
  801cca:	83 ec 18             	sub    $0x18,%esp
  801ccd:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd0:	e8 0c ff ff ff       	call   801be1 <fd2sockid>
  801cd5:	89 c2                	mov    %eax,%edx
  801cd7:	85 c0                	test   %eax,%eax
  801cd9:	78 23                	js     801cfe <accept+0x37>
  801cdb:	8b 45 10             	mov    0x10(%ebp),%eax
  801cde:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ce2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ce5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ce9:	89 14 24             	mov    %edx,(%esp)
  801cec:	e8 66 02 00 00       	call   801f57 <nsipc_accept>
  801cf1:	89 c2                	mov    %eax,%edx
  801cf3:	85 c0                	test   %eax,%eax
  801cf5:	78 07                	js     801cfe <accept+0x37>
  801cf7:	e8 42 fe ff ff       	call   801b3e <alloc_sockfd>
  801cfc:	89 c2                	mov    %eax,%edx
  801cfe:	89 d0                	mov    %edx,%eax
  801d00:	c9                   	leave  
  801d01:	c3                   	ret    
	...

00801d10 <nsipc>:
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d10:	55                   	push   %ebp
  801d11:	89 e5                	mov    %esp,%ebp
  801d13:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d16:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  801d1c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d23:	00 
  801d24:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801d2b:	00 
  801d2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d30:	89 14 24             	mov    %edx,(%esp)
  801d33:	e8 e8 02 00 00       	call   802020 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d38:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d3f:	00 
  801d40:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d47:	00 
  801d48:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d4f:	e8 80 03 00 00       	call   8020d4 <ipc_recv>
}
  801d54:	c9                   	leave  
  801d55:	c3                   	ret    

00801d56 <nsipc_socket>:

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
  801d56:	55                   	push   %ebp
  801d57:	89 e5                	mov    %esp,%ebp
  801d59:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5f:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.socket.req_type = type;
  801d64:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d67:	a3 04 50 80 00       	mov    %eax,0x805004
	nsipcbuf.socket.req_protocol = protocol;
  801d6c:	8b 45 10             	mov    0x10(%ebp),%eax
  801d6f:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SOCKET);
  801d74:	b8 09 00 00 00       	mov    $0x9,%eax
  801d79:	e8 92 ff ff ff       	call   801d10 <nsipc>
}
  801d7e:	c9                   	leave  
  801d7f:	c3                   	ret    

00801d80 <nsipc_listen>:
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
  801d83:	83 ec 08             	sub    $0x8,%esp
  801d86:	8b 45 08             	mov    0x8(%ebp),%eax
  801d89:	a3 00 50 80 00       	mov    %eax,0x805000
  801d8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d91:	a3 04 50 80 00       	mov    %eax,0x805004
  801d96:	b8 06 00 00 00       	mov    $0x6,%eax
  801d9b:	e8 70 ff ff ff       	call   801d10 <nsipc>
  801da0:	c9                   	leave  
  801da1:	c3                   	ret    

00801da2 <nsipc_close>:
  801da2:	55                   	push   %ebp
  801da3:	89 e5                	mov    %esp,%ebp
  801da5:	83 ec 08             	sub    $0x8,%esp
  801da8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dab:	a3 00 50 80 00       	mov    %eax,0x805000
  801db0:	b8 04 00 00 00       	mov    $0x4,%eax
  801db5:	e8 56 ff ff ff       	call   801d10 <nsipc>
  801dba:	c9                   	leave  
  801dbb:	c3                   	ret    

00801dbc <nsipc_shutdown>:
  801dbc:	55                   	push   %ebp
  801dbd:	89 e5                	mov    %esp,%ebp
  801dbf:	83 ec 08             	sub    $0x8,%esp
  801dc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc5:	a3 00 50 80 00       	mov    %eax,0x805000
  801dca:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dcd:	a3 04 50 80 00       	mov    %eax,0x805004
  801dd2:	b8 03 00 00 00       	mov    $0x3,%eax
  801dd7:	e8 34 ff ff ff       	call   801d10 <nsipc>
  801ddc:	c9                   	leave  
  801ddd:	c3                   	ret    

00801dde <nsipc_send>:
  801dde:	55                   	push   %ebp
  801ddf:	89 e5                	mov    %esp,%ebp
  801de1:	53                   	push   %ebx
  801de2:	83 ec 14             	sub    $0x14,%esp
  801de5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801de8:	8b 45 08             	mov    0x8(%ebp),%eax
  801deb:	a3 00 50 80 00       	mov    %eax,0x805000
  801df0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801df6:	7e 24                	jle    801e1c <nsipc_send+0x3e>
  801df8:	c7 44 24 0c a4 2c 80 	movl   $0x802ca4,0xc(%esp)
  801dff:	00 
  801e00:	c7 44 24 08 b0 2c 80 	movl   $0x802cb0,0x8(%esp)
  801e07:	00 
  801e08:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  801e0f:	00 
  801e10:	c7 04 24 c5 2c 80 00 	movl   $0x802cc5,(%esp)
  801e17:	e8 8c 01 00 00       	call   801fa8 <_panic>
  801e1c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e20:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e23:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e27:	c7 04 24 0c 50 80 00 	movl   $0x80500c,(%esp)
  801e2e:	e8 57 ed ff ff       	call   800b8a <memmove>
  801e33:	89 1d 04 50 80 00    	mov    %ebx,0x805004
  801e39:	8b 45 14             	mov    0x14(%ebp),%eax
  801e3c:	a3 08 50 80 00       	mov    %eax,0x805008
  801e41:	b8 08 00 00 00       	mov    $0x8,%eax
  801e46:	e8 c5 fe ff ff       	call   801d10 <nsipc>
  801e4b:	83 c4 14             	add    $0x14,%esp
  801e4e:	5b                   	pop    %ebx
  801e4f:	5d                   	pop    %ebp
  801e50:	c3                   	ret    

00801e51 <nsipc_recv>:
  801e51:	55                   	push   %ebp
  801e52:	89 e5                	mov    %esp,%ebp
  801e54:	83 ec 18             	sub    $0x18,%esp
  801e57:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  801e5a:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  801e5d:	8b 75 10             	mov    0x10(%ebp),%esi
  801e60:	8b 45 08             	mov    0x8(%ebp),%eax
  801e63:	a3 00 50 80 00       	mov    %eax,0x805000
  801e68:	89 35 04 50 80 00    	mov    %esi,0x805004
  801e6e:	8b 45 14             	mov    0x14(%ebp),%eax
  801e71:	a3 08 50 80 00       	mov    %eax,0x805008
  801e76:	b8 07 00 00 00       	mov    $0x7,%eax
  801e7b:	e8 90 fe ff ff       	call   801d10 <nsipc>
  801e80:	89 c3                	mov    %eax,%ebx
  801e82:	85 c0                	test   %eax,%eax
  801e84:	78 47                	js     801ecd <nsipc_recv+0x7c>
  801e86:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e8b:	7f 05                	jg     801e92 <nsipc_recv+0x41>
  801e8d:	39 c6                	cmp    %eax,%esi
  801e8f:	90                   	nop    
  801e90:	7d 24                	jge    801eb6 <nsipc_recv+0x65>
  801e92:	c7 44 24 0c d1 2c 80 	movl   $0x802cd1,0xc(%esp)
  801e99:	00 
  801e9a:	c7 44 24 08 b0 2c 80 	movl   $0x802cb0,0x8(%esp)
  801ea1:	00 
  801ea2:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  801ea9:	00 
  801eaa:	c7 04 24 c5 2c 80 00 	movl   $0x802cc5,(%esp)
  801eb1:	e8 f2 00 00 00       	call   801fa8 <_panic>
  801eb6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801eba:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801ec1:	00 
  801ec2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec5:	89 04 24             	mov    %eax,(%esp)
  801ec8:	e8 bd ec ff ff       	call   800b8a <memmove>
  801ecd:	89 d8                	mov    %ebx,%eax
  801ecf:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  801ed2:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  801ed5:	89 ec                	mov    %ebp,%esp
  801ed7:	5d                   	pop    %ebp
  801ed8:	c3                   	ret    

00801ed9 <nsipc_connect>:
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	53                   	push   %ebx
  801edd:	83 ec 14             	sub    $0x14,%esp
  801ee0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ee3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee6:	a3 00 50 80 00       	mov    %eax,0x805000
  801eeb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801eef:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ef6:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  801efd:	e8 88 ec ff ff       	call   800b8a <memmove>
  801f02:	89 1d 14 50 80 00    	mov    %ebx,0x805014
  801f08:	b8 05 00 00 00       	mov    $0x5,%eax
  801f0d:	e8 fe fd ff ff       	call   801d10 <nsipc>
  801f12:	83 c4 14             	add    $0x14,%esp
  801f15:	5b                   	pop    %ebx
  801f16:	5d                   	pop    %ebp
  801f17:	c3                   	ret    

00801f18 <nsipc_bind>:
  801f18:	55                   	push   %ebp
  801f19:	89 e5                	mov    %esp,%ebp
  801f1b:	53                   	push   %ebx
  801f1c:	83 ec 14             	sub    $0x14,%esp
  801f1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f22:	8b 45 08             	mov    0x8(%ebp),%eax
  801f25:	a3 00 50 80 00       	mov    %eax,0x805000
  801f2a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f31:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f35:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  801f3c:	e8 49 ec ff ff       	call   800b8a <memmove>
  801f41:	89 1d 14 50 80 00    	mov    %ebx,0x805014
  801f47:	b8 02 00 00 00       	mov    $0x2,%eax
  801f4c:	e8 bf fd ff ff       	call   801d10 <nsipc>
  801f51:	83 c4 14             	add    $0x14,%esp
  801f54:	5b                   	pop    %ebx
  801f55:	5d                   	pop    %ebp
  801f56:	c3                   	ret    

00801f57 <nsipc_accept>:
  801f57:	55                   	push   %ebp
  801f58:	89 e5                	mov    %esp,%ebp
  801f5a:	53                   	push   %ebx
  801f5b:	83 ec 14             	sub    $0x14,%esp
  801f5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f61:	a3 00 50 80 00       	mov    %eax,0x805000
  801f66:	b8 01 00 00 00       	mov    $0x1,%eax
  801f6b:	e8 a0 fd ff ff       	call   801d10 <nsipc>
  801f70:	89 c3                	mov    %eax,%ebx
  801f72:	85 c0                	test   %eax,%eax
  801f74:	78 27                	js     801f9d <nsipc_accept+0x46>
  801f76:	a1 10 50 80 00       	mov    0x805010,%eax
  801f7b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f7f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801f86:	00 
  801f87:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f8a:	89 04 24             	mov    %eax,(%esp)
  801f8d:	e8 f8 eb ff ff       	call   800b8a <memmove>
  801f92:	8b 15 10 50 80 00    	mov    0x805010,%edx
  801f98:	8b 45 10             	mov    0x10(%ebp),%eax
  801f9b:	89 10                	mov    %edx,(%eax)
  801f9d:	89 d8                	mov    %ebx,%eax
  801f9f:	83 c4 14             	add    $0x14,%esp
  801fa2:	5b                   	pop    %ebx
  801fa3:	5d                   	pop    %ebp
  801fa4:	c3                   	ret    
  801fa5:	00 00                	add    %al,(%eax)
	...

00801fa8 <_panic>:
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  801fa8:	55                   	push   %ebp
  801fa9:	89 e5                	mov    %esp,%ebp
  801fab:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  801fae:	8d 45 14             	lea    0x14(%ebp),%eax
  801fb1:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)

	// Print the panic message
	if (argv0)
  801fb4:	a1 50 60 80 00       	mov    0x806050,%eax
  801fb9:	85 c0                	test   %eax,%eax
  801fbb:	74 10                	je     801fcd <_panic+0x25>
		cprintf("%s: ", argv0);
  801fbd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fc1:	c7 04 24 e6 2c 80 00 	movl   $0x802ce6,(%esp)
  801fc8:	e8 2c e3 ff ff       	call   8002f9 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  801fcd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fd0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fd4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fdb:	a1 00 60 80 00       	mov    0x806000,%eax
  801fe0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe4:	c7 04 24 eb 2c 80 00 	movl   $0x802ceb,(%esp)
  801feb:	e8 09 e3 ff ff       	call   8002f9 <cprintf>
	vcprintf(fmt, ap);
  801ff0:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  801ff3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ff7:	8b 45 10             	mov    0x10(%ebp),%eax
  801ffa:	89 04 24             	mov    %eax,(%esp)
  801ffd:	e8 96 e2 ff ff       	call   800298 <vcprintf>
	cprintf("\n");
  802002:	c7 04 24 49 2d 80 00 	movl   $0x802d49,(%esp)
  802009:	e8 eb e2 ff ff       	call   8002f9 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80200e:	cc                   	int3   
  80200f:	eb fd                	jmp    80200e <_panic+0x66>
	...

00802020 <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	57                   	push   %edi
  802024:	56                   	push   %esi
  802025:	53                   	push   %ebx
  802026:	83 ec 1c             	sub    $0x1c,%esp
  802029:	8b 75 08             	mov    0x8(%ebp),%esi
  80202c:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  80202f:	e8 09 f1 ff ff       	call   80113d <sys_getenvid>
  802034:	25 ff 03 00 00       	and    $0x3ff,%eax
  802039:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80203c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802041:	a3 4c 60 80 00       	mov    %eax,0x80604c
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  802046:	e8 f2 f0 ff ff       	call   80113d <sys_getenvid>
  80204b:	25 ff 03 00 00       	and    $0x3ff,%eax
  802050:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802053:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802058:	a3 4c 60 80 00       	mov    %eax,0x80604c
		if(env->env_id==to_env){
  80205d:	8b 40 4c             	mov    0x4c(%eax),%eax
  802060:	39 f0                	cmp    %esi,%eax
  802062:	75 0e                	jne    802072 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  802064:	c7 04 24 07 2d 80 00 	movl   $0x802d07,(%esp)
  80206b:	e8 89 e2 ff ff       	call   8002f9 <cprintf>
  802070:	eb 5a                	jmp    8020cc <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  802072:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802076:	8b 45 10             	mov    0x10(%ebp),%eax
  802079:	89 44 24 08          	mov    %eax,0x8(%esp)
  80207d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802080:	89 44 24 04          	mov    %eax,0x4(%esp)
  802084:	89 34 24             	mov    %esi,(%esp)
  802087:	e8 10 ee ff ff       	call   800e9c <sys_ipc_try_send>
  80208c:	89 c3                	mov    %eax,%ebx
  80208e:	85 c0                	test   %eax,%eax
  802090:	79 25                	jns    8020b7 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  802092:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802095:	74 2b                	je     8020c2 <ipc_send+0xa2>
				panic("send error:%e",r);
  802097:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80209b:	c7 44 24 08 23 2d 80 	movl   $0x802d23,0x8(%esp)
  8020a2:	00 
  8020a3:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8020aa:	00 
  8020ab:	c7 04 24 31 2d 80 00 	movl   $0x802d31,(%esp)
  8020b2:	e8 f1 fe ff ff       	call   801fa8 <_panic>
		}
			sys_yield();
  8020b7:	e8 4d f0 ff ff       	call   801109 <sys_yield>
		
	}while(r!=0);
  8020bc:	85 db                	test   %ebx,%ebx
  8020be:	75 86                	jne    802046 <ipc_send+0x26>
  8020c0:	eb 0a                	jmp    8020cc <ipc_send+0xac>
  8020c2:	e8 42 f0 ff ff       	call   801109 <sys_yield>
  8020c7:	e9 7a ff ff ff       	jmp    802046 <ipc_send+0x26>
	return;
	//panic("ipc_send not implemented");
}
  8020cc:	83 c4 1c             	add    $0x1c,%esp
  8020cf:	5b                   	pop    %ebx
  8020d0:	5e                   	pop    %esi
  8020d1:	5f                   	pop    %edi
  8020d2:	5d                   	pop    %ebp
  8020d3:	c3                   	ret    

008020d4 <ipc_recv>:
  8020d4:	55                   	push   %ebp
  8020d5:	89 e5                	mov    %esp,%ebp
  8020d7:	57                   	push   %edi
  8020d8:	56                   	push   %esi
  8020d9:	53                   	push   %ebx
  8020da:	83 ec 0c             	sub    $0xc,%esp
  8020dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8020e0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8020e3:	e8 55 f0 ff ff       	call   80113d <sys_getenvid>
  8020e8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8020ed:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020f0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020f5:	a3 4c 60 80 00       	mov    %eax,0x80604c
  8020fa:	85 f6                	test   %esi,%esi
  8020fc:	74 29                	je     802127 <ipc_recv+0x53>
  8020fe:	8b 40 4c             	mov    0x4c(%eax),%eax
  802101:	3b 06                	cmp    (%esi),%eax
  802103:	75 22                	jne    802127 <ipc_recv+0x53>
  802105:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80210b:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  802111:	c7 04 24 07 2d 80 00 	movl   $0x802d07,(%esp)
  802118:	e8 dc e1 ff ff       	call   8002f9 <cprintf>
  80211d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802122:	e9 8a 00 00 00       	jmp    8021b1 <ipc_recv+0xdd>
  802127:	e8 11 f0 ff ff       	call   80113d <sys_getenvid>
  80212c:	25 ff 03 00 00       	and    $0x3ff,%eax
  802131:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802134:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802139:	a3 4c 60 80 00       	mov    %eax,0x80604c
  80213e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802141:	89 04 24             	mov    %eax,(%esp)
  802144:	e8 f6 ec ff ff       	call   800e3f <sys_ipc_recv>
  802149:	89 c3                	mov    %eax,%ebx
  80214b:	85 c0                	test   %eax,%eax
  80214d:	79 1a                	jns    802169 <ipc_recv+0x95>
  80214f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802155:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  80215b:	c7 04 24 3b 2d 80 00 	movl   $0x802d3b,(%esp)
  802162:	e8 92 e1 ff ff       	call   8002f9 <cprintf>
  802167:	eb 48                	jmp    8021b1 <ipc_recv+0xdd>
  802169:	e8 cf ef ff ff       	call   80113d <sys_getenvid>
  80216e:	25 ff 03 00 00       	and    $0x3ff,%eax
  802173:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802176:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80217b:	a3 4c 60 80 00       	mov    %eax,0x80604c
  802180:	85 f6                	test   %esi,%esi
  802182:	74 05                	je     802189 <ipc_recv+0xb5>
  802184:	8b 40 74             	mov    0x74(%eax),%eax
  802187:	89 06                	mov    %eax,(%esi)
  802189:	85 ff                	test   %edi,%edi
  80218b:	74 0a                	je     802197 <ipc_recv+0xc3>
  80218d:	a1 4c 60 80 00       	mov    0x80604c,%eax
  802192:	8b 40 78             	mov    0x78(%eax),%eax
  802195:	89 07                	mov    %eax,(%edi)
  802197:	e8 a1 ef ff ff       	call   80113d <sys_getenvid>
  80219c:	25 ff 03 00 00       	and    $0x3ff,%eax
  8021a1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8021a4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021a9:	a3 4c 60 80 00       	mov    %eax,0x80604c
  8021ae:	8b 58 70             	mov    0x70(%eax),%ebx
  8021b1:	89 d8                	mov    %ebx,%eax
  8021b3:	83 c4 0c             	add    $0xc,%esp
  8021b6:	5b                   	pop    %ebx
  8021b7:	5e                   	pop    %esi
  8021b8:	5f                   	pop    %edi
  8021b9:	5d                   	pop    %ebp
  8021ba:	c3                   	ret    
  8021bb:	00 00                	add    %al,(%eax)
  8021bd:	00 00                	add    %al,(%eax)
	...

008021c0 <inet_ntoa>:
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8021c0:	55                   	push   %ebp
  8021c1:	89 e5                	mov    %esp,%ebp
  8021c3:	57                   	push   %edi
  8021c4:	56                   	push   %esi
  8021c5:	53                   	push   %ebx
  8021c6:	83 ec 18             	sub    $0x18,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8021c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8021cc:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  char inv[3];
  char *rp;
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  8021cf:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  8021d2:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  8021d5:	be 00 00 00 00       	mov    $0x0,%esi
  8021da:	bf 3c 60 80 00       	mov    $0x80603c,%edi
  8021df:	c6 45 e3 00          	movb   $0x0,0xffffffe3(%ebp)
  8021e3:	eb 02                	jmp    8021e7 <inet_ntoa+0x27>
  8021e5:	89 c6                	mov    %eax,%esi
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  8021e7:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  8021ea:	0f b6 0a             	movzbl (%edx),%ecx
      *ap /= (u8_t)10;
  8021ed:	b8 cd ff ff ff       	mov    $0xffffffcd,%eax
  8021f2:	f6 e1                	mul    %cl
  8021f4:	89 c2                	mov    %eax,%edx
  8021f6:	66 c1 ea 08          	shr    $0x8,%dx
  8021fa:	c0 ea 03             	shr    $0x3,%dl
  8021fd:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  802200:	88 10                	mov    %dl,(%eax)
      inv[i++] = '0' + rem;
  802202:	89 f0                	mov    %esi,%eax
  802204:	0f b6 d8             	movzbl %al,%ebx
  802207:	8d 04 92             	lea    (%edx,%edx,4),%eax
  80220a:	01 c0                	add    %eax,%eax
  80220c:	28 c1                	sub    %al,%cl
  80220e:	83 c1 30             	add    $0x30,%ecx
  802211:	88 4c 1d ed          	mov    %cl,0xffffffed(%ebp,%ebx,1)
  802215:	8d 46 01             	lea    0x1(%esi),%eax
    } while(*ap);
  802218:	84 d2                	test   %dl,%dl
  80221a:	75 c9                	jne    8021e5 <inet_ntoa+0x25>
    while(i--)
  80221c:	89 f1                	mov    %esi,%ecx
  80221e:	80 f9 ff             	cmp    $0xff,%cl
  802221:	74 20                	je     802243 <inet_ntoa+0x83>
  802223:	89 fa                	mov    %edi,%edx
      *rp++ = inv[i];
  802225:	0f b6 c1             	movzbl %cl,%eax
  802228:	0f b6 44 05 ed       	movzbl 0xffffffed(%ebp,%eax,1),%eax
  80222d:	88 02                	mov    %al,(%edx)
  80222f:	83 c2 01             	add    $0x1,%edx
  802232:	83 e9 01             	sub    $0x1,%ecx
  802235:	80 f9 ff             	cmp    $0xff,%cl
  802238:	75 eb                	jne    802225 <inet_ntoa+0x65>
  80223a:	89 f2                	mov    %esi,%edx
  80223c:	0f b6 c2             	movzbl %dl,%eax
  80223f:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
    *rp++ = '.';
  802243:	c6 07 2e             	movb   $0x2e,(%edi)
  802246:	83 c7 01             	add    $0x1,%edi
  802249:	80 45 e3 01          	addb   $0x1,0xffffffe3(%ebp)
  80224d:	80 7d e3 03          	cmpb   $0x3,0xffffffe3(%ebp)
  802251:	77 0b                	ja     80225e <inet_ntoa+0x9e>
    ap++;
  802253:	83 45 dc 01          	addl   $0x1,0xffffffdc(%ebp)
  802257:	b8 00 00 00 00       	mov    $0x0,%eax
  80225c:	eb 87                	jmp    8021e5 <inet_ntoa+0x25>
  }
  *--rp = 0;
  80225e:	c6 47 ff 00          	movb   $0x0,0xffffffff(%edi)
  return str;
}
  802262:	b8 3c 60 80 00       	mov    $0x80603c,%eax
  802267:	83 c4 18             	add    $0x18,%esp
  80226a:	5b                   	pop    %ebx
  80226b:	5e                   	pop    %esi
  80226c:	5f                   	pop    %edi
  80226d:	5d                   	pop    %ebp
  80226e:	c3                   	ret    

0080226f <htons>:

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
  80226f:	55                   	push   %ebp
  802270:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  802272:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  802276:	89 c2                	mov    %eax,%edx
  802278:	c1 ea 08             	shr    $0x8,%edx
  80227b:	c1 e0 08             	shl    $0x8,%eax
  80227e:	09 d0                	or     %edx,%eax
  802280:	0f b7 c0             	movzwl %ax,%eax
}
  802283:	5d                   	pop    %ebp
  802284:	c3                   	ret    

00802285 <ntohs>:

/**
 * Convert an u16_t from network- to host byte order.
 *
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  802285:	55                   	push   %ebp
  802286:	89 e5                	mov    %esp,%ebp
  802288:	83 ec 04             	sub    $0x4,%esp
  return htons(n);
  80228b:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80228f:	89 04 24             	mov    %eax,(%esp)
  802292:	e8 d8 ff ff ff       	call   80226f <htons>
  802297:	0f b7 c0             	movzwl %ax,%eax
}
  80229a:	c9                   	leave  
  80229b:	c3                   	ret    

0080229c <htonl>:

/**
 * Convert an u32_t from host- to network byte order.
 *
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  80229c:	55                   	push   %ebp
  80229d:	89 e5                	mov    %esp,%ebp
  80229f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022a2:	89 c8                	mov    %ecx,%eax
  8022a4:	25 00 ff 00 00       	and    $0xff00,%eax
  8022a9:	c1 e0 08             	shl    $0x8,%eax
  8022ac:	89 ca                	mov    %ecx,%edx
  8022ae:	c1 e2 18             	shl    $0x18,%edx
  8022b1:	09 d0                	or     %edx,%eax
  8022b3:	89 ca                	mov    %ecx,%edx
  8022b5:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  8022bb:	c1 ea 08             	shr    $0x8,%edx
  8022be:	09 d0                	or     %edx,%eax
  8022c0:	c1 e9 18             	shr    $0x18,%ecx
  8022c3:	09 c8                	or     %ecx,%eax
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  8022c5:	5d                   	pop    %ebp
  8022c6:	c3                   	ret    

008022c7 <inet_aton>:
  8022c7:	55                   	push   %ebp
  8022c8:	89 e5                	mov    %esp,%ebp
  8022ca:	57                   	push   %edi
  8022cb:	56                   	push   %esi
  8022cc:	53                   	push   %ebx
  8022cd:	83 ec 1c             	sub    $0x1c,%esp
  8022d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8022d3:	0f be 0b             	movsbl (%ebx),%ecx
  8022d6:	8d 41 d0             	lea    0xffffffd0(%ecx),%eax
  8022d9:	3c 09                	cmp    $0x9,%al
  8022db:	0f 87 9a 01 00 00    	ja     80247b <inet_aton+0x1b4>
  8022e1:	8d 45 e4             	lea    0xffffffe4(%ebp),%eax
  8022e4:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  8022e7:	be 0a 00 00 00       	mov    $0xa,%esi
  8022ec:	83 f9 30             	cmp    $0x30,%ecx
  8022ef:	75 20                	jne    802311 <inet_aton+0x4a>
  8022f1:	83 c3 01             	add    $0x1,%ebx
  8022f4:	0f be 0b             	movsbl (%ebx),%ecx
  8022f7:	83 f9 78             	cmp    $0x78,%ecx
  8022fa:	74 0a                	je     802306 <inet_aton+0x3f>
  8022fc:	be 08 00 00 00       	mov    $0x8,%esi
  802301:	83 f9 58             	cmp    $0x58,%ecx
  802304:	75 0b                	jne    802311 <inet_aton+0x4a>
  802306:	83 c3 01             	add    $0x1,%ebx
  802309:	0f be 0b             	movsbl (%ebx),%ecx
  80230c:	be 10 00 00 00       	mov    $0x10,%esi
  802311:	bf 00 00 00 00       	mov    $0x0,%edi
  802316:	89 ca                	mov    %ecx,%edx
  802318:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  80231b:	3c 09                	cmp    $0x9,%al
  80231d:	77 11                	ja     802330 <inet_aton+0x69>
  80231f:	89 f8                	mov    %edi,%eax
  802321:	0f af c6             	imul   %esi,%eax
  802324:	8d 7c 08 d0          	lea    0xffffffd0(%eax,%ecx,1),%edi
  802328:	83 c3 01             	add    $0x1,%ebx
  80232b:	0f be 0b             	movsbl (%ebx),%ecx
  80232e:	eb e6                	jmp    802316 <inet_aton+0x4f>
  802330:	83 fe 10             	cmp    $0x10,%esi
  802333:	75 30                	jne    802365 <inet_aton+0x9e>
  802335:	8d 42 9f             	lea    0xffffff9f(%edx),%eax
  802338:	88 45 df             	mov    %al,0xffffffdf(%ebp)
  80233b:	3c 05                	cmp    $0x5,%al
  80233d:	76 07                	jbe    802346 <inet_aton+0x7f>
  80233f:	8d 42 bf             	lea    0xffffffbf(%edx),%eax
  802342:	3c 05                	cmp    $0x5,%al
  802344:	77 1f                	ja     802365 <inet_aton+0x9e>
  802346:	80 7d df 1a          	cmpb   $0x1a,0xffffffdf(%ebp)
  80234a:	19 c0                	sbb    %eax,%eax
  80234c:	83 e0 20             	and    $0x20,%eax
  80234f:	29 c1                	sub    %eax,%ecx
  802351:	8d 41 c9             	lea    0xffffffc9(%ecx),%eax
  802354:	89 fa                	mov    %edi,%edx
  802356:	c1 e2 04             	shl    $0x4,%edx
  802359:	89 c7                	mov    %eax,%edi
  80235b:	09 d7                	or     %edx,%edi
  80235d:	83 c3 01             	add    $0x1,%ebx
  802360:	0f be 0b             	movsbl (%ebx),%ecx
  802363:	eb b1                	jmp    802316 <inet_aton+0x4f>
  802365:	83 f9 2e             	cmp    $0x2e,%ecx
  802368:	75 2d                	jne    802397 <inet_aton+0xd0>
  80236a:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  80236d:	3b 45 e0             	cmp    0xffffffe0(%ebp),%eax
  802370:	0f 86 05 01 00 00    	jbe    80247b <inet_aton+0x1b4>
  802376:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  802379:	89 3a                	mov    %edi,(%edx)
  80237b:	83 c3 01             	add    $0x1,%ebx
  80237e:	0f be 0b             	movsbl (%ebx),%ecx
  802381:	8d 41 d0             	lea    0xffffffd0(%ecx),%eax
  802384:	3c 09                	cmp    $0x9,%al
  802386:	0f 87 ef 00 00 00    	ja     80247b <inet_aton+0x1b4>
  80238c:	83 c2 04             	add    $0x4,%edx
  80238f:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  802392:	e9 50 ff ff ff       	jmp    8022e7 <inet_aton+0x20>
  802397:	89 fb                	mov    %edi,%ebx
  802399:	85 c9                	test   %ecx,%ecx
  80239b:	74 2e                	je     8023cb <inet_aton+0x104>
  80239d:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  8023a0:	3c 5f                	cmp    $0x5f,%al
  8023a2:	0f 87 d3 00 00 00    	ja     80247b <inet_aton+0x1b4>
  8023a8:	83 f9 20             	cmp    $0x20,%ecx
  8023ab:	74 1e                	je     8023cb <inet_aton+0x104>
  8023ad:	83 f9 0c             	cmp    $0xc,%ecx
  8023b0:	74 19                	je     8023cb <inet_aton+0x104>
  8023b2:	83 f9 0a             	cmp    $0xa,%ecx
  8023b5:	74 14                	je     8023cb <inet_aton+0x104>
  8023b7:	83 f9 0d             	cmp    $0xd,%ecx
  8023ba:	74 0f                	je     8023cb <inet_aton+0x104>
  8023bc:	83 f9 09             	cmp    $0x9,%ecx
  8023bf:	90                   	nop    
  8023c0:	74 09                	je     8023cb <inet_aton+0x104>
  8023c2:	83 f9 0b             	cmp    $0xb,%ecx
  8023c5:	0f 85 b0 00 00 00    	jne    80247b <inet_aton+0x1b4>
  8023cb:	8d 45 e4             	lea    0xffffffe4(%ebp),%eax
  8023ce:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  8023d1:	29 c2                	sub    %eax,%edx
  8023d3:	89 d0                	mov    %edx,%eax
  8023d5:	c1 f8 02             	sar    $0x2,%eax
  8023d8:	83 c0 01             	add    $0x1,%eax
  8023db:	83 f8 02             	cmp    $0x2,%eax
  8023de:	74 24                	je     802404 <inet_aton+0x13d>
  8023e0:	83 f8 02             	cmp    $0x2,%eax
  8023e3:	7f 0d                	jg     8023f2 <inet_aton+0x12b>
  8023e5:	85 c0                	test   %eax,%eax
  8023e7:	0f 84 8e 00 00 00    	je     80247b <inet_aton+0x1b4>
  8023ed:	8d 76 00             	lea    0x0(%esi),%esi
  8023f0:	eb 6a                	jmp    80245c <inet_aton+0x195>
  8023f2:	83 f8 03             	cmp    $0x3,%eax
  8023f5:	74 27                	je     80241e <inet_aton+0x157>
  8023f7:	83 f8 04             	cmp    $0x4,%eax
  8023fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802400:	75 5a                	jne    80245c <inet_aton+0x195>
  802402:	eb 36                	jmp    80243a <inet_aton+0x173>
  802404:	81 fb ff ff ff 00    	cmp    $0xffffff,%ebx
  80240a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802410:	77 69                	ja     80247b <inet_aton+0x1b4>
  802412:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  802415:	c1 e0 18             	shl    $0x18,%eax
  802418:	89 df                	mov    %ebx,%edi
  80241a:	09 c7                	or     %eax,%edi
  80241c:	eb 3e                	jmp    80245c <inet_aton+0x195>
  80241e:	81 fb ff ff 00 00    	cmp    $0xffff,%ebx
  802424:	77 55                	ja     80247b <inet_aton+0x1b4>
  802426:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
  802429:	c1 e2 10             	shl    $0x10,%edx
  80242c:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  80242f:	c1 e0 18             	shl    $0x18,%eax
  802432:	09 c2                	or     %eax,%edx
  802434:	89 d7                	mov    %edx,%edi
  802436:	09 df                	or     %ebx,%edi
  802438:	eb 22                	jmp    80245c <inet_aton+0x195>
  80243a:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
  802440:	77 39                	ja     80247b <inet_aton+0x1b4>
  802442:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802445:	c1 e0 10             	shl    $0x10,%eax
  802448:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  80244b:	c1 e2 18             	shl    $0x18,%edx
  80244e:	09 d0                	or     %edx,%eax
  802450:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  802453:	c1 e2 08             	shl    $0x8,%edx
  802456:	09 d0                	or     %edx,%eax
  802458:	89 c7                	mov    %eax,%edi
  80245a:	09 df                	or     %ebx,%edi
  80245c:	b8 01 00 00 00       	mov    $0x1,%eax
  802461:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802465:	74 19                	je     802480 <inet_aton+0x1b9>
  802467:	89 3c 24             	mov    %edi,(%esp)
  80246a:	e8 2d fe ff ff       	call   80229c <htonl>
  80246f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802472:	89 02                	mov    %eax,(%edx)
  802474:	b8 01 00 00 00       	mov    $0x1,%eax
  802479:	eb 05                	jmp    802480 <inet_aton+0x1b9>
  80247b:	b8 00 00 00 00       	mov    $0x0,%eax
  802480:	83 c4 1c             	add    $0x1c,%esp
  802483:	5b                   	pop    %ebx
  802484:	5e                   	pop    %esi
  802485:	5f                   	pop    %edi
  802486:	5d                   	pop    %ebp
  802487:	c3                   	ret    

00802488 <inet_addr>:
  802488:	55                   	push   %ebp
  802489:	89 e5                	mov    %esp,%ebp
  80248b:	83 ec 18             	sub    $0x18,%esp
  80248e:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  802491:	89 44 24 04          	mov    %eax,0x4(%esp)
  802495:	8b 45 08             	mov    0x8(%ebp),%eax
  802498:	89 04 24             	mov    %eax,(%esp)
  80249b:	e8 27 fe ff ff       	call   8022c7 <inet_aton>
  8024a0:	83 f8 01             	cmp    $0x1,%eax
  8024a3:	19 c0                	sbb    %eax,%eax
  8024a5:	0b 45 fc             	or     0xfffffffc(%ebp),%eax
  8024a8:	c9                   	leave  
  8024a9:	c3                   	ret    

008024aa <ntohl>:

/**
 * Convert an u32_t from network- to host byte order.
 *
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  8024aa:	55                   	push   %ebp
  8024ab:	89 e5                	mov    %esp,%ebp
  8024ad:	83 ec 04             	sub    $0x4,%esp
  return htonl(n);
  8024b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8024b3:	89 04 24             	mov    %eax,(%esp)
  8024b6:	e8 e1 fd ff ff       	call   80229c <htonl>
}
  8024bb:	c9                   	leave  
  8024bc:	c3                   	ret    
  8024bd:	00 00                	add    %al,(%eax)
	...

008024c0 <__udivdi3>:
  8024c0:	55                   	push   %ebp
  8024c1:	89 e5                	mov    %esp,%ebp
  8024c3:	57                   	push   %edi
  8024c4:	56                   	push   %esi
  8024c5:	83 ec 1c             	sub    $0x1c,%esp
  8024c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8024cb:	8b 55 14             	mov    0x14(%ebp),%edx
  8024ce:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8024d1:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  8024d4:	89 c1                	mov    %eax,%ecx
  8024d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8024d9:	85 d2                	test   %edx,%edx
  8024db:	89 d6                	mov    %edx,%esi
  8024dd:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
  8024e0:	75 1e                	jne    802500 <__udivdi3+0x40>
  8024e2:	39 f9                	cmp    %edi,%ecx
  8024e4:	0f 86 8d 00 00 00    	jbe    802577 <__udivdi3+0xb7>
  8024ea:	89 fa                	mov    %edi,%edx
  8024ec:	f7 f1                	div    %ecx
  8024ee:	89 c1                	mov    %eax,%ecx
  8024f0:	89 c8                	mov    %ecx,%eax
  8024f2:	89 f2                	mov    %esi,%edx
  8024f4:	83 c4 1c             	add    $0x1c,%esp
  8024f7:	5e                   	pop    %esi
  8024f8:	5f                   	pop    %edi
  8024f9:	5d                   	pop    %ebp
  8024fa:	c3                   	ret    
  8024fb:	90                   	nop    
  8024fc:	8d 74 26 00          	lea    0x0(%esi),%esi
  802500:	39 fa                	cmp    %edi,%edx
  802502:	0f 87 98 00 00 00    	ja     8025a0 <__udivdi3+0xe0>
  802508:	0f bd c2             	bsr    %edx,%eax
  80250b:	83 f0 1f             	xor    $0x1f,%eax
  80250e:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  802511:	74 7f                	je     802592 <__udivdi3+0xd2>
  802513:	b8 20 00 00 00       	mov    $0x20,%eax
  802518:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  80251b:	2b 45 e4             	sub    0xffffffe4(%ebp),%eax
  80251e:	89 c1                	mov    %eax,%ecx
  802520:	d3 ea                	shr    %cl,%edx
  802522:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802526:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  802529:	89 f0                	mov    %esi,%eax
  80252b:	d3 e0                	shl    %cl,%eax
  80252d:	09 c2                	or     %eax,%edx
  80252f:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802532:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  802535:	89 fa                	mov    %edi,%edx
  802537:	d3 e0                	shl    %cl,%eax
  802539:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  80253d:	89 45 f4             	mov    %eax,0xfffffff4(%ebp)
  802540:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802543:	d3 e8                	shr    %cl,%eax
  802545:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802549:	d3 e2                	shl    %cl,%edx
  80254b:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  80254f:	09 d0                	or     %edx,%eax
  802551:	d3 ef                	shr    %cl,%edi
  802553:	89 fa                	mov    %edi,%edx
  802555:	f7 75 e0             	divl   0xffffffe0(%ebp)
  802558:	89 d1                	mov    %edx,%ecx
  80255a:	89 c7                	mov    %eax,%edi
  80255c:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80255f:	f7 e7                	mul    %edi
  802561:	39 d1                	cmp    %edx,%ecx
  802563:	89 c6                	mov    %eax,%esi
  802565:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  802568:	72 6f                	jb     8025d9 <__udivdi3+0x119>
  80256a:	39 ca                	cmp    %ecx,%edx
  80256c:	74 5e                	je     8025cc <__udivdi3+0x10c>
  80256e:	89 f9                	mov    %edi,%ecx
  802570:	31 f6                	xor    %esi,%esi
  802572:	e9 79 ff ff ff       	jmp    8024f0 <__udivdi3+0x30>
  802577:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80257a:	85 c0                	test   %eax,%eax
  80257c:	74 32                	je     8025b0 <__udivdi3+0xf0>
  80257e:	89 f2                	mov    %esi,%edx
  802580:	89 f8                	mov    %edi,%eax
  802582:	f7 f1                	div    %ecx
  802584:	89 c6                	mov    %eax,%esi
  802586:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802589:	f7 f1                	div    %ecx
  80258b:	89 c1                	mov    %eax,%ecx
  80258d:	e9 5e ff ff ff       	jmp    8024f0 <__udivdi3+0x30>
  802592:	39 d7                	cmp    %edx,%edi
  802594:	77 2a                	ja     8025c0 <__udivdi3+0x100>
  802596:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  802599:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
  80259c:	73 22                	jae    8025c0 <__udivdi3+0x100>
  80259e:	66 90                	xchg   %ax,%ax
  8025a0:	31 c9                	xor    %ecx,%ecx
  8025a2:	31 f6                	xor    %esi,%esi
  8025a4:	e9 47 ff ff ff       	jmp    8024f0 <__udivdi3+0x30>
  8025a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  8025b0:	b8 01 00 00 00       	mov    $0x1,%eax
  8025b5:	31 d2                	xor    %edx,%edx
  8025b7:	f7 75 f0             	divl   0xfffffff0(%ebp)
  8025ba:	89 c1                	mov    %eax,%ecx
  8025bc:	eb c0                	jmp    80257e <__udivdi3+0xbe>
  8025be:	66 90                	xchg   %ax,%ax
  8025c0:	b9 01 00 00 00       	mov    $0x1,%ecx
  8025c5:	31 f6                	xor    %esi,%esi
  8025c7:	e9 24 ff ff ff       	jmp    8024f0 <__udivdi3+0x30>
  8025cc:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8025cf:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8025d3:	d3 e0                	shl    %cl,%eax
  8025d5:	39 c6                	cmp    %eax,%esi
  8025d7:	76 95                	jbe    80256e <__udivdi3+0xae>
  8025d9:	8d 4f ff             	lea    0xffffffff(%edi),%ecx
  8025dc:	31 f6                	xor    %esi,%esi
  8025de:	e9 0d ff ff ff       	jmp    8024f0 <__udivdi3+0x30>
	...

008025f0 <__umoddi3>:
  8025f0:	55                   	push   %ebp
  8025f1:	89 e5                	mov    %esp,%ebp
  8025f3:	57                   	push   %edi
  8025f4:	56                   	push   %esi
  8025f5:	83 ec 30             	sub    $0x30,%esp
  8025f8:	8b 55 14             	mov    0x14(%ebp),%edx
  8025fb:	8b 45 10             	mov    0x10(%ebp),%eax
  8025fe:	8b 75 08             	mov    0x8(%ebp),%esi
  802601:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802604:	85 d2                	test   %edx,%edx
  802606:	c7 45 d0 00 00 00 00 	movl   $0x0,0xffffffd0(%ebp)
  80260d:	89 c1                	mov    %eax,%ecx
  80260f:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  802616:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  802619:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  80261c:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  80261f:	89 7d e0             	mov    %edi,0xffffffe0(%ebp)
  802622:	75 1c                	jne    802640 <__umoddi3+0x50>
  802624:	39 f8                	cmp    %edi,%eax
  802626:	89 fa                	mov    %edi,%edx
  802628:	0f 86 d4 00 00 00    	jbe    802702 <__umoddi3+0x112>
  80262e:	89 f0                	mov    %esi,%eax
  802630:	f7 f1                	div    %ecx
  802632:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802635:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  80263c:	eb 12                	jmp    802650 <__umoddi3+0x60>
  80263e:	66 90                	xchg   %ax,%ax
  802640:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802643:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  802646:	76 18                	jbe    802660 <__umoddi3+0x70>
  802648:	89 75 d0             	mov    %esi,0xffffffd0(%ebp)
  80264b:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  80264e:	66 90                	xchg   %ax,%ax
  802650:	8b 45 d0             	mov    0xffffffd0(%ebp),%eax
  802653:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  802656:	83 c4 30             	add    $0x30,%esp
  802659:	5e                   	pop    %esi
  80265a:	5f                   	pop    %edi
  80265b:	5d                   	pop    %ebp
  80265c:	c3                   	ret    
  80265d:	8d 76 00             	lea    0x0(%esi),%esi
  802660:	0f bd 45 e8          	bsr    0xffffffe8(%ebp),%eax
  802664:	83 f0 1f             	xor    $0x1f,%eax
  802667:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  80266a:	0f 84 c0 00 00 00    	je     802730 <__umoddi3+0x140>
  802670:	b8 20 00 00 00       	mov    $0x20,%eax
  802675:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  802678:	2b 45 dc             	sub    0xffffffdc(%ebp),%eax
  80267b:	8b 7d ec             	mov    0xffffffec(%ebp),%edi
  80267e:	8b 75 f0             	mov    0xfffffff0(%ebp),%esi
  802681:	89 c1                	mov    %eax,%ecx
  802683:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  802686:	d3 ea                	shr    %cl,%edx
  802688:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  80268b:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  80268f:	d3 e0                	shl    %cl,%eax
  802691:	09 c2                	or     %eax,%edx
  802693:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802696:	d3 e7                	shl    %cl,%edi
  802698:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  80269c:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  80269f:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  8026a2:	d3 e8                	shr    %cl,%eax
  8026a4:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  8026a8:	d3 e2                	shl    %cl,%edx
  8026aa:	09 d0                	or     %edx,%eax
  8026ac:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  8026af:	d3 e6                	shl    %cl,%esi
  8026b1:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8026b5:	d3 ea                	shr    %cl,%edx
  8026b7:	f7 75 f4             	divl   0xfffffff4(%ebp)
  8026ba:	89 55 cc             	mov    %edx,0xffffffcc(%ebp)
  8026bd:	f7 e7                	mul    %edi
  8026bf:	39 55 cc             	cmp    %edx,0xffffffcc(%ebp)
  8026c2:	0f 82 a5 00 00 00    	jb     80276d <__umoddi3+0x17d>
  8026c8:	3b 55 cc             	cmp    0xffffffcc(%ebp),%edx
  8026cb:	0f 84 94 00 00 00    	je     802765 <__umoddi3+0x175>
  8026d1:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
  8026d4:	29 c6                	sub    %eax,%esi
  8026d6:	19 d1                	sbb    %edx,%ecx
  8026d8:	89 4d cc             	mov    %ecx,0xffffffcc(%ebp)
  8026db:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  8026df:	89 f2                	mov    %esi,%edx
  8026e1:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  8026e4:	d3 ea                	shr    %cl,%edx
  8026e6:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8026ea:	d3 e0                	shl    %cl,%eax
  8026ec:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  8026f0:	09 c2                	or     %eax,%edx
  8026f2:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  8026f5:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  8026f8:	d3 e8                	shr    %cl,%eax
  8026fa:	89 45 d4             	mov    %eax,0xffffffd4(%ebp)
  8026fd:	e9 4e ff ff ff       	jmp    802650 <__umoddi3+0x60>
  802702:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  802705:	85 c0                	test   %eax,%eax
  802707:	74 17                	je     802720 <__umoddi3+0x130>
  802709:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  80270c:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
  80270f:	f7 f1                	div    %ecx
  802711:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802714:	f7 f1                	div    %ecx
  802716:	e9 17 ff ff ff       	jmp    802632 <__umoddi3+0x42>
  80271b:	90                   	nop    
  80271c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802720:	b8 01 00 00 00       	mov    $0x1,%eax
  802725:	31 d2                	xor    %edx,%edx
  802727:	f7 75 ec             	divl   0xffffffec(%ebp)
  80272a:	89 c1                	mov    %eax,%ecx
  80272c:	eb db                	jmp    802709 <__umoddi3+0x119>
  80272e:	66 90                	xchg   %ax,%ax
  802730:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802733:	39 45 e0             	cmp    %eax,0xffffffe0(%ebp)
  802736:	77 19                	ja     802751 <__umoddi3+0x161>
  802738:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  80273b:	39 55 f0             	cmp    %edx,0xfffffff0(%ebp)
  80273e:	73 11                	jae    802751 <__umoddi3+0x161>
  802740:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  802743:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802746:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802749:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  80274c:	e9 ff fe ff ff       	jmp    802650 <__umoddi3+0x60>
  802751:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802754:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802757:	2b 45 ec             	sub    0xffffffec(%ebp),%eax
  80275a:	1b 4d e8             	sbb    0xffffffe8(%ebp),%ecx
  80275d:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  802760:	89 4d e0             	mov    %ecx,0xffffffe0(%ebp)
  802763:	eb db                	jmp    802740 <__umoddi3+0x150>
  802765:	39 f0                	cmp    %esi,%eax
  802767:	0f 86 64 ff ff ff    	jbe    8026d1 <__umoddi3+0xe1>
  80276d:	29 f8                	sub    %edi,%eax
  80276f:	1b 55 f4             	sbb    0xfffffff4(%ebp),%edx
  802772:	e9 5a ff ff ff       	jmp    8026d1 <__umoddi3+0xe1>
