
obj/user/idle:     file format elf32-i386

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
  80002c:	e8 1b 00 00 00       	call   80004c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  80003a:	c7 05 00 60 80 00 60 	movl   $0x802260,0x806000
  800041:	22 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800044:	e8 e0 03 00 00       	call   800429 <sys_yield>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  800049:	cc                   	int3   
  80004a:	eb f8                	jmp    800044 <umain+0x10>

0080004c <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  80004c:	55                   	push   %ebp
  80004d:	89 e5                	mov    %esp,%ebp
  80004f:	83 ec 18             	sub    $0x18,%esp
  800052:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800055:	89 75 fc             	mov    %esi,-0x4(%ebp)
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

	// call user main routine
	umain(argc, argv);
  80008a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008e:	89 34 24             	mov    %esi,(%esp)
  800091:	e8 9e ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800096:	e8 0d 00 00 00       	call   8000a8 <exit>
}
  80009b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80009e:	8b 75 fc             	mov    -0x4(%ebp),%esi
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
  8000ae:	e8 2d 0a 00 00       	call   800ae0 <close_all>
	sys_env_destroy(0);
  8000b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ba:	e8 d2 03 00 00       	call   800491 <sys_env_destroy>
}
  8000bf:	c9                   	leave  
  8000c0:	c3                   	ret    
  8000c1:	00 00                	add    %al,(%eax)
	...

008000c4 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
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
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000da:	bf 00 00 00 00       	mov    $0x0,%edi
  8000df:	89 fa                	mov    %edi,%edx
  8000e1:	89 f9                	mov    %edi,%ecx
  8000e3:	89 fb                	mov    %edi,%ebx
  8000e5:	89 fe                	mov    %edi,%esi
  8000e7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e9:	8b 1c 24             	mov    (%esp),%ebx
  8000ec:	8b 74 24 04          	mov    0x4(%esp),%esi
  8000f0:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8000f4:	89 ec                	mov    %ebp,%esp
  8000f6:	5d                   	pop    %ebp
  8000f7:	c3                   	ret    

008000f8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	83 ec 0c             	sub    $0xc,%esp
  8000fe:	89 1c 24             	mov    %ebx,(%esp)
  800101:	89 74 24 04          	mov    %esi,0x4(%esp)
  800105:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800109:	8b 55 08             	mov    0x8(%ebp),%edx
  80010c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010f:	bf 00 00 00 00       	mov    $0x0,%edi
  800114:	89 f8                	mov    %edi,%eax
  800116:	89 fb                	mov    %edi,%ebx
  800118:	89 fe                	mov    %edi,%esi
  80011a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80011c:	8b 1c 24             	mov    (%esp),%ebx
  80011f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800123:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800127:	89 ec                	mov    %ebp,%esp
  800129:	5d                   	pop    %ebp
  80012a:	c3                   	ret    

0080012b <sys_time_msec>:
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
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800141:	bf 00 00 00 00       	mov    $0x0,%edi
  800146:	89 fa                	mov    %edi,%edx
  800148:	89 f9                	mov    %edi,%ecx
  80014a:	89 fb                	mov    %edi,%ebx
  80014c:	89 fe                	mov    %edi,%esi
  80014e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800150:	8b 1c 24             	mov    (%esp),%ebx
  800153:	8b 74 24 04          	mov    0x4(%esp),%esi
  800157:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80015b:	89 ec                	mov    %ebp,%esp
  80015d:	5d                   	pop    %ebp
  80015e:	c3                   	ret    

0080015f <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	83 ec 28             	sub    $0x28,%esp
  800165:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800168:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80016b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80016e:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800171:	b8 0d 00 00 00       	mov    $0xd,%eax
  800176:	bf 00 00 00 00       	mov    $0x0,%edi
  80017b:	89 f9                	mov    %edi,%ecx
  80017d:	89 fb                	mov    %edi,%ebx
  80017f:	89 fe                	mov    %edi,%esi
  800181:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	7e 28                	jle    8001af <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800187:	89 44 24 10          	mov    %eax,0x10(%esp)
  80018b:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800192:	00 
  800193:	c7 44 24 08 7c 22 80 	movl   $0x80227c,0x8(%esp)
  80019a:	00 
  80019b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001a2:	00 
  8001a3:	c7 04 24 99 22 80 00 	movl   $0x802299,(%esp)
  8001aa:	e8 ed 10 00 00       	call   80129c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8001af:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001b2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001b5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001b8:	89 ec                	mov    %ebp,%esp
  8001ba:	5d                   	pop    %ebp
  8001bb:	c3                   	ret    

008001bc <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
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
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d9:	b8 0c 00 00 00       	mov    $0xc,%eax
  8001de:	be 00 00 00 00       	mov    $0x0,%esi
  8001e3:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8001e5:	8b 1c 24             	mov    (%esp),%ebx
  8001e8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8001ec:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8001f0:	89 ec                	mov    %ebp,%esp
  8001f2:	5d                   	pop    %ebp
  8001f3:	c3                   	ret    

008001f4 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	83 ec 28             	sub    $0x28,%esp
  8001fa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001fd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800200:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800203:	8b 55 08             	mov    0x8(%ebp),%edx
  800206:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800209:	b8 0a 00 00 00       	mov    $0xa,%eax
  80020e:	bf 00 00 00 00       	mov    $0x0,%edi
  800213:	89 fb                	mov    %edi,%ebx
  800215:	89 fe                	mov    %edi,%esi
  800217:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800219:	85 c0                	test   %eax,%eax
  80021b:	7e 28                	jle    800245 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80021d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800221:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800228:	00 
  800229:	c7 44 24 08 7c 22 80 	movl   $0x80227c,0x8(%esp)
  800230:	00 
  800231:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800238:	00 
  800239:	c7 04 24 99 22 80 00 	movl   $0x802299,(%esp)
  800240:	e8 57 10 00 00       	call   80129c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800245:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800248:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80024b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80024e:	89 ec                	mov    %ebp,%esp
  800250:	5d                   	pop    %ebp
  800251:	c3                   	ret    

00800252 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
  800255:	83 ec 28             	sub    $0x28,%esp
  800258:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80025b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80025e:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800261:	8b 55 08             	mov    0x8(%ebp),%edx
  800264:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800267:	b8 09 00 00 00       	mov    $0x9,%eax
  80026c:	bf 00 00 00 00       	mov    $0x0,%edi
  800271:	89 fb                	mov    %edi,%ebx
  800273:	89 fe                	mov    %edi,%esi
  800275:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800277:	85 c0                	test   %eax,%eax
  800279:	7e 28                	jle    8002a3 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80027b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80027f:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800286:	00 
  800287:	c7 44 24 08 7c 22 80 	movl   $0x80227c,0x8(%esp)
  80028e:	00 
  80028f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800296:	00 
  800297:	c7 04 24 99 22 80 00 	movl   $0x802299,(%esp)
  80029e:	e8 f9 0f 00 00       	call   80129c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002a6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002a9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002ac:	89 ec                	mov    %ebp,%esp
  8002ae:	5d                   	pop    %ebp
  8002af:	c3                   	ret    

008002b0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	83 ec 28             	sub    $0x28,%esp
  8002b6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002b9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002bc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8002bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c5:	b8 08 00 00 00       	mov    $0x8,%eax
  8002ca:	bf 00 00 00 00       	mov    $0x0,%edi
  8002cf:	89 fb                	mov    %edi,%ebx
  8002d1:	89 fe                	mov    %edi,%esi
  8002d3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8002d5:	85 c0                	test   %eax,%eax
  8002d7:	7e 28                	jle    800301 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002dd:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002e4:	00 
  8002e5:	c7 44 24 08 7c 22 80 	movl   $0x80227c,0x8(%esp)
  8002ec:	00 
  8002ed:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002f4:	00 
  8002f5:	c7 04 24 99 22 80 00 	movl   $0x802299,(%esp)
  8002fc:	e8 9b 0f 00 00       	call   80129c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800301:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800304:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800307:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80030a:	89 ec                	mov    %ebp,%esp
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	83 ec 28             	sub    $0x28,%esp
  800314:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800317:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80031a:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80031d:	8b 55 08             	mov    0x8(%ebp),%edx
  800320:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800323:	b8 06 00 00 00       	mov    $0x6,%eax
  800328:	bf 00 00 00 00       	mov    $0x0,%edi
  80032d:	89 fb                	mov    %edi,%ebx
  80032f:	89 fe                	mov    %edi,%esi
  800331:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800333:	85 c0                	test   %eax,%eax
  800335:	7e 28                	jle    80035f <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800337:	89 44 24 10          	mov    %eax,0x10(%esp)
  80033b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800342:	00 
  800343:	c7 44 24 08 7c 22 80 	movl   $0x80227c,0x8(%esp)
  80034a:	00 
  80034b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800352:	00 
  800353:	c7 04 24 99 22 80 00 	movl   $0x802299,(%esp)
  80035a:	e8 3d 0f 00 00       	call   80129c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80035f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800362:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800365:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800368:	89 ec                	mov    %ebp,%esp
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    

0080036c <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	83 ec 28             	sub    $0x28,%esp
  800372:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800375:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800378:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80037b:	8b 55 08             	mov    0x8(%ebp),%edx
  80037e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800381:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800384:	8b 7d 14             	mov    0x14(%ebp),%edi
  800387:	8b 75 18             	mov    0x18(%ebp),%esi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80038a:	b8 05 00 00 00       	mov    $0x5,%eax
  80038f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800391:	85 c0                	test   %eax,%eax
  800393:	7e 28                	jle    8003bd <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800395:	89 44 24 10          	mov    %eax,0x10(%esp)
  800399:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8003a0:	00 
  8003a1:	c7 44 24 08 7c 22 80 	movl   $0x80227c,0x8(%esp)
  8003a8:	00 
  8003a9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003b0:	00 
  8003b1:	c7 04 24 99 22 80 00 	movl   $0x802299,(%esp)
  8003b8:	e8 df 0e 00 00       	call   80129c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8003bd:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003c0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003c3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003c6:	89 ec                	mov    %ebp,%esp
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	83 ec 28             	sub    $0x28,%esp
  8003d0:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003d3:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003d6:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8003d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003df:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003e2:	b8 04 00 00 00       	mov    $0x4,%eax
  8003e7:	bf 00 00 00 00       	mov    $0x0,%edi
  8003ec:	89 fe                	mov    %edi,%esi
  8003ee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8003f0:	85 c0                	test   %eax,%eax
  8003f2:	7e 28                	jle    80041c <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003f8:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8003ff:	00 
  800400:	c7 44 24 08 7c 22 80 	movl   $0x80227c,0x8(%esp)
  800407:	00 
  800408:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80040f:	00 
  800410:	c7 04 24 99 22 80 00 	movl   $0x802299,(%esp)
  800417:	e8 80 0e 00 00       	call   80129c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80041c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80041f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800422:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800425:	89 ec                	mov    %ebp,%esp
  800427:	5d                   	pop    %ebp
  800428:	c3                   	ret    

00800429 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800429:	55                   	push   %ebp
  80042a:	89 e5                	mov    %esp,%ebp
  80042c:	83 ec 0c             	sub    $0xc,%esp
  80042f:	89 1c 24             	mov    %ebx,(%esp)
  800432:	89 74 24 04          	mov    %esi,0x4(%esp)
  800436:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80043a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80043f:	bf 00 00 00 00       	mov    $0x0,%edi
  800444:	89 fa                	mov    %edi,%edx
  800446:	89 f9                	mov    %edi,%ecx
  800448:	89 fb                	mov    %edi,%ebx
  80044a:	89 fe                	mov    %edi,%esi
  80044c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80044e:	8b 1c 24             	mov    (%esp),%ebx
  800451:	8b 74 24 04          	mov    0x4(%esp),%esi
  800455:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800459:	89 ec                	mov    %ebp,%esp
  80045b:	5d                   	pop    %ebp
  80045c:	c3                   	ret    

0080045d <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  80045d:	55                   	push   %ebp
  80045e:	89 e5                	mov    %esp,%ebp
  800460:	83 ec 0c             	sub    $0xc,%esp
  800463:	89 1c 24             	mov    %ebx,(%esp)
  800466:	89 74 24 04          	mov    %esi,0x4(%esp)
  80046a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80046e:	b8 02 00 00 00       	mov    $0x2,%eax
  800473:	bf 00 00 00 00       	mov    $0x0,%edi
  800478:	89 fa                	mov    %edi,%edx
  80047a:	89 f9                	mov    %edi,%ecx
  80047c:	89 fb                	mov    %edi,%ebx
  80047e:	89 fe                	mov    %edi,%esi
  800480:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800482:	8b 1c 24             	mov    (%esp),%ebx
  800485:	8b 74 24 04          	mov    0x4(%esp),%esi
  800489:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80048d:	89 ec                	mov    %ebp,%esp
  80048f:	5d                   	pop    %ebp
  800490:	c3                   	ret    

00800491 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800491:	55                   	push   %ebp
  800492:	89 e5                	mov    %esp,%ebp
  800494:	83 ec 28             	sub    $0x28,%esp
  800497:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80049a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80049d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8004a0:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004a3:	b8 03 00 00 00       	mov    $0x3,%eax
  8004a8:	bf 00 00 00 00       	mov    $0x0,%edi
  8004ad:	89 f9                	mov    %edi,%ecx
  8004af:	89 fb                	mov    %edi,%ebx
  8004b1:	89 fe                	mov    %edi,%esi
  8004b3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8004b5:	85 c0                	test   %eax,%eax
  8004b7:	7e 28                	jle    8004e1 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004b9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004bd:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8004c4:	00 
  8004c5:	c7 44 24 08 7c 22 80 	movl   $0x80227c,0x8(%esp)
  8004cc:	00 
  8004cd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8004d4:	00 
  8004d5:	c7 04 24 99 22 80 00 	movl   $0x802299,(%esp)
  8004dc:	e8 bb 0d 00 00       	call   80129c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8004e1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8004e4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8004e7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8004ea:	89 ec                	mov    %ebp,%esp
  8004ec:	5d                   	pop    %ebp
  8004ed:	c3                   	ret    
	...

008004f0 <fd2num>:
// File descriptor manipulators
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
  80052e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800535:	a8 01                	test   $0x1,%al
  800537:	74 10                	je     800549 <fd_alloc+0x2e>
  800539:	89 d0                	mov    %edx,%eax
  80053b:	c1 e8 0c             	shr    $0xc,%eax
  80053e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800545:	a8 01                	test   $0x1,%al
  800547:	75 09                	jne    800552 <fd_alloc+0x37>
			*fd_store = fd;
  800549:	89 0b                	mov    %ecx,(%ebx)
  80054b:	b8 00 00 00 00       	mov    $0x0,%eax
  800550:	eb 19                	jmp    80056b <fd_alloc+0x50>
			return 0;
  800552:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800558:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  80055e:	75 c7                	jne    800527 <fd_alloc+0xc>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
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
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80056e:	55                   	push   %ebp
  80056f:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800571:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  800575:	77 38                	ja     8005af <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800577:	8b 45 08             	mov    0x8(%ebp),%eax
  80057a:	c1 e0 0c             	shl    $0xc,%eax
  80057d:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  800583:	89 d0                	mov    %edx,%eax
  800585:	c1 e8 16             	shr    $0x16,%eax
  800588:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80058f:	a8 01                	test   $0x1,%al
  800591:	74 1c                	je     8005af <fd_lookup+0x41>
  800593:	89 d0                	mov    %edx,%eax
  800595:	c1 e8 0c             	shr    $0xc,%eax
  800598:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80059f:	a8 01                	test   $0x1,%al
  8005a1:	74 0c                	je     8005af <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8005a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005a6:	89 10                	mov    %edx,(%eax)
  8005a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ad:	eb 05                	jmp    8005b4 <fd_lookup+0x46>
	return 0;
  8005af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8005b4:	5d                   	pop    %ebp
  8005b5:	c3                   	ret    

008005b6 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8005b6:	55                   	push   %ebp
  8005b7:	89 e5                	mov    %esp,%ebp
  8005b9:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005bc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8005bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c6:	89 04 24             	mov    %eax,(%esp)
  8005c9:	e8 a0 ff ff ff       	call   80056e <fd_lookup>
  8005ce:	85 c0                	test   %eax,%eax
  8005d0:	78 0e                	js     8005e0 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8005d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8005d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005d8:	89 50 04             	mov    %edx,0x4(%eax)
  8005db:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8005e0:	c9                   	leave  
  8005e1:	c3                   	ret    

008005e2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8005e2:	55                   	push   %ebp
  8005e3:	89 e5                	mov    %esp,%ebp
  8005e5:	53                   	push   %ebx
  8005e6:	83 ec 14             	sub    $0x14,%esp
  8005e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8005ef:	ba 04 60 80 00       	mov    $0x806004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8005f4:	b8 00 00 00 00       	mov    $0x0,%eax
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8005f9:	39 0d 04 60 80 00    	cmp    %ecx,0x806004
  8005ff:	75 11                	jne    800612 <dev_lookup+0x30>
  800601:	eb 04                	jmp    800607 <dev_lookup+0x25>
  800603:	39 0a                	cmp    %ecx,(%edx)
  800605:	75 0b                	jne    800612 <dev_lookup+0x30>
			*dev = devtab[i];
  800607:	89 13                	mov    %edx,(%ebx)
  800609:	b8 00 00 00 00       	mov    $0x0,%eax
  80060e:	66 90                	xchg   %ax,%ax
  800610:	eb 35                	jmp    800647 <dev_lookup+0x65>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800612:	83 c0 01             	add    $0x1,%eax
  800615:	8b 14 85 24 23 80 00 	mov    0x802324(,%eax,4),%edx
  80061c:	85 d2                	test   %edx,%edx
  80061e:	75 e3                	jne    800603 <dev_lookup+0x21>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  800620:	a1 3c 60 80 00       	mov    0x80603c,%eax
  800625:	8b 40 4c             	mov    0x4c(%eax),%eax
  800628:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80062c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800630:	c7 04 24 a8 22 80 00 	movl   $0x8022a8,(%esp)
  800637:	e8 2d 0d 00 00       	call   801369 <cprintf>
	*dev = 0;
  80063c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800642:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  800647:	83 c4 14             	add    $0x14,%esp
  80064a:	5b                   	pop    %ebx
  80064b:	5d                   	pop    %ebp
  80064c:	c3                   	ret    

0080064d <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80064d:	55                   	push   %ebp
  80064e:	89 e5                	mov    %esp,%ebp
  800650:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800653:	8d 45 f8             	lea    -0x8(%ebp),%eax
  800656:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065a:	8b 45 08             	mov    0x8(%ebp),%eax
  80065d:	89 04 24             	mov    %eax,(%esp)
  800660:	e8 09 ff ff ff       	call   80056e <fd_lookup>
  800665:	89 c2                	mov    %eax,%edx
  800667:	85 c0                	test   %eax,%eax
  800669:	78 5a                	js     8006c5 <fstat+0x78>
  80066b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80066e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800672:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800675:	8b 00                	mov    (%eax),%eax
  800677:	89 04 24             	mov    %eax,(%esp)
  80067a:	e8 63 ff ff ff       	call   8005e2 <dev_lookup>
  80067f:	89 c2                	mov    %eax,%edx
  800681:	85 c0                	test   %eax,%eax
  800683:	78 40                	js     8006c5 <fstat+0x78>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  800685:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  80068a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80068d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800691:	74 32                	je     8006c5 <fstat+0x78>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800693:	8b 45 0c             	mov    0xc(%ebp),%eax
  800696:	c6 00 00             	movb   $0x0,(%eax)
	stat->st_size = 0;
  800699:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  8006a0:	00 00 00 
	stat->st_isdir = 0;
  8006a3:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
  8006aa:	00 00 00 
	stat->st_dev = dev;
  8006ad:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8006b0:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
	return (*dev->dev_stat)(fd, stat);
  8006b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8006bd:	89 04 24             	mov    %eax,(%esp)
  8006c0:	ff 52 14             	call   *0x14(%edx)
  8006c3:	89 c2                	mov    %eax,%edx
}
  8006c5:	89 d0                	mov    %edx,%eax
  8006c7:	c9                   	leave  
  8006c8:	c3                   	ret    

008006c9 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8006c9:	55                   	push   %ebp
  8006ca:	89 e5                	mov    %esp,%ebp
  8006cc:	53                   	push   %ebx
  8006cd:	83 ec 24             	sub    $0x24,%esp
  8006d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006da:	89 1c 24             	mov    %ebx,(%esp)
  8006dd:	e8 8c fe ff ff       	call   80056e <fd_lookup>
  8006e2:	85 c0                	test   %eax,%eax
  8006e4:	78 61                	js     800747 <ftruncate+0x7e>
  8006e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e9:	8b 10                	mov    (%eax),%edx
  8006eb:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8006ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f2:	89 14 24             	mov    %edx,(%esp)
  8006f5:	e8 e8 fe ff ff       	call   8005e2 <dev_lookup>
  8006fa:	85 c0                	test   %eax,%eax
  8006fc:	78 49                	js     800747 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8006fe:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  800701:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  800705:	75 23                	jne    80072a <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800707:	a1 3c 60 80 00       	mov    0x80603c,%eax
  80070c:	8b 40 4c             	mov    0x4c(%eax),%eax
  80070f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800713:	89 44 24 04          	mov    %eax,0x4(%esp)
  800717:	c7 04 24 c8 22 80 00 	movl   $0x8022c8,(%esp)
  80071e:	e8 46 0c 00 00       	call   801369 <cprintf>
  800723:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800728:	eb 1d                	jmp    800747 <ftruncate+0x7e>
			env->env_id, fdnum); 
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80072a:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80072d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800732:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  800736:	74 0f                	je     800747 <ftruncate+0x7e>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800738:	8b 42 18             	mov    0x18(%edx),%eax
  80073b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80073e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800742:	89 0c 24             	mov    %ecx,(%esp)
  800745:	ff d0                	call   *%eax
}
  800747:	83 c4 24             	add    $0x24,%esp
  80074a:	5b                   	pop    %ebx
  80074b:	5d                   	pop    %ebp
  80074c:	c3                   	ret    

0080074d <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80074d:	55                   	push   %ebp
  80074e:	89 e5                	mov    %esp,%ebp
  800750:	53                   	push   %ebx
  800751:	83 ec 24             	sub    $0x24,%esp
  800754:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800757:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80075a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075e:	89 1c 24             	mov    %ebx,(%esp)
  800761:	e8 08 fe ff ff       	call   80056e <fd_lookup>
  800766:	85 c0                	test   %eax,%eax
  800768:	78 68                	js     8007d2 <write+0x85>
  80076a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076d:	8b 10                	mov    (%eax),%edx
  80076f:	8d 45 f8             	lea    -0x8(%ebp),%eax
  800772:	89 44 24 04          	mov    %eax,0x4(%esp)
  800776:	89 14 24             	mov    %edx,(%esp)
  800779:	e8 64 fe ff ff       	call   8005e2 <dev_lookup>
  80077e:	85 c0                	test   %eax,%eax
  800780:	78 50                	js     8007d2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800782:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  800785:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  800789:	75 23                	jne    8007ae <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  80078b:	a1 3c 60 80 00       	mov    0x80603c,%eax
  800790:	8b 40 4c             	mov    0x4c(%eax),%eax
  800793:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800797:	89 44 24 04          	mov    %eax,0x4(%esp)
  80079b:	c7 04 24 e9 22 80 00 	movl   $0x8022e9,(%esp)
  8007a2:	e8 c2 0b 00 00       	call   801369 <cprintf>
  8007a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ac:	eb 24                	jmp    8007d2 <write+0x85>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007ae:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8007b1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007b6:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  8007ba:	74 16                	je     8007d2 <write+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007bc:	8b 42 0c             	mov    0xc(%edx),%eax
  8007bf:	8b 55 10             	mov    0x10(%ebp),%edx
  8007c2:	89 54 24 08          	mov    %edx,0x8(%esp)
  8007c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007cd:	89 0c 24             	mov    %ecx,(%esp)
  8007d0:	ff d0                	call   *%eax
}
  8007d2:	83 c4 24             	add    $0x24,%esp
  8007d5:	5b                   	pop    %ebx
  8007d6:	5d                   	pop    %ebp
  8007d7:	c3                   	ret    

008007d8 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	53                   	push   %ebx
  8007dc:	83 ec 24             	sub    $0x24,%esp
  8007df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e9:	89 1c 24             	mov    %ebx,(%esp)
  8007ec:	e8 7d fd ff ff       	call   80056e <fd_lookup>
  8007f1:	85 c0                	test   %eax,%eax
  8007f3:	78 6d                	js     800862 <read+0x8a>
  8007f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f8:	8b 10                	mov    (%eax),%edx
  8007fa:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8007fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800801:	89 14 24             	mov    %edx,(%esp)
  800804:	e8 d9 fd ff ff       	call   8005e2 <dev_lookup>
  800809:	85 c0                	test   %eax,%eax
  80080b:	78 55                	js     800862 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80080d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  800810:	8b 41 08             	mov    0x8(%ecx),%eax
  800813:	83 e0 03             	and    $0x3,%eax
  800816:	83 f8 01             	cmp    $0x1,%eax
  800819:	75 23                	jne    80083e <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  80081b:	a1 3c 60 80 00       	mov    0x80603c,%eax
  800820:	8b 40 4c             	mov    0x4c(%eax),%eax
  800823:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800827:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082b:	c7 04 24 06 23 80 00 	movl   $0x802306,(%esp)
  800832:	e8 32 0b 00 00       	call   801369 <cprintf>
  800837:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80083c:	eb 24                	jmp    800862 <read+0x8a>
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80083e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  800841:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800846:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  80084a:	74 16                	je     800862 <read+0x8a>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80084c:	8b 42 08             	mov    0x8(%edx),%eax
  80084f:	8b 55 10             	mov    0x10(%ebp),%edx
  800852:	89 54 24 08          	mov    %edx,0x8(%esp)
  800856:	8b 55 0c             	mov    0xc(%ebp),%edx
  800859:	89 54 24 04          	mov    %edx,0x4(%esp)
  80085d:	89 0c 24             	mov    %ecx,(%esp)
  800860:	ff d0                	call   *%eax
}
  800862:	83 c4 24             	add    $0x24,%esp
  800865:	5b                   	pop    %ebx
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	57                   	push   %edi
  80086c:	56                   	push   %esi
  80086d:	53                   	push   %ebx
  80086e:	83 ec 0c             	sub    $0xc,%esp
  800871:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800874:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800877:	b8 00 00 00 00       	mov    $0x0,%eax
  80087c:	85 f6                	test   %esi,%esi
  80087e:	74 36                	je     8008b6 <readn+0x4e>
  800880:	bb 00 00 00 00       	mov    $0x0,%ebx
  800885:	ba 00 00 00 00       	mov    $0x0,%edx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80088a:	89 f0                	mov    %esi,%eax
  80088c:	29 d0                	sub    %edx,%eax
  80088e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800892:	8d 04 17             	lea    (%edi,%edx,1),%eax
  800895:	89 44 24 04          	mov    %eax,0x4(%esp)
  800899:	8b 45 08             	mov    0x8(%ebp),%eax
  80089c:	89 04 24             	mov    %eax,(%esp)
  80089f:	e8 34 ff ff ff       	call   8007d8 <read>
		if (m < 0)
  8008a4:	85 c0                	test   %eax,%eax
  8008a6:	78 0e                	js     8008b6 <readn+0x4e>
			return m;
		if (m == 0)
  8008a8:	85 c0                	test   %eax,%eax
  8008aa:	74 08                	je     8008b4 <readn+0x4c>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8008ac:	01 c3                	add    %eax,%ebx
  8008ae:	89 da                	mov    %ebx,%edx
  8008b0:	39 f3                	cmp    %esi,%ebx
  8008b2:	72 d6                	jb     80088a <readn+0x22>
  8008b4:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8008b6:	83 c4 0c             	add    $0xc,%esp
  8008b9:	5b                   	pop    %ebx
  8008ba:	5e                   	pop    %esi
  8008bb:	5f                   	pop    %edi
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	83 ec 28             	sub    $0x28,%esp
  8008c4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8008c7:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8008ca:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8008cd:	89 34 24             	mov    %esi,(%esp)
  8008d0:	e8 1b fc ff ff       	call   8004f0 <fd2num>
  8008d5:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8008d8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008dc:	89 04 24             	mov    %eax,(%esp)
  8008df:	e8 8a fc ff ff       	call   80056e <fd_lookup>
  8008e4:	89 c3                	mov    %eax,%ebx
  8008e6:	85 c0                	test   %eax,%eax
  8008e8:	78 05                	js     8008ef <fd_close+0x31>
  8008ea:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8008ed:	74 0d                	je     8008fc <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8008ef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008f3:	75 44                	jne    800939 <fd_close+0x7b>
  8008f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008fa:	eb 3d                	jmp    800939 <fd_close+0x7b>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8008fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800903:	8b 06                	mov    (%esi),%eax
  800905:	89 04 24             	mov    %eax,(%esp)
  800908:	e8 d5 fc ff ff       	call   8005e2 <dev_lookup>
  80090d:	89 c3                	mov    %eax,%ebx
  80090f:	85 c0                	test   %eax,%eax
  800911:	78 16                	js     800929 <fd_close+0x6b>
		if (dev->dev_close)
  800913:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800916:	8b 40 10             	mov    0x10(%eax),%eax
  800919:	bb 00 00 00 00       	mov    $0x0,%ebx
  80091e:	85 c0                	test   %eax,%eax
  800920:	74 07                	je     800929 <fd_close+0x6b>
			r = (*dev->dev_close)(fd);
  800922:	89 34 24             	mov    %esi,(%esp)
  800925:	ff d0                	call   *%eax
  800927:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800929:	89 74 24 04          	mov    %esi,0x4(%esp)
  80092d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800934:	e8 d5 f9 ff ff       	call   80030e <sys_page_unmap>
	return r;
}
  800939:	89 d8                	mov    %ebx,%eax
  80093b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80093e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800941:	89 ec                	mov    %ebp,%esp
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80094b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80094e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800952:	8b 45 08             	mov    0x8(%ebp),%eax
  800955:	89 04 24             	mov    %eax,(%esp)
  800958:	e8 11 fc ff ff       	call   80056e <fd_lookup>
  80095d:	85 c0                	test   %eax,%eax
  80095f:	78 13                	js     800974 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800961:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800968:	00 
  800969:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80096c:	89 04 24             	mov    %eax,(%esp)
  80096f:	e8 4a ff ff ff       	call   8008be <fd_close>
}
  800974:	c9                   	leave  
  800975:	c3                   	ret    

00800976 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	83 ec 18             	sub    $0x18,%esp
  80097c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80097f:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800982:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800989:	00 
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	89 04 24             	mov    %eax,(%esp)
  800990:	e8 5a 03 00 00       	call   800cef <open>
  800995:	89 c6                	mov    %eax,%esi
  800997:	85 c0                	test   %eax,%eax
  800999:	78 1b                	js     8009b6 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  80099b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a2:	89 34 24             	mov    %esi,(%esp)
  8009a5:	e8 a3 fc ff ff       	call   80064d <fstat>
  8009aa:	89 c3                	mov    %eax,%ebx
	close(fd);
  8009ac:	89 34 24             	mov    %esi,(%esp)
  8009af:	e8 91 ff ff ff       	call   800945 <close>
  8009b4:	89 de                	mov    %ebx,%esi
	return r;
}
  8009b6:	89 f0                	mov    %esi,%eax
  8009b8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8009bb:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8009be:	89 ec                	mov    %ebp,%esp
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	83 ec 38             	sub    $0x38,%esp
  8009c8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8009cb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8009ce:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8009d1:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8009d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	89 04 24             	mov    %eax,(%esp)
  8009e1:	e8 88 fb ff ff       	call   80056e <fd_lookup>
  8009e6:	89 c3                	mov    %eax,%ebx
  8009e8:	85 c0                	test   %eax,%eax
  8009ea:	0f 88 e1 00 00 00    	js     800ad1 <dup+0x10f>
		return r;
	close(newfdnum);
  8009f0:	89 3c 24             	mov    %edi,(%esp)
  8009f3:	e8 4d ff ff ff       	call   800945 <close>

	newfd = INDEX2FD(newfdnum);
  8009f8:	89 f8                	mov    %edi,%eax
  8009fa:	c1 e0 0c             	shl    $0xc,%eax
  8009fd:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  800a03:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a06:	89 04 24             	mov    %eax,(%esp)
  800a09:	e8 f2 fa ff ff       	call   800500 <fd2data>
  800a0e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800a10:	89 34 24             	mov    %esi,(%esp)
  800a13:	e8 e8 fa ff ff       	call   800500 <fd2data>
  800a18:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  800a1b:	89 d8                	mov    %ebx,%eax
  800a1d:	c1 e8 16             	shr    $0x16,%eax
  800a20:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800a27:	a8 01                	test   $0x1,%al
  800a29:	74 45                	je     800a70 <dup+0xae>
  800a2b:	89 da                	mov    %ebx,%edx
  800a2d:	c1 ea 0c             	shr    $0xc,%edx
  800a30:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800a37:	a8 01                	test   $0x1,%al
  800a39:	74 35                	je     800a70 <dup+0xae>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  800a3b:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800a42:	25 07 0e 00 00       	and    $0xe07,%eax
  800a47:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a4e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a52:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a59:	00 
  800a5a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a5e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a65:	e8 02 f9 ff ff       	call   80036c <sys_page_map>
  800a6a:	89 c3                	mov    %eax,%ebx
  800a6c:	85 c0                	test   %eax,%eax
  800a6e:	78 3e                	js     800aae <dup+0xec>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  800a70:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a73:	89 d0                	mov    %edx,%eax
  800a75:	c1 e8 0c             	shr    $0xc,%eax
  800a78:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a7f:	25 07 0e 00 00       	and    $0xe07,%eax
  800a84:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a88:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800a8c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a93:	00 
  800a94:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a98:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a9f:	e8 c8 f8 ff ff       	call   80036c <sys_page_map>
  800aa4:	89 c3                	mov    %eax,%ebx
  800aa6:	85 c0                	test   %eax,%eax
  800aa8:	78 04                	js     800aae <dup+0xec>
		goto err;
  800aaa:	89 fb                	mov    %edi,%ebx
  800aac:	eb 23                	jmp    800ad1 <dup+0x10f>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800aae:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ab2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ab9:	e8 50 f8 ff ff       	call   80030e <sys_page_unmap>
	sys_page_unmap(0, nva);
  800abe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ac1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800acc:	e8 3d f8 ff ff       	call   80030e <sys_page_unmap>
	return r;
}
  800ad1:	89 d8                	mov    %ebx,%eax
  800ad3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ad6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ad9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800adc:	89 ec                	mov    %ebp,%esp
  800ade:	5d                   	pop    %ebp
  800adf:	c3                   	ret    

00800ae0 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	53                   	push   %ebx
  800ae4:	83 ec 04             	sub    $0x4,%esp
  800ae7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  800aec:	89 1c 24             	mov    %ebx,(%esp)
  800aef:	e8 51 fe ff ff       	call   800945 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800af4:	83 c3 01             	add    $0x1,%ebx
  800af7:	83 fb 20             	cmp    $0x20,%ebx
  800afa:	75 f0                	jne    800aec <close_all+0xc>
		close(i);
}
  800afc:	83 c4 04             	add    $0x4,%esp
  800aff:	5b                   	pop    %ebx
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    
	...

00800b04 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	53                   	push   %ebx
  800b08:	83 ec 14             	sub    $0x14,%esp
  800b0b:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800b0d:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  800b13:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800b1a:	00 
  800b1b:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  800b22:	00 
  800b23:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b27:	89 14 24             	mov    %edx,(%esp)
  800b2a:	e8 e1 12 00 00       	call   801e10 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800b2f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800b36:	00 
  800b37:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b3b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b42:	e8 7d 13 00 00       	call   801ec4 <ipc_recv>
}
  800b47:	83 c4 14             	add    $0x14,%esp
  800b4a:	5b                   	pop    %ebx
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b53:	ba 00 00 00 00       	mov    $0x0,%edx
  800b58:	b8 08 00 00 00       	mov    $0x8,%eax
  800b5d:	e8 a2 ff ff ff       	call   800b04 <fsipc>
}
  800b62:	c9                   	leave  
  800b63:	c3                   	ret    

00800b64 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800b6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6d:	8b 40 0c             	mov    0xc(%eax),%eax
  800b70:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.set_size.req_size = newsize;
  800b75:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b78:	a3 04 30 80 00       	mov    %eax,0x803004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800b7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b82:	b8 02 00 00 00       	mov    $0x2,%eax
  800b87:	e8 78 ff ff ff       	call   800b04 <fsipc>
}
  800b8c:	c9                   	leave  
  800b8d:	c3                   	ret    

00800b8e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800b94:	8b 45 08             	mov    0x8(%ebp),%eax
  800b97:	8b 40 0c             	mov    0xc(%eax),%eax
  800b9a:	a3 00 30 80 00       	mov    %eax,0x803000
	return fsipc(FSREQ_FLUSH, NULL);
  800b9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba4:	b8 06 00 00 00       	mov    $0x6,%eax
  800ba9:	e8 56 ff ff ff       	call   800b04 <fsipc>
}
  800bae:	c9                   	leave  
  800baf:	c3                   	ret    

00800bb0 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 14             	sub    $0x14,%esp
  800bb7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800bba:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbd:	8b 40 0c             	mov    0xc(%eax),%eax
  800bc0:	a3 00 30 80 00       	mov    %eax,0x803000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800bc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bca:	b8 05 00 00 00       	mov    $0x5,%eax
  800bcf:	e8 30 ff ff ff       	call   800b04 <fsipc>
  800bd4:	85 c0                	test   %eax,%eax
  800bd6:	78 2b                	js     800c03 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800bd8:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  800bdf:	00 
  800be0:	89 1c 24             	mov    %ebx,(%esp)
  800be3:	e8 e9 0d 00 00       	call   8019d1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800be8:	a1 80 30 80 00       	mov    0x803080,%eax
  800bed:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800bf3:	a1 84 30 80 00       	mov    0x803084,%eax
  800bf8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  800bfe:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  800c03:	83 c4 14             	add    $0x14,%esp
  800c06:	5b                   	pop    %ebx
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    

00800c09 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	83 ec 18             	sub    $0x18,%esp
  800c0f:	8b 55 10             	mov    0x10(%ebp),%edx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	ssize_t writesize;
	size_t bufsize;
	fsipcbuf.write.req_fileid=fd->fd_file.id;
  800c12:	8b 45 08             	mov    0x8(%ebp),%eax
  800c15:	8b 40 0c             	mov    0xc(%eax),%eax
  800c18:	a3 00 30 80 00       	mov    %eax,0x803000
	bufsize=sizeof(fsipcbuf.write.req_buf);
	if(n<bufsize)
  800c1d:	89 d0                	mov    %edx,%eax
  800c1f:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  800c25:	76 05                	jbe    800c2c <devfile_write+0x23>
  800c27:	b8 f8 0f 00 00       	mov    $0xff8,%eax
		bufsize=n;	
	fsipcbuf.write.req_n=n;
  800c2c:	89 15 04 30 80 00    	mov    %edx,0x803004
	memmove((void*)fsipcbuf.write.req_buf,buf,bufsize);
  800c32:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c36:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c39:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c3d:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  800c44:	e8 8f 0f 00 00       	call   801bd8 <memmove>
	writesize=(ssize_t)fsipc(FSREQ_WRITE,NULL);
  800c49:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4e:	b8 04 00 00 00       	mov    $0x4,%eax
  800c53:	e8 ac fe ff ff       	call   800b04 <fsipc>
	return writesize;
	//panic("devfile_write not implemented");
}
  800c58:	c9                   	leave  
  800c59:	c3                   	ret    

00800c5a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	53                   	push   %ebx
  800c5e:	83 ec 14             	sub    $0x14,%esp
	// system server.
	// LAB 5: Your code here
	ssize_t readsize;
	if(debug)
		cprintf("devfile_read:fileid=%x readsize=%x\n",fd->fd_file.id,n);
	fsipcbuf.read.req_fileid=fd->fd_file.id;
  800c61:	8b 45 08             	mov    0x8(%ebp),%eax
  800c64:	8b 40 0c             	mov    0xc(%eax),%eax
  800c67:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.read.req_n=n;
  800c6c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c6f:	a3 04 30 80 00       	mov    %eax,0x803004
	readsize=(ssize_t)fsipc(FSREQ_READ,&fsipcbuf);
  800c74:	ba 00 30 80 00       	mov    $0x803000,%edx
  800c79:	b8 03 00 00 00       	mov    $0x3,%eax
  800c7e:	e8 81 fe ff ff       	call   800b04 <fsipc>
  800c83:	89 c3                	mov    %eax,%ebx
	//cprintf("readsize=%d\n",readsize);
	if(debug)
		cprintf("devfile_read:buf1=%s\nbuf2=%s\n",(char*)&fsipcbuf,fsipcbuf.readRet.ret_buf);
	if(readsize>0)
  800c85:	85 c0                	test   %eax,%eax
  800c87:	7e 17                	jle    800ca0 <devfile_read+0x46>
		memmove(buf,(void*)&fsipcbuf,(size_t)readsize);
  800c89:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c8d:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  800c94:	00 
  800c95:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c98:	89 04 24             	mov    %eax,(%esp)
  800c9b:	e8 38 0f 00 00       	call   801bd8 <memmove>
	//cprintf("readsize=%d",readsize);
	return readsize;
	//panic("devfile_read not implemented");
}
  800ca0:	89 d8                	mov    %ebx,%eax
  800ca2:	83 c4 14             	add    $0x14,%esp
  800ca5:	5b                   	pop    %ebx
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    

00800ca8 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	53                   	push   %ebx
  800cac:	83 ec 14             	sub    $0x14,%esp
  800caf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800cb2:	89 1c 24             	mov    %ebx,(%esp)
  800cb5:	e8 c6 0c 00 00       	call   801980 <strlen>
  800cba:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  800cbf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800cc4:	7f 21                	jg     800ce7 <remove+0x3f>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  800cc6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cca:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  800cd1:	e8 fb 0c 00 00       	call   8019d1 <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  800cd6:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdb:	b8 07 00 00 00       	mov    $0x7,%eax
  800ce0:	e8 1f fe ff ff       	call   800b04 <fsipc>
  800ce5:	89 c2                	mov    %eax,%edx
}
  800ce7:	89 d0                	mov    %edx,%eax
  800ce9:	83 c4 14             	add    $0x14,%esp
  800cec:	5b                   	pop    %ebx
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
  800cf4:	83 ec 30             	sub    $0x30,%esp

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;
	void *page;
	if((r=fd_alloc(&fd))<0){
  800cf7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cfa:	89 04 24             	mov    %eax,(%esp)
  800cfd:	e8 19 f8 ff ff       	call   80051b <fd_alloc>
  800d02:	89 c3                	mov    %eax,%ebx
  800d04:	85 c0                	test   %eax,%eax
  800d06:	79 18                	jns    800d20 <open+0x31>
		fd_close(fd,0);
  800d08:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d0f:	00 
  800d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d13:	89 04 24             	mov    %eax,(%esp)
  800d16:	e8 a3 fb ff ff       	call   8008be <fd_close>
  800d1b:	e9 9f 00 00 00       	jmp    800dbf <open+0xd0>
		return r;
	}
	//cprintf("open:fd=%x\n",fd);
	strcpy(fsipcbuf.open.req_path,path);
  800d20:	8b 45 08             	mov    0x8(%ebp),%eax
  800d23:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d27:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  800d2e:	e8 9e 0c 00 00       	call   8019d1 <strcpy>
	fsipcbuf.open.req_omode=mode;
  800d33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d36:	a3 00 34 80 00       	mov    %eax,0x803400
	page=(void*)fd2data(fd);
  800d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d3e:	89 04 24             	mov    %eax,(%esp)
  800d41:	e8 ba f7 ff ff       	call   800500 <fd2data>
  800d46:	89 c6                	mov    %eax,%esi
	if((r=fsipc(FSREQ_OPEN,(void*)fd))<0)
  800d48:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d4b:	b8 01 00 00 00       	mov    $0x1,%eax
  800d50:	e8 af fd ff ff       	call   800b04 <fsipc>
  800d55:	89 c3                	mov    %eax,%ebx
  800d57:	85 c0                	test   %eax,%eax
  800d59:	79 15                	jns    800d70 <open+0x81>
	{
		fd_close(fd,1);
  800d5b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800d62:	00 
  800d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d66:	89 04 24             	mov    %eax,(%esp)
  800d69:	e8 50 fb ff ff       	call   8008be <fd_close>
  800d6e:	eb 4f                	jmp    800dbf <open+0xd0>
		return r;	
	}
	//cprintf("open:page=%x\n",page);
	if((r=sys_page_map(0,(void*)fd,0,(void*)page,PTE_P | PTE_W | PTE_U))<0)
  800d70:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800d77:	00 
  800d78:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800d7c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d83:	00 
  800d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d87:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d8b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d92:	e8 d5 f5 ff ff       	call   80036c <sys_page_map>
  800d97:	89 c3                	mov    %eax,%ebx
  800d99:	85 c0                	test   %eax,%eax
  800d9b:	79 15                	jns    800db2 <open+0xc3>
	{
		fd_close(fd,1);
  800d9d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800da4:	00 
  800da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800da8:	89 04 24             	mov    %eax,(%esp)
  800dab:	e8 0e fb ff ff       	call   8008be <fd_close>
  800db0:	eb 0d                	jmp    800dbf <open+0xd0>
		return r;
	}
	//cprintf("open:fileid=%x\n",fd->fd_file.id);
	return fd2num(fd);
  800db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800db5:	89 04 24             	mov    %eax,(%esp)
  800db8:	e8 33 f7 ff ff       	call   8004f0 <fd2num>
  800dbd:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  800dbf:	89 d8                	mov    %ebx,%eax
  800dc1:	83 c4 30             	add    $0x30,%esp
  800dc4:	5b                   	pop    %ebx
  800dc5:	5e                   	pop    %esi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    
	...

00800dd0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	83 ec 08             	sub    $0x8,%esp
	strcpy(stat->st_name, "<sock>");
  800dd6:	c7 44 24 04 30 23 80 	movl   $0x802330,0x4(%esp)
  800ddd:	00 
  800dde:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de1:	89 04 24             	mov    %eax,(%esp)
  800de4:	e8 e8 0b 00 00       	call   8019d1 <strcpy>
	return 0;
}
  800de9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dee:	c9                   	leave  
  800def:	c3                   	ret    

00800df0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_close(fd->fd_sock.sockid);
  800df6:	8b 45 08             	mov    0x8(%ebp),%eax
  800df9:	8b 40 0c             	mov    0xc(%eax),%eax
  800dfc:	89 04 24             	mov    %eax,(%esp)
  800dff:	e8 9e 02 00 00       	call   8010a2 <nsipc_close>
}
  800e04:	c9                   	leave  
  800e05:	c3                   	ret    

00800e06 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800e0c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e13:	00 
  800e14:	8b 45 10             	mov    0x10(%ebp),%eax
  800e17:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e22:	8b 45 08             	mov    0x8(%ebp),%eax
  800e25:	8b 40 0c             	mov    0xc(%eax),%eax
  800e28:	89 04 24             	mov    %eax,(%esp)
  800e2b:	e8 ae 02 00 00       	call   8010de <nsipc_send>
}
  800e30:	c9                   	leave  
  800e31:	c3                   	ret    

00800e32 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800e38:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e3f:	00 
  800e40:	8b 45 10             	mov    0x10(%ebp),%eax
  800e43:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e51:	8b 40 0c             	mov    0xc(%eax),%eax
  800e54:	89 04 24             	mov    %eax,(%esp)
  800e57:	e8 f5 02 00 00       	call   801151 <nsipc_recv>
}
  800e5c:	c9                   	leave  
  800e5d:	c3                   	ret    

00800e5e <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
  800e61:	56                   	push   %esi
  800e62:	53                   	push   %ebx
  800e63:	83 ec 20             	sub    $0x20,%esp
  800e66:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800e68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e6b:	89 04 24             	mov    %eax,(%esp)
  800e6e:	e8 a8 f6 ff ff       	call   80051b <fd_alloc>
  800e73:	89 c3                	mov    %eax,%ebx
  800e75:	85 c0                	test   %eax,%eax
  800e77:	78 21                	js     800e9a <alloc_sockfd+0x3c>
  800e79:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e80:	00 
  800e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e84:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e88:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e8f:	e8 36 f5 ff ff       	call   8003ca <sys_page_alloc>
  800e94:	89 c3                	mov    %eax,%ebx
  800e96:	85 c0                	test   %eax,%eax
  800e98:	79 0a                	jns    800ea4 <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U)) < 0) {
		nsipc_close(sockid);
  800e9a:	89 34 24             	mov    %esi,(%esp)
  800e9d:	e8 00 02 00 00       	call   8010a2 <nsipc_close>
  800ea2:	eb 28                	jmp    800ecc <alloc_sockfd+0x6e>
		return r;
	}

	sfd->fd_dev_id = devsock.dev_id;
  800ea4:	8b 15 20 60 80 00    	mov    0x806020,%edx
  800eaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ead:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800eaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eb2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800eb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ebc:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800ebf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ec2:	89 04 24             	mov    %eax,(%esp)
  800ec5:	e8 26 f6 ff ff       	call   8004f0 <fd2num>
  800eca:	89 c3                	mov    %eax,%ebx
}
  800ecc:	89 d8                	mov    %ebx,%eax
  800ece:	83 c4 20             	add    $0x20,%esp
  800ed1:	5b                   	pop    %ebx
  800ed2:	5e                   	pop    %esi
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    

00800ed5 <socket>:
	return 0;
}

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
  800eef:	e8 62 01 00 00       	call   801056 <nsipc_socket>
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
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	83 ec 18             	sub    $0x18,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800f07:	8d 55 fc             	lea    -0x4(%ebp),%edx
  800f0a:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f0e:	89 04 24             	mov    %eax,(%esp)
  800f11:	e8 58 f6 ff ff       	call   80056e <fd_lookup>
  800f16:	89 c2                	mov    %eax,%edx
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	78 15                	js     800f31 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800f1c:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  800f1f:	8b 01                	mov    (%ecx),%eax
  800f21:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  800f26:	3b 05 20 60 80 00    	cmp    0x806020,%eax
  800f2c:	75 03                	jne    800f31 <fd2sockid+0x30>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800f2e:	8b 51 0c             	mov    0xc(%ecx),%edx
}
  800f31:	89 d0                	mov    %edx,%eax
  800f33:	c9                   	leave  
  800f34:	c3                   	ret    

00800f35 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800f3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3e:	e8 be ff ff ff       	call   800f01 <fd2sockid>
  800f43:	85 c0                	test   %eax,%eax
  800f45:	78 0f                	js     800f56 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800f47:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f4a:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f4e:	89 04 24             	mov    %eax,(%esp)
  800f51:	e8 2a 01 00 00       	call   801080 <nsipc_listen>
}
  800f56:	c9                   	leave  
  800f57:	c3                   	ret    

00800f58 <connect>:
	return nsipc_close(fd->fd_sock.sockid);
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800f5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f61:	e8 9b ff ff ff       	call   800f01 <fd2sockid>
  800f66:	85 c0                	test   %eax,%eax
  800f68:	78 16                	js     800f80 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  800f6a:	8b 55 10             	mov    0x10(%ebp),%edx
  800f6d:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f71:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f74:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f78:	89 04 24             	mov    %eax,(%esp)
  800f7b:	e8 51 02 00 00       	call   8011d1 <nsipc_connect>
}
  800f80:	c9                   	leave  
  800f81:	c3                   	ret    

00800f82 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800f88:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8b:	e8 71 ff ff ff       	call   800f01 <fd2sockid>
  800f90:	85 c0                	test   %eax,%eax
  800f92:	78 0f                	js     800fa3 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800f94:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f97:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f9b:	89 04 24             	mov    %eax,(%esp)
  800f9e:	e8 19 01 00 00       	call   8010bc <nsipc_shutdown>
}
  800fa3:	c9                   	leave  
  800fa4:	c3                   	ret    

00800fa5 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800fa5:	55                   	push   %ebp
  800fa6:	89 e5                	mov    %esp,%ebp
  800fa8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800fab:	8b 45 08             	mov    0x8(%ebp),%eax
  800fae:	e8 4e ff ff ff       	call   800f01 <fd2sockid>
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	78 16                	js     800fcd <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  800fb7:	8b 55 10             	mov    0x10(%ebp),%edx
  800fba:	89 54 24 08          	mov    %edx,0x8(%esp)
  800fbe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fc5:	89 04 24             	mov    %eax,(%esp)
  800fc8:	e8 43 02 00 00       	call   801210 <nsipc_bind>
}
  800fcd:	c9                   	leave  
  800fce:	c3                   	ret    

00800fcf <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800fd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd8:	e8 24 ff ff ff       	call   800f01 <fd2sockid>
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	78 1f                	js     801000 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800fe1:	8b 55 10             	mov    0x10(%ebp),%edx
  800fe4:	89 54 24 08          	mov    %edx,0x8(%esp)
  800fe8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800feb:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fef:	89 04 24             	mov    %eax,(%esp)
  800ff2:	e8 58 02 00 00       	call   80124f <nsipc_accept>
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	78 05                	js     801000 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  800ffb:	e8 5e fe ff ff       	call   800e5e <alloc_sockfd>
}
  801000:	c9                   	leave  
  801001:	c3                   	ret    
	...

00801010 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("[%08x] nsipc %d\n", env->env_id, type);

	ipc_send(envs[2].env_id, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801016:	8b 15 44 01 c0 ee    	mov    0xeec00144,%edx
  80101c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801023:	00 
  801024:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  80102b:	00 
  80102c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801030:	89 14 24             	mov    %edx,(%esp)
  801033:	e8 d8 0d 00 00       	call   801e10 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801038:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80103f:	00 
  801040:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801047:	00 
  801048:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80104f:	e8 70 0e 00 00       	call   801ec4 <ipc_recv>
}
  801054:	c9                   	leave  
  801055:	c3                   	ret    

00801056 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80105c:	8b 45 08             	mov    0x8(%ebp),%eax
  80105f:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.socket.req_type = type;
  801064:	8b 45 0c             	mov    0xc(%ebp),%eax
  801067:	a3 04 50 80 00       	mov    %eax,0x805004
	nsipcbuf.socket.req_protocol = protocol;
  80106c:	8b 45 10             	mov    0x10(%ebp),%eax
  80106f:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SOCKET);
  801074:	b8 09 00 00 00       	mov    $0x9,%eax
  801079:	e8 92 ff ff ff       	call   801010 <nsipc>
}
  80107e:	c9                   	leave  
  80107f:	c3                   	ret    

00801080 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801086:	8b 45 08             	mov    0x8(%ebp),%eax
  801089:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.listen.req_backlog = backlog;
  80108e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801091:	a3 04 50 80 00       	mov    %eax,0x805004
	return nsipc(NSREQ_LISTEN);
  801096:	b8 06 00 00 00       	mov    $0x6,%eax
  80109b:	e8 70 ff ff ff       	call   801010 <nsipc>
}
  8010a0:	c9                   	leave  
  8010a1:	c3                   	ret    

008010a2 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8010a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ab:	a3 00 50 80 00       	mov    %eax,0x805000
	return nsipc(NSREQ_CLOSE);
  8010b0:	b8 04 00 00 00       	mov    $0x4,%eax
  8010b5:	e8 56 ff ff ff       	call   801010 <nsipc>
}
  8010ba:	c9                   	leave  
  8010bb:	c3                   	ret    

008010bc <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8010c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c5:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.shutdown.req_how = how;
  8010ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010cd:	a3 04 50 80 00       	mov    %eax,0x805004
	return nsipc(NSREQ_SHUTDOWN);
  8010d2:	b8 03 00 00 00       	mov    $0x3,%eax
  8010d7:	e8 34 ff ff ff       	call   801010 <nsipc>
}
  8010dc:	c9                   	leave  
  8010dd:	c3                   	ret    

008010de <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	53                   	push   %ebx
  8010e2:	83 ec 14             	sub    $0x14,%esp
  8010e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8010e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010eb:	a3 00 50 80 00       	mov    %eax,0x805000
	assert(size < 1600);
  8010f0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8010f6:	7e 24                	jle    80111c <nsipc_send+0x3e>
  8010f8:	c7 44 24 0c 3c 23 80 	movl   $0x80233c,0xc(%esp)
  8010ff:	00 
  801100:	c7 44 24 08 48 23 80 	movl   $0x802348,0x8(%esp)
  801107:	00 
  801108:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  80110f:	00 
  801110:	c7 04 24 5d 23 80 00 	movl   $0x80235d,(%esp)
  801117:	e8 80 01 00 00       	call   80129c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80111c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801120:	8b 45 0c             	mov    0xc(%ebp),%eax
  801123:	89 44 24 04          	mov    %eax,0x4(%esp)
  801127:	c7 04 24 0c 50 80 00 	movl   $0x80500c,(%esp)
  80112e:	e8 a5 0a 00 00       	call   801bd8 <memmove>
	nsipcbuf.send.req_size = size;
  801133:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	nsipcbuf.send.req_flags = flags;
  801139:	8b 45 14             	mov    0x14(%ebp),%eax
  80113c:	a3 08 50 80 00       	mov    %eax,0x805008
	return nsipc(NSREQ_SEND);
  801141:	b8 08 00 00 00       	mov    $0x8,%eax
  801146:	e8 c5 fe ff ff       	call   801010 <nsipc>
}
  80114b:	83 c4 14             	add    $0x14,%esp
  80114e:	5b                   	pop    %ebx
  80114f:	5d                   	pop    %ebp
  801150:	c3                   	ret    

00801151 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801151:	55                   	push   %ebp
  801152:	89 e5                	mov    %esp,%ebp
  801154:	56                   	push   %esi
  801155:	53                   	push   %ebx
  801156:	83 ec 10             	sub    $0x10,%esp
  801159:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80115c:	8b 45 08             	mov    0x8(%ebp),%eax
  80115f:	a3 00 50 80 00       	mov    %eax,0x805000
	nsipcbuf.recv.req_len = len;
  801164:	89 35 04 50 80 00    	mov    %esi,0x805004
	nsipcbuf.recv.req_flags = flags;
  80116a:	8b 45 14             	mov    0x14(%ebp),%eax
  80116d:	a3 08 50 80 00       	mov    %eax,0x805008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801172:	b8 07 00 00 00       	mov    $0x7,%eax
  801177:	e8 94 fe ff ff       	call   801010 <nsipc>
  80117c:	89 c3                	mov    %eax,%ebx
  80117e:	85 c0                	test   %eax,%eax
  801180:	78 46                	js     8011c8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801182:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801187:	7f 04                	jg     80118d <nsipc_recv+0x3c>
  801189:	39 c6                	cmp    %eax,%esi
  80118b:	7d 24                	jge    8011b1 <nsipc_recv+0x60>
  80118d:	c7 44 24 0c 69 23 80 	movl   $0x802369,0xc(%esp)
  801194:	00 
  801195:	c7 44 24 08 48 23 80 	movl   $0x802348,0x8(%esp)
  80119c:	00 
  80119d:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  8011a4:	00 
  8011a5:	c7 04 24 5d 23 80 00 	movl   $0x80235d,(%esp)
  8011ac:	e8 eb 00 00 00       	call   80129c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8011b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011b5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8011bc:	00 
  8011bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011c0:	89 04 24             	mov    %eax,(%esp)
  8011c3:	e8 10 0a 00 00       	call   801bd8 <memmove>
	}

	return r;
}
  8011c8:	89 d8                	mov    %ebx,%eax
  8011ca:	83 c4 10             	add    $0x10,%esp
  8011cd:	5b                   	pop    %ebx
  8011ce:	5e                   	pop    %esi
  8011cf:	5d                   	pop    %ebp
  8011d0:	c3                   	ret    

008011d1 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
  8011d4:	53                   	push   %ebx
  8011d5:	83 ec 14             	sub    $0x14,%esp
  8011d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8011db:	8b 45 08             	mov    0x8(%ebp),%eax
  8011de:	a3 00 50 80 00       	mov    %eax,0x805000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8011e3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ee:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  8011f5:	e8 de 09 00 00       	call   801bd8 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8011fa:	89 1d 14 50 80 00    	mov    %ebx,0x805014
	return nsipc(NSREQ_CONNECT);
  801200:	b8 05 00 00 00       	mov    $0x5,%eax
  801205:	e8 06 fe ff ff       	call   801010 <nsipc>
}
  80120a:	83 c4 14             	add    $0x14,%esp
  80120d:	5b                   	pop    %ebx
  80120e:	5d                   	pop    %ebp
  80120f:	c3                   	ret    

00801210 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	53                   	push   %ebx
  801214:	83 ec 14             	sub    $0x14,%esp
  801217:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80121a:	8b 45 08             	mov    0x8(%ebp),%eax
  80121d:	a3 00 50 80 00       	mov    %eax,0x805000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801222:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801226:	8b 45 0c             	mov    0xc(%ebp),%eax
  801229:	89 44 24 04          	mov    %eax,0x4(%esp)
  80122d:	c7 04 24 04 50 80 00 	movl   $0x805004,(%esp)
  801234:	e8 9f 09 00 00       	call   801bd8 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801239:	89 1d 14 50 80 00    	mov    %ebx,0x805014
	return nsipc(NSREQ_BIND);
  80123f:	b8 02 00 00 00       	mov    $0x2,%eax
  801244:	e8 c7 fd ff ff       	call   801010 <nsipc>
}
  801249:	83 c4 14             	add    $0x14,%esp
  80124c:	5b                   	pop    %ebx
  80124d:	5d                   	pop    %ebp
  80124e:	c3                   	ret    

0080124f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	53                   	push   %ebx
  801253:	83 ec 14             	sub    $0x14,%esp
	int r;
	
	nsipcbuf.accept.req_s = s;
  801256:	8b 45 08             	mov    0x8(%ebp),%eax
  801259:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80125e:	b8 01 00 00 00       	mov    $0x1,%eax
  801263:	e8 a8 fd ff ff       	call   801010 <nsipc>
  801268:	89 c3                	mov    %eax,%ebx
  80126a:	85 c0                	test   %eax,%eax
  80126c:	78 26                	js     801294 <nsipc_accept+0x45>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80126e:	a1 10 50 80 00       	mov    0x805010,%eax
  801273:	89 44 24 08          	mov    %eax,0x8(%esp)
  801277:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80127e:	00 
  80127f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801282:	89 04 24             	mov    %eax,(%esp)
  801285:	e8 4e 09 00 00       	call   801bd8 <memmove>
		*addrlen = ret->ret_addrlen;
  80128a:	a1 10 50 80 00       	mov    0x805010,%eax
  80128f:	8b 55 10             	mov    0x10(%ebp),%edx
  801292:	89 02                	mov    %eax,(%edx)
	}
	return r;
}
  801294:	89 d8                	mov    %ebx,%eax
  801296:	83 c4 14             	add    $0x14,%esp
  801299:	5b                   	pop    %ebx
  80129a:	5d                   	pop    %ebp
  80129b:	c3                   	ret    

0080129c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8012a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8012a5:	89 45 fc             	mov    %eax,-0x4(%ebp)

	// Print the panic message
	if (argv0)
  8012a8:	a1 40 60 80 00       	mov    0x806040,%eax
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	74 10                	je     8012c1 <_panic+0x25>
		cprintf("%s: ", argv0);
  8012b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b5:	c7 04 24 7e 23 80 00 	movl   $0x80237e,(%esp)
  8012bc:	e8 a8 00 00 00       	call   801369 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8012c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8012cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012cf:	a1 00 60 80 00       	mov    0x806000,%eax
  8012d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d8:	c7 04 24 83 23 80 00 	movl   $0x802383,(%esp)
  8012df:	e8 85 00 00 00       	call   801369 <cprintf>
	vcprintf(fmt, ap);
  8012e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012eb:	8b 45 10             	mov    0x10(%ebp),%eax
  8012ee:	89 04 24             	mov    %eax,(%esp)
  8012f1:	e8 12 00 00 00       	call   801308 <vcprintf>
	cprintf("\n");
  8012f6:	c7 04 24 e2 26 80 00 	movl   $0x8026e2,(%esp)
  8012fd:	e8 67 00 00 00       	call   801369 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801302:	cc                   	int3   
  801303:	eb fd                	jmp    801302 <_panic+0x66>
  801305:	00 00                	add    %al,(%eax)
	...

00801308 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
  80130b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801311:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  801318:	00 00 00 
	b.cnt = 0;
  80131b:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  801322:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801325:	8b 45 0c             	mov    0xc(%ebp),%eax
  801328:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80132c:	8b 45 08             	mov    0x8(%ebp),%eax
  80132f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801333:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801339:	89 44 24 04          	mov    %eax,0x4(%esp)
  80133d:	c7 04 24 86 13 80 00 	movl   $0x801386,(%esp)
  801344:	e8 cc 01 00 00       	call   801515 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801349:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
  80134f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801353:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  801359:	89 04 24             	mov    %eax,(%esp)
  80135c:	e8 97 ed ff ff       	call   8000f8 <sys_cputs>
  801361:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  801367:	c9                   	leave  
  801368:	c3                   	ret    

00801369 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801369:	55                   	push   %ebp
  80136a:	89 e5                	mov    %esp,%ebp
  80136c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80136f:	8d 45 0c             	lea    0xc(%ebp),%eax
  801372:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  801375:	89 44 24 04          	mov    %eax,0x4(%esp)
  801379:	8b 45 08             	mov    0x8(%ebp),%eax
  80137c:	89 04 24             	mov    %eax,(%esp)
  80137f:	e8 84 ff ff ff       	call   801308 <vcprintf>
	va_end(ap);

	return cnt;
}
  801384:	c9                   	leave  
  801385:	c3                   	ret    

00801386 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	53                   	push   %ebx
  80138a:	83 ec 14             	sub    $0x14,%esp
  80138d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801390:	8b 03                	mov    (%ebx),%eax
  801392:	8b 55 08             	mov    0x8(%ebp),%edx
  801395:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801399:	83 c0 01             	add    $0x1,%eax
  80139c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80139e:	3d ff 00 00 00       	cmp    $0xff,%eax
  8013a3:	75 19                	jne    8013be <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8013a5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8013ac:	00 
  8013ad:	8d 43 08             	lea    0x8(%ebx),%eax
  8013b0:	89 04 24             	mov    %eax,(%esp)
  8013b3:	e8 40 ed ff ff       	call   8000f8 <sys_cputs>
		b->idx = 0;
  8013b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8013be:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8013c2:	83 c4 14             	add    $0x14,%esp
  8013c5:	5b                   	pop    %ebx
  8013c6:	5d                   	pop    %ebp
  8013c7:	c3                   	ret    
	...

008013d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
  8013d3:	57                   	push   %edi
  8013d4:	56                   	push   %esi
  8013d5:	53                   	push   %ebx
  8013d6:	83 ec 3c             	sub    $0x3c,%esp
  8013d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8013dc:	89 d7                	mov    %edx,%edi
  8013de:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8013e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8013ea:	8b 55 10             	mov    0x10(%ebp),%edx
  8013ed:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8013f0:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8013f3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  8013fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013fd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  801400:	72 14                	jb     801416 <printnum+0x46>
  801402:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801405:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  801408:	76 0c                	jbe    801416 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80140a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80140d:	83 eb 01             	sub    $0x1,%ebx
  801410:	85 db                	test   %ebx,%ebx
  801412:	7f 57                	jg     80146b <printnum+0x9b>
  801414:	eb 64                	jmp    80147a <printnum+0xaa>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801416:	89 74 24 10          	mov    %esi,0x10(%esp)
  80141a:	8b 45 14             	mov    0x14(%ebp),%eax
  80141d:	83 e8 01             	sub    $0x1,%eax
  801420:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801424:	89 54 24 08          	mov    %edx,0x8(%esp)
  801428:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80142c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801430:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801433:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801436:	89 44 24 08          	mov    %eax,0x8(%esp)
  80143a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80143e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801441:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801444:	89 04 24             	mov    %eax,(%esp)
  801447:	89 54 24 04          	mov    %edx,0x4(%esp)
  80144b:	e8 60 0b 00 00       	call   801fb0 <__udivdi3>
  801450:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801454:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801458:	89 04 24             	mov    %eax,(%esp)
  80145b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80145f:	89 fa                	mov    %edi,%edx
  801461:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801464:	e8 67 ff ff ff       	call   8013d0 <printnum>
  801469:	eb 0f                	jmp    80147a <printnum+0xaa>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80146b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80146f:	89 34 24             	mov    %esi,(%esp)
  801472:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801475:	83 eb 01             	sub    $0x1,%ebx
  801478:	75 f1                	jne    80146b <printnum+0x9b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80147a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80147e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801482:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801485:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801488:	89 44 24 08          	mov    %eax,0x8(%esp)
  80148c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801490:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801493:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801496:	89 04 24             	mov    %eax,(%esp)
  801499:	89 54 24 04          	mov    %edx,0x4(%esp)
  80149d:	e8 3e 0c 00 00       	call   8020e0 <__umoddi3>
  8014a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014a6:	0f be 80 9f 23 80 00 	movsbl 0x80239f(%eax),%eax
  8014ad:	89 04 24             	mov    %eax,(%esp)
  8014b0:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8014b3:	83 c4 3c             	add    $0x3c,%esp
  8014b6:	5b                   	pop    %ebx
  8014b7:	5e                   	pop    %esi
  8014b8:	5f                   	pop    %edi
  8014b9:	5d                   	pop    %ebp
  8014ba:	c3                   	ret    

008014bb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8014c0:	83 fa 01             	cmp    $0x1,%edx
  8014c3:	7e 0e                	jle    8014d3 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8014c5:	8b 10                	mov    (%eax),%edx
  8014c7:	8d 42 08             	lea    0x8(%edx),%eax
  8014ca:	89 01                	mov    %eax,(%ecx)
  8014cc:	8b 02                	mov    (%edx),%eax
  8014ce:	8b 52 04             	mov    0x4(%edx),%edx
  8014d1:	eb 22                	jmp    8014f5 <getuint+0x3a>
	else if (lflag)
  8014d3:	85 d2                	test   %edx,%edx
  8014d5:	74 10                	je     8014e7 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8014d7:	8b 10                	mov    (%eax),%edx
  8014d9:	8d 42 04             	lea    0x4(%edx),%eax
  8014dc:	89 01                	mov    %eax,(%ecx)
  8014de:	8b 02                	mov    (%edx),%eax
  8014e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e5:	eb 0e                	jmp    8014f5 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  8014e7:	8b 10                	mov    (%eax),%edx
  8014e9:	8d 42 04             	lea    0x4(%edx),%eax
  8014ec:	89 01                	mov    %eax,(%ecx)
  8014ee:	8b 02                	mov    (%edx),%eax
  8014f0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8014f5:	5d                   	pop    %ebp
  8014f6:	c3                   	ret    

008014f7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8014f7:	55                   	push   %ebp
  8014f8:	89 e5                	mov    %esp,%ebp
  8014fa:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  8014fd:	83 42 08 01          	addl   $0x1,0x8(%edx)
	if (b->buf < b->ebuf)
  801501:	8b 02                	mov    (%edx),%eax
  801503:	3b 42 04             	cmp    0x4(%edx),%eax
  801506:	73 0b                	jae    801513 <sprintputch+0x1c>
		*b->buf++ = ch;
  801508:	0f b6 4d 08          	movzbl 0x8(%ebp),%ecx
  80150c:	88 08                	mov    %cl,(%eax)
  80150e:	83 c0 01             	add    $0x1,%eax
  801511:	89 02                	mov    %eax,(%edx)
}
  801513:	5d                   	pop    %ebp
  801514:	c3                   	ret    

00801515 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	57                   	push   %edi
  801519:	56                   	push   %esi
  80151a:	53                   	push   %ebx
  80151b:	83 ec 3c             	sub    $0x3c,%esp
  80151e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801521:	eb 18                	jmp    80153b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801523:	84 c0                	test   %al,%al
  801525:	0f 84 9f 03 00 00    	je     8018ca <vprintfmt+0x3b5>
				return;
			putch(ch, putdat);
  80152b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80152e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801532:	0f b6 c0             	movzbl %al,%eax
  801535:	89 04 24             	mov    %eax,(%esp)
  801538:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80153b:	0f b6 03             	movzbl (%ebx),%eax
  80153e:	83 c3 01             	add    $0x1,%ebx
  801541:	3c 25                	cmp    $0x25,%al
  801543:	75 de                	jne    801523 <vprintfmt+0xe>
  801545:	b9 00 00 00 00       	mov    $0x0,%ecx
  80154a:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
  801551:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  801556:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80155d:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
  801561:	eb 07                	jmp    80156a <vprintfmt+0x55>
  801563:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80156a:	0f b6 13             	movzbl (%ebx),%edx
  80156d:	83 c3 01             	add    $0x1,%ebx
  801570:	8d 42 dd             	lea    -0x23(%edx),%eax
  801573:	3c 55                	cmp    $0x55,%al
  801575:	0f 87 22 03 00 00    	ja     80189d <vprintfmt+0x388>
  80157b:	0f b6 c0             	movzbl %al,%eax
  80157e:	ff 24 85 e0 24 80 00 	jmp    *0x8024e0(,%eax,4)
  801585:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
  801589:	eb df                	jmp    80156a <vprintfmt+0x55>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80158b:	0f b6 c2             	movzbl %dl,%eax
  80158e:	8d 78 d0             	lea    -0x30(%eax),%edi
				ch = *fmt;
  801591:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  801594:	8d 42 d0             	lea    -0x30(%edx),%eax
  801597:	83 f8 09             	cmp    $0x9,%eax
  80159a:	76 08                	jbe    8015a4 <vprintfmt+0x8f>
  80159c:	eb 39                	jmp    8015d7 <vprintfmt+0xc2>
  80159e:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
  8015a2:	eb c6                	jmp    80156a <vprintfmt+0x55>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8015a4:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  8015a7:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  8015aa:	8d 7c 42 d0          	lea    -0x30(%edx,%eax,2),%edi
				ch = *fmt;
  8015ae:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  8015b1:	8d 42 d0             	lea    -0x30(%edx),%eax
  8015b4:	83 f8 09             	cmp    $0x9,%eax
  8015b7:	77 1e                	ja     8015d7 <vprintfmt+0xc2>
  8015b9:	eb e9                	jmp    8015a4 <vprintfmt+0x8f>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8015bb:	8b 55 14             	mov    0x14(%ebp),%edx
  8015be:	8d 42 04             	lea    0x4(%edx),%eax
  8015c1:	89 45 14             	mov    %eax,0x14(%ebp)
  8015c4:	8b 3a                	mov    (%edx),%edi
  8015c6:	eb 0f                	jmp    8015d7 <vprintfmt+0xc2>
			goto process_precision;

		case '.':
			if (width < 0)
  8015c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8015cc:	79 9c                	jns    80156a <vprintfmt+0x55>
  8015ce:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8015d5:	eb 93                	jmp    80156a <vprintfmt+0x55>
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8015d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8015db:	90                   	nop    
  8015dc:	8d 74 26 00          	lea    0x0(%esi),%esi
  8015e0:	79 88                	jns    80156a <vprintfmt+0x55>
  8015e2:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8015e5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8015ea:	e9 7b ff ff ff       	jmp    80156a <vprintfmt+0x55>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8015ef:	83 c1 01             	add    $0x1,%ecx
  8015f2:	e9 73 ff ff ff       	jmp    80156a <vprintfmt+0x55>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8015f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8015fa:	8d 50 04             	lea    0x4(%eax),%edx
  8015fd:	89 55 14             	mov    %edx,0x14(%ebp)
  801600:	8b 55 0c             	mov    0xc(%ebp),%edx
  801603:	89 54 24 04          	mov    %edx,0x4(%esp)
  801607:	8b 00                	mov    (%eax),%eax
  801609:	89 04 24             	mov    %eax,(%esp)
  80160c:	ff 55 08             	call   *0x8(%ebp)
  80160f:	e9 27 ff ff ff       	jmp    80153b <vprintfmt+0x26>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801614:	8b 55 14             	mov    0x14(%ebp),%edx
  801617:	8d 42 04             	lea    0x4(%edx),%eax
  80161a:	89 45 14             	mov    %eax,0x14(%ebp)
  80161d:	8b 02                	mov    (%edx),%eax
  80161f:	89 c2                	mov    %eax,%edx
  801621:	c1 fa 1f             	sar    $0x1f,%edx
  801624:	31 d0                	xor    %edx,%eax
  801626:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  801628:	83 f8 0f             	cmp    $0xf,%eax
  80162b:	7f 0b                	jg     801638 <vprintfmt+0x123>
  80162d:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  801634:	85 d2                	test   %edx,%edx
  801636:	75 23                	jne    80165b <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  801638:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80163c:	c7 44 24 08 b0 23 80 	movl   $0x8023b0,0x8(%esp)
  801643:	00 
  801644:	8b 45 0c             	mov    0xc(%ebp),%eax
  801647:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164b:	8b 55 08             	mov    0x8(%ebp),%edx
  80164e:	89 14 24             	mov    %edx,(%esp)
  801651:	e8 ff 02 00 00       	call   801955 <printfmt>
  801656:	e9 e0 fe ff ff       	jmp    80153b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80165b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80165f:	c7 44 24 08 5a 23 80 	movl   $0x80235a,0x8(%esp)
  801666:	00 
  801667:	8b 45 0c             	mov    0xc(%ebp),%eax
  80166a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166e:	8b 55 08             	mov    0x8(%ebp),%edx
  801671:	89 14 24             	mov    %edx,(%esp)
  801674:	e8 dc 02 00 00       	call   801955 <printfmt>
  801679:	e9 bd fe ff ff       	jmp    80153b <vprintfmt+0x26>
  80167e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801681:	89 f9                	mov    %edi,%ecx
  801683:	89 5d ec             	mov    %ebx,-0x14(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801686:	8b 55 14             	mov    0x14(%ebp),%edx
  801689:	8d 42 04             	lea    0x4(%edx),%eax
  80168c:	89 45 14             	mov    %eax,0x14(%ebp)
  80168f:	8b 12                	mov    (%edx),%edx
  801691:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801694:	85 d2                	test   %edx,%edx
  801696:	75 07                	jne    80169f <vprintfmt+0x18a>
  801698:	c7 45 dc b9 23 80 00 	movl   $0x8023b9,-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80169f:	85 f6                	test   %esi,%esi
  8016a1:	7e 41                	jle    8016e4 <vprintfmt+0x1cf>
  8016a3:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  8016a7:	74 3b                	je     8016e4 <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
  8016a9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8016b0:	89 04 24             	mov    %eax,(%esp)
  8016b3:	e8 e8 02 00 00       	call   8019a0 <strnlen>
  8016b8:	29 c6                	sub    %eax,%esi
  8016ba:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8016bd:	85 f6                	test   %esi,%esi
  8016bf:	7e 23                	jle    8016e4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8016c1:	0f be 55 eb          	movsbl -0x15(%ebp),%edx
  8016c5:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8016c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016cf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8016d2:	89 14 24             	mov    %edx,(%esp)
  8016d5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8016d8:	83 ee 01             	sub    $0x1,%esi
  8016db:	75 eb                	jne    8016c8 <vprintfmt+0x1b3>
  8016dd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8016e4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8016e7:	0f b6 02             	movzbl (%edx),%eax
  8016ea:	0f be d0             	movsbl %al,%edx
  8016ed:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8016f0:	84 c0                	test   %al,%al
  8016f2:	75 42                	jne    801736 <vprintfmt+0x221>
  8016f4:	eb 49                	jmp    80173f <vprintfmt+0x22a>
				if (altflag && (ch < ' ' || ch > '~'))
  8016f6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8016fa:	74 1b                	je     801717 <vprintfmt+0x202>
  8016fc:	8d 42 e0             	lea    -0x20(%edx),%eax
  8016ff:	83 f8 5e             	cmp    $0x5e,%eax
  801702:	76 13                	jbe    801717 <vprintfmt+0x202>
					putch('?', putdat);
  801704:	8b 45 0c             	mov    0xc(%ebp),%eax
  801707:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801712:	ff 55 08             	call   *0x8(%ebp)
  801715:	eb 0d                	jmp    801724 <vprintfmt+0x20f>
				else
					putch(ch, putdat);
  801717:	8b 45 0c             	mov    0xc(%ebp),%eax
  80171a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80171e:	89 14 24             	mov    %edx,(%esp)
  801721:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801724:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  801728:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80172c:	83 c6 01             	add    $0x1,%esi
  80172f:	84 c0                	test   %al,%al
  801731:	74 0c                	je     80173f <vprintfmt+0x22a>
  801733:	0f be d0             	movsbl %al,%edx
  801736:	85 ff                	test   %edi,%edi
  801738:	78 bc                	js     8016f6 <vprintfmt+0x1e1>
  80173a:	83 ef 01             	sub    $0x1,%edi
  80173d:	79 b7                	jns    8016f6 <vprintfmt+0x1e1>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80173f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801743:	0f 8e f2 fd ff ff    	jle    80153b <vprintfmt+0x26>
				putch(' ', putdat);
  801749:	8b 55 0c             	mov    0xc(%ebp),%edx
  80174c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801750:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801757:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80175a:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  80175e:	75 e9                	jne    801749 <vprintfmt+0x234>
  801760:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  801763:	e9 d3 fd ff ff       	jmp    80153b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801768:	83 f9 01             	cmp    $0x1,%ecx
  80176b:	90                   	nop    
  80176c:	8d 74 26 00          	lea    0x0(%esi),%esi
  801770:	7e 10                	jle    801782 <vprintfmt+0x26d>
		return va_arg(*ap, long long);
  801772:	8b 55 14             	mov    0x14(%ebp),%edx
  801775:	8d 42 08             	lea    0x8(%edx),%eax
  801778:	89 45 14             	mov    %eax,0x14(%ebp)
  80177b:	8b 32                	mov    (%edx),%esi
  80177d:	8b 7a 04             	mov    0x4(%edx),%edi
  801780:	eb 2a                	jmp    8017ac <vprintfmt+0x297>
	else if (lflag)
  801782:	85 c9                	test   %ecx,%ecx
  801784:	74 14                	je     80179a <vprintfmt+0x285>
		return va_arg(*ap, long);
  801786:	8b 45 14             	mov    0x14(%ebp),%eax
  801789:	8d 50 04             	lea    0x4(%eax),%edx
  80178c:	89 55 14             	mov    %edx,0x14(%ebp)
  80178f:	8b 00                	mov    (%eax),%eax
  801791:	89 c6                	mov    %eax,%esi
  801793:	89 c7                	mov    %eax,%edi
  801795:	c1 ff 1f             	sar    $0x1f,%edi
  801798:	eb 12                	jmp    8017ac <vprintfmt+0x297>
	else
		return va_arg(*ap, int);
  80179a:	8b 45 14             	mov    0x14(%ebp),%eax
  80179d:	8d 50 04             	lea    0x4(%eax),%edx
  8017a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8017a3:	8b 00                	mov    (%eax),%eax
  8017a5:	89 c6                	mov    %eax,%esi
  8017a7:	89 c7                	mov    %eax,%edi
  8017a9:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8017ac:	89 f2                	mov    %esi,%edx
  8017ae:	89 f9                	mov    %edi,%ecx
  8017b0:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
			if ((long long) num < 0) {
  8017b7:	85 ff                	test   %edi,%edi
  8017b9:	0f 89 9b 00 00 00    	jns    80185a <vprintfmt+0x345>
				putch('-', putdat);
  8017bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8017cd:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8017d0:	89 f2                	mov    %esi,%edx
  8017d2:	89 f9                	mov    %edi,%ecx
  8017d4:	f7 da                	neg    %edx
  8017d6:	83 d1 00             	adc    $0x0,%ecx
  8017d9:	f7 d9                	neg    %ecx
  8017db:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  8017e2:	eb 76                	jmp    80185a <vprintfmt+0x345>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8017e4:	89 ca                	mov    %ecx,%edx
  8017e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8017e9:	e8 cd fc ff ff       	call   8014bb <getuint>
  8017ee:	89 d1                	mov    %edx,%ecx
  8017f0:	89 c2                	mov    %eax,%edx
  8017f2:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  8017f9:	eb 5f                	jmp    80185a <vprintfmt+0x345>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap,lflag);
  8017fb:	89 ca                	mov    %ecx,%edx
  8017fd:	8d 45 14             	lea    0x14(%ebp),%eax
  801800:	e8 b6 fc ff ff       	call   8014bb <getuint>
  801805:	e9 31 fd ff ff       	jmp    80153b <vprintfmt+0x26>
			base=8;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80180a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80180d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801811:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801818:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80181b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80181e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801822:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801829:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  80182c:	8b 55 14             	mov    0x14(%ebp),%edx
  80182f:	8d 42 04             	lea    0x4(%edx),%eax
  801832:	89 45 14             	mov    %eax,0x14(%ebp)
  801835:	8b 12                	mov    (%edx),%edx
  801837:	b9 00 00 00 00       	mov    $0x0,%ecx
  80183c:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  801843:	eb 15                	jmp    80185a <vprintfmt+0x345>
			base = 16;
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801845:	89 ca                	mov    %ecx,%edx
  801847:	8d 45 14             	lea    0x14(%ebp),%eax
  80184a:	e8 6c fc ff ff       	call   8014bb <getuint>
  80184f:	89 d1                	mov    %edx,%ecx
  801851:	89 c2                	mov    %eax,%edx
  801853:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80185a:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  80185e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801862:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801865:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801869:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80186c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801870:	89 14 24             	mov    %edx,(%esp)
  801873:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801877:	8b 55 0c             	mov    0xc(%ebp),%edx
  80187a:	8b 45 08             	mov    0x8(%ebp),%eax
  80187d:	e8 4e fb ff ff       	call   8013d0 <printnum>
  801882:	e9 b4 fc ff ff       	jmp    80153b <vprintfmt+0x26>
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801887:	8b 55 0c             	mov    0xc(%ebp),%edx
  80188a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80188e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801895:	ff 55 08             	call   *0x8(%ebp)
  801898:	e9 9e fc ff ff       	jmp    80153b <vprintfmt+0x26>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80189d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8018ab:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8018ae:	83 eb 01             	sub    $0x1,%ebx
  8018b1:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8018b5:	0f 84 80 fc ff ff    	je     80153b <vprintfmt+0x26>
  8018bb:	83 eb 01             	sub    $0x1,%ebx
  8018be:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8018c2:	0f 84 73 fc ff ff    	je     80153b <vprintfmt+0x26>
  8018c8:	eb f1                	jmp    8018bb <vprintfmt+0x3a6>
				/* do nothing */;
			break;
		}
	}
}
  8018ca:	83 c4 3c             	add    $0x3c,%esp
  8018cd:	5b                   	pop    %ebx
  8018ce:	5e                   	pop    %esi
  8018cf:	5f                   	pop    %edi
  8018d0:	5d                   	pop    %ebp
  8018d1:	c3                   	ret    

008018d2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8018d2:	55                   	push   %ebp
  8018d3:	89 e5                	mov    %esp,%ebp
  8018d5:	83 ec 28             	sub    $0x28,%esp
  8018d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8018db:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8018de:	85 d2                	test   %edx,%edx
  8018e0:	74 04                	je     8018e6 <vsnprintf+0x14>
  8018e2:	85 c0                	test   %eax,%eax
  8018e4:	7f 07                	jg     8018ed <vsnprintf+0x1b>
  8018e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018eb:	eb 3b                	jmp    801928 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8018ed:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8018f4:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
  8018f8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  8018fb:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8018fe:	8b 45 14             	mov    0x14(%ebp),%eax
  801901:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801905:	8b 45 10             	mov    0x10(%ebp),%eax
  801908:	89 44 24 08          	mov    %eax,0x8(%esp)
  80190c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80190f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801913:	c7 04 24 f7 14 80 00 	movl   $0x8014f7,(%esp)
  80191a:	e8 f6 fb ff ff       	call   801515 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80191f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801922:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801925:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  801928:	c9                   	leave  
  801929:	c3                   	ret    

0080192a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80192a:	55                   	push   %ebp
  80192b:	89 e5                	mov    %esp,%ebp
  80192d:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801930:	8d 45 14             	lea    0x14(%ebp),%eax
  801933:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  801936:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80193a:	8b 45 10             	mov    0x10(%ebp),%eax
  80193d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801941:	8b 45 0c             	mov    0xc(%ebp),%eax
  801944:	89 44 24 04          	mov    %eax,0x4(%esp)
  801948:	8b 45 08             	mov    0x8(%ebp),%eax
  80194b:	89 04 24             	mov    %eax,(%esp)
  80194e:	e8 7f ff ff ff       	call   8018d2 <vsnprintf>
	va_end(ap);

	return rc;
}
  801953:	c9                   	leave  
  801954:	c3                   	ret    

00801955 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  80195b:	8d 45 14             	lea    0x14(%ebp),%eax
  80195e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  801961:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801965:	8b 45 10             	mov    0x10(%ebp),%eax
  801968:	89 44 24 08          	mov    %eax,0x8(%esp)
  80196c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801973:	8b 45 08             	mov    0x8(%ebp),%eax
  801976:	89 04 24             	mov    %eax,(%esp)
  801979:	e8 97 fb ff ff       	call   801515 <vprintfmt>
	va_end(ap);
}
  80197e:	c9                   	leave  
  80197f:	c3                   	ret    

00801980 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801986:	b8 00 00 00 00       	mov    $0x0,%eax
  80198b:	80 3a 00             	cmpb   $0x0,(%edx)
  80198e:	74 0e                	je     80199e <strlen+0x1e>
  801990:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801995:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801998:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  80199c:	75 f7                	jne    801995 <strlen+0x15>
		n++;
	return n;
}
  80199e:	5d                   	pop    %ebp
  80199f:	c3                   	ret    

008019a0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019a6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019a9:	85 d2                	test   %edx,%edx
  8019ab:	74 19                	je     8019c6 <strnlen+0x26>
  8019ad:	80 39 00             	cmpb   $0x0,(%ecx)
  8019b0:	74 14                	je     8019c6 <strnlen+0x26>
  8019b2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8019b7:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019ba:	39 d0                	cmp    %edx,%eax
  8019bc:	74 0d                	je     8019cb <strnlen+0x2b>
  8019be:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  8019c2:	74 07                	je     8019cb <strnlen+0x2b>
  8019c4:	eb f1                	jmp    8019b7 <strnlen+0x17>
  8019c6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8019cb:	5d                   	pop    %ebp
  8019cc:	8d 74 26 00          	lea    0x0(%esi),%esi
  8019d0:	c3                   	ret    

008019d1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8019d1:	55                   	push   %ebp
  8019d2:	89 e5                	mov    %esp,%ebp
  8019d4:	53                   	push   %ebx
  8019d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8019d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019db:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8019dd:	0f b6 01             	movzbl (%ecx),%eax
  8019e0:	88 02                	mov    %al,(%edx)
  8019e2:	83 c2 01             	add    $0x1,%edx
  8019e5:	83 c1 01             	add    $0x1,%ecx
  8019e8:	84 c0                	test   %al,%al
  8019ea:	75 f1                	jne    8019dd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8019ec:	89 d8                	mov    %ebx,%eax
  8019ee:	5b                   	pop    %ebx
  8019ef:	5d                   	pop    %ebp
  8019f0:	c3                   	ret    

008019f1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
  8019f4:	57                   	push   %edi
  8019f5:	56                   	push   %esi
  8019f6:	53                   	push   %ebx
  8019f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019fd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a00:	85 f6                	test   %esi,%esi
  801a02:	74 1c                	je     801a20 <strncpy+0x2f>
  801a04:	89 fa                	mov    %edi,%edx
  801a06:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  801a0b:	0f b6 01             	movzbl (%ecx),%eax
  801a0e:	88 02                	mov    %al,(%edx)
  801a10:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801a13:	80 39 01             	cmpb   $0x1,(%ecx)
  801a16:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a19:	83 c3 01             	add    $0x1,%ebx
  801a1c:	39 f3                	cmp    %esi,%ebx
  801a1e:	75 eb                	jne    801a0b <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801a20:	89 f8                	mov    %edi,%eax
  801a22:	5b                   	pop    %ebx
  801a23:	5e                   	pop    %esi
  801a24:	5f                   	pop    %edi
  801a25:	5d                   	pop    %ebp
  801a26:	c3                   	ret    

00801a27 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801a27:	55                   	push   %ebp
  801a28:	89 e5                	mov    %esp,%ebp
  801a2a:	56                   	push   %esi
  801a2b:	53                   	push   %ebx
  801a2c:	8b 75 08             	mov    0x8(%ebp),%esi
  801a2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a32:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801a35:	89 f0                	mov    %esi,%eax
  801a37:	85 d2                	test   %edx,%edx
  801a39:	74 2c                	je     801a67 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  801a3b:	89 d3                	mov    %edx,%ebx
  801a3d:	83 eb 01             	sub    $0x1,%ebx
  801a40:	74 20                	je     801a62 <strlcpy+0x3b>
  801a42:	0f b6 11             	movzbl (%ecx),%edx
  801a45:	84 d2                	test   %dl,%dl
  801a47:	74 19                	je     801a62 <strlcpy+0x3b>
  801a49:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  801a4b:	88 10                	mov    %dl,(%eax)
  801a4d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801a50:	83 eb 01             	sub    $0x1,%ebx
  801a53:	74 0f                	je     801a64 <strlcpy+0x3d>
  801a55:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  801a59:	83 c1 01             	add    $0x1,%ecx
  801a5c:	84 d2                	test   %dl,%dl
  801a5e:	74 04                	je     801a64 <strlcpy+0x3d>
  801a60:	eb e9                	jmp    801a4b <strlcpy+0x24>
  801a62:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801a64:	c6 00 00             	movb   $0x0,(%eax)
  801a67:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  801a69:	5b                   	pop    %ebx
  801a6a:	5e                   	pop    %esi
  801a6b:	5d                   	pop    %ebp
  801a6c:	c3                   	ret    

00801a6d <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	56                   	push   %esi
  801a71:	53                   	push   %ebx
  801a72:	8b 75 08             	mov    0x8(%ebp),%esi
  801a75:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a78:	8b 55 10             	mov    0x10(%ebp),%edx
    int c;
    char *q = buf;

    if (buf_size <= 0)
  801a7b:	85 c0                	test   %eax,%eax
  801a7d:	7e 2e                	jle    801aad <pstrcpy+0x40>
        return;

    for(;;) {
        c = *str++;
  801a7f:	0f b6 0a             	movzbl (%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  801a82:	84 c9                	test   %cl,%cl
  801a84:	74 22                	je     801aa8 <pstrcpy+0x3b>
  801a86:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  801a8a:	89 f0                	mov    %esi,%eax
  801a8c:	39 de                	cmp    %ebx,%esi
  801a8e:	72 09                	jb     801a99 <pstrcpy+0x2c>
  801a90:	eb 16                	jmp    801aa8 <pstrcpy+0x3b>
  801a92:	83 c2 01             	add    $0x1,%edx
  801a95:	39 d8                	cmp    %ebx,%eax
  801a97:	73 11                	jae    801aaa <pstrcpy+0x3d>
            break;
        *q++ = c;
  801a99:	88 08                	mov    %cl,(%eax)
  801a9b:	83 c0 01             	add    $0x1,%eax

    if (buf_size <= 0)
        return;

    for(;;) {
        c = *str++;
  801a9e:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  801aa2:	84 c9                	test   %cl,%cl
  801aa4:	75 ec                	jne    801a92 <pstrcpy+0x25>
  801aa6:	eb 02                	jmp    801aaa <pstrcpy+0x3d>
  801aa8:	89 f0                	mov    %esi,%eax
            break;
        *q++ = c;
    }
    *q = '\0';
  801aaa:	c6 00 00             	movb   $0x0,(%eax)
}
  801aad:	5b                   	pop    %ebx
  801aae:	5e                   	pop    %esi
  801aaf:	5d                   	pop    %ebp
  801ab0:	c3                   	ret    

00801ab1 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  801ab1:	55                   	push   %ebp
  801ab2:	89 e5                	mov    %esp,%ebp
  801ab4:	8b 55 08             	mov    0x8(%ebp),%edx
  801ab7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  801aba:	0f b6 02             	movzbl (%edx),%eax
  801abd:	84 c0                	test   %al,%al
  801abf:	74 16                	je     801ad7 <strcmp+0x26>
  801ac1:	3a 01                	cmp    (%ecx),%al
  801ac3:	75 12                	jne    801ad7 <strcmp+0x26>
		p++, q++;
  801ac5:	83 c1 01             	add    $0x1,%ecx
    *q = '\0';
}
int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801ac8:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  801acc:	84 c0                	test   %al,%al
  801ace:	74 07                	je     801ad7 <strcmp+0x26>
  801ad0:	83 c2 01             	add    $0x1,%edx
  801ad3:	3a 01                	cmp    (%ecx),%al
  801ad5:	74 ee                	je     801ac5 <strcmp+0x14>
  801ad7:	0f b6 c0             	movzbl %al,%eax
  801ada:	0f b6 11             	movzbl (%ecx),%edx
  801add:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801adf:	5d                   	pop    %ebp
  801ae0:	c3                   	ret    

00801ae1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	53                   	push   %ebx
  801ae5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ae8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801aeb:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801aee:	85 d2                	test   %edx,%edx
  801af0:	74 2d                	je     801b1f <strncmp+0x3e>
  801af2:	0f b6 01             	movzbl (%ecx),%eax
  801af5:	84 c0                	test   %al,%al
  801af7:	74 1a                	je     801b13 <strncmp+0x32>
  801af9:	3a 03                	cmp    (%ebx),%al
  801afb:	75 16                	jne    801b13 <strncmp+0x32>
  801afd:	83 ea 01             	sub    $0x1,%edx
  801b00:	74 1d                	je     801b1f <strncmp+0x3e>
		n--, p++, q++;
  801b02:	83 c1 01             	add    $0x1,%ecx
  801b05:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801b08:	0f b6 01             	movzbl (%ecx),%eax
  801b0b:	84 c0                	test   %al,%al
  801b0d:	74 04                	je     801b13 <strncmp+0x32>
  801b0f:	3a 03                	cmp    (%ebx),%al
  801b11:	74 ea                	je     801afd <strncmp+0x1c>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801b13:	0f b6 11             	movzbl (%ecx),%edx
  801b16:	0f b6 03             	movzbl (%ebx),%eax
  801b19:	29 c2                	sub    %eax,%edx
  801b1b:	89 d0                	mov    %edx,%eax
  801b1d:	eb 05                	jmp    801b24 <strncmp+0x43>
  801b1f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b24:	5b                   	pop    %ebx
  801b25:	5d                   	pop    %ebp
  801b26:	c3                   	ret    

00801b27 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b31:	0f b6 10             	movzbl (%eax),%edx
  801b34:	84 d2                	test   %dl,%dl
  801b36:	74 14                	je     801b4c <strchr+0x25>
		if (*s == c)
  801b38:	38 ca                	cmp    %cl,%dl
  801b3a:	75 06                	jne    801b42 <strchr+0x1b>
  801b3c:	eb 13                	jmp    801b51 <strchr+0x2a>
  801b3e:	38 ca                	cmp    %cl,%dl
  801b40:	74 0f                	je     801b51 <strchr+0x2a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801b42:	83 c0 01             	add    $0x1,%eax
  801b45:	0f b6 10             	movzbl (%eax),%edx
  801b48:	84 d2                	test   %dl,%dl
  801b4a:	75 f2                	jne    801b3e <strchr+0x17>
  801b4c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  801b51:	5d                   	pop    %ebp
  801b52:	c3                   	ret    

00801b53 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	8b 45 08             	mov    0x8(%ebp),%eax
  801b59:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b5d:	0f b6 10             	movzbl (%eax),%edx
  801b60:	84 d2                	test   %dl,%dl
  801b62:	74 18                	je     801b7c <strfind+0x29>
		if (*s == c)
  801b64:	38 ca                	cmp    %cl,%dl
  801b66:	75 0a                	jne    801b72 <strfind+0x1f>
  801b68:	eb 12                	jmp    801b7c <strfind+0x29>
  801b6a:	38 ca                	cmp    %cl,%dl
  801b6c:	8d 74 26 00          	lea    0x0(%esi),%esi
  801b70:	74 0a                	je     801b7c <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801b72:	83 c0 01             	add    $0x1,%eax
  801b75:	0f b6 10             	movzbl (%eax),%edx
  801b78:	84 d2                	test   %dl,%dl
  801b7a:	75 ee                	jne    801b6a <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  801b7c:	5d                   	pop    %ebp
  801b7d:	c3                   	ret    

00801b7e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	83 ec 08             	sub    $0x8,%esp
  801b84:	89 1c 24             	mov    %ebx,(%esp)
  801b87:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b8b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  801b91:	85 db                	test   %ebx,%ebx
  801b93:	74 36                	je     801bcb <memset+0x4d>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b95:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b9b:	75 26                	jne    801bc3 <memset+0x45>
  801b9d:	f6 c3 03             	test   $0x3,%bl
  801ba0:	75 21                	jne    801bc3 <memset+0x45>
		c &= 0xFF;
  801ba2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801ba6:	89 d0                	mov    %edx,%eax
  801ba8:	c1 e0 18             	shl    $0x18,%eax
  801bab:	89 d1                	mov    %edx,%ecx
  801bad:	c1 e1 10             	shl    $0x10,%ecx
  801bb0:	09 c8                	or     %ecx,%eax
  801bb2:	09 d0                	or     %edx,%eax
  801bb4:	c1 e2 08             	shl    $0x8,%edx
  801bb7:	09 d0                	or     %edx,%eax
  801bb9:	89 d9                	mov    %ebx,%ecx
  801bbb:	c1 e9 02             	shr    $0x2,%ecx
  801bbe:	fc                   	cld    
  801bbf:	f3 ab                	rep stos %eax,%es:(%edi)
  801bc1:	eb 08                	jmp    801bcb <memset+0x4d>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801bc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bc6:	89 d9                	mov    %ebx,%ecx
  801bc8:	fc                   	cld    
  801bc9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801bcb:	89 f8                	mov    %edi,%eax
  801bcd:	8b 1c 24             	mov    (%esp),%ebx
  801bd0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801bd4:	89 ec                	mov    %ebp,%esp
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    

00801bd8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	83 ec 08             	sub    $0x8,%esp
  801bde:	89 34 24             	mov    %esi,(%esp)
  801be1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801be5:	8b 45 08             	mov    0x8(%ebp),%eax
  801be8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  801beb:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  801bee:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  801bf0:	39 c6                	cmp    %eax,%esi
  801bf2:	73 38                	jae    801c2c <memmove+0x54>
  801bf4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801bf7:	39 d0                	cmp    %edx,%eax
  801bf9:	73 31                	jae    801c2c <memmove+0x54>
		s += n;
		d += n;
  801bfb:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bfe:	f6 c2 03             	test   $0x3,%dl
  801c01:	75 1d                	jne    801c20 <memmove+0x48>
  801c03:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801c09:	75 15                	jne    801c20 <memmove+0x48>
  801c0b:	f6 c1 03             	test   $0x3,%cl
  801c0e:	66 90                	xchg   %ax,%ax
  801c10:	75 0e                	jne    801c20 <memmove+0x48>
			asm volatile("std; rep movsl\n"
  801c12:	8d 7e fc             	lea    -0x4(%esi),%edi
  801c15:	8d 72 fc             	lea    -0x4(%edx),%esi
  801c18:	c1 e9 02             	shr    $0x2,%ecx
  801c1b:	fd                   	std    
  801c1c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801c1e:	eb 09                	jmp    801c29 <memmove+0x51>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801c20:	8d 7e ff             	lea    -0x1(%esi),%edi
  801c23:	8d 72 ff             	lea    -0x1(%edx),%esi
  801c26:	fd                   	std    
  801c27:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801c29:	fc                   	cld    
  801c2a:	eb 21                	jmp    801c4d <memmove+0x75>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801c2c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801c32:	75 16                	jne    801c4a <memmove+0x72>
  801c34:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801c3a:	75 0e                	jne    801c4a <memmove+0x72>
  801c3c:	f6 c1 03             	test   $0x3,%cl
  801c3f:	90                   	nop    
  801c40:	75 08                	jne    801c4a <memmove+0x72>
			asm volatile("cld; rep movsl\n"
  801c42:	c1 e9 02             	shr    $0x2,%ecx
  801c45:	fc                   	cld    
  801c46:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801c48:	eb 03                	jmp    801c4d <memmove+0x75>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801c4a:	fc                   	cld    
  801c4b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801c4d:	8b 34 24             	mov    (%esp),%esi
  801c50:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801c54:	89 ec                	mov    %ebp,%esp
  801c56:	5d                   	pop    %ebp
  801c57:	c3                   	ret    

00801c58 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801c58:	55                   	push   %ebp
  801c59:	89 e5                	mov    %esp,%ebp
  801c5b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801c5e:	8b 45 10             	mov    0x10(%ebp),%eax
  801c61:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c65:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c68:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6f:	89 04 24             	mov    %eax,(%esp)
  801c72:	e8 61 ff ff ff       	call   801bd8 <memmove>
}
  801c77:	c9                   	leave  
  801c78:	c3                   	ret    

00801c79 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
  801c7c:	57                   	push   %edi
  801c7d:	56                   	push   %esi
  801c7e:	53                   	push   %ebx
  801c7f:	83 ec 04             	sub    $0x4,%esp
  801c82:	8b 45 08             	mov    0x8(%ebp),%eax
  801c85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c88:	8b 55 10             	mov    0x10(%ebp),%edx
  801c8b:	83 ea 01             	sub    $0x1,%edx
  801c8e:	83 fa ff             	cmp    $0xffffffff,%edx
  801c91:	74 47                	je     801cda <memcmp+0x61>
		if (*s1 != *s2)
  801c93:	0f b6 30             	movzbl (%eax),%esi
  801c96:	0f b6 39             	movzbl (%ecx),%edi
			return (int) *s1 - (int) *s2;
  801c99:	89 45 f0             	mov    %eax,-0x10(%ebp)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  801c9c:	89 f0                	mov    %esi,%eax
  801c9e:	89 fb                	mov    %edi,%ebx
  801ca0:	38 d8                	cmp    %bl,%al
  801ca2:	74 2e                	je     801cd2 <memcmp+0x59>
  801ca4:	eb 1c                	jmp    801cc2 <memcmp+0x49>
  801ca6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ca9:	0f b6 70 01          	movzbl 0x1(%eax),%esi
  801cad:	0f b6 79 01          	movzbl 0x1(%ecx),%edi
  801cb1:	83 c0 01             	add    $0x1,%eax
  801cb4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801cb7:	83 c1 01             	add    $0x1,%ecx
  801cba:	89 f3                	mov    %esi,%ebx
  801cbc:	89 f8                	mov    %edi,%eax
  801cbe:	38 c3                	cmp    %al,%bl
  801cc0:	74 10                	je     801cd2 <memcmp+0x59>
			return (int) *s1 - (int) *s2;
  801cc2:	89 f1                	mov    %esi,%ecx
  801cc4:	0f b6 d1             	movzbl %cl,%edx
  801cc7:	89 fb                	mov    %edi,%ebx
  801cc9:	0f b6 c3             	movzbl %bl,%eax
  801ccc:	29 c2                	sub    %eax,%edx
  801cce:	89 d0                	mov    %edx,%eax
  801cd0:	eb 0d                	jmp    801cdf <memcmp+0x66>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801cd2:	83 ea 01             	sub    $0x1,%edx
  801cd5:	83 fa ff             	cmp    $0xffffffff,%edx
  801cd8:	75 cc                	jne    801ca6 <memcmp+0x2d>
  801cda:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  801cdf:	83 c4 04             	add    $0x4,%esp
  801ce2:	5b                   	pop    %ebx
  801ce3:	5e                   	pop    %esi
  801ce4:	5f                   	pop    %edi
  801ce5:	5d                   	pop    %ebp
  801ce6:	c3                   	ret    

00801ce7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801ce7:	55                   	push   %ebp
  801ce8:	89 e5                	mov    %esp,%ebp
  801cea:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801ced:	89 c1                	mov    %eax,%ecx
  801cef:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
  801cf2:	39 c8                	cmp    %ecx,%eax
  801cf4:	73 15                	jae    801d0b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  801cf6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
  801cfa:	38 10                	cmp    %dl,(%eax)
  801cfc:	75 06                	jne    801d04 <memfind+0x1d>
  801cfe:	eb 0b                	jmp    801d0b <memfind+0x24>
  801d00:	38 10                	cmp    %dl,(%eax)
  801d02:	74 07                	je     801d0b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d04:	83 c0 01             	add    $0x1,%eax
  801d07:	39 c8                	cmp    %ecx,%eax
  801d09:	75 f5                	jne    801d00 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801d0b:	5d                   	pop    %ebp
  801d0c:	8d 74 26 00          	lea    0x0(%esi),%esi
  801d10:	c3                   	ret    

00801d11 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801d11:	55                   	push   %ebp
  801d12:	89 e5                	mov    %esp,%ebp
  801d14:	57                   	push   %edi
  801d15:	56                   	push   %esi
  801d16:	53                   	push   %ebx
  801d17:	83 ec 04             	sub    $0x4,%esp
  801d1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d1d:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801d20:	0f b6 01             	movzbl (%ecx),%eax
  801d23:	3c 20                	cmp    $0x20,%al
  801d25:	74 04                	je     801d2b <strtol+0x1a>
  801d27:	3c 09                	cmp    $0x9,%al
  801d29:	75 0e                	jne    801d39 <strtol+0x28>
		s++;
  801d2b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801d2e:	0f b6 01             	movzbl (%ecx),%eax
  801d31:	3c 20                	cmp    $0x20,%al
  801d33:	74 f6                	je     801d2b <strtol+0x1a>
  801d35:	3c 09                	cmp    $0x9,%al
  801d37:	74 f2                	je     801d2b <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801d39:	3c 2b                	cmp    $0x2b,%al
  801d3b:	75 0c                	jne    801d49 <strtol+0x38>
		s++;
  801d3d:	83 c1 01             	add    $0x1,%ecx
  801d40:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801d47:	eb 15                	jmp    801d5e <strtol+0x4d>
	else if (*s == '-')
  801d49:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801d50:	3c 2d                	cmp    $0x2d,%al
  801d52:	75 0a                	jne    801d5e <strtol+0x4d>
		s++, neg = 1;
  801d54:	83 c1 01             	add    $0x1,%ecx
  801d57:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801d5e:	85 f6                	test   %esi,%esi
  801d60:	0f 94 c0             	sete   %al
  801d63:	74 05                	je     801d6a <strtol+0x59>
  801d65:	83 fe 10             	cmp    $0x10,%esi
  801d68:	75 18                	jne    801d82 <strtol+0x71>
  801d6a:	80 39 30             	cmpb   $0x30,(%ecx)
  801d6d:	75 13                	jne    801d82 <strtol+0x71>
  801d6f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801d73:	75 0d                	jne    801d82 <strtol+0x71>
		s += 2, base = 16;
  801d75:	83 c1 02             	add    $0x2,%ecx
  801d78:	be 10 00 00 00       	mov    $0x10,%esi
  801d7d:	8d 76 00             	lea    0x0(%esi),%esi
  801d80:	eb 1b                	jmp    801d9d <strtol+0x8c>
	else if (base == 0 && s[0] == '0')
  801d82:	85 f6                	test   %esi,%esi
  801d84:	75 0e                	jne    801d94 <strtol+0x83>
  801d86:	80 39 30             	cmpb   $0x30,(%ecx)
  801d89:	75 09                	jne    801d94 <strtol+0x83>
		s++, base = 8;
  801d8b:	83 c1 01             	add    $0x1,%ecx
  801d8e:	66 be 08 00          	mov    $0x8,%si
  801d92:	eb 09                	jmp    801d9d <strtol+0x8c>
	else if (base == 0)
  801d94:	84 c0                	test   %al,%al
  801d96:	74 05                	je     801d9d <strtol+0x8c>
  801d98:	be 0a 00 00 00       	mov    $0xa,%esi
  801d9d:	bf 00 00 00 00       	mov    $0x0,%edi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801da2:	0f b6 11             	movzbl (%ecx),%edx
  801da5:	89 d3                	mov    %edx,%ebx
  801da7:	8d 42 d0             	lea    -0x30(%edx),%eax
  801daa:	3c 09                	cmp    $0x9,%al
  801dac:	77 08                	ja     801db6 <strtol+0xa5>
			dig = *s - '0';
  801dae:	0f be c2             	movsbl %dl,%eax
  801db1:	8d 50 d0             	lea    -0x30(%eax),%edx
  801db4:	eb 1c                	jmp    801dd2 <strtol+0xc1>
		else if (*s >= 'a' && *s <= 'z')
  801db6:	8d 43 9f             	lea    -0x61(%ebx),%eax
  801db9:	3c 19                	cmp    $0x19,%al
  801dbb:	77 08                	ja     801dc5 <strtol+0xb4>
			dig = *s - 'a' + 10;
  801dbd:	0f be c2             	movsbl %dl,%eax
  801dc0:	8d 50 a9             	lea    -0x57(%eax),%edx
  801dc3:	eb 0d                	jmp    801dd2 <strtol+0xc1>
		else if (*s >= 'A' && *s <= 'Z')
  801dc5:	8d 43 bf             	lea    -0x41(%ebx),%eax
  801dc8:	3c 19                	cmp    $0x19,%al
  801dca:	77 17                	ja     801de3 <strtol+0xd2>
			dig = *s - 'A' + 10;
  801dcc:	0f be c2             	movsbl %dl,%eax
  801dcf:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  801dd2:	39 f2                	cmp    %esi,%edx
  801dd4:	7d 0d                	jge    801de3 <strtol+0xd2>
			break;
		s++, val = (val * base) + dig;
  801dd6:	83 c1 01             	add    $0x1,%ecx
  801dd9:	89 f8                	mov    %edi,%eax
  801ddb:	0f af c6             	imul   %esi,%eax
  801dde:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  801de1:	eb bf                	jmp    801da2 <strtol+0x91>
		// we don't properly detect overflow!
	}
  801de3:	89 f8                	mov    %edi,%eax

	if (endptr)
  801de5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801de9:	74 05                	je     801df0 <strtol+0xdf>
		*endptr = (char *) s;
  801deb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dee:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  801df0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801df4:	74 04                	je     801dfa <strtol+0xe9>
  801df6:	89 c7                	mov    %eax,%edi
  801df8:	f7 df                	neg    %edi
}
  801dfa:	89 f8                	mov    %edi,%eax
  801dfc:	83 c4 04             	add    $0x4,%esp
  801dff:	5b                   	pop    %ebx
  801e00:	5e                   	pop    %esi
  801e01:	5f                   	pop    %edi
  801e02:	5d                   	pop    %ebp
  801e03:	c3                   	ret    
	...

00801e10 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	57                   	push   %edi
  801e14:	56                   	push   %esi
  801e15:	53                   	push   %ebx
  801e16:	83 ec 1c             	sub    $0x1c,%esp
  801e19:	8b 75 08             	mov    0x8(%ebp),%esi
  801e1c:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  801e1f:	e8 39 e6 ff ff       	call   80045d <sys_getenvid>
  801e24:	25 ff 03 00 00       	and    $0x3ff,%eax
  801e29:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e2c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e31:	a3 3c 60 80 00       	mov    %eax,0x80603c
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  801e36:	e8 22 e6 ff ff       	call   80045d <sys_getenvid>
  801e3b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801e40:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e43:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e48:	a3 3c 60 80 00       	mov    %eax,0x80603c
		if(env->env_id==to_env){
  801e4d:	8b 40 4c             	mov    0x4c(%eax),%eax
  801e50:	39 f0                	cmp    %esi,%eax
  801e52:	75 0e                	jne    801e62 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  801e54:	c7 04 24 a0 26 80 00 	movl   $0x8026a0,(%esp)
  801e5b:	e8 09 f5 ff ff       	call   801369 <cprintf>
  801e60:	eb 5a                	jmp    801ebc <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  801e62:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e66:	8b 45 10             	mov    0x10(%ebp),%eax
  801e69:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e70:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e74:	89 34 24             	mov    %esi,(%esp)
  801e77:	e8 40 e3 ff ff       	call   8001bc <sys_ipc_try_send>
  801e7c:	89 c3                	mov    %eax,%ebx
  801e7e:	85 c0                	test   %eax,%eax
  801e80:	79 25                	jns    801ea7 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  801e82:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e85:	74 2b                	je     801eb2 <ipc_send+0xa2>
				panic("send error:%e",r);
  801e87:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e8b:	c7 44 24 08 bc 26 80 	movl   $0x8026bc,0x8(%esp)
  801e92:	00 
  801e93:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  801e9a:	00 
  801e9b:	c7 04 24 ca 26 80 00 	movl   $0x8026ca,(%esp)
  801ea2:	e8 f5 f3 ff ff       	call   80129c <_panic>
		}
			sys_yield();
  801ea7:	e8 7d e5 ff ff       	call   800429 <sys_yield>
		
	}while(r!=0);
  801eac:	85 db                	test   %ebx,%ebx
  801eae:	75 86                	jne    801e36 <ipc_send+0x26>
  801eb0:	eb 0a                	jmp    801ebc <ipc_send+0xac>
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
		{	
			if(r!=-E_IPC_NOT_RECV)
				panic("send error:%e",r);
		}
			sys_yield();
  801eb2:	e8 72 e5 ff ff       	call   800429 <sys_yield>
  801eb7:	e9 7a ff ff ff       	jmp    801e36 <ipc_send+0x26>
		
	}while(r!=0);
	return;
	//panic("ipc_send not implemented");
}
  801ebc:	83 c4 1c             	add    $0x1c,%esp
  801ebf:	5b                   	pop    %ebx
  801ec0:	5e                   	pop    %esi
  801ec1:	5f                   	pop    %edi
  801ec2:	5d                   	pop    %ebp
  801ec3:	c3                   	ret    

00801ec4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
  801ec7:	57                   	push   %edi
  801ec8:	56                   	push   %esi
  801ec9:	53                   	push   %ebx
  801eca:	83 ec 0c             	sub    $0xc,%esp
  801ecd:	8b 75 08             	mov    0x8(%ebp),%esi
  801ed0:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	void *dstva=NULL;
	if(pg)
		dstva=pg;
	env = &envs[ENVX(sys_getenvid())];
  801ed3:	e8 85 e5 ff ff       	call   80045d <sys_getenvid>
  801ed8:	25 ff 03 00 00       	and    $0x3ff,%eax
  801edd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ee0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ee5:	a3 3c 60 80 00       	mov    %eax,0x80603c
	if(from_env_store&&(env->env_id==*from_env_store))
  801eea:	85 f6                	test   %esi,%esi
  801eec:	74 29                	je     801f17 <ipc_recv+0x53>
  801eee:	8b 40 4c             	mov    0x4c(%eax),%eax
  801ef1:	3b 06                	cmp    (%esi),%eax
  801ef3:	75 22                	jne    801f17 <ipc_recv+0x53>
	{
		*from_env_store=0;
  801ef5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  801efb:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("send:the reciver is sender\n");
  801f01:	c7 04 24 a0 26 80 00 	movl   $0x8026a0,(%esp)
  801f08:	e8 5c f4 ff ff       	call   801369 <cprintf>
  801f0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f12:	e9 8a 00 00 00       	jmp    801fa1 <ipc_recv+0xdd>
		return 0;
	}
	env = &envs[ENVX(sys_getenvid())];
  801f17:	e8 41 e5 ff ff       	call   80045d <sys_getenvid>
  801f1c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801f21:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f24:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f29:	a3 3c 60 80 00       	mov    %eax,0x80603c
	if((r=sys_ipc_recv(dstva))<0)
  801f2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f31:	89 04 24             	mov    %eax,(%esp)
  801f34:	e8 26 e2 ff ff       	call   80015f <sys_ipc_recv>
  801f39:	89 c3                	mov    %eax,%ebx
  801f3b:	85 c0                	test   %eax,%eax
  801f3d:	79 1a                	jns    801f59 <ipc_recv+0x95>
	{
		*from_env_store=0;
  801f3f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  801f45:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("reciver failed\n");
  801f4b:	c7 04 24 d4 26 80 00 	movl   $0x8026d4,(%esp)
  801f52:	e8 12 f4 ff ff       	call   801369 <cprintf>
  801f57:	eb 48                	jmp    801fa1 <ipc_recv+0xdd>
		return r;
	}
	else{//接收成功
		env = &envs[ENVX(sys_getenvid())];
  801f59:	e8 ff e4 ff ff       	call   80045d <sys_getenvid>
  801f5e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801f63:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f66:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f6b:	a3 3c 60 80 00       	mov    %eax,0x80603c
		if(from_env_store)
  801f70:	85 f6                	test   %esi,%esi
  801f72:	74 05                	je     801f79 <ipc_recv+0xb5>
			*from_env_store=env->env_ipc_from;	
  801f74:	8b 40 74             	mov    0x74(%eax),%eax
  801f77:	89 06                	mov    %eax,(%esi)
		if(perm_store)
  801f79:	85 ff                	test   %edi,%edi
  801f7b:	74 0a                	je     801f87 <ipc_recv+0xc3>
			*perm_store=env->env_ipc_perm;
  801f7d:	a1 3c 60 80 00       	mov    0x80603c,%eax
  801f82:	8b 40 78             	mov    0x78(%eax),%eax
  801f85:	89 07                	mov    %eax,(%edi)
		env = &envs[ENVX(sys_getenvid())];
  801f87:	e8 d1 e4 ff ff       	call   80045d <sys_getenvid>
  801f8c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801f91:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f94:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f99:	a3 3c 60 80 00       	mov    %eax,0x80603c
		return env->env_ipc_value;
  801f9e:	8b 58 70             	mov    0x70(%eax),%ebx
	}
	//panic("ipc_recv not implemented");
	return 0;
}
  801fa1:	89 d8                	mov    %ebx,%eax
  801fa3:	83 c4 0c             	add    $0xc,%esp
  801fa6:	5b                   	pop    %ebx
  801fa7:	5e                   	pop    %esi
  801fa8:	5f                   	pop    %edi
  801fa9:	5d                   	pop    %ebp
  801faa:	c3                   	ret    
  801fab:	00 00                	add    %al,(%eax)
  801fad:	00 00                	add    %al,(%eax)
	...

00801fb0 <__udivdi3>:
  801fb0:	55                   	push   %ebp
  801fb1:	89 e5                	mov    %esp,%ebp
  801fb3:	57                   	push   %edi
  801fb4:	56                   	push   %esi
  801fb5:	83 ec 18             	sub    $0x18,%esp
  801fb8:	8b 45 10             	mov    0x10(%ebp),%eax
  801fbb:	8b 55 14             	mov    0x14(%ebp),%edx
  801fbe:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801fc4:	89 c1                	mov    %eax,%ecx
  801fc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc9:	85 d2                	test   %edx,%edx
  801fcb:	89 d7                	mov    %edx,%edi
  801fcd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801fd0:	75 1e                	jne    801ff0 <__udivdi3+0x40>
  801fd2:	39 f1                	cmp    %esi,%ecx
  801fd4:	0f 86 8d 00 00 00    	jbe    802067 <__udivdi3+0xb7>
  801fda:	89 f2                	mov    %esi,%edx
  801fdc:	31 f6                	xor    %esi,%esi
  801fde:	f7 f1                	div    %ecx
  801fe0:	89 c1                	mov    %eax,%ecx
  801fe2:	89 c8                	mov    %ecx,%eax
  801fe4:	89 f2                	mov    %esi,%edx
  801fe6:	83 c4 18             	add    $0x18,%esp
  801fe9:	5e                   	pop    %esi
  801fea:	5f                   	pop    %edi
  801feb:	5d                   	pop    %ebp
  801fec:	c3                   	ret    
  801fed:	8d 76 00             	lea    0x0(%esi),%esi
  801ff0:	39 f2                	cmp    %esi,%edx
  801ff2:	0f 87 a8 00 00 00    	ja     8020a0 <__udivdi3+0xf0>
  801ff8:	0f bd c2             	bsr    %edx,%eax
  801ffb:	83 f0 1f             	xor    $0x1f,%eax
  801ffe:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802001:	0f 84 89 00 00 00    	je     802090 <__udivdi3+0xe0>
  802007:	b8 20 00 00 00       	mov    $0x20,%eax
  80200c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80200f:	2b 45 e8             	sub    -0x18(%ebp),%eax
  802012:	89 c1                	mov    %eax,%ecx
  802014:	d3 ea                	shr    %cl,%edx
  802016:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  80201a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80201d:	89 f8                	mov    %edi,%eax
  80201f:	8b 7d f4             	mov    -0xc(%ebp),%edi
  802022:	d3 e0                	shl    %cl,%eax
  802024:	09 c2                	or     %eax,%edx
  802026:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802029:	d3 e7                	shl    %cl,%edi
  80202b:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80202f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802032:	89 f2                	mov    %esi,%edx
  802034:	d3 e8                	shr    %cl,%eax
  802036:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  80203a:	d3 e2                	shl    %cl,%edx
  80203c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802040:	09 d0                	or     %edx,%eax
  802042:	d3 ee                	shr    %cl,%esi
  802044:	89 f2                	mov    %esi,%edx
  802046:	f7 75 e4             	divl   -0x1c(%ebp)
  802049:	89 d1                	mov    %edx,%ecx
  80204b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80204e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802051:	f7 e7                	mul    %edi
  802053:	39 d1                	cmp    %edx,%ecx
  802055:	89 c6                	mov    %eax,%esi
  802057:	72 70                	jb     8020c9 <__udivdi3+0x119>
  802059:	39 ca                	cmp    %ecx,%edx
  80205b:	74 5f                	je     8020bc <__udivdi3+0x10c>
  80205d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802060:	31 f6                	xor    %esi,%esi
  802062:	e9 7b ff ff ff       	jmp    801fe2 <__udivdi3+0x32>
  802067:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80206a:	85 c0                	test   %eax,%eax
  80206c:	75 0c                	jne    80207a <__udivdi3+0xca>
  80206e:	b8 01 00 00 00       	mov    $0x1,%eax
  802073:	31 d2                	xor    %edx,%edx
  802075:	f7 75 f4             	divl   -0xc(%ebp)
  802078:	89 c1                	mov    %eax,%ecx
  80207a:	89 f0                	mov    %esi,%eax
  80207c:	89 fa                	mov    %edi,%edx
  80207e:	f7 f1                	div    %ecx
  802080:	89 c6                	mov    %eax,%esi
  802082:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802085:	f7 f1                	div    %ecx
  802087:	89 c1                	mov    %eax,%ecx
  802089:	e9 54 ff ff ff       	jmp    801fe2 <__udivdi3+0x32>
  80208e:	66 90                	xchg   %ax,%ax
  802090:	39 d6                	cmp    %edx,%esi
  802092:	77 1c                	ja     8020b0 <__udivdi3+0x100>
  802094:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802097:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  80209a:	73 14                	jae    8020b0 <__udivdi3+0x100>
  80209c:	8d 74 26 00          	lea    0x0(%esi),%esi
  8020a0:	31 c9                	xor    %ecx,%ecx
  8020a2:	31 f6                	xor    %esi,%esi
  8020a4:	e9 39 ff ff ff       	jmp    801fe2 <__udivdi3+0x32>
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  8020b0:	b9 01 00 00 00       	mov    $0x1,%ecx
  8020b5:	31 f6                	xor    %esi,%esi
  8020b7:	e9 26 ff ff ff       	jmp    801fe2 <__udivdi3+0x32>
  8020bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8020bf:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  8020c3:	d3 e0                	shl    %cl,%eax
  8020c5:	39 c6                	cmp    %eax,%esi
  8020c7:	76 94                	jbe    80205d <__udivdi3+0xad>
  8020c9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8020cc:	31 f6                	xor    %esi,%esi
  8020ce:	83 e9 01             	sub    $0x1,%ecx
  8020d1:	e9 0c ff ff ff       	jmp    801fe2 <__udivdi3+0x32>
	...

008020e0 <__umoddi3>:
  8020e0:	55                   	push   %ebp
  8020e1:	89 e5                	mov    %esp,%ebp
  8020e3:	57                   	push   %edi
  8020e4:	56                   	push   %esi
  8020e5:	83 ec 30             	sub    $0x30,%esp
  8020e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8020eb:	8b 55 14             	mov    0x14(%ebp),%edx
  8020ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8020f1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8020f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020f7:	89 c1                	mov    %eax,%ecx
  8020f9:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8020fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8020ff:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  802106:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80210d:	89 fa                	mov    %edi,%edx
  80210f:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  802112:	85 c0                	test   %eax,%eax
  802114:	89 75 f0             	mov    %esi,-0x10(%ebp)
  802117:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80211a:	75 14                	jne    802130 <__umoddi3+0x50>
  80211c:	39 f9                	cmp    %edi,%ecx
  80211e:	76 60                	jbe    802180 <__umoddi3+0xa0>
  802120:	89 f0                	mov    %esi,%eax
  802122:	f7 f1                	div    %ecx
  802124:	89 55 d0             	mov    %edx,-0x30(%ebp)
  802127:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80212e:	eb 10                	jmp    802140 <__umoddi3+0x60>
  802130:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802133:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  802136:	76 18                	jbe    802150 <__umoddi3+0x70>
  802138:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80213b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80213e:	66 90                	xchg   %ax,%ax
  802140:	8b 45 d0             	mov    -0x30(%ebp),%eax
  802143:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  802146:	83 c4 30             	add    $0x30,%esp
  802149:	5e                   	pop    %esi
  80214a:	5f                   	pop    %edi
  80214b:	5d                   	pop    %ebp
  80214c:	c3                   	ret    
  80214d:	8d 76 00             	lea    0x0(%esi),%esi
  802150:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
  802154:	83 f0 1f             	xor    $0x1f,%eax
  802157:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80215a:	75 46                	jne    8021a2 <__umoddi3+0xc2>
  80215c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80215f:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  802162:	0f 87 c9 00 00 00    	ja     802231 <__umoddi3+0x151>
  802168:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  80216b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80216e:	0f 83 bd 00 00 00    	jae    802231 <__umoddi3+0x151>
  802174:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802177:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80217a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80217d:	eb c1                	jmp    802140 <__umoddi3+0x60>
  80217f:	90                   	nop    
  802180:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802183:	85 c0                	test   %eax,%eax
  802185:	75 0c                	jne    802193 <__umoddi3+0xb3>
  802187:	b8 01 00 00 00       	mov    $0x1,%eax
  80218c:	31 d2                	xor    %edx,%edx
  80218e:	f7 75 ec             	divl   -0x14(%ebp)
  802191:	89 c1                	mov    %eax,%ecx
  802193:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802196:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802199:	f7 f1                	div    %ecx
  80219b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80219e:	f7 f1                	div    %ecx
  8021a0:	eb 82                	jmp    802124 <__umoddi3+0x44>
  8021a2:	b8 20 00 00 00       	mov    $0x20,%eax
  8021a7:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8021aa:	2b 45 d8             	sub    -0x28(%ebp),%eax
  8021ad:	8b 75 ec             	mov    -0x14(%ebp),%esi
  8021b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8021b3:	89 c1                	mov    %eax,%ecx
  8021b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8021b8:	d3 ea                	shr    %cl,%edx
  8021ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8021bd:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8021c1:	d3 e0                	shl    %cl,%eax
  8021c3:	09 c2                	or     %eax,%edx
  8021c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021c8:	d3 e6                	shl    %cl,%esi
  8021ca:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  8021ce:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8021d1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8021d4:	d3 e8                	shr    %cl,%eax
  8021d6:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  8021da:	d3 e2                	shl    %cl,%edx
  8021dc:	09 d0                	or     %edx,%eax
  8021de:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8021e1:	d3 e7                	shl    %cl,%edi
  8021e3:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  8021e7:	d3 ea                	shr    %cl,%edx
  8021e9:	f7 75 f4             	divl   -0xc(%ebp)
  8021ec:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8021ef:	f7 e6                	mul    %esi
  8021f1:	39 55 cc             	cmp    %edx,-0x34(%ebp)
  8021f4:	72 53                	jb     802249 <__umoddi3+0x169>
  8021f6:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  8021f9:	74 4a                	je     802245 <__umoddi3+0x165>
  8021fb:	90                   	nop    
  8021fc:	8d 74 26 00          	lea    0x0(%esi),%esi
  802200:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  802203:	29 c7                	sub    %eax,%edi
  802205:	19 d1                	sbb    %edx,%ecx
  802207:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80220a:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  80220e:	89 fa                	mov    %edi,%edx
  802210:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802213:	d3 ea                	shr    %cl,%edx
  802215:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  802219:	d3 e0                	shl    %cl,%eax
  80221b:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  80221f:	09 c2                	or     %eax,%edx
  802221:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802224:	89 55 d0             	mov    %edx,-0x30(%ebp)
  802227:	d3 e8                	shr    %cl,%eax
  802229:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80222c:	e9 0f ff ff ff       	jmp    802140 <__umoddi3+0x60>
  802231:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802234:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802237:	2b 45 ec             	sub    -0x14(%ebp),%eax
  80223a:	1b 55 e8             	sbb    -0x18(%ebp),%edx
  80223d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802240:	e9 2f ff ff ff       	jmp    802174 <__umoddi3+0x94>
  802245:	39 f8                	cmp    %edi,%eax
  802247:	76 b7                	jbe    802200 <__umoddi3+0x120>
  802249:	29 f0                	sub    %esi,%eax
  80224b:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  80224e:	eb b0                	jmp    802200 <__umoddi3+0x120>
