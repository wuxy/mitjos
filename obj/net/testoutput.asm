
obj/net/testoutput:     file format elf32-i386

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
  80002c:	e8 f3 01 00 00       	call   800224 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <umain>:


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
  800049:	e8 5f 11 00 00       	call   8011ad <sys_getenvid>
  80004e:	89 c3                	mov    %eax,%ebx
	int i, r;

	binaryname = "testoutput";
  800050:	c7 05 00 70 80 00 80 	movl   $0x802a80,0x807000
  800057:	2a 80 00 

	output_envid = fork();
  80005a:	e8 2a 16 00 00       	call   801689 <fork>
  80005f:	a3 3c 70 80 00       	mov    %eax,0x80703c
	if (output_envid < 0)
  800064:	85 c0                	test   %eax,%eax
  800066:	79 1c                	jns    800084 <umain+0x44>
		panic("error forking");
  800068:	c7 44 24 08 8b 2a 80 	movl   $0x802a8b,0x8(%esp)
  80006f:	00 
  800070:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  800077:	00 
  800078:	c7 04 24 99 2a 80 00 	movl   $0x802a99,(%esp)
  80007f:	e8 18 02 00 00       	call   80029c <_panic>
	else if (output_envid == 0) {
  800084:	85 c0                	test   %eax,%eax
  800086:	75 0d                	jne    800095 <umain+0x55>
		output(ns_envid);
  800088:	89 1c 24             	mov    %ebx,(%esp)
  80008b:	e8 84 01 00 00       	call   800214 <output>
  800090:	e9 c7 00 00 00       	jmp    80015c <umain+0x11c>
		return;
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
		if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  800095:	8b 35 e4 2a 80 00    	mov    0x802ae4,%esi
			panic("sys_page_alloc: %e", r);
		pkt->jp_len = snprintf(pkt->jp_data,
  80009b:	8d 7e 04             	lea    0x4(%esi),%edi
  80009e:	bb 00 00 00 00       	mov    $0x0,%ebx
  8000a3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8000aa:	00 
  8000ab:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b6:	e8 5f 10 00 00       	call   80111a <sys_page_alloc>
  8000bb:	85 c0                	test   %eax,%eax
  8000bd:	79 20                	jns    8000df <umain+0x9f>
  8000bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c3:	c7 44 24 08 aa 2a 80 	movl   $0x802aaa,0x8(%esp)
  8000ca:	00 
  8000cb:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8000d2:	00 
  8000d3:	c7 04 24 99 2a 80 00 	movl   $0x802a99,(%esp)
  8000da:	e8 bd 01 00 00       	call   80029c <_panic>
  8000df:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000e3:	c7 44 24 08 bd 2a 80 	movl   $0x802abd,0x8(%esp)
  8000ea:	00 
  8000eb:	c7 44 24 04 fc 0f 00 	movl   $0xffc,0x4(%esp)
  8000f2:	00 
  8000f3:	89 3c 24             	mov    %edi,(%esp)
  8000f6:	e8 44 08 00 00       	call   80093f <snprintf>
  8000fb:	89 06                	mov    %eax,(%esi)
				       PGSIZE - sizeof(pkt->jp_len),
				       "Packet %02d", i);
		cprintf("Transmitting packet %d\n", i);
  8000fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800101:	c7 04 24 c9 2a 80 00 	movl   $0x802ac9,(%esp)
  800108:	e8 5c 02 00 00       	call   800369 <cprintf>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  80010d:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800114:	00 
  800115:	89 74 24 08          	mov    %esi,0x8(%esp)
  800119:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
  800120:	00 
  800121:	a1 3c 70 80 00       	mov    0x80703c,%eax
  800126:	89 04 24             	mov    %eax,(%esp)
  800129:	e8 62 16 00 00       	call   801790 <ipc_send>
		sys_page_unmap(0, pkt);
  80012e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800132:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800139:	e8 20 0f 00 00       	call   80105e <sys_page_unmap>
  80013e:	83 c3 01             	add    $0x1,%ebx
  800141:	83 fb 64             	cmp    $0x64,%ebx
  800144:	0f 85 59 ff ff ff    	jne    8000a3 <umain+0x63>
  80014a:	b3 00                	mov    $0x0,%bl
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
		sys_yield();
  80014c:	e8 28 10 00 00       	call   801179 <sys_yield>
  800151:	83 c3 01             	add    $0x1,%ebx
  800154:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  80015a:	75 f0                	jne    80014c <umain+0x10c>
}
  80015c:	83 c4 1c             	add    $0x1c,%esp
  80015f:	5b                   	pop    %ebx
  800160:	5e                   	pop    %esi
  800161:	5f                   	pop    %edi
  800162:	5d                   	pop    %ebp
  800163:	c3                   	ret    
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
  80017c:	e8 fa 0c 00 00       	call   800e7b <sys_time_msec>
  800181:	89 c3                	mov    %eax,%ebx
  800183:	03 5d 0c             	add    0xc(%ebp),%ebx

	binaryname = "ns_timer";
  800186:	c7 05 00 70 80 00 e8 	movl   $0x802ae8,0x807000
  80018d:	2a 80 00 
  800190:	eb 05                	jmp    800197 <timer+0x27>

	while (1) {
		while(sys_time_msec() < stop) {
			sys_yield();
  800192:	e8 e2 0f 00 00       	call   801179 <sys_yield>
  800197:	e8 df 0c 00 00       	call   800e7b <sys_time_msec>
  80019c:	39 c3                	cmp    %eax,%ebx
  80019e:	66 90                	xchg   %ax,%ax
  8001a0:	77 f0                	ja     800192 <timer+0x22>
		}

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  8001a2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001a9:	00 
  8001aa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001b1:	00 
  8001b2:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
  8001b9:	00 
  8001ba:	89 3c 24             	mov    %edi,(%esp)
  8001bd:	e8 ce 15 00 00       	call   801790 <ipc_send>
  8001c2:	8d 75 f0             	lea    0xfffffff0(%ebp),%esi

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8001c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001cc:	00 
  8001cd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001d4:	00 
  8001d5:	89 34 24             	mov    %esi,(%esp)
  8001d8:	e8 67 16 00 00       	call   801844 <ipc_recv>
  8001dd:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  8001df:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8001e2:	39 c7                	cmp    %eax,%edi
  8001e4:	74 12                	je     8001f8 <timer+0x88>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  8001e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ea:	c7 04 24 f4 2a 80 00 	movl   $0x802af4,(%esp)
  8001f1:	e8 73 01 00 00       	call   800369 <cprintf>
  8001f6:	eb cd                	jmp    8001c5 <timer+0x55>
				continue;
			}

			stop = sys_time_msec() + to;
  8001f8:	e8 7e 0c 00 00       	call   800e7b <sys_time_msec>
  8001fd:	01 c3                	add    %eax,%ebx
  8001ff:	90                   	nop    
  800200:	eb 95                	jmp    800197 <timer+0x27>
	...

00800204 <input>:
extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
	binaryname = "ns_input";
  800207:	c7 05 00 70 80 00 2f 	movl   $0x802b2f,0x807000
  80020e:	2b 80 00 

	// LAB 6: Your code here:
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
  800217:	c7 05 00 70 80 00 38 	movl   $0x802b38,0x807000
  80021e:	2b 80 00 

	// LAB 6: Your code here:
	// 	- read a packet from the network server
	//	- send the packet to the device driver
}
  800221:	5d                   	pop    %ebp
  800222:	c3                   	ret    
	...

00800224 <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	83 ec 18             	sub    $0x18,%esp
  80022a:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  80022d:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  800230:	8b 75 08             	mov    0x8(%ebp),%esi
  800233:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  800236:	c7 05 40 70 80 00 00 	movl   $0x0,0x807040
  80023d:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  800240:	e8 68 0f 00 00       	call   8011ad <sys_getenvid>
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

	// call user main routine调用用户主例程
	umain(argc, argv);
  800262:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800266:	89 34 24             	mov    %esi,(%esp)
  800269:	e8 d2 fd ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  80026e:	e8 0d 00 00 00       	call   800280 <exit>
}
  800273:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  800276:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
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
  800286:	e8 9b 1c 00 00       	call   801f26 <close_all>
	sys_env_destroy(0);
  80028b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800292:	e8 4a 0f 00 00       	call   8011e1 <sys_env_destroy>
}
  800297:	c9                   	leave  
  800298:	c3                   	ret    
  800299:	00 00                	add    %al,(%eax)
	...

0080029c <_panic>:
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
  8002a5:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)

	// Print the panic message
	if (argv0)
  8002a8:	a1 44 70 80 00       	mov    0x807044,%eax
  8002ad:	85 c0                	test   %eax,%eax
  8002af:	74 10                	je     8002c1 <_panic+0x25>
		cprintf("%s: ", argv0);
  8002b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b5:	c7 04 24 59 2b 80 00 	movl   $0x802b59,(%esp)
  8002bc:	e8 a8 00 00 00       	call   800369 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8002c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002cf:	a1 00 70 80 00       	mov    0x807000,%eax
  8002d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d8:	c7 04 24 5e 2b 80 00 	movl   $0x802b5e,(%esp)
  8002df:	e8 85 00 00 00       	call   800369 <cprintf>
	vcprintf(fmt, ap);
  8002e4:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  8002e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002eb:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ee:	89 04 24             	mov    %eax,(%esp)
  8002f1:	e8 12 00 00 00       	call   800308 <vcprintf>
	cprintf("\n");
  8002f6:	c7 04 24 df 2a 80 00 	movl   $0x802adf,(%esp)
  8002fd:	e8 67 00 00 00       	call   800369 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800302:	cc                   	int3   
  800303:	eb fd                	jmp    800302 <_panic+0x66>
  800305:	00 00                	add    %al,(%eax)
	...

00800308 <vcprintf>:
}

int
vcprintf(const char *fmt, va_list ap)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800311:	c7 85 f8 fe ff ff 00 	movl   $0x0,0xfffffef8(%ebp)
  800318:	00 00 00 
	b.cnt = 0;
  80031b:	c7 85 fc fe ff ff 00 	movl   $0x0,0xfffffefc(%ebp)
  800322:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800325:	8b 45 0c             	mov    0xc(%ebp),%eax
  800328:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80032c:	8b 45 08             	mov    0x8(%ebp),%eax
  80032f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800333:	8d 85 f8 fe ff ff    	lea    0xfffffef8(%ebp),%eax
  800339:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033d:	c7 04 24 86 03 80 00 	movl   $0x800386,(%esp)
  800344:	e8 c8 01 00 00       	call   800511 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800349:	8b 85 f8 fe ff ff    	mov    0xfffffef8(%ebp),%eax
  80034f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800353:	8d 85 00 ff ff ff    	lea    0xffffff00(%ebp),%eax
  800359:	89 04 24             	mov    %eax,(%esp)
  80035c:	e8 e7 0a 00 00       	call   800e48 <sys_cputs>
  800361:	8b 85 fc fe ff ff    	mov    0xfffffefc(%ebp),%eax

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
  800372:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
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
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
  800389:	53                   	push   %ebx
  80038a:	83 ec 14             	sub    $0x14,%esp
  80038d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800390:	8b 03                	mov    (%ebx),%eax
  800392:	8b 55 08             	mov    0x8(%ebp),%edx
  800395:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800399:	83 c0 01             	add    $0x1,%eax
  80039c:	89 03                	mov    %eax,(%ebx)
  80039e:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a3:	75 19                	jne    8003be <putch+0x38>
  8003a5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003ac:	00 
  8003ad:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b0:	89 04 24             	mov    %eax,(%esp)
  8003b3:	e8 90 0a 00 00       	call   800e48 <sys_cputs>
  8003b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003be:	83 43 04 01          	addl   $0x1,0x4(%ebx)
  8003c2:	83 c4 14             	add    $0x14,%esp
  8003c5:	5b                   	pop    %ebx
  8003c6:	5d                   	pop    %ebp
  8003c7:	c3                   	ret    
	...

008003d0 <printnum>:
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
  8003d9:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8003dc:	89 d7                	mov    %edx,%edi
  8003de:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003e4:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  8003e7:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  8003ea:	8b 55 10             	mov    0x10(%ebp),%edx
  8003ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f0:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003f3:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  8003f6:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  8003fd:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800400:	39 4d ec             	cmp    %ecx,0xffffffec(%ebp)
  800403:	72 11                	jb     800416 <printnum+0x46>
  800405:	8b 4d d8             	mov    0xffffffd8(%ebp),%ecx
  800408:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  80040b:	76 09                	jbe    800416 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80040d:	8d 58 ff             	lea    0xffffffff(%eax),%ebx
  800410:	85 db                	test   %ebx,%ebx
  800412:	7f 54                	jg     800468 <printnum+0x98>
  800414:	eb 61                	jmp    800477 <printnum+0xa7>
  800416:	89 74 24 10          	mov    %esi,0x10(%esp)
  80041a:	83 e8 01             	sub    $0x1,%eax
  80041d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800421:	89 54 24 08          	mov    %edx,0x8(%esp)
  800425:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800429:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80042d:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800430:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800433:	89 44 24 08          	mov    %eax,0x8(%esp)
  800437:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80043b:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  80043e:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800441:	89 14 24             	mov    %edx,(%esp)
  800444:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800448:	e8 73 23 00 00       	call   8027c0 <__udivdi3>
  80044d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800451:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800455:	89 04 24             	mov    %eax,(%esp)
  800458:	89 54 24 04          	mov    %edx,0x4(%esp)
  80045c:	89 fa                	mov    %edi,%edx
  80045e:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  800461:	e8 6a ff ff ff       	call   8003d0 <printnum>
  800466:	eb 0f                	jmp    800477 <printnum+0xa7>
			putch(padc, putdat);
  800468:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80046c:	89 34 24             	mov    %esi,(%esp)
  80046f:	ff 55 e4             	call   *0xffffffe4(%ebp)
  800472:	83 eb 01             	sub    $0x1,%ebx
  800475:	75 f1                	jne    800468 <printnum+0x98>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800477:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80047b:	8b 74 24 04          	mov    0x4(%esp),%esi
  80047f:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800482:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800485:	89 44 24 08          	mov    %eax,0x8(%esp)
  800489:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80048d:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800490:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800493:	89 14 24             	mov    %edx,(%esp)
  800496:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80049a:	e8 51 24 00 00       	call   8028f0 <__umoddi3>
  80049f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004a3:	0f be 80 7a 2b 80 00 	movsbl 0x802b7a(%eax),%eax
  8004aa:	89 04 24             	mov    %eax,(%esp)
  8004ad:	ff 55 e4             	call   *0xffffffe4(%ebp)
}
  8004b0:	83 c4 3c             	add    $0x3c,%esp
  8004b3:	5b                   	pop    %ebx
  8004b4:	5e                   	pop    %esi
  8004b5:	5f                   	pop    %edi
  8004b6:	5d                   	pop    %ebp
  8004b7:	c3                   	ret    

008004b8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
  8004bb:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8004bd:	83 fa 01             	cmp    $0x1,%edx
  8004c0:	7e 0e                	jle    8004d0 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8004c2:	8b 10                	mov    (%eax),%edx
  8004c4:	8d 42 08             	lea    0x8(%edx),%eax
  8004c7:	89 01                	mov    %eax,(%ecx)
  8004c9:	8b 02                	mov    (%edx),%eax
  8004cb:	8b 52 04             	mov    0x4(%edx),%edx
  8004ce:	eb 22                	jmp    8004f2 <getuint+0x3a>
	else if (lflag)
  8004d0:	85 d2                	test   %edx,%edx
  8004d2:	74 10                	je     8004e4 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8004d4:	8b 10                	mov    (%eax),%edx
  8004d6:	8d 42 04             	lea    0x4(%edx),%eax
  8004d9:	89 01                	mov    %eax,(%ecx)
  8004db:	8b 02                	mov    (%edx),%eax
  8004dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e2:	eb 0e                	jmp    8004f2 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  8004e4:	8b 10                	mov    (%eax),%edx
  8004e6:	8d 42 04             	lea    0x4(%edx),%eax
  8004e9:	89 01                	mov    %eax,(%ecx)
  8004eb:	8b 02                	mov    (%edx),%eax
  8004ed:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004f2:	5d                   	pop    %ebp
  8004f3:	c3                   	ret    

008004f4 <sprintputch>:

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
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
  8004f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  8004fa:	83 41 08 01          	addl   $0x1,0x8(%ecx)
	if (b->buf < b->ebuf)
  8004fe:	8b 11                	mov    (%ecx),%edx
  800500:	3b 51 04             	cmp    0x4(%ecx),%edx
  800503:	73 0a                	jae    80050f <sprintputch+0x1b>
		*b->buf++ = ch;
  800505:	8b 45 08             	mov    0x8(%ebp),%eax
  800508:	88 02                	mov    %al,(%edx)
  80050a:	8d 42 01             	lea    0x1(%edx),%eax
  80050d:	89 01                	mov    %eax,(%ecx)
}
  80050f:	5d                   	pop    %ebp
  800510:	c3                   	ret    

00800511 <vprintfmt>:
  800511:	55                   	push   %ebp
  800512:	89 e5                	mov    %esp,%ebp
  800514:	57                   	push   %edi
  800515:	56                   	push   %esi
  800516:	53                   	push   %ebx
  800517:	83 ec 4c             	sub    $0x4c,%esp
  80051a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80051d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800520:	eb 03                	jmp    800525 <vprintfmt+0x14>
  800522:	8b 5d e8             	mov    0xffffffe8(%ebp),%ebx
  800525:	0f b6 03             	movzbl (%ebx),%eax
  800528:	83 c3 01             	add    $0x1,%ebx
  80052b:	3c 25                	cmp    $0x25,%al
  80052d:	74 30                	je     80055f <vprintfmt+0x4e>
  80052f:	84 c0                	test   %al,%al
  800531:	0f 84 a8 03 00 00    	je     8008df <vprintfmt+0x3ce>
  800537:	0f b6 d0             	movzbl %al,%edx
  80053a:	eb 0a                	jmp    800546 <vprintfmt+0x35>
  80053c:	84 c0                	test   %al,%al
  80053e:	66 90                	xchg   %ax,%ax
  800540:	0f 84 99 03 00 00    	je     8008df <vprintfmt+0x3ce>
  800546:	8b 45 0c             	mov    0xc(%ebp),%eax
  800549:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054d:	89 14 24             	mov    %edx,(%esp)
  800550:	ff d7                	call   *%edi
  800552:	0f b6 03             	movzbl (%ebx),%eax
  800555:	0f b6 d0             	movzbl %al,%edx
  800558:	83 c3 01             	add    $0x1,%ebx
  80055b:	3c 25                	cmp    $0x25,%al
  80055d:	75 dd                	jne    80053c <vprintfmt+0x2b>
  80055f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800564:	c7 45 ec ff ff ff ff 	movl   $0xffffffff,0xffffffec(%ebp)
  80056b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  800572:	c7 45 dc 00 00 00 00 	movl   $0x0,0xffffffdc(%ebp)
  800579:	c6 45 e3 20          	movb   $0x20,0xffffffe3(%ebp)
  80057d:	eb 07                	jmp    800586 <vprintfmt+0x75>
  80057f:	c7 45 dc 01 00 00 00 	movl   $0x1,0xffffffdc(%ebp)
  800586:	0f b6 03             	movzbl (%ebx),%eax
  800589:	0f b6 d0             	movzbl %al,%edx
  80058c:	83 c3 01             	add    $0x1,%ebx
  80058f:	83 e8 23             	sub    $0x23,%eax
  800592:	3c 55                	cmp    $0x55,%al
  800594:	0f 87 11 03 00 00    	ja     8008ab <vprintfmt+0x39a>
  80059a:	0f b6 c0             	movzbl %al,%eax
  80059d:	ff 24 85 c0 2c 80 00 	jmp    *0x802cc0(,%eax,4)
  8005a4:	c6 45 e3 30          	movb   $0x30,0xffffffe3(%ebp)
  8005a8:	eb dc                	jmp    800586 <vprintfmt+0x75>
  8005aa:	83 ea 30             	sub    $0x30,%edx
  8005ad:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  8005b0:	0f be 13             	movsbl (%ebx),%edx
  8005b3:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  8005b6:	83 f8 09             	cmp    $0x9,%eax
  8005b9:	76 08                	jbe    8005c3 <vprintfmt+0xb2>
  8005bb:	eb 42                	jmp    8005ff <vprintfmt+0xee>
  8005bd:	c6 45 e3 2d          	movb   $0x2d,0xffffffe3(%ebp)
  8005c1:	eb c3                	jmp    800586 <vprintfmt+0x75>
  8005c3:	83 c3 01             	add    $0x1,%ebx
  8005c6:	8b 75 e4             	mov    0xffffffe4(%ebp),%esi
  8005c9:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8005cc:	8d 44 42 d0          	lea    0xffffffd0(%edx,%eax,2),%eax
  8005d0:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8005d3:	0f be 13             	movsbl (%ebx),%edx
  8005d6:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  8005d9:	83 f8 09             	cmp    $0x9,%eax
  8005dc:	77 21                	ja     8005ff <vprintfmt+0xee>
  8005de:	eb e3                	jmp    8005c3 <vprintfmt+0xb2>
  8005e0:	8b 55 14             	mov    0x14(%ebp),%edx
  8005e3:	8d 42 04             	lea    0x4(%edx),%eax
  8005e6:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e9:	8b 12                	mov    (%edx),%edx
  8005eb:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  8005ee:	eb 0f                	jmp    8005ff <vprintfmt+0xee>
  8005f0:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  8005f4:	79 90                	jns    800586 <vprintfmt+0x75>
  8005f6:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  8005fd:	eb 87                	jmp    800586 <vprintfmt+0x75>
  8005ff:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800603:	79 81                	jns    800586 <vprintfmt+0x75>
  800605:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  800608:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  80060b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  800612:	e9 6f ff ff ff       	jmp    800586 <vprintfmt+0x75>
  800617:	83 c1 01             	add    $0x1,%ecx
  80061a:	e9 67 ff ff ff       	jmp    800586 <vprintfmt+0x75>
  80061f:	8b 45 14             	mov    0x14(%ebp),%eax
  800622:	8d 50 04             	lea    0x4(%eax),%edx
  800625:	89 55 14             	mov    %edx,0x14(%ebp)
  800628:	8b 55 0c             	mov    0xc(%ebp),%edx
  80062b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80062f:	8b 00                	mov    (%eax),%eax
  800631:	89 04 24             	mov    %eax,(%esp)
  800634:	ff d7                	call   *%edi
  800636:	e9 ea fe ff ff       	jmp    800525 <vprintfmt+0x14>
  80063b:	8b 55 14             	mov    0x14(%ebp),%edx
  80063e:	8d 42 04             	lea    0x4(%edx),%eax
  800641:	89 45 14             	mov    %eax,0x14(%ebp)
  800644:	8b 02                	mov    (%edx),%eax
  800646:	89 c2                	mov    %eax,%edx
  800648:	c1 fa 1f             	sar    $0x1f,%edx
  80064b:	31 d0                	xor    %edx,%eax
  80064d:	29 d0                	sub    %edx,%eax
  80064f:	83 f8 0f             	cmp    $0xf,%eax
  800652:	7f 0b                	jg     80065f <vprintfmt+0x14e>
  800654:	8b 14 85 20 2e 80 00 	mov    0x802e20(,%eax,4),%edx
  80065b:	85 d2                	test   %edx,%edx
  80065d:	75 20                	jne    80067f <vprintfmt+0x16e>
  80065f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800663:	c7 44 24 08 8b 2b 80 	movl   $0x802b8b,0x8(%esp)
  80066a:	00 
  80066b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80066e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800672:	89 3c 24             	mov    %edi,(%esp)
  800675:	e8 f0 02 00 00       	call   80096a <printfmt>
  80067a:	e9 a6 fe ff ff       	jmp    800525 <vprintfmt+0x14>
  80067f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800683:	c7 44 24 08 aa 30 80 	movl   $0x8030aa,0x8(%esp)
  80068a:	00 
  80068b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80068e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800692:	89 3c 24             	mov    %edi,(%esp)
  800695:	e8 d0 02 00 00       	call   80096a <printfmt>
  80069a:	e9 86 fe ff ff       	jmp    800525 <vprintfmt+0x14>
  80069f:	8b 75 ec             	mov    0xffffffec(%ebp),%esi
  8006a2:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  8006a5:	89 5d e8             	mov    %ebx,0xffffffe8(%ebp)
  8006a8:	8b 55 14             	mov    0x14(%ebp),%edx
  8006ab:	8d 42 04             	lea    0x4(%edx),%eax
  8006ae:	89 45 14             	mov    %eax,0x14(%ebp)
  8006b1:	8b 12                	mov    (%edx),%edx
  8006b3:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  8006b6:	85 d2                	test   %edx,%edx
  8006b8:	75 07                	jne    8006c1 <vprintfmt+0x1b0>
  8006ba:	c7 45 d8 94 2b 80 00 	movl   $0x802b94,0xffffffd8(%ebp)
  8006c1:	85 f6                	test   %esi,%esi
  8006c3:	7e 40                	jle    800705 <vprintfmt+0x1f4>
  8006c5:	80 7d e3 2d          	cmpb   $0x2d,0xffffffe3(%ebp)
  8006c9:	74 3a                	je     800705 <vprintfmt+0x1f4>
  8006cb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006cf:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  8006d2:	89 14 24             	mov    %edx,(%esp)
  8006d5:	e8 e6 02 00 00       	call   8009c0 <strnlen>
  8006da:	29 c6                	sub    %eax,%esi
  8006dc:	89 75 ec             	mov    %esi,0xffffffec(%ebp)
  8006df:	85 f6                	test   %esi,%esi
  8006e1:	7e 22                	jle    800705 <vprintfmt+0x1f4>
  8006e3:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  8006e7:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  8006ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006f1:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  8006f4:	89 04 24             	mov    %eax,(%esp)
  8006f7:	ff d7                	call   *%edi
  8006f9:	83 ee 01             	sub    $0x1,%esi
  8006fc:	75 ec                	jne    8006ea <vprintfmt+0x1d9>
  8006fe:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  800705:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800708:	0f b6 02             	movzbl (%edx),%eax
  80070b:	0f be d0             	movsbl %al,%edx
  80070e:	8b 75 d8             	mov    0xffffffd8(%ebp),%esi
  800711:	84 c0                	test   %al,%al
  800713:	75 40                	jne    800755 <vprintfmt+0x244>
  800715:	eb 4a                	jmp    800761 <vprintfmt+0x250>
  800717:	83 7d dc 00          	cmpl   $0x0,0xffffffdc(%ebp)
  80071b:	74 1a                	je     800737 <vprintfmt+0x226>
  80071d:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  800720:	83 f8 5e             	cmp    $0x5e,%eax
  800723:	76 12                	jbe    800737 <vprintfmt+0x226>
  800725:	8b 45 0c             	mov    0xc(%ebp),%eax
  800728:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800733:	ff d7                	call   *%edi
  800735:	eb 0c                	jmp    800743 <vprintfmt+0x232>
  800737:	8b 45 0c             	mov    0xc(%ebp),%eax
  80073a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073e:	89 14 24             	mov    %edx,(%esp)
  800741:	ff d7                	call   *%edi
  800743:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  800747:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80074b:	83 c6 01             	add    $0x1,%esi
  80074e:	84 c0                	test   %al,%al
  800750:	74 0f                	je     800761 <vprintfmt+0x250>
  800752:	0f be d0             	movsbl %al,%edx
  800755:	83 7d e4 00          	cmpl   $0x0,0xffffffe4(%ebp)
  800759:	78 bc                	js     800717 <vprintfmt+0x206>
  80075b:	83 6d e4 01          	subl   $0x1,0xffffffe4(%ebp)
  80075f:	79 b6                	jns    800717 <vprintfmt+0x206>
  800761:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800765:	0f 8e ba fd ff ff    	jle    800525 <vprintfmt+0x14>
  80076b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80076e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800772:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800779:	ff d7                	call   *%edi
  80077b:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  80077f:	0f 84 9d fd ff ff    	je     800522 <vprintfmt+0x11>
  800785:	eb e4                	jmp    80076b <vprintfmt+0x25a>
  800787:	83 f9 01             	cmp    $0x1,%ecx
  80078a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800790:	7e 10                	jle    8007a2 <vprintfmt+0x291>
  800792:	8b 55 14             	mov    0x14(%ebp),%edx
  800795:	8d 42 08             	lea    0x8(%edx),%eax
  800798:	89 45 14             	mov    %eax,0x14(%ebp)
  80079b:	8b 02                	mov    (%edx),%eax
  80079d:	8b 52 04             	mov    0x4(%edx),%edx
  8007a0:	eb 26                	jmp    8007c8 <vprintfmt+0x2b7>
  8007a2:	85 c9                	test   %ecx,%ecx
  8007a4:	74 12                	je     8007b8 <vprintfmt+0x2a7>
  8007a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a9:	8d 50 04             	lea    0x4(%eax),%edx
  8007ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8007af:	8b 00                	mov    (%eax),%eax
  8007b1:	89 c2                	mov    %eax,%edx
  8007b3:	c1 fa 1f             	sar    $0x1f,%edx
  8007b6:	eb 10                	jmp    8007c8 <vprintfmt+0x2b7>
  8007b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bb:	8d 50 04             	lea    0x4(%eax),%edx
  8007be:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c1:	8b 00                	mov    (%eax),%eax
  8007c3:	89 c2                	mov    %eax,%edx
  8007c5:	c1 fa 1f             	sar    $0x1f,%edx
  8007c8:	89 d1                	mov    %edx,%ecx
  8007ca:	89 c2                	mov    %eax,%edx
  8007cc:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  8007cf:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  8007d2:	be 0a 00 00 00       	mov    $0xa,%esi
  8007d7:	85 c9                	test   %ecx,%ecx
  8007d9:	0f 89 92 00 00 00    	jns    800871 <vprintfmt+0x360>
  8007df:	8b 75 0c             	mov    0xc(%ebp),%esi
  8007e2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007e6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007ed:	ff d7                	call   *%edi
  8007ef:	8b 55 d0             	mov    0xffffffd0(%ebp),%edx
  8007f2:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
  8007f5:	f7 da                	neg    %edx
  8007f7:	83 d1 00             	adc    $0x0,%ecx
  8007fa:	f7 d9                	neg    %ecx
  8007fc:	be 0a 00 00 00       	mov    $0xa,%esi
  800801:	eb 6e                	jmp    800871 <vprintfmt+0x360>
  800803:	8d 45 14             	lea    0x14(%ebp),%eax
  800806:	89 ca                	mov    %ecx,%edx
  800808:	e8 ab fc ff ff       	call   8004b8 <getuint>
  80080d:	89 d1                	mov    %edx,%ecx
  80080f:	89 c2                	mov    %eax,%edx
  800811:	be 0a 00 00 00       	mov    $0xa,%esi
  800816:	eb 59                	jmp    800871 <vprintfmt+0x360>
  800818:	8d 45 14             	lea    0x14(%ebp),%eax
  80081b:	89 ca                	mov    %ecx,%edx
  80081d:	e8 96 fc ff ff       	call   8004b8 <getuint>
  800822:	e9 fe fc ff ff       	jmp    800525 <vprintfmt+0x14>
  800827:	8b 45 0c             	mov    0xc(%ebp),%eax
  80082a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800835:	ff d7                	call   *%edi
  800837:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80083e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800845:	ff d7                	call   *%edi
  800847:	8b 55 14             	mov    0x14(%ebp),%edx
  80084a:	8d 42 04             	lea    0x4(%edx),%eax
  80084d:	89 45 14             	mov    %eax,0x14(%ebp)
  800850:	8b 12                	mov    (%edx),%edx
  800852:	b9 00 00 00 00       	mov    $0x0,%ecx
  800857:	be 10 00 00 00       	mov    $0x10,%esi
  80085c:	eb 13                	jmp    800871 <vprintfmt+0x360>
  80085e:	8d 45 14             	lea    0x14(%ebp),%eax
  800861:	89 ca                	mov    %ecx,%edx
  800863:	e8 50 fc ff ff       	call   8004b8 <getuint>
  800868:	89 d1                	mov    %edx,%ecx
  80086a:	89 c2                	mov    %eax,%edx
  80086c:	be 10 00 00 00       	mov    $0x10,%esi
  800871:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  800875:	89 44 24 10          	mov    %eax,0x10(%esp)
  800879:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  80087c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800880:	89 74 24 08          	mov    %esi,0x8(%esp)
  800884:	89 14 24             	mov    %edx,(%esp)
  800887:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80088b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088e:	89 f8                	mov    %edi,%eax
  800890:	e8 3b fb ff ff       	call   8003d0 <printnum>
  800895:	e9 8b fc ff ff       	jmp    800525 <vprintfmt+0x14>
  80089a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80089d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008a1:	89 14 24             	mov    %edx,(%esp)
  8008a4:	ff d7                	call   *%edi
  8008a6:	e9 7a fc ff ff       	jmp    800525 <vprintfmt+0x14>
  8008ab:	89 de                	mov    %ebx,%esi
  8008ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008bb:	ff d7                	call   *%edi
  8008bd:	83 eb 01             	sub    $0x1,%ebx
  8008c0:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  8008c4:	0f 84 5b fc ff ff    	je     800525 <vprintfmt+0x14>
  8008ca:	8d 56 fd             	lea    0xfffffffd(%esi),%edx
  8008cd:	0f b6 02             	movzbl (%edx),%eax
  8008d0:	83 ea 01             	sub    $0x1,%edx
  8008d3:	3c 25                	cmp    $0x25,%al
  8008d5:	75 f6                	jne    8008cd <vprintfmt+0x3bc>
  8008d7:	8d 5a 02             	lea    0x2(%edx),%ebx
  8008da:	e9 46 fc ff ff       	jmp    800525 <vprintfmt+0x14>
  8008df:	83 c4 4c             	add    $0x4c,%esp
  8008e2:	5b                   	pop    %ebx
  8008e3:	5e                   	pop    %esi
  8008e4:	5f                   	pop    %edi
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	83 ec 28             	sub    $0x28,%esp
  8008ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8008f0:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8008f3:	85 d2                	test   %edx,%edx
  8008f5:	74 04                	je     8008fb <vsnprintf+0x14>
  8008f7:	85 c0                	test   %eax,%eax
  8008f9:	7f 07                	jg     800902 <vsnprintf+0x1b>
  8008fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800900:	eb 3b                	jmp    80093d <vsnprintf+0x56>
  800902:	c7 45 fc 00 00 00 00 	movl   $0x0,0xfffffffc(%ebp)
  800909:	8d 44 02 ff          	lea    0xffffffff(%edx,%eax,1),%eax
  80090d:	89 45 f8             	mov    %eax,0xfffffff8(%ebp)
  800910:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800913:	8b 45 14             	mov    0x14(%ebp),%eax
  800916:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80091a:	8b 45 10             	mov    0x10(%ebp),%eax
  80091d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800921:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  800924:	89 44 24 04          	mov    %eax,0x4(%esp)
  800928:	c7 04 24 f4 04 80 00 	movl   $0x8004f4,(%esp)
  80092f:	e8 dd fb ff ff       	call   800511 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800934:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  800937:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80093a:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
}
  80093d:	c9                   	leave  
  80093e:	c3                   	ret    

0080093f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800945:	8d 45 14             	lea    0x14(%ebp),%eax
  800948:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  80094b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80094f:	8b 45 10             	mov    0x10(%ebp),%eax
  800952:	89 44 24 08          	mov    %eax,0x8(%esp)
  800956:	8b 45 0c             	mov    0xc(%ebp),%eax
  800959:	89 44 24 04          	mov    %eax,0x4(%esp)
  80095d:	8b 45 08             	mov    0x8(%ebp),%eax
  800960:	89 04 24             	mov    %eax,(%esp)
  800963:	e8 7f ff ff ff       	call   8008e7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800968:	c9                   	leave  
  800969:	c3                   	ret    

0080096a <printfmt>:
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	83 ec 28             	sub    $0x28,%esp
  800970:	8d 45 14             	lea    0x14(%ebp),%eax
  800973:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
  800976:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80097a:	8b 45 10             	mov    0x10(%ebp),%eax
  80097d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800981:	8b 45 0c             	mov    0xc(%ebp),%eax
  800984:	89 44 24 04          	mov    %eax,0x4(%esp)
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	89 04 24             	mov    %eax,(%esp)
  80098e:	e8 7e fb ff ff       	call   800511 <vprintfmt>
  800993:	c9                   	leave  
  800994:	c3                   	ret    
	...

008009a0 <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ab:	80 3a 00             	cmpb   $0x0,(%edx)
  8009ae:	74 0e                	je     8009be <strlen+0x1e>
  8009b0:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009b5:	83 c0 01             	add    $0x1,%eax
  8009b8:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  8009bc:	75 f7                	jne    8009b5 <strlen+0x15>
	return n;
}
  8009be:	5d                   	pop    %ebp
  8009bf:	c3                   	ret    

008009c0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c9:	85 d2                	test   %edx,%edx
  8009cb:	74 19                	je     8009e6 <strnlen+0x26>
  8009cd:	80 39 00             	cmpb   $0x0,(%ecx)
  8009d0:	74 14                	je     8009e6 <strnlen+0x26>
  8009d2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009d7:	83 c0 01             	add    $0x1,%eax
  8009da:	39 d0                	cmp    %edx,%eax
  8009dc:	74 0d                	je     8009eb <strnlen+0x2b>
  8009de:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  8009e2:	74 07                	je     8009eb <strnlen+0x2b>
  8009e4:	eb f1                	jmp    8009d7 <strnlen+0x17>
  8009e6:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  8009eb:	5d                   	pop    %ebp
  8009ec:	8d 74 26 00          	lea    0x0(%esi),%esi
  8009f0:	c3                   	ret    

008009f1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	53                   	push   %ebx
  8009f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009fb:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009fd:	0f b6 01             	movzbl (%ecx),%eax
  800a00:	88 02                	mov    %al,(%edx)
  800a02:	83 c2 01             	add    $0x1,%edx
  800a05:	83 c1 01             	add    $0x1,%ecx
  800a08:	84 c0                	test   %al,%al
  800a0a:	75 f1                	jne    8009fd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a0c:	89 d8                	mov    %ebx,%eax
  800a0e:	5b                   	pop    %ebx
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	57                   	push   %edi
  800a15:	56                   	push   %esi
  800a16:	53                   	push   %ebx
  800a17:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a1d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a20:	85 f6                	test   %esi,%esi
  800a22:	74 1c                	je     800a40 <strncpy+0x2f>
  800a24:	89 fa                	mov    %edi,%edx
  800a26:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  800a2b:	0f b6 01             	movzbl (%ecx),%eax
  800a2e:	88 02                	mov    %al,(%edx)
  800a30:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a33:	80 39 01             	cmpb   $0x1,(%ecx)
  800a36:	83 d9 ff             	sbb    $0xffffffff,%ecx
  800a39:	83 c3 01             	add    $0x1,%ebx
  800a3c:	39 f3                	cmp    %esi,%ebx
  800a3e:	75 eb                	jne    800a2b <strncpy+0x1a>
	}
	return ret;
}
  800a40:	89 f8                	mov    %edi,%eax
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5f                   	pop    %edi
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	56                   	push   %esi
  800a4b:	53                   	push   %ebx
  800a4c:	8b 75 08             	mov    0x8(%ebp),%esi
  800a4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a52:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a55:	89 f0                	mov    %esi,%eax
  800a57:	85 d2                	test   %edx,%edx
  800a59:	74 2c                	je     800a87 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800a5b:	89 d3                	mov    %edx,%ebx
  800a5d:	83 eb 01             	sub    $0x1,%ebx
  800a60:	74 20                	je     800a82 <strlcpy+0x3b>
  800a62:	0f b6 11             	movzbl (%ecx),%edx
  800a65:	84 d2                	test   %dl,%dl
  800a67:	74 19                	je     800a82 <strlcpy+0x3b>
  800a69:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800a6b:	88 10                	mov    %dl,(%eax)
  800a6d:	83 c0 01             	add    $0x1,%eax
  800a70:	83 eb 01             	sub    $0x1,%ebx
  800a73:	74 0f                	je     800a84 <strlcpy+0x3d>
  800a75:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  800a79:	83 c1 01             	add    $0x1,%ecx
  800a7c:	84 d2                	test   %dl,%dl
  800a7e:	74 04                	je     800a84 <strlcpy+0x3d>
  800a80:	eb e9                	jmp    800a6b <strlcpy+0x24>
  800a82:	89 f0                	mov    %esi,%eax
		*dst = '\0';
  800a84:	c6 00 00             	movb   $0x0,(%eax)
  800a87:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800a89:	5b                   	pop    %ebx
  800a8a:	5e                   	pop    %esi
  800a8b:	5d                   	pop    %ebp
  800a8c:	c3                   	ret    

00800a8d <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	57                   	push   %edi
  800a91:	56                   	push   %esi
  800a92:	53                   	push   %ebx
  800a93:	8b 55 08             	mov    0x8(%ebp),%edx
  800a96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a99:	8b 7d 10             	mov    0x10(%ebp),%edi
    int c;
    char *q = buf;

    if (buf_size <= 0)
  800a9c:	85 c9                	test   %ecx,%ecx
  800a9e:	7e 30                	jle    800ad0 <pstrcpy+0x43>
        return;

    for(;;) {
        c = *str++;
  800aa0:	0f b6 07             	movzbl (%edi),%eax
        if (c == 0 || q >= buf + buf_size - 1)
  800aa3:	84 c0                	test   %al,%al
  800aa5:	74 26                	je     800acd <pstrcpy+0x40>
  800aa7:	8d 74 0a ff          	lea    0xffffffff(%edx,%ecx,1),%esi
  800aab:	0f be d8             	movsbl %al,%ebx
  800aae:	89 f9                	mov    %edi,%ecx
  800ab0:	39 f2                	cmp    %esi,%edx
  800ab2:	72 09                	jb     800abd <pstrcpy+0x30>
  800ab4:	eb 17                	jmp    800acd <pstrcpy+0x40>
  800ab6:	83 c1 01             	add    $0x1,%ecx
  800ab9:	39 f2                	cmp    %esi,%edx
  800abb:	73 10                	jae    800acd <pstrcpy+0x40>
            break;
        *q++ = c;
  800abd:	88 1a                	mov    %bl,(%edx)
  800abf:	83 c2 01             	add    $0x1,%edx
  800ac2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800ac6:	0f be d8             	movsbl %al,%ebx
  800ac9:	84 c0                	test   %al,%al
  800acb:	75 e9                	jne    800ab6 <pstrcpy+0x29>
    }
    *q = '\0';
  800acd:	c6 02 00             	movb   $0x0,(%edx)
}
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5f                   	pop    %edi
  800ad3:	5d                   	pop    %ebp
  800ad4:	c3                   	ret    

00800ad5 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	8b 55 08             	mov    0x8(%ebp),%edx
  800adb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  800ade:	0f b6 02             	movzbl (%edx),%eax
  800ae1:	84 c0                	test   %al,%al
  800ae3:	74 16                	je     800afb <strcmp+0x26>
  800ae5:	3a 01                	cmp    (%ecx),%al
  800ae7:	75 12                	jne    800afb <strcmp+0x26>
		p++, q++;
  800ae9:	83 c1 01             	add    $0x1,%ecx
  800aec:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  800af0:	84 c0                	test   %al,%al
  800af2:	74 07                	je     800afb <strcmp+0x26>
  800af4:	83 c2 01             	add    $0x1,%edx
  800af7:	3a 01                	cmp    (%ecx),%al
  800af9:	74 ee                	je     800ae9 <strcmp+0x14>
  800afb:	0f b6 c0             	movzbl %al,%eax
  800afe:	0f b6 11             	movzbl (%ecx),%edx
  800b01:	29 d0                	sub    %edx,%eax
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    

00800b05 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	53                   	push   %ebx
  800b09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b0f:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b12:	85 d2                	test   %edx,%edx
  800b14:	74 2d                	je     800b43 <strncmp+0x3e>
  800b16:	0f b6 01             	movzbl (%ecx),%eax
  800b19:	84 c0                	test   %al,%al
  800b1b:	74 1a                	je     800b37 <strncmp+0x32>
  800b1d:	3a 03                	cmp    (%ebx),%al
  800b1f:	75 16                	jne    800b37 <strncmp+0x32>
  800b21:	83 ea 01             	sub    $0x1,%edx
  800b24:	74 1d                	je     800b43 <strncmp+0x3e>
		n--, p++, q++;
  800b26:	83 c1 01             	add    $0x1,%ecx
  800b29:	83 c3 01             	add    $0x1,%ebx
  800b2c:	0f b6 01             	movzbl (%ecx),%eax
  800b2f:	84 c0                	test   %al,%al
  800b31:	74 04                	je     800b37 <strncmp+0x32>
  800b33:	3a 03                	cmp    (%ebx),%al
  800b35:	74 ea                	je     800b21 <strncmp+0x1c>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b37:	0f b6 11             	movzbl (%ecx),%edx
  800b3a:	0f b6 03             	movzbl (%ebx),%eax
  800b3d:	29 c2                	sub    %eax,%edx
  800b3f:	89 d0                	mov    %edx,%eax
  800b41:	eb 05                	jmp    800b48 <strncmp+0x43>
  800b43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b48:	5b                   	pop    %ebx
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b55:	0f b6 10             	movzbl (%eax),%edx
  800b58:	84 d2                	test   %dl,%dl
  800b5a:	74 16                	je     800b72 <strchr+0x27>
		if (*s == c)
  800b5c:	38 ca                	cmp    %cl,%dl
  800b5e:	75 06                	jne    800b66 <strchr+0x1b>
  800b60:	eb 15                	jmp    800b77 <strchr+0x2c>
  800b62:	38 ca                	cmp    %cl,%dl
  800b64:	74 11                	je     800b77 <strchr+0x2c>
  800b66:	83 c0 01             	add    $0x1,%eax
  800b69:	0f b6 10             	movzbl (%eax),%edx
  800b6c:	84 d2                	test   %dl,%dl
  800b6e:	66 90                	xchg   %ax,%ax
  800b70:	75 f0                	jne    800b62 <strchr+0x17>
  800b72:	b8 00 00 00 00       	mov    $0x0,%eax
			return (char *) s;
	return 0;
}
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b83:	0f b6 10             	movzbl (%eax),%edx
  800b86:	84 d2                	test   %dl,%dl
  800b88:	74 14                	je     800b9e <strfind+0x25>
		if (*s == c)
  800b8a:	38 ca                	cmp    %cl,%dl
  800b8c:	75 06                	jne    800b94 <strfind+0x1b>
  800b8e:	eb 0e                	jmp    800b9e <strfind+0x25>
  800b90:	38 ca                	cmp    %cl,%dl
  800b92:	74 0a                	je     800b9e <strfind+0x25>
  800b94:	83 c0 01             	add    $0x1,%eax
  800b97:	0f b6 10             	movzbl (%eax),%edx
  800b9a:	84 d2                	test   %dl,%dl
  800b9c:	75 f2                	jne    800b90 <strfind+0x17>
			break;
	return (char *) s;
}
  800b9e:	5d                   	pop    %ebp
  800b9f:	90                   	nop    
  800ba0:	c3                   	ret    

00800ba1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	83 ec 08             	sub    $0x8,%esp
  800ba7:	89 1c 24             	mov    %ebx,(%esp)
  800baa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bae:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bb1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800bb7:	85 db                	test   %ebx,%ebx
  800bb9:	74 32                	je     800bed <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bbb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bc1:	75 25                	jne    800be8 <memset+0x47>
  800bc3:	f6 c3 03             	test   $0x3,%bl
  800bc6:	75 20                	jne    800be8 <memset+0x47>
		c &= 0xFF;
  800bc8:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bcb:	89 d0                	mov    %edx,%eax
  800bcd:	c1 e0 18             	shl    $0x18,%eax
  800bd0:	89 d1                	mov    %edx,%ecx
  800bd2:	c1 e1 10             	shl    $0x10,%ecx
  800bd5:	09 c8                	or     %ecx,%eax
  800bd7:	09 d0                	or     %edx,%eax
  800bd9:	c1 e2 08             	shl    $0x8,%edx
  800bdc:	09 d0                	or     %edx,%eax
  800bde:	89 d9                	mov    %ebx,%ecx
  800be0:	c1 e9 02             	shr    $0x2,%ecx
  800be3:	fc                   	cld    
  800be4:	f3 ab                	rep stos %eax,%es:(%edi)
  800be6:	eb 05                	jmp    800bed <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800be8:	89 d9                	mov    %ebx,%ecx
  800bea:	fc                   	cld    
  800beb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bed:	89 f8                	mov    %edi,%eax
  800bef:	8b 1c 24             	mov    (%esp),%ebx
  800bf2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800bf6:	89 ec                	mov    %ebp,%esp
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	83 ec 08             	sub    $0x8,%esp
  800c00:	89 34 24             	mov    %esi,(%esp)
  800c03:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c07:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800c0d:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800c10:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800c12:	39 c6                	cmp    %eax,%esi
  800c14:	73 36                	jae    800c4c <memmove+0x52>
  800c16:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c19:	39 d0                	cmp    %edx,%eax
  800c1b:	73 2f                	jae    800c4c <memmove+0x52>
		s += n;
		d += n;
  800c1d:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c20:	f6 c2 03             	test   $0x3,%dl
  800c23:	75 1b                	jne    800c40 <memmove+0x46>
  800c25:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c2b:	75 13                	jne    800c40 <memmove+0x46>
  800c2d:	f6 c1 03             	test   $0x3,%cl
  800c30:	75 0e                	jne    800c40 <memmove+0x46>
			asm volatile("std; rep movsl\n"
  800c32:	8d 7e fc             	lea    0xfffffffc(%esi),%edi
  800c35:	8d 72 fc             	lea    0xfffffffc(%edx),%esi
  800c38:	c1 e9 02             	shr    $0x2,%ecx
  800c3b:	fd                   	std    
  800c3c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c3e:	eb 09                	jmp    800c49 <memmove+0x4f>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c40:	8d 7e ff             	lea    0xffffffff(%esi),%edi
  800c43:	8d 72 ff             	lea    0xffffffff(%edx),%esi
  800c46:	fd                   	std    
  800c47:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c49:	fc                   	cld    
  800c4a:	eb 21                	jmp    800c6d <memmove+0x73>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c4c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c52:	75 16                	jne    800c6a <memmove+0x70>
  800c54:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c5a:	75 0e                	jne    800c6a <memmove+0x70>
  800c5c:	f6 c1 03             	test   $0x3,%cl
  800c5f:	90                   	nop    
  800c60:	75 08                	jne    800c6a <memmove+0x70>
			asm volatile("cld; rep movsl\n"
  800c62:	c1 e9 02             	shr    $0x2,%ecx
  800c65:	fc                   	cld    
  800c66:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c68:	eb 03                	jmp    800c6d <memmove+0x73>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c6a:	fc                   	cld    
  800c6b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c6d:	8b 34 24             	mov    (%esp),%esi
  800c70:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c74:	89 ec                	mov    %ebp,%esp
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    

00800c78 <memcpy>:

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
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c7e:	8b 45 10             	mov    0x10(%ebp),%eax
  800c81:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c85:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c88:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8f:	89 04 24             	mov    %eax,(%esp)
  800c92:	e8 63 ff ff ff       	call   800bfa <memmove>
}
  800c97:	c9                   	leave  
  800c98:	c3                   	ret    

00800c99 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	56                   	push   %esi
  800c9d:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c9e:	8b 75 10             	mov    0x10(%ebp),%esi
  800ca1:	83 ee 01             	sub    $0x1,%esi
  800ca4:	83 fe ff             	cmp    $0xffffffff,%esi
  800ca7:	74 38                	je     800ce1 <memcmp+0x48>
  800ca9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cac:	8b 55 0c             	mov    0xc(%ebp),%edx
		if (*s1 != *s2)
  800caf:	0f b6 18             	movzbl (%eax),%ebx
  800cb2:	0f b6 0a             	movzbl (%edx),%ecx
  800cb5:	38 cb                	cmp    %cl,%bl
  800cb7:	74 20                	je     800cd9 <memcmp+0x40>
  800cb9:	eb 12                	jmp    800ccd <memcmp+0x34>
  800cbb:	0f b6 58 01          	movzbl 0x1(%eax),%ebx
  800cbf:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
  800cc3:	83 c0 01             	add    $0x1,%eax
  800cc6:	83 c2 01             	add    $0x1,%edx
  800cc9:	38 cb                	cmp    %cl,%bl
  800ccb:	74 0c                	je     800cd9 <memcmp+0x40>
			return (int) *s1 - (int) *s2;
  800ccd:	0f b6 d3             	movzbl %bl,%edx
  800cd0:	0f b6 c1             	movzbl %cl,%eax
  800cd3:	29 c2                	sub    %eax,%edx
  800cd5:	89 d0                	mov    %edx,%eax
  800cd7:	eb 0d                	jmp    800ce6 <memcmp+0x4d>
  800cd9:	83 ee 01             	sub    $0x1,%esi
  800cdc:	83 fe ff             	cmp    $0xffffffff,%esi
  800cdf:	75 da                	jne    800cbb <memcmp+0x22>
  800ce1:	b8 00 00 00 00       	mov    $0x0,%eax
		s1++, s2++;
	}

	return 0;
}
  800ce6:	5b                   	pop    %ebx
  800ce7:	5e                   	pop    %esi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	53                   	push   %ebx
  800cee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800cf1:	89 da                	mov    %ebx,%edx
  800cf3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cf6:	39 d3                	cmp    %edx,%ebx
  800cf8:	73 1a                	jae    800d14 <memfind+0x2a>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cfa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
			break;
  800cfe:	89 d8                	mov    %ebx,%eax
  800d00:	38 0b                	cmp    %cl,(%ebx)
  800d02:	75 06                	jne    800d0a <memfind+0x20>
  800d04:	eb 0e                	jmp    800d14 <memfind+0x2a>
  800d06:	38 08                	cmp    %cl,(%eax)
  800d08:	74 0c                	je     800d16 <memfind+0x2c>
  800d0a:	83 c0 01             	add    $0x1,%eax
  800d0d:	39 d0                	cmp    %edx,%eax
  800d0f:	90                   	nop    
  800d10:	75 f4                	jne    800d06 <memfind+0x1c>
  800d12:	eb 02                	jmp    800d16 <memfind+0x2c>
  800d14:	89 d8                	mov    %ebx,%eax
	return (void *) s;
}
  800d16:	5b                   	pop    %ebx
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    

00800d19 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	57                   	push   %edi
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
  800d1f:	83 ec 04             	sub    $0x4,%esp
  800d22:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d25:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d28:	0f b6 03             	movzbl (%ebx),%eax
  800d2b:	3c 20                	cmp    $0x20,%al
  800d2d:	74 04                	je     800d33 <strtol+0x1a>
  800d2f:	3c 09                	cmp    $0x9,%al
  800d31:	75 0e                	jne    800d41 <strtol+0x28>
		s++;
  800d33:	83 c3 01             	add    $0x1,%ebx
  800d36:	0f b6 03             	movzbl (%ebx),%eax
  800d39:	3c 20                	cmp    $0x20,%al
  800d3b:	74 f6                	je     800d33 <strtol+0x1a>
  800d3d:	3c 09                	cmp    $0x9,%al
  800d3f:	74 f2                	je     800d33 <strtol+0x1a>

	// plus/minus sign
	if (*s == '+')
  800d41:	3c 2b                	cmp    $0x2b,%al
  800d43:	75 0d                	jne    800d52 <strtol+0x39>
		s++;
  800d45:	83 c3 01             	add    $0x1,%ebx
  800d48:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800d4f:	90                   	nop    
  800d50:	eb 15                	jmp    800d67 <strtol+0x4e>
	else if (*s == '-')
  800d52:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800d59:	3c 2d                	cmp    $0x2d,%al
  800d5b:	75 0a                	jne    800d67 <strtol+0x4e>
		s++, neg = 1;
  800d5d:	83 c3 01             	add    $0x1,%ebx
  800d60:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d67:	85 f6                	test   %esi,%esi
  800d69:	0f 94 c0             	sete   %al
  800d6c:	84 c0                	test   %al,%al
  800d6e:	75 05                	jne    800d75 <strtol+0x5c>
  800d70:	83 fe 10             	cmp    $0x10,%esi
  800d73:	75 17                	jne    800d8c <strtol+0x73>
  800d75:	80 3b 30             	cmpb   $0x30,(%ebx)
  800d78:	75 12                	jne    800d8c <strtol+0x73>
  800d7a:	80 7b 01 78          	cmpb   $0x78,0x1(%ebx)
  800d7e:	66 90                	xchg   %ax,%ax
  800d80:	75 0a                	jne    800d8c <strtol+0x73>
		s += 2, base = 16;
  800d82:	83 c3 02             	add    $0x2,%ebx
  800d85:	be 10 00 00 00       	mov    $0x10,%esi
  800d8a:	eb 1f                	jmp    800dab <strtol+0x92>
	else if (base == 0 && s[0] == '0')
  800d8c:	85 f6                	test   %esi,%esi
  800d8e:	66 90                	xchg   %ax,%ax
  800d90:	75 10                	jne    800da2 <strtol+0x89>
  800d92:	80 3b 30             	cmpb   $0x30,(%ebx)
  800d95:	75 0b                	jne    800da2 <strtol+0x89>
		s++, base = 8;
  800d97:	83 c3 01             	add    $0x1,%ebx
  800d9a:	66 be 08 00          	mov    $0x8,%si
  800d9e:	66 90                	xchg   %ax,%ax
  800da0:	eb 09                	jmp    800dab <strtol+0x92>
	else if (base == 0)
  800da2:	84 c0                	test   %al,%al
  800da4:	74 05                	je     800dab <strtol+0x92>
  800da6:	be 0a 00 00 00       	mov    $0xa,%esi
  800dab:	bf 00 00 00 00       	mov    $0x0,%edi
		base = 10;

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800db0:	0f b6 13             	movzbl (%ebx),%edx
  800db3:	89 d1                	mov    %edx,%ecx
  800db5:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800db8:	3c 09                	cmp    $0x9,%al
  800dba:	77 08                	ja     800dc4 <strtol+0xab>
			dig = *s - '0';
  800dbc:	0f be c2             	movsbl %dl,%eax
  800dbf:	8d 50 d0             	lea    0xffffffd0(%eax),%edx
  800dc2:	eb 1c                	jmp    800de0 <strtol+0xc7>
		else if (*s >= 'a' && *s <= 'z')
  800dc4:	8d 41 9f             	lea    0xffffff9f(%ecx),%eax
  800dc7:	3c 19                	cmp    $0x19,%al
  800dc9:	77 08                	ja     800dd3 <strtol+0xba>
			dig = *s - 'a' + 10;
  800dcb:	0f be c2             	movsbl %dl,%eax
  800dce:	8d 50 a9             	lea    0xffffffa9(%eax),%edx
  800dd1:	eb 0d                	jmp    800de0 <strtol+0xc7>
		else if (*s >= 'A' && *s <= 'Z')
  800dd3:	8d 41 bf             	lea    0xffffffbf(%ecx),%eax
  800dd6:	3c 19                	cmp    $0x19,%al
  800dd8:	77 17                	ja     800df1 <strtol+0xd8>
			dig = *s - 'A' + 10;
  800dda:	0f be c2             	movsbl %dl,%eax
  800ddd:	8d 50 c9             	lea    0xffffffc9(%eax),%edx
		else
			break;
		if (dig >= base)
  800de0:	39 f2                	cmp    %esi,%edx
  800de2:	7d 0d                	jge    800df1 <strtol+0xd8>
			break;
		s++, val = (val * base) + dig;
  800de4:	83 c3 01             	add    $0x1,%ebx
  800de7:	89 f8                	mov    %edi,%eax
  800de9:	0f af c6             	imul   %esi,%eax
  800dec:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800def:	eb bf                	jmp    800db0 <strtol+0x97>
		// we don't properly detect overflow!
	}
  800df1:	89 f8                	mov    %edi,%eax

	if (endptr)
  800df3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800df7:	74 05                	je     800dfe <strtol+0xe5>
		*endptr = (char *) s;
  800df9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dfc:	89 1a                	mov    %ebx,(%edx)
	return (neg ? -val : val);
  800dfe:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800e02:	74 04                	je     800e08 <strtol+0xef>
  800e04:	89 c7                	mov    %eax,%edi
  800e06:	f7 df                	neg    %edi
}
  800e08:	89 f8                	mov    %edi,%eax
  800e0a:	83 c4 04             	add    $0x4,%esp
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5f                   	pop    %edi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    
	...

00800e14 <sys_cgetc>:
}

int
sys_cgetc(void)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	83 ec 0c             	sub    $0xc,%esp
  800e1a:	89 1c 24             	mov    %ebx,(%esp)
  800e1d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e21:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e25:	b8 01 00 00 00       	mov    $0x1,%eax
  800e2a:	bf 00 00 00 00       	mov    $0x0,%edi
  800e2f:	89 fa                	mov    %edi,%edx
  800e31:	89 f9                	mov    %edi,%ecx
  800e33:	89 fb                	mov    %edi,%ebx
  800e35:	89 fe                	mov    %edi,%esi
  800e37:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e39:	8b 1c 24             	mov    (%esp),%ebx
  800e3c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e40:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e44:	89 ec                	mov    %ebp,%esp
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    

00800e48 <sys_cputs>:
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	83 ec 0c             	sub    $0xc,%esp
  800e4e:	89 1c 24             	mov    %ebx,(%esp)
  800e51:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e55:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e59:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5f:	bf 00 00 00 00       	mov    $0x0,%edi
  800e64:	89 f8                	mov    %edi,%eax
  800e66:	89 fb                	mov    %edi,%ebx
  800e68:	89 fe                	mov    %edi,%esi
  800e6a:	cd 30                	int    $0x30
  800e6c:	8b 1c 24             	mov    (%esp),%ebx
  800e6f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e73:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e77:	89 ec                	mov    %ebp,%esp
  800e79:	5d                   	pop    %ebp
  800e7a:	c3                   	ret    

00800e7b <sys_time_msec>:

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
  800e7b:	55                   	push   %ebp
  800e7c:	89 e5                	mov    %esp,%ebp
  800e7e:	83 ec 0c             	sub    $0xc,%esp
  800e81:	89 1c 24             	mov    %ebx,(%esp)
  800e84:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e88:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e8c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e91:	bf 00 00 00 00       	mov    $0x0,%edi
  800e96:	89 fa                	mov    %edi,%edx
  800e98:	89 f9                	mov    %edi,%ecx
  800e9a:	89 fb                	mov    %edi,%ebx
  800e9c:	89 fe                	mov    %edi,%esi
  800e9e:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ea0:	8b 1c 24             	mov    (%esp),%ebx
  800ea3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ea7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800eab:	89 ec                	mov    %ebp,%esp
  800ead:	5d                   	pop    %ebp
  800eae:	c3                   	ret    

00800eaf <sys_ipc_recv>:
  800eaf:	55                   	push   %ebp
  800eb0:	89 e5                	mov    %esp,%ebp
  800eb2:	83 ec 28             	sub    $0x28,%esp
  800eb5:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800eb8:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800ebb:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800ebe:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ec6:	bf 00 00 00 00       	mov    $0x0,%edi
  800ecb:	89 f9                	mov    %edi,%ecx
  800ecd:	89 fb                	mov    %edi,%ebx
  800ecf:	89 fe                	mov    %edi,%esi
  800ed1:	cd 30                	int    $0x30
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	7e 28                	jle    800eff <sys_ipc_recv+0x50>
  800ed7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800edb:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ee2:	00 
  800ee3:	c7 44 24 08 7f 2e 80 	movl   $0x802e7f,0x8(%esp)
  800eea:	00 
  800eeb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef2:	00 
  800ef3:	c7 04 24 9c 2e 80 00 	movl   $0x802e9c,(%esp)
  800efa:	e8 9d f3 ff ff       	call   80029c <_panic>
  800eff:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800f02:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800f05:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800f08:	89 ec                	mov    %ebp,%esp
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    

00800f0c <sys_ipc_try_send>:
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	83 ec 0c             	sub    $0xc,%esp
  800f12:	89 1c 24             	mov    %ebx,(%esp)
  800f15:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f19:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f23:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f26:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f29:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f2e:	be 00 00 00 00       	mov    $0x0,%esi
  800f33:	cd 30                	int    $0x30
  800f35:	8b 1c 24             	mov    (%esp),%ebx
  800f38:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f3c:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f40:	89 ec                	mov    %ebp,%esp
  800f42:	5d                   	pop    %ebp
  800f43:	c3                   	ret    

00800f44 <sys_env_set_pgfault_upcall>:
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
  800f47:	83 ec 28             	sub    $0x28,%esp
  800f4a:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800f4d:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800f50:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800f53:	8b 55 08             	mov    0x8(%ebp),%edx
  800f56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f59:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f5e:	bf 00 00 00 00       	mov    $0x0,%edi
  800f63:	89 fb                	mov    %edi,%ebx
  800f65:	89 fe                	mov    %edi,%esi
  800f67:	cd 30                	int    $0x30
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	7e 28                	jle    800f95 <sys_env_set_pgfault_upcall+0x51>
  800f6d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f71:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f78:	00 
  800f79:	c7 44 24 08 7f 2e 80 	movl   $0x802e7f,0x8(%esp)
  800f80:	00 
  800f81:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f88:	00 
  800f89:	c7 04 24 9c 2e 80 00 	movl   $0x802e9c,(%esp)
  800f90:	e8 07 f3 ff ff       	call   80029c <_panic>
  800f95:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800f98:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800f9b:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800f9e:	89 ec                	mov    %ebp,%esp
  800fa0:	5d                   	pop    %ebp
  800fa1:	c3                   	ret    

00800fa2 <sys_env_set_trapframe>:
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	83 ec 28             	sub    $0x28,%esp
  800fa8:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800fab:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800fae:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800fb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb7:	b8 09 00 00 00       	mov    $0x9,%eax
  800fbc:	bf 00 00 00 00       	mov    $0x0,%edi
  800fc1:	89 fb                	mov    %edi,%ebx
  800fc3:	89 fe                	mov    %edi,%esi
  800fc5:	cd 30                	int    $0x30
  800fc7:	85 c0                	test   %eax,%eax
  800fc9:	7e 28                	jle    800ff3 <sys_env_set_trapframe+0x51>
  800fcb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fcf:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800fd6:	00 
  800fd7:	c7 44 24 08 7f 2e 80 	movl   $0x802e7f,0x8(%esp)
  800fde:	00 
  800fdf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fe6:	00 
  800fe7:	c7 04 24 9c 2e 80 00 	movl   $0x802e9c,(%esp)
  800fee:	e8 a9 f2 ff ff       	call   80029c <_panic>
  800ff3:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800ff6:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800ff9:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800ffc:	89 ec                	mov    %ebp,%esp
  800ffe:	5d                   	pop    %ebp
  800fff:	c3                   	ret    

00801000 <sys_env_set_status>:
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	83 ec 28             	sub    $0x28,%esp
  801006:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  801009:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  80100c:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  80100f:	8b 55 08             	mov    0x8(%ebp),%edx
  801012:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801015:	b8 08 00 00 00       	mov    $0x8,%eax
  80101a:	bf 00 00 00 00       	mov    $0x0,%edi
  80101f:	89 fb                	mov    %edi,%ebx
  801021:	89 fe                	mov    %edi,%esi
  801023:	cd 30                	int    $0x30
  801025:	85 c0                	test   %eax,%eax
  801027:	7e 28                	jle    801051 <sys_env_set_status+0x51>
  801029:	89 44 24 10          	mov    %eax,0x10(%esp)
  80102d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801034:	00 
  801035:	c7 44 24 08 7f 2e 80 	movl   $0x802e7f,0x8(%esp)
  80103c:	00 
  80103d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801044:	00 
  801045:	c7 04 24 9c 2e 80 00 	movl   $0x802e9c,(%esp)
  80104c:	e8 4b f2 ff ff       	call   80029c <_panic>
  801051:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801054:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801057:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  80105a:	89 ec                	mov    %ebp,%esp
  80105c:	5d                   	pop    %ebp
  80105d:	c3                   	ret    

0080105e <sys_page_unmap>:
  80105e:	55                   	push   %ebp
  80105f:	89 e5                	mov    %esp,%ebp
  801061:	83 ec 28             	sub    $0x28,%esp
  801064:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  801067:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  80106a:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  80106d:	8b 55 08             	mov    0x8(%ebp),%edx
  801070:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801073:	b8 06 00 00 00       	mov    $0x6,%eax
  801078:	bf 00 00 00 00       	mov    $0x0,%edi
  80107d:	89 fb                	mov    %edi,%ebx
  80107f:	89 fe                	mov    %edi,%esi
  801081:	cd 30                	int    $0x30
  801083:	85 c0                	test   %eax,%eax
  801085:	7e 28                	jle    8010af <sys_page_unmap+0x51>
  801087:	89 44 24 10          	mov    %eax,0x10(%esp)
  80108b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801092:	00 
  801093:	c7 44 24 08 7f 2e 80 	movl   $0x802e7f,0x8(%esp)
  80109a:	00 
  80109b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010a2:	00 
  8010a3:	c7 04 24 9c 2e 80 00 	movl   $0x802e9c,(%esp)
  8010aa:	e8 ed f1 ff ff       	call   80029c <_panic>
  8010af:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  8010b2:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  8010b5:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  8010b8:	89 ec                	mov    %ebp,%esp
  8010ba:	5d                   	pop    %ebp
  8010bb:	c3                   	ret    

008010bc <sys_page_map>:
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	83 ec 28             	sub    $0x28,%esp
  8010c2:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  8010c5:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  8010c8:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  8010cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010d4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010d7:	8b 75 18             	mov    0x18(%ebp),%esi
  8010da:	b8 05 00 00 00       	mov    $0x5,%eax
  8010df:	cd 30                	int    $0x30
  8010e1:	85 c0                	test   %eax,%eax
  8010e3:	7e 28                	jle    80110d <sys_page_map+0x51>
  8010e5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010e9:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8010f0:	00 
  8010f1:	c7 44 24 08 7f 2e 80 	movl   $0x802e7f,0x8(%esp)
  8010f8:	00 
  8010f9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801100:	00 
  801101:	c7 04 24 9c 2e 80 00 	movl   $0x802e9c,(%esp)
  801108:	e8 8f f1 ff ff       	call   80029c <_panic>
  80110d:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801110:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801113:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801116:	89 ec                	mov    %ebp,%esp
  801118:	5d                   	pop    %ebp
  801119:	c3                   	ret    

0080111a <sys_page_alloc>:
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	83 ec 28             	sub    $0x28,%esp
  801120:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  801123:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  801126:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  801129:	8b 55 08             	mov    0x8(%ebp),%edx
  80112c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801132:	b8 04 00 00 00       	mov    $0x4,%eax
  801137:	bf 00 00 00 00       	mov    $0x0,%edi
  80113c:	89 fe                	mov    %edi,%esi
  80113e:	cd 30                	int    $0x30
  801140:	85 c0                	test   %eax,%eax
  801142:	7e 28                	jle    80116c <sys_page_alloc+0x52>
  801144:	89 44 24 10          	mov    %eax,0x10(%esp)
  801148:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80114f:	00 
  801150:	c7 44 24 08 7f 2e 80 	movl   $0x802e7f,0x8(%esp)
  801157:	00 
  801158:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80115f:	00 
  801160:	c7 04 24 9c 2e 80 00 	movl   $0x802e9c,(%esp)
  801167:	e8 30 f1 ff ff       	call   80029c <_panic>
  80116c:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  80116f:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801172:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801175:	89 ec                	mov    %ebp,%esp
  801177:	5d                   	pop    %ebp
  801178:	c3                   	ret    

00801179 <sys_yield>:
  801179:	55                   	push   %ebp
  80117a:	89 e5                	mov    %esp,%ebp
  80117c:	83 ec 0c             	sub    $0xc,%esp
  80117f:	89 1c 24             	mov    %ebx,(%esp)
  801182:	89 74 24 04          	mov    %esi,0x4(%esp)
  801186:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80118a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80118f:	bf 00 00 00 00       	mov    $0x0,%edi
  801194:	89 fa                	mov    %edi,%edx
  801196:	89 f9                	mov    %edi,%ecx
  801198:	89 fb                	mov    %edi,%ebx
  80119a:	89 fe                	mov    %edi,%esi
  80119c:	cd 30                	int    $0x30
  80119e:	8b 1c 24             	mov    (%esp),%ebx
  8011a1:	8b 74 24 04          	mov    0x4(%esp),%esi
  8011a5:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8011a9:	89 ec                	mov    %ebp,%esp
  8011ab:	5d                   	pop    %ebp
  8011ac:	c3                   	ret    

008011ad <sys_getenvid>:
  8011ad:	55                   	push   %ebp
  8011ae:	89 e5                	mov    %esp,%ebp
  8011b0:	83 ec 0c             	sub    $0xc,%esp
  8011b3:	89 1c 24             	mov    %ebx,(%esp)
  8011b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011ba:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8011be:	b8 02 00 00 00       	mov    $0x2,%eax
  8011c3:	bf 00 00 00 00       	mov    $0x0,%edi
  8011c8:	89 fa                	mov    %edi,%edx
  8011ca:	89 f9                	mov    %edi,%ecx
  8011cc:	89 fb                	mov    %edi,%ebx
  8011ce:	89 fe                	mov    %edi,%esi
  8011d0:	cd 30                	int    $0x30
  8011d2:	8b 1c 24             	mov    (%esp),%ebx
  8011d5:	8b 74 24 04          	mov    0x4(%esp),%esi
  8011d9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8011dd:	89 ec                	mov    %ebp,%esp
  8011df:	5d                   	pop    %ebp
  8011e0:	c3                   	ret    

008011e1 <sys_env_destroy>:
  8011e1:	55                   	push   %ebp
  8011e2:	89 e5                	mov    %esp,%ebp
  8011e4:	83 ec 28             	sub    $0x28,%esp
  8011e7:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  8011ea:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  8011ed:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  8011f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f3:	b8 03 00 00 00       	mov    $0x3,%eax
  8011f8:	bf 00 00 00 00       	mov    $0x0,%edi
  8011fd:	89 f9                	mov    %edi,%ecx
  8011ff:	89 fb                	mov    %edi,%ebx
  801201:	89 fe                	mov    %edi,%esi
  801203:	cd 30                	int    $0x30
  801205:	85 c0                	test   %eax,%eax
  801207:	7e 28                	jle    801231 <sys_env_destroy+0x50>
  801209:	89 44 24 10          	mov    %eax,0x10(%esp)
  80120d:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801214:	00 
  801215:	c7 44 24 08 7f 2e 80 	movl   $0x802e7f,0x8(%esp)
  80121c:	00 
  80121d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801224:	00 
  801225:	c7 04 24 9c 2e 80 00 	movl   $0x802e9c,(%esp)
  80122c:	e8 6b f0 ff ff       	call   80029c <_panic>
  801231:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801234:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801237:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  80123a:	89 ec                	mov    %ebp,%esp
  80123c:	5d                   	pop    %ebp
  80123d:	c3                   	ret    
	...

00801240 <duppage>:
// It is also OK to panic on error.
// 
static int
duppage(envid_t envid, unsigned pn)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	53                   	push   %ebx
  801244:	83 ec 14             	sub    $0x14,%esp
  801247:	89 c1                	mov    %eax,%ecx
	int r;

	// LAB 4: Your code here.
	pde_t *pde;
	pte_t *pte;
	void *addr=(void*)(pn*PGSIZE);
  801249:	89 d3                	mov    %edx,%ebx
  80124b:	c1 e3 0c             	shl    $0xc,%ebx
	pde =(pde_t*) &vpd[VPD(addr)];
	if(*pde&PTE_P)
  80124e:	89 d8                	mov    %ebx,%eax
  801250:	c1 e8 16             	shr    $0x16,%eax
  801253:	f6 04 85 00 d0 7b ef 	testb  $0x1,0xef7bd000(,%eax,4)
  80125a:	01 
  80125b:	74 14                	je     801271 <duppage+0x31>
	{
		pte=(pte_t*)&vpt[VPN(addr)];
	}
	else    panic("page table for pn page is not exist");
	if((*pte&PTE_W)||(*pte&PTE_COW))
  80125d:	89 d8                	mov    %ebx,%eax
  80125f:	c1 e8 0c             	shr    $0xc,%eax
  801262:	f7 04 85 00 00 40 ef 	testl  $0x802,0xef400000(,%eax,4)
  801269:	02 08 00 00 
  80126d:	75 1e                	jne    80128d <duppage+0x4d>
  80126f:	eb 73                	jmp    8012e4 <duppage+0xa4>
  801271:	c7 44 24 08 ac 2e 80 	movl   $0x802eac,0x8(%esp)
  801278:	00 
  801279:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
  801280:	00 
  801281:	c7 04 24 6a 2f 80 00 	movl   $0x802f6a,(%esp)
  801288:	e8 0f f0 ff ff       	call   80029c <_panic>
	{
		if((r=sys_page_map(0,addr,envid,addr,PTE_COW|PTE_U))<0)
  80128d:	c7 44 24 10 04 08 00 	movl   $0x804,0x10(%esp)
  801294:	00 
  801295:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801299:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80129d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012a8:	e8 0f fe ff ff       	call   8010bc <sys_page_map>
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	78 60                	js     801311 <duppage+0xd1>
			return r;
		if((r=sys_page_map(0,addr,0,addr,PTE_COW|PTE_U))<0)//映射的时候注意env的id
  8012b1:	c7 44 24 10 04 08 00 	movl   $0x804,0x10(%esp)
  8012b8:	00 
  8012b9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012bd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012c4:	00 
  8012c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012d0:	e8 e7 fd ff ff       	call   8010bc <sys_page_map>
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	0f 9f c2             	setg   %dl
  8012da:	0f b6 d2             	movzbl %dl,%edx
  8012dd:	83 ea 01             	sub    $0x1,%edx
  8012e0:	21 d0                	and    %edx,%eax
  8012e2:	eb 2d                	jmp    801311 <duppage+0xd1>
                        return r;
	}
	else{	
		if((r=sys_page_map(0,addr,envid,addr,PTE_U|PTE_P))<0)
  8012e4:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8012eb:	00 
  8012ec:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012f0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012ff:	e8 b8 fd ff ff       	call   8010bc <sys_page_map>
  801304:	85 c0                	test   %eax,%eax
  801306:	0f 9f c2             	setg   %dl
  801309:	0f b6 d2             	movzbl %dl,%edx
  80130c:	83 ea 01             	sub    $0x1,%edx
  80130f:	21 d0                	and    %edx,%eax
			return r;
	}
	//panic("duppage not implemented");
	return 0;
}
  801311:	83 c4 14             	add    $0x14,%esp
  801314:	5b                   	pop    %ebx
  801315:	5d                   	pop    %ebp
  801316:	c3                   	ret    

00801317 <sfork>:

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
  801317:	55                   	push   %ebp
  801318:	89 e5                	mov    %esp,%ebp
  80131a:	57                   	push   %edi
  80131b:	56                   	push   %esi
  80131c:	53                   	push   %ebx
  80131d:	83 ec 1c             	sub    $0x1c,%esp
static __inline envid_t
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801320:	ba 07 00 00 00       	mov    $0x7,%edx
  801325:	89 d0                	mov    %edx,%eax
  801327:	cd 30                	int    $0x30
  801329:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
	int r;
	pde_t *pde;
	pte_t *pte;
	unsigned i;
	uint32_t addr;
	envid_t envid;
	envid = sys_exofork();//创建子环境
	if(envid < 0)
  80132c:	85 c0                	test   %eax,%eax
  80132e:	79 20                	jns    801350 <sfork+0x39>
		panic("sys_exofork: %e", envid);
  801330:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801334:	c7 44 24 08 75 2f 80 	movl   $0x802f75,0x8(%esp)
  80133b:	00 
  80133c:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  801343:	00 
  801344:	c7 04 24 6a 2f 80 00 	movl   $0x802f6a,(%esp)
  80134b:	e8 4c ef ff ff       	call   80029c <_panic>
	if(envid==0)//子环境中
  801350:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  801354:	75 21                	jne    801377 <sfork+0x60>
	{
		env = &envs[ENVX(sys_getenvid())];
  801356:	e8 52 fe ff ff       	call   8011ad <sys_getenvid>
  80135b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801360:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801363:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801368:	a3 40 70 80 00       	mov    %eax,0x807040
  80136d:	b8 00 00 00 00       	mov    $0x0,%eax
  801372:	e9 83 01 00 00       	jmp    8014fa <sfork+0x1e3>
		return 0;
	}
	else{//父环境中,注意：这里需要设置父环境的缺页异常栈，还需要设置子环境的缺页异常栈，
	//父子环境的页异常栈不共享？具体原因还得思考
		env = &envs[ENVX(sys_getenvid())];
  801377:	e8 31 fe ff ff       	call   8011ad <sys_getenvid>
  80137c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801381:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801384:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801389:	a3 40 70 80 00       	mov    %eax,0x807040
		set_pgfault_handler(pgfault);//设置缺页异常处理函数，这里设置了父环境的缺页异常栈
  80138e:	c7 04 24 02 15 80 00 	movl   $0x801502,(%esp)
  801395:	e8 6e 13 00 00       	call   802708 <set_pgfault_handler>
  80139a:	be 00 00 00 00       	mov    $0x0,%esi
  80139f:	bf 00 00 00 00       	mov    $0x0,%edi
		for(i=0;i<(unsigned)VPN(UTOP);i++)//重映射writable or copy-to-write的页面
		{
			addr=i*PGSIZE;
			pde =(pde_t*) &vpd[VPD(addr)];
  8013a4:	89 f8                	mov    %edi,%eax
  8013a6:	c1 e8 16             	shr    $0x16,%eax
  8013a9:	c1 e0 02             	shl    $0x2,%eax
			if(*pde&PTE_P)//这里只处理有物理页面映射的页表项
  8013ac:	f6 80 00 d0 7b ef 01 	testb  $0x1,0xef7bd000(%eax)
  8013b3:	0f 84 dc 00 00 00    	je     801495 <sfork+0x17e>
			{
				pte=(pte_t*)&vpt[VPN(addr)];
			}
			else    continue;
			if((i==(unsigned)VPN(USTACKTOP-PGSIZE))||(i==(unsigned)VPN(PFTEMP)))
  8013b9:	81 fe fd eb 0e 00    	cmp    $0xeebfd,%esi
  8013bf:	74 08                	je     8013c9 <sfork+0xb2>
  8013c1:	81 fe ff 07 00 00    	cmp    $0x7ff,%esi
  8013c7:	75 17                	jne    8013e0 <sfork+0xc9>
								//特殊处理，用户层普通栈
			{	
				if((r=duppage(envid,i))<0)
  8013c9:	89 f2                	mov    %esi,%edx
  8013cb:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8013ce:	e8 6d fe ff ff       	call   801240 <duppage>
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	0f 89 ba 00 00 00    	jns    801495 <sfork+0x17e>
  8013db:	e9 1a 01 00 00       	jmp    8014fa <sfork+0x1e3>
  8013e0:	f6 80 00 d0 7b ef 01 	testb  $0x1,0xef7bd000(%eax)
  8013e7:	74 11                	je     8013fa <sfork+0xe3>
  8013e9:	89 f8                	mov    %edi,%eax
  8013eb:	c1 e8 0c             	shr    $0xc,%eax
  8013ee:	f6 04 85 00 00 40 ef 	testb  $0x2,0xef400000(,%eax,4)
  8013f5:	02 
  8013f6:	75 1e                	jne    801416 <sfork+0xff>
  8013f8:	eb 74                	jmp    80146e <sfork+0x157>
  8013fa:	c7 44 24 08 ac 2e 80 	movl   $0x802eac,0x8(%esp)
  801401:	00 
  801402:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
  801409:	00 
  80140a:	c7 04 24 6a 2f 80 00 	movl   $0x802f6a,(%esp)
  801411:	e8 86 ee ff ff       	call   80029c <_panic>
  801416:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
  80141d:	00 
  80141e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801422:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  801425:	89 44 24 08          	mov    %eax,0x8(%esp)
  801429:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80142d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801434:	e8 83 fc ff ff       	call   8010bc <sys_page_map>
  801439:	85 c0                	test   %eax,%eax
  80143b:	0f 88 b9 00 00 00    	js     8014fa <sfork+0x1e3>
  801441:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
  801448:	00 
  801449:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80144d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801454:	00 
  801455:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801459:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801460:	e8 57 fc ff ff       	call   8010bc <sys_page_map>
  801465:	85 c0                	test   %eax,%eax
  801467:	79 2c                	jns    801495 <sfork+0x17e>
  801469:	e9 8c 00 00 00       	jmp    8014fa <sfork+0x1e3>
  80146e:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801475:	00 
  801476:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80147a:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80147d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801481:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801485:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80148c:	e8 2b fc ff ff       	call   8010bc <sys_page_map>
  801491:	85 c0                	test   %eax,%eax
  801493:	78 65                	js     8014fa <sfork+0x1e3>
  801495:	83 c6 01             	add    $0x1,%esi
  801498:	81 c7 00 10 00 00    	add    $0x1000,%edi
  80149e:	81 fe 00 ec 0e 00    	cmp    $0xeec00,%esi
  8014a4:	0f 85 fa fe ff ff    	jne    8013a4 <sfork+0x8d>
					return r;
				continue;
			}
			if((r=sduppage(envid,i))<0)
				return r;
		}
		if((r=sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  8014aa:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8014b1:	00 
  8014b2:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8014b9:	ee 
  8014ba:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8014bd:	89 04 24             	mov    %eax,(%esp)
  8014c0:	e8 55 fc ff ff       	call   80111a <sys_page_alloc>
  8014c5:	85 c0                	test   %eax,%eax
  8014c7:	78 31                	js     8014fa <sfork+0x1e3>
                        return r;//设置子环境的缺页异常栈
		if((r=sys_env_set_pgfault_upcall(envid,(void*)_pgfault_upcall))<0)
  8014c9:	c7 44 24 04 8c 27 80 	movl   $0x80278c,0x4(%esp)
  8014d0:	00 
  8014d1:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8014d4:	89 04 24             	mov    %eax,(%esp)
  8014d7:	e8 68 fa ff ff       	call   800f44 <sys_env_set_pgfault_upcall>
  8014dc:	85 c0                	test   %eax,%eax
  8014de:	78 1a                	js     8014fa <sfork+0x1e3>
			return r;//设置子环境的缺页异常处理入口点
		if((r=sys_env_set_status(envid,ENV_RUNNABLE))<0)
  8014e0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8014e7:	00 
  8014e8:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8014eb:	89 04 24             	mov    %eax,(%esp)
  8014ee:	e8 0d fb ff ff       	call   801000 <sys_env_set_status>
  8014f3:	85 c0                	test   %eax,%eax
  8014f5:	78 03                	js     8014fa <sfork+0x1e3>
  8014f7:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
			return r;//设置子环境的状态为可运行
		return envid;
	}
	//panic("sfork not implemented");
	//return -E_INVAL;
}
  8014fa:	83 c4 1c             	add    $0x1c,%esp
  8014fd:	5b                   	pop    %ebx
  8014fe:	5e                   	pop    %esi
  8014ff:	5f                   	pop    %edi
  801500:	5d                   	pop    %ebp
  801501:	c3                   	ret    

00801502 <pgfault>:
  801502:	55                   	push   %ebp
  801503:	89 e5                	mov    %esp,%ebp
  801505:	56                   	push   %esi
  801506:	53                   	push   %ebx
  801507:	83 ec 20             	sub    $0x20,%esp
  80150a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80150d:	8b 71 04             	mov    0x4(%ecx),%esi
  801510:	8b 19                	mov    (%ecx),%ebx
  801512:	89 d8                	mov    %ebx,%eax
  801514:	c1 e8 16             	shr    $0x16,%eax
  801517:	c1 e0 02             	shl    $0x2,%eax
  80151a:	8d 90 00 d0 7b ef    	lea    0xef7bd000(%eax),%edx
  801520:	f6 80 00 d0 7b ef 01 	testb  $0x1,0xef7bd000(%eax)
  801527:	74 16                	je     80153f <pgfault+0x3d>
  801529:	89 d8                	mov    %ebx,%eax
  80152b:	c1 e8 0c             	shr    $0xc,%eax
  80152e:	8d 04 85 00 00 40 ef 	lea    0xef400000(,%eax,4),%eax
  801535:	f7 c6 02 00 00 00    	test   $0x2,%esi
  80153b:	75 3f                	jne    80157c <pgfault+0x7a>
  80153d:	eb 43                	jmp    801582 <pgfault+0x80>
  80153f:	8b 41 28             	mov    0x28(%ecx),%eax
  801542:	8b 12                	mov    (%edx),%edx
  801544:	89 44 24 10          	mov    %eax,0x10(%esp)
  801548:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80154c:	89 74 24 08          	mov    %esi,0x8(%esp)
  801550:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801554:	c7 04 24 d0 2e 80 00 	movl   $0x802ed0,(%esp)
  80155b:	e8 09 ee ff ff       	call   800369 <cprintf>
  801560:	c7 44 24 08 f4 2e 80 	movl   $0x802ef4,0x8(%esp)
  801567:	00 
  801568:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80156f:	00 
  801570:	c7 04 24 6a 2f 80 00 	movl   $0x802f6a,(%esp)
  801577:	e8 20 ed ff ff       	call   80029c <_panic>
  80157c:	f6 40 01 08          	testb  $0x8,0x1(%eax)
  801580:	75 49                	jne    8015cb <pgfault+0xc9>
  801582:	8b 51 28             	mov    0x28(%ecx),%edx
  801585:	8b 08                	mov    (%eax),%ecx
  801587:	a1 40 70 80 00       	mov    0x807040,%eax
  80158c:	8b 40 4c             	mov    0x4c(%eax),%eax
  80158f:	89 54 24 14          	mov    %edx,0x14(%esp)
  801593:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801597:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80159b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80159f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a3:	c7 04 24 1c 2f 80 00 	movl   $0x802f1c,(%esp)
  8015aa:	e8 ba ed ff ff       	call   800369 <cprintf>
  8015af:	c7 44 24 08 85 2f 80 	movl   $0x802f85,0x8(%esp)
  8015b6:	00 
  8015b7:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8015be:	00 
  8015bf:	c7 04 24 6a 2f 80 00 	movl   $0x802f6a,(%esp)
  8015c6:	e8 d1 ec ff ff       	call   80029c <_panic>
  8015cb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8015d2:	00 
  8015d3:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8015da:	00 
  8015db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015e2:	e8 33 fb ff ff       	call   80111a <sys_page_alloc>
  8015e7:	85 c0                	test   %eax,%eax
  8015e9:	79 20                	jns    80160b <pgfault+0x109>
  8015eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015ef:	c7 44 24 08 48 2f 80 	movl   $0x802f48,0x8(%esp)
  8015f6:	00 
  8015f7:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8015fe:	00 
  8015ff:	c7 04 24 6a 2f 80 00 	movl   $0x802f6a,(%esp)
  801606:	e8 91 ec ff ff       	call   80029c <_panic>
  80160b:	89 de                	mov    %ebx,%esi
  80160d:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  801613:	89 f2                	mov    %esi,%edx
  801615:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  80161b:	89 c3                	mov    %eax,%ebx
  80161d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801623:	39 de                	cmp    %ebx,%esi
  801625:	73 13                	jae    80163a <pgfault+0x138>
  801627:	b9 00 f0 7f 00       	mov    $0x7ff000,%ecx
  80162c:	8b 02                	mov    (%edx),%eax
  80162e:	89 01                	mov    %eax,(%ecx)
  801630:	83 c1 04             	add    $0x4,%ecx
  801633:	83 c2 04             	add    $0x4,%edx
  801636:	39 d3                	cmp    %edx,%ebx
  801638:	77 f2                	ja     80162c <pgfault+0x12a>
  80163a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801641:	00 
  801642:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801646:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80164d:	00 
  80164e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801655:	00 
  801656:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80165d:	e8 5a fa ff ff       	call   8010bc <sys_page_map>
  801662:	85 c0                	test   %eax,%eax
  801664:	79 1c                	jns    801682 <pgfault+0x180>
  801666:	c7 44 24 08 a0 2f 80 	movl   $0x802fa0,0x8(%esp)
  80166d:	00 
  80166e:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801675:	00 
  801676:	c7 04 24 6a 2f 80 00 	movl   $0x802f6a,(%esp)
  80167d:	e8 1a ec ff ff       	call   80029c <_panic>
  801682:	83 c4 20             	add    $0x20,%esp
  801685:	5b                   	pop    %ebx
  801686:	5e                   	pop    %esi
  801687:	5d                   	pop    %ebp
  801688:	c3                   	ret    

00801689 <fork>:
  801689:	55                   	push   %ebp
  80168a:	89 e5                	mov    %esp,%ebp
  80168c:	56                   	push   %esi
  80168d:	53                   	push   %ebx
  80168e:	83 ec 10             	sub    $0x10,%esp
static __inline envid_t
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801691:	ba 07 00 00 00       	mov    $0x7,%edx
  801696:	89 d0                	mov    %edx,%eax
  801698:	cd 30                	int    $0x30
  80169a:	89 c6                	mov    %eax,%esi
  80169c:	85 c0                	test   %eax,%eax
  80169e:	79 20                	jns    8016c0 <fork+0x37>
  8016a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016a4:	c7 44 24 08 75 2f 80 	movl   $0x802f75,0x8(%esp)
  8016ab:	00 
  8016ac:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  8016b3:	00 
  8016b4:	c7 04 24 6a 2f 80 00 	movl   $0x802f6a,(%esp)
  8016bb:	e8 dc eb ff ff       	call   80029c <_panic>
  8016c0:	85 c0                	test   %eax,%eax
  8016c2:	75 21                	jne    8016e5 <fork+0x5c>
  8016c4:	e8 e4 fa ff ff       	call   8011ad <sys_getenvid>
  8016c9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8016ce:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8016d1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8016d6:	a3 40 70 80 00       	mov    %eax,0x807040
  8016db:	b8 00 00 00 00       	mov    $0x0,%eax
  8016e0:	e9 9f 00 00 00       	jmp    801784 <fork+0xfb>
  8016e5:	c7 04 24 02 15 80 00 	movl   $0x801502,(%esp)
  8016ec:	e8 17 10 00 00       	call   802708 <set_pgfault_handler>
  8016f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016f6:	eb 08                	jmp    801700 <fork+0x77>
  8016f8:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  8016fe:	74 3e                	je     80173e <fork+0xb5>
  801700:	89 da                	mov    %ebx,%edx
  801702:	c1 e2 0c             	shl    $0xc,%edx
  801705:	89 d0                	mov    %edx,%eax
  801707:	c1 e8 16             	shr    $0x16,%eax
  80170a:	f6 04 85 00 d0 7b ef 	testb  $0x1,0xef7bd000(,%eax,4)
  801711:	01 
  801712:	74 1f                	je     801733 <fork+0xaa>
  801714:	89 d0                	mov    %edx,%eax
  801716:	c1 e8 0c             	shr    $0xc,%eax
  801719:	f7 04 85 00 00 40 ef 	testl  $0x802,0xef400000(,%eax,4)
  801720:	02 08 00 00 
  801724:	74 0d                	je     801733 <fork+0xaa>
  801726:	89 da                	mov    %ebx,%edx
  801728:	89 f0                	mov    %esi,%eax
  80172a:	e8 11 fb ff ff       	call   801240 <duppage>
  80172f:	85 c0                	test   %eax,%eax
  801731:	78 51                	js     801784 <fork+0xfb>
  801733:	83 c3 01             	add    $0x1,%ebx
  801736:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  80173c:	75 ba                	jne    8016f8 <fork+0x6f>
  80173e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801745:	00 
  801746:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80174d:	ee 
  80174e:	89 34 24             	mov    %esi,(%esp)
  801751:	e8 c4 f9 ff ff       	call   80111a <sys_page_alloc>
  801756:	85 c0                	test   %eax,%eax
  801758:	78 2a                	js     801784 <fork+0xfb>
  80175a:	c7 44 24 04 8c 27 80 	movl   $0x80278c,0x4(%esp)
  801761:	00 
  801762:	89 34 24             	mov    %esi,(%esp)
  801765:	e8 da f7 ff ff       	call   800f44 <sys_env_set_pgfault_upcall>
  80176a:	85 c0                	test   %eax,%eax
  80176c:	78 16                	js     801784 <fork+0xfb>
  80176e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801775:	00 
  801776:	89 34 24             	mov    %esi,(%esp)
  801779:	e8 82 f8 ff ff       	call   801000 <sys_env_set_status>
  80177e:	85 c0                	test   %eax,%eax
  801780:	78 02                	js     801784 <fork+0xfb>
  801782:	89 f0                	mov    %esi,%eax
  801784:	83 c4 10             	add    $0x10,%esp
  801787:	5b                   	pop    %ebx
  801788:	5e                   	pop    %esi
  801789:	5d                   	pop    %ebp
  80178a:	c3                   	ret    
  80178b:	00 00                	add    %al,(%eax)
  80178d:	00 00                	add    %al,(%eax)
	...

00801790 <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	57                   	push   %edi
  801794:	56                   	push   %esi
  801795:	53                   	push   %ebx
  801796:	83 ec 1c             	sub    $0x1c,%esp
  801799:	8b 75 08             	mov    0x8(%ebp),%esi
  80179c:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  80179f:	e8 09 fa ff ff       	call   8011ad <sys_getenvid>
  8017a4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8017a9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8017ac:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8017b1:	a3 40 70 80 00       	mov    %eax,0x807040
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  8017b6:	e8 f2 f9 ff ff       	call   8011ad <sys_getenvid>
  8017bb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8017c0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8017c3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8017c8:	a3 40 70 80 00       	mov    %eax,0x807040
		if(env->env_id==to_env){
  8017cd:	8b 40 4c             	mov    0x4c(%eax),%eax
  8017d0:	39 f0                	cmp    %esi,%eax
  8017d2:	75 0e                	jne    8017e2 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  8017d4:	c7 04 24 b4 2f 80 00 	movl   $0x802fb4,(%esp)
  8017db:	e8 89 eb ff ff       	call   800369 <cprintf>
  8017e0:	eb 5a                	jmp    80183c <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  8017e2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8017e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8017e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f4:	89 34 24             	mov    %esi,(%esp)
  8017f7:	e8 10 f7 ff ff       	call   800f0c <sys_ipc_try_send>
  8017fc:	89 c3                	mov    %eax,%ebx
  8017fe:	85 c0                	test   %eax,%eax
  801800:	79 25                	jns    801827 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  801802:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801805:	74 2b                	je     801832 <ipc_send+0xa2>
				panic("send error:%e",r);
  801807:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80180b:	c7 44 24 08 d0 2f 80 	movl   $0x802fd0,0x8(%esp)
  801812:	00 
  801813:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80181a:	00 
  80181b:	c7 04 24 de 2f 80 00 	movl   $0x802fde,(%esp)
  801822:	e8 75 ea ff ff       	call   80029c <_panic>
		}
			sys_yield();
  801827:	e8 4d f9 ff ff       	call   801179 <sys_yield>
		
	}while(r!=0);
  80182c:	85 db                	test   %ebx,%ebx
  80182e:	75 86                	jne    8017b6 <ipc_send+0x26>
  801830:	eb 0a                	jmp    80183c <ipc_send+0xac>
  801832:	e8 42 f9 ff ff       	call   801179 <sys_yield>
  801837:	e9 7a ff ff ff       	jmp    8017b6 <ipc_send+0x26>
	return;
	//panic("ipc_send not implemented");
}
  80183c:	83 c4 1c             	add    $0x1c,%esp
  80183f:	5b                   	pop    %ebx
  801840:	5e                   	pop    %esi
  801841:	5f                   	pop    %edi
  801842:	5d                   	pop    %ebp
  801843:	c3                   	ret    

00801844 <ipc_recv>:
  801844:	55                   	push   %ebp
  801845:	89 e5                	mov    %esp,%ebp
  801847:	57                   	push   %edi
  801848:	56                   	push   %esi
  801849:	53                   	push   %ebx
  80184a:	83 ec 0c             	sub    $0xc,%esp
  80184d:	8b 75 08             	mov    0x8(%ebp),%esi
  801850:	8b 7d 10             	mov    0x10(%ebp),%edi
  801853:	e8 55 f9 ff ff       	call   8011ad <sys_getenvid>
  801858:	25 ff 03 00 00       	and    $0x3ff,%eax
  80185d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801860:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801865:	a3 40 70 80 00       	mov    %eax,0x807040
  80186a:	85 f6                	test   %esi,%esi
  80186c:	74 29                	je     801897 <ipc_recv+0x53>
  80186e:	8b 40 4c             	mov    0x4c(%eax),%eax
  801871:	3b 06                	cmp    (%esi),%eax
  801873:	75 22                	jne    801897 <ipc_recv+0x53>
  801875:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80187b:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801881:	c7 04 24 b4 2f 80 00 	movl   $0x802fb4,(%esp)
  801888:	e8 dc ea ff ff       	call   800369 <cprintf>
  80188d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801892:	e9 8a 00 00 00       	jmp    801921 <ipc_recv+0xdd>
  801897:	e8 11 f9 ff ff       	call   8011ad <sys_getenvid>
  80189c:	25 ff 03 00 00       	and    $0x3ff,%eax
  8018a1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8018a4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8018a9:	a3 40 70 80 00       	mov    %eax,0x807040
  8018ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b1:	89 04 24             	mov    %eax,(%esp)
  8018b4:	e8 f6 f5 ff ff       	call   800eaf <sys_ipc_recv>
  8018b9:	89 c3                	mov    %eax,%ebx
  8018bb:	85 c0                	test   %eax,%eax
  8018bd:	79 1a                	jns    8018d9 <ipc_recv+0x95>
  8018bf:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8018c5:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8018cb:	c7 04 24 e8 2f 80 00 	movl   $0x802fe8,(%esp)
  8018d2:	e8 92 ea ff ff       	call   800369 <cprintf>
  8018d7:	eb 48                	jmp    801921 <ipc_recv+0xdd>
  8018d9:	e8 cf f8 ff ff       	call   8011ad <sys_getenvid>
  8018de:	25 ff 03 00 00       	and    $0x3ff,%eax
  8018e3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8018e6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8018eb:	a3 40 70 80 00       	mov    %eax,0x807040
  8018f0:	85 f6                	test   %esi,%esi
  8018f2:	74 05                	je     8018f9 <ipc_recv+0xb5>
  8018f4:	8b 40 74             	mov    0x74(%eax),%eax
  8018f7:	89 06                	mov    %eax,(%esi)
  8018f9:	85 ff                	test   %edi,%edi
  8018fb:	74 0a                	je     801907 <ipc_recv+0xc3>
  8018fd:	a1 40 70 80 00       	mov    0x807040,%eax
  801902:	8b 40 78             	mov    0x78(%eax),%eax
  801905:	89 07                	mov    %eax,(%edi)
  801907:	e8 a1 f8 ff ff       	call   8011ad <sys_getenvid>
  80190c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801911:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801914:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801919:	a3 40 70 80 00       	mov    %eax,0x807040
  80191e:	8b 58 70             	mov    0x70(%eax),%ebx
  801921:	89 d8                	mov    %ebx,%eax
  801923:	83 c4 0c             	add    $0xc,%esp
  801926:	5b                   	pop    %ebx
  801927:	5e                   	pop    %esi
  801928:	5f                   	pop    %edi
  801929:	5d                   	pop    %ebp
  80192a:	c3                   	ret    
  80192b:	00 00                	add    %al,(%eax)
  80192d:	00 00                	add    %al,(%eax)
	...

00801930 <fd2num>:
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	8b 45 08             	mov    0x8(%ebp),%eax
  801936:	05 00 00 00 30       	add    $0x30000000,%eax
  80193b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80193e:	5d                   	pop    %ebp
  80193f:	c3                   	ret    

00801940 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801946:	8b 45 08             	mov    0x8(%ebp),%eax
  801949:	89 04 24             	mov    %eax,(%esp)
  80194c:	e8 df ff ff ff       	call   801930 <fd2num>
  801951:	c1 e0 0c             	shl    $0xc,%eax
  801954:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801959:	c9                   	leave  
  80195a:	c3                   	ret    

0080195b <fd_alloc>:

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
  80195b:	55                   	push   %ebp
  80195c:	89 e5                	mov    %esp,%ebp
  80195e:	53                   	push   %ebx
  80195f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801962:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  801967:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801969:	89 d0                	mov    %edx,%eax
  80196b:	c1 e8 16             	shr    $0x16,%eax
  80196e:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  801975:	a8 01                	test   $0x1,%al
  801977:	74 10                	je     801989 <fd_alloc+0x2e>
  801979:	89 d0                	mov    %edx,%eax
  80197b:	c1 e8 0c             	shr    $0xc,%eax
  80197e:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  801985:	a8 01                	test   $0x1,%al
  801987:	75 09                	jne    801992 <fd_alloc+0x37>
			*fd_store = fd;
  801989:	89 0b                	mov    %ecx,(%ebx)
  80198b:	b8 00 00 00 00       	mov    $0x0,%eax
  801990:	eb 19                	jmp    8019ab <fd_alloc+0x50>
			return 0;
  801992:	81 c2 00 10 00 00    	add    $0x1000,%edx
  801998:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  80199e:	75 c7                	jne    801967 <fd_alloc+0xc>
		}
	}
	*fd_store = 0;
  8019a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8019a6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8019ab:	5b                   	pop    %ebx
  8019ac:	5d                   	pop    %ebp
  8019ad:	c3                   	ret    

008019ae <fd_lookup>:

// Check that fdnum is in range and mapped.
// If it is, set *fd_store to the fd page virtual address.
//
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8019ae:	55                   	push   %ebp
  8019af:	89 e5                	mov    %esp,%ebp
  8019b1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8019b4:	83 f8 1f             	cmp    $0x1f,%eax
  8019b7:	77 35                	ja     8019ee <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8019b9:	c1 e0 0c             	shl    $0xc,%eax
  8019bc:	8d 90 00 00 00 d0    	lea    0xd0000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  8019c2:	89 d0                	mov    %edx,%eax
  8019c4:	c1 e8 16             	shr    $0x16,%eax
  8019c7:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  8019ce:	a8 01                	test   $0x1,%al
  8019d0:	74 1c                	je     8019ee <fd_lookup+0x40>
  8019d2:	89 d0                	mov    %edx,%eax
  8019d4:	c1 e8 0c             	shr    $0xc,%eax
  8019d7:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  8019de:	a8 01                	test   $0x1,%al
  8019e0:	74 0c                	je     8019ee <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8019e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e5:	89 10                	mov    %edx,(%eax)
  8019e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ec:	eb 05                	jmp    8019f3 <fd_lookup+0x45>
	return 0;
  8019ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8019f3:	5d                   	pop    %ebp
  8019f4:	c3                   	ret    

008019f5 <seek>:

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
  8019f5:	55                   	push   %ebp
  8019f6:	89 e5                	mov    %esp,%ebp
  8019f8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019fb:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  8019fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a02:	8b 45 08             	mov    0x8(%ebp),%eax
  801a05:	89 04 24             	mov    %eax,(%esp)
  801a08:	e8 a1 ff ff ff       	call   8019ae <fd_lookup>
  801a0d:	85 c0                	test   %eax,%eax
  801a0f:	78 0e                	js     801a1f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801a11:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a14:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  801a17:	89 50 04             	mov    %edx,0x4(%eax)
  801a1a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801a1f:	c9                   	leave  
  801a20:	c3                   	ret    

00801a21 <dev_lookup>:
  801a21:	55                   	push   %ebp
  801a22:	89 e5                	mov    %esp,%ebp
  801a24:	53                   	push   %ebx
  801a25:	83 ec 14             	sub    $0x14,%esp
  801a28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a2b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a2e:	ba 04 70 80 00       	mov    $0x807004,%edx
  801a33:	b8 00 00 00 00       	mov    $0x0,%eax
  801a38:	39 0d 04 70 80 00    	cmp    %ecx,0x807004
  801a3e:	75 12                	jne    801a52 <dev_lookup+0x31>
  801a40:	eb 04                	jmp    801a46 <dev_lookup+0x25>
  801a42:	39 0a                	cmp    %ecx,(%edx)
  801a44:	75 0c                	jne    801a52 <dev_lookup+0x31>
  801a46:	89 13                	mov    %edx,(%ebx)
  801a48:	b8 00 00 00 00       	mov    $0x0,%eax
  801a4d:	8d 76 00             	lea    0x0(%esi),%esi
  801a50:	eb 35                	jmp    801a87 <dev_lookup+0x66>
  801a52:	83 c0 01             	add    $0x1,%eax
  801a55:	8b 14 85 74 30 80 00 	mov    0x803074(,%eax,4),%edx
  801a5c:	85 d2                	test   %edx,%edx
  801a5e:	75 e2                	jne    801a42 <dev_lookup+0x21>
  801a60:	a1 40 70 80 00       	mov    0x807040,%eax
  801a65:	8b 40 4c             	mov    0x4c(%eax),%eax
  801a68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a70:	c7 04 24 f8 2f 80 00 	movl   $0x802ff8,(%esp)
  801a77:	e8 ed e8 ff ff       	call   800369 <cprintf>
  801a7c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a82:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a87:	83 c4 14             	add    $0x14,%esp
  801a8a:	5b                   	pop    %ebx
  801a8b:	5d                   	pop    %ebp
  801a8c:	c3                   	ret    

00801a8d <fstat>:

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
  801a8d:	55                   	push   %ebp
  801a8e:	89 e5                	mov    %esp,%ebp
  801a90:	53                   	push   %ebx
  801a91:	83 ec 24             	sub    $0x24,%esp
  801a94:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a97:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  801a9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa1:	89 04 24             	mov    %eax,(%esp)
  801aa4:	e8 05 ff ff ff       	call   8019ae <fd_lookup>
  801aa9:	89 c2                	mov    %eax,%edx
  801aab:	85 c0                	test   %eax,%eax
  801aad:	78 57                	js     801b06 <fstat+0x79>
  801aaf:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab6:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801ab9:	8b 00                	mov    (%eax),%eax
  801abb:	89 04 24             	mov    %eax,(%esp)
  801abe:	e8 5e ff ff ff       	call   801a21 <dev_lookup>
  801ac3:	89 c2                	mov    %eax,%edx
  801ac5:	85 c0                	test   %eax,%eax
  801ac7:	78 3d                	js     801b06 <fstat+0x79>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801ac9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  801ace:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
  801ad1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801ad5:	74 2f                	je     801b06 <fstat+0x79>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801ad7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801ada:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801ae1:	00 00 00 
	stat->st_isdir = 0;
  801ae4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801aeb:	00 00 00 
	stat->st_dev = dev;
  801aee:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801af1:	89 93 88 00 00 00    	mov    %edx,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801af7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801afb:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801afe:	89 04 24             	mov    %eax,(%esp)
  801b01:	ff 52 14             	call   *0x14(%edx)
  801b04:	89 c2                	mov    %eax,%edx
}
  801b06:	89 d0                	mov    %edx,%eax
  801b08:	83 c4 24             	add    $0x24,%esp
  801b0b:	5b                   	pop    %ebx
  801b0c:	5d                   	pop    %ebp
  801b0d:	c3                   	ret    

00801b0e <ftruncate>:
  801b0e:	55                   	push   %ebp
  801b0f:	89 e5                	mov    %esp,%ebp
  801b11:	53                   	push   %ebx
  801b12:	83 ec 24             	sub    $0x24,%esp
  801b15:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b18:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  801b1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b1f:	89 1c 24             	mov    %ebx,(%esp)
  801b22:	e8 87 fe ff ff       	call   8019ae <fd_lookup>
  801b27:	85 c0                	test   %eax,%eax
  801b29:	78 61                	js     801b8c <ftruncate+0x7e>
  801b2b:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801b2e:	8b 10                	mov    (%eax),%edx
  801b30:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801b33:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b37:	89 14 24             	mov    %edx,(%esp)
  801b3a:	e8 e2 fe ff ff       	call   801a21 <dev_lookup>
  801b3f:	85 c0                	test   %eax,%eax
  801b41:	78 49                	js     801b8c <ftruncate+0x7e>
  801b43:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  801b46:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801b4a:	75 23                	jne    801b6f <ftruncate+0x61>
  801b4c:	a1 40 70 80 00       	mov    0x807040,%eax
  801b51:	8b 40 4c             	mov    0x4c(%eax),%eax
  801b54:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b58:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b5c:	c7 04 24 18 30 80 00 	movl   $0x803018,(%esp)
  801b63:	e8 01 e8 ff ff       	call   800369 <cprintf>
  801b68:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b6d:	eb 1d                	jmp    801b8c <ftruncate+0x7e>
  801b6f:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801b72:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b77:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  801b7b:	74 0f                	je     801b8c <ftruncate+0x7e>
  801b7d:	8b 52 18             	mov    0x18(%edx),%edx
  801b80:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b83:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b87:	89 0c 24             	mov    %ecx,(%esp)
  801b8a:	ff d2                	call   *%edx
  801b8c:	83 c4 24             	add    $0x24,%esp
  801b8f:	5b                   	pop    %ebx
  801b90:	5d                   	pop    %ebp
  801b91:	c3                   	ret    

00801b92 <write>:
  801b92:	55                   	push   %ebp
  801b93:	89 e5                	mov    %esp,%ebp
  801b95:	53                   	push   %ebx
  801b96:	83 ec 24             	sub    $0x24,%esp
  801b99:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b9c:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  801b9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba3:	89 1c 24             	mov    %ebx,(%esp)
  801ba6:	e8 03 fe ff ff       	call   8019ae <fd_lookup>
  801bab:	85 c0                	test   %eax,%eax
  801bad:	78 68                	js     801c17 <write+0x85>
  801baf:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801bb2:	8b 10                	mov    (%eax),%edx
  801bb4:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801bb7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bbb:	89 14 24             	mov    %edx,(%esp)
  801bbe:	e8 5e fe ff ff       	call   801a21 <dev_lookup>
  801bc3:	85 c0                	test   %eax,%eax
  801bc5:	78 50                	js     801c17 <write+0x85>
  801bc7:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  801bca:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  801bce:	75 23                	jne    801bf3 <write+0x61>
  801bd0:	a1 40 70 80 00       	mov    0x807040,%eax
  801bd5:	8b 40 4c             	mov    0x4c(%eax),%eax
  801bd8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bdc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be0:	c7 04 24 39 30 80 00 	movl   $0x803039,(%esp)
  801be7:	e8 7d e7 ff ff       	call   800369 <cprintf>
  801bec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801bf1:	eb 24                	jmp    801c17 <write+0x85>
  801bf3:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801bf6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801bfb:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  801bff:	74 16                	je     801c17 <write+0x85>
  801c01:	8b 42 0c             	mov    0xc(%edx),%eax
  801c04:	8b 55 10             	mov    0x10(%ebp),%edx
  801c07:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c0e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c12:	89 0c 24             	mov    %ecx,(%esp)
  801c15:	ff d0                	call   *%eax
  801c17:	83 c4 24             	add    $0x24,%esp
  801c1a:	5b                   	pop    %ebx
  801c1b:	5d                   	pop    %ebp
  801c1c:	c3                   	ret    

00801c1d <read>:
  801c1d:	55                   	push   %ebp
  801c1e:	89 e5                	mov    %esp,%ebp
  801c20:	53                   	push   %ebx
  801c21:	83 ec 24             	sub    $0x24,%esp
  801c24:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801c27:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  801c2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c2e:	89 1c 24             	mov    %ebx,(%esp)
  801c31:	e8 78 fd ff ff       	call   8019ae <fd_lookup>
  801c36:	85 c0                	test   %eax,%eax
  801c38:	78 6d                	js     801ca7 <read+0x8a>
  801c3a:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801c3d:	8b 10                	mov    (%eax),%edx
  801c3f:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  801c42:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c46:	89 14 24             	mov    %edx,(%esp)
  801c49:	e8 d3 fd ff ff       	call   801a21 <dev_lookup>
  801c4e:	85 c0                	test   %eax,%eax
  801c50:	78 55                	js     801ca7 <read+0x8a>
  801c52:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  801c55:	8b 41 08             	mov    0x8(%ecx),%eax
  801c58:	83 e0 03             	and    $0x3,%eax
  801c5b:	83 f8 01             	cmp    $0x1,%eax
  801c5e:	75 23                	jne    801c83 <read+0x66>
  801c60:	a1 40 70 80 00       	mov    0x807040,%eax
  801c65:	8b 40 4c             	mov    0x4c(%eax),%eax
  801c68:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c70:	c7 04 24 56 30 80 00 	movl   $0x803056,(%esp)
  801c77:	e8 ed e6 ff ff       	call   800369 <cprintf>
  801c7c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c81:	eb 24                	jmp    801ca7 <read+0x8a>
  801c83:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  801c86:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c8b:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  801c8f:	74 16                	je     801ca7 <read+0x8a>
  801c91:	8b 42 08             	mov    0x8(%edx),%eax
  801c94:	8b 55 10             	mov    0x10(%ebp),%edx
  801c97:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c9b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c9e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ca2:	89 0c 24             	mov    %ecx,(%esp)
  801ca5:	ff d0                	call   *%eax
  801ca7:	83 c4 24             	add    $0x24,%esp
  801caa:	5b                   	pop    %ebx
  801cab:	5d                   	pop    %ebp
  801cac:	c3                   	ret    

00801cad <readn>:
  801cad:	55                   	push   %ebp
  801cae:	89 e5                	mov    %esp,%ebp
  801cb0:	57                   	push   %edi
  801cb1:	56                   	push   %esi
  801cb2:	53                   	push   %ebx
  801cb3:	83 ec 0c             	sub    $0xc,%esp
  801cb6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801cb9:	8b 75 10             	mov    0x10(%ebp),%esi
  801cbc:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc1:	85 f6                	test   %esi,%esi
  801cc3:	74 36                	je     801cfb <readn+0x4e>
  801cc5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cca:	ba 00 00 00 00       	mov    $0x0,%edx
  801ccf:	89 f0                	mov    %esi,%eax
  801cd1:	29 d0                	sub    %edx,%eax
  801cd3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cd7:	8d 04 17             	lea    (%edi,%edx,1),%eax
  801cda:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cde:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce1:	89 04 24             	mov    %eax,(%esp)
  801ce4:	e8 34 ff ff ff       	call   801c1d <read>
  801ce9:	85 c0                	test   %eax,%eax
  801ceb:	78 0e                	js     801cfb <readn+0x4e>
  801ced:	85 c0                	test   %eax,%eax
  801cef:	74 08                	je     801cf9 <readn+0x4c>
  801cf1:	01 c3                	add    %eax,%ebx
  801cf3:	89 da                	mov    %ebx,%edx
  801cf5:	39 f3                	cmp    %esi,%ebx
  801cf7:	72 d6                	jb     801ccf <readn+0x22>
  801cf9:	89 d8                	mov    %ebx,%eax
  801cfb:	83 c4 0c             	add    $0xc,%esp
  801cfe:	5b                   	pop    %ebx
  801cff:	5e                   	pop    %esi
  801d00:	5f                   	pop    %edi
  801d01:	5d                   	pop    %ebp
  801d02:	c3                   	ret    

00801d03 <fd_close>:
  801d03:	55                   	push   %ebp
  801d04:	89 e5                	mov    %esp,%ebp
  801d06:	83 ec 28             	sub    $0x28,%esp
  801d09:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  801d0c:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  801d0f:	8b 75 08             	mov    0x8(%ebp),%esi
  801d12:	89 34 24             	mov    %esi,(%esp)
  801d15:	e8 16 fc ff ff       	call   801930 <fd2num>
  801d1a:	8d 55 f4             	lea    0xfffffff4(%ebp),%edx
  801d1d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d21:	89 04 24             	mov    %eax,(%esp)
  801d24:	e8 85 fc ff ff       	call   8019ae <fd_lookup>
  801d29:	89 c3                	mov    %eax,%ebx
  801d2b:	85 c0                	test   %eax,%eax
  801d2d:	78 05                	js     801d34 <fd_close+0x31>
  801d2f:	3b 75 f4             	cmp    0xfffffff4(%ebp),%esi
  801d32:	74 0e                	je     801d42 <fd_close+0x3f>
  801d34:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d38:	75 45                	jne    801d7f <fd_close+0x7c>
  801d3a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d3f:	90                   	nop    
  801d40:	eb 3d                	jmp    801d7f <fd_close+0x7c>
  801d42:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  801d45:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d49:	8b 06                	mov    (%esi),%eax
  801d4b:	89 04 24             	mov    %eax,(%esp)
  801d4e:	e8 ce fc ff ff       	call   801a21 <dev_lookup>
  801d53:	89 c3                	mov    %eax,%ebx
  801d55:	85 c0                	test   %eax,%eax
  801d57:	78 16                	js     801d6f <fd_close+0x6c>
  801d59:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  801d5c:	8b 40 10             	mov    0x10(%eax),%eax
  801d5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d64:	85 c0                	test   %eax,%eax
  801d66:	74 07                	je     801d6f <fd_close+0x6c>
  801d68:	89 34 24             	mov    %esi,(%esp)
  801d6b:	ff d0                	call   *%eax
  801d6d:	89 c3                	mov    %eax,%ebx
  801d6f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d73:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d7a:	e8 df f2 ff ff       	call   80105e <sys_page_unmap>
  801d7f:	89 d8                	mov    %ebx,%eax
  801d81:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  801d84:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  801d87:	89 ec                	mov    %ebp,%esp
  801d89:	5d                   	pop    %ebp
  801d8a:	c3                   	ret    

00801d8b <close>:
  801d8b:	55                   	push   %ebp
  801d8c:	89 e5                	mov    %esp,%ebp
  801d8e:	83 ec 18             	sub    $0x18,%esp
  801d91:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  801d94:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d98:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9b:	89 04 24             	mov    %eax,(%esp)
  801d9e:	e8 0b fc ff ff       	call   8019ae <fd_lookup>
  801da3:	85 c0                	test   %eax,%eax
  801da5:	78 13                	js     801dba <close+0x2f>
  801da7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801dae:	00 
  801daf:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  801db2:	89 04 24             	mov    %eax,(%esp)
  801db5:	e8 49 ff ff ff       	call   801d03 <fd_close>
  801dba:	c9                   	leave  
  801dbb:	c3                   	ret    

00801dbc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801dbc:	55                   	push   %ebp
  801dbd:	89 e5                	mov    %esp,%ebp
  801dbf:	83 ec 18             	sub    $0x18,%esp
  801dc2:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  801dc5:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801dc8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801dcf:	00 
  801dd0:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd3:	89 04 24             	mov    %eax,(%esp)
  801dd6:	e8 58 03 00 00       	call   802133 <open>
  801ddb:	89 c6                	mov    %eax,%esi
  801ddd:	85 c0                	test   %eax,%eax
  801ddf:	78 1b                	js     801dfc <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801de1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801de8:	89 34 24             	mov    %esi,(%esp)
  801deb:	e8 9d fc ff ff       	call   801a8d <fstat>
  801df0:	89 c3                	mov    %eax,%ebx
	close(fd);
  801df2:	89 34 24             	mov    %esi,(%esp)
  801df5:	e8 91 ff ff ff       	call   801d8b <close>
  801dfa:	89 de                	mov    %ebx,%esi
	return r;
}
  801dfc:	89 f0                	mov    %esi,%eax
  801dfe:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  801e01:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  801e04:	89 ec                	mov    %ebp,%esp
  801e06:	5d                   	pop    %ebp
  801e07:	c3                   	ret    

00801e08 <dup>:
  801e08:	55                   	push   %ebp
  801e09:	89 e5                	mov    %esp,%ebp
  801e0b:	83 ec 38             	sub    $0x38,%esp
  801e0e:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  801e11:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  801e14:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  801e17:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e1a:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  801e1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e21:	8b 45 08             	mov    0x8(%ebp),%eax
  801e24:	89 04 24             	mov    %eax,(%esp)
  801e27:	e8 82 fb ff ff       	call   8019ae <fd_lookup>
  801e2c:	89 c3                	mov    %eax,%ebx
  801e2e:	85 c0                	test   %eax,%eax
  801e30:	0f 88 e1 00 00 00    	js     801f17 <dup+0x10f>
  801e36:	89 3c 24             	mov    %edi,(%esp)
  801e39:	e8 4d ff ff ff       	call   801d8b <close>
  801e3e:	89 f8                	mov    %edi,%eax
  801e40:	c1 e0 0c             	shl    $0xc,%eax
  801e43:	8d b0 00 00 00 d0    	lea    0xd0000000(%eax),%esi
  801e49:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  801e4c:	89 04 24             	mov    %eax,(%esp)
  801e4f:	e8 ec fa ff ff       	call   801940 <fd2data>
  801e54:	89 c3                	mov    %eax,%ebx
  801e56:	89 34 24             	mov    %esi,(%esp)
  801e59:	e8 e2 fa ff ff       	call   801940 <fd2data>
  801e5e:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  801e61:	89 d8                	mov    %ebx,%eax
  801e63:	c1 e8 16             	shr    $0x16,%eax
  801e66:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  801e6d:	a8 01                	test   $0x1,%al
  801e6f:	74 45                	je     801eb6 <dup+0xae>
  801e71:	89 da                	mov    %ebx,%edx
  801e73:	c1 ea 0c             	shr    $0xc,%edx
  801e76:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  801e7d:	a8 01                	test   $0x1,%al
  801e7f:	74 35                	je     801eb6 <dup+0xae>
  801e81:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  801e88:	25 07 0e 00 00       	and    $0xe07,%eax
  801e8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e91:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  801e94:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e98:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e9f:	00 
  801ea0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ea4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eab:	e8 0c f2 ff ff       	call   8010bc <sys_page_map>
  801eb0:	89 c3                	mov    %eax,%ebx
  801eb2:	85 c0                	test   %eax,%eax
  801eb4:	78 3e                	js     801ef4 <dup+0xec>
  801eb6:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  801eb9:	89 d0                	mov    %edx,%eax
  801ebb:	c1 e8 0c             	shr    $0xc,%eax
  801ebe:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  801ec5:	25 07 0e 00 00       	and    $0xe07,%eax
  801eca:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ece:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801ed2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ed9:	00 
  801eda:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ede:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ee5:	e8 d2 f1 ff ff       	call   8010bc <sys_page_map>
  801eea:	89 c3                	mov    %eax,%ebx
  801eec:	85 c0                	test   %eax,%eax
  801eee:	78 04                	js     801ef4 <dup+0xec>
  801ef0:	89 fb                	mov    %edi,%ebx
  801ef2:	eb 23                	jmp    801f17 <dup+0x10f>
  801ef4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ef8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eff:	e8 5a f1 ff ff       	call   80105e <sys_page_unmap>
  801f04:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  801f07:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f12:	e8 47 f1 ff ff       	call   80105e <sys_page_unmap>
  801f17:	89 d8                	mov    %ebx,%eax
  801f19:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  801f1c:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  801f1f:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  801f22:	89 ec                	mov    %ebp,%esp
  801f24:	5d                   	pop    %ebp
  801f25:	c3                   	ret    

00801f26 <close_all>:
  801f26:	55                   	push   %ebp
  801f27:	89 e5                	mov    %esp,%ebp
  801f29:	53                   	push   %ebx
  801f2a:	83 ec 04             	sub    $0x4,%esp
  801f2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f32:	89 1c 24             	mov    %ebx,(%esp)
  801f35:	e8 51 fe ff ff       	call   801d8b <close>
  801f3a:	83 c3 01             	add    $0x1,%ebx
  801f3d:	83 fb 20             	cmp    $0x20,%ebx
  801f40:	75 f0                	jne    801f32 <close_all+0xc>
  801f42:	83 c4 04             	add    $0x4,%esp
  801f45:	5b                   	pop    %ebx
  801f46:	5d                   	pop    %ebp
  801f47:	c3                   	ret    

00801f48 <fsipc>:
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801f48:	55                   	push   %ebp
  801f49:	89 e5                	mov    %esp,%ebp
  801f4b:	53                   	push   %ebx
  801f4c:	83 ec 14             	sub    $0x14,%esp
  801f4f:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801f51:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  801f57:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801f5e:	00 
  801f5f:	c7 44 24 08 00 40 80 	movl   $0x804000,0x8(%esp)
  801f66:	00 
  801f67:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f6b:	89 14 24             	mov    %edx,(%esp)
  801f6e:	e8 1d f8 ff ff       	call   801790 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801f73:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f7a:	00 
  801f7b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f86:	e8 b9 f8 ff ff       	call   801844 <ipc_recv>
}
  801f8b:	83 c4 14             	add    $0x14,%esp
  801f8e:	5b                   	pop    %ebx
  801f8f:	5d                   	pop    %ebp
  801f90:	c3                   	ret    

00801f91 <sync>:

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
  801f91:	55                   	push   %ebp
  801f92:	89 e5                	mov    %esp,%ebp
  801f94:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801f97:	ba 00 00 00 00       	mov    $0x0,%edx
  801f9c:	b8 08 00 00 00       	mov    $0x8,%eax
  801fa1:	e8 a2 ff ff ff       	call   801f48 <fsipc>
}
  801fa6:	c9                   	leave  
  801fa7:	c3                   	ret    

00801fa8 <devfile_trunc>:
  801fa8:	55                   	push   %ebp
  801fa9:	89 e5                	mov    %esp,%ebp
  801fab:	83 ec 08             	sub    $0x8,%esp
  801fae:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb1:	8b 40 0c             	mov    0xc(%eax),%eax
  801fb4:	a3 00 40 80 00       	mov    %eax,0x804000
  801fb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fbc:	a3 04 40 80 00       	mov    %eax,0x804004
  801fc1:	ba 00 00 00 00       	mov    $0x0,%edx
  801fc6:	b8 02 00 00 00       	mov    $0x2,%eax
  801fcb:	e8 78 ff ff ff       	call   801f48 <fsipc>
  801fd0:	c9                   	leave  
  801fd1:	c3                   	ret    

00801fd2 <devfile_flush>:
  801fd2:	55                   	push   %ebp
  801fd3:	89 e5                	mov    %esp,%ebp
  801fd5:	83 ec 08             	sub    $0x8,%esp
  801fd8:	8b 45 08             	mov    0x8(%ebp),%eax
  801fdb:	8b 40 0c             	mov    0xc(%eax),%eax
  801fde:	a3 00 40 80 00       	mov    %eax,0x804000
  801fe3:	ba 00 00 00 00       	mov    $0x0,%edx
  801fe8:	b8 06 00 00 00       	mov    $0x6,%eax
  801fed:	e8 56 ff ff ff       	call   801f48 <fsipc>
  801ff2:	c9                   	leave  
  801ff3:	c3                   	ret    

00801ff4 <devfile_stat>:
  801ff4:	55                   	push   %ebp
  801ff5:	89 e5                	mov    %esp,%ebp
  801ff7:	53                   	push   %ebx
  801ff8:	83 ec 14             	sub    $0x14,%esp
  801ffb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ffe:	8b 45 08             	mov    0x8(%ebp),%eax
  802001:	8b 40 0c             	mov    0xc(%eax),%eax
  802004:	a3 00 40 80 00       	mov    %eax,0x804000
  802009:	ba 00 00 00 00       	mov    $0x0,%edx
  80200e:	b8 05 00 00 00       	mov    $0x5,%eax
  802013:	e8 30 ff ff ff       	call   801f48 <fsipc>
  802018:	85 c0                	test   %eax,%eax
  80201a:	78 2b                	js     802047 <devfile_stat+0x53>
  80201c:	c7 44 24 04 00 40 80 	movl   $0x804000,0x4(%esp)
  802023:	00 
  802024:	89 1c 24             	mov    %ebx,(%esp)
  802027:	e8 c5 e9 ff ff       	call   8009f1 <strcpy>
  80202c:	a1 80 40 80 00       	mov    0x804080,%eax
  802031:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  802037:	a1 84 40 80 00       	mov    0x804084,%eax
  80203c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  802042:	b8 00 00 00 00       	mov    $0x0,%eax
  802047:	83 c4 14             	add    $0x14,%esp
  80204a:	5b                   	pop    %ebx
  80204b:	5d                   	pop    %ebp
  80204c:	c3                   	ret    

0080204d <devfile_write>:
  80204d:	55                   	push   %ebp
  80204e:	89 e5                	mov    %esp,%ebp
  802050:	83 ec 18             	sub    $0x18,%esp
  802053:	8b 55 10             	mov    0x10(%ebp),%edx
  802056:	8b 45 08             	mov    0x8(%ebp),%eax
  802059:	8b 40 0c             	mov    0xc(%eax),%eax
  80205c:	a3 00 40 80 00       	mov    %eax,0x804000
  802061:	89 d0                	mov    %edx,%eax
  802063:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  802069:	76 05                	jbe    802070 <devfile_write+0x23>
  80206b:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  802070:	89 15 04 40 80 00    	mov    %edx,0x804004
  802076:	89 44 24 08          	mov    %eax,0x8(%esp)
  80207a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80207d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802081:	c7 04 24 08 40 80 00 	movl   $0x804008,(%esp)
  802088:	e8 6d eb ff ff       	call   800bfa <memmove>
  80208d:	ba 00 00 00 00       	mov    $0x0,%edx
  802092:	b8 04 00 00 00       	mov    $0x4,%eax
  802097:	e8 ac fe ff ff       	call   801f48 <fsipc>
  80209c:	c9                   	leave  
  80209d:	c3                   	ret    

0080209e <devfile_read>:
  80209e:	55                   	push   %ebp
  80209f:	89 e5                	mov    %esp,%ebp
  8020a1:	53                   	push   %ebx
  8020a2:	83 ec 14             	sub    $0x14,%esp
  8020a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a8:	8b 40 0c             	mov    0xc(%eax),%eax
  8020ab:	a3 00 40 80 00       	mov    %eax,0x804000
  8020b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8020b3:	a3 04 40 80 00       	mov    %eax,0x804004
  8020b8:	ba 00 40 80 00       	mov    $0x804000,%edx
  8020bd:	b8 03 00 00 00       	mov    $0x3,%eax
  8020c2:	e8 81 fe ff ff       	call   801f48 <fsipc>
  8020c7:	89 c3                	mov    %eax,%ebx
  8020c9:	85 c0                	test   %eax,%eax
  8020cb:	7e 17                	jle    8020e4 <devfile_read+0x46>
  8020cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020d1:	c7 44 24 04 00 40 80 	movl   $0x804000,0x4(%esp)
  8020d8:	00 
  8020d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020dc:	89 04 24             	mov    %eax,(%esp)
  8020df:	e8 16 eb ff ff       	call   800bfa <memmove>
  8020e4:	89 d8                	mov    %ebx,%eax
  8020e6:	83 c4 14             	add    $0x14,%esp
  8020e9:	5b                   	pop    %ebx
  8020ea:	5d                   	pop    %ebp
  8020eb:	c3                   	ret    

008020ec <remove>:
  8020ec:	55                   	push   %ebp
  8020ed:	89 e5                	mov    %esp,%ebp
  8020ef:	53                   	push   %ebx
  8020f0:	83 ec 14             	sub    $0x14,%esp
  8020f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8020f6:	89 1c 24             	mov    %ebx,(%esp)
  8020f9:	e8 a2 e8 ff ff       	call   8009a0 <strlen>
  8020fe:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  802103:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802108:	7f 21                	jg     80212b <remove+0x3f>
  80210a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80210e:	c7 04 24 00 40 80 00 	movl   $0x804000,(%esp)
  802115:	e8 d7 e8 ff ff       	call   8009f1 <strcpy>
  80211a:	ba 00 00 00 00       	mov    $0x0,%edx
  80211f:	b8 07 00 00 00       	mov    $0x7,%eax
  802124:	e8 1f fe ff ff       	call   801f48 <fsipc>
  802129:	89 c2                	mov    %eax,%edx
  80212b:	89 d0                	mov    %edx,%eax
  80212d:	83 c4 14             	add    $0x14,%esp
  802130:	5b                   	pop    %ebx
  802131:	5d                   	pop    %ebp
  802132:	c3                   	ret    

00802133 <open>:
  802133:	55                   	push   %ebp
  802134:	89 e5                	mov    %esp,%ebp
  802136:	56                   	push   %esi
  802137:	53                   	push   %ebx
  802138:	83 ec 30             	sub    $0x30,%esp
  80213b:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80213e:	89 04 24             	mov    %eax,(%esp)
  802141:	e8 15 f8 ff ff       	call   80195b <fd_alloc>
  802146:	89 c3                	mov    %eax,%ebx
  802148:	85 c0                	test   %eax,%eax
  80214a:	79 18                	jns    802164 <open+0x31>
  80214c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802153:	00 
  802154:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  802157:	89 04 24             	mov    %eax,(%esp)
  80215a:	e8 a4 fb ff ff       	call   801d03 <fd_close>
  80215f:	e9 9f 00 00 00       	jmp    802203 <open+0xd0>
  802164:	8b 45 08             	mov    0x8(%ebp),%eax
  802167:	89 44 24 04          	mov    %eax,0x4(%esp)
  80216b:	c7 04 24 00 40 80 00 	movl   $0x804000,(%esp)
  802172:	e8 7a e8 ff ff       	call   8009f1 <strcpy>
  802177:	8b 45 0c             	mov    0xc(%ebp),%eax
  80217a:	a3 00 44 80 00       	mov    %eax,0x804400
  80217f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  802182:	89 04 24             	mov    %eax,(%esp)
  802185:	e8 b6 f7 ff ff       	call   801940 <fd2data>
  80218a:	89 c6                	mov    %eax,%esi
  80218c:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  80218f:	b8 01 00 00 00       	mov    $0x1,%eax
  802194:	e8 af fd ff ff       	call   801f48 <fsipc>
  802199:	89 c3                	mov    %eax,%ebx
  80219b:	85 c0                	test   %eax,%eax
  80219d:	79 15                	jns    8021b4 <open+0x81>
  80219f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8021a6:	00 
  8021a7:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8021aa:	89 04 24             	mov    %eax,(%esp)
  8021ad:	e8 51 fb ff ff       	call   801d03 <fd_close>
  8021b2:	eb 4f                	jmp    802203 <open+0xd0>
  8021b4:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8021bb:	00 
  8021bc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8021c0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8021c7:	00 
  8021c8:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8021cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021d6:	e8 e1 ee ff ff       	call   8010bc <sys_page_map>
  8021db:	89 c3                	mov    %eax,%ebx
  8021dd:	85 c0                	test   %eax,%eax
  8021df:	79 15                	jns    8021f6 <open+0xc3>
  8021e1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8021e8:	00 
  8021e9:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8021ec:	89 04 24             	mov    %eax,(%esp)
  8021ef:	e8 0f fb ff ff       	call   801d03 <fd_close>
  8021f4:	eb 0d                	jmp    802203 <open+0xd0>
  8021f6:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8021f9:	89 04 24             	mov    %eax,(%esp)
  8021fc:	e8 2f f7 ff ff       	call   801930 <fd2num>
  802201:	89 c3                	mov    %eax,%ebx
  802203:	89 d8                	mov    %ebx,%eax
  802205:	83 c4 30             	add    $0x30,%esp
  802208:	5b                   	pop    %ebx
  802209:	5e                   	pop    %esi
  80220a:	5d                   	pop    %ebp
  80220b:	c3                   	ret    
  80220c:	00 00                	add    %al,(%eax)
	...

00802210 <devsock_stat>:
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802210:	55                   	push   %ebp
  802211:	89 e5                	mov    %esp,%ebp
  802213:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  802216:	c7 44 24 04 80 30 80 	movl   $0x803080,0x4(%esp)
  80221d:	00 
  80221e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802221:	89 04 24             	mov    %eax,(%esp)
  802224:	e8 c8 e7 ff ff       	call   8009f1 <strcpy>
	return 0;
}
  802229:	b8 00 00 00 00       	mov    $0x0,%eax
  80222e:	c9                   	leave  
  80222f:	c3                   	ret    

00802230 <devsock_close>:
  802230:	55                   	push   %ebp
  802231:	89 e5                	mov    %esp,%ebp
  802233:	83 ec 08             	sub    $0x8,%esp
  802236:	8b 45 08             	mov    0x8(%ebp),%eax
  802239:	8b 40 0c             	mov    0xc(%eax),%eax
  80223c:	89 04 24             	mov    %eax,(%esp)
  80223f:	e8 be 02 00 00       	call   802502 <nsipc_close>
  802244:	c9                   	leave  
  802245:	c3                   	ret    

00802246 <devsock_write>:
  802246:	55                   	push   %ebp
  802247:	89 e5                	mov    %esp,%ebp
  802249:	83 ec 18             	sub    $0x18,%esp
  80224c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802253:	00 
  802254:	8b 45 10             	mov    0x10(%ebp),%eax
  802257:	89 44 24 08          	mov    %eax,0x8(%esp)
  80225b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80225e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802262:	8b 45 08             	mov    0x8(%ebp),%eax
  802265:	8b 40 0c             	mov    0xc(%eax),%eax
  802268:	89 04 24             	mov    %eax,(%esp)
  80226b:	e8 ce 02 00 00       	call   80253e <nsipc_send>
  802270:	c9                   	leave  
  802271:	c3                   	ret    

00802272 <devsock_read>:
  802272:	55                   	push   %ebp
  802273:	89 e5                	mov    %esp,%ebp
  802275:	83 ec 18             	sub    $0x18,%esp
  802278:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80227f:	00 
  802280:	8b 45 10             	mov    0x10(%ebp),%eax
  802283:	89 44 24 08          	mov    %eax,0x8(%esp)
  802287:	8b 45 0c             	mov    0xc(%ebp),%eax
  80228a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80228e:	8b 45 08             	mov    0x8(%ebp),%eax
  802291:	8b 40 0c             	mov    0xc(%eax),%eax
  802294:	89 04 24             	mov    %eax,(%esp)
  802297:	e8 15 03 00 00       	call   8025b1 <nsipc_recv>
  80229c:	c9                   	leave  
  80229d:	c3                   	ret    

0080229e <alloc_sockfd>:
  80229e:	55                   	push   %ebp
  80229f:	89 e5                	mov    %esp,%ebp
  8022a1:	56                   	push   %esi
  8022a2:	53                   	push   %ebx
  8022a3:	83 ec 20             	sub    $0x20,%esp
  8022a6:	89 c6                	mov    %eax,%esi
  8022a8:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8022ab:	89 04 24             	mov    %eax,(%esp)
  8022ae:	e8 a8 f6 ff ff       	call   80195b <fd_alloc>
  8022b3:	89 c3                	mov    %eax,%ebx
  8022b5:	85 c0                	test   %eax,%eax
  8022b7:	78 21                	js     8022da <alloc_sockfd+0x3c>
  8022b9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8022c0:	00 
  8022c1:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8022c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022cf:	e8 46 ee ff ff       	call   80111a <sys_page_alloc>
  8022d4:	89 c3                	mov    %eax,%ebx
  8022d6:	85 c0                	test   %eax,%eax
  8022d8:	79 0a                	jns    8022e4 <alloc_sockfd+0x46>
  8022da:	89 34 24             	mov    %esi,(%esp)
  8022dd:	e8 20 02 00 00       	call   802502 <nsipc_close>
  8022e2:	eb 28                	jmp    80230c <alloc_sockfd+0x6e>
  8022e4:	8b 15 20 70 80 00    	mov    0x807020,%edx
  8022ea:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8022ed:	89 10                	mov    %edx,(%eax)
  8022ef:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8022f2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
  8022f9:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8022fc:	89 70 0c             	mov    %esi,0xc(%eax)
  8022ff:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  802302:	89 04 24             	mov    %eax,(%esp)
  802305:	e8 26 f6 ff ff       	call   801930 <fd2num>
  80230a:	89 c3                	mov    %eax,%ebx
  80230c:	89 d8                	mov    %ebx,%eax
  80230e:	83 c4 20             	add    $0x20,%esp
  802311:	5b                   	pop    %ebx
  802312:	5e                   	pop    %esi
  802313:	5d                   	pop    %ebp
  802314:	c3                   	ret    

00802315 <socket>:

int
socket(int domain, int type, int protocol)
{
  802315:	55                   	push   %ebp
  802316:	89 e5                	mov    %esp,%ebp
  802318:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80231b:	8b 45 10             	mov    0x10(%ebp),%eax
  80231e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802322:	8b 45 0c             	mov    0xc(%ebp),%eax
  802325:	89 44 24 04          	mov    %eax,0x4(%esp)
  802329:	8b 45 08             	mov    0x8(%ebp),%eax
  80232c:	89 04 24             	mov    %eax,(%esp)
  80232f:	e8 82 01 00 00       	call   8024b6 <nsipc_socket>
  802334:	85 c0                	test   %eax,%eax
  802336:	78 05                	js     80233d <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802338:	e8 61 ff ff ff       	call   80229e <alloc_sockfd>
}
  80233d:	c9                   	leave  
  80233e:	66 90                	xchg   %ax,%ax
  802340:	c3                   	ret    

00802341 <fd2sockid>:
  802341:	55                   	push   %ebp
  802342:	89 e5                	mov    %esp,%ebp
  802344:	83 ec 18             	sub    $0x18,%esp
  802347:	8d 55 fc             	lea    0xfffffffc(%ebp),%edx
  80234a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80234e:	89 04 24             	mov    %eax,(%esp)
  802351:	e8 58 f6 ff ff       	call   8019ae <fd_lookup>
  802356:	89 c2                	mov    %eax,%edx
  802358:	85 c0                	test   %eax,%eax
  80235a:	78 15                	js     802371 <fd2sockid+0x30>
  80235c:	8b 4d fc             	mov    0xfffffffc(%ebp),%ecx
  80235f:	8b 01                	mov    (%ecx),%eax
  802361:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  802366:	3b 05 20 70 80 00    	cmp    0x807020,%eax
  80236c:	75 03                	jne    802371 <fd2sockid+0x30>
  80236e:	8b 51 0c             	mov    0xc(%ecx),%edx
  802371:	89 d0                	mov    %edx,%eax
  802373:	c9                   	leave  
  802374:	c3                   	ret    

00802375 <listen>:
  802375:	55                   	push   %ebp
  802376:	89 e5                	mov    %esp,%ebp
  802378:	83 ec 08             	sub    $0x8,%esp
  80237b:	8b 45 08             	mov    0x8(%ebp),%eax
  80237e:	e8 be ff ff ff       	call   802341 <fd2sockid>
  802383:	89 c2                	mov    %eax,%edx
  802385:	85 c0                	test   %eax,%eax
  802387:	78 11                	js     80239a <listen+0x25>
  802389:	8b 45 0c             	mov    0xc(%ebp),%eax
  80238c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802390:	89 14 24             	mov    %edx,(%esp)
  802393:	e8 48 01 00 00       	call   8024e0 <nsipc_listen>
  802398:	89 c2                	mov    %eax,%edx
  80239a:	89 d0                	mov    %edx,%eax
  80239c:	c9                   	leave  
  80239d:	c3                   	ret    

0080239e <connect>:
  80239e:	55                   	push   %ebp
  80239f:	89 e5                	mov    %esp,%ebp
  8023a1:	83 ec 18             	sub    $0x18,%esp
  8023a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8023a7:	e8 95 ff ff ff       	call   802341 <fd2sockid>
  8023ac:	89 c2                	mov    %eax,%edx
  8023ae:	85 c0                	test   %eax,%eax
  8023b0:	78 18                	js     8023ca <connect+0x2c>
  8023b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8023b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023c0:	89 14 24             	mov    %edx,(%esp)
  8023c3:	e8 71 02 00 00       	call   802639 <nsipc_connect>
  8023c8:	89 c2                	mov    %eax,%edx
  8023ca:	89 d0                	mov    %edx,%eax
  8023cc:	c9                   	leave  
  8023cd:	c3                   	ret    

008023ce <shutdown>:
  8023ce:	55                   	push   %ebp
  8023cf:	89 e5                	mov    %esp,%ebp
  8023d1:	83 ec 08             	sub    $0x8,%esp
  8023d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8023d7:	e8 65 ff ff ff       	call   802341 <fd2sockid>
  8023dc:	89 c2                	mov    %eax,%edx
  8023de:	85 c0                	test   %eax,%eax
  8023e0:	78 11                	js     8023f3 <shutdown+0x25>
  8023e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023e9:	89 14 24             	mov    %edx,(%esp)
  8023ec:	e8 2b 01 00 00       	call   80251c <nsipc_shutdown>
  8023f1:	89 c2                	mov    %eax,%edx
  8023f3:	89 d0                	mov    %edx,%eax
  8023f5:	c9                   	leave  
  8023f6:	c3                   	ret    

008023f7 <bind>:
  8023f7:	55                   	push   %ebp
  8023f8:	89 e5                	mov    %esp,%ebp
  8023fa:	83 ec 18             	sub    $0x18,%esp
  8023fd:	8b 45 08             	mov    0x8(%ebp),%eax
  802400:	e8 3c ff ff ff       	call   802341 <fd2sockid>
  802405:	89 c2                	mov    %eax,%edx
  802407:	85 c0                	test   %eax,%eax
  802409:	78 18                	js     802423 <bind+0x2c>
  80240b:	8b 45 10             	mov    0x10(%ebp),%eax
  80240e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802412:	8b 45 0c             	mov    0xc(%ebp),%eax
  802415:	89 44 24 04          	mov    %eax,0x4(%esp)
  802419:	89 14 24             	mov    %edx,(%esp)
  80241c:	e8 57 02 00 00       	call   802678 <nsipc_bind>
  802421:	89 c2                	mov    %eax,%edx
  802423:	89 d0                	mov    %edx,%eax
  802425:	c9                   	leave  
  802426:	c3                   	ret    

00802427 <accept>:
  802427:	55                   	push   %ebp
  802428:	89 e5                	mov    %esp,%ebp
  80242a:	83 ec 18             	sub    $0x18,%esp
  80242d:	8b 45 08             	mov    0x8(%ebp),%eax
  802430:	e8 0c ff ff ff       	call   802341 <fd2sockid>
  802435:	89 c2                	mov    %eax,%edx
  802437:	85 c0                	test   %eax,%eax
  802439:	78 23                	js     80245e <accept+0x37>
  80243b:	8b 45 10             	mov    0x10(%ebp),%eax
  80243e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802442:	8b 45 0c             	mov    0xc(%ebp),%eax
  802445:	89 44 24 04          	mov    %eax,0x4(%esp)
  802449:	89 14 24             	mov    %edx,(%esp)
  80244c:	e8 66 02 00 00       	call   8026b7 <nsipc_accept>
  802451:	89 c2                	mov    %eax,%edx
  802453:	85 c0                	test   %eax,%eax
  802455:	78 07                	js     80245e <accept+0x37>
  802457:	e8 42 fe ff ff       	call   80229e <alloc_sockfd>
  80245c:	89 c2                	mov    %eax,%edx
  80245e:	89 d0                	mov    %edx,%eax
  802460:	c9                   	leave  
  802461:	c3                   	ret    
	...

00802470 <nsipc>:
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802470:	55                   	push   %ebp
  802471:	89 e5                	mov    %esp,%ebp
  802473:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802476:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  80247c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802483:	00 
  802484:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  80248b:	00 
  80248c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802490:	89 14 24             	mov    %edx,(%esp)
  802493:	e8 f8 f2 ff ff       	call   801790 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802498:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80249f:	00 
  8024a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8024a7:	00 
  8024a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024af:	e8 90 f3 ff ff       	call   801844 <ipc_recv>
}
  8024b4:	c9                   	leave  
  8024b5:	c3                   	ret    

008024b6 <nsipc_socket>:

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
  8024b6:	55                   	push   %ebp
  8024b7:	89 e5                	mov    %esp,%ebp
  8024b9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8024bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8024bf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8024c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024c7:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8024cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8024cf:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8024d4:	b8 09 00 00 00       	mov    $0x9,%eax
  8024d9:	e8 92 ff ff ff       	call   802470 <nsipc>
}
  8024de:	c9                   	leave  
  8024df:	c3                   	ret    

008024e0 <nsipc_listen>:
  8024e0:	55                   	push   %ebp
  8024e1:	89 e5                	mov    %esp,%ebp
  8024e3:	83 ec 08             	sub    $0x8,%esp
  8024e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8024e9:	a3 00 60 80 00       	mov    %eax,0x806000
  8024ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024f1:	a3 04 60 80 00       	mov    %eax,0x806004
  8024f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8024fb:	e8 70 ff ff ff       	call   802470 <nsipc>
  802500:	c9                   	leave  
  802501:	c3                   	ret    

00802502 <nsipc_close>:
  802502:	55                   	push   %ebp
  802503:	89 e5                	mov    %esp,%ebp
  802505:	83 ec 08             	sub    $0x8,%esp
  802508:	8b 45 08             	mov    0x8(%ebp),%eax
  80250b:	a3 00 60 80 00       	mov    %eax,0x806000
  802510:	b8 04 00 00 00       	mov    $0x4,%eax
  802515:	e8 56 ff ff ff       	call   802470 <nsipc>
  80251a:	c9                   	leave  
  80251b:	c3                   	ret    

0080251c <nsipc_shutdown>:
  80251c:	55                   	push   %ebp
  80251d:	89 e5                	mov    %esp,%ebp
  80251f:	83 ec 08             	sub    $0x8,%esp
  802522:	8b 45 08             	mov    0x8(%ebp),%eax
  802525:	a3 00 60 80 00       	mov    %eax,0x806000
  80252a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80252d:	a3 04 60 80 00       	mov    %eax,0x806004
  802532:	b8 03 00 00 00       	mov    $0x3,%eax
  802537:	e8 34 ff ff ff       	call   802470 <nsipc>
  80253c:	c9                   	leave  
  80253d:	c3                   	ret    

0080253e <nsipc_send>:
  80253e:	55                   	push   %ebp
  80253f:	89 e5                	mov    %esp,%ebp
  802541:	53                   	push   %ebx
  802542:	83 ec 14             	sub    $0x14,%esp
  802545:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802548:	8b 45 08             	mov    0x8(%ebp),%eax
  80254b:	a3 00 60 80 00       	mov    %eax,0x806000
  802550:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802556:	7e 24                	jle    80257c <nsipc_send+0x3e>
  802558:	c7 44 24 0c 8c 30 80 	movl   $0x80308c,0xc(%esp)
  80255f:	00 
  802560:	c7 44 24 08 98 30 80 	movl   $0x803098,0x8(%esp)
  802567:	00 
  802568:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  80256f:	00 
  802570:	c7 04 24 ad 30 80 00 	movl   $0x8030ad,(%esp)
  802577:	e8 20 dd ff ff       	call   80029c <_panic>
  80257c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802580:	8b 45 0c             	mov    0xc(%ebp),%eax
  802583:	89 44 24 04          	mov    %eax,0x4(%esp)
  802587:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  80258e:	e8 67 e6 ff ff       	call   800bfa <memmove>
  802593:	89 1d 04 60 80 00    	mov    %ebx,0x806004
  802599:	8b 45 14             	mov    0x14(%ebp),%eax
  80259c:	a3 08 60 80 00       	mov    %eax,0x806008
  8025a1:	b8 08 00 00 00       	mov    $0x8,%eax
  8025a6:	e8 c5 fe ff ff       	call   802470 <nsipc>
  8025ab:	83 c4 14             	add    $0x14,%esp
  8025ae:	5b                   	pop    %ebx
  8025af:	5d                   	pop    %ebp
  8025b0:	c3                   	ret    

008025b1 <nsipc_recv>:
  8025b1:	55                   	push   %ebp
  8025b2:	89 e5                	mov    %esp,%ebp
  8025b4:	83 ec 18             	sub    $0x18,%esp
  8025b7:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  8025ba:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  8025bd:	8b 75 10             	mov    0x10(%ebp),%esi
  8025c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8025c3:	a3 00 60 80 00       	mov    %eax,0x806000
  8025c8:	89 35 04 60 80 00    	mov    %esi,0x806004
  8025ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8025d1:	a3 08 60 80 00       	mov    %eax,0x806008
  8025d6:	b8 07 00 00 00       	mov    $0x7,%eax
  8025db:	e8 90 fe ff ff       	call   802470 <nsipc>
  8025e0:	89 c3                	mov    %eax,%ebx
  8025e2:	85 c0                	test   %eax,%eax
  8025e4:	78 47                	js     80262d <nsipc_recv+0x7c>
  8025e6:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8025eb:	7f 05                	jg     8025f2 <nsipc_recv+0x41>
  8025ed:	39 c6                	cmp    %eax,%esi
  8025ef:	90                   	nop    
  8025f0:	7d 24                	jge    802616 <nsipc_recv+0x65>
  8025f2:	c7 44 24 0c b9 30 80 	movl   $0x8030b9,0xc(%esp)
  8025f9:	00 
  8025fa:	c7 44 24 08 98 30 80 	movl   $0x803098,0x8(%esp)
  802601:	00 
  802602:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  802609:	00 
  80260a:	c7 04 24 ad 30 80 00 	movl   $0x8030ad,(%esp)
  802611:	e8 86 dc ff ff       	call   80029c <_panic>
  802616:	89 44 24 08          	mov    %eax,0x8(%esp)
  80261a:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802621:	00 
  802622:	8b 45 0c             	mov    0xc(%ebp),%eax
  802625:	89 04 24             	mov    %eax,(%esp)
  802628:	e8 cd e5 ff ff       	call   800bfa <memmove>
  80262d:	89 d8                	mov    %ebx,%eax
  80262f:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  802632:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  802635:	89 ec                	mov    %ebp,%esp
  802637:	5d                   	pop    %ebp
  802638:	c3                   	ret    

00802639 <nsipc_connect>:
  802639:	55                   	push   %ebp
  80263a:	89 e5                	mov    %esp,%ebp
  80263c:	53                   	push   %ebx
  80263d:	83 ec 14             	sub    $0x14,%esp
  802640:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802643:	8b 45 08             	mov    0x8(%ebp),%eax
  802646:	a3 00 60 80 00       	mov    %eax,0x806000
  80264b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80264f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802652:	89 44 24 04          	mov    %eax,0x4(%esp)
  802656:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  80265d:	e8 98 e5 ff ff       	call   800bfa <memmove>
  802662:	89 1d 14 60 80 00    	mov    %ebx,0x806014
  802668:	b8 05 00 00 00       	mov    $0x5,%eax
  80266d:	e8 fe fd ff ff       	call   802470 <nsipc>
  802672:	83 c4 14             	add    $0x14,%esp
  802675:	5b                   	pop    %ebx
  802676:	5d                   	pop    %ebp
  802677:	c3                   	ret    

00802678 <nsipc_bind>:
  802678:	55                   	push   %ebp
  802679:	89 e5                	mov    %esp,%ebp
  80267b:	53                   	push   %ebx
  80267c:	83 ec 14             	sub    $0x14,%esp
  80267f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802682:	8b 45 08             	mov    0x8(%ebp),%eax
  802685:	a3 00 60 80 00       	mov    %eax,0x806000
  80268a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80268e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802691:	89 44 24 04          	mov    %eax,0x4(%esp)
  802695:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  80269c:	e8 59 e5 ff ff       	call   800bfa <memmove>
  8026a1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
  8026a7:	b8 02 00 00 00       	mov    $0x2,%eax
  8026ac:	e8 bf fd ff ff       	call   802470 <nsipc>
  8026b1:	83 c4 14             	add    $0x14,%esp
  8026b4:	5b                   	pop    %ebx
  8026b5:	5d                   	pop    %ebp
  8026b6:	c3                   	ret    

008026b7 <nsipc_accept>:
  8026b7:	55                   	push   %ebp
  8026b8:	89 e5                	mov    %esp,%ebp
  8026ba:	53                   	push   %ebx
  8026bb:	83 ec 14             	sub    $0x14,%esp
  8026be:	8b 45 08             	mov    0x8(%ebp),%eax
  8026c1:	a3 00 60 80 00       	mov    %eax,0x806000
  8026c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8026cb:	e8 a0 fd ff ff       	call   802470 <nsipc>
  8026d0:	89 c3                	mov    %eax,%ebx
  8026d2:	85 c0                	test   %eax,%eax
  8026d4:	78 27                	js     8026fd <nsipc_accept+0x46>
  8026d6:	a1 10 60 80 00       	mov    0x806010,%eax
  8026db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026df:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8026e6:	00 
  8026e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026ea:	89 04 24             	mov    %eax,(%esp)
  8026ed:	e8 08 e5 ff ff       	call   800bfa <memmove>
  8026f2:	8b 15 10 60 80 00    	mov    0x806010,%edx
  8026f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8026fb:	89 10                	mov    %edx,(%eax)
  8026fd:	89 d8                	mov    %ebx,%eax
  8026ff:	83 c4 14             	add    $0x14,%esp
  802702:	5b                   	pop    %ebx
  802703:	5d                   	pop    %ebp
  802704:	c3                   	ret    
  802705:	00 00                	add    %al,(%eax)
	...

00802708 <set_pgfault_handler>:
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802708:	55                   	push   %ebp
  802709:	89 e5                	mov    %esp,%ebp
  80270b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80270e:	83 3d 48 70 80 00 00 	cmpl   $0x0,0x807048
  802715:	75 6a                	jne    802781 <set_pgfault_handler+0x79>
		// First time through!
		// LAB 4: Your code here.
		env=(struct Env*)&envs[ENVX(sys_getenvid())];
  802717:	e8 91 ea ff ff       	call   8011ad <sys_getenvid>
  80271c:	25 ff 03 00 00       	and    $0x3ff,%eax
  802721:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802724:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802729:	a3 40 70 80 00       	mov    %eax,0x807040
		if((r=sys_page_alloc(env->env_id,(void*)(UXSTACKTOP-PGSIZE),PTE_W|PTE_U|PTE_P))<0)
  80272e:	8b 40 4c             	mov    0x4c(%eax),%eax
  802731:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802738:	00 
  802739:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802740:	ee 
  802741:	89 04 24             	mov    %eax,(%esp)
  802744:	e8 d1 e9 ff ff       	call   80111a <sys_page_alloc>
  802749:	85 c0                	test   %eax,%eax
  80274b:	79 1c                	jns    802769 <set_pgfault_handler+0x61>
		{
			panic("Alloc a page for an exception stack failed");
  80274d:	c7 44 24 08 d0 30 80 	movl   $0x8030d0,0x8(%esp)
  802754:	00 
  802755:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80275c:	00 
  80275d:	c7 04 24 fc 30 80 00 	movl   $0x8030fc,(%esp)
  802764:	e8 33 db ff ff       	call   80029c <_panic>
		}
		sys_env_set_pgfault_upcall(env->env_id,(void*)_pgfault_upcall);
  802769:	a1 40 70 80 00       	mov    0x807040,%eax
  80276e:	8b 40 4c             	mov    0x4c(%eax),%eax
  802771:	c7 44 24 04 8c 27 80 	movl   $0x80278c,0x4(%esp)
  802778:	00 
  802779:	89 04 24             	mov    %eax,(%esp)
  80277c:	e8 c3 e7 ff ff       	call   800f44 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802781:	8b 45 08             	mov    0x8(%ebp),%eax
  802784:	a3 48 70 80 00       	mov    %eax,0x807048
}
  802789:	c9                   	leave  
  80278a:	c3                   	ret    
	...

0080278c <_pgfault_upcall>:
  80278c:	54                   	push   %esp
  80278d:	a1 48 70 80 00       	mov    0x807048,%eax
  802792:	ff d0                	call   *%eax
  802794:	83 c4 04             	add    $0x4,%esp
  802797:	8b 44 24 28          	mov    0x28(%esp),%eax
  80279b:	50                   	push   %eax
  80279c:	89 e0                	mov    %esp,%eax
  80279e:	8b 60 34             	mov    0x34(%eax),%esp
  8027a1:	ff 30                	pushl  (%eax)
  8027a3:	89 c4                	mov    %eax,%esp
  8027a5:	83 6c 24 34 04       	subl   $0x4,0x34(%esp)
  8027aa:	83 c4 0c             	add    $0xc,%esp
  8027ad:	61                   	popa   
  8027ae:	83 c4 04             	add    $0x4,%esp
  8027b1:	9d                   	popf   
  8027b2:	5c                   	pop    %esp
  8027b3:	c3                   	ret    
	...

008027c0 <__udivdi3>:
  8027c0:	55                   	push   %ebp
  8027c1:	89 e5                	mov    %esp,%ebp
  8027c3:	57                   	push   %edi
  8027c4:	56                   	push   %esi
  8027c5:	83 ec 1c             	sub    $0x1c,%esp
  8027c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8027cb:	8b 55 14             	mov    0x14(%ebp),%edx
  8027ce:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8027d1:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  8027d4:	89 c1                	mov    %eax,%ecx
  8027d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8027d9:	85 d2                	test   %edx,%edx
  8027db:	89 d6                	mov    %edx,%esi
  8027dd:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
  8027e0:	75 1e                	jne    802800 <__udivdi3+0x40>
  8027e2:	39 f9                	cmp    %edi,%ecx
  8027e4:	0f 86 8d 00 00 00    	jbe    802877 <__udivdi3+0xb7>
  8027ea:	89 fa                	mov    %edi,%edx
  8027ec:	f7 f1                	div    %ecx
  8027ee:	89 c1                	mov    %eax,%ecx
  8027f0:	89 c8                	mov    %ecx,%eax
  8027f2:	89 f2                	mov    %esi,%edx
  8027f4:	83 c4 1c             	add    $0x1c,%esp
  8027f7:	5e                   	pop    %esi
  8027f8:	5f                   	pop    %edi
  8027f9:	5d                   	pop    %ebp
  8027fa:	c3                   	ret    
  8027fb:	90                   	nop    
  8027fc:	8d 74 26 00          	lea    0x0(%esi),%esi
  802800:	39 fa                	cmp    %edi,%edx
  802802:	0f 87 98 00 00 00    	ja     8028a0 <__udivdi3+0xe0>
  802808:	0f bd c2             	bsr    %edx,%eax
  80280b:	83 f0 1f             	xor    $0x1f,%eax
  80280e:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  802811:	74 7f                	je     802892 <__udivdi3+0xd2>
  802813:	b8 20 00 00 00       	mov    $0x20,%eax
  802818:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  80281b:	2b 45 e4             	sub    0xffffffe4(%ebp),%eax
  80281e:	89 c1                	mov    %eax,%ecx
  802820:	d3 ea                	shr    %cl,%edx
  802822:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802826:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  802829:	89 f0                	mov    %esi,%eax
  80282b:	d3 e0                	shl    %cl,%eax
  80282d:	09 c2                	or     %eax,%edx
  80282f:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802832:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  802835:	89 fa                	mov    %edi,%edx
  802837:	d3 e0                	shl    %cl,%eax
  802839:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  80283d:	89 45 f4             	mov    %eax,0xfffffff4(%ebp)
  802840:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802843:	d3 e8                	shr    %cl,%eax
  802845:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802849:	d3 e2                	shl    %cl,%edx
  80284b:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  80284f:	09 d0                	or     %edx,%eax
  802851:	d3 ef                	shr    %cl,%edi
  802853:	89 fa                	mov    %edi,%edx
  802855:	f7 75 e0             	divl   0xffffffe0(%ebp)
  802858:	89 d1                	mov    %edx,%ecx
  80285a:	89 c7                	mov    %eax,%edi
  80285c:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80285f:	f7 e7                	mul    %edi
  802861:	39 d1                	cmp    %edx,%ecx
  802863:	89 c6                	mov    %eax,%esi
  802865:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  802868:	72 6f                	jb     8028d9 <__udivdi3+0x119>
  80286a:	39 ca                	cmp    %ecx,%edx
  80286c:	74 5e                	je     8028cc <__udivdi3+0x10c>
  80286e:	89 f9                	mov    %edi,%ecx
  802870:	31 f6                	xor    %esi,%esi
  802872:	e9 79 ff ff ff       	jmp    8027f0 <__udivdi3+0x30>
  802877:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80287a:	85 c0                	test   %eax,%eax
  80287c:	74 32                	je     8028b0 <__udivdi3+0xf0>
  80287e:	89 f2                	mov    %esi,%edx
  802880:	89 f8                	mov    %edi,%eax
  802882:	f7 f1                	div    %ecx
  802884:	89 c6                	mov    %eax,%esi
  802886:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802889:	f7 f1                	div    %ecx
  80288b:	89 c1                	mov    %eax,%ecx
  80288d:	e9 5e ff ff ff       	jmp    8027f0 <__udivdi3+0x30>
  802892:	39 d7                	cmp    %edx,%edi
  802894:	77 2a                	ja     8028c0 <__udivdi3+0x100>
  802896:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  802899:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
  80289c:	73 22                	jae    8028c0 <__udivdi3+0x100>
  80289e:	66 90                	xchg   %ax,%ax
  8028a0:	31 c9                	xor    %ecx,%ecx
  8028a2:	31 f6                	xor    %esi,%esi
  8028a4:	e9 47 ff ff ff       	jmp    8027f0 <__udivdi3+0x30>
  8028a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  8028b0:	b8 01 00 00 00       	mov    $0x1,%eax
  8028b5:	31 d2                	xor    %edx,%edx
  8028b7:	f7 75 f0             	divl   0xfffffff0(%ebp)
  8028ba:	89 c1                	mov    %eax,%ecx
  8028bc:	eb c0                	jmp    80287e <__udivdi3+0xbe>
  8028be:	66 90                	xchg   %ax,%ax
  8028c0:	b9 01 00 00 00       	mov    $0x1,%ecx
  8028c5:	31 f6                	xor    %esi,%esi
  8028c7:	e9 24 ff ff ff       	jmp    8027f0 <__udivdi3+0x30>
  8028cc:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8028cf:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8028d3:	d3 e0                	shl    %cl,%eax
  8028d5:	39 c6                	cmp    %eax,%esi
  8028d7:	76 95                	jbe    80286e <__udivdi3+0xae>
  8028d9:	8d 4f ff             	lea    0xffffffff(%edi),%ecx
  8028dc:	31 f6                	xor    %esi,%esi
  8028de:	e9 0d ff ff ff       	jmp    8027f0 <__udivdi3+0x30>
	...

008028f0 <__umoddi3>:
  8028f0:	55                   	push   %ebp
  8028f1:	89 e5                	mov    %esp,%ebp
  8028f3:	57                   	push   %edi
  8028f4:	56                   	push   %esi
  8028f5:	83 ec 30             	sub    $0x30,%esp
  8028f8:	8b 55 14             	mov    0x14(%ebp),%edx
  8028fb:	8b 45 10             	mov    0x10(%ebp),%eax
  8028fe:	8b 75 08             	mov    0x8(%ebp),%esi
  802901:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802904:	85 d2                	test   %edx,%edx
  802906:	c7 45 d0 00 00 00 00 	movl   $0x0,0xffffffd0(%ebp)
  80290d:	89 c1                	mov    %eax,%ecx
  80290f:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  802916:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  802919:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  80291c:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  80291f:	89 7d e0             	mov    %edi,0xffffffe0(%ebp)
  802922:	75 1c                	jne    802940 <__umoddi3+0x50>
  802924:	39 f8                	cmp    %edi,%eax
  802926:	89 fa                	mov    %edi,%edx
  802928:	0f 86 d4 00 00 00    	jbe    802a02 <__umoddi3+0x112>
  80292e:	89 f0                	mov    %esi,%eax
  802930:	f7 f1                	div    %ecx
  802932:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802935:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  80293c:	eb 12                	jmp    802950 <__umoddi3+0x60>
  80293e:	66 90                	xchg   %ax,%ax
  802940:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802943:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  802946:	76 18                	jbe    802960 <__umoddi3+0x70>
  802948:	89 75 d0             	mov    %esi,0xffffffd0(%ebp)
  80294b:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  80294e:	66 90                	xchg   %ax,%ax
  802950:	8b 45 d0             	mov    0xffffffd0(%ebp),%eax
  802953:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  802956:	83 c4 30             	add    $0x30,%esp
  802959:	5e                   	pop    %esi
  80295a:	5f                   	pop    %edi
  80295b:	5d                   	pop    %ebp
  80295c:	c3                   	ret    
  80295d:	8d 76 00             	lea    0x0(%esi),%esi
  802960:	0f bd 45 e8          	bsr    0xffffffe8(%ebp),%eax
  802964:	83 f0 1f             	xor    $0x1f,%eax
  802967:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  80296a:	0f 84 c0 00 00 00    	je     802a30 <__umoddi3+0x140>
  802970:	b8 20 00 00 00       	mov    $0x20,%eax
  802975:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  802978:	2b 45 dc             	sub    0xffffffdc(%ebp),%eax
  80297b:	8b 7d ec             	mov    0xffffffec(%ebp),%edi
  80297e:	8b 75 f0             	mov    0xfffffff0(%ebp),%esi
  802981:	89 c1                	mov    %eax,%ecx
  802983:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  802986:	d3 ea                	shr    %cl,%edx
  802988:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  80298b:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  80298f:	d3 e0                	shl    %cl,%eax
  802991:	09 c2                	or     %eax,%edx
  802993:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802996:	d3 e7                	shl    %cl,%edi
  802998:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  80299c:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  80299f:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  8029a2:	d3 e8                	shr    %cl,%eax
  8029a4:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  8029a8:	d3 e2                	shl    %cl,%edx
  8029aa:	09 d0                	or     %edx,%eax
  8029ac:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  8029af:	d3 e6                	shl    %cl,%esi
  8029b1:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8029b5:	d3 ea                	shr    %cl,%edx
  8029b7:	f7 75 f4             	divl   0xfffffff4(%ebp)
  8029ba:	89 55 cc             	mov    %edx,0xffffffcc(%ebp)
  8029bd:	f7 e7                	mul    %edi
  8029bf:	39 55 cc             	cmp    %edx,0xffffffcc(%ebp)
  8029c2:	0f 82 a5 00 00 00    	jb     802a6d <__umoddi3+0x17d>
  8029c8:	3b 55 cc             	cmp    0xffffffcc(%ebp),%edx
  8029cb:	0f 84 94 00 00 00    	je     802a65 <__umoddi3+0x175>
  8029d1:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
  8029d4:	29 c6                	sub    %eax,%esi
  8029d6:	19 d1                	sbb    %edx,%ecx
  8029d8:	89 4d cc             	mov    %ecx,0xffffffcc(%ebp)
  8029db:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  8029df:	89 f2                	mov    %esi,%edx
  8029e1:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  8029e4:	d3 ea                	shr    %cl,%edx
  8029e6:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8029ea:	d3 e0                	shl    %cl,%eax
  8029ec:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  8029f0:	09 c2                	or     %eax,%edx
  8029f2:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  8029f5:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  8029f8:	d3 e8                	shr    %cl,%eax
  8029fa:	89 45 d4             	mov    %eax,0xffffffd4(%ebp)
  8029fd:	e9 4e ff ff ff       	jmp    802950 <__umoddi3+0x60>
  802a02:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  802a05:	85 c0                	test   %eax,%eax
  802a07:	74 17                	je     802a20 <__umoddi3+0x130>
  802a09:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  802a0c:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
  802a0f:	f7 f1                	div    %ecx
  802a11:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802a14:	f7 f1                	div    %ecx
  802a16:	e9 17 ff ff ff       	jmp    802932 <__umoddi3+0x42>
  802a1b:	90                   	nop    
  802a1c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802a20:	b8 01 00 00 00       	mov    $0x1,%eax
  802a25:	31 d2                	xor    %edx,%edx
  802a27:	f7 75 ec             	divl   0xffffffec(%ebp)
  802a2a:	89 c1                	mov    %eax,%ecx
  802a2c:	eb db                	jmp    802a09 <__umoddi3+0x119>
  802a2e:	66 90                	xchg   %ax,%ax
  802a30:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802a33:	39 45 e0             	cmp    %eax,0xffffffe0(%ebp)
  802a36:	77 19                	ja     802a51 <__umoddi3+0x161>
  802a38:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  802a3b:	39 55 f0             	cmp    %edx,0xfffffff0(%ebp)
  802a3e:	73 11                	jae    802a51 <__umoddi3+0x161>
  802a40:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  802a43:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802a46:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802a49:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  802a4c:	e9 ff fe ff ff       	jmp    802950 <__umoddi3+0x60>
  802a51:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802a54:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802a57:	2b 45 ec             	sub    0xffffffec(%ebp),%eax
  802a5a:	1b 4d e8             	sbb    0xffffffe8(%ebp),%ecx
  802a5d:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  802a60:	89 4d e0             	mov    %ecx,0xffffffe0(%ebp)
  802a63:	eb db                	jmp    802a40 <__umoddi3+0x150>
  802a65:	39 f0                	cmp    %esi,%eax
  802a67:	0f 86 64 ff ff ff    	jbe    8029d1 <__umoddi3+0xe1>
  802a6d:	29 f8                	sub    %edi,%eax
  802a6f:	1b 55 f4             	sbb    0xfffffff4(%ebp),%edx
  802a72:	e9 5a ff ff ff       	jmp    8029d1 <__umoddi3+0xe1>
