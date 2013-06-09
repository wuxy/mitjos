
obj/user/httpd:     file format elf32-i386

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
  80002c:	e8 0b 03 00 00       	call   80033c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <die>:
};

static void
die(char *m)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 08             	sub    $0x8,%esp
	cprintf("%s\n", m);
  80003a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80003e:	c7 04 24 40 2b 80 00 	movl   $0x802b40,(%esp)
  800045:	e8 37 04 00 00       	call   800481 <cprintf>
	exit();
  80004a:	e8 49 03 00 00       	call   800398 <exit>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    

00800051 <umain>:

static void
req_free(struct http_request *req)
{
	free(req->url);
	free(req->version);
}

static int
send_header(struct http_request *req, int code)
{
	struct responce_header *h = headers;
	while (h->code != 0 && h->header!= 0) {
		if (h->code == code)
			break;
		h++;
	}

	if (h->code == 0)
		return -1;

	int len = strlen(h->header);
	if (write(req->sock, h->header, len) != len) {
		die("Failed to send bytes to client");
	}
	
	return 0;
}

static int
send_data(struct http_request *req, int fd)
{
	// LAB 6: Your code here.
	panic("send_data not implemented");
}

static int
send_size(struct http_request *req, off_t size)
{
	char buf[64];
	int r;

	r = snprintf(buf, 64, "Content-Length: %ld\r\n", (long)size);
	if (r > 63)
		panic("buffer too small!");

	if (write(req->sock, buf, r) != r)
		return -1;

	return 0;
}

static const char*
mime_type(const char *file)
{
	//TODO: for now only a single mime type
	return "text/html";
}

static int
send_content_type(struct http_request *req)
{
	char buf[128];
	int r;
	const char *type;

	type = mime_type(req->url);
	if (!type)
		return -1;

	r = snprintf(buf, 128, "Content-Type: %s\r\n", type);
	if (r > 127)
		panic("buffer too small!");

	if (write(req->sock, buf, r) != r)
		return -1;

	return 0;
}

static int
send_header_fin(struct http_request *req)
{
	char *fin = "\r\n";
	int fin_len = strlen(fin);

	if (write(req->sock, fin, fin_len) != fin_len)
		return -1;

	return 0;
}

// given a request, this function creates a struct http_request
static int
http_request_parse(struct http_request *req, char *request)
{
	const char *url;
	const char *version;
	int url_len, version_len;

	if (!req)
		return -1;

	if (strncmp(request, "GET ", 4) != 0)
		return -E_BAD_REQ;

	// skip GET
	request += 4;

	// get the url
	url = request;
	while (*request && *request != ' ')
		request++;
	url_len = request - url;

	req->url = malloc(url_len + 1);
	memmove(req->url, url, url_len);
	req->url[url_len] = '\0';

	// skip space
	request++;

	version = request;
	while (*request && *request != '\n')
		request++;
	version_len = request - version;

	req->version = malloc(version_len + 1);
	memmove(req->version, version, version_len);
	req->version[version_len] = '\0';

	// no entity parsing

	return 0;
}

static int
send_error(struct http_request *req, int code)
{
	char buf[512];
	int r;

	struct error_messages *e = errors;
	while (e->code != 0 && e->msg != 0) {
		if (e->code == code)
			break;
		e++;
	}
	
	if (e->code == 0)
		return -1;

	r = snprintf(buf, 512, "HTTP/" HTTP_VERSION" %d %s\r\n"
			       "Server: jhttpd/" VERSION "\r\n"
			       "Connection: close"
			       "Content-type: text/html\r\n"
			       "\r\n"
			       "<html><body><p>%d - %s</p></body></html>\r\n",
			       e->code, e->msg, e->code, e->msg);

	if (write(req->sock, buf, r) != r)
		return -1;

	return 0;
}

static int
send_file(struct http_request *req)
{
	int r;
	off_t file_size = -1;
	int fd;

	// open the requested url for reading
	// if the file does not exist, send a 404 error using send_error
	// if the file is a directory, send a 404 error using send_error
	// set file_size to the size of the file

	// LAB 6: Your code here.
	panic("send_file not implemented");

	if ((r = send_header(req, 200)) < 0)
		goto end;

	if ((r = send_size(req, file_size)) < 0)
		goto end;

	if ((r = send_content_type(req)) < 0)
		goto end;

	if ((r = send_header_fin(req)) < 0)
		goto end;

	r = send_data(req, fd);

end:
	close(fd);
	return r;
}

static void
handle_client(int sock)
{
	struct http_request con_d;
	int r;
	char buffer[BUFFSIZE];
	int received = -1;
	struct http_request *req = &con_d;

	while (1) 
	{
		// Receive message
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
			panic("failed to read");

		memset(req, 0, sizeof(req));

		req->sock = sock;

		r = http_request_parse(req, buffer);
		if (r == -E_BAD_REQ)
			send_error(req, 400);
		else if (r < 0)
			panic("parse failed");
		else
			send_file(req);

		req_free(req);

		// no keep alive
		break;
	}

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
  80005d:	c7 05 20 70 80 00 44 	movl   $0x802b44,0x807020
  800064:	2b 80 00 

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  800067:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800076:	00 
  800077:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80007e:	e8 b2 1c 00 00       	call   801d35 <socket>
  800083:	89 c7                	mov    %eax,%edi
  800085:	85 c0                	test   %eax,%eax
  800087:	79 0a                	jns    800093 <umain+0x42>
		die("Failed to create socket");
  800089:	b8 4b 2b 80 00       	mov    $0x802b4b,%eax
  80008e:	e8 a1 ff ff ff       	call   800034 <die>

	// Construct the server sockaddr_in structure
	memset(&server, 0, sizeof(server));		// Clear struct
  800093:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  80009a:	00 
  80009b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000a2:	00 
  8000a3:	8d 5d e4             	lea    0xffffffe4(%ebp),%ebx
  8000a6:	89 1c 24             	mov    %ebx,(%esp)
  8000a9:	e8 03 0c 00 00       	call   800cb1 <memset>
	server.sin_family = AF_INET;			// Internet/IP
  8000ae:	c6 45 e5 02          	movb   $0x2,0xffffffe5(%ebp)
	server.sin_addr.s_addr = htonl(INADDR_ANY);	// IP address
  8000b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b9:	e8 8e 25 00 00       	call   80264c <htonl>
  8000be:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
	server.sin_port = htons(PORT);			// server port
  8000c1:	c7 04 24 50 00 00 00 	movl   $0x50,(%esp)
  8000c8:	e8 52 25 00 00       	call   80261f <htons>
  8000cd:	66 89 45 e6          	mov    %ax,0xffffffe6(%ebp)

	// Bind the server socket
	if (bind(serversock, (struct sockaddr *) &server,
  8000d1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  8000d8:	00 
  8000d9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000dd:	89 3c 24             	mov    %edi,(%esp)
  8000e0:	e8 32 1d 00 00       	call   801e17 <bind>
  8000e5:	85 c0                	test   %eax,%eax
  8000e7:	79 0a                	jns    8000f3 <umain+0xa2>
		 sizeof(server)) < 0) 
	{
		die("Failed to bind the server socket");
  8000e9:	b8 b4 2b 80 00       	mov    $0x802bb4,%eax
  8000ee:	e8 41 ff ff ff       	call   800034 <die>
	}

	// Listen on the server socket
	if (listen(serversock, MAXPENDING) < 0)
  8000f3:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  8000fa:	00 
  8000fb:	89 3c 24             	mov    %edi,(%esp)
  8000fe:	e8 92 1c 00 00       	call   801d95 <listen>
  800103:	85 c0                	test   %eax,%eax
  800105:	79 0a                	jns    800111 <umain+0xc0>
		die("Failed to listen on server socket");
  800107:	b8 d8 2b 80 00       	mov    $0x802bd8,%eax
  80010c:	e8 23 ff ff ff       	call   800034 <die>

	cprintf("Waiting for http connections...\n");
  800111:	c7 04 24 fc 2b 80 00 	movl   $0x802bfc,(%esp)
  800118:	e8 64 03 00 00       	call   800481 <cprintf>

	while (1) {
		unsigned int clientlen = sizeof(client);
  80011d:	c7 45 d0 10 00 00 00 	movl   $0x10,0xffffffd0(%ebp)
		// Wait for client connection
		if ((clientsock = accept(serversock,
  800124:	8d 55 d4             	lea    0xffffffd4(%ebp),%edx
  800127:	8d 45 d0             	lea    0xffffffd0(%ebp),%eax
  80012a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80012e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800132:	89 3c 24             	mov    %edi,(%esp)
  800135:	e8 0d 1d 00 00       	call   801e47 <accept>
  80013a:	89 c6                	mov    %eax,%esi
  80013c:	85 c0                	test   %eax,%eax
  80013e:	79 0a                	jns    80014a <umain+0xf9>
					 (struct sockaddr *) &client,
					 &clientlen)) < 0) 
		{
			die("Failed to accept client connection");
  800140:	b8 20 2c 80 00       	mov    $0x802c20,%eax
  800145:	e8 ea fe ff ff       	call   800034 <die>
  80014a:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800151:	00 
  800152:	8d 85 c4 fd ff ff    	lea    0xfffffdc4(%ebp),%eax
  800158:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015c:	89 34 24             	mov    %esi,(%esp)
  80015f:	e8 d9 14 00 00       	call   80163d <read>
  800164:	85 c0                	test   %eax,%eax
  800166:	79 1c                	jns    800184 <umain+0x133>
  800168:	c7 44 24 08 63 2b 80 	movl   $0x802b63,0x8(%esp)
  80016f:	00 
  800170:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
  800177:	00 
  800178:	c7 04 24 72 2b 80 00 	movl   $0x802b72,(%esp)
  80017f:	e8 30 02 00 00       	call   8003b4 <_panic>
  800184:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  80018b:	00 
  80018c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800193:	00 
  800194:	8d 45 c4             	lea    0xffffffc4(%ebp),%eax
  800197:	89 04 24             	mov    %eax,(%esp)
  80019a:	e8 12 0b 00 00       	call   800cb1 <memset>
  80019f:	89 75 c4             	mov    %esi,0xffffffc4(%ebp)
  8001a2:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  8001a9:	00 
  8001aa:	c7 44 24 04 7f 2b 80 	movl   $0x802b7f,0x4(%esp)
  8001b1:	00 
  8001b2:	8d 85 c4 fd ff ff    	lea    0xfffffdc4(%ebp),%eax
  8001b8:	89 04 24             	mov    %eax,(%esp)
  8001bb:	e8 55 0a 00 00       	call   800c15 <strncmp>
  8001c0:	85 c0                	test   %eax,%eax
  8001c2:	0f 85 3e 01 00 00    	jne    800306 <umain+0x2b5>
  8001c8:	0f b6 85 c8 fd ff ff 	movzbl 0xfffffdc8(%ebp),%eax
  8001cf:	84 c0                	test   %al,%al
  8001d1:	74 0a                	je     8001dd <umain+0x18c>
  8001d3:	8d bd c8 fd ff ff    	lea    0xfffffdc8(%ebp),%edi
  8001d9:	3c 20                	cmp    $0x20,%al
  8001db:	75 08                	jne    8001e5 <umain+0x194>
  8001dd:	8d bd c8 fd ff ff    	lea    0xfffffdc8(%ebp),%edi
  8001e3:	eb 0e                	jmp    8001f3 <umain+0x1a2>
  8001e5:	83 c7 01             	add    $0x1,%edi
  8001e8:	0f b6 07             	movzbl (%edi),%eax
  8001eb:	84 c0                	test   %al,%al
  8001ed:	74 04                	je     8001f3 <umain+0x1a2>
  8001ef:	3c 20                	cmp    $0x20,%al
  8001f1:	75 f2                	jne    8001e5 <umain+0x194>
  8001f3:	8d b5 c8 fd ff ff    	lea    0xfffffdc8(%ebp),%esi
  8001f9:	89 fb                	mov    %edi,%ebx
  8001fb:	29 f3                	sub    %esi,%ebx
  8001fd:	8d 43 01             	lea    0x1(%ebx),%eax
  800200:	89 04 24             	mov    %eax,(%esp)
  800203:	e8 fc 1f 00 00       	call   802204 <malloc>
  800208:	89 45 c8             	mov    %eax,0xffffffc8(%ebp)
  80020b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80020f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800213:	89 04 24             	mov    %eax,(%esp)
  800216:	e8 ef 0a 00 00       	call   800d0a <memmove>
  80021b:	8b 45 c8             	mov    0xffffffc8(%ebp),%eax
  80021e:	c6 04 18 00          	movb   $0x0,(%eax,%ebx,1)
  800222:	8d 47 01             	lea    0x1(%edi),%eax
  800225:	89 c6                	mov    %eax,%esi
  800227:	0f b6 57 01          	movzbl 0x1(%edi),%edx
  80022b:	84 d2                	test   %dl,%dl
  80022d:	74 14                	je     800243 <umain+0x1f2>
  80022f:	80 fa 0a             	cmp    $0xa,%dl
  800232:	74 0f                	je     800243 <umain+0x1f2>
  800234:	83 c0 01             	add    $0x1,%eax
  800237:	0f b6 10             	movzbl (%eax),%edx
  80023a:	84 d2                	test   %dl,%dl
  80023c:	74 05                	je     800243 <umain+0x1f2>
  80023e:	80 fa 0a             	cmp    $0xa,%dl
  800241:	75 f1                	jne    800234 <umain+0x1e3>
  800243:	89 c3                	mov    %eax,%ebx
  800245:	29 f3                	sub    %esi,%ebx
  800247:	8d 43 01             	lea    0x1(%ebx),%eax
  80024a:	89 04 24             	mov    %eax,(%esp)
  80024d:	e8 b2 1f 00 00       	call   802204 <malloc>
  800252:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  800255:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800259:	89 74 24 04          	mov    %esi,0x4(%esp)
  80025d:	89 04 24             	mov    %eax,(%esp)
  800260:	e8 a5 0a 00 00       	call   800d0a <memmove>
  800265:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  800268:	c6 04 18 00          	movb   $0x0,(%eax,%ebx,1)
  80026c:	c7 44 24 08 84 2b 80 	movl   $0x802b84,0x8(%esp)
  800273:	00 
  800274:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
  80027b:	00 
  80027c:	c7 04 24 72 2b 80 00 	movl   $0x802b72,(%esp)
  800283:	e8 2c 01 00 00       	call   8003b4 <_panic>
  800288:	81 fa 90 01 00 00    	cmp    $0x190,%edx
  80028e:	74 0f                	je     80029f <umain+0x24e>
  800290:	83 c0 08             	add    $0x8,%eax
  800293:	8b 10                	mov    (%eax),%edx
  800295:	85 d2                	test   %edx,%edx
  800297:	74 4a                	je     8002e3 <umain+0x292>
  800299:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
  80029d:	75 e9                	jne    800288 <umain+0x237>
  80029f:	8b 40 04             	mov    0x4(%eax),%eax
  8002a2:	89 44 24 18          	mov    %eax,0x18(%esp)
  8002a6:	89 54 24 14          	mov    %edx,0x14(%esp)
  8002aa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ae:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002b2:	c7 44 24 08 44 2c 80 	movl   $0x802c44,0x8(%esp)
  8002b9:	00 
  8002ba:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
  8002c1:	00 
  8002c2:	8d 9d c4 fb ff ff    	lea    0xfffffbc4(%ebp),%ebx
  8002c8:	89 1c 24             	mov    %ebx,(%esp)
  8002cb:	e8 7f 07 00 00       	call   800a4f <snprintf>
  8002d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002d8:	8b 45 c4             	mov    0xffffffc4(%ebp),%eax
  8002db:	89 04 24             	mov    %eax,(%esp)
  8002de:	e8 cf 12 00 00       	call   8015b2 <write>
  8002e3:	8b 45 c8             	mov    0xffffffc8(%ebp),%eax
  8002e6:	89 04 24             	mov    %eax,(%esp)
  8002e9:	e8 42 1e 00 00       	call   802130 <free>
  8002ee:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  8002f1:	89 04 24             	mov    %eax,(%esp)
  8002f4:	e8 37 1e 00 00       	call   802130 <free>
  8002f9:	89 34 24             	mov    %esi,(%esp)
  8002fc:	e8 aa 14 00 00       	call   8017ab <close>
  800301:	e9 17 fe ff ff       	jmp    80011d <umain+0xcc>
  800306:	8b 15 10 70 80 00    	mov    0x807010,%edx
  80030c:	85 d2                	test   %edx,%edx
  80030e:	74 d3                	je     8002e3 <umain+0x292>
  800310:	b8 10 70 80 00       	mov    $0x807010,%eax
  800315:	83 3d 14 70 80 00 00 	cmpl   $0x0,0x807014
  80031c:	74 81                	je     80029f <umain+0x24e>
  80031e:	b8 10 70 80 00       	mov    $0x807010,%eax
  800323:	81 fa 90 01 00 00    	cmp    $0x190,%edx
  800329:	0f 84 70 ff ff ff    	je     80029f <umain+0x24e>
  80032f:	b8 10 70 80 00       	mov    $0x807010,%eax
  800334:	e9 57 ff ff ff       	jmp    800290 <umain+0x23f>
  800339:	00 00                	add    %al,(%eax)
	...

0080033c <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	83 ec 18             	sub    $0x18,%esp
  800342:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  800345:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  800348:	8b 75 08             	mov    0x8(%ebp),%esi
  80034b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  80034e:	c7 05 70 70 80 00 00 	movl   $0x0,0x807070
  800355:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  800358:	e8 60 0f 00 00       	call   8012bd <sys_getenvid>
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

	// call user main routine调用用户主例程
	umain(argc, argv);
  80037a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80037e:	89 34 24             	mov    %esi,(%esp)
  800381:	e8 cb fc ff ff       	call   800051 <umain>

	// exit gracefully
	exit();
  800386:	e8 0d 00 00 00       	call   800398 <exit>
}
  80038b:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  80038e:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
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
  80039e:	e8 a3 15 00 00       	call   801946 <close_all>
	sys_env_destroy(0);
  8003a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003aa:	e8 42 0f 00 00       	call   8012f1 <sys_env_destroy>
}
  8003af:	c9                   	leave  
  8003b0:	c3                   	ret    
  8003b1:	00 00                	add    %al,(%eax)
	...

008003b4 <_panic>:
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
  8003bd:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)

	// Print the panic message
	if (argv0)
  8003c0:	a1 74 70 80 00       	mov    0x807074,%eax
  8003c5:	85 c0                	test   %eax,%eax
  8003c7:	74 10                	je     8003d9 <_panic+0x25>
		cprintf("%s: ", argv0);
  8003c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003cd:	c7 04 24 fd 2c 80 00 	movl   $0x802cfd,(%esp)
  8003d4:	e8 a8 00 00 00       	call   800481 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8003d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003e7:	a1 20 70 80 00       	mov    0x807020,%eax
  8003ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f0:	c7 04 24 02 2d 80 00 	movl   $0x802d02,(%esp)
  8003f7:	e8 85 00 00 00       	call   800481 <cprintf>
	vcprintf(fmt, ap);
  8003fc:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  8003ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800403:	8b 45 10             	mov    0x10(%ebp),%eax
  800406:	89 04 24             	mov    %eax,(%esp)
  800409:	e8 12 00 00 00       	call   800420 <vcprintf>
	cprintf("\n");
  80040e:	c7 04 24 c6 31 80 00 	movl   $0x8031c6,(%esp)
  800415:	e8 67 00 00 00       	call   800481 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80041a:	cc                   	int3   
  80041b:	eb fd                	jmp    80041a <_panic+0x66>
  80041d:	00 00                	add    %al,(%eax)
	...

00800420 <vcprintf>:
}

int
vcprintf(const char *fmt, va_list ap)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800429:	c7 85 f8 fe ff ff 00 	movl   $0x0,0xfffffef8(%ebp)
  800430:	00 00 00 
	b.cnt = 0;
  800433:	c7 85 fc fe ff ff 00 	movl   $0x0,0xfffffefc(%ebp)
  80043a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80043d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800440:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800444:	8b 45 08             	mov    0x8(%ebp),%eax
  800447:	89 44 24 08          	mov    %eax,0x8(%esp)
  80044b:	8d 85 f8 fe ff ff    	lea    0xfffffef8(%ebp),%eax
  800451:	89 44 24 04          	mov    %eax,0x4(%esp)
  800455:	c7 04 24 9e 04 80 00 	movl   $0x80049e,(%esp)
  80045c:	e8 c0 01 00 00       	call   800621 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800461:	8b 85 f8 fe ff ff    	mov    0xfffffef8(%ebp),%eax
  800467:	89 44 24 04          	mov    %eax,0x4(%esp)
  80046b:	8d 85 00 ff ff ff    	lea    0xffffff00(%ebp),%eax
  800471:	89 04 24             	mov    %eax,(%esp)
  800474:	e8 df 0a 00 00       	call   800f58 <sys_cputs>
  800479:	8b 85 fc fe ff ff    	mov    0xfffffefc(%ebp),%eax

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
  80048a:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
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
  80049e:	55                   	push   %ebp
  80049f:	89 e5                	mov    %esp,%ebp
  8004a1:	53                   	push   %ebx
  8004a2:	83 ec 14             	sub    $0x14,%esp
  8004a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004a8:	8b 03                	mov    (%ebx),%eax
  8004aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8004ad:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004b1:	83 c0 01             	add    $0x1,%eax
  8004b4:	89 03                	mov    %eax,(%ebx)
  8004b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004bb:	75 19                	jne    8004d6 <putch+0x38>
  8004bd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004c4:	00 
  8004c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8004c8:	89 04 24             	mov    %eax,(%esp)
  8004cb:	e8 88 0a 00 00       	call   800f58 <sys_cputs>
  8004d0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8004d6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
  8004da:	83 c4 14             	add    $0x14,%esp
  8004dd:	5b                   	pop    %ebx
  8004de:	5d                   	pop    %ebp
  8004df:	c3                   	ret    

008004e0 <printnum>:
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
  8004e9:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8004ec:	89 d7                	mov    %edx,%edi
  8004ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004f4:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  8004f7:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  8004fa:	8b 55 10             	mov    0x10(%ebp),%edx
  8004fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800500:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800503:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  800506:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  80050d:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800510:	39 4d ec             	cmp    %ecx,0xffffffec(%ebp)
  800513:	72 11                	jb     800526 <printnum+0x46>
  800515:	8b 4d d8             	mov    0xffffffd8(%ebp),%ecx
  800518:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  80051b:	76 09                	jbe    800526 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80051d:	8d 58 ff             	lea    0xffffffff(%eax),%ebx
  800520:	85 db                	test   %ebx,%ebx
  800522:	7f 54                	jg     800578 <printnum+0x98>
  800524:	eb 61                	jmp    800587 <printnum+0xa7>
  800526:	89 74 24 10          	mov    %esi,0x10(%esp)
  80052a:	83 e8 01             	sub    $0x1,%eax
  80052d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800531:	89 54 24 08          	mov    %edx,0x8(%esp)
  800535:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800539:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80053d:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800540:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800543:	89 44 24 08          	mov    %eax,0x8(%esp)
  800547:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80054b:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  80054e:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800551:	89 14 24             	mov    %edx,(%esp)
  800554:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800558:	e8 13 23 00 00       	call   802870 <__udivdi3>
  80055d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800561:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800565:	89 04 24             	mov    %eax,(%esp)
  800568:	89 54 24 04          	mov    %edx,0x4(%esp)
  80056c:	89 fa                	mov    %edi,%edx
  80056e:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  800571:	e8 6a ff ff ff       	call   8004e0 <printnum>
  800576:	eb 0f                	jmp    800587 <printnum+0xa7>
			putch(padc, putdat);
  800578:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80057c:	89 34 24             	mov    %esi,(%esp)
  80057f:	ff 55 e4             	call   *0xffffffe4(%ebp)
  800582:	83 eb 01             	sub    $0x1,%ebx
  800585:	75 f1                	jne    800578 <printnum+0x98>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800587:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80058b:	8b 74 24 04          	mov    0x4(%esp),%esi
  80058f:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800592:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800595:	89 44 24 08          	mov    %eax,0x8(%esp)
  800599:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80059d:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  8005a0:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  8005a3:	89 14 24             	mov    %edx,(%esp)
  8005a6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005aa:	e8 f1 23 00 00       	call   8029a0 <__umoddi3>
  8005af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005b3:	0f be 80 1e 2d 80 00 	movsbl 0x802d1e(%eax),%eax
  8005ba:	89 04 24             	mov    %eax,(%esp)
  8005bd:	ff 55 e4             	call   *0xffffffe4(%ebp)
}
  8005c0:	83 c4 3c             	add    $0x3c,%esp
  8005c3:	5b                   	pop    %ebx
  8005c4:	5e                   	pop    %esi
  8005c5:	5f                   	pop    %edi
  8005c6:	5d                   	pop    %ebp
  8005c7:	c3                   	ret    

008005c8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005c8:	55                   	push   %ebp
  8005c9:	89 e5                	mov    %esp,%ebp
  8005cb:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8005cd:	83 fa 01             	cmp    $0x1,%edx
  8005d0:	7e 0e                	jle    8005e0 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8005d2:	8b 10                	mov    (%eax),%edx
  8005d4:	8d 42 08             	lea    0x8(%edx),%eax
  8005d7:	89 01                	mov    %eax,(%ecx)
  8005d9:	8b 02                	mov    (%edx),%eax
  8005db:	8b 52 04             	mov    0x4(%edx),%edx
  8005de:	eb 22                	jmp    800602 <getuint+0x3a>
	else if (lflag)
  8005e0:	85 d2                	test   %edx,%edx
  8005e2:	74 10                	je     8005f4 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8005e4:	8b 10                	mov    (%eax),%edx
  8005e6:	8d 42 04             	lea    0x4(%edx),%eax
  8005e9:	89 01                	mov    %eax,(%ecx)
  8005eb:	8b 02                	mov    (%edx),%eax
  8005ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8005f2:	eb 0e                	jmp    800602 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  8005f4:	8b 10                	mov    (%eax),%edx
  8005f6:	8d 42 04             	lea    0x4(%edx),%eax
  8005f9:	89 01                	mov    %eax,(%ecx)
  8005fb:	8b 02                	mov    (%edx),%eax
  8005fd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800602:	5d                   	pop    %ebp
  800603:	c3                   	ret    

00800604 <sprintputch>:

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
  800604:	55                   	push   %ebp
  800605:	89 e5                	mov    %esp,%ebp
  800607:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  80060a:	83 41 08 01          	addl   $0x1,0x8(%ecx)
	if (b->buf < b->ebuf)
  80060e:	8b 11                	mov    (%ecx),%edx
  800610:	3b 51 04             	cmp    0x4(%ecx),%edx
  800613:	73 0a                	jae    80061f <sprintputch+0x1b>
		*b->buf++ = ch;
  800615:	8b 45 08             	mov    0x8(%ebp),%eax
  800618:	88 02                	mov    %al,(%edx)
  80061a:	8d 42 01             	lea    0x1(%edx),%eax
  80061d:	89 01                	mov    %eax,(%ecx)
}
  80061f:	5d                   	pop    %ebp
  800620:	c3                   	ret    

00800621 <vprintfmt>:
  800621:	55                   	push   %ebp
  800622:	89 e5                	mov    %esp,%ebp
  800624:	57                   	push   %edi
  800625:	56                   	push   %esi
  800626:	53                   	push   %ebx
  800627:	83 ec 4c             	sub    $0x4c,%esp
  80062a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80062d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800630:	eb 03                	jmp    800635 <vprintfmt+0x14>
  800632:	8b 5d e8             	mov    0xffffffe8(%ebp),%ebx
  800635:	0f b6 03             	movzbl (%ebx),%eax
  800638:	83 c3 01             	add    $0x1,%ebx
  80063b:	3c 25                	cmp    $0x25,%al
  80063d:	74 30                	je     80066f <vprintfmt+0x4e>
  80063f:	84 c0                	test   %al,%al
  800641:	0f 84 a8 03 00 00    	je     8009ef <vprintfmt+0x3ce>
  800647:	0f b6 d0             	movzbl %al,%edx
  80064a:	eb 0a                	jmp    800656 <vprintfmt+0x35>
  80064c:	84 c0                	test   %al,%al
  80064e:	66 90                	xchg   %ax,%ax
  800650:	0f 84 99 03 00 00    	je     8009ef <vprintfmt+0x3ce>
  800656:	8b 45 0c             	mov    0xc(%ebp),%eax
  800659:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065d:	89 14 24             	mov    %edx,(%esp)
  800660:	ff d7                	call   *%edi
  800662:	0f b6 03             	movzbl (%ebx),%eax
  800665:	0f b6 d0             	movzbl %al,%edx
  800668:	83 c3 01             	add    $0x1,%ebx
  80066b:	3c 25                	cmp    $0x25,%al
  80066d:	75 dd                	jne    80064c <vprintfmt+0x2b>
  80066f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800674:	c7 45 ec ff ff ff ff 	movl   $0xffffffff,0xffffffec(%ebp)
  80067b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  800682:	c7 45 dc 00 00 00 00 	movl   $0x0,0xffffffdc(%ebp)
  800689:	c6 45 e3 20          	movb   $0x20,0xffffffe3(%ebp)
  80068d:	eb 07                	jmp    800696 <vprintfmt+0x75>
  80068f:	c7 45 dc 01 00 00 00 	movl   $0x1,0xffffffdc(%ebp)
  800696:	0f b6 03             	movzbl (%ebx),%eax
  800699:	0f b6 d0             	movzbl %al,%edx
  80069c:	83 c3 01             	add    $0x1,%ebx
  80069f:	83 e8 23             	sub    $0x23,%eax
  8006a2:	3c 55                	cmp    $0x55,%al
  8006a4:	0f 87 11 03 00 00    	ja     8009bb <vprintfmt+0x39a>
  8006aa:	0f b6 c0             	movzbl %al,%eax
  8006ad:	ff 24 85 60 2e 80 00 	jmp    *0x802e60(,%eax,4)
  8006b4:	c6 45 e3 30          	movb   $0x30,0xffffffe3(%ebp)
  8006b8:	eb dc                	jmp    800696 <vprintfmt+0x75>
  8006ba:	83 ea 30             	sub    $0x30,%edx
  8006bd:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  8006c0:	0f be 13             	movsbl (%ebx),%edx
  8006c3:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  8006c6:	83 f8 09             	cmp    $0x9,%eax
  8006c9:	76 08                	jbe    8006d3 <vprintfmt+0xb2>
  8006cb:	eb 42                	jmp    80070f <vprintfmt+0xee>
  8006cd:	c6 45 e3 2d          	movb   $0x2d,0xffffffe3(%ebp)
  8006d1:	eb c3                	jmp    800696 <vprintfmt+0x75>
  8006d3:	83 c3 01             	add    $0x1,%ebx
  8006d6:	8b 75 e4             	mov    0xffffffe4(%ebp),%esi
  8006d9:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8006dc:	8d 44 42 d0          	lea    0xffffffd0(%edx,%eax,2),%eax
  8006e0:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8006e3:	0f be 13             	movsbl (%ebx),%edx
  8006e6:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  8006e9:	83 f8 09             	cmp    $0x9,%eax
  8006ec:	77 21                	ja     80070f <vprintfmt+0xee>
  8006ee:	eb e3                	jmp    8006d3 <vprintfmt+0xb2>
  8006f0:	8b 55 14             	mov    0x14(%ebp),%edx
  8006f3:	8d 42 04             	lea    0x4(%edx),%eax
  8006f6:	89 45 14             	mov    %eax,0x14(%ebp)
  8006f9:	8b 12                	mov    (%edx),%edx
  8006fb:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  8006fe:	eb 0f                	jmp    80070f <vprintfmt+0xee>
  800700:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800704:	79 90                	jns    800696 <vprintfmt+0x75>
  800706:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  80070d:	eb 87                	jmp    800696 <vprintfmt+0x75>
  80070f:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800713:	79 81                	jns    800696 <vprintfmt+0x75>
  800715:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  800718:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  80071b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  800722:	e9 6f ff ff ff       	jmp    800696 <vprintfmt+0x75>
  800727:	83 c1 01             	add    $0x1,%ecx
  80072a:	e9 67 ff ff ff       	jmp    800696 <vprintfmt+0x75>
  80072f:	8b 45 14             	mov    0x14(%ebp),%eax
  800732:	8d 50 04             	lea    0x4(%eax),%edx
  800735:	89 55 14             	mov    %edx,0x14(%ebp)
  800738:	8b 55 0c             	mov    0xc(%ebp),%edx
  80073b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80073f:	8b 00                	mov    (%eax),%eax
  800741:	89 04 24             	mov    %eax,(%esp)
  800744:	ff d7                	call   *%edi
  800746:	e9 ea fe ff ff       	jmp    800635 <vprintfmt+0x14>
  80074b:	8b 55 14             	mov    0x14(%ebp),%edx
  80074e:	8d 42 04             	lea    0x4(%edx),%eax
  800751:	89 45 14             	mov    %eax,0x14(%ebp)
  800754:	8b 02                	mov    (%edx),%eax
  800756:	89 c2                	mov    %eax,%edx
  800758:	c1 fa 1f             	sar    $0x1f,%edx
  80075b:	31 d0                	xor    %edx,%eax
  80075d:	29 d0                	sub    %edx,%eax
  80075f:	83 f8 0f             	cmp    $0xf,%eax
  800762:	7f 0b                	jg     80076f <vprintfmt+0x14e>
  800764:	8b 14 85 c0 2f 80 00 	mov    0x802fc0(,%eax,4),%edx
  80076b:	85 d2                	test   %edx,%edx
  80076d:	75 20                	jne    80078f <vprintfmt+0x16e>
  80076f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800773:	c7 44 24 08 2f 2d 80 	movl   $0x802d2f,0x8(%esp)
  80077a:	00 
  80077b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80077e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800782:	89 3c 24             	mov    %edi,(%esp)
  800785:	e8 f0 02 00 00       	call   800a7a <printfmt>
  80078a:	e9 a6 fe ff ff       	jmp    800635 <vprintfmt+0x14>
  80078f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800793:	c7 44 24 08 fe 30 80 	movl   $0x8030fe,0x8(%esp)
  80079a:	00 
  80079b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80079e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a2:	89 3c 24             	mov    %edi,(%esp)
  8007a5:	e8 d0 02 00 00       	call   800a7a <printfmt>
  8007aa:	e9 86 fe ff ff       	jmp    800635 <vprintfmt+0x14>
  8007af:	8b 75 ec             	mov    0xffffffec(%ebp),%esi
  8007b2:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  8007b5:	89 5d e8             	mov    %ebx,0xffffffe8(%ebp)
  8007b8:	8b 55 14             	mov    0x14(%ebp),%edx
  8007bb:	8d 42 04             	lea    0x4(%edx),%eax
  8007be:	89 45 14             	mov    %eax,0x14(%ebp)
  8007c1:	8b 12                	mov    (%edx),%edx
  8007c3:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  8007c6:	85 d2                	test   %edx,%edx
  8007c8:	75 07                	jne    8007d1 <vprintfmt+0x1b0>
  8007ca:	c7 45 d8 38 2d 80 00 	movl   $0x802d38,0xffffffd8(%ebp)
  8007d1:	85 f6                	test   %esi,%esi
  8007d3:	7e 40                	jle    800815 <vprintfmt+0x1f4>
  8007d5:	80 7d e3 2d          	cmpb   $0x2d,0xffffffe3(%ebp)
  8007d9:	74 3a                	je     800815 <vprintfmt+0x1f4>
  8007db:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007df:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  8007e2:	89 14 24             	mov    %edx,(%esp)
  8007e5:	e8 e6 02 00 00       	call   800ad0 <strnlen>
  8007ea:	29 c6                	sub    %eax,%esi
  8007ec:	89 75 ec             	mov    %esi,0xffffffec(%ebp)
  8007ef:	85 f6                	test   %esi,%esi
  8007f1:	7e 22                	jle    800815 <vprintfmt+0x1f4>
  8007f3:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  8007f7:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  8007fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800801:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  800804:	89 04 24             	mov    %eax,(%esp)
  800807:	ff d7                	call   *%edi
  800809:	83 ee 01             	sub    $0x1,%esi
  80080c:	75 ec                	jne    8007fa <vprintfmt+0x1d9>
  80080e:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  800815:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800818:	0f b6 02             	movzbl (%edx),%eax
  80081b:	0f be d0             	movsbl %al,%edx
  80081e:	8b 75 d8             	mov    0xffffffd8(%ebp),%esi
  800821:	84 c0                	test   %al,%al
  800823:	75 40                	jne    800865 <vprintfmt+0x244>
  800825:	eb 4a                	jmp    800871 <vprintfmt+0x250>
  800827:	83 7d dc 00          	cmpl   $0x0,0xffffffdc(%ebp)
  80082b:	74 1a                	je     800847 <vprintfmt+0x226>
  80082d:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  800830:	83 f8 5e             	cmp    $0x5e,%eax
  800833:	76 12                	jbe    800847 <vprintfmt+0x226>
  800835:	8b 45 0c             	mov    0xc(%ebp),%eax
  800838:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800843:	ff d7                	call   *%edi
  800845:	eb 0c                	jmp    800853 <vprintfmt+0x232>
  800847:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80084e:	89 14 24             	mov    %edx,(%esp)
  800851:	ff d7                	call   *%edi
  800853:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  800857:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80085b:	83 c6 01             	add    $0x1,%esi
  80085e:	84 c0                	test   %al,%al
  800860:	74 0f                	je     800871 <vprintfmt+0x250>
  800862:	0f be d0             	movsbl %al,%edx
  800865:	83 7d e4 00          	cmpl   $0x0,0xffffffe4(%ebp)
  800869:	78 bc                	js     800827 <vprintfmt+0x206>
  80086b:	83 6d e4 01          	subl   $0x1,0xffffffe4(%ebp)
  80086f:	79 b6                	jns    800827 <vprintfmt+0x206>
  800871:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800875:	0f 8e ba fd ff ff    	jle    800635 <vprintfmt+0x14>
  80087b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800882:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800889:	ff d7                	call   *%edi
  80088b:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  80088f:	0f 84 9d fd ff ff    	je     800632 <vprintfmt+0x11>
  800895:	eb e4                	jmp    80087b <vprintfmt+0x25a>
  800897:	83 f9 01             	cmp    $0x1,%ecx
  80089a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8008a0:	7e 10                	jle    8008b2 <vprintfmt+0x291>
  8008a2:	8b 55 14             	mov    0x14(%ebp),%edx
  8008a5:	8d 42 08             	lea    0x8(%edx),%eax
  8008a8:	89 45 14             	mov    %eax,0x14(%ebp)
  8008ab:	8b 02                	mov    (%edx),%eax
  8008ad:	8b 52 04             	mov    0x4(%edx),%edx
  8008b0:	eb 26                	jmp    8008d8 <vprintfmt+0x2b7>
  8008b2:	85 c9                	test   %ecx,%ecx
  8008b4:	74 12                	je     8008c8 <vprintfmt+0x2a7>
  8008b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b9:	8d 50 04             	lea    0x4(%eax),%edx
  8008bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8008bf:	8b 00                	mov    (%eax),%eax
  8008c1:	89 c2                	mov    %eax,%edx
  8008c3:	c1 fa 1f             	sar    $0x1f,%edx
  8008c6:	eb 10                	jmp    8008d8 <vprintfmt+0x2b7>
  8008c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cb:	8d 50 04             	lea    0x4(%eax),%edx
  8008ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d1:	8b 00                	mov    (%eax),%eax
  8008d3:	89 c2                	mov    %eax,%edx
  8008d5:	c1 fa 1f             	sar    $0x1f,%edx
  8008d8:	89 d1                	mov    %edx,%ecx
  8008da:	89 c2                	mov    %eax,%edx
  8008dc:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  8008df:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  8008e2:	be 0a 00 00 00       	mov    $0xa,%esi
  8008e7:	85 c9                	test   %ecx,%ecx
  8008e9:	0f 89 92 00 00 00    	jns    800981 <vprintfmt+0x360>
  8008ef:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008f6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008fd:	ff d7                	call   *%edi
  8008ff:	8b 55 d0             	mov    0xffffffd0(%ebp),%edx
  800902:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
  800905:	f7 da                	neg    %edx
  800907:	83 d1 00             	adc    $0x0,%ecx
  80090a:	f7 d9                	neg    %ecx
  80090c:	be 0a 00 00 00       	mov    $0xa,%esi
  800911:	eb 6e                	jmp    800981 <vprintfmt+0x360>
  800913:	8d 45 14             	lea    0x14(%ebp),%eax
  800916:	89 ca                	mov    %ecx,%edx
  800918:	e8 ab fc ff ff       	call   8005c8 <getuint>
  80091d:	89 d1                	mov    %edx,%ecx
  80091f:	89 c2                	mov    %eax,%edx
  800921:	be 0a 00 00 00       	mov    $0xa,%esi
  800926:	eb 59                	jmp    800981 <vprintfmt+0x360>
  800928:	8d 45 14             	lea    0x14(%ebp),%eax
  80092b:	89 ca                	mov    %ecx,%edx
  80092d:	e8 96 fc ff ff       	call   8005c8 <getuint>
  800932:	e9 fe fc ff ff       	jmp    800635 <vprintfmt+0x14>
  800937:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800945:	ff d7                	call   *%edi
  800947:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80094e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800955:	ff d7                	call   *%edi
  800957:	8b 55 14             	mov    0x14(%ebp),%edx
  80095a:	8d 42 04             	lea    0x4(%edx),%eax
  80095d:	89 45 14             	mov    %eax,0x14(%ebp)
  800960:	8b 12                	mov    (%edx),%edx
  800962:	b9 00 00 00 00       	mov    $0x0,%ecx
  800967:	be 10 00 00 00       	mov    $0x10,%esi
  80096c:	eb 13                	jmp    800981 <vprintfmt+0x360>
  80096e:	8d 45 14             	lea    0x14(%ebp),%eax
  800971:	89 ca                	mov    %ecx,%edx
  800973:	e8 50 fc ff ff       	call   8005c8 <getuint>
  800978:	89 d1                	mov    %edx,%ecx
  80097a:	89 c2                	mov    %eax,%edx
  80097c:	be 10 00 00 00       	mov    $0x10,%esi
  800981:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  800985:	89 44 24 10          	mov    %eax,0x10(%esp)
  800989:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  80098c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800990:	89 74 24 08          	mov    %esi,0x8(%esp)
  800994:	89 14 24             	mov    %edx,(%esp)
  800997:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80099b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099e:	89 f8                	mov    %edi,%eax
  8009a0:	e8 3b fb ff ff       	call   8004e0 <printnum>
  8009a5:	e9 8b fc ff ff       	jmp    800635 <vprintfmt+0x14>
  8009aa:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009b1:	89 14 24             	mov    %edx,(%esp)
  8009b4:	ff d7                	call   *%edi
  8009b6:	e9 7a fc ff ff       	jmp    800635 <vprintfmt+0x14>
  8009bb:	89 de                	mov    %ebx,%esi
  8009bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009cb:	ff d7                	call   *%edi
  8009cd:	83 eb 01             	sub    $0x1,%ebx
  8009d0:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  8009d4:	0f 84 5b fc ff ff    	je     800635 <vprintfmt+0x14>
  8009da:	8d 56 fd             	lea    0xfffffffd(%esi),%edx
  8009dd:	0f b6 02             	movzbl (%edx),%eax
  8009e0:	83 ea 01             	sub    $0x1,%edx
  8009e3:	3c 25                	cmp    $0x25,%al
  8009e5:	75 f6                	jne    8009dd <vprintfmt+0x3bc>
  8009e7:	8d 5a 02             	lea    0x2(%edx),%ebx
  8009ea:	e9 46 fc ff ff       	jmp    800635 <vprintfmt+0x14>
  8009ef:	83 c4 4c             	add    $0x4c,%esp
  8009f2:	5b                   	pop    %ebx
  8009f3:	5e                   	pop    %esi
  8009f4:	5f                   	pop    %edi
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	83 ec 28             	sub    $0x28,%esp
  8009fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800a00:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800a03:	85 d2                	test   %edx,%edx
  800a05:	74 04                	je     800a0b <vsnprintf+0x14>
  800a07:	85 c0                	test   %eax,%eax
  800a09:	7f 07                	jg     800a12 <vsnprintf+0x1b>
  800a0b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a10:	eb 3b                	jmp    800a4d <vsnprintf+0x56>
  800a12:	c7 45 fc 00 00 00 00 	movl   $0x0,0xfffffffc(%ebp)
  800a19:	8d 44 02 ff          	lea    0xffffffff(%edx,%eax,1),%eax
  800a1d:	89 45 f8             	mov    %eax,0xfffffff8(%ebp)
  800a20:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a23:	8b 45 14             	mov    0x14(%ebp),%eax
  800a26:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a2a:	8b 45 10             	mov    0x10(%ebp),%eax
  800a2d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a31:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  800a34:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a38:	c7 04 24 04 06 80 00 	movl   $0x800604,(%esp)
  800a3f:	e8 dd fb ff ff       	call   800621 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a44:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  800a47:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a4a:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
}
  800a4d:	c9                   	leave  
  800a4e:	c3                   	ret    

00800a4f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a55:	8d 45 14             	lea    0x14(%ebp),%eax
  800a58:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800a5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a5f:	8b 45 10             	mov    0x10(%ebp),%eax
  800a62:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a66:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a69:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a70:	89 04 24             	mov    %eax,(%esp)
  800a73:	e8 7f ff ff ff       	call   8009f7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a78:	c9                   	leave  
  800a79:	c3                   	ret    

00800a7a <printfmt>:
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	83 ec 28             	sub    $0x28,%esp
  800a80:	8d 45 14             	lea    0x14(%ebp),%eax
  800a83:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
  800a86:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a8a:	8b 45 10             	mov    0x10(%ebp),%eax
  800a8d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a91:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a94:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a98:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9b:	89 04 24             	mov    %eax,(%esp)
  800a9e:	e8 7e fb ff ff       	call   800621 <vprintfmt>
  800aa3:	c9                   	leave  
  800aa4:	c3                   	ret    
	...

00800ab0 <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ab6:	b8 00 00 00 00       	mov    $0x0,%eax
  800abb:	80 3a 00             	cmpb   $0x0,(%edx)
  800abe:	74 0e                	je     800ace <strlen+0x1e>
  800ac0:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800ac5:	83 c0 01             	add    $0x1,%eax
  800ac8:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  800acc:	75 f7                	jne    800ac5 <strlen+0x15>
	return n;
}
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ad9:	85 d2                	test   %edx,%edx
  800adb:	74 19                	je     800af6 <strnlen+0x26>
  800add:	80 39 00             	cmpb   $0x0,(%ecx)
  800ae0:	74 14                	je     800af6 <strnlen+0x26>
  800ae2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800ae7:	83 c0 01             	add    $0x1,%eax
  800aea:	39 d0                	cmp    %edx,%eax
  800aec:	74 0d                	je     800afb <strnlen+0x2b>
  800aee:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800af2:	74 07                	je     800afb <strnlen+0x2b>
  800af4:	eb f1                	jmp    800ae7 <strnlen+0x17>
  800af6:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800afb:	5d                   	pop    %ebp
  800afc:	8d 74 26 00          	lea    0x0(%esi),%esi
  800b00:	c3                   	ret    

00800b01 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	53                   	push   %ebx
  800b05:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0b:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b0d:	0f b6 01             	movzbl (%ecx),%eax
  800b10:	88 02                	mov    %al,(%edx)
  800b12:	83 c2 01             	add    $0x1,%edx
  800b15:	83 c1 01             	add    $0x1,%ecx
  800b18:	84 c0                	test   %al,%al
  800b1a:	75 f1                	jne    800b0d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b1c:	89 d8                	mov    %ebx,%eax
  800b1e:	5b                   	pop    %ebx
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	57                   	push   %edi
  800b25:	56                   	push   %esi
  800b26:	53                   	push   %ebx
  800b27:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b30:	85 f6                	test   %esi,%esi
  800b32:	74 1c                	je     800b50 <strncpy+0x2f>
  800b34:	89 fa                	mov    %edi,%edx
  800b36:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  800b3b:	0f b6 01             	movzbl (%ecx),%eax
  800b3e:	88 02                	mov    %al,(%edx)
  800b40:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b43:	80 39 01             	cmpb   $0x1,(%ecx)
  800b46:	83 d9 ff             	sbb    $0xffffffff,%ecx
  800b49:	83 c3 01             	add    $0x1,%ebx
  800b4c:	39 f3                	cmp    %esi,%ebx
  800b4e:	75 eb                	jne    800b3b <strncpy+0x1a>
	}
	return ret;
}
  800b50:	89 f8                	mov    %edi,%eax
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	56                   	push   %esi
  800b5b:	53                   	push   %ebx
  800b5c:	8b 75 08             	mov    0x8(%ebp),%esi
  800b5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b62:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b65:	89 f0                	mov    %esi,%eax
  800b67:	85 d2                	test   %edx,%edx
  800b69:	74 2c                	je     800b97 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800b6b:	89 d3                	mov    %edx,%ebx
  800b6d:	83 eb 01             	sub    $0x1,%ebx
  800b70:	74 20                	je     800b92 <strlcpy+0x3b>
  800b72:	0f b6 11             	movzbl (%ecx),%edx
  800b75:	84 d2                	test   %dl,%dl
  800b77:	74 19                	je     800b92 <strlcpy+0x3b>
  800b79:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800b7b:	88 10                	mov    %dl,(%eax)
  800b7d:	83 c0 01             	add    $0x1,%eax
  800b80:	83 eb 01             	sub    $0x1,%ebx
  800b83:	74 0f                	je     800b94 <strlcpy+0x3d>
  800b85:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  800b89:	83 c1 01             	add    $0x1,%ecx
  800b8c:	84 d2                	test   %dl,%dl
  800b8e:	74 04                	je     800b94 <strlcpy+0x3d>
  800b90:	eb e9                	jmp    800b7b <strlcpy+0x24>
  800b92:	89 f0                	mov    %esi,%eax
		*dst = '\0';
  800b94:	c6 00 00             	movb   $0x0,(%eax)
  800b97:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800b99:	5b                   	pop    %ebx
  800b9a:	5e                   	pop    %esi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
  800ba3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba9:	8b 7d 10             	mov    0x10(%ebp),%edi
    int c;
    char *q = buf;

    if (buf_size <= 0)
  800bac:	85 c9                	test   %ecx,%ecx
  800bae:	7e 30                	jle    800be0 <pstrcpy+0x43>
        return;

    for(;;) {
        c = *str++;
  800bb0:	0f b6 07             	movzbl (%edi),%eax
        if (c == 0 || q >= buf + buf_size - 1)
  800bb3:	84 c0                	test   %al,%al
  800bb5:	74 26                	je     800bdd <pstrcpy+0x40>
  800bb7:	8d 74 0a ff          	lea    0xffffffff(%edx,%ecx,1),%esi
  800bbb:	0f be d8             	movsbl %al,%ebx
  800bbe:	89 f9                	mov    %edi,%ecx
  800bc0:	39 f2                	cmp    %esi,%edx
  800bc2:	72 09                	jb     800bcd <pstrcpy+0x30>
  800bc4:	eb 17                	jmp    800bdd <pstrcpy+0x40>
  800bc6:	83 c1 01             	add    $0x1,%ecx
  800bc9:	39 f2                	cmp    %esi,%edx
  800bcb:	73 10                	jae    800bdd <pstrcpy+0x40>
            break;
        *q++ = c;
  800bcd:	88 1a                	mov    %bl,(%edx)
  800bcf:	83 c2 01             	add    $0x1,%edx
  800bd2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800bd6:	0f be d8             	movsbl %al,%ebx
  800bd9:	84 c0                	test   %al,%al
  800bdb:	75 e9                	jne    800bc6 <pstrcpy+0x29>
    }
    *q = '\0';
  800bdd:	c6 02 00             	movb   $0x0,(%edx)
}
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	8b 55 08             	mov    0x8(%ebp),%edx
  800beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  800bee:	0f b6 02             	movzbl (%edx),%eax
  800bf1:	84 c0                	test   %al,%al
  800bf3:	74 16                	je     800c0b <strcmp+0x26>
  800bf5:	3a 01                	cmp    (%ecx),%al
  800bf7:	75 12                	jne    800c0b <strcmp+0x26>
		p++, q++;
  800bf9:	83 c1 01             	add    $0x1,%ecx
  800bfc:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  800c00:	84 c0                	test   %al,%al
  800c02:	74 07                	je     800c0b <strcmp+0x26>
  800c04:	83 c2 01             	add    $0x1,%edx
  800c07:	3a 01                	cmp    (%ecx),%al
  800c09:	74 ee                	je     800bf9 <strcmp+0x14>
  800c0b:	0f b6 c0             	movzbl %al,%eax
  800c0e:	0f b6 11             	movzbl (%ecx),%edx
  800c11:	29 d0                	sub    %edx,%eax
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	53                   	push   %ebx
  800c19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c1f:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800c22:	85 d2                	test   %edx,%edx
  800c24:	74 2d                	je     800c53 <strncmp+0x3e>
  800c26:	0f b6 01             	movzbl (%ecx),%eax
  800c29:	84 c0                	test   %al,%al
  800c2b:	74 1a                	je     800c47 <strncmp+0x32>
  800c2d:	3a 03                	cmp    (%ebx),%al
  800c2f:	75 16                	jne    800c47 <strncmp+0x32>
  800c31:	83 ea 01             	sub    $0x1,%edx
  800c34:	74 1d                	je     800c53 <strncmp+0x3e>
		n--, p++, q++;
  800c36:	83 c1 01             	add    $0x1,%ecx
  800c39:	83 c3 01             	add    $0x1,%ebx
  800c3c:	0f b6 01             	movzbl (%ecx),%eax
  800c3f:	84 c0                	test   %al,%al
  800c41:	74 04                	je     800c47 <strncmp+0x32>
  800c43:	3a 03                	cmp    (%ebx),%al
  800c45:	74 ea                	je     800c31 <strncmp+0x1c>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c47:	0f b6 11             	movzbl (%ecx),%edx
  800c4a:	0f b6 03             	movzbl (%ebx),%eax
  800c4d:	29 c2                	sub    %eax,%edx
  800c4f:	89 d0                	mov    %edx,%eax
  800c51:	eb 05                	jmp    800c58 <strncmp+0x43>
  800c53:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c58:	5b                   	pop    %ebx
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c61:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c65:	0f b6 10             	movzbl (%eax),%edx
  800c68:	84 d2                	test   %dl,%dl
  800c6a:	74 16                	je     800c82 <strchr+0x27>
		if (*s == c)
  800c6c:	38 ca                	cmp    %cl,%dl
  800c6e:	75 06                	jne    800c76 <strchr+0x1b>
  800c70:	eb 15                	jmp    800c87 <strchr+0x2c>
  800c72:	38 ca                	cmp    %cl,%dl
  800c74:	74 11                	je     800c87 <strchr+0x2c>
  800c76:	83 c0 01             	add    $0x1,%eax
  800c79:	0f b6 10             	movzbl (%eax),%edx
  800c7c:	84 d2                	test   %dl,%dl
  800c7e:	66 90                	xchg   %ax,%ax
  800c80:	75 f0                	jne    800c72 <strchr+0x17>
  800c82:	b8 00 00 00 00       	mov    $0x0,%eax
			return (char *) s;
	return 0;
}
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c93:	0f b6 10             	movzbl (%eax),%edx
  800c96:	84 d2                	test   %dl,%dl
  800c98:	74 14                	je     800cae <strfind+0x25>
		if (*s == c)
  800c9a:	38 ca                	cmp    %cl,%dl
  800c9c:	75 06                	jne    800ca4 <strfind+0x1b>
  800c9e:	eb 0e                	jmp    800cae <strfind+0x25>
  800ca0:	38 ca                	cmp    %cl,%dl
  800ca2:	74 0a                	je     800cae <strfind+0x25>
  800ca4:	83 c0 01             	add    $0x1,%eax
  800ca7:	0f b6 10             	movzbl (%eax),%edx
  800caa:	84 d2                	test   %dl,%dl
  800cac:	75 f2                	jne    800ca0 <strfind+0x17>
			break;
	return (char *) s;
}
  800cae:	5d                   	pop    %ebp
  800caf:	90                   	nop    
  800cb0:	c3                   	ret    

00800cb1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	83 ec 08             	sub    $0x8,%esp
  800cb7:	89 1c 24             	mov    %ebx,(%esp)
  800cba:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cbe:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cc1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cc4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800cc7:	85 db                	test   %ebx,%ebx
  800cc9:	74 32                	je     800cfd <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ccb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cd1:	75 25                	jne    800cf8 <memset+0x47>
  800cd3:	f6 c3 03             	test   $0x3,%bl
  800cd6:	75 20                	jne    800cf8 <memset+0x47>
		c &= 0xFF;
  800cd8:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800cdb:	89 d0                	mov    %edx,%eax
  800cdd:	c1 e0 18             	shl    $0x18,%eax
  800ce0:	89 d1                	mov    %edx,%ecx
  800ce2:	c1 e1 10             	shl    $0x10,%ecx
  800ce5:	09 c8                	or     %ecx,%eax
  800ce7:	09 d0                	or     %edx,%eax
  800ce9:	c1 e2 08             	shl    $0x8,%edx
  800cec:	09 d0                	or     %edx,%eax
  800cee:	89 d9                	mov    %ebx,%ecx
  800cf0:	c1 e9 02             	shr    $0x2,%ecx
  800cf3:	fc                   	cld    
  800cf4:	f3 ab                	rep stos %eax,%es:(%edi)
  800cf6:	eb 05                	jmp    800cfd <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cf8:	89 d9                	mov    %ebx,%ecx
  800cfa:	fc                   	cld    
  800cfb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cfd:	89 f8                	mov    %edi,%eax
  800cff:	8b 1c 24             	mov    (%esp),%ebx
  800d02:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d06:	89 ec                	mov    %ebp,%esp
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    

00800d0a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	83 ec 08             	sub    $0x8,%esp
  800d10:	89 34 24             	mov    %esi,(%esp)
  800d13:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d17:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800d1d:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800d20:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800d22:	39 c6                	cmp    %eax,%esi
  800d24:	73 36                	jae    800d5c <memmove+0x52>
  800d26:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d29:	39 d0                	cmp    %edx,%eax
  800d2b:	73 2f                	jae    800d5c <memmove+0x52>
		s += n;
		d += n;
  800d2d:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d30:	f6 c2 03             	test   $0x3,%dl
  800d33:	75 1b                	jne    800d50 <memmove+0x46>
  800d35:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d3b:	75 13                	jne    800d50 <memmove+0x46>
  800d3d:	f6 c1 03             	test   $0x3,%cl
  800d40:	75 0e                	jne    800d50 <memmove+0x46>
			asm volatile("std; rep movsl\n"
  800d42:	8d 7e fc             	lea    0xfffffffc(%esi),%edi
  800d45:	8d 72 fc             	lea    0xfffffffc(%edx),%esi
  800d48:	c1 e9 02             	shr    $0x2,%ecx
  800d4b:	fd                   	std    
  800d4c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d4e:	eb 09                	jmp    800d59 <memmove+0x4f>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d50:	8d 7e ff             	lea    0xffffffff(%esi),%edi
  800d53:	8d 72 ff             	lea    0xffffffff(%edx),%esi
  800d56:	fd                   	std    
  800d57:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d59:	fc                   	cld    
  800d5a:	eb 21                	jmp    800d7d <memmove+0x73>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d5c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d62:	75 16                	jne    800d7a <memmove+0x70>
  800d64:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d6a:	75 0e                	jne    800d7a <memmove+0x70>
  800d6c:	f6 c1 03             	test   $0x3,%cl
  800d6f:	90                   	nop    
  800d70:	75 08                	jne    800d7a <memmove+0x70>
			asm volatile("cld; rep movsl\n"
  800d72:	c1 e9 02             	shr    $0x2,%ecx
  800d75:	fc                   	cld    
  800d76:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d78:	eb 03                	jmp    800d7d <memmove+0x73>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d7a:	fc                   	cld    
  800d7b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d7d:	8b 34 24             	mov    (%esp),%esi
  800d80:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d84:	89 ec                	mov    %ebp,%esp
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <memcpy>:

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
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d8e:	8b 45 10             	mov    0x10(%ebp),%eax
  800d91:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d95:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d98:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9f:	89 04 24             	mov    %eax,(%esp)
  800da2:	e8 63 ff ff ff       	call   800d0a <memmove>
}
  800da7:	c9                   	leave  
  800da8:	c3                   	ret    

00800da9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	56                   	push   %esi
  800dad:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dae:	8b 75 10             	mov    0x10(%ebp),%esi
  800db1:	83 ee 01             	sub    $0x1,%esi
  800db4:	83 fe ff             	cmp    $0xffffffff,%esi
  800db7:	74 38                	je     800df1 <memcmp+0x48>
  800db9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbc:	8b 55 0c             	mov    0xc(%ebp),%edx
		if (*s1 != *s2)
  800dbf:	0f b6 18             	movzbl (%eax),%ebx
  800dc2:	0f b6 0a             	movzbl (%edx),%ecx
  800dc5:	38 cb                	cmp    %cl,%bl
  800dc7:	74 20                	je     800de9 <memcmp+0x40>
  800dc9:	eb 12                	jmp    800ddd <memcmp+0x34>
  800dcb:	0f b6 58 01          	movzbl 0x1(%eax),%ebx
  800dcf:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
  800dd3:	83 c0 01             	add    $0x1,%eax
  800dd6:	83 c2 01             	add    $0x1,%edx
  800dd9:	38 cb                	cmp    %cl,%bl
  800ddb:	74 0c                	je     800de9 <memcmp+0x40>
			return (int) *s1 - (int) *s2;
  800ddd:	0f b6 d3             	movzbl %bl,%edx
  800de0:	0f b6 c1             	movzbl %cl,%eax
  800de3:	29 c2                	sub    %eax,%edx
  800de5:	89 d0                	mov    %edx,%eax
  800de7:	eb 0d                	jmp    800df6 <memcmp+0x4d>
  800de9:	83 ee 01             	sub    $0x1,%esi
  800dec:	83 fe ff             	cmp    $0xffffffff,%esi
  800def:	75 da                	jne    800dcb <memcmp+0x22>
  800df1:	b8 00 00 00 00       	mov    $0x0,%eax
		s1++, s2++;
	}

	return 0;
}
  800df6:	5b                   	pop    %ebx
  800df7:	5e                   	pop    %esi
  800df8:	5d                   	pop    %ebp
  800df9:	c3                   	ret    

00800dfa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	53                   	push   %ebx
  800dfe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800e01:	89 da                	mov    %ebx,%edx
  800e03:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e06:	39 d3                	cmp    %edx,%ebx
  800e08:	73 1a                	jae    800e24 <memfind+0x2a>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e0a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
			break;
  800e0e:	89 d8                	mov    %ebx,%eax
  800e10:	38 0b                	cmp    %cl,(%ebx)
  800e12:	75 06                	jne    800e1a <memfind+0x20>
  800e14:	eb 0e                	jmp    800e24 <memfind+0x2a>
  800e16:	38 08                	cmp    %cl,(%eax)
  800e18:	74 0c                	je     800e26 <memfind+0x2c>
  800e1a:	83 c0 01             	add    $0x1,%eax
  800e1d:	39 d0                	cmp    %edx,%eax
  800e1f:	90                   	nop    
  800e20:	75 f4                	jne    800e16 <memfind+0x1c>
  800e22:	eb 02                	jmp    800e26 <memfind+0x2c>
  800e24:	89 d8                	mov    %ebx,%eax
	return (void *) s;
}
  800e26:	5b                   	pop    %ebx
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	83 ec 04             	sub    $0x4,%esp
  800e32:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e35:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e38:	0f b6 03             	movzbl (%ebx),%eax
  800e3b:	3c 20                	cmp    $0x20,%al
  800e3d:	74 04                	je     800e43 <strtol+0x1a>
  800e3f:	3c 09                	cmp    $0x9,%al
  800e41:	75 0e                	jne    800e51 <strtol+0x28>
		s++;
  800e43:	83 c3 01             	add    $0x1,%ebx
  800e46:	0f b6 03             	movzbl (%ebx),%eax
  800e49:	3c 20                	cmp    $0x20,%al
  800e4b:	74 f6                	je     800e43 <strtol+0x1a>
  800e4d:	3c 09                	cmp    $0x9,%al
  800e4f:	74 f2                	je     800e43 <strtol+0x1a>

	// plus/minus sign
	if (*s == '+')
  800e51:	3c 2b                	cmp    $0x2b,%al
  800e53:	75 0d                	jne    800e62 <strtol+0x39>
		s++;
  800e55:	83 c3 01             	add    $0x1,%ebx
  800e58:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800e5f:	90                   	nop    
  800e60:	eb 15                	jmp    800e77 <strtol+0x4e>
	else if (*s == '-')
  800e62:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800e69:	3c 2d                	cmp    $0x2d,%al
  800e6b:	75 0a                	jne    800e77 <strtol+0x4e>
		s++, neg = 1;
  800e6d:	83 c3 01             	add    $0x1,%ebx
  800e70:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e77:	85 f6                	test   %esi,%esi
  800e79:	0f 94 c0             	sete   %al
  800e7c:	84 c0                	test   %al,%al
  800e7e:	75 05                	jne    800e85 <strtol+0x5c>
  800e80:	83 fe 10             	cmp    $0x10,%esi
  800e83:	75 17                	jne    800e9c <strtol+0x73>
  800e85:	80 3b 30             	cmpb   $0x30,(%ebx)
  800e88:	75 12                	jne    800e9c <strtol+0x73>
  800e8a:	80 7b 01 78          	cmpb   $0x78,0x1(%ebx)
  800e8e:	66 90                	xchg   %ax,%ax
  800e90:	75 0a                	jne    800e9c <strtol+0x73>
		s += 2, base = 16;
  800e92:	83 c3 02             	add    $0x2,%ebx
  800e95:	be 10 00 00 00       	mov    $0x10,%esi
  800e9a:	eb 1f                	jmp    800ebb <strtol+0x92>
	else if (base == 0 && s[0] == '0')
  800e9c:	85 f6                	test   %esi,%esi
  800e9e:	66 90                	xchg   %ax,%ax
  800ea0:	75 10                	jne    800eb2 <strtol+0x89>
  800ea2:	80 3b 30             	cmpb   $0x30,(%ebx)
  800ea5:	75 0b                	jne    800eb2 <strtol+0x89>
		s++, base = 8;
  800ea7:	83 c3 01             	add    $0x1,%ebx
  800eaa:	66 be 08 00          	mov    $0x8,%si
  800eae:	66 90                	xchg   %ax,%ax
  800eb0:	eb 09                	jmp    800ebb <strtol+0x92>
	else if (base == 0)
  800eb2:	84 c0                	test   %al,%al
  800eb4:	74 05                	je     800ebb <strtol+0x92>
  800eb6:	be 0a 00 00 00       	mov    $0xa,%esi
  800ebb:	bf 00 00 00 00       	mov    $0x0,%edi
		base = 10;

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ec0:	0f b6 13             	movzbl (%ebx),%edx
  800ec3:	89 d1                	mov    %edx,%ecx
  800ec5:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800ec8:	3c 09                	cmp    $0x9,%al
  800eca:	77 08                	ja     800ed4 <strtol+0xab>
			dig = *s - '0';
  800ecc:	0f be c2             	movsbl %dl,%eax
  800ecf:	8d 50 d0             	lea    0xffffffd0(%eax),%edx
  800ed2:	eb 1c                	jmp    800ef0 <strtol+0xc7>
		else if (*s >= 'a' && *s <= 'z')
  800ed4:	8d 41 9f             	lea    0xffffff9f(%ecx),%eax
  800ed7:	3c 19                	cmp    $0x19,%al
  800ed9:	77 08                	ja     800ee3 <strtol+0xba>
			dig = *s - 'a' + 10;
  800edb:	0f be c2             	movsbl %dl,%eax
  800ede:	8d 50 a9             	lea    0xffffffa9(%eax),%edx
  800ee1:	eb 0d                	jmp    800ef0 <strtol+0xc7>
		else if (*s >= 'A' && *s <= 'Z')
  800ee3:	8d 41 bf             	lea    0xffffffbf(%ecx),%eax
  800ee6:	3c 19                	cmp    $0x19,%al
  800ee8:	77 17                	ja     800f01 <strtol+0xd8>
			dig = *s - 'A' + 10;
  800eea:	0f be c2             	movsbl %dl,%eax
  800eed:	8d 50 c9             	lea    0xffffffc9(%eax),%edx
		else
			break;
		if (dig >= base)
  800ef0:	39 f2                	cmp    %esi,%edx
  800ef2:	7d 0d                	jge    800f01 <strtol+0xd8>
			break;
		s++, val = (val * base) + dig;
  800ef4:	83 c3 01             	add    $0x1,%ebx
  800ef7:	89 f8                	mov    %edi,%eax
  800ef9:	0f af c6             	imul   %esi,%eax
  800efc:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800eff:	eb bf                	jmp    800ec0 <strtol+0x97>
		// we don't properly detect overflow!
	}
  800f01:	89 f8                	mov    %edi,%eax

	if (endptr)
  800f03:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f07:	74 05                	je     800f0e <strtol+0xe5>
		*endptr = (char *) s;
  800f09:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f0c:	89 1a                	mov    %ebx,(%edx)
	return (neg ? -val : val);
  800f0e:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800f12:	74 04                	je     800f18 <strtol+0xef>
  800f14:	89 c7                	mov    %eax,%edi
  800f16:	f7 df                	neg    %edi
}
  800f18:	89 f8                	mov    %edi,%eax
  800f1a:	83 c4 04             	add    $0x4,%esp
  800f1d:	5b                   	pop    %ebx
  800f1e:	5e                   	pop    %esi
  800f1f:	5f                   	pop    %edi
  800f20:	5d                   	pop    %ebp
  800f21:	c3                   	ret    
	...

00800f24 <sys_cgetc>:
}

int
sys_cgetc(void)
{
  800f24:	55                   	push   %ebp
  800f25:	89 e5                	mov    %esp,%ebp
  800f27:	83 ec 0c             	sub    $0xc,%esp
  800f2a:	89 1c 24             	mov    %ebx,(%esp)
  800f2d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f31:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f35:	b8 01 00 00 00       	mov    $0x1,%eax
  800f3a:	bf 00 00 00 00       	mov    $0x0,%edi
  800f3f:	89 fa                	mov    %edi,%edx
  800f41:	89 f9                	mov    %edi,%ecx
  800f43:	89 fb                	mov    %edi,%ebx
  800f45:	89 fe                	mov    %edi,%esi
  800f47:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f49:	8b 1c 24             	mov    (%esp),%ebx
  800f4c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f50:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f54:	89 ec                	mov    %ebp,%esp
  800f56:	5d                   	pop    %ebp
  800f57:	c3                   	ret    

00800f58 <sys_cputs>:
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	83 ec 0c             	sub    $0xc,%esp
  800f5e:	89 1c 24             	mov    %ebx,(%esp)
  800f61:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f65:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f69:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f6f:	bf 00 00 00 00       	mov    $0x0,%edi
  800f74:	89 f8                	mov    %edi,%eax
  800f76:	89 fb                	mov    %edi,%ebx
  800f78:	89 fe                	mov    %edi,%esi
  800f7a:	cd 30                	int    $0x30
  800f7c:	8b 1c 24             	mov    (%esp),%ebx
  800f7f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f83:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f87:	89 ec                	mov    %ebp,%esp
  800f89:	5d                   	pop    %ebp
  800f8a:	c3                   	ret    

00800f8b <sys_time_msec>:

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
  800f8b:	55                   	push   %ebp
  800f8c:	89 e5                	mov    %esp,%ebp
  800f8e:	83 ec 0c             	sub    $0xc,%esp
  800f91:	89 1c 24             	mov    %ebx,(%esp)
  800f94:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f98:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f9c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800fa1:	bf 00 00 00 00       	mov    $0x0,%edi
  800fa6:	89 fa                	mov    %edi,%edx
  800fa8:	89 f9                	mov    %edi,%ecx
  800faa:	89 fb                	mov    %edi,%ebx
  800fac:	89 fe                	mov    %edi,%esi
  800fae:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800fb0:	8b 1c 24             	mov    (%esp),%ebx
  800fb3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fb7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fbb:	89 ec                	mov    %ebp,%esp
  800fbd:	5d                   	pop    %ebp
  800fbe:	c3                   	ret    

00800fbf <sys_ipc_recv>:
  800fbf:	55                   	push   %ebp
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	83 ec 28             	sub    $0x28,%esp
  800fc5:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800fc8:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800fcb:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800fce:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fd6:	bf 00 00 00 00       	mov    $0x0,%edi
  800fdb:	89 f9                	mov    %edi,%ecx
  800fdd:	89 fb                	mov    %edi,%ebx
  800fdf:	89 fe                	mov    %edi,%esi
  800fe1:	cd 30                	int    $0x30
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	7e 28                	jle    80100f <sys_ipc_recv+0x50>
  800fe7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800feb:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ff2:	00 
  800ff3:	c7 44 24 08 1f 30 80 	movl   $0x80301f,0x8(%esp)
  800ffa:	00 
  800ffb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801002:	00 
  801003:	c7 04 24 3c 30 80 00 	movl   $0x80303c,(%esp)
  80100a:	e8 a5 f3 ff ff       	call   8003b4 <_panic>
  80100f:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801012:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801015:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801018:	89 ec                	mov    %ebp,%esp
  80101a:	5d                   	pop    %ebp
  80101b:	c3                   	ret    

0080101c <sys_ipc_try_send>:
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	83 ec 0c             	sub    $0xc,%esp
  801022:	89 1c 24             	mov    %ebx,(%esp)
  801025:	89 74 24 04          	mov    %esi,0x4(%esp)
  801029:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80102d:	8b 55 08             	mov    0x8(%ebp),%edx
  801030:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801033:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801036:	8b 7d 14             	mov    0x14(%ebp),%edi
  801039:	b8 0c 00 00 00       	mov    $0xc,%eax
  80103e:	be 00 00 00 00       	mov    $0x0,%esi
  801043:	cd 30                	int    $0x30
  801045:	8b 1c 24             	mov    (%esp),%ebx
  801048:	8b 74 24 04          	mov    0x4(%esp),%esi
  80104c:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801050:	89 ec                	mov    %ebp,%esp
  801052:	5d                   	pop    %ebp
  801053:	c3                   	ret    

00801054 <sys_env_set_pgfault_upcall>:
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	83 ec 28             	sub    $0x28,%esp
  80105a:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  80105d:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  801060:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  801063:	8b 55 08             	mov    0x8(%ebp),%edx
  801066:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801069:	b8 0a 00 00 00       	mov    $0xa,%eax
  80106e:	bf 00 00 00 00       	mov    $0x0,%edi
  801073:	89 fb                	mov    %edi,%ebx
  801075:	89 fe                	mov    %edi,%esi
  801077:	cd 30                	int    $0x30
  801079:	85 c0                	test   %eax,%eax
  80107b:	7e 28                	jle    8010a5 <sys_env_set_pgfault_upcall+0x51>
  80107d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801081:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801088:	00 
  801089:	c7 44 24 08 1f 30 80 	movl   $0x80301f,0x8(%esp)
  801090:	00 
  801091:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801098:	00 
  801099:	c7 04 24 3c 30 80 00 	movl   $0x80303c,(%esp)
  8010a0:	e8 0f f3 ff ff       	call   8003b4 <_panic>
  8010a5:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  8010a8:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  8010ab:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  8010ae:	89 ec                	mov    %ebp,%esp
  8010b0:	5d                   	pop    %ebp
  8010b1:	c3                   	ret    

008010b2 <sys_env_set_trapframe>:
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	83 ec 28             	sub    $0x28,%esp
  8010b8:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  8010bb:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  8010be:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  8010c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c7:	b8 09 00 00 00       	mov    $0x9,%eax
  8010cc:	bf 00 00 00 00       	mov    $0x0,%edi
  8010d1:	89 fb                	mov    %edi,%ebx
  8010d3:	89 fe                	mov    %edi,%esi
  8010d5:	cd 30                	int    $0x30
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	7e 28                	jle    801103 <sys_env_set_trapframe+0x51>
  8010db:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010df:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8010e6:	00 
  8010e7:	c7 44 24 08 1f 30 80 	movl   $0x80301f,0x8(%esp)
  8010ee:	00 
  8010ef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010f6:	00 
  8010f7:	c7 04 24 3c 30 80 00 	movl   $0x80303c,(%esp)
  8010fe:	e8 b1 f2 ff ff       	call   8003b4 <_panic>
  801103:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801106:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801109:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  80110c:	89 ec                	mov    %ebp,%esp
  80110e:	5d                   	pop    %ebp
  80110f:	c3                   	ret    

00801110 <sys_env_set_status>:
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	83 ec 28             	sub    $0x28,%esp
  801116:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  801119:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  80111c:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  80111f:	8b 55 08             	mov    0x8(%ebp),%edx
  801122:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801125:	b8 08 00 00 00       	mov    $0x8,%eax
  80112a:	bf 00 00 00 00       	mov    $0x0,%edi
  80112f:	89 fb                	mov    %edi,%ebx
  801131:	89 fe                	mov    %edi,%esi
  801133:	cd 30                	int    $0x30
  801135:	85 c0                	test   %eax,%eax
  801137:	7e 28                	jle    801161 <sys_env_set_status+0x51>
  801139:	89 44 24 10          	mov    %eax,0x10(%esp)
  80113d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801144:	00 
  801145:	c7 44 24 08 1f 30 80 	movl   $0x80301f,0x8(%esp)
  80114c:	00 
  80114d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801154:	00 
  801155:	c7 04 24 3c 30 80 00 	movl   $0x80303c,(%esp)
  80115c:	e8 53 f2 ff ff       	call   8003b4 <_panic>
  801161:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801164:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801167:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  80116a:	89 ec                	mov    %ebp,%esp
  80116c:	5d                   	pop    %ebp
  80116d:	c3                   	ret    

0080116e <sys_page_unmap>:
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	83 ec 28             	sub    $0x28,%esp
  801174:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  801177:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  80117a:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  80117d:	8b 55 08             	mov    0x8(%ebp),%edx
  801180:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801183:	b8 06 00 00 00       	mov    $0x6,%eax
  801188:	bf 00 00 00 00       	mov    $0x0,%edi
  80118d:	89 fb                	mov    %edi,%ebx
  80118f:	89 fe                	mov    %edi,%esi
  801191:	cd 30                	int    $0x30
  801193:	85 c0                	test   %eax,%eax
  801195:	7e 28                	jle    8011bf <sys_page_unmap+0x51>
  801197:	89 44 24 10          	mov    %eax,0x10(%esp)
  80119b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8011a2:	00 
  8011a3:	c7 44 24 08 1f 30 80 	movl   $0x80301f,0x8(%esp)
  8011aa:	00 
  8011ab:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011b2:	00 
  8011b3:	c7 04 24 3c 30 80 00 	movl   $0x80303c,(%esp)
  8011ba:	e8 f5 f1 ff ff       	call   8003b4 <_panic>
  8011bf:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  8011c2:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  8011c5:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  8011c8:	89 ec                	mov    %ebp,%esp
  8011ca:	5d                   	pop    %ebp
  8011cb:	c3                   	ret    

008011cc <sys_page_map>:
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
  8011cf:	83 ec 28             	sub    $0x28,%esp
  8011d2:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  8011d5:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  8011d8:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  8011db:	8b 55 08             	mov    0x8(%ebp),%edx
  8011de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011e4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011e7:	8b 75 18             	mov    0x18(%ebp),%esi
  8011ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8011ef:	cd 30                	int    $0x30
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	7e 28                	jle    80121d <sys_page_map+0x51>
  8011f5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011f9:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801200:	00 
  801201:	c7 44 24 08 1f 30 80 	movl   $0x80301f,0x8(%esp)
  801208:	00 
  801209:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801210:	00 
  801211:	c7 04 24 3c 30 80 00 	movl   $0x80303c,(%esp)
  801218:	e8 97 f1 ff ff       	call   8003b4 <_panic>
  80121d:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801220:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801223:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801226:	89 ec                	mov    %ebp,%esp
  801228:	5d                   	pop    %ebp
  801229:	c3                   	ret    

0080122a <sys_page_alloc>:
  80122a:	55                   	push   %ebp
  80122b:	89 e5                	mov    %esp,%ebp
  80122d:	83 ec 28             	sub    $0x28,%esp
  801230:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  801233:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  801236:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  801239:	8b 55 08             	mov    0x8(%ebp),%edx
  80123c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80123f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801242:	b8 04 00 00 00       	mov    $0x4,%eax
  801247:	bf 00 00 00 00       	mov    $0x0,%edi
  80124c:	89 fe                	mov    %edi,%esi
  80124e:	cd 30                	int    $0x30
  801250:	85 c0                	test   %eax,%eax
  801252:	7e 28                	jle    80127c <sys_page_alloc+0x52>
  801254:	89 44 24 10          	mov    %eax,0x10(%esp)
  801258:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80125f:	00 
  801260:	c7 44 24 08 1f 30 80 	movl   $0x80301f,0x8(%esp)
  801267:	00 
  801268:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80126f:	00 
  801270:	c7 04 24 3c 30 80 00 	movl   $0x80303c,(%esp)
  801277:	e8 38 f1 ff ff       	call   8003b4 <_panic>
  80127c:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  80127f:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801282:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801285:	89 ec                	mov    %ebp,%esp
  801287:	5d                   	pop    %ebp
  801288:	c3                   	ret    

00801289 <sys_yield>:
  801289:	55                   	push   %ebp
  80128a:	89 e5                	mov    %esp,%ebp
  80128c:	83 ec 0c             	sub    $0xc,%esp
  80128f:	89 1c 24             	mov    %ebx,(%esp)
  801292:	89 74 24 04          	mov    %esi,0x4(%esp)
  801296:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80129a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80129f:	bf 00 00 00 00       	mov    $0x0,%edi
  8012a4:	89 fa                	mov    %edi,%edx
  8012a6:	89 f9                	mov    %edi,%ecx
  8012a8:	89 fb                	mov    %edi,%ebx
  8012aa:	89 fe                	mov    %edi,%esi
  8012ac:	cd 30                	int    $0x30
  8012ae:	8b 1c 24             	mov    (%esp),%ebx
  8012b1:	8b 74 24 04          	mov    0x4(%esp),%esi
  8012b5:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8012b9:	89 ec                	mov    %ebp,%esp
  8012bb:	5d                   	pop    %ebp
  8012bc:	c3                   	ret    

008012bd <sys_getenvid>:
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
  8012c0:	83 ec 0c             	sub    $0xc,%esp
  8012c3:	89 1c 24             	mov    %ebx,(%esp)
  8012c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012ca:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8012ce:	b8 02 00 00 00       	mov    $0x2,%eax
  8012d3:	bf 00 00 00 00       	mov    $0x0,%edi
  8012d8:	89 fa                	mov    %edi,%edx
  8012da:	89 f9                	mov    %edi,%ecx
  8012dc:	89 fb                	mov    %edi,%ebx
  8012de:	89 fe                	mov    %edi,%esi
  8012e0:	cd 30                	int    $0x30
  8012e2:	8b 1c 24             	mov    (%esp),%ebx
  8012e5:	8b 74 24 04          	mov    0x4(%esp),%esi
  8012e9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8012ed:	89 ec                	mov    %ebp,%esp
  8012ef:	5d                   	pop    %ebp
  8012f0:	c3                   	ret    

008012f1 <sys_env_destroy>:
  8012f1:	55                   	push   %ebp
  8012f2:	89 e5                	mov    %esp,%ebp
  8012f4:	83 ec 28             	sub    $0x28,%esp
  8012f7:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  8012fa:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  8012fd:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  801300:	8b 55 08             	mov    0x8(%ebp),%edx
  801303:	b8 03 00 00 00       	mov    $0x3,%eax
  801308:	bf 00 00 00 00       	mov    $0x0,%edi
  80130d:	89 f9                	mov    %edi,%ecx
  80130f:	89 fb                	mov    %edi,%ebx
  801311:	89 fe                	mov    %edi,%esi
  801313:	cd 30                	int    $0x30
  801315:	85 c0                	test   %eax,%eax
  801317:	7e 28                	jle    801341 <sys_env_destroy+0x50>
  801319:	89 44 24 10          	mov    %eax,0x10(%esp)
  80131d:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801324:	00 
  801325:	c7 44 24 08 1f 30 80 	movl   $0x80301f,0x8(%esp)
  80132c:	00 
  80132d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801334:	00 
  801335:	c7 04 24 3c 30 80 00 	movl   $0x80303c,(%esp)
  80133c:	e8 73 f0 ff ff       	call   8003b4 <_panic>
  801341:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801344:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801347:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  80134a:	89 ec                	mov    %ebp,%esp
  80134c:	5d                   	pop    %ebp
  80134d:	c3                   	ret    
	...

00801350 <fd2num>:
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801350:	55                   	push   %ebp
  801351:	89 e5                	mov    %esp,%ebp
  801353:	8b 45 08             	mov    0x8(%ebp),%eax
  801356:	05 00 00 00 30       	add    $0x30000000,%eax
  80135b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80135e:	5d                   	pop    %ebp
  80135f:	c3                   	ret    

00801360 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801360:	55                   	push   %ebp
  801361:	89 e5                	mov    %esp,%ebp
  801363:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801366:	8b 45 08             	mov    0x8(%ebp),%eax
  801369:	89 04 24             	mov    %eax,(%esp)
  80136c:	e8 df ff ff ff       	call   801350 <fd2num>
  801371:	c1 e0 0c             	shl    $0xc,%eax
  801374:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801379:	c9                   	leave  
  80137a:	c3                   	ret    

0080137b <fd_alloc>:

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
  80137b:	55                   	push   %ebp
  80137c:	89 e5                	mov    %esp,%ebp
  80137e:	53                   	push   %ebx
  80137f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801382:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  801387:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801389:	89 d0                	mov    %edx,%eax
  80138b:	c1 e8 16             	shr    $0x16,%eax
  80138e:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  801395:	a8 01                	test   $0x1,%al
  801397:	74 10                	je     8013a9 <fd_alloc+0x2e>
  801399:	89 d0                	mov    %edx,%eax
  80139b:	c1 e8 0c             	shr    $0xc,%eax
  80139e:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  8013a5:	a8 01                	test   $0x1,%al
  8013a7:	75 09                	jne    8013b2 <fd_alloc+0x37>
			*fd_store = fd;
  8013a9:	89 0b                	mov    %ecx,(%ebx)
  8013ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b0:	eb 19                	jmp    8013cb <fd_alloc+0x50>
			return 0;
  8013b2:	81 c2 00 10 00 00    	add    $0x1000,%edx
  8013b8:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  8013be:	75 c7                	jne    801387 <fd_alloc+0xc>
		}
	}
	*fd_store = 0;
  8013c0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8013c6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8013cb:	5b                   	pop    %ebx
  8013cc:	5d                   	pop    %ebp
  8013cd:	c3                   	ret    

008013ce <fd_lookup>:

// Check that fdnum is in range and mapped.
// If it is, set *fd_store to the fd page virtual address.
//
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013d4:	83 f8 1f             	cmp    $0x1f,%eax
  8013d7:	77 35                	ja     80140e <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013d9:	c1 e0 0c             	shl    $0xc,%eax
  8013dc:	8d 90 00 00 00 d0    	lea    0xd0000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  8013e2:	89 d0                	mov    %edx,%eax
  8013e4:	c1 e8 16             	shr    $0x16,%eax
  8013e7:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  8013ee:	a8 01                	test   $0x1,%al
  8013f0:	74 1c                	je     80140e <fd_lookup+0x40>
  8013f2:	89 d0                	mov    %edx,%eax
  8013f4:	c1 e8 0c             	shr    $0xc,%eax
  8013f7:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  8013fe:	a8 01                	test   $0x1,%al
  801400:	74 0c                	je     80140e <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801402:	8b 45 0c             	mov    0xc(%ebp),%eax
  801405:	89 10                	mov    %edx,(%eax)
  801407:	b8 00 00 00 00       	mov    $0x0,%eax
  80140c:	eb 05                	jmp    801413 <fd_lookup+0x45>
	return 0;
  80140e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801413:	5d                   	pop    %ebp
  801414:	c3                   	ret    

00801415 <seek>:

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
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
  801418:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80141b:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  80141e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801422:	8b 45 08             	mov    0x8(%ebp),%eax
  801425:	89 04 24             	mov    %eax,(%esp)
  801428:	e8 a1 ff ff ff       	call   8013ce <fd_lookup>
  80142d:	85 c0                	test   %eax,%eax
  80142f:	78 0e                	js     80143f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801431:	8b 55 0c             	mov    0xc(%ebp),%edx
  801434:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  801437:	89 50 04             	mov    %edx,0x4(%eax)
  80143a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80143f:	c9                   	leave  
  801440:	c3                   	ret    

00801441 <dev_lookup>:
  801441:	55                   	push   %ebp
  801442:	89 e5                	mov    %esp,%ebp
  801444:	53                   	push   %ebx
  801445:	83 ec 14             	sub    $0x14,%esp
  801448:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80144b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80144e:	ba 24 70 80 00       	mov    $0x807024,%edx
  801453:	b8 00 00 00 00       	mov    $0x0,%eax
  801458:	39 0d 24 70 80 00    	cmp    %ecx,0x807024
  80145e:	75 12                	jne    801472 <dev_lookup+0x31>
  801460:	eb 04                	jmp    801466 <dev_lookup+0x25>
  801462:	39 0a                	cmp    %ecx,(%edx)
  801464:	75 0c                	jne    801472 <dev_lookup+0x31>
  801466:	89 13                	mov    %edx,(%ebx)
  801468:	b8 00 00 00 00       	mov    $0x0,%eax
  80146d:	8d 76 00             	lea    0x0(%esi),%esi
  801470:	eb 35                	jmp    8014a7 <dev_lookup+0x66>
  801472:	83 c0 01             	add    $0x1,%eax
  801475:	8b 14 85 c8 30 80 00 	mov    0x8030c8(,%eax,4),%edx
  80147c:	85 d2                	test   %edx,%edx
  80147e:	75 e2                	jne    801462 <dev_lookup+0x21>
  801480:	a1 70 70 80 00       	mov    0x807070,%eax
  801485:	8b 40 4c             	mov    0x4c(%eax),%eax
  801488:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80148c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801490:	c7 04 24 4c 30 80 00 	movl   $0x80304c,(%esp)
  801497:	e8 e5 ef ff ff       	call   800481 <cprintf>
  80149c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8014a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a7:	83 c4 14             	add    $0x14,%esp
  8014aa:	5b                   	pop    %ebx
  8014ab:	5d                   	pop    %ebp
  8014ac:	c3                   	ret    

008014ad <fstat>:

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
  8014ad:	55                   	push   %ebp
  8014ae:	89 e5                	mov    %esp,%ebp
  8014b0:	53                   	push   %ebx
  8014b1:	83 ec 24             	sub    $0x24,%esp
  8014b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014b7:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8014ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014be:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c1:	89 04 24             	mov    %eax,(%esp)
  8014c4:	e8 05 ff ff ff       	call   8013ce <fd_lookup>
  8014c9:	89 c2                	mov    %eax,%edx
  8014cb:	85 c0                	test   %eax,%eax
  8014cd:	78 57                	js     801526 <fstat+0x79>
  8014cf:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  8014d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d6:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8014d9:	8b 00                	mov    (%eax),%eax
  8014db:	89 04 24             	mov    %eax,(%esp)
  8014de:	e8 5e ff ff ff       	call   801441 <dev_lookup>
  8014e3:	89 c2                	mov    %eax,%edx
  8014e5:	85 c0                	test   %eax,%eax
  8014e7:	78 3d                	js     801526 <fstat+0x79>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8014e9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  8014ee:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
  8014f1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014f5:	74 2f                	je     801526 <fstat+0x79>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014f7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014fa:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801501:	00 00 00 
	stat->st_isdir = 0;
  801504:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80150b:	00 00 00 
	stat->st_dev = dev;
  80150e:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801511:	89 93 88 00 00 00    	mov    %edx,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801517:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80151b:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80151e:	89 04 24             	mov    %eax,(%esp)
  801521:	ff 52 14             	call   *0x14(%edx)
  801524:	89 c2                	mov    %eax,%edx
}
  801526:	89 d0                	mov    %edx,%eax
  801528:	83 c4 24             	add    $0x24,%esp
  80152b:	5b                   	pop    %ebx
  80152c:	5d                   	pop    %ebp
  80152d:	c3                   	ret    

0080152e <ftruncate>:
  80152e:	55                   	push   %ebp
  80152f:	89 e5                	mov    %esp,%ebp
  801531:	53                   	push   %ebx
  801532:	83 ec 24             	sub    $0x24,%esp
  801535:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801538:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80153b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80153f:	89 1c 24             	mov    %ebx,(%esp)
  801542:	e8 87 fe ff ff       	call   8013ce <fd_lookup>
  801547:	85 c0                	test   %eax,%eax
  801549:	78 61                	js     8015ac <ftruncate+0x7e>
  80154b:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80154e:	8b 10                	mov    (%eax),%edx
  801550:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801553:	89 44 24 04          	mov    %eax,0x4(%esp)
  801557:	89 14 24             	mov    %edx,(%esp)
  80155a:	e8 e2 fe ff ff       	call   801441 <dev_lookup>
  80155f:	85 c0                	test   %eax,%eax
  801561:	78 49                	js     8015ac <ftruncate+0x7e>
  801563:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  801566:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  80156a:	75 23                	jne    80158f <ftruncate+0x61>
  80156c:	a1 70 70 80 00       	mov    0x807070,%eax
  801571:	8b 40 4c             	mov    0x4c(%eax),%eax
  801574:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801578:	89 44 24 04          	mov    %eax,0x4(%esp)
  80157c:	c7 04 24 6c 30 80 00 	movl   $0x80306c,(%esp)
  801583:	e8 f9 ee ff ff       	call   800481 <cprintf>
  801588:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80158d:	eb 1d                	jmp    8015ac <ftruncate+0x7e>
  80158f:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801592:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801597:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  80159b:	74 0f                	je     8015ac <ftruncate+0x7e>
  80159d:	8b 52 18             	mov    0x18(%edx),%edx
  8015a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a7:	89 0c 24             	mov    %ecx,(%esp)
  8015aa:	ff d2                	call   *%edx
  8015ac:	83 c4 24             	add    $0x24,%esp
  8015af:	5b                   	pop    %ebx
  8015b0:	5d                   	pop    %ebp
  8015b1:	c3                   	ret    

008015b2 <write>:
  8015b2:	55                   	push   %ebp
  8015b3:	89 e5                	mov    %esp,%ebp
  8015b5:	53                   	push   %ebx
  8015b6:	83 ec 24             	sub    $0x24,%esp
  8015b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8015bc:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8015bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c3:	89 1c 24             	mov    %ebx,(%esp)
  8015c6:	e8 03 fe ff ff       	call   8013ce <fd_lookup>
  8015cb:	85 c0                	test   %eax,%eax
  8015cd:	78 68                	js     801637 <write+0x85>
  8015cf:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8015d2:	8b 10                	mov    (%eax),%edx
  8015d4:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  8015d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015db:	89 14 24             	mov    %edx,(%esp)
  8015de:	e8 5e fe ff ff       	call   801441 <dev_lookup>
  8015e3:	85 c0                	test   %eax,%eax
  8015e5:	78 50                	js     801637 <write+0x85>
  8015e7:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  8015ea:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  8015ee:	75 23                	jne    801613 <write+0x61>
  8015f0:	a1 70 70 80 00       	mov    0x807070,%eax
  8015f5:	8b 40 4c             	mov    0x4c(%eax),%eax
  8015f8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801600:	c7 04 24 8d 30 80 00 	movl   $0x80308d,(%esp)
  801607:	e8 75 ee ff ff       	call   800481 <cprintf>
  80160c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801611:	eb 24                	jmp    801637 <write+0x85>
  801613:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801616:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80161b:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  80161f:	74 16                	je     801637 <write+0x85>
  801621:	8b 42 0c             	mov    0xc(%edx),%eax
  801624:	8b 55 10             	mov    0x10(%ebp),%edx
  801627:	89 54 24 08          	mov    %edx,0x8(%esp)
  80162b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80162e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801632:	89 0c 24             	mov    %ecx,(%esp)
  801635:	ff d0                	call   *%eax
  801637:	83 c4 24             	add    $0x24,%esp
  80163a:	5b                   	pop    %ebx
  80163b:	5d                   	pop    %ebp
  80163c:	c3                   	ret    

0080163d <read>:
  80163d:	55                   	push   %ebp
  80163e:	89 e5                	mov    %esp,%ebp
  801640:	53                   	push   %ebx
  801641:	83 ec 24             	sub    $0x24,%esp
  801644:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801647:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80164a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164e:	89 1c 24             	mov    %ebx,(%esp)
  801651:	e8 78 fd ff ff       	call   8013ce <fd_lookup>
  801656:	85 c0                	test   %eax,%eax
  801658:	78 6d                	js     8016c7 <read+0x8a>
  80165a:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80165d:	8b 10                	mov    (%eax),%edx
  80165f:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801662:	89 44 24 04          	mov    %eax,0x4(%esp)
  801666:	89 14 24             	mov    %edx,(%esp)
  801669:	e8 d3 fd ff ff       	call   801441 <dev_lookup>
  80166e:	85 c0                	test   %eax,%eax
  801670:	78 55                	js     8016c7 <read+0x8a>
  801672:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  801675:	8b 41 08             	mov    0x8(%ecx),%eax
  801678:	83 e0 03             	and    $0x3,%eax
  80167b:	83 f8 01             	cmp    $0x1,%eax
  80167e:	75 23                	jne    8016a3 <read+0x66>
  801680:	a1 70 70 80 00       	mov    0x807070,%eax
  801685:	8b 40 4c             	mov    0x4c(%eax),%eax
  801688:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80168c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801690:	c7 04 24 aa 30 80 00 	movl   $0x8030aa,(%esp)
  801697:	e8 e5 ed ff ff       	call   800481 <cprintf>
  80169c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016a1:	eb 24                	jmp    8016c7 <read+0x8a>
  8016a3:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  8016a6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016ab:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  8016af:	74 16                	je     8016c7 <read+0x8a>
  8016b1:	8b 42 08             	mov    0x8(%edx),%eax
  8016b4:	8b 55 10             	mov    0x10(%ebp),%edx
  8016b7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8016bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8016c2:	89 0c 24             	mov    %ecx,(%esp)
  8016c5:	ff d0                	call   *%eax
  8016c7:	83 c4 24             	add    $0x24,%esp
  8016ca:	5b                   	pop    %ebx
  8016cb:	5d                   	pop    %ebp
  8016cc:	c3                   	ret    

008016cd <readn>:
  8016cd:	55                   	push   %ebp
  8016ce:	89 e5                	mov    %esp,%ebp
  8016d0:	57                   	push   %edi
  8016d1:	56                   	push   %esi
  8016d2:	53                   	push   %ebx
  8016d3:	83 ec 0c             	sub    $0xc,%esp
  8016d6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8016d9:	8b 75 10             	mov    0x10(%ebp),%esi
  8016dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8016e1:	85 f6                	test   %esi,%esi
  8016e3:	74 36                	je     80171b <readn+0x4e>
  8016e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ef:	89 f0                	mov    %esi,%eax
  8016f1:	29 d0                	sub    %edx,%eax
  8016f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016f7:	8d 04 17             	lea    (%edi,%edx,1),%eax
  8016fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801701:	89 04 24             	mov    %eax,(%esp)
  801704:	e8 34 ff ff ff       	call   80163d <read>
  801709:	85 c0                	test   %eax,%eax
  80170b:	78 0e                	js     80171b <readn+0x4e>
  80170d:	85 c0                	test   %eax,%eax
  80170f:	74 08                	je     801719 <readn+0x4c>
  801711:	01 c3                	add    %eax,%ebx
  801713:	89 da                	mov    %ebx,%edx
  801715:	39 f3                	cmp    %esi,%ebx
  801717:	72 d6                	jb     8016ef <readn+0x22>
  801719:	89 d8                	mov    %ebx,%eax
  80171b:	83 c4 0c             	add    $0xc,%esp
  80171e:	5b                   	pop    %ebx
  80171f:	5e                   	pop    %esi
  801720:	5f                   	pop    %edi
  801721:	5d                   	pop    %ebp
  801722:	c3                   	ret    

00801723 <fd_close>:
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	83 ec 28             	sub    $0x28,%esp
  801729:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  80172c:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  80172f:	8b 75 08             	mov    0x8(%ebp),%esi
  801732:	89 34 24             	mov    %esi,(%esp)
  801735:	e8 16 fc ff ff       	call   801350 <fd2num>
  80173a:	8d 55 f4             	lea    0xfffffff4(%ebp),%edx
  80173d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801741:	89 04 24             	mov    %eax,(%esp)
  801744:	e8 85 fc ff ff       	call   8013ce <fd_lookup>
  801749:	89 c3                	mov    %eax,%ebx
  80174b:	85 c0                	test   %eax,%eax
  80174d:	78 05                	js     801754 <fd_close+0x31>
  80174f:	3b 75 f4             	cmp    0xfffffff4(%ebp),%esi
  801752:	74 0e                	je     801762 <fd_close+0x3f>
  801754:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801758:	75 45                	jne    80179f <fd_close+0x7c>
  80175a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80175f:	90                   	nop    
  801760:	eb 3d                	jmp    80179f <fd_close+0x7c>
  801762:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  801765:	89 44 24 04          	mov    %eax,0x4(%esp)
  801769:	8b 06                	mov    (%esi),%eax
  80176b:	89 04 24             	mov    %eax,(%esp)
  80176e:	e8 ce fc ff ff       	call   801441 <dev_lookup>
  801773:	89 c3                	mov    %eax,%ebx
  801775:	85 c0                	test   %eax,%eax
  801777:	78 16                	js     80178f <fd_close+0x6c>
  801779:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80177c:	8b 40 10             	mov    0x10(%eax),%eax
  80177f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801784:	85 c0                	test   %eax,%eax
  801786:	74 07                	je     80178f <fd_close+0x6c>
  801788:	89 34 24             	mov    %esi,(%esp)
  80178b:	ff d0                	call   *%eax
  80178d:	89 c3                	mov    %eax,%ebx
  80178f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801793:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80179a:	e8 cf f9 ff ff       	call   80116e <sys_page_unmap>
  80179f:	89 d8                	mov    %ebx,%eax
  8017a1:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  8017a4:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  8017a7:	89 ec                	mov    %ebp,%esp
  8017a9:	5d                   	pop    %ebp
  8017aa:	c3                   	ret    

008017ab <close>:
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	83 ec 18             	sub    $0x18,%esp
  8017b1:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  8017b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bb:	89 04 24             	mov    %eax,(%esp)
  8017be:	e8 0b fc ff ff       	call   8013ce <fd_lookup>
  8017c3:	85 c0                	test   %eax,%eax
  8017c5:	78 13                	js     8017da <close+0x2f>
  8017c7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8017ce:	00 
  8017cf:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  8017d2:	89 04 24             	mov    %eax,(%esp)
  8017d5:	e8 49 ff ff ff       	call   801723 <fd_close>
  8017da:	c9                   	leave  
  8017db:	c3                   	ret    

008017dc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
  8017df:	83 ec 18             	sub    $0x18,%esp
  8017e2:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  8017e5:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017e8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017ef:	00 
  8017f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f3:	89 04 24             	mov    %eax,(%esp)
  8017f6:	e8 58 03 00 00       	call   801b53 <open>
  8017fb:	89 c6                	mov    %eax,%esi
  8017fd:	85 c0                	test   %eax,%eax
  8017ff:	78 1b                	js     80181c <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801801:	8b 45 0c             	mov    0xc(%ebp),%eax
  801804:	89 44 24 04          	mov    %eax,0x4(%esp)
  801808:	89 34 24             	mov    %esi,(%esp)
  80180b:	e8 9d fc ff ff       	call   8014ad <fstat>
  801810:	89 c3                	mov    %eax,%ebx
	close(fd);
  801812:	89 34 24             	mov    %esi,(%esp)
  801815:	e8 91 ff ff ff       	call   8017ab <close>
  80181a:	89 de                	mov    %ebx,%esi
	return r;
}
  80181c:	89 f0                	mov    %esi,%eax
  80181e:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  801821:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  801824:	89 ec                	mov    %ebp,%esp
  801826:	5d                   	pop    %ebp
  801827:	c3                   	ret    

00801828 <dup>:
  801828:	55                   	push   %ebp
  801829:	89 e5                	mov    %esp,%ebp
  80182b:	83 ec 38             	sub    $0x38,%esp
  80182e:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  801831:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  801834:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  801837:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80183a:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  80183d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801841:	8b 45 08             	mov    0x8(%ebp),%eax
  801844:	89 04 24             	mov    %eax,(%esp)
  801847:	e8 82 fb ff ff       	call   8013ce <fd_lookup>
  80184c:	89 c3                	mov    %eax,%ebx
  80184e:	85 c0                	test   %eax,%eax
  801850:	0f 88 e1 00 00 00    	js     801937 <dup+0x10f>
  801856:	89 3c 24             	mov    %edi,(%esp)
  801859:	e8 4d ff ff ff       	call   8017ab <close>
  80185e:	89 f8                	mov    %edi,%eax
  801860:	c1 e0 0c             	shl    $0xc,%eax
  801863:	8d b0 00 00 00 d0    	lea    0xd0000000(%eax),%esi
  801869:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80186c:	89 04 24             	mov    %eax,(%esp)
  80186f:	e8 ec fa ff ff       	call   801360 <fd2data>
  801874:	89 c3                	mov    %eax,%ebx
  801876:	89 34 24             	mov    %esi,(%esp)
  801879:	e8 e2 fa ff ff       	call   801360 <fd2data>
  80187e:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  801881:	89 d8                	mov    %ebx,%eax
  801883:	c1 e8 16             	shr    $0x16,%eax
  801886:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  80188d:	a8 01                	test   $0x1,%al
  80188f:	74 45                	je     8018d6 <dup+0xae>
  801891:	89 da                	mov    %ebx,%edx
  801893:	c1 ea 0c             	shr    $0xc,%edx
  801896:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  80189d:	a8 01                	test   $0x1,%al
  80189f:	74 35                	je     8018d6 <dup+0xae>
  8018a1:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  8018a8:	25 07 0e 00 00       	and    $0xe07,%eax
  8018ad:	89 44 24 10          	mov    %eax,0x10(%esp)
  8018b1:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  8018b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018b8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018bf:	00 
  8018c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018cb:	e8 fc f8 ff ff       	call   8011cc <sys_page_map>
  8018d0:	89 c3                	mov    %eax,%ebx
  8018d2:	85 c0                	test   %eax,%eax
  8018d4:	78 3e                	js     801914 <dup+0xec>
  8018d6:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  8018d9:	89 d0                	mov    %edx,%eax
  8018db:	c1 e8 0c             	shr    $0xc,%eax
  8018de:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  8018e5:	25 07 0e 00 00       	and    $0xe07,%eax
  8018ea:	89 44 24 10          	mov    %eax,0x10(%esp)
  8018ee:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8018f2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018f9:	00 
  8018fa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801905:	e8 c2 f8 ff ff       	call   8011cc <sys_page_map>
  80190a:	89 c3                	mov    %eax,%ebx
  80190c:	85 c0                	test   %eax,%eax
  80190e:	78 04                	js     801914 <dup+0xec>
  801910:	89 fb                	mov    %edi,%ebx
  801912:	eb 23                	jmp    801937 <dup+0x10f>
  801914:	89 74 24 04          	mov    %esi,0x4(%esp)
  801918:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80191f:	e8 4a f8 ff ff       	call   80116e <sys_page_unmap>
  801924:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  801927:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801932:	e8 37 f8 ff ff       	call   80116e <sys_page_unmap>
  801937:	89 d8                	mov    %ebx,%eax
  801939:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  80193c:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  80193f:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801942:	89 ec                	mov    %ebp,%esp
  801944:	5d                   	pop    %ebp
  801945:	c3                   	ret    

00801946 <close_all>:
  801946:	55                   	push   %ebp
  801947:	89 e5                	mov    %esp,%ebp
  801949:	53                   	push   %ebx
  80194a:	83 ec 04             	sub    $0x4,%esp
  80194d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801952:	89 1c 24             	mov    %ebx,(%esp)
  801955:	e8 51 fe ff ff       	call   8017ab <close>
  80195a:	83 c3 01             	add    $0x1,%ebx
  80195d:	83 fb 20             	cmp    $0x20,%ebx
  801960:	75 f0                	jne    801952 <close_all+0xc>
  801962:	83 c4 04             	add    $0x4,%esp
  801965:	5b                   	pop    %ebx
  801966:	5d                   	pop    %ebp
  801967:	c3                   	ret    

00801968 <fsipc>:
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801968:	55                   	push   %ebp
  801969:	89 e5                	mov    %esp,%ebp
  80196b:	53                   	push   %ebx
  80196c:	83 ec 14             	sub    $0x14,%esp
  80196f:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801971:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  801977:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80197e:	00 
  80197f:	c7 44 24 08 00 40 80 	movl   $0x804000,0x8(%esp)
  801986:	00 
  801987:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198b:	89 14 24             	mov    %edx,(%esp)
  80198e:	e8 3d 0a 00 00       	call   8023d0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801993:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80199a:	00 
  80199b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80199f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019a6:	e8 d9 0a 00 00       	call   802484 <ipc_recv>
}
  8019ab:	83 c4 14             	add    $0x14,%esp
  8019ae:	5b                   	pop    %ebx
  8019af:	5d                   	pop    %ebp
  8019b0:	c3                   	ret    

008019b1 <sync>:

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
  8019b1:	55                   	push   %ebp
  8019b2:	89 e5                	mov    %esp,%ebp
  8019b4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019bc:	b8 08 00 00 00       	mov    $0x8,%eax
  8019c1:	e8 a2 ff ff ff       	call   801968 <fsipc>
}
  8019c6:	c9                   	leave  
  8019c7:	c3                   	ret    

008019c8 <devfile_trunc>:
  8019c8:	55                   	push   %ebp
  8019c9:	89 e5                	mov    %esp,%ebp
  8019cb:	83 ec 08             	sub    $0x8,%esp
  8019ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8019d4:	a3 00 40 80 00       	mov    %eax,0x804000
  8019d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019dc:	a3 04 40 80 00       	mov    %eax,0x804004
  8019e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e6:	b8 02 00 00 00       	mov    $0x2,%eax
  8019eb:	e8 78 ff ff ff       	call   801968 <fsipc>
  8019f0:	c9                   	leave  
  8019f1:	c3                   	ret    

008019f2 <devfile_flush>:
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
  8019f5:	83 ec 08             	sub    $0x8,%esp
  8019f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8019fe:	a3 00 40 80 00       	mov    %eax,0x804000
  801a03:	ba 00 00 00 00       	mov    $0x0,%edx
  801a08:	b8 06 00 00 00       	mov    $0x6,%eax
  801a0d:	e8 56 ff ff ff       	call   801968 <fsipc>
  801a12:	c9                   	leave  
  801a13:	c3                   	ret    

00801a14 <devfile_stat>:
  801a14:	55                   	push   %ebp
  801a15:	89 e5                	mov    %esp,%ebp
  801a17:	53                   	push   %ebx
  801a18:	83 ec 14             	sub    $0x14,%esp
  801a1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a21:	8b 40 0c             	mov    0xc(%eax),%eax
  801a24:	a3 00 40 80 00       	mov    %eax,0x804000
  801a29:	ba 00 00 00 00       	mov    $0x0,%edx
  801a2e:	b8 05 00 00 00       	mov    $0x5,%eax
  801a33:	e8 30 ff ff ff       	call   801968 <fsipc>
  801a38:	85 c0                	test   %eax,%eax
  801a3a:	78 2b                	js     801a67 <devfile_stat+0x53>
  801a3c:	c7 44 24 04 00 40 80 	movl   $0x804000,0x4(%esp)
  801a43:	00 
  801a44:	89 1c 24             	mov    %ebx,(%esp)
  801a47:	e8 b5 f0 ff ff       	call   800b01 <strcpy>
  801a4c:	a1 80 40 80 00       	mov    0x804080,%eax
  801a51:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  801a57:	a1 84 40 80 00       	mov    0x804084,%eax
  801a5c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801a62:	b8 00 00 00 00       	mov    $0x0,%eax
  801a67:	83 c4 14             	add    $0x14,%esp
  801a6a:	5b                   	pop    %ebx
  801a6b:	5d                   	pop    %ebp
  801a6c:	c3                   	ret    

00801a6d <devfile_write>:
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	83 ec 18             	sub    $0x18,%esp
  801a73:	8b 55 10             	mov    0x10(%ebp),%edx
  801a76:	8b 45 08             	mov    0x8(%ebp),%eax
  801a79:	8b 40 0c             	mov    0xc(%eax),%eax
  801a7c:	a3 00 40 80 00       	mov    %eax,0x804000
  801a81:	89 d0                	mov    %edx,%eax
  801a83:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  801a89:	76 05                	jbe    801a90 <devfile_write+0x23>
  801a8b:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801a90:	89 15 04 40 80 00    	mov    %edx,0x804004
  801a96:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa1:	c7 04 24 08 40 80 00 	movl   $0x804008,(%esp)
  801aa8:	e8 5d f2 ff ff       	call   800d0a <memmove>
  801aad:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab2:	b8 04 00 00 00       	mov    $0x4,%eax
  801ab7:	e8 ac fe ff ff       	call   801968 <fsipc>
  801abc:	c9                   	leave  
  801abd:	c3                   	ret    

00801abe <devfile_read>:
  801abe:	55                   	push   %ebp
  801abf:	89 e5                	mov    %esp,%ebp
  801ac1:	53                   	push   %ebx
  801ac2:	83 ec 14             	sub    $0x14,%esp
  801ac5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac8:	8b 40 0c             	mov    0xc(%eax),%eax
  801acb:	a3 00 40 80 00       	mov    %eax,0x804000
  801ad0:	8b 45 10             	mov    0x10(%ebp),%eax
  801ad3:	a3 04 40 80 00       	mov    %eax,0x804004
  801ad8:	ba 00 40 80 00       	mov    $0x804000,%edx
  801add:	b8 03 00 00 00       	mov    $0x3,%eax
  801ae2:	e8 81 fe ff ff       	call   801968 <fsipc>
  801ae7:	89 c3                	mov    %eax,%ebx
  801ae9:	85 c0                	test   %eax,%eax
  801aeb:	7e 17                	jle    801b04 <devfile_read+0x46>
  801aed:	89 44 24 08          	mov    %eax,0x8(%esp)
  801af1:	c7 44 24 04 00 40 80 	movl   $0x804000,0x4(%esp)
  801af8:	00 
  801af9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801afc:	89 04 24             	mov    %eax,(%esp)
  801aff:	e8 06 f2 ff ff       	call   800d0a <memmove>
  801b04:	89 d8                	mov    %ebx,%eax
  801b06:	83 c4 14             	add    $0x14,%esp
  801b09:	5b                   	pop    %ebx
  801b0a:	5d                   	pop    %ebp
  801b0b:	c3                   	ret    

00801b0c <remove>:
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	53                   	push   %ebx
  801b10:	83 ec 14             	sub    $0x14,%esp
  801b13:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b16:	89 1c 24             	mov    %ebx,(%esp)
  801b19:	e8 92 ef ff ff       	call   800ab0 <strlen>
  801b1e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  801b23:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b28:	7f 21                	jg     801b4b <remove+0x3f>
  801b2a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b2e:	c7 04 24 00 40 80 00 	movl   $0x804000,(%esp)
  801b35:	e8 c7 ef ff ff       	call   800b01 <strcpy>
  801b3a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b3f:	b8 07 00 00 00       	mov    $0x7,%eax
  801b44:	e8 1f fe ff ff       	call   801968 <fsipc>
  801b49:	89 c2                	mov    %eax,%edx
  801b4b:	89 d0                	mov    %edx,%eax
  801b4d:	83 c4 14             	add    $0x14,%esp
  801b50:	5b                   	pop    %ebx
  801b51:	5d                   	pop    %ebp
  801b52:	c3                   	ret    

00801b53 <open>:
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	56                   	push   %esi
  801b57:	53                   	push   %ebx
  801b58:	83 ec 30             	sub    $0x30,%esp
  801b5b:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  801b5e:	89 04 24             	mov    %eax,(%esp)
  801b61:	e8 15 f8 ff ff       	call   80137b <fd_alloc>
  801b66:	89 c3                	mov    %eax,%ebx
  801b68:	85 c0                	test   %eax,%eax
  801b6a:	79 18                	jns    801b84 <open+0x31>
  801b6c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b73:	00 
  801b74:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801b77:	89 04 24             	mov    %eax,(%esp)
  801b7a:	e8 a4 fb ff ff       	call   801723 <fd_close>
  801b7f:	e9 9f 00 00 00       	jmp    801c23 <open+0xd0>
  801b84:	8b 45 08             	mov    0x8(%ebp),%eax
  801b87:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b8b:	c7 04 24 00 40 80 00 	movl   $0x804000,(%esp)
  801b92:	e8 6a ef ff ff       	call   800b01 <strcpy>
  801b97:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b9a:	a3 00 44 80 00       	mov    %eax,0x804400
  801b9f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801ba2:	89 04 24             	mov    %eax,(%esp)
  801ba5:	e8 b6 f7 ff ff       	call   801360 <fd2data>
  801baa:	89 c6                	mov    %eax,%esi
  801bac:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  801baf:	b8 01 00 00 00       	mov    $0x1,%eax
  801bb4:	e8 af fd ff ff       	call   801968 <fsipc>
  801bb9:	89 c3                	mov    %eax,%ebx
  801bbb:	85 c0                	test   %eax,%eax
  801bbd:	79 15                	jns    801bd4 <open+0x81>
  801bbf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801bc6:	00 
  801bc7:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801bca:	89 04 24             	mov    %eax,(%esp)
  801bcd:	e8 51 fb ff ff       	call   801723 <fd_close>
  801bd2:	eb 4f                	jmp    801c23 <open+0xd0>
  801bd4:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801bdb:	00 
  801bdc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801be0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801be7:	00 
  801be8:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801beb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bf6:	e8 d1 f5 ff ff       	call   8011cc <sys_page_map>
  801bfb:	89 c3                	mov    %eax,%ebx
  801bfd:	85 c0                	test   %eax,%eax
  801bff:	79 15                	jns    801c16 <open+0xc3>
  801c01:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801c08:	00 
  801c09:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801c0c:	89 04 24             	mov    %eax,(%esp)
  801c0f:	e8 0f fb ff ff       	call   801723 <fd_close>
  801c14:	eb 0d                	jmp    801c23 <open+0xd0>
  801c16:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801c19:	89 04 24             	mov    %eax,(%esp)
  801c1c:	e8 2f f7 ff ff       	call   801350 <fd2num>
  801c21:	89 c3                	mov    %eax,%ebx
  801c23:	89 d8                	mov    %ebx,%eax
  801c25:	83 c4 30             	add    $0x30,%esp
  801c28:	5b                   	pop    %ebx
  801c29:	5e                   	pop    %esi
  801c2a:	5d                   	pop    %ebp
  801c2b:	c3                   	ret    
  801c2c:	00 00                	add    %al,(%eax)
	...

00801c30 <devsock_stat>:
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c30:	55                   	push   %ebp
  801c31:	89 e5                	mov    %esp,%ebp
  801c33:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  801c36:	c7 44 24 04 d4 30 80 	movl   $0x8030d4,0x4(%esp)
  801c3d:	00 
  801c3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c41:	89 04 24             	mov    %eax,(%esp)
  801c44:	e8 b8 ee ff ff       	call   800b01 <strcpy>
	return 0;
}
  801c49:	b8 00 00 00 00       	mov    $0x0,%eax
  801c4e:	c9                   	leave  
  801c4f:	c3                   	ret    

00801c50 <devsock_close>:
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
  801c53:	83 ec 08             	sub    $0x8,%esp
  801c56:	8b 45 08             	mov    0x8(%ebp),%eax
  801c59:	8b 40 0c             	mov    0xc(%eax),%eax
  801c5c:	89 04 24             	mov    %eax,(%esp)
  801c5f:	e8 be 02 00 00       	call   801f22 <nsipc_close>
  801c64:	c9                   	leave  
  801c65:	c3                   	ret    

00801c66 <devsock_write>:
  801c66:	55                   	push   %ebp
  801c67:	89 e5                	mov    %esp,%ebp
  801c69:	83 ec 18             	sub    $0x18,%esp
  801c6c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801c73:	00 
  801c74:	8b 45 10             	mov    0x10(%ebp),%eax
  801c77:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c82:	8b 45 08             	mov    0x8(%ebp),%eax
  801c85:	8b 40 0c             	mov    0xc(%eax),%eax
  801c88:	89 04 24             	mov    %eax,(%esp)
  801c8b:	e8 ce 02 00 00       	call   801f5e <nsipc_send>
  801c90:	c9                   	leave  
  801c91:	c3                   	ret    

00801c92 <devsock_read>:
  801c92:	55                   	push   %ebp
  801c93:	89 e5                	mov    %esp,%ebp
  801c95:	83 ec 18             	sub    $0x18,%esp
  801c98:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801c9f:	00 
  801ca0:	8b 45 10             	mov    0x10(%ebp),%eax
  801ca3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ca7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801caa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cae:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb1:	8b 40 0c             	mov    0xc(%eax),%eax
  801cb4:	89 04 24             	mov    %eax,(%esp)
  801cb7:	e8 15 03 00 00       	call   801fd1 <nsipc_recv>
  801cbc:	c9                   	leave  
  801cbd:	c3                   	ret    

00801cbe <alloc_sockfd>:
  801cbe:	55                   	push   %ebp
  801cbf:	89 e5                	mov    %esp,%ebp
  801cc1:	56                   	push   %esi
  801cc2:	53                   	push   %ebx
  801cc3:	83 ec 20             	sub    $0x20,%esp
  801cc6:	89 c6                	mov    %eax,%esi
  801cc8:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  801ccb:	89 04 24             	mov    %eax,(%esp)
  801cce:	e8 a8 f6 ff ff       	call   80137b <fd_alloc>
  801cd3:	89 c3                	mov    %eax,%ebx
  801cd5:	85 c0                	test   %eax,%eax
  801cd7:	78 21                	js     801cfa <alloc_sockfd+0x3c>
  801cd9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801ce0:	00 
  801ce1:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801ce4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ce8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cef:	e8 36 f5 ff ff       	call   80122a <sys_page_alloc>
  801cf4:	89 c3                	mov    %eax,%ebx
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	79 0a                	jns    801d04 <alloc_sockfd+0x46>
  801cfa:	89 34 24             	mov    %esi,(%esp)
  801cfd:	e8 20 02 00 00       	call   801f22 <nsipc_close>
  801d02:	eb 28                	jmp    801d2c <alloc_sockfd+0x6e>
  801d04:	8b 15 40 70 80 00    	mov    0x807040,%edx
  801d0a:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801d0d:	89 10                	mov    %edx,(%eax)
  801d0f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801d12:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
  801d19:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801d1c:	89 70 0c             	mov    %esi,0xc(%eax)
  801d1f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801d22:	89 04 24             	mov    %eax,(%esp)
  801d25:	e8 26 f6 ff ff       	call   801350 <fd2num>
  801d2a:	89 c3                	mov    %eax,%ebx
  801d2c:	89 d8                	mov    %ebx,%eax
  801d2e:	83 c4 20             	add    $0x20,%esp
  801d31:	5b                   	pop    %ebx
  801d32:	5e                   	pop    %esi
  801d33:	5d                   	pop    %ebp
  801d34:	c3                   	ret    

00801d35 <socket>:

int
socket(int domain, int type, int protocol)
{
  801d35:	55                   	push   %ebp
  801d36:	89 e5                	mov    %esp,%ebp
  801d38:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801d3b:	8b 45 10             	mov    0x10(%ebp),%eax
  801d3e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d42:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d45:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d49:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4c:	89 04 24             	mov    %eax,(%esp)
  801d4f:	e8 82 01 00 00       	call   801ed6 <nsipc_socket>
  801d54:	85 c0                	test   %eax,%eax
  801d56:	78 05                	js     801d5d <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801d58:	e8 61 ff ff ff       	call   801cbe <alloc_sockfd>
}
  801d5d:	c9                   	leave  
  801d5e:	66 90                	xchg   %ax,%ax
  801d60:	c3                   	ret    

00801d61 <fd2sockid>:
  801d61:	55                   	push   %ebp
  801d62:	89 e5                	mov    %esp,%ebp
  801d64:	83 ec 18             	sub    $0x18,%esp
  801d67:	8d 55 fc             	lea    0xfffffffc(%ebp),%edx
  801d6a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d6e:	89 04 24             	mov    %eax,(%esp)
  801d71:	e8 58 f6 ff ff       	call   8013ce <fd_lookup>
  801d76:	89 c2                	mov    %eax,%edx
  801d78:	85 c0                	test   %eax,%eax
  801d7a:	78 15                	js     801d91 <fd2sockid+0x30>
  801d7c:	8b 4d fc             	mov    0xfffffffc(%ebp),%ecx
  801d7f:	8b 01                	mov    (%ecx),%eax
  801d81:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  801d86:	3b 05 40 70 80 00    	cmp    0x807040,%eax
  801d8c:	75 03                	jne    801d91 <fd2sockid+0x30>
  801d8e:	8b 51 0c             	mov    0xc(%ecx),%edx
  801d91:	89 d0                	mov    %edx,%eax
  801d93:	c9                   	leave  
  801d94:	c3                   	ret    

00801d95 <listen>:
  801d95:	55                   	push   %ebp
  801d96:	89 e5                	mov    %esp,%ebp
  801d98:	83 ec 08             	sub    $0x8,%esp
  801d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9e:	e8 be ff ff ff       	call   801d61 <fd2sockid>
  801da3:	89 c2                	mov    %eax,%edx
  801da5:	85 c0                	test   %eax,%eax
  801da7:	78 11                	js     801dba <listen+0x25>
  801da9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dac:	89 44 24 04          	mov    %eax,0x4(%esp)
  801db0:	89 14 24             	mov    %edx,(%esp)
  801db3:	e8 48 01 00 00       	call   801f00 <nsipc_listen>
  801db8:	89 c2                	mov    %eax,%edx
  801dba:	89 d0                	mov    %edx,%eax
  801dbc:	c9                   	leave  
  801dbd:	c3                   	ret    

00801dbe <connect>:
  801dbe:	55                   	push   %ebp
  801dbf:	89 e5                	mov    %esp,%ebp
  801dc1:	83 ec 18             	sub    $0x18,%esp
  801dc4:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc7:	e8 95 ff ff ff       	call   801d61 <fd2sockid>
  801dcc:	89 c2                	mov    %eax,%edx
  801dce:	85 c0                	test   %eax,%eax
  801dd0:	78 18                	js     801dea <connect+0x2c>
  801dd2:	8b 45 10             	mov    0x10(%ebp),%eax
  801dd5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ddc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801de0:	89 14 24             	mov    %edx,(%esp)
  801de3:	e8 71 02 00 00       	call   802059 <nsipc_connect>
  801de8:	89 c2                	mov    %eax,%edx
  801dea:	89 d0                	mov    %edx,%eax
  801dec:	c9                   	leave  
  801ded:	c3                   	ret    

00801dee <shutdown>:
  801dee:	55                   	push   %ebp
  801def:	89 e5                	mov    %esp,%ebp
  801df1:	83 ec 08             	sub    $0x8,%esp
  801df4:	8b 45 08             	mov    0x8(%ebp),%eax
  801df7:	e8 65 ff ff ff       	call   801d61 <fd2sockid>
  801dfc:	89 c2                	mov    %eax,%edx
  801dfe:	85 c0                	test   %eax,%eax
  801e00:	78 11                	js     801e13 <shutdown+0x25>
  801e02:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e09:	89 14 24             	mov    %edx,(%esp)
  801e0c:	e8 2b 01 00 00       	call   801f3c <nsipc_shutdown>
  801e11:	89 c2                	mov    %eax,%edx
  801e13:	89 d0                	mov    %edx,%eax
  801e15:	c9                   	leave  
  801e16:	c3                   	ret    

00801e17 <bind>:
  801e17:	55                   	push   %ebp
  801e18:	89 e5                	mov    %esp,%ebp
  801e1a:	83 ec 18             	sub    $0x18,%esp
  801e1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e20:	e8 3c ff ff ff       	call   801d61 <fd2sockid>
  801e25:	89 c2                	mov    %eax,%edx
  801e27:	85 c0                	test   %eax,%eax
  801e29:	78 18                	js     801e43 <bind+0x2c>
  801e2b:	8b 45 10             	mov    0x10(%ebp),%eax
  801e2e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e32:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e35:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e39:	89 14 24             	mov    %edx,(%esp)
  801e3c:	e8 57 02 00 00       	call   802098 <nsipc_bind>
  801e41:	89 c2                	mov    %eax,%edx
  801e43:	89 d0                	mov    %edx,%eax
  801e45:	c9                   	leave  
  801e46:	c3                   	ret    

00801e47 <accept>:
  801e47:	55                   	push   %ebp
  801e48:	89 e5                	mov    %esp,%ebp
  801e4a:	83 ec 18             	sub    $0x18,%esp
  801e4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e50:	e8 0c ff ff ff       	call   801d61 <fd2sockid>
  801e55:	89 c2                	mov    %eax,%edx
  801e57:	85 c0                	test   %eax,%eax
  801e59:	78 23                	js     801e7e <accept+0x37>
  801e5b:	8b 45 10             	mov    0x10(%ebp),%eax
  801e5e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e62:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e65:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e69:	89 14 24             	mov    %edx,(%esp)
  801e6c:	e8 66 02 00 00       	call   8020d7 <nsipc_accept>
  801e71:	89 c2                	mov    %eax,%edx
  801e73:	85 c0                	test   %eax,%eax
  801e75:	78 07                	js     801e7e <accept+0x37>
  801e77:	e8 42 fe ff ff       	call   801cbe <alloc_sockfd>
  801e7c:	89 c2                	mov    %eax,%edx
  801e7e:	89 d0                	mov    %edx,%eax
  801e80:	c9                   	leave  
  801e81:	c3                   	ret    
	...

00801e90 <nsipc>:
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e90:	55                   	push   %ebp
  801e91:	89 e5                	mov    %esp,%ebp
  801e93:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801e96:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  801e9c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801ea3:	00 
  801ea4:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801eab:	00 
  801eac:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb0:	89 14 24             	mov    %edx,(%esp)
  801eb3:	e8 18 05 00 00       	call   8023d0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801eb8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ebf:	00 
  801ec0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ec7:	00 
  801ec8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ecf:	e8 b0 05 00 00       	call   802484 <ipc_recv>
}
  801ed4:	c9                   	leave  
  801ed5:	c3                   	ret    

00801ed6 <nsipc_socket>:

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
  801ed6:	55                   	push   %ebp
  801ed7:	89 e5                	mov    %esp,%ebp
  801ed9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801edc:	8b 45 08             	mov    0x8(%ebp),%eax
  801edf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801ee4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee7:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801eec:	8b 45 10             	mov    0x10(%ebp),%eax
  801eef:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ef4:	b8 09 00 00 00       	mov    $0x9,%eax
  801ef9:	e8 92 ff ff ff       	call   801e90 <nsipc>
}
  801efe:	c9                   	leave  
  801eff:	c3                   	ret    

00801f00 <nsipc_listen>:
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	83 ec 08             	sub    $0x8,%esp
  801f06:	8b 45 08             	mov    0x8(%ebp),%eax
  801f09:	a3 00 60 80 00       	mov    %eax,0x806000
  801f0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f11:	a3 04 60 80 00       	mov    %eax,0x806004
  801f16:	b8 06 00 00 00       	mov    $0x6,%eax
  801f1b:	e8 70 ff ff ff       	call   801e90 <nsipc>
  801f20:	c9                   	leave  
  801f21:	c3                   	ret    

00801f22 <nsipc_close>:
  801f22:	55                   	push   %ebp
  801f23:	89 e5                	mov    %esp,%ebp
  801f25:	83 ec 08             	sub    $0x8,%esp
  801f28:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2b:	a3 00 60 80 00       	mov    %eax,0x806000
  801f30:	b8 04 00 00 00       	mov    $0x4,%eax
  801f35:	e8 56 ff ff ff       	call   801e90 <nsipc>
  801f3a:	c9                   	leave  
  801f3b:	c3                   	ret    

00801f3c <nsipc_shutdown>:
  801f3c:	55                   	push   %ebp
  801f3d:	89 e5                	mov    %esp,%ebp
  801f3f:	83 ec 08             	sub    $0x8,%esp
  801f42:	8b 45 08             	mov    0x8(%ebp),%eax
  801f45:	a3 00 60 80 00       	mov    %eax,0x806000
  801f4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f4d:	a3 04 60 80 00       	mov    %eax,0x806004
  801f52:	b8 03 00 00 00       	mov    $0x3,%eax
  801f57:	e8 34 ff ff ff       	call   801e90 <nsipc>
  801f5c:	c9                   	leave  
  801f5d:	c3                   	ret    

00801f5e <nsipc_send>:
  801f5e:	55                   	push   %ebp
  801f5f:	89 e5                	mov    %esp,%ebp
  801f61:	53                   	push   %ebx
  801f62:	83 ec 14             	sub    $0x14,%esp
  801f65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f68:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6b:	a3 00 60 80 00       	mov    %eax,0x806000
  801f70:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801f76:	7e 24                	jle    801f9c <nsipc_send+0x3e>
  801f78:	c7 44 24 0c e0 30 80 	movl   $0x8030e0,0xc(%esp)
  801f7f:	00 
  801f80:	c7 44 24 08 ec 30 80 	movl   $0x8030ec,0x8(%esp)
  801f87:	00 
  801f88:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  801f8f:	00 
  801f90:	c7 04 24 01 31 80 00 	movl   $0x803101,(%esp)
  801f97:	e8 18 e4 ff ff       	call   8003b4 <_panic>
  801f9c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fa0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fa3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa7:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801fae:	e8 57 ed ff ff       	call   800d0a <memmove>
  801fb3:	89 1d 04 60 80 00    	mov    %ebx,0x806004
  801fb9:	8b 45 14             	mov    0x14(%ebp),%eax
  801fbc:	a3 08 60 80 00       	mov    %eax,0x806008
  801fc1:	b8 08 00 00 00       	mov    $0x8,%eax
  801fc6:	e8 c5 fe ff ff       	call   801e90 <nsipc>
  801fcb:	83 c4 14             	add    $0x14,%esp
  801fce:	5b                   	pop    %ebx
  801fcf:	5d                   	pop    %ebp
  801fd0:	c3                   	ret    

00801fd1 <nsipc_recv>:
  801fd1:	55                   	push   %ebp
  801fd2:	89 e5                	mov    %esp,%ebp
  801fd4:	83 ec 18             	sub    $0x18,%esp
  801fd7:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  801fda:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  801fdd:	8b 75 10             	mov    0x10(%ebp),%esi
  801fe0:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe3:	a3 00 60 80 00       	mov    %eax,0x806000
  801fe8:	89 35 04 60 80 00    	mov    %esi,0x806004
  801fee:	8b 45 14             	mov    0x14(%ebp),%eax
  801ff1:	a3 08 60 80 00       	mov    %eax,0x806008
  801ff6:	b8 07 00 00 00       	mov    $0x7,%eax
  801ffb:	e8 90 fe ff ff       	call   801e90 <nsipc>
  802000:	89 c3                	mov    %eax,%ebx
  802002:	85 c0                	test   %eax,%eax
  802004:	78 47                	js     80204d <nsipc_recv+0x7c>
  802006:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80200b:	7f 05                	jg     802012 <nsipc_recv+0x41>
  80200d:	39 c6                	cmp    %eax,%esi
  80200f:	90                   	nop    
  802010:	7d 24                	jge    802036 <nsipc_recv+0x65>
  802012:	c7 44 24 0c 0d 31 80 	movl   $0x80310d,0xc(%esp)
  802019:	00 
  80201a:	c7 44 24 08 ec 30 80 	movl   $0x8030ec,0x8(%esp)
  802021:	00 
  802022:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  802029:	00 
  80202a:	c7 04 24 01 31 80 00 	movl   $0x803101,(%esp)
  802031:	e8 7e e3 ff ff       	call   8003b4 <_panic>
  802036:	89 44 24 08          	mov    %eax,0x8(%esp)
  80203a:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802041:	00 
  802042:	8b 45 0c             	mov    0xc(%ebp),%eax
  802045:	89 04 24             	mov    %eax,(%esp)
  802048:	e8 bd ec ff ff       	call   800d0a <memmove>
  80204d:	89 d8                	mov    %ebx,%eax
  80204f:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  802052:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  802055:	89 ec                	mov    %ebp,%esp
  802057:	5d                   	pop    %ebp
  802058:	c3                   	ret    

00802059 <nsipc_connect>:
  802059:	55                   	push   %ebp
  80205a:	89 e5                	mov    %esp,%ebp
  80205c:	53                   	push   %ebx
  80205d:	83 ec 14             	sub    $0x14,%esp
  802060:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802063:	8b 45 08             	mov    0x8(%ebp),%eax
  802066:	a3 00 60 80 00       	mov    %eax,0x806000
  80206b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80206f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802072:	89 44 24 04          	mov    %eax,0x4(%esp)
  802076:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  80207d:	e8 88 ec ff ff       	call   800d0a <memmove>
  802082:	89 1d 14 60 80 00    	mov    %ebx,0x806014
  802088:	b8 05 00 00 00       	mov    $0x5,%eax
  80208d:	e8 fe fd ff ff       	call   801e90 <nsipc>
  802092:	83 c4 14             	add    $0x14,%esp
  802095:	5b                   	pop    %ebx
  802096:	5d                   	pop    %ebp
  802097:	c3                   	ret    

00802098 <nsipc_bind>:
  802098:	55                   	push   %ebp
  802099:	89 e5                	mov    %esp,%ebp
  80209b:	53                   	push   %ebx
  80209c:	83 ec 14             	sub    $0x14,%esp
  80209f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8020a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a5:	a3 00 60 80 00       	mov    %eax,0x806000
  8020aa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020b5:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  8020bc:	e8 49 ec ff ff       	call   800d0a <memmove>
  8020c1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
  8020c7:	b8 02 00 00 00       	mov    $0x2,%eax
  8020cc:	e8 bf fd ff ff       	call   801e90 <nsipc>
  8020d1:	83 c4 14             	add    $0x14,%esp
  8020d4:	5b                   	pop    %ebx
  8020d5:	5d                   	pop    %ebp
  8020d6:	c3                   	ret    

008020d7 <nsipc_accept>:
  8020d7:	55                   	push   %ebp
  8020d8:	89 e5                	mov    %esp,%ebp
  8020da:	53                   	push   %ebx
  8020db:	83 ec 14             	sub    $0x14,%esp
  8020de:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e1:	a3 00 60 80 00       	mov    %eax,0x806000
  8020e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020eb:	e8 a0 fd ff ff       	call   801e90 <nsipc>
  8020f0:	89 c3                	mov    %eax,%ebx
  8020f2:	85 c0                	test   %eax,%eax
  8020f4:	78 27                	js     80211d <nsipc_accept+0x46>
  8020f6:	a1 10 60 80 00       	mov    0x806010,%eax
  8020fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020ff:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802106:	00 
  802107:	8b 45 0c             	mov    0xc(%ebp),%eax
  80210a:	89 04 24             	mov    %eax,(%esp)
  80210d:	e8 f8 eb ff ff       	call   800d0a <memmove>
  802112:	8b 15 10 60 80 00    	mov    0x806010,%edx
  802118:	8b 45 10             	mov    0x10(%ebp),%eax
  80211b:	89 10                	mov    %edx,(%eax)
  80211d:	89 d8                	mov    %ebx,%eax
  80211f:	83 c4 14             	add    $0x14,%esp
  802122:	5b                   	pop    %ebx
  802123:	5d                   	pop    %ebp
  802124:	c3                   	ret    
	...

00802130 <free>:
}

void
free(void *v)
{
  802130:	55                   	push   %ebp
  802131:	89 e5                	mov    %esp,%ebp
  802133:	57                   	push   %edi
  802134:	56                   	push   %esi
  802135:	53                   	push   %ebx
  802136:	83 ec 1c             	sub    $0x1c,%esp
  802139:	8b 45 08             	mov    0x8(%ebp),%eax
	uint8_t *c;
	uint32_t *ref;

	if (v == 0)
  80213c:	85 c0                	test   %eax,%eax
  80213e:	0f 84 b8 00 00 00    	je     8021fc <free+0xcc>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);
  802144:	8b 3d 7c 31 80 00    	mov    0x80317c,%edi
  80214a:	39 c7                	cmp    %eax,%edi
  80214c:	77 0a                	ja     802158 <free+0x28>
  80214e:	8b 35 80 31 80 00    	mov    0x803180,%esi
  802154:	39 f0                	cmp    %esi,%eax
  802156:	72 24                	jb     80217c <free+0x4c>
  802158:	c7 44 24 0c 24 31 80 	movl   $0x803124,0xc(%esp)
  80215f:	00 
  802160:	c7 44 24 08 ec 30 80 	movl   $0x8030ec,0x8(%esp)
  802167:	00 
  802168:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  80216f:	00 
  802170:	c7 04 24 54 31 80 00 	movl   $0x803154,(%esp)
  802177:	e8 38 e2 ff ff       	call   8003b4 <_panic>

	c = ROUNDDOWN(v, PGSIZE);
  80217c:	89 c3                	mov    %eax,%ebx
  80217e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  802184:	eb 42                	jmp    8021c8 <free+0x98>

	while (vpt[VPN(c)] & PTE_CONTINUED) {
		sys_page_unmap(0, c);
  802186:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80218a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802191:	e8 d8 ef ff ff       	call   80116e <sys_page_unmap>
		c += PGSIZE;
  802196:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		assert(mbegin <= c && c < mend);
  80219c:	39 df                	cmp    %ebx,%edi
  80219e:	77 04                	ja     8021a4 <free+0x74>
  8021a0:	39 de                	cmp    %ebx,%esi
  8021a2:	77 24                	ja     8021c8 <free+0x98>
  8021a4:	c7 44 24 0c 61 31 80 	movl   $0x803161,0xc(%esp)
  8021ab:	00 
  8021ac:	c7 44 24 08 ec 30 80 	movl   $0x8030ec,0x8(%esp)
  8021b3:	00 
  8021b4:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
  8021bb:	00 
  8021bc:	c7 04 24 54 31 80 00 	movl   $0x803154,(%esp)
  8021c3:	e8 ec e1 ff ff       	call   8003b4 <_panic>
  8021c8:	89 d8                	mov    %ebx,%eax
  8021ca:	c1 e8 0c             	shr    $0xc,%eax
  8021cd:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  8021d4:	f6 c4 04             	test   $0x4,%ah
  8021d7:	75 ad                	jne    802186 <free+0x56>
	}

	/*
	 * c is just a piece of this page, so dec the ref count
	 * and maybe free the page.
	 */
	ref = (uint32_t*) (c + PGSIZE - 4);
	if (--(*ref) == 0)
  8021d9:	8b 83 fc 0f 00 00    	mov    0xffc(%ebx),%eax
  8021df:	83 e8 01             	sub    $0x1,%eax
  8021e2:	89 83 fc 0f 00 00    	mov    %eax,0xffc(%ebx)
  8021e8:	85 c0                	test   %eax,%eax
  8021ea:	75 10                	jne    8021fc <free+0xcc>
		sys_page_unmap(0, c);	
  8021ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021f7:	e8 72 ef ff ff       	call   80116e <sys_page_unmap>
}
  8021fc:	83 c4 1c             	add    $0x1c,%esp
  8021ff:	5b                   	pop    %ebx
  802200:	5e                   	pop    %esi
  802201:	5f                   	pop    %edi
  802202:	5d                   	pop    %ebp
  802203:	c3                   	ret    

00802204 <malloc>:
  802204:	55                   	push   %ebp
  802205:	89 e5                	mov    %esp,%ebp
  802207:	57                   	push   %edi
  802208:	56                   	push   %esi
  802209:	53                   	push   %ebx
  80220a:	83 ec 1c             	sub    $0x1c,%esp
  80220d:	83 3d 5c 70 80 00 00 	cmpl   $0x0,0x80705c
  802214:	75 0a                	jne    802220 <malloc+0x1c>
  802216:	a1 7c 31 80 00       	mov    0x80317c,%eax
  80221b:	a3 5c 70 80 00       	mov    %eax,0x80705c
  802220:	8b 45 08             	mov    0x8(%ebp),%eax
  802223:	83 c0 03             	add    $0x3,%eax
  802226:	83 e0 fc             	and    $0xfffffffc,%eax
  802229:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  80222c:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
  802231:	0f 87 80 01 00 00    	ja     8023b7 <malloc+0x1b3>
  802237:	8b 0d 5c 70 80 00    	mov    0x80705c,%ecx
  80223d:	f7 c1 ff 0f 00 00    	test   $0xfff,%ecx
  802243:	74 4a                	je     80228f <malloc+0x8b>
  802245:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
  802248:	89 ca                	mov    %ecx,%edx
  80224a:	c1 ea 0c             	shr    $0xc,%edx
  80224d:	8d 43 03             	lea    0x3(%ebx),%eax
  802250:	c1 e8 0c             	shr    $0xc,%eax
  802253:	39 c2                	cmp    %eax,%edx
  802255:	75 1c                	jne    802273 <malloc+0x6f>
  802257:	8d 81 ff 0f 00 00    	lea    0xfff(%ecx),%eax
  80225d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  802262:	83 40 fc 01          	addl   $0x1,0xfffffffc(%eax)
  802266:	89 ca                	mov    %ecx,%edx
  802268:	89 1d 5c 70 80 00    	mov    %ebx,0x80705c
  80226e:	e9 49 01 00 00       	jmp    8023bc <malloc+0x1b8>
  802273:	89 0c 24             	mov    %ecx,(%esp)
  802276:	e8 b5 fe ff ff       	call   802130 <free>
  80227b:	a1 5c 70 80 00       	mov    0x80705c,%eax
  802280:	05 00 10 00 00       	add    $0x1000,%eax
  802285:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80228a:	a3 5c 70 80 00       	mov    %eax,0x80705c
  80228f:	8b 35 80 31 80 00    	mov    0x803180,%esi
  802295:	8b 1d 5c 70 80 00    	mov    0x80705c,%ebx
  80229b:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  8022a2:	eb 06                	jmp    8022aa <malloc+0xa6>
  8022a4:	8b 1d 7c 31 80 00    	mov    0x80317c,%ebx
  8022aa:	8b 7d f0             	mov    0xfffffff0(%ebp),%edi
  8022ad:	83 c7 04             	add    $0x4,%edi
  8022b0:	89 da                	mov    %ebx,%edx
  8022b2:	8d 0c 3b             	lea    (%ebx,%edi,1),%ecx
  8022b5:	39 cb                	cmp    %ecx,%ebx
  8022b7:	0f 83 cc 00 00 00    	jae    802389 <malloc+0x185>
  8022bd:	39 f3                	cmp    %esi,%ebx
  8022bf:	72 06                	jb     8022c7 <malloc+0xc3>
  8022c1:	eb 3e                	jmp    802301 <malloc+0xfd>
  8022c3:	39 d6                	cmp    %edx,%esi
  8022c5:	76 3a                	jbe    802301 <malloc+0xfd>
  8022c7:	89 d0                	mov    %edx,%eax
  8022c9:	c1 e8 16             	shr    $0x16,%eax
  8022cc:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  8022d3:	a8 01                	test   $0x1,%al
  8022d5:	74 10                	je     8022e7 <malloc+0xe3>
  8022d7:	89 d0                	mov    %edx,%eax
  8022d9:	c1 e8 0c             	shr    $0xc,%eax
  8022dc:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  8022e3:	a8 01                	test   $0x1,%al
  8022e5:	75 1a                	jne    802301 <malloc+0xfd>
  8022e7:	81 c2 00 10 00 00    	add    $0x1000,%edx
  8022ed:	39 d1                	cmp    %edx,%ecx
  8022ef:	77 d2                	ja     8022c3 <malloc+0xbf>
  8022f1:	89 1d 5c 70 80 00    	mov    %ebx,0x80705c
  8022f7:	be 00 00 00 00       	mov    $0x0,%esi
  8022fc:	e9 96 00 00 00       	jmp    802397 <malloc+0x193>
  802301:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802307:	3b 1d 80 31 80 00    	cmp    0x803180,%ebx
  80230d:	75 9b                	jne    8022aa <malloc+0xa6>
  80230f:	83 45 ec 01          	addl   $0x1,0xffffffec(%ebp)
  802313:	83 7d ec 02          	cmpl   $0x2,0xffffffec(%ebp)
  802317:	75 8b                	jne    8022a4 <malloc+0xa0>
  802319:	a1 7c 31 80 00       	mov    0x80317c,%eax
  80231e:	a3 5c 70 80 00       	mov    %eax,0x80705c
  802323:	ba 00 00 00 00       	mov    $0x0,%edx
  802328:	e9 8f 00 00 00       	jmp    8023bc <malloc+0x1b8>
  80232d:	8d 9e 00 10 00 00    	lea    0x1000(%esi),%ebx
  802333:	39 fb                	cmp    %edi,%ebx
  802335:	19 c0                	sbb    %eax,%eax
  802337:	25 00 04 00 00       	and    $0x400,%eax
  80233c:	83 c8 07             	or     $0x7,%eax
  80233f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802343:	8d 83 00 f0 ff ff    	lea    0xfffff000(%ebx),%eax
  802349:	03 05 5c 70 80 00    	add    0x80705c,%eax
  80234f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802353:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80235a:	e8 cb ee ff ff       	call   80122a <sys_page_alloc>
  80235f:	85 c0                	test   %eax,%eax
  802361:	79 32                	jns    802395 <malloc+0x191>
  802363:	85 f6                	test   %esi,%esi
  802365:	78 50                	js     8023b7 <malloc+0x1b3>
  802367:	89 f0                	mov    %esi,%eax
  802369:	03 05 5c 70 80 00    	add    0x80705c,%eax
  80236f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802373:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80237a:	e8 ef ed ff ff       	call   80116e <sys_page_unmap>
  80237f:	81 ee 00 10 00 00    	sub    $0x1000,%esi
  802385:	78 30                	js     8023b7 <malloc+0x1b3>
  802387:	eb de                	jmp    802367 <malloc+0x163>
  802389:	89 1d 5c 70 80 00    	mov    %ebx,0x80705c
  80238f:	90                   	nop    
  802390:	e9 62 ff ff ff       	jmp    8022f7 <malloc+0xf3>
  802395:	89 de                	mov    %ebx,%esi
  802397:	39 fe                	cmp    %edi,%esi
  802399:	72 92                	jb     80232d <malloc+0x129>
  80239b:	a1 5c 70 80 00       	mov    0x80705c,%eax
  8023a0:	c7 44 30 fc 02 00 00 	movl   $0x2,0xfffffffc(%eax,%esi,1)
  8023a7:	00 
  8023a8:	89 c2                	mov    %eax,%edx
  8023aa:	8b 4d f0             	mov    0xfffffff0(%ebp),%ecx
  8023ad:	8d 04 08             	lea    (%eax,%ecx,1),%eax
  8023b0:	a3 5c 70 80 00       	mov    %eax,0x80705c
  8023b5:	eb 05                	jmp    8023bc <malloc+0x1b8>
  8023b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8023bc:	89 d0                	mov    %edx,%eax
  8023be:	83 c4 1c             	add    $0x1c,%esp
  8023c1:	5b                   	pop    %ebx
  8023c2:	5e                   	pop    %esi
  8023c3:	5f                   	pop    %edi
  8023c4:	5d                   	pop    %ebp
  8023c5:	c3                   	ret    
	...

008023d0 <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023d0:	55                   	push   %ebp
  8023d1:	89 e5                	mov    %esp,%ebp
  8023d3:	57                   	push   %edi
  8023d4:	56                   	push   %esi
  8023d5:	53                   	push   %ebx
  8023d6:	83 ec 1c             	sub    $0x1c,%esp
  8023d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8023dc:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  8023df:	e8 d9 ee ff ff       	call   8012bd <sys_getenvid>
  8023e4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8023e9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8023ec:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8023f1:	a3 70 70 80 00       	mov    %eax,0x807070
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  8023f6:	e8 c2 ee ff ff       	call   8012bd <sys_getenvid>
  8023fb:	25 ff 03 00 00       	and    $0x3ff,%eax
  802400:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802403:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802408:	a3 70 70 80 00       	mov    %eax,0x807070
		if(env->env_id==to_env){
  80240d:	8b 40 4c             	mov    0x4c(%eax),%eax
  802410:	39 f0                	cmp    %esi,%eax
  802412:	75 0e                	jne    802422 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  802414:	c7 04 24 84 31 80 00 	movl   $0x803184,(%esp)
  80241b:	e8 61 e0 ff ff       	call   800481 <cprintf>
  802420:	eb 5a                	jmp    80247c <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  802422:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802426:	8b 45 10             	mov    0x10(%ebp),%eax
  802429:	89 44 24 08          	mov    %eax,0x8(%esp)
  80242d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802430:	89 44 24 04          	mov    %eax,0x4(%esp)
  802434:	89 34 24             	mov    %esi,(%esp)
  802437:	e8 e0 eb ff ff       	call   80101c <sys_ipc_try_send>
  80243c:	89 c3                	mov    %eax,%ebx
  80243e:	85 c0                	test   %eax,%eax
  802440:	79 25                	jns    802467 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  802442:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802445:	74 2b                	je     802472 <ipc_send+0xa2>
				panic("send error:%e",r);
  802447:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80244b:	c7 44 24 08 a0 31 80 	movl   $0x8031a0,0x8(%esp)
  802452:	00 
  802453:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80245a:	00 
  80245b:	c7 04 24 ae 31 80 00 	movl   $0x8031ae,(%esp)
  802462:	e8 4d df ff ff       	call   8003b4 <_panic>
		}
			sys_yield();
  802467:	e8 1d ee ff ff       	call   801289 <sys_yield>
		
	}while(r!=0);
  80246c:	85 db                	test   %ebx,%ebx
  80246e:	75 86                	jne    8023f6 <ipc_send+0x26>
  802470:	eb 0a                	jmp    80247c <ipc_send+0xac>
  802472:	e8 12 ee ff ff       	call   801289 <sys_yield>
  802477:	e9 7a ff ff ff       	jmp    8023f6 <ipc_send+0x26>
	return;
	//panic("ipc_send not implemented");
}
  80247c:	83 c4 1c             	add    $0x1c,%esp
  80247f:	5b                   	pop    %ebx
  802480:	5e                   	pop    %esi
  802481:	5f                   	pop    %edi
  802482:	5d                   	pop    %ebp
  802483:	c3                   	ret    

00802484 <ipc_recv>:
  802484:	55                   	push   %ebp
  802485:	89 e5                	mov    %esp,%ebp
  802487:	57                   	push   %edi
  802488:	56                   	push   %esi
  802489:	53                   	push   %ebx
  80248a:	83 ec 0c             	sub    $0xc,%esp
  80248d:	8b 75 08             	mov    0x8(%ebp),%esi
  802490:	8b 7d 10             	mov    0x10(%ebp),%edi
  802493:	e8 25 ee ff ff       	call   8012bd <sys_getenvid>
  802498:	25 ff 03 00 00       	and    $0x3ff,%eax
  80249d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8024a0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8024a5:	a3 70 70 80 00       	mov    %eax,0x807070
  8024aa:	85 f6                	test   %esi,%esi
  8024ac:	74 29                	je     8024d7 <ipc_recv+0x53>
  8024ae:	8b 40 4c             	mov    0x4c(%eax),%eax
  8024b1:	3b 06                	cmp    (%esi),%eax
  8024b3:	75 22                	jne    8024d7 <ipc_recv+0x53>
  8024b5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8024bb:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8024c1:	c7 04 24 84 31 80 00 	movl   $0x803184,(%esp)
  8024c8:	e8 b4 df ff ff       	call   800481 <cprintf>
  8024cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024d2:	e9 8a 00 00 00       	jmp    802561 <ipc_recv+0xdd>
  8024d7:	e8 e1 ed ff ff       	call   8012bd <sys_getenvid>
  8024dc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8024e1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8024e4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8024e9:	a3 70 70 80 00       	mov    %eax,0x807070
  8024ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024f1:	89 04 24             	mov    %eax,(%esp)
  8024f4:	e8 c6 ea ff ff       	call   800fbf <sys_ipc_recv>
  8024f9:	89 c3                	mov    %eax,%ebx
  8024fb:	85 c0                	test   %eax,%eax
  8024fd:	79 1a                	jns    802519 <ipc_recv+0x95>
  8024ff:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802505:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  80250b:	c7 04 24 b8 31 80 00 	movl   $0x8031b8,(%esp)
  802512:	e8 6a df ff ff       	call   800481 <cprintf>
  802517:	eb 48                	jmp    802561 <ipc_recv+0xdd>
  802519:	e8 9f ed ff ff       	call   8012bd <sys_getenvid>
  80251e:	25 ff 03 00 00       	and    $0x3ff,%eax
  802523:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802526:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80252b:	a3 70 70 80 00       	mov    %eax,0x807070
  802530:	85 f6                	test   %esi,%esi
  802532:	74 05                	je     802539 <ipc_recv+0xb5>
  802534:	8b 40 74             	mov    0x74(%eax),%eax
  802537:	89 06                	mov    %eax,(%esi)
  802539:	85 ff                	test   %edi,%edi
  80253b:	74 0a                	je     802547 <ipc_recv+0xc3>
  80253d:	a1 70 70 80 00       	mov    0x807070,%eax
  802542:	8b 40 78             	mov    0x78(%eax),%eax
  802545:	89 07                	mov    %eax,(%edi)
  802547:	e8 71 ed ff ff       	call   8012bd <sys_getenvid>
  80254c:	25 ff 03 00 00       	and    $0x3ff,%eax
  802551:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802554:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802559:	a3 70 70 80 00       	mov    %eax,0x807070
  80255e:	8b 58 70             	mov    0x70(%eax),%ebx
  802561:	89 d8                	mov    %ebx,%eax
  802563:	83 c4 0c             	add    $0xc,%esp
  802566:	5b                   	pop    %ebx
  802567:	5e                   	pop    %esi
  802568:	5f                   	pop    %edi
  802569:	5d                   	pop    %ebp
  80256a:	c3                   	ret    
  80256b:	00 00                	add    %al,(%eax)
  80256d:	00 00                	add    %al,(%eax)
	...

00802570 <inet_ntoa>:
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  802570:	55                   	push   %ebp
  802571:	89 e5                	mov    %esp,%ebp
  802573:	57                   	push   %edi
  802574:	56                   	push   %esi
  802575:	53                   	push   %ebx
  802576:	83 ec 18             	sub    $0x18,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  802579:	8b 45 08             	mov    0x8(%ebp),%eax
  80257c:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  char inv[3];
  char *rp;
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  80257f:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  802582:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  802585:	be 00 00 00 00       	mov    $0x0,%esi
  80258a:	bf 60 70 80 00       	mov    $0x807060,%edi
  80258f:	c6 45 e3 00          	movb   $0x0,0xffffffe3(%ebp)
  802593:	eb 02                	jmp    802597 <inet_ntoa+0x27>
  802595:	89 c6                	mov    %eax,%esi
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  802597:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  80259a:	0f b6 0a             	movzbl (%edx),%ecx
      *ap /= (u8_t)10;
  80259d:	b8 cd ff ff ff       	mov    $0xffffffcd,%eax
  8025a2:	f6 e1                	mul    %cl
  8025a4:	89 c2                	mov    %eax,%edx
  8025a6:	66 c1 ea 08          	shr    $0x8,%dx
  8025aa:	c0 ea 03             	shr    $0x3,%dl
  8025ad:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  8025b0:	88 10                	mov    %dl,(%eax)
      inv[i++] = '0' + rem;
  8025b2:	89 f0                	mov    %esi,%eax
  8025b4:	0f b6 d8             	movzbl %al,%ebx
  8025b7:	8d 04 92             	lea    (%edx,%edx,4),%eax
  8025ba:	01 c0                	add    %eax,%eax
  8025bc:	28 c1                	sub    %al,%cl
  8025be:	83 c1 30             	add    $0x30,%ecx
  8025c1:	88 4c 1d ed          	mov    %cl,0xffffffed(%ebp,%ebx,1)
  8025c5:	8d 46 01             	lea    0x1(%esi),%eax
    } while(*ap);
  8025c8:	84 d2                	test   %dl,%dl
  8025ca:	75 c9                	jne    802595 <inet_ntoa+0x25>
    while(i--)
  8025cc:	89 f1                	mov    %esi,%ecx
  8025ce:	80 f9 ff             	cmp    $0xff,%cl
  8025d1:	74 20                	je     8025f3 <inet_ntoa+0x83>
  8025d3:	89 fa                	mov    %edi,%edx
      *rp++ = inv[i];
  8025d5:	0f b6 c1             	movzbl %cl,%eax
  8025d8:	0f b6 44 05 ed       	movzbl 0xffffffed(%ebp,%eax,1),%eax
  8025dd:	88 02                	mov    %al,(%edx)
  8025df:	83 c2 01             	add    $0x1,%edx
  8025e2:	83 e9 01             	sub    $0x1,%ecx
  8025e5:	80 f9 ff             	cmp    $0xff,%cl
  8025e8:	75 eb                	jne    8025d5 <inet_ntoa+0x65>
  8025ea:	89 f2                	mov    %esi,%edx
  8025ec:	0f b6 c2             	movzbl %dl,%eax
  8025ef:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
    *rp++ = '.';
  8025f3:	c6 07 2e             	movb   $0x2e,(%edi)
  8025f6:	83 c7 01             	add    $0x1,%edi
  8025f9:	80 45 e3 01          	addb   $0x1,0xffffffe3(%ebp)
  8025fd:	80 7d e3 03          	cmpb   $0x3,0xffffffe3(%ebp)
  802601:	77 0b                	ja     80260e <inet_ntoa+0x9e>
    ap++;
  802603:	83 45 dc 01          	addl   $0x1,0xffffffdc(%ebp)
  802607:	b8 00 00 00 00       	mov    $0x0,%eax
  80260c:	eb 87                	jmp    802595 <inet_ntoa+0x25>
  }
  *--rp = 0;
  80260e:	c6 47 ff 00          	movb   $0x0,0xffffffff(%edi)
  return str;
}
  802612:	b8 60 70 80 00       	mov    $0x807060,%eax
  802617:	83 c4 18             	add    $0x18,%esp
  80261a:	5b                   	pop    %ebx
  80261b:	5e                   	pop    %esi
  80261c:	5f                   	pop    %edi
  80261d:	5d                   	pop    %ebp
  80261e:	c3                   	ret    

0080261f <htons>:

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
  80261f:	55                   	push   %ebp
  802620:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  802622:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  802626:	89 c2                	mov    %eax,%edx
  802628:	c1 ea 08             	shr    $0x8,%edx
  80262b:	c1 e0 08             	shl    $0x8,%eax
  80262e:	09 d0                	or     %edx,%eax
  802630:	0f b7 c0             	movzwl %ax,%eax
}
  802633:	5d                   	pop    %ebp
  802634:	c3                   	ret    

00802635 <ntohs>:

/**
 * Convert an u16_t from network- to host byte order.
 *
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  802635:	55                   	push   %ebp
  802636:	89 e5                	mov    %esp,%ebp
  802638:	83 ec 04             	sub    $0x4,%esp
  return htons(n);
  80263b:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80263f:	89 04 24             	mov    %eax,(%esp)
  802642:	e8 d8 ff ff ff       	call   80261f <htons>
  802647:	0f b7 c0             	movzwl %ax,%eax
}
  80264a:	c9                   	leave  
  80264b:	c3                   	ret    

0080264c <htonl>:

/**
 * Convert an u32_t from host- to network byte order.
 *
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  80264c:	55                   	push   %ebp
  80264d:	89 e5                	mov    %esp,%ebp
  80264f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802652:	89 c8                	mov    %ecx,%eax
  802654:	25 00 ff 00 00       	and    $0xff00,%eax
  802659:	c1 e0 08             	shl    $0x8,%eax
  80265c:	89 ca                	mov    %ecx,%edx
  80265e:	c1 e2 18             	shl    $0x18,%edx
  802661:	09 d0                	or     %edx,%eax
  802663:	89 ca                	mov    %ecx,%edx
  802665:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  80266b:	c1 ea 08             	shr    $0x8,%edx
  80266e:	09 d0                	or     %edx,%eax
  802670:	c1 e9 18             	shr    $0x18,%ecx
  802673:	09 c8                	or     %ecx,%eax
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  802675:	5d                   	pop    %ebp
  802676:	c3                   	ret    

00802677 <inet_aton>:
  802677:	55                   	push   %ebp
  802678:	89 e5                	mov    %esp,%ebp
  80267a:	57                   	push   %edi
  80267b:	56                   	push   %esi
  80267c:	53                   	push   %ebx
  80267d:	83 ec 1c             	sub    $0x1c,%esp
  802680:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802683:	0f be 0b             	movsbl (%ebx),%ecx
  802686:	8d 41 d0             	lea    0xffffffd0(%ecx),%eax
  802689:	3c 09                	cmp    $0x9,%al
  80268b:	0f 87 9a 01 00 00    	ja     80282b <inet_aton+0x1b4>
  802691:	8d 45 e4             	lea    0xffffffe4(%ebp),%eax
  802694:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  802697:	be 0a 00 00 00       	mov    $0xa,%esi
  80269c:	83 f9 30             	cmp    $0x30,%ecx
  80269f:	75 20                	jne    8026c1 <inet_aton+0x4a>
  8026a1:	83 c3 01             	add    $0x1,%ebx
  8026a4:	0f be 0b             	movsbl (%ebx),%ecx
  8026a7:	83 f9 78             	cmp    $0x78,%ecx
  8026aa:	74 0a                	je     8026b6 <inet_aton+0x3f>
  8026ac:	be 08 00 00 00       	mov    $0x8,%esi
  8026b1:	83 f9 58             	cmp    $0x58,%ecx
  8026b4:	75 0b                	jne    8026c1 <inet_aton+0x4a>
  8026b6:	83 c3 01             	add    $0x1,%ebx
  8026b9:	0f be 0b             	movsbl (%ebx),%ecx
  8026bc:	be 10 00 00 00       	mov    $0x10,%esi
  8026c1:	bf 00 00 00 00       	mov    $0x0,%edi
  8026c6:	89 ca                	mov    %ecx,%edx
  8026c8:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  8026cb:	3c 09                	cmp    $0x9,%al
  8026cd:	77 11                	ja     8026e0 <inet_aton+0x69>
  8026cf:	89 f8                	mov    %edi,%eax
  8026d1:	0f af c6             	imul   %esi,%eax
  8026d4:	8d 7c 08 d0          	lea    0xffffffd0(%eax,%ecx,1),%edi
  8026d8:	83 c3 01             	add    $0x1,%ebx
  8026db:	0f be 0b             	movsbl (%ebx),%ecx
  8026de:	eb e6                	jmp    8026c6 <inet_aton+0x4f>
  8026e0:	83 fe 10             	cmp    $0x10,%esi
  8026e3:	75 30                	jne    802715 <inet_aton+0x9e>
  8026e5:	8d 42 9f             	lea    0xffffff9f(%edx),%eax
  8026e8:	88 45 df             	mov    %al,0xffffffdf(%ebp)
  8026eb:	3c 05                	cmp    $0x5,%al
  8026ed:	76 07                	jbe    8026f6 <inet_aton+0x7f>
  8026ef:	8d 42 bf             	lea    0xffffffbf(%edx),%eax
  8026f2:	3c 05                	cmp    $0x5,%al
  8026f4:	77 1f                	ja     802715 <inet_aton+0x9e>
  8026f6:	80 7d df 1a          	cmpb   $0x1a,0xffffffdf(%ebp)
  8026fa:	19 c0                	sbb    %eax,%eax
  8026fc:	83 e0 20             	and    $0x20,%eax
  8026ff:	29 c1                	sub    %eax,%ecx
  802701:	8d 41 c9             	lea    0xffffffc9(%ecx),%eax
  802704:	89 fa                	mov    %edi,%edx
  802706:	c1 e2 04             	shl    $0x4,%edx
  802709:	89 c7                	mov    %eax,%edi
  80270b:	09 d7                	or     %edx,%edi
  80270d:	83 c3 01             	add    $0x1,%ebx
  802710:	0f be 0b             	movsbl (%ebx),%ecx
  802713:	eb b1                	jmp    8026c6 <inet_aton+0x4f>
  802715:	83 f9 2e             	cmp    $0x2e,%ecx
  802718:	75 2d                	jne    802747 <inet_aton+0xd0>
  80271a:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  80271d:	3b 45 e0             	cmp    0xffffffe0(%ebp),%eax
  802720:	0f 86 05 01 00 00    	jbe    80282b <inet_aton+0x1b4>
  802726:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  802729:	89 3a                	mov    %edi,(%edx)
  80272b:	83 c3 01             	add    $0x1,%ebx
  80272e:	0f be 0b             	movsbl (%ebx),%ecx
  802731:	8d 41 d0             	lea    0xffffffd0(%ecx),%eax
  802734:	3c 09                	cmp    $0x9,%al
  802736:	0f 87 ef 00 00 00    	ja     80282b <inet_aton+0x1b4>
  80273c:	83 c2 04             	add    $0x4,%edx
  80273f:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  802742:	e9 50 ff ff ff       	jmp    802697 <inet_aton+0x20>
  802747:	89 fb                	mov    %edi,%ebx
  802749:	85 c9                	test   %ecx,%ecx
  80274b:	74 2e                	je     80277b <inet_aton+0x104>
  80274d:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  802750:	3c 5f                	cmp    $0x5f,%al
  802752:	0f 87 d3 00 00 00    	ja     80282b <inet_aton+0x1b4>
  802758:	83 f9 20             	cmp    $0x20,%ecx
  80275b:	74 1e                	je     80277b <inet_aton+0x104>
  80275d:	83 f9 0c             	cmp    $0xc,%ecx
  802760:	74 19                	je     80277b <inet_aton+0x104>
  802762:	83 f9 0a             	cmp    $0xa,%ecx
  802765:	74 14                	je     80277b <inet_aton+0x104>
  802767:	83 f9 0d             	cmp    $0xd,%ecx
  80276a:	74 0f                	je     80277b <inet_aton+0x104>
  80276c:	83 f9 09             	cmp    $0x9,%ecx
  80276f:	90                   	nop    
  802770:	74 09                	je     80277b <inet_aton+0x104>
  802772:	83 f9 0b             	cmp    $0xb,%ecx
  802775:	0f 85 b0 00 00 00    	jne    80282b <inet_aton+0x1b4>
  80277b:	8d 45 e4             	lea    0xffffffe4(%ebp),%eax
  80277e:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  802781:	29 c2                	sub    %eax,%edx
  802783:	89 d0                	mov    %edx,%eax
  802785:	c1 f8 02             	sar    $0x2,%eax
  802788:	83 c0 01             	add    $0x1,%eax
  80278b:	83 f8 02             	cmp    $0x2,%eax
  80278e:	74 24                	je     8027b4 <inet_aton+0x13d>
  802790:	83 f8 02             	cmp    $0x2,%eax
  802793:	7f 0d                	jg     8027a2 <inet_aton+0x12b>
  802795:	85 c0                	test   %eax,%eax
  802797:	0f 84 8e 00 00 00    	je     80282b <inet_aton+0x1b4>
  80279d:	8d 76 00             	lea    0x0(%esi),%esi
  8027a0:	eb 6a                	jmp    80280c <inet_aton+0x195>
  8027a2:	83 f8 03             	cmp    $0x3,%eax
  8027a5:	74 27                	je     8027ce <inet_aton+0x157>
  8027a7:	83 f8 04             	cmp    $0x4,%eax
  8027aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027b0:	75 5a                	jne    80280c <inet_aton+0x195>
  8027b2:	eb 36                	jmp    8027ea <inet_aton+0x173>
  8027b4:	81 fb ff ff ff 00    	cmp    $0xffffff,%ebx
  8027ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027c0:	77 69                	ja     80282b <inet_aton+0x1b4>
  8027c2:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  8027c5:	c1 e0 18             	shl    $0x18,%eax
  8027c8:	89 df                	mov    %ebx,%edi
  8027ca:	09 c7                	or     %eax,%edi
  8027cc:	eb 3e                	jmp    80280c <inet_aton+0x195>
  8027ce:	81 fb ff ff 00 00    	cmp    $0xffff,%ebx
  8027d4:	77 55                	ja     80282b <inet_aton+0x1b4>
  8027d6:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
  8027d9:	c1 e2 10             	shl    $0x10,%edx
  8027dc:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  8027df:	c1 e0 18             	shl    $0x18,%eax
  8027e2:	09 c2                	or     %eax,%edx
  8027e4:	89 d7                	mov    %edx,%edi
  8027e6:	09 df                	or     %ebx,%edi
  8027e8:	eb 22                	jmp    80280c <inet_aton+0x195>
  8027ea:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
  8027f0:	77 39                	ja     80282b <inet_aton+0x1b4>
  8027f2:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8027f5:	c1 e0 10             	shl    $0x10,%eax
  8027f8:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  8027fb:	c1 e2 18             	shl    $0x18,%edx
  8027fe:	09 d0                	or     %edx,%eax
  802800:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  802803:	c1 e2 08             	shl    $0x8,%edx
  802806:	09 d0                	or     %edx,%eax
  802808:	89 c7                	mov    %eax,%edi
  80280a:	09 df                	or     %ebx,%edi
  80280c:	b8 01 00 00 00       	mov    $0x1,%eax
  802811:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802815:	74 19                	je     802830 <inet_aton+0x1b9>
  802817:	89 3c 24             	mov    %edi,(%esp)
  80281a:	e8 2d fe ff ff       	call   80264c <htonl>
  80281f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802822:	89 02                	mov    %eax,(%edx)
  802824:	b8 01 00 00 00       	mov    $0x1,%eax
  802829:	eb 05                	jmp    802830 <inet_aton+0x1b9>
  80282b:	b8 00 00 00 00       	mov    $0x0,%eax
  802830:	83 c4 1c             	add    $0x1c,%esp
  802833:	5b                   	pop    %ebx
  802834:	5e                   	pop    %esi
  802835:	5f                   	pop    %edi
  802836:	5d                   	pop    %ebp
  802837:	c3                   	ret    

00802838 <inet_addr>:
  802838:	55                   	push   %ebp
  802839:	89 e5                	mov    %esp,%ebp
  80283b:	83 ec 18             	sub    $0x18,%esp
  80283e:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  802841:	89 44 24 04          	mov    %eax,0x4(%esp)
  802845:	8b 45 08             	mov    0x8(%ebp),%eax
  802848:	89 04 24             	mov    %eax,(%esp)
  80284b:	e8 27 fe ff ff       	call   802677 <inet_aton>
  802850:	83 f8 01             	cmp    $0x1,%eax
  802853:	19 c0                	sbb    %eax,%eax
  802855:	0b 45 fc             	or     0xfffffffc(%ebp),%eax
  802858:	c9                   	leave  
  802859:	c3                   	ret    

0080285a <ntohl>:

/**
 * Convert an u32_t from network- to host byte order.
 *
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  80285a:	55                   	push   %ebp
  80285b:	89 e5                	mov    %esp,%ebp
  80285d:	83 ec 04             	sub    $0x4,%esp
  return htonl(n);
  802860:	8b 45 08             	mov    0x8(%ebp),%eax
  802863:	89 04 24             	mov    %eax,(%esp)
  802866:	e8 e1 fd ff ff       	call   80264c <htonl>
}
  80286b:	c9                   	leave  
  80286c:	c3                   	ret    
  80286d:	00 00                	add    %al,(%eax)
	...

00802870 <__udivdi3>:
  802870:	55                   	push   %ebp
  802871:	89 e5                	mov    %esp,%ebp
  802873:	57                   	push   %edi
  802874:	56                   	push   %esi
  802875:	83 ec 1c             	sub    $0x1c,%esp
  802878:	8b 45 10             	mov    0x10(%ebp),%eax
  80287b:	8b 55 14             	mov    0x14(%ebp),%edx
  80287e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802881:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  802884:	89 c1                	mov    %eax,%ecx
  802886:	8b 45 08             	mov    0x8(%ebp),%eax
  802889:	85 d2                	test   %edx,%edx
  80288b:	89 d6                	mov    %edx,%esi
  80288d:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
  802890:	75 1e                	jne    8028b0 <__udivdi3+0x40>
  802892:	39 f9                	cmp    %edi,%ecx
  802894:	0f 86 8d 00 00 00    	jbe    802927 <__udivdi3+0xb7>
  80289a:	89 fa                	mov    %edi,%edx
  80289c:	f7 f1                	div    %ecx
  80289e:	89 c1                	mov    %eax,%ecx
  8028a0:	89 c8                	mov    %ecx,%eax
  8028a2:	89 f2                	mov    %esi,%edx
  8028a4:	83 c4 1c             	add    $0x1c,%esp
  8028a7:	5e                   	pop    %esi
  8028a8:	5f                   	pop    %edi
  8028a9:	5d                   	pop    %ebp
  8028aa:	c3                   	ret    
  8028ab:	90                   	nop    
  8028ac:	8d 74 26 00          	lea    0x0(%esi),%esi
  8028b0:	39 fa                	cmp    %edi,%edx
  8028b2:	0f 87 98 00 00 00    	ja     802950 <__udivdi3+0xe0>
  8028b8:	0f bd c2             	bsr    %edx,%eax
  8028bb:	83 f0 1f             	xor    $0x1f,%eax
  8028be:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8028c1:	74 7f                	je     802942 <__udivdi3+0xd2>
  8028c3:	b8 20 00 00 00       	mov    $0x20,%eax
  8028c8:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  8028cb:	2b 45 e4             	sub    0xffffffe4(%ebp),%eax
  8028ce:	89 c1                	mov    %eax,%ecx
  8028d0:	d3 ea                	shr    %cl,%edx
  8028d2:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8028d6:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  8028d9:	89 f0                	mov    %esi,%eax
  8028db:	d3 e0                	shl    %cl,%eax
  8028dd:	09 c2                	or     %eax,%edx
  8028df:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8028e2:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  8028e5:	89 fa                	mov    %edi,%edx
  8028e7:	d3 e0                	shl    %cl,%eax
  8028e9:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  8028ed:	89 45 f4             	mov    %eax,0xfffffff4(%ebp)
  8028f0:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8028f3:	d3 e8                	shr    %cl,%eax
  8028f5:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8028f9:	d3 e2                	shl    %cl,%edx
  8028fb:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  8028ff:	09 d0                	or     %edx,%eax
  802901:	d3 ef                	shr    %cl,%edi
  802903:	89 fa                	mov    %edi,%edx
  802905:	f7 75 e0             	divl   0xffffffe0(%ebp)
  802908:	89 d1                	mov    %edx,%ecx
  80290a:	89 c7                	mov    %eax,%edi
  80290c:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80290f:	f7 e7                	mul    %edi
  802911:	39 d1                	cmp    %edx,%ecx
  802913:	89 c6                	mov    %eax,%esi
  802915:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  802918:	72 6f                	jb     802989 <__udivdi3+0x119>
  80291a:	39 ca                	cmp    %ecx,%edx
  80291c:	74 5e                	je     80297c <__udivdi3+0x10c>
  80291e:	89 f9                	mov    %edi,%ecx
  802920:	31 f6                	xor    %esi,%esi
  802922:	e9 79 ff ff ff       	jmp    8028a0 <__udivdi3+0x30>
  802927:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80292a:	85 c0                	test   %eax,%eax
  80292c:	74 32                	je     802960 <__udivdi3+0xf0>
  80292e:	89 f2                	mov    %esi,%edx
  802930:	89 f8                	mov    %edi,%eax
  802932:	f7 f1                	div    %ecx
  802934:	89 c6                	mov    %eax,%esi
  802936:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802939:	f7 f1                	div    %ecx
  80293b:	89 c1                	mov    %eax,%ecx
  80293d:	e9 5e ff ff ff       	jmp    8028a0 <__udivdi3+0x30>
  802942:	39 d7                	cmp    %edx,%edi
  802944:	77 2a                	ja     802970 <__udivdi3+0x100>
  802946:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  802949:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
  80294c:	73 22                	jae    802970 <__udivdi3+0x100>
  80294e:	66 90                	xchg   %ax,%ax
  802950:	31 c9                	xor    %ecx,%ecx
  802952:	31 f6                	xor    %esi,%esi
  802954:	e9 47 ff ff ff       	jmp    8028a0 <__udivdi3+0x30>
  802959:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  802960:	b8 01 00 00 00       	mov    $0x1,%eax
  802965:	31 d2                	xor    %edx,%edx
  802967:	f7 75 f0             	divl   0xfffffff0(%ebp)
  80296a:	89 c1                	mov    %eax,%ecx
  80296c:	eb c0                	jmp    80292e <__udivdi3+0xbe>
  80296e:	66 90                	xchg   %ax,%ax
  802970:	b9 01 00 00 00       	mov    $0x1,%ecx
  802975:	31 f6                	xor    %esi,%esi
  802977:	e9 24 ff ff ff       	jmp    8028a0 <__udivdi3+0x30>
  80297c:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  80297f:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802983:	d3 e0                	shl    %cl,%eax
  802985:	39 c6                	cmp    %eax,%esi
  802987:	76 95                	jbe    80291e <__udivdi3+0xae>
  802989:	8d 4f ff             	lea    0xffffffff(%edi),%ecx
  80298c:	31 f6                	xor    %esi,%esi
  80298e:	e9 0d ff ff ff       	jmp    8028a0 <__udivdi3+0x30>
	...

008029a0 <__umoddi3>:
  8029a0:	55                   	push   %ebp
  8029a1:	89 e5                	mov    %esp,%ebp
  8029a3:	57                   	push   %edi
  8029a4:	56                   	push   %esi
  8029a5:	83 ec 30             	sub    $0x30,%esp
  8029a8:	8b 55 14             	mov    0x14(%ebp),%edx
  8029ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8029ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8029b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8029b4:	85 d2                	test   %edx,%edx
  8029b6:	c7 45 d0 00 00 00 00 	movl   $0x0,0xffffffd0(%ebp)
  8029bd:	89 c1                	mov    %eax,%ecx
  8029bf:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  8029c6:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  8029c9:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  8029cc:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  8029cf:	89 7d e0             	mov    %edi,0xffffffe0(%ebp)
  8029d2:	75 1c                	jne    8029f0 <__umoddi3+0x50>
  8029d4:	39 f8                	cmp    %edi,%eax
  8029d6:	89 fa                	mov    %edi,%edx
  8029d8:	0f 86 d4 00 00 00    	jbe    802ab2 <__umoddi3+0x112>
  8029de:	89 f0                	mov    %esi,%eax
  8029e0:	f7 f1                	div    %ecx
  8029e2:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  8029e5:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  8029ec:	eb 12                	jmp    802a00 <__umoddi3+0x60>
  8029ee:	66 90                	xchg   %ax,%ax
  8029f0:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  8029f3:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  8029f6:	76 18                	jbe    802a10 <__umoddi3+0x70>
  8029f8:	89 75 d0             	mov    %esi,0xffffffd0(%ebp)
  8029fb:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  8029fe:	66 90                	xchg   %ax,%ax
  802a00:	8b 45 d0             	mov    0xffffffd0(%ebp),%eax
  802a03:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  802a06:	83 c4 30             	add    $0x30,%esp
  802a09:	5e                   	pop    %esi
  802a0a:	5f                   	pop    %edi
  802a0b:	5d                   	pop    %ebp
  802a0c:	c3                   	ret    
  802a0d:	8d 76 00             	lea    0x0(%esi),%esi
  802a10:	0f bd 45 e8          	bsr    0xffffffe8(%ebp),%eax
  802a14:	83 f0 1f             	xor    $0x1f,%eax
  802a17:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  802a1a:	0f 84 c0 00 00 00    	je     802ae0 <__umoddi3+0x140>
  802a20:	b8 20 00 00 00       	mov    $0x20,%eax
  802a25:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  802a28:	2b 45 dc             	sub    0xffffffdc(%ebp),%eax
  802a2b:	8b 7d ec             	mov    0xffffffec(%ebp),%edi
  802a2e:	8b 75 f0             	mov    0xfffffff0(%ebp),%esi
  802a31:	89 c1                	mov    %eax,%ecx
  802a33:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  802a36:	d3 ea                	shr    %cl,%edx
  802a38:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802a3b:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  802a3f:	d3 e0                	shl    %cl,%eax
  802a41:	09 c2                	or     %eax,%edx
  802a43:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802a46:	d3 e7                	shl    %cl,%edi
  802a48:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802a4c:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  802a4f:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  802a52:	d3 e8                	shr    %cl,%eax
  802a54:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  802a58:	d3 e2                	shl    %cl,%edx
  802a5a:	09 d0                	or     %edx,%eax
  802a5c:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  802a5f:	d3 e6                	shl    %cl,%esi
  802a61:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802a65:	d3 ea                	shr    %cl,%edx
  802a67:	f7 75 f4             	divl   0xfffffff4(%ebp)
  802a6a:	89 55 cc             	mov    %edx,0xffffffcc(%ebp)
  802a6d:	f7 e7                	mul    %edi
  802a6f:	39 55 cc             	cmp    %edx,0xffffffcc(%ebp)
  802a72:	0f 82 a5 00 00 00    	jb     802b1d <__umoddi3+0x17d>
  802a78:	3b 55 cc             	cmp    0xffffffcc(%ebp),%edx
  802a7b:	0f 84 94 00 00 00    	je     802b15 <__umoddi3+0x175>
  802a81:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
  802a84:	29 c6                	sub    %eax,%esi
  802a86:	19 d1                	sbb    %edx,%ecx
  802a88:	89 4d cc             	mov    %ecx,0xffffffcc(%ebp)
  802a8b:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  802a8f:	89 f2                	mov    %esi,%edx
  802a91:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  802a94:	d3 ea                	shr    %cl,%edx
  802a96:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802a9a:	d3 e0                	shl    %cl,%eax
  802a9c:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  802aa0:	09 c2                	or     %eax,%edx
  802aa2:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  802aa5:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802aa8:	d3 e8                	shr    %cl,%eax
  802aaa:	89 45 d4             	mov    %eax,0xffffffd4(%ebp)
  802aad:	e9 4e ff ff ff       	jmp    802a00 <__umoddi3+0x60>
  802ab2:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  802ab5:	85 c0                	test   %eax,%eax
  802ab7:	74 17                	je     802ad0 <__umoddi3+0x130>
  802ab9:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  802abc:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
  802abf:	f7 f1                	div    %ecx
  802ac1:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802ac4:	f7 f1                	div    %ecx
  802ac6:	e9 17 ff ff ff       	jmp    8029e2 <__umoddi3+0x42>
  802acb:	90                   	nop    
  802acc:	8d 74 26 00          	lea    0x0(%esi),%esi
  802ad0:	b8 01 00 00 00       	mov    $0x1,%eax
  802ad5:	31 d2                	xor    %edx,%edx
  802ad7:	f7 75 ec             	divl   0xffffffec(%ebp)
  802ada:	89 c1                	mov    %eax,%ecx
  802adc:	eb db                	jmp    802ab9 <__umoddi3+0x119>
  802ade:	66 90                	xchg   %ax,%ax
  802ae0:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802ae3:	39 45 e0             	cmp    %eax,0xffffffe0(%ebp)
  802ae6:	77 19                	ja     802b01 <__umoddi3+0x161>
  802ae8:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  802aeb:	39 55 f0             	cmp    %edx,0xfffffff0(%ebp)
  802aee:	73 11                	jae    802b01 <__umoddi3+0x161>
  802af0:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  802af3:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802af6:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802af9:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  802afc:	e9 ff fe ff ff       	jmp    802a00 <__umoddi3+0x60>
  802b01:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802b04:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802b07:	2b 45 ec             	sub    0xffffffec(%ebp),%eax
  802b0a:	1b 4d e8             	sbb    0xffffffe8(%ebp),%ecx
  802b0d:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  802b10:	89 4d e0             	mov    %ecx,0xffffffe0(%ebp)
  802b13:	eb db                	jmp    802af0 <__umoddi3+0x150>
  802b15:	39 f0                	cmp    %esi,%eax
  802b17:	0f 86 64 ff ff ff    	jbe    802a81 <__umoddi3+0xe1>
  802b1d:	29 f8                	sub    %edi,%eax
  802b1f:	1b 55 f4             	sbb    0xfffffff4(%ebp),%edx
  802b22:	e9 5a ff ff ff       	jmp    802a81 <__umoddi3+0xe1>
