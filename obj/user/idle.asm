
obj/user/idle:     file format elf32-i386

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
  80002c:	e8 1b 00 00 00       	call   80004c <libmain>
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
  800037:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  80003a:	c7 05 00 60 80 00 c0 	movl   $0x8022c0,0x806000
  800041:	22 80 00 

	// Loop forever, simply trying to yield to a different environment.
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800044:	e8 e0 03 00 00       	call   800429 <sys_yield>

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  800049:	cc                   	int3   
  80004a:	eb f8                	jmp    800044 <umain+0x10>

0080004c <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  80004c:	55                   	push   %ebp
  80004d:	89 e5                	mov    %esp,%ebp
  80004f:	83 ec 18             	sub    $0x18,%esp
  800052:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  800055:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  800058:	8b 75 08             	mov    0x8(%ebp),%esi
  80005b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  80005e:	c7 05 3c 60 80 00 00 	movl   $0x0,0x80603c
  800065:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  800068:	e8 f0 03 00 00       	call   80045d <sys_getenvid>
  80006d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800072:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800075:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007a:	a3 3c 60 80 00       	mov    %eax,0x80603c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007f:	85 f6                	test   %esi,%esi
  800081:	7e 07                	jle    80008a <libmain+0x3e>
		binaryname = argv[0];
  800083:	8b 03                	mov    (%ebx),%eax
  800085:	a3 00 60 80 00       	mov    %eax,0x806000

	// call user main routine调用用户主例程
	umain(argc, argv);
  80008a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008e:	89 34 24             	mov    %esi,(%esp)
  800091:	e8 9e ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800096:	e8 0d 00 00 00       	call   8000a8 <exit>
}
  80009b:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  80009e:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  8000a1:	89 ec                	mov    %ebp,%esp
  8000a3:	5d                   	pop    %ebp
  8000a4:	c3                   	ret    
  8000a5:	00 00                	add    %al,(%eax)
	...

008000a8 <exit>:
#include <inc/lib.h>

void
exit(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ae:	e8 33 0a 00 00       	call   800ae6 <close_all>
	sys_env_destroy(0);
  8000b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ba:	e8 d2 03 00 00       	call   800491 <sys_env_destroy>
}
  8000bf:	c9                   	leave  
  8000c0:	c3                   	ret    
  8000c1:	00 00                	add    %al,(%eax)
	...

008000c4 <sys_cgetc>:
}

int
sys_cgetc(void)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	83 ec 0c             	sub    $0xc,%esp
  8000ca:	89 1c 24             	mov    %ebx,(%esp)
  8000cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000d1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8000d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000da:	bf 00 00 00 00       	mov    $0x0,%edi
  8000df:	89 fa                	mov    %edi,%edx
  8000e1:	89 f9                	mov    %edi,%ecx
  8000e3:	89 fb                	mov    %edi,%ebx
  8000e5:	89 fe                	mov    %edi,%esi
  8000e7:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e9:	8b 1c 24             	mov    (%esp),%ebx
  8000ec:	8b 74 24 04          	mov    0x4(%esp),%esi
  8000f0:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8000f4:	89 ec                	mov    %ebp,%esp
  8000f6:	5d                   	pop    %ebp
  8000f7:	c3                   	ret    

008000f8 <sys_cputs>:
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	83 ec 0c             	sub    $0xc,%esp
  8000fe:	89 1c 24             	mov    %ebx,(%esp)
  800101:	89 74 24 04          	mov    %esi,0x4(%esp)
  800105:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800109:	8b 55 08             	mov    0x8(%ebp),%edx
  80010c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80010f:	bf 00 00 00 00       	mov    $0x0,%edi
  800114:	89 f8                	mov    %edi,%eax
  800116:	89 fb                	mov    %edi,%ebx
  800118:	89 fe                	mov    %edi,%esi
  80011a:	cd 30                	int    $0x30
  80011c:	8b 1c 24             	mov    (%esp),%ebx
  80011f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800123:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800127:	89 ec                	mov    %ebp,%esp
  800129:	5d                   	pop    %ebp
  80012a:	c3                   	ret    

0080012b <sys_time_msec>:

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
  80012b:	55                   	push   %ebp
  80012c:	89 e5                	mov    %esp,%ebp
  80012e:	83 ec 0c             	sub    $0xc,%esp
  800131:	89 1c 24             	mov    %ebx,(%esp)
  800134:	89 74 24 04          	mov    %esi,0x4(%esp)
  800138:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80013c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800141:	bf 00 00 00 00       	mov    $0x0,%edi
  800146:	89 fa                	mov    %edi,%edx
  800148:	89 f9                	mov    %edi,%ecx
  80014a:	89 fb                	mov    %edi,%ebx
  80014c:	89 fe                	mov    %edi,%esi
  80014e:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800150:	8b 1c 24             	mov    (%esp),%ebx
  800153:	8b 74 24 04          	mov    0x4(%esp),%esi
  800157:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80015b:	89 ec                	mov    %ebp,%esp
  80015d:	5d                   	pop    %ebp
  80015e:	c3                   	ret    

0080015f <sys_ipc_recv>:
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	83 ec 28             	sub    $0x28,%esp
  800165:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800168:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  80016b:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  80016e:	8b 55 08             	mov    0x8(%ebp),%edx
  800171:	b8 0d 00 00 00       	mov    $0xd,%eax
  800176:	bf 00 00 00 00       	mov    $0x0,%edi
  80017b:	89 f9                	mov    %edi,%ecx
  80017d:	89 fb                	mov    %edi,%ebx
  80017f:	89 fe                	mov    %edi,%esi
  800181:	cd 30                	int    $0x30
  800183:	85 c0                	test   %eax,%eax
  800185:	7e 28                	jle    8001af <sys_ipc_recv+0x50>
  800187:	89 44 24 10          	mov    %eax,0x10(%esp)
  80018b:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800192:	00 
  800193:	c7 44 24 08 dc 22 80 	movl   $0x8022dc,0x8(%esp)
  80019a:	00 
  80019b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001a2:	00 
  8001a3:	c7 04 24 f9 22 80 00 	movl   $0x8022f9,(%esp)
  8001aa:	e8 19 11 00 00       	call   8012c8 <_panic>
  8001af:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  8001b2:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  8001b5:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  8001b8:	89 ec                	mov    %ebp,%esp
  8001ba:	5d                   	pop    %ebp
  8001bb:	c3                   	ret    

008001bc <sys_ipc_try_send>:
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	83 ec 0c             	sub    $0xc,%esp
  8001c2:	89 1c 24             	mov    %ebx,(%esp)
  8001c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001c9:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8001cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d9:	b8 0c 00 00 00       	mov    $0xc,%eax
  8001de:	be 00 00 00 00       	mov    $0x0,%esi
  8001e3:	cd 30                	int    $0x30
  8001e5:	8b 1c 24             	mov    (%esp),%ebx
  8001e8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8001ec:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8001f0:	89 ec                	mov    %ebp,%esp
  8001f2:	5d                   	pop    %ebp
  8001f3:	c3                   	ret    

008001f4 <sys_env_set_pgfault_upcall>:
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	83 ec 28             	sub    $0x28,%esp
  8001fa:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  8001fd:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800200:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800203:	8b 55 08             	mov    0x8(%ebp),%edx
  800206:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800209:	b8 0a 00 00 00       	mov    $0xa,%eax
  80020e:	bf 00 00 00 00       	mov    $0x0,%edi
  800213:	89 fb                	mov    %edi,%ebx
  800215:	89 fe                	mov    %edi,%esi
  800217:	cd 30                	int    $0x30
  800219:	85 c0                	test   %eax,%eax
  80021b:	7e 28                	jle    800245 <sys_env_set_pgfault_upcall+0x51>
  80021d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800221:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800228:	00 
  800229:	c7 44 24 08 dc 22 80 	movl   $0x8022dc,0x8(%esp)
  800230:	00 
  800231:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800238:	00 
  800239:	c7 04 24 f9 22 80 00 	movl   $0x8022f9,(%esp)
  800240:	e8 83 10 00 00       	call   8012c8 <_panic>
  800245:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800248:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  80024b:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  80024e:	89 ec                	mov    %ebp,%esp
  800250:	5d                   	pop    %ebp
  800251:	c3                   	ret    

00800252 <sys_env_set_trapframe>:
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
  800255:	83 ec 28             	sub    $0x28,%esp
  800258:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  80025b:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  80025e:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  800261:	8b 55 08             	mov    0x8(%ebp),%edx
  800264:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800267:	b8 09 00 00 00       	mov    $0x9,%eax
  80026c:	bf 00 00 00 00       	mov    $0x0,%edi
  800271:	89 fb                	mov    %edi,%ebx
  800273:	89 fe                	mov    %edi,%esi
  800275:	cd 30                	int    $0x30
  800277:	85 c0                	test   %eax,%eax
  800279:	7e 28                	jle    8002a3 <sys_env_set_trapframe+0x51>
  80027b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80027f:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800286:	00 
  800287:	c7 44 24 08 dc 22 80 	movl   $0x8022dc,0x8(%esp)
  80028e:	00 
  80028f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800296:	00 
  800297:	c7 04 24 f9 22 80 00 	movl   $0x8022f9,(%esp)
  80029e:	e8 25 10 00 00       	call   8012c8 <_panic>
  8002a3:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  8002a6:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  8002a9:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  8002ac:	89 ec                	mov    %ebp,%esp
  8002ae:	5d                   	pop    %ebp
  8002af:	c3                   	ret    

008002b0 <sys_env_set_status>:
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	83 ec 28             	sub    $0x28,%esp
  8002b6:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  8002b9:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  8002bc:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  8002bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c5:	b8 08 00 00 00       	mov    $0x8,%eax
  8002ca:	bf 00 00 00 00       	mov    $0x0,%edi
  8002cf:	89 fb                	mov    %edi,%ebx
  8002d1:	89 fe                	mov    %edi,%esi
  8002d3:	cd 30                	int    $0x30
  8002d5:	85 c0                	test   %eax,%eax
  8002d7:	7e 28                	jle    800301 <sys_env_set_status+0x51>
  8002d9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002dd:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002e4:	00 
  8002e5:	c7 44 24 08 dc 22 80 	movl   $0x8022dc,0x8(%esp)
  8002ec:	00 
  8002ed:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002f4:	00 
  8002f5:	c7 04 24 f9 22 80 00 	movl   $0x8022f9,(%esp)
  8002fc:	e8 c7 0f 00 00       	call   8012c8 <_panic>
  800301:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800304:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800307:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  80030a:	89 ec                	mov    %ebp,%esp
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_page_unmap>:
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	83 ec 28             	sub    $0x28,%esp
  800314:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800317:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  80031a:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  80031d:	8b 55 08             	mov    0x8(%ebp),%edx
  800320:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800323:	b8 06 00 00 00       	mov    $0x6,%eax
  800328:	bf 00 00 00 00       	mov    $0x0,%edi
  80032d:	89 fb                	mov    %edi,%ebx
  80032f:	89 fe                	mov    %edi,%esi
  800331:	cd 30                	int    $0x30
  800333:	85 c0                	test   %eax,%eax
  800335:	7e 28                	jle    80035f <sys_page_unmap+0x51>
  800337:	89 44 24 10          	mov    %eax,0x10(%esp)
  80033b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800342:	00 
  800343:	c7 44 24 08 dc 22 80 	movl   $0x8022dc,0x8(%esp)
  80034a:	00 
  80034b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800352:	00 
  800353:	c7 04 24 f9 22 80 00 	movl   $0x8022f9,(%esp)
  80035a:	e8 69 0f 00 00       	call   8012c8 <_panic>
  80035f:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800362:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800365:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800368:	89 ec                	mov    %ebp,%esp
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    

0080036c <sys_page_map>:
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	83 ec 28             	sub    $0x28,%esp
  800372:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  800375:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  800378:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  80037b:	8b 55 08             	mov    0x8(%ebp),%edx
  80037e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800381:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800384:	8b 7d 14             	mov    0x14(%ebp),%edi
  800387:	8b 75 18             	mov    0x18(%ebp),%esi
  80038a:	b8 05 00 00 00       	mov    $0x5,%eax
  80038f:	cd 30                	int    $0x30
  800391:	85 c0                	test   %eax,%eax
  800393:	7e 28                	jle    8003bd <sys_page_map+0x51>
  800395:	89 44 24 10          	mov    %eax,0x10(%esp)
  800399:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8003a0:	00 
  8003a1:	c7 44 24 08 dc 22 80 	movl   $0x8022dc,0x8(%esp)
  8003a8:	00 
  8003a9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003b0:	00 
  8003b1:	c7 04 24 f9 22 80 00 	movl   $0x8022f9,(%esp)
  8003b8:	e8 0b 0f 00 00       	call   8012c8 <_panic>
  8003bd:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  8003c0:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  8003c3:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  8003c6:	89 ec                	mov    %ebp,%esp
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <sys_page_alloc>:
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	83 ec 28             	sub    $0x28,%esp
  8003d0:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  8003d3:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  8003d6:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  8003d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003df:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003e2:	b8 04 00 00 00       	mov    $0x4,%eax
  8003e7:	bf 00 00 00 00       	mov    $0x0,%edi
  8003ec:	89 fe                	mov    %edi,%esi
  8003ee:	cd 30                	int    $0x30
  8003f0:	85 c0                	test   %eax,%eax
  8003f2:	7e 28                	jle    80041c <sys_page_alloc+0x52>
  8003f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003f8:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8003ff:	00 
  800400:	c7 44 24 08 dc 22 80 	movl   $0x8022dc,0x8(%esp)
  800407:	00 
  800408:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80040f:	00 
  800410:	c7 04 24 f9 22 80 00 	movl   $0x8022f9,(%esp)
  800417:	e8 ac 0e 00 00       	call   8012c8 <_panic>
  80041c:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  80041f:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800422:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800425:	89 ec                	mov    %ebp,%esp
  800427:	5d                   	pop    %ebp
  800428:	c3                   	ret    

00800429 <sys_yield>:
  800429:	55                   	push   %ebp
  80042a:	89 e5                	mov    %esp,%ebp
  80042c:	83 ec 0c             	sub    $0xc,%esp
  80042f:	89 1c 24             	mov    %ebx,(%esp)
  800432:	89 74 24 04          	mov    %esi,0x4(%esp)
  800436:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80043a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80043f:	bf 00 00 00 00       	mov    $0x0,%edi
  800444:	89 fa                	mov    %edi,%edx
  800446:	89 f9                	mov    %edi,%ecx
  800448:	89 fb                	mov    %edi,%ebx
  80044a:	89 fe                	mov    %edi,%esi
  80044c:	cd 30                	int    $0x30
  80044e:	8b 1c 24             	mov    (%esp),%ebx
  800451:	8b 74 24 04          	mov    0x4(%esp),%esi
  800455:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800459:	89 ec                	mov    %ebp,%esp
  80045b:	5d                   	pop    %ebp
  80045c:	c3                   	ret    

0080045d <sys_getenvid>:
  80045d:	55                   	push   %ebp
  80045e:	89 e5                	mov    %esp,%ebp
  800460:	83 ec 0c             	sub    $0xc,%esp
  800463:	89 1c 24             	mov    %ebx,(%esp)
  800466:	89 74 24 04          	mov    %esi,0x4(%esp)
  80046a:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80046e:	b8 02 00 00 00       	mov    $0x2,%eax
  800473:	bf 00 00 00 00       	mov    $0x0,%edi
  800478:	89 fa                	mov    %edi,%edx
  80047a:	89 f9                	mov    %edi,%ecx
  80047c:	89 fb                	mov    %edi,%ebx
  80047e:	89 fe                	mov    %edi,%esi
  800480:	cd 30                	int    $0x30
  800482:	8b 1c 24             	mov    (%esp),%ebx
  800485:	8b 74 24 04          	mov    0x4(%esp),%esi
  800489:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80048d:	89 ec                	mov    %ebp,%esp
  80048f:	5d                   	pop    %ebp
  800490:	c3                   	ret    

00800491 <sys_env_destroy>:
  800491:	55                   	push   %ebp
  800492:	89 e5                	mov    %esp,%ebp
  800494:	83 ec 28             	sub    $0x28,%esp
  800497:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  80049a:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  80049d:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  8004a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8004a3:	b8 03 00 00 00       	mov    $0x3,%eax
  8004a8:	bf 00 00 00 00       	mov    $0x0,%edi
  8004ad:	89 f9                	mov    %edi,%ecx
  8004af:	89 fb                	mov    %edi,%ebx
  8004b1:	89 fe                	mov    %edi,%esi
  8004b3:	cd 30                	int    $0x30
  8004b5:	85 c0                	test   %eax,%eax
  8004b7:	7e 28                	jle    8004e1 <sys_env_destroy+0x50>
  8004b9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004bd:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8004c4:	00 
  8004c5:	c7 44 24 08 dc 22 80 	movl   $0x8022dc,0x8(%esp)
  8004cc:	00 
  8004cd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8004d4:	00 
  8004d5:	c7 04 24 f9 22 80 00 	movl   $0x8022f9,(%esp)
  8004dc:	e8 e7 0d 00 00       	call   8012c8 <_panic>
  8004e1:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  8004e4:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  8004e7:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  8004ea:	89 ec                	mov    %ebp,%esp
  8004ec:	5d                   	pop    %ebp
  8004ed:	c3                   	ret    
	...

008004f0 <fd2num>:
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8004f0:	55                   	push   %ebp
  8004f1:	89 e5                	mov    %esp,%ebp
  8004f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8004fb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8004fe:	5d                   	pop    %ebp
  8004ff:	c3                   	ret    

00800500 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800500:	55                   	push   %ebp
  800501:	89 e5                	mov    %esp,%ebp
  800503:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800506:	8b 45 08             	mov    0x8(%ebp),%eax
  800509:	89 04 24             	mov    %eax,(%esp)
  80050c:	e8 df ff ff ff       	call   8004f0 <fd2num>
  800511:	c1 e0 0c             	shl    $0xc,%eax
  800514:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800519:	c9                   	leave  
  80051a:	c3                   	ret    

0080051b <fd_alloc>:

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
  80051b:	55                   	push   %ebp
  80051c:	89 e5                	mov    %esp,%ebp
  80051e:	53                   	push   %ebx
  80051f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800522:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  800527:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  800529:	89 d0                	mov    %edx,%eax
  80052b:	c1 e8 16             	shr    $0x16,%eax
  80052e:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  800535:	a8 01                	test   $0x1,%al
  800537:	74 10                	je     800549 <fd_alloc+0x2e>
  800539:	89 d0                	mov    %edx,%eax
  80053b:	c1 e8 0c             	shr    $0xc,%eax
  80053e:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  800545:	a8 01                	test   $0x1,%al
  800547:	75 09                	jne    800552 <fd_alloc+0x37>
			*fd_store = fd;
  800549:	89 0b                	mov    %ecx,(%ebx)
  80054b:	b8 00 00 00 00       	mov    $0x0,%eax
  800550:	eb 19                	jmp    80056b <fd_alloc+0x50>
			return 0;
  800552:	81 c2 00 10 00 00    	add    $0x1000,%edx
  800558:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  80055e:	75 c7                	jne    800527 <fd_alloc+0xc>
		}
	}
	*fd_store = 0;
  800560:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800566:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  80056b:	5b                   	pop    %ebx
  80056c:	5d                   	pop    %ebp
  80056d:	c3                   	ret    

0080056e <fd_lookup>:

// Check that fdnum is in range and mapped.
// If it is, set *fd_store to the fd page virtual address.
//
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80056e:	55                   	push   %ebp
  80056f:	89 e5                	mov    %esp,%ebp
  800571:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800574:	83 f8 1f             	cmp    $0x1f,%eax
  800577:	77 35                	ja     8005ae <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800579:	c1 e0 0c             	shl    $0xc,%eax
  80057c:	8d 90 00 00 00 d0    	lea    0xd0000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  800582:	89 d0                	mov    %edx,%eax
  800584:	c1 e8 16             	shr    $0x16,%eax
  800587:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  80058e:	a8 01                	test   $0x1,%al
  800590:	74 1c                	je     8005ae <fd_lookup+0x40>
  800592:	89 d0                	mov    %edx,%eax
  800594:	c1 e8 0c             	shr    $0xc,%eax
  800597:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  80059e:	a8 01                	test   $0x1,%al
  8005a0:	74 0c                	je     8005ae <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8005a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005a5:	89 10                	mov    %edx,(%eax)
  8005a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ac:	eb 05                	jmp    8005b3 <fd_lookup+0x45>
	return 0;
  8005ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8005b3:	5d                   	pop    %ebp
  8005b4:	c3                   	ret    

008005b5 <seek>:

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
  8005b5:	55                   	push   %ebp
  8005b6:	89 e5                	mov    %esp,%ebp
  8005b8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005bb:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  8005be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c5:	89 04 24             	mov    %eax,(%esp)
  8005c8:	e8 a1 ff ff ff       	call   80056e <fd_lookup>
  8005cd:	85 c0                	test   %eax,%eax
  8005cf:	78 0e                	js     8005df <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8005d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005d4:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  8005d7:	89 50 04             	mov    %edx,0x4(%eax)
  8005da:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8005df:	c9                   	leave  
  8005e0:	c3                   	ret    

008005e1 <dev_lookup>:
  8005e1:	55                   	push   %ebp
  8005e2:	89 e5                	mov    %esp,%ebp
  8005e4:	53                   	push   %ebx
  8005e5:	83 ec 14             	sub    $0x14,%esp
  8005e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ee:	ba 04 60 80 00       	mov    $0x806004,%edx
  8005f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f8:	39 0d 04 60 80 00    	cmp    %ecx,0x806004
  8005fe:	75 12                	jne    800612 <dev_lookup+0x31>
  800600:	eb 04                	jmp    800606 <dev_lookup+0x25>
  800602:	39 0a                	cmp    %ecx,(%edx)
  800604:	75 0c                	jne    800612 <dev_lookup+0x31>
  800606:	89 13                	mov    %edx,(%ebx)
  800608:	b8 00 00 00 00       	mov    $0x0,%eax
  80060d:	8d 76 00             	lea    0x0(%esi),%esi
  800610:	eb 35                	jmp    800647 <dev_lookup+0x66>
  800612:	83 c0 01             	add    $0x1,%eax
  800615:	8b 14 85 84 23 80 00 	mov    0x802384(,%eax,4),%edx
  80061c:	85 d2                	test   %edx,%edx
  80061e:	75 e2                	jne    800602 <dev_lookup+0x21>
  800620:	a1 3c 60 80 00       	mov    0x80603c,%eax
  800625:	8b 40 4c             	mov    0x4c(%eax),%eax
  800628:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80062c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800630:	c7 04 24 08 23 80 00 	movl   $0x802308,(%esp)
  800637:	e8 59 0d 00 00       	call   801395 <cprintf>
  80063c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800642:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800647:	83 c4 14             	add    $0x14,%esp
  80064a:	5b                   	pop    %ebx
  80064b:	5d                   	pop    %ebp
  80064c:	c3                   	ret    

0080064d <fstat>:

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
  80064d:	55                   	push   %ebp
  80064e:	89 e5                	mov    %esp,%ebp
  800650:	53                   	push   %ebx
  800651:	83 ec 24             	sub    $0x24,%esp
  800654:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800657:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80065a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065e:	8b 45 08             	mov    0x8(%ebp),%eax
  800661:	89 04 24             	mov    %eax,(%esp)
  800664:	e8 05 ff ff ff       	call   80056e <fd_lookup>
  800669:	89 c2                	mov    %eax,%edx
  80066b:	85 c0                	test   %eax,%eax
  80066d:	78 57                	js     8006c6 <fstat+0x79>
  80066f:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  800672:	89 44 24 04          	mov    %eax,0x4(%esp)
  800676:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  800679:	8b 00                	mov    (%eax),%eax
  80067b:	89 04 24             	mov    %eax,(%esp)
  80067e:	e8 5e ff ff ff       	call   8005e1 <dev_lookup>
  800683:	89 c2                	mov    %eax,%edx
  800685:	85 c0                	test   %eax,%eax
  800687:	78 3d                	js     8006c6 <fstat+0x79>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  800689:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  80068e:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
  800691:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800695:	74 2f                	je     8006c6 <fstat+0x79>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800697:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80069a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8006a1:	00 00 00 
	stat->st_isdir = 0;
  8006a4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8006ab:	00 00 00 
	stat->st_dev = dev;
  8006ae:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  8006b1:	89 93 88 00 00 00    	mov    %edx,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8006b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bb:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8006be:	89 04 24             	mov    %eax,(%esp)
  8006c1:	ff 52 14             	call   *0x14(%edx)
  8006c4:	89 c2                	mov    %eax,%edx
}
  8006c6:	89 d0                	mov    %edx,%eax
  8006c8:	83 c4 24             	add    $0x24,%esp
  8006cb:	5b                   	pop    %ebx
  8006cc:	5d                   	pop    %ebp
  8006cd:	c3                   	ret    

008006ce <ftruncate>:
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	53                   	push   %ebx
  8006d2:	83 ec 24             	sub    $0x24,%esp
  8006d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8006d8:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8006db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006df:	89 1c 24             	mov    %ebx,(%esp)
  8006e2:	e8 87 fe ff ff       	call   80056e <fd_lookup>
  8006e7:	85 c0                	test   %eax,%eax
  8006e9:	78 61                	js     80074c <ftruncate+0x7e>
  8006eb:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8006ee:	8b 10                	mov    (%eax),%edx
  8006f0:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  8006f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f7:	89 14 24             	mov    %edx,(%esp)
  8006fa:	e8 e2 fe ff ff       	call   8005e1 <dev_lookup>
  8006ff:	85 c0                	test   %eax,%eax
  800701:	78 49                	js     80074c <ftruncate+0x7e>
  800703:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  800706:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  80070a:	75 23                	jne    80072f <ftruncate+0x61>
  80070c:	a1 3c 60 80 00       	mov    0x80603c,%eax
  800711:	8b 40 4c             	mov    0x4c(%eax),%eax
  800714:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800718:	89 44 24 04          	mov    %eax,0x4(%esp)
  80071c:	c7 04 24 28 23 80 00 	movl   $0x802328,(%esp)
  800723:	e8 6d 0c 00 00       	call   801395 <cprintf>
  800728:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80072d:	eb 1d                	jmp    80074c <ftruncate+0x7e>
  80072f:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  800732:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800737:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  80073b:	74 0f                	je     80074c <ftruncate+0x7e>
  80073d:	8b 52 18             	mov    0x18(%edx),%edx
  800740:	8b 45 0c             	mov    0xc(%ebp),%eax
  800743:	89 44 24 04          	mov    %eax,0x4(%esp)
  800747:	89 0c 24             	mov    %ecx,(%esp)
  80074a:	ff d2                	call   *%edx
  80074c:	83 c4 24             	add    $0x24,%esp
  80074f:	5b                   	pop    %ebx
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <write>:
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	53                   	push   %ebx
  800756:	83 ec 24             	sub    $0x24,%esp
  800759:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80075c:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80075f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800763:	89 1c 24             	mov    %ebx,(%esp)
  800766:	e8 03 fe ff ff       	call   80056e <fd_lookup>
  80076b:	85 c0                	test   %eax,%eax
  80076d:	78 68                	js     8007d7 <write+0x85>
  80076f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  800772:	8b 10                	mov    (%eax),%edx
  800774:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  800777:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077b:	89 14 24             	mov    %edx,(%esp)
  80077e:	e8 5e fe ff ff       	call   8005e1 <dev_lookup>
  800783:	85 c0                	test   %eax,%eax
  800785:	78 50                	js     8007d7 <write+0x85>
  800787:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  80078a:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  80078e:	75 23                	jne    8007b3 <write+0x61>
  800790:	a1 3c 60 80 00       	mov    0x80603c,%eax
  800795:	8b 40 4c             	mov    0x4c(%eax),%eax
  800798:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80079c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a0:	c7 04 24 49 23 80 00 	movl   $0x802349,(%esp)
  8007a7:	e8 e9 0b 00 00       	call   801395 <cprintf>
  8007ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b1:	eb 24                	jmp    8007d7 <write+0x85>
  8007b3:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  8007b6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007bb:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  8007bf:	74 16                	je     8007d7 <write+0x85>
  8007c1:	8b 42 0c             	mov    0xc(%edx),%eax
  8007c4:	8b 55 10             	mov    0x10(%ebp),%edx
  8007c7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8007cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007d2:	89 0c 24             	mov    %ecx,(%esp)
  8007d5:	ff d0                	call   *%eax
  8007d7:	83 c4 24             	add    $0x24,%esp
  8007da:	5b                   	pop    %ebx
  8007db:	5d                   	pop    %ebp
  8007dc:	c3                   	ret    

008007dd <read>:
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	53                   	push   %ebx
  8007e1:	83 ec 24             	sub    $0x24,%esp
  8007e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007e7:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  8007ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ee:	89 1c 24             	mov    %ebx,(%esp)
  8007f1:	e8 78 fd ff ff       	call   80056e <fd_lookup>
  8007f6:	85 c0                	test   %eax,%eax
  8007f8:	78 6d                	js     800867 <read+0x8a>
  8007fa:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  8007fd:	8b 10                	mov    (%eax),%edx
  8007ff:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  800802:	89 44 24 04          	mov    %eax,0x4(%esp)
  800806:	89 14 24             	mov    %edx,(%esp)
  800809:	e8 d3 fd ff ff       	call   8005e1 <dev_lookup>
  80080e:	85 c0                	test   %eax,%eax
  800810:	78 55                	js     800867 <read+0x8a>
  800812:	8b 4d f4             	mov    0xfffffff4(%ebp),%ecx
  800815:	8b 41 08             	mov    0x8(%ecx),%eax
  800818:	83 e0 03             	and    $0x3,%eax
  80081b:	83 f8 01             	cmp    $0x1,%eax
  80081e:	75 23                	jne    800843 <read+0x66>
  800820:	a1 3c 60 80 00       	mov    0x80603c,%eax
  800825:	8b 40 4c             	mov    0x4c(%eax),%eax
  800828:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80082c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800830:	c7 04 24 66 23 80 00 	movl   $0x802366,(%esp)
  800837:	e8 59 0b 00 00       	call   801395 <cprintf>
  80083c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800841:	eb 24                	jmp    800867 <read+0x8a>
  800843:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
  800846:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80084b:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  80084f:	74 16                	je     800867 <read+0x8a>
  800851:	8b 42 08             	mov    0x8(%edx),%eax
  800854:	8b 55 10             	mov    0x10(%ebp),%edx
  800857:	89 54 24 08          	mov    %edx,0x8(%esp)
  80085b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800862:	89 0c 24             	mov    %ecx,(%esp)
  800865:	ff d0                	call   *%eax
  800867:	83 c4 24             	add    $0x24,%esp
  80086a:	5b                   	pop    %ebx
  80086b:	5d                   	pop    %ebp
  80086c:	c3                   	ret    

0080086d <readn>:
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	57                   	push   %edi
  800871:	56                   	push   %esi
  800872:	53                   	push   %ebx
  800873:	83 ec 0c             	sub    $0xc,%esp
  800876:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800879:	8b 75 10             	mov    0x10(%ebp),%esi
  80087c:	b8 00 00 00 00       	mov    $0x0,%eax
  800881:	85 f6                	test   %esi,%esi
  800883:	74 36                	je     8008bb <readn+0x4e>
  800885:	bb 00 00 00 00       	mov    $0x0,%ebx
  80088a:	ba 00 00 00 00       	mov    $0x0,%edx
  80088f:	89 f0                	mov    %esi,%eax
  800891:	29 d0                	sub    %edx,%eax
  800893:	89 44 24 08          	mov    %eax,0x8(%esp)
  800897:	8d 04 17             	lea    (%edi,%edx,1),%eax
  80089a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80089e:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a1:	89 04 24             	mov    %eax,(%esp)
  8008a4:	e8 34 ff ff ff       	call   8007dd <read>
  8008a9:	85 c0                	test   %eax,%eax
  8008ab:	78 0e                	js     8008bb <readn+0x4e>
  8008ad:	85 c0                	test   %eax,%eax
  8008af:	74 08                	je     8008b9 <readn+0x4c>
  8008b1:	01 c3                	add    %eax,%ebx
  8008b3:	89 da                	mov    %ebx,%edx
  8008b5:	39 f3                	cmp    %esi,%ebx
  8008b7:	72 d6                	jb     80088f <readn+0x22>
  8008b9:	89 d8                	mov    %ebx,%eax
  8008bb:	83 c4 0c             	add    $0xc,%esp
  8008be:	5b                   	pop    %ebx
  8008bf:	5e                   	pop    %esi
  8008c0:	5f                   	pop    %edi
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <fd_close>:
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	83 ec 28             	sub    $0x28,%esp
  8008c9:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  8008cc:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  8008cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d2:	89 34 24             	mov    %esi,(%esp)
  8008d5:	e8 16 fc ff ff       	call   8004f0 <fd2num>
  8008da:	8d 55 f4             	lea    0xfffffff4(%ebp),%edx
  8008dd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008e1:	89 04 24             	mov    %eax,(%esp)
  8008e4:	e8 85 fc ff ff       	call   80056e <fd_lookup>
  8008e9:	89 c3                	mov    %eax,%ebx
  8008eb:	85 c0                	test   %eax,%eax
  8008ed:	78 05                	js     8008f4 <fd_close+0x31>
  8008ef:	3b 75 f4             	cmp    0xfffffff4(%ebp),%esi
  8008f2:	74 0e                	je     800902 <fd_close+0x3f>
  8008f4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008f8:	75 45                	jne    80093f <fd_close+0x7c>
  8008fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008ff:	90                   	nop    
  800900:	eb 3d                	jmp    80093f <fd_close+0x7c>
  800902:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  800905:	89 44 24 04          	mov    %eax,0x4(%esp)
  800909:	8b 06                	mov    (%esi),%eax
  80090b:	89 04 24             	mov    %eax,(%esp)
  80090e:	e8 ce fc ff ff       	call   8005e1 <dev_lookup>
  800913:	89 c3                	mov    %eax,%ebx
  800915:	85 c0                	test   %eax,%eax
  800917:	78 16                	js     80092f <fd_close+0x6c>
  800919:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80091c:	8b 40 10             	mov    0x10(%eax),%eax
  80091f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800924:	85 c0                	test   %eax,%eax
  800926:	74 07                	je     80092f <fd_close+0x6c>
  800928:	89 34 24             	mov    %esi,(%esp)
  80092b:	ff d0                	call   *%eax
  80092d:	89 c3                	mov    %eax,%ebx
  80092f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800933:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80093a:	e8 cf f9 ff ff       	call   80030e <sys_page_unmap>
  80093f:	89 d8                	mov    %ebx,%eax
  800941:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  800944:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  800947:	89 ec                	mov    %ebp,%esp
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <close>:
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	83 ec 18             	sub    $0x18,%esp
  800951:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  800954:	89 44 24 04          	mov    %eax,0x4(%esp)
  800958:	8b 45 08             	mov    0x8(%ebp),%eax
  80095b:	89 04 24             	mov    %eax,(%esp)
  80095e:	e8 0b fc ff ff       	call   80056e <fd_lookup>
  800963:	85 c0                	test   %eax,%eax
  800965:	78 13                	js     80097a <close+0x2f>
  800967:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80096e:	00 
  80096f:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  800972:	89 04 24             	mov    %eax,(%esp)
  800975:	e8 49 ff ff ff       	call   8008c3 <fd_close>
  80097a:	c9                   	leave  
  80097b:	c3                   	ret    

0080097c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	83 ec 18             	sub    $0x18,%esp
  800982:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  800985:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800988:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80098f:	00 
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	89 04 24             	mov    %eax,(%esp)
  800996:	e8 58 03 00 00       	call   800cf3 <open>
  80099b:	89 c6                	mov    %eax,%esi
  80099d:	85 c0                	test   %eax,%eax
  80099f:	78 1b                	js     8009bc <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8009a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a8:	89 34 24             	mov    %esi,(%esp)
  8009ab:	e8 9d fc ff ff       	call   80064d <fstat>
  8009b0:	89 c3                	mov    %eax,%ebx
	close(fd);
  8009b2:	89 34 24             	mov    %esi,(%esp)
  8009b5:	e8 91 ff ff ff       	call   80094b <close>
  8009ba:	89 de                	mov    %ebx,%esi
	return r;
}
  8009bc:	89 f0                	mov    %esi,%eax
  8009be:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  8009c1:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  8009c4:	89 ec                	mov    %ebp,%esp
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    

008009c8 <dup>:
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	83 ec 38             	sub    $0x38,%esp
  8009ce:	89 5d f4             	mov    %ebx,0xfffffff4(%ebp)
  8009d1:	89 75 f8             	mov    %esi,0xfffffff8(%ebp)
  8009d4:	89 7d fc             	mov    %edi,0xfffffffc(%ebp)
  8009d7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8009da:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  8009dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e4:	89 04 24             	mov    %eax,(%esp)
  8009e7:	e8 82 fb ff ff       	call   80056e <fd_lookup>
  8009ec:	89 c3                	mov    %eax,%ebx
  8009ee:	85 c0                	test   %eax,%eax
  8009f0:	0f 88 e1 00 00 00    	js     800ad7 <dup+0x10f>
  8009f6:	89 3c 24             	mov    %edi,(%esp)
  8009f9:	e8 4d ff ff ff       	call   80094b <close>
  8009fe:	89 f8                	mov    %edi,%eax
  800a00:	c1 e0 0c             	shl    $0xc,%eax
  800a03:	8d b0 00 00 00 d0    	lea    0xd0000000(%eax),%esi
  800a09:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800a0c:	89 04 24             	mov    %eax,(%esp)
  800a0f:	e8 ec fa ff ff       	call   800500 <fd2data>
  800a14:	89 c3                	mov    %eax,%ebx
  800a16:	89 34 24             	mov    %esi,(%esp)
  800a19:	e8 e2 fa ff ff       	call   800500 <fd2data>
  800a1e:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  800a21:	89 d8                	mov    %ebx,%eax
  800a23:	c1 e8 16             	shr    $0x16,%eax
  800a26:	8b 04 85 00 d0 7b ef 	mov    0xef7bd000(,%eax,4),%eax
  800a2d:	a8 01                	test   $0x1,%al
  800a2f:	74 45                	je     800a76 <dup+0xae>
  800a31:	89 da                	mov    %ebx,%edx
  800a33:	c1 ea 0c             	shr    $0xc,%edx
  800a36:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  800a3d:	a8 01                	test   $0x1,%al
  800a3f:	74 35                	je     800a76 <dup+0xae>
  800a41:	8b 04 95 00 00 40 ef 	mov    0xef400000(,%edx,4),%eax
  800a48:	25 07 0e 00 00       	and    $0xe07,%eax
  800a4d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a51:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  800a54:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a58:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a5f:	00 
  800a60:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a64:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a6b:	e8 fc f8 ff ff       	call   80036c <sys_page_map>
  800a70:	89 c3                	mov    %eax,%ebx
  800a72:	85 c0                	test   %eax,%eax
  800a74:	78 3e                	js     800ab4 <dup+0xec>
  800a76:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  800a79:	89 d0                	mov    %edx,%eax
  800a7b:	c1 e8 0c             	shr    $0xc,%eax
  800a7e:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  800a85:	25 07 0e 00 00       	and    $0xe07,%eax
  800a8a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a8e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800a92:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a99:	00 
  800a9a:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a9e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800aa5:	e8 c2 f8 ff ff       	call   80036c <sys_page_map>
  800aaa:	89 c3                	mov    %eax,%ebx
  800aac:	85 c0                	test   %eax,%eax
  800aae:	78 04                	js     800ab4 <dup+0xec>
  800ab0:	89 fb                	mov    %edi,%ebx
  800ab2:	eb 23                	jmp    800ad7 <dup+0x10f>
  800ab4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ab8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800abf:	e8 4a f8 ff ff       	call   80030e <sys_page_unmap>
  800ac4:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  800ac7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800acb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ad2:	e8 37 f8 ff ff       	call   80030e <sys_page_unmap>
  800ad7:	89 d8                	mov    %ebx,%eax
  800ad9:	8b 5d f4             	mov    0xfffffff4(%ebp),%ebx
  800adc:	8b 75 f8             	mov    0xfffffff8(%ebp),%esi
  800adf:	8b 7d fc             	mov    0xfffffffc(%ebp),%edi
  800ae2:	89 ec                	mov    %ebp,%esp
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <close_all>:
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	53                   	push   %ebx
  800aea:	83 ec 04             	sub    $0x4,%esp
  800aed:	bb 00 00 00 00       	mov    $0x0,%ebx
  800af2:	89 1c 24             	mov    %ebx,(%esp)
  800af5:	e8 51 fe ff ff       	call   80094b <close>
  800afa:	83 c3 01             	add    $0x1,%ebx
  800afd:	83 fb 20             	cmp    $0x20,%ebx
  800b00:	75 f0                	jne    800af2 <close_all+0xc>
  800b02:	83 c4 04             	add    $0x4,%esp
  800b05:	5b                   	pop    %ebx
  800b06:	5d                   	pop    %ebp
  800b07:	c3                   	ret    

00800b08 <fsipc>:
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	53                   	push   %ebx
  800b0c:	83 ec 14             	sub    $0x14,%esp
  800b0f:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800b11:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  800b17:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800b1e:	00 
  800b1f:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  800b26:	00 
  800b27:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b2b:	89 14 24             	mov    %edx,(%esp)
  800b2e:	e8 1d 13 00 00       	call   801e50 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800b33:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800b3a:	00 
  800b3b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b3f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b46:	e8 b9 13 00 00       	call   801f04 <ipc_recv>
}
  800b4b:	83 c4 14             	add    $0x14,%esp
  800b4e:	5b                   	pop    %ebx
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <sync>:

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
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b57:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5c:	b8 08 00 00 00       	mov    $0x8,%eax
  800b61:	e8 a2 ff ff ff       	call   800b08 <fsipc>
}
  800b66:	c9                   	leave  
  800b67:	c3                   	ret    

00800b68 <devfile_trunc>:
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	83 ec 08             	sub    $0x8,%esp
  800b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b71:	8b 40 0c             	mov    0xc(%eax),%eax
  800b74:	a3 00 30 80 00       	mov    %eax,0x803000
  800b79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7c:	a3 04 30 80 00       	mov    %eax,0x803004
  800b81:	ba 00 00 00 00       	mov    $0x0,%edx
  800b86:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8b:	e8 78 ff ff ff       	call   800b08 <fsipc>
  800b90:	c9                   	leave  
  800b91:	c3                   	ret    

00800b92 <devfile_flush>:
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	83 ec 08             	sub    $0x8,%esp
  800b98:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9b:	8b 40 0c             	mov    0xc(%eax),%eax
  800b9e:	a3 00 30 80 00       	mov    %eax,0x803000
  800ba3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba8:	b8 06 00 00 00       	mov    $0x6,%eax
  800bad:	e8 56 ff ff ff       	call   800b08 <fsipc>
  800bb2:	c9                   	leave  
  800bb3:	c3                   	ret    

00800bb4 <devfile_stat>:
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	53                   	push   %ebx
  800bb8:	83 ec 14             	sub    $0x14,%esp
  800bbb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc1:	8b 40 0c             	mov    0xc(%eax),%eax
  800bc4:	a3 00 30 80 00       	mov    %eax,0x803000
  800bc9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bce:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd3:	e8 30 ff ff ff       	call   800b08 <fsipc>
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	78 2b                	js     800c07 <devfile_stat+0x53>
  800bdc:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  800be3:	00 
  800be4:	89 1c 24             	mov    %ebx,(%esp)
  800be7:	e8 35 0e 00 00       	call   801a21 <strcpy>
  800bec:	a1 80 30 80 00       	mov    0x803080,%eax
  800bf1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  800bf7:	a1 84 30 80 00       	mov    0x803084,%eax
  800bfc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  800c02:	b8 00 00 00 00       	mov    $0x0,%eax
  800c07:	83 c4 14             	add    $0x14,%esp
  800c0a:	5b                   	pop    %ebx
  800c0b:	5d                   	pop    %ebp
  800c0c:	c3                   	ret    

00800c0d <devfile_write>:
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	83 ec 18             	sub    $0x18,%esp
  800c13:	8b 55 10             	mov    0x10(%ebp),%edx
  800c16:	8b 45 08             	mov    0x8(%ebp),%eax
  800c19:	8b 40 0c             	mov    0xc(%eax),%eax
  800c1c:	a3 00 30 80 00       	mov    %eax,0x803000
  800c21:	89 d0                	mov    %edx,%eax
  800c23:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  800c29:	76 05                	jbe    800c30 <devfile_write+0x23>
  800c2b:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  800c30:	89 15 04 30 80 00    	mov    %edx,0x803004
  800c36:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c41:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  800c48:	e8 dd 0f 00 00       	call   801c2a <memmove>
  800c4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c52:	b8 04 00 00 00       	mov    $0x4,%eax
  800c57:	e8 ac fe ff ff       	call   800b08 <fsipc>
  800c5c:	c9                   	leave  
  800c5d:	c3                   	ret    

00800c5e <devfile_read>:
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	53                   	push   %ebx
  800c62:	83 ec 14             	sub    $0x14,%esp
  800c65:	8b 45 08             	mov    0x8(%ebp),%eax
  800c68:	8b 40 0c             	mov    0xc(%eax),%eax
  800c6b:	a3 00 30 80 00       	mov    %eax,0x803000
  800c70:	8b 45 10             	mov    0x10(%ebp),%eax
  800c73:	a3 04 30 80 00       	mov    %eax,0x803004
  800c78:	ba 00 30 80 00       	mov    $0x803000,%edx
  800c7d:	b8 03 00 00 00       	mov    $0x3,%eax
  800c82:	e8 81 fe ff ff       	call   800b08 <fsipc>
  800c87:	89 c3                	mov    %eax,%ebx
  800c89:	85 c0                	test   %eax,%eax
  800c8b:	7e 17                	jle    800ca4 <devfile_read+0x46>
  800c8d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c91:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  800c98:	00 
  800c99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c9c:	89 04 24             	mov    %eax,(%esp)
  800c9f:	e8 86 0f 00 00       	call   801c2a <memmove>
  800ca4:	89 d8                	mov    %ebx,%eax
  800ca6:	83 c4 14             	add    $0x14,%esp
  800ca9:	5b                   	pop    %ebx
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    

00800cac <remove>:
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	53                   	push   %ebx
  800cb0:	83 ec 14             	sub    $0x14,%esp
  800cb3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cb6:	89 1c 24             	mov    %ebx,(%esp)
  800cb9:	e8 12 0d 00 00       	call   8019d0 <strlen>
  800cbe:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  800cc3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800cc8:	7f 21                	jg     800ceb <remove+0x3f>
  800cca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cce:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  800cd5:	e8 47 0d 00 00       	call   801a21 <strcpy>
  800cda:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdf:	b8 07 00 00 00       	mov    $0x7,%eax
  800ce4:	e8 1f fe ff ff       	call   800b08 <fsipc>
  800ce9:	89 c2                	mov    %eax,%edx
  800ceb:	89 d0                	mov    %edx,%eax
  800ced:	83 c4 14             	add    $0x14,%esp
  800cf0:	5b                   	pop    %ebx
  800cf1:	5d                   	pop    %ebp
  800cf2:	c3                   	ret    

00800cf3 <open>:
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	56                   	push   %esi
  800cf7:	53                   	push   %ebx
  800cf8:	83 ec 30             	sub    $0x30,%esp
  800cfb:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  800cfe:	89 04 24             	mov    %eax,(%esp)
  800d01:	e8 15 f8 ff ff       	call   80051b <fd_alloc>
  800d06:	89 c3                	mov    %eax,%ebx
  800d08:	85 c0                	test   %eax,%eax
  800d0a:	79 18                	jns    800d24 <open+0x31>
  800d0c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d13:	00 
  800d14:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  800d17:	89 04 24             	mov    %eax,(%esp)
  800d1a:	e8 a4 fb ff ff       	call   8008c3 <fd_close>
  800d1f:	e9 9f 00 00 00       	jmp    800dc3 <open+0xd0>
  800d24:	8b 45 08             	mov    0x8(%ebp),%eax
  800d27:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d2b:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  800d32:	e8 ea 0c 00 00       	call   801a21 <strcpy>
  800d37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d3a:	a3 00 34 80 00       	mov    %eax,0x803400
  800d3f:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  800d42:	89 04 24             	mov    %eax,(%esp)
  800d45:	e8 b6 f7 ff ff       	call   800500 <fd2data>
  800d4a:	89 c6                	mov    %eax,%esi
  800d4c:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800d4f:	b8 01 00 00 00       	mov    $0x1,%eax
  800d54:	e8 af fd ff ff       	call   800b08 <fsipc>
  800d59:	89 c3                	mov    %eax,%ebx
  800d5b:	85 c0                	test   %eax,%eax
  800d5d:	79 15                	jns    800d74 <open+0x81>
  800d5f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800d66:	00 
  800d67:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  800d6a:	89 04 24             	mov    %eax,(%esp)
  800d6d:	e8 51 fb ff ff       	call   8008c3 <fd_close>
  800d72:	eb 4f                	jmp    800dc3 <open+0xd0>
  800d74:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800d7b:	00 
  800d7c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800d80:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d87:	00 
  800d88:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  800d8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d96:	e8 d1 f5 ff ff       	call   80036c <sys_page_map>
  800d9b:	89 c3                	mov    %eax,%ebx
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	79 15                	jns    800db6 <open+0xc3>
  800da1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800da8:	00 
  800da9:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  800dac:	89 04 24             	mov    %eax,(%esp)
  800daf:	e8 0f fb ff ff       	call   8008c3 <fd_close>
  800db4:	eb 0d                	jmp    800dc3 <open+0xd0>
  800db6:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  800db9:	89 04 24             	mov    %eax,(%esp)
  800dbc:	e8 2f f7 ff ff       	call   8004f0 <fd2num>
  800dc1:	89 c3                	mov    %eax,%ebx
  800dc3:	89 d8                	mov    %ebx,%eax
  800dc5:	83 c4 30             	add    $0x30,%esp
  800dc8:	5b                   	pop    %ebx
  800dc9:	5e                   	pop    %esi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    
  800dcc:	00 00                	add    %al,(%eax)
	...

00800dd0 <devsock_stat>:
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  800dd6:	c7 44 24 04 90 23 80 	movl   $0x802390,0x4(%esp)
  800ddd:	00 
  800dde:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de1:	89 04 24             	mov    %eax,(%esp)
  800de4:	e8 38 0c 00 00       	call   801a21 <strcpy>
	return 0;
}
  800de9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dee:	c9                   	leave  
  800def:	c3                   	ret    

00800df0 <devsock_close>:
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	83 ec 08             	sub    $0x8,%esp
  800df6:	8b 45 08             	mov    0x8(%ebp),%eax
  800df9:	8b 40 0c             	mov    0xc(%eax),%eax
  800dfc:	89 04 24             	mov    %eax,(%esp)
  800dff:	e8 be 02 00 00       	call   8010c2 <nsipc_close>
  800e04:	c9                   	leave  
  800e05:	c3                   	ret    

00800e06 <devsock_write>:
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	83 ec 18             	sub    $0x18,%esp
  800e0c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e13:	00 
  800e14:	8b 45 10             	mov    0x10(%ebp),%eax
  800e17:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e22:	8b 45 08             	mov    0x8(%ebp),%eax
  800e25:	8b 40 0c             	mov    0xc(%eax),%eax
  800e28:	89 04 24             	mov    %eax,(%esp)
  800e2b:	e8 ce 02 00 00       	call   8010fe <nsipc_send>
  800e30:	c9                   	leave  
  800e31:	c3                   	ret    

00800e32 <devsock_read>:
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	83 ec 18             	sub    $0x18,%esp
  800e38:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e3f:	00 
  800e40:	8b 45 10             	mov    0x10(%ebp),%eax
  800e43:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e51:	8b 40 0c             	mov    0xc(%eax),%eax
  800e54:	89 04 24             	mov    %eax,(%esp)
  800e57:	e8 15 03 00 00       	call   801171 <nsipc_recv>
  800e5c:	c9                   	leave  
  800e5d:	c3                   	ret    

00800e5e <alloc_sockfd>:
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
  800e61:	56                   	push   %esi
  800e62:	53                   	push   %ebx
  800e63:	83 ec 20             	sub    $0x20,%esp
  800e66:	89 c6                	mov    %eax,%esi
  800e68:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  800e6b:	89 04 24             	mov    %eax,(%esp)
  800e6e:	e8 a8 f6 ff ff       	call   80051b <fd_alloc>
  800e73:	89 c3                	mov    %eax,%ebx
  800e75:	85 c0                	test   %eax,%eax
  800e77:	78 21                	js     800e9a <alloc_sockfd+0x3c>
  800e79:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e80:	00 
  800e81:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  800e84:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e88:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e8f:	e8 36 f5 ff ff       	call   8003ca <sys_page_alloc>
  800e94:	89 c3                	mov    %eax,%ebx
  800e96:	85 c0                	test   %eax,%eax
  800e98:	79 0a                	jns    800ea4 <alloc_sockfd+0x46>
  800e9a:	89 34 24             	mov    %esi,(%esp)
  800e9d:	e8 20 02 00 00       	call   8010c2 <nsipc_close>
  800ea2:	eb 28                	jmp    800ecc <alloc_sockfd+0x6e>
  800ea4:	8b 15 20 60 80 00    	mov    0x806020,%edx
  800eaa:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  800ead:	89 10                	mov    %edx,(%eax)
  800eaf:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  800eb2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
  800eb9:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  800ebc:	89 70 0c             	mov    %esi,0xc(%eax)
  800ebf:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  800ec2:	89 04 24             	mov    %eax,(%esp)
  800ec5:	e8 26 f6 ff ff       	call   8004f0 <fd2num>
  800eca:	89 c3                	mov    %eax,%ebx
  800ecc:	89 d8                	mov    %ebx,%eax
  800ece:	83 c4 20             	add    $0x20,%esp
  800ed1:	5b                   	pop    %ebx
  800ed2:	5e                   	pop    %esi
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    

00800ed5 <socket>:

int
socket(int domain, int type, int protocol)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800edb:	8b 45 10             	mov    0x10(%ebp),%eax
  800ede:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ee2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ee9:	8b 45 08             	mov    0x8(%ebp),%eax
  800eec:	89 04 24             	mov    %eax,(%esp)
  800eef:	e8 82 01 00 00       	call   801076 <nsipc_socket>
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	78 05                	js     800efd <socket+0x28>
		return r;
	return alloc_sockfd(r);
  800ef8:	e8 61 ff ff ff       	call   800e5e <alloc_sockfd>
}
  800efd:	c9                   	leave  
  800efe:	66 90                	xchg   %ax,%ax
  800f00:	c3                   	ret    

00800f01 <fd2sockid>:
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	83 ec 18             	sub    $0x18,%esp
  800f07:	8d 55 fc             	lea    0xfffffffc(%ebp),%edx
  800f0a:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f0e:	89 04 24             	mov    %eax,(%esp)
  800f11:	e8 58 f6 ff ff       	call   80056e <fd_lookup>
  800f16:	89 c2                	mov    %eax,%edx
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	78 15                	js     800f31 <fd2sockid+0x30>
  800f1c:	8b 4d fc             	mov    0xfffffffc(%ebp),%ecx
  800f1f:	8b 01                	mov    (%ecx),%eax
  800f21:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  800f26:	3b 05 20 60 80 00    	cmp    0x806020,%eax
  800f2c:	75 03                	jne    800f31 <fd2sockid+0x30>
  800f2e:	8b 51 0c             	mov    0xc(%ecx),%edx
  800f31:	89 d0                	mov    %edx,%eax
  800f33:	c9                   	leave  
  800f34:	c3                   	ret    

00800f35 <listen>:
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	83 ec 08             	sub    $0x8,%esp
  800f3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3e:	e8 be ff ff ff       	call   800f01 <fd2sockid>
  800f43:	89 c2                	mov    %eax,%edx
  800f45:	85 c0                	test   %eax,%eax
  800f47:	78 11                	js     800f5a <listen+0x25>
  800f49:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f50:	89 14 24             	mov    %edx,(%esp)
  800f53:	e8 48 01 00 00       	call   8010a0 <nsipc_listen>
  800f58:	89 c2                	mov    %eax,%edx
  800f5a:	89 d0                	mov    %edx,%eax
  800f5c:	c9                   	leave  
  800f5d:	c3                   	ret    

00800f5e <connect>:
  800f5e:	55                   	push   %ebp
  800f5f:	89 e5                	mov    %esp,%ebp
  800f61:	83 ec 18             	sub    $0x18,%esp
  800f64:	8b 45 08             	mov    0x8(%ebp),%eax
  800f67:	e8 95 ff ff ff       	call   800f01 <fd2sockid>
  800f6c:	89 c2                	mov    %eax,%edx
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	78 18                	js     800f8a <connect+0x2c>
  800f72:	8b 45 10             	mov    0x10(%ebp),%eax
  800f75:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f80:	89 14 24             	mov    %edx,(%esp)
  800f83:	e8 71 02 00 00       	call   8011f9 <nsipc_connect>
  800f88:	89 c2                	mov    %eax,%edx
  800f8a:	89 d0                	mov    %edx,%eax
  800f8c:	c9                   	leave  
  800f8d:	c3                   	ret    

00800f8e <shutdown>:
  800f8e:	55                   	push   %ebp
  800f8f:	89 e5                	mov    %esp,%ebp
  800f91:	83 ec 08             	sub    $0x8,%esp
  800f94:	8b 45 08             	mov    0x8(%ebp),%eax
  800f97:	e8 65 ff ff ff       	call   800f01 <fd2sockid>
  800f9c:	89 c2                	mov    %eax,%edx
  800f9e:	85 c0                	test   %eax,%eax
  800fa0:	78 11                	js     800fb3 <shutdown+0x25>
  800fa2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fa5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fa9:	89 14 24             	mov    %edx,(%esp)
  800fac:	e8 2b 01 00 00       	call   8010dc <nsipc_shutdown>
  800fb1:	89 c2                	mov    %eax,%edx
  800fb3:	89 d0                	mov    %edx,%eax
  800fb5:	c9                   	leave  
  800fb6:	c3                   	ret    

00800fb7 <bind>:
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	83 ec 18             	sub    $0x18,%esp
  800fbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc0:	e8 3c ff ff ff       	call   800f01 <fd2sockid>
  800fc5:	89 c2                	mov    %eax,%edx
  800fc7:	85 c0                	test   %eax,%eax
  800fc9:	78 18                	js     800fe3 <bind+0x2c>
  800fcb:	8b 45 10             	mov    0x10(%ebp),%eax
  800fce:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fd2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fd5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fd9:	89 14 24             	mov    %edx,(%esp)
  800fdc:	e8 57 02 00 00       	call   801238 <nsipc_bind>
  800fe1:	89 c2                	mov    %eax,%edx
  800fe3:	89 d0                	mov    %edx,%eax
  800fe5:	c9                   	leave  
  800fe6:	c3                   	ret    

00800fe7 <accept>:
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	83 ec 18             	sub    $0x18,%esp
  800fed:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff0:	e8 0c ff ff ff       	call   800f01 <fd2sockid>
  800ff5:	89 c2                	mov    %eax,%edx
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	78 23                	js     80101e <accept+0x37>
  800ffb:	8b 45 10             	mov    0x10(%ebp),%eax
  800ffe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801002:	8b 45 0c             	mov    0xc(%ebp),%eax
  801005:	89 44 24 04          	mov    %eax,0x4(%esp)
  801009:	89 14 24             	mov    %edx,(%esp)
  80100c:	e8 66 02 00 00       	call   801277 <nsipc_accept>
  801011:	89 c2                	mov    %eax,%edx
  801013:	85 c0                	test   %eax,%eax
  801015:	78 07                	js     80101e <accept+0x37>
  801017:	e8 42 fe ff ff       	call   800e5e <alloc_sockfd>
  80101c:	89 c2                	mov    %eax,%edx
  80101e:	89 d0                	mov    %edx,%eax
  801020:	c9                   	leave  
  801021:	c3                   	ret    
	...

00801030 <nsipc>:
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801036:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  80103c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801043:	00 
  801044:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  80104b:	00 
  80104c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801050:	89 14 24             	mov    %edx,(%esp)
  801053:	e8 f8 0d 00 00       	call   801e50 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801058:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80105f:	00 
  801060:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801067:	00 
  801068:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80106f:	e8 90 0e 00 00       	call   801f04 <ipc_recv>
}
  801074:	c9                   	leave  
  801075:	c3                   	ret    

00801076 <nsipc_socket>:

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
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80107c:	8b 45 08             	mov    0x8(%ebp),%eax
  80107f:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.socket.req_type = type;
  801084:	8b 45 0c             	mov    0xc(%ebp),%eax
  801087:	a3 04 50 80 00       	mov    %eax,0x805004
	nsipcbuf.socket.req_protocol = protocol;
  80108c:	8b 45 10             	mov    0x10(%ebp),%eax
  80108f:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SOCKET);
  801094:	b8 09 00 00 00       	mov    $0x9,%eax
  801099:	e8 92 ff ff ff       	call   801030 <nsipc>
}
  80109e:	c9                   	leave  
  80109f:	c3                   	ret    

008010a0 <nsipc_listen>:
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	83 ec 08             	sub    $0x8,%esp
  8010a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a9:	a3 00 50 80 00       	mov    %eax,0x805000
  8010ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b1:	a3 04 50 80 00       	mov    %eax,0x805004
  8010b6:	b8 06 00 00 00       	mov    $0x6,%eax
  8010bb:	e8 70 ff ff ff       	call   801030 <nsipc>
  8010c0:	c9                   	leave  
  8010c1:	c3                   	ret    

008010c2 <nsipc_close>:
  8010c2:	55                   	push   %ebp
  8010c3:	89 e5                	mov    %esp,%ebp
  8010c5:	83 ec 08             	sub    $0x8,%esp
  8010c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cb:	a3 00 50 80 00       	mov    %eax,0x805000
  8010d0:	b8 04 00 00 00       	mov    $0x4,%eax
  8010d5:	e8 56 ff ff ff       	call   801030 <nsipc>
  8010da:	c9                   	leave  
  8010db:	c3                   	ret    

008010dc <nsipc_shutdown>:
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	83 ec 08             	sub    $0x8,%esp
  8010e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e5:	a3 00 50 80 00       	mov    %eax,0x805000
  8010ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010ed:	a3 04 50 80 00       	mov    %eax,0x805004
  8010f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8010f7:	e8 34 ff ff ff       	call   801030 <nsipc>
  8010fc:	c9                   	leave  
  8010fd:	c3                   	ret    

008010fe <nsipc_send>:
  8010fe:	55                   	push   %ebp
  8010ff:	89 e5                	mov    %esp,%ebp
  801101:	53                   	push   %ebx
  801102:	83 ec 14             	sub    $0x14,%esp
  801105:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801108:	8b 45 08             	mov    0x8(%ebp),%eax
  80110b:	a3 00 50 80 00       	mov    %eax,0x805000
  801110:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801116:	7e 24                	jle    80113c <nsipc_send+0x3e>
  801118:	c7 44 24 0c 9c 23 80 	movl   $0x80239c,0xc(%esp)
  80111f:	00 
  801120:	c7 44 24 08 a8 23 80 	movl   $0x8023a8,0x8(%esp)
  801127:	00 
  801128:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  80112f:	00 
  801130:	c7 04 24 bd 23 80 00 	movl   $0x8023bd,(%esp)
  801137:	e8 8c 01 00 00       	call   8012c8 <_panic>
  80113c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801140:	8b 45 0c             	mov    0xc(%ebp),%eax
  801143:	89 44 24 04          	mov    %eax,0x4(%esp)
  801147:	c7 04 24 0c 50 80 00 	movl   $0x80500c,(%esp)
  80114e:	e8 d7 0a 00 00       	call   801c2a <memmove>
  801153:	89 1d 04 50 80 00    	mov    %ebx,0x805004
  801159:	8b 45 14             	mov    0x14(%ebp),%eax
  80115c:	a3 08 50 80 00       	mov    %eax,0x805008
  801161:	b8 08 00 00 00       	mov    $0x8,%eax
  801166:	e8 c5 fe ff ff       	call   801030 <nsipc>
  80116b:	83 c4 14             	add    $0x14,%esp
  80116e:	5b                   	pop    %ebx
  80116f:	5d                   	pop    %ebp
  801170:	c3                   	ret    

00801171 <nsipc_recv>:
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	83 ec 18             	sub    $0x18,%esp
  801177:	89 5d f8             	mov    %ebx,0xfffffff8(%ebp)
  80117a:	89 75 fc             	mov    %esi,0xfffffffc(%ebp)
  80117d:	8b 75 10             	mov    0x10(%ebp),%esi
  801180:	8b 45 08             	mov    0x8(%ebp),%eax
  801183:	a3 00 50 80 00       	mov    %eax,0x805000
  801188:	89 35 04 50 80 00    	mov    %esi,0x805004
  80118e:	8b 45 14             	mov    0x14(%ebp),%eax
  801191:	a3 08 50 80 00       	mov    %eax,0x805008
  801196:	b8 07 00 00 00       	mov    $0x7,%eax
  80119b:	e8 90 fe ff ff       	call   801030 <nsipc>
  8011a0:	89 c3                	mov    %eax,%ebx
  8011a2:	85 c0                	test   %eax,%eax
  8011a4:	78 47                	js     8011ed <nsipc_recv+0x7c>
  8011a6:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8011ab:	7f 05                	jg     8011b2 <nsipc_recv+0x41>
  8011ad:	39 c6                	cmp    %eax,%esi
  8011af:	90                   	nop    
  8011b0:	7d 24                	jge    8011d6 <nsipc_recv+0x65>
  8011b2:	c7 44 24 0c c9 23 80 	movl   $0x8023c9,0xc(%esp)
  8011b9:	00 
  8011ba:	c7 44 24 08 a8 23 80 	movl   $0x8023a8,0x8(%esp)
  8011c1:	00 
  8011c2:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  8011c9:	00 
  8011ca:	c7 04 24 bd 23 80 00 	movl   $0x8023bd,(%esp)
  8011d1:	e8 f2 00 00 00       	call   8012c8 <_panic>
  8011d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011da:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8011e1:	00 
  8011e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011e5:	89 04 24             	mov    %eax,(%esp)
  8011e8:	e8 3d 0a 00 00       	call   801c2a <memmove>
  8011ed:	89 d8                	mov    %ebx,%eax
  8011ef:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
  8011f2:	8b 75 fc             	mov    0xfffffffc(%ebp),%esi
  8011f5:	89 ec                	mov    %ebp,%esp
  8011f7:	5d                   	pop    %ebp
  8011f8:	c3                   	ret    

008011f9 <nsipc_connect>:
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	53                   	push   %ebx
  8011fd:	83 ec 14             	sub    $0x14,%esp
  801200:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801203:	8b 45 08             	mov    0x8(%ebp),%eax
  801206:	a3 00 50 80 00       	mov    %eax,0x805000
  80120b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80120f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801212:	89 44 24 04          	mov    %eax,0x4(%esp)
  801216:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  80121d:	e8 08 0a 00 00       	call   801c2a <memmove>
  801222:	89 1d 14 50 80 00    	mov    %ebx,0x805014
  801228:	b8 05 00 00 00       	mov    $0x5,%eax
  80122d:	e8 fe fd ff ff       	call   801030 <nsipc>
  801232:	83 c4 14             	add    $0x14,%esp
  801235:	5b                   	pop    %ebx
  801236:	5d                   	pop    %ebp
  801237:	c3                   	ret    

00801238 <nsipc_bind>:
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	53                   	push   %ebx
  80123c:	83 ec 14             	sub    $0x14,%esp
  80123f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801242:	8b 45 08             	mov    0x8(%ebp),%eax
  801245:	a3 00 50 80 00       	mov    %eax,0x805000
  80124a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80124e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801251:	89 44 24 04          	mov    %eax,0x4(%esp)
  801255:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  80125c:	e8 c9 09 00 00       	call   801c2a <memmove>
  801261:	89 1d 14 50 80 00    	mov    %ebx,0x805014
  801267:	b8 02 00 00 00       	mov    $0x2,%eax
  80126c:	e8 bf fd ff ff       	call   801030 <nsipc>
  801271:	83 c4 14             	add    $0x14,%esp
  801274:	5b                   	pop    %ebx
  801275:	5d                   	pop    %ebp
  801276:	c3                   	ret    

00801277 <nsipc_accept>:
  801277:	55                   	push   %ebp
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	53                   	push   %ebx
  80127b:	83 ec 14             	sub    $0x14,%esp
  80127e:	8b 45 08             	mov    0x8(%ebp),%eax
  801281:	a3 00 50 80 00       	mov    %eax,0x805000
  801286:	b8 01 00 00 00       	mov    $0x1,%eax
  80128b:	e8 a0 fd ff ff       	call   801030 <nsipc>
  801290:	89 c3                	mov    %eax,%ebx
  801292:	85 c0                	test   %eax,%eax
  801294:	78 27                	js     8012bd <nsipc_accept+0x46>
  801296:	a1 10 50 80 00       	mov    0x805010,%eax
  80129b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80129f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8012a6:	00 
  8012a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012aa:	89 04 24             	mov    %eax,(%esp)
  8012ad:	e8 78 09 00 00       	call   801c2a <memmove>
  8012b2:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8012b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8012bb:	89 10                	mov    %edx,(%eax)
  8012bd:	89 d8                	mov    %ebx,%eax
  8012bf:	83 c4 14             	add    $0x14,%esp
  8012c2:	5b                   	pop    %ebx
  8012c3:	5d                   	pop    %ebp
  8012c4:	c3                   	ret    
  8012c5:	00 00                	add    %al,(%eax)
	...

008012c8 <_panic>:
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  8012c8:	55                   	push   %ebp
  8012c9:	89 e5                	mov    %esp,%ebp
  8012cb:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8012ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8012d1:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)

	// Print the panic message
	if (argv0)
  8012d4:	a1 40 60 80 00       	mov    0x806040,%eax
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	74 10                	je     8012ed <_panic+0x25>
		cprintf("%s: ", argv0);
  8012dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e1:	c7 04 24 de 23 80 00 	movl   $0x8023de,(%esp)
  8012e8:	e8 a8 00 00 00       	call   801395 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8012ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012fb:	a1 00 60 80 00       	mov    0x806000,%eax
  801300:	89 44 24 04          	mov    %eax,0x4(%esp)
  801304:	c7 04 24 e3 23 80 00 	movl   $0x8023e3,(%esp)
  80130b:	e8 85 00 00 00       	call   801395 <cprintf>
	vcprintf(fmt, ap);
  801310:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
  801313:	89 44 24 04          	mov    %eax,0x4(%esp)
  801317:	8b 45 10             	mov    0x10(%ebp),%eax
  80131a:	89 04 24             	mov    %eax,(%esp)
  80131d:	e8 12 00 00 00       	call   801334 <vcprintf>
	cprintf("\n");
  801322:	c7 04 24 42 27 80 00 	movl   $0x802742,(%esp)
  801329:	e8 67 00 00 00       	call   801395 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80132e:	cc                   	int3   
  80132f:	eb fd                	jmp    80132e <_panic+0x66>
  801331:	00 00                	add    %al,(%eax)
	...

00801334 <vcprintf>:
}

int
vcprintf(const char *fmt, va_list ap)
{
  801334:	55                   	push   %ebp
  801335:	89 e5                	mov    %esp,%ebp
  801337:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80133d:	c7 85 f8 fe ff ff 00 	movl   $0x0,0xfffffef8(%ebp)
  801344:	00 00 00 
	b.cnt = 0;
  801347:	c7 85 fc fe ff ff 00 	movl   $0x0,0xfffffefc(%ebp)
  80134e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801351:	8b 45 0c             	mov    0xc(%ebp),%eax
  801354:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801358:	8b 45 08             	mov    0x8(%ebp),%eax
  80135b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80135f:	8d 85 f8 fe ff ff    	lea    0xfffffef8(%ebp),%eax
  801365:	89 44 24 04          	mov    %eax,0x4(%esp)
  801369:	c7 04 24 b2 13 80 00 	movl   $0x8013b2,(%esp)
  801370:	e8 cc 01 00 00       	call   801541 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801375:	8b 85 f8 fe ff ff    	mov    0xfffffef8(%ebp),%eax
  80137b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137f:	8d 85 00 ff ff ff    	lea    0xffffff00(%ebp),%eax
  801385:	89 04 24             	mov    %eax,(%esp)
  801388:	e8 6b ed ff ff       	call   8000f8 <sys_cputs>
  80138d:	8b 85 fc fe ff ff    	mov    0xfffffefc(%ebp),%eax

	return b.cnt;
}
  801393:	c9                   	leave  
  801394:	c3                   	ret    

00801395 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
  801398:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80139b:	8d 45 0c             	lea    0xc(%ebp),%eax
  80139e:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
	cnt = vcprintf(fmt, ap);
  8013a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a8:	89 04 24             	mov    %eax,(%esp)
  8013ab:	e8 84 ff ff ff       	call   801334 <vcprintf>
	va_end(ap);

	return cnt;
}
  8013b0:	c9                   	leave  
  8013b1:	c3                   	ret    

008013b2 <putch>:
  8013b2:	55                   	push   %ebp
  8013b3:	89 e5                	mov    %esp,%ebp
  8013b5:	53                   	push   %ebx
  8013b6:	83 ec 14             	sub    $0x14,%esp
  8013b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013bc:	8b 03                	mov    (%ebx),%eax
  8013be:	8b 55 08             	mov    0x8(%ebp),%edx
  8013c1:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8013c5:	83 c0 01             	add    $0x1,%eax
  8013c8:	89 03                	mov    %eax,(%ebx)
  8013ca:	3d ff 00 00 00       	cmp    $0xff,%eax
  8013cf:	75 19                	jne    8013ea <putch+0x38>
  8013d1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8013d8:	00 
  8013d9:	8d 43 08             	lea    0x8(%ebx),%eax
  8013dc:	89 04 24             	mov    %eax,(%esp)
  8013df:	e8 14 ed ff ff       	call   8000f8 <sys_cputs>
  8013e4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8013ea:	83 43 04 01          	addl   $0x1,0x4(%ebx)
  8013ee:	83 c4 14             	add    $0x14,%esp
  8013f1:	5b                   	pop    %ebx
  8013f2:	5d                   	pop    %ebp
  8013f3:	c3                   	ret    
	...

00801400 <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
  801403:	57                   	push   %edi
  801404:	56                   	push   %esi
  801405:	53                   	push   %ebx
  801406:	83 ec 3c             	sub    $0x3c,%esp
  801409:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  80140c:	89 d7                	mov    %edx,%edi
  80140e:	8b 45 08             	mov    0x8(%ebp),%eax
  801411:	8b 55 0c             	mov    0xc(%ebp),%edx
  801414:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  801417:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  80141a:	8b 55 10             	mov    0x10(%ebp),%edx
  80141d:	8b 45 14             	mov    0x14(%ebp),%eax
  801420:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801423:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  801426:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  80142d:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  801430:	39 4d ec             	cmp    %ecx,0xffffffec(%ebp)
  801433:	72 11                	jb     801446 <printnum+0x46>
  801435:	8b 4d d8             	mov    0xffffffd8(%ebp),%ecx
  801438:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  80143b:	76 09                	jbe    801446 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80143d:	8d 58 ff             	lea    0xffffffff(%eax),%ebx
  801440:	85 db                	test   %ebx,%ebx
  801442:	7f 54                	jg     801498 <printnum+0x98>
  801444:	eb 61                	jmp    8014a7 <printnum+0xa7>
  801446:	89 74 24 10          	mov    %esi,0x10(%esp)
  80144a:	83 e8 01             	sub    $0x1,%eax
  80144d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801451:	89 54 24 08          	mov    %edx,0x8(%esp)
  801455:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  801459:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80145d:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  801460:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  801463:	89 44 24 08          	mov    %eax,0x8(%esp)
  801467:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80146b:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  80146e:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  801471:	89 14 24             	mov    %edx,(%esp)
  801474:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801478:	e8 73 0b 00 00       	call   801ff0 <__udivdi3>
  80147d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801481:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801485:	89 04 24             	mov    %eax,(%esp)
  801488:	89 54 24 04          	mov    %edx,0x4(%esp)
  80148c:	89 fa                	mov    %edi,%edx
  80148e:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  801491:	e8 6a ff ff ff       	call   801400 <printnum>
  801496:	eb 0f                	jmp    8014a7 <printnum+0xa7>
			putch(padc, putdat);
  801498:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80149c:	89 34 24             	mov    %esi,(%esp)
  80149f:	ff 55 e4             	call   *0xffffffe4(%ebp)
  8014a2:	83 eb 01             	sub    $0x1,%ebx
  8014a5:	75 f1                	jne    801498 <printnum+0x98>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8014a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014ab:	8b 74 24 04          	mov    0x4(%esp),%esi
  8014af:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8014b2:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  8014b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014b9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8014bd:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  8014c0:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  8014c3:	89 14 24             	mov    %edx,(%esp)
  8014c6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014ca:	e8 51 0c 00 00       	call   802120 <__umoddi3>
  8014cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014d3:	0f be 80 ff 23 80 00 	movsbl 0x8023ff(%eax),%eax
  8014da:	89 04 24             	mov    %eax,(%esp)
  8014dd:	ff 55 e4             	call   *0xffffffe4(%ebp)
}
  8014e0:	83 c4 3c             	add    $0x3c,%esp
  8014e3:	5b                   	pop    %ebx
  8014e4:	5e                   	pop    %esi
  8014e5:	5f                   	pop    %edi
  8014e6:	5d                   	pop    %ebp
  8014e7:	c3                   	ret    

008014e8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
  8014eb:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8014ed:	83 fa 01             	cmp    $0x1,%edx
  8014f0:	7e 0e                	jle    801500 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8014f2:	8b 10                	mov    (%eax),%edx
  8014f4:	8d 42 08             	lea    0x8(%edx),%eax
  8014f7:	89 01                	mov    %eax,(%ecx)
  8014f9:	8b 02                	mov    (%edx),%eax
  8014fb:	8b 52 04             	mov    0x4(%edx),%edx
  8014fe:	eb 22                	jmp    801522 <getuint+0x3a>
	else if (lflag)
  801500:	85 d2                	test   %edx,%edx
  801502:	74 10                	je     801514 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  801504:	8b 10                	mov    (%eax),%edx
  801506:	8d 42 04             	lea    0x4(%edx),%eax
  801509:	89 01                	mov    %eax,(%ecx)
  80150b:	8b 02                	mov    (%edx),%eax
  80150d:	ba 00 00 00 00       	mov    $0x0,%edx
  801512:	eb 0e                	jmp    801522 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  801514:	8b 10                	mov    (%eax),%edx
  801516:	8d 42 04             	lea    0x4(%edx),%eax
  801519:	89 01                	mov    %eax,(%ecx)
  80151b:	8b 02                	mov    (%edx),%eax
  80151d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801522:	5d                   	pop    %ebp
  801523:	c3                   	ret    

00801524 <sprintputch>:

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
  801524:	55                   	push   %ebp
  801525:	89 e5                	mov    %esp,%ebp
  801527:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  80152a:	83 41 08 01          	addl   $0x1,0x8(%ecx)
	if (b->buf < b->ebuf)
  80152e:	8b 11                	mov    (%ecx),%edx
  801530:	3b 51 04             	cmp    0x4(%ecx),%edx
  801533:	73 0a                	jae    80153f <sprintputch+0x1b>
		*b->buf++ = ch;
  801535:	8b 45 08             	mov    0x8(%ebp),%eax
  801538:	88 02                	mov    %al,(%edx)
  80153a:	8d 42 01             	lea    0x1(%edx),%eax
  80153d:	89 01                	mov    %eax,(%ecx)
}
  80153f:	5d                   	pop    %ebp
  801540:	c3                   	ret    

00801541 <vprintfmt>:
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	57                   	push   %edi
  801545:	56                   	push   %esi
  801546:	53                   	push   %ebx
  801547:	83 ec 4c             	sub    $0x4c,%esp
  80154a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80154d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801550:	eb 03                	jmp    801555 <vprintfmt+0x14>
  801552:	8b 5d e8             	mov    0xffffffe8(%ebp),%ebx
  801555:	0f b6 03             	movzbl (%ebx),%eax
  801558:	83 c3 01             	add    $0x1,%ebx
  80155b:	3c 25                	cmp    $0x25,%al
  80155d:	74 30                	je     80158f <vprintfmt+0x4e>
  80155f:	84 c0                	test   %al,%al
  801561:	0f 84 a8 03 00 00    	je     80190f <vprintfmt+0x3ce>
  801567:	0f b6 d0             	movzbl %al,%edx
  80156a:	eb 0a                	jmp    801576 <vprintfmt+0x35>
  80156c:	84 c0                	test   %al,%al
  80156e:	66 90                	xchg   %ax,%ax
  801570:	0f 84 99 03 00 00    	je     80190f <vprintfmt+0x3ce>
  801576:	8b 45 0c             	mov    0xc(%ebp),%eax
  801579:	89 44 24 04          	mov    %eax,0x4(%esp)
  80157d:	89 14 24             	mov    %edx,(%esp)
  801580:	ff d7                	call   *%edi
  801582:	0f b6 03             	movzbl (%ebx),%eax
  801585:	0f b6 d0             	movzbl %al,%edx
  801588:	83 c3 01             	add    $0x1,%ebx
  80158b:	3c 25                	cmp    $0x25,%al
  80158d:	75 dd                	jne    80156c <vprintfmt+0x2b>
  80158f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801594:	c7 45 ec ff ff ff ff 	movl   $0xffffffff,0xffffffec(%ebp)
  80159b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  8015a2:	c7 45 dc 00 00 00 00 	movl   $0x0,0xffffffdc(%ebp)
  8015a9:	c6 45 e3 20          	movb   $0x20,0xffffffe3(%ebp)
  8015ad:	eb 07                	jmp    8015b6 <vprintfmt+0x75>
  8015af:	c7 45 dc 01 00 00 00 	movl   $0x1,0xffffffdc(%ebp)
  8015b6:	0f b6 03             	movzbl (%ebx),%eax
  8015b9:	0f b6 d0             	movzbl %al,%edx
  8015bc:	83 c3 01             	add    $0x1,%ebx
  8015bf:	83 e8 23             	sub    $0x23,%eax
  8015c2:	3c 55                	cmp    $0x55,%al
  8015c4:	0f 87 11 03 00 00    	ja     8018db <vprintfmt+0x39a>
  8015ca:	0f b6 c0             	movzbl %al,%eax
  8015cd:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
  8015d4:	c6 45 e3 30          	movb   $0x30,0xffffffe3(%ebp)
  8015d8:	eb dc                	jmp    8015b6 <vprintfmt+0x75>
  8015da:	83 ea 30             	sub    $0x30,%edx
  8015dd:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  8015e0:	0f be 13             	movsbl (%ebx),%edx
  8015e3:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  8015e6:	83 f8 09             	cmp    $0x9,%eax
  8015e9:	76 08                	jbe    8015f3 <vprintfmt+0xb2>
  8015eb:	eb 42                	jmp    80162f <vprintfmt+0xee>
  8015ed:	c6 45 e3 2d          	movb   $0x2d,0xffffffe3(%ebp)
  8015f1:	eb c3                	jmp    8015b6 <vprintfmt+0x75>
  8015f3:	83 c3 01             	add    $0x1,%ebx
  8015f6:	8b 75 e4             	mov    0xffffffe4(%ebp),%esi
  8015f9:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8015fc:	8d 44 42 d0          	lea    0xffffffd0(%edx,%eax,2),%eax
  801600:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  801603:	0f be 13             	movsbl (%ebx),%edx
  801606:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  801609:	83 f8 09             	cmp    $0x9,%eax
  80160c:	77 21                	ja     80162f <vprintfmt+0xee>
  80160e:	eb e3                	jmp    8015f3 <vprintfmt+0xb2>
  801610:	8b 55 14             	mov    0x14(%ebp),%edx
  801613:	8d 42 04             	lea    0x4(%edx),%eax
  801616:	89 45 14             	mov    %eax,0x14(%ebp)
  801619:	8b 12                	mov    (%edx),%edx
  80161b:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  80161e:	eb 0f                	jmp    80162f <vprintfmt+0xee>
  801620:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  801624:	79 90                	jns    8015b6 <vprintfmt+0x75>
  801626:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  80162d:	eb 87                	jmp    8015b6 <vprintfmt+0x75>
  80162f:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  801633:	79 81                	jns    8015b6 <vprintfmt+0x75>
  801635:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
  801638:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  80163b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,0xffffffe4(%ebp)
  801642:	e9 6f ff ff ff       	jmp    8015b6 <vprintfmt+0x75>
  801647:	83 c1 01             	add    $0x1,%ecx
  80164a:	e9 67 ff ff ff       	jmp    8015b6 <vprintfmt+0x75>
  80164f:	8b 45 14             	mov    0x14(%ebp),%eax
  801652:	8d 50 04             	lea    0x4(%eax),%edx
  801655:	89 55 14             	mov    %edx,0x14(%ebp)
  801658:	8b 55 0c             	mov    0xc(%ebp),%edx
  80165b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80165f:	8b 00                	mov    (%eax),%eax
  801661:	89 04 24             	mov    %eax,(%esp)
  801664:	ff d7                	call   *%edi
  801666:	e9 ea fe ff ff       	jmp    801555 <vprintfmt+0x14>
  80166b:	8b 55 14             	mov    0x14(%ebp),%edx
  80166e:	8d 42 04             	lea    0x4(%edx),%eax
  801671:	89 45 14             	mov    %eax,0x14(%ebp)
  801674:	8b 02                	mov    (%edx),%eax
  801676:	89 c2                	mov    %eax,%edx
  801678:	c1 fa 1f             	sar    $0x1f,%edx
  80167b:	31 d0                	xor    %edx,%eax
  80167d:	29 d0                	sub    %edx,%eax
  80167f:	83 f8 0f             	cmp    $0xf,%eax
  801682:	7f 0b                	jg     80168f <vprintfmt+0x14e>
  801684:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  80168b:	85 d2                	test   %edx,%edx
  80168d:	75 20                	jne    8016af <vprintfmt+0x16e>
  80168f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801693:	c7 44 24 08 10 24 80 	movl   $0x802410,0x8(%esp)
  80169a:	00 
  80169b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80169e:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016a2:	89 3c 24             	mov    %edi,(%esp)
  8016a5:	e8 f0 02 00 00       	call   80199a <printfmt>
  8016aa:	e9 a6 fe ff ff       	jmp    801555 <vprintfmt+0x14>
  8016af:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8016b3:	c7 44 24 08 ba 23 80 	movl   $0x8023ba,0x8(%esp)
  8016ba:	00 
  8016bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c2:	89 3c 24             	mov    %edi,(%esp)
  8016c5:	e8 d0 02 00 00       	call   80199a <printfmt>
  8016ca:	e9 86 fe ff ff       	jmp    801555 <vprintfmt+0x14>
  8016cf:	8b 75 ec             	mov    0xffffffec(%ebp),%esi
  8016d2:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  8016d5:	89 5d e8             	mov    %ebx,0xffffffe8(%ebp)
  8016d8:	8b 55 14             	mov    0x14(%ebp),%edx
  8016db:	8d 42 04             	lea    0x4(%edx),%eax
  8016de:	89 45 14             	mov    %eax,0x14(%ebp)
  8016e1:	8b 12                	mov    (%edx),%edx
  8016e3:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  8016e6:	85 d2                	test   %edx,%edx
  8016e8:	75 07                	jne    8016f1 <vprintfmt+0x1b0>
  8016ea:	c7 45 d8 19 24 80 00 	movl   $0x802419,0xffffffd8(%ebp)
  8016f1:	85 f6                	test   %esi,%esi
  8016f3:	7e 40                	jle    801735 <vprintfmt+0x1f4>
  8016f5:	80 7d e3 2d          	cmpb   $0x2d,0xffffffe3(%ebp)
  8016f9:	74 3a                	je     801735 <vprintfmt+0x1f4>
  8016fb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016ff:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  801702:	89 14 24             	mov    %edx,(%esp)
  801705:	e8 e6 02 00 00       	call   8019f0 <strnlen>
  80170a:	29 c6                	sub    %eax,%esi
  80170c:	89 75 ec             	mov    %esi,0xffffffec(%ebp)
  80170f:	85 f6                	test   %esi,%esi
  801711:	7e 22                	jle    801735 <vprintfmt+0x1f4>
  801713:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  801717:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  80171a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80171d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801721:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  801724:	89 04 24             	mov    %eax,(%esp)
  801727:	ff d7                	call   *%edi
  801729:	83 ee 01             	sub    $0x1,%esi
  80172c:	75 ec                	jne    80171a <vprintfmt+0x1d9>
  80172e:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
  801735:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  801738:	0f b6 02             	movzbl (%edx),%eax
  80173b:	0f be d0             	movsbl %al,%edx
  80173e:	8b 75 d8             	mov    0xffffffd8(%ebp),%esi
  801741:	84 c0                	test   %al,%al
  801743:	75 40                	jne    801785 <vprintfmt+0x244>
  801745:	eb 4a                	jmp    801791 <vprintfmt+0x250>
  801747:	83 7d dc 00          	cmpl   $0x0,0xffffffdc(%ebp)
  80174b:	74 1a                	je     801767 <vprintfmt+0x226>
  80174d:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  801750:	83 f8 5e             	cmp    $0x5e,%eax
  801753:	76 12                	jbe    801767 <vprintfmt+0x226>
  801755:	8b 45 0c             	mov    0xc(%ebp),%eax
  801758:	89 44 24 04          	mov    %eax,0x4(%esp)
  80175c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801763:	ff d7                	call   *%edi
  801765:	eb 0c                	jmp    801773 <vprintfmt+0x232>
  801767:	8b 45 0c             	mov    0xc(%ebp),%eax
  80176a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80176e:	89 14 24             	mov    %edx,(%esp)
  801771:	ff d7                	call   *%edi
  801773:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  801777:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80177b:	83 c6 01             	add    $0x1,%esi
  80177e:	84 c0                	test   %al,%al
  801780:	74 0f                	je     801791 <vprintfmt+0x250>
  801782:	0f be d0             	movsbl %al,%edx
  801785:	83 7d e4 00          	cmpl   $0x0,0xffffffe4(%ebp)
  801789:	78 bc                	js     801747 <vprintfmt+0x206>
  80178b:	83 6d e4 01          	subl   $0x1,0xffffffe4(%ebp)
  80178f:	79 b6                	jns    801747 <vprintfmt+0x206>
  801791:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  801795:	0f 8e ba fd ff ff    	jle    801555 <vprintfmt+0x14>
  80179b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80179e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017a2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8017a9:	ff d7                	call   *%edi
  8017ab:	83 6d ec 01          	subl   $0x1,0xffffffec(%ebp)
  8017af:	0f 84 9d fd ff ff    	je     801552 <vprintfmt+0x11>
  8017b5:	eb e4                	jmp    80179b <vprintfmt+0x25a>
  8017b7:	83 f9 01             	cmp    $0x1,%ecx
  8017ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8017c0:	7e 10                	jle    8017d2 <vprintfmt+0x291>
  8017c2:	8b 55 14             	mov    0x14(%ebp),%edx
  8017c5:	8d 42 08             	lea    0x8(%edx),%eax
  8017c8:	89 45 14             	mov    %eax,0x14(%ebp)
  8017cb:	8b 02                	mov    (%edx),%eax
  8017cd:	8b 52 04             	mov    0x4(%edx),%edx
  8017d0:	eb 26                	jmp    8017f8 <vprintfmt+0x2b7>
  8017d2:	85 c9                	test   %ecx,%ecx
  8017d4:	74 12                	je     8017e8 <vprintfmt+0x2a7>
  8017d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8017d9:	8d 50 04             	lea    0x4(%eax),%edx
  8017dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8017df:	8b 00                	mov    (%eax),%eax
  8017e1:	89 c2                	mov    %eax,%edx
  8017e3:	c1 fa 1f             	sar    $0x1f,%edx
  8017e6:	eb 10                	jmp    8017f8 <vprintfmt+0x2b7>
  8017e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8017eb:	8d 50 04             	lea    0x4(%eax),%edx
  8017ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8017f1:	8b 00                	mov    (%eax),%eax
  8017f3:	89 c2                	mov    %eax,%edx
  8017f5:	c1 fa 1f             	sar    $0x1f,%edx
  8017f8:	89 d1                	mov    %edx,%ecx
  8017fa:	89 c2                	mov    %eax,%edx
  8017fc:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  8017ff:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  801802:	be 0a 00 00 00       	mov    $0xa,%esi
  801807:	85 c9                	test   %ecx,%ecx
  801809:	0f 89 92 00 00 00    	jns    8018a1 <vprintfmt+0x360>
  80180f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801812:	89 74 24 04          	mov    %esi,0x4(%esp)
  801816:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80181d:	ff d7                	call   *%edi
  80181f:	8b 55 d0             	mov    0xffffffd0(%ebp),%edx
  801822:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
  801825:	f7 da                	neg    %edx
  801827:	83 d1 00             	adc    $0x0,%ecx
  80182a:	f7 d9                	neg    %ecx
  80182c:	be 0a 00 00 00       	mov    $0xa,%esi
  801831:	eb 6e                	jmp    8018a1 <vprintfmt+0x360>
  801833:	8d 45 14             	lea    0x14(%ebp),%eax
  801836:	89 ca                	mov    %ecx,%edx
  801838:	e8 ab fc ff ff       	call   8014e8 <getuint>
  80183d:	89 d1                	mov    %edx,%ecx
  80183f:	89 c2                	mov    %eax,%edx
  801841:	be 0a 00 00 00       	mov    $0xa,%esi
  801846:	eb 59                	jmp    8018a1 <vprintfmt+0x360>
  801848:	8d 45 14             	lea    0x14(%ebp),%eax
  80184b:	89 ca                	mov    %ecx,%edx
  80184d:	e8 96 fc ff ff       	call   8014e8 <getuint>
  801852:	e9 fe fc ff ff       	jmp    801555 <vprintfmt+0x14>
  801857:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80185e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801865:	ff d7                	call   *%edi
  801867:	8b 55 0c             	mov    0xc(%ebp),%edx
  80186a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80186e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801875:	ff d7                	call   *%edi
  801877:	8b 55 14             	mov    0x14(%ebp),%edx
  80187a:	8d 42 04             	lea    0x4(%edx),%eax
  80187d:	89 45 14             	mov    %eax,0x14(%ebp)
  801880:	8b 12                	mov    (%edx),%edx
  801882:	b9 00 00 00 00       	mov    $0x0,%ecx
  801887:	be 10 00 00 00       	mov    $0x10,%esi
  80188c:	eb 13                	jmp    8018a1 <vprintfmt+0x360>
  80188e:	8d 45 14             	lea    0x14(%ebp),%eax
  801891:	89 ca                	mov    %ecx,%edx
  801893:	e8 50 fc ff ff       	call   8014e8 <getuint>
  801898:	89 d1                	mov    %edx,%ecx
  80189a:	89 c2                	mov    %eax,%edx
  80189c:	be 10 00 00 00       	mov    $0x10,%esi
  8018a1:	0f be 45 e3          	movsbl 0xffffffe3(%ebp),%eax
  8018a5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8018a9:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  8018ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018b0:	89 74 24 08          	mov    %esi,0x8(%esp)
  8018b4:	89 14 24             	mov    %edx,(%esp)
  8018b7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018be:	89 f8                	mov    %edi,%eax
  8018c0:	e8 3b fb ff ff       	call   801400 <printnum>
  8018c5:	e9 8b fc ff ff       	jmp    801555 <vprintfmt+0x14>
  8018ca:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018d1:	89 14 24             	mov    %edx,(%esp)
  8018d4:	ff d7                	call   *%edi
  8018d6:	e9 7a fc ff ff       	jmp    801555 <vprintfmt+0x14>
  8018db:	89 de                	mov    %ebx,%esi
  8018dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8018eb:	ff d7                	call   *%edi
  8018ed:	83 eb 01             	sub    $0x1,%ebx
  8018f0:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  8018f4:	0f 84 5b fc ff ff    	je     801555 <vprintfmt+0x14>
  8018fa:	8d 56 fd             	lea    0xfffffffd(%esi),%edx
  8018fd:	0f b6 02             	movzbl (%edx),%eax
  801900:	83 ea 01             	sub    $0x1,%edx
  801903:	3c 25                	cmp    $0x25,%al
  801905:	75 f6                	jne    8018fd <vprintfmt+0x3bc>
  801907:	8d 5a 02             	lea    0x2(%edx),%ebx
  80190a:	e9 46 fc ff ff       	jmp    801555 <vprintfmt+0x14>
  80190f:	83 c4 4c             	add    $0x4c,%esp
  801912:	5b                   	pop    %ebx
  801913:	5e                   	pop    %esi
  801914:	5f                   	pop    %edi
  801915:	5d                   	pop    %ebp
  801916:	c3                   	ret    

00801917 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801917:	55                   	push   %ebp
  801918:	89 e5                	mov    %esp,%ebp
  80191a:	83 ec 28             	sub    $0x28,%esp
  80191d:	8b 55 08             	mov    0x8(%ebp),%edx
  801920:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  801923:	85 d2                	test   %edx,%edx
  801925:	74 04                	je     80192b <vsnprintf+0x14>
  801927:	85 c0                	test   %eax,%eax
  801929:	7f 07                	jg     801932 <vsnprintf+0x1b>
  80192b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801930:	eb 3b                	jmp    80196d <vsnprintf+0x56>
  801932:	c7 45 fc 00 00 00 00 	movl   $0x0,0xfffffffc(%ebp)
  801939:	8d 44 02 ff          	lea    0xffffffff(%edx,%eax,1),%eax
  80193d:	89 45 f8             	mov    %eax,0xfffffff8(%ebp)
  801940:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801943:	8b 45 14             	mov    0x14(%ebp),%eax
  801946:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80194a:	8b 45 10             	mov    0x10(%ebp),%eax
  80194d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801951:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  801954:	89 44 24 04          	mov    %eax,0x4(%esp)
  801958:	c7 04 24 24 15 80 00 	movl   $0x801524,(%esp)
  80195f:	e8 dd fb ff ff       	call   801541 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801964:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  801967:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80196a:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
}
  80196d:	c9                   	leave  
  80196e:	c3                   	ret    

0080196f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80196f:	55                   	push   %ebp
  801970:	89 e5                	mov    %esp,%ebp
  801972:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801975:	8d 45 14             	lea    0x14(%ebp),%eax
  801978:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  80197b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80197f:	8b 45 10             	mov    0x10(%ebp),%eax
  801982:	89 44 24 08          	mov    %eax,0x8(%esp)
  801986:	8b 45 0c             	mov    0xc(%ebp),%eax
  801989:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198d:	8b 45 08             	mov    0x8(%ebp),%eax
  801990:	89 04 24             	mov    %eax,(%esp)
  801993:	e8 7f ff ff ff       	call   801917 <vsnprintf>
	va_end(ap);

	return rc;
}
  801998:	c9                   	leave  
  801999:	c3                   	ret    

0080199a <printfmt>:
  80199a:	55                   	push   %ebp
  80199b:	89 e5                	mov    %esp,%ebp
  80199d:	83 ec 28             	sub    $0x28,%esp
  8019a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8019a3:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
  8019a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8019ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bb:	89 04 24             	mov    %eax,(%esp)
  8019be:	e8 7e fb ff ff       	call   801541 <vprintfmt>
  8019c3:	c9                   	leave  
  8019c4:	c3                   	ret    
	...

008019d0 <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8019d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8019db:	80 3a 00             	cmpb   $0x0,(%edx)
  8019de:	74 0e                	je     8019ee <strlen+0x1e>
  8019e0:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8019e5:	83 c0 01             	add    $0x1,%eax
  8019e8:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  8019ec:	75 f7                	jne    8019e5 <strlen+0x15>
	return n;
}
  8019ee:	5d                   	pop    %ebp
  8019ef:	c3                   	ret    

008019f0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8019f0:	55                   	push   %ebp
  8019f1:	89 e5                	mov    %esp,%ebp
  8019f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019f9:	85 d2                	test   %edx,%edx
  8019fb:	74 19                	je     801a16 <strnlen+0x26>
  8019fd:	80 39 00             	cmpb   $0x0,(%ecx)
  801a00:	74 14                	je     801a16 <strnlen+0x26>
  801a02:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801a07:	83 c0 01             	add    $0x1,%eax
  801a0a:	39 d0                	cmp    %edx,%eax
  801a0c:	74 0d                	je     801a1b <strnlen+0x2b>
  801a0e:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  801a12:	74 07                	je     801a1b <strnlen+0x2b>
  801a14:	eb f1                	jmp    801a07 <strnlen+0x17>
  801a16:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  801a1b:	5d                   	pop    %ebp
  801a1c:	8d 74 26 00          	lea    0x0(%esi),%esi
  801a20:	c3                   	ret    

00801a21 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801a21:	55                   	push   %ebp
  801a22:	89 e5                	mov    %esp,%ebp
  801a24:	53                   	push   %ebx
  801a25:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a2b:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801a2d:	0f b6 01             	movzbl (%ecx),%eax
  801a30:	88 02                	mov    %al,(%edx)
  801a32:	83 c2 01             	add    $0x1,%edx
  801a35:	83 c1 01             	add    $0x1,%ecx
  801a38:	84 c0                	test   %al,%al
  801a3a:	75 f1                	jne    801a2d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801a3c:	89 d8                	mov    %ebx,%eax
  801a3e:	5b                   	pop    %ebx
  801a3f:	5d                   	pop    %ebp
  801a40:	c3                   	ret    

00801a41 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	57                   	push   %edi
  801a45:	56                   	push   %esi
  801a46:	53                   	push   %ebx
  801a47:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a4d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a50:	85 f6                	test   %esi,%esi
  801a52:	74 1c                	je     801a70 <strncpy+0x2f>
  801a54:	89 fa                	mov    %edi,%edx
  801a56:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  801a5b:	0f b6 01             	movzbl (%ecx),%eax
  801a5e:	88 02                	mov    %al,(%edx)
  801a60:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801a63:	80 39 01             	cmpb   $0x1,(%ecx)
  801a66:	83 d9 ff             	sbb    $0xffffffff,%ecx
  801a69:	83 c3 01             	add    $0x1,%ebx
  801a6c:	39 f3                	cmp    %esi,%ebx
  801a6e:	75 eb                	jne    801a5b <strncpy+0x1a>
	}
	return ret;
}
  801a70:	89 f8                	mov    %edi,%eax
  801a72:	5b                   	pop    %ebx
  801a73:	5e                   	pop    %esi
  801a74:	5f                   	pop    %edi
  801a75:	5d                   	pop    %ebp
  801a76:	c3                   	ret    

00801a77 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801a77:	55                   	push   %ebp
  801a78:	89 e5                	mov    %esp,%ebp
  801a7a:	56                   	push   %esi
  801a7b:	53                   	push   %ebx
  801a7c:	8b 75 08             	mov    0x8(%ebp),%esi
  801a7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a82:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801a85:	89 f0                	mov    %esi,%eax
  801a87:	85 d2                	test   %edx,%edx
  801a89:	74 2c                	je     801ab7 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  801a8b:	89 d3                	mov    %edx,%ebx
  801a8d:	83 eb 01             	sub    $0x1,%ebx
  801a90:	74 20                	je     801ab2 <strlcpy+0x3b>
  801a92:	0f b6 11             	movzbl (%ecx),%edx
  801a95:	84 d2                	test   %dl,%dl
  801a97:	74 19                	je     801ab2 <strlcpy+0x3b>
  801a99:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  801a9b:	88 10                	mov    %dl,(%eax)
  801a9d:	83 c0 01             	add    $0x1,%eax
  801aa0:	83 eb 01             	sub    $0x1,%ebx
  801aa3:	74 0f                	je     801ab4 <strlcpy+0x3d>
  801aa5:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  801aa9:	83 c1 01             	add    $0x1,%ecx
  801aac:	84 d2                	test   %dl,%dl
  801aae:	74 04                	je     801ab4 <strlcpy+0x3d>
  801ab0:	eb e9                	jmp    801a9b <strlcpy+0x24>
  801ab2:	89 f0                	mov    %esi,%eax
		*dst = '\0';
  801ab4:	c6 00 00             	movb   $0x0,(%eax)
  801ab7:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  801ab9:	5b                   	pop    %ebx
  801aba:	5e                   	pop    %esi
  801abb:	5d                   	pop    %ebp
  801abc:	c3                   	ret    

00801abd <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  801abd:	55                   	push   %ebp
  801abe:	89 e5                	mov    %esp,%ebp
  801ac0:	57                   	push   %edi
  801ac1:	56                   	push   %esi
  801ac2:	53                   	push   %ebx
  801ac3:	8b 55 08             	mov    0x8(%ebp),%edx
  801ac6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ac9:	8b 7d 10             	mov    0x10(%ebp),%edi
    int c;
    char *q = buf;

    if (buf_size <= 0)
  801acc:	85 c9                	test   %ecx,%ecx
  801ace:	7e 30                	jle    801b00 <pstrcpy+0x43>
        return;

    for(;;) {
        c = *str++;
  801ad0:	0f b6 07             	movzbl (%edi),%eax
        if (c == 0 || q >= buf + buf_size - 1)
  801ad3:	84 c0                	test   %al,%al
  801ad5:	74 26                	je     801afd <pstrcpy+0x40>
  801ad7:	8d 74 0a ff          	lea    0xffffffff(%edx,%ecx,1),%esi
  801adb:	0f be d8             	movsbl %al,%ebx
  801ade:	89 f9                	mov    %edi,%ecx
  801ae0:	39 f2                	cmp    %esi,%edx
  801ae2:	72 09                	jb     801aed <pstrcpy+0x30>
  801ae4:	eb 17                	jmp    801afd <pstrcpy+0x40>
  801ae6:	83 c1 01             	add    $0x1,%ecx
  801ae9:	39 f2                	cmp    %esi,%edx
  801aeb:	73 10                	jae    801afd <pstrcpy+0x40>
            break;
        *q++ = c;
  801aed:	88 1a                	mov    %bl,(%edx)
  801aef:	83 c2 01             	add    $0x1,%edx
  801af2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  801af6:	0f be d8             	movsbl %al,%ebx
  801af9:	84 c0                	test   %al,%al
  801afb:	75 e9                	jne    801ae6 <pstrcpy+0x29>
    }
    *q = '\0';
  801afd:	c6 02 00             	movb   $0x0,(%edx)
}
  801b00:	5b                   	pop    %ebx
  801b01:	5e                   	pop    %esi
  801b02:	5f                   	pop    %edi
  801b03:	5d                   	pop    %ebp
  801b04:	c3                   	ret    

00801b05 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  801b05:	55                   	push   %ebp
  801b06:	89 e5                	mov    %esp,%ebp
  801b08:	8b 55 08             	mov    0x8(%ebp),%edx
  801b0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  801b0e:	0f b6 02             	movzbl (%edx),%eax
  801b11:	84 c0                	test   %al,%al
  801b13:	74 16                	je     801b2b <strcmp+0x26>
  801b15:	3a 01                	cmp    (%ecx),%al
  801b17:	75 12                	jne    801b2b <strcmp+0x26>
		p++, q++;
  801b19:	83 c1 01             	add    $0x1,%ecx
  801b1c:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  801b20:	84 c0                	test   %al,%al
  801b22:	74 07                	je     801b2b <strcmp+0x26>
  801b24:	83 c2 01             	add    $0x1,%edx
  801b27:	3a 01                	cmp    (%ecx),%al
  801b29:	74 ee                	je     801b19 <strcmp+0x14>
  801b2b:	0f b6 c0             	movzbl %al,%eax
  801b2e:	0f b6 11             	movzbl (%ecx),%edx
  801b31:	29 d0                	sub    %edx,%eax
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801b33:	5d                   	pop    %ebp
  801b34:	c3                   	ret    

00801b35 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	53                   	push   %ebx
  801b39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b3f:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801b42:	85 d2                	test   %edx,%edx
  801b44:	74 2d                	je     801b73 <strncmp+0x3e>
  801b46:	0f b6 01             	movzbl (%ecx),%eax
  801b49:	84 c0                	test   %al,%al
  801b4b:	74 1a                	je     801b67 <strncmp+0x32>
  801b4d:	3a 03                	cmp    (%ebx),%al
  801b4f:	75 16                	jne    801b67 <strncmp+0x32>
  801b51:	83 ea 01             	sub    $0x1,%edx
  801b54:	74 1d                	je     801b73 <strncmp+0x3e>
		n--, p++, q++;
  801b56:	83 c1 01             	add    $0x1,%ecx
  801b59:	83 c3 01             	add    $0x1,%ebx
  801b5c:	0f b6 01             	movzbl (%ecx),%eax
  801b5f:	84 c0                	test   %al,%al
  801b61:	74 04                	je     801b67 <strncmp+0x32>
  801b63:	3a 03                	cmp    (%ebx),%al
  801b65:	74 ea                	je     801b51 <strncmp+0x1c>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801b67:	0f b6 11             	movzbl (%ecx),%edx
  801b6a:	0f b6 03             	movzbl (%ebx),%eax
  801b6d:	29 c2                	sub    %eax,%edx
  801b6f:	89 d0                	mov    %edx,%eax
  801b71:	eb 05                	jmp    801b78 <strncmp+0x43>
  801b73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b78:	5b                   	pop    %ebx
  801b79:	5d                   	pop    %ebp
  801b7a:	c3                   	ret    

00801b7b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b81:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b85:	0f b6 10             	movzbl (%eax),%edx
  801b88:	84 d2                	test   %dl,%dl
  801b8a:	74 16                	je     801ba2 <strchr+0x27>
		if (*s == c)
  801b8c:	38 ca                	cmp    %cl,%dl
  801b8e:	75 06                	jne    801b96 <strchr+0x1b>
  801b90:	eb 15                	jmp    801ba7 <strchr+0x2c>
  801b92:	38 ca                	cmp    %cl,%dl
  801b94:	74 11                	je     801ba7 <strchr+0x2c>
  801b96:	83 c0 01             	add    $0x1,%eax
  801b99:	0f b6 10             	movzbl (%eax),%edx
  801b9c:	84 d2                	test   %dl,%dl
  801b9e:	66 90                	xchg   %ax,%ax
  801ba0:	75 f0                	jne    801b92 <strchr+0x17>
  801ba2:	b8 00 00 00 00       	mov    $0x0,%eax
			return (char *) s;
	return 0;
}
  801ba7:	5d                   	pop    %ebp
  801ba8:	c3                   	ret    

00801ba9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801ba9:	55                   	push   %ebp
  801baa:	89 e5                	mov    %esp,%ebp
  801bac:	8b 45 08             	mov    0x8(%ebp),%eax
  801baf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801bb3:	0f b6 10             	movzbl (%eax),%edx
  801bb6:	84 d2                	test   %dl,%dl
  801bb8:	74 14                	je     801bce <strfind+0x25>
		if (*s == c)
  801bba:	38 ca                	cmp    %cl,%dl
  801bbc:	75 06                	jne    801bc4 <strfind+0x1b>
  801bbe:	eb 0e                	jmp    801bce <strfind+0x25>
  801bc0:	38 ca                	cmp    %cl,%dl
  801bc2:	74 0a                	je     801bce <strfind+0x25>
  801bc4:	83 c0 01             	add    $0x1,%eax
  801bc7:	0f b6 10             	movzbl (%eax),%edx
  801bca:	84 d2                	test   %dl,%dl
  801bcc:	75 f2                	jne    801bc0 <strfind+0x17>
			break;
	return (char *) s;
}
  801bce:	5d                   	pop    %ebp
  801bcf:	90                   	nop    
  801bd0:	c3                   	ret    

00801bd1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801bd1:	55                   	push   %ebp
  801bd2:	89 e5                	mov    %esp,%ebp
  801bd4:	83 ec 08             	sub    $0x8,%esp
  801bd7:	89 1c 24             	mov    %ebx,(%esp)
  801bda:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801bde:	8b 7d 08             	mov    0x8(%ebp),%edi
  801be1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  801be7:	85 db                	test   %ebx,%ebx
  801be9:	74 32                	je     801c1d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801beb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801bf1:	75 25                	jne    801c18 <memset+0x47>
  801bf3:	f6 c3 03             	test   $0x3,%bl
  801bf6:	75 20                	jne    801c18 <memset+0x47>
		c &= 0xFF;
  801bf8:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801bfb:	89 d0                	mov    %edx,%eax
  801bfd:	c1 e0 18             	shl    $0x18,%eax
  801c00:	89 d1                	mov    %edx,%ecx
  801c02:	c1 e1 10             	shl    $0x10,%ecx
  801c05:	09 c8                	or     %ecx,%eax
  801c07:	09 d0                	or     %edx,%eax
  801c09:	c1 e2 08             	shl    $0x8,%edx
  801c0c:	09 d0                	or     %edx,%eax
  801c0e:	89 d9                	mov    %ebx,%ecx
  801c10:	c1 e9 02             	shr    $0x2,%ecx
  801c13:	fc                   	cld    
  801c14:	f3 ab                	rep stos %eax,%es:(%edi)
  801c16:	eb 05                	jmp    801c1d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801c18:	89 d9                	mov    %ebx,%ecx
  801c1a:	fc                   	cld    
  801c1b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801c1d:	89 f8                	mov    %edi,%eax
  801c1f:	8b 1c 24             	mov    (%esp),%ebx
  801c22:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801c26:	89 ec                	mov    %ebp,%esp
  801c28:	5d                   	pop    %ebp
  801c29:	c3                   	ret    

00801c2a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801c2a:	55                   	push   %ebp
  801c2b:	89 e5                	mov    %esp,%ebp
  801c2d:	83 ec 08             	sub    $0x8,%esp
  801c30:	89 34 24             	mov    %esi,(%esp)
  801c33:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c37:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  801c3d:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  801c40:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  801c42:	39 c6                	cmp    %eax,%esi
  801c44:	73 36                	jae    801c7c <memmove+0x52>
  801c46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801c49:	39 d0                	cmp    %edx,%eax
  801c4b:	73 2f                	jae    801c7c <memmove+0x52>
		s += n;
		d += n;
  801c4d:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801c50:	f6 c2 03             	test   $0x3,%dl
  801c53:	75 1b                	jne    801c70 <memmove+0x46>
  801c55:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801c5b:	75 13                	jne    801c70 <memmove+0x46>
  801c5d:	f6 c1 03             	test   $0x3,%cl
  801c60:	75 0e                	jne    801c70 <memmove+0x46>
			asm volatile("std; rep movsl\n"
  801c62:	8d 7e fc             	lea    0xfffffffc(%esi),%edi
  801c65:	8d 72 fc             	lea    0xfffffffc(%edx),%esi
  801c68:	c1 e9 02             	shr    $0x2,%ecx
  801c6b:	fd                   	std    
  801c6c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801c6e:	eb 09                	jmp    801c79 <memmove+0x4f>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801c70:	8d 7e ff             	lea    0xffffffff(%esi),%edi
  801c73:	8d 72 ff             	lea    0xffffffff(%edx),%esi
  801c76:	fd                   	std    
  801c77:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801c79:	fc                   	cld    
  801c7a:	eb 21                	jmp    801c9d <memmove+0x73>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801c7c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801c82:	75 16                	jne    801c9a <memmove+0x70>
  801c84:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801c8a:	75 0e                	jne    801c9a <memmove+0x70>
  801c8c:	f6 c1 03             	test   $0x3,%cl
  801c8f:	90                   	nop    
  801c90:	75 08                	jne    801c9a <memmove+0x70>
			asm volatile("cld; rep movsl\n"
  801c92:	c1 e9 02             	shr    $0x2,%ecx
  801c95:	fc                   	cld    
  801c96:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801c98:	eb 03                	jmp    801c9d <memmove+0x73>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801c9a:	fc                   	cld    
  801c9b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801c9d:	8b 34 24             	mov    (%esp),%esi
  801ca0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ca4:	89 ec                	mov    %ebp,%esp
  801ca6:	5d                   	pop    %ebp
  801ca7:	c3                   	ret    

00801ca8 <memcpy>:

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
  801ca8:	55                   	push   %ebp
  801ca9:	89 e5                	mov    %esp,%ebp
  801cab:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801cae:	8b 45 10             	mov    0x10(%ebp),%eax
  801cb1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cb5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbf:	89 04 24             	mov    %eax,(%esp)
  801cc2:	e8 63 ff ff ff       	call   801c2a <memmove>
}
  801cc7:	c9                   	leave  
  801cc8:	c3                   	ret    

00801cc9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801cc9:	55                   	push   %ebp
  801cca:	89 e5                	mov    %esp,%ebp
  801ccc:	56                   	push   %esi
  801ccd:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801cce:	8b 75 10             	mov    0x10(%ebp),%esi
  801cd1:	83 ee 01             	sub    $0x1,%esi
  801cd4:	83 fe ff             	cmp    $0xffffffff,%esi
  801cd7:	74 38                	je     801d11 <memcmp+0x48>
  801cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdc:	8b 55 0c             	mov    0xc(%ebp),%edx
		if (*s1 != *s2)
  801cdf:	0f b6 18             	movzbl (%eax),%ebx
  801ce2:	0f b6 0a             	movzbl (%edx),%ecx
  801ce5:	38 cb                	cmp    %cl,%bl
  801ce7:	74 20                	je     801d09 <memcmp+0x40>
  801ce9:	eb 12                	jmp    801cfd <memcmp+0x34>
  801ceb:	0f b6 58 01          	movzbl 0x1(%eax),%ebx
  801cef:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
  801cf3:	83 c0 01             	add    $0x1,%eax
  801cf6:	83 c2 01             	add    $0x1,%edx
  801cf9:	38 cb                	cmp    %cl,%bl
  801cfb:	74 0c                	je     801d09 <memcmp+0x40>
			return (int) *s1 - (int) *s2;
  801cfd:	0f b6 d3             	movzbl %bl,%edx
  801d00:	0f b6 c1             	movzbl %cl,%eax
  801d03:	29 c2                	sub    %eax,%edx
  801d05:	89 d0                	mov    %edx,%eax
  801d07:	eb 0d                	jmp    801d16 <memcmp+0x4d>
  801d09:	83 ee 01             	sub    $0x1,%esi
  801d0c:	83 fe ff             	cmp    $0xffffffff,%esi
  801d0f:	75 da                	jne    801ceb <memcmp+0x22>
  801d11:	b8 00 00 00 00       	mov    $0x0,%eax
		s1++, s2++;
	}

	return 0;
}
  801d16:	5b                   	pop    %ebx
  801d17:	5e                   	pop    %esi
  801d18:	5d                   	pop    %ebp
  801d19:	c3                   	ret    

00801d1a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d1a:	55                   	push   %ebp
  801d1b:	89 e5                	mov    %esp,%ebp
  801d1d:	53                   	push   %ebx
  801d1e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	const void *ends = (const char *) s + n;
  801d21:	89 da                	mov    %ebx,%edx
  801d23:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801d26:	39 d3                	cmp    %edx,%ebx
  801d28:	73 1a                	jae    801d44 <memfind+0x2a>
		if (*(const unsigned char *) s == (unsigned char) c)
  801d2a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
			break;
  801d2e:	89 d8                	mov    %ebx,%eax
  801d30:	38 0b                	cmp    %cl,(%ebx)
  801d32:	75 06                	jne    801d3a <memfind+0x20>
  801d34:	eb 0e                	jmp    801d44 <memfind+0x2a>
  801d36:	38 08                	cmp    %cl,(%eax)
  801d38:	74 0c                	je     801d46 <memfind+0x2c>
  801d3a:	83 c0 01             	add    $0x1,%eax
  801d3d:	39 d0                	cmp    %edx,%eax
  801d3f:	90                   	nop    
  801d40:	75 f4                	jne    801d36 <memfind+0x1c>
  801d42:	eb 02                	jmp    801d46 <memfind+0x2c>
  801d44:	89 d8                	mov    %ebx,%eax
	return (void *) s;
}
  801d46:	5b                   	pop    %ebx
  801d47:	5d                   	pop    %ebp
  801d48:	c3                   	ret    

00801d49 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801d49:	55                   	push   %ebp
  801d4a:	89 e5                	mov    %esp,%ebp
  801d4c:	57                   	push   %edi
  801d4d:	56                   	push   %esi
  801d4e:	53                   	push   %ebx
  801d4f:	83 ec 04             	sub    $0x4,%esp
  801d52:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801d55:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801d58:	0f b6 03             	movzbl (%ebx),%eax
  801d5b:	3c 20                	cmp    $0x20,%al
  801d5d:	74 04                	je     801d63 <strtol+0x1a>
  801d5f:	3c 09                	cmp    $0x9,%al
  801d61:	75 0e                	jne    801d71 <strtol+0x28>
		s++;
  801d63:	83 c3 01             	add    $0x1,%ebx
  801d66:	0f b6 03             	movzbl (%ebx),%eax
  801d69:	3c 20                	cmp    $0x20,%al
  801d6b:	74 f6                	je     801d63 <strtol+0x1a>
  801d6d:	3c 09                	cmp    $0x9,%al
  801d6f:	74 f2                	je     801d63 <strtol+0x1a>

	// plus/minus sign
	if (*s == '+')
  801d71:	3c 2b                	cmp    $0x2b,%al
  801d73:	75 0d                	jne    801d82 <strtol+0x39>
		s++;
  801d75:	83 c3 01             	add    $0x1,%ebx
  801d78:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  801d7f:	90                   	nop    
  801d80:	eb 15                	jmp    801d97 <strtol+0x4e>
	else if (*s == '-')
  801d82:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  801d89:	3c 2d                	cmp    $0x2d,%al
  801d8b:	75 0a                	jne    801d97 <strtol+0x4e>
		s++, neg = 1;
  801d8d:	83 c3 01             	add    $0x1,%ebx
  801d90:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801d97:	85 f6                	test   %esi,%esi
  801d99:	0f 94 c0             	sete   %al
  801d9c:	84 c0                	test   %al,%al
  801d9e:	75 05                	jne    801da5 <strtol+0x5c>
  801da0:	83 fe 10             	cmp    $0x10,%esi
  801da3:	75 17                	jne    801dbc <strtol+0x73>
  801da5:	80 3b 30             	cmpb   $0x30,(%ebx)
  801da8:	75 12                	jne    801dbc <strtol+0x73>
  801daa:	80 7b 01 78          	cmpb   $0x78,0x1(%ebx)
  801dae:	66 90                	xchg   %ax,%ax
  801db0:	75 0a                	jne    801dbc <strtol+0x73>
		s += 2, base = 16;
  801db2:	83 c3 02             	add    $0x2,%ebx
  801db5:	be 10 00 00 00       	mov    $0x10,%esi
  801dba:	eb 1f                	jmp    801ddb <strtol+0x92>
	else if (base == 0 && s[0] == '0')
  801dbc:	85 f6                	test   %esi,%esi
  801dbe:	66 90                	xchg   %ax,%ax
  801dc0:	75 10                	jne    801dd2 <strtol+0x89>
  801dc2:	80 3b 30             	cmpb   $0x30,(%ebx)
  801dc5:	75 0b                	jne    801dd2 <strtol+0x89>
		s++, base = 8;
  801dc7:	83 c3 01             	add    $0x1,%ebx
  801dca:	66 be 08 00          	mov    $0x8,%si
  801dce:	66 90                	xchg   %ax,%ax
  801dd0:	eb 09                	jmp    801ddb <strtol+0x92>
	else if (base == 0)
  801dd2:	84 c0                	test   %al,%al
  801dd4:	74 05                	je     801ddb <strtol+0x92>
  801dd6:	be 0a 00 00 00       	mov    $0xa,%esi
  801ddb:	bf 00 00 00 00       	mov    $0x0,%edi
		base = 10;

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801de0:	0f b6 13             	movzbl (%ebx),%edx
  801de3:	89 d1                	mov    %edx,%ecx
  801de5:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  801de8:	3c 09                	cmp    $0x9,%al
  801dea:	77 08                	ja     801df4 <strtol+0xab>
			dig = *s - '0';
  801dec:	0f be c2             	movsbl %dl,%eax
  801def:	8d 50 d0             	lea    0xffffffd0(%eax),%edx
  801df2:	eb 1c                	jmp    801e10 <strtol+0xc7>
		else if (*s >= 'a' && *s <= 'z')
  801df4:	8d 41 9f             	lea    0xffffff9f(%ecx),%eax
  801df7:	3c 19                	cmp    $0x19,%al
  801df9:	77 08                	ja     801e03 <strtol+0xba>
			dig = *s - 'a' + 10;
  801dfb:	0f be c2             	movsbl %dl,%eax
  801dfe:	8d 50 a9             	lea    0xffffffa9(%eax),%edx
  801e01:	eb 0d                	jmp    801e10 <strtol+0xc7>
		else if (*s >= 'A' && *s <= 'Z')
  801e03:	8d 41 bf             	lea    0xffffffbf(%ecx),%eax
  801e06:	3c 19                	cmp    $0x19,%al
  801e08:	77 17                	ja     801e21 <strtol+0xd8>
			dig = *s - 'A' + 10;
  801e0a:	0f be c2             	movsbl %dl,%eax
  801e0d:	8d 50 c9             	lea    0xffffffc9(%eax),%edx
		else
			break;
		if (dig >= base)
  801e10:	39 f2                	cmp    %esi,%edx
  801e12:	7d 0d                	jge    801e21 <strtol+0xd8>
			break;
		s++, val = (val * base) + dig;
  801e14:	83 c3 01             	add    $0x1,%ebx
  801e17:	89 f8                	mov    %edi,%eax
  801e19:	0f af c6             	imul   %esi,%eax
  801e1c:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  801e1f:	eb bf                	jmp    801de0 <strtol+0x97>
		// we don't properly detect overflow!
	}
  801e21:	89 f8                	mov    %edi,%eax

	if (endptr)
  801e23:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e27:	74 05                	je     801e2e <strtol+0xe5>
		*endptr = (char *) s;
  801e29:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e2c:	89 1a                	mov    %ebx,(%edx)
	return (neg ? -val : val);
  801e2e:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  801e32:	74 04                	je     801e38 <strtol+0xef>
  801e34:	89 c7                	mov    %eax,%edi
  801e36:	f7 df                	neg    %edi
}
  801e38:	89 f8                	mov    %edi,%eax
  801e3a:	83 c4 04             	add    $0x4,%esp
  801e3d:	5b                   	pop    %ebx
  801e3e:	5e                   	pop    %esi
  801e3f:	5f                   	pop    %edi
  801e40:	5d                   	pop    %ebp
  801e41:	c3                   	ret    
	...

00801e50 <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e50:	55                   	push   %ebp
  801e51:	89 e5                	mov    %esp,%ebp
  801e53:	57                   	push   %edi
  801e54:	56                   	push   %esi
  801e55:	53                   	push   %ebx
  801e56:	83 ec 1c             	sub    $0x1c,%esp
  801e59:	8b 75 08             	mov    0x8(%ebp),%esi
  801e5c:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  801e5f:	e8 f9 e5 ff ff       	call   80045d <sys_getenvid>
  801e64:	25 ff 03 00 00       	and    $0x3ff,%eax
  801e69:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e6c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e71:	a3 3c 60 80 00       	mov    %eax,0x80603c
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  801e76:	e8 e2 e5 ff ff       	call   80045d <sys_getenvid>
  801e7b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801e80:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e83:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e88:	a3 3c 60 80 00       	mov    %eax,0x80603c
		if(env->env_id==to_env){
  801e8d:	8b 40 4c             	mov    0x4c(%eax),%eax
  801e90:	39 f0                	cmp    %esi,%eax
  801e92:	75 0e                	jne    801ea2 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  801e94:	c7 04 24 00 27 80 00 	movl   $0x802700,(%esp)
  801e9b:	e8 f5 f4 ff ff       	call   801395 <cprintf>
  801ea0:	eb 5a                	jmp    801efc <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  801ea2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ea6:	8b 45 10             	mov    0x10(%ebp),%eax
  801ea9:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ead:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb4:	89 34 24             	mov    %esi,(%esp)
  801eb7:	e8 00 e3 ff ff       	call   8001bc <sys_ipc_try_send>
  801ebc:	89 c3                	mov    %eax,%ebx
  801ebe:	85 c0                	test   %eax,%eax
  801ec0:	79 25                	jns    801ee7 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  801ec2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ec5:	74 2b                	je     801ef2 <ipc_send+0xa2>
				panic("send error:%e",r);
  801ec7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ecb:	c7 44 24 08 1c 27 80 	movl   $0x80271c,0x8(%esp)
  801ed2:	00 
  801ed3:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  801eda:	00 
  801edb:	c7 04 24 2a 27 80 00 	movl   $0x80272a,(%esp)
  801ee2:	e8 e1 f3 ff ff       	call   8012c8 <_panic>
		}
			sys_yield();
  801ee7:	e8 3d e5 ff ff       	call   800429 <sys_yield>
		
	}while(r!=0);
  801eec:	85 db                	test   %ebx,%ebx
  801eee:	75 86                	jne    801e76 <ipc_send+0x26>
  801ef0:	eb 0a                	jmp    801efc <ipc_send+0xac>
  801ef2:	e8 32 e5 ff ff       	call   800429 <sys_yield>
  801ef7:	e9 7a ff ff ff       	jmp    801e76 <ipc_send+0x26>
	return;
	//panic("ipc_send not implemented");
}
  801efc:	83 c4 1c             	add    $0x1c,%esp
  801eff:	5b                   	pop    %ebx
  801f00:	5e                   	pop    %esi
  801f01:	5f                   	pop    %edi
  801f02:	5d                   	pop    %ebp
  801f03:	c3                   	ret    

00801f04 <ipc_recv>:
  801f04:	55                   	push   %ebp
  801f05:	89 e5                	mov    %esp,%ebp
  801f07:	57                   	push   %edi
  801f08:	56                   	push   %esi
  801f09:	53                   	push   %ebx
  801f0a:	83 ec 0c             	sub    $0xc,%esp
  801f0d:	8b 75 08             	mov    0x8(%ebp),%esi
  801f10:	8b 7d 10             	mov    0x10(%ebp),%edi
  801f13:	e8 45 e5 ff ff       	call   80045d <sys_getenvid>
  801f18:	25 ff 03 00 00       	and    $0x3ff,%eax
  801f1d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f20:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f25:	a3 3c 60 80 00       	mov    %eax,0x80603c
  801f2a:	85 f6                	test   %esi,%esi
  801f2c:	74 29                	je     801f57 <ipc_recv+0x53>
  801f2e:	8b 40 4c             	mov    0x4c(%eax),%eax
  801f31:	3b 06                	cmp    (%esi),%eax
  801f33:	75 22                	jne    801f57 <ipc_recv+0x53>
  801f35:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801f3b:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801f41:	c7 04 24 00 27 80 00 	movl   $0x802700,(%esp)
  801f48:	e8 48 f4 ff ff       	call   801395 <cprintf>
  801f4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f52:	e9 8a 00 00 00       	jmp    801fe1 <ipc_recv+0xdd>
  801f57:	e8 01 e5 ff ff       	call   80045d <sys_getenvid>
  801f5c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801f61:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f64:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f69:	a3 3c 60 80 00       	mov    %eax,0x80603c
  801f6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f71:	89 04 24             	mov    %eax,(%esp)
  801f74:	e8 e6 e1 ff ff       	call   80015f <sys_ipc_recv>
  801f79:	89 c3                	mov    %eax,%ebx
  801f7b:	85 c0                	test   %eax,%eax
  801f7d:	79 1a                	jns    801f99 <ipc_recv+0x95>
  801f7f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801f85:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801f8b:	c7 04 24 34 27 80 00 	movl   $0x802734,(%esp)
  801f92:	e8 fe f3 ff ff       	call   801395 <cprintf>
  801f97:	eb 48                	jmp    801fe1 <ipc_recv+0xdd>
  801f99:	e8 bf e4 ff ff       	call   80045d <sys_getenvid>
  801f9e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801fa3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fa6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fab:	a3 3c 60 80 00       	mov    %eax,0x80603c
  801fb0:	85 f6                	test   %esi,%esi
  801fb2:	74 05                	je     801fb9 <ipc_recv+0xb5>
  801fb4:	8b 40 74             	mov    0x74(%eax),%eax
  801fb7:	89 06                	mov    %eax,(%esi)
  801fb9:	85 ff                	test   %edi,%edi
  801fbb:	74 0a                	je     801fc7 <ipc_recv+0xc3>
  801fbd:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801fc2:	8b 40 78             	mov    0x78(%eax),%eax
  801fc5:	89 07                	mov    %eax,(%edi)
  801fc7:	e8 91 e4 ff ff       	call   80045d <sys_getenvid>
  801fcc:	25 ff 03 00 00       	and    $0x3ff,%eax
  801fd1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fd4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fd9:	a3 3c 60 80 00       	mov    %eax,0x80603c
  801fde:	8b 58 70             	mov    0x70(%eax),%ebx
  801fe1:	89 d8                	mov    %ebx,%eax
  801fe3:	83 c4 0c             	add    $0xc,%esp
  801fe6:	5b                   	pop    %ebx
  801fe7:	5e                   	pop    %esi
  801fe8:	5f                   	pop    %edi
  801fe9:	5d                   	pop    %ebp
  801fea:	c3                   	ret    
  801feb:	00 00                	add    %al,(%eax)
  801fed:	00 00                	add    %al,(%eax)
	...

00801ff0 <__udivdi3>:
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	57                   	push   %edi
  801ff4:	56                   	push   %esi
  801ff5:	83 ec 1c             	sub    $0x1c,%esp
  801ff8:	8b 45 10             	mov    0x10(%ebp),%eax
  801ffb:	8b 55 14             	mov    0x14(%ebp),%edx
  801ffe:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802001:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  802004:	89 c1                	mov    %eax,%ecx
  802006:	8b 45 08             	mov    0x8(%ebp),%eax
  802009:	85 d2                	test   %edx,%edx
  80200b:	89 d6                	mov    %edx,%esi
  80200d:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
  802010:	75 1e                	jne    802030 <__udivdi3+0x40>
  802012:	39 f9                	cmp    %edi,%ecx
  802014:	0f 86 8d 00 00 00    	jbe    8020a7 <__udivdi3+0xb7>
  80201a:	89 fa                	mov    %edi,%edx
  80201c:	f7 f1                	div    %ecx
  80201e:	89 c1                	mov    %eax,%ecx
  802020:	89 c8                	mov    %ecx,%eax
  802022:	89 f2                	mov    %esi,%edx
  802024:	83 c4 1c             	add    $0x1c,%esp
  802027:	5e                   	pop    %esi
  802028:	5f                   	pop    %edi
  802029:	5d                   	pop    %ebp
  80202a:	c3                   	ret    
  80202b:	90                   	nop    
  80202c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802030:	39 fa                	cmp    %edi,%edx
  802032:	0f 87 98 00 00 00    	ja     8020d0 <__udivdi3+0xe0>
  802038:	0f bd c2             	bsr    %edx,%eax
  80203b:	83 f0 1f             	xor    $0x1f,%eax
  80203e:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  802041:	74 7f                	je     8020c2 <__udivdi3+0xd2>
  802043:	b8 20 00 00 00       	mov    $0x20,%eax
  802048:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  80204b:	2b 45 e4             	sub    0xffffffe4(%ebp),%eax
  80204e:	89 c1                	mov    %eax,%ecx
  802050:	d3 ea                	shr    %cl,%edx
  802052:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802056:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  802059:	89 f0                	mov    %esi,%eax
  80205b:	d3 e0                	shl    %cl,%eax
  80205d:	09 c2                	or     %eax,%edx
  80205f:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802062:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  802065:	89 fa                	mov    %edi,%edx
  802067:	d3 e0                	shl    %cl,%eax
  802069:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  80206d:	89 45 f4             	mov    %eax,0xfffffff4(%ebp)
  802070:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802073:	d3 e8                	shr    %cl,%eax
  802075:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802079:	d3 e2                	shl    %cl,%edx
  80207b:	0f b6 4d ec          	movzbl 0xffffffec(%ebp),%ecx
  80207f:	09 d0                	or     %edx,%eax
  802081:	d3 ef                	shr    %cl,%edi
  802083:	89 fa                	mov    %edi,%edx
  802085:	f7 75 e0             	divl   0xffffffe0(%ebp)
  802088:	89 d1                	mov    %edx,%ecx
  80208a:	89 c7                	mov    %eax,%edi
  80208c:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
  80208f:	f7 e7                	mul    %edi
  802091:	39 d1                	cmp    %edx,%ecx
  802093:	89 c6                	mov    %eax,%esi
  802095:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  802098:	72 6f                	jb     802109 <__udivdi3+0x119>
  80209a:	39 ca                	cmp    %ecx,%edx
  80209c:	74 5e                	je     8020fc <__udivdi3+0x10c>
  80209e:	89 f9                	mov    %edi,%ecx
  8020a0:	31 f6                	xor    %esi,%esi
  8020a2:	e9 79 ff ff ff       	jmp    802020 <__udivdi3+0x30>
  8020a7:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8020aa:	85 c0                	test   %eax,%eax
  8020ac:	74 32                	je     8020e0 <__udivdi3+0xf0>
  8020ae:	89 f2                	mov    %esi,%edx
  8020b0:	89 f8                	mov    %edi,%eax
  8020b2:	f7 f1                	div    %ecx
  8020b4:	89 c6                	mov    %eax,%esi
  8020b6:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8020b9:	f7 f1                	div    %ecx
  8020bb:	89 c1                	mov    %eax,%ecx
  8020bd:	e9 5e ff ff ff       	jmp    802020 <__udivdi3+0x30>
  8020c2:	39 d7                	cmp    %edx,%edi
  8020c4:	77 2a                	ja     8020f0 <__udivdi3+0x100>
  8020c6:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  8020c9:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
  8020cc:	73 22                	jae    8020f0 <__udivdi3+0x100>
  8020ce:	66 90                	xchg   %ax,%ax
  8020d0:	31 c9                	xor    %ecx,%ecx
  8020d2:	31 f6                	xor    %esi,%esi
  8020d4:	e9 47 ff ff ff       	jmp    802020 <__udivdi3+0x30>
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  8020e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8020e5:	31 d2                	xor    %edx,%edx
  8020e7:	f7 75 f0             	divl   0xfffffff0(%ebp)
  8020ea:	89 c1                	mov    %eax,%ecx
  8020ec:	eb c0                	jmp    8020ae <__udivdi3+0xbe>
  8020ee:	66 90                	xchg   %ax,%ax
  8020f0:	b9 01 00 00 00       	mov    $0x1,%ecx
  8020f5:	31 f6                	xor    %esi,%esi
  8020f7:	e9 24 ff ff ff       	jmp    802020 <__udivdi3+0x30>
  8020fc:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8020ff:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  802103:	d3 e0                	shl    %cl,%eax
  802105:	39 c6                	cmp    %eax,%esi
  802107:	76 95                	jbe    80209e <__udivdi3+0xae>
  802109:	8d 4f ff             	lea    0xffffffff(%edi),%ecx
  80210c:	31 f6                	xor    %esi,%esi
  80210e:	e9 0d ff ff ff       	jmp    802020 <__udivdi3+0x30>
	...

00802120 <__umoddi3>:
  802120:	55                   	push   %ebp
  802121:	89 e5                	mov    %esp,%ebp
  802123:	57                   	push   %edi
  802124:	56                   	push   %esi
  802125:	83 ec 30             	sub    $0x30,%esp
  802128:	8b 55 14             	mov    0x14(%ebp),%edx
  80212b:	8b 45 10             	mov    0x10(%ebp),%eax
  80212e:	8b 75 08             	mov    0x8(%ebp),%esi
  802131:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802134:	85 d2                	test   %edx,%edx
  802136:	c7 45 d0 00 00 00 00 	movl   $0x0,0xffffffd0(%ebp)
  80213d:	89 c1                	mov    %eax,%ecx
  80213f:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  802146:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  802149:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  80214c:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  80214f:	89 7d e0             	mov    %edi,0xffffffe0(%ebp)
  802152:	75 1c                	jne    802170 <__umoddi3+0x50>
  802154:	39 f8                	cmp    %edi,%eax
  802156:	89 fa                	mov    %edi,%edx
  802158:	0f 86 d4 00 00 00    	jbe    802232 <__umoddi3+0x112>
  80215e:	89 f0                	mov    %esi,%eax
  802160:	f7 f1                	div    %ecx
  802162:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802165:	c7 45 d4 00 00 00 00 	movl   $0x0,0xffffffd4(%ebp)
  80216c:	eb 12                	jmp    802180 <__umoddi3+0x60>
  80216e:	66 90                	xchg   %ax,%ax
  802170:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802173:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  802176:	76 18                	jbe    802190 <__umoddi3+0x70>
  802178:	89 75 d0             	mov    %esi,0xffffffd0(%ebp)
  80217b:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  80217e:	66 90                	xchg   %ax,%ax
  802180:	8b 45 d0             	mov    0xffffffd0(%ebp),%eax
  802183:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  802186:	83 c4 30             	add    $0x30,%esp
  802189:	5e                   	pop    %esi
  80218a:	5f                   	pop    %edi
  80218b:	5d                   	pop    %ebp
  80218c:	c3                   	ret    
  80218d:	8d 76 00             	lea    0x0(%esi),%esi
  802190:	0f bd 45 e8          	bsr    0xffffffe8(%ebp),%eax
  802194:	83 f0 1f             	xor    $0x1f,%eax
  802197:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  80219a:	0f 84 c0 00 00 00    	je     802260 <__umoddi3+0x140>
  8021a0:	b8 20 00 00 00       	mov    $0x20,%eax
  8021a5:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  8021a8:	2b 45 dc             	sub    0xffffffdc(%ebp),%eax
  8021ab:	8b 7d ec             	mov    0xffffffec(%ebp),%edi
  8021ae:	8b 75 f0             	mov    0xfffffff0(%ebp),%esi
  8021b1:	89 c1                	mov    %eax,%ecx
  8021b3:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8021b6:	d3 ea                	shr    %cl,%edx
  8021b8:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8021bb:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  8021bf:	d3 e0                	shl    %cl,%eax
  8021c1:	09 c2                	or     %eax,%edx
  8021c3:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8021c6:	d3 e7                	shl    %cl,%edi
  8021c8:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8021cc:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  8021cf:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  8021d2:	d3 e8                	shr    %cl,%eax
  8021d4:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  8021d8:	d3 e2                	shl    %cl,%edx
  8021da:	09 d0                	or     %edx,%eax
  8021dc:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  8021df:	d3 e6                	shl    %cl,%esi
  8021e1:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  8021e5:	d3 ea                	shr    %cl,%edx
  8021e7:	f7 75 f4             	divl   0xfffffff4(%ebp)
  8021ea:	89 55 cc             	mov    %edx,0xffffffcc(%ebp)
  8021ed:	f7 e7                	mul    %edi
  8021ef:	39 55 cc             	cmp    %edx,0xffffffcc(%ebp)
  8021f2:	0f 82 a5 00 00 00    	jb     80229d <__umoddi3+0x17d>
  8021f8:	3b 55 cc             	cmp    0xffffffcc(%ebp),%edx
  8021fb:	0f 84 94 00 00 00    	je     802295 <__umoddi3+0x175>
  802201:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
  802204:	29 c6                	sub    %eax,%esi
  802206:	19 d1                	sbb    %edx,%ecx
  802208:	89 4d cc             	mov    %ecx,0xffffffcc(%ebp)
  80220b:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  80220f:	89 f2                	mov    %esi,%edx
  802211:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  802214:	d3 ea                	shr    %cl,%edx
  802216:	0f b6 4d e4          	movzbl 0xffffffe4(%ebp),%ecx
  80221a:	d3 e0                	shl    %cl,%eax
  80221c:	0f b6 4d dc          	movzbl 0xffffffdc(%ebp),%ecx
  802220:	09 c2                	or     %eax,%edx
  802222:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  802225:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802228:	d3 e8                	shr    %cl,%eax
  80222a:	89 45 d4             	mov    %eax,0xffffffd4(%ebp)
  80222d:	e9 4e ff ff ff       	jmp    802180 <__umoddi3+0x60>
  802232:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  802235:	85 c0                	test   %eax,%eax
  802237:	74 17                	je     802250 <__umoddi3+0x130>
  802239:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  80223c:	8b 55 e8             	mov    0xffffffe8(%ebp),%edx
  80223f:	f7 f1                	div    %ecx
  802241:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802244:	f7 f1                	div    %ecx
  802246:	e9 17 ff ff ff       	jmp    802162 <__umoddi3+0x42>
  80224b:	90                   	nop    
  80224c:	8d 74 26 00          	lea    0x0(%esi),%esi
  802250:	b8 01 00 00 00       	mov    $0x1,%eax
  802255:	31 d2                	xor    %edx,%edx
  802257:	f7 75 ec             	divl   0xffffffec(%ebp)
  80225a:	89 c1                	mov    %eax,%ecx
  80225c:	eb db                	jmp    802239 <__umoddi3+0x119>
  80225e:	66 90                	xchg   %ax,%ax
  802260:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  802263:	39 45 e0             	cmp    %eax,0xffffffe0(%ebp)
  802266:	77 19                	ja     802281 <__umoddi3+0x161>
  802268:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  80226b:	39 55 f0             	cmp    %edx,0xfffffff0(%ebp)
  80226e:	73 11                	jae    802281 <__umoddi3+0x161>
  802270:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  802273:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802276:	89 55 d0             	mov    %edx,0xffffffd0(%ebp)
  802279:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  80227c:	e9 ff fe ff ff       	jmp    802180 <__umoddi3+0x60>
  802281:	8b 4d e0             	mov    0xffffffe0(%ebp),%ecx
  802284:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  802287:	2b 45 ec             	sub    0xffffffec(%ebp),%eax
  80228a:	1b 4d e8             	sbb    0xffffffe8(%ebp),%ecx
  80228d:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  802290:	89 4d e0             	mov    %ecx,0xffffffe0(%ebp)
  802293:	eb db                	jmp    802270 <__umoddi3+0x150>
  802295:	39 f0                	cmp    %esi,%eax
  802297:	0f 86 64 ff ff ff    	jbe    802201 <__umoddi3+0xe1>
  80229d:	29 f8                	sub    %edi,%eax
  80229f:	1b 55 f4             	sbb    0xfffffff4(%ebp),%edx
  8022a2:	e9 5a ff ff ff       	jmp    802201 <__umoddi3+0xe1>
