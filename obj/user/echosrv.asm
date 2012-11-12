
obj/user/echosrv:     file format elf32-i386

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
  80002c:	e8 db 01 00 00       	call   80020c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <die>:
#define BUFFSIZE 32
#define MAXPENDING 5    // Max connection requests

static void
die(char *m)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 08             	sub    $0x8,%esp
	cprintf("%s\n", m);
  80003a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80003e:	c7 04 24 90 27 80 00 	movl   $0x802790,(%esp)
  800045:	e8 9b 02 00 00       	call   8002e5 <cprintf>
	exit();
  80004a:	e8 19 02 00 00       	call   800268 <exit>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    

00800051 <handle_client>:

void
handle_client(int sock)
{
  800051:	55                   	push   %ebp
  800052:	89 e5                	mov    %esp,%ebp
  800054:	57                   	push   %edi
  800055:	56                   	push   %esi
  800056:	53                   	push   %ebx
  800057:	83 ec 2c             	sub    $0x2c,%esp
  80005a:	8b 75 08             	mov    0x8(%ebp),%esi
	char buffer[BUFFSIZE];
	int received = -1;
	// Receive message
	if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  80005d:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
  800064:	00 
  800065:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  800068:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006c:	89 34 24             	mov    %esi,(%esp)
  80006f:	e8 24 14 00 00       	call   801498 <read>
  800074:	89 c3                	mov    %eax,%ebx
  800076:	85 c0                	test   %eax,%eax
  800078:	79 0a                	jns    800084 <handle_client+0x33>
		die("Failed to receive initial bytes from client");
  80007a:	b8 94 27 80 00       	mov    $0x802794,%eax
  80007f:	e8 b0 ff ff ff       	call   800034 <die>

	// Send bytes and check for more incoming data in loop
	while (received > 0) {
  800084:	85 db                	test   %ebx,%ebx
  800086:	7e 49                	jle    8000d1 <handle_client+0x80>
		// Send back received data
		if (write(sock, buffer, received) != received)
  800088:	8d 7d d4             	lea    -0x2c(%ebp),%edi
  80008b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80008f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800093:	89 34 24             	mov    %esi,(%esp)
  800096:	e8 72 13 00 00       	call   80140d <write>
  80009b:	39 d8                	cmp    %ebx,%eax
  80009d:	74 0a                	je     8000a9 <handle_client+0x58>
			die("Failed to send bytes to client");
  80009f:	b8 c0 27 80 00       	mov    $0x8027c0,%eax
  8000a4:	e8 8b ff ff ff       	call   800034 <die>

		// Check for more data
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  8000a9:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
  8000b0:	00 
  8000b1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8000b5:	89 34 24             	mov    %esi,(%esp)
  8000b8:	e8 db 13 00 00       	call   801498 <read>
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	79 0a                	jns    8000cd <handle_client+0x7c>
			die("Failed to receive additional bytes from client");
  8000c3:	b8 e0 27 80 00       	mov    $0x8027e0,%eax
  8000c8:	e8 67 ff ff ff       	call   800034 <die>
	// Receive message
	if ((received = read(sock, buffer, BUFFSIZE)) < 0)
		die("Failed to receive initial bytes from client");

	// Send bytes and check for more incoming data in loop
	while (received > 0) {
  8000cd:	85 db                	test   %ebx,%ebx
  8000cf:	7f ba                	jg     80008b <handle_client+0x3a>

		// Check for more data
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
			die("Failed to receive additional bytes from client");
	}
	close(sock);
  8000d1:	89 34 24             	mov    %esi,(%esp)
  8000d4:	e8 2c 15 00 00       	call   801605 <close>
}
  8000d9:	83 c4 2c             	add    $0x2c,%esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5f                   	pop    %edi
  8000df:	5d                   	pop    %ebp
  8000e0:	c3                   	ret    

008000e1 <umain>:

int
umain(void)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	57                   	push   %edi
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	83 ec 3c             	sub    $0x3c,%esp
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  8000ea:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  8000f1:	00 
  8000f2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8000f9:	00 
  8000fa:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800101:	e8 8f 1a 00 00       	call   801b95 <socket>
  800106:	89 c6                	mov    %eax,%esi
  800108:	85 c0                	test   %eax,%eax
  80010a:	79 0a                	jns    800116 <umain+0x35>
		die("Failed to create socket");
  80010c:	b8 40 27 80 00       	mov    $0x802740,%eax
  800111:	e8 1e ff ff ff       	call   800034 <die>

	cprintf("opened socket\n");
  800116:	c7 04 24 58 27 80 00 	movl   $0x802758,(%esp)
  80011d:	e8 c3 01 00 00       	call   8002e5 <cprintf>

	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  800122:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  800129:	00 
  80012a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800131:	00 
  800132:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  800135:	89 1c 24             	mov    %ebx,(%esp)
  800138:	e8 c1 09 00 00       	call   800afe <memset>
	echoserver.sin_family = AF_INET;                  // Internet/IP
  80013d:	c6 45 e5 02          	movb   $0x2,-0x1b(%ebp)
	echoserver.sin_addr.s_addr = htonl(INADDR_ANY);   // IP address
  800141:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800148:	e8 ff 20 00 00       	call   80224c <htonl>
  80014d:	89 45 e8             	mov    %eax,-0x18(%ebp)
	echoserver.sin_port = htons(PORT);		  // server port
  800150:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800157:	e8 c3 20 00 00       	call   80221f <htons>
  80015c:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)

	cprintf("trying to bind\n");
  800160:	c7 04 24 67 27 80 00 	movl   $0x802767,(%esp)
  800167:	e8 79 01 00 00       	call   8002e5 <cprintf>

	// Bind the server socket
	if (bind(serversock, (struct sockaddr *) &echoserver,
  80016c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  800173:	00 
  800174:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800178:	89 34 24             	mov    %esi,(%esp)
  80017b:	e8 e5 1a 00 00       	call   801c65 <bind>
  800180:	85 c0                	test   %eax,%eax
  800182:	79 0a                	jns    80018e <umain+0xad>
		 sizeof(echoserver)) < 0) {
		die("Failed to bind the server socket");
  800184:	b8 10 28 80 00       	mov    $0x802810,%eax
  800189:	e8 a6 fe ff ff       	call   800034 <die>
	}

	// Listen on the server socket
	if (listen(serversock, MAXPENDING) < 0)
  80018e:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  800195:	00 
  800196:	89 34 24             	mov    %esi,(%esp)
  800199:	e8 57 1a 00 00       	call   801bf5 <listen>
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	79 0a                	jns    8001ac <umain+0xcb>
		die("Failed to listen on server socket");
  8001a2:	b8 34 28 80 00       	mov    $0x802834,%eax
  8001a7:	e8 88 fe ff ff       	call   800034 <die>

	cprintf("bound\n");
  8001ac:	c7 04 24 77 27 80 00 	movl   $0x802777,(%esp)
  8001b3:	e8 2d 01 00 00       	call   8002e5 <cprintf>

	// Run until canceled
	while (1) {
		unsigned int clientlen = sizeof(echoclient);
		// Wait for client connection
		if ((clientsock =
  8001b8:	8d 7d d0             	lea    -0x30(%ebp),%edi

	cprintf("bound\n");

	// Run until canceled
	while (1) {
		unsigned int clientlen = sizeof(echoclient);
  8001bb:	c7 45 d0 10 00 00 00 	movl   $0x10,-0x30(%ebp)
		// Wait for client connection
		if ((clientsock =
  8001c2:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8001c6:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  8001c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001cd:	89 34 24             	mov    %esi,(%esp)
  8001d0:	e8 ba 1a 00 00       	call   801c8f <accept>
  8001d5:	89 c3                	mov    %eax,%ebx
  8001d7:	85 c0                	test   %eax,%eax
  8001d9:	79 0a                	jns    8001e5 <umain+0x104>
		     accept(serversock, (struct sockaddr *) &echoclient,
			    &clientlen)) < 0) {
			die("Failed to accept client connection");
  8001db:	b8 58 28 80 00       	mov    $0x802858,%eax
  8001e0:	e8 4f fe ff ff       	call   800034 <die>
		}
		cprintf("Client connected: %s\n", inet_ntoa(echoclient.sin_addr));
  8001e5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8001e8:	89 04 24             	mov    %eax,(%esp)
  8001eb:	e8 80 1f 00 00       	call   802170 <inet_ntoa>
  8001f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f4:	c7 04 24 7e 27 80 00 	movl   $0x80277e,(%esp)
  8001fb:	e8 e5 00 00 00       	call   8002e5 <cprintf>
		handle_client(clientsock);
  800200:	89 1c 24             	mov    %ebx,(%esp)
  800203:	e8 49 fe ff ff       	call   800051 <handle_client>
  800208:	eb b1                	jmp    8001bb <umain+0xda>
	...

0080020c <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	83 ec 18             	sub    $0x18,%esp
  800212:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800215:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800218:	8b 75 08             	mov    0x8(%ebp),%esi
  80021b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  80021e:	c7 05 4c 60 80 00 00 	movl   $0x0,0x80604c
  800225:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  800228:	e8 f0 0e 00 00       	call   80111d <sys_getenvid>
  80022d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800232:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800235:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80023a:	a3 4c 60 80 00       	mov    %eax,0x80604c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80023f:	85 f6                	test   %esi,%esi
  800241:	7e 07                	jle    80024a <libmain+0x3e>
		binaryname = argv[0];
  800243:	8b 03                	mov    (%ebx),%eax
  800245:	a3 00 60 80 00       	mov    %eax,0x806000

	// call user main routine
	umain(argc, argv);
  80024a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80024e:	89 34 24             	mov    %esi,(%esp)
  800251:	e8 8b fe ff ff       	call   8000e1 <umain>

	// exit gracefully
	exit();
  800256:	e8 0d 00 00 00       	call   800268 <exit>
}
  80025b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80025e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800261:	89 ec                	mov    %ebp,%esp
  800263:	5d                   	pop    %ebp
  800264:	c3                   	ret    
  800265:	00 00                	add    %al,(%eax)
	...

00800268 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80026e:	e8 2d 15 00 00       	call   8017a0 <close_all>
	sys_env_destroy(0);
  800273:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80027a:	e8 d2 0e 00 00       	call   801151 <sys_env_destroy>
}
  80027f:	c9                   	leave  
  800280:	c3                   	ret    
  800281:	00 00                	add    %al,(%eax)
	...

00800284 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80028d:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  800294:	00 00 00 
	b.cnt = 0;
  800297:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  80029e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002af:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b9:	c7 04 24 02 03 80 00 	movl   $0x800302,(%esp)
  8002c0:	e8 d0 01 00 00       	call   800495 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002c5:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
  8002cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cf:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  8002d5:	89 04 24             	mov    %eax,(%esp)
  8002d8:	e8 db 0a 00 00       	call   800db8 <sys_cputs>
  8002dd:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  8002e3:	c9                   	leave  
  8002e4:	c3                   	ret    

008002e5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
  8002e8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002eb:	8d 45 0c             	lea    0xc(%ebp),%eax
  8002ee:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  8002f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f8:	89 04 24             	mov    %eax,(%esp)
  8002fb:	e8 84 ff ff ff       	call   800284 <vcprintf>
	va_end(ap);

	return cnt;
}
  800300:	c9                   	leave  
  800301:	c3                   	ret    

00800302 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800302:	55                   	push   %ebp
  800303:	89 e5                	mov    %esp,%ebp
  800305:	53                   	push   %ebx
  800306:	83 ec 14             	sub    $0x14,%esp
  800309:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80030c:	8b 03                	mov    (%ebx),%eax
  80030e:	8b 55 08             	mov    0x8(%ebp),%edx
  800311:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800315:	83 c0 01             	add    $0x1,%eax
  800318:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80031a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80031f:	75 19                	jne    80033a <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800321:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800328:	00 
  800329:	8d 43 08             	lea    0x8(%ebx),%eax
  80032c:	89 04 24             	mov    %eax,(%esp)
  80032f:	e8 84 0a 00 00       	call   800db8 <sys_cputs>
		b->idx = 0;
  800334:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80033a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80033e:	83 c4 14             	add    $0x14,%esp
  800341:	5b                   	pop    %ebx
  800342:	5d                   	pop    %ebp
  800343:	c3                   	ret    
	...

00800350 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	57                   	push   %edi
  800354:	56                   	push   %esi
  800355:	53                   	push   %ebx
  800356:	83 ec 3c             	sub    $0x3c,%esp
  800359:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80035c:	89 d7                	mov    %edx,%edi
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	8b 55 0c             	mov    0xc(%ebp),%edx
  800364:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800367:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80036a:	8b 55 10             	mov    0x10(%ebp),%edx
  80036d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800370:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800373:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  80037a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80037d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  800380:	72 14                	jb     800396 <printnum+0x46>
  800382:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800385:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800388:	76 0c                	jbe    800396 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80038a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80038d:	83 eb 01             	sub    $0x1,%ebx
  800390:	85 db                	test   %ebx,%ebx
  800392:	7f 57                	jg     8003eb <printnum+0x9b>
  800394:	eb 64                	jmp    8003fa <printnum+0xaa>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800396:	89 74 24 10          	mov    %esi,0x10(%esp)
  80039a:	8b 45 14             	mov    0x14(%ebp),%eax
  80039d:	83 e8 01             	sub    $0x1,%eax
  8003a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003a4:	89 54 24 08          	mov    %edx,0x8(%esp)
  8003a8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8003ac:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8003b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8003b3:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8003b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ba:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003be:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003c1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8003c4:	89 04 24             	mov    %eax,(%esp)
  8003c7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003cb:	e8 d0 20 00 00       	call   8024a0 <__udivdi3>
  8003d0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003d4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003d8:	89 04 24             	mov    %eax,(%esp)
  8003db:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003df:	89 fa                	mov    %edi,%edx
  8003e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003e4:	e8 67 ff ff ff       	call   800350 <printnum>
  8003e9:	eb 0f                	jmp    8003fa <printnum+0xaa>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003eb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003ef:	89 34 24             	mov    %esi,(%esp)
  8003f2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003f5:	83 eb 01             	sub    $0x1,%ebx
  8003f8:	75 f1                	jne    8003eb <printnum+0x9b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003fe:	8b 74 24 04          	mov    0x4(%esp),%esi
  800402:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800405:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800408:	89 44 24 08          	mov    %eax,0x8(%esp)
  80040c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800410:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800413:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800416:	89 04 24             	mov    %eax,(%esp)
  800419:	89 54 24 04          	mov    %edx,0x4(%esp)
  80041d:	e8 ae 21 00 00       	call   8025d0 <__umoddi3>
  800422:	89 74 24 04          	mov    %esi,0x4(%esp)
  800426:	0f be 80 92 28 80 00 	movsbl 0x802892(%eax),%eax
  80042d:	89 04 24             	mov    %eax,(%esp)
  800430:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800433:	83 c4 3c             	add    $0x3c,%esp
  800436:	5b                   	pop    %ebx
  800437:	5e                   	pop    %esi
  800438:	5f                   	pop    %edi
  800439:	5d                   	pop    %ebp
  80043a:	c3                   	ret    

0080043b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80043b:	55                   	push   %ebp
  80043c:	89 e5                	mov    %esp,%ebp
  80043e:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800440:	83 fa 01             	cmp    $0x1,%edx
  800443:	7e 0e                	jle    800453 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  800445:	8b 10                	mov    (%eax),%edx
  800447:	8d 42 08             	lea    0x8(%edx),%eax
  80044a:	89 01                	mov    %eax,(%ecx)
  80044c:	8b 02                	mov    (%edx),%eax
  80044e:	8b 52 04             	mov    0x4(%edx),%edx
  800451:	eb 22                	jmp    800475 <getuint+0x3a>
	else if (lflag)
  800453:	85 d2                	test   %edx,%edx
  800455:	74 10                	je     800467 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800457:	8b 10                	mov    (%eax),%edx
  800459:	8d 42 04             	lea    0x4(%edx),%eax
  80045c:	89 01                	mov    %eax,(%ecx)
  80045e:	8b 02                	mov    (%edx),%eax
  800460:	ba 00 00 00 00       	mov    $0x0,%edx
  800465:	eb 0e                	jmp    800475 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800467:	8b 10                	mov    (%eax),%edx
  800469:	8d 42 04             	lea    0x4(%edx),%eax
  80046c:	89 01                	mov    %eax,(%ecx)
  80046e:	8b 02                	mov    (%edx),%eax
  800470:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800475:	5d                   	pop    %ebp
  800476:	c3                   	ret    

00800477 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800477:	55                   	push   %ebp
  800478:	89 e5                	mov    %esp,%ebp
  80047a:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  80047d:	83 42 08 01          	addl   $0x1,0x8(%edx)
	if (b->buf < b->ebuf)
  800481:	8b 02                	mov    (%edx),%eax
  800483:	3b 42 04             	cmp    0x4(%edx),%eax
  800486:	73 0b                	jae    800493 <sprintputch+0x1c>
		*b->buf++ = ch;
  800488:	0f b6 4d 08          	movzbl 0x8(%ebp),%ecx
  80048c:	88 08                	mov    %cl,(%eax)
  80048e:	83 c0 01             	add    $0x1,%eax
  800491:	89 02                	mov    %eax,(%edx)
}
  800493:	5d                   	pop    %ebp
  800494:	c3                   	ret    

00800495 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800495:	55                   	push   %ebp
  800496:	89 e5                	mov    %esp,%ebp
  800498:	57                   	push   %edi
  800499:	56                   	push   %esi
  80049a:	53                   	push   %ebx
  80049b:	83 ec 3c             	sub    $0x3c,%esp
  80049e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004a1:	eb 18                	jmp    8004bb <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004a3:	84 c0                	test   %al,%al
  8004a5:	0f 84 9f 03 00 00    	je     80084a <vprintfmt+0x3b5>
				return;
			putch(ch, putdat);
  8004ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004b2:	0f b6 c0             	movzbl %al,%eax
  8004b5:	89 04 24             	mov    %eax,(%esp)
  8004b8:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004bb:	0f b6 03             	movzbl (%ebx),%eax
  8004be:	83 c3 01             	add    $0x1,%ebx
  8004c1:	3c 25                	cmp    $0x25,%al
  8004c3:	75 de                	jne    8004a3 <vprintfmt+0xe>
  8004c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004ca:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
  8004d1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8004d6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004dd:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
  8004e1:	eb 07                	jmp    8004ea <vprintfmt+0x55>
  8004e3:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ea:	0f b6 13             	movzbl (%ebx),%edx
  8004ed:	83 c3 01             	add    $0x1,%ebx
  8004f0:	8d 42 dd             	lea    -0x23(%edx),%eax
  8004f3:	3c 55                	cmp    $0x55,%al
  8004f5:	0f 87 22 03 00 00    	ja     80081d <vprintfmt+0x388>
  8004fb:	0f b6 c0             	movzbl %al,%eax
  8004fe:	ff 24 85 e0 29 80 00 	jmp    *0x8029e0(,%eax,4)
  800505:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
  800509:	eb df                	jmp    8004ea <vprintfmt+0x55>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80050b:	0f b6 c2             	movzbl %dl,%eax
  80050e:	8d 78 d0             	lea    -0x30(%eax),%edi
				ch = *fmt;
  800511:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800514:	8d 42 d0             	lea    -0x30(%edx),%eax
  800517:	83 f8 09             	cmp    $0x9,%eax
  80051a:	76 08                	jbe    800524 <vprintfmt+0x8f>
  80051c:	eb 39                	jmp    800557 <vprintfmt+0xc2>
  80051e:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
  800522:	eb c6                	jmp    8004ea <vprintfmt+0x55>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800524:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800527:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  80052a:	8d 7c 42 d0          	lea    -0x30(%edx,%eax,2),%edi
				ch = *fmt;
  80052e:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800531:	8d 42 d0             	lea    -0x30(%edx),%eax
  800534:	83 f8 09             	cmp    $0x9,%eax
  800537:	77 1e                	ja     800557 <vprintfmt+0xc2>
  800539:	eb e9                	jmp    800524 <vprintfmt+0x8f>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80053b:	8b 55 14             	mov    0x14(%ebp),%edx
  80053e:	8d 42 04             	lea    0x4(%edx),%eax
  800541:	89 45 14             	mov    %eax,0x14(%ebp)
  800544:	8b 3a                	mov    (%edx),%edi
  800546:	eb 0f                	jmp    800557 <vprintfmt+0xc2>
			goto process_precision;

		case '.':
			if (width < 0)
  800548:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80054c:	79 9c                	jns    8004ea <vprintfmt+0x55>
  80054e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800555:	eb 93                	jmp    8004ea <vprintfmt+0x55>
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800557:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80055b:	90                   	nop    
  80055c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800560:	79 88                	jns    8004ea <vprintfmt+0x55>
  800562:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800565:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80056a:	e9 7b ff ff ff       	jmp    8004ea <vprintfmt+0x55>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80056f:	83 c1 01             	add    $0x1,%ecx
  800572:	e9 73 ff ff ff       	jmp    8004ea <vprintfmt+0x55>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8d 50 04             	lea    0x4(%eax),%edx
  80057d:	89 55 14             	mov    %edx,0x14(%ebp)
  800580:	8b 55 0c             	mov    0xc(%ebp),%edx
  800583:	89 54 24 04          	mov    %edx,0x4(%esp)
  800587:	8b 00                	mov    (%eax),%eax
  800589:	89 04 24             	mov    %eax,(%esp)
  80058c:	ff 55 08             	call   *0x8(%ebp)
  80058f:	e9 27 ff ff ff       	jmp    8004bb <vprintfmt+0x26>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800594:	8b 55 14             	mov    0x14(%ebp),%edx
  800597:	8d 42 04             	lea    0x4(%edx),%eax
  80059a:	89 45 14             	mov    %eax,0x14(%ebp)
  80059d:	8b 02                	mov    (%edx),%eax
  80059f:	89 c2                	mov    %eax,%edx
  8005a1:	c1 fa 1f             	sar    $0x1f,%edx
  8005a4:	31 d0                	xor    %edx,%eax
  8005a6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8005a8:	83 f8 0f             	cmp    $0xf,%eax
  8005ab:	7f 0b                	jg     8005b8 <vprintfmt+0x123>
  8005ad:	8b 14 85 40 2b 80 00 	mov    0x802b40(,%eax,4),%edx
  8005b4:	85 d2                	test   %edx,%edx
  8005b6:	75 23                	jne    8005db <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8005b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005bc:	c7 44 24 08 a3 28 80 	movl   $0x8028a3,0x8(%esp)
  8005c3:	00 
  8005c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8005ce:	89 14 24             	mov    %edx,(%esp)
  8005d1:	e8 ff 02 00 00       	call   8008d5 <printfmt>
  8005d6:	e9 e0 fe ff ff       	jmp    8004bb <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005db:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005df:	c7 44 24 08 82 2c 80 	movl   $0x802c82,0x8(%esp)
  8005e6:	00 
  8005e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8005f1:	89 14 24             	mov    %edx,(%esp)
  8005f4:	e8 dc 02 00 00       	call   8008d5 <printfmt>
  8005f9:	e9 bd fe ff ff       	jmp    8004bb <vprintfmt+0x26>
  8005fe:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800601:	89 f9                	mov    %edi,%ecx
  800603:	89 5d ec             	mov    %ebx,-0x14(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800606:	8b 55 14             	mov    0x14(%ebp),%edx
  800609:	8d 42 04             	lea    0x4(%edx),%eax
  80060c:	89 45 14             	mov    %eax,0x14(%ebp)
  80060f:	8b 12                	mov    (%edx),%edx
  800611:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800614:	85 d2                	test   %edx,%edx
  800616:	75 07                	jne    80061f <vprintfmt+0x18a>
  800618:	c7 45 dc ac 28 80 00 	movl   $0x8028ac,-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80061f:	85 f6                	test   %esi,%esi
  800621:	7e 41                	jle    800664 <vprintfmt+0x1cf>
  800623:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  800627:	74 3b                	je     800664 <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
  800629:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80062d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800630:	89 04 24             	mov    %eax,(%esp)
  800633:	e8 e8 02 00 00       	call   800920 <strnlen>
  800638:	29 c6                	sub    %eax,%esi
  80063a:	89 75 f0             	mov    %esi,-0x10(%ebp)
  80063d:	85 f6                	test   %esi,%esi
  80063f:	7e 23                	jle    800664 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800641:	0f be 55 eb          	movsbl -0x15(%ebp),%edx
  800645:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800648:	8b 45 0c             	mov    0xc(%ebp),%eax
  80064b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800652:	89 14 24             	mov    %edx,(%esp)
  800655:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800658:	83 ee 01             	sub    $0x1,%esi
  80065b:	75 eb                	jne    800648 <vprintfmt+0x1b3>
  80065d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800664:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800667:	0f b6 02             	movzbl (%edx),%eax
  80066a:	0f be d0             	movsbl %al,%edx
  80066d:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800670:	84 c0                	test   %al,%al
  800672:	75 42                	jne    8006b6 <vprintfmt+0x221>
  800674:	eb 49                	jmp    8006bf <vprintfmt+0x22a>
				if (altflag && (ch < ' ' || ch > '~'))
  800676:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80067a:	74 1b                	je     800697 <vprintfmt+0x202>
  80067c:	8d 42 e0             	lea    -0x20(%edx),%eax
  80067f:	83 f8 5e             	cmp    $0x5e,%eax
  800682:	76 13                	jbe    800697 <vprintfmt+0x202>
					putch('?', putdat);
  800684:	8b 45 0c             	mov    0xc(%ebp),%eax
  800687:	89 44 24 04          	mov    %eax,0x4(%esp)
  80068b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800692:	ff 55 08             	call   *0x8(%ebp)
  800695:	eb 0d                	jmp    8006a4 <vprintfmt+0x20f>
				else
					putch(ch, putdat);
  800697:	8b 45 0c             	mov    0xc(%ebp),%eax
  80069a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069e:	89 14 24             	mov    %edx,(%esp)
  8006a1:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006a4:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  8006a8:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8006ac:	83 c6 01             	add    $0x1,%esi
  8006af:	84 c0                	test   %al,%al
  8006b1:	74 0c                	je     8006bf <vprintfmt+0x22a>
  8006b3:	0f be d0             	movsbl %al,%edx
  8006b6:	85 ff                	test   %edi,%edi
  8006b8:	78 bc                	js     800676 <vprintfmt+0x1e1>
  8006ba:	83 ef 01             	sub    $0x1,%edi
  8006bd:	79 b7                	jns    800676 <vprintfmt+0x1e1>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006bf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8006c3:	0f 8e f2 fd ff ff    	jle    8004bb <vprintfmt+0x26>
				putch(' ', putdat);
  8006c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006cc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006d0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006d7:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006da:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  8006de:	75 e9                	jne    8006c9 <vprintfmt+0x234>
  8006e0:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  8006e3:	e9 d3 fd ff ff       	jmp    8004bb <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006e8:	83 f9 01             	cmp    $0x1,%ecx
  8006eb:	90                   	nop    
  8006ec:	8d 74 26 00          	lea    0x0(%esi),%esi
  8006f0:	7e 10                	jle    800702 <vprintfmt+0x26d>
		return va_arg(*ap, long long);
  8006f2:	8b 55 14             	mov    0x14(%ebp),%edx
  8006f5:	8d 42 08             	lea    0x8(%edx),%eax
  8006f8:	89 45 14             	mov    %eax,0x14(%ebp)
  8006fb:	8b 32                	mov    (%edx),%esi
  8006fd:	8b 7a 04             	mov    0x4(%edx),%edi
  800700:	eb 2a                	jmp    80072c <vprintfmt+0x297>
	else if (lflag)
  800702:	85 c9                	test   %ecx,%ecx
  800704:	74 14                	je     80071a <vprintfmt+0x285>
		return va_arg(*ap, long);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8d 50 04             	lea    0x4(%eax),%edx
  80070c:	89 55 14             	mov    %edx,0x14(%ebp)
  80070f:	8b 00                	mov    (%eax),%eax
  800711:	89 c6                	mov    %eax,%esi
  800713:	89 c7                	mov    %eax,%edi
  800715:	c1 ff 1f             	sar    $0x1f,%edi
  800718:	eb 12                	jmp    80072c <vprintfmt+0x297>
	else
		return va_arg(*ap, int);
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8d 50 04             	lea    0x4(%eax),%edx
  800720:	89 55 14             	mov    %edx,0x14(%ebp)
  800723:	8b 00                	mov    (%eax),%eax
  800725:	89 c6                	mov    %eax,%esi
  800727:	89 c7                	mov    %eax,%edi
  800729:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80072c:	89 f2                	mov    %esi,%edx
  80072e:	89 f9                	mov    %edi,%ecx
  800730:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
			if ((long long) num < 0) {
  800737:	85 ff                	test   %edi,%edi
  800739:	0f 89 9b 00 00 00    	jns    8007da <vprintfmt+0x345>
				putch('-', putdat);
  80073f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800742:	89 44 24 04          	mov    %eax,0x4(%esp)
  800746:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80074d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800750:	89 f2                	mov    %esi,%edx
  800752:	89 f9                	mov    %edi,%ecx
  800754:	f7 da                	neg    %edx
  800756:	83 d1 00             	adc    $0x0,%ecx
  800759:	f7 d9                	neg    %ecx
  80075b:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  800762:	eb 76                	jmp    8007da <vprintfmt+0x345>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800764:	89 ca                	mov    %ecx,%edx
  800766:	8d 45 14             	lea    0x14(%ebp),%eax
  800769:	e8 cd fc ff ff       	call   80043b <getuint>
  80076e:	89 d1                	mov    %edx,%ecx
  800770:	89 c2                	mov    %eax,%edx
  800772:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  800779:	eb 5f                	jmp    8007da <vprintfmt+0x345>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap,lflag);
  80077b:	89 ca                	mov    %ecx,%edx
  80077d:	8d 45 14             	lea    0x14(%ebp),%eax
  800780:	e8 b6 fc ff ff       	call   80043b <getuint>
  800785:	e9 31 fd ff ff       	jmp    8004bb <vprintfmt+0x26>
			base=8;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80078a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80078d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800791:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800798:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80079b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80079e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a2:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007a9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007ac:	8b 55 14             	mov    0x14(%ebp),%edx
  8007af:	8d 42 04             	lea    0x4(%edx),%eax
  8007b2:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b5:	8b 12                	mov    (%edx),%edx
  8007b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007bc:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  8007c3:	eb 15                	jmp    8007da <vprintfmt+0x345>
			base = 16;
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007c5:	89 ca                	mov    %ecx,%edx
  8007c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ca:	e8 6c fc ff ff       	call   80043b <getuint>
  8007cf:	89 d1                	mov    %edx,%ecx
  8007d1:	89 c2                	mov    %eax,%edx
  8007d3:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007da:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  8007de:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007f0:	89 14 24             	mov    %edx,(%esp)
  8007f3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fd:	e8 4e fb ff ff       	call   800350 <printnum>
  800802:	e9 b4 fc ff ff       	jmp    8004bb <vprintfmt+0x26>
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800807:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80080e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800815:	ff 55 08             	call   *0x8(%ebp)
  800818:	e9 9e fc ff ff       	jmp    8004bb <vprintfmt+0x26>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80081d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800820:	89 44 24 04          	mov    %eax,0x4(%esp)
  800824:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80082b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80082e:	83 eb 01             	sub    $0x1,%ebx
  800831:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800835:	0f 84 80 fc ff ff    	je     8004bb <vprintfmt+0x26>
  80083b:	83 eb 01             	sub    $0x1,%ebx
  80083e:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800842:	0f 84 73 fc ff ff    	je     8004bb <vprintfmt+0x26>
  800848:	eb f1                	jmp    80083b <vprintfmt+0x3a6>
				/* do nothing */;
			break;
		}
	}
}
  80084a:	83 c4 3c             	add    $0x3c,%esp
  80084d:	5b                   	pop    %ebx
  80084e:	5e                   	pop    %esi
  80084f:	5f                   	pop    %edi
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	83 ec 28             	sub    $0x28,%esp
  800858:	8b 55 08             	mov    0x8(%ebp),%edx
  80085b:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80085e:	85 d2                	test   %edx,%edx
  800860:	74 04                	je     800866 <vsnprintf+0x14>
  800862:	85 c0                	test   %eax,%eax
  800864:	7f 07                	jg     80086d <vsnprintf+0x1b>
  800866:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80086b:	eb 3b                	jmp    8008a8 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80086d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800874:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
  800878:	89 45 f8             	mov    %eax,-0x8(%ebp)
  80087b:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80087e:	8b 45 14             	mov    0x14(%ebp),%eax
  800881:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800885:	8b 45 10             	mov    0x10(%ebp),%eax
  800888:	89 44 24 08          	mov    %eax,0x8(%esp)
  80088c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80088f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800893:	c7 04 24 77 04 80 00 	movl   $0x800477,(%esp)
  80089a:	e8 f6 fb ff ff       	call   800495 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80089f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008a8:	c9                   	leave  
  8008a9:	c3                   	ret    

008008aa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008b0:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b3:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8008b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8008bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cb:	89 04 24             	mov    %eax,(%esp)
  8008ce:	e8 7f ff ff ff       	call   800852 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008d3:	c9                   	leave  
  8008d4:	c3                   	ret    

008008d5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8008db:	8d 45 14             	lea    0x14(%ebp),%eax
  8008de:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8008e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8008e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f6:	89 04 24             	mov    %eax,(%esp)
  8008f9:	e8 97 fb ff ff       	call   800495 <vprintfmt>
	va_end(ap);
}
  8008fe:	c9                   	leave  
  8008ff:	c3                   	ret    

00800900 <strlen>:
// Primespipe runs 3x faster this way.
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
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800918:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  80091c:	75 f7                	jne    800915 <strlen+0x15>
		n++;
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
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80093a:	39 d0                	cmp    %edx,%eax
  80093c:	74 0d                	je     80094b <strnlen+0x2b>
  80093e:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800942:	74 07                	je     80094b <strnlen+0x2b>
  800944:	eb f1                	jmp    800937 <strnlen+0x17>
  800946:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
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
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800999:	83 c3 01             	add    $0x1,%ebx
  80099c:	39 f3                	cmp    %esi,%ebx
  80099e:	75 eb                	jne    80098b <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
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
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009d0:	83 eb 01             	sub    $0x1,%ebx
  8009d3:	74 0f                	je     8009e4 <strlcpy+0x3d>
  8009d5:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  8009d9:	83 c1 01             	add    $0x1,%ecx
  8009dc:	84 d2                	test   %dl,%dl
  8009de:	74 04                	je     8009e4 <strlcpy+0x3d>
  8009e0:	eb e9                	jmp    8009cb <strlcpy+0x24>
  8009e2:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
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
  8009f0:	56                   	push   %esi
  8009f1:	53                   	push   %ebx
  8009f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f8:	8b 55 10             	mov    0x10(%ebp),%edx
    int c;
    char *q = buf;

    if (buf_size <= 0)
  8009fb:	85 c0                	test   %eax,%eax
  8009fd:	7e 2e                	jle    800a2d <pstrcpy+0x40>
        return;

    for(;;) {
        c = *str++;
  8009ff:	0f b6 0a             	movzbl (%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  800a02:	84 c9                	test   %cl,%cl
  800a04:	74 22                	je     800a28 <pstrcpy+0x3b>
  800a06:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  800a0a:	89 f0                	mov    %esi,%eax
  800a0c:	39 de                	cmp    %ebx,%esi
  800a0e:	72 09                	jb     800a19 <pstrcpy+0x2c>
  800a10:	eb 16                	jmp    800a28 <pstrcpy+0x3b>
  800a12:	83 c2 01             	add    $0x1,%edx
  800a15:	39 d8                	cmp    %ebx,%eax
  800a17:	73 11                	jae    800a2a <pstrcpy+0x3d>
            break;
        *q++ = c;
  800a19:	88 08                	mov    %cl,(%eax)
  800a1b:	83 c0 01             	add    $0x1,%eax

    if (buf_size <= 0)
        return;

    for(;;) {
        c = *str++;
  800a1e:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  800a22:	84 c9                	test   %cl,%cl
  800a24:	75 ec                	jne    800a12 <pstrcpy+0x25>
  800a26:	eb 02                	jmp    800a2a <pstrcpy+0x3d>
  800a28:	89 f0                	mov    %esi,%eax
            break;
        *q++ = c;
    }
    *q = '\0';
  800a2a:	c6 00 00             	movb   $0x0,(%eax)
}
  800a2d:	5b                   	pop    %ebx
  800a2e:	5e                   	pop    %esi
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	8b 55 08             	mov    0x8(%ebp),%edx
  800a37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  800a3a:	0f b6 02             	movzbl (%edx),%eax
  800a3d:	84 c0                	test   %al,%al
  800a3f:	74 16                	je     800a57 <strcmp+0x26>
  800a41:	3a 01                	cmp    (%ecx),%al
  800a43:	75 12                	jne    800a57 <strcmp+0x26>
		p++, q++;
  800a45:	83 c1 01             	add    $0x1,%ecx
    *q = '\0';
}
int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a48:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  800a4c:	84 c0                	test   %al,%al
  800a4e:	74 07                	je     800a57 <strcmp+0x26>
  800a50:	83 c2 01             	add    $0x1,%edx
  800a53:	3a 01                	cmp    (%ecx),%al
  800a55:	74 ee                	je     800a45 <strcmp+0x14>
  800a57:	0f b6 c0             	movzbl %al,%eax
  800a5a:	0f b6 11             	movzbl (%ecx),%edx
  800a5d:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    

00800a61 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	53                   	push   %ebx
  800a65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a68:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a6b:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800a6e:	85 d2                	test   %edx,%edx
  800a70:	74 2d                	je     800a9f <strncmp+0x3e>
  800a72:	0f b6 01             	movzbl (%ecx),%eax
  800a75:	84 c0                	test   %al,%al
  800a77:	74 1a                	je     800a93 <strncmp+0x32>
  800a79:	3a 03                	cmp    (%ebx),%al
  800a7b:	75 16                	jne    800a93 <strncmp+0x32>
  800a7d:	83 ea 01             	sub    $0x1,%edx
  800a80:	74 1d                	je     800a9f <strncmp+0x3e>
		n--, p++, q++;
  800a82:	83 c1 01             	add    $0x1,%ecx
  800a85:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a88:	0f b6 01             	movzbl (%ecx),%eax
  800a8b:	84 c0                	test   %al,%al
  800a8d:	74 04                	je     800a93 <strncmp+0x32>
  800a8f:	3a 03                	cmp    (%ebx),%al
  800a91:	74 ea                	je     800a7d <strncmp+0x1c>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a93:	0f b6 11             	movzbl (%ecx),%edx
  800a96:	0f b6 03             	movzbl (%ebx),%eax
  800a99:	29 c2                	sub    %eax,%edx
  800a9b:	89 d0                	mov    %edx,%eax
  800a9d:	eb 05                	jmp    800aa4 <strncmp+0x43>
  800a9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa4:	5b                   	pop    %ebx
  800aa5:	5d                   	pop    %ebp
  800aa6:	c3                   	ret    

00800aa7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  800aad:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ab1:	0f b6 10             	movzbl (%eax),%edx
  800ab4:	84 d2                	test   %dl,%dl
  800ab6:	74 14                	je     800acc <strchr+0x25>
		if (*s == c)
  800ab8:	38 ca                	cmp    %cl,%dl
  800aba:	75 06                	jne    800ac2 <strchr+0x1b>
  800abc:	eb 13                	jmp    800ad1 <strchr+0x2a>
  800abe:	38 ca                	cmp    %cl,%dl
  800ac0:	74 0f                	je     800ad1 <strchr+0x2a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ac2:	83 c0 01             	add    $0x1,%eax
  800ac5:	0f b6 10             	movzbl (%eax),%edx
  800ac8:	84 d2                	test   %dl,%dl
  800aca:	75 f2                	jne    800abe <strchr+0x17>
  800acc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    

00800ad3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800add:	0f b6 10             	movzbl (%eax),%edx
  800ae0:	84 d2                	test   %dl,%dl
  800ae2:	74 18                	je     800afc <strfind+0x29>
		if (*s == c)
  800ae4:	38 ca                	cmp    %cl,%dl
  800ae6:	75 0a                	jne    800af2 <strfind+0x1f>
  800ae8:	eb 12                	jmp    800afc <strfind+0x29>
  800aea:	38 ca                	cmp    %cl,%dl
  800aec:	8d 74 26 00          	lea    0x0(%esi),%esi
  800af0:	74 0a                	je     800afc <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800af2:	83 c0 01             	add    $0x1,%eax
  800af5:	0f b6 10             	movzbl (%eax),%edx
  800af8:	84 d2                	test   %dl,%dl
  800afa:	75 ee                	jne    800aea <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	83 ec 08             	sub    $0x8,%esp
  800b04:	89 1c 24             	mov    %ebx,(%esp)
  800b07:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b0b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800b11:	85 db                	test   %ebx,%ebx
  800b13:	74 36                	je     800b4b <memset+0x4d>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b15:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b1b:	75 26                	jne    800b43 <memset+0x45>
  800b1d:	f6 c3 03             	test   $0x3,%bl
  800b20:	75 21                	jne    800b43 <memset+0x45>
		c &= 0xFF;
  800b22:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b26:	89 d0                	mov    %edx,%eax
  800b28:	c1 e0 18             	shl    $0x18,%eax
  800b2b:	89 d1                	mov    %edx,%ecx
  800b2d:	c1 e1 10             	shl    $0x10,%ecx
  800b30:	09 c8                	or     %ecx,%eax
  800b32:	09 d0                	or     %edx,%eax
  800b34:	c1 e2 08             	shl    $0x8,%edx
  800b37:	09 d0                	or     %edx,%eax
  800b39:	89 d9                	mov    %ebx,%ecx
  800b3b:	c1 e9 02             	shr    $0x2,%ecx
  800b3e:	fc                   	cld    
  800b3f:	f3 ab                	rep stos %eax,%es:(%edi)
  800b41:	eb 08                	jmp    800b4b <memset+0x4d>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b46:	89 d9                	mov    %ebx,%ecx
  800b48:	fc                   	cld    
  800b49:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b4b:	89 f8                	mov    %edi,%eax
  800b4d:	8b 1c 24             	mov    (%esp),%ebx
  800b50:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b54:	89 ec                	mov    %ebp,%esp
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	83 ec 08             	sub    $0x8,%esp
  800b5e:	89 34 24             	mov    %esi,(%esp)
  800b61:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b65:	8b 45 08             	mov    0x8(%ebp),%eax
  800b68:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800b6b:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b6e:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b70:	39 c6                	cmp    %eax,%esi
  800b72:	73 38                	jae    800bac <memmove+0x54>
  800b74:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b77:	39 d0                	cmp    %edx,%eax
  800b79:	73 31                	jae    800bac <memmove+0x54>
		s += n;
		d += n;
  800b7b:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b7e:	f6 c2 03             	test   $0x3,%dl
  800b81:	75 1d                	jne    800ba0 <memmove+0x48>
  800b83:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b89:	75 15                	jne    800ba0 <memmove+0x48>
  800b8b:	f6 c1 03             	test   $0x3,%cl
  800b8e:	66 90                	xchg   %ax,%ax
  800b90:	75 0e                	jne    800ba0 <memmove+0x48>
			asm volatile("std; rep movsl\n"
  800b92:	8d 7e fc             	lea    -0x4(%esi),%edi
  800b95:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b98:	c1 e9 02             	shr    $0x2,%ecx
  800b9b:	fd                   	std    
  800b9c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b9e:	eb 09                	jmp    800ba9 <memmove+0x51>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ba0:	8d 7e ff             	lea    -0x1(%esi),%edi
  800ba3:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ba6:	fd                   	std    
  800ba7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ba9:	fc                   	cld    
  800baa:	eb 21                	jmp    800bcd <memmove+0x75>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bac:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bb2:	75 16                	jne    800bca <memmove+0x72>
  800bb4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bba:	75 0e                	jne    800bca <memmove+0x72>
  800bbc:	f6 c1 03             	test   $0x3,%cl
  800bbf:	90                   	nop    
  800bc0:	75 08                	jne    800bca <memmove+0x72>
			asm volatile("cld; rep movsl\n"
  800bc2:	c1 e9 02             	shr    $0x2,%ecx
  800bc5:	fc                   	cld    
  800bc6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bc8:	eb 03                	jmp    800bcd <memmove+0x75>
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
  800bf2:	e8 61 ff ff ff       	call   800b58 <memmove>
}
  800bf7:	c9                   	leave  
  800bf8:	c3                   	ret    

00800bf9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
  800bff:	83 ec 04             	sub    $0x4,%esp
  800c02:	8b 45 08             	mov    0x8(%ebp),%eax
  800c05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c08:	8b 55 10             	mov    0x10(%ebp),%edx
  800c0b:	83 ea 01             	sub    $0x1,%edx
  800c0e:	83 fa ff             	cmp    $0xffffffff,%edx
  800c11:	74 47                	je     800c5a <memcmp+0x61>
		if (*s1 != *s2)
  800c13:	0f b6 30             	movzbl (%eax),%esi
  800c16:	0f b6 39             	movzbl (%ecx),%edi
			return (int) *s1 - (int) *s2;
  800c19:	89 45 f0             	mov    %eax,-0x10(%ebp)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  800c1c:	89 f0                	mov    %esi,%eax
  800c1e:	89 fb                	mov    %edi,%ebx
  800c20:	38 d8                	cmp    %bl,%al
  800c22:	74 2e                	je     800c52 <memcmp+0x59>
  800c24:	eb 1c                	jmp    800c42 <memcmp+0x49>
  800c26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c29:	0f b6 70 01          	movzbl 0x1(%eax),%esi
  800c2d:	0f b6 79 01          	movzbl 0x1(%ecx),%edi
  800c31:	83 c0 01             	add    $0x1,%eax
  800c34:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c37:	83 c1 01             	add    $0x1,%ecx
  800c3a:	89 f3                	mov    %esi,%ebx
  800c3c:	89 f8                	mov    %edi,%eax
  800c3e:	38 c3                	cmp    %al,%bl
  800c40:	74 10                	je     800c52 <memcmp+0x59>
			return (int) *s1 - (int) *s2;
  800c42:	89 f1                	mov    %esi,%ecx
  800c44:	0f b6 d1             	movzbl %cl,%edx
  800c47:	89 fb                	mov    %edi,%ebx
  800c49:	0f b6 c3             	movzbl %bl,%eax
  800c4c:	29 c2                	sub    %eax,%edx
  800c4e:	89 d0                	mov    %edx,%eax
  800c50:	eb 0d                	jmp    800c5f <memcmp+0x66>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c52:	83 ea 01             	sub    $0x1,%edx
  800c55:	83 fa ff             	cmp    $0xffffffff,%edx
  800c58:	75 cc                	jne    800c26 <memcmp+0x2d>
  800c5a:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800c5f:	83 c4 04             	add    $0x4,%esp
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c6d:	89 c1                	mov    %eax,%ecx
  800c6f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
  800c72:	39 c8                	cmp    %ecx,%eax
  800c74:	73 15                	jae    800c8b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c76:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
  800c7a:	38 10                	cmp    %dl,(%eax)
  800c7c:	75 06                	jne    800c84 <memfind+0x1d>
  800c7e:	eb 0b                	jmp    800c8b <memfind+0x24>
  800c80:	38 10                	cmp    %dl,(%eax)
  800c82:	74 07                	je     800c8b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c84:	83 c0 01             	add    $0x1,%eax
  800c87:	39 c8                	cmp    %ecx,%eax
  800c89:	75 f5                	jne    800c80 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c8b:	5d                   	pop    %ebp
  800c8c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800c90:	c3                   	ret    

00800c91 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	57                   	push   %edi
  800c95:	56                   	push   %esi
  800c96:	53                   	push   %ebx
  800c97:	83 ec 04             	sub    $0x4,%esp
  800c9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c9d:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca0:	0f b6 01             	movzbl (%ecx),%eax
  800ca3:	3c 20                	cmp    $0x20,%al
  800ca5:	74 04                	je     800cab <strtol+0x1a>
  800ca7:	3c 09                	cmp    $0x9,%al
  800ca9:	75 0e                	jne    800cb9 <strtol+0x28>
		s++;
  800cab:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cae:	0f b6 01             	movzbl (%ecx),%eax
  800cb1:	3c 20                	cmp    $0x20,%al
  800cb3:	74 f6                	je     800cab <strtol+0x1a>
  800cb5:	3c 09                	cmp    $0x9,%al
  800cb7:	74 f2                	je     800cab <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cb9:	3c 2b                	cmp    $0x2b,%al
  800cbb:	75 0c                	jne    800cc9 <strtol+0x38>
		s++;
  800cbd:	83 c1 01             	add    $0x1,%ecx
  800cc0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800cc7:	eb 15                	jmp    800cde <strtol+0x4d>
	else if (*s == '-')
  800cc9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800cd0:	3c 2d                	cmp    $0x2d,%al
  800cd2:	75 0a                	jne    800cde <strtol+0x4d>
		s++, neg = 1;
  800cd4:	83 c1 01             	add    $0x1,%ecx
  800cd7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cde:	85 f6                	test   %esi,%esi
  800ce0:	0f 94 c0             	sete   %al
  800ce3:	74 05                	je     800cea <strtol+0x59>
  800ce5:	83 fe 10             	cmp    $0x10,%esi
  800ce8:	75 18                	jne    800d02 <strtol+0x71>
  800cea:	80 39 30             	cmpb   $0x30,(%ecx)
  800ced:	75 13                	jne    800d02 <strtol+0x71>
  800cef:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cf3:	75 0d                	jne    800d02 <strtol+0x71>
		s += 2, base = 16;
  800cf5:	83 c1 02             	add    $0x2,%ecx
  800cf8:	be 10 00 00 00       	mov    $0x10,%esi
  800cfd:	8d 76 00             	lea    0x0(%esi),%esi
  800d00:	eb 1b                	jmp    800d1d <strtol+0x8c>
	else if (base == 0 && s[0] == '0')
  800d02:	85 f6                	test   %esi,%esi
  800d04:	75 0e                	jne    800d14 <strtol+0x83>
  800d06:	80 39 30             	cmpb   $0x30,(%ecx)
  800d09:	75 09                	jne    800d14 <strtol+0x83>
		s++, base = 8;
  800d0b:	83 c1 01             	add    $0x1,%ecx
  800d0e:	66 be 08 00          	mov    $0x8,%si
  800d12:	eb 09                	jmp    800d1d <strtol+0x8c>
	else if (base == 0)
  800d14:	84 c0                	test   %al,%al
  800d16:	74 05                	je     800d1d <strtol+0x8c>
  800d18:	be 0a 00 00 00       	mov    $0xa,%esi
  800d1d:	bf 00 00 00 00       	mov    $0x0,%edi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d22:	0f b6 11             	movzbl (%ecx),%edx
  800d25:	89 d3                	mov    %edx,%ebx
  800d27:	8d 42 d0             	lea    -0x30(%edx),%eax
  800d2a:	3c 09                	cmp    $0x9,%al
  800d2c:	77 08                	ja     800d36 <strtol+0xa5>
			dig = *s - '0';
  800d2e:	0f be c2             	movsbl %dl,%eax
  800d31:	8d 50 d0             	lea    -0x30(%eax),%edx
  800d34:	eb 1c                	jmp    800d52 <strtol+0xc1>
		else if (*s >= 'a' && *s <= 'z')
  800d36:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800d39:	3c 19                	cmp    $0x19,%al
  800d3b:	77 08                	ja     800d45 <strtol+0xb4>
			dig = *s - 'a' + 10;
  800d3d:	0f be c2             	movsbl %dl,%eax
  800d40:	8d 50 a9             	lea    -0x57(%eax),%edx
  800d43:	eb 0d                	jmp    800d52 <strtol+0xc1>
		else if (*s >= 'A' && *s <= 'Z')
  800d45:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800d48:	3c 19                	cmp    $0x19,%al
  800d4a:	77 17                	ja     800d63 <strtol+0xd2>
			dig = *s - 'A' + 10;
  800d4c:	0f be c2             	movsbl %dl,%eax
  800d4f:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800d52:	39 f2                	cmp    %esi,%edx
  800d54:	7d 0d                	jge    800d63 <strtol+0xd2>
			break;
		s++, val = (val * base) + dig;
  800d56:	83 c1 01             	add    $0x1,%ecx
  800d59:	89 f8                	mov    %edi,%eax
  800d5b:	0f af c6             	imul   %esi,%eax
  800d5e:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800d61:	eb bf                	jmp    800d22 <strtol+0x91>
		// we don't properly detect overflow!
	}
  800d63:	89 f8                	mov    %edi,%eax

	if (endptr)
  800d65:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d69:	74 05                	je     800d70 <strtol+0xdf>
		*endptr = (char *) s;
  800d6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d6e:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800d70:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800d74:	74 04                	je     800d7a <strtol+0xe9>
  800d76:	89 c7                	mov    %eax,%edi
  800d78:	f7 df                	neg    %edi
}
  800d7a:	89 f8                	mov    %edi,%eax
  800d7c:	83 c4 04             	add    $0x4,%esp
  800d7f:	5b                   	pop    %ebx
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	83 ec 0c             	sub    $0xc,%esp
  800d8a:	89 1c 24             	mov    %ebx,(%esp)
  800d8d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d91:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d95:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9a:	bf 00 00 00 00       	mov    $0x0,%edi
  800d9f:	89 fa                	mov    %edi,%edx
  800da1:	89 f9                	mov    %edi,%ecx
  800da3:	89 fb                	mov    %edi,%ebx
  800da5:	89 fe                	mov    %edi,%esi
  800da7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800da9:	8b 1c 24             	mov    (%esp),%ebx
  800dac:	8b 74 24 04          	mov    0x4(%esp),%esi
  800db0:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800db4:	89 ec                	mov    %ebp,%esp
  800db6:	5d                   	pop    %ebp
  800db7:	c3                   	ret    

00800db8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
  800dbb:	83 ec 0c             	sub    $0xc,%esp
  800dbe:	89 1c 24             	mov    %ebx,(%esp)
  800dc1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dc5:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800dc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcf:	bf 00 00 00 00       	mov    $0x0,%edi
  800dd4:	89 f8                	mov    %edi,%eax
  800dd6:	89 fb                	mov    %edi,%ebx
  800dd8:	89 fe                	mov    %edi,%esi
  800dda:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ddc:	8b 1c 24             	mov    (%esp),%ebx
  800ddf:	8b 74 24 04          	mov    0x4(%esp),%esi
  800de3:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800de7:	89 ec                	mov    %ebp,%esp
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	83 ec 0c             	sub    $0xc,%esp
  800df1:	89 1c 24             	mov    %ebx,(%esp)
  800df4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800df8:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfc:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e01:	bf 00 00 00 00       	mov    $0x0,%edi
  800e06:	89 fa                	mov    %edi,%edx
  800e08:	89 f9                	mov    %edi,%ecx
  800e0a:	89 fb                	mov    %edi,%ebx
  800e0c:	89 fe                	mov    %edi,%esi
  800e0e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e10:	8b 1c 24             	mov    (%esp),%ebx
  800e13:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e17:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e1b:	89 ec                	mov    %ebp,%esp
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    

00800e1f <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	83 ec 28             	sub    $0x28,%esp
  800e25:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e28:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e2b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e2e:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e31:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e36:	bf 00 00 00 00       	mov    $0x0,%edi
  800e3b:	89 f9                	mov    %edi,%ecx
  800e3d:	89 fb                	mov    %edi,%ebx
  800e3f:	89 fe                	mov    %edi,%esi
  800e41:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800e43:	85 c0                	test   %eax,%eax
  800e45:	7e 28                	jle    800e6f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e47:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4b:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e52:	00 
  800e53:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800e5a:	00 
  800e5b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e62:	00 
  800e63:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800e6a:	e8 ed 10 00 00       	call   801f5c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e6f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e72:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e75:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e78:	89 ec                	mov    %ebp,%esp
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    

00800e7c <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	83 ec 0c             	sub    $0xc,%esp
  800e82:	89 1c 24             	mov    %ebx,(%esp)
  800e85:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e89:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e93:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e96:	8b 7d 14             	mov    0x14(%ebp),%edi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e99:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e9e:	be 00 00 00 00       	mov    $0x0,%esi
  800ea3:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ea5:	8b 1c 24             	mov    (%esp),%ebx
  800ea8:	8b 74 24 04          	mov    0x4(%esp),%esi
  800eac:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800eb0:	89 ec                	mov    %ebp,%esp
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    

00800eb4 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	83 ec 28             	sub    $0x28,%esp
  800eba:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ebd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ec0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ec3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ece:	bf 00 00 00 00       	mov    $0x0,%edi
  800ed3:	89 fb                	mov    %edi,%ebx
  800ed5:	89 fe                	mov    %edi,%esi
  800ed7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800ed9:	85 c0                	test   %eax,%eax
  800edb:	7e 28                	jle    800f05 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800edd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee1:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ee8:	00 
  800ee9:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800ef0:	00 
  800ef1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef8:	00 
  800ef9:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800f00:	e8 57 10 00 00       	call   801f5c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f05:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f08:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f0b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f0e:	89 ec                	mov    %ebp,%esp
  800f10:	5d                   	pop    %ebp
  800f11:	c3                   	ret    

00800f12 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f12:	55                   	push   %ebp
  800f13:	89 e5                	mov    %esp,%ebp
  800f15:	83 ec 28             	sub    $0x28,%esp
  800f18:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f1b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f1e:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f21:	8b 55 08             	mov    0x8(%ebp),%edx
  800f24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f27:	b8 09 00 00 00       	mov    $0x9,%eax
  800f2c:	bf 00 00 00 00       	mov    $0x0,%edi
  800f31:	89 fb                	mov    %edi,%ebx
  800f33:	89 fe                	mov    %edi,%esi
  800f35:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f37:	85 c0                	test   %eax,%eax
  800f39:	7e 28                	jle    800f63 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f3b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f3f:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f46:	00 
  800f47:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800f4e:	00 
  800f4f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f56:	00 
  800f57:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800f5e:	e8 f9 0f 00 00       	call   801f5c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f63:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f66:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f69:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f6c:	89 ec                	mov    %ebp,%esp
  800f6e:	5d                   	pop    %ebp
  800f6f:	c3                   	ret    

00800f70 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	83 ec 28             	sub    $0x28,%esp
  800f76:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f79:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f7c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f85:	b8 08 00 00 00       	mov    $0x8,%eax
  800f8a:	bf 00 00 00 00       	mov    $0x0,%edi
  800f8f:	89 fb                	mov    %edi,%ebx
  800f91:	89 fe                	mov    %edi,%esi
  800f93:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f95:	85 c0                	test   %eax,%eax
  800f97:	7e 28                	jle    800fc1 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f99:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f9d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800fa4:	00 
  800fa5:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800fac:	00 
  800fad:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fb4:	00 
  800fb5:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800fbc:	e8 9b 0f 00 00       	call   801f5c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fc1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fc4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fc7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fca:	89 ec                	mov    %ebp,%esp
  800fcc:	5d                   	pop    %ebp
  800fcd:	c3                   	ret    

00800fce <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	83 ec 28             	sub    $0x28,%esp
  800fd4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fd7:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fda:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800fdd:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe3:	b8 06 00 00 00       	mov    $0x6,%eax
  800fe8:	bf 00 00 00 00       	mov    $0x0,%edi
  800fed:	89 fb                	mov    %edi,%ebx
  800fef:	89 fe                	mov    %edi,%esi
  800ff1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	7e 28                	jle    80101f <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ffb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801002:	00 
  801003:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  80100a:	00 
  80100b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801012:	00 
  801013:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  80101a:	e8 3d 0f 00 00       	call   801f5c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80101f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801022:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801025:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801028:	89 ec                	mov    %ebp,%esp
  80102a:	5d                   	pop    %ebp
  80102b:	c3                   	ret    

0080102c <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	83 ec 28             	sub    $0x28,%esp
  801032:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801035:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801038:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80103b:	8b 55 08             	mov    0x8(%ebp),%edx
  80103e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801041:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801044:	8b 7d 14             	mov    0x14(%ebp),%edi
  801047:	8b 75 18             	mov    0x18(%ebp),%esi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80104a:	b8 05 00 00 00       	mov    $0x5,%eax
  80104f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801051:	85 c0                	test   %eax,%eax
  801053:	7e 28                	jle    80107d <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801055:	89 44 24 10          	mov    %eax,0x10(%esp)
  801059:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801060:	00 
  801061:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  801068:	00 
  801069:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801070:	00 
  801071:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  801078:	e8 df 0e 00 00       	call   801f5c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80107d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801080:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801083:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801086:	89 ec                	mov    %ebp,%esp
  801088:	5d                   	pop    %ebp
  801089:	c3                   	ret    

0080108a <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80108a:	55                   	push   %ebp
  80108b:	89 e5                	mov    %esp,%ebp
  80108d:	83 ec 28             	sub    $0x28,%esp
  801090:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801093:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801096:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801099:	8b 55 08             	mov    0x8(%ebp),%edx
  80109c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80109f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010a2:	b8 04 00 00 00       	mov    $0x4,%eax
  8010a7:	bf 00 00 00 00       	mov    $0x0,%edi
  8010ac:	89 fe                	mov    %edi,%esi
  8010ae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8010b0:	85 c0                	test   %eax,%eax
  8010b2:	7e 28                	jle    8010dc <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010b8:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8010bf:	00 
  8010c0:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  8010c7:	00 
  8010c8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010cf:	00 
  8010d0:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  8010d7:	e8 80 0e 00 00       	call   801f5c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010dc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010df:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010e2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010e5:	89 ec                	mov    %ebp,%esp
  8010e7:	5d                   	pop    %ebp
  8010e8:	c3                   	ret    

008010e9 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	83 ec 0c             	sub    $0xc,%esp
  8010ef:	89 1c 24             	mov    %ebx,(%esp)
  8010f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010f6:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010fa:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010ff:	bf 00 00 00 00       	mov    $0x0,%edi
  801104:	89 fa                	mov    %edi,%edx
  801106:	89 f9                	mov    %edi,%ecx
  801108:	89 fb                	mov    %edi,%ebx
  80110a:	89 fe                	mov    %edi,%esi
  80110c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80110e:	8b 1c 24             	mov    (%esp),%ebx
  801111:	8b 74 24 04          	mov    0x4(%esp),%esi
  801115:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801119:	89 ec                	mov    %ebp,%esp
  80111b:	5d                   	pop    %ebp
  80111c:	c3                   	ret    

0080111d <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  80111d:	55                   	push   %ebp
  80111e:	89 e5                	mov    %esp,%ebp
  801120:	83 ec 0c             	sub    $0xc,%esp
  801123:	89 1c 24             	mov    %ebx,(%esp)
  801126:	89 74 24 04          	mov    %esi,0x4(%esp)
  80112a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80112e:	b8 02 00 00 00       	mov    $0x2,%eax
  801133:	bf 00 00 00 00       	mov    $0x0,%edi
  801138:	89 fa                	mov    %edi,%edx
  80113a:	89 f9                	mov    %edi,%ecx
  80113c:	89 fb                	mov    %edi,%ebx
  80113e:	89 fe                	mov    %edi,%esi
  801140:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801142:	8b 1c 24             	mov    (%esp),%ebx
  801145:	8b 74 24 04          	mov    0x4(%esp),%esi
  801149:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80114d:	89 ec                	mov    %ebp,%esp
  80114f:	5d                   	pop    %ebp
  801150:	c3                   	ret    

00801151 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801151:	55                   	push   %ebp
  801152:	89 e5                	mov    %esp,%ebp
  801154:	83 ec 28             	sub    $0x28,%esp
  801157:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80115a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80115d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801160:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801163:	b8 03 00 00 00       	mov    $0x3,%eax
  801168:	bf 00 00 00 00       	mov    $0x0,%edi
  80116d:	89 f9                	mov    %edi,%ecx
  80116f:	89 fb                	mov    %edi,%ebx
  801171:	89 fe                	mov    %edi,%esi
  801173:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801175:	85 c0                	test   %eax,%eax
  801177:	7e 28                	jle    8011a1 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801179:	89 44 24 10          	mov    %eax,0x10(%esp)
  80117d:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801184:	00 
  801185:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  80118c:	00 
  80118d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801194:	00 
  801195:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  80119c:	e8 bb 0d 00 00       	call   801f5c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8011a1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011a4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011a7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011aa:	89 ec                	mov    %ebp,%esp
  8011ac:	5d                   	pop    %ebp
  8011ad:	c3                   	ret    
	...

008011b0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
  8011b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011bb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8011be:	5d                   	pop    %ebp
  8011bf:	c3                   	ret    

008011c0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8011c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c9:	89 04 24             	mov    %eax,(%esp)
  8011cc:	e8 df ff ff ff       	call   8011b0 <fd2num>
  8011d1:	c1 e0 0c             	shl    $0xc,%eax
  8011d4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011d9:	c9                   	leave  
  8011da:	c3                   	ret    

008011db <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	53                   	push   %ebx
  8011df:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8011e2:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  8011e7:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  8011e9:	89 d0                	mov    %edx,%eax
  8011eb:	c1 e8 16             	shr    $0x16,%eax
  8011ee:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011f5:	a8 01                	test   $0x1,%al
  8011f7:	74 10                	je     801209 <fd_alloc+0x2e>
  8011f9:	89 d0                	mov    %edx,%eax
  8011fb:	c1 e8 0c             	shr    $0xc,%eax
  8011fe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801205:	a8 01                	test   $0x1,%al
  801207:	75 09                	jne    801212 <fd_alloc+0x37>
			*fd_store = fd;
  801209:	89 0b                	mov    %ecx,(%ebx)
  80120b:	b8 00 00 00 00       	mov    $0x0,%eax
  801210:	eb 19                	jmp    80122b <fd_alloc+0x50>
			return 0;
  801212:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801218:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  80121e:	75 c7                	jne    8011e7 <fd_alloc+0xc>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801220:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801226:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  80122b:	5b                   	pop    %ebx
  80122c:	5d                   	pop    %ebp
  80122d:	c3                   	ret    

0080122e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801231:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  801235:	77 38                	ja     80126f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801237:	8b 45 08             	mov    0x8(%ebp),%eax
  80123a:	c1 e0 0c             	shl    $0xc,%eax
  80123d:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  801243:	89 d0                	mov    %edx,%eax
  801245:	c1 e8 16             	shr    $0x16,%eax
  801248:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80124f:	a8 01                	test   $0x1,%al
  801251:	74 1c                	je     80126f <fd_lookup+0x41>
  801253:	89 d0                	mov    %edx,%eax
  801255:	c1 e8 0c             	shr    $0xc,%eax
  801258:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80125f:	a8 01                	test   $0x1,%al
  801261:	74 0c                	je     80126f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801263:	8b 45 0c             	mov    0xc(%ebp),%eax
  801266:	89 10                	mov    %edx,(%eax)
  801268:	b8 00 00 00 00       	mov    $0x0,%eax
  80126d:	eb 05                	jmp    801274 <fd_lookup+0x46>
	return 0;
  80126f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801274:	5d                   	pop    %ebp
  801275:	c3                   	ret    

00801276 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801276:	55                   	push   %ebp
  801277:	89 e5                	mov    %esp,%ebp
  801279:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80127c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80127f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801283:	8b 45 08             	mov    0x8(%ebp),%eax
  801286:	89 04 24             	mov    %eax,(%esp)
  801289:	e8 a0 ff ff ff       	call   80122e <fd_lookup>
  80128e:	85 c0                	test   %eax,%eax
  801290:	78 0e                	js     8012a0 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801292:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801295:	8b 55 0c             	mov    0xc(%ebp),%edx
  801298:	89 50 04             	mov    %edx,0x4(%eax)
  80129b:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8012a0:	c9                   	leave  
  8012a1:	c3                   	ret    

008012a2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
  8012a5:	53                   	push   %ebx
  8012a6:	83 ec 14             	sub    $0x14,%esp
  8012a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8012af:	ba 04 60 80 00       	mov    $0x806004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8012b4:	b8 00 00 00 00       	mov    $0x0,%eax
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8012b9:	39 0d 04 60 80 00    	cmp    %ecx,0x806004
  8012bf:	75 11                	jne    8012d2 <dev_lookup+0x30>
  8012c1:	eb 04                	jmp    8012c7 <dev_lookup+0x25>
  8012c3:	39 0a                	cmp    %ecx,(%edx)
  8012c5:	75 0b                	jne    8012d2 <dev_lookup+0x30>
			*dev = devtab[i];
  8012c7:	89 13                	mov    %edx,(%ebx)
  8012c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ce:	66 90                	xchg   %ax,%ax
  8012d0:	eb 35                	jmp    801307 <dev_lookup+0x65>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012d2:	83 c0 01             	add    $0x1,%eax
  8012d5:	8b 14 85 4c 2c 80 00 	mov    0x802c4c(,%eax,4),%edx
  8012dc:	85 d2                	test   %edx,%edx
  8012de:	75 e3                	jne    8012c3 <dev_lookup+0x21>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  8012e0:	a1 4c 60 80 00       	mov    0x80604c,%eax
  8012e5:	8b 40 4c             	mov    0x4c(%eax),%eax
  8012e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f0:	c7 04 24 cc 2b 80 00 	movl   $0x802bcc,(%esp)
  8012f7:	e8 e9 ef ff ff       	call   8002e5 <cprintf>
	*dev = 0;
  8012fc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801302:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801307:	83 c4 14             	add    $0x14,%esp
  80130a:	5b                   	pop    %ebx
  80130b:	5d                   	pop    %ebp
  80130c:	c3                   	ret    

0080130d <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80130d:	55                   	push   %ebp
  80130e:	89 e5                	mov    %esp,%ebp
  801310:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801313:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801316:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131a:	8b 45 08             	mov    0x8(%ebp),%eax
  80131d:	89 04 24             	mov    %eax,(%esp)
  801320:	e8 09 ff ff ff       	call   80122e <fd_lookup>
  801325:	89 c2                	mov    %eax,%edx
  801327:	85 c0                	test   %eax,%eax
  801329:	78 5a                	js     801385 <fstat+0x78>
  80132b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80132e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801332:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801335:	8b 00                	mov    (%eax),%eax
  801337:	89 04 24             	mov    %eax,(%esp)
  80133a:	e8 63 ff ff ff       	call   8012a2 <dev_lookup>
  80133f:	89 c2                	mov    %eax,%edx
  801341:	85 c0                	test   %eax,%eax
  801343:	78 40                	js     801385 <fstat+0x78>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801345:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  80134a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80134d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801351:	74 32                	je     801385 <fstat+0x78>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801353:	8b 45 0c             	mov    0xc(%ebp),%eax
  801356:	c6 00 00             	movb   $0x0,(%eax)
	stat->st_size = 0;
  801359:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  801360:	00 00 00 
	stat->st_isdir = 0;
  801363:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
  80136a:	00 00 00 
	stat->st_dev = dev;
  80136d:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801370:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
	return (*dev->dev_stat)(fd, stat);
  801376:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80137d:	89 04 24             	mov    %eax,(%esp)
  801380:	ff 52 14             	call   *0x14(%edx)
  801383:	89 c2                	mov    %eax,%edx
}
  801385:	89 d0                	mov    %edx,%eax
  801387:	c9                   	leave  
  801388:	c3                   	ret    

00801389 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801389:	55                   	push   %ebp
  80138a:	89 e5                	mov    %esp,%ebp
  80138c:	53                   	push   %ebx
  80138d:	83 ec 24             	sub    $0x24,%esp
  801390:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801393:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801396:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139a:	89 1c 24             	mov    %ebx,(%esp)
  80139d:	e8 8c fe ff ff       	call   80122e <fd_lookup>
  8013a2:	85 c0                	test   %eax,%eax
  8013a4:	78 61                	js     801407 <ftruncate+0x7e>
  8013a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013a9:	8b 10                	mov    (%eax),%edx
  8013ab:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8013ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b2:	89 14 24             	mov    %edx,(%esp)
  8013b5:	e8 e8 fe ff ff       	call   8012a2 <dev_lookup>
  8013ba:	85 c0                	test   %eax,%eax
  8013bc:	78 49                	js     801407 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013be:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  8013c1:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  8013c5:	75 23                	jne    8013ea <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013c7:	a1 4c 60 80 00       	mov    0x80604c,%eax
  8013cc:	8b 40 4c             	mov    0x4c(%eax),%eax
  8013cf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d7:	c7 04 24 ec 2b 80 00 	movl   $0x802bec,(%esp)
  8013de:	e8 02 ef ff ff       	call   8002e5 <cprintf>
  8013e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013e8:	eb 1d                	jmp    801407 <ftruncate+0x7e>
			env->env_id, fdnum); 
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8013ea:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8013ed:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013f2:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  8013f6:	74 0f                	je     801407 <ftruncate+0x7e>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013f8:	8b 42 18             	mov    0x18(%edx),%eax
  8013fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  801402:	89 0c 24             	mov    %ecx,(%esp)
  801405:	ff d0                	call   *%eax
}
  801407:	83 c4 24             	add    $0x24,%esp
  80140a:	5b                   	pop    %ebx
  80140b:	5d                   	pop    %ebp
  80140c:	c3                   	ret    

0080140d <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80140d:	55                   	push   %ebp
  80140e:	89 e5                	mov    %esp,%ebp
  801410:	53                   	push   %ebx
  801411:	83 ec 24             	sub    $0x24,%esp
  801414:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801417:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80141a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141e:	89 1c 24             	mov    %ebx,(%esp)
  801421:	e8 08 fe ff ff       	call   80122e <fd_lookup>
  801426:	85 c0                	test   %eax,%eax
  801428:	78 68                	js     801492 <write+0x85>
  80142a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80142d:	8b 10                	mov    (%eax),%edx
  80142f:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801432:	89 44 24 04          	mov    %eax,0x4(%esp)
  801436:	89 14 24             	mov    %edx,(%esp)
  801439:	e8 64 fe ff ff       	call   8012a2 <dev_lookup>
  80143e:	85 c0                	test   %eax,%eax
  801440:	78 50                	js     801492 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801442:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801445:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801449:	75 23                	jne    80146e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  80144b:	a1 4c 60 80 00       	mov    0x80604c,%eax
  801450:	8b 40 4c             	mov    0x4c(%eax),%eax
  801453:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801457:	89 44 24 04          	mov    %eax,0x4(%esp)
  80145b:	c7 04 24 10 2c 80 00 	movl   $0x802c10,(%esp)
  801462:	e8 7e ee ff ff       	call   8002e5 <cprintf>
  801467:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80146c:	eb 24                	jmp    801492 <write+0x85>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80146e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801471:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801476:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  80147a:	74 16                	je     801492 <write+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80147c:	8b 42 0c             	mov    0xc(%edx),%eax
  80147f:	8b 55 10             	mov    0x10(%ebp),%edx
  801482:	89 54 24 08          	mov    %edx,0x8(%esp)
  801486:	8b 55 0c             	mov    0xc(%ebp),%edx
  801489:	89 54 24 04          	mov    %edx,0x4(%esp)
  80148d:	89 0c 24             	mov    %ecx,(%esp)
  801490:	ff d0                	call   *%eax
}
  801492:	83 c4 24             	add    $0x24,%esp
  801495:	5b                   	pop    %ebx
  801496:	5d                   	pop    %ebp
  801497:	c3                   	ret    

00801498 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801498:	55                   	push   %ebp
  801499:	89 e5                	mov    %esp,%ebp
  80149b:	53                   	push   %ebx
  80149c:	83 ec 24             	sub    $0x24,%esp
  80149f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a9:	89 1c 24             	mov    %ebx,(%esp)
  8014ac:	e8 7d fd ff ff       	call   80122e <fd_lookup>
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	78 6d                	js     801522 <read+0x8a>
  8014b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b8:	8b 10                	mov    (%eax),%edx
  8014ba:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8014bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c1:	89 14 24             	mov    %edx,(%esp)
  8014c4:	e8 d9 fd ff ff       	call   8012a2 <dev_lookup>
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	78 55                	js     801522 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014cd:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  8014d0:	8b 41 08             	mov    0x8(%ecx),%eax
  8014d3:	83 e0 03             	and    $0x3,%eax
  8014d6:	83 f8 01             	cmp    $0x1,%eax
  8014d9:	75 23                	jne    8014fe <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  8014db:	a1 4c 60 80 00       	mov    0x80604c,%eax
  8014e0:	8b 40 4c             	mov    0x4c(%eax),%eax
  8014e3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014eb:	c7 04 24 2d 2c 80 00 	movl   $0x802c2d,(%esp)
  8014f2:	e8 ee ed ff ff       	call   8002e5 <cprintf>
  8014f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014fc:	eb 24                	jmp    801522 <read+0x8a>
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8014fe:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801501:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801506:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  80150a:	74 16                	je     801522 <read+0x8a>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80150c:	8b 42 08             	mov    0x8(%edx),%eax
  80150f:	8b 55 10             	mov    0x10(%ebp),%edx
  801512:	89 54 24 08          	mov    %edx,0x8(%esp)
  801516:	8b 55 0c             	mov    0xc(%ebp),%edx
  801519:	89 54 24 04          	mov    %edx,0x4(%esp)
  80151d:	89 0c 24             	mov    %ecx,(%esp)
  801520:	ff d0                	call   *%eax
}
  801522:	83 c4 24             	add    $0x24,%esp
  801525:	5b                   	pop    %ebx
  801526:	5d                   	pop    %ebp
  801527:	c3                   	ret    

00801528 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801528:	55                   	push   %ebp
  801529:	89 e5                	mov    %esp,%ebp
  80152b:	57                   	push   %edi
  80152c:	56                   	push   %esi
  80152d:	53                   	push   %ebx
  80152e:	83 ec 0c             	sub    $0xc,%esp
  801531:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801534:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801537:	b8 00 00 00 00       	mov    $0x0,%eax
  80153c:	85 f6                	test   %esi,%esi
  80153e:	74 36                	je     801576 <readn+0x4e>
  801540:	bb 00 00 00 00       	mov    $0x0,%ebx
  801545:	ba 00 00 00 00       	mov    $0x0,%edx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80154a:	89 f0                	mov    %esi,%eax
  80154c:	29 d0                	sub    %edx,%eax
  80154e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801552:	8d 04 17             	lea    (%edi,%edx,1),%eax
  801555:	89 44 24 04          	mov    %eax,0x4(%esp)
  801559:	8b 45 08             	mov    0x8(%ebp),%eax
  80155c:	89 04 24             	mov    %eax,(%esp)
  80155f:	e8 34 ff ff ff       	call   801498 <read>
		if (m < 0)
  801564:	85 c0                	test   %eax,%eax
  801566:	78 0e                	js     801576 <readn+0x4e>
			return m;
		if (m == 0)
  801568:	85 c0                	test   %eax,%eax
  80156a:	74 08                	je     801574 <readn+0x4c>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80156c:	01 c3                	add    %eax,%ebx
  80156e:	89 da                	mov    %ebx,%edx
  801570:	39 f3                	cmp    %esi,%ebx
  801572:	72 d6                	jb     80154a <readn+0x22>
  801574:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801576:	83 c4 0c             	add    $0xc,%esp
  801579:	5b                   	pop    %ebx
  80157a:	5e                   	pop    %esi
  80157b:	5f                   	pop    %edi
  80157c:	5d                   	pop    %ebp
  80157d:	c3                   	ret    

0080157e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80157e:	55                   	push   %ebp
  80157f:	89 e5                	mov    %esp,%ebp
  801581:	83 ec 28             	sub    $0x28,%esp
  801584:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801587:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80158a:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80158d:	89 34 24             	mov    %esi,(%esp)
  801590:	e8 1b fc ff ff       	call   8011b0 <fd2num>
  801595:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801598:	89 54 24 04          	mov    %edx,0x4(%esp)
  80159c:	89 04 24             	mov    %eax,(%esp)
  80159f:	e8 8a fc ff ff       	call   80122e <fd_lookup>
  8015a4:	89 c3                	mov    %eax,%ebx
  8015a6:	85 c0                	test   %eax,%eax
  8015a8:	78 05                	js     8015af <fd_close+0x31>
  8015aa:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015ad:	74 0d                	je     8015bc <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8015af:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8015b3:	75 44                	jne    8015f9 <fd_close+0x7b>
  8015b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015ba:	eb 3d                	jmp    8015f9 <fd_close+0x7b>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c3:	8b 06                	mov    (%esi),%eax
  8015c5:	89 04 24             	mov    %eax,(%esp)
  8015c8:	e8 d5 fc ff ff       	call   8012a2 <dev_lookup>
  8015cd:	89 c3                	mov    %eax,%ebx
  8015cf:	85 c0                	test   %eax,%eax
  8015d1:	78 16                	js     8015e9 <fd_close+0x6b>
		if (dev->dev_close)
  8015d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d6:	8b 40 10             	mov    0x10(%eax),%eax
  8015d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015de:	85 c0                	test   %eax,%eax
  8015e0:	74 07                	je     8015e9 <fd_close+0x6b>
			r = (*dev->dev_close)(fd);
  8015e2:	89 34 24             	mov    %esi,(%esp)
  8015e5:	ff d0                	call   *%eax
  8015e7:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015f4:	e8 d5 f9 ff ff       	call   800fce <sys_page_unmap>
	return r;
}
  8015f9:	89 d8                	mov    %ebx,%eax
  8015fb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8015fe:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801601:	89 ec                	mov    %ebp,%esp
  801603:	5d                   	pop    %ebp
  801604:	c3                   	ret    

00801605 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801605:	55                   	push   %ebp
  801606:	89 e5                	mov    %esp,%ebp
  801608:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80160b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80160e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801612:	8b 45 08             	mov    0x8(%ebp),%eax
  801615:	89 04 24             	mov    %eax,(%esp)
  801618:	e8 11 fc ff ff       	call   80122e <fd_lookup>
  80161d:	85 c0                	test   %eax,%eax
  80161f:	78 13                	js     801634 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801621:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801628:	00 
  801629:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80162c:	89 04 24             	mov    %eax,(%esp)
  80162f:	e8 4a ff ff ff       	call   80157e <fd_close>
}
  801634:	c9                   	leave  
  801635:	c3                   	ret    

00801636 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
  801639:	83 ec 18             	sub    $0x18,%esp
  80163c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80163f:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801642:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801649:	00 
  80164a:	8b 45 08             	mov    0x8(%ebp),%eax
  80164d:	89 04 24             	mov    %eax,(%esp)
  801650:	e8 5a 03 00 00       	call   8019af <open>
  801655:	89 c6                	mov    %eax,%esi
  801657:	85 c0                	test   %eax,%eax
  801659:	78 1b                	js     801676 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  80165b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80165e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801662:	89 34 24             	mov    %esi,(%esp)
  801665:	e8 a3 fc ff ff       	call   80130d <fstat>
  80166a:	89 c3                	mov    %eax,%ebx
	close(fd);
  80166c:	89 34 24             	mov    %esi,(%esp)
  80166f:	e8 91 ff ff ff       	call   801605 <close>
  801674:	89 de                	mov    %ebx,%esi
	return r;
}
  801676:	89 f0                	mov    %esi,%eax
  801678:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80167b:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80167e:	89 ec                	mov    %ebp,%esp
  801680:	5d                   	pop    %ebp
  801681:	c3                   	ret    

00801682 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	83 ec 38             	sub    $0x38,%esp
  801688:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80168b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80168e:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801691:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801694:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801697:	89 44 24 04          	mov    %eax,0x4(%esp)
  80169b:	8b 45 08             	mov    0x8(%ebp),%eax
  80169e:	89 04 24             	mov    %eax,(%esp)
  8016a1:	e8 88 fb ff ff       	call   80122e <fd_lookup>
  8016a6:	89 c3                	mov    %eax,%ebx
  8016a8:	85 c0                	test   %eax,%eax
  8016aa:	0f 88 e1 00 00 00    	js     801791 <dup+0x10f>
		return r;
	close(newfdnum);
  8016b0:	89 3c 24             	mov    %edi,(%esp)
  8016b3:	e8 4d ff ff ff       	call   801605 <close>

	newfd = INDEX2FD(newfdnum);
  8016b8:	89 f8                	mov    %edi,%eax
  8016ba:	c1 e0 0c             	shl    $0xc,%eax
  8016bd:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  8016c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c6:	89 04 24             	mov    %eax,(%esp)
  8016c9:	e8 f2 fa ff ff       	call   8011c0 <fd2data>
  8016ce:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8016d0:	89 34 24             	mov    %esi,(%esp)
  8016d3:	e8 e8 fa ff ff       	call   8011c0 <fd2data>
  8016d8:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  8016db:	89 d8                	mov    %ebx,%eax
  8016dd:	c1 e8 16             	shr    $0x16,%eax
  8016e0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016e7:	a8 01                	test   $0x1,%al
  8016e9:	74 45                	je     801730 <dup+0xae>
  8016eb:	89 da                	mov    %ebx,%edx
  8016ed:	c1 ea 0c             	shr    $0xc,%edx
  8016f0:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8016f7:	a8 01                	test   $0x1,%al
  8016f9:	74 35                	je     801730 <dup+0xae>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  8016fb:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801702:	25 07 0e 00 00       	and    $0xe07,%eax
  801707:	89 44 24 10          	mov    %eax,0x10(%esp)
  80170b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80170e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801712:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801719:	00 
  80171a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80171e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801725:	e8 02 f9 ff ff       	call   80102c <sys_page_map>
  80172a:	89 c3                	mov    %eax,%ebx
  80172c:	85 c0                	test   %eax,%eax
  80172e:	78 3e                	js     80176e <dup+0xec>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  801730:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801733:	89 d0                	mov    %edx,%eax
  801735:	c1 e8 0c             	shr    $0xc,%eax
  801738:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80173f:	25 07 0e 00 00       	and    $0xe07,%eax
  801744:	89 44 24 10          	mov    %eax,0x10(%esp)
  801748:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80174c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801753:	00 
  801754:	89 54 24 04          	mov    %edx,0x4(%esp)
  801758:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80175f:	e8 c8 f8 ff ff       	call   80102c <sys_page_map>
  801764:	89 c3                	mov    %eax,%ebx
  801766:	85 c0                	test   %eax,%eax
  801768:	78 04                	js     80176e <dup+0xec>
		goto err;
  80176a:	89 fb                	mov    %edi,%ebx
  80176c:	eb 23                	jmp    801791 <dup+0x10f>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80176e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801772:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801779:	e8 50 f8 ff ff       	call   800fce <sys_page_unmap>
	sys_page_unmap(0, nva);
  80177e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801781:	89 44 24 04          	mov    %eax,0x4(%esp)
  801785:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80178c:	e8 3d f8 ff ff       	call   800fce <sys_page_unmap>
	return r;
}
  801791:	89 d8                	mov    %ebx,%eax
  801793:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801796:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801799:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80179c:	89 ec                	mov    %ebp,%esp
  80179e:	5d                   	pop    %ebp
  80179f:	c3                   	ret    

008017a0 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	53                   	push   %ebx
  8017a4:	83 ec 04             	sub    $0x4,%esp
  8017a7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8017ac:	89 1c 24             	mov    %ebx,(%esp)
  8017af:	e8 51 fe ff ff       	call   801605 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8017b4:	83 c3 01             	add    $0x1,%ebx
  8017b7:	83 fb 20             	cmp    $0x20,%ebx
  8017ba:	75 f0                	jne    8017ac <close_all+0xc>
		close(i);
}
  8017bc:	83 c4 04             	add    $0x4,%esp
  8017bf:	5b                   	pop    %ebx
  8017c0:	5d                   	pop    %ebp
  8017c1:	c3                   	ret    
	...

008017c4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	53                   	push   %ebx
  8017c8:	83 ec 14             	sub    $0x14,%esp
  8017cb:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017cd:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  8017d3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8017da:	00 
  8017db:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  8017e2:	00 
  8017e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e7:	89 14 24             	mov    %edx,(%esp)
  8017ea:	e8 e1 07 00 00       	call   801fd0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017f6:	00 
  8017f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801802:	e8 7d 08 00 00       	call   802084 <ipc_recv>
}
  801807:	83 c4 14             	add    $0x14,%esp
  80180a:	5b                   	pop    %ebx
  80180b:	5d                   	pop    %ebp
  80180c:	c3                   	ret    

0080180d <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  80180d:	55                   	push   %ebp
  80180e:	89 e5                	mov    %esp,%ebp
  801810:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801813:	ba 00 00 00 00       	mov    $0x0,%edx
  801818:	b8 08 00 00 00       	mov    $0x8,%eax
  80181d:	e8 a2 ff ff ff       	call   8017c4 <fsipc>
}
  801822:	c9                   	leave  
  801823:	c3                   	ret    

00801824 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80182a:	8b 45 08             	mov    0x8(%ebp),%eax
  80182d:	8b 40 0c             	mov    0xc(%eax),%eax
  801830:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.set_size.req_size = newsize;
  801835:	8b 45 0c             	mov    0xc(%ebp),%eax
  801838:	a3 04 30 80 00       	mov    %eax,0x803004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80183d:	ba 00 00 00 00       	mov    $0x0,%edx
  801842:	b8 02 00 00 00       	mov    $0x2,%eax
  801847:	e8 78 ff ff ff       	call   8017c4 <fsipc>
}
  80184c:	c9                   	leave  
  80184d:	c3                   	ret    

0080184e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801854:	8b 45 08             	mov    0x8(%ebp),%eax
  801857:	8b 40 0c             	mov    0xc(%eax),%eax
  80185a:	a3 00 30 80 00       	mov    %eax,0x803000
	return fsipc(FSREQ_FLUSH, NULL);
  80185f:	ba 00 00 00 00       	mov    $0x0,%edx
  801864:	b8 06 00 00 00       	mov    $0x6,%eax
  801869:	e8 56 ff ff ff       	call   8017c4 <fsipc>
}
  80186e:	c9                   	leave  
  80186f:	c3                   	ret    

00801870 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	53                   	push   %ebx
  801874:	83 ec 14             	sub    $0x14,%esp
  801877:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80187a:	8b 45 08             	mov    0x8(%ebp),%eax
  80187d:	8b 40 0c             	mov    0xc(%eax),%eax
  801880:	a3 00 30 80 00       	mov    %eax,0x803000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801885:	ba 00 00 00 00       	mov    $0x0,%edx
  80188a:	b8 05 00 00 00       	mov    $0x5,%eax
  80188f:	e8 30 ff ff ff       	call   8017c4 <fsipc>
  801894:	85 c0                	test   %eax,%eax
  801896:	78 2b                	js     8018c3 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801898:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  80189f:	00 
  8018a0:	89 1c 24             	mov    %ebx,(%esp)
  8018a3:	e8 a9 f0 ff ff       	call   800951 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018a8:	a1 80 30 80 00       	mov    0x803080,%eax
  8018ad:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018b3:	a1 84 30 80 00       	mov    0x803084,%eax
  8018b8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8018be:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8018c3:	83 c4 14             	add    $0x14,%esp
  8018c6:	5b                   	pop    %ebx
  8018c7:	5d                   	pop    %ebp
  8018c8:	c3                   	ret    

008018c9 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018c9:	55                   	push   %ebp
  8018ca:	89 e5                	mov    %esp,%ebp
  8018cc:	83 ec 18             	sub    $0x18,%esp
  8018cf:	8b 55 10             	mov    0x10(%ebp),%edx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	ssize_t writesize;
	size_t bufsize;
	fsipcbuf.write.req_fileid=fd->fd_file.id;
  8018d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d8:	a3 00 30 80 00       	mov    %eax,0x803000
	bufsize=sizeof(fsipcbuf.write.req_buf);
	if(n<bufsize)
  8018dd:	89 d0                	mov    %edx,%eax
  8018df:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  8018e5:	76 05                	jbe    8018ec <devfile_write+0x23>
  8018e7:	b8 f8 0f 00 00       	mov    $0xff8,%eax
		bufsize=n;	
	fsipcbuf.write.req_n=n;
  8018ec:	89 15 04 30 80 00    	mov    %edx,0x803004
	memmove((void*)fsipcbuf.write.req_buf,buf,bufsize);
  8018f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018fd:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  801904:	e8 4f f2 ff ff       	call   800b58 <memmove>
	writesize=(ssize_t)fsipc(FSREQ_WRITE,NULL);
  801909:	ba 00 00 00 00       	mov    $0x0,%edx
  80190e:	b8 04 00 00 00       	mov    $0x4,%eax
  801913:	e8 ac fe ff ff       	call   8017c4 <fsipc>
	return writesize;
	//panic("devfile_write not implemented");
}
  801918:	c9                   	leave  
  801919:	c3                   	ret    

0080191a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80191a:	55                   	push   %ebp
  80191b:	89 e5                	mov    %esp,%ebp
  80191d:	53                   	push   %ebx
  80191e:	83 ec 14             	sub    $0x14,%esp
	// system server.
	// LAB 5: Your code here
	ssize_t readsize;
	if(debug)
		cprintf("devfile_read:fileid=%x readsize=%x\n",fd->fd_file.id,n);
	fsipcbuf.read.req_fileid=fd->fd_file.id;
  801921:	8b 45 08             	mov    0x8(%ebp),%eax
  801924:	8b 40 0c             	mov    0xc(%eax),%eax
  801927:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.read.req_n=n;
  80192c:	8b 45 10             	mov    0x10(%ebp),%eax
  80192f:	a3 04 30 80 00       	mov    %eax,0x803004
	readsize=(ssize_t)fsipc(FSREQ_READ,&fsipcbuf);
  801934:	ba 00 30 80 00       	mov    $0x803000,%edx
  801939:	b8 03 00 00 00       	mov    $0x3,%eax
  80193e:	e8 81 fe ff ff       	call   8017c4 <fsipc>
  801943:	89 c3                	mov    %eax,%ebx
	//cprintf("readsize=%d\n",readsize);
	if(debug)
		cprintf("devfile_read:buf1=%s\nbuf2=%s\n",(char*)&fsipcbuf,fsipcbuf.readRet.ret_buf);
	if(readsize>0)
  801945:	85 c0                	test   %eax,%eax
  801947:	7e 17                	jle    801960 <devfile_read+0x46>
		memmove(buf,(void*)&fsipcbuf,(size_t)readsize);
  801949:	89 44 24 08          	mov    %eax,0x8(%esp)
  80194d:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801954:	00 
  801955:	8b 45 0c             	mov    0xc(%ebp),%eax
  801958:	89 04 24             	mov    %eax,(%esp)
  80195b:	e8 f8 f1 ff ff       	call   800b58 <memmove>
	//cprintf("readsize=%d",readsize);
	return readsize;
	//panic("devfile_read not implemented");
}
  801960:	89 d8                	mov    %ebx,%eax
  801962:	83 c4 14             	add    $0x14,%esp
  801965:	5b                   	pop    %ebx
  801966:	5d                   	pop    %ebp
  801967:	c3                   	ret    

00801968 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801968:	55                   	push   %ebp
  801969:	89 e5                	mov    %esp,%ebp
  80196b:	53                   	push   %ebx
  80196c:	83 ec 14             	sub    $0x14,%esp
  80196f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801972:	89 1c 24             	mov    %ebx,(%esp)
  801975:	e8 86 ef ff ff       	call   800900 <strlen>
  80197a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  80197f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801984:	7f 21                	jg     8019a7 <remove+0x3f>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801986:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80198a:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801991:	e8 bb ef ff ff       	call   800951 <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801996:	ba 00 00 00 00       	mov    $0x0,%edx
  80199b:	b8 07 00 00 00       	mov    $0x7,%eax
  8019a0:	e8 1f fe ff ff       	call   8017c4 <fsipc>
  8019a5:	89 c2                	mov    %eax,%edx
}
  8019a7:	89 d0                	mov    %edx,%eax
  8019a9:	83 c4 14             	add    $0x14,%esp
  8019ac:	5b                   	pop    %ebx
  8019ad:	5d                   	pop    %ebp
  8019ae:	c3                   	ret    

008019af <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019af:	55                   	push   %ebp
  8019b0:	89 e5                	mov    %esp,%ebp
  8019b2:	56                   	push   %esi
  8019b3:	53                   	push   %ebx
  8019b4:	83 ec 30             	sub    $0x30,%esp

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;
	void *page;
	if((r=fd_alloc(&fd))<0){
  8019b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ba:	89 04 24             	mov    %eax,(%esp)
  8019bd:	e8 19 f8 ff ff       	call   8011db <fd_alloc>
  8019c2:	89 c3                	mov    %eax,%ebx
  8019c4:	85 c0                	test   %eax,%eax
  8019c6:	79 18                	jns    8019e0 <open+0x31>
		fd_close(fd,0);
  8019c8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019cf:	00 
  8019d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d3:	89 04 24             	mov    %eax,(%esp)
  8019d6:	e8 a3 fb ff ff       	call   80157e <fd_close>
  8019db:	e9 9f 00 00 00       	jmp    801a7f <open+0xd0>
		return r;
	}
	//cprintf("open:fd=%x\n",fd);
	strcpy(fsipcbuf.open.req_path,path);
  8019e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e7:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  8019ee:	e8 5e ef ff ff       	call   800951 <strcpy>
	fsipcbuf.open.req_omode=mode;
  8019f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f6:	a3 00 34 80 00       	mov    %eax,0x803400
	page=(void*)fd2data(fd);
  8019fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019fe:	89 04 24             	mov    %eax,(%esp)
  801a01:	e8 ba f7 ff ff       	call   8011c0 <fd2data>
  801a06:	89 c6                	mov    %eax,%esi
	if((r=fsipc(FSREQ_OPEN,(void*)fd))<0)
  801a08:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a0b:	b8 01 00 00 00       	mov    $0x1,%eax
  801a10:	e8 af fd ff ff       	call   8017c4 <fsipc>
  801a15:	89 c3                	mov    %eax,%ebx
  801a17:	85 c0                	test   %eax,%eax
  801a19:	79 15                	jns    801a30 <open+0x81>
	{
		fd_close(fd,1);
  801a1b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a22:	00 
  801a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a26:	89 04 24             	mov    %eax,(%esp)
  801a29:	e8 50 fb ff ff       	call   80157e <fd_close>
  801a2e:	eb 4f                	jmp    801a7f <open+0xd0>
		return r;	
	}
	//cprintf("open:page=%x\n",page);
	if((r=sys_page_map(0,(void*)fd,0,(void*)page,PTE_P | PTE_W | PTE_U))<0)
  801a30:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801a37:	00 
  801a38:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801a3c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a43:	00 
  801a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a52:	e8 d5 f5 ff ff       	call   80102c <sys_page_map>
  801a57:	89 c3                	mov    %eax,%ebx
  801a59:	85 c0                	test   %eax,%eax
  801a5b:	79 15                	jns    801a72 <open+0xc3>
	{
		fd_close(fd,1);
  801a5d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a64:	00 
  801a65:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a68:	89 04 24             	mov    %eax,(%esp)
  801a6b:	e8 0e fb ff ff       	call   80157e <fd_close>
  801a70:	eb 0d                	jmp    801a7f <open+0xd0>
		return r;
	}
	//cprintf("open:fileid=%x\n",fd->fd_file.id);
	return fd2num(fd);
  801a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a75:	89 04 24             	mov    %eax,(%esp)
  801a78:	e8 33 f7 ff ff       	call   8011b0 <fd2num>
  801a7d:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801a7f:	89 d8                	mov    %ebx,%eax
  801a81:	83 c4 30             	add    $0x30,%esp
  801a84:	5b                   	pop    %ebx
  801a85:	5e                   	pop    %esi
  801a86:	5d                   	pop    %ebp
  801a87:	c3                   	ret    
	...

00801a90 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  801a96:	c7 44 24 04 58 2c 80 	movl   $0x802c58,0x4(%esp)
  801a9d:	00 
  801a9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa1:	89 04 24             	mov    %eax,(%esp)
  801aa4:	e8 a8 ee ff ff       	call   800951 <strcpy>
	return 0;
}
  801aa9:	b8 00 00 00 00       	mov    $0x0,%eax
  801aae:	c9                   	leave  
  801aaf:	c3                   	ret    

00801ab0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ab0:	55                   	push   %ebp
  801ab1:	89 e5                	mov    %esp,%ebp
  801ab3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_close(fd->fd_sock.sockid);
  801ab6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab9:	8b 40 0c             	mov    0xc(%eax),%eax
  801abc:	89 04 24             	mov    %eax,(%esp)
  801abf:	e8 9e 02 00 00       	call   801d62 <nsipc_close>
}
  801ac4:	c9                   	leave  
  801ac5:	c3                   	ret    

00801ac6 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801acc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801ad3:	00 
  801ad4:	8b 45 10             	mov    0x10(%ebp),%eax
  801ad7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801adb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ade:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae5:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae8:	89 04 24             	mov    %eax,(%esp)
  801aeb:	e8 ae 02 00 00       	call   801d9e <nsipc_send>
}
  801af0:	c9                   	leave  
  801af1:	c3                   	ret    

00801af2 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801af8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801aff:	00 
  801b00:	8b 45 10             	mov    0x10(%ebp),%eax
  801b03:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b07:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b11:	8b 40 0c             	mov    0xc(%eax),%eax
  801b14:	89 04 24             	mov    %eax,(%esp)
  801b17:	e8 f5 02 00 00       	call   801e11 <nsipc_recv>
}
  801b1c:	c9                   	leave  
  801b1d:	c3                   	ret    

00801b1e <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801b1e:	55                   	push   %ebp
  801b1f:	89 e5                	mov    %esp,%ebp
  801b21:	56                   	push   %esi
  801b22:	53                   	push   %ebx
  801b23:	83 ec 20             	sub    $0x20,%esp
  801b26:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b2b:	89 04 24             	mov    %eax,(%esp)
  801b2e:	e8 a8 f6 ff ff       	call   8011db <fd_alloc>
  801b33:	89 c3                	mov    %eax,%ebx
  801b35:	85 c0                	test   %eax,%eax
  801b37:	78 21                	js     801b5a <alloc_sockfd+0x3c>
  801b39:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801b40:	00 
  801b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b44:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b48:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b4f:	e8 36 f5 ff ff       	call   80108a <sys_page_alloc>
  801b54:	89 c3                	mov    %eax,%ebx
  801b56:	85 c0                	test   %eax,%eax
  801b58:	79 0a                	jns    801b64 <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U)) < 0) {
		nsipc_close(sockid);
  801b5a:	89 34 24             	mov    %esi,(%esp)
  801b5d:	e8 00 02 00 00       	call   801d62 <nsipc_close>
  801b62:	eb 28                	jmp    801b8c <alloc_sockfd+0x6e>
		return r;
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b64:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801b6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6d:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b72:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b82:	89 04 24             	mov    %eax,(%esp)
  801b85:	e8 26 f6 ff ff       	call   8011b0 <fd2num>
  801b8a:	89 c3                	mov    %eax,%ebx
}
  801b8c:	89 d8                	mov    %ebx,%eax
  801b8e:	83 c4 20             	add    $0x20,%esp
  801b91:	5b                   	pop    %ebx
  801b92:	5e                   	pop    %esi
  801b93:	5d                   	pop    %ebp
  801b94:	c3                   	ret    

00801b95 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b9b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b9e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ba2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bac:	89 04 24             	mov    %eax,(%esp)
  801baf:	e8 62 01 00 00       	call   801d16 <nsipc_socket>
  801bb4:	85 c0                	test   %eax,%eax
  801bb6:	78 05                	js     801bbd <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801bb8:	e8 61 ff ff ff       	call   801b1e <alloc_sockfd>
}
  801bbd:	c9                   	leave  
  801bbe:	66 90                	xchg   %ax,%ax
  801bc0:	c3                   	ret    

00801bc1 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801bc1:	55                   	push   %ebp
  801bc2:	89 e5                	mov    %esp,%ebp
  801bc4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801bc7:	8d 55 fc             	lea    -0x4(%ebp),%edx
  801bca:	89 54 24 04          	mov    %edx,0x4(%esp)
  801bce:	89 04 24             	mov    %eax,(%esp)
  801bd1:	e8 58 f6 ff ff       	call   80122e <fd_lookup>
  801bd6:	89 c2                	mov    %eax,%edx
  801bd8:	85 c0                	test   %eax,%eax
  801bda:	78 15                	js     801bf1 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801bdc:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  801bdf:	8b 01                	mov    (%ecx),%eax
  801be1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  801be6:	3b 05 20 60 80 00    	cmp    0x806020,%eax
  801bec:	75 03                	jne    801bf1 <fd2sockid+0x30>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801bee:	8b 51 0c             	mov    0xc(%ecx),%edx
}
  801bf1:	89 d0                	mov    %edx,%eax
  801bf3:	c9                   	leave  
  801bf4:	c3                   	ret    

00801bf5 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  801bf5:	55                   	push   %ebp
  801bf6:	89 e5                	mov    %esp,%ebp
  801bf8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bfb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfe:	e8 be ff ff ff       	call   801bc1 <fd2sockid>
  801c03:	85 c0                	test   %eax,%eax
  801c05:	78 0f                	js     801c16 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c07:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c0a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c0e:	89 04 24             	mov    %eax,(%esp)
  801c11:	e8 2a 01 00 00       	call   801d40 <nsipc_listen>
}
  801c16:	c9                   	leave  
  801c17:	c3                   	ret    

00801c18 <connect>:
	return nsipc_close(fd->fd_sock.sockid);
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c21:	e8 9b ff ff ff       	call   801bc1 <fd2sockid>
  801c26:	85 c0                	test   %eax,%eax
  801c28:	78 16                	js     801c40 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801c2a:	8b 55 10             	mov    0x10(%ebp),%edx
  801c2d:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c31:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c34:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c38:	89 04 24             	mov    %eax,(%esp)
  801c3b:	e8 51 02 00 00       	call   801e91 <nsipc_connect>
}
  801c40:	c9                   	leave  
  801c41:	c3                   	ret    

00801c42 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c48:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4b:	e8 71 ff ff ff       	call   801bc1 <fd2sockid>
  801c50:	85 c0                	test   %eax,%eax
  801c52:	78 0f                	js     801c63 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801c54:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c57:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c5b:	89 04 24             	mov    %eax,(%esp)
  801c5e:	e8 19 01 00 00       	call   801d7c <nsipc_shutdown>
}
  801c63:	c9                   	leave  
  801c64:	c3                   	ret    

00801c65 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c65:	55                   	push   %ebp
  801c66:	89 e5                	mov    %esp,%ebp
  801c68:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6e:	e8 4e ff ff ff       	call   801bc1 <fd2sockid>
  801c73:	85 c0                	test   %eax,%eax
  801c75:	78 16                	js     801c8d <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801c77:	8b 55 10             	mov    0x10(%ebp),%edx
  801c7a:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c7e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c81:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c85:	89 04 24             	mov    %eax,(%esp)
  801c88:	e8 43 02 00 00       	call   801ed0 <nsipc_bind>
}
  801c8d:	c9                   	leave  
  801c8e:	c3                   	ret    

00801c8f <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c95:	8b 45 08             	mov    0x8(%ebp),%eax
  801c98:	e8 24 ff ff ff       	call   801bc1 <fd2sockid>
  801c9d:	85 c0                	test   %eax,%eax
  801c9f:	78 1f                	js     801cc0 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ca1:	8b 55 10             	mov    0x10(%ebp),%edx
  801ca4:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ca8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cab:	89 54 24 04          	mov    %edx,0x4(%esp)
  801caf:	89 04 24             	mov    %eax,(%esp)
  801cb2:	e8 58 02 00 00       	call   801f0f <nsipc_accept>
  801cb7:	85 c0                	test   %eax,%eax
  801cb9:	78 05                	js     801cc0 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801cbb:	e8 5e fe ff ff       	call   801b1e <alloc_sockfd>
}
  801cc0:	c9                   	leave  
  801cc1:	c3                   	ret    
	...

00801cd0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
  801cd3:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801cd6:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  801cdc:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801ce3:	00 
  801ce4:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801ceb:	00 
  801cec:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cf0:	89 14 24             	mov    %edx,(%esp)
  801cf3:	e8 d8 02 00 00       	call   801fd0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801cf8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cff:	00 
  801d00:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d07:	00 
  801d08:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d0f:	e8 70 03 00 00       	call   802084 <ipc_recv>
}
  801d14:	c9                   	leave  
  801d15:	c3                   	ret    

00801d16 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801d16:	55                   	push   %ebp
  801d17:	89 e5                	mov    %esp,%ebp
  801d19:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1f:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.socket.req_type = type;
  801d24:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d27:	a3 04 50 80 00       	mov    %eax,0x805004
	nsipcbuf.socket.req_protocol = protocol;
  801d2c:	8b 45 10             	mov    0x10(%ebp),%eax
  801d2f:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SOCKET);
  801d34:	b8 09 00 00 00       	mov    $0x9,%eax
  801d39:	e8 92 ff ff ff       	call   801cd0 <nsipc>
}
  801d3e:	c9                   	leave  
  801d3f:	c3                   	ret    

00801d40 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
  801d43:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d46:	8b 45 08             	mov    0x8(%ebp),%eax
  801d49:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.listen.req_backlog = backlog;
  801d4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d51:	a3 04 50 80 00       	mov    %eax,0x805004
	return nsipc(NSREQ_LISTEN);
  801d56:	b8 06 00 00 00       	mov    $0x6,%eax
  801d5b:	e8 70 ff ff ff       	call   801cd0 <nsipc>
}
  801d60:	c9                   	leave  
  801d61:	c3                   	ret    

00801d62 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  801d62:	55                   	push   %ebp
  801d63:	89 e5                	mov    %esp,%ebp
  801d65:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d68:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6b:	a3 00 50 80 00       	mov    %eax,0x805000
	return nsipc(NSREQ_CLOSE);
  801d70:	b8 04 00 00 00       	mov    $0x4,%eax
  801d75:	e8 56 ff ff ff       	call   801cd0 <nsipc>
}
  801d7a:	c9                   	leave  
  801d7b:	c3                   	ret    

00801d7c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  801d7c:	55                   	push   %ebp
  801d7d:	89 e5                	mov    %esp,%ebp
  801d7f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d82:	8b 45 08             	mov    0x8(%ebp),%eax
  801d85:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.shutdown.req_how = how;
  801d8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d8d:	a3 04 50 80 00       	mov    %eax,0x805004
	return nsipc(NSREQ_SHUTDOWN);
  801d92:	b8 03 00 00 00       	mov    $0x3,%eax
  801d97:	e8 34 ff ff ff       	call   801cd0 <nsipc>
}
  801d9c:	c9                   	leave  
  801d9d:	c3                   	ret    

00801d9e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d9e:	55                   	push   %ebp
  801d9f:	89 e5                	mov    %esp,%ebp
  801da1:	53                   	push   %ebx
  801da2:	83 ec 14             	sub    $0x14,%esp
  801da5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801da8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dab:	a3 00 50 80 00       	mov    %eax,0x805000
	assert(size < 1600);
  801db0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801db6:	7e 24                	jle    801ddc <nsipc_send+0x3e>
  801db8:	c7 44 24 0c 64 2c 80 	movl   $0x802c64,0xc(%esp)
  801dbf:	00 
  801dc0:	c7 44 24 08 70 2c 80 	movl   $0x802c70,0x8(%esp)
  801dc7:	00 
  801dc8:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  801dcf:	00 
  801dd0:	c7 04 24 85 2c 80 00 	movl   $0x802c85,(%esp)
  801dd7:	e8 80 01 00 00       	call   801f5c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801ddc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801de0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801de7:	c7 04 24 0c 50 80 00 	movl   $0x80500c,(%esp)
  801dee:	e8 65 ed ff ff       	call   800b58 <memmove>
	nsipcbuf.send.req_size = size;
  801df3:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	nsipcbuf.send.req_flags = flags;
  801df9:	8b 45 14             	mov    0x14(%ebp),%eax
  801dfc:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SEND);
  801e01:	b8 08 00 00 00       	mov    $0x8,%eax
  801e06:	e8 c5 fe ff ff       	call   801cd0 <nsipc>
}
  801e0b:	83 c4 14             	add    $0x14,%esp
  801e0e:	5b                   	pop    %ebx
  801e0f:	5d                   	pop    %ebp
  801e10:	c3                   	ret    

00801e11 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e11:	55                   	push   %ebp
  801e12:	89 e5                	mov    %esp,%ebp
  801e14:	56                   	push   %esi
  801e15:	53                   	push   %ebx
  801e16:	83 ec 10             	sub    $0x10,%esp
  801e19:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1f:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.recv.req_len = len;
  801e24:	89 35 04 50 80 00    	mov    %esi,0x805004
	nsipcbuf.recv.req_flags = flags;
  801e2a:	8b 45 14             	mov    0x14(%ebp),%eax
  801e2d:	a3 08 50 80 00       	mov    %eax,0x805008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e32:	b8 07 00 00 00       	mov    $0x7,%eax
  801e37:	e8 94 fe ff ff       	call   801cd0 <nsipc>
  801e3c:	89 c3                	mov    %eax,%ebx
  801e3e:	85 c0                	test   %eax,%eax
  801e40:	78 46                	js     801e88 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801e42:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e47:	7f 04                	jg     801e4d <nsipc_recv+0x3c>
  801e49:	39 c6                	cmp    %eax,%esi
  801e4b:	7d 24                	jge    801e71 <nsipc_recv+0x60>
  801e4d:	c7 44 24 0c 91 2c 80 	movl   $0x802c91,0xc(%esp)
  801e54:	00 
  801e55:	c7 44 24 08 70 2c 80 	movl   $0x802c70,0x8(%esp)
  801e5c:	00 
  801e5d:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  801e64:	00 
  801e65:	c7 04 24 85 2c 80 00 	movl   $0x802c85,(%esp)
  801e6c:	e8 eb 00 00 00       	call   801f5c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e71:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e75:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801e7c:	00 
  801e7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e80:	89 04 24             	mov    %eax,(%esp)
  801e83:	e8 d0 ec ff ff       	call   800b58 <memmove>
	}

	return r;
}
  801e88:	89 d8                	mov    %ebx,%eax
  801e8a:	83 c4 10             	add    $0x10,%esp
  801e8d:	5b                   	pop    %ebx
  801e8e:	5e                   	pop    %esi
  801e8f:	5d                   	pop    %ebp
  801e90:	c3                   	ret    

00801e91 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e91:	55                   	push   %ebp
  801e92:	89 e5                	mov    %esp,%ebp
  801e94:	53                   	push   %ebx
  801e95:	83 ec 14             	sub    $0x14,%esp
  801e98:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801e9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9e:	a3 00 50 80 00       	mov    %eax,0x805000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ea3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ea7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eaa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eae:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  801eb5:	e8 9e ec ff ff       	call   800b58 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801eba:	89 1d 14 50 80 00    	mov    %ebx,0x805014
	return nsipc(NSREQ_CONNECT);
  801ec0:	b8 05 00 00 00       	mov    $0x5,%eax
  801ec5:	e8 06 fe ff ff       	call   801cd0 <nsipc>
}
  801eca:	83 c4 14             	add    $0x14,%esp
  801ecd:	5b                   	pop    %ebx
  801ece:	5d                   	pop    %ebp
  801ecf:	c3                   	ret    

00801ed0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
  801ed3:	53                   	push   %ebx
  801ed4:	83 ec 14             	sub    $0x14,%esp
  801ed7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801eda:	8b 45 08             	mov    0x8(%ebp),%eax
  801edd:	a3 00 50 80 00       	mov    %eax,0x805000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801ee2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ee6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eed:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  801ef4:	e8 5f ec ff ff       	call   800b58 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801ef9:	89 1d 14 50 80 00    	mov    %ebx,0x805014
	return nsipc(NSREQ_BIND);
  801eff:	b8 02 00 00 00       	mov    $0x2,%eax
  801f04:	e8 c7 fd ff ff       	call   801cd0 <nsipc>
}
  801f09:	83 c4 14             	add    $0x14,%esp
  801f0c:	5b                   	pop    %ebx
  801f0d:	5d                   	pop    %ebp
  801f0e:	c3                   	ret    

00801f0f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f0f:	55                   	push   %ebp
  801f10:	89 e5                	mov    %esp,%ebp
  801f12:	53                   	push   %ebx
  801f13:	83 ec 14             	sub    $0x14,%esp
	int r;
	
	nsipcbuf.accept.req_s = s;
  801f16:	8b 45 08             	mov    0x8(%ebp),%eax
  801f19:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f1e:	b8 01 00 00 00       	mov    $0x1,%eax
  801f23:	e8 a8 fd ff ff       	call   801cd0 <nsipc>
  801f28:	89 c3                	mov    %eax,%ebx
  801f2a:	85 c0                	test   %eax,%eax
  801f2c:	78 26                	js     801f54 <nsipc_accept+0x45>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f2e:	a1 10 50 80 00       	mov    0x805010,%eax
  801f33:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f37:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801f3e:	00 
  801f3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f42:	89 04 24             	mov    %eax,(%esp)
  801f45:	e8 0e ec ff ff       	call   800b58 <memmove>
		*addrlen = ret->ret_addrlen;
  801f4a:	a1 10 50 80 00       	mov    0x805010,%eax
  801f4f:	8b 55 10             	mov    0x10(%ebp),%edx
  801f52:	89 02                	mov    %eax,(%edx)
	}
	return r;
}
  801f54:	89 d8                	mov    %ebx,%eax
  801f56:	83 c4 14             	add    $0x14,%esp
  801f59:	5b                   	pop    %ebx
  801f5a:	5d                   	pop    %ebp
  801f5b:	c3                   	ret    

00801f5c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  801f5c:	55                   	push   %ebp
  801f5d:	89 e5                	mov    %esp,%ebp
  801f5f:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  801f62:	8d 45 14             	lea    0x14(%ebp),%eax
  801f65:	89 45 fc             	mov    %eax,-0x4(%ebp)

	// Print the panic message
	if (argv0)
  801f68:	a1 50 60 80 00       	mov    0x806050,%eax
  801f6d:	85 c0                	test   %eax,%eax
  801f6f:	74 10                	je     801f81 <_panic+0x25>
		cprintf("%s: ", argv0);
  801f71:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f75:	c7 04 24 a6 2c 80 00 	movl   $0x802ca6,(%esp)
  801f7c:	e8 64 e3 ff ff       	call   8002e5 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  801f81:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f84:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f88:	8b 45 08             	mov    0x8(%ebp),%eax
  801f8b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f8f:	a1 00 60 80 00       	mov    0x806000,%eax
  801f94:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f98:	c7 04 24 ab 2c 80 00 	movl   $0x802cab,(%esp)
  801f9f:	e8 41 e3 ff ff       	call   8002e5 <cprintf>
	vcprintf(fmt, ap);
  801fa4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801fa7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fab:	8b 45 10             	mov    0x10(%ebp),%eax
  801fae:	89 04 24             	mov    %eax,(%esp)
  801fb1:	e8 ce e2 ff ff       	call   800284 <vcprintf>
	cprintf("\n");
  801fb6:	c7 04 24 09 2d 80 00 	movl   $0x802d09,(%esp)
  801fbd:	e8 23 e3 ff ff       	call   8002e5 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801fc2:	cc                   	int3   
  801fc3:	eb fd                	jmp    801fc2 <_panic+0x66>
	...

00801fd0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fd0:	55                   	push   %ebp
  801fd1:	89 e5                	mov    %esp,%ebp
  801fd3:	57                   	push   %edi
  801fd4:	56                   	push   %esi
  801fd5:	53                   	push   %ebx
  801fd6:	83 ec 1c             	sub    $0x1c,%esp
  801fd9:	8b 75 08             	mov    0x8(%ebp),%esi
  801fdc:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  801fdf:	e8 39 f1 ff ff       	call   80111d <sys_getenvid>
  801fe4:	25 ff 03 00 00       	and    $0x3ff,%eax
  801fe9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fec:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ff1:	a3 4c 60 80 00       	mov    %eax,0x80604c
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  801ff6:	e8 22 f1 ff ff       	call   80111d <sys_getenvid>
  801ffb:	25 ff 03 00 00       	and    $0x3ff,%eax
  802000:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802003:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802008:	a3 4c 60 80 00       	mov    %eax,0x80604c
		if(env->env_id==to_env){
  80200d:	8b 40 4c             	mov    0x4c(%eax),%eax
  802010:	39 f0                	cmp    %esi,%eax
  802012:	75 0e                	jne    802022 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  802014:	c7 04 24 c7 2c 80 00 	movl   $0x802cc7,(%esp)
  80201b:	e8 c5 e2 ff ff       	call   8002e5 <cprintf>
  802020:	eb 5a                	jmp    80207c <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  802022:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802026:	8b 45 10             	mov    0x10(%ebp),%eax
  802029:	89 44 24 08          	mov    %eax,0x8(%esp)
  80202d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802030:	89 44 24 04          	mov    %eax,0x4(%esp)
  802034:	89 34 24             	mov    %esi,(%esp)
  802037:	e8 40 ee ff ff       	call   800e7c <sys_ipc_try_send>
  80203c:	89 c3                	mov    %eax,%ebx
  80203e:	85 c0                	test   %eax,%eax
  802040:	79 25                	jns    802067 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  802042:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802045:	74 2b                	je     802072 <ipc_send+0xa2>
				panic("send error:%e",r);
  802047:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80204b:	c7 44 24 08 e3 2c 80 	movl   $0x802ce3,0x8(%esp)
  802052:	00 
  802053:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80205a:	00 
  80205b:	c7 04 24 f1 2c 80 00 	movl   $0x802cf1,(%esp)
  802062:	e8 f5 fe ff ff       	call   801f5c <_panic>
		}
			sys_yield();
  802067:	e8 7d f0 ff ff       	call   8010e9 <sys_yield>
		
	}while(r!=0);
  80206c:	85 db                	test   %ebx,%ebx
  80206e:	75 86                	jne    801ff6 <ipc_send+0x26>
  802070:	eb 0a                	jmp    80207c <ipc_send+0xac>
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
		{	
			if(r!=-E_IPC_NOT_RECV)
				panic("send error:%e",r);
		}
			sys_yield();
  802072:	e8 72 f0 ff ff       	call   8010e9 <sys_yield>
  802077:	e9 7a ff ff ff       	jmp    801ff6 <ipc_send+0x26>
		
	}while(r!=0);
	return;
	//panic("ipc_send not implemented");
}
  80207c:	83 c4 1c             	add    $0x1c,%esp
  80207f:	5b                   	pop    %ebx
  802080:	5e                   	pop    %esi
  802081:	5f                   	pop    %edi
  802082:	5d                   	pop    %ebp
  802083:	c3                   	ret    

00802084 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802084:	55                   	push   %ebp
  802085:	89 e5                	mov    %esp,%ebp
  802087:	57                   	push   %edi
  802088:	56                   	push   %esi
  802089:	53                   	push   %ebx
  80208a:	83 ec 0c             	sub    $0xc,%esp
  80208d:	8b 75 08             	mov    0x8(%ebp),%esi
  802090:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	void *dstva=NULL;
	if(pg)
		dstva=pg;
	env = &envs[ENVX(sys_getenvid())];
  802093:	e8 85 f0 ff ff       	call   80111d <sys_getenvid>
  802098:	25 ff 03 00 00       	and    $0x3ff,%eax
  80209d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020a0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020a5:	a3 4c 60 80 00       	mov    %eax,0x80604c
	if(from_env_store&&(env->env_id==*from_env_store))
  8020aa:	85 f6                	test   %esi,%esi
  8020ac:	74 29                	je     8020d7 <ipc_recv+0x53>
  8020ae:	8b 40 4c             	mov    0x4c(%eax),%eax
  8020b1:	3b 06                	cmp    (%esi),%eax
  8020b3:	75 22                	jne    8020d7 <ipc_recv+0x53>
	{
		*from_env_store=0;
  8020b5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  8020bb:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("send:the reciver is sender\n");
  8020c1:	c7 04 24 c7 2c 80 00 	movl   $0x802cc7,(%esp)
  8020c8:	e8 18 e2 ff ff       	call   8002e5 <cprintf>
  8020cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020d2:	e9 8a 00 00 00       	jmp    802161 <ipc_recv+0xdd>
		return 0;
	}
	env = &envs[ENVX(sys_getenvid())];
  8020d7:	e8 41 f0 ff ff       	call   80111d <sys_getenvid>
  8020dc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8020e1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020e4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020e9:	a3 4c 60 80 00       	mov    %eax,0x80604c
	if((r=sys_ipc_recv(dstva))<0)
  8020ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020f1:	89 04 24             	mov    %eax,(%esp)
  8020f4:	e8 26 ed ff ff       	call   800e1f <sys_ipc_recv>
  8020f9:	89 c3                	mov    %eax,%ebx
  8020fb:	85 c0                	test   %eax,%eax
  8020fd:	79 1a                	jns    802119 <ipc_recv+0x95>
	{
		*from_env_store=0;
  8020ff:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  802105:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("reciver failed\n");
  80210b:	c7 04 24 fb 2c 80 00 	movl   $0x802cfb,(%esp)
  802112:	e8 ce e1 ff ff       	call   8002e5 <cprintf>
  802117:	eb 48                	jmp    802161 <ipc_recv+0xdd>
		return r;
	}
	else{//接收成功
		env = &envs[ENVX(sys_getenvid())];
  802119:	e8 ff ef ff ff       	call   80111d <sys_getenvid>
  80211e:	25 ff 03 00 00       	and    $0x3ff,%eax
  802123:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802126:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80212b:	a3 4c 60 80 00       	mov    %eax,0x80604c
		if(from_env_store)
  802130:	85 f6                	test   %esi,%esi
  802132:	74 05                	je     802139 <ipc_recv+0xb5>
			*from_env_store=env->env_ipc_from;	
  802134:	8b 40 74             	mov    0x74(%eax),%eax
  802137:	89 06                	mov    %eax,(%esi)
		if(perm_store)
  802139:	85 ff                	test   %edi,%edi
  80213b:	74 0a                	je     802147 <ipc_recv+0xc3>
			*perm_store=env->env_ipc_perm;
  80213d:	a1 4c 60 80 00       	mov    0x80604c,%eax
  802142:	8b 40 78             	mov    0x78(%eax),%eax
  802145:	89 07                	mov    %eax,(%edi)
		env = &envs[ENVX(sys_getenvid())];
  802147:	e8 d1 ef ff ff       	call   80111d <sys_getenvid>
  80214c:	25 ff 03 00 00       	and    $0x3ff,%eax
  802151:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802154:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802159:	a3 4c 60 80 00       	mov    %eax,0x80604c
		return env->env_ipc_value;
  80215e:	8b 58 70             	mov    0x70(%eax),%ebx
	}
	//panic("ipc_recv not implemented");
	return 0;
}
  802161:	89 d8                	mov    %ebx,%eax
  802163:	83 c4 0c             	add    $0xc,%esp
  802166:	5b                   	pop    %ebx
  802167:	5e                   	pop    %esi
  802168:	5f                   	pop    %edi
  802169:	5d                   	pop    %ebp
  80216a:	c3                   	ret    
  80216b:	00 00                	add    %al,(%eax)
  80216d:	00 00                	add    %al,(%eax)
	...

00802170 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  802170:	55                   	push   %ebp
  802171:	89 e5                	mov    %esp,%ebp
  802173:	57                   	push   %edi
  802174:	56                   	push   %esi
  802175:	53                   	push   %ebx
  802176:	83 ec 18             	sub    $0x18,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  802179:	8b 45 08             	mov    0x8(%ebp),%eax
  80217c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  80217f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802182:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802185:	be 00 00 00 00       	mov    $0x0,%esi
  80218a:	bf 3c 60 80 00       	mov    $0x80603c,%edi
  80218f:	c6 45 e3 00          	movb   $0x0,-0x1d(%ebp)
  802193:	eb 02                	jmp    802197 <inet_ntoa+0x27>
  for(n = 0; n < 4; n++) {
  802195:	89 c6                	mov    %eax,%esi
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  802197:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80219a:	0f b6 0a             	movzbl (%edx),%ecx
      *ap /= (u8_t)10;
  80219d:	b8 cd ff ff ff       	mov    $0xffffffcd,%eax
  8021a2:	f6 e1                	mul    %cl
  8021a4:	89 c2                	mov    %eax,%edx
  8021a6:	66 c1 ea 08          	shr    $0x8,%dx
  8021aa:	c0 ea 03             	shr    $0x3,%dl
  8021ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8021b0:	88 10                	mov    %dl,(%eax)
      inv[i++] = '0' + rem;
  8021b2:	89 f0                	mov    %esi,%eax
  8021b4:	0f b6 d8             	movzbl %al,%ebx
  8021b7:	8d 04 92             	lea    (%edx,%edx,4),%eax
  8021ba:	01 c0                	add    %eax,%eax
  8021bc:	28 c1                	sub    %al,%cl
  8021be:	83 c1 30             	add    $0x30,%ecx
  8021c1:	88 4c 1d ed          	mov    %cl,-0x13(%ebp,%ebx,1)
  8021c5:	8d 46 01             	lea    0x1(%esi),%eax
    } while(*ap);
  8021c8:	84 d2                	test   %dl,%dl
  8021ca:	75 c9                	jne    802195 <inet_ntoa+0x25>
    while(i--)
  8021cc:	89 f1                	mov    %esi,%ecx
  8021ce:	80 f9 ff             	cmp    $0xff,%cl
  8021d1:	74 20                	je     8021f3 <inet_ntoa+0x83>
  8021d3:	89 fa                	mov    %edi,%edx
      *rp++ = inv[i];
  8021d5:	0f b6 c1             	movzbl %cl,%eax
  8021d8:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  8021dd:	88 02                	mov    %al,(%edx)
  8021df:	83 c2 01             	add    $0x1,%edx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  8021e2:	83 e9 01             	sub    $0x1,%ecx
  8021e5:	80 f9 ff             	cmp    $0xff,%cl
  8021e8:	75 eb                	jne    8021d5 <inet_ntoa+0x65>
  8021ea:	89 f2                	mov    %esi,%edx
  8021ec:	0f b6 c2             	movzbl %dl,%eax
  8021ef:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
      *rp++ = inv[i];
    *rp++ = '.';
  8021f3:	c6 07 2e             	movb   $0x2e,(%edi)
  8021f6:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  8021f9:	80 45 e3 01          	addb   $0x1,-0x1d(%ebp)
  8021fd:	80 7d e3 03          	cmpb   $0x3,-0x1d(%ebp)
  802201:	77 0b                	ja     80220e <inet_ntoa+0x9e>
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  802203:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  802207:	b8 00 00 00 00       	mov    $0x0,%eax
  80220c:	eb 87                	jmp    802195 <inet_ntoa+0x25>
  }
  *--rp = 0;
  80220e:	c6 47 ff 00          	movb   $0x0,-0x1(%edi)
  return str;
}
  802212:	b8 3c 60 80 00       	mov    $0x80603c,%eax
  802217:	83 c4 18             	add    $0x18,%esp
  80221a:	5b                   	pop    %ebx
  80221b:	5e                   	pop    %esi
  80221c:	5f                   	pop    %edi
  80221d:	5d                   	pop    %ebp
  80221e:	c3                   	ret    

0080221f <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  80221f:	55                   	push   %ebp
  802220:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  802222:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  802226:	89 c2                	mov    %eax,%edx
  802228:	c1 ea 08             	shr    $0x8,%edx
  80222b:	c1 e0 08             	shl    $0x8,%eax
  80222e:	09 d0                	or     %edx,%eax
  802230:	0f b7 c0             	movzwl %ax,%eax
}
  802233:	5d                   	pop    %ebp
  802234:	c3                   	ret    

00802235 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  802235:	55                   	push   %ebp
  802236:	89 e5                	mov    %esp,%ebp
  802238:	83 ec 04             	sub    $0x4,%esp
  return htons(n);
  80223b:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80223f:	89 04 24             	mov    %eax,(%esp)
  802242:	e8 d8 ff ff ff       	call   80221f <htons>
  802247:	0f b7 c0             	movzwl %ax,%eax
}
  80224a:	c9                   	leave  
  80224b:	c3                   	ret    

0080224c <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  80224c:	55                   	push   %ebp
  80224d:	89 e5                	mov    %esp,%ebp
  80224f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802252:	89 c8                	mov    %ecx,%eax
  802254:	25 00 ff 00 00       	and    $0xff00,%eax
  802259:	c1 e0 08             	shl    $0x8,%eax
  80225c:	89 ca                	mov    %ecx,%edx
  80225e:	c1 e2 18             	shl    $0x18,%edx
  802261:	09 d0                	or     %edx,%eax
  802263:	89 ca                	mov    %ecx,%edx
  802265:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  80226b:	c1 ea 08             	shr    $0x8,%edx
  80226e:	09 d0                	or     %edx,%eax
  802270:	c1 e9 18             	shr    $0x18,%ecx
  802273:	09 c8                	or     %ecx,%eax
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  802275:	5d                   	pop    %ebp
  802276:	c3                   	ret    

00802277 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  802277:	55                   	push   %ebp
  802278:	89 e5                	mov    %esp,%ebp
  80227a:	57                   	push   %edi
  80227b:	56                   	push   %esi
  80227c:	53                   	push   %ebx
  80227d:	83 ec 24             	sub    $0x24,%esp
  802280:	8b 55 08             	mov    0x8(%ebp),%edx
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  802283:	0f be 32             	movsbl (%edx),%esi
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  802286:	8d 46 d0             	lea    -0x30(%esi),%eax
  802289:	3c 09                	cmp    $0x9,%al
  80228b:	0f 87 c0 01 00 00    	ja     802451 <inet_aton+0x1da>
  802291:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802294:	89 45 e0             	mov    %eax,-0x20(%ebp)
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  802297:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80229a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     */
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
  80229d:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
  8022a4:	83 fe 30             	cmp    $0x30,%esi
  8022a7:	75 24                	jne    8022cd <inet_aton+0x56>
      c = *++cp;
  8022a9:	83 c2 01             	add    $0x1,%edx
  8022ac:	0f be 32             	movsbl (%edx),%esi
      if (c == 'x' || c == 'X') {
  8022af:	83 fe 78             	cmp    $0x78,%esi
  8022b2:	74 0c                	je     8022c0 <inet_aton+0x49>
  8022b4:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  8022bb:	83 fe 58             	cmp    $0x58,%esi
  8022be:	75 0d                	jne    8022cd <inet_aton+0x56>
        base = 16;
        c = *++cp;
  8022c0:	83 c2 01             	add    $0x1,%edx
  8022c3:	0f be 32             	movsbl (%edx),%esi
  8022c6:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
  8022cd:	8d 5a 01             	lea    0x1(%edx),%ebx
  8022d0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8022d7:	eb 03                	jmp    8022dc <inet_aton+0x65>
  8022d9:	83 c3 01             	add    $0x1,%ebx
  8022dc:	8d 7b ff             	lea    -0x1(%ebx),%edi
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  8022df:	89 f1                	mov    %esi,%ecx
  8022e1:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8022e4:	3c 09                	cmp    $0x9,%al
  8022e6:	77 13                	ja     8022fb <inet_aton+0x84>
        val = (val * base) + (int)(c - '0');
  8022e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8022eb:	0f af 45 d8          	imul   -0x28(%ebp),%eax
  8022ef:	8d 74 06 d0          	lea    -0x30(%esi,%eax,1),%esi
  8022f3:	89 75 d8             	mov    %esi,-0x28(%ebp)
        c = *++cp;
  8022f6:	0f be 33             	movsbl (%ebx),%esi
  8022f9:	eb de                	jmp    8022d9 <inet_aton+0x62>
      } else if (base == 16 && isxdigit(c)) {
  8022fb:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  8022ff:	75 2c                	jne    80232d <inet_aton+0xb6>
  802301:	8d 51 9f             	lea    -0x61(%ecx),%edx
  802304:	80 fa 05             	cmp    $0x5,%dl
  802307:	76 07                	jbe    802310 <inet_aton+0x99>
  802309:	8d 41 bf             	lea    -0x41(%ecx),%eax
  80230c:	3c 05                	cmp    $0x5,%al
  80230e:	77 1d                	ja     80232d <inet_aton+0xb6>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  802310:	80 fa 1a             	cmp    $0x1a,%dl
  802313:	19 c0                	sbb    %eax,%eax
  802315:	83 e0 20             	and    $0x20,%eax
  802318:	29 c6                	sub    %eax,%esi
  80231a:	8d 46 c9             	lea    -0x37(%esi),%eax
  80231d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  802320:	c1 e2 04             	shl    $0x4,%edx
  802323:	09 d0                	or     %edx,%eax
  802325:	89 45 d8             	mov    %eax,-0x28(%ebp)
        c = *++cp;
  802328:	0f be 33             	movsbl (%ebx),%esi
  80232b:	eb ac                	jmp    8022d9 <inet_aton+0x62>
      } else
        break;
    }
    if (c == '.') {
  80232d:	83 fe 2e             	cmp    $0x2e,%esi
  802330:	75 2c                	jne    80235e <inet_aton+0xe7>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  802332:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802335:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  802338:	0f 86 13 01 00 00    	jbe    802451 <inet_aton+0x1da>
        return (0);
      *pp++ = val;
  80233e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802341:	89 02                	mov    %eax,(%edx)
      c = *++cp;
  802343:	8d 57 01             	lea    0x1(%edi),%edx
  802346:	0f be 77 01          	movsbl 0x1(%edi),%esi
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  80234a:	8d 46 d0             	lea    -0x30(%esi),%eax
  80234d:	3c 09                	cmp    $0x9,%al
  80234f:	0f 87 fc 00 00 00    	ja     802451 <inet_aton+0x1da>
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
      *pp++ = val;
  802355:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
  802359:	e9 3f ff ff ff       	jmp    80229d <inet_aton+0x26>
  80235e:	8b 5d d8             	mov    -0x28(%ebp),%ebx
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  802361:	85 f6                	test   %esi,%esi
  802363:	74 36                	je     80239b <inet_aton+0x124>
  802365:	80 f9 1f             	cmp    $0x1f,%cl
  802368:	0f 86 e3 00 00 00    	jbe    802451 <inet_aton+0x1da>
  80236e:	89 f2                	mov    %esi,%edx
  802370:	84 d2                	test   %dl,%dl
  802372:	0f 88 d9 00 00 00    	js     802451 <inet_aton+0x1da>
  802378:	83 fe 20             	cmp    $0x20,%esi
  80237b:	74 1e                	je     80239b <inet_aton+0x124>
  80237d:	83 fe 0c             	cmp    $0xc,%esi
  802380:	74 19                	je     80239b <inet_aton+0x124>
  802382:	83 fe 0a             	cmp    $0xa,%esi
  802385:	74 14                	je     80239b <inet_aton+0x124>
  802387:	83 fe 0d             	cmp    $0xd,%esi
  80238a:	74 0f                	je     80239b <inet_aton+0x124>
  80238c:	83 fe 09             	cmp    $0x9,%esi
  80238f:	90                   	nop    
  802390:	74 09                	je     80239b <inet_aton+0x124>
  802392:	83 fe 0b             	cmp    $0xb,%esi
  802395:	0f 85 b6 00 00 00    	jne    802451 <inet_aton+0x1da>
    return (0);
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  80239b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  switch (n) {
  80239e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8023a1:	29 c2                	sub    %eax,%edx
  8023a3:	89 d0                	mov    %edx,%eax
  8023a5:	c1 f8 02             	sar    $0x2,%eax
  8023a8:	83 c0 01             	add    $0x1,%eax
  8023ab:	83 f8 02             	cmp    $0x2,%eax
  8023ae:	74 24                	je     8023d4 <inet_aton+0x15d>
  8023b0:	83 f8 02             	cmp    $0x2,%eax
  8023b3:	7f 0d                	jg     8023c2 <inet_aton+0x14b>
  8023b5:	85 c0                	test   %eax,%eax
  8023b7:	0f 84 94 00 00 00    	je     802451 <inet_aton+0x1da>
  8023bd:	8d 76 00             	lea    0x0(%esi),%esi
  8023c0:	eb 6d                	jmp    80242f <inet_aton+0x1b8>
  8023c2:	83 f8 03             	cmp    $0x3,%eax
  8023c5:	74 28                	je     8023ef <inet_aton+0x178>
  8023c7:	83 f8 04             	cmp    $0x4,%eax
  8023ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023d0:	75 5d                	jne    80242f <inet_aton+0x1b8>
  8023d2:	eb 38                	jmp    80240c <inet_aton+0x195>

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  8023d4:	81 fb ff ff ff 00    	cmp    $0xffffff,%ebx
  8023da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023e0:	77 6f                	ja     802451 <inet_aton+0x1da>
      return (0);
    val |= parts[0] << 24;
  8023e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023e5:	c1 e0 18             	shl    $0x18,%eax
  8023e8:	09 c3                	or     %eax,%ebx
  8023ea:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8023ed:	eb 40                	jmp    80242f <inet_aton+0x1b8>
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  8023ef:	81 fb ff ff 00 00    	cmp    $0xffff,%ebx
  8023f5:	77 5a                	ja     802451 <inet_aton+0x1da>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  8023f7:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8023fa:	c1 e2 10             	shl    $0x10,%edx
  8023fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802400:	c1 e0 18             	shl    $0x18,%eax
  802403:	09 c2                	or     %eax,%edx
  802405:	09 da                	or     %ebx,%edx
  802407:	89 55 d8             	mov    %edx,-0x28(%ebp)
  80240a:	eb 23                	jmp    80242f <inet_aton+0x1b8>
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  80240c:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
  802412:	77 3d                	ja     802451 <inet_aton+0x1da>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  802414:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802417:	c1 e0 10             	shl    $0x10,%eax
  80241a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80241d:	c1 e2 18             	shl    $0x18,%edx
  802420:	09 d0                	or     %edx,%eax
  802422:	8b 55 ec             	mov    -0x14(%ebp),%edx
  802425:	c1 e2 08             	shl    $0x8,%edx
  802428:	09 d0                	or     %edx,%eax
  80242a:	09 d8                	or     %ebx,%eax
  80242c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    break;
  }
  if (addr)
  80242f:	b8 01 00 00 00       	mov    $0x1,%eax
  802434:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802438:	74 1c                	je     802456 <inet_aton+0x1df>
    addr->s_addr = htonl(val);
  80243a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80243d:	89 04 24             	mov    %eax,(%esp)
  802440:	e8 07 fe ff ff       	call   80224c <htonl>
  802445:	8b 55 0c             	mov    0xc(%ebp),%edx
  802448:	89 02                	mov    %eax,(%edx)
  80244a:	b8 01 00 00 00       	mov    $0x1,%eax
  80244f:	eb 05                	jmp    802456 <inet_aton+0x1df>
  802451:	b8 00 00 00 00       	mov    $0x0,%eax
  return (1);
}
  802456:	83 c4 24             	add    $0x24,%esp
  802459:	5b                   	pop    %ebx
  80245a:	5e                   	pop    %esi
  80245b:	5f                   	pop    %edi
  80245c:	5d                   	pop    %ebp
  80245d:	c3                   	ret    

0080245e <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  80245e:	55                   	push   %ebp
  80245f:	89 e5                	mov    %esp,%ebp
  802461:	83 ec 18             	sub    $0x18,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  802464:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802467:	89 44 24 04          	mov    %eax,0x4(%esp)
  80246b:	8b 45 08             	mov    0x8(%ebp),%eax
  80246e:	89 04 24             	mov    %eax,(%esp)
  802471:	e8 01 fe ff ff       	call   802277 <inet_aton>
  802476:	83 f8 01             	cmp    $0x1,%eax
  802479:	19 c0                	sbb    %eax,%eax
  80247b:	0b 45 fc             	or     -0x4(%ebp),%eax
    return (val.s_addr);
  }
  return (INADDR_NONE);
}
  80247e:	c9                   	leave  
  80247f:	c3                   	ret    

00802480 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  802480:	55                   	push   %ebp
  802481:	89 e5                	mov    %esp,%ebp
  802483:	83 ec 04             	sub    $0x4,%esp
  return htonl(n);
  802486:	8b 45 08             	mov    0x8(%ebp),%eax
  802489:	89 04 24             	mov    %eax,(%esp)
  80248c:	e8 bb fd ff ff       	call   80224c <htonl>
}
  802491:	c9                   	leave  
  802492:	c3                   	ret    
	...

008024a0 <__udivdi3>:
  8024a0:	55                   	push   %ebp
  8024a1:	89 e5                	mov    %esp,%ebp
  8024a3:	57                   	push   %edi
  8024a4:	56                   	push   %esi
  8024a5:	83 ec 18             	sub    $0x18,%esp
  8024a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8024ab:	8b 55 14             	mov    0x14(%ebp),%edx
  8024ae:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8024b4:	89 c1                	mov    %eax,%ecx
  8024b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8024b9:	85 d2                	test   %edx,%edx
  8024bb:	89 d7                	mov    %edx,%edi
  8024bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8024c0:	75 1e                	jne    8024e0 <__udivdi3+0x40>
  8024c2:	39 f1                	cmp    %esi,%ecx
  8024c4:	0f 86 8d 00 00 00    	jbe    802557 <__udivdi3+0xb7>
  8024ca:	89 f2                	mov    %esi,%edx
  8024cc:	31 f6                	xor    %esi,%esi
  8024ce:	f7 f1                	div    %ecx
  8024d0:	89 c1                	mov    %eax,%ecx
  8024d2:	89 c8                	mov    %ecx,%eax
  8024d4:	89 f2                	mov    %esi,%edx
  8024d6:	83 c4 18             	add    $0x18,%esp
  8024d9:	5e                   	pop    %esi
  8024da:	5f                   	pop    %edi
  8024db:	5d                   	pop    %ebp
  8024dc:	c3                   	ret    
  8024dd:	8d 76 00             	lea    0x0(%esi),%esi
  8024e0:	39 f2                	cmp    %esi,%edx
  8024e2:	0f 87 a8 00 00 00    	ja     802590 <__udivdi3+0xf0>
  8024e8:	0f bd c2             	bsr    %edx,%eax
  8024eb:	83 f0 1f             	xor    $0x1f,%eax
  8024ee:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8024f1:	0f 84 89 00 00 00    	je     802580 <__udivdi3+0xe0>
  8024f7:	b8 20 00 00 00       	mov    $0x20,%eax
  8024fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8024ff:	2b 45 e8             	sub    -0x18(%ebp),%eax
  802502:	89 c1                	mov    %eax,%ecx
  802504:	d3 ea                	shr    %cl,%edx
  802506:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  80250a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80250d:	89 f8                	mov    %edi,%eax
  80250f:	8b 7d f4             	mov    -0xc(%ebp),%edi
  802512:	d3 e0                	shl    %cl,%eax
  802514:	09 c2                	or     %eax,%edx
  802516:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802519:	d3 e7                	shl    %cl,%edi
  80251b:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80251f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802522:	89 f2                	mov    %esi,%edx
  802524:	d3 e8                	shr    %cl,%eax
  802526:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  80252a:	d3 e2                	shl    %cl,%edx
  80252c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802530:	09 d0                	or     %edx,%eax
  802532:	d3 ee                	shr    %cl,%esi
  802534:	89 f2                	mov    %esi,%edx
  802536:	f7 75 e4             	divl   -0x1c(%ebp)
  802539:	89 d1                	mov    %edx,%ecx
  80253b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80253e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802541:	f7 e7                	mul    %edi
  802543:	39 d1                	cmp    %edx,%ecx
  802545:	89 c6                	mov    %eax,%esi
  802547:	72 70                	jb     8025b9 <__udivdi3+0x119>
  802549:	39 ca                	cmp    %ecx,%edx
  80254b:	74 5f                	je     8025ac <__udivdi3+0x10c>
  80254d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802550:	31 f6                	xor    %esi,%esi
  802552:	e9 7b ff ff ff       	jmp    8024d2 <__udivdi3+0x32>
  802557:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80255a:	85 c0                	test   %eax,%eax
  80255c:	75 0c                	jne    80256a <__udivdi3+0xca>
  80255e:	b8 01 00 00 00       	mov    $0x1,%eax
  802563:	31 d2                	xor    %edx,%edx
  802565:	f7 75 f4             	divl   -0xc(%ebp)
  802568:	89 c1                	mov    %eax,%ecx
  80256a:	89 f0                	mov    %esi,%eax
  80256c:	89 fa                	mov    %edi,%edx
  80256e:	f7 f1                	div    %ecx
  802570:	89 c6                	mov    %eax,%esi
  802572:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802575:	f7 f1                	div    %ecx
  802577:	89 c1                	mov    %eax,%ecx
  802579:	e9 54 ff ff ff       	jmp    8024d2 <__udivdi3+0x32>
  80257e:	66 90                	xchg   %ax,%ax
  802580:	39 d6                	cmp    %edx,%esi
  802582:	77 1c                	ja     8025a0 <__udivdi3+0x100>
  802584:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802587:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  80258a:	73 14                	jae    8025a0 <__udivdi3+0x100>
  80258c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802590:	31 c9                	xor    %ecx,%ecx
  802592:	31 f6                	xor    %esi,%esi
  802594:	e9 39 ff ff ff       	jmp    8024d2 <__udivdi3+0x32>
  802599:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  8025a0:	b9 01 00 00 00       	mov    $0x1,%ecx
  8025a5:	31 f6                	xor    %esi,%esi
  8025a7:	e9 26 ff ff ff       	jmp    8024d2 <__udivdi3+0x32>
  8025ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8025af:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  8025b3:	d3 e0                	shl    %cl,%eax
  8025b5:	39 c6                	cmp    %eax,%esi
  8025b7:	76 94                	jbe    80254d <__udivdi3+0xad>
  8025b9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8025bc:	31 f6                	xor    %esi,%esi
  8025be:	83 e9 01             	sub    $0x1,%ecx
  8025c1:	e9 0c ff ff ff       	jmp    8024d2 <__udivdi3+0x32>
	...

008025d0 <__umoddi3>:
  8025d0:	55                   	push   %ebp
  8025d1:	89 e5                	mov    %esp,%ebp
  8025d3:	57                   	push   %edi
  8025d4:	56                   	push   %esi
  8025d5:	83 ec 30             	sub    $0x30,%esp
  8025d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8025db:	8b 55 14             	mov    0x14(%ebp),%edx
  8025de:	8b 75 08             	mov    0x8(%ebp),%esi
  8025e1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8025e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8025e7:	89 c1                	mov    %eax,%ecx
  8025e9:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8025ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8025ef:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8025f6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8025fd:	89 fa                	mov    %edi,%edx
  8025ff:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  802602:	85 c0                	test   %eax,%eax
  802604:	89 75 f0             	mov    %esi,-0x10(%ebp)
  802607:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80260a:	75 14                	jne    802620 <__umoddi3+0x50>
  80260c:	39 f9                	cmp    %edi,%ecx
  80260e:	76 60                	jbe    802670 <__umoddi3+0xa0>
  802610:	89 f0                	mov    %esi,%eax
  802612:	f7 f1                	div    %ecx
  802614:	89 55 d0             	mov    %edx,-0x30(%ebp)
  802617:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80261e:	eb 10                	jmp    802630 <__umoddi3+0x60>
  802620:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802623:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  802626:	76 18                	jbe    802640 <__umoddi3+0x70>
  802628:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80262b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80262e:	66 90                	xchg   %ax,%ax
  802630:	8b 45 d0             	mov    -0x30(%ebp),%eax
  802633:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  802636:	83 c4 30             	add    $0x30,%esp
  802639:	5e                   	pop    %esi
  80263a:	5f                   	pop    %edi
  80263b:	5d                   	pop    %ebp
  80263c:	c3                   	ret    
  80263d:	8d 76 00             	lea    0x0(%esi),%esi
  802640:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
  802644:	83 f0 1f             	xor    $0x1f,%eax
  802647:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80264a:	75 46                	jne    802692 <__umoddi3+0xc2>
  80264c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80264f:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  802652:	0f 87 c9 00 00 00    	ja     802721 <__umoddi3+0x151>
  802658:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  80265b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80265e:	0f 83 bd 00 00 00    	jae    802721 <__umoddi3+0x151>
  802664:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802667:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80266a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80266d:	eb c1                	jmp    802630 <__umoddi3+0x60>
  80266f:	90                   	nop    
  802670:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802673:	85 c0                	test   %eax,%eax
  802675:	75 0c                	jne    802683 <__umoddi3+0xb3>
  802677:	b8 01 00 00 00       	mov    $0x1,%eax
  80267c:	31 d2                	xor    %edx,%edx
  80267e:	f7 75 ec             	divl   -0x14(%ebp)
  802681:	89 c1                	mov    %eax,%ecx
  802683:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802686:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802689:	f7 f1                	div    %ecx
  80268b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80268e:	f7 f1                	div    %ecx
  802690:	eb 82                	jmp    802614 <__umoddi3+0x44>
  802692:	b8 20 00 00 00       	mov    $0x20,%eax
  802697:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80269a:	2b 45 d8             	sub    -0x28(%ebp),%eax
  80269d:	8b 75 ec             	mov    -0x14(%ebp),%esi
  8026a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8026a3:	89 c1                	mov    %eax,%ecx
  8026a5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8026a8:	d3 ea                	shr    %cl,%edx
  8026aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8026ad:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8026b1:	d3 e0                	shl    %cl,%eax
  8026b3:	09 c2                	or     %eax,%edx
  8026b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8026b8:	d3 e6                	shl    %cl,%esi
  8026ba:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  8026be:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8026c1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8026c4:	d3 e8                	shr    %cl,%eax
  8026c6:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8026ca:	d3 e2                	shl    %cl,%edx
  8026cc:	09 d0                	or     %edx,%eax
  8026ce:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8026d1:	d3 e7                	shl    %cl,%edi
  8026d3:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  8026d7:	d3 ea                	shr    %cl,%edx
  8026d9:	f7 75 f4             	divl   -0xc(%ebp)
  8026dc:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8026df:	f7 e6                	mul    %esi
  8026e1:	39 55 cc             	cmp    %edx,-0x34(%ebp)
  8026e4:	72 53                	jb     802739 <__umoddi3+0x169>
  8026e6:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  8026e9:	74 4a                	je     802735 <__umoddi3+0x165>
  8026eb:	90                   	nop    
  8026ec:	8d 74 26 00          	lea    0x0(%esi),%esi
  8026f0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8026f3:	29 c7                	sub    %eax,%edi
  8026f5:	19 d1                	sbb    %edx,%ecx
  8026f7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8026fa:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8026fe:	89 fa                	mov    %edi,%edx
  802700:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802703:	d3 ea                	shr    %cl,%edx
  802705:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  802709:	d3 e0                	shl    %cl,%eax
  80270b:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  80270f:	09 c2                	or     %eax,%edx
  802711:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802714:	89 55 d0             	mov    %edx,-0x30(%ebp)
  802717:	d3 e8                	shr    %cl,%eax
  802719:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80271c:	e9 0f ff ff ff       	jmp    802630 <__umoddi3+0x60>
  802721:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802724:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802727:	2b 45 ec             	sub    -0x14(%ebp),%eax
  80272a:	1b 55 e8             	sbb    -0x18(%ebp),%edx
  80272d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802730:	e9 2f ff ff ff       	jmp    802664 <__umoddi3+0x94>
  802735:	39 f8                	cmp    %edi,%eax
  802737:	76 b7                	jbe    8026f0 <__umoddi3+0x120>
  802739:	29 f0                	sub    %esi,%eax
  80273b:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  80273e:	eb b0                	jmp    8026f0 <__umoddi3+0x120>
