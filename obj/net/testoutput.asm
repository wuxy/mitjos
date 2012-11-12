
obj/net/testoutput:     file format elf32-i386

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
  80002c:	e8 f3 01 00 00       	call   800224 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <umain>:
static struct jif_pkt *pkt = (struct jif_pkt*)REQVA;


void
umain(void)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	57                   	push   %edi
  800044:	56                   	push   %esi
  800045:	53                   	push   %ebx
  800046:	83 ec 1c             	sub    $0x1c,%esp
	envid_t ns_envid = sys_getenvid();
  800049:	e8 4f 11 00 00       	call   80119d <sys_getenvid>
  80004e:	89 c3                	mov    %eax,%ebx
	int i, r;

	binaryname = "testoutput";
  800050:	c7 05 00 70 80 00 20 	movl   $0x802a20,0x807000
  800057:	2a 80 00 

	output_envid = fork();
  80005a:	e8 1a 16 00 00       	call   801679 <fork>
  80005f:	a3 3c 70 80 00       	mov    %eax,0x80703c
	if (output_envid < 0)
  800064:	85 c0                	test   %eax,%eax
  800066:	79 1c                	jns    800084 <umain+0x44>
		panic("error forking");
  800068:	c7 44 24 08 2b 2a 80 	movl   $0x802a2b,0x8(%esp)
  80006f:	00 
  800070:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  800077:	00 
  800078:	c7 04 24 39 2a 80 00 	movl   $0x802a39,(%esp)
  80007f:	e8 18 02 00 00       	call   80029c <_panic>
	else if (output_envid == 0) {
  800084:	85 c0                	test   %eax,%eax
  800086:	75 0d                	jne    800095 <umain+0x55>
		output(ns_envid);
  800088:	89 1c 24             	mov    %ebx,(%esp)
  80008b:	e8 84 01 00 00       	call   800214 <output>
  800090:	e9 c4 00 00 00       	jmp    800159 <umain+0x119>
		return;
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
		if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  800095:	8b 35 84 2a 80 00    	mov    0x802a84,%esi
			panic("sys_page_alloc: %e", r);
		pkt->jp_len = snprintf(pkt->jp_data,
  80009b:	8d 7e 04             	lea    0x4(%esi),%edi
  80009e:	bb 00 00 00 00       	mov    $0x0,%ebx
		output(ns_envid);
		return;
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
		if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  8000a3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8000aa:	00 
  8000ab:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b6:	e8 4f 10 00 00       	call   80110a <sys_page_alloc>
  8000bb:	85 c0                	test   %eax,%eax
  8000bd:	79 20                	jns    8000df <umain+0x9f>
			panic("sys_page_alloc: %e", r);
  8000bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c3:	c7 44 24 08 4a 2a 80 	movl   $0x802a4a,0x8(%esp)
  8000ca:	00 
  8000cb:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8000d2:	00 
  8000d3:	c7 04 24 39 2a 80 00 	movl   $0x802a39,(%esp)
  8000da:	e8 bd 01 00 00       	call   80029c <_panic>
		pkt->jp_len = snprintf(pkt->jp_data,
  8000df:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000e3:	c7 44 24 08 5d 2a 80 	movl   $0x802a5d,0x8(%esp)
  8000ea:	00 
  8000eb:	c7 44 24 04 fc 0f 00 	movl   $0xffc,0x4(%esp)
  8000f2:	00 
  8000f3:	89 3c 24             	mov    %edi,(%esp)
  8000f6:	e8 2f 08 00 00       	call   80092a <snprintf>
  8000fb:	89 06                	mov    %eax,(%esi)
				       PGSIZE - sizeof(pkt->jp_len),
				       "Packet %02d", i);
		cprintf("Transmitting packet %d\n", i);
  8000fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800101:	c7 04 24 69 2a 80 00 	movl   $0x802a69,(%esp)
  800108:	e8 5c 02 00 00       	call   800369 <cprintf>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  80010d:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800114:	00 
  800115:	89 74 24 08          	mov    %esi,0x8(%esp)
  800119:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
  800120:	00 
  800121:	a1 3c 70 80 00       	mov    0x80703c,%eax
  800126:	89 04 24             	mov    %eax,(%esp)
  800129:	e8 52 16 00 00       	call   801780 <ipc_send>
		sys_page_unmap(0, pkt);
  80012e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800132:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800139:	e8 10 0f 00 00       	call   80104e <sys_page_unmap>
	else if (output_envid == 0) {
		output(ns_envid);
		return;
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
  80013e:	83 c3 01             	add    $0x1,%ebx
  800141:	83 fb 0a             	cmp    $0xa,%ebx
  800144:	0f 85 59 ff ff ff    	jne    8000a3 <umain+0x63>
  80014a:	b3 00                	mov    $0x0,%bl
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
		sys_yield();
  80014c:	e8 18 10 00 00       	call   801169 <sys_yield>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
  800151:	83 c3 01             	add    $0x1,%ebx
  800154:	83 fb 14             	cmp    $0x14,%ebx
  800157:	75 f3                	jne    80014c <umain+0x10c>
		sys_yield();
}
  800159:	83 c4 1c             	add    $0x1c,%esp
  80015c:	5b                   	pop    %ebx
  80015d:	5e                   	pop    %esi
  80015e:	5f                   	pop    %edi
  80015f:	5d                   	pop    %ebp
  800160:	c3                   	ret    
	...

00800170 <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 2c             	sub    $0x2c,%esp
  800179:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint32_t stop = sys_time_msec() + initial_to;
  80017c:	e8 ea 0c 00 00       	call   800e6b <sys_time_msec>
  800181:	89 c3                	mov    %eax,%ebx
  800183:	03 5d 0c             	add    0xc(%ebp),%ebx

	binaryname = "ns_timer";
  800186:	c7 05 00 70 80 00 88 	movl   $0x802a88,0x807000
  80018d:	2a 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  800190:	8d 75 f0             	lea    -0x10(%ebp),%esi
  800193:	eb 05                	jmp    80019a <timer+0x2a>

	binaryname = "ns_timer";

	while (1) {
		while(sys_time_msec() < stop) {
			sys_yield();
  800195:	e8 cf 0f 00 00       	call   801169 <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while(sys_time_msec() < stop) {
  80019a:	e8 cc 0c 00 00       	call   800e6b <sys_time_msec>
  80019f:	39 c3                	cmp    %eax,%ebx
  8001a1:	77 f2                	ja     800195 <timer+0x25>
			sys_yield();
		}

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  8001a3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001aa:	00 
  8001ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001b2:	00 
  8001b3:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
  8001ba:	00 
  8001bb:	89 3c 24             	mov    %edi,(%esp)
  8001be:	e8 bd 15 00 00       	call   801780 <ipc_send>

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8001c3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001ca:	00 
  8001cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001d2:	00 
  8001d3:	89 34 24             	mov    %esi,(%esp)
  8001d6:	e8 59 16 00 00       	call   801834 <ipc_recv>
  8001db:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  8001dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001e0:	39 c7                	cmp    %eax,%edi
  8001e2:	74 12                	je     8001f6 <timer+0x86>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  8001e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e8:	c7 04 24 94 2a 80 00 	movl   $0x802a94,(%esp)
  8001ef:	e8 75 01 00 00       	call   800369 <cprintf>
  8001f4:	eb cd                	jmp    8001c3 <timer+0x53>
				continue;
			}

			stop = sys_time_msec() + to;
  8001f6:	e8 70 0c 00 00       	call   800e6b <sys_time_msec>
  8001fb:	01 c3                	add    %eax,%ebx
  8001fd:	8d 76 00             	lea    0x0(%esi),%esi
  800200:	eb 98                	jmp    80019a <timer+0x2a>
	...

00800204 <input>:

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
	binaryname = "ns_input";
  800207:	c7 05 00 70 80 00 cf 	movl   $0x802acf,0x807000
  80020e:	2a 80 00 
	// 	- read a packet from the device driver
	//	- send it to the network server
	// Hint: When you IPC a page to the network server, it will be
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
}
  800211:	5d                   	pop    %ebp
  800212:	c3                   	ret    
	...

00800214 <output>:

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
	binaryname = "ns_output";
  800217:	c7 05 00 70 80 00 d8 	movl   $0x802ad8,0x807000
  80021e:	2a 80 00 

	// LAB 6: Your code here:
	// 	- read a packet from the network server
	//	- send the packet to the device driver
}
  800221:	5d                   	pop    %ebp
  800222:	c3                   	ret    
	...

00800224 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	83 ec 18             	sub    $0x18,%esp
  80022a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80022d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800230:	8b 75 08             	mov    0x8(%ebp),%esi
  800233:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  800236:	c7 05 40 70 80 00 00 	movl   $0x0,0x807040
  80023d:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  800240:	e8 58 0f 00 00       	call   80119d <sys_getenvid>
  800245:	25 ff 03 00 00       	and    $0x3ff,%eax
  80024a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80024d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800252:	a3 40 70 80 00       	mov    %eax,0x807040
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800257:	85 f6                	test   %esi,%esi
  800259:	7e 07                	jle    800262 <libmain+0x3e>
		binaryname = argv[0];
  80025b:	8b 03                	mov    (%ebx),%eax
  80025d:	a3 00 70 80 00       	mov    %eax,0x807000

	// call user main routine
	umain(argc, argv);
  800262:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800266:	89 34 24             	mov    %esi,(%esp)
  800269:	e8 d2 fd ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  80026e:	e8 0d 00 00 00       	call   800280 <exit>
}
  800273:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800276:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800279:	89 ec                	mov    %ebp,%esp
  80027b:	5d                   	pop    %ebp
  80027c:	c3                   	ret    
  80027d:	00 00                	add    %al,(%eax)
	...

00800280 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800286:	e8 85 1c 00 00       	call   801f10 <close_all>
	sys_env_destroy(0);
  80028b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800292:	e8 3a 0f 00 00       	call   8011d1 <sys_env_destroy>
}
  800297:	c9                   	leave  
  800298:	c3                   	ret    
  800299:	00 00                	add    %al,(%eax)
	...

0080029c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8002a5:	89 45 fc             	mov    %eax,-0x4(%ebp)

	// Print the panic message
	if (argv0)
  8002a8:	a1 44 70 80 00       	mov    0x807044,%eax
  8002ad:	85 c0                	test   %eax,%eax
  8002af:	74 10                	je     8002c1 <_panic+0x25>
		cprintf("%s: ", argv0);
  8002b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b5:	c7 04 24 f9 2a 80 00 	movl   $0x802af9,(%esp)
  8002bc:	e8 a8 00 00 00       	call   800369 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8002c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002cf:	a1 00 70 80 00       	mov    0x807000,%eax
  8002d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d8:	c7 04 24 fe 2a 80 00 	movl   $0x802afe,(%esp)
  8002df:	e8 85 00 00 00       	call   800369 <cprintf>
	vcprintf(fmt, ap);
  8002e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8002e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002eb:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ee:	89 04 24             	mov    %eax,(%esp)
  8002f1:	e8 12 00 00 00       	call   800308 <vcprintf>
	cprintf("\n");
  8002f6:	c7 04 24 7f 2a 80 00 	movl   $0x802a7f,(%esp)
  8002fd:	e8 67 00 00 00       	call   800369 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800302:	cc                   	int3   
  800303:	eb fd                	jmp    800302 <_panic+0x66>
  800305:	00 00                	add    %al,(%eax)
	...

00800308 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800311:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  800318:	00 00 00 
	b.cnt = 0;
  80031b:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  800322:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800325:	8b 45 0c             	mov    0xc(%ebp),%eax
  800328:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80032c:	8b 45 08             	mov    0x8(%ebp),%eax
  80032f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800333:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800339:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033d:	c7 04 24 86 03 80 00 	movl   $0x800386,(%esp)
  800344:	e8 cc 01 00 00       	call   800515 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800349:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
  80034f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800353:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  800359:	89 04 24             	mov    %eax,(%esp)
  80035c:	e8 d7 0a 00 00       	call   800e38 <sys_cputs>
  800361:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  800367:	c9                   	leave  
  800368:	c3                   	ret    

00800369 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800369:	55                   	push   %ebp
  80036a:	89 e5                	mov    %esp,%ebp
  80036c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80036f:	8d 45 0c             	lea    0xc(%ebp),%eax
  800372:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800375:	89 44 24 04          	mov    %eax,0x4(%esp)
  800379:	8b 45 08             	mov    0x8(%ebp),%eax
  80037c:	89 04 24             	mov    %eax,(%esp)
  80037f:	e8 84 ff ff ff       	call   800308 <vcprintf>
	va_end(ap);

	return cnt;
}
  800384:	c9                   	leave  
  800385:	c3                   	ret    

00800386 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
  800389:	53                   	push   %ebx
  80038a:	83 ec 14             	sub    $0x14,%esp
  80038d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800390:	8b 03                	mov    (%ebx),%eax
  800392:	8b 55 08             	mov    0x8(%ebp),%edx
  800395:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800399:	83 c0 01             	add    $0x1,%eax
  80039c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80039e:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a3:	75 19                	jne    8003be <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8003a5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003ac:	00 
  8003ad:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b0:	89 04 24             	mov    %eax,(%esp)
  8003b3:	e8 80 0a 00 00       	call   800e38 <sys_cputs>
		b->idx = 0;
  8003b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003be:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003c2:	83 c4 14             	add    $0x14,%esp
  8003c5:	5b                   	pop    %ebx
  8003c6:	5d                   	pop    %ebp
  8003c7:	c3                   	ret    
	...

008003d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	57                   	push   %edi
  8003d4:	56                   	push   %esi
  8003d5:	53                   	push   %ebx
  8003d6:	83 ec 3c             	sub    $0x3c,%esp
  8003d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003dc:	89 d7                	mov    %edx,%edi
  8003de:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003ea:	8b 55 10             	mov    0x10(%ebp),%edx
  8003ed:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003f0:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8003f3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  8003fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003fd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  800400:	72 14                	jb     800416 <printnum+0x46>
  800402:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800405:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800408:	76 0c                	jbe    800416 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80040a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80040d:	83 eb 01             	sub    $0x1,%ebx
  800410:	85 db                	test   %ebx,%ebx
  800412:	7f 57                	jg     80046b <printnum+0x9b>
  800414:	eb 64                	jmp    80047a <printnum+0xaa>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800416:	89 74 24 10          	mov    %esi,0x10(%esp)
  80041a:	8b 45 14             	mov    0x14(%ebp),%eax
  80041d:	83 e8 01             	sub    $0x1,%eax
  800420:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800424:	89 54 24 08          	mov    %edx,0x8(%esp)
  800428:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80042c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800430:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800433:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800436:	89 44 24 08          	mov    %eax,0x8(%esp)
  80043a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80043e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800441:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800444:	89 04 24             	mov    %eax,(%esp)
  800447:	89 54 24 04          	mov    %edx,0x4(%esp)
  80044b:	e8 30 23 00 00       	call   802780 <__udivdi3>
  800450:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800454:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800458:	89 04 24             	mov    %eax,(%esp)
  80045b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80045f:	89 fa                	mov    %edi,%edx
  800461:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800464:	e8 67 ff ff ff       	call   8003d0 <printnum>
  800469:	eb 0f                	jmp    80047a <printnum+0xaa>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80046b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80046f:	89 34 24             	mov    %esi,(%esp)
  800472:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800475:	83 eb 01             	sub    $0x1,%ebx
  800478:	75 f1                	jne    80046b <printnum+0x9b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80047e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800482:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800485:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800488:	89 44 24 08          	mov    %eax,0x8(%esp)
  80048c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800490:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800493:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800496:	89 04 24             	mov    %eax,(%esp)
  800499:	89 54 24 04          	mov    %edx,0x4(%esp)
  80049d:	e8 0e 24 00 00       	call   8028b0 <__umoddi3>
  8004a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004a6:	0f be 80 1a 2b 80 00 	movsbl 0x802b1a(%eax),%eax
  8004ad:	89 04 24             	mov    %eax,(%esp)
  8004b0:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8004b3:	83 c4 3c             	add    $0x3c,%esp
  8004b6:	5b                   	pop    %ebx
  8004b7:	5e                   	pop    %esi
  8004b8:	5f                   	pop    %edi
  8004b9:	5d                   	pop    %ebp
  8004ba:	c3                   	ret    

008004bb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004bb:	55                   	push   %ebp
  8004bc:	89 e5                	mov    %esp,%ebp
  8004be:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8004c0:	83 fa 01             	cmp    $0x1,%edx
  8004c3:	7e 0e                	jle    8004d3 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8004c5:	8b 10                	mov    (%eax),%edx
  8004c7:	8d 42 08             	lea    0x8(%edx),%eax
  8004ca:	89 01                	mov    %eax,(%ecx)
  8004cc:	8b 02                	mov    (%edx),%eax
  8004ce:	8b 52 04             	mov    0x4(%edx),%edx
  8004d1:	eb 22                	jmp    8004f5 <getuint+0x3a>
	else if (lflag)
  8004d3:	85 d2                	test   %edx,%edx
  8004d5:	74 10                	je     8004e7 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8004d7:	8b 10                	mov    (%eax),%edx
  8004d9:	8d 42 04             	lea    0x4(%edx),%eax
  8004dc:	89 01                	mov    %eax,(%ecx)
  8004de:	8b 02                	mov    (%edx),%eax
  8004e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e5:	eb 0e                	jmp    8004f5 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  8004e7:	8b 10                	mov    (%eax),%edx
  8004e9:	8d 42 04             	lea    0x4(%edx),%eax
  8004ec:	89 01                	mov    %eax,(%ecx)
  8004ee:	8b 02                	mov    (%edx),%eax
  8004f0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004f5:	5d                   	pop    %ebp
  8004f6:	c3                   	ret    

008004f7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004f7:	55                   	push   %ebp
  8004f8:	89 e5                	mov    %esp,%ebp
  8004fa:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  8004fd:	83 42 08 01          	addl   $0x1,0x8(%edx)
	if (b->buf < b->ebuf)
  800501:	8b 02                	mov    (%edx),%eax
  800503:	3b 42 04             	cmp    0x4(%edx),%eax
  800506:	73 0b                	jae    800513 <sprintputch+0x1c>
		*b->buf++ = ch;
  800508:	0f b6 4d 08          	movzbl 0x8(%ebp),%ecx
  80050c:	88 08                	mov    %cl,(%eax)
  80050e:	83 c0 01             	add    $0x1,%eax
  800511:	89 02                	mov    %eax,(%edx)
}
  800513:	5d                   	pop    %ebp
  800514:	c3                   	ret    

00800515 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800515:	55                   	push   %ebp
  800516:	89 e5                	mov    %esp,%ebp
  800518:	57                   	push   %edi
  800519:	56                   	push   %esi
  80051a:	53                   	push   %ebx
  80051b:	83 ec 3c             	sub    $0x3c,%esp
  80051e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800521:	eb 18                	jmp    80053b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800523:	84 c0                	test   %al,%al
  800525:	0f 84 9f 03 00 00    	je     8008ca <vprintfmt+0x3b5>
				return;
			putch(ch, putdat);
  80052b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80052e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800532:	0f b6 c0             	movzbl %al,%eax
  800535:	89 04 24             	mov    %eax,(%esp)
  800538:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80053b:	0f b6 03             	movzbl (%ebx),%eax
  80053e:	83 c3 01             	add    $0x1,%ebx
  800541:	3c 25                	cmp    $0x25,%al
  800543:	75 de                	jne    800523 <vprintfmt+0xe>
  800545:	b9 00 00 00 00       	mov    $0x0,%ecx
  80054a:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
  800551:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800556:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80055d:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
  800561:	eb 07                	jmp    80056a <vprintfmt+0x55>
  800563:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	0f b6 13             	movzbl (%ebx),%edx
  80056d:	83 c3 01             	add    $0x1,%ebx
  800570:	8d 42 dd             	lea    -0x23(%edx),%eax
  800573:	3c 55                	cmp    $0x55,%al
  800575:	0f 87 22 03 00 00    	ja     80089d <vprintfmt+0x388>
  80057b:	0f b6 c0             	movzbl %al,%eax
  80057e:	ff 24 85 60 2c 80 00 	jmp    *0x802c60(,%eax,4)
  800585:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
  800589:	eb df                	jmp    80056a <vprintfmt+0x55>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80058b:	0f b6 c2             	movzbl %dl,%eax
  80058e:	8d 78 d0             	lea    -0x30(%eax),%edi
				ch = *fmt;
  800591:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800594:	8d 42 d0             	lea    -0x30(%edx),%eax
  800597:	83 f8 09             	cmp    $0x9,%eax
  80059a:	76 08                	jbe    8005a4 <vprintfmt+0x8f>
  80059c:	eb 39                	jmp    8005d7 <vprintfmt+0xc2>
  80059e:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
  8005a2:	eb c6                	jmp    80056a <vprintfmt+0x55>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005a4:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  8005a7:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  8005aa:	8d 7c 42 d0          	lea    -0x30(%edx,%eax,2),%edi
				ch = *fmt;
  8005ae:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  8005b1:	8d 42 d0             	lea    -0x30(%edx),%eax
  8005b4:	83 f8 09             	cmp    $0x9,%eax
  8005b7:	77 1e                	ja     8005d7 <vprintfmt+0xc2>
  8005b9:	eb e9                	jmp    8005a4 <vprintfmt+0x8f>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005bb:	8b 55 14             	mov    0x14(%ebp),%edx
  8005be:	8d 42 04             	lea    0x4(%edx),%eax
  8005c1:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c4:	8b 3a                	mov    (%edx),%edi
  8005c6:	eb 0f                	jmp    8005d7 <vprintfmt+0xc2>
			goto process_precision;

		case '.':
			if (width < 0)
  8005c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8005cc:	79 9c                	jns    80056a <vprintfmt+0x55>
  8005ce:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8005d5:	eb 93                	jmp    80056a <vprintfmt+0x55>
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8005db:	90                   	nop    
  8005dc:	8d 74 26 00          	lea    0x0(%esi),%esi
  8005e0:	79 88                	jns    80056a <vprintfmt+0x55>
  8005e2:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8005e5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8005ea:	e9 7b ff ff ff       	jmp    80056a <vprintfmt+0x55>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005ef:	83 c1 01             	add    $0x1,%ecx
  8005f2:	e9 73 ff ff ff       	jmp    80056a <vprintfmt+0x55>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8d 50 04             	lea    0x4(%eax),%edx
  8005fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800600:	8b 55 0c             	mov    0xc(%ebp),%edx
  800603:	89 54 24 04          	mov    %edx,0x4(%esp)
  800607:	8b 00                	mov    (%eax),%eax
  800609:	89 04 24             	mov    %eax,(%esp)
  80060c:	ff 55 08             	call   *0x8(%ebp)
  80060f:	e9 27 ff ff ff       	jmp    80053b <vprintfmt+0x26>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800614:	8b 55 14             	mov    0x14(%ebp),%edx
  800617:	8d 42 04             	lea    0x4(%edx),%eax
  80061a:	89 45 14             	mov    %eax,0x14(%ebp)
  80061d:	8b 02                	mov    (%edx),%eax
  80061f:	89 c2                	mov    %eax,%edx
  800621:	c1 fa 1f             	sar    $0x1f,%edx
  800624:	31 d0                	xor    %edx,%eax
  800626:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800628:	83 f8 0f             	cmp    $0xf,%eax
  80062b:	7f 0b                	jg     800638 <vprintfmt+0x123>
  80062d:	8b 14 85 c0 2d 80 00 	mov    0x802dc0(,%eax,4),%edx
  800634:	85 d2                	test   %edx,%edx
  800636:	75 23                	jne    80065b <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800638:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80063c:	c7 44 24 08 2b 2b 80 	movl   $0x802b2b,0x8(%esp)
  800643:	00 
  800644:	8b 45 0c             	mov    0xc(%ebp),%eax
  800647:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064b:	8b 55 08             	mov    0x8(%ebp),%edx
  80064e:	89 14 24             	mov    %edx,(%esp)
  800651:	e8 ff 02 00 00       	call   800955 <printfmt>
  800656:	e9 e0 fe ff ff       	jmp    80053b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80065b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80065f:	c7 44 24 08 4a 30 80 	movl   $0x80304a,0x8(%esp)
  800666:	00 
  800667:	8b 45 0c             	mov    0xc(%ebp),%eax
  80066a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066e:	8b 55 08             	mov    0x8(%ebp),%edx
  800671:	89 14 24             	mov    %edx,(%esp)
  800674:	e8 dc 02 00 00       	call   800955 <printfmt>
  800679:	e9 bd fe ff ff       	jmp    80053b <vprintfmt+0x26>
  80067e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800681:	89 f9                	mov    %edi,%ecx
  800683:	89 5d ec             	mov    %ebx,-0x14(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800686:	8b 55 14             	mov    0x14(%ebp),%edx
  800689:	8d 42 04             	lea    0x4(%edx),%eax
  80068c:	89 45 14             	mov    %eax,0x14(%ebp)
  80068f:	8b 12                	mov    (%edx),%edx
  800691:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800694:	85 d2                	test   %edx,%edx
  800696:	75 07                	jne    80069f <vprintfmt+0x18a>
  800698:	c7 45 dc 34 2b 80 00 	movl   $0x802b34,-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80069f:	85 f6                	test   %esi,%esi
  8006a1:	7e 41                	jle    8006e4 <vprintfmt+0x1cf>
  8006a3:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  8006a7:	74 3b                	je     8006e4 <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006b0:	89 04 24             	mov    %eax,(%esp)
  8006b3:	e8 e8 02 00 00       	call   8009a0 <strnlen>
  8006b8:	29 c6                	sub    %eax,%esi
  8006ba:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8006bd:	85 f6                	test   %esi,%esi
  8006bf:	7e 23                	jle    8006e4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006c1:	0f be 55 eb          	movsbl -0x15(%ebp),%edx
  8006c5:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8006c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006cf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006d2:	89 14 24             	mov    %edx,(%esp)
  8006d5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d8:	83 ee 01             	sub    $0x1,%esi
  8006db:	75 eb                	jne    8006c8 <vprintfmt+0x1b3>
  8006dd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006e4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006e7:	0f b6 02             	movzbl (%edx),%eax
  8006ea:	0f be d0             	movsbl %al,%edx
  8006ed:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006f0:	84 c0                	test   %al,%al
  8006f2:	75 42                	jne    800736 <vprintfmt+0x221>
  8006f4:	eb 49                	jmp    80073f <vprintfmt+0x22a>
				if (altflag && (ch < ' ' || ch > '~'))
  8006f6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006fa:	74 1b                	je     800717 <vprintfmt+0x202>
  8006fc:	8d 42 e0             	lea    -0x20(%edx),%eax
  8006ff:	83 f8 5e             	cmp    $0x5e,%eax
  800702:	76 13                	jbe    800717 <vprintfmt+0x202>
					putch('?', putdat);
  800704:	8b 45 0c             	mov    0xc(%ebp),%eax
  800707:	89 44 24 04          	mov    %eax,0x4(%esp)
  80070b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800712:	ff 55 08             	call   *0x8(%ebp)
  800715:	eb 0d                	jmp    800724 <vprintfmt+0x20f>
				else
					putch(ch, putdat);
  800717:	8b 45 0c             	mov    0xc(%ebp),%eax
  80071a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80071e:	89 14 24             	mov    %edx,(%esp)
  800721:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800724:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  800728:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80072c:	83 c6 01             	add    $0x1,%esi
  80072f:	84 c0                	test   %al,%al
  800731:	74 0c                	je     80073f <vprintfmt+0x22a>
  800733:	0f be d0             	movsbl %al,%edx
  800736:	85 ff                	test   %edi,%edi
  800738:	78 bc                	js     8006f6 <vprintfmt+0x1e1>
  80073a:	83 ef 01             	sub    $0x1,%edi
  80073d:	79 b7                	jns    8006f6 <vprintfmt+0x1e1>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80073f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800743:	0f 8e f2 fd ff ff    	jle    80053b <vprintfmt+0x26>
				putch(' ', putdat);
  800749:	8b 55 0c             	mov    0xc(%ebp),%edx
  80074c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800750:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800757:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80075a:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  80075e:	75 e9                	jne    800749 <vprintfmt+0x234>
  800760:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  800763:	e9 d3 fd ff ff       	jmp    80053b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800768:	83 f9 01             	cmp    $0x1,%ecx
  80076b:	90                   	nop    
  80076c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800770:	7e 10                	jle    800782 <vprintfmt+0x26d>
		return va_arg(*ap, long long);
  800772:	8b 55 14             	mov    0x14(%ebp),%edx
  800775:	8d 42 08             	lea    0x8(%edx),%eax
  800778:	89 45 14             	mov    %eax,0x14(%ebp)
  80077b:	8b 32                	mov    (%edx),%esi
  80077d:	8b 7a 04             	mov    0x4(%edx),%edi
  800780:	eb 2a                	jmp    8007ac <vprintfmt+0x297>
	else if (lflag)
  800782:	85 c9                	test   %ecx,%ecx
  800784:	74 14                	je     80079a <vprintfmt+0x285>
		return va_arg(*ap, long);
  800786:	8b 45 14             	mov    0x14(%ebp),%eax
  800789:	8d 50 04             	lea    0x4(%eax),%edx
  80078c:	89 55 14             	mov    %edx,0x14(%ebp)
  80078f:	8b 00                	mov    (%eax),%eax
  800791:	89 c6                	mov    %eax,%esi
  800793:	89 c7                	mov    %eax,%edi
  800795:	c1 ff 1f             	sar    $0x1f,%edi
  800798:	eb 12                	jmp    8007ac <vprintfmt+0x297>
	else
		return va_arg(*ap, int);
  80079a:	8b 45 14             	mov    0x14(%ebp),%eax
  80079d:	8d 50 04             	lea    0x4(%eax),%edx
  8007a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a3:	8b 00                	mov    (%eax),%eax
  8007a5:	89 c6                	mov    %eax,%esi
  8007a7:	89 c7                	mov    %eax,%edi
  8007a9:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007ac:	89 f2                	mov    %esi,%edx
  8007ae:	89 f9                	mov    %edi,%ecx
  8007b0:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
			if ((long long) num < 0) {
  8007b7:	85 ff                	test   %edi,%edi
  8007b9:	0f 89 9b 00 00 00    	jns    80085a <vprintfmt+0x345>
				putch('-', putdat);
  8007bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007cd:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007d0:	89 f2                	mov    %esi,%edx
  8007d2:	89 f9                	mov    %edi,%ecx
  8007d4:	f7 da                	neg    %edx
  8007d6:	83 d1 00             	adc    $0x0,%ecx
  8007d9:	f7 d9                	neg    %ecx
  8007db:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  8007e2:	eb 76                	jmp    80085a <vprintfmt+0x345>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007e4:	89 ca                	mov    %ecx,%edx
  8007e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e9:	e8 cd fc ff ff       	call   8004bb <getuint>
  8007ee:	89 d1                	mov    %edx,%ecx
  8007f0:	89 c2                	mov    %eax,%edx
  8007f2:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  8007f9:	eb 5f                	jmp    80085a <vprintfmt+0x345>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap,lflag);
  8007fb:	89 ca                	mov    %ecx,%edx
  8007fd:	8d 45 14             	lea    0x14(%ebp),%eax
  800800:	e8 b6 fc ff ff       	call   8004bb <getuint>
  800805:	e9 31 fd ff ff       	jmp    80053b <vprintfmt+0x26>
			base=8;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80080a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800811:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800818:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80081b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80081e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800822:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800829:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  80082c:	8b 55 14             	mov    0x14(%ebp),%edx
  80082f:	8d 42 04             	lea    0x4(%edx),%eax
  800832:	89 45 14             	mov    %eax,0x14(%ebp)
  800835:	8b 12                	mov    (%edx),%edx
  800837:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083c:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  800843:	eb 15                	jmp    80085a <vprintfmt+0x345>
			base = 16;
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800845:	89 ca                	mov    %ecx,%edx
  800847:	8d 45 14             	lea    0x14(%ebp),%eax
  80084a:	e8 6c fc ff ff       	call   8004bb <getuint>
  80084f:	89 d1                	mov    %edx,%ecx
  800851:	89 c2                	mov    %eax,%edx
  800853:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80085a:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  80085e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800862:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800865:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800869:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80086c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800870:	89 14 24             	mov    %edx,(%esp)
  800873:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800877:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087a:	8b 45 08             	mov    0x8(%ebp),%eax
  80087d:	e8 4e fb ff ff       	call   8003d0 <printnum>
  800882:	e9 b4 fc ff ff       	jmp    80053b <vprintfmt+0x26>
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800887:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80088e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800895:	ff 55 08             	call   *0x8(%ebp)
  800898:	e9 9e fc ff ff       	jmp    80053b <vprintfmt+0x26>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80089d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008ab:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008ae:	83 eb 01             	sub    $0x1,%ebx
  8008b1:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8008b5:	0f 84 80 fc ff ff    	je     80053b <vprintfmt+0x26>
  8008bb:	83 eb 01             	sub    $0x1,%ebx
  8008be:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8008c2:	0f 84 73 fc ff ff    	je     80053b <vprintfmt+0x26>
  8008c8:	eb f1                	jmp    8008bb <vprintfmt+0x3a6>
				/* do nothing */;
			break;
		}
	}
}
  8008ca:	83 c4 3c             	add    $0x3c,%esp
  8008cd:	5b                   	pop    %ebx
  8008ce:	5e                   	pop    %esi
  8008cf:	5f                   	pop    %edi
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	83 ec 28             	sub    $0x28,%esp
  8008d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8008db:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8008de:	85 d2                	test   %edx,%edx
  8008e0:	74 04                	je     8008e6 <vsnprintf+0x14>
  8008e2:	85 c0                	test   %eax,%eax
  8008e4:	7f 07                	jg     8008ed <vsnprintf+0x1b>
  8008e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008eb:	eb 3b                	jmp    800928 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ed:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008f4:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
  8008f8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  8008fb:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800901:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800905:	8b 45 10             	mov    0x10(%ebp),%eax
  800908:	89 44 24 08          	mov    %eax,0x8(%esp)
  80090c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80090f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800913:	c7 04 24 f7 04 80 00 	movl   $0x8004f7,(%esp)
  80091a:	e8 f6 fb ff ff       	call   800515 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80091f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800922:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800925:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800928:	c9                   	leave  
  800929:	c3                   	ret    

0080092a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800930:	8d 45 14             	lea    0x14(%ebp),%eax
  800933:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800936:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80093a:	8b 45 10             	mov    0x10(%ebp),%eax
  80093d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800941:	8b 45 0c             	mov    0xc(%ebp),%eax
  800944:	89 44 24 04          	mov    %eax,0x4(%esp)
  800948:	8b 45 08             	mov    0x8(%ebp),%eax
  80094b:	89 04 24             	mov    %eax,(%esp)
  80094e:	e8 7f ff ff ff       	call   8008d2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800953:	c9                   	leave  
  800954:	c3                   	ret    

00800955 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  80095b:	8d 45 14             	lea    0x14(%ebp),%eax
  80095e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800961:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800965:	8b 45 10             	mov    0x10(%ebp),%eax
  800968:	89 44 24 08          	mov    %eax,0x8(%esp)
  80096c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800973:	8b 45 08             	mov    0x8(%ebp),%eax
  800976:	89 04 24             	mov    %eax,(%esp)
  800979:	e8 97 fb ff ff       	call   800515 <vprintfmt>
	va_end(ap);
}
  80097e:	c9                   	leave  
  80097f:	c3                   	ret    

00800980 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800986:	b8 00 00 00 00       	mov    $0x0,%eax
  80098b:	80 3a 00             	cmpb   $0x0,(%edx)
  80098e:	74 0e                	je     80099e <strlen+0x1e>
  800990:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800995:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800998:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  80099c:	75 f7                	jne    800995 <strlen+0x15>
		n++;
	return n;
}
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a9:	85 d2                	test   %edx,%edx
  8009ab:	74 19                	je     8009c6 <strnlen+0x26>
  8009ad:	80 39 00             	cmpb   $0x0,(%ecx)
  8009b0:	74 14                	je     8009c6 <strnlen+0x26>
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009b7:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ba:	39 d0                	cmp    %edx,%eax
  8009bc:	74 0d                	je     8009cb <strnlen+0x2b>
  8009be:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  8009c2:	74 07                	je     8009cb <strnlen+0x2b>
  8009c4:	eb f1                	jmp    8009b7 <strnlen+0x17>
  8009c6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009cb:	5d                   	pop    %ebp
  8009cc:	8d 74 26 00          	lea    0x0(%esi),%esi
  8009d0:	c3                   	ret    

008009d1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	53                   	push   %ebx
  8009d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009db:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009dd:	0f b6 01             	movzbl (%ecx),%eax
  8009e0:	88 02                	mov    %al,(%edx)
  8009e2:	83 c2 01             	add    $0x1,%edx
  8009e5:	83 c1 01             	add    $0x1,%ecx
  8009e8:	84 c0                	test   %al,%al
  8009ea:	75 f1                	jne    8009dd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009ec:	89 d8                	mov    %ebx,%eax
  8009ee:	5b                   	pop    %ebx
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	57                   	push   %edi
  8009f5:	56                   	push   %esi
  8009f6:	53                   	push   %ebx
  8009f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009fd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a00:	85 f6                	test   %esi,%esi
  800a02:	74 1c                	je     800a20 <strncpy+0x2f>
  800a04:	89 fa                	mov    %edi,%edx
  800a06:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  800a0b:	0f b6 01             	movzbl (%ecx),%eax
  800a0e:	88 02                	mov    %al,(%edx)
  800a10:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a13:	80 39 01             	cmpb   $0x1,(%ecx)
  800a16:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a19:	83 c3 01             	add    $0x1,%ebx
  800a1c:	39 f3                	cmp    %esi,%ebx
  800a1e:	75 eb                	jne    800a0b <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a20:	89 f8                	mov    %edi,%eax
  800a22:	5b                   	pop    %ebx
  800a23:	5e                   	pop    %esi
  800a24:	5f                   	pop    %edi
  800a25:	5d                   	pop    %ebp
  800a26:	c3                   	ret    

00800a27 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	56                   	push   %esi
  800a2b:	53                   	push   %ebx
  800a2c:	8b 75 08             	mov    0x8(%ebp),%esi
  800a2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a32:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a35:	89 f0                	mov    %esi,%eax
  800a37:	85 d2                	test   %edx,%edx
  800a39:	74 2c                	je     800a67 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800a3b:	89 d3                	mov    %edx,%ebx
  800a3d:	83 eb 01             	sub    $0x1,%ebx
  800a40:	74 20                	je     800a62 <strlcpy+0x3b>
  800a42:	0f b6 11             	movzbl (%ecx),%edx
  800a45:	84 d2                	test   %dl,%dl
  800a47:	74 19                	je     800a62 <strlcpy+0x3b>
  800a49:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800a4b:	88 10                	mov    %dl,(%eax)
  800a4d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a50:	83 eb 01             	sub    $0x1,%ebx
  800a53:	74 0f                	je     800a64 <strlcpy+0x3d>
  800a55:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  800a59:	83 c1 01             	add    $0x1,%ecx
  800a5c:	84 d2                	test   %dl,%dl
  800a5e:	74 04                	je     800a64 <strlcpy+0x3d>
  800a60:	eb e9                	jmp    800a4b <strlcpy+0x24>
  800a62:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a64:	c6 00 00             	movb   $0x0,(%eax)
  800a67:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800a69:	5b                   	pop    %ebx
  800a6a:	5e                   	pop    %esi
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    

00800a6d <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	56                   	push   %esi
  800a71:	53                   	push   %ebx
  800a72:	8b 75 08             	mov    0x8(%ebp),%esi
  800a75:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a78:	8b 55 10             	mov    0x10(%ebp),%edx
    int c;
    char *q = buf;

    if (buf_size <= 0)
  800a7b:	85 c0                	test   %eax,%eax
  800a7d:	7e 2e                	jle    800aad <pstrcpy+0x40>
        return;

    for(;;) {
        c = *str++;
  800a7f:	0f b6 0a             	movzbl (%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  800a82:	84 c9                	test   %cl,%cl
  800a84:	74 22                	je     800aa8 <pstrcpy+0x3b>
  800a86:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  800a8a:	89 f0                	mov    %esi,%eax
  800a8c:	39 de                	cmp    %ebx,%esi
  800a8e:	72 09                	jb     800a99 <pstrcpy+0x2c>
  800a90:	eb 16                	jmp    800aa8 <pstrcpy+0x3b>
  800a92:	83 c2 01             	add    $0x1,%edx
  800a95:	39 d8                	cmp    %ebx,%eax
  800a97:	73 11                	jae    800aaa <pstrcpy+0x3d>
            break;
        *q++ = c;
  800a99:	88 08                	mov    %cl,(%eax)
  800a9b:	83 c0 01             	add    $0x1,%eax

    if (buf_size <= 0)
        return;

    for(;;) {
        c = *str++;
  800a9e:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  800aa2:	84 c9                	test   %cl,%cl
  800aa4:	75 ec                	jne    800a92 <pstrcpy+0x25>
  800aa6:	eb 02                	jmp    800aaa <pstrcpy+0x3d>
  800aa8:	89 f0                	mov    %esi,%eax
            break;
        *q++ = c;
    }
    *q = '\0';
  800aaa:	c6 00 00             	movb   $0x0,(%eax)
}
  800aad:	5b                   	pop    %ebx
  800aae:	5e                   	pop    %esi
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  800aba:	0f b6 02             	movzbl (%edx),%eax
  800abd:	84 c0                	test   %al,%al
  800abf:	74 16                	je     800ad7 <strcmp+0x26>
  800ac1:	3a 01                	cmp    (%ecx),%al
  800ac3:	75 12                	jne    800ad7 <strcmp+0x26>
		p++, q++;
  800ac5:	83 c1 01             	add    $0x1,%ecx
    *q = '\0';
}
int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ac8:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  800acc:	84 c0                	test   %al,%al
  800ace:	74 07                	je     800ad7 <strcmp+0x26>
  800ad0:	83 c2 01             	add    $0x1,%edx
  800ad3:	3a 01                	cmp    (%ecx),%al
  800ad5:	74 ee                	je     800ac5 <strcmp+0x14>
  800ad7:	0f b6 c0             	movzbl %al,%eax
  800ada:	0f b6 11             	movzbl (%ecx),%edx
  800add:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	53                   	push   %ebx
  800ae5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aeb:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800aee:	85 d2                	test   %edx,%edx
  800af0:	74 2d                	je     800b1f <strncmp+0x3e>
  800af2:	0f b6 01             	movzbl (%ecx),%eax
  800af5:	84 c0                	test   %al,%al
  800af7:	74 1a                	je     800b13 <strncmp+0x32>
  800af9:	3a 03                	cmp    (%ebx),%al
  800afb:	75 16                	jne    800b13 <strncmp+0x32>
  800afd:	83 ea 01             	sub    $0x1,%edx
  800b00:	74 1d                	je     800b1f <strncmp+0x3e>
		n--, p++, q++;
  800b02:	83 c1 01             	add    $0x1,%ecx
  800b05:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b08:	0f b6 01             	movzbl (%ecx),%eax
  800b0b:	84 c0                	test   %al,%al
  800b0d:	74 04                	je     800b13 <strncmp+0x32>
  800b0f:	3a 03                	cmp    (%ebx),%al
  800b11:	74 ea                	je     800afd <strncmp+0x1c>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b13:	0f b6 11             	movzbl (%ecx),%edx
  800b16:	0f b6 03             	movzbl (%ebx),%eax
  800b19:	29 c2                	sub    %eax,%edx
  800b1b:	89 d0                	mov    %edx,%eax
  800b1d:	eb 05                	jmp    800b24 <strncmp+0x43>
  800b1f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b24:	5b                   	pop    %ebx
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b31:	0f b6 10             	movzbl (%eax),%edx
  800b34:	84 d2                	test   %dl,%dl
  800b36:	74 14                	je     800b4c <strchr+0x25>
		if (*s == c)
  800b38:	38 ca                	cmp    %cl,%dl
  800b3a:	75 06                	jne    800b42 <strchr+0x1b>
  800b3c:	eb 13                	jmp    800b51 <strchr+0x2a>
  800b3e:	38 ca                	cmp    %cl,%dl
  800b40:	74 0f                	je     800b51 <strchr+0x2a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b42:	83 c0 01             	add    $0x1,%eax
  800b45:	0f b6 10             	movzbl (%eax),%edx
  800b48:	84 d2                	test   %dl,%dl
  800b4a:	75 f2                	jne    800b3e <strchr+0x17>
  800b4c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    

00800b53 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	8b 45 08             	mov    0x8(%ebp),%eax
  800b59:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b5d:	0f b6 10             	movzbl (%eax),%edx
  800b60:	84 d2                	test   %dl,%dl
  800b62:	74 18                	je     800b7c <strfind+0x29>
		if (*s == c)
  800b64:	38 ca                	cmp    %cl,%dl
  800b66:	75 0a                	jne    800b72 <strfind+0x1f>
  800b68:	eb 12                	jmp    800b7c <strfind+0x29>
  800b6a:	38 ca                	cmp    %cl,%dl
  800b6c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800b70:	74 0a                	je     800b7c <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b72:	83 c0 01             	add    $0x1,%eax
  800b75:	0f b6 10             	movzbl (%eax),%edx
  800b78:	84 d2                	test   %dl,%dl
  800b7a:	75 ee                	jne    800b6a <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	83 ec 08             	sub    $0x8,%esp
  800b84:	89 1c 24             	mov    %ebx,(%esp)
  800b87:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b8b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800b91:	85 db                	test   %ebx,%ebx
  800b93:	74 36                	je     800bcb <memset+0x4d>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b95:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b9b:	75 26                	jne    800bc3 <memset+0x45>
  800b9d:	f6 c3 03             	test   $0x3,%bl
  800ba0:	75 21                	jne    800bc3 <memset+0x45>
		c &= 0xFF;
  800ba2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ba6:	89 d0                	mov    %edx,%eax
  800ba8:	c1 e0 18             	shl    $0x18,%eax
  800bab:	89 d1                	mov    %edx,%ecx
  800bad:	c1 e1 10             	shl    $0x10,%ecx
  800bb0:	09 c8                	or     %ecx,%eax
  800bb2:	09 d0                	or     %edx,%eax
  800bb4:	c1 e2 08             	shl    $0x8,%edx
  800bb7:	09 d0                	or     %edx,%eax
  800bb9:	89 d9                	mov    %ebx,%ecx
  800bbb:	c1 e9 02             	shr    $0x2,%ecx
  800bbe:	fc                   	cld    
  800bbf:	f3 ab                	rep stos %eax,%es:(%edi)
  800bc1:	eb 08                	jmp    800bcb <memset+0x4d>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc6:	89 d9                	mov    %ebx,%ecx
  800bc8:	fc                   	cld    
  800bc9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bcb:	89 f8                	mov    %edi,%eax
  800bcd:	8b 1c 24             	mov    (%esp),%ebx
  800bd0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800bd4:	89 ec                	mov    %ebp,%esp
  800bd6:	5d                   	pop    %ebp
  800bd7:	c3                   	ret    

00800bd8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	83 ec 08             	sub    $0x8,%esp
  800bde:	89 34 24             	mov    %esi,(%esp)
  800be1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800be5:	8b 45 08             	mov    0x8(%ebp),%eax
  800be8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800beb:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800bee:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800bf0:	39 c6                	cmp    %eax,%esi
  800bf2:	73 38                	jae    800c2c <memmove+0x54>
  800bf4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bf7:	39 d0                	cmp    %edx,%eax
  800bf9:	73 31                	jae    800c2c <memmove+0x54>
		s += n;
		d += n;
  800bfb:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bfe:	f6 c2 03             	test   $0x3,%dl
  800c01:	75 1d                	jne    800c20 <memmove+0x48>
  800c03:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c09:	75 15                	jne    800c20 <memmove+0x48>
  800c0b:	f6 c1 03             	test   $0x3,%cl
  800c0e:	66 90                	xchg   %ax,%ax
  800c10:	75 0e                	jne    800c20 <memmove+0x48>
			asm volatile("std; rep movsl\n"
  800c12:	8d 7e fc             	lea    -0x4(%esi),%edi
  800c15:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c18:	c1 e9 02             	shr    $0x2,%ecx
  800c1b:	fd                   	std    
  800c1c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c1e:	eb 09                	jmp    800c29 <memmove+0x51>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c20:	8d 7e ff             	lea    -0x1(%esi),%edi
  800c23:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c26:	fd                   	std    
  800c27:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c29:	fc                   	cld    
  800c2a:	eb 21                	jmp    800c4d <memmove+0x75>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c2c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c32:	75 16                	jne    800c4a <memmove+0x72>
  800c34:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c3a:	75 0e                	jne    800c4a <memmove+0x72>
  800c3c:	f6 c1 03             	test   $0x3,%cl
  800c3f:	90                   	nop    
  800c40:	75 08                	jne    800c4a <memmove+0x72>
			asm volatile("cld; rep movsl\n"
  800c42:	c1 e9 02             	shr    $0x2,%ecx
  800c45:	fc                   	cld    
  800c46:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c48:	eb 03                	jmp    800c4d <memmove+0x75>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c4a:	fc                   	cld    
  800c4b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c4d:	8b 34 24             	mov    (%esp),%esi
  800c50:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c54:	89 ec                	mov    %ebp,%esp
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    

00800c58 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c5e:	8b 45 10             	mov    0x10(%ebp),%eax
  800c61:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c68:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6f:	89 04 24             	mov    %eax,(%esp)
  800c72:	e8 61 ff ff ff       	call   800bd8 <memmove>
}
  800c77:	c9                   	leave  
  800c78:	c3                   	ret    

00800c79 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	57                   	push   %edi
  800c7d:	56                   	push   %esi
  800c7e:	53                   	push   %ebx
  800c7f:	83 ec 04             	sub    $0x4,%esp
  800c82:	8b 45 08             	mov    0x8(%ebp),%eax
  800c85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c88:	8b 55 10             	mov    0x10(%ebp),%edx
  800c8b:	83 ea 01             	sub    $0x1,%edx
  800c8e:	83 fa ff             	cmp    $0xffffffff,%edx
  800c91:	74 47                	je     800cda <memcmp+0x61>
		if (*s1 != *s2)
  800c93:	0f b6 30             	movzbl (%eax),%esi
  800c96:	0f b6 39             	movzbl (%ecx),%edi
			return (int) *s1 - (int) *s2;
  800c99:	89 45 f0             	mov    %eax,-0x10(%ebp)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  800c9c:	89 f0                	mov    %esi,%eax
  800c9e:	89 fb                	mov    %edi,%ebx
  800ca0:	38 d8                	cmp    %bl,%al
  800ca2:	74 2e                	je     800cd2 <memcmp+0x59>
  800ca4:	eb 1c                	jmp    800cc2 <memcmp+0x49>
  800ca6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ca9:	0f b6 70 01          	movzbl 0x1(%eax),%esi
  800cad:	0f b6 79 01          	movzbl 0x1(%ecx),%edi
  800cb1:	83 c0 01             	add    $0x1,%eax
  800cb4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800cb7:	83 c1 01             	add    $0x1,%ecx
  800cba:	89 f3                	mov    %esi,%ebx
  800cbc:	89 f8                	mov    %edi,%eax
  800cbe:	38 c3                	cmp    %al,%bl
  800cc0:	74 10                	je     800cd2 <memcmp+0x59>
			return (int) *s1 - (int) *s2;
  800cc2:	89 f1                	mov    %esi,%ecx
  800cc4:	0f b6 d1             	movzbl %cl,%edx
  800cc7:	89 fb                	mov    %edi,%ebx
  800cc9:	0f b6 c3             	movzbl %bl,%eax
  800ccc:	29 c2                	sub    %eax,%edx
  800cce:	89 d0                	mov    %edx,%eax
  800cd0:	eb 0d                	jmp    800cdf <memcmp+0x66>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cd2:	83 ea 01             	sub    $0x1,%edx
  800cd5:	83 fa ff             	cmp    $0xffffffff,%edx
  800cd8:	75 cc                	jne    800ca6 <memcmp+0x2d>
  800cda:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800cdf:	83 c4 04             	add    $0x4,%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ced:	89 c1                	mov    %eax,%ecx
  800cef:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
  800cf2:	39 c8                	cmp    %ecx,%eax
  800cf4:	73 15                	jae    800d0b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cf6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
  800cfa:	38 10                	cmp    %dl,(%eax)
  800cfc:	75 06                	jne    800d04 <memfind+0x1d>
  800cfe:	eb 0b                	jmp    800d0b <memfind+0x24>
  800d00:	38 10                	cmp    %dl,(%eax)
  800d02:	74 07                	je     800d0b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d04:	83 c0 01             	add    $0x1,%eax
  800d07:	39 c8                	cmp    %ecx,%eax
  800d09:	75 f5                	jne    800d00 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d0b:	5d                   	pop    %ebp
  800d0c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800d10:	c3                   	ret    

00800d11 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	57                   	push   %edi
  800d15:	56                   	push   %esi
  800d16:	53                   	push   %ebx
  800d17:	83 ec 04             	sub    $0x4,%esp
  800d1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d1d:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d20:	0f b6 01             	movzbl (%ecx),%eax
  800d23:	3c 20                	cmp    $0x20,%al
  800d25:	74 04                	je     800d2b <strtol+0x1a>
  800d27:	3c 09                	cmp    $0x9,%al
  800d29:	75 0e                	jne    800d39 <strtol+0x28>
		s++;
  800d2b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d2e:	0f b6 01             	movzbl (%ecx),%eax
  800d31:	3c 20                	cmp    $0x20,%al
  800d33:	74 f6                	je     800d2b <strtol+0x1a>
  800d35:	3c 09                	cmp    $0x9,%al
  800d37:	74 f2                	je     800d2b <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d39:	3c 2b                	cmp    $0x2b,%al
  800d3b:	75 0c                	jne    800d49 <strtol+0x38>
		s++;
  800d3d:	83 c1 01             	add    $0x1,%ecx
  800d40:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d47:	eb 15                	jmp    800d5e <strtol+0x4d>
	else if (*s == '-')
  800d49:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d50:	3c 2d                	cmp    $0x2d,%al
  800d52:	75 0a                	jne    800d5e <strtol+0x4d>
		s++, neg = 1;
  800d54:	83 c1 01             	add    $0x1,%ecx
  800d57:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d5e:	85 f6                	test   %esi,%esi
  800d60:	0f 94 c0             	sete   %al
  800d63:	74 05                	je     800d6a <strtol+0x59>
  800d65:	83 fe 10             	cmp    $0x10,%esi
  800d68:	75 18                	jne    800d82 <strtol+0x71>
  800d6a:	80 39 30             	cmpb   $0x30,(%ecx)
  800d6d:	75 13                	jne    800d82 <strtol+0x71>
  800d6f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d73:	75 0d                	jne    800d82 <strtol+0x71>
		s += 2, base = 16;
  800d75:	83 c1 02             	add    $0x2,%ecx
  800d78:	be 10 00 00 00       	mov    $0x10,%esi
  800d7d:	8d 76 00             	lea    0x0(%esi),%esi
  800d80:	eb 1b                	jmp    800d9d <strtol+0x8c>
	else if (base == 0 && s[0] == '0')
  800d82:	85 f6                	test   %esi,%esi
  800d84:	75 0e                	jne    800d94 <strtol+0x83>
  800d86:	80 39 30             	cmpb   $0x30,(%ecx)
  800d89:	75 09                	jne    800d94 <strtol+0x83>
		s++, base = 8;
  800d8b:	83 c1 01             	add    $0x1,%ecx
  800d8e:	66 be 08 00          	mov    $0x8,%si
  800d92:	eb 09                	jmp    800d9d <strtol+0x8c>
	else if (base == 0)
  800d94:	84 c0                	test   %al,%al
  800d96:	74 05                	je     800d9d <strtol+0x8c>
  800d98:	be 0a 00 00 00       	mov    $0xa,%esi
  800d9d:	bf 00 00 00 00       	mov    $0x0,%edi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800da2:	0f b6 11             	movzbl (%ecx),%edx
  800da5:	89 d3                	mov    %edx,%ebx
  800da7:	8d 42 d0             	lea    -0x30(%edx),%eax
  800daa:	3c 09                	cmp    $0x9,%al
  800dac:	77 08                	ja     800db6 <strtol+0xa5>
			dig = *s - '0';
  800dae:	0f be c2             	movsbl %dl,%eax
  800db1:	8d 50 d0             	lea    -0x30(%eax),%edx
  800db4:	eb 1c                	jmp    800dd2 <strtol+0xc1>
		else if (*s >= 'a' && *s <= 'z')
  800db6:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800db9:	3c 19                	cmp    $0x19,%al
  800dbb:	77 08                	ja     800dc5 <strtol+0xb4>
			dig = *s - 'a' + 10;
  800dbd:	0f be c2             	movsbl %dl,%eax
  800dc0:	8d 50 a9             	lea    -0x57(%eax),%edx
  800dc3:	eb 0d                	jmp    800dd2 <strtol+0xc1>
		else if (*s >= 'A' && *s <= 'Z')
  800dc5:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800dc8:	3c 19                	cmp    $0x19,%al
  800dca:	77 17                	ja     800de3 <strtol+0xd2>
			dig = *s - 'A' + 10;
  800dcc:	0f be c2             	movsbl %dl,%eax
  800dcf:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800dd2:	39 f2                	cmp    %esi,%edx
  800dd4:	7d 0d                	jge    800de3 <strtol+0xd2>
			break;
		s++, val = (val * base) + dig;
  800dd6:	83 c1 01             	add    $0x1,%ecx
  800dd9:	89 f8                	mov    %edi,%eax
  800ddb:	0f af c6             	imul   %esi,%eax
  800dde:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800de1:	eb bf                	jmp    800da2 <strtol+0x91>
		// we don't properly detect overflow!
	}
  800de3:	89 f8                	mov    %edi,%eax

	if (endptr)
  800de5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800de9:	74 05                	je     800df0 <strtol+0xdf>
		*endptr = (char *) s;
  800deb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dee:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800df0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800df4:	74 04                	je     800dfa <strtol+0xe9>
  800df6:	89 c7                	mov    %eax,%edi
  800df8:	f7 df                	neg    %edi
}
  800dfa:	89 f8                	mov    %edi,%eax
  800dfc:	83 c4 04             	add    $0x4,%esp
  800dff:	5b                   	pop    %ebx
  800e00:	5e                   	pop    %esi
  800e01:	5f                   	pop    %edi
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	83 ec 0c             	sub    $0xc,%esp
  800e0a:	89 1c 24             	mov    %ebx,(%esp)
  800e0d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e11:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e15:	b8 01 00 00 00       	mov    $0x1,%eax
  800e1a:	bf 00 00 00 00       	mov    $0x0,%edi
  800e1f:	89 fa                	mov    %edi,%edx
  800e21:	89 f9                	mov    %edi,%ecx
  800e23:	89 fb                	mov    %edi,%ebx
  800e25:	89 fe                	mov    %edi,%esi
  800e27:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e29:	8b 1c 24             	mov    (%esp),%ebx
  800e2c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e30:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e34:	89 ec                	mov    %ebp,%esp
  800e36:	5d                   	pop    %ebp
  800e37:	c3                   	ret    

00800e38 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e38:	55                   	push   %ebp
  800e39:	89 e5                	mov    %esp,%ebp
  800e3b:	83 ec 0c             	sub    $0xc,%esp
  800e3e:	89 1c 24             	mov    %ebx,(%esp)
  800e41:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e45:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e49:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4f:	bf 00 00 00 00       	mov    $0x0,%edi
  800e54:	89 f8                	mov    %edi,%eax
  800e56:	89 fb                	mov    %edi,%ebx
  800e58:	89 fe                	mov    %edi,%esi
  800e5a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e5c:	8b 1c 24             	mov    (%esp),%ebx
  800e5f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e63:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e67:	89 ec                	mov    %ebp,%esp
  800e69:	5d                   	pop    %ebp
  800e6a:	c3                   	ret    

00800e6b <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	83 ec 0c             	sub    $0xc,%esp
  800e71:	89 1c 24             	mov    %ebx,(%esp)
  800e74:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e78:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e81:	bf 00 00 00 00       	mov    $0x0,%edi
  800e86:	89 fa                	mov    %edi,%edx
  800e88:	89 f9                	mov    %edi,%ecx
  800e8a:	89 fb                	mov    %edi,%ebx
  800e8c:	89 fe                	mov    %edi,%esi
  800e8e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e90:	8b 1c 24             	mov    (%esp),%ebx
  800e93:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e97:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e9b:	89 ec                	mov    %ebp,%esp
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    

00800e9f <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	83 ec 28             	sub    $0x28,%esp
  800ea5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ea8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eab:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800eae:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eb6:	bf 00 00 00 00       	mov    $0x0,%edi
  800ebb:	89 f9                	mov    %edi,%ecx
  800ebd:	89 fb                	mov    %edi,%ebx
  800ebf:	89 fe                	mov    %edi,%esi
  800ec1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800ec3:	85 c0                	test   %eax,%eax
  800ec5:	7e 28                	jle    800eef <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ecb:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ed2:	00 
  800ed3:	c7 44 24 08 1f 2e 80 	movl   $0x802e1f,0x8(%esp)
  800eda:	00 
  800edb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee2:	00 
  800ee3:	c7 04 24 3c 2e 80 00 	movl   $0x802e3c,(%esp)
  800eea:	e8 ad f3 ff ff       	call   80029c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eef:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ef2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ef5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ef8:	89 ec                	mov    %ebp,%esp
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    

00800efc <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	83 ec 0c             	sub    $0xc,%esp
  800f02:	89 1c 24             	mov    %ebx,(%esp)
  800f05:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f09:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f13:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f16:	8b 7d 14             	mov    0x14(%ebp),%edi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f19:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f1e:	be 00 00 00 00       	mov    $0x0,%esi
  800f23:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f25:	8b 1c 24             	mov    (%esp),%ebx
  800f28:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f2c:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f30:	89 ec                	mov    %ebp,%esp
  800f32:	5d                   	pop    %ebp
  800f33:	c3                   	ret    

00800f34 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	83 ec 28             	sub    $0x28,%esp
  800f3a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f3d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f40:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f43:	8b 55 08             	mov    0x8(%ebp),%edx
  800f46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f49:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f4e:	bf 00 00 00 00       	mov    $0x0,%edi
  800f53:	89 fb                	mov    %edi,%ebx
  800f55:	89 fe                	mov    %edi,%esi
  800f57:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f59:	85 c0                	test   %eax,%eax
  800f5b:	7e 28                	jle    800f85 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f61:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f68:	00 
  800f69:	c7 44 24 08 1f 2e 80 	movl   $0x802e1f,0x8(%esp)
  800f70:	00 
  800f71:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f78:	00 
  800f79:	c7 04 24 3c 2e 80 00 	movl   $0x802e3c,(%esp)
  800f80:	e8 17 f3 ff ff       	call   80029c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f85:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f88:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f8b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f8e:	89 ec                	mov    %ebp,%esp
  800f90:	5d                   	pop    %ebp
  800f91:	c3                   	ret    

00800f92 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f92:	55                   	push   %ebp
  800f93:	89 e5                	mov    %esp,%ebp
  800f95:	83 ec 28             	sub    $0x28,%esp
  800f98:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f9b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f9e:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800fa1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa7:	b8 09 00 00 00       	mov    $0x9,%eax
  800fac:	bf 00 00 00 00       	mov    $0x0,%edi
  800fb1:	89 fb                	mov    %edi,%ebx
  800fb3:	89 fe                	mov    %edi,%esi
  800fb5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800fb7:	85 c0                	test   %eax,%eax
  800fb9:	7e 28                	jle    800fe3 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fbb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fbf:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800fc6:	00 
  800fc7:	c7 44 24 08 1f 2e 80 	movl   $0x802e1f,0x8(%esp)
  800fce:	00 
  800fcf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fd6:	00 
  800fd7:	c7 04 24 3c 2e 80 00 	movl   $0x802e3c,(%esp)
  800fde:	e8 b9 f2 ff ff       	call   80029c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fe3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fe6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fe9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fec:	89 ec                	mov    %ebp,%esp
  800fee:	5d                   	pop    %ebp
  800fef:	c3                   	ret    

00800ff0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	83 ec 28             	sub    $0x28,%esp
  800ff6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ff9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ffc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800fff:	8b 55 08             	mov    0x8(%ebp),%edx
  801002:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801005:	b8 08 00 00 00       	mov    $0x8,%eax
  80100a:	bf 00 00 00 00       	mov    $0x0,%edi
  80100f:	89 fb                	mov    %edi,%ebx
  801011:	89 fe                	mov    %edi,%esi
  801013:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801015:	85 c0                	test   %eax,%eax
  801017:	7e 28                	jle    801041 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801019:	89 44 24 10          	mov    %eax,0x10(%esp)
  80101d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801024:	00 
  801025:	c7 44 24 08 1f 2e 80 	movl   $0x802e1f,0x8(%esp)
  80102c:	00 
  80102d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801034:	00 
  801035:	c7 04 24 3c 2e 80 00 	movl   $0x802e3c,(%esp)
  80103c:	e8 5b f2 ff ff       	call   80029c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801041:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801044:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801047:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80104a:	89 ec                	mov    %ebp,%esp
  80104c:	5d                   	pop    %ebp
  80104d:	c3                   	ret    

0080104e <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	83 ec 28             	sub    $0x28,%esp
  801054:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801057:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80105a:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80105d:	8b 55 08             	mov    0x8(%ebp),%edx
  801060:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801063:	b8 06 00 00 00       	mov    $0x6,%eax
  801068:	bf 00 00 00 00       	mov    $0x0,%edi
  80106d:	89 fb                	mov    %edi,%ebx
  80106f:	89 fe                	mov    %edi,%esi
  801071:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801073:	85 c0                	test   %eax,%eax
  801075:	7e 28                	jle    80109f <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801077:	89 44 24 10          	mov    %eax,0x10(%esp)
  80107b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801082:	00 
  801083:	c7 44 24 08 1f 2e 80 	movl   $0x802e1f,0x8(%esp)
  80108a:	00 
  80108b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801092:	00 
  801093:	c7 04 24 3c 2e 80 00 	movl   $0x802e3c,(%esp)
  80109a:	e8 fd f1 ff ff       	call   80029c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80109f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010a2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010a5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010a8:	89 ec                	mov    %ebp,%esp
  8010aa:	5d                   	pop    %ebp
  8010ab:	c3                   	ret    

008010ac <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
  8010af:	83 ec 28             	sub    $0x28,%esp
  8010b2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010b5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010b8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8010bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8010be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010c4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010c7:	8b 75 18             	mov    0x18(%ebp),%esi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ca:	b8 05 00 00 00       	mov    $0x5,%eax
  8010cf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8010d1:	85 c0                	test   %eax,%eax
  8010d3:	7e 28                	jle    8010fd <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010d5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010d9:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8010e0:	00 
  8010e1:	c7 44 24 08 1f 2e 80 	movl   $0x802e1f,0x8(%esp)
  8010e8:	00 
  8010e9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010f0:	00 
  8010f1:	c7 04 24 3c 2e 80 00 	movl   $0x802e3c,(%esp)
  8010f8:	e8 9f f1 ff ff       	call   80029c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010fd:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801100:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801103:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801106:	89 ec                	mov    %ebp,%esp
  801108:	5d                   	pop    %ebp
  801109:	c3                   	ret    

0080110a <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80110a:	55                   	push   %ebp
  80110b:	89 e5                	mov    %esp,%ebp
  80110d:	83 ec 28             	sub    $0x28,%esp
  801110:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801113:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801116:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801119:	8b 55 08             	mov    0x8(%ebp),%edx
  80111c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80111f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801122:	b8 04 00 00 00       	mov    $0x4,%eax
  801127:	bf 00 00 00 00       	mov    $0x0,%edi
  80112c:	89 fe                	mov    %edi,%esi
  80112e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801130:	85 c0                	test   %eax,%eax
  801132:	7e 28                	jle    80115c <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  801134:	89 44 24 10          	mov    %eax,0x10(%esp)
  801138:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80113f:	00 
  801140:	c7 44 24 08 1f 2e 80 	movl   $0x802e1f,0x8(%esp)
  801147:	00 
  801148:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80114f:	00 
  801150:	c7 04 24 3c 2e 80 00 	movl   $0x802e3c,(%esp)
  801157:	e8 40 f1 ff ff       	call   80029c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80115c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80115f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801162:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801165:	89 ec                	mov    %ebp,%esp
  801167:	5d                   	pop    %ebp
  801168:	c3                   	ret    

00801169 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  801169:	55                   	push   %ebp
  80116a:	89 e5                	mov    %esp,%ebp
  80116c:	83 ec 0c             	sub    $0xc,%esp
  80116f:	89 1c 24             	mov    %ebx,(%esp)
  801172:	89 74 24 04          	mov    %esi,0x4(%esp)
  801176:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80117a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80117f:	bf 00 00 00 00       	mov    $0x0,%edi
  801184:	89 fa                	mov    %edi,%edx
  801186:	89 f9                	mov    %edi,%ecx
  801188:	89 fb                	mov    %edi,%ebx
  80118a:	89 fe                	mov    %edi,%esi
  80118c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80118e:	8b 1c 24             	mov    (%esp),%ebx
  801191:	8b 74 24 04          	mov    0x4(%esp),%esi
  801195:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801199:	89 ec                	mov    %ebp,%esp
  80119b:	5d                   	pop    %ebp
  80119c:	c3                   	ret    

0080119d <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	83 ec 0c             	sub    $0xc,%esp
  8011a3:	89 1c 24             	mov    %ebx,(%esp)
  8011a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011aa:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ae:	b8 02 00 00 00       	mov    $0x2,%eax
  8011b3:	bf 00 00 00 00       	mov    $0x0,%edi
  8011b8:	89 fa                	mov    %edi,%edx
  8011ba:	89 f9                	mov    %edi,%ecx
  8011bc:	89 fb                	mov    %edi,%ebx
  8011be:	89 fe                	mov    %edi,%esi
  8011c0:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8011c2:	8b 1c 24             	mov    (%esp),%ebx
  8011c5:	8b 74 24 04          	mov    0x4(%esp),%esi
  8011c9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8011cd:	89 ec                	mov    %ebp,%esp
  8011cf:	5d                   	pop    %ebp
  8011d0:	c3                   	ret    

008011d1 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
  8011d4:	83 ec 28             	sub    $0x28,%esp
  8011d7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011da:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011dd:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8011e0:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e3:	b8 03 00 00 00       	mov    $0x3,%eax
  8011e8:	bf 00 00 00 00       	mov    $0x0,%edi
  8011ed:	89 f9                	mov    %edi,%ecx
  8011ef:	89 fb                	mov    %edi,%ebx
  8011f1:	89 fe                	mov    %edi,%esi
  8011f3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8011f5:	85 c0                	test   %eax,%eax
  8011f7:	7e 28                	jle    801221 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011f9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011fd:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801204:	00 
  801205:	c7 44 24 08 1f 2e 80 	movl   $0x802e1f,0x8(%esp)
  80120c:	00 
  80120d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801214:	00 
  801215:	c7 04 24 3c 2e 80 00 	movl   $0x802e3c,(%esp)
  80121c:	e8 7b f0 ff ff       	call   80029c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801221:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801224:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801227:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80122a:	89 ec                	mov    %ebp,%esp
  80122c:	5d                   	pop    %ebp
  80122d:	c3                   	ret    
	...

00801230 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
// 
static int
duppage(envid_t envid, unsigned pn)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	53                   	push   %ebx
  801234:	83 ec 14             	sub    $0x14,%esp
  801237:	89 c1                	mov    %eax,%ecx
	int r;

	// LAB 4: Your code here.
	pde_t *pde;
	pte_t *pte;
	void *addr=(void*)(pn*PGSIZE);
  801239:	89 d3                	mov    %edx,%ebx
  80123b:	c1 e3 0c             	shl    $0xc,%ebx
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
  80123e:	89 d8                	mov    %ebx,%eax
  801240:	c1 e8 16             	shr    $0x16,%eax
  801243:	f6 04 85 00 d0 7b ef 	testb  $0x1,-0x10843000(,%eax,4)
  80124a:	01 
  80124b:	74 14                	je     801261 <duppage+0x31>
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else    panic("page table for pn page is not exist");
	if((*pte&PTE_W)||(*pte&PTE_COW))
  80124d:	89 d8                	mov    %ebx,%eax
  80124f:	c1 e8 0c             	shr    $0xc,%eax
  801252:	f7 04 85 00 00 40 ef 	testl  $0x802,-0x10c00000(,%eax,4)
  801259:	02 08 00 00 
  80125d:	75 1e                	jne    80127d <duppage+0x4d>
  80125f:	eb 73                	jmp    8012d4 <duppage+0xa4>
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else    panic("page table for pn page is not exist");
  801261:	c7 44 24 08 4c 2e 80 	movl   $0x802e4c,0x8(%esp)
  801268:	00 
  801269:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
  801270:	00 
  801271:	c7 04 24 0a 2f 80 00 	movl   $0x802f0a,(%esp)
  801278:	e8 1f f0 ff ff       	call   80029c <_panic>
	if((*pte&PTE_W)||(*pte&PTE_COW))
	{
		if((r=sys_page_map(0,addr,envid,addr,PTE_COW|PTE_U))<0)
  80127d:	c7 44 24 10 04 08 00 	movl   $0x804,0x10(%esp)
  801284:	00 
  801285:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801289:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80128d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801291:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801298:	e8 0f fe ff ff       	call   8010ac <sys_page_map>
  80129d:	85 c0                	test   %eax,%eax
  80129f:	78 60                	js     801301 <duppage+0xd1>
			return r;
		if((r=sys_page_map(0,addr,0,addr,PTE_COW|PTE_U))<0)//映射的时候注意env的id
  8012a1:	c7 44 24 10 04 08 00 	movl   $0x804,0x10(%esp)
  8012a8:	00 
  8012a9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012ad:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012b4:	00 
  8012b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012c0:	e8 e7 fd ff ff       	call   8010ac <sys_page_map>
  8012c5:	85 c0                	test   %eax,%eax
  8012c7:	0f 9f c2             	setg   %dl
  8012ca:	0f b6 d2             	movzbl %dl,%edx
  8012cd:	83 ea 01             	sub    $0x1,%edx
  8012d0:	21 d0                	and    %edx,%eax
  8012d2:	eb 2d                	jmp    801301 <duppage+0xd1>
                        return r;
	}
	else{	
		if((r=sys_page_map(0,addr,envid,addr,PTE_U|PTE_P))<0)
  8012d4:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8012db:	00 
  8012dc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012e0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012ef:	e8 b8 fd ff ff       	call   8010ac <sys_page_map>
  8012f4:	85 c0                	test   %eax,%eax
  8012f6:	0f 9f c2             	setg   %dl
  8012f9:	0f b6 d2             	movzbl %dl,%edx
  8012fc:	83 ea 01             	sub    $0x1,%edx
  8012ff:	21 d0                	and    %edx,%eax
			return r;
	}
	//panic("duppage not implemented");
	return 0;
}
  801301:	83 c4 14             	add    $0x14,%esp
  801304:	5b                   	pop    %ebx
  801305:	5d                   	pop    %ebp
  801306:	c3                   	ret    

00801307 <sfork>:
	return 0;
}
// Challenge!
int
sfork(void)
{
  801307:	55                   	push   %ebp
  801308:	89 e5                	mov    %esp,%ebp
  80130a:	57                   	push   %edi
  80130b:	56                   	push   %esi
  80130c:	53                   	push   %ebx
  80130d:	83 ec 1c             	sub    $0x1c,%esp
static __inline envid_t sys_exofork(void) __attribute__((always_inline));
static __inline envid_t
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801310:	ba 07 00 00 00       	mov    $0x7,%edx
  801315:	89 d0                	mov    %edx,%eax
  801317:	cd 30                	int    $0x30
  801319:	89 45 f0             	mov    %eax,-0x10(%ebp)
	pte_t *pte;
	unsigned i;
	uint32_t addr;
	envid_t envid;
	envid = sys_exofork();//创建子环境
	if(envid < 0)
  80131c:	85 c0                	test   %eax,%eax
  80131e:	79 20                	jns    801340 <sfork+0x39>
		panic("sys_exofork: %e", envid);
  801320:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801324:	c7 44 24 08 15 2f 80 	movl   $0x802f15,0x8(%esp)
  80132b:	00 
  80132c:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  801333:	00 
  801334:	c7 04 24 0a 2f 80 00 	movl   $0x802f0a,(%esp)
  80133b:	e8 5c ef ff ff       	call   80029c <_panic>
	if(envid==0)//子环境中
  801340:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801344:	75 21                	jne    801367 <sfork+0x60>
	{
		env = &envs[ENVX(sys_getenvid())];
  801346:	e8 52 fe ff ff       	call   80119d <sys_getenvid>
  80134b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801350:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801353:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801358:	a3 40 70 80 00       	mov    %eax,0x807040
  80135d:	b8 00 00 00 00       	mov    $0x0,%eax
  801362:	e9 83 01 00 00       	jmp    8014ea <sfork+0x1e3>
		return 0;
	}
	else{//父环境中,注意：这里需要设置父环境的缺页异常栈，还需要设置子环境的缺页异常栈，
	//父子环境的页异常栈不共享？具体原因还得思考
		env = &envs[ENVX(sys_getenvid())];
  801367:	e8 31 fe ff ff       	call   80119d <sys_getenvid>
  80136c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801371:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801374:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801379:	a3 40 70 80 00       	mov    %eax,0x807040
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
  80137e:	c7 04 24 f2 14 80 00 	movl   $0x8014f2,(%esp)
  801385:	e8 42 13 00 00       	call   8026cc <set_pgfault_handler>
  80138a:	be 00 00 00 00       	mov    $0x0,%esi
  80138f:	bf 00 00 00 00       	mov    $0x0,%edi
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
		{
			addr=i*PGSIZE;
			pde =(pde_t*) &vpd[VPD(addr)];
  801394:	89 f8                	mov    %edi,%eax
  801396:	c1 e8 16             	shr    $0x16,%eax
  801399:	c1 e0 02             	shl    $0x2,%eax
			if(*pde&PTE_P)//这里只处理有物理页面映射的页表项
  80139c:	f6 80 00 d0 7b ef 01 	testb  $0x1,-0x10843000(%eax)
  8013a3:	0f 84 dc 00 00 00    	je     801485 <sfork+0x17e>
			{
				pte=(pte_t*)&vpt[VPN(addr)];
			}
			else    continue;
			if((i==(unsigned)VPN(USTACKTOP-PGSIZE))||(i==(unsigned)VPN(PFTEMP)))
  8013a9:	81 fe fd eb 0e 00    	cmp    $0xeebfd,%esi
  8013af:	74 08                	je     8013b9 <sfork+0xb2>
  8013b1:	81 fe ff 07 00 00    	cmp    $0x7ff,%esi
  8013b7:	75 17                	jne    8013d0 <sfork+0xc9>
								//特殊处理，用户层普通栈
			{	
				if((r=duppage(envid,i))<0)
  8013b9:	89 f2                	mov    %esi,%edx
  8013bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013be:	e8 6d fe ff ff       	call   801230 <duppage>
  8013c3:	85 c0                	test   %eax,%eax
  8013c5:	0f 89 ba 00 00 00    	jns    801485 <sfork+0x17e>
  8013cb:	e9 1a 01 00 00       	jmp    8014ea <sfork+0x1e3>
	// LAB 4: Your code here.
	pde_t *pde;
	pte_t *pte;
	void *addr=(void*)(pn*PGSIZE);
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
  8013d0:	f6 80 00 d0 7b ef 01 	testb  $0x1,-0x10843000(%eax)
  8013d7:	74 11                	je     8013ea <sfork+0xe3>
	{
		pte=(pte_t*)&vpt[VPN(addr)];
  8013d9:	89 f8                	mov    %edi,%eax
  8013db:	c1 e8 0c             	shr    $0xc,%eax
	}
	else    panic("page table for pn page is not exist");
	if(*pte&PTE_W)
  8013de:	f6 04 85 00 00 40 ef 	testb  $0x2,-0x10c00000(,%eax,4)
  8013e5:	02 
  8013e6:	75 1e                	jne    801406 <sfork+0xff>
  8013e8:	eb 74                	jmp    80145e <sfork+0x157>
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else    panic("page table for pn page is not exist");
  8013ea:	c7 44 24 08 4c 2e 80 	movl   $0x802e4c,0x8(%esp)
  8013f1:	00 
  8013f2:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
  8013f9:	00 
  8013fa:	c7 04 24 0a 2f 80 00 	movl   $0x802f0a,(%esp)
  801401:	e8 96 ee ff ff       	call   80029c <_panic>
	if(*pte&PTE_W)
	{
		//cprintf("sduppage:addr=%x\n",addr);
		if((r=sys_page_map(0,addr,envid,addr,PTE_W|PTE_U))<0)
  801406:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
  80140d:	00 
  80140e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801412:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801415:	89 44 24 08          	mov    %eax,0x8(%esp)
  801419:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80141d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801424:	e8 83 fc ff ff       	call   8010ac <sys_page_map>
  801429:	85 c0                	test   %eax,%eax
  80142b:	0f 88 b9 00 00 00    	js     8014ea <sfork+0x1e3>
			return r;
		if((r=sys_page_map(0,addr,0,addr,PTE_W|PTE_U))<0)//映射的时候注意env的id
  801431:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
  801438:	00 
  801439:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80143d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801444:	00 
  801445:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801449:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801450:	e8 57 fc ff ff       	call   8010ac <sys_page_map>
  801455:	85 c0                	test   %eax,%eax
  801457:	79 2c                	jns    801485 <sfork+0x17e>
  801459:	e9 8c 00 00 00       	jmp    8014ea <sfork+0x1e3>
                        return r;
	}
	else{	
		if((r=sys_page_map(0,addr,envid,addr,PTE_U|PTE_P))<0)
  80145e:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801465:	00 
  801466:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80146a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801471:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801475:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80147c:	e8 2b fc ff ff       	call   8010ac <sys_page_map>
  801481:	85 c0                	test   %eax,%eax
  801483:	78 65                	js     8014ea <sfork+0x1e3>
	}
	else{//父环境中,注意：这里需要设置父环境的缺页异常栈，还需要设置子环境的缺页异常栈，
	//父子环境的页异常栈不共享？具体原因还得思考
		env = &envs[ENVX(sys_getenvid())];
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
  801485:	83 c6 01             	add    $0x1,%esi
  801488:	81 c7 00 10 00 00    	add    $0x1000,%edi
  80148e:	81 fe 00 ec 0e 00    	cmp    $0xeec00,%esi
  801494:	0f 85 fa fe ff ff    	jne    801394 <sfork+0x8d>
				continue;
			}
			if((r=sduppage(envid,i))<0)
				return r;
		}
		if((r=sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  80149a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8014a1:	00 
  8014a2:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8014a9:	ee 
  8014aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ad:	89 04 24             	mov    %eax,(%esp)
  8014b0:	e8 55 fc ff ff       	call   80110a <sys_page_alloc>
  8014b5:	85 c0                	test   %eax,%eax
  8014b7:	78 31                	js     8014ea <sfork+0x1e3>
                        return r;//设置子环境的缺页异常栈
		if((r=sys_env_set_pgfault_upcall(envid,(void*)_pgfault_upcall))<0)
  8014b9:	c7 44 24 04 50 27 80 	movl   $0x802750,0x4(%esp)
  8014c0:	00 
  8014c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c4:	89 04 24             	mov    %eax,(%esp)
  8014c7:	e8 68 fa ff ff       	call   800f34 <sys_env_set_pgfault_upcall>
  8014cc:	85 c0                	test   %eax,%eax
  8014ce:	78 1a                	js     8014ea <sfork+0x1e3>
			return r;//设置子环境的缺页异常处理入口点
		if((r=sys_env_set_status(envid,ENV_RUNNABLE))<0)
  8014d0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8014d7:	00 
  8014d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014db:	89 04 24             	mov    %eax,(%esp)
  8014de:	e8 0d fb ff ff       	call   800ff0 <sys_env_set_status>
  8014e3:	85 c0                	test   %eax,%eax
  8014e5:	78 03                	js     8014ea <sfork+0x1e3>
  8014e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
			return r;//设置子环境的状态为可运行
		return envid;
	}
	//panic("sfork not implemented");
	//return -E_INVAL;
}
  8014ea:	83 c4 1c             	add    $0x1c,%esp
  8014ed:	5b                   	pop    %ebx
  8014ee:	5e                   	pop    %esi
  8014ef:	5f                   	pop    %edi
  8014f0:	5d                   	pop    %ebp
  8014f1:	c3                   	ret    

008014f2 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8014f2:	55                   	push   %ebp
  8014f3:	89 e5                	mov    %esp,%ebp
  8014f5:	56                   	push   %esi
  8014f6:	53                   	push   %ebx
  8014f7:	83 ec 20             	sub    $0x20,%esp
  8014fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
  8014fd:	8b 71 04             	mov    0x4(%ecx),%esi

	// LAB 4: Your code here.
	pde_t *pde;
	pte_t *pte;
	uint32_t *va,*srcva,*dstva;
	pde =(pde_t*) &vpd[VPD(addr)];
  801500:	8b 19                	mov    (%ecx),%ebx
  801502:	89 d8                	mov    %ebx,%eax
  801504:	c1 e8 16             	shr    $0x16,%eax
  801507:	c1 e0 02             	shl    $0x2,%eax
  80150a:	8d 90 00 d0 7b ef    	lea    -0x10843000(%eax),%edx
	if(*pde&PTE_P)
  801510:	f6 80 00 d0 7b ef 01 	testb  $0x1,-0x10843000(%eax)
  801517:	74 16                	je     80152f <pgfault+0x3d>
	{
		pte=(pte_t*)&vpt[VPN(addr)];
  801519:	89 d8                	mov    %ebx,%eax
  80151b:	c1 e8 0c             	shr    $0xc,%eax
  80151e:	8d 04 85 00 00 40 ef 	lea    -0x10c00000(,%eax,4),%eax
	else{
		cprintf("addr=%x err=%x *pde=%x utf_eip=%x\n",(uint32_t)addr,err,*pde,utf->utf_eip);	
		panic("page table for fault va is not exist");
	}
	//cprintf("addr=%x err=%x *pte=%x utf_eip=%x\n",(uint32_t)addr,err,*pte,utf->utf_eip);
	if(!(err&FEC_WR)||!(*pte&PTE_COW))
  801525:	f7 c6 02 00 00 00    	test   $0x2,%esi
  80152b:	75 3f                	jne    80156c <pgfault+0x7a>
  80152d:	eb 43                	jmp    801572 <pgfault+0x80>
	if(*pde&PTE_P)
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else{
		cprintf("addr=%x err=%x *pde=%x utf_eip=%x\n",(uint32_t)addr,err,*pde,utf->utf_eip);	
  80152f:	8b 41 28             	mov    0x28(%ecx),%eax
  801532:	8b 12                	mov    (%edx),%edx
  801534:	89 44 24 10          	mov    %eax,0x10(%esp)
  801538:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80153c:	89 74 24 08          	mov    %esi,0x8(%esp)
  801540:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801544:	c7 04 24 70 2e 80 00 	movl   $0x802e70,(%esp)
  80154b:	e8 19 ee ff ff       	call   800369 <cprintf>
		panic("page table for fault va is not exist");
  801550:	c7 44 24 08 94 2e 80 	movl   $0x802e94,0x8(%esp)
  801557:	00 
  801558:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80155f:	00 
  801560:	c7 04 24 0a 2f 80 00 	movl   $0x802f0a,(%esp)
  801567:	e8 30 ed ff ff       	call   80029c <_panic>
	}
	//cprintf("addr=%x err=%x *pte=%x utf_eip=%x\n",(uint32_t)addr,err,*pte,utf->utf_eip);
	if(!(err&FEC_WR)||!(*pte&PTE_COW))
  80156c:	f6 40 01 08          	testb  $0x8,0x1(%eax)
  801570:	75 49                	jne    8015bb <pgfault+0xc9>
	{	
		cprintf("envid=%x addr=%x err=%x *pte=%x utf_eip=%x\n",env->env_id,(uint32_t)addr,err,*pte,utf->utf_eip);
  801572:	8b 51 28             	mov    0x28(%ecx),%edx
  801575:	8b 08                	mov    (%eax),%ecx
  801577:	a1 40 70 80 00       	mov    0x807040,%eax
  80157c:	8b 40 4c             	mov    0x4c(%eax),%eax
  80157f:	89 54 24 14          	mov    %edx,0x14(%esp)
  801583:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801587:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80158b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80158f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801593:	c7 04 24 bc 2e 80 00 	movl   $0x802ebc,(%esp)
  80159a:	e8 ca ed ff ff       	call   800369 <cprintf>
		panic("faulting access is illegle");
  80159f:	c7 44 24 08 25 2f 80 	movl   $0x802f25,0x8(%esp)
  8015a6:	00 
  8015a7:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8015ae:	00 
  8015af:	c7 04 24 0a 2f 80 00 	movl   $0x802f0a,(%esp)
  8015b6:	e8 e1 ec ff ff       	call   80029c <_panic>
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	//cprintf("pgfault:env_id=%x\n",env->env_id);
	if((r=sys_page_alloc(0,PFTEMP,PTE_W|PTE_U|PTE_P))<0)
  8015bb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8015c2:	00 
  8015c3:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8015ca:	00 
  8015cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015d2:	e8 33 fb ff ff       	call   80110a <sys_page_alloc>
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	79 20                	jns    8015fb <pgfault+0x109>
			//输入id=0表示当前环境id(curenv->env_id),这个时候不能用env->env-id,子环境中env的修改会缺页
		panic("alloc a page for PFTEMP failed:%e",r);
  8015db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015df:	c7 44 24 08 e8 2e 80 	movl   $0x802ee8,0x8(%esp)
  8015e6:	00 
  8015e7:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8015ee:	00 
  8015ef:	c7 04 24 0a 2f 80 00 	movl   $0x802f0a,(%esp)
  8015f6:	e8 a1 ec ff ff       	call   80029c <_panic>
	//cprintf("PFTEMP=%x add=%x\n",PFTEMP,(uint32_t)addr&0xfffff000);
	srcva = (uint32_t*)((uint32_t)addr&0xfffff000);
  8015fb:	89 de                	mov    %ebx,%esi
  8015fd:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  801603:	89 f2                	mov    %esi,%edx
	dstva = (uint32_t*)PFTEMP;
	//strncpy((char*)PFTEMP,(char*)((uint32_t)addr&0xfffff000),PGSIZE);
	for(;srcva<(uint32_t*)(ROUNDUP(addr,PGSIZE));srcva++)//数据拷贝要注意，用strncpy出错了，原因还得分析
  801605:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  80160b:	89 c3                	mov    %eax,%ebx
  80160d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801613:	39 de                	cmp    %ebx,%esi
  801615:	73 13                	jae    80162a <pgfault+0x138>
  801617:	b9 00 f0 7f 00       	mov    $0x7ff000,%ecx
	{
		*dstva=*srcva;
  80161c:	8b 02                	mov    (%edx),%eax
  80161e:	89 01                	mov    %eax,(%ecx)
		dstva++;
  801620:	83 c1 04             	add    $0x4,%ecx
		panic("alloc a page for PFTEMP failed:%e",r);
	//cprintf("PFTEMP=%x add=%x\n",PFTEMP,(uint32_t)addr&0xfffff000);
	srcva = (uint32_t*)((uint32_t)addr&0xfffff000);
	dstva = (uint32_t*)PFTEMP;
	//strncpy((char*)PFTEMP,(char*)((uint32_t)addr&0xfffff000),PGSIZE);
	for(;srcva<(uint32_t*)(ROUNDUP(addr,PGSIZE));srcva++)//数据拷贝要注意，用strncpy出错了，原因还得分析
  801623:	83 c2 04             	add    $0x4,%edx
  801626:	39 da                	cmp    %ebx,%edx
  801628:	72 f2                	jb     80161c <pgfault+0x12a>
	{
		*dstva=*srcva;
		dstva++;
	}
	if((r=sys_page_map(0,(void*)PFTEMP,0,(void*)((uint32_t)addr&0xfffff000),PTE_W|PTE_U|PTE_P))<0)
  80162a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801631:	00 
  801632:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801636:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80163d:	00 
  80163e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801645:	00 
  801646:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80164d:	e8 5a fa ff ff       	call   8010ac <sys_page_map>
  801652:	85 c0                	test   %eax,%eax
  801654:	79 1c                	jns    801672 <pgfault+0x180>
			//输入id=0表示当前环境id(curenv->env_id),这个时候不能用env->env-id,子环境中env的修改会缺页
		panic("page mapping failed");
  801656:	c7 44 24 08 40 2f 80 	movl   $0x802f40,0x8(%esp)
  80165d:	00 
  80165e:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801665:	00 
  801666:	c7 04 24 0a 2f 80 00 	movl   $0x802f0a,(%esp)
  80166d:	e8 2a ec ff ff       	call   80029c <_panic>
	//panic("pgfault not implemented");
}
  801672:	83 c4 20             	add    $0x20,%esp
  801675:	5b                   	pop    %ebx
  801676:	5e                   	pop    %esi
  801677:	5d                   	pop    %ebp
  801678:	c3                   	ret    

00801679 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801679:	55                   	push   %ebp
  80167a:	89 e5                	mov    %esp,%ebp
  80167c:	56                   	push   %esi
  80167d:	53                   	push   %ebx
  80167e:	83 ec 10             	sub    $0x10,%esp
  801681:	ba 07 00 00 00       	mov    $0x7,%edx
  801686:	89 d0                	mov    %edx,%eax
  801688:	cd 30                	int    $0x30
  80168a:	89 c6                	mov    %eax,%esi
	pte_t *pte;
	unsigned i;
	uint32_t addr;
	envid_t envid;
	envid = sys_exofork();//创建子环境
	if(envid < 0)
  80168c:	85 c0                	test   %eax,%eax
  80168e:	79 20                	jns    8016b0 <fork+0x37>
		panic("sys_exofork: %e", envid);
  801690:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801694:	c7 44 24 08 15 2f 80 	movl   $0x802f15,0x8(%esp)
  80169b:	00 
  80169c:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  8016a3:	00 
  8016a4:	c7 04 24 0a 2f 80 00 	movl   $0x802f0a,(%esp)
  8016ab:	e8 ec eb ff ff       	call   80029c <_panic>
	if(envid==0)//子环境中
  8016b0:	85 c0                	test   %eax,%eax
  8016b2:	75 21                	jne    8016d5 <fork+0x5c>
	{
		env = &envs[ENVX(sys_getenvid())];
  8016b4:	e8 e4 fa ff ff       	call   80119d <sys_getenvid>
  8016b9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8016be:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8016c1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8016c6:	a3 40 70 80 00       	mov    %eax,0x807040
  8016cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8016d0:	e9 9e 00 00 00       	jmp    801773 <fork+0xfa>
		return 0;
	}
	else{//父环境中
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
  8016d5:	c7 04 24 f2 14 80 00 	movl   $0x8014f2,(%esp)
  8016dc:	e8 eb 0f 00 00       	call   8026cc <set_pgfault_handler>
  8016e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016e6:	eb 08                	jmp    8016f0 <fork+0x77>
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
		{
			if(i==(unsigned)VPN(UXSTACKTOP-PGSIZE))//特殊处理，用户层缺页异常栈
  8016e8:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  8016ee:	74 3d                	je     80172d <fork+0xb4>
				continue;
  8016f0:	89 da                	mov    %ebx,%edx
  8016f2:	c1 e2 0c             	shl    $0xc,%edx
			addr=i*PGSIZE;
			pde =(pde_t*) &vpd[VPD(addr)];
  8016f5:	89 d0                	mov    %edx,%eax
  8016f7:	c1 e8 16             	shr    $0x16,%eax
			if(*pde&PTE_P)//这里只处理有物理页面映射的页表项
  8016fa:	f6 04 85 00 d0 7b ef 	testb  $0x1,-0x10843000(,%eax,4)
  801701:	01 
  801702:	74 1e                	je     801722 <fork+0xa9>
			{
				pte=(pte_t*)&vpt[VPN(addr)];
  801704:	89 d0                	mov    %edx,%eax
  801706:	c1 e8 0a             	shr    $0xa,%eax
			}
			else    continue;
			if((*pte&PTE_W)||(*pte&PTE_COW))
  801709:	f7 80 00 00 40 ef 02 	testl  $0x802,-0x10c00000(%eax)
  801710:	08 00 00 
  801713:	74 0d                	je     801722 <fork+0xa9>
			{
				if((r=duppage(envid,i))<0)
  801715:	89 da                	mov    %ebx,%edx
  801717:	89 f0                	mov    %esi,%eax
  801719:	e8 12 fb ff ff       	call   801230 <duppage>
  80171e:	85 c0                	test   %eax,%eax
  801720:	78 51                	js     801773 <fork+0xfa>
		env = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	else{//父环境中
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
  801722:	83 c3 01             	add    $0x1,%ebx
  801725:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  80172b:	75 bb                	jne    8016e8 <fork+0x6f>
			{
				if((r=duppage(envid,i))<0)
					return r;
			}
		}
		if((r=sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  80172d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801734:	00 
  801735:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80173c:	ee 
  80173d:	89 34 24             	mov    %esi,(%esp)
  801740:	e8 c5 f9 ff ff       	call   80110a <sys_page_alloc>
  801745:	85 c0                	test   %eax,%eax
  801747:	78 2a                	js     801773 <fork+0xfa>
			return r;//设置子环境的缺页异常栈
		if((r=sys_env_set_pgfault_upcall(envid,(void*)_pgfault_upcall))<0)
  801749:	c7 44 24 04 50 27 80 	movl   $0x802750,0x4(%esp)
  801750:	00 
  801751:	89 34 24             	mov    %esi,(%esp)
  801754:	e8 db f7 ff ff       	call   800f34 <sys_env_set_pgfault_upcall>
  801759:	85 c0                	test   %eax,%eax
  80175b:	78 16                	js     801773 <fork+0xfa>
			return r;//设置子环境的缺页异常处理入口点
		if((r=sys_env_set_status(envid,ENV_RUNNABLE))<0)
  80175d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801764:	00 
  801765:	89 34 24             	mov    %esi,(%esp)
  801768:	e8 83 f8 ff ff       	call   800ff0 <sys_env_set_status>
  80176d:	85 c0                	test   %eax,%eax
  80176f:	78 02                	js     801773 <fork+0xfa>
  801771:	89 f0                	mov    %esi,%eax
			return r;//设置子环境的状态为可运行
		return envid;
	}
	//panic("fork not implemented");
}
  801773:	83 c4 10             	add    $0x10,%esp
  801776:	5b                   	pop    %ebx
  801777:	5e                   	pop    %esi
  801778:	5d                   	pop    %ebp
  801779:	c3                   	ret    
  80177a:	00 00                	add    %al,(%eax)
  80177c:	00 00                	add    %al,(%eax)
	...

00801780 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	57                   	push   %edi
  801784:	56                   	push   %esi
  801785:	53                   	push   %ebx
  801786:	83 ec 1c             	sub    $0x1c,%esp
  801789:	8b 75 08             	mov    0x8(%ebp),%esi
  80178c:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  80178f:	e8 09 fa ff ff       	call   80119d <sys_getenvid>
  801794:	25 ff 03 00 00       	and    $0x3ff,%eax
  801799:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80179c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8017a1:	a3 40 70 80 00       	mov    %eax,0x807040
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  8017a6:	e8 f2 f9 ff ff       	call   80119d <sys_getenvid>
  8017ab:	25 ff 03 00 00       	and    $0x3ff,%eax
  8017b0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8017b3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8017b8:	a3 40 70 80 00       	mov    %eax,0x807040
		if(env->env_id==to_env){
  8017bd:	8b 40 4c             	mov    0x4c(%eax),%eax
  8017c0:	39 f0                	cmp    %esi,%eax
  8017c2:	75 0e                	jne    8017d2 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  8017c4:	c7 04 24 54 2f 80 00 	movl   $0x802f54,(%esp)
  8017cb:	e8 99 eb ff ff       	call   800369 <cprintf>
  8017d0:	eb 5a                	jmp    80182c <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  8017d2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8017d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8017d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e4:	89 34 24             	mov    %esi,(%esp)
  8017e7:	e8 10 f7 ff ff       	call   800efc <sys_ipc_try_send>
  8017ec:	89 c3                	mov    %eax,%ebx
  8017ee:	85 c0                	test   %eax,%eax
  8017f0:	79 25                	jns    801817 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  8017f2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8017f5:	74 2b                	je     801822 <ipc_send+0xa2>
				panic("send error:%e",r);
  8017f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017fb:	c7 44 24 08 70 2f 80 	movl   $0x802f70,0x8(%esp)
  801802:	00 
  801803:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80180a:	00 
  80180b:	c7 04 24 7e 2f 80 00 	movl   $0x802f7e,(%esp)
  801812:	e8 85 ea ff ff       	call   80029c <_panic>
		}
			sys_yield();
  801817:	e8 4d f9 ff ff       	call   801169 <sys_yield>
		
	}while(r!=0);
  80181c:	85 db                	test   %ebx,%ebx
  80181e:	75 86                	jne    8017a6 <ipc_send+0x26>
  801820:	eb 0a                	jmp    80182c <ipc_send+0xac>
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
		{	
			if(r!=-E_IPC_NOT_RECV)
				panic("send error:%e",r);
		}
			sys_yield();
  801822:	e8 42 f9 ff ff       	call   801169 <sys_yield>
  801827:	e9 7a ff ff ff       	jmp    8017a6 <ipc_send+0x26>
		
	}while(r!=0);
	return;
	//panic("ipc_send not implemented");
}
  80182c:	83 c4 1c             	add    $0x1c,%esp
  80182f:	5b                   	pop    %ebx
  801830:	5e                   	pop    %esi
  801831:	5f                   	pop    %edi
  801832:	5d                   	pop    %ebp
  801833:	c3                   	ret    

00801834 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	57                   	push   %edi
  801838:	56                   	push   %esi
  801839:	53                   	push   %ebx
  80183a:	83 ec 0c             	sub    $0xc,%esp
  80183d:	8b 75 08             	mov    0x8(%ebp),%esi
  801840:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	void *dstva=NULL;
	if(pg)
		dstva=pg;
	env = &envs[ENVX(sys_getenvid())];
  801843:	e8 55 f9 ff ff       	call   80119d <sys_getenvid>
  801848:	25 ff 03 00 00       	and    $0x3ff,%eax
  80184d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801850:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801855:	a3 40 70 80 00       	mov    %eax,0x807040
	if(from_env_store&&(env->env_id==*from_env_store))
  80185a:	85 f6                	test   %esi,%esi
  80185c:	74 29                	je     801887 <ipc_recv+0x53>
  80185e:	8b 40 4c             	mov    0x4c(%eax),%eax
  801861:	3b 06                	cmp    (%esi),%eax
  801863:	75 22                	jne    801887 <ipc_recv+0x53>
	{
		*from_env_store=0;
  801865:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  80186b:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("send:the reciver is sender\n");
  801871:	c7 04 24 54 2f 80 00 	movl   $0x802f54,(%esp)
  801878:	e8 ec ea ff ff       	call   800369 <cprintf>
  80187d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801882:	e9 8a 00 00 00       	jmp    801911 <ipc_recv+0xdd>
		return 0;
	}
	env = &envs[ENVX(sys_getenvid())];
  801887:	e8 11 f9 ff ff       	call   80119d <sys_getenvid>
  80188c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801891:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801894:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801899:	a3 40 70 80 00       	mov    %eax,0x807040
	if((r=sys_ipc_recv(dstva))<0)
  80189e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a1:	89 04 24             	mov    %eax,(%esp)
  8018a4:	e8 f6 f5 ff ff       	call   800e9f <sys_ipc_recv>
  8018a9:	89 c3                	mov    %eax,%ebx
  8018ab:	85 c0                	test   %eax,%eax
  8018ad:	79 1a                	jns    8018c9 <ipc_recv+0x95>
	{
		*from_env_store=0;
  8018af:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  8018b5:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("reciver failed\n");
  8018bb:	c7 04 24 88 2f 80 00 	movl   $0x802f88,(%esp)
  8018c2:	e8 a2 ea ff ff       	call   800369 <cprintf>
  8018c7:	eb 48                	jmp    801911 <ipc_recv+0xdd>
		return r;
	}
	else{//接收成功
		env = &envs[ENVX(sys_getenvid())];
  8018c9:	e8 cf f8 ff ff       	call   80119d <sys_getenvid>
  8018ce:	25 ff 03 00 00       	and    $0x3ff,%eax
  8018d3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8018d6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8018db:	a3 40 70 80 00       	mov    %eax,0x807040
		if(from_env_store)
  8018e0:	85 f6                	test   %esi,%esi
  8018e2:	74 05                	je     8018e9 <ipc_recv+0xb5>
			*from_env_store=env->env_ipc_from;	
  8018e4:	8b 40 74             	mov    0x74(%eax),%eax
  8018e7:	89 06                	mov    %eax,(%esi)
		if(perm_store)
  8018e9:	85 ff                	test   %edi,%edi
  8018eb:	74 0a                	je     8018f7 <ipc_recv+0xc3>
			*perm_store=env->env_ipc_perm;
  8018ed:	a1 40 70 80 00       	mov    0x807040,%eax
  8018f2:	8b 40 78             	mov    0x78(%eax),%eax
  8018f5:	89 07                	mov    %eax,(%edi)
		env = &envs[ENVX(sys_getenvid())];
  8018f7:	e8 a1 f8 ff ff       	call   80119d <sys_getenvid>
  8018fc:	25 ff 03 00 00       	and    $0x3ff,%eax
  801901:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801904:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801909:	a3 40 70 80 00       	mov    %eax,0x807040
		return env->env_ipc_value;
  80190e:	8b 58 70             	mov    0x70(%eax),%ebx
	}
	//panic("ipc_recv not implemented");
	return 0;
}
  801911:	89 d8                	mov    %ebx,%eax
  801913:	83 c4 0c             	add    $0xc,%esp
  801916:	5b                   	pop    %ebx
  801917:	5e                   	pop    %esi
  801918:	5f                   	pop    %edi
  801919:	5d                   	pop    %ebp
  80191a:	c3                   	ret    
  80191b:	00 00                	add    %al,(%eax)
  80191d:	00 00                	add    %al,(%eax)
	...

00801920 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	8b 45 08             	mov    0x8(%ebp),%eax
  801926:	05 00 00 00 30       	add    $0x30000000,%eax
  80192b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80192e:	5d                   	pop    %ebp
  80192f:	c3                   	ret    

00801930 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801936:	8b 45 08             	mov    0x8(%ebp),%eax
  801939:	89 04 24             	mov    %eax,(%esp)
  80193c:	e8 df ff ff ff       	call   801920 <fd2num>
  801941:	c1 e0 0c             	shl    $0xc,%eax
  801944:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801949:	c9                   	leave  
  80194a:	c3                   	ret    

0080194b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80194b:	55                   	push   %ebp
  80194c:	89 e5                	mov    %esp,%ebp
  80194e:	53                   	push   %ebx
  80194f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801952:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  801957:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801959:	89 d0                	mov    %edx,%eax
  80195b:	c1 e8 16             	shr    $0x16,%eax
  80195e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801965:	a8 01                	test   $0x1,%al
  801967:	74 10                	je     801979 <fd_alloc+0x2e>
  801969:	89 d0                	mov    %edx,%eax
  80196b:	c1 e8 0c             	shr    $0xc,%eax
  80196e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801975:	a8 01                	test   $0x1,%al
  801977:	75 09                	jne    801982 <fd_alloc+0x37>
			*fd_store = fd;
  801979:	89 0b                	mov    %ecx,(%ebx)
  80197b:	b8 00 00 00 00       	mov    $0x0,%eax
  801980:	eb 19                	jmp    80199b <fd_alloc+0x50>
			return 0;
  801982:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801988:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  80198e:	75 c7                	jne    801957 <fd_alloc+0xc>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801990:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801996:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  80199b:	5b                   	pop    %ebx
  80199c:	5d                   	pop    %ebp
  80199d:	c3                   	ret    

0080199e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8019a1:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  8019a5:	77 38                	ja     8019df <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8019a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019aa:	c1 e0 0c             	shl    $0xc,%eax
  8019ad:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  8019b3:	89 d0                	mov    %edx,%eax
  8019b5:	c1 e8 16             	shr    $0x16,%eax
  8019b8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8019bf:	a8 01                	test   $0x1,%al
  8019c1:	74 1c                	je     8019df <fd_lookup+0x41>
  8019c3:	89 d0                	mov    %edx,%eax
  8019c5:	c1 e8 0c             	shr    $0xc,%eax
  8019c8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019cf:	a8 01                	test   $0x1,%al
  8019d1:	74 0c                	je     8019df <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8019d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d6:	89 10                	mov    %edx,(%eax)
  8019d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8019dd:	eb 05                	jmp    8019e4 <fd_lookup+0x46>
	return 0;
  8019df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8019e4:	5d                   	pop    %ebp
  8019e5:	c3                   	ret    

008019e6 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8019e6:	55                   	push   %ebp
  8019e7:	89 e5                	mov    %esp,%ebp
  8019e9:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019ec:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8019ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f6:	89 04 24             	mov    %eax,(%esp)
  8019f9:	e8 a0 ff ff ff       	call   80199e <fd_lookup>
  8019fe:	85 c0                	test   %eax,%eax
  801a00:	78 0e                	js     801a10 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801a02:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801a05:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a08:	89 50 04             	mov    %edx,0x4(%eax)
  801a0b:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801a10:	c9                   	leave  
  801a11:	c3                   	ret    

00801a12 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	53                   	push   %ebx
  801a16:	83 ec 14             	sub    $0x14,%esp
  801a19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801a1f:	ba 04 70 80 00       	mov    $0x807004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801a24:	b8 00 00 00 00       	mov    $0x0,%eax
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801a29:	39 0d 04 70 80 00    	cmp    %ecx,0x807004
  801a2f:	75 11                	jne    801a42 <dev_lookup+0x30>
  801a31:	eb 04                	jmp    801a37 <dev_lookup+0x25>
  801a33:	39 0a                	cmp    %ecx,(%edx)
  801a35:	75 0b                	jne    801a42 <dev_lookup+0x30>
			*dev = devtab[i];
  801a37:	89 13                	mov    %edx,(%ebx)
  801a39:	b8 00 00 00 00       	mov    $0x0,%eax
  801a3e:	66 90                	xchg   %ax,%ax
  801a40:	eb 35                	jmp    801a77 <dev_lookup+0x65>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801a42:	83 c0 01             	add    $0x1,%eax
  801a45:	8b 14 85 14 30 80 00 	mov    0x803014(,%eax,4),%edx
  801a4c:	85 d2                	test   %edx,%edx
  801a4e:	75 e3                	jne    801a33 <dev_lookup+0x21>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  801a50:	a1 40 70 80 00       	mov    0x807040,%eax
  801a55:	8b 40 4c             	mov    0x4c(%eax),%eax
  801a58:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a60:	c7 04 24 98 2f 80 00 	movl   $0x802f98,(%esp)
  801a67:	e8 fd e8 ff ff       	call   800369 <cprintf>
	*dev = 0;
  801a6c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a72:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801a77:	83 c4 14             	add    $0x14,%esp
  801a7a:	5b                   	pop    %ebx
  801a7b:	5d                   	pop    %ebp
  801a7c:	c3                   	ret    

00801a7d <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  801a7d:	55                   	push   %ebp
  801a7e:	89 e5                	mov    %esp,%ebp
  801a80:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a83:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801a86:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8d:	89 04 24             	mov    %eax,(%esp)
  801a90:	e8 09 ff ff ff       	call   80199e <fd_lookup>
  801a95:	89 c2                	mov    %eax,%edx
  801a97:	85 c0                	test   %eax,%eax
  801a99:	78 5a                	js     801af5 <fstat+0x78>
  801a9b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801a9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801aa5:	8b 00                	mov    (%eax),%eax
  801aa7:	89 04 24             	mov    %eax,(%esp)
  801aaa:	e8 63 ff ff ff       	call   801a12 <dev_lookup>
  801aaf:	89 c2                	mov    %eax,%edx
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	78 40                	js     801af5 <fstat+0x78>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801ab5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  801aba:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801abd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801ac1:	74 32                	je     801af5 <fstat+0x78>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac6:	c6 00 00             	movb   $0x0,(%eax)
	stat->st_size = 0;
  801ac9:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  801ad0:	00 00 00 
	stat->st_isdir = 0;
  801ad3:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
  801ada:	00 00 00 
	stat->st_dev = dev;
  801add:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801ae0:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
	return (*dev->dev_stat)(fd, stat);
  801ae6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aea:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801aed:	89 04 24             	mov    %eax,(%esp)
  801af0:	ff 52 14             	call   *0x14(%edx)
  801af3:	89 c2                	mov    %eax,%edx
}
  801af5:	89 d0                	mov    %edx,%eax
  801af7:	c9                   	leave  
  801af8:	c3                   	ret    

00801af9 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801af9:	55                   	push   %ebp
  801afa:	89 e5                	mov    %esp,%ebp
  801afc:	53                   	push   %ebx
  801afd:	83 ec 24             	sub    $0x24,%esp
  801b00:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b06:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b0a:	89 1c 24             	mov    %ebx,(%esp)
  801b0d:	e8 8c fe ff ff       	call   80199e <fd_lookup>
  801b12:	85 c0                	test   %eax,%eax
  801b14:	78 61                	js     801b77 <ftruncate+0x7e>
  801b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b19:	8b 10                	mov    (%eax),%edx
  801b1b:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801b1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b22:	89 14 24             	mov    %edx,(%esp)
  801b25:	e8 e8 fe ff ff       	call   801a12 <dev_lookup>
  801b2a:	85 c0                	test   %eax,%eax
  801b2c:	78 49                	js     801b77 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b2e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801b31:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801b35:	75 23                	jne    801b5a <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801b37:	a1 40 70 80 00       	mov    0x807040,%eax
  801b3c:	8b 40 4c             	mov    0x4c(%eax),%eax
  801b3f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b43:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b47:	c7 04 24 b8 2f 80 00 	movl   $0x802fb8,(%esp)
  801b4e:	e8 16 e8 ff ff       	call   800369 <cprintf>
  801b53:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b58:	eb 1d                	jmp    801b77 <ftruncate+0x7e>
			env->env_id, fdnum); 
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801b5a:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801b5d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b62:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  801b66:	74 0f                	je     801b77 <ftruncate+0x7e>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801b68:	8b 42 18             	mov    0x18(%edx),%eax
  801b6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b6e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b72:	89 0c 24             	mov    %ecx,(%esp)
  801b75:	ff d0                	call   *%eax
}
  801b77:	83 c4 24             	add    $0x24,%esp
  801b7a:	5b                   	pop    %ebx
  801b7b:	5d                   	pop    %ebp
  801b7c:	c3                   	ret    

00801b7d <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801b7d:	55                   	push   %ebp
  801b7e:	89 e5                	mov    %esp,%ebp
  801b80:	53                   	push   %ebx
  801b81:	83 ec 24             	sub    $0x24,%esp
  801b84:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b87:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b8e:	89 1c 24             	mov    %ebx,(%esp)
  801b91:	e8 08 fe ff ff       	call   80199e <fd_lookup>
  801b96:	85 c0                	test   %eax,%eax
  801b98:	78 68                	js     801c02 <write+0x85>
  801b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b9d:	8b 10                	mov    (%eax),%edx
  801b9f:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801ba2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba6:	89 14 24             	mov    %edx,(%esp)
  801ba9:	e8 64 fe ff ff       	call   801a12 <dev_lookup>
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	78 50                	js     801c02 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801bb2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801bb5:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801bb9:	75 23                	jne    801bde <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  801bbb:	a1 40 70 80 00       	mov    0x807040,%eax
  801bc0:	8b 40 4c             	mov    0x4c(%eax),%eax
  801bc3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bc7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bcb:	c7 04 24 d9 2f 80 00 	movl   $0x802fd9,(%esp)
  801bd2:	e8 92 e7 ff ff       	call   800369 <cprintf>
  801bd7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801bdc:	eb 24                	jmp    801c02 <write+0x85>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801bde:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801be1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801be6:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  801bea:	74 16                	je     801c02 <write+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801bec:	8b 42 0c             	mov    0xc(%edx),%eax
  801bef:	8b 55 10             	mov    0x10(%ebp),%edx
  801bf2:	89 54 24 08          	mov    %edx,0x8(%esp)
  801bf6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bf9:	89 54 24 04          	mov    %edx,0x4(%esp)
  801bfd:	89 0c 24             	mov    %ecx,(%esp)
  801c00:	ff d0                	call   *%eax
}
  801c02:	83 c4 24             	add    $0x24,%esp
  801c05:	5b                   	pop    %ebx
  801c06:	5d                   	pop    %ebp
  801c07:	c3                   	ret    

00801c08 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801c08:	55                   	push   %ebp
  801c09:	89 e5                	mov    %esp,%ebp
  801c0b:	53                   	push   %ebx
  801c0c:	83 ec 24             	sub    $0x24,%esp
  801c0f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c15:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c19:	89 1c 24             	mov    %ebx,(%esp)
  801c1c:	e8 7d fd ff ff       	call   80199e <fd_lookup>
  801c21:	85 c0                	test   %eax,%eax
  801c23:	78 6d                	js     801c92 <read+0x8a>
  801c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c28:	8b 10                	mov    (%eax),%edx
  801c2a:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801c2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c31:	89 14 24             	mov    %edx,(%esp)
  801c34:	e8 d9 fd ff ff       	call   801a12 <dev_lookup>
  801c39:	85 c0                	test   %eax,%eax
  801c3b:	78 55                	js     801c92 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801c3d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  801c40:	8b 41 08             	mov    0x8(%ecx),%eax
  801c43:	83 e0 03             	and    $0x3,%eax
  801c46:	83 f8 01             	cmp    $0x1,%eax
  801c49:	75 23                	jne    801c6e <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  801c4b:	a1 40 70 80 00       	mov    0x807040,%eax
  801c50:	8b 40 4c             	mov    0x4c(%eax),%eax
  801c53:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c57:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c5b:	c7 04 24 f6 2f 80 00 	movl   $0x802ff6,(%esp)
  801c62:	e8 02 e7 ff ff       	call   800369 <cprintf>
  801c67:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c6c:	eb 24                	jmp    801c92 <read+0x8a>
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801c6e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801c71:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c76:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  801c7a:	74 16                	je     801c92 <read+0x8a>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801c7c:	8b 42 08             	mov    0x8(%edx),%eax
  801c7f:	8b 55 10             	mov    0x10(%ebp),%edx
  801c82:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c86:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c89:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c8d:	89 0c 24             	mov    %ecx,(%esp)
  801c90:	ff d0                	call   *%eax
}
  801c92:	83 c4 24             	add    $0x24,%esp
  801c95:	5b                   	pop    %ebx
  801c96:	5d                   	pop    %ebp
  801c97:	c3                   	ret    

00801c98 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801c98:	55                   	push   %ebp
  801c99:	89 e5                	mov    %esp,%ebp
  801c9b:	57                   	push   %edi
  801c9c:	56                   	push   %esi
  801c9d:	53                   	push   %ebx
  801c9e:	83 ec 0c             	sub    $0xc,%esp
  801ca1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ca4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801ca7:	b8 00 00 00 00       	mov    $0x0,%eax
  801cac:	85 f6                	test   %esi,%esi
  801cae:	74 36                	je     801ce6 <readn+0x4e>
  801cb0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cb5:	ba 00 00 00 00       	mov    $0x0,%edx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801cba:	89 f0                	mov    %esi,%eax
  801cbc:	29 d0                	sub    %edx,%eax
  801cbe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cc2:	8d 04 17             	lea    (%edi,%edx,1),%eax
  801cc5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ccc:	89 04 24             	mov    %eax,(%esp)
  801ccf:	e8 34 ff ff ff       	call   801c08 <read>
		if (m < 0)
  801cd4:	85 c0                	test   %eax,%eax
  801cd6:	78 0e                	js     801ce6 <readn+0x4e>
			return m;
		if (m == 0)
  801cd8:	85 c0                	test   %eax,%eax
  801cda:	74 08                	je     801ce4 <readn+0x4c>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801cdc:	01 c3                	add    %eax,%ebx
  801cde:	89 da                	mov    %ebx,%edx
  801ce0:	39 f3                	cmp    %esi,%ebx
  801ce2:	72 d6                	jb     801cba <readn+0x22>
  801ce4:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801ce6:	83 c4 0c             	add    $0xc,%esp
  801ce9:	5b                   	pop    %ebx
  801cea:	5e                   	pop    %esi
  801ceb:	5f                   	pop    %edi
  801cec:	5d                   	pop    %ebp
  801ced:	c3                   	ret    

00801cee <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801cee:	55                   	push   %ebp
  801cef:	89 e5                	mov    %esp,%ebp
  801cf1:	83 ec 28             	sub    $0x28,%esp
  801cf4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801cf7:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801cfa:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801cfd:	89 34 24             	mov    %esi,(%esp)
  801d00:	e8 1b fc ff ff       	call   801920 <fd2num>
  801d05:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d08:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d0c:	89 04 24             	mov    %eax,(%esp)
  801d0f:	e8 8a fc ff ff       	call   80199e <fd_lookup>
  801d14:	89 c3                	mov    %eax,%ebx
  801d16:	85 c0                	test   %eax,%eax
  801d18:	78 05                	js     801d1f <fd_close+0x31>
  801d1a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801d1d:	74 0d                	je     801d2c <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801d1f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d23:	75 44                	jne    801d69 <fd_close+0x7b>
  801d25:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d2a:	eb 3d                	jmp    801d69 <fd_close+0x7b>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801d2c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d33:	8b 06                	mov    (%esi),%eax
  801d35:	89 04 24             	mov    %eax,(%esp)
  801d38:	e8 d5 fc ff ff       	call   801a12 <dev_lookup>
  801d3d:	89 c3                	mov    %eax,%ebx
  801d3f:	85 c0                	test   %eax,%eax
  801d41:	78 16                	js     801d59 <fd_close+0x6b>
		if (dev->dev_close)
  801d43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d46:	8b 40 10             	mov    0x10(%eax),%eax
  801d49:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d4e:	85 c0                	test   %eax,%eax
  801d50:	74 07                	je     801d59 <fd_close+0x6b>
			r = (*dev->dev_close)(fd);
  801d52:	89 34 24             	mov    %esi,(%esp)
  801d55:	ff d0                	call   *%eax
  801d57:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801d59:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d64:	e8 e5 f2 ff ff       	call   80104e <sys_page_unmap>
	return r;
}
  801d69:	89 d8                	mov    %ebx,%eax
  801d6b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d6e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d71:	89 ec                	mov    %ebp,%esp
  801d73:	5d                   	pop    %ebp
  801d74:	c3                   	ret    

00801d75 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801d75:	55                   	push   %ebp
  801d76:	89 e5                	mov    %esp,%ebp
  801d78:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d7b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801d7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d82:	8b 45 08             	mov    0x8(%ebp),%eax
  801d85:	89 04 24             	mov    %eax,(%esp)
  801d88:	e8 11 fc ff ff       	call   80199e <fd_lookup>
  801d8d:	85 c0                	test   %eax,%eax
  801d8f:	78 13                	js     801da4 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801d91:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801d98:	00 
  801d99:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801d9c:	89 04 24             	mov    %eax,(%esp)
  801d9f:	e8 4a ff ff ff       	call   801cee <fd_close>
}
  801da4:	c9                   	leave  
  801da5:	c3                   	ret    

00801da6 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801da6:	55                   	push   %ebp
  801da7:	89 e5                	mov    %esp,%ebp
  801da9:	83 ec 18             	sub    $0x18,%esp
  801dac:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801daf:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801db2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801db9:	00 
  801dba:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbd:	89 04 24             	mov    %eax,(%esp)
  801dc0:	e8 5a 03 00 00       	call   80211f <open>
  801dc5:	89 c6                	mov    %eax,%esi
  801dc7:	85 c0                	test   %eax,%eax
  801dc9:	78 1b                	js     801de6 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801dcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dce:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd2:	89 34 24             	mov    %esi,(%esp)
  801dd5:	e8 a3 fc ff ff       	call   801a7d <fstat>
  801dda:	89 c3                	mov    %eax,%ebx
	close(fd);
  801ddc:	89 34 24             	mov    %esi,(%esp)
  801ddf:	e8 91 ff ff ff       	call   801d75 <close>
  801de4:	89 de                	mov    %ebx,%esi
	return r;
}
  801de6:	89 f0                	mov    %esi,%eax
  801de8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801deb:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801dee:	89 ec                	mov    %ebp,%esp
  801df0:	5d                   	pop    %ebp
  801df1:	c3                   	ret    

00801df2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801df2:	55                   	push   %ebp
  801df3:	89 e5                	mov    %esp,%ebp
  801df5:	83 ec 38             	sub    $0x38,%esp
  801df8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801dfb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801dfe:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801e01:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801e04:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e07:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0e:	89 04 24             	mov    %eax,(%esp)
  801e11:	e8 88 fb ff ff       	call   80199e <fd_lookup>
  801e16:	89 c3                	mov    %eax,%ebx
  801e18:	85 c0                	test   %eax,%eax
  801e1a:	0f 88 e1 00 00 00    	js     801f01 <dup+0x10f>
		return r;
	close(newfdnum);
  801e20:	89 3c 24             	mov    %edi,(%esp)
  801e23:	e8 4d ff ff ff       	call   801d75 <close>

	newfd = INDEX2FD(newfdnum);
  801e28:	89 f8                	mov    %edi,%eax
  801e2a:	c1 e0 0c             	shl    $0xc,%eax
  801e2d:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  801e33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e36:	89 04 24             	mov    %eax,(%esp)
  801e39:	e8 f2 fa ff ff       	call   801930 <fd2data>
  801e3e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801e40:	89 34 24             	mov    %esi,(%esp)
  801e43:	e8 e8 fa ff ff       	call   801930 <fd2data>
  801e48:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  801e4b:	89 d8                	mov    %ebx,%eax
  801e4d:	c1 e8 16             	shr    $0x16,%eax
  801e50:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e57:	a8 01                	test   $0x1,%al
  801e59:	74 45                	je     801ea0 <dup+0xae>
  801e5b:	89 da                	mov    %ebx,%edx
  801e5d:	c1 ea 0c             	shr    $0xc,%edx
  801e60:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801e67:	a8 01                	test   $0x1,%al
  801e69:	74 35                	je     801ea0 <dup+0xae>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  801e6b:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801e72:	25 07 0e 00 00       	and    $0xe07,%eax
  801e77:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e7e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e82:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e89:	00 
  801e8a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e8e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e95:	e8 12 f2 ff ff       	call   8010ac <sys_page_map>
  801e9a:	89 c3                	mov    %eax,%ebx
  801e9c:	85 c0                	test   %eax,%eax
  801e9e:	78 3e                	js     801ede <dup+0xec>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  801ea0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ea3:	89 d0                	mov    %edx,%eax
  801ea5:	c1 e8 0c             	shr    $0xc,%eax
  801ea8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801eaf:	25 07 0e 00 00       	and    $0xe07,%eax
  801eb4:	89 44 24 10          	mov    %eax,0x10(%esp)
  801eb8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801ebc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ec3:	00 
  801ec4:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ec8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ecf:	e8 d8 f1 ff ff       	call   8010ac <sys_page_map>
  801ed4:	89 c3                	mov    %eax,%ebx
  801ed6:	85 c0                	test   %eax,%eax
  801ed8:	78 04                	js     801ede <dup+0xec>
		goto err;
  801eda:	89 fb                	mov    %edi,%ebx
  801edc:	eb 23                	jmp    801f01 <dup+0x10f>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801ede:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ee2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ee9:	e8 60 f1 ff ff       	call   80104e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801eee:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ef1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ef5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801efc:	e8 4d f1 ff ff       	call   80104e <sys_page_unmap>
	return r;
}
  801f01:	89 d8                	mov    %ebx,%eax
  801f03:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801f06:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801f09:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801f0c:	89 ec                	mov    %ebp,%esp
  801f0e:	5d                   	pop    %ebp
  801f0f:	c3                   	ret    

00801f10 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801f10:	55                   	push   %ebp
  801f11:	89 e5                	mov    %esp,%ebp
  801f13:	53                   	push   %ebx
  801f14:	83 ec 04             	sub    $0x4,%esp
  801f17:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801f1c:	89 1c 24             	mov    %ebx,(%esp)
  801f1f:	e8 51 fe ff ff       	call   801d75 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801f24:	83 c3 01             	add    $0x1,%ebx
  801f27:	83 fb 20             	cmp    $0x20,%ebx
  801f2a:	75 f0                	jne    801f1c <close_all+0xc>
		close(i);
}
  801f2c:	83 c4 04             	add    $0x4,%esp
  801f2f:	5b                   	pop    %ebx
  801f30:	5d                   	pop    %ebp
  801f31:	c3                   	ret    
	...

00801f34 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801f34:	55                   	push   %ebp
  801f35:	89 e5                	mov    %esp,%ebp
  801f37:	53                   	push   %ebx
  801f38:	83 ec 14             	sub    $0x14,%esp
  801f3b:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801f3d:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  801f43:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801f4a:	00 
  801f4b:	c7 44 24 08 00 40 80 	movl   $0x804000,0x8(%esp)
  801f52:	00 
  801f53:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f57:	89 14 24             	mov    %edx,(%esp)
  801f5a:	e8 21 f8 ff ff       	call   801780 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801f5f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f66:	00 
  801f67:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f6b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f72:	e8 bd f8 ff ff       	call   801834 <ipc_recv>
}
  801f77:	83 c4 14             	add    $0x14,%esp
  801f7a:	5b                   	pop    %ebx
  801f7b:	5d                   	pop    %ebp
  801f7c:	c3                   	ret    

00801f7d <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801f7d:	55                   	push   %ebp
  801f7e:	89 e5                	mov    %esp,%ebp
  801f80:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801f83:	ba 00 00 00 00       	mov    $0x0,%edx
  801f88:	b8 08 00 00 00       	mov    $0x8,%eax
  801f8d:	e8 a2 ff ff ff       	call   801f34 <fsipc>
}
  801f92:	c9                   	leave  
  801f93:	c3                   	ret    

00801f94 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801f94:	55                   	push   %ebp
  801f95:	89 e5                	mov    %esp,%ebp
  801f97:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801f9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f9d:	8b 40 0c             	mov    0xc(%eax),%eax
  801fa0:	a3 00 40 80 00       	mov    %eax,0x804000
	fsipcbuf.set_size.req_size = newsize;
  801fa5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fa8:	a3 04 40 80 00       	mov    %eax,0x804004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801fad:	ba 00 00 00 00       	mov    $0x0,%edx
  801fb2:	b8 02 00 00 00       	mov    $0x2,%eax
  801fb7:	e8 78 ff ff ff       	call   801f34 <fsipc>
}
  801fbc:	c9                   	leave  
  801fbd:	c3                   	ret    

00801fbe <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801fbe:	55                   	push   %ebp
  801fbf:	89 e5                	mov    %esp,%ebp
  801fc1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801fc4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc7:	8b 40 0c             	mov    0xc(%eax),%eax
  801fca:	a3 00 40 80 00       	mov    %eax,0x804000
	return fsipc(FSREQ_FLUSH, NULL);
  801fcf:	ba 00 00 00 00       	mov    $0x0,%edx
  801fd4:	b8 06 00 00 00       	mov    $0x6,%eax
  801fd9:	e8 56 ff ff ff       	call   801f34 <fsipc>
}
  801fde:	c9                   	leave  
  801fdf:	c3                   	ret    

00801fe0 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801fe0:	55                   	push   %ebp
  801fe1:	89 e5                	mov    %esp,%ebp
  801fe3:	53                   	push   %ebx
  801fe4:	83 ec 14             	sub    $0x14,%esp
  801fe7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801fea:	8b 45 08             	mov    0x8(%ebp),%eax
  801fed:	8b 40 0c             	mov    0xc(%eax),%eax
  801ff0:	a3 00 40 80 00       	mov    %eax,0x804000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ff5:	ba 00 00 00 00       	mov    $0x0,%edx
  801ffa:	b8 05 00 00 00       	mov    $0x5,%eax
  801fff:	e8 30 ff ff ff       	call   801f34 <fsipc>
  802004:	85 c0                	test   %eax,%eax
  802006:	78 2b                	js     802033 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802008:	c7 44 24 04 00 40 80 	movl   $0x804000,0x4(%esp)
  80200f:	00 
  802010:	89 1c 24             	mov    %ebx,(%esp)
  802013:	e8 b9 e9 ff ff       	call   8009d1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802018:	a1 80 40 80 00       	mov    0x804080,%eax
  80201d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802023:	a1 84 40 80 00       	mov    0x804084,%eax
  802028:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  80202e:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  802033:	83 c4 14             	add    $0x14,%esp
  802036:	5b                   	pop    %ebx
  802037:	5d                   	pop    %ebp
  802038:	c3                   	ret    

00802039 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802039:	55                   	push   %ebp
  80203a:	89 e5                	mov    %esp,%ebp
  80203c:	83 ec 18             	sub    $0x18,%esp
  80203f:	8b 55 10             	mov    0x10(%ebp),%edx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	ssize_t writesize;
	size_t bufsize;
	fsipcbuf.write.req_fileid=fd->fd_file.id;
  802042:	8b 45 08             	mov    0x8(%ebp),%eax
  802045:	8b 40 0c             	mov    0xc(%eax),%eax
  802048:	a3 00 40 80 00       	mov    %eax,0x804000
	bufsize=sizeof(fsipcbuf.write.req_buf);
	if(n<bufsize)
  80204d:	89 d0                	mov    %edx,%eax
  80204f:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  802055:	76 05                	jbe    80205c <devfile_write+0x23>
  802057:	b8 f8 0f 00 00       	mov    $0xff8,%eax
		bufsize=n;	
	fsipcbuf.write.req_n=n;
  80205c:	89 15 04 40 80 00    	mov    %edx,0x804004
	memmove((void*)fsipcbuf.write.req_buf,buf,bufsize);
  802062:	89 44 24 08          	mov    %eax,0x8(%esp)
  802066:	8b 45 0c             	mov    0xc(%ebp),%eax
  802069:	89 44 24 04          	mov    %eax,0x4(%esp)
  80206d:	c7 04 24 08 40 80 00 	movl   $0x804008,(%esp)
  802074:	e8 5f eb ff ff       	call   800bd8 <memmove>
	writesize=(ssize_t)fsipc(FSREQ_WRITE,NULL);
  802079:	ba 00 00 00 00       	mov    $0x0,%edx
  80207e:	b8 04 00 00 00       	mov    $0x4,%eax
  802083:	e8 ac fe ff ff       	call   801f34 <fsipc>
	return writesize;
	//panic("devfile_write not implemented");
}
  802088:	c9                   	leave  
  802089:	c3                   	ret    

0080208a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80208a:	55                   	push   %ebp
  80208b:	89 e5                	mov    %esp,%ebp
  80208d:	53                   	push   %ebx
  80208e:	83 ec 14             	sub    $0x14,%esp
	// system server.
	// LAB 5: Your code here
	ssize_t readsize;
	if(debug)
		cprintf("devfile_read:fileid=%x readsize=%x\n",fd->fd_file.id,n);
	fsipcbuf.read.req_fileid=fd->fd_file.id;
  802091:	8b 45 08             	mov    0x8(%ebp),%eax
  802094:	8b 40 0c             	mov    0xc(%eax),%eax
  802097:	a3 00 40 80 00       	mov    %eax,0x804000
	fsipcbuf.read.req_n=n;
  80209c:	8b 45 10             	mov    0x10(%ebp),%eax
  80209f:	a3 04 40 80 00       	mov    %eax,0x804004
	readsize=(ssize_t)fsipc(FSREQ_READ,&fsipcbuf);
  8020a4:	ba 00 40 80 00       	mov    $0x804000,%edx
  8020a9:	b8 03 00 00 00       	mov    $0x3,%eax
  8020ae:	e8 81 fe ff ff       	call   801f34 <fsipc>
  8020b3:	89 c3                	mov    %eax,%ebx
	//cprintf("readsize=%d\n",readsize);
	if(debug)
		cprintf("devfile_read:buf1=%s\nbuf2=%s\n",(char*)&fsipcbuf,fsipcbuf.readRet.ret_buf);
	if(readsize>0)
  8020b5:	85 c0                	test   %eax,%eax
  8020b7:	7e 17                	jle    8020d0 <devfile_read+0x46>
		memmove(buf,(void*)&fsipcbuf,(size_t)readsize);
  8020b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020bd:	c7 44 24 04 00 40 80 	movl   $0x804000,0x4(%esp)
  8020c4:	00 
  8020c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020c8:	89 04 24             	mov    %eax,(%esp)
  8020cb:	e8 08 eb ff ff       	call   800bd8 <memmove>
	//cprintf("readsize=%d",readsize);
	return readsize;
	//panic("devfile_read not implemented");
}
  8020d0:	89 d8                	mov    %ebx,%eax
  8020d2:	83 c4 14             	add    $0x14,%esp
  8020d5:	5b                   	pop    %ebx
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    

008020d8 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  8020d8:	55                   	push   %ebp
  8020d9:	89 e5                	mov    %esp,%ebp
  8020db:	53                   	push   %ebx
  8020dc:	83 ec 14             	sub    $0x14,%esp
  8020df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8020e2:	89 1c 24             	mov    %ebx,(%esp)
  8020e5:	e8 96 e8 ff ff       	call   800980 <strlen>
  8020ea:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  8020ef:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8020f4:	7f 21                	jg     802117 <remove+0x3f>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  8020f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020fa:	c7 04 24 00 40 80 00 	movl   $0x804000,(%esp)
  802101:	e8 cb e8 ff ff       	call   8009d1 <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  802106:	ba 00 00 00 00       	mov    $0x0,%edx
  80210b:	b8 07 00 00 00       	mov    $0x7,%eax
  802110:	e8 1f fe ff ff       	call   801f34 <fsipc>
  802115:	89 c2                	mov    %eax,%edx
}
  802117:	89 d0                	mov    %edx,%eax
  802119:	83 c4 14             	add    $0x14,%esp
  80211c:	5b                   	pop    %ebx
  80211d:	5d                   	pop    %ebp
  80211e:	c3                   	ret    

0080211f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80211f:	55                   	push   %ebp
  802120:	89 e5                	mov    %esp,%ebp
  802122:	56                   	push   %esi
  802123:	53                   	push   %ebx
  802124:	83 ec 30             	sub    $0x30,%esp

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;
	void *page;
	if((r=fd_alloc(&fd))<0){
  802127:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80212a:	89 04 24             	mov    %eax,(%esp)
  80212d:	e8 19 f8 ff ff       	call   80194b <fd_alloc>
  802132:	89 c3                	mov    %eax,%ebx
  802134:	85 c0                	test   %eax,%eax
  802136:	79 18                	jns    802150 <open+0x31>
		fd_close(fd,0);
  802138:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80213f:	00 
  802140:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802143:	89 04 24             	mov    %eax,(%esp)
  802146:	e8 a3 fb ff ff       	call   801cee <fd_close>
  80214b:	e9 9f 00 00 00       	jmp    8021ef <open+0xd0>
		return r;
	}
	//cprintf("open:fd=%x\n",fd);
	strcpy(fsipcbuf.open.req_path,path);
  802150:	8b 45 08             	mov    0x8(%ebp),%eax
  802153:	89 44 24 04          	mov    %eax,0x4(%esp)
  802157:	c7 04 24 00 40 80 00 	movl   $0x804000,(%esp)
  80215e:	e8 6e e8 ff ff       	call   8009d1 <strcpy>
	fsipcbuf.open.req_omode=mode;
  802163:	8b 45 0c             	mov    0xc(%ebp),%eax
  802166:	a3 00 44 80 00       	mov    %eax,0x804400
	page=(void*)fd2data(fd);
  80216b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80216e:	89 04 24             	mov    %eax,(%esp)
  802171:	e8 ba f7 ff ff       	call   801930 <fd2data>
  802176:	89 c6                	mov    %eax,%esi
	if((r=fsipc(FSREQ_OPEN,(void*)fd))<0)
  802178:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80217b:	b8 01 00 00 00       	mov    $0x1,%eax
  802180:	e8 af fd ff ff       	call   801f34 <fsipc>
  802185:	89 c3                	mov    %eax,%ebx
  802187:	85 c0                	test   %eax,%eax
  802189:	79 15                	jns    8021a0 <open+0x81>
	{
		fd_close(fd,1);
  80218b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802192:	00 
  802193:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802196:	89 04 24             	mov    %eax,(%esp)
  802199:	e8 50 fb ff ff       	call   801cee <fd_close>
  80219e:	eb 4f                	jmp    8021ef <open+0xd0>
		return r;	
	}
	//cprintf("open:page=%x\n",page);
	if((r=sys_page_map(0,(void*)fd,0,(void*)page,PTE_P | PTE_W | PTE_U))<0)
  8021a0:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8021a7:	00 
  8021a8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8021ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8021b3:	00 
  8021b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021c2:	e8 e5 ee ff ff       	call   8010ac <sys_page_map>
  8021c7:	89 c3                	mov    %eax,%ebx
  8021c9:	85 c0                	test   %eax,%eax
  8021cb:	79 15                	jns    8021e2 <open+0xc3>
	{
		fd_close(fd,1);
  8021cd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8021d4:	00 
  8021d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021d8:	89 04 24             	mov    %eax,(%esp)
  8021db:	e8 0e fb ff ff       	call   801cee <fd_close>
  8021e0:	eb 0d                	jmp    8021ef <open+0xd0>
		return r;
	}
	//cprintf("open:fileid=%x\n",fd->fd_file.id);
	return fd2num(fd);
  8021e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021e5:	89 04 24             	mov    %eax,(%esp)
  8021e8:	e8 33 f7 ff ff       	call   801920 <fd2num>
  8021ed:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  8021ef:	89 d8                	mov    %ebx,%eax
  8021f1:	83 c4 30             	add    $0x30,%esp
  8021f4:	5b                   	pop    %ebx
  8021f5:	5e                   	pop    %esi
  8021f6:	5d                   	pop    %ebp
  8021f7:	c3                   	ret    
	...

00802200 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802200:	55                   	push   %ebp
  802201:	89 e5                	mov    %esp,%ebp
  802203:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  802206:	c7 44 24 04 20 30 80 	movl   $0x803020,0x4(%esp)
  80220d:	00 
  80220e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802211:	89 04 24             	mov    %eax,(%esp)
  802214:	e8 b8 e7 ff ff       	call   8009d1 <strcpy>
	return 0;
}
  802219:	b8 00 00 00 00       	mov    $0x0,%eax
  80221e:	c9                   	leave  
  80221f:	c3                   	ret    

00802220 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802220:	55                   	push   %ebp
  802221:	89 e5                	mov    %esp,%ebp
  802223:	83 ec 08             	sub    $0x8,%esp
	return nsipc_close(fd->fd_sock.sockid);
  802226:	8b 45 08             	mov    0x8(%ebp),%eax
  802229:	8b 40 0c             	mov    0xc(%eax),%eax
  80222c:	89 04 24             	mov    %eax,(%esp)
  80222f:	e8 9e 02 00 00       	call   8024d2 <nsipc_close>
}
  802234:	c9                   	leave  
  802235:	c3                   	ret    

00802236 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802236:	55                   	push   %ebp
  802237:	89 e5                	mov    %esp,%ebp
  802239:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80223c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802243:	00 
  802244:	8b 45 10             	mov    0x10(%ebp),%eax
  802247:	89 44 24 08          	mov    %eax,0x8(%esp)
  80224b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80224e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802252:	8b 45 08             	mov    0x8(%ebp),%eax
  802255:	8b 40 0c             	mov    0xc(%eax),%eax
  802258:	89 04 24             	mov    %eax,(%esp)
  80225b:	e8 ae 02 00 00       	call   80250e <nsipc_send>
}
  802260:	c9                   	leave  
  802261:	c3                   	ret    

00802262 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  802262:	55                   	push   %ebp
  802263:	89 e5                	mov    %esp,%ebp
  802265:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802268:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80226f:	00 
  802270:	8b 45 10             	mov    0x10(%ebp),%eax
  802273:	89 44 24 08          	mov    %eax,0x8(%esp)
  802277:	8b 45 0c             	mov    0xc(%ebp),%eax
  80227a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80227e:	8b 45 08             	mov    0x8(%ebp),%eax
  802281:	8b 40 0c             	mov    0xc(%eax),%eax
  802284:	89 04 24             	mov    %eax,(%esp)
  802287:	e8 f5 02 00 00       	call   802581 <nsipc_recv>
}
  80228c:	c9                   	leave  
  80228d:	c3                   	ret    

0080228e <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  80228e:	55                   	push   %ebp
  80228f:	89 e5                	mov    %esp,%ebp
  802291:	56                   	push   %esi
  802292:	53                   	push   %ebx
  802293:	83 ec 20             	sub    $0x20,%esp
  802296:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802298:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80229b:	89 04 24             	mov    %eax,(%esp)
  80229e:	e8 a8 f6 ff ff       	call   80194b <fd_alloc>
  8022a3:	89 c3                	mov    %eax,%ebx
  8022a5:	85 c0                	test   %eax,%eax
  8022a7:	78 21                	js     8022ca <alloc_sockfd+0x3c>
  8022a9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8022b0:	00 
  8022b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022bf:	e8 46 ee ff ff       	call   80110a <sys_page_alloc>
  8022c4:	89 c3                	mov    %eax,%ebx
  8022c6:	85 c0                	test   %eax,%eax
  8022c8:	79 0a                	jns    8022d4 <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U)) < 0) {
		nsipc_close(sockid);
  8022ca:	89 34 24             	mov    %esi,(%esp)
  8022cd:	e8 00 02 00 00       	call   8024d2 <nsipc_close>
  8022d2:	eb 28                	jmp    8022fc <alloc_sockfd+0x6e>
		return r;
	}

	sfd->fd_dev_id = devsock.dev_id;
  8022d4:	8b 15 20 70 80 00    	mov    0x807020,%edx
  8022da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022dd:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8022df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022e2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8022e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ec:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8022ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022f2:	89 04 24             	mov    %eax,(%esp)
  8022f5:	e8 26 f6 ff ff       	call   801920 <fd2num>
  8022fa:	89 c3                	mov    %eax,%ebx
}
  8022fc:	89 d8                	mov    %ebx,%eax
  8022fe:	83 c4 20             	add    $0x20,%esp
  802301:	5b                   	pop    %ebx
  802302:	5e                   	pop    %esi
  802303:	5d                   	pop    %ebp
  802304:	c3                   	ret    

00802305 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802305:	55                   	push   %ebp
  802306:	89 e5                	mov    %esp,%ebp
  802308:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80230b:	8b 45 10             	mov    0x10(%ebp),%eax
  80230e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802312:	8b 45 0c             	mov    0xc(%ebp),%eax
  802315:	89 44 24 04          	mov    %eax,0x4(%esp)
  802319:	8b 45 08             	mov    0x8(%ebp),%eax
  80231c:	89 04 24             	mov    %eax,(%esp)
  80231f:	e8 62 01 00 00       	call   802486 <nsipc_socket>
  802324:	85 c0                	test   %eax,%eax
  802326:	78 05                	js     80232d <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802328:	e8 61 ff ff ff       	call   80228e <alloc_sockfd>
}
  80232d:	c9                   	leave  
  80232e:	66 90                	xchg   %ax,%ax
  802330:	c3                   	ret    

00802331 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802331:	55                   	push   %ebp
  802332:	89 e5                	mov    %esp,%ebp
  802334:	83 ec 18             	sub    $0x18,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802337:	8d 55 fc             	lea    -0x4(%ebp),%edx
  80233a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80233e:	89 04 24             	mov    %eax,(%esp)
  802341:	e8 58 f6 ff ff       	call   80199e <fd_lookup>
  802346:	89 c2                	mov    %eax,%edx
  802348:	85 c0                	test   %eax,%eax
  80234a:	78 15                	js     802361 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80234c:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  80234f:	8b 01                	mov    (%ecx),%eax
  802351:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  802356:	3b 05 20 70 80 00    	cmp    0x807020,%eax
  80235c:	75 03                	jne    802361 <fd2sockid+0x30>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80235e:	8b 51 0c             	mov    0xc(%ecx),%edx
}
  802361:	89 d0                	mov    %edx,%eax
  802363:	c9                   	leave  
  802364:	c3                   	ret    

00802365 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  802365:	55                   	push   %ebp
  802366:	89 e5                	mov    %esp,%ebp
  802368:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80236b:	8b 45 08             	mov    0x8(%ebp),%eax
  80236e:	e8 be ff ff ff       	call   802331 <fd2sockid>
  802373:	85 c0                	test   %eax,%eax
  802375:	78 0f                	js     802386 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802377:	8b 55 0c             	mov    0xc(%ebp),%edx
  80237a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80237e:	89 04 24             	mov    %eax,(%esp)
  802381:	e8 2a 01 00 00       	call   8024b0 <nsipc_listen>
}
  802386:	c9                   	leave  
  802387:	c3                   	ret    

00802388 <connect>:
	return nsipc_close(fd->fd_sock.sockid);
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802388:	55                   	push   %ebp
  802389:	89 e5                	mov    %esp,%ebp
  80238b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80238e:	8b 45 08             	mov    0x8(%ebp),%eax
  802391:	e8 9b ff ff ff       	call   802331 <fd2sockid>
  802396:	85 c0                	test   %eax,%eax
  802398:	78 16                	js     8023b0 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80239a:	8b 55 10             	mov    0x10(%ebp),%edx
  80239d:	89 54 24 08          	mov    %edx,0x8(%esp)
  8023a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023a4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023a8:	89 04 24             	mov    %eax,(%esp)
  8023ab:	e8 51 02 00 00       	call   802601 <nsipc_connect>
}
  8023b0:	c9                   	leave  
  8023b1:	c3                   	ret    

008023b2 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  8023b2:	55                   	push   %ebp
  8023b3:	89 e5                	mov    %esp,%ebp
  8023b5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8023b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8023bb:	e8 71 ff ff ff       	call   802331 <fd2sockid>
  8023c0:	85 c0                	test   %eax,%eax
  8023c2:	78 0f                	js     8023d3 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8023c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023c7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023cb:	89 04 24             	mov    %eax,(%esp)
  8023ce:	e8 19 01 00 00       	call   8024ec <nsipc_shutdown>
}
  8023d3:	c9                   	leave  
  8023d4:	c3                   	ret    

008023d5 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8023d5:	55                   	push   %ebp
  8023d6:	89 e5                	mov    %esp,%ebp
  8023d8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8023db:	8b 45 08             	mov    0x8(%ebp),%eax
  8023de:	e8 4e ff ff ff       	call   802331 <fd2sockid>
  8023e3:	85 c0                	test   %eax,%eax
  8023e5:	78 16                	js     8023fd <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  8023e7:	8b 55 10             	mov    0x10(%ebp),%edx
  8023ea:	89 54 24 08          	mov    %edx,0x8(%esp)
  8023ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023f5:	89 04 24             	mov    %eax,(%esp)
  8023f8:	e8 43 02 00 00       	call   802640 <nsipc_bind>
}
  8023fd:	c9                   	leave  
  8023fe:	c3                   	ret    

008023ff <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8023ff:	55                   	push   %ebp
  802400:	89 e5                	mov    %esp,%ebp
  802402:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802405:	8b 45 08             	mov    0x8(%ebp),%eax
  802408:	e8 24 ff ff ff       	call   802331 <fd2sockid>
  80240d:	85 c0                	test   %eax,%eax
  80240f:	78 1f                	js     802430 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802411:	8b 55 10             	mov    0x10(%ebp),%edx
  802414:	89 54 24 08          	mov    %edx,0x8(%esp)
  802418:	8b 55 0c             	mov    0xc(%ebp),%edx
  80241b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80241f:	89 04 24             	mov    %eax,(%esp)
  802422:	e8 58 02 00 00       	call   80267f <nsipc_accept>
  802427:	85 c0                	test   %eax,%eax
  802429:	78 05                	js     802430 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80242b:	e8 5e fe ff ff       	call   80228e <alloc_sockfd>
}
  802430:	c9                   	leave  
  802431:	c3                   	ret    
	...

00802440 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802440:	55                   	push   %ebp
  802441:	89 e5                	mov    %esp,%ebp
  802443:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802446:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  80244c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802453:	00 
  802454:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  80245b:	00 
  80245c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802460:	89 14 24             	mov    %edx,(%esp)
  802463:	e8 18 f3 ff ff       	call   801780 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802468:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80246f:	00 
  802470:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802477:	00 
  802478:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80247f:	e8 b0 f3 ff ff       	call   801834 <ipc_recv>
}
  802484:	c9                   	leave  
  802485:	c3                   	ret    

00802486 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  802486:	55                   	push   %ebp
  802487:	89 e5                	mov    %esp,%ebp
  802489:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80248c:	8b 45 08             	mov    0x8(%ebp),%eax
  80248f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802494:	8b 45 0c             	mov    0xc(%ebp),%eax
  802497:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80249c:	8b 45 10             	mov    0x10(%ebp),%eax
  80249f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8024a4:	b8 09 00 00 00       	mov    $0x9,%eax
  8024a9:	e8 92 ff ff ff       	call   802440 <nsipc>
}
  8024ae:	c9                   	leave  
  8024af:	c3                   	ret    

008024b0 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  8024b0:	55                   	push   %ebp
  8024b1:	89 e5                	mov    %esp,%ebp
  8024b3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8024b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8024b9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8024be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024c1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8024c6:	b8 06 00 00 00       	mov    $0x6,%eax
  8024cb:	e8 70 ff ff ff       	call   802440 <nsipc>
}
  8024d0:	c9                   	leave  
  8024d1:	c3                   	ret    

008024d2 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  8024d2:	55                   	push   %ebp
  8024d3:	89 e5                	mov    %esp,%ebp
  8024d5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8024d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8024db:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8024e0:	b8 04 00 00 00       	mov    $0x4,%eax
  8024e5:	e8 56 ff ff ff       	call   802440 <nsipc>
}
  8024ea:	c9                   	leave  
  8024eb:	c3                   	ret    

008024ec <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  8024ec:	55                   	push   %ebp
  8024ed:	89 e5                	mov    %esp,%ebp
  8024ef:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8024f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8024f5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8024fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024fd:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  802502:	b8 03 00 00 00       	mov    $0x3,%eax
  802507:	e8 34 ff ff ff       	call   802440 <nsipc>
}
  80250c:	c9                   	leave  
  80250d:	c3                   	ret    

0080250e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80250e:	55                   	push   %ebp
  80250f:	89 e5                	mov    %esp,%ebp
  802511:	53                   	push   %ebx
  802512:	83 ec 14             	sub    $0x14,%esp
  802515:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802518:	8b 45 08             	mov    0x8(%ebp),%eax
  80251b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  802520:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802526:	7e 24                	jle    80254c <nsipc_send+0x3e>
  802528:	c7 44 24 0c 2c 30 80 	movl   $0x80302c,0xc(%esp)
  80252f:	00 
  802530:	c7 44 24 08 38 30 80 	movl   $0x803038,0x8(%esp)
  802537:	00 
  802538:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  80253f:	00 
  802540:	c7 04 24 4d 30 80 00 	movl   $0x80304d,(%esp)
  802547:	e8 50 dd ff ff       	call   80029c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80254c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802550:	8b 45 0c             	mov    0xc(%ebp),%eax
  802553:	89 44 24 04          	mov    %eax,0x4(%esp)
  802557:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  80255e:	e8 75 e6 ff ff       	call   800bd8 <memmove>
	nsipcbuf.send.req_size = size;
  802563:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  802569:	8b 45 14             	mov    0x14(%ebp),%eax
  80256c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  802571:	b8 08 00 00 00       	mov    $0x8,%eax
  802576:	e8 c5 fe ff ff       	call   802440 <nsipc>
}
  80257b:	83 c4 14             	add    $0x14,%esp
  80257e:	5b                   	pop    %ebx
  80257f:	5d                   	pop    %ebp
  802580:	c3                   	ret    

00802581 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802581:	55                   	push   %ebp
  802582:	89 e5                	mov    %esp,%ebp
  802584:	56                   	push   %esi
  802585:	53                   	push   %ebx
  802586:	83 ec 10             	sub    $0x10,%esp
  802589:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80258c:	8b 45 08             	mov    0x8(%ebp),%eax
  80258f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  802594:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80259a:	8b 45 14             	mov    0x14(%ebp),%eax
  80259d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8025a2:	b8 07 00 00 00       	mov    $0x7,%eax
  8025a7:	e8 94 fe ff ff       	call   802440 <nsipc>
  8025ac:	89 c3                	mov    %eax,%ebx
  8025ae:	85 c0                	test   %eax,%eax
  8025b0:	78 46                	js     8025f8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8025b2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8025b7:	7f 04                	jg     8025bd <nsipc_recv+0x3c>
  8025b9:	39 c6                	cmp    %eax,%esi
  8025bb:	7d 24                	jge    8025e1 <nsipc_recv+0x60>
  8025bd:	c7 44 24 0c 59 30 80 	movl   $0x803059,0xc(%esp)
  8025c4:	00 
  8025c5:	c7 44 24 08 38 30 80 	movl   $0x803038,0x8(%esp)
  8025cc:	00 
  8025cd:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  8025d4:	00 
  8025d5:	c7 04 24 4d 30 80 00 	movl   $0x80304d,(%esp)
  8025dc:	e8 bb dc ff ff       	call   80029c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8025e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025e5:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8025ec:	00 
  8025ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025f0:	89 04 24             	mov    %eax,(%esp)
  8025f3:	e8 e0 e5 ff ff       	call   800bd8 <memmove>
	}

	return r;
}
  8025f8:	89 d8                	mov    %ebx,%eax
  8025fa:	83 c4 10             	add    $0x10,%esp
  8025fd:	5b                   	pop    %ebx
  8025fe:	5e                   	pop    %esi
  8025ff:	5d                   	pop    %ebp
  802600:	c3                   	ret    

00802601 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802601:	55                   	push   %ebp
  802602:	89 e5                	mov    %esp,%ebp
  802604:	53                   	push   %ebx
  802605:	83 ec 14             	sub    $0x14,%esp
  802608:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80260b:	8b 45 08             	mov    0x8(%ebp),%eax
  80260e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802613:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802617:	8b 45 0c             	mov    0xc(%ebp),%eax
  80261a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80261e:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  802625:	e8 ae e5 ff ff       	call   800bd8 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80262a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  802630:	b8 05 00 00 00       	mov    $0x5,%eax
  802635:	e8 06 fe ff ff       	call   802440 <nsipc>
}
  80263a:	83 c4 14             	add    $0x14,%esp
  80263d:	5b                   	pop    %ebx
  80263e:	5d                   	pop    %ebp
  80263f:	c3                   	ret    

00802640 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802640:	55                   	push   %ebp
  802641:	89 e5                	mov    %esp,%ebp
  802643:	53                   	push   %ebx
  802644:	83 ec 14             	sub    $0x14,%esp
  802647:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80264a:	8b 45 08             	mov    0x8(%ebp),%eax
  80264d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802652:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802656:	8b 45 0c             	mov    0xc(%ebp),%eax
  802659:	89 44 24 04          	mov    %eax,0x4(%esp)
  80265d:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  802664:	e8 6f e5 ff ff       	call   800bd8 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802669:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80266f:	b8 02 00 00 00       	mov    $0x2,%eax
  802674:	e8 c7 fd ff ff       	call   802440 <nsipc>
}
  802679:	83 c4 14             	add    $0x14,%esp
  80267c:	5b                   	pop    %ebx
  80267d:	5d                   	pop    %ebp
  80267e:	c3                   	ret    

0080267f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80267f:	55                   	push   %ebp
  802680:	89 e5                	mov    %esp,%ebp
  802682:	53                   	push   %ebx
  802683:	83 ec 14             	sub    $0x14,%esp
	int r;
	
	nsipcbuf.accept.req_s = s;
  802686:	8b 45 08             	mov    0x8(%ebp),%eax
  802689:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80268e:	b8 01 00 00 00       	mov    $0x1,%eax
  802693:	e8 a8 fd ff ff       	call   802440 <nsipc>
  802698:	89 c3                	mov    %eax,%ebx
  80269a:	85 c0                	test   %eax,%eax
  80269c:	78 26                	js     8026c4 <nsipc_accept+0x45>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80269e:	a1 10 60 80 00       	mov    0x806010,%eax
  8026a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026a7:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8026ae:	00 
  8026af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026b2:	89 04 24             	mov    %eax,(%esp)
  8026b5:	e8 1e e5 ff ff       	call   800bd8 <memmove>
		*addrlen = ret->ret_addrlen;
  8026ba:	a1 10 60 80 00       	mov    0x806010,%eax
  8026bf:	8b 55 10             	mov    0x10(%ebp),%edx
  8026c2:	89 02                	mov    %eax,(%edx)
	}
	return r;
}
  8026c4:	89 d8                	mov    %ebx,%eax
  8026c6:	83 c4 14             	add    $0x14,%esp
  8026c9:	5b                   	pop    %ebx
  8026ca:	5d                   	pop    %ebp
  8026cb:	c3                   	ret    

008026cc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8026cc:	55                   	push   %ebp
  8026cd:	89 e5                	mov    %esp,%ebp
  8026cf:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8026d2:	83 3d 48 70 80 00 00 	cmpl   $0x0,0x807048
  8026d9:	75 6a                	jne    802745 <set_pgfault_handler+0x79>
		// First time through!
		// LAB 4: Your code here.
		env=(struct Env*)&envs[ENVX(sys_getenvid())];
  8026db:	e8 bd ea ff ff       	call   80119d <sys_getenvid>
  8026e0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8026e5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8026e8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8026ed:	a3 40 70 80 00       	mov    %eax,0x807040
		if((r=sys_page_alloc(env->env_id,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  8026f2:	8b 40 4c             	mov    0x4c(%eax),%eax
  8026f5:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8026fc:	00 
  8026fd:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802704:	ee 
  802705:	89 04 24             	mov    %eax,(%esp)
  802708:	e8 fd e9 ff ff       	call   80110a <sys_page_alloc>
  80270d:	85 c0                	test   %eax,%eax
  80270f:	79 1c                	jns    80272d <set_pgfault_handler+0x61>
		{
			panic("Alloc a page for an exception stack failed");
  802711:	c7 44 24 08 70 30 80 	movl   $0x803070,0x8(%esp)
  802718:	00 
  802719:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802720:	00 
  802721:	c7 04 24 9c 30 80 00 	movl   $0x80309c,(%esp)
  802728:	e8 6f db ff ff       	call   80029c <_panic>
		}
		sys_env_set_pgfault_upcall(env->env_id,(void*)_pgfault_upcall);
  80272d:	a1 40 70 80 00       	mov    0x807040,%eax
  802732:	8b 40 4c             	mov    0x4c(%eax),%eax
  802735:	c7 44 24 04 50 27 80 	movl   $0x802750,0x4(%esp)
  80273c:	00 
  80273d:	89 04 24             	mov    %eax,(%esp)
  802740:	e8 ef e7 ff ff       	call   800f34 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802745:	8b 45 08             	mov    0x8(%ebp),%eax
  802748:	a3 48 70 80 00       	mov    %eax,0x807048
}
  80274d:	c9                   	leave  
  80274e:	c3                   	ret    
	...

00802750 <_pgfault_upcall>:
  802750:	54                   	push   %esp
  802751:	a1 48 70 80 00       	mov    0x807048,%eax
  802756:	ff d0                	call   *%eax
  802758:	83 c4 04             	add    $0x4,%esp
  80275b:	8b 44 24 28          	mov    0x28(%esp),%eax
  80275f:	50                   	push   %eax
  802760:	89 e0                	mov    %esp,%eax
  802762:	8b 60 34             	mov    0x34(%eax),%esp
  802765:	ff 30                	pushl  (%eax)
  802767:	89 c4                	mov    %eax,%esp
  802769:	83 6c 24 34 04       	subl   $0x4,0x34(%esp)
  80276e:	83 c4 0c             	add    $0xc,%esp
  802771:	61                   	popa   
  802772:	83 c4 04             	add    $0x4,%esp
  802775:	9d                   	popf   
  802776:	5c                   	pop    %esp
  802777:	c3                   	ret    
	...

00802780 <__udivdi3>:
  802780:	55                   	push   %ebp
  802781:	89 e5                	mov    %esp,%ebp
  802783:	57                   	push   %edi
  802784:	56                   	push   %esi
  802785:	83 ec 18             	sub    $0x18,%esp
  802788:	8b 45 10             	mov    0x10(%ebp),%eax
  80278b:	8b 55 14             	mov    0x14(%ebp),%edx
  80278e:	8b 75 0c             	mov    0xc(%ebp),%esi
  802791:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802794:	89 c1                	mov    %eax,%ecx
  802796:	8b 45 08             	mov    0x8(%ebp),%eax
  802799:	85 d2                	test   %edx,%edx
  80279b:	89 d7                	mov    %edx,%edi
  80279d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8027a0:	75 1e                	jne    8027c0 <__udivdi3+0x40>
  8027a2:	39 f1                	cmp    %esi,%ecx
  8027a4:	0f 86 8d 00 00 00    	jbe    802837 <__udivdi3+0xb7>
  8027aa:	89 f2                	mov    %esi,%edx
  8027ac:	31 f6                	xor    %esi,%esi
  8027ae:	f7 f1                	div    %ecx
  8027b0:	89 c1                	mov    %eax,%ecx
  8027b2:	89 c8                	mov    %ecx,%eax
  8027b4:	89 f2                	mov    %esi,%edx
  8027b6:	83 c4 18             	add    $0x18,%esp
  8027b9:	5e                   	pop    %esi
  8027ba:	5f                   	pop    %edi
  8027bb:	5d                   	pop    %ebp
  8027bc:	c3                   	ret    
  8027bd:	8d 76 00             	lea    0x0(%esi),%esi
  8027c0:	39 f2                	cmp    %esi,%edx
  8027c2:	0f 87 a8 00 00 00    	ja     802870 <__udivdi3+0xf0>
  8027c8:	0f bd c2             	bsr    %edx,%eax
  8027cb:	83 f0 1f             	xor    $0x1f,%eax
  8027ce:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8027d1:	0f 84 89 00 00 00    	je     802860 <__udivdi3+0xe0>
  8027d7:	b8 20 00 00 00       	mov    $0x20,%eax
  8027dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8027df:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8027e2:	89 c1                	mov    %eax,%ecx
  8027e4:	d3 ea                	shr    %cl,%edx
  8027e6:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  8027ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8027ed:	89 f8                	mov    %edi,%eax
  8027ef:	8b 7d f4             	mov    -0xc(%ebp),%edi
  8027f2:	d3 e0                	shl    %cl,%eax
  8027f4:	09 c2                	or     %eax,%edx
  8027f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8027f9:	d3 e7                	shl    %cl,%edi
  8027fb:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027ff:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802802:	89 f2                	mov    %esi,%edx
  802804:	d3 e8                	shr    %cl,%eax
  802806:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  80280a:	d3 e2                	shl    %cl,%edx
  80280c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802810:	09 d0                	or     %edx,%eax
  802812:	d3 ee                	shr    %cl,%esi
  802814:	89 f2                	mov    %esi,%edx
  802816:	f7 75 e4             	divl   -0x1c(%ebp)
  802819:	89 d1                	mov    %edx,%ecx
  80281b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80281e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802821:	f7 e7                	mul    %edi
  802823:	39 d1                	cmp    %edx,%ecx
  802825:	89 c6                	mov    %eax,%esi
  802827:	72 70                	jb     802899 <__udivdi3+0x119>
  802829:	39 ca                	cmp    %ecx,%edx
  80282b:	74 5f                	je     80288c <__udivdi3+0x10c>
  80282d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802830:	31 f6                	xor    %esi,%esi
  802832:	e9 7b ff ff ff       	jmp    8027b2 <__udivdi3+0x32>
  802837:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80283a:	85 c0                	test   %eax,%eax
  80283c:	75 0c                	jne    80284a <__udivdi3+0xca>
  80283e:	b8 01 00 00 00       	mov    $0x1,%eax
  802843:	31 d2                	xor    %edx,%edx
  802845:	f7 75 f4             	divl   -0xc(%ebp)
  802848:	89 c1                	mov    %eax,%ecx
  80284a:	89 f0                	mov    %esi,%eax
  80284c:	89 fa                	mov    %edi,%edx
  80284e:	f7 f1                	div    %ecx
  802850:	89 c6                	mov    %eax,%esi
  802852:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802855:	f7 f1                	div    %ecx
  802857:	89 c1                	mov    %eax,%ecx
  802859:	e9 54 ff ff ff       	jmp    8027b2 <__udivdi3+0x32>
  80285e:	66 90                	xchg   %ax,%ax
  802860:	39 d6                	cmp    %edx,%esi
  802862:	77 1c                	ja     802880 <__udivdi3+0x100>
  802864:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802867:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  80286a:	73 14                	jae    802880 <__udivdi3+0x100>
  80286c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802870:	31 c9                	xor    %ecx,%ecx
  802872:	31 f6                	xor    %esi,%esi
  802874:	e9 39 ff ff ff       	jmp    8027b2 <__udivdi3+0x32>
  802879:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  802880:	b9 01 00 00 00       	mov    $0x1,%ecx
  802885:	31 f6                	xor    %esi,%esi
  802887:	e9 26 ff ff ff       	jmp    8027b2 <__udivdi3+0x32>
  80288c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80288f:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  802893:	d3 e0                	shl    %cl,%eax
  802895:	39 c6                	cmp    %eax,%esi
  802897:	76 94                	jbe    80282d <__udivdi3+0xad>
  802899:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80289c:	31 f6                	xor    %esi,%esi
  80289e:	83 e9 01             	sub    $0x1,%ecx
  8028a1:	e9 0c ff ff ff       	jmp    8027b2 <__udivdi3+0x32>
	...

008028b0 <__umoddi3>:
  8028b0:	55                   	push   %ebp
  8028b1:	89 e5                	mov    %esp,%ebp
  8028b3:	57                   	push   %edi
  8028b4:	56                   	push   %esi
  8028b5:	83 ec 30             	sub    $0x30,%esp
  8028b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8028bb:	8b 55 14             	mov    0x14(%ebp),%edx
  8028be:	8b 75 08             	mov    0x8(%ebp),%esi
  8028c1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8028c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8028c7:	89 c1                	mov    %eax,%ecx
  8028c9:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8028cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8028cf:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8028d6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8028dd:	89 fa                	mov    %edi,%edx
  8028df:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8028e2:	85 c0                	test   %eax,%eax
  8028e4:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8028e7:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8028ea:	75 14                	jne    802900 <__umoddi3+0x50>
  8028ec:	39 f9                	cmp    %edi,%ecx
  8028ee:	76 60                	jbe    802950 <__umoddi3+0xa0>
  8028f0:	89 f0                	mov    %esi,%eax
  8028f2:	f7 f1                	div    %ecx
  8028f4:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8028f7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8028fe:	eb 10                	jmp    802910 <__umoddi3+0x60>
  802900:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802903:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  802906:	76 18                	jbe    802920 <__umoddi3+0x70>
  802908:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80290b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80290e:	66 90                	xchg   %ax,%ax
  802910:	8b 45 d0             	mov    -0x30(%ebp),%eax
  802913:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  802916:	83 c4 30             	add    $0x30,%esp
  802919:	5e                   	pop    %esi
  80291a:	5f                   	pop    %edi
  80291b:	5d                   	pop    %ebp
  80291c:	c3                   	ret    
  80291d:	8d 76 00             	lea    0x0(%esi),%esi
  802920:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
  802924:	83 f0 1f             	xor    $0x1f,%eax
  802927:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80292a:	75 46                	jne    802972 <__umoddi3+0xc2>
  80292c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80292f:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  802932:	0f 87 c9 00 00 00    	ja     802a01 <__umoddi3+0x151>
  802938:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  80293b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80293e:	0f 83 bd 00 00 00    	jae    802a01 <__umoddi3+0x151>
  802944:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802947:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80294a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80294d:	eb c1                	jmp    802910 <__umoddi3+0x60>
  80294f:	90                   	nop    
  802950:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802953:	85 c0                	test   %eax,%eax
  802955:	75 0c                	jne    802963 <__umoddi3+0xb3>
  802957:	b8 01 00 00 00       	mov    $0x1,%eax
  80295c:	31 d2                	xor    %edx,%edx
  80295e:	f7 75 ec             	divl   -0x14(%ebp)
  802961:	89 c1                	mov    %eax,%ecx
  802963:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802966:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802969:	f7 f1                	div    %ecx
  80296b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80296e:	f7 f1                	div    %ecx
  802970:	eb 82                	jmp    8028f4 <__umoddi3+0x44>
  802972:	b8 20 00 00 00       	mov    $0x20,%eax
  802977:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80297a:	2b 45 d8             	sub    -0x28(%ebp),%eax
  80297d:	8b 75 ec             	mov    -0x14(%ebp),%esi
  802980:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802983:	89 c1                	mov    %eax,%ecx
  802985:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802988:	d3 ea                	shr    %cl,%edx
  80298a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80298d:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  802991:	d3 e0                	shl    %cl,%eax
  802993:	09 c2                	or     %eax,%edx
  802995:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802998:	d3 e6                	shl    %cl,%esi
  80299a:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  80299e:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8029a1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8029a4:	d3 e8                	shr    %cl,%eax
  8029a6:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8029aa:	d3 e2                	shl    %cl,%edx
  8029ac:	09 d0                	or     %edx,%eax
  8029ae:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8029b1:	d3 e7                	shl    %cl,%edi
  8029b3:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  8029b7:	d3 ea                	shr    %cl,%edx
  8029b9:	f7 75 f4             	divl   -0xc(%ebp)
  8029bc:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8029bf:	f7 e6                	mul    %esi
  8029c1:	39 55 cc             	cmp    %edx,-0x34(%ebp)
  8029c4:	72 53                	jb     802a19 <__umoddi3+0x169>
  8029c6:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  8029c9:	74 4a                	je     802a15 <__umoddi3+0x165>
  8029cb:	90                   	nop    
  8029cc:	8d 74 26 00          	lea    0x0(%esi),%esi
  8029d0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8029d3:	29 c7                	sub    %eax,%edi
  8029d5:	19 d1                	sbb    %edx,%ecx
  8029d7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8029da:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8029de:	89 fa                	mov    %edi,%edx
  8029e0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8029e3:	d3 ea                	shr    %cl,%edx
  8029e5:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  8029e9:	d3 e0                	shl    %cl,%eax
  8029eb:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8029ef:	09 c2                	or     %eax,%edx
  8029f1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8029f4:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8029f7:	d3 e8                	shr    %cl,%eax
  8029f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8029fc:	e9 0f ff ff ff       	jmp    802910 <__umoddi3+0x60>
  802a01:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802a04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802a07:	2b 45 ec             	sub    -0x14(%ebp),%eax
  802a0a:	1b 55 e8             	sbb    -0x18(%ebp),%edx
  802a0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802a10:	e9 2f ff ff ff       	jmp    802944 <__umoddi3+0x94>
  802a15:	39 f8                	cmp    %edi,%eax
  802a17:	76 b7                	jbe    8029d0 <__umoddi3+0x120>
  802a19:	29 f0                	sub    %esi,%eax
  802a1b:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802a1e:	eb b0                	jmp    8029d0 <__umoddi3+0x120>
