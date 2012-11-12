
obj/user/httpd:     file format elf32-i386

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
  80002c:	e8 0b 03 00 00       	call   80033c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <die>:
	{404, "Not Found"},
};

static void
die(char *m)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 08             	sub    $0x8,%esp
	cprintf("%s\n", m);
  80003a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80003e:	c7 04 24 20 2b 80 00 	movl   $0x802b20,(%esp)
  800045:	e8 37 04 00 00       	call   800481 <cprintf>
	exit();
  80004a:	e8 49 03 00 00       	call   800398 <exit>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    

00800051 <umain>:
	close(sock);
}

int
umain(void)
{
  800051:	55                   	push   %ebp
  800052:	89 e5                	mov    %esp,%ebp
  800054:	57                   	push   %edi
  800055:	56                   	push   %esi
  800056:	53                   	push   %ebx
  800057:	81 ec 4c 04 00 00    	sub    $0x44c,%esp
	int serversock, clientsock;
	struct sockaddr_in server, client;

	binaryname = "jhttpd";
  80005d:	c7 05 20 70 80 00 24 	movl   $0x802b24,0x807020
  800064:	2b 80 00 

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  800067:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800076:	00 
  800077:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80007e:	e8 a2 1c 00 00       	call   801d25 <socket>
  800083:	89 c7                	mov    %eax,%edi
  800085:	85 c0                	test   %eax,%eax
  800087:	79 0a                	jns    800093 <umain+0x42>
		die("Failed to create socket");
  800089:	b8 2b 2b 80 00       	mov    $0x802b2b,%eax
  80008e:	e8 a1 ff ff ff       	call   800034 <die>

	// Construct the server sockaddr_in structure
	memset(&server, 0, sizeof(server));		// Clear struct
  800093:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  80009a:	00 
  80009b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000a2:	00 
  8000a3:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  8000a6:	89 1c 24             	mov    %ebx,(%esp)
  8000a9:	e8 e0 0b 00 00       	call   800c8e <memset>
	server.sin_family = AF_INET;			// Internet/IP
  8000ae:	c6 45 e5 02          	movb   $0x2,-0x1b(%ebp)
	server.sin_addr.s_addr = htonl(INADDR_ANY);	// IP address
  8000b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b9:	e8 5e 25 00 00       	call   80261c <htonl>
  8000be:	89 45 e8             	mov    %eax,-0x18(%ebp)
	server.sin_port = htons(PORT);			// server port
  8000c1:	c7 04 24 50 00 00 00 	movl   $0x50,(%esp)
  8000c8:	e8 22 25 00 00       	call   8025ef <htons>
  8000cd:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)

	// Bind the server socket
	if (bind(serversock, (struct sockaddr *) &server,
  8000d1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  8000d8:	00 
  8000d9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000dd:	89 3c 24             	mov    %edi,(%esp)
  8000e0:	e8 10 1d 00 00       	call   801df5 <bind>
  8000e5:	85 c0                	test   %eax,%eax
  8000e7:	79 0a                	jns    8000f3 <umain+0xa2>
		 sizeof(server)) < 0) 
	{
		die("Failed to bind the server socket");
  8000e9:	b8 94 2b 80 00       	mov    $0x802b94,%eax
  8000ee:	e8 41 ff ff ff       	call   800034 <die>
	}

	// Listen on the server socket
	if (listen(serversock, MAXPENDING) < 0)
  8000f3:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  8000fa:	00 
  8000fb:	89 3c 24             	mov    %edi,(%esp)
  8000fe:	e8 82 1c 00 00       	call   801d85 <listen>
  800103:	85 c0                	test   %eax,%eax
  800105:	79 0a                	jns    800111 <umain+0xc0>
		die("Failed to listen on server socket");
  800107:	b8 b8 2b 80 00       	mov    $0x802bb8,%eax
  80010c:	e8 23 ff ff ff       	call   800034 <die>

	cprintf("Waiting for http connections...\n");
  800111:	c7 04 24 dc 2b 80 00 	movl   $0x802bdc,(%esp)
  800118:	e8 64 03 00 00       	call   800481 <cprintf>

	while (1) {
		unsigned int clientlen = sizeof(client);
  80011d:	c7 45 d0 10 00 00 00 	movl   $0x10,-0x30(%ebp)
		// Wait for client connection
		if ((clientsock = accept(serversock,
  800124:	8d 45 d0             	lea    -0x30(%ebp),%eax
  800127:	89 44 24 08          	mov    %eax,0x8(%esp)
  80012b:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  80012e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800132:	89 3c 24             	mov    %edi,(%esp)
  800135:	e8 e5 1c 00 00       	call   801e1f <accept>
  80013a:	89 c6                	mov    %eax,%esi
  80013c:	85 c0                	test   %eax,%eax
  80013e:	79 0a                	jns    80014a <umain+0xf9>
					 (struct sockaddr *) &client,
					 &clientlen)) < 0) 
		{
			die("Failed to accept client connection");
  800140:	b8 00 2c 80 00       	mov    $0x802c00,%eax
  800145:	e8 ea fe ff ff       	call   800034 <die>
	struct http_request *req = &con_d;

	while (1) 
	{
		// Receive message
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  80014a:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800151:	00 
  800152:	8d 85 c4 fd ff ff    	lea    -0x23c(%ebp),%eax
  800158:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015c:	89 34 24             	mov    %esi,(%esp)
  80015f:	e8 c4 14 00 00       	call   801628 <read>
  800164:	85 c0                	test   %eax,%eax
  800166:	79 1c                	jns    800184 <umain+0x133>
			panic("failed to read");
  800168:	c7 44 24 08 43 2b 80 	movl   $0x802b43,0x8(%esp)
  80016f:	00 
  800170:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
  800177:	00 
  800178:	c7 04 24 52 2b 80 00 	movl   $0x802b52,(%esp)
  80017f:	e8 30 02 00 00       	call   8003b4 <_panic>

		memset(req, 0, sizeof(req));
  800184:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  80018b:	00 
  80018c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800193:	00 
  800194:	8d 45 c4             	lea    -0x3c(%ebp),%eax
  800197:	89 04 24             	mov    %eax,(%esp)
  80019a:	e8 ef 0a 00 00       	call   800c8e <memset>

		req->sock = sock;
  80019f:	89 75 c4             	mov    %esi,-0x3c(%ebp)
	int url_len, version_len;

	if (!req)
		return -1;

	if (strncmp(request, "GET ", 4) != 0)
  8001a2:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  8001a9:	00 
  8001aa:	c7 44 24 04 5f 2b 80 	movl   $0x802b5f,0x4(%esp)
  8001b1:	00 
  8001b2:	8d 85 c4 fd ff ff    	lea    -0x23c(%ebp),%eax
  8001b8:	89 04 24             	mov    %eax,(%esp)
  8001bb:	e8 31 0a 00 00       	call   800bf1 <strncmp>
  8001c0:	85 c0                	test   %eax,%eax
  8001c2:	74 3b                	je     8001ff <umain+0x1ae>
{
	char buf[512];
	int r;

	struct error_messages *e = errors;
	while (e->code != 0 && e->msg != 0) {
  8001c4:	8b 15 10 70 80 00    	mov    0x807010,%edx
  8001ca:	85 d2                	test   %edx,%edx
  8001cc:	0f 84 46 01 00 00    	je     800318 <umain+0x2c7>
  8001d2:	b8 10 70 80 00       	mov    $0x807010,%eax
  8001d7:	83 3d 14 70 80 00 00 	cmpl   $0x0,0x807014
  8001de:	0f 84 f0 00 00 00    	je     8002d4 <umain+0x283>
		if (e->code == code)
  8001e4:	b8 10 70 80 00       	mov    $0x807010,%eax
  8001e9:	81 fa 90 01 00 00    	cmp    $0x190,%edx
  8001ef:	0f 84 df 00 00 00    	je     8002d4 <umain+0x283>
  8001f5:	b8 10 70 80 00       	mov    $0x807010,%eax
  8001fa:	e9 c6 00 00 00       	jmp    8002c5 <umain+0x274>
	// skip GET
	request += 4;

	// get the url
	url = request;
	while (*request && *request != ' ')
  8001ff:	0f b6 85 c8 fd ff ff 	movzbl -0x238(%ebp),%eax
  800206:	84 c0                	test   %al,%al
  800208:	74 0a                	je     800214 <umain+0x1c3>
  80020a:	8d bd c8 fd ff ff    	lea    -0x238(%ebp),%edi
  800210:	3c 20                	cmp    $0x20,%al
  800212:	75 08                	jne    80021c <umain+0x1cb>
  800214:	8d bd c8 fd ff ff    	lea    -0x238(%ebp),%edi
  80021a:	eb 0e                	jmp    80022a <umain+0x1d9>
		request++;
  80021c:	83 c7 01             	add    $0x1,%edi
	// skip GET
	request += 4;

	// get the url
	url = request;
	while (*request && *request != ' ')
  80021f:	0f b6 07             	movzbl (%edi),%eax
  800222:	84 c0                	test   %al,%al
  800224:	74 04                	je     80022a <umain+0x1d9>
  800226:	3c 20                	cmp    $0x20,%al
  800228:	75 f2                	jne    80021c <umain+0x1cb>
		request++;
	url_len = request - url;
  80022a:	8d b5 c8 fd ff ff    	lea    -0x238(%ebp),%esi
  800230:	89 fb                	mov    %edi,%ebx
  800232:	29 f3                	sub    %esi,%ebx

	req->url = malloc(url_len + 1);
  800234:	8d 43 01             	lea    0x1(%ebx),%eax
  800237:	89 04 24             	mov    %eax,(%esp)
  80023a:	e8 85 1f 00 00       	call   8021c4 <malloc>
  80023f:	89 45 c8             	mov    %eax,-0x38(%ebp)
	memmove(req->url, url, url_len);
  800242:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800246:	89 74 24 04          	mov    %esi,0x4(%esp)
  80024a:	89 04 24             	mov    %eax,(%esp)
  80024d:	e8 96 0a 00 00       	call   800ce8 <memmove>
	req->url[url_len] = '\0';
  800252:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800255:	c6 04 18 00          	movb   $0x0,(%eax,%ebx,1)

	// skip space
	request++;
  800259:	8d 57 01             	lea    0x1(%edi),%edx

	version = request;
  80025c:	89 d6                	mov    %edx,%esi
	while (*request && *request != '\n')
  80025e:	0f b6 47 01          	movzbl 0x1(%edi),%eax
  800262:	84 c0                	test   %al,%al
  800264:	74 12                	je     800278 <umain+0x227>
  800266:	3c 0a                	cmp    $0xa,%al
  800268:	74 0e                	je     800278 <umain+0x227>
		request++;
  80026a:	83 c2 01             	add    $0x1,%edx

	// skip space
	request++;

	version = request;
	while (*request && *request != '\n')
  80026d:	0f b6 02             	movzbl (%edx),%eax
  800270:	84 c0                	test   %al,%al
  800272:	74 04                	je     800278 <umain+0x227>
  800274:	3c 0a                	cmp    $0xa,%al
  800276:	75 f2                	jne    80026a <umain+0x219>
		request++;
	version_len = request - version;
  800278:	89 d3                	mov    %edx,%ebx
  80027a:	29 f3                	sub    %esi,%ebx

	req->version = malloc(version_len + 1);
  80027c:	8d 43 01             	lea    0x1(%ebx),%eax
  80027f:	89 04 24             	mov    %eax,(%esp)
  800282:	e8 3d 1f 00 00       	call   8021c4 <malloc>
  800287:	89 45 cc             	mov    %eax,-0x34(%ebp)
	memmove(req->version, version, version_len);
  80028a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80028e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800292:	89 04 24             	mov    %eax,(%esp)
  800295:	e8 4e 0a 00 00       	call   800ce8 <memmove>
	req->version[version_len] = '\0';
  80029a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80029d:	c6 04 18 00          	movb   $0x0,(%eax,%ebx,1)
	// if the file does not exist, send a 404 error using send_error
	// if the file is a directory, send a 404 error using send_error
	// set file_size to the size of the file

	// LAB 6: Your code here.
	panic("send_file not implemented");
  8002a1:	c7 44 24 08 64 2b 80 	movl   $0x802b64,0x8(%esp)
  8002a8:	00 
  8002a9:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
  8002b0:	00 
  8002b1:	c7 04 24 52 2b 80 00 	movl   $0x802b52,(%esp)
  8002b8:	e8 f7 00 00 00       	call   8003b4 <_panic>
	char buf[512];
	int r;

	struct error_messages *e = errors;
	while (e->code != 0 && e->msg != 0) {
		if (e->code == code)
  8002bd:	81 fa 90 01 00 00    	cmp    $0x190,%edx
  8002c3:	74 0f                	je     8002d4 <umain+0x283>
			break;
		e++;
  8002c5:	83 c0 08             	add    $0x8,%eax
{
	char buf[512];
	int r;

	struct error_messages *e = errors;
	while (e->code != 0 && e->msg != 0) {
  8002c8:	8b 10                	mov    (%eax),%edx
  8002ca:	85 d2                	test   %edx,%edx
  8002cc:	74 4a                	je     800318 <umain+0x2c7>
  8002ce:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
  8002d2:	75 e9                	jne    8002bd <umain+0x26c>
	}
	
	if (e->code == 0)
		return -1;

	r = snprintf(buf, 512, "HTTP/" HTTP_VERSION" %d %s\r\n"
  8002d4:	8b 40 04             	mov    0x4(%eax),%eax
  8002d7:	89 44 24 18          	mov    %eax,0x18(%esp)
  8002db:	89 54 24 14          	mov    %edx,0x14(%esp)
  8002df:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002e3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002e7:	c7 44 24 08 24 2c 80 	movl   $0x802c24,0x8(%esp)
  8002ee:	00 
  8002ef:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
  8002f6:	00 
  8002f7:	8d 9d c4 fb ff ff    	lea    -0x43c(%ebp),%ebx
  8002fd:	89 1c 24             	mov    %ebx,(%esp)
  800300:	e8 35 07 00 00       	call   800a3a <snprintf>
			       "Content-type: text/html\r\n"
			       "\r\n"
			       "<html><body><p>%d - %s</p></body></html>\r\n",
			       e->code, e->msg, e->code, e->msg);

	if (write(req->sock, buf, r) != r)
  800305:	89 44 24 08          	mov    %eax,0x8(%esp)
  800309:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80030d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800310:	89 04 24             	mov    %eax,(%esp)
  800313:	e8 85 12 00 00       	call   80159d <write>
}

static void
req_free(struct http_request *req)
{
	free(req->url);
  800318:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80031b:	89 04 24             	mov    %eax,(%esp)
  80031e:	e8 cd 1d 00 00       	call   8020f0 <free>
	free(req->version);
  800323:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800326:	89 04 24             	mov    %eax,(%esp)
  800329:	e8 c2 1d 00 00       	call   8020f0 <free>

		// no keep alive
		break;
	}

	close(sock);
  80032e:	89 34 24             	mov    %esi,(%esp)
  800331:	e8 5f 14 00 00       	call   801795 <close>
  800336:	e9 e2 fd ff ff       	jmp    80011d <umain+0xcc>
	...

0080033c <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	83 ec 18             	sub    $0x18,%esp
  800342:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800345:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800348:	8b 75 08             	mov    0x8(%ebp),%esi
  80034b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  80034e:	c7 05 70 70 80 00 00 	movl   $0x0,0x807070
  800355:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  800358:	e8 50 0f 00 00       	call   8012ad <sys_getenvid>
  80035d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800362:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800365:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80036a:	a3 70 70 80 00       	mov    %eax,0x807070
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80036f:	85 f6                	test   %esi,%esi
  800371:	7e 07                	jle    80037a <libmain+0x3e>
		binaryname = argv[0];
  800373:	8b 03                	mov    (%ebx),%eax
  800375:	a3 20 70 80 00       	mov    %eax,0x807020

	// call user main routine
	umain(argc, argv);
  80037a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80037e:	89 34 24             	mov    %esi,(%esp)
  800381:	e8 cb fc ff ff       	call   800051 <umain>

	// exit gracefully
	exit();
  800386:	e8 0d 00 00 00       	call   800398 <exit>
}
  80038b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80038e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800391:	89 ec                	mov    %ebp,%esp
  800393:	5d                   	pop    %ebp
  800394:	c3                   	ret    
  800395:	00 00                	add    %al,(%eax)
	...

00800398 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
  80039b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80039e:	e8 8d 15 00 00       	call   801930 <close_all>
	sys_env_destroy(0);
  8003a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003aa:	e8 32 0f 00 00       	call   8012e1 <sys_env_destroy>
}
  8003af:	c9                   	leave  
  8003b0:	c3                   	ret    
  8003b1:	00 00                	add    %al,(%eax)
	...

008003b4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
  8003b7:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8003bd:	89 45 fc             	mov    %eax,-0x4(%ebp)

	// Print the panic message
	if (argv0)
  8003c0:	a1 74 70 80 00       	mov    0x807074,%eax
  8003c5:	85 c0                	test   %eax,%eax
  8003c7:	74 10                	je     8003d9 <_panic+0x25>
		cprintf("%s: ", argv0);
  8003c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003cd:	c7 04 24 dd 2c 80 00 	movl   $0x802cdd,(%esp)
  8003d4:	e8 a8 00 00 00       	call   800481 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8003d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003e7:	a1 20 70 80 00       	mov    0x807020,%eax
  8003ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f0:	c7 04 24 e2 2c 80 00 	movl   $0x802ce2,(%esp)
  8003f7:	e8 85 00 00 00       	call   800481 <cprintf>
	vcprintf(fmt, ap);
  8003fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8003ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800403:	8b 45 10             	mov    0x10(%ebp),%eax
  800406:	89 04 24             	mov    %eax,(%esp)
  800409:	e8 12 00 00 00       	call   800420 <vcprintf>
	cprintf("\n");
  80040e:	c7 04 24 a6 31 80 00 	movl   $0x8031a6,(%esp)
  800415:	e8 67 00 00 00       	call   800481 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80041a:	cc                   	int3   
  80041b:	eb fd                	jmp    80041a <_panic+0x66>
  80041d:	00 00                	add    %al,(%eax)
	...

00800420 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800429:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  800430:	00 00 00 
	b.cnt = 0;
  800433:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  80043a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80043d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800440:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800444:	8b 45 08             	mov    0x8(%ebp),%eax
  800447:	89 44 24 08          	mov    %eax,0x8(%esp)
  80044b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800451:	89 44 24 04          	mov    %eax,0x4(%esp)
  800455:	c7 04 24 9e 04 80 00 	movl   $0x80049e,(%esp)
  80045c:	e8 c4 01 00 00       	call   800625 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800461:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
  800467:	89 44 24 04          	mov    %eax,0x4(%esp)
  80046b:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  800471:	89 04 24             	mov    %eax,(%esp)
  800474:	e8 cf 0a 00 00       	call   800f48 <sys_cputs>
  800479:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  80047f:	c9                   	leave  
  800480:	c3                   	ret    

00800481 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800481:	55                   	push   %ebp
  800482:	89 e5                	mov    %esp,%ebp
  800484:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800487:	8d 45 0c             	lea    0xc(%ebp),%eax
  80048a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  80048d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800491:	8b 45 08             	mov    0x8(%ebp),%eax
  800494:	89 04 24             	mov    %eax,(%esp)
  800497:	e8 84 ff ff ff       	call   800420 <vcprintf>
	va_end(ap);

	return cnt;
}
  80049c:	c9                   	leave  
  80049d:	c3                   	ret    

0080049e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80049e:	55                   	push   %ebp
  80049f:	89 e5                	mov    %esp,%ebp
  8004a1:	53                   	push   %ebx
  8004a2:	83 ec 14             	sub    $0x14,%esp
  8004a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004a8:	8b 03                	mov    (%ebx),%eax
  8004aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8004ad:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004b1:	83 c0 01             	add    $0x1,%eax
  8004b4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004bb:	75 19                	jne    8004d6 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004bd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004c4:	00 
  8004c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8004c8:	89 04 24             	mov    %eax,(%esp)
  8004cb:	e8 78 0a 00 00       	call   800f48 <sys_cputs>
		b->idx = 0;
  8004d0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004d6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004da:	83 c4 14             	add    $0x14,%esp
  8004dd:	5b                   	pop    %ebx
  8004de:	5d                   	pop    %ebp
  8004df:	c3                   	ret    

008004e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	57                   	push   %edi
  8004e4:	56                   	push   %esi
  8004e5:	53                   	push   %ebx
  8004e6:	83 ec 3c             	sub    $0x3c,%esp
  8004e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ec:	89 d7                	mov    %edx,%edi
  8004ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004fa:	8b 55 10             	mov    0x10(%ebp),%edx
  8004fd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800500:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800503:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  80050a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80050d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  800510:	72 14                	jb     800526 <printnum+0x46>
  800512:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800515:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800518:	76 0c                	jbe    800526 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80051a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80051d:	83 eb 01             	sub    $0x1,%ebx
  800520:	85 db                	test   %ebx,%ebx
  800522:	7f 57                	jg     80057b <printnum+0x9b>
  800524:	eb 64                	jmp    80058a <printnum+0xaa>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800526:	89 74 24 10          	mov    %esi,0x10(%esp)
  80052a:	8b 45 14             	mov    0x14(%ebp),%eax
  80052d:	83 e8 01             	sub    $0x1,%eax
  800530:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800534:	89 54 24 08          	mov    %edx,0x8(%esp)
  800538:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80053c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800540:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800543:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800546:	89 44 24 08          	mov    %eax,0x8(%esp)
  80054a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80054e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800551:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800554:	89 04 24             	mov    %eax,(%esp)
  800557:	89 54 24 04          	mov    %edx,0x4(%esp)
  80055b:	e8 10 23 00 00       	call   802870 <__udivdi3>
  800560:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800564:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800568:	89 04 24             	mov    %eax,(%esp)
  80056b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80056f:	89 fa                	mov    %edi,%edx
  800571:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800574:	e8 67 ff ff ff       	call   8004e0 <printnum>
  800579:	eb 0f                	jmp    80058a <printnum+0xaa>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80057b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80057f:	89 34 24             	mov    %esi,(%esp)
  800582:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800585:	83 eb 01             	sub    $0x1,%ebx
  800588:	75 f1                	jne    80057b <printnum+0x9b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80058a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80058e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800592:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800595:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800598:	89 44 24 08          	mov    %eax,0x8(%esp)
  80059c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005a0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005a3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005a6:	89 04 24             	mov    %eax,(%esp)
  8005a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005ad:	e8 ee 23 00 00       	call   8029a0 <__umoddi3>
  8005b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005b6:	0f be 80 fe 2c 80 00 	movsbl 0x802cfe(%eax),%eax
  8005bd:	89 04 24             	mov    %eax,(%esp)
  8005c0:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8005c3:	83 c4 3c             	add    $0x3c,%esp
  8005c6:	5b                   	pop    %ebx
  8005c7:	5e                   	pop    %esi
  8005c8:	5f                   	pop    %edi
  8005c9:	5d                   	pop    %ebp
  8005ca:	c3                   	ret    

008005cb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005cb:	55                   	push   %ebp
  8005cc:	89 e5                	mov    %esp,%ebp
  8005ce:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8005d0:	83 fa 01             	cmp    $0x1,%edx
  8005d3:	7e 0e                	jle    8005e3 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8005d5:	8b 10                	mov    (%eax),%edx
  8005d7:	8d 42 08             	lea    0x8(%edx),%eax
  8005da:	89 01                	mov    %eax,(%ecx)
  8005dc:	8b 02                	mov    (%edx),%eax
  8005de:	8b 52 04             	mov    0x4(%edx),%edx
  8005e1:	eb 22                	jmp    800605 <getuint+0x3a>
	else if (lflag)
  8005e3:	85 d2                	test   %edx,%edx
  8005e5:	74 10                	je     8005f7 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8005e7:	8b 10                	mov    (%eax),%edx
  8005e9:	8d 42 04             	lea    0x4(%edx),%eax
  8005ec:	89 01                	mov    %eax,(%ecx)
  8005ee:	8b 02                	mov    (%edx),%eax
  8005f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8005f5:	eb 0e                	jmp    800605 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  8005f7:	8b 10                	mov    (%eax),%edx
  8005f9:	8d 42 04             	lea    0x4(%edx),%eax
  8005fc:	89 01                	mov    %eax,(%ecx)
  8005fe:	8b 02                	mov    (%edx),%eax
  800600:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800605:	5d                   	pop    %ebp
  800606:	c3                   	ret    

00800607 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800607:	55                   	push   %ebp
  800608:	89 e5                	mov    %esp,%ebp
  80060a:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  80060d:	83 42 08 01          	addl   $0x1,0x8(%edx)
	if (b->buf < b->ebuf)
  800611:	8b 02                	mov    (%edx),%eax
  800613:	3b 42 04             	cmp    0x4(%edx),%eax
  800616:	73 0b                	jae    800623 <sprintputch+0x1c>
		*b->buf++ = ch;
  800618:	0f b6 4d 08          	movzbl 0x8(%ebp),%ecx
  80061c:	88 08                	mov    %cl,(%eax)
  80061e:	83 c0 01             	add    $0x1,%eax
  800621:	89 02                	mov    %eax,(%edx)
}
  800623:	5d                   	pop    %ebp
  800624:	c3                   	ret    

00800625 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800625:	55                   	push   %ebp
  800626:	89 e5                	mov    %esp,%ebp
  800628:	57                   	push   %edi
  800629:	56                   	push   %esi
  80062a:	53                   	push   %ebx
  80062b:	83 ec 3c             	sub    $0x3c,%esp
  80062e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800631:	eb 18                	jmp    80064b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800633:	84 c0                	test   %al,%al
  800635:	0f 84 9f 03 00 00    	je     8009da <vprintfmt+0x3b5>
				return;
			putch(ch, putdat);
  80063b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80063e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800642:	0f b6 c0             	movzbl %al,%eax
  800645:	89 04 24             	mov    %eax,(%esp)
  800648:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80064b:	0f b6 03             	movzbl (%ebx),%eax
  80064e:	83 c3 01             	add    $0x1,%ebx
  800651:	3c 25                	cmp    $0x25,%al
  800653:	75 de                	jne    800633 <vprintfmt+0xe>
  800655:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065a:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
  800661:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800666:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80066d:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
  800671:	eb 07                	jmp    80067a <vprintfmt+0x55>
  800673:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067a:	0f b6 13             	movzbl (%ebx),%edx
  80067d:	83 c3 01             	add    $0x1,%ebx
  800680:	8d 42 dd             	lea    -0x23(%edx),%eax
  800683:	3c 55                	cmp    $0x55,%al
  800685:	0f 87 22 03 00 00    	ja     8009ad <vprintfmt+0x388>
  80068b:	0f b6 c0             	movzbl %al,%eax
  80068e:	ff 24 85 40 2e 80 00 	jmp    *0x802e40(,%eax,4)
  800695:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
  800699:	eb df                	jmp    80067a <vprintfmt+0x55>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80069b:	0f b6 c2             	movzbl %dl,%eax
  80069e:	8d 78 d0             	lea    -0x30(%eax),%edi
				ch = *fmt;
  8006a1:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  8006a4:	8d 42 d0             	lea    -0x30(%edx),%eax
  8006a7:	83 f8 09             	cmp    $0x9,%eax
  8006aa:	76 08                	jbe    8006b4 <vprintfmt+0x8f>
  8006ac:	eb 39                	jmp    8006e7 <vprintfmt+0xc2>
  8006ae:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
  8006b2:	eb c6                	jmp    80067a <vprintfmt+0x55>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006b4:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  8006b7:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  8006ba:	8d 7c 42 d0          	lea    -0x30(%edx,%eax,2),%edi
				ch = *fmt;
  8006be:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  8006c1:	8d 42 d0             	lea    -0x30(%edx),%eax
  8006c4:	83 f8 09             	cmp    $0x9,%eax
  8006c7:	77 1e                	ja     8006e7 <vprintfmt+0xc2>
  8006c9:	eb e9                	jmp    8006b4 <vprintfmt+0x8f>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006cb:	8b 55 14             	mov    0x14(%ebp),%edx
  8006ce:	8d 42 04             	lea    0x4(%edx),%eax
  8006d1:	89 45 14             	mov    %eax,0x14(%ebp)
  8006d4:	8b 3a                	mov    (%edx),%edi
  8006d6:	eb 0f                	jmp    8006e7 <vprintfmt+0xc2>
			goto process_precision;

		case '.':
			if (width < 0)
  8006d8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8006dc:	79 9c                	jns    80067a <vprintfmt+0x55>
  8006de:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8006e5:	eb 93                	jmp    80067a <vprintfmt+0x55>
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8006e7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8006eb:	90                   	nop    
  8006ec:	8d 74 26 00          	lea    0x0(%esi),%esi
  8006f0:	79 88                	jns    80067a <vprintfmt+0x55>
  8006f2:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8006f5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8006fa:	e9 7b ff ff ff       	jmp    80067a <vprintfmt+0x55>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006ff:	83 c1 01             	add    $0x1,%ecx
  800702:	e9 73 ff ff ff       	jmp    80067a <vprintfmt+0x55>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800707:	8b 45 14             	mov    0x14(%ebp),%eax
  80070a:	8d 50 04             	lea    0x4(%eax),%edx
  80070d:	89 55 14             	mov    %edx,0x14(%ebp)
  800710:	8b 55 0c             	mov    0xc(%ebp),%edx
  800713:	89 54 24 04          	mov    %edx,0x4(%esp)
  800717:	8b 00                	mov    (%eax),%eax
  800719:	89 04 24             	mov    %eax,(%esp)
  80071c:	ff 55 08             	call   *0x8(%ebp)
  80071f:	e9 27 ff ff ff       	jmp    80064b <vprintfmt+0x26>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800724:	8b 55 14             	mov    0x14(%ebp),%edx
  800727:	8d 42 04             	lea    0x4(%edx),%eax
  80072a:	89 45 14             	mov    %eax,0x14(%ebp)
  80072d:	8b 02                	mov    (%edx),%eax
  80072f:	89 c2                	mov    %eax,%edx
  800731:	c1 fa 1f             	sar    $0x1f,%edx
  800734:	31 d0                	xor    %edx,%eax
  800736:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800738:	83 f8 0f             	cmp    $0xf,%eax
  80073b:	7f 0b                	jg     800748 <vprintfmt+0x123>
  80073d:	8b 14 85 a0 2f 80 00 	mov    0x802fa0(,%eax,4),%edx
  800744:	85 d2                	test   %edx,%edx
  800746:	75 23                	jne    80076b <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800748:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80074c:	c7 44 24 08 0f 2d 80 	movl   $0x802d0f,0x8(%esp)
  800753:	00 
  800754:	8b 45 0c             	mov    0xc(%ebp),%eax
  800757:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075b:	8b 55 08             	mov    0x8(%ebp),%edx
  80075e:	89 14 24             	mov    %edx,(%esp)
  800761:	e8 ff 02 00 00       	call   800a65 <printfmt>
  800766:	e9 e0 fe ff ff       	jmp    80064b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80076b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80076f:	c7 44 24 08 de 30 80 	movl   $0x8030de,0x8(%esp)
  800776:	00 
  800777:	8b 45 0c             	mov    0xc(%ebp),%eax
  80077a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077e:	8b 55 08             	mov    0x8(%ebp),%edx
  800781:	89 14 24             	mov    %edx,(%esp)
  800784:	e8 dc 02 00 00       	call   800a65 <printfmt>
  800789:	e9 bd fe ff ff       	jmp    80064b <vprintfmt+0x26>
  80078e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800791:	89 f9                	mov    %edi,%ecx
  800793:	89 5d ec             	mov    %ebx,-0x14(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800796:	8b 55 14             	mov    0x14(%ebp),%edx
  800799:	8d 42 04             	lea    0x4(%edx),%eax
  80079c:	89 45 14             	mov    %eax,0x14(%ebp)
  80079f:	8b 12                	mov    (%edx),%edx
  8007a1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007a4:	85 d2                	test   %edx,%edx
  8007a6:	75 07                	jne    8007af <vprintfmt+0x18a>
  8007a8:	c7 45 dc 18 2d 80 00 	movl   $0x802d18,-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8007af:	85 f6                	test   %esi,%esi
  8007b1:	7e 41                	jle    8007f4 <vprintfmt+0x1cf>
  8007b3:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  8007b7:	74 3b                	je     8007f4 <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007b9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8007c0:	89 04 24             	mov    %eax,(%esp)
  8007c3:	e8 e8 02 00 00       	call   800ab0 <strnlen>
  8007c8:	29 c6                	sub    %eax,%esi
  8007ca:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8007cd:	85 f6                	test   %esi,%esi
  8007cf:	7e 23                	jle    8007f4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8007d1:	0f be 55 eb          	movsbl -0x15(%ebp),%edx
  8007d5:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8007d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007df:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007e2:	89 14 24             	mov    %edx,(%esp)
  8007e5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007e8:	83 ee 01             	sub    $0x1,%esi
  8007eb:	75 eb                	jne    8007d8 <vprintfmt+0x1b3>
  8007ed:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007f4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007f7:	0f b6 02             	movzbl (%edx),%eax
  8007fa:	0f be d0             	movsbl %al,%edx
  8007fd:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800800:	84 c0                	test   %al,%al
  800802:	75 42                	jne    800846 <vprintfmt+0x221>
  800804:	eb 49                	jmp    80084f <vprintfmt+0x22a>
				if (altflag && (ch < ' ' || ch > '~'))
  800806:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80080a:	74 1b                	je     800827 <vprintfmt+0x202>
  80080c:	8d 42 e0             	lea    -0x20(%edx),%eax
  80080f:	83 f8 5e             	cmp    $0x5e,%eax
  800812:	76 13                	jbe    800827 <vprintfmt+0x202>
					putch('?', putdat);
  800814:	8b 45 0c             	mov    0xc(%ebp),%eax
  800817:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800822:	ff 55 08             	call   *0x8(%ebp)
  800825:	eb 0d                	jmp    800834 <vprintfmt+0x20f>
				else
					putch(ch, putdat);
  800827:	8b 45 0c             	mov    0xc(%ebp),%eax
  80082a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082e:	89 14 24             	mov    %edx,(%esp)
  800831:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800834:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  800838:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80083c:	83 c6 01             	add    $0x1,%esi
  80083f:	84 c0                	test   %al,%al
  800841:	74 0c                	je     80084f <vprintfmt+0x22a>
  800843:	0f be d0             	movsbl %al,%edx
  800846:	85 ff                	test   %edi,%edi
  800848:	78 bc                	js     800806 <vprintfmt+0x1e1>
  80084a:	83 ef 01             	sub    $0x1,%edi
  80084d:	79 b7                	jns    800806 <vprintfmt+0x1e1>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80084f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800853:	0f 8e f2 fd ff ff    	jle    80064b <vprintfmt+0x26>
				putch(' ', putdat);
  800859:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800860:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800867:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80086a:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  80086e:	75 e9                	jne    800859 <vprintfmt+0x234>
  800870:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  800873:	e9 d3 fd ff ff       	jmp    80064b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800878:	83 f9 01             	cmp    $0x1,%ecx
  80087b:	90                   	nop    
  80087c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800880:	7e 10                	jle    800892 <vprintfmt+0x26d>
		return va_arg(*ap, long long);
  800882:	8b 55 14             	mov    0x14(%ebp),%edx
  800885:	8d 42 08             	lea    0x8(%edx),%eax
  800888:	89 45 14             	mov    %eax,0x14(%ebp)
  80088b:	8b 32                	mov    (%edx),%esi
  80088d:	8b 7a 04             	mov    0x4(%edx),%edi
  800890:	eb 2a                	jmp    8008bc <vprintfmt+0x297>
	else if (lflag)
  800892:	85 c9                	test   %ecx,%ecx
  800894:	74 14                	je     8008aa <vprintfmt+0x285>
		return va_arg(*ap, long);
  800896:	8b 45 14             	mov    0x14(%ebp),%eax
  800899:	8d 50 04             	lea    0x4(%eax),%edx
  80089c:	89 55 14             	mov    %edx,0x14(%ebp)
  80089f:	8b 00                	mov    (%eax),%eax
  8008a1:	89 c6                	mov    %eax,%esi
  8008a3:	89 c7                	mov    %eax,%edi
  8008a5:	c1 ff 1f             	sar    $0x1f,%edi
  8008a8:	eb 12                	jmp    8008bc <vprintfmt+0x297>
	else
		return va_arg(*ap, int);
  8008aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ad:	8d 50 04             	lea    0x4(%eax),%edx
  8008b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b3:	8b 00                	mov    (%eax),%eax
  8008b5:	89 c6                	mov    %eax,%esi
  8008b7:	89 c7                	mov    %eax,%edi
  8008b9:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008bc:	89 f2                	mov    %esi,%edx
  8008be:	89 f9                	mov    %edi,%ecx
  8008c0:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
			if ((long long) num < 0) {
  8008c7:	85 ff                	test   %edi,%edi
  8008c9:	0f 89 9b 00 00 00    	jns    80096a <vprintfmt+0x345>
				putch('-', putdat);
  8008cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008dd:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008e0:	89 f2                	mov    %esi,%edx
  8008e2:	89 f9                	mov    %edi,%ecx
  8008e4:	f7 da                	neg    %edx
  8008e6:	83 d1 00             	adc    $0x0,%ecx
  8008e9:	f7 d9                	neg    %ecx
  8008eb:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  8008f2:	eb 76                	jmp    80096a <vprintfmt+0x345>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008f4:	89 ca                	mov    %ecx,%edx
  8008f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8008f9:	e8 cd fc ff ff       	call   8005cb <getuint>
  8008fe:	89 d1                	mov    %edx,%ecx
  800900:	89 c2                	mov    %eax,%edx
  800902:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  800909:	eb 5f                	jmp    80096a <vprintfmt+0x345>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap,lflag);
  80090b:	89 ca                	mov    %ecx,%edx
  80090d:	8d 45 14             	lea    0x14(%ebp),%eax
  800910:	e8 b6 fc ff ff       	call   8005cb <getuint>
  800915:	e9 31 fd ff ff       	jmp    80064b <vprintfmt+0x26>
			base=8;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80091a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800921:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800928:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80092b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800932:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800939:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  80093c:	8b 55 14             	mov    0x14(%ebp),%edx
  80093f:	8d 42 04             	lea    0x4(%edx),%eax
  800942:	89 45 14             	mov    %eax,0x14(%ebp)
  800945:	8b 12                	mov    (%edx),%edx
  800947:	b9 00 00 00 00       	mov    $0x0,%ecx
  80094c:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  800953:	eb 15                	jmp    80096a <vprintfmt+0x345>
			base = 16;
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800955:	89 ca                	mov    %ecx,%edx
  800957:	8d 45 14             	lea    0x14(%ebp),%eax
  80095a:	e8 6c fc ff ff       	call   8005cb <getuint>
  80095f:	89 d1                	mov    %edx,%ecx
  800961:	89 c2                	mov    %eax,%edx
  800963:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80096a:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  80096e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800972:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800975:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800979:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80097c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800980:	89 14 24             	mov    %edx,(%esp)
  800983:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800987:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	e8 4e fb ff ff       	call   8004e0 <printnum>
  800992:	e9 b4 fc ff ff       	jmp    80064b <vprintfmt+0x26>
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800997:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80099e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009a5:	ff 55 08             	call   *0x8(%ebp)
  8009a8:	e9 9e fc ff ff       	jmp    80064b <vprintfmt+0x26>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009bb:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009be:	83 eb 01             	sub    $0x1,%ebx
  8009c1:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8009c5:	0f 84 80 fc ff ff    	je     80064b <vprintfmt+0x26>
  8009cb:	83 eb 01             	sub    $0x1,%ebx
  8009ce:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8009d2:	0f 84 73 fc ff ff    	je     80064b <vprintfmt+0x26>
  8009d8:	eb f1                	jmp    8009cb <vprintfmt+0x3a6>
				/* do nothing */;
			break;
		}
	}
}
  8009da:	83 c4 3c             	add    $0x3c,%esp
  8009dd:	5b                   	pop    %ebx
  8009de:	5e                   	pop    %esi
  8009df:	5f                   	pop    %edi
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	83 ec 28             	sub    $0x28,%esp
  8009e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8009eb:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8009ee:	85 d2                	test   %edx,%edx
  8009f0:	74 04                	je     8009f6 <vsnprintf+0x14>
  8009f2:	85 c0                	test   %eax,%eax
  8009f4:	7f 07                	jg     8009fd <vsnprintf+0x1b>
  8009f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009fb:	eb 3b                	jmp    800a38 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009fd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800a04:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
  800a08:	89 45 f8             	mov    %eax,-0x8(%ebp)
  800a0b:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a0e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a11:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a15:	8b 45 10             	mov    0x10(%ebp),%eax
  800a18:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a23:	c7 04 24 07 06 80 00 	movl   $0x800607,(%esp)
  800a2a:	e8 f6 fb ff ff       	call   800625 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a32:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a35:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800a38:	c9                   	leave  
  800a39:	c3                   	ret    

00800a3a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a40:	8d 45 14             	lea    0x14(%ebp),%eax
  800a43:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800a46:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a4a:	8b 45 10             	mov    0x10(%ebp),%eax
  800a4d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a54:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a58:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5b:	89 04 24             	mov    %eax,(%esp)
  800a5e:	e8 7f ff ff ff       	call   8009e2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a63:	c9                   	leave  
  800a64:	c3                   	ret    

00800a65 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800a6b:	8d 45 14             	lea    0x14(%ebp),%eax
  800a6e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800a71:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a75:	8b 45 10             	mov    0x10(%ebp),%eax
  800a78:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a83:	8b 45 08             	mov    0x8(%ebp),%eax
  800a86:	89 04 24             	mov    %eax,(%esp)
  800a89:	e8 97 fb ff ff       	call   800625 <vprintfmt>
	va_end(ap);
}
  800a8e:	c9                   	leave  
  800a8f:	c3                   	ret    

00800a90 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a96:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9b:	80 3a 00             	cmpb   $0x0,(%edx)
  800a9e:	74 0e                	je     800aae <strlen+0x1e>
  800aa0:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800aa5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800aa8:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  800aac:	75 f7                	jne    800aa5 <strlen+0x15>
		n++;
	return n;
}
  800aae:	5d                   	pop    %ebp
  800aaf:	c3                   	ret    

00800ab0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ab9:	85 d2                	test   %edx,%edx
  800abb:	74 19                	je     800ad6 <strnlen+0x26>
  800abd:	80 39 00             	cmpb   $0x0,(%ecx)
  800ac0:	74 14                	je     800ad6 <strnlen+0x26>
  800ac2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800ac7:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aca:	39 d0                	cmp    %edx,%eax
  800acc:	74 0d                	je     800adb <strnlen+0x2b>
  800ace:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800ad2:	74 07                	je     800adb <strnlen+0x2b>
  800ad4:	eb f1                	jmp    800ac7 <strnlen+0x17>
  800ad6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800adb:	5d                   	pop    %ebp
  800adc:	8d 74 26 00          	lea    0x0(%esi),%esi
  800ae0:	c3                   	ret    

00800ae1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	53                   	push   %ebx
  800ae5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ae8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aeb:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800aed:	0f b6 01             	movzbl (%ecx),%eax
  800af0:	88 02                	mov    %al,(%edx)
  800af2:	83 c2 01             	add    $0x1,%edx
  800af5:	83 c1 01             	add    $0x1,%ecx
  800af8:	84 c0                	test   %al,%al
  800afa:	75 f1                	jne    800aed <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800afc:	89 d8                	mov    %ebx,%eax
  800afe:	5b                   	pop    %ebx
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	57                   	push   %edi
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
  800b07:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b10:	85 f6                	test   %esi,%esi
  800b12:	74 1c                	je     800b30 <strncpy+0x2f>
  800b14:	89 fa                	mov    %edi,%edx
  800b16:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  800b1b:	0f b6 01             	movzbl (%ecx),%eax
  800b1e:	88 02                	mov    %al,(%edx)
  800b20:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b23:	80 39 01             	cmpb   $0x1,(%ecx)
  800b26:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b29:	83 c3 01             	add    $0x1,%ebx
  800b2c:	39 f3                	cmp    %esi,%ebx
  800b2e:	75 eb                	jne    800b1b <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b30:	89 f8                	mov    %edi,%eax
  800b32:	5b                   	pop    %ebx
  800b33:	5e                   	pop    %esi
  800b34:	5f                   	pop    %edi
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	56                   	push   %esi
  800b3b:	53                   	push   %ebx
  800b3c:	8b 75 08             	mov    0x8(%ebp),%esi
  800b3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b42:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b45:	89 f0                	mov    %esi,%eax
  800b47:	85 d2                	test   %edx,%edx
  800b49:	74 2c                	je     800b77 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800b4b:	89 d3                	mov    %edx,%ebx
  800b4d:	83 eb 01             	sub    $0x1,%ebx
  800b50:	74 20                	je     800b72 <strlcpy+0x3b>
  800b52:	0f b6 11             	movzbl (%ecx),%edx
  800b55:	84 d2                	test   %dl,%dl
  800b57:	74 19                	je     800b72 <strlcpy+0x3b>
  800b59:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800b5b:	88 10                	mov    %dl,(%eax)
  800b5d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b60:	83 eb 01             	sub    $0x1,%ebx
  800b63:	74 0f                	je     800b74 <strlcpy+0x3d>
  800b65:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  800b69:	83 c1 01             	add    $0x1,%ecx
  800b6c:	84 d2                	test   %dl,%dl
  800b6e:	74 04                	je     800b74 <strlcpy+0x3d>
  800b70:	eb e9                	jmp    800b5b <strlcpy+0x24>
  800b72:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b74:	c6 00 00             	movb   $0x0,(%eax)
  800b77:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	8b 75 08             	mov    0x8(%ebp),%esi
  800b85:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b88:	8b 55 10             	mov    0x10(%ebp),%edx
    int c;
    char *q = buf;

    if (buf_size <= 0)
  800b8b:	85 c0                	test   %eax,%eax
  800b8d:	7e 2e                	jle    800bbd <pstrcpy+0x40>
        return;

    for(;;) {
        c = *str++;
  800b8f:	0f b6 0a             	movzbl (%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  800b92:	84 c9                	test   %cl,%cl
  800b94:	74 22                	je     800bb8 <pstrcpy+0x3b>
  800b96:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  800b9a:	89 f0                	mov    %esi,%eax
  800b9c:	39 de                	cmp    %ebx,%esi
  800b9e:	72 09                	jb     800ba9 <pstrcpy+0x2c>
  800ba0:	eb 16                	jmp    800bb8 <pstrcpy+0x3b>
  800ba2:	83 c2 01             	add    $0x1,%edx
  800ba5:	39 d8                	cmp    %ebx,%eax
  800ba7:	73 11                	jae    800bba <pstrcpy+0x3d>
            break;
        *q++ = c;
  800ba9:	88 08                	mov    %cl,(%eax)
  800bab:	83 c0 01             	add    $0x1,%eax

    if (buf_size <= 0)
        return;

    for(;;) {
        c = *str++;
  800bae:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  800bb2:	84 c9                	test   %cl,%cl
  800bb4:	75 ec                	jne    800ba2 <pstrcpy+0x25>
  800bb6:	eb 02                	jmp    800bba <pstrcpy+0x3d>
  800bb8:	89 f0                	mov    %esi,%eax
            break;
        *q++ = c;
    }
    *q = '\0';
  800bba:	c6 00 00             	movb   $0x0,(%eax)
}
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  800bca:	0f b6 02             	movzbl (%edx),%eax
  800bcd:	84 c0                	test   %al,%al
  800bcf:	74 16                	je     800be7 <strcmp+0x26>
  800bd1:	3a 01                	cmp    (%ecx),%al
  800bd3:	75 12                	jne    800be7 <strcmp+0x26>
		p++, q++;
  800bd5:	83 c1 01             	add    $0x1,%ecx
    *q = '\0';
}
int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bd8:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  800bdc:	84 c0                	test   %al,%al
  800bde:	74 07                	je     800be7 <strcmp+0x26>
  800be0:	83 c2 01             	add    $0x1,%edx
  800be3:	3a 01                	cmp    (%ecx),%al
  800be5:	74 ee                	je     800bd5 <strcmp+0x14>
  800be7:	0f b6 c0             	movzbl %al,%eax
  800bea:	0f b6 11             	movzbl (%ecx),%edx
  800bed:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	53                   	push   %ebx
  800bf5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bfb:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800bfe:	85 d2                	test   %edx,%edx
  800c00:	74 2d                	je     800c2f <strncmp+0x3e>
  800c02:	0f b6 01             	movzbl (%ecx),%eax
  800c05:	84 c0                	test   %al,%al
  800c07:	74 1a                	je     800c23 <strncmp+0x32>
  800c09:	3a 03                	cmp    (%ebx),%al
  800c0b:	75 16                	jne    800c23 <strncmp+0x32>
  800c0d:	83 ea 01             	sub    $0x1,%edx
  800c10:	74 1d                	je     800c2f <strncmp+0x3e>
		n--, p++, q++;
  800c12:	83 c1 01             	add    $0x1,%ecx
  800c15:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c18:	0f b6 01             	movzbl (%ecx),%eax
  800c1b:	84 c0                	test   %al,%al
  800c1d:	74 04                	je     800c23 <strncmp+0x32>
  800c1f:	3a 03                	cmp    (%ebx),%al
  800c21:	74 ea                	je     800c0d <strncmp+0x1c>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c23:	0f b6 11             	movzbl (%ecx),%edx
  800c26:	0f b6 03             	movzbl (%ebx),%eax
  800c29:	29 c2                	sub    %eax,%edx
  800c2b:	89 d0                	mov    %edx,%eax
  800c2d:	eb 05                	jmp    800c34 <strncmp+0x43>
  800c2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c34:	5b                   	pop    %ebx
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c41:	0f b6 10             	movzbl (%eax),%edx
  800c44:	84 d2                	test   %dl,%dl
  800c46:	74 14                	je     800c5c <strchr+0x25>
		if (*s == c)
  800c48:	38 ca                	cmp    %cl,%dl
  800c4a:	75 06                	jne    800c52 <strchr+0x1b>
  800c4c:	eb 13                	jmp    800c61 <strchr+0x2a>
  800c4e:	38 ca                	cmp    %cl,%dl
  800c50:	74 0f                	je     800c61 <strchr+0x2a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c52:	83 c0 01             	add    $0x1,%eax
  800c55:	0f b6 10             	movzbl (%eax),%edx
  800c58:	84 d2                	test   %dl,%dl
  800c5a:	75 f2                	jne    800c4e <strchr+0x17>
  800c5c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	8b 45 08             	mov    0x8(%ebp),%eax
  800c69:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c6d:	0f b6 10             	movzbl (%eax),%edx
  800c70:	84 d2                	test   %dl,%dl
  800c72:	74 18                	je     800c8c <strfind+0x29>
		if (*s == c)
  800c74:	38 ca                	cmp    %cl,%dl
  800c76:	75 0a                	jne    800c82 <strfind+0x1f>
  800c78:	eb 12                	jmp    800c8c <strfind+0x29>
  800c7a:	38 ca                	cmp    %cl,%dl
  800c7c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800c80:	74 0a                	je     800c8c <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c82:	83 c0 01             	add    $0x1,%eax
  800c85:	0f b6 10             	movzbl (%eax),%edx
  800c88:	84 d2                	test   %dl,%dl
  800c8a:	75 ee                	jne    800c7a <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800c8c:	5d                   	pop    %ebp
  800c8d:	c3                   	ret    

00800c8e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	83 ec 08             	sub    $0x8,%esp
  800c94:	89 1c 24             	mov    %ebx,(%esp)
  800c97:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c9b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800ca1:	85 db                	test   %ebx,%ebx
  800ca3:	74 36                	je     800cdb <memset+0x4d>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ca5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cab:	75 26                	jne    800cd3 <memset+0x45>
  800cad:	f6 c3 03             	test   $0x3,%bl
  800cb0:	75 21                	jne    800cd3 <memset+0x45>
		c &= 0xFF;
  800cb2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800cb6:	89 d0                	mov    %edx,%eax
  800cb8:	c1 e0 18             	shl    $0x18,%eax
  800cbb:	89 d1                	mov    %edx,%ecx
  800cbd:	c1 e1 10             	shl    $0x10,%ecx
  800cc0:	09 c8                	or     %ecx,%eax
  800cc2:	09 d0                	or     %edx,%eax
  800cc4:	c1 e2 08             	shl    $0x8,%edx
  800cc7:	09 d0                	or     %edx,%eax
  800cc9:	89 d9                	mov    %ebx,%ecx
  800ccb:	c1 e9 02             	shr    $0x2,%ecx
  800cce:	fc                   	cld    
  800ccf:	f3 ab                	rep stos %eax,%es:(%edi)
  800cd1:	eb 08                	jmp    800cdb <memset+0x4d>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd6:	89 d9                	mov    %ebx,%ecx
  800cd8:	fc                   	cld    
  800cd9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cdb:	89 f8                	mov    %edi,%eax
  800cdd:	8b 1c 24             	mov    (%esp),%ebx
  800ce0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ce4:	89 ec                	mov    %ebp,%esp
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	83 ec 08             	sub    $0x8,%esp
  800cee:	89 34 24             	mov    %esi,(%esp)
  800cf1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cf5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800cfb:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800cfe:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800d00:	39 c6                	cmp    %eax,%esi
  800d02:	73 38                	jae    800d3c <memmove+0x54>
  800d04:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d07:	39 d0                	cmp    %edx,%eax
  800d09:	73 31                	jae    800d3c <memmove+0x54>
		s += n;
		d += n;
  800d0b:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d0e:	f6 c2 03             	test   $0x3,%dl
  800d11:	75 1d                	jne    800d30 <memmove+0x48>
  800d13:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d19:	75 15                	jne    800d30 <memmove+0x48>
  800d1b:	f6 c1 03             	test   $0x3,%cl
  800d1e:	66 90                	xchg   %ax,%ax
  800d20:	75 0e                	jne    800d30 <memmove+0x48>
			asm volatile("std; rep movsl\n"
  800d22:	8d 7e fc             	lea    -0x4(%esi),%edi
  800d25:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d28:	c1 e9 02             	shr    $0x2,%ecx
  800d2b:	fd                   	std    
  800d2c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d2e:	eb 09                	jmp    800d39 <memmove+0x51>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d30:	8d 7e ff             	lea    -0x1(%esi),%edi
  800d33:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d36:	fd                   	std    
  800d37:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d39:	fc                   	cld    
  800d3a:	eb 21                	jmp    800d5d <memmove+0x75>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d3c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d42:	75 16                	jne    800d5a <memmove+0x72>
  800d44:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d4a:	75 0e                	jne    800d5a <memmove+0x72>
  800d4c:	f6 c1 03             	test   $0x3,%cl
  800d4f:	90                   	nop    
  800d50:	75 08                	jne    800d5a <memmove+0x72>
			asm volatile("cld; rep movsl\n"
  800d52:	c1 e9 02             	shr    $0x2,%ecx
  800d55:	fc                   	cld    
  800d56:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d58:	eb 03                	jmp    800d5d <memmove+0x75>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d5a:	fc                   	cld    
  800d5b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d5d:	8b 34 24             	mov    (%esp),%esi
  800d60:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d64:	89 ec                	mov    %ebp,%esp
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d6e:	8b 45 10             	mov    0x10(%ebp),%eax
  800d71:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d75:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d78:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7f:	89 04 24             	mov    %eax,(%esp)
  800d82:	e8 61 ff ff ff       	call   800ce8 <memmove>
}
  800d87:	c9                   	leave  
  800d88:	c3                   	ret    

00800d89 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	57                   	push   %edi
  800d8d:	56                   	push   %esi
  800d8e:	53                   	push   %ebx
  800d8f:	83 ec 04             	sub    $0x4,%esp
  800d92:	8b 45 08             	mov    0x8(%ebp),%eax
  800d95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d98:	8b 55 10             	mov    0x10(%ebp),%edx
  800d9b:	83 ea 01             	sub    $0x1,%edx
  800d9e:	83 fa ff             	cmp    $0xffffffff,%edx
  800da1:	74 47                	je     800dea <memcmp+0x61>
		if (*s1 != *s2)
  800da3:	0f b6 30             	movzbl (%eax),%esi
  800da6:	0f b6 39             	movzbl (%ecx),%edi
			return (int) *s1 - (int) *s2;
  800da9:	89 45 f0             	mov    %eax,-0x10(%ebp)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  800dac:	89 f0                	mov    %esi,%eax
  800dae:	89 fb                	mov    %edi,%ebx
  800db0:	38 d8                	cmp    %bl,%al
  800db2:	74 2e                	je     800de2 <memcmp+0x59>
  800db4:	eb 1c                	jmp    800dd2 <memcmp+0x49>
  800db6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800db9:	0f b6 70 01          	movzbl 0x1(%eax),%esi
  800dbd:	0f b6 79 01          	movzbl 0x1(%ecx),%edi
  800dc1:	83 c0 01             	add    $0x1,%eax
  800dc4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800dc7:	83 c1 01             	add    $0x1,%ecx
  800dca:	89 f3                	mov    %esi,%ebx
  800dcc:	89 f8                	mov    %edi,%eax
  800dce:	38 c3                	cmp    %al,%bl
  800dd0:	74 10                	je     800de2 <memcmp+0x59>
			return (int) *s1 - (int) *s2;
  800dd2:	89 f1                	mov    %esi,%ecx
  800dd4:	0f b6 d1             	movzbl %cl,%edx
  800dd7:	89 fb                	mov    %edi,%ebx
  800dd9:	0f b6 c3             	movzbl %bl,%eax
  800ddc:	29 c2                	sub    %eax,%edx
  800dde:	89 d0                	mov    %edx,%eax
  800de0:	eb 0d                	jmp    800def <memcmp+0x66>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800de2:	83 ea 01             	sub    $0x1,%edx
  800de5:	83 fa ff             	cmp    $0xffffffff,%edx
  800de8:	75 cc                	jne    800db6 <memcmp+0x2d>
  800dea:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800def:	83 c4 04             	add    $0x4,%esp
  800df2:	5b                   	pop    %ebx
  800df3:	5e                   	pop    %esi
  800df4:	5f                   	pop    %edi
  800df5:	5d                   	pop    %ebp
  800df6:	c3                   	ret    

00800df7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800dfd:	89 c1                	mov    %eax,%ecx
  800dff:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
  800e02:	39 c8                	cmp    %ecx,%eax
  800e04:	73 15                	jae    800e1b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e06:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
  800e0a:	38 10                	cmp    %dl,(%eax)
  800e0c:	75 06                	jne    800e14 <memfind+0x1d>
  800e0e:	eb 0b                	jmp    800e1b <memfind+0x24>
  800e10:	38 10                	cmp    %dl,(%eax)
  800e12:	74 07                	je     800e1b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e14:	83 c0 01             	add    $0x1,%eax
  800e17:	39 c8                	cmp    %ecx,%eax
  800e19:	75 f5                	jne    800e10 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e1b:	5d                   	pop    %ebp
  800e1c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800e20:	c3                   	ret    

00800e21 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	57                   	push   %edi
  800e25:	56                   	push   %esi
  800e26:	53                   	push   %ebx
  800e27:	83 ec 04             	sub    $0x4,%esp
  800e2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2d:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e30:	0f b6 01             	movzbl (%ecx),%eax
  800e33:	3c 20                	cmp    $0x20,%al
  800e35:	74 04                	je     800e3b <strtol+0x1a>
  800e37:	3c 09                	cmp    $0x9,%al
  800e39:	75 0e                	jne    800e49 <strtol+0x28>
		s++;
  800e3b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e3e:	0f b6 01             	movzbl (%ecx),%eax
  800e41:	3c 20                	cmp    $0x20,%al
  800e43:	74 f6                	je     800e3b <strtol+0x1a>
  800e45:	3c 09                	cmp    $0x9,%al
  800e47:	74 f2                	je     800e3b <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e49:	3c 2b                	cmp    $0x2b,%al
  800e4b:	75 0c                	jne    800e59 <strtol+0x38>
		s++;
  800e4d:	83 c1 01             	add    $0x1,%ecx
  800e50:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e57:	eb 15                	jmp    800e6e <strtol+0x4d>
	else if (*s == '-')
  800e59:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e60:	3c 2d                	cmp    $0x2d,%al
  800e62:	75 0a                	jne    800e6e <strtol+0x4d>
		s++, neg = 1;
  800e64:	83 c1 01             	add    $0x1,%ecx
  800e67:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e6e:	85 f6                	test   %esi,%esi
  800e70:	0f 94 c0             	sete   %al
  800e73:	74 05                	je     800e7a <strtol+0x59>
  800e75:	83 fe 10             	cmp    $0x10,%esi
  800e78:	75 18                	jne    800e92 <strtol+0x71>
  800e7a:	80 39 30             	cmpb   $0x30,(%ecx)
  800e7d:	75 13                	jne    800e92 <strtol+0x71>
  800e7f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e83:	75 0d                	jne    800e92 <strtol+0x71>
		s += 2, base = 16;
  800e85:	83 c1 02             	add    $0x2,%ecx
  800e88:	be 10 00 00 00       	mov    $0x10,%esi
  800e8d:	8d 76 00             	lea    0x0(%esi),%esi
  800e90:	eb 1b                	jmp    800ead <strtol+0x8c>
	else if (base == 0 && s[0] == '0')
  800e92:	85 f6                	test   %esi,%esi
  800e94:	75 0e                	jne    800ea4 <strtol+0x83>
  800e96:	80 39 30             	cmpb   $0x30,(%ecx)
  800e99:	75 09                	jne    800ea4 <strtol+0x83>
		s++, base = 8;
  800e9b:	83 c1 01             	add    $0x1,%ecx
  800e9e:	66 be 08 00          	mov    $0x8,%si
  800ea2:	eb 09                	jmp    800ead <strtol+0x8c>
	else if (base == 0)
  800ea4:	84 c0                	test   %al,%al
  800ea6:	74 05                	je     800ead <strtol+0x8c>
  800ea8:	be 0a 00 00 00       	mov    $0xa,%esi
  800ead:	bf 00 00 00 00       	mov    $0x0,%edi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800eb2:	0f b6 11             	movzbl (%ecx),%edx
  800eb5:	89 d3                	mov    %edx,%ebx
  800eb7:	8d 42 d0             	lea    -0x30(%edx),%eax
  800eba:	3c 09                	cmp    $0x9,%al
  800ebc:	77 08                	ja     800ec6 <strtol+0xa5>
			dig = *s - '0';
  800ebe:	0f be c2             	movsbl %dl,%eax
  800ec1:	8d 50 d0             	lea    -0x30(%eax),%edx
  800ec4:	eb 1c                	jmp    800ee2 <strtol+0xc1>
		else if (*s >= 'a' && *s <= 'z')
  800ec6:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800ec9:	3c 19                	cmp    $0x19,%al
  800ecb:	77 08                	ja     800ed5 <strtol+0xb4>
			dig = *s - 'a' + 10;
  800ecd:	0f be c2             	movsbl %dl,%eax
  800ed0:	8d 50 a9             	lea    -0x57(%eax),%edx
  800ed3:	eb 0d                	jmp    800ee2 <strtol+0xc1>
		else if (*s >= 'A' && *s <= 'Z')
  800ed5:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800ed8:	3c 19                	cmp    $0x19,%al
  800eda:	77 17                	ja     800ef3 <strtol+0xd2>
			dig = *s - 'A' + 10;
  800edc:	0f be c2             	movsbl %dl,%eax
  800edf:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800ee2:	39 f2                	cmp    %esi,%edx
  800ee4:	7d 0d                	jge    800ef3 <strtol+0xd2>
			break;
		s++, val = (val * base) + dig;
  800ee6:	83 c1 01             	add    $0x1,%ecx
  800ee9:	89 f8                	mov    %edi,%eax
  800eeb:	0f af c6             	imul   %esi,%eax
  800eee:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800ef1:	eb bf                	jmp    800eb2 <strtol+0x91>
		// we don't properly detect overflow!
	}
  800ef3:	89 f8                	mov    %edi,%eax

	if (endptr)
  800ef5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ef9:	74 05                	je     800f00 <strtol+0xdf>
		*endptr = (char *) s;
  800efb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800efe:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800f00:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800f04:	74 04                	je     800f0a <strtol+0xe9>
  800f06:	89 c7                	mov    %eax,%edi
  800f08:	f7 df                	neg    %edi
}
  800f0a:	89 f8                	mov    %edi,%eax
  800f0c:	83 c4 04             	add    $0x4,%esp
  800f0f:	5b                   	pop    %ebx
  800f10:	5e                   	pop    %esi
  800f11:	5f                   	pop    %edi
  800f12:	5d                   	pop    %ebp
  800f13:	c3                   	ret    

00800f14 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	83 ec 0c             	sub    $0xc,%esp
  800f1a:	89 1c 24             	mov    %ebx,(%esp)
  800f1d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f21:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f25:	b8 01 00 00 00       	mov    $0x1,%eax
  800f2a:	bf 00 00 00 00       	mov    $0x0,%edi
  800f2f:	89 fa                	mov    %edi,%edx
  800f31:	89 f9                	mov    %edi,%ecx
  800f33:	89 fb                	mov    %edi,%ebx
  800f35:	89 fe                	mov    %edi,%esi
  800f37:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f39:	8b 1c 24             	mov    (%esp),%ebx
  800f3c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f40:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f44:	89 ec                	mov    %ebp,%esp
  800f46:	5d                   	pop    %ebp
  800f47:	c3                   	ret    

00800f48 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f48:	55                   	push   %ebp
  800f49:	89 e5                	mov    %esp,%ebp
  800f4b:	83 ec 0c             	sub    $0xc,%esp
  800f4e:	89 1c 24             	mov    %ebx,(%esp)
  800f51:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f55:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f59:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f5f:	bf 00 00 00 00       	mov    $0x0,%edi
  800f64:	89 f8                	mov    %edi,%eax
  800f66:	89 fb                	mov    %edi,%ebx
  800f68:	89 fe                	mov    %edi,%esi
  800f6a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f6c:	8b 1c 24             	mov    (%esp),%ebx
  800f6f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f73:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f77:	89 ec                	mov    %ebp,%esp
  800f79:	5d                   	pop    %ebp
  800f7a:	c3                   	ret    

00800f7b <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	83 ec 0c             	sub    $0xc,%esp
  800f81:	89 1c 24             	mov    %ebx,(%esp)
  800f84:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f88:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f91:	bf 00 00 00 00       	mov    $0x0,%edi
  800f96:	89 fa                	mov    %edi,%edx
  800f98:	89 f9                	mov    %edi,%ecx
  800f9a:	89 fb                	mov    %edi,%ebx
  800f9c:	89 fe                	mov    %edi,%esi
  800f9e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800fa0:	8b 1c 24             	mov    (%esp),%ebx
  800fa3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fa7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fab:	89 ec                	mov    %ebp,%esp
  800fad:	5d                   	pop    %ebp
  800fae:	c3                   	ret    

00800faf <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800faf:	55                   	push   %ebp
  800fb0:	89 e5                	mov    %esp,%ebp
  800fb2:	83 ec 28             	sub    $0x28,%esp
  800fb5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fb8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fbb:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800fbe:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fc6:	bf 00 00 00 00       	mov    $0x0,%edi
  800fcb:	89 f9                	mov    %edi,%ecx
  800fcd:	89 fb                	mov    %edi,%ebx
  800fcf:	89 fe                	mov    %edi,%esi
  800fd1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800fd3:	85 c0                	test   %eax,%eax
  800fd5:	7e 28                	jle    800fff <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fdb:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800fe2:	00 
  800fe3:	c7 44 24 08 ff 2f 80 	movl   $0x802fff,0x8(%esp)
  800fea:	00 
  800feb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ff2:	00 
  800ff3:	c7 04 24 1c 30 80 00 	movl   $0x80301c,(%esp)
  800ffa:	e8 b5 f3 ff ff       	call   8003b4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fff:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801002:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801005:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801008:	89 ec                	mov    %ebp,%esp
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    

0080100c <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	83 ec 0c             	sub    $0xc,%esp
  801012:	89 1c 24             	mov    %ebx,(%esp)
  801015:	89 74 24 04          	mov    %esi,0x4(%esp)
  801019:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80101d:	8b 55 08             	mov    0x8(%ebp),%edx
  801020:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801023:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801026:	8b 7d 14             	mov    0x14(%ebp),%edi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801029:	b8 0c 00 00 00       	mov    $0xc,%eax
  80102e:	be 00 00 00 00       	mov    $0x0,%esi
  801033:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801035:	8b 1c 24             	mov    (%esp),%ebx
  801038:	8b 74 24 04          	mov    0x4(%esp),%esi
  80103c:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801040:	89 ec                	mov    %ebp,%esp
  801042:	5d                   	pop    %ebp
  801043:	c3                   	ret    

00801044 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	83 ec 28             	sub    $0x28,%esp
  80104a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80104d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801050:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801053:	8b 55 08             	mov    0x8(%ebp),%edx
  801056:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801059:	b8 0a 00 00 00       	mov    $0xa,%eax
  80105e:	bf 00 00 00 00       	mov    $0x0,%edi
  801063:	89 fb                	mov    %edi,%ebx
  801065:	89 fe                	mov    %edi,%esi
  801067:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801069:	85 c0                	test   %eax,%eax
  80106b:	7e 28                	jle    801095 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80106d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801071:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801078:	00 
  801079:	c7 44 24 08 ff 2f 80 	movl   $0x802fff,0x8(%esp)
  801080:	00 
  801081:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801088:	00 
  801089:	c7 04 24 1c 30 80 00 	movl   $0x80301c,(%esp)
  801090:	e8 1f f3 ff ff       	call   8003b4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801095:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801098:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80109b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80109e:	89 ec                	mov    %ebp,%esp
  8010a0:	5d                   	pop    %ebp
  8010a1:	c3                   	ret    

008010a2 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	83 ec 28             	sub    $0x28,%esp
  8010a8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010ab:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010ae:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8010b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b7:	b8 09 00 00 00       	mov    $0x9,%eax
  8010bc:	bf 00 00 00 00       	mov    $0x0,%edi
  8010c1:	89 fb                	mov    %edi,%ebx
  8010c3:	89 fe                	mov    %edi,%esi
  8010c5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	7e 28                	jle    8010f3 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010cb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010cf:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8010d6:	00 
  8010d7:	c7 44 24 08 ff 2f 80 	movl   $0x802fff,0x8(%esp)
  8010de:	00 
  8010df:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010e6:	00 
  8010e7:	c7 04 24 1c 30 80 00 	movl   $0x80301c,(%esp)
  8010ee:	e8 c1 f2 ff ff       	call   8003b4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8010f3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010f6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010f9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010fc:	89 ec                	mov    %ebp,%esp
  8010fe:	5d                   	pop    %ebp
  8010ff:	c3                   	ret    

00801100 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	83 ec 28             	sub    $0x28,%esp
  801106:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801109:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80110c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80110f:	8b 55 08             	mov    0x8(%ebp),%edx
  801112:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801115:	b8 08 00 00 00       	mov    $0x8,%eax
  80111a:	bf 00 00 00 00       	mov    $0x0,%edi
  80111f:	89 fb                	mov    %edi,%ebx
  801121:	89 fe                	mov    %edi,%esi
  801123:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801125:	85 c0                	test   %eax,%eax
  801127:	7e 28                	jle    801151 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801129:	89 44 24 10          	mov    %eax,0x10(%esp)
  80112d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801134:	00 
  801135:	c7 44 24 08 ff 2f 80 	movl   $0x802fff,0x8(%esp)
  80113c:	00 
  80113d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801144:	00 
  801145:	c7 04 24 1c 30 80 00 	movl   $0x80301c,(%esp)
  80114c:	e8 63 f2 ff ff       	call   8003b4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801151:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801154:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801157:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80115a:	89 ec                	mov    %ebp,%esp
  80115c:	5d                   	pop    %ebp
  80115d:	c3                   	ret    

0080115e <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80115e:	55                   	push   %ebp
  80115f:	89 e5                	mov    %esp,%ebp
  801161:	83 ec 28             	sub    $0x28,%esp
  801164:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801167:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80116a:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80116d:	8b 55 08             	mov    0x8(%ebp),%edx
  801170:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801173:	b8 06 00 00 00       	mov    $0x6,%eax
  801178:	bf 00 00 00 00       	mov    $0x0,%edi
  80117d:	89 fb                	mov    %edi,%ebx
  80117f:	89 fe                	mov    %edi,%esi
  801181:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801183:	85 c0                	test   %eax,%eax
  801185:	7e 28                	jle    8011af <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801187:	89 44 24 10          	mov    %eax,0x10(%esp)
  80118b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801192:	00 
  801193:	c7 44 24 08 ff 2f 80 	movl   $0x802fff,0x8(%esp)
  80119a:	00 
  80119b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011a2:	00 
  8011a3:	c7 04 24 1c 30 80 00 	movl   $0x80301c,(%esp)
  8011aa:	e8 05 f2 ff ff       	call   8003b4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011af:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011b2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011b5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011b8:	89 ec                	mov    %ebp,%esp
  8011ba:	5d                   	pop    %ebp
  8011bb:	c3                   	ret    

008011bc <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011bc:	55                   	push   %ebp
  8011bd:	89 e5                	mov    %esp,%ebp
  8011bf:	83 ec 28             	sub    $0x28,%esp
  8011c2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011c5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011c8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8011cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011d4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011d7:	8b 75 18             	mov    0x18(%ebp),%esi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011da:	b8 05 00 00 00       	mov    $0x5,%eax
  8011df:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	7e 28                	jle    80120d <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011e5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011e9:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8011f0:	00 
  8011f1:	c7 44 24 08 ff 2f 80 	movl   $0x802fff,0x8(%esp)
  8011f8:	00 
  8011f9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801200:	00 
  801201:	c7 04 24 1c 30 80 00 	movl   $0x80301c,(%esp)
  801208:	e8 a7 f1 ff ff       	call   8003b4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80120d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801210:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801213:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801216:	89 ec                	mov    %ebp,%esp
  801218:	5d                   	pop    %ebp
  801219:	c3                   	ret    

0080121a <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	83 ec 28             	sub    $0x28,%esp
  801220:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801223:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801226:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801229:	8b 55 08             	mov    0x8(%ebp),%edx
  80122c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80122f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801232:	b8 04 00 00 00       	mov    $0x4,%eax
  801237:	bf 00 00 00 00       	mov    $0x0,%edi
  80123c:	89 fe                	mov    %edi,%esi
  80123e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801240:	85 c0                	test   %eax,%eax
  801242:	7e 28                	jle    80126c <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  801244:	89 44 24 10          	mov    %eax,0x10(%esp)
  801248:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80124f:	00 
  801250:	c7 44 24 08 ff 2f 80 	movl   $0x802fff,0x8(%esp)
  801257:	00 
  801258:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80125f:	00 
  801260:	c7 04 24 1c 30 80 00 	movl   $0x80301c,(%esp)
  801267:	e8 48 f1 ff ff       	call   8003b4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80126c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80126f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801272:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801275:	89 ec                	mov    %ebp,%esp
  801277:	5d                   	pop    %ebp
  801278:	c3                   	ret    

00801279 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  801279:	55                   	push   %ebp
  80127a:	89 e5                	mov    %esp,%ebp
  80127c:	83 ec 0c             	sub    $0xc,%esp
  80127f:	89 1c 24             	mov    %ebx,(%esp)
  801282:	89 74 24 04          	mov    %esi,0x4(%esp)
  801286:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80128a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80128f:	bf 00 00 00 00       	mov    $0x0,%edi
  801294:	89 fa                	mov    %edi,%edx
  801296:	89 f9                	mov    %edi,%ecx
  801298:	89 fb                	mov    %edi,%ebx
  80129a:	89 fe                	mov    %edi,%esi
  80129c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80129e:	8b 1c 24             	mov    (%esp),%ebx
  8012a1:	8b 74 24 04          	mov    0x4(%esp),%esi
  8012a5:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8012a9:	89 ec                	mov    %ebp,%esp
  8012ab:	5d                   	pop    %ebp
  8012ac:	c3                   	ret    

008012ad <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8012ad:	55                   	push   %ebp
  8012ae:	89 e5                	mov    %esp,%ebp
  8012b0:	83 ec 0c             	sub    $0xc,%esp
  8012b3:	89 1c 24             	mov    %ebx,(%esp)
  8012b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012ba:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012be:	b8 02 00 00 00       	mov    $0x2,%eax
  8012c3:	bf 00 00 00 00       	mov    $0x0,%edi
  8012c8:	89 fa                	mov    %edi,%edx
  8012ca:	89 f9                	mov    %edi,%ecx
  8012cc:	89 fb                	mov    %edi,%ebx
  8012ce:	89 fe                	mov    %edi,%esi
  8012d0:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8012d2:	8b 1c 24             	mov    (%esp),%ebx
  8012d5:	8b 74 24 04          	mov    0x4(%esp),%esi
  8012d9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8012dd:	89 ec                	mov    %ebp,%esp
  8012df:	5d                   	pop    %ebp
  8012e0:	c3                   	ret    

008012e1 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	83 ec 28             	sub    $0x28,%esp
  8012e7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012ea:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012ed:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8012f0:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012f3:	b8 03 00 00 00       	mov    $0x3,%eax
  8012f8:	bf 00 00 00 00       	mov    $0x0,%edi
  8012fd:	89 f9                	mov    %edi,%ecx
  8012ff:	89 fb                	mov    %edi,%ebx
  801301:	89 fe                	mov    %edi,%esi
  801303:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801305:	85 c0                	test   %eax,%eax
  801307:	7e 28                	jle    801331 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801309:	89 44 24 10          	mov    %eax,0x10(%esp)
  80130d:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801314:	00 
  801315:	c7 44 24 08 ff 2f 80 	movl   $0x802fff,0x8(%esp)
  80131c:	00 
  80131d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801324:	00 
  801325:	c7 04 24 1c 30 80 00 	movl   $0x80301c,(%esp)
  80132c:	e8 83 f0 ff ff       	call   8003b4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801331:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801334:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801337:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80133a:	89 ec                	mov    %ebp,%esp
  80133c:	5d                   	pop    %ebp
  80133d:	c3                   	ret    
	...

00801340 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
  801343:	8b 45 08             	mov    0x8(%ebp),%eax
  801346:	05 00 00 00 30       	add    $0x30000000,%eax
  80134b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80134e:	5d                   	pop    %ebp
  80134f:	c3                   	ret    

00801350 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801350:	55                   	push   %ebp
  801351:	89 e5                	mov    %esp,%ebp
  801353:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801356:	8b 45 08             	mov    0x8(%ebp),%eax
  801359:	89 04 24             	mov    %eax,(%esp)
  80135c:	e8 df ff ff ff       	call   801340 <fd2num>
  801361:	c1 e0 0c             	shl    $0xc,%eax
  801364:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801369:	c9                   	leave  
  80136a:	c3                   	ret    

0080136b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
  80136e:	53                   	push   %ebx
  80136f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801372:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  801377:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801379:	89 d0                	mov    %edx,%eax
  80137b:	c1 e8 16             	shr    $0x16,%eax
  80137e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801385:	a8 01                	test   $0x1,%al
  801387:	74 10                	je     801399 <fd_alloc+0x2e>
  801389:	89 d0                	mov    %edx,%eax
  80138b:	c1 e8 0c             	shr    $0xc,%eax
  80138e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801395:	a8 01                	test   $0x1,%al
  801397:	75 09                	jne    8013a2 <fd_alloc+0x37>
			*fd_store = fd;
  801399:	89 0b                	mov    %ecx,(%ebx)
  80139b:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a0:	eb 19                	jmp    8013bb <fd_alloc+0x50>
			return 0;
  8013a2:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013a8:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  8013ae:	75 c7                	jne    801377 <fd_alloc+0xc>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013b0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8013b6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8013bb:	5b                   	pop    %ebx
  8013bc:	5d                   	pop    %ebp
  8013bd:	c3                   	ret    

008013be <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013be:	55                   	push   %ebp
  8013bf:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013c1:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  8013c5:	77 38                	ja     8013ff <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ca:	c1 e0 0c             	shl    $0xc,%eax
  8013cd:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  8013d3:	89 d0                	mov    %edx,%eax
  8013d5:	c1 e8 16             	shr    $0x16,%eax
  8013d8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013df:	a8 01                	test   $0x1,%al
  8013e1:	74 1c                	je     8013ff <fd_lookup+0x41>
  8013e3:	89 d0                	mov    %edx,%eax
  8013e5:	c1 e8 0c             	shr    $0xc,%eax
  8013e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ef:	a8 01                	test   $0x1,%al
  8013f1:	74 0c                	je     8013ff <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f6:	89 10                	mov    %edx,(%eax)
  8013f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8013fd:	eb 05                	jmp    801404 <fd_lookup+0x46>
	return 0;
  8013ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801404:	5d                   	pop    %ebp
  801405:	c3                   	ret    

00801406 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801406:	55                   	push   %ebp
  801407:	89 e5                	mov    %esp,%ebp
  801409:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80140c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80140f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801413:	8b 45 08             	mov    0x8(%ebp),%eax
  801416:	89 04 24             	mov    %eax,(%esp)
  801419:	e8 a0 ff ff ff       	call   8013be <fd_lookup>
  80141e:	85 c0                	test   %eax,%eax
  801420:	78 0e                	js     801430 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801422:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801425:	8b 55 0c             	mov    0xc(%ebp),%edx
  801428:	89 50 04             	mov    %edx,0x4(%eax)
  80142b:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801430:	c9                   	leave  
  801431:	c3                   	ret    

00801432 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801432:	55                   	push   %ebp
  801433:	89 e5                	mov    %esp,%ebp
  801435:	53                   	push   %ebx
  801436:	83 ec 14             	sub    $0x14,%esp
  801439:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80143c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80143f:	ba 24 70 80 00       	mov    $0x807024,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801444:	b8 00 00 00 00       	mov    $0x0,%eax
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801449:	39 0d 24 70 80 00    	cmp    %ecx,0x807024
  80144f:	75 11                	jne    801462 <dev_lookup+0x30>
  801451:	eb 04                	jmp    801457 <dev_lookup+0x25>
  801453:	39 0a                	cmp    %ecx,(%edx)
  801455:	75 0b                	jne    801462 <dev_lookup+0x30>
			*dev = devtab[i];
  801457:	89 13                	mov    %edx,(%ebx)
  801459:	b8 00 00 00 00       	mov    $0x0,%eax
  80145e:	66 90                	xchg   %ax,%ax
  801460:	eb 35                	jmp    801497 <dev_lookup+0x65>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801462:	83 c0 01             	add    $0x1,%eax
  801465:	8b 14 85 a8 30 80 00 	mov    0x8030a8(,%eax,4),%edx
  80146c:	85 d2                	test   %edx,%edx
  80146e:	75 e3                	jne    801453 <dev_lookup+0x21>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  801470:	a1 70 70 80 00       	mov    0x807070,%eax
  801475:	8b 40 4c             	mov    0x4c(%eax),%eax
  801478:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80147c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801480:	c7 04 24 2c 30 80 00 	movl   $0x80302c,(%esp)
  801487:	e8 f5 ef ff ff       	call   800481 <cprintf>
	*dev = 0;
  80148c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801492:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801497:	83 c4 14             	add    $0x14,%esp
  80149a:	5b                   	pop    %ebx
  80149b:	5d                   	pop    %ebp
  80149c:	c3                   	ret    

0080149d <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80149d:	55                   	push   %ebp
  80149e:	89 e5                	mov    %esp,%ebp
  8014a0:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a3:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8014a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ad:	89 04 24             	mov    %eax,(%esp)
  8014b0:	e8 09 ff ff ff       	call   8013be <fd_lookup>
  8014b5:	89 c2                	mov    %eax,%edx
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	78 5a                	js     801515 <fstat+0x78>
  8014bb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8014c5:	8b 00                	mov    (%eax),%eax
  8014c7:	89 04 24             	mov    %eax,(%esp)
  8014ca:	e8 63 ff ff ff       	call   801432 <dev_lookup>
  8014cf:	89 c2                	mov    %eax,%edx
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	78 40                	js     801515 <fstat+0x78>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8014d5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  8014da:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014dd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014e1:	74 32                	je     801515 <fstat+0x78>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014e6:	c6 00 00             	movb   $0x0,(%eax)
	stat->st_size = 0;
  8014e9:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  8014f0:	00 00 00 
	stat->st_isdir = 0;
  8014f3:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
  8014fa:	00 00 00 
	stat->st_dev = dev;
  8014fd:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801500:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
	return (*dev->dev_stat)(fd, stat);
  801506:	89 44 24 04          	mov    %eax,0x4(%esp)
  80150a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80150d:	89 04 24             	mov    %eax,(%esp)
  801510:	ff 52 14             	call   *0x14(%edx)
  801513:	89 c2                	mov    %eax,%edx
}
  801515:	89 d0                	mov    %edx,%eax
  801517:	c9                   	leave  
  801518:	c3                   	ret    

00801519 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801519:	55                   	push   %ebp
  80151a:	89 e5                	mov    %esp,%ebp
  80151c:	53                   	push   %ebx
  80151d:	83 ec 24             	sub    $0x24,%esp
  801520:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801523:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801526:	89 44 24 04          	mov    %eax,0x4(%esp)
  80152a:	89 1c 24             	mov    %ebx,(%esp)
  80152d:	e8 8c fe ff ff       	call   8013be <fd_lookup>
  801532:	85 c0                	test   %eax,%eax
  801534:	78 61                	js     801597 <ftruncate+0x7e>
  801536:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801539:	8b 10                	mov    (%eax),%edx
  80153b:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80153e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801542:	89 14 24             	mov    %edx,(%esp)
  801545:	e8 e8 fe ff ff       	call   801432 <dev_lookup>
  80154a:	85 c0                	test   %eax,%eax
  80154c:	78 49                	js     801597 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80154e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801551:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801555:	75 23                	jne    80157a <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801557:	a1 70 70 80 00       	mov    0x807070,%eax
  80155c:	8b 40 4c             	mov    0x4c(%eax),%eax
  80155f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801563:	89 44 24 04          	mov    %eax,0x4(%esp)
  801567:	c7 04 24 4c 30 80 00 	movl   $0x80304c,(%esp)
  80156e:	e8 0e ef ff ff       	call   800481 <cprintf>
  801573:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801578:	eb 1d                	jmp    801597 <ftruncate+0x7e>
			env->env_id, fdnum); 
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80157a:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80157d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801582:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  801586:	74 0f                	je     801597 <ftruncate+0x7e>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801588:	8b 42 18             	mov    0x18(%edx),%eax
  80158b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80158e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801592:	89 0c 24             	mov    %ecx,(%esp)
  801595:	ff d0                	call   *%eax
}
  801597:	83 c4 24             	add    $0x24,%esp
  80159a:	5b                   	pop    %ebx
  80159b:	5d                   	pop    %ebp
  80159c:	c3                   	ret    

0080159d <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80159d:	55                   	push   %ebp
  80159e:	89 e5                	mov    %esp,%ebp
  8015a0:	53                   	push   %ebx
  8015a1:	83 ec 24             	sub    $0x24,%esp
  8015a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ae:	89 1c 24             	mov    %ebx,(%esp)
  8015b1:	e8 08 fe ff ff       	call   8013be <fd_lookup>
  8015b6:	85 c0                	test   %eax,%eax
  8015b8:	78 68                	js     801622 <write+0x85>
  8015ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015bd:	8b 10                	mov    (%eax),%edx
  8015bf:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8015c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c6:	89 14 24             	mov    %edx,(%esp)
  8015c9:	e8 64 fe ff ff       	call   801432 <dev_lookup>
  8015ce:	85 c0                	test   %eax,%eax
  8015d0:	78 50                	js     801622 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015d2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  8015d5:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  8015d9:	75 23                	jne    8015fe <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  8015db:	a1 70 70 80 00       	mov    0x807070,%eax
  8015e0:	8b 40 4c             	mov    0x4c(%eax),%eax
  8015e3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015eb:	c7 04 24 6d 30 80 00 	movl   $0x80306d,(%esp)
  8015f2:	e8 8a ee ff ff       	call   800481 <cprintf>
  8015f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015fc:	eb 24                	jmp    801622 <write+0x85>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015fe:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801601:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801606:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  80160a:	74 16                	je     801622 <write+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80160c:	8b 42 0c             	mov    0xc(%edx),%eax
  80160f:	8b 55 10             	mov    0x10(%ebp),%edx
  801612:	89 54 24 08          	mov    %edx,0x8(%esp)
  801616:	8b 55 0c             	mov    0xc(%ebp),%edx
  801619:	89 54 24 04          	mov    %edx,0x4(%esp)
  80161d:	89 0c 24             	mov    %ecx,(%esp)
  801620:	ff d0                	call   *%eax
}
  801622:	83 c4 24             	add    $0x24,%esp
  801625:	5b                   	pop    %ebx
  801626:	5d                   	pop    %ebp
  801627:	c3                   	ret    

00801628 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801628:	55                   	push   %ebp
  801629:	89 e5                	mov    %esp,%ebp
  80162b:	53                   	push   %ebx
  80162c:	83 ec 24             	sub    $0x24,%esp
  80162f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801632:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801635:	89 44 24 04          	mov    %eax,0x4(%esp)
  801639:	89 1c 24             	mov    %ebx,(%esp)
  80163c:	e8 7d fd ff ff       	call   8013be <fd_lookup>
  801641:	85 c0                	test   %eax,%eax
  801643:	78 6d                	js     8016b2 <read+0x8a>
  801645:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801648:	8b 10                	mov    (%eax),%edx
  80164a:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80164d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801651:	89 14 24             	mov    %edx,(%esp)
  801654:	e8 d9 fd ff ff       	call   801432 <dev_lookup>
  801659:	85 c0                	test   %eax,%eax
  80165b:	78 55                	js     8016b2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80165d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801660:	8b 41 08             	mov    0x8(%ecx),%eax
  801663:	83 e0 03             	and    $0x3,%eax
  801666:	83 f8 01             	cmp    $0x1,%eax
  801669:	75 23                	jne    80168e <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  80166b:	a1 70 70 80 00       	mov    0x807070,%eax
  801670:	8b 40 4c             	mov    0x4c(%eax),%eax
  801673:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801677:	89 44 24 04          	mov    %eax,0x4(%esp)
  80167b:	c7 04 24 8a 30 80 00 	movl   $0x80308a,(%esp)
  801682:	e8 fa ed ff ff       	call   800481 <cprintf>
  801687:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80168c:	eb 24                	jmp    8016b2 <read+0x8a>
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80168e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801691:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801696:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  80169a:	74 16                	je     8016b2 <read+0x8a>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80169c:	8b 42 08             	mov    0x8(%edx),%eax
  80169f:	8b 55 10             	mov    0x10(%ebp),%edx
  8016a2:	89 54 24 08          	mov    %edx,0x8(%esp)
  8016a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8016ad:	89 0c 24             	mov    %ecx,(%esp)
  8016b0:	ff d0                	call   *%eax
}
  8016b2:	83 c4 24             	add    $0x24,%esp
  8016b5:	5b                   	pop    %ebx
  8016b6:	5d                   	pop    %ebp
  8016b7:	c3                   	ret    

008016b8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016b8:	55                   	push   %ebp
  8016b9:	89 e5                	mov    %esp,%ebp
  8016bb:	57                   	push   %edi
  8016bc:	56                   	push   %esi
  8016bd:	53                   	push   %ebx
  8016be:	83 ec 0c             	sub    $0xc,%esp
  8016c1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8016c4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8016cc:	85 f6                	test   %esi,%esi
  8016ce:	74 36                	je     801706 <readn+0x4e>
  8016d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016d5:	ba 00 00 00 00       	mov    $0x0,%edx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016da:	89 f0                	mov    %esi,%eax
  8016dc:	29 d0                	sub    %edx,%eax
  8016de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016e2:	8d 04 17             	lea    (%edi,%edx,1),%eax
  8016e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ec:	89 04 24             	mov    %eax,(%esp)
  8016ef:	e8 34 ff ff ff       	call   801628 <read>
		if (m < 0)
  8016f4:	85 c0                	test   %eax,%eax
  8016f6:	78 0e                	js     801706 <readn+0x4e>
			return m;
		if (m == 0)
  8016f8:	85 c0                	test   %eax,%eax
  8016fa:	74 08                	je     801704 <readn+0x4c>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016fc:	01 c3                	add    %eax,%ebx
  8016fe:	89 da                	mov    %ebx,%edx
  801700:	39 f3                	cmp    %esi,%ebx
  801702:	72 d6                	jb     8016da <readn+0x22>
  801704:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801706:	83 c4 0c             	add    $0xc,%esp
  801709:	5b                   	pop    %ebx
  80170a:	5e                   	pop    %esi
  80170b:	5f                   	pop    %edi
  80170c:	5d                   	pop    %ebp
  80170d:	c3                   	ret    

0080170e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	83 ec 28             	sub    $0x28,%esp
  801714:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801717:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80171a:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80171d:	89 34 24             	mov    %esi,(%esp)
  801720:	e8 1b fc ff ff       	call   801340 <fd2num>
  801725:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801728:	89 54 24 04          	mov    %edx,0x4(%esp)
  80172c:	89 04 24             	mov    %eax,(%esp)
  80172f:	e8 8a fc ff ff       	call   8013be <fd_lookup>
  801734:	89 c3                	mov    %eax,%ebx
  801736:	85 c0                	test   %eax,%eax
  801738:	78 05                	js     80173f <fd_close+0x31>
  80173a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80173d:	74 0d                	je     80174c <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80173f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801743:	75 44                	jne    801789 <fd_close+0x7b>
  801745:	bb 00 00 00 00       	mov    $0x0,%ebx
  80174a:	eb 3d                	jmp    801789 <fd_close+0x7b>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80174c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80174f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801753:	8b 06                	mov    (%esi),%eax
  801755:	89 04 24             	mov    %eax,(%esp)
  801758:	e8 d5 fc ff ff       	call   801432 <dev_lookup>
  80175d:	89 c3                	mov    %eax,%ebx
  80175f:	85 c0                	test   %eax,%eax
  801761:	78 16                	js     801779 <fd_close+0x6b>
		if (dev->dev_close)
  801763:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801766:	8b 40 10             	mov    0x10(%eax),%eax
  801769:	bb 00 00 00 00       	mov    $0x0,%ebx
  80176e:	85 c0                	test   %eax,%eax
  801770:	74 07                	je     801779 <fd_close+0x6b>
			r = (*dev->dev_close)(fd);
  801772:	89 34 24             	mov    %esi,(%esp)
  801775:	ff d0                	call   *%eax
  801777:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801779:	89 74 24 04          	mov    %esi,0x4(%esp)
  80177d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801784:	e8 d5 f9 ff ff       	call   80115e <sys_page_unmap>
	return r;
}
  801789:	89 d8                	mov    %ebx,%eax
  80178b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80178e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801791:	89 ec                	mov    %ebp,%esp
  801793:	5d                   	pop    %ebp
  801794:	c3                   	ret    

00801795 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80179b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80179e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a5:	89 04 24             	mov    %eax,(%esp)
  8017a8:	e8 11 fc ff ff       	call   8013be <fd_lookup>
  8017ad:	85 c0                	test   %eax,%eax
  8017af:	78 13                	js     8017c4 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8017b1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8017b8:	00 
  8017b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017bc:	89 04 24             	mov    %eax,(%esp)
  8017bf:	e8 4a ff ff ff       	call   80170e <fd_close>
}
  8017c4:	c9                   	leave  
  8017c5:	c3                   	ret    

008017c6 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	83 ec 18             	sub    $0x18,%esp
  8017cc:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8017cf:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017d2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017d9:	00 
  8017da:	8b 45 08             	mov    0x8(%ebp),%eax
  8017dd:	89 04 24             	mov    %eax,(%esp)
  8017e0:	e8 5a 03 00 00       	call   801b3f <open>
  8017e5:	89 c6                	mov    %eax,%esi
  8017e7:	85 c0                	test   %eax,%eax
  8017e9:	78 1b                	js     801806 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8017eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f2:	89 34 24             	mov    %esi,(%esp)
  8017f5:	e8 a3 fc ff ff       	call   80149d <fstat>
  8017fa:	89 c3                	mov    %eax,%ebx
	close(fd);
  8017fc:	89 34 24             	mov    %esi,(%esp)
  8017ff:	e8 91 ff ff ff       	call   801795 <close>
  801804:	89 de                	mov    %ebx,%esi
	return r;
}
  801806:	89 f0                	mov    %esi,%eax
  801808:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80180b:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80180e:	89 ec                	mov    %ebp,%esp
  801810:	5d                   	pop    %ebp
  801811:	c3                   	ret    

00801812 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801812:	55                   	push   %ebp
  801813:	89 e5                	mov    %esp,%ebp
  801815:	83 ec 38             	sub    $0x38,%esp
  801818:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80181b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80181e:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801821:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801824:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801827:	89 44 24 04          	mov    %eax,0x4(%esp)
  80182b:	8b 45 08             	mov    0x8(%ebp),%eax
  80182e:	89 04 24             	mov    %eax,(%esp)
  801831:	e8 88 fb ff ff       	call   8013be <fd_lookup>
  801836:	89 c3                	mov    %eax,%ebx
  801838:	85 c0                	test   %eax,%eax
  80183a:	0f 88 e1 00 00 00    	js     801921 <dup+0x10f>
		return r;
	close(newfdnum);
  801840:	89 3c 24             	mov    %edi,(%esp)
  801843:	e8 4d ff ff ff       	call   801795 <close>

	newfd = INDEX2FD(newfdnum);
  801848:	89 f8                	mov    %edi,%eax
  80184a:	c1 e0 0c             	shl    $0xc,%eax
  80184d:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  801853:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801856:	89 04 24             	mov    %eax,(%esp)
  801859:	e8 f2 fa ff ff       	call   801350 <fd2data>
  80185e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801860:	89 34 24             	mov    %esi,(%esp)
  801863:	e8 e8 fa ff ff       	call   801350 <fd2data>
  801868:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  80186b:	89 d8                	mov    %ebx,%eax
  80186d:	c1 e8 16             	shr    $0x16,%eax
  801870:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801877:	a8 01                	test   $0x1,%al
  801879:	74 45                	je     8018c0 <dup+0xae>
  80187b:	89 da                	mov    %ebx,%edx
  80187d:	c1 ea 0c             	shr    $0xc,%edx
  801880:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801887:	a8 01                	test   $0x1,%al
  801889:	74 35                	je     8018c0 <dup+0xae>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  80188b:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801892:	25 07 0e 00 00       	and    $0xe07,%eax
  801897:	89 44 24 10          	mov    %eax,0x10(%esp)
  80189b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80189e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018a2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018a9:	00 
  8018aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018b5:	e8 02 f9 ff ff       	call   8011bc <sys_page_map>
  8018ba:	89 c3                	mov    %eax,%ebx
  8018bc:	85 c0                	test   %eax,%eax
  8018be:	78 3e                	js     8018fe <dup+0xec>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  8018c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018c3:	89 d0                	mov    %edx,%eax
  8018c5:	c1 e8 0c             	shr    $0xc,%eax
  8018c8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018cf:	25 07 0e 00 00       	and    $0xe07,%eax
  8018d4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8018d8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8018dc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018e3:	00 
  8018e4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018ef:	e8 c8 f8 ff ff       	call   8011bc <sys_page_map>
  8018f4:	89 c3                	mov    %eax,%ebx
  8018f6:	85 c0                	test   %eax,%eax
  8018f8:	78 04                	js     8018fe <dup+0xec>
		goto err;
  8018fa:	89 fb                	mov    %edi,%ebx
  8018fc:	eb 23                	jmp    801921 <dup+0x10f>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8018fe:	89 74 24 04          	mov    %esi,0x4(%esp)
  801902:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801909:	e8 50 f8 ff ff       	call   80115e <sys_page_unmap>
	sys_page_unmap(0, nva);
  80190e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801911:	89 44 24 04          	mov    %eax,0x4(%esp)
  801915:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80191c:	e8 3d f8 ff ff       	call   80115e <sys_page_unmap>
	return r;
}
  801921:	89 d8                	mov    %ebx,%eax
  801923:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801926:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801929:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80192c:	89 ec                	mov    %ebp,%esp
  80192e:	5d                   	pop    %ebp
  80192f:	c3                   	ret    

00801930 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	53                   	push   %ebx
  801934:	83 ec 04             	sub    $0x4,%esp
  801937:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  80193c:	89 1c 24             	mov    %ebx,(%esp)
  80193f:	e8 51 fe ff ff       	call   801795 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801944:	83 c3 01             	add    $0x1,%ebx
  801947:	83 fb 20             	cmp    $0x20,%ebx
  80194a:	75 f0                	jne    80193c <close_all+0xc>
		close(i);
}
  80194c:	83 c4 04             	add    $0x4,%esp
  80194f:	5b                   	pop    %ebx
  801950:	5d                   	pop    %ebp
  801951:	c3                   	ret    
	...

00801954 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	53                   	push   %ebx
  801958:	83 ec 14             	sub    $0x14,%esp
  80195b:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80195d:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  801963:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80196a:	00 
  80196b:	c7 44 24 08 00 40 80 	movl   $0x804000,0x8(%esp)
  801972:	00 
  801973:	89 44 24 04          	mov    %eax,0x4(%esp)
  801977:	89 14 24             	mov    %edx,(%esp)
  80197a:	e8 21 0a 00 00       	call   8023a0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80197f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801986:	00 
  801987:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80198b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801992:	e8 bd 0a 00 00       	call   802454 <ipc_recv>
}
  801997:	83 c4 14             	add    $0x14,%esp
  80199a:	5b                   	pop    %ebx
  80199b:	5d                   	pop    %ebp
  80199c:	c3                   	ret    

0080199d <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  80199d:	55                   	push   %ebp
  80199e:	89 e5                	mov    %esp,%ebp
  8019a0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a8:	b8 08 00 00 00       	mov    $0x8,%eax
  8019ad:	e8 a2 ff ff ff       	call   801954 <fsipc>
}
  8019b2:	c9                   	leave  
  8019b3:	c3                   	ret    

008019b4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c0:	a3 00 40 80 00       	mov    %eax,0x804000
	fsipcbuf.set_size.req_size = newsize;
  8019c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c8:	a3 04 40 80 00       	mov    %eax,0x804004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d2:	b8 02 00 00 00       	mov    $0x2,%eax
  8019d7:	e8 78 ff ff ff       	call   801954 <fsipc>
}
  8019dc:	c9                   	leave  
  8019dd:	c3                   	ret    

008019de <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ea:	a3 00 40 80 00       	mov    %eax,0x804000
	return fsipc(FSREQ_FLUSH, NULL);
  8019ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f4:	b8 06 00 00 00       	mov    $0x6,%eax
  8019f9:	e8 56 ff ff ff       	call   801954 <fsipc>
}
  8019fe:	c9                   	leave  
  8019ff:	c3                   	ret    

00801a00 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	53                   	push   %ebx
  801a04:	83 ec 14             	sub    $0x14,%esp
  801a07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a10:	a3 00 40 80 00       	mov    %eax,0x804000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a15:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1a:	b8 05 00 00 00       	mov    $0x5,%eax
  801a1f:	e8 30 ff ff ff       	call   801954 <fsipc>
  801a24:	85 c0                	test   %eax,%eax
  801a26:	78 2b                	js     801a53 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a28:	c7 44 24 04 00 40 80 	movl   $0x804000,0x4(%esp)
  801a2f:	00 
  801a30:	89 1c 24             	mov    %ebx,(%esp)
  801a33:	e8 a9 f0 ff ff       	call   800ae1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a38:	a1 80 40 80 00       	mov    0x804080,%eax
  801a3d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a43:	a1 84 40 80 00       	mov    0x804084,%eax
  801a48:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801a4e:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801a53:	83 c4 14             	add    $0x14,%esp
  801a56:	5b                   	pop    %ebx
  801a57:	5d                   	pop    %ebp
  801a58:	c3                   	ret    

00801a59 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a59:	55                   	push   %ebp
  801a5a:	89 e5                	mov    %esp,%ebp
  801a5c:	83 ec 18             	sub    $0x18,%esp
  801a5f:	8b 55 10             	mov    0x10(%ebp),%edx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	ssize_t writesize;
	size_t bufsize;
	fsipcbuf.write.req_fileid=fd->fd_file.id;
  801a62:	8b 45 08             	mov    0x8(%ebp),%eax
  801a65:	8b 40 0c             	mov    0xc(%eax),%eax
  801a68:	a3 00 40 80 00       	mov    %eax,0x804000
	bufsize=sizeof(fsipcbuf.write.req_buf);
	if(n<bufsize)
  801a6d:	89 d0                	mov    %edx,%eax
  801a6f:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  801a75:	76 05                	jbe    801a7c <devfile_write+0x23>
  801a77:	b8 f8 0f 00 00       	mov    $0xff8,%eax
		bufsize=n;	
	fsipcbuf.write.req_n=n;
  801a7c:	89 15 04 40 80 00    	mov    %edx,0x804004
	memmove((void*)fsipcbuf.write.req_buf,buf,bufsize);
  801a82:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a86:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a89:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8d:	c7 04 24 08 40 80 00 	movl   $0x804008,(%esp)
  801a94:	e8 4f f2 ff ff       	call   800ce8 <memmove>
	writesize=(ssize_t)fsipc(FSREQ_WRITE,NULL);
  801a99:	ba 00 00 00 00       	mov    $0x0,%edx
  801a9e:	b8 04 00 00 00       	mov    $0x4,%eax
  801aa3:	e8 ac fe ff ff       	call   801954 <fsipc>
	return writesize;
	//panic("devfile_write not implemented");
}
  801aa8:	c9                   	leave  
  801aa9:	c3                   	ret    

00801aaa <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801aaa:	55                   	push   %ebp
  801aab:	89 e5                	mov    %esp,%ebp
  801aad:	53                   	push   %ebx
  801aae:	83 ec 14             	sub    $0x14,%esp
	// system server.
	// LAB 5: Your code here
	ssize_t readsize;
	if(debug)
		cprintf("devfile_read:fileid=%x readsize=%x\n",fd->fd_file.id,n);
	fsipcbuf.read.req_fileid=fd->fd_file.id;
  801ab1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab4:	8b 40 0c             	mov    0xc(%eax),%eax
  801ab7:	a3 00 40 80 00       	mov    %eax,0x804000
	fsipcbuf.read.req_n=n;
  801abc:	8b 45 10             	mov    0x10(%ebp),%eax
  801abf:	a3 04 40 80 00       	mov    %eax,0x804004
	readsize=(ssize_t)fsipc(FSREQ_READ,&fsipcbuf);
  801ac4:	ba 00 40 80 00       	mov    $0x804000,%edx
  801ac9:	b8 03 00 00 00       	mov    $0x3,%eax
  801ace:	e8 81 fe ff ff       	call   801954 <fsipc>
  801ad3:	89 c3                	mov    %eax,%ebx
	//cprintf("readsize=%d\n",readsize);
	if(debug)
		cprintf("devfile_read:buf1=%s\nbuf2=%s\n",(char*)&fsipcbuf,fsipcbuf.readRet.ret_buf);
	if(readsize>0)
  801ad5:	85 c0                	test   %eax,%eax
  801ad7:	7e 17                	jle    801af0 <devfile_read+0x46>
		memmove(buf,(void*)&fsipcbuf,(size_t)readsize);
  801ad9:	89 44 24 08          	mov    %eax,0x8(%esp)
  801add:	c7 44 24 04 00 40 80 	movl   $0x804000,0x4(%esp)
  801ae4:	00 
  801ae5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae8:	89 04 24             	mov    %eax,(%esp)
  801aeb:	e8 f8 f1 ff ff       	call   800ce8 <memmove>
	//cprintf("readsize=%d",readsize);
	return readsize;
	//panic("devfile_read not implemented");
}
  801af0:	89 d8                	mov    %ebx,%eax
  801af2:	83 c4 14             	add    $0x14,%esp
  801af5:	5b                   	pop    %ebx
  801af6:	5d                   	pop    %ebp
  801af7:	c3                   	ret    

00801af8 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801af8:	55                   	push   %ebp
  801af9:	89 e5                	mov    %esp,%ebp
  801afb:	53                   	push   %ebx
  801afc:	83 ec 14             	sub    $0x14,%esp
  801aff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801b02:	89 1c 24             	mov    %ebx,(%esp)
  801b05:	e8 86 ef ff ff       	call   800a90 <strlen>
  801b0a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  801b0f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b14:	7f 21                	jg     801b37 <remove+0x3f>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801b16:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b1a:	c7 04 24 00 40 80 00 	movl   $0x804000,(%esp)
  801b21:	e8 bb ef ff ff       	call   800ae1 <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801b26:	ba 00 00 00 00       	mov    $0x0,%edx
  801b2b:	b8 07 00 00 00       	mov    $0x7,%eax
  801b30:	e8 1f fe ff ff       	call   801954 <fsipc>
  801b35:	89 c2                	mov    %eax,%edx
}
  801b37:	89 d0                	mov    %edx,%eax
  801b39:	83 c4 14             	add    $0x14,%esp
  801b3c:	5b                   	pop    %ebx
  801b3d:	5d                   	pop    %ebp
  801b3e:	c3                   	ret    

00801b3f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b3f:	55                   	push   %ebp
  801b40:	89 e5                	mov    %esp,%ebp
  801b42:	56                   	push   %esi
  801b43:	53                   	push   %ebx
  801b44:	83 ec 30             	sub    $0x30,%esp

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;
	void *page;
	if((r=fd_alloc(&fd))<0){
  801b47:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b4a:	89 04 24             	mov    %eax,(%esp)
  801b4d:	e8 19 f8 ff ff       	call   80136b <fd_alloc>
  801b52:	89 c3                	mov    %eax,%ebx
  801b54:	85 c0                	test   %eax,%eax
  801b56:	79 18                	jns    801b70 <open+0x31>
		fd_close(fd,0);
  801b58:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b5f:	00 
  801b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b63:	89 04 24             	mov    %eax,(%esp)
  801b66:	e8 a3 fb ff ff       	call   80170e <fd_close>
  801b6b:	e9 9f 00 00 00       	jmp    801c0f <open+0xd0>
		return r;
	}
	//cprintf("open:fd=%x\n",fd);
	strcpy(fsipcbuf.open.req_path,path);
  801b70:	8b 45 08             	mov    0x8(%ebp),%eax
  801b73:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b77:	c7 04 24 00 40 80 00 	movl   $0x804000,(%esp)
  801b7e:	e8 5e ef ff ff       	call   800ae1 <strcpy>
	fsipcbuf.open.req_omode=mode;
  801b83:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b86:	a3 00 44 80 00       	mov    %eax,0x804400
	page=(void*)fd2data(fd);
  801b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b8e:	89 04 24             	mov    %eax,(%esp)
  801b91:	e8 ba f7 ff ff       	call   801350 <fd2data>
  801b96:	89 c6                	mov    %eax,%esi
	if((r=fsipc(FSREQ_OPEN,(void*)fd))<0)
  801b98:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b9b:	b8 01 00 00 00       	mov    $0x1,%eax
  801ba0:	e8 af fd ff ff       	call   801954 <fsipc>
  801ba5:	89 c3                	mov    %eax,%ebx
  801ba7:	85 c0                	test   %eax,%eax
  801ba9:	79 15                	jns    801bc0 <open+0x81>
	{
		fd_close(fd,1);
  801bab:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801bb2:	00 
  801bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb6:	89 04 24             	mov    %eax,(%esp)
  801bb9:	e8 50 fb ff ff       	call   80170e <fd_close>
  801bbe:	eb 4f                	jmp    801c0f <open+0xd0>
		return r;	
	}
	//cprintf("open:page=%x\n",page);
	if((r=sys_page_map(0,(void*)fd,0,(void*)page,PTE_P | PTE_W | PTE_U))<0)
  801bc0:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801bc7:	00 
  801bc8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801bcc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bd3:	00 
  801bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bdb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801be2:	e8 d5 f5 ff ff       	call   8011bc <sys_page_map>
  801be7:	89 c3                	mov    %eax,%ebx
  801be9:	85 c0                	test   %eax,%eax
  801beb:	79 15                	jns    801c02 <open+0xc3>
	{
		fd_close(fd,1);
  801bed:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801bf4:	00 
  801bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf8:	89 04 24             	mov    %eax,(%esp)
  801bfb:	e8 0e fb ff ff       	call   80170e <fd_close>
  801c00:	eb 0d                	jmp    801c0f <open+0xd0>
		return r;
	}
	//cprintf("open:fileid=%x\n",fd->fd_file.id);
	return fd2num(fd);
  801c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c05:	89 04 24             	mov    %eax,(%esp)
  801c08:	e8 33 f7 ff ff       	call   801340 <fd2num>
  801c0d:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801c0f:	89 d8                	mov    %ebx,%eax
  801c11:	83 c4 30             	add    $0x30,%esp
  801c14:	5b                   	pop    %ebx
  801c15:	5e                   	pop    %esi
  801c16:	5d                   	pop    %ebp
  801c17:	c3                   	ret    
	...

00801c20 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  801c26:	c7 44 24 04 b4 30 80 	movl   $0x8030b4,0x4(%esp)
  801c2d:	00 
  801c2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c31:	89 04 24             	mov    %eax,(%esp)
  801c34:	e8 a8 ee ff ff       	call   800ae1 <strcpy>
	return 0;
}
  801c39:	b8 00 00 00 00       	mov    $0x0,%eax
  801c3e:	c9                   	leave  
  801c3f:	c3                   	ret    

00801c40 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	83 ec 08             	sub    $0x8,%esp
	return nsipc_close(fd->fd_sock.sockid);
  801c46:	8b 45 08             	mov    0x8(%ebp),%eax
  801c49:	8b 40 0c             	mov    0xc(%eax),%eax
  801c4c:	89 04 24             	mov    %eax,(%esp)
  801c4f:	e8 9e 02 00 00       	call   801ef2 <nsipc_close>
}
  801c54:	c9                   	leave  
  801c55:	c3                   	ret    

00801c56 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c5c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801c63:	00 
  801c64:	8b 45 10             	mov    0x10(%ebp),%eax
  801c67:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c72:	8b 45 08             	mov    0x8(%ebp),%eax
  801c75:	8b 40 0c             	mov    0xc(%eax),%eax
  801c78:	89 04 24             	mov    %eax,(%esp)
  801c7b:	e8 ae 02 00 00       	call   801f2e <nsipc_send>
}
  801c80:	c9                   	leave  
  801c81:	c3                   	ret    

00801c82 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801c82:	55                   	push   %ebp
  801c83:	89 e5                	mov    %esp,%ebp
  801c85:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801c88:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801c8f:	00 
  801c90:	8b 45 10             	mov    0x10(%ebp),%eax
  801c93:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c97:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca1:	8b 40 0c             	mov    0xc(%eax),%eax
  801ca4:	89 04 24             	mov    %eax,(%esp)
  801ca7:	e8 f5 02 00 00       	call   801fa1 <nsipc_recv>
}
  801cac:	c9                   	leave  
  801cad:	c3                   	ret    

00801cae <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801cae:	55                   	push   %ebp
  801caf:	89 e5                	mov    %esp,%ebp
  801cb1:	56                   	push   %esi
  801cb2:	53                   	push   %ebx
  801cb3:	83 ec 20             	sub    $0x20,%esp
  801cb6:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801cb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbb:	89 04 24             	mov    %eax,(%esp)
  801cbe:	e8 a8 f6 ff ff       	call   80136b <fd_alloc>
  801cc3:	89 c3                	mov    %eax,%ebx
  801cc5:	85 c0                	test   %eax,%eax
  801cc7:	78 21                	js     801cea <alloc_sockfd+0x3c>
  801cc9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801cd0:	00 
  801cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cd8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cdf:	e8 36 f5 ff ff       	call   80121a <sys_page_alloc>
  801ce4:	89 c3                	mov    %eax,%ebx
  801ce6:	85 c0                	test   %eax,%eax
  801ce8:	79 0a                	jns    801cf4 <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U)) < 0) {
		nsipc_close(sockid);
  801cea:	89 34 24             	mov    %esi,(%esp)
  801ced:	e8 00 02 00 00       	call   801ef2 <nsipc_close>
  801cf2:	eb 28                	jmp    801d1c <alloc_sockfd+0x6e>
		return r;
	}

	sfd->fd_dev_id = devsock.dev_id;
  801cf4:	8b 15 40 70 80 00    	mov    0x807040,%edx
  801cfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cfd:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801cff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d02:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801d09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d12:	89 04 24             	mov    %eax,(%esp)
  801d15:	e8 26 f6 ff ff       	call   801340 <fd2num>
  801d1a:	89 c3                	mov    %eax,%ebx
}
  801d1c:	89 d8                	mov    %ebx,%eax
  801d1e:	83 c4 20             	add    $0x20,%esp
  801d21:	5b                   	pop    %ebx
  801d22:	5e                   	pop    %esi
  801d23:	5d                   	pop    %ebp
  801d24:	c3                   	ret    

00801d25 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801d25:	55                   	push   %ebp
  801d26:	89 e5                	mov    %esp,%ebp
  801d28:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801d2b:	8b 45 10             	mov    0x10(%ebp),%eax
  801d2e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d32:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d35:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d39:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3c:	89 04 24             	mov    %eax,(%esp)
  801d3f:	e8 62 01 00 00       	call   801ea6 <nsipc_socket>
  801d44:	85 c0                	test   %eax,%eax
  801d46:	78 05                	js     801d4d <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801d48:	e8 61 ff ff ff       	call   801cae <alloc_sockfd>
}
  801d4d:	c9                   	leave  
  801d4e:	66 90                	xchg   %ax,%ax
  801d50:	c3                   	ret    

00801d51 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801d51:	55                   	push   %ebp
  801d52:	89 e5                	mov    %esp,%ebp
  801d54:	83 ec 18             	sub    $0x18,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d57:	8d 55 fc             	lea    -0x4(%ebp),%edx
  801d5a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d5e:	89 04 24             	mov    %eax,(%esp)
  801d61:	e8 58 f6 ff ff       	call   8013be <fd_lookup>
  801d66:	89 c2                	mov    %eax,%edx
  801d68:	85 c0                	test   %eax,%eax
  801d6a:	78 15                	js     801d81 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d6c:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  801d6f:	8b 01                	mov    (%ecx),%eax
  801d71:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  801d76:	3b 05 40 70 80 00    	cmp    0x807040,%eax
  801d7c:	75 03                	jne    801d81 <fd2sockid+0x30>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d7e:	8b 51 0c             	mov    0xc(%ecx),%edx
}
  801d81:	89 d0                	mov    %edx,%eax
  801d83:	c9                   	leave  
  801d84:	c3                   	ret    

00801d85 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  801d85:	55                   	push   %ebp
  801d86:	89 e5                	mov    %esp,%ebp
  801d88:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8e:	e8 be ff ff ff       	call   801d51 <fd2sockid>
  801d93:	85 c0                	test   %eax,%eax
  801d95:	78 0f                	js     801da6 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801d97:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d9a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d9e:	89 04 24             	mov    %eax,(%esp)
  801da1:	e8 2a 01 00 00       	call   801ed0 <nsipc_listen>
}
  801da6:	c9                   	leave  
  801da7:	c3                   	ret    

00801da8 <connect>:
	return nsipc_close(fd->fd_sock.sockid);
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801da8:	55                   	push   %ebp
  801da9:	89 e5                	mov    %esp,%ebp
  801dab:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dae:	8b 45 08             	mov    0x8(%ebp),%eax
  801db1:	e8 9b ff ff ff       	call   801d51 <fd2sockid>
  801db6:	85 c0                	test   %eax,%eax
  801db8:	78 16                	js     801dd0 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801dba:	8b 55 10             	mov    0x10(%ebp),%edx
  801dbd:	89 54 24 08          	mov    %edx,0x8(%esp)
  801dc1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dc4:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dc8:	89 04 24             	mov    %eax,(%esp)
  801dcb:	e8 51 02 00 00       	call   802021 <nsipc_connect>
}
  801dd0:	c9                   	leave  
  801dd1:	c3                   	ret    

00801dd2 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801dd2:	55                   	push   %ebp
  801dd3:	89 e5                	mov    %esp,%ebp
  801dd5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dd8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddb:	e8 71 ff ff ff       	call   801d51 <fd2sockid>
  801de0:	85 c0                	test   %eax,%eax
  801de2:	78 0f                	js     801df3 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801de4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801de7:	89 54 24 04          	mov    %edx,0x4(%esp)
  801deb:	89 04 24             	mov    %eax,(%esp)
  801dee:	e8 19 01 00 00       	call   801f0c <nsipc_shutdown>
}
  801df3:	c9                   	leave  
  801df4:	c3                   	ret    

00801df5 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801df5:	55                   	push   %ebp
  801df6:	89 e5                	mov    %esp,%ebp
  801df8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dfb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfe:	e8 4e ff ff ff       	call   801d51 <fd2sockid>
  801e03:	85 c0                	test   %eax,%eax
  801e05:	78 16                	js     801e1d <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801e07:	8b 55 10             	mov    0x10(%ebp),%edx
  801e0a:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e11:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e15:	89 04 24             	mov    %eax,(%esp)
  801e18:	e8 43 02 00 00       	call   802060 <nsipc_bind>
}
  801e1d:	c9                   	leave  
  801e1e:	c3                   	ret    

00801e1f <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e1f:	55                   	push   %ebp
  801e20:	89 e5                	mov    %esp,%ebp
  801e22:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e25:	8b 45 08             	mov    0x8(%ebp),%eax
  801e28:	e8 24 ff ff ff       	call   801d51 <fd2sockid>
  801e2d:	85 c0                	test   %eax,%eax
  801e2f:	78 1f                	js     801e50 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e31:	8b 55 10             	mov    0x10(%ebp),%edx
  801e34:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e38:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e3b:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e3f:	89 04 24             	mov    %eax,(%esp)
  801e42:	e8 58 02 00 00       	call   80209f <nsipc_accept>
  801e47:	85 c0                	test   %eax,%eax
  801e49:	78 05                	js     801e50 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801e4b:	e8 5e fe ff ff       	call   801cae <alloc_sockfd>
}
  801e50:	c9                   	leave  
  801e51:	c3                   	ret    
	...

00801e60 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e60:	55                   	push   %ebp
  801e61:	89 e5                	mov    %esp,%ebp
  801e63:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801e66:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  801e6c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801e73:	00 
  801e74:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801e7b:	00 
  801e7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e80:	89 14 24             	mov    %edx,(%esp)
  801e83:	e8 18 05 00 00       	call   8023a0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801e88:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e8f:	00 
  801e90:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e97:	00 
  801e98:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e9f:	e8 b0 05 00 00       	call   802454 <ipc_recv>
}
  801ea4:	c9                   	leave  
  801ea5:	c3                   	ret    

00801ea6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801ea6:	55                   	push   %ebp
  801ea7:	89 e5                	mov    %esp,%ebp
  801ea9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801eac:	8b 45 08             	mov    0x8(%ebp),%eax
  801eaf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801eb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb7:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801ebc:	8b 45 10             	mov    0x10(%ebp),%eax
  801ebf:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ec4:	b8 09 00 00 00       	mov    $0x9,%eax
  801ec9:	e8 92 ff ff ff       	call   801e60 <nsipc>
}
  801ece:	c9                   	leave  
  801ecf:	c3                   	ret    

00801ed0 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
  801ed3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ed6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801ede:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801ee6:	b8 06 00 00 00       	mov    $0x6,%eax
  801eeb:	e8 70 ff ff ff       	call   801e60 <nsipc>
}
  801ef0:	c9                   	leave  
  801ef1:	c3                   	ret    

00801ef2 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  801ef2:	55                   	push   %ebp
  801ef3:	89 e5                	mov    %esp,%ebp
  801ef5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ef8:	8b 45 08             	mov    0x8(%ebp),%eax
  801efb:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801f00:	b8 04 00 00 00       	mov    $0x4,%eax
  801f05:	e8 56 ff ff ff       	call   801e60 <nsipc>
}
  801f0a:	c9                   	leave  
  801f0b:	c3                   	ret    

00801f0c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f12:	8b 45 08             	mov    0x8(%ebp),%eax
  801f15:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801f1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f1d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801f22:	b8 03 00 00 00       	mov    $0x3,%eax
  801f27:	e8 34 ff ff ff       	call   801e60 <nsipc>
}
  801f2c:	c9                   	leave  
  801f2d:	c3                   	ret    

00801f2e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801f2e:	55                   	push   %ebp
  801f2f:	89 e5                	mov    %esp,%ebp
  801f31:	53                   	push   %ebx
  801f32:	83 ec 14             	sub    $0x14,%esp
  801f35:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801f38:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801f40:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801f46:	7e 24                	jle    801f6c <nsipc_send+0x3e>
  801f48:	c7 44 24 0c c0 30 80 	movl   $0x8030c0,0xc(%esp)
  801f4f:	00 
  801f50:	c7 44 24 08 cc 30 80 	movl   $0x8030cc,0x8(%esp)
  801f57:	00 
  801f58:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  801f5f:	00 
  801f60:	c7 04 24 e1 30 80 00 	movl   $0x8030e1,(%esp)
  801f67:	e8 48 e4 ff ff       	call   8003b4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801f6c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f70:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f73:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f77:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801f7e:	e8 65 ed ff ff       	call   800ce8 <memmove>
	nsipcbuf.send.req_size = size;
  801f83:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801f89:	8b 45 14             	mov    0x14(%ebp),%eax
  801f8c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801f91:	b8 08 00 00 00       	mov    $0x8,%eax
  801f96:	e8 c5 fe ff ff       	call   801e60 <nsipc>
}
  801f9b:	83 c4 14             	add    $0x14,%esp
  801f9e:	5b                   	pop    %ebx
  801f9f:	5d                   	pop    %ebp
  801fa0:	c3                   	ret    

00801fa1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801fa1:	55                   	push   %ebp
  801fa2:	89 e5                	mov    %esp,%ebp
  801fa4:	56                   	push   %esi
  801fa5:	53                   	push   %ebx
  801fa6:	83 ec 10             	sub    $0x10,%esp
  801fa9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801fac:	8b 45 08             	mov    0x8(%ebp),%eax
  801faf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801fb4:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801fba:	8b 45 14             	mov    0x14(%ebp),%eax
  801fbd:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801fc2:	b8 07 00 00 00       	mov    $0x7,%eax
  801fc7:	e8 94 fe ff ff       	call   801e60 <nsipc>
  801fcc:	89 c3                	mov    %eax,%ebx
  801fce:	85 c0                	test   %eax,%eax
  801fd0:	78 46                	js     802018 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801fd2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801fd7:	7f 04                	jg     801fdd <nsipc_recv+0x3c>
  801fd9:	39 c6                	cmp    %eax,%esi
  801fdb:	7d 24                	jge    802001 <nsipc_recv+0x60>
  801fdd:	c7 44 24 0c ed 30 80 	movl   $0x8030ed,0xc(%esp)
  801fe4:	00 
  801fe5:	c7 44 24 08 cc 30 80 	movl   $0x8030cc,0x8(%esp)
  801fec:	00 
  801fed:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  801ff4:	00 
  801ff5:	c7 04 24 e1 30 80 00 	movl   $0x8030e1,(%esp)
  801ffc:	e8 b3 e3 ff ff       	call   8003b4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802001:	89 44 24 08          	mov    %eax,0x8(%esp)
  802005:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80200c:	00 
  80200d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802010:	89 04 24             	mov    %eax,(%esp)
  802013:	e8 d0 ec ff ff       	call   800ce8 <memmove>
	}

	return r;
}
  802018:	89 d8                	mov    %ebx,%eax
  80201a:	83 c4 10             	add    $0x10,%esp
  80201d:	5b                   	pop    %ebx
  80201e:	5e                   	pop    %esi
  80201f:	5d                   	pop    %ebp
  802020:	c3                   	ret    

00802021 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802021:	55                   	push   %ebp
  802022:	89 e5                	mov    %esp,%ebp
  802024:	53                   	push   %ebx
  802025:	83 ec 14             	sub    $0x14,%esp
  802028:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80202b:	8b 45 08             	mov    0x8(%ebp),%eax
  80202e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802033:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802037:	8b 45 0c             	mov    0xc(%ebp),%eax
  80203a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80203e:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  802045:	e8 9e ec ff ff       	call   800ce8 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80204a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  802050:	b8 05 00 00 00       	mov    $0x5,%eax
  802055:	e8 06 fe ff ff       	call   801e60 <nsipc>
}
  80205a:	83 c4 14             	add    $0x14,%esp
  80205d:	5b                   	pop    %ebx
  80205e:	5d                   	pop    %ebp
  80205f:	c3                   	ret    

00802060 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802060:	55                   	push   %ebp
  802061:	89 e5                	mov    %esp,%ebp
  802063:	53                   	push   %ebx
  802064:	83 ec 14             	sub    $0x14,%esp
  802067:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80206a:	8b 45 08             	mov    0x8(%ebp),%eax
  80206d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802072:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802076:	8b 45 0c             	mov    0xc(%ebp),%eax
  802079:	89 44 24 04          	mov    %eax,0x4(%esp)
  80207d:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  802084:	e8 5f ec ff ff       	call   800ce8 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802089:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80208f:	b8 02 00 00 00       	mov    $0x2,%eax
  802094:	e8 c7 fd ff ff       	call   801e60 <nsipc>
}
  802099:	83 c4 14             	add    $0x14,%esp
  80209c:	5b                   	pop    %ebx
  80209d:	5d                   	pop    %ebp
  80209e:	c3                   	ret    

0080209f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80209f:	55                   	push   %ebp
  8020a0:	89 e5                	mov    %esp,%ebp
  8020a2:	53                   	push   %ebx
  8020a3:	83 ec 14             	sub    $0x14,%esp
	int r;
	
	nsipcbuf.accept.req_s = s;
  8020a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a9:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8020ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b3:	e8 a8 fd ff ff       	call   801e60 <nsipc>
  8020b8:	89 c3                	mov    %eax,%ebx
  8020ba:	85 c0                	test   %eax,%eax
  8020bc:	78 26                	js     8020e4 <nsipc_accept+0x45>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8020be:	a1 10 60 80 00       	mov    0x806010,%eax
  8020c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020c7:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8020ce:	00 
  8020cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d2:	89 04 24             	mov    %eax,(%esp)
  8020d5:	e8 0e ec ff ff       	call   800ce8 <memmove>
		*addrlen = ret->ret_addrlen;
  8020da:	a1 10 60 80 00       	mov    0x806010,%eax
  8020df:	8b 55 10             	mov    0x10(%ebp),%edx
  8020e2:	89 02                	mov    %eax,(%edx)
	}
	return r;
}
  8020e4:	89 d8                	mov    %ebx,%eax
  8020e6:	83 c4 14             	add    $0x14,%esp
  8020e9:	5b                   	pop    %ebx
  8020ea:	5d                   	pop    %ebp
  8020eb:	c3                   	ret    
  8020ec:	00 00                	add    %al,(%eax)
	...

008020f0 <free>:
	return v;
}

void
free(void *v)
{
  8020f0:	55                   	push   %ebp
  8020f1:	89 e5                	mov    %esp,%ebp
  8020f3:	57                   	push   %edi
  8020f4:	56                   	push   %esi
  8020f5:	53                   	push   %ebx
  8020f6:	83 ec 1c             	sub    $0x1c,%esp
  8020f9:	8b 45 08             	mov    0x8(%ebp),%eax
	uint8_t *c;
	uint32_t *ref;

	if (v == 0)
  8020fc:	85 c0                	test   %eax,%eax
  8020fe:	0f 84 b8 00 00 00    	je     8021bc <free+0xcc>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);
  802104:	8b 3d 5c 31 80 00    	mov    0x80315c,%edi
  80210a:	39 c7                	cmp    %eax,%edi
  80210c:	77 0a                	ja     802118 <free+0x28>
  80210e:	8b 35 60 31 80 00    	mov    0x803160,%esi
  802114:	39 f0                	cmp    %esi,%eax
  802116:	72 24                	jb     80213c <free+0x4c>
  802118:	c7 44 24 0c 04 31 80 	movl   $0x803104,0xc(%esp)
  80211f:	00 
  802120:	c7 44 24 08 cc 30 80 	movl   $0x8030cc,0x8(%esp)
  802127:	00 
  802128:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  80212f:	00 
  802130:	c7 04 24 34 31 80 00 	movl   $0x803134,(%esp)
  802137:	e8 78 e2 ff ff       	call   8003b4 <_panic>

	c = ROUNDDOWN(v, PGSIZE);
  80213c:	89 c3                	mov    %eax,%ebx
  80213e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  802144:	eb 42                	jmp    802188 <free+0x98>

	while (vpt[VPN(c)] & PTE_CONTINUED) {
		sys_page_unmap(0, c);
  802146:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80214a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802151:	e8 08 f0 ff ff       	call   80115e <sys_page_unmap>
		c += PGSIZE;
  802156:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		assert(mbegin <= c && c < mend);
  80215c:	39 df                	cmp    %ebx,%edi
  80215e:	77 04                	ja     802164 <free+0x74>
  802160:	39 de                	cmp    %ebx,%esi
  802162:	77 24                	ja     802188 <free+0x98>
  802164:	c7 44 24 0c 41 31 80 	movl   $0x803141,0xc(%esp)
  80216b:	00 
  80216c:	c7 44 24 08 cc 30 80 	movl   $0x8030cc,0x8(%esp)
  802173:	00 
  802174:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
  80217b:	00 
  80217c:	c7 04 24 34 31 80 00 	movl   $0x803134,(%esp)
  802183:	e8 2c e2 ff ff       	call   8003b4 <_panic>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);

	c = ROUNDDOWN(v, PGSIZE);

	while (vpt[VPN(c)] & PTE_CONTINUED) {
  802188:	89 d8                	mov    %ebx,%eax
  80218a:	c1 e8 0c             	shr    $0xc,%eax
  80218d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802194:	f6 c4 04             	test   $0x4,%ah
  802197:	75 ad                	jne    802146 <free+0x56>
	/*
	 * c is just a piece of this page, so dec the ref count
	 * and maybe free the page.
	 */
	ref = (uint32_t*) (c + PGSIZE - 4);
	if (--(*ref) == 0)
  802199:	8b 83 fc 0f 00 00    	mov    0xffc(%ebx),%eax
  80219f:	83 e8 01             	sub    $0x1,%eax
  8021a2:	89 83 fc 0f 00 00    	mov    %eax,0xffc(%ebx)
  8021a8:	85 c0                	test   %eax,%eax
  8021aa:	75 10                	jne    8021bc <free+0xcc>
		sys_page_unmap(0, c);	
  8021ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021b7:	e8 a2 ef ff ff       	call   80115e <sys_page_unmap>
}
  8021bc:	83 c4 1c             	add    $0x1c,%esp
  8021bf:	5b                   	pop    %ebx
  8021c0:	5e                   	pop    %esi
  8021c1:	5f                   	pop    %edi
  8021c2:	5d                   	pop    %ebp
  8021c3:	c3                   	ret    

008021c4 <malloc>:
	return 1;
}

void*
malloc(size_t n)
{
  8021c4:	55                   	push   %ebp
  8021c5:	89 e5                	mov    %esp,%ebp
  8021c7:	57                   	push   %edi
  8021c8:	56                   	push   %esi
  8021c9:	53                   	push   %ebx
  8021ca:	83 ec 1c             	sub    $0x1c,%esp
	int i, cont;
	int nwrap;
	uint32_t *ref;
	void *v;

	if (mptr == 0)
  8021cd:	83 3d 5c 70 80 00 00 	cmpl   $0x0,0x80705c
  8021d4:	75 0a                	jne    8021e0 <malloc+0x1c>
		mptr = mbegin;
  8021d6:	a1 5c 31 80 00       	mov    0x80315c,%eax
  8021db:	a3 5c 70 80 00       	mov    %eax,0x80705c

	n = ROUNDUP(n, 4);
  8021e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e3:	83 c0 03             	add    $0x3,%eax
  8021e6:	83 e0 fc             	and    $0xfffffffc,%eax
  8021e9:	89 45 f0             	mov    %eax,-0x10(%ebp)

	if (n >= MAXMALLOC)
  8021ec:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
  8021f1:	0f 87 90 01 00 00    	ja     802387 <malloc+0x1c3>
		return 0;

	if ((uintptr_t) mptr % PGSIZE){
  8021f7:	8b 0d 5c 70 80 00    	mov    0x80705c,%ecx
  8021fd:	f7 c1 ff 0f 00 00    	test   $0xfff,%ecx
  802203:	74 4a                	je     80224f <malloc+0x8b>
		 * we're in the middle of a partially
		 * allocated page - can we add this chunk?
		 * the +4 below is for the ref count.
		 */
		ref = (uint32_t*) (ROUNDUP(mptr, PGSIZE) - 4);
		if ((uintptr_t) mptr / PGSIZE == (uintptr_t) (mptr + n - 1 + 4) / PGSIZE) {
  802205:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
  802208:	89 ca                	mov    %ecx,%edx
  80220a:	c1 ea 0c             	shr    $0xc,%edx
  80220d:	8d 43 03             	lea    0x3(%ebx),%eax
  802210:	c1 e8 0c             	shr    $0xc,%eax
  802213:	39 c2                	cmp    %eax,%edx
  802215:	75 1c                	jne    802233 <malloc+0x6f>
		/*
		 * we're in the middle of a partially
		 * allocated page - can we add this chunk?
		 * the +4 below is for the ref count.
		 */
		ref = (uint32_t*) (ROUNDUP(mptr, PGSIZE) - 4);
  802217:	8d 81 ff 0f 00 00    	lea    0xfff(%ecx),%eax
  80221d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
		if ((uintptr_t) mptr / PGSIZE == (uintptr_t) (mptr + n - 1 + 4) / PGSIZE) {
			(*ref)++;
  802222:	83 40 fc 01          	addl   $0x1,-0x4(%eax)
			v = mptr;
  802226:	89 ca                	mov    %ecx,%edx
			mptr += n;
  802228:	89 1d 5c 70 80 00    	mov    %ebx,0x80705c
  80222e:	e9 59 01 00 00       	jmp    80238c <malloc+0x1c8>
			return v;
		}
		/*
		 * stop working on this page and move on.
		 */
		free(mptr);	/* drop reference to this page */
  802233:	89 0c 24             	mov    %ecx,(%esp)
  802236:	e8 b5 fe ff ff       	call   8020f0 <free>
		mptr = ROUNDDOWN(mptr + PGSIZE, PGSIZE);
  80223b:	a1 5c 70 80 00       	mov    0x80705c,%eax
  802240:	05 00 10 00 00       	add    $0x1000,%eax
  802245:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80224a:	a3 5c 70 80 00       	mov    %eax,0x80705c
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
		if (va >= (uintptr_t) mend
  80224f:	8b 35 60 31 80 00    	mov    0x803160,%esi
  802255:	8b 1d 5c 70 80 00    	mov    0x80705c,%ebx
	while (1) {
		if (isfree(mptr, n + 4))
			break;
		mptr += PGSIZE;
		if (mptr == mend) {
			mptr = mbegin;
  80225b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	 * runs of more than a page can't have ref counts so we 
	 * flag the PTE entries instead.
	 */
	nwrap = 0;
	while (1) {
		if (isfree(mptr, n + 4))
  802262:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802265:	83 c0 04             	add    $0x4,%eax
  802268:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80226b:	eb 06                	jmp    802273 <malloc+0xaf>
			break;
		mptr += PGSIZE;
		if (mptr == mend) {
			mptr = mbegin;
  80226d:	8b 1d 5c 31 80 00    	mov    0x80315c,%ebx
	 * runs of more than a page can't have ref counts so we 
	 * flag the PTE entries instead.
	 */
	nwrap = 0;
	while (1) {
		if (isfree(mptr, n + 4))
  802273:	8b 7d e8             	mov    -0x18(%ebp),%edi
static uint8_t *mptr;

static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;
  802276:	89 da                	mov    %ebx,%edx
  802278:	8d 0c 3b             	lea    (%ebx,%edi,1),%ecx

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  80227b:	39 cb                	cmp    %ecx,%ebx
  80227d:	0f 83 d3 00 00 00    	jae    802356 <malloc+0x192>
		if (va >= (uintptr_t) mend
  802283:	39 f3                	cmp    %esi,%ebx
  802285:	72 0b                	jb     802292 <malloc+0xce>
  802287:	eb 43                	jmp    8022cc <malloc+0x108>
  802289:	39 f2                	cmp    %esi,%edx
  80228b:	90                   	nop    
  80228c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802290:	73 3a                	jae    8022cc <malloc+0x108>
  802292:	89 d0                	mov    %edx,%eax
  802294:	c1 e8 16             	shr    $0x16,%eax
  802297:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80229e:	a8 01                	test   $0x1,%al
  8022a0:	74 10                	je     8022b2 <malloc+0xee>
  8022a2:	89 d0                	mov    %edx,%eax
  8022a4:	c1 e8 0c             	shr    $0xc,%eax
  8022a7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8022ae:	a8 01                	test   $0x1,%al
  8022b0:	75 1a                	jne    8022cc <malloc+0x108>
static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  8022b2:	81 c2 00 10 00 00    	add    $0x1000,%edx
  8022b8:	39 d1                	cmp    %edx,%ecx
  8022ba:	77 cd                	ja     802289 <malloc+0xc5>
  8022bc:	89 1d 5c 70 80 00    	mov    %ebx,0x80705c
  8022c2:	be 00 00 00 00       	mov    $0x0,%esi
  8022c7:	e9 9b 00 00 00       	jmp    802367 <malloc+0x1a3>
	 */
	nwrap = 0;
	while (1) {
		if (isfree(mptr, n + 4))
			break;
		mptr += PGSIZE;
  8022cc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		if (mptr == mend) {
  8022d2:	3b 1d 60 31 80 00    	cmp    0x803160,%ebx
  8022d8:	75 99                	jne    802273 <malloc+0xaf>
			mptr = mbegin;
			if (++nwrap == 2)
  8022da:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  8022de:	83 7d ec 02          	cmpl   $0x2,-0x14(%ebp)
  8022e2:	75 89                	jne    80226d <malloc+0xa9>
  8022e4:	8b 0d 5c 31 80 00    	mov    0x80315c,%ecx
  8022ea:	89 0d 5c 70 80 00    	mov    %ecx,0x80705c
  8022f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8022f5:	e9 92 00 00 00       	jmp    80238c <malloc+0x1c8>

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
  8022fa:	8d 9e 00 10 00 00    	lea    0x1000(%esi),%ebx
  802300:	39 fb                	cmp    %edi,%ebx
  802302:	19 c0                	sbb    %eax,%eax
  802304:	25 00 04 00 00       	and    $0x400,%eax
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
  802309:	83 c8 07             	or     $0x7,%eax
  80230c:	8d 93 00 f0 ff ff    	lea    -0x1000(%ebx),%edx
  802312:	03 15 5c 70 80 00    	add    0x80705c,%edx
  802318:	89 44 24 08          	mov    %eax,0x8(%esp)
  80231c:	89 54 24 04          	mov    %edx,0x4(%esp)
  802320:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802327:	e8 ee ee ff ff       	call   80121a <sys_page_alloc>
  80232c:	85 c0                	test   %eax,%eax
  80232e:	79 35                	jns    802365 <malloc+0x1a1>
			for (; i >= 0; i -= PGSIZE)
  802330:	85 f6                	test   %esi,%esi
  802332:	78 53                	js     802387 <malloc+0x1c3>
				sys_page_unmap(0, mptr + i);
  802334:	89 f0                	mov    %esi,%eax
  802336:	03 05 5c 70 80 00    	add    0x80705c,%eax
  80233c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802340:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802347:	e8 12 ee ff ff       	call   80115e <sys_page_unmap>
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
			for (; i >= 0; i -= PGSIZE)
  80234c:	81 ee 00 10 00 00    	sub    $0x1000,%esi
  802352:	78 33                	js     802387 <malloc+0x1c3>
  802354:	eb de                	jmp    802334 <malloc+0x170>
  802356:	89 1d 5c 70 80 00    	mov    %ebx,0x80705c
  80235c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802360:	e9 5d ff ff ff       	jmp    8022c2 <malloc+0xfe>
  802365:	89 de                	mov    %ebx,%esi
	}

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
  802367:	39 fe                	cmp    %edi,%esi
  802369:	72 8f                	jb     8022fa <malloc+0x136>
				sys_page_unmap(0, mptr + i);
			return 0;	/* out of physical memory */
		}
	}

	ref = (uint32_t*) (mptr + i - 4);
  80236b:	a1 5c 70 80 00       	mov    0x80705c,%eax
	*ref = 2;	/* reference for mptr, reference for returned block */
  802370:	c7 44 30 fc 02 00 00 	movl   $0x2,-0x4(%eax,%esi,1)
  802377:	00 
	v = mptr;
  802378:	89 c2                	mov    %eax,%edx
	mptr += n;
  80237a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  80237d:	8d 04 08             	lea    (%eax,%ecx,1),%eax
  802380:	a3 5c 70 80 00       	mov    %eax,0x80705c
  802385:	eb 05                	jmp    80238c <malloc+0x1c8>
	return v;
  802387:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80238c:	89 d0                	mov    %edx,%eax
  80238e:	83 c4 1c             	add    $0x1c,%esp
  802391:	5b                   	pop    %ebx
  802392:	5e                   	pop    %esi
  802393:	5f                   	pop    %edi
  802394:	5d                   	pop    %ebp
  802395:	c3                   	ret    
	...

008023a0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023a0:	55                   	push   %ebp
  8023a1:	89 e5                	mov    %esp,%ebp
  8023a3:	57                   	push   %edi
  8023a4:	56                   	push   %esi
  8023a5:	53                   	push   %ebx
  8023a6:	83 ec 1c             	sub    $0x1c,%esp
  8023a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8023ac:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  8023af:	e8 f9 ee ff ff       	call   8012ad <sys_getenvid>
  8023b4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8023b9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8023bc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8023c1:	a3 70 70 80 00       	mov    %eax,0x807070
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  8023c6:	e8 e2 ee ff ff       	call   8012ad <sys_getenvid>
  8023cb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8023d0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8023d3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8023d8:	a3 70 70 80 00       	mov    %eax,0x807070
		if(env->env_id==to_env){
  8023dd:	8b 40 4c             	mov    0x4c(%eax),%eax
  8023e0:	39 f0                	cmp    %esi,%eax
  8023e2:	75 0e                	jne    8023f2 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  8023e4:	c7 04 24 64 31 80 00 	movl   $0x803164,(%esp)
  8023eb:	e8 91 e0 ff ff       	call   800481 <cprintf>
  8023f0:	eb 5a                	jmp    80244c <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  8023f2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8023f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8023f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  802400:	89 44 24 04          	mov    %eax,0x4(%esp)
  802404:	89 34 24             	mov    %esi,(%esp)
  802407:	e8 00 ec ff ff       	call   80100c <sys_ipc_try_send>
  80240c:	89 c3                	mov    %eax,%ebx
  80240e:	85 c0                	test   %eax,%eax
  802410:	79 25                	jns    802437 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  802412:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802415:	74 2b                	je     802442 <ipc_send+0xa2>
				panic("send error:%e",r);
  802417:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80241b:	c7 44 24 08 80 31 80 	movl   $0x803180,0x8(%esp)
  802422:	00 
  802423:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80242a:	00 
  80242b:	c7 04 24 8e 31 80 00 	movl   $0x80318e,(%esp)
  802432:	e8 7d df ff ff       	call   8003b4 <_panic>
		}
			sys_yield();
  802437:	e8 3d ee ff ff       	call   801279 <sys_yield>
		
	}while(r!=0);
  80243c:	85 db                	test   %ebx,%ebx
  80243e:	75 86                	jne    8023c6 <ipc_send+0x26>
  802440:	eb 0a                	jmp    80244c <ipc_send+0xac>
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
		{	
			if(r!=-E_IPC_NOT_RECV)
				panic("send error:%e",r);
		}
			sys_yield();
  802442:	e8 32 ee ff ff       	call   801279 <sys_yield>
  802447:	e9 7a ff ff ff       	jmp    8023c6 <ipc_send+0x26>
		
	}while(r!=0);
	return;
	//panic("ipc_send not implemented");
}
  80244c:	83 c4 1c             	add    $0x1c,%esp
  80244f:	5b                   	pop    %ebx
  802450:	5e                   	pop    %esi
  802451:	5f                   	pop    %edi
  802452:	5d                   	pop    %ebp
  802453:	c3                   	ret    

00802454 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802454:	55                   	push   %ebp
  802455:	89 e5                	mov    %esp,%ebp
  802457:	57                   	push   %edi
  802458:	56                   	push   %esi
  802459:	53                   	push   %ebx
  80245a:	83 ec 0c             	sub    $0xc,%esp
  80245d:	8b 75 08             	mov    0x8(%ebp),%esi
  802460:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	void *dstva=NULL;
	if(pg)
		dstva=pg;
	env = &envs[ENVX(sys_getenvid())];
  802463:	e8 45 ee ff ff       	call   8012ad <sys_getenvid>
  802468:	25 ff 03 00 00       	and    $0x3ff,%eax
  80246d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802470:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802475:	a3 70 70 80 00       	mov    %eax,0x807070
	if(from_env_store&&(env->env_id==*from_env_store))
  80247a:	85 f6                	test   %esi,%esi
  80247c:	74 29                	je     8024a7 <ipc_recv+0x53>
  80247e:	8b 40 4c             	mov    0x4c(%eax),%eax
  802481:	3b 06                	cmp    (%esi),%eax
  802483:	75 22                	jne    8024a7 <ipc_recv+0x53>
	{
		*from_env_store=0;
  802485:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  80248b:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("send:the reciver is sender\n");
  802491:	c7 04 24 64 31 80 00 	movl   $0x803164,(%esp)
  802498:	e8 e4 df ff ff       	call   800481 <cprintf>
  80249d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024a2:	e9 8a 00 00 00       	jmp    802531 <ipc_recv+0xdd>
		return 0;
	}
	env = &envs[ENVX(sys_getenvid())];
  8024a7:	e8 01 ee ff ff       	call   8012ad <sys_getenvid>
  8024ac:	25 ff 03 00 00       	and    $0x3ff,%eax
  8024b1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8024b4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8024b9:	a3 70 70 80 00       	mov    %eax,0x807070
	if((r=sys_ipc_recv(dstva))<0)
  8024be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024c1:	89 04 24             	mov    %eax,(%esp)
  8024c4:	e8 e6 ea ff ff       	call   800faf <sys_ipc_recv>
  8024c9:	89 c3                	mov    %eax,%ebx
  8024cb:	85 c0                	test   %eax,%eax
  8024cd:	79 1a                	jns    8024e9 <ipc_recv+0x95>
	{
		*from_env_store=0;
  8024cf:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  8024d5:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("reciver failed\n");
  8024db:	c7 04 24 98 31 80 00 	movl   $0x803198,(%esp)
  8024e2:	e8 9a df ff ff       	call   800481 <cprintf>
  8024e7:	eb 48                	jmp    802531 <ipc_recv+0xdd>
		return r;
	}
	else{//接收成功
		env = &envs[ENVX(sys_getenvid())];
  8024e9:	e8 bf ed ff ff       	call   8012ad <sys_getenvid>
  8024ee:	25 ff 03 00 00       	and    $0x3ff,%eax
  8024f3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8024f6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8024fb:	a3 70 70 80 00       	mov    %eax,0x807070
		if(from_env_store)
  802500:	85 f6                	test   %esi,%esi
  802502:	74 05                	je     802509 <ipc_recv+0xb5>
			*from_env_store=env->env_ipc_from;	
  802504:	8b 40 74             	mov    0x74(%eax),%eax
  802507:	89 06                	mov    %eax,(%esi)
		if(perm_store)
  802509:	85 ff                	test   %edi,%edi
  80250b:	74 0a                	je     802517 <ipc_recv+0xc3>
			*perm_store=env->env_ipc_perm;
  80250d:	a1 70 70 80 00       	mov    0x807070,%eax
  802512:	8b 40 78             	mov    0x78(%eax),%eax
  802515:	89 07                	mov    %eax,(%edi)
		env = &envs[ENVX(sys_getenvid())];
  802517:	e8 91 ed ff ff       	call   8012ad <sys_getenvid>
  80251c:	25 ff 03 00 00       	and    $0x3ff,%eax
  802521:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802524:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802529:	a3 70 70 80 00       	mov    %eax,0x807070
		return env->env_ipc_value;
  80252e:	8b 58 70             	mov    0x70(%eax),%ebx
	}
	//panic("ipc_recv not implemented");
	return 0;
}
  802531:	89 d8                	mov    %ebx,%eax
  802533:	83 c4 0c             	add    $0xc,%esp
  802536:	5b                   	pop    %ebx
  802537:	5e                   	pop    %esi
  802538:	5f                   	pop    %edi
  802539:	5d                   	pop    %ebp
  80253a:	c3                   	ret    
  80253b:	00 00                	add    %al,(%eax)
  80253d:	00 00                	add    %al,(%eax)
	...

00802540 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  802540:	55                   	push   %ebp
  802541:	89 e5                	mov    %esp,%ebp
  802543:	57                   	push   %edi
  802544:	56                   	push   %esi
  802545:	53                   	push   %ebx
  802546:	83 ec 18             	sub    $0x18,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  802549:	8b 45 08             	mov    0x8(%ebp),%eax
  80254c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  80254f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802552:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802555:	be 00 00 00 00       	mov    $0x0,%esi
  80255a:	bf 60 70 80 00       	mov    $0x807060,%edi
  80255f:	c6 45 e3 00          	movb   $0x0,-0x1d(%ebp)
  802563:	eb 02                	jmp    802567 <inet_ntoa+0x27>
  for(n = 0; n < 4; n++) {
  802565:	89 c6                	mov    %eax,%esi
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  802567:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80256a:	0f b6 0a             	movzbl (%edx),%ecx
      *ap /= (u8_t)10;
  80256d:	b8 cd ff ff ff       	mov    $0xffffffcd,%eax
  802572:	f6 e1                	mul    %cl
  802574:	89 c2                	mov    %eax,%edx
  802576:	66 c1 ea 08          	shr    $0x8,%dx
  80257a:	c0 ea 03             	shr    $0x3,%dl
  80257d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  802580:	88 10                	mov    %dl,(%eax)
      inv[i++] = '0' + rem;
  802582:	89 f0                	mov    %esi,%eax
  802584:	0f b6 d8             	movzbl %al,%ebx
  802587:	8d 04 92             	lea    (%edx,%edx,4),%eax
  80258a:	01 c0                	add    %eax,%eax
  80258c:	28 c1                	sub    %al,%cl
  80258e:	83 c1 30             	add    $0x30,%ecx
  802591:	88 4c 1d ed          	mov    %cl,-0x13(%ebp,%ebx,1)
  802595:	8d 46 01             	lea    0x1(%esi),%eax
    } while(*ap);
  802598:	84 d2                	test   %dl,%dl
  80259a:	75 c9                	jne    802565 <inet_ntoa+0x25>
    while(i--)
  80259c:	89 f1                	mov    %esi,%ecx
  80259e:	80 f9 ff             	cmp    $0xff,%cl
  8025a1:	74 20                	je     8025c3 <inet_ntoa+0x83>
  8025a3:	89 fa                	mov    %edi,%edx
      *rp++ = inv[i];
  8025a5:	0f b6 c1             	movzbl %cl,%eax
  8025a8:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  8025ad:	88 02                	mov    %al,(%edx)
  8025af:	83 c2 01             	add    $0x1,%edx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  8025b2:	83 e9 01             	sub    $0x1,%ecx
  8025b5:	80 f9 ff             	cmp    $0xff,%cl
  8025b8:	75 eb                	jne    8025a5 <inet_ntoa+0x65>
  8025ba:	89 f2                	mov    %esi,%edx
  8025bc:	0f b6 c2             	movzbl %dl,%eax
  8025bf:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
      *rp++ = inv[i];
    *rp++ = '.';
  8025c3:	c6 07 2e             	movb   $0x2e,(%edi)
  8025c6:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  8025c9:	80 45 e3 01          	addb   $0x1,-0x1d(%ebp)
  8025cd:	80 7d e3 03          	cmpb   $0x3,-0x1d(%ebp)
  8025d1:	77 0b                	ja     8025de <inet_ntoa+0x9e>
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  8025d3:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  8025d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8025dc:	eb 87                	jmp    802565 <inet_ntoa+0x25>
  }
  *--rp = 0;
  8025de:	c6 47 ff 00          	movb   $0x0,-0x1(%edi)
  return str;
}
  8025e2:	b8 60 70 80 00       	mov    $0x807060,%eax
  8025e7:	83 c4 18             	add    $0x18,%esp
  8025ea:	5b                   	pop    %ebx
  8025eb:	5e                   	pop    %esi
  8025ec:	5f                   	pop    %edi
  8025ed:	5d                   	pop    %ebp
  8025ee:	c3                   	ret    

008025ef <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  8025ef:	55                   	push   %ebp
  8025f0:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  8025f2:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8025f6:	89 c2                	mov    %eax,%edx
  8025f8:	c1 ea 08             	shr    $0x8,%edx
  8025fb:	c1 e0 08             	shl    $0x8,%eax
  8025fe:	09 d0                	or     %edx,%eax
  802600:	0f b7 c0             	movzwl %ax,%eax
}
  802603:	5d                   	pop    %ebp
  802604:	c3                   	ret    

00802605 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  802605:	55                   	push   %ebp
  802606:	89 e5                	mov    %esp,%ebp
  802608:	83 ec 04             	sub    $0x4,%esp
  return htons(n);
  80260b:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80260f:	89 04 24             	mov    %eax,(%esp)
  802612:	e8 d8 ff ff ff       	call   8025ef <htons>
  802617:	0f b7 c0             	movzwl %ax,%eax
}
  80261a:	c9                   	leave  
  80261b:	c3                   	ret    

0080261c <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  80261c:	55                   	push   %ebp
  80261d:	89 e5                	mov    %esp,%ebp
  80261f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802622:	89 c8                	mov    %ecx,%eax
  802624:	25 00 ff 00 00       	and    $0xff00,%eax
  802629:	c1 e0 08             	shl    $0x8,%eax
  80262c:	89 ca                	mov    %ecx,%edx
  80262e:	c1 e2 18             	shl    $0x18,%edx
  802631:	09 d0                	or     %edx,%eax
  802633:	89 ca                	mov    %ecx,%edx
  802635:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  80263b:	c1 ea 08             	shr    $0x8,%edx
  80263e:	09 d0                	or     %edx,%eax
  802640:	c1 e9 18             	shr    $0x18,%ecx
  802643:	09 c8                	or     %ecx,%eax
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  802645:	5d                   	pop    %ebp
  802646:	c3                   	ret    

00802647 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  802647:	55                   	push   %ebp
  802648:	89 e5                	mov    %esp,%ebp
  80264a:	57                   	push   %edi
  80264b:	56                   	push   %esi
  80264c:	53                   	push   %ebx
  80264d:	83 ec 24             	sub    $0x24,%esp
  802650:	8b 55 08             	mov    0x8(%ebp),%edx
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  802653:	0f be 32             	movsbl (%edx),%esi
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  802656:	8d 46 d0             	lea    -0x30(%esi),%eax
  802659:	3c 09                	cmp    $0x9,%al
  80265b:	0f 87 c0 01 00 00    	ja     802821 <inet_aton+0x1da>
  802661:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802664:	89 45 e0             	mov    %eax,-0x20(%ebp)
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  802667:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80266a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     */
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
  80266d:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
  802674:	83 fe 30             	cmp    $0x30,%esi
  802677:	75 24                	jne    80269d <inet_aton+0x56>
      c = *++cp;
  802679:	83 c2 01             	add    $0x1,%edx
  80267c:	0f be 32             	movsbl (%edx),%esi
      if (c == 'x' || c == 'X') {
  80267f:	83 fe 78             	cmp    $0x78,%esi
  802682:	74 0c                	je     802690 <inet_aton+0x49>
  802684:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  80268b:	83 fe 58             	cmp    $0x58,%esi
  80268e:	75 0d                	jne    80269d <inet_aton+0x56>
        base = 16;
        c = *++cp;
  802690:	83 c2 01             	add    $0x1,%edx
  802693:	0f be 32             	movsbl (%edx),%esi
  802696:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
  80269d:	8d 5a 01             	lea    0x1(%edx),%ebx
  8026a0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8026a7:	eb 03                	jmp    8026ac <inet_aton+0x65>
  8026a9:	83 c3 01             	add    $0x1,%ebx
  8026ac:	8d 7b ff             	lea    -0x1(%ebx),%edi
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  8026af:	89 f1                	mov    %esi,%ecx
  8026b1:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8026b4:	3c 09                	cmp    $0x9,%al
  8026b6:	77 13                	ja     8026cb <inet_aton+0x84>
        val = (val * base) + (int)(c - '0');
  8026b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8026bb:	0f af 45 d8          	imul   -0x28(%ebp),%eax
  8026bf:	8d 74 06 d0          	lea    -0x30(%esi,%eax,1),%esi
  8026c3:	89 75 d8             	mov    %esi,-0x28(%ebp)
        c = *++cp;
  8026c6:	0f be 33             	movsbl (%ebx),%esi
  8026c9:	eb de                	jmp    8026a9 <inet_aton+0x62>
      } else if (base == 16 && isxdigit(c)) {
  8026cb:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  8026cf:	75 2c                	jne    8026fd <inet_aton+0xb6>
  8026d1:	8d 51 9f             	lea    -0x61(%ecx),%edx
  8026d4:	80 fa 05             	cmp    $0x5,%dl
  8026d7:	76 07                	jbe    8026e0 <inet_aton+0x99>
  8026d9:	8d 41 bf             	lea    -0x41(%ecx),%eax
  8026dc:	3c 05                	cmp    $0x5,%al
  8026de:	77 1d                	ja     8026fd <inet_aton+0xb6>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  8026e0:	80 fa 1a             	cmp    $0x1a,%dl
  8026e3:	19 c0                	sbb    %eax,%eax
  8026e5:	83 e0 20             	and    $0x20,%eax
  8026e8:	29 c6                	sub    %eax,%esi
  8026ea:	8d 46 c9             	lea    -0x37(%esi),%eax
  8026ed:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8026f0:	c1 e2 04             	shl    $0x4,%edx
  8026f3:	09 d0                	or     %edx,%eax
  8026f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
        c = *++cp;
  8026f8:	0f be 33             	movsbl (%ebx),%esi
  8026fb:	eb ac                	jmp    8026a9 <inet_aton+0x62>
      } else
        break;
    }
    if (c == '.') {
  8026fd:	83 fe 2e             	cmp    $0x2e,%esi
  802700:	75 2c                	jne    80272e <inet_aton+0xe7>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  802702:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802705:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  802708:	0f 86 13 01 00 00    	jbe    802821 <inet_aton+0x1da>
        return (0);
      *pp++ = val;
  80270e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802711:	89 02                	mov    %eax,(%edx)
      c = *++cp;
  802713:	8d 57 01             	lea    0x1(%edi),%edx
  802716:	0f be 77 01          	movsbl 0x1(%edi),%esi
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  80271a:	8d 46 d0             	lea    -0x30(%esi),%eax
  80271d:	3c 09                	cmp    $0x9,%al
  80271f:	0f 87 fc 00 00 00    	ja     802821 <inet_aton+0x1da>
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
      *pp++ = val;
  802725:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
  802729:	e9 3f ff ff ff       	jmp    80266d <inet_aton+0x26>
  80272e:	8b 5d d8             	mov    -0x28(%ebp),%ebx
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  802731:	85 f6                	test   %esi,%esi
  802733:	74 36                	je     80276b <inet_aton+0x124>
  802735:	80 f9 1f             	cmp    $0x1f,%cl
  802738:	0f 86 e3 00 00 00    	jbe    802821 <inet_aton+0x1da>
  80273e:	89 f2                	mov    %esi,%edx
  802740:	84 d2                	test   %dl,%dl
  802742:	0f 88 d9 00 00 00    	js     802821 <inet_aton+0x1da>
  802748:	83 fe 20             	cmp    $0x20,%esi
  80274b:	74 1e                	je     80276b <inet_aton+0x124>
  80274d:	83 fe 0c             	cmp    $0xc,%esi
  802750:	74 19                	je     80276b <inet_aton+0x124>
  802752:	83 fe 0a             	cmp    $0xa,%esi
  802755:	74 14                	je     80276b <inet_aton+0x124>
  802757:	83 fe 0d             	cmp    $0xd,%esi
  80275a:	74 0f                	je     80276b <inet_aton+0x124>
  80275c:	83 fe 09             	cmp    $0x9,%esi
  80275f:	90                   	nop    
  802760:	74 09                	je     80276b <inet_aton+0x124>
  802762:	83 fe 0b             	cmp    $0xb,%esi
  802765:	0f 85 b6 00 00 00    	jne    802821 <inet_aton+0x1da>
    return (0);
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  80276b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  switch (n) {
  80276e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802771:	29 c2                	sub    %eax,%edx
  802773:	89 d0                	mov    %edx,%eax
  802775:	c1 f8 02             	sar    $0x2,%eax
  802778:	83 c0 01             	add    $0x1,%eax
  80277b:	83 f8 02             	cmp    $0x2,%eax
  80277e:	74 24                	je     8027a4 <inet_aton+0x15d>
  802780:	83 f8 02             	cmp    $0x2,%eax
  802783:	7f 0d                	jg     802792 <inet_aton+0x14b>
  802785:	85 c0                	test   %eax,%eax
  802787:	0f 84 94 00 00 00    	je     802821 <inet_aton+0x1da>
  80278d:	8d 76 00             	lea    0x0(%esi),%esi
  802790:	eb 6d                	jmp    8027ff <inet_aton+0x1b8>
  802792:	83 f8 03             	cmp    $0x3,%eax
  802795:	74 28                	je     8027bf <inet_aton+0x178>
  802797:	83 f8 04             	cmp    $0x4,%eax
  80279a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027a0:	75 5d                	jne    8027ff <inet_aton+0x1b8>
  8027a2:	eb 38                	jmp    8027dc <inet_aton+0x195>

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  8027a4:	81 fb ff ff ff 00    	cmp    $0xffffff,%ebx
  8027aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027b0:	77 6f                	ja     802821 <inet_aton+0x1da>
      return (0);
    val |= parts[0] << 24;
  8027b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8027b5:	c1 e0 18             	shl    $0x18,%eax
  8027b8:	09 c3                	or     %eax,%ebx
  8027ba:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8027bd:	eb 40                	jmp    8027ff <inet_aton+0x1b8>
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  8027bf:	81 fb ff ff 00 00    	cmp    $0xffff,%ebx
  8027c5:	77 5a                	ja     802821 <inet_aton+0x1da>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  8027c7:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8027ca:	c1 e2 10             	shl    $0x10,%edx
  8027cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8027d0:	c1 e0 18             	shl    $0x18,%eax
  8027d3:	09 c2                	or     %eax,%edx
  8027d5:	09 da                	or     %ebx,%edx
  8027d7:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8027da:	eb 23                	jmp    8027ff <inet_aton+0x1b8>
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  8027dc:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
  8027e2:	77 3d                	ja     802821 <inet_aton+0x1da>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  8027e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8027e7:	c1 e0 10             	shl    $0x10,%eax
  8027ea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8027ed:	c1 e2 18             	shl    $0x18,%edx
  8027f0:	09 d0                	or     %edx,%eax
  8027f2:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8027f5:	c1 e2 08             	shl    $0x8,%edx
  8027f8:	09 d0                	or     %edx,%eax
  8027fa:	09 d8                	or     %ebx,%eax
  8027fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
    break;
  }
  if (addr)
  8027ff:	b8 01 00 00 00       	mov    $0x1,%eax
  802804:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802808:	74 1c                	je     802826 <inet_aton+0x1df>
    addr->s_addr = htonl(val);
  80280a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80280d:	89 04 24             	mov    %eax,(%esp)
  802810:	e8 07 fe ff ff       	call   80261c <htonl>
  802815:	8b 55 0c             	mov    0xc(%ebp),%edx
  802818:	89 02                	mov    %eax,(%edx)
  80281a:	b8 01 00 00 00       	mov    $0x1,%eax
  80281f:	eb 05                	jmp    802826 <inet_aton+0x1df>
  802821:	b8 00 00 00 00       	mov    $0x0,%eax
  return (1);
}
  802826:	83 c4 24             	add    $0x24,%esp
  802829:	5b                   	pop    %ebx
  80282a:	5e                   	pop    %esi
  80282b:	5f                   	pop    %edi
  80282c:	5d                   	pop    %ebp
  80282d:	c3                   	ret    

0080282e <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  80282e:	55                   	push   %ebp
  80282f:	89 e5                	mov    %esp,%ebp
  802831:	83 ec 18             	sub    $0x18,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  802834:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802837:	89 44 24 04          	mov    %eax,0x4(%esp)
  80283b:	8b 45 08             	mov    0x8(%ebp),%eax
  80283e:	89 04 24             	mov    %eax,(%esp)
  802841:	e8 01 fe ff ff       	call   802647 <inet_aton>
  802846:	83 f8 01             	cmp    $0x1,%eax
  802849:	19 c0                	sbb    %eax,%eax
  80284b:	0b 45 fc             	or     -0x4(%ebp),%eax
    return (val.s_addr);
  }
  return (INADDR_NONE);
}
  80284e:	c9                   	leave  
  80284f:	c3                   	ret    

00802850 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  802850:	55                   	push   %ebp
  802851:	89 e5                	mov    %esp,%ebp
  802853:	83 ec 04             	sub    $0x4,%esp
  return htonl(n);
  802856:	8b 45 08             	mov    0x8(%ebp),%eax
  802859:	89 04 24             	mov    %eax,(%esp)
  80285c:	e8 bb fd ff ff       	call   80261c <htonl>
}
  802861:	c9                   	leave  
  802862:	c3                   	ret    
	...

00802870 <__udivdi3>:
  802870:	55                   	push   %ebp
  802871:	89 e5                	mov    %esp,%ebp
  802873:	57                   	push   %edi
  802874:	56                   	push   %esi
  802875:	83 ec 18             	sub    $0x18,%esp
  802878:	8b 45 10             	mov    0x10(%ebp),%eax
  80287b:	8b 55 14             	mov    0x14(%ebp),%edx
  80287e:	8b 75 0c             	mov    0xc(%ebp),%esi
  802881:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802884:	89 c1                	mov    %eax,%ecx
  802886:	8b 45 08             	mov    0x8(%ebp),%eax
  802889:	85 d2                	test   %edx,%edx
  80288b:	89 d7                	mov    %edx,%edi
  80288d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802890:	75 1e                	jne    8028b0 <__udivdi3+0x40>
  802892:	39 f1                	cmp    %esi,%ecx
  802894:	0f 86 8d 00 00 00    	jbe    802927 <__udivdi3+0xb7>
  80289a:	89 f2                	mov    %esi,%edx
  80289c:	31 f6                	xor    %esi,%esi
  80289e:	f7 f1                	div    %ecx
  8028a0:	89 c1                	mov    %eax,%ecx
  8028a2:	89 c8                	mov    %ecx,%eax
  8028a4:	89 f2                	mov    %esi,%edx
  8028a6:	83 c4 18             	add    $0x18,%esp
  8028a9:	5e                   	pop    %esi
  8028aa:	5f                   	pop    %edi
  8028ab:	5d                   	pop    %ebp
  8028ac:	c3                   	ret    
  8028ad:	8d 76 00             	lea    0x0(%esi),%esi
  8028b0:	39 f2                	cmp    %esi,%edx
  8028b2:	0f 87 a8 00 00 00    	ja     802960 <__udivdi3+0xf0>
  8028b8:	0f bd c2             	bsr    %edx,%eax
  8028bb:	83 f0 1f             	xor    $0x1f,%eax
  8028be:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8028c1:	0f 84 89 00 00 00    	je     802950 <__udivdi3+0xe0>
  8028c7:	b8 20 00 00 00       	mov    $0x20,%eax
  8028cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8028cf:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8028d2:	89 c1                	mov    %eax,%ecx
  8028d4:	d3 ea                	shr    %cl,%edx
  8028d6:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  8028da:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8028dd:	89 f8                	mov    %edi,%eax
  8028df:	8b 7d f4             	mov    -0xc(%ebp),%edi
  8028e2:	d3 e0                	shl    %cl,%eax
  8028e4:	09 c2                	or     %eax,%edx
  8028e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8028e9:	d3 e7                	shl    %cl,%edi
  8028eb:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8028ef:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8028f2:	89 f2                	mov    %esi,%edx
  8028f4:	d3 e8                	shr    %cl,%eax
  8028f6:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  8028fa:	d3 e2                	shl    %cl,%edx
  8028fc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802900:	09 d0                	or     %edx,%eax
  802902:	d3 ee                	shr    %cl,%esi
  802904:	89 f2                	mov    %esi,%edx
  802906:	f7 75 e4             	divl   -0x1c(%ebp)
  802909:	89 d1                	mov    %edx,%ecx
  80290b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80290e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802911:	f7 e7                	mul    %edi
  802913:	39 d1                	cmp    %edx,%ecx
  802915:	89 c6                	mov    %eax,%esi
  802917:	72 70                	jb     802989 <__udivdi3+0x119>
  802919:	39 ca                	cmp    %ecx,%edx
  80291b:	74 5f                	je     80297c <__udivdi3+0x10c>
  80291d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802920:	31 f6                	xor    %esi,%esi
  802922:	e9 7b ff ff ff       	jmp    8028a2 <__udivdi3+0x32>
  802927:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80292a:	85 c0                	test   %eax,%eax
  80292c:	75 0c                	jne    80293a <__udivdi3+0xca>
  80292e:	b8 01 00 00 00       	mov    $0x1,%eax
  802933:	31 d2                	xor    %edx,%edx
  802935:	f7 75 f4             	divl   -0xc(%ebp)
  802938:	89 c1                	mov    %eax,%ecx
  80293a:	89 f0                	mov    %esi,%eax
  80293c:	89 fa                	mov    %edi,%edx
  80293e:	f7 f1                	div    %ecx
  802940:	89 c6                	mov    %eax,%esi
  802942:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802945:	f7 f1                	div    %ecx
  802947:	89 c1                	mov    %eax,%ecx
  802949:	e9 54 ff ff ff       	jmp    8028a2 <__udivdi3+0x32>
  80294e:	66 90                	xchg   %ax,%ax
  802950:	39 d6                	cmp    %edx,%esi
  802952:	77 1c                	ja     802970 <__udivdi3+0x100>
  802954:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802957:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  80295a:	73 14                	jae    802970 <__udivdi3+0x100>
  80295c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802960:	31 c9                	xor    %ecx,%ecx
  802962:	31 f6                	xor    %esi,%esi
  802964:	e9 39 ff ff ff       	jmp    8028a2 <__udivdi3+0x32>
  802969:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  802970:	b9 01 00 00 00       	mov    $0x1,%ecx
  802975:	31 f6                	xor    %esi,%esi
  802977:	e9 26 ff ff ff       	jmp    8028a2 <__udivdi3+0x32>
  80297c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80297f:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  802983:	d3 e0                	shl    %cl,%eax
  802985:	39 c6                	cmp    %eax,%esi
  802987:	76 94                	jbe    80291d <__udivdi3+0xad>
  802989:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80298c:	31 f6                	xor    %esi,%esi
  80298e:	83 e9 01             	sub    $0x1,%ecx
  802991:	e9 0c ff ff ff       	jmp    8028a2 <__udivdi3+0x32>
	...

008029a0 <__umoddi3>:
  8029a0:	55                   	push   %ebp
  8029a1:	89 e5                	mov    %esp,%ebp
  8029a3:	57                   	push   %edi
  8029a4:	56                   	push   %esi
  8029a5:	83 ec 30             	sub    $0x30,%esp
  8029a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8029ab:	8b 55 14             	mov    0x14(%ebp),%edx
  8029ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8029b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8029b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8029b7:	89 c1                	mov    %eax,%ecx
  8029b9:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8029bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8029bf:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8029c6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8029cd:	89 fa                	mov    %edi,%edx
  8029cf:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8029d2:	85 c0                	test   %eax,%eax
  8029d4:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8029d7:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8029da:	75 14                	jne    8029f0 <__umoddi3+0x50>
  8029dc:	39 f9                	cmp    %edi,%ecx
  8029de:	76 60                	jbe    802a40 <__umoddi3+0xa0>
  8029e0:	89 f0                	mov    %esi,%eax
  8029e2:	f7 f1                	div    %ecx
  8029e4:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8029e7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8029ee:	eb 10                	jmp    802a00 <__umoddi3+0x60>
  8029f0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8029f3:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  8029f6:	76 18                	jbe    802a10 <__umoddi3+0x70>
  8029f8:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8029fb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8029fe:	66 90                	xchg   %ax,%ax
  802a00:	8b 45 d0             	mov    -0x30(%ebp),%eax
  802a03:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  802a06:	83 c4 30             	add    $0x30,%esp
  802a09:	5e                   	pop    %esi
  802a0a:	5f                   	pop    %edi
  802a0b:	5d                   	pop    %ebp
  802a0c:	c3                   	ret    
  802a0d:	8d 76 00             	lea    0x0(%esi),%esi
  802a10:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
  802a14:	83 f0 1f             	xor    $0x1f,%eax
  802a17:	89 45 d8             	mov    %eax,-0x28(%ebp)
  802a1a:	75 46                	jne    802a62 <__umoddi3+0xc2>
  802a1c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802a1f:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  802a22:	0f 87 c9 00 00 00    	ja     802af1 <__umoddi3+0x151>
  802a28:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  802a2b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  802a2e:	0f 83 bd 00 00 00    	jae    802af1 <__umoddi3+0x151>
  802a34:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802a37:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  802a3a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  802a3d:	eb c1                	jmp    802a00 <__umoddi3+0x60>
  802a3f:	90                   	nop    
  802a40:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802a43:	85 c0                	test   %eax,%eax
  802a45:	75 0c                	jne    802a53 <__umoddi3+0xb3>
  802a47:	b8 01 00 00 00       	mov    $0x1,%eax
  802a4c:	31 d2                	xor    %edx,%edx
  802a4e:	f7 75 ec             	divl   -0x14(%ebp)
  802a51:	89 c1                	mov    %eax,%ecx
  802a53:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802a56:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802a59:	f7 f1                	div    %ecx
  802a5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802a5e:	f7 f1                	div    %ecx
  802a60:	eb 82                	jmp    8029e4 <__umoddi3+0x44>
  802a62:	b8 20 00 00 00       	mov    $0x20,%eax
  802a67:	8b 55 ec             	mov    -0x14(%ebp),%edx
  802a6a:	2b 45 d8             	sub    -0x28(%ebp),%eax
  802a6d:	8b 75 ec             	mov    -0x14(%ebp),%esi
  802a70:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802a73:	89 c1                	mov    %eax,%ecx
  802a75:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802a78:	d3 ea                	shr    %cl,%edx
  802a7a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802a7d:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  802a81:	d3 e0                	shl    %cl,%eax
  802a83:	09 c2                	or     %eax,%edx
  802a85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802a88:	d3 e6                	shl    %cl,%esi
  802a8a:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  802a8e:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802a91:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802a94:	d3 e8                	shr    %cl,%eax
  802a96:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  802a9a:	d3 e2                	shl    %cl,%edx
  802a9c:	09 d0                	or     %edx,%eax
  802a9e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802aa1:	d3 e7                	shl    %cl,%edi
  802aa3:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  802aa7:	d3 ea                	shr    %cl,%edx
  802aa9:	f7 75 f4             	divl   -0xc(%ebp)
  802aac:	89 55 cc             	mov    %edx,-0x34(%ebp)
  802aaf:	f7 e6                	mul    %esi
  802ab1:	39 55 cc             	cmp    %edx,-0x34(%ebp)
  802ab4:	72 53                	jb     802b09 <__umoddi3+0x169>
  802ab6:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  802ab9:	74 4a                	je     802b05 <__umoddi3+0x165>
  802abb:	90                   	nop    
  802abc:	8d 74 26 00          	lea    0x0(%esi),%esi
  802ac0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  802ac3:	29 c7                	sub    %eax,%edi
  802ac5:	19 d1                	sbb    %edx,%ecx
  802ac7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  802aca:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  802ace:	89 fa                	mov    %edi,%edx
  802ad0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802ad3:	d3 ea                	shr    %cl,%edx
  802ad5:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  802ad9:	d3 e0                	shl    %cl,%eax
  802adb:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  802adf:	09 c2                	or     %eax,%edx
  802ae1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802ae4:	89 55 d0             	mov    %edx,-0x30(%ebp)
  802ae7:	d3 e8                	shr    %cl,%eax
  802ae9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  802aec:	e9 0f ff ff ff       	jmp    802a00 <__umoddi3+0x60>
  802af1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802af4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802af7:	2b 45 ec             	sub    -0x14(%ebp),%eax
  802afa:	1b 55 e8             	sbb    -0x18(%ebp),%edx
  802afd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802b00:	e9 2f ff ff ff       	jmp    802a34 <__umoddi3+0x94>
  802b05:	39 f8                	cmp    %edi,%eax
  802b07:	76 b7                	jbe    802ac0 <__umoddi3+0x120>
  802b09:	29 f0                	sub    %esi,%eax
  802b0b:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802b0e:	eb b0                	jmp    802ac0 <__umoddi3+0x120>
