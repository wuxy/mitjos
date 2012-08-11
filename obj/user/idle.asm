
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
  80003a:	c7 05 00 50 80 00 80 	movl   $0x801d80,0x805000
  800041:	1d 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800044:	e8 ac 03 00 00       	call   8003f5 <sys_yield>
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
  80005e:	c7 05 20 50 80 00 00 	movl   $0x0,0x805020
  800065:	00 00 00 
	env = &envs[ENVX(sys_getenvid())];
  800068:	e8 bc 03 00 00       	call   800429 <sys_getenvid>
  80006d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800072:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800075:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007a:	a3 20 50 80 00       	mov    %eax,0x805020
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007f:	85 f6                	test   %esi,%esi
  800081:	7e 07                	jle    80008a <libmain+0x3e>
		binaryname = argv[0];
  800083:	8b 03                	mov    (%ebx),%eax
  800085:	a3 00 50 80 00       	mov    %eax,0x805000

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
  8000ae:	e8 fd 09 00 00       	call   800ab0 <close_all>
	sys_env_destroy(0);
  8000b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ba:	e8 9e 03 00 00       	call   80045d <sys_env_destroy>
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

0080012b <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80012b:	55                   	push   %ebp
  80012c:	89 e5                	mov    %esp,%ebp
  80012e:	83 ec 28             	sub    $0x28,%esp
  800131:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800134:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800137:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80013a:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800142:	bf 00 00 00 00       	mov    $0x0,%edi
  800147:	89 f9                	mov    %edi,%ecx
  800149:	89 fb                	mov    %edi,%ebx
  80014b:	89 fe                	mov    %edi,%esi
  80014d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  80014f:	85 c0                	test   %eax,%eax
  800151:	7e 28                	jle    80017b <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800153:	89 44 24 10          	mov    %eax,0x10(%esp)
  800157:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80015e:	00 
  80015f:	c7 44 24 08 9c 1d 80 	movl   $0x801d9c,0x8(%esp)
  800166:	00 
  800167:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80016e:	00 
  80016f:	c7 04 24 b9 1d 80 00 	movl   $0x801db9,(%esp)
  800176:	e8 41 0c 00 00       	call   800dbc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80017b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80017e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800181:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800184:	89 ec                	mov    %ebp,%esp
  800186:	5d                   	pop    %ebp
  800187:	c3                   	ret    

00800188 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	83 ec 0c             	sub    $0xc,%esp
  80018e:	89 1c 24             	mov    %ebx,(%esp)
  800191:	89 74 24 04          	mov    %esi,0x4(%esp)
  800195:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800199:	8b 55 08             	mov    0x8(%ebp),%edx
  80019c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a2:	8b 7d 14             	mov    0x14(%ebp),%edi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8001aa:	be 00 00 00 00       	mov    $0x0,%esi
  8001af:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8001b1:	8b 1c 24             	mov    (%esp),%ebx
  8001b4:	8b 74 24 04          	mov    0x4(%esp),%esi
  8001b8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8001bc:	89 ec                	mov    %ebp,%esp
  8001be:	5d                   	pop    %ebp
  8001bf:	c3                   	ret    

008001c0 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	83 ec 28             	sub    $0x28,%esp
  8001c6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001c9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001cc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8001cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001da:	bf 00 00 00 00       	mov    $0x0,%edi
  8001df:	89 fb                	mov    %edi,%ebx
  8001e1:	89 fe                	mov    %edi,%esi
  8001e3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8001e5:	85 c0                	test   %eax,%eax
  8001e7:	7e 28                	jle    800211 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001ed:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8001f4:	00 
  8001f5:	c7 44 24 08 9c 1d 80 	movl   $0x801d9c,0x8(%esp)
  8001fc:	00 
  8001fd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800204:	00 
  800205:	c7 04 24 b9 1d 80 00 	movl   $0x801db9,(%esp)
  80020c:	e8 ab 0b 00 00       	call   800dbc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800211:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800214:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800217:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80021a:	89 ec                	mov    %ebp,%esp
  80021c:	5d                   	pop    %ebp
  80021d:	c3                   	ret    

0080021e <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	83 ec 28             	sub    $0x28,%esp
  800224:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800227:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80022a:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80022d:	8b 55 08             	mov    0x8(%ebp),%edx
  800230:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800233:	b8 09 00 00 00       	mov    $0x9,%eax
  800238:	bf 00 00 00 00       	mov    $0x0,%edi
  80023d:	89 fb                	mov    %edi,%ebx
  80023f:	89 fe                	mov    %edi,%esi
  800241:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800243:	85 c0                	test   %eax,%eax
  800245:	7e 28                	jle    80026f <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800247:	89 44 24 10          	mov    %eax,0x10(%esp)
  80024b:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800252:	00 
  800253:	c7 44 24 08 9c 1d 80 	movl   $0x801d9c,0x8(%esp)
  80025a:	00 
  80025b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800262:	00 
  800263:	c7 04 24 b9 1d 80 00 	movl   $0x801db9,(%esp)
  80026a:	e8 4d 0b 00 00       	call   800dbc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80026f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800272:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800275:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800278:	89 ec                	mov    %ebp,%esp
  80027a:	5d                   	pop    %ebp
  80027b:	c3                   	ret    

0080027c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	83 ec 28             	sub    $0x28,%esp
  800282:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800285:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800288:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80028b:	8b 55 08             	mov    0x8(%ebp),%edx
  80028e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800291:	b8 08 00 00 00       	mov    $0x8,%eax
  800296:	bf 00 00 00 00       	mov    $0x0,%edi
  80029b:	89 fb                	mov    %edi,%ebx
  80029d:	89 fe                	mov    %edi,%esi
  80029f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8002a1:	85 c0                	test   %eax,%eax
  8002a3:	7e 28                	jle    8002cd <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002a9:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002b0:	00 
  8002b1:	c7 44 24 08 9c 1d 80 	movl   $0x801d9c,0x8(%esp)
  8002b8:	00 
  8002b9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002c0:	00 
  8002c1:	c7 04 24 b9 1d 80 00 	movl   $0x801db9,(%esp)
  8002c8:	e8 ef 0a 00 00       	call   800dbc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002cd:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002d0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002d3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002d6:	89 ec                	mov    %ebp,%esp
  8002d8:	5d                   	pop    %ebp
  8002d9:	c3                   	ret    

008002da <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	83 ec 28             	sub    $0x28,%esp
  8002e0:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002e3:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002e6:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8002e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ef:	b8 06 00 00 00       	mov    $0x6,%eax
  8002f4:	bf 00 00 00 00       	mov    $0x0,%edi
  8002f9:	89 fb                	mov    %edi,%ebx
  8002fb:	89 fe                	mov    %edi,%esi
  8002fd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8002ff:	85 c0                	test   %eax,%eax
  800301:	7e 28                	jle    80032b <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800303:	89 44 24 10          	mov    %eax,0x10(%esp)
  800307:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80030e:	00 
  80030f:	c7 44 24 08 9c 1d 80 	movl   $0x801d9c,0x8(%esp)
  800316:	00 
  800317:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80031e:	00 
  80031f:	c7 04 24 b9 1d 80 00 	movl   $0x801db9,(%esp)
  800326:	e8 91 0a 00 00       	call   800dbc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80032b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80032e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800331:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800334:	89 ec                	mov    %ebp,%esp
  800336:	5d                   	pop    %ebp
  800337:	c3                   	ret    

00800338 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
  80033b:	83 ec 28             	sub    $0x28,%esp
  80033e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800341:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800344:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800347:	8b 55 08             	mov    0x8(%ebp),%edx
  80034a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80034d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800350:	8b 7d 14             	mov    0x14(%ebp),%edi
  800353:	8b 75 18             	mov    0x18(%ebp),%esi
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800356:	b8 05 00 00 00       	mov    $0x5,%eax
  80035b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  80035d:	85 c0                	test   %eax,%eax
  80035f:	7e 28                	jle    800389 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800361:	89 44 24 10          	mov    %eax,0x10(%esp)
  800365:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80036c:	00 
  80036d:	c7 44 24 08 9c 1d 80 	movl   $0x801d9c,0x8(%esp)
  800374:	00 
  800375:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80037c:	00 
  80037d:	c7 04 24 b9 1d 80 00 	movl   $0x801db9,(%esp)
  800384:	e8 33 0a 00 00       	call   800dbc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800389:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80038c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80038f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800392:	89 ec                	mov    %ebp,%esp
  800394:	5d                   	pop    %ebp
  800395:	c3                   	ret    

00800396 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800396:	55                   	push   %ebp
  800397:	89 e5                	mov    %esp,%ebp
  800399:	83 ec 28             	sub    $0x28,%esp
  80039c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80039f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003a2:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8003a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003ae:	b8 04 00 00 00       	mov    $0x4,%eax
  8003b3:	bf 00 00 00 00       	mov    $0x0,%edi
  8003b8:	89 fe                	mov    %edi,%esi
  8003ba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8003bc:	85 c0                	test   %eax,%eax
  8003be:	7e 28                	jle    8003e8 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003c0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003c4:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8003cb:	00 
  8003cc:	c7 44 24 08 9c 1d 80 	movl   $0x801d9c,0x8(%esp)
  8003d3:	00 
  8003d4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003db:	00 
  8003dc:	c7 04 24 b9 1d 80 00 	movl   $0x801db9,(%esp)
  8003e3:	e8 d4 09 00 00       	call   800dbc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8003e8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003eb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003ee:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003f1:	89 ec                	mov    %ebp,%esp
  8003f3:	5d                   	pop    %ebp
  8003f4:	c3                   	ret    

008003f5 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  8003f5:	55                   	push   %ebp
  8003f6:	89 e5                	mov    %esp,%ebp
  8003f8:	83 ec 0c             	sub    $0xc,%esp
  8003fb:	89 1c 24             	mov    %ebx,(%esp)
  8003fe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800402:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800406:	b8 0b 00 00 00       	mov    $0xb,%eax
  80040b:	bf 00 00 00 00       	mov    $0x0,%edi
  800410:	89 fa                	mov    %edi,%edx
  800412:	89 f9                	mov    %edi,%ecx
  800414:	89 fb                	mov    %edi,%ebx
  800416:	89 fe                	mov    %edi,%esi
  800418:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80041a:	8b 1c 24             	mov    (%esp),%ebx
  80041d:	8b 74 24 04          	mov    0x4(%esp),%esi
  800421:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800425:	89 ec                	mov    %ebp,%esp
  800427:	5d                   	pop    %ebp
  800428:	c3                   	ret    

00800429 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
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
  80043a:	b8 02 00 00 00       	mov    $0x2,%eax
  80043f:	bf 00 00 00 00       	mov    $0x0,%edi
  800444:	89 fa                	mov    %edi,%edx
  800446:	89 f9                	mov    %edi,%ecx
  800448:	89 fb                	mov    %edi,%ebx
  80044a:	89 fe                	mov    %edi,%esi
  80044c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80044e:	8b 1c 24             	mov    (%esp),%ebx
  800451:	8b 74 24 04          	mov    0x4(%esp),%esi
  800455:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800459:	89 ec                	mov    %ebp,%esp
  80045b:	5d                   	pop    %ebp
  80045c:	c3                   	ret    

0080045d <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80045d:	55                   	push   %ebp
  80045e:	89 e5                	mov    %esp,%ebp
  800460:	83 ec 28             	sub    $0x28,%esp
  800463:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800466:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800469:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80046c:	8b 55 08             	mov    0x8(%ebp),%edx
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80046f:	b8 03 00 00 00       	mov    $0x3,%eax
  800474:	bf 00 00 00 00       	mov    $0x0,%edi
  800479:	89 f9                	mov    %edi,%ecx
  80047b:	89 fb                	mov    %edi,%ebx
  80047d:	89 fe                	mov    %edi,%esi
  80047f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800481:	85 c0                	test   %eax,%eax
  800483:	7e 28                	jle    8004ad <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800485:	89 44 24 10          	mov    %eax,0x10(%esp)
  800489:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800490:	00 
  800491:	c7 44 24 08 9c 1d 80 	movl   $0x801d9c,0x8(%esp)
  800498:	00 
  800499:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8004a0:	00 
  8004a1:	c7 04 24 b9 1d 80 00 	movl   $0x801db9,(%esp)
  8004a8:	e8 0f 09 00 00       	call   800dbc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8004ad:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8004b0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8004b3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8004b6:	89 ec                	mov    %ebp,%esp
  8004b8:	5d                   	pop    %ebp
  8004b9:	c3                   	ret    
  8004ba:	00 00                	add    %al,(%eax)
  8004bc:	00 00                	add    %al,(%eax)
	...

008004c0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
  8004c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c6:	05 00 00 00 30       	add    $0x30000000,%eax
  8004cb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8004ce:	5d                   	pop    %ebp
  8004cf:	c3                   	ret    

008004d0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8004d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d9:	89 04 24             	mov    %eax,(%esp)
  8004dc:	e8 df ff ff ff       	call   8004c0 <fd2num>
  8004e1:	c1 e0 0c             	shl    $0xc,%eax
  8004e4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8004e9:	c9                   	leave  
  8004ea:	c3                   	ret    

008004eb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8004eb:	55                   	push   %ebp
  8004ec:	89 e5                	mov    %esp,%ebp
  8004ee:	53                   	push   %ebx
  8004ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004f2:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  8004f7:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  8004f9:	89 d0                	mov    %edx,%eax
  8004fb:	c1 e8 16             	shr    $0x16,%eax
  8004fe:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800505:	a8 01                	test   $0x1,%al
  800507:	74 10                	je     800519 <fd_alloc+0x2e>
  800509:	89 d0                	mov    %edx,%eax
  80050b:	c1 e8 0c             	shr    $0xc,%eax
  80050e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800515:	a8 01                	test   $0x1,%al
  800517:	75 09                	jne    800522 <fd_alloc+0x37>
			*fd_store = fd;
  800519:	89 0b                	mov    %ecx,(%ebx)
  80051b:	b8 00 00 00 00       	mov    $0x0,%eax
  800520:	eb 19                	jmp    80053b <fd_alloc+0x50>
			return 0;
  800522:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800528:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  80052e:	75 c7                	jne    8004f7 <fd_alloc+0xc>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800530:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800536:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  80053b:	5b                   	pop    %ebx
  80053c:	5d                   	pop    %ebp
  80053d:	c3                   	ret    

0080053e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80053e:	55                   	push   %ebp
  80053f:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800541:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  800545:	77 38                	ja     80057f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800547:	8b 45 08             	mov    0x8(%ebp),%eax
  80054a:	c1 e0 0c             	shl    $0xc,%eax
  80054d:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  800553:	89 d0                	mov    %edx,%eax
  800555:	c1 e8 16             	shr    $0x16,%eax
  800558:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80055f:	a8 01                	test   $0x1,%al
  800561:	74 1c                	je     80057f <fd_lookup+0x41>
  800563:	89 d0                	mov    %edx,%eax
  800565:	c1 e8 0c             	shr    $0xc,%eax
  800568:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80056f:	a8 01                	test   $0x1,%al
  800571:	74 0c                	je     80057f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  800573:	8b 45 0c             	mov    0xc(%ebp),%eax
  800576:	89 10                	mov    %edx,(%eax)
  800578:	b8 00 00 00 00       	mov    $0x0,%eax
  80057d:	eb 05                	jmp    800584 <fd_lookup+0x46>
	return 0;
  80057f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800584:	5d                   	pop    %ebp
  800585:	c3                   	ret    

00800586 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  800586:	55                   	push   %ebp
  800587:	89 e5                	mov    %esp,%ebp
  800589:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80058c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80058f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800593:	8b 45 08             	mov    0x8(%ebp),%eax
  800596:	89 04 24             	mov    %eax,(%esp)
  800599:	e8 a0 ff ff ff       	call   80053e <fd_lookup>
  80059e:	85 c0                	test   %eax,%eax
  8005a0:	78 0e                	js     8005b0 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8005a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8005a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005a8:	89 50 04             	mov    %edx,0x4(%eax)
  8005ab:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8005b0:	c9                   	leave  
  8005b1:	c3                   	ret    

008005b2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8005b2:	55                   	push   %ebp
  8005b3:	89 e5                	mov    %esp,%ebp
  8005b5:	53                   	push   %ebx
  8005b6:	83 ec 14             	sub    $0x14,%esp
  8005b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8005bf:	ba 04 50 80 00       	mov    $0x805004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8005c4:	b8 00 00 00 00       	mov    $0x0,%eax
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8005c9:	39 0d 04 50 80 00    	cmp    %ecx,0x805004
  8005cf:	75 11                	jne    8005e2 <dev_lookup+0x30>
  8005d1:	eb 04                	jmp    8005d7 <dev_lookup+0x25>
  8005d3:	39 0a                	cmp    %ecx,(%edx)
  8005d5:	75 0b                	jne    8005e2 <dev_lookup+0x30>
			*dev = devtab[i];
  8005d7:	89 13                	mov    %edx,(%ebx)
  8005d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8005de:	66 90                	xchg   %ax,%ax
  8005e0:	eb 35                	jmp    800617 <dev_lookup+0x65>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8005e2:	83 c0 01             	add    $0x1,%eax
  8005e5:	8b 14 85 44 1e 80 00 	mov    0x801e44(,%eax,4),%edx
  8005ec:	85 d2                	test   %edx,%edx
  8005ee:	75 e3                	jne    8005d3 <dev_lookup+0x21>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  8005f0:	a1 20 50 80 00       	mov    0x805020,%eax
  8005f5:	8b 40 4c             	mov    0x4c(%eax),%eax
  8005f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8005fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800600:	c7 04 24 c8 1d 80 00 	movl   $0x801dc8,(%esp)
  800607:	e8 7d 08 00 00       	call   800e89 <cprintf>
	*dev = 0;
  80060c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800612:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  800617:	83 c4 14             	add    $0x14,%esp
  80061a:	5b                   	pop    %ebx
  80061b:	5d                   	pop    %ebp
  80061c:	c3                   	ret    

0080061d <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80061d:	55                   	push   %ebp
  80061e:	89 e5                	mov    %esp,%ebp
  800620:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800623:	8d 45 f8             	lea    -0x8(%ebp),%eax
  800626:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062a:	8b 45 08             	mov    0x8(%ebp),%eax
  80062d:	89 04 24             	mov    %eax,(%esp)
  800630:	e8 09 ff ff ff       	call   80053e <fd_lookup>
  800635:	89 c2                	mov    %eax,%edx
  800637:	85 c0                	test   %eax,%eax
  800639:	78 5a                	js     800695 <fstat+0x78>
  80063b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80063e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800642:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800645:	8b 00                	mov    (%eax),%eax
  800647:	89 04 24             	mov    %eax,(%esp)
  80064a:	e8 63 ff ff ff       	call   8005b2 <dev_lookup>
  80064f:	89 c2                	mov    %eax,%edx
  800651:	85 c0                	test   %eax,%eax
  800653:	78 40                	js     800695 <fstat+0x78>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  800655:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
  80065a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80065d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800661:	74 32                	je     800695 <fstat+0x78>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800663:	8b 45 0c             	mov    0xc(%ebp),%eax
  800666:	c6 00 00             	movb   $0x0,(%eax)
	stat->st_size = 0;
  800669:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  800670:	00 00 00 
	stat->st_isdir = 0;
  800673:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
  80067a:	00 00 00 
	stat->st_dev = dev;
  80067d:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800680:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
	return (*dev->dev_stat)(fd, stat);
  800686:	89 44 24 04          	mov    %eax,0x4(%esp)
  80068a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80068d:	89 04 24             	mov    %eax,(%esp)
  800690:	ff 52 14             	call   *0x14(%edx)
  800693:	89 c2                	mov    %eax,%edx
}
  800695:	89 d0                	mov    %edx,%eax
  800697:	c9                   	leave  
  800698:	c3                   	ret    

00800699 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  800699:	55                   	push   %ebp
  80069a:	89 e5                	mov    %esp,%ebp
  80069c:	53                   	push   %ebx
  80069d:	83 ec 24             	sub    $0x24,%esp
  8006a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006aa:	89 1c 24             	mov    %ebx,(%esp)
  8006ad:	e8 8c fe ff ff       	call   80053e <fd_lookup>
  8006b2:	85 c0                	test   %eax,%eax
  8006b4:	78 61                	js     800717 <ftruncate+0x7e>
  8006b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b9:	8b 10                	mov    (%eax),%edx
  8006bb:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8006be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c2:	89 14 24             	mov    %edx,(%esp)
  8006c5:	e8 e8 fe ff ff       	call   8005b2 <dev_lookup>
  8006ca:	85 c0                	test   %eax,%eax
  8006cc:	78 49                	js     800717 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8006ce:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  8006d1:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  8006d5:	75 23                	jne    8006fa <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8006d7:	a1 20 50 80 00       	mov    0x805020,%eax
  8006dc:	8b 40 4c             	mov    0x4c(%eax),%eax
  8006df:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8006e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e7:	c7 04 24 e8 1d 80 00 	movl   $0x801de8,(%esp)
  8006ee:	e8 96 07 00 00       	call   800e89 <cprintf>
  8006f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006f8:	eb 1d                	jmp    800717 <ftruncate+0x7e>
			env->env_id, fdnum); 
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8006fa:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8006fd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800702:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  800706:	74 0f                	je     800717 <ftruncate+0x7e>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800708:	8b 42 18             	mov    0x18(%edx),%eax
  80070b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80070e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800712:	89 0c 24             	mov    %ecx,(%esp)
  800715:	ff d0                	call   *%eax
}
  800717:	83 c4 24             	add    $0x24,%esp
  80071a:	5b                   	pop    %ebx
  80071b:	5d                   	pop    %ebp
  80071c:	c3                   	ret    

0080071d <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80071d:	55                   	push   %ebp
  80071e:	89 e5                	mov    %esp,%ebp
  800720:	53                   	push   %ebx
  800721:	83 ec 24             	sub    $0x24,%esp
  800724:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800727:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80072a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072e:	89 1c 24             	mov    %ebx,(%esp)
  800731:	e8 08 fe ff ff       	call   80053e <fd_lookup>
  800736:	85 c0                	test   %eax,%eax
  800738:	78 68                	js     8007a2 <write+0x85>
  80073a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073d:	8b 10                	mov    (%eax),%edx
  80073f:	8d 45 f8             	lea    -0x8(%ebp),%eax
  800742:	89 44 24 04          	mov    %eax,0x4(%esp)
  800746:	89 14 24             	mov    %edx,(%esp)
  800749:	e8 64 fe ff ff       	call   8005b2 <dev_lookup>
  80074e:	85 c0                	test   %eax,%eax
  800750:	78 50                	js     8007a2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800752:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  800755:	f6 41 08 03          	testb  $0x3,0x8(%ecx)
  800759:	75 23                	jne    80077e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  80075b:	a1 20 50 80 00       	mov    0x805020,%eax
  800760:	8b 40 4c             	mov    0x4c(%eax),%eax
  800763:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800767:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076b:	c7 04 24 09 1e 80 00 	movl   $0x801e09,(%esp)
  800772:	e8 12 07 00 00       	call   800e89 <cprintf>
  800777:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80077c:	eb 24                	jmp    8007a2 <write+0x85>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80077e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  800781:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800786:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  80078a:	74 16                	je     8007a2 <write+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80078c:	8b 42 0c             	mov    0xc(%edx),%eax
  80078f:	8b 55 10             	mov    0x10(%ebp),%edx
  800792:	89 54 24 08          	mov    %edx,0x8(%esp)
  800796:	8b 55 0c             	mov    0xc(%ebp),%edx
  800799:	89 54 24 04          	mov    %edx,0x4(%esp)
  80079d:	89 0c 24             	mov    %ecx,(%esp)
  8007a0:	ff d0                	call   *%eax
}
  8007a2:	83 c4 24             	add    $0x24,%esp
  8007a5:	5b                   	pop    %ebx
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	53                   	push   %ebx
  8007ac:	83 ec 24             	sub    $0x24,%esp
  8007af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b9:	89 1c 24             	mov    %ebx,(%esp)
  8007bc:	e8 7d fd ff ff       	call   80053e <fd_lookup>
  8007c1:	85 c0                	test   %eax,%eax
  8007c3:	78 6d                	js     800832 <read+0x8a>
  8007c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007c8:	8b 10                	mov    (%eax),%edx
  8007ca:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8007cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d1:	89 14 24             	mov    %edx,(%esp)
  8007d4:	e8 d9 fd ff ff       	call   8005b2 <dev_lookup>
  8007d9:	85 c0                	test   %eax,%eax
  8007db:	78 55                	js     800832 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8007dd:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  8007e0:	8b 41 08             	mov    0x8(%ecx),%eax
  8007e3:	83 e0 03             	and    $0x3,%eax
  8007e6:	83 f8 01             	cmp    $0x1,%eax
  8007e9:	75 23                	jne    80080e <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  8007eb:	a1 20 50 80 00       	mov    0x805020,%eax
  8007f0:	8b 40 4c             	mov    0x4c(%eax),%eax
  8007f3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007fb:	c7 04 24 26 1e 80 00 	movl   $0x801e26,(%esp)
  800802:	e8 82 06 00 00       	call   800e89 <cprintf>
  800807:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80080c:	eb 24                	jmp    800832 <read+0x8a>
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80080e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  800811:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800816:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  80081a:	74 16                	je     800832 <read+0x8a>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80081c:	8b 42 08             	mov    0x8(%edx),%eax
  80081f:	8b 55 10             	mov    0x10(%ebp),%edx
  800822:	89 54 24 08          	mov    %edx,0x8(%esp)
  800826:	8b 55 0c             	mov    0xc(%ebp),%edx
  800829:	89 54 24 04          	mov    %edx,0x4(%esp)
  80082d:	89 0c 24             	mov    %ecx,(%esp)
  800830:	ff d0                	call   *%eax
}
  800832:	83 c4 24             	add    $0x24,%esp
  800835:	5b                   	pop    %ebx
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	57                   	push   %edi
  80083c:	56                   	push   %esi
  80083d:	53                   	push   %ebx
  80083e:	83 ec 0c             	sub    $0xc,%esp
  800841:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800844:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800847:	b8 00 00 00 00       	mov    $0x0,%eax
  80084c:	85 f6                	test   %esi,%esi
  80084e:	74 36                	je     800886 <readn+0x4e>
  800850:	bb 00 00 00 00       	mov    $0x0,%ebx
  800855:	ba 00 00 00 00       	mov    $0x0,%edx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80085a:	89 f0                	mov    %esi,%eax
  80085c:	29 d0                	sub    %edx,%eax
  80085e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800862:	8d 04 17             	lea    (%edi,%edx,1),%eax
  800865:	89 44 24 04          	mov    %eax,0x4(%esp)
  800869:	8b 45 08             	mov    0x8(%ebp),%eax
  80086c:	89 04 24             	mov    %eax,(%esp)
  80086f:	e8 34 ff ff ff       	call   8007a8 <read>
		if (m < 0)
  800874:	85 c0                	test   %eax,%eax
  800876:	78 0e                	js     800886 <readn+0x4e>
			return m;
		if (m == 0)
  800878:	85 c0                	test   %eax,%eax
  80087a:	74 08                	je     800884 <readn+0x4c>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80087c:	01 c3                	add    %eax,%ebx
  80087e:	89 da                	mov    %ebx,%edx
  800880:	39 f3                	cmp    %esi,%ebx
  800882:	72 d6                	jb     80085a <readn+0x22>
  800884:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800886:	83 c4 0c             	add    $0xc,%esp
  800889:	5b                   	pop    %ebx
  80088a:	5e                   	pop    %esi
  80088b:	5f                   	pop    %edi
  80088c:	5d                   	pop    %ebp
  80088d:	c3                   	ret    

0080088e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	83 ec 28             	sub    $0x28,%esp
  800894:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800897:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80089a:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80089d:	89 34 24             	mov    %esi,(%esp)
  8008a0:	e8 1b fc ff ff       	call   8004c0 <fd2num>
  8008a5:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8008a8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008ac:	89 04 24             	mov    %eax,(%esp)
  8008af:	e8 8a fc ff ff       	call   80053e <fd_lookup>
  8008b4:	89 c3                	mov    %eax,%ebx
  8008b6:	85 c0                	test   %eax,%eax
  8008b8:	78 05                	js     8008bf <fd_close+0x31>
  8008ba:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8008bd:	74 0d                	je     8008cc <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8008bf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008c3:	75 44                	jne    800909 <fd_close+0x7b>
  8008c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008ca:	eb 3d                	jmp    800909 <fd_close+0x7b>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8008cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d3:	8b 06                	mov    (%esi),%eax
  8008d5:	89 04 24             	mov    %eax,(%esp)
  8008d8:	e8 d5 fc ff ff       	call   8005b2 <dev_lookup>
  8008dd:	89 c3                	mov    %eax,%ebx
  8008df:	85 c0                	test   %eax,%eax
  8008e1:	78 16                	js     8008f9 <fd_close+0x6b>
		if (dev->dev_close)
  8008e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008e6:	8b 40 10             	mov    0x10(%eax),%eax
  8008e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008ee:	85 c0                	test   %eax,%eax
  8008f0:	74 07                	je     8008f9 <fd_close+0x6b>
			r = (*dev->dev_close)(fd);
  8008f2:	89 34 24             	mov    %esi,(%esp)
  8008f5:	ff d0                	call   *%eax
  8008f7:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8008f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800904:	e8 d1 f9 ff ff       	call   8002da <sys_page_unmap>
	return r;
}
  800909:	89 d8                	mov    %ebx,%eax
  80090b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80090e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800911:	89 ec                	mov    %ebp,%esp
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80091b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80091e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800922:	8b 45 08             	mov    0x8(%ebp),%eax
  800925:	89 04 24             	mov    %eax,(%esp)
  800928:	e8 11 fc ff ff       	call   80053e <fd_lookup>
  80092d:	85 c0                	test   %eax,%eax
  80092f:	78 13                	js     800944 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800931:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800938:	00 
  800939:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80093c:	89 04 24             	mov    %eax,(%esp)
  80093f:	e8 4a ff ff ff       	call   80088e <fd_close>
}
  800944:	c9                   	leave  
  800945:	c3                   	ret    

00800946 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	83 ec 18             	sub    $0x18,%esp
  80094c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80094f:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800952:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800959:	00 
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	89 04 24             	mov    %eax,(%esp)
  800960:	e8 6a 03 00 00       	call   800ccf <open>
  800965:	89 c6                	mov    %eax,%esi
  800967:	85 c0                	test   %eax,%eax
  800969:	78 1b                	js     800986 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  80096b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800972:	89 34 24             	mov    %esi,(%esp)
  800975:	e8 a3 fc ff ff       	call   80061d <fstat>
  80097a:	89 c3                	mov    %eax,%ebx
	close(fd);
  80097c:	89 34 24             	mov    %esi,(%esp)
  80097f:	e8 91 ff ff ff       	call   800915 <close>
  800984:	89 de                	mov    %ebx,%esi
	return r;
}
  800986:	89 f0                	mov    %esi,%eax
  800988:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80098b:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80098e:	89 ec                	mov    %ebp,%esp
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	83 ec 38             	sub    $0x38,%esp
  800998:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80099b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80099e:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8009a1:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8009a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	89 04 24             	mov    %eax,(%esp)
  8009b1:	e8 88 fb ff ff       	call   80053e <fd_lookup>
  8009b6:	89 c3                	mov    %eax,%ebx
  8009b8:	85 c0                	test   %eax,%eax
  8009ba:	0f 88 e1 00 00 00    	js     800aa1 <dup+0x10f>
		return r;
	close(newfdnum);
  8009c0:	89 3c 24             	mov    %edi,(%esp)
  8009c3:	e8 4d ff ff ff       	call   800915 <close>

	newfd = INDEX2FD(newfdnum);
  8009c8:	89 f8                	mov    %edi,%eax
  8009ca:	c1 e0 0c             	shl    $0xc,%eax
  8009cd:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  8009d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009d6:	89 04 24             	mov    %eax,(%esp)
  8009d9:	e8 f2 fa ff ff       	call   8004d0 <fd2data>
  8009de:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8009e0:	89 34 24             	mov    %esi,(%esp)
  8009e3:	e8 e8 fa ff ff       	call   8004d0 <fd2data>
  8009e8:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  8009eb:	89 d8                	mov    %ebx,%eax
  8009ed:	c1 e8 16             	shr    $0x16,%eax
  8009f0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8009f7:	a8 01                	test   $0x1,%al
  8009f9:	74 45                	je     800a40 <dup+0xae>
  8009fb:	89 da                	mov    %ebx,%edx
  8009fd:	c1 ea 0c             	shr    $0xc,%edx
  800a00:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800a07:	a8 01                	test   $0x1,%al
  800a09:	74 35                	je     800a40 <dup+0xae>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  800a0b:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800a12:	25 07 0e 00 00       	and    $0xe07,%eax
  800a17:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a1b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a1e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a22:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a29:	00 
  800a2a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a2e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a35:	e8 fe f8 ff ff       	call   800338 <sys_page_map>
  800a3a:	89 c3                	mov    %eax,%ebx
  800a3c:	85 c0                	test   %eax,%eax
  800a3e:	78 3e                	js     800a7e <dup+0xec>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  800a40:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a43:	89 d0                	mov    %edx,%eax
  800a45:	c1 e8 0c             	shr    $0xc,%eax
  800a48:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a4f:	25 07 0e 00 00       	and    $0xe07,%eax
  800a54:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a58:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800a5c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a63:	00 
  800a64:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a68:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a6f:	e8 c4 f8 ff ff       	call   800338 <sys_page_map>
  800a74:	89 c3                	mov    %eax,%ebx
  800a76:	85 c0                	test   %eax,%eax
  800a78:	78 04                	js     800a7e <dup+0xec>
		goto err;
  800a7a:	89 fb                	mov    %edi,%ebx
  800a7c:	eb 23                	jmp    800aa1 <dup+0x10f>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800a7e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a82:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a89:	e8 4c f8 ff ff       	call   8002da <sys_page_unmap>
	sys_page_unmap(0, nva);
  800a8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a91:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a95:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a9c:	e8 39 f8 ff ff       	call   8002da <sys_page_unmap>
	return r;
}
  800aa1:	89 d8                	mov    %ebx,%eax
  800aa3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800aa6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800aa9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800aac:	89 ec                	mov    %ebp,%esp
  800aae:	5d                   	pop    %ebp
  800aaf:	c3                   	ret    

00800ab0 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	53                   	push   %ebx
  800ab4:	83 ec 04             	sub    $0x4,%esp
  800ab7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  800abc:	89 1c 24             	mov    %ebx,(%esp)
  800abf:	e8 51 fe ff ff       	call   800915 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ac4:	83 c3 01             	add    $0x1,%ebx
  800ac7:	83 fb 20             	cmp    $0x20,%ebx
  800aca:	75 f0                	jne    800abc <close_all+0xc>
		close(i);
}
  800acc:	83 c4 04             	add    $0x4,%esp
  800acf:	5b                   	pop    %ebx
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    
	...

00800ad4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	53                   	push   %ebx
  800ad8:	83 ec 14             	sub    $0x14,%esp
  800adb:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800add:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  800ae3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800aea:	00 
  800aeb:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  800af2:	00 
  800af3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af7:	89 14 24             	mov    %edx,(%esp)
  800afa:	e8 31 0e 00 00       	call   801930 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800aff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800b06:	00 
  800b07:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b12:	e8 cd 0e 00 00       	call   8019e4 <ipc_recv>
}
  800b17:	83 c4 14             	add    $0x14,%esp
  800b1a:	5b                   	pop    %ebx
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b23:	ba 00 00 00 00       	mov    $0x0,%edx
  800b28:	b8 08 00 00 00       	mov    $0x8,%eax
  800b2d:	e8 a2 ff ff ff       	call   800ad4 <fsipc>
}
  800b32:	c9                   	leave  
  800b33:	c3                   	ret    

00800b34 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800b3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3d:	8b 40 0c             	mov    0xc(%eax),%eax
  800b40:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.set_size.req_size = newsize;
  800b45:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b48:	a3 04 30 80 00       	mov    %eax,0x803004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800b4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b52:	b8 02 00 00 00       	mov    $0x2,%eax
  800b57:	e8 78 ff ff ff       	call   800ad4 <fsipc>
}
  800b5c:	c9                   	leave  
  800b5d:	c3                   	ret    

00800b5e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800b64:	8b 45 08             	mov    0x8(%ebp),%eax
  800b67:	8b 40 0c             	mov    0xc(%eax),%eax
  800b6a:	a3 00 30 80 00       	mov    %eax,0x803000
	return fsipc(FSREQ_FLUSH, NULL);
  800b6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b74:	b8 06 00 00 00       	mov    $0x6,%eax
  800b79:	e8 56 ff ff ff       	call   800ad4 <fsipc>
}
  800b7e:	c9                   	leave  
  800b7f:	c3                   	ret    

00800b80 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	53                   	push   %ebx
  800b84:	83 ec 14             	sub    $0x14,%esp
  800b87:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800b8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8d:	8b 40 0c             	mov    0xc(%eax),%eax
  800b90:	a3 00 30 80 00       	mov    %eax,0x803000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800b95:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9a:	b8 05 00 00 00       	mov    $0x5,%eax
  800b9f:	e8 30 ff ff ff       	call   800ad4 <fsipc>
  800ba4:	85 c0                	test   %eax,%eax
  800ba6:	78 2b                	js     800bd3 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800ba8:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  800baf:	00 
  800bb0:	89 1c 24             	mov    %ebx,(%esp)
  800bb3:	e8 39 09 00 00       	call   8014f1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800bb8:	a1 80 30 80 00       	mov    0x803080,%eax
  800bbd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800bc3:	a1 84 30 80 00       	mov    0x803084,%eax
  800bc8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  800bce:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  800bd3:	83 c4 14             	add    $0x14,%esp
  800bd6:	5b                   	pop    %ebx
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	83 ec 18             	sub    $0x18,%esp
  800bdf:	8b 55 10             	mov    0x10(%ebp),%edx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	ssize_t writesize;
	size_t bufsize;
	fsipcbuf.write.req_fileid=fd->fd_file.id;
  800be2:	8b 45 08             	mov    0x8(%ebp),%eax
  800be5:	8b 40 0c             	mov    0xc(%eax),%eax
  800be8:	a3 00 30 80 00       	mov    %eax,0x803000
	bufsize=sizeof(fsipcbuf.write.req_buf);
	if(n<bufsize)
  800bed:	89 d0                	mov    %edx,%eax
  800bef:	81 fa f7 0f 00 00    	cmp    $0xff7,%edx
  800bf5:	76 05                	jbe    800bfc <devfile_write+0x23>
  800bf7:	b8 f8 0f 00 00       	mov    $0xff8,%eax
		bufsize=n;	
	fsipcbuf.write.req_n=n;
  800bfc:	89 15 04 30 80 00    	mov    %edx,0x803004
	memmove((void*)fsipcbuf.write.req_buf,buf,bufsize);
  800c02:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c06:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c09:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c0d:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  800c14:	e8 df 0a 00 00       	call   8016f8 <memmove>
	writesize=(ssize_t)fsipc(FSREQ_WRITE,NULL);
  800c19:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1e:	b8 04 00 00 00       	mov    $0x4,%eax
  800c23:	e8 ac fe ff ff       	call   800ad4 <fsipc>
	return writesize;
	//panic("devfile_write not implemented");
}
  800c28:	c9                   	leave  
  800c29:	c3                   	ret    

00800c2a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	53                   	push   %ebx
  800c2e:	83 ec 14             	sub    $0x14,%esp
	// system server.
	// LAB 5: Your code here
	ssize_t readsize;
	if(debug)
		cprintf("devfile_read:fileid=%x readsize=%x\n",fd->fd_file.id,n);
	fsipcbuf.read.req_fileid=fd->fd_file.id;
  800c31:	8b 45 08             	mov    0x8(%ebp),%eax
  800c34:	8b 40 0c             	mov    0xc(%eax),%eax
  800c37:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.read.req_n=n;
  800c3c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c3f:	a3 04 30 80 00       	mov    %eax,0x803004
	readsize=(ssize_t)fsipc(FSREQ_READ,&fsipcbuf);
  800c44:	ba 00 30 80 00       	mov    $0x803000,%edx
  800c49:	b8 03 00 00 00       	mov    $0x3,%eax
  800c4e:	e8 81 fe ff ff       	call   800ad4 <fsipc>
  800c53:	89 c3                	mov    %eax,%ebx
	cprintf("readsize=%d\n",readsize);
  800c55:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c59:	c7 04 24 4c 1e 80 00 	movl   $0x801e4c,(%esp)
  800c60:	e8 24 02 00 00       	call   800e89 <cprintf>
	if(debug)
		cprintf("devfile_read:buf1=%s\nbuf2=%s\n",(char*)&fsipcbuf,fsipcbuf.readRet.ret_buf);
	if(readsize>0)
  800c65:	85 db                	test   %ebx,%ebx
  800c67:	7e 17                	jle    800c80 <devfile_read+0x56>
		memmove(buf,(void*)&fsipcbuf,(size_t)readsize);
  800c69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800c6d:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  800c74:	00 
  800c75:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c78:	89 04 24             	mov    %eax,(%esp)
  800c7b:	e8 78 0a 00 00       	call   8016f8 <memmove>
	//cprintf("readsize=%d",readsize);
	return readsize;
	//panic("devfile_read not implemented");
}
  800c80:	89 d8                	mov    %ebx,%eax
  800c82:	83 c4 14             	add    $0x14,%esp
  800c85:	5b                   	pop    %ebx
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	53                   	push   %ebx
  800c8c:	83 ec 14             	sub    $0x14,%esp
  800c8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800c92:	89 1c 24             	mov    %ebx,(%esp)
  800c95:	e8 06 08 00 00       	call   8014a0 <strlen>
  800c9a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
  800c9f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ca4:	7f 21                	jg     800cc7 <remove+0x3f>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  800ca6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800caa:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  800cb1:	e8 3b 08 00 00       	call   8014f1 <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  800cb6:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbb:	b8 07 00 00 00       	mov    $0x7,%eax
  800cc0:	e8 0f fe ff ff       	call   800ad4 <fsipc>
  800cc5:	89 c2                	mov    %eax,%edx
}
  800cc7:	89 d0                	mov    %edx,%eax
  800cc9:	83 c4 14             	add    $0x14,%esp
  800ccc:	5b                   	pop    %ebx
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    

00800ccf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	53                   	push   %ebx
  800cd3:	83 ec 24             	sub    $0x24,%esp
	// file descriptor.

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;
	if((r=fd_alloc(&fd))<0){
  800cd6:	8d 45 f8             	lea    -0x8(%ebp),%eax
  800cd9:	89 04 24             	mov    %eax,(%esp)
  800cdc:	e8 0a f8 ff ff       	call   8004eb <fd_alloc>
  800ce1:	89 c3                	mov    %eax,%ebx
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	79 18                	jns    800cff <open+0x30>
		fd_close(fd,0);
  800ce7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800cee:	00 
  800cef:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800cf2:	89 04 24             	mov    %eax,(%esp)
  800cf5:	e8 94 fb ff ff       	call   80088e <fd_close>
  800cfa:	e9 b4 00 00 00       	jmp    800db3 <open+0xe4>
		return r;
	}
	cprintf("open:fd=%x\n",fd);
  800cff:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d02:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d06:	c7 04 24 59 1e 80 00 	movl   $0x801e59,(%esp)
  800d0d:	e8 77 01 00 00       	call   800e89 <cprintf>
	strcpy(fsipcbuf.open.req_path,path);
  800d12:	8b 45 08             	mov    0x8(%ebp),%eax
  800d15:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d19:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  800d20:	e8 cc 07 00 00       	call   8014f1 <strcpy>
	fsipcbuf.open.req_omode=mode;
  800d25:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d28:	a3 00 34 80 00       	mov    %eax,0x803400
	if((r=fsipc(FSREQ_OPEN,(void*)fd))<0)
  800d2d:	8b 55 f8             	mov    -0x8(%ebp),%edx
  800d30:	b8 01 00 00 00       	mov    $0x1,%eax
  800d35:	e8 9a fd ff ff       	call   800ad4 <fsipc>
  800d3a:	89 c3                	mov    %eax,%ebx
  800d3c:	85 c0                	test   %eax,%eax
  800d3e:	79 15                	jns    800d55 <open+0x86>
	{
		fd_close(fd,1);
  800d40:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800d47:	00 
  800d48:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d4b:	89 04 24             	mov    %eax,(%esp)
  800d4e:	e8 3b fb ff ff       	call   80088e <fd_close>
  800d53:	eb 5e                	jmp    800db3 <open+0xe4>
		return r;	
	}
	if((r=sys_page_map(0,(void*)fd,0,(void*)fd,PTE_P | PTE_W | PTE_U))<0)
  800d55:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d58:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800d5f:	00 
  800d60:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d64:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d6b:	00 
  800d6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d77:	e8 bc f5 ff ff       	call   800338 <sys_page_map>
  800d7c:	89 c3                	mov    %eax,%ebx
  800d7e:	85 c0                	test   %eax,%eax
  800d80:	79 15                	jns    800d97 <open+0xc8>
	{
		fd_close(fd,1);
  800d82:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800d89:	00 
  800d8a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d8d:	89 04 24             	mov    %eax,(%esp)
  800d90:	e8 f9 fa ff ff       	call   80088e <fd_close>
  800d95:	eb 1c                	jmp    800db3 <open+0xe4>
		return r;
	}
	//INDEX2DATA(fd->fd_file.id);
	cprintf("fileid=%x\n",fd->fd_file.id);
  800d97:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d9a:	8b 40 0c             	mov    0xc(%eax),%eax
  800d9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800da1:	c7 04 24 65 1e 80 00 	movl   $0x801e65,(%esp)
  800da8:	e8 dc 00 00 00       	call   800e89 <cprintf>
	return fd->fd_file.id;
  800dad:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800db0:	8b 58 0c             	mov    0xc(%eax),%ebx
	//panic("open not implemented");
}
  800db3:	89 d8                	mov    %ebx,%eax
  800db5:	83 c4 24             	add    $0x24,%esp
  800db8:	5b                   	pop    %ebx
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    
	...

00800dbc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800dc2:	8d 45 14             	lea    0x14(%ebp),%eax
  800dc5:	89 45 fc             	mov    %eax,-0x4(%ebp)

	// Print the panic message
	if (argv0)
  800dc8:	a1 24 50 80 00       	mov    0x805024,%eax
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	74 10                	je     800de1 <_panic+0x25>
		cprintf("%s: ", argv0);
  800dd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dd5:	c7 04 24 70 1e 80 00 	movl   $0x801e70,(%esp)
  800ddc:	e8 a8 00 00 00       	call   800e89 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  800de1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800de8:	8b 45 08             	mov    0x8(%ebp),%eax
  800deb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800def:	a1 00 50 80 00       	mov    0x805000,%eax
  800df4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800df8:	c7 04 24 75 1e 80 00 	movl   $0x801e75,(%esp)
  800dff:	e8 85 00 00 00       	call   800e89 <cprintf>
	vcprintf(fmt, ap);
  800e04:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800e07:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e0b:	8b 45 10             	mov    0x10(%ebp),%eax
  800e0e:	89 04 24             	mov    %eax,(%esp)
  800e11:	e8 12 00 00 00       	call   800e28 <vcprintf>
	cprintf("\n");
  800e16:	c7 04 24 57 1e 80 00 	movl   $0x801e57,(%esp)
  800e1d:	e8 67 00 00 00       	call   800e89 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e22:	cc                   	int3   
  800e23:	eb fd                	jmp    800e22 <_panic+0x66>
  800e25:	00 00                	add    %al,(%eax)
	...

00800e28 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800e31:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  800e38:	00 00 00 
	b.cnt = 0;
  800e3b:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  800e42:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800e45:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e48:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e53:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800e59:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e5d:	c7 04 24 a6 0e 80 00 	movl   $0x800ea6,(%esp)
  800e64:	e8 cc 01 00 00       	call   801035 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800e69:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
  800e6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e73:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  800e79:	89 04 24             	mov    %eax,(%esp)
  800e7c:	e8 77 f2 ff ff       	call   8000f8 <sys_cputs>
  800e81:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  800e87:	c9                   	leave  
  800e88:	c3                   	ret    

00800e89 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800e8f:	8d 45 0c             	lea    0xc(%ebp),%eax
  800e92:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800e95:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e99:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9c:	89 04 24             	mov    %eax,(%esp)
  800e9f:	e8 84 ff ff ff       	call   800e28 <vcprintf>
	va_end(ap);

	return cnt;
}
  800ea4:	c9                   	leave  
  800ea5:	c3                   	ret    

00800ea6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	53                   	push   %ebx
  800eaa:	83 ec 14             	sub    $0x14,%esp
  800ead:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800eb0:	8b 03                	mov    (%ebx),%eax
  800eb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb5:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800eb9:	83 c0 01             	add    $0x1,%eax
  800ebc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800ebe:	3d ff 00 00 00       	cmp    $0xff,%eax
  800ec3:	75 19                	jne    800ede <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800ec5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800ecc:	00 
  800ecd:	8d 43 08             	lea    0x8(%ebx),%eax
  800ed0:	89 04 24             	mov    %eax,(%esp)
  800ed3:	e8 20 f2 ff ff       	call   8000f8 <sys_cputs>
		b->idx = 0;
  800ed8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800ede:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800ee2:	83 c4 14             	add    $0x14,%esp
  800ee5:	5b                   	pop    %ebx
  800ee6:	5d                   	pop    %ebp
  800ee7:	c3                   	ret    
	...

00800ef0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	57                   	push   %edi
  800ef4:	56                   	push   %esi
  800ef5:	53                   	push   %ebx
  800ef6:	83 ec 3c             	sub    $0x3c,%esp
  800ef9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800efc:	89 d7                	mov    %edx,%edi
  800efe:	8b 45 08             	mov    0x8(%ebp),%eax
  800f01:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f04:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f07:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800f0a:	8b 55 10             	mov    0x10(%ebp),%edx
  800f0d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800f10:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800f13:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  800f1a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800f1d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  800f20:	72 14                	jb     800f36 <printnum+0x46>
  800f22:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f25:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800f28:	76 0c                	jbe    800f36 <printnum+0x46>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800f2a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800f2d:	83 eb 01             	sub    $0x1,%ebx
  800f30:	85 db                	test   %ebx,%ebx
  800f32:	7f 57                	jg     800f8b <printnum+0x9b>
  800f34:	eb 64                	jmp    800f9a <printnum+0xaa>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800f36:	89 74 24 10          	mov    %esi,0x10(%esp)
  800f3a:	8b 45 14             	mov    0x14(%ebp),%eax
  800f3d:	83 e8 01             	sub    $0x1,%eax
  800f40:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f44:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f48:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800f4c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800f50:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f53:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800f56:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f5a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f5e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f61:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800f64:	89 04 24             	mov    %eax,(%esp)
  800f67:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f6b:	e8 60 0b 00 00       	call   801ad0 <__udivdi3>
  800f70:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f74:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800f78:	89 04 24             	mov    %eax,(%esp)
  800f7b:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f7f:	89 fa                	mov    %edi,%edx
  800f81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f84:	e8 67 ff ff ff       	call   800ef0 <printnum>
  800f89:	eb 0f                	jmp    800f9a <printnum+0xaa>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800f8b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f8f:	89 34 24             	mov    %esi,(%esp)
  800f92:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800f95:	83 eb 01             	sub    $0x1,%ebx
  800f98:	75 f1                	jne    800f8b <printnum+0x9b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800f9a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f9e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fa2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800fa5:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800fa8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fb0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800fb3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800fb6:	89 04 24             	mov    %eax,(%esp)
  800fb9:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fbd:	e8 3e 0c 00 00       	call   801c00 <__umoddi3>
  800fc2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fc6:	0f be 80 91 1e 80 00 	movsbl 0x801e91(%eax),%eax
  800fcd:	89 04 24             	mov    %eax,(%esp)
  800fd0:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800fd3:	83 c4 3c             	add    $0x3c,%esp
  800fd6:	5b                   	pop    %ebx
  800fd7:	5e                   	pop    %esi
  800fd8:	5f                   	pop    %edi
  800fd9:	5d                   	pop    %ebp
  800fda:	c3                   	ret    

00800fdb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800fdb:	55                   	push   %ebp
  800fdc:	89 e5                	mov    %esp,%ebp
  800fde:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800fe0:	83 fa 01             	cmp    $0x1,%edx
  800fe3:	7e 0e                	jle    800ff3 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  800fe5:	8b 10                	mov    (%eax),%edx
  800fe7:	8d 42 08             	lea    0x8(%edx),%eax
  800fea:	89 01                	mov    %eax,(%ecx)
  800fec:	8b 02                	mov    (%edx),%eax
  800fee:	8b 52 04             	mov    0x4(%edx),%edx
  800ff1:	eb 22                	jmp    801015 <getuint+0x3a>
	else if (lflag)
  800ff3:	85 d2                	test   %edx,%edx
  800ff5:	74 10                	je     801007 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800ff7:	8b 10                	mov    (%eax),%edx
  800ff9:	8d 42 04             	lea    0x4(%edx),%eax
  800ffc:	89 01                	mov    %eax,(%ecx)
  800ffe:	8b 02                	mov    (%edx),%eax
  801000:	ba 00 00 00 00       	mov    $0x0,%edx
  801005:	eb 0e                	jmp    801015 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  801007:	8b 10                	mov    (%eax),%edx
  801009:	8d 42 04             	lea    0x4(%edx),%eax
  80100c:	89 01                	mov    %eax,(%ecx)
  80100e:	8b 02                	mov    (%edx),%eax
  801010:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801015:	5d                   	pop    %ebp
  801016:	c3                   	ret    

00801017 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801017:	55                   	push   %ebp
  801018:	89 e5                	mov    %esp,%ebp
  80101a:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  80101d:	83 42 08 01          	addl   $0x1,0x8(%edx)
	if (b->buf < b->ebuf)
  801021:	8b 02                	mov    (%edx),%eax
  801023:	3b 42 04             	cmp    0x4(%edx),%eax
  801026:	73 0b                	jae    801033 <sprintputch+0x1c>
		*b->buf++ = ch;
  801028:	0f b6 4d 08          	movzbl 0x8(%ebp),%ecx
  80102c:	88 08                	mov    %cl,(%eax)
  80102e:	83 c0 01             	add    $0x1,%eax
  801031:	89 02                	mov    %eax,(%edx)
}
  801033:	5d                   	pop    %ebp
  801034:	c3                   	ret    

00801035 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
  801038:	57                   	push   %edi
  801039:	56                   	push   %esi
  80103a:	53                   	push   %ebx
  80103b:	83 ec 3c             	sub    $0x3c,%esp
  80103e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801041:	eb 18                	jmp    80105b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801043:	84 c0                	test   %al,%al
  801045:	0f 84 9f 03 00 00    	je     8013ea <vprintfmt+0x3b5>
				return;
			putch(ch, putdat);
  80104b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80104e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801052:	0f b6 c0             	movzbl %al,%eax
  801055:	89 04 24             	mov    %eax,(%esp)
  801058:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80105b:	0f b6 03             	movzbl (%ebx),%eax
  80105e:	83 c3 01             	add    $0x1,%ebx
  801061:	3c 25                	cmp    $0x25,%al
  801063:	75 de                	jne    801043 <vprintfmt+0xe>
  801065:	b9 00 00 00 00       	mov    $0x0,%ecx
  80106a:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
  801071:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  801076:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80107d:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
  801081:	eb 07                	jmp    80108a <vprintfmt+0x55>
  801083:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80108a:	0f b6 13             	movzbl (%ebx),%edx
  80108d:	83 c3 01             	add    $0x1,%ebx
  801090:	8d 42 dd             	lea    -0x23(%edx),%eax
  801093:	3c 55                	cmp    $0x55,%al
  801095:	0f 87 22 03 00 00    	ja     8013bd <vprintfmt+0x388>
  80109b:	0f b6 c0             	movzbl %al,%eax
  80109e:	ff 24 85 e0 1f 80 00 	jmp    *0x801fe0(,%eax,4)
  8010a5:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
  8010a9:	eb df                	jmp    80108a <vprintfmt+0x55>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8010ab:	0f b6 c2             	movzbl %dl,%eax
  8010ae:	8d 78 d0             	lea    -0x30(%eax),%edi
				ch = *fmt;
  8010b1:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  8010b4:	8d 42 d0             	lea    -0x30(%edx),%eax
  8010b7:	83 f8 09             	cmp    $0x9,%eax
  8010ba:	76 08                	jbe    8010c4 <vprintfmt+0x8f>
  8010bc:	eb 39                	jmp    8010f7 <vprintfmt+0xc2>
  8010be:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
  8010c2:	eb c6                	jmp    80108a <vprintfmt+0x55>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8010c4:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  8010c7:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  8010ca:	8d 7c 42 d0          	lea    -0x30(%edx,%eax,2),%edi
				ch = *fmt;
  8010ce:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  8010d1:	8d 42 d0             	lea    -0x30(%edx),%eax
  8010d4:	83 f8 09             	cmp    $0x9,%eax
  8010d7:	77 1e                	ja     8010f7 <vprintfmt+0xc2>
  8010d9:	eb e9                	jmp    8010c4 <vprintfmt+0x8f>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8010db:	8b 55 14             	mov    0x14(%ebp),%edx
  8010de:	8d 42 04             	lea    0x4(%edx),%eax
  8010e1:	89 45 14             	mov    %eax,0x14(%ebp)
  8010e4:	8b 3a                	mov    (%edx),%edi
  8010e6:	eb 0f                	jmp    8010f7 <vprintfmt+0xc2>
			goto process_precision;

		case '.':
			if (width < 0)
  8010e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8010ec:	79 9c                	jns    80108a <vprintfmt+0x55>
  8010ee:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8010f5:	eb 93                	jmp    80108a <vprintfmt+0x55>
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8010f7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8010fb:	90                   	nop    
  8010fc:	8d 74 26 00          	lea    0x0(%esi),%esi
  801100:	79 88                	jns    80108a <vprintfmt+0x55>
  801102:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801105:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80110a:	e9 7b ff ff ff       	jmp    80108a <vprintfmt+0x55>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80110f:	83 c1 01             	add    $0x1,%ecx
  801112:	e9 73 ff ff ff       	jmp    80108a <vprintfmt+0x55>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801117:	8b 45 14             	mov    0x14(%ebp),%eax
  80111a:	8d 50 04             	lea    0x4(%eax),%edx
  80111d:	89 55 14             	mov    %edx,0x14(%ebp)
  801120:	8b 55 0c             	mov    0xc(%ebp),%edx
  801123:	89 54 24 04          	mov    %edx,0x4(%esp)
  801127:	8b 00                	mov    (%eax),%eax
  801129:	89 04 24             	mov    %eax,(%esp)
  80112c:	ff 55 08             	call   *0x8(%ebp)
  80112f:	e9 27 ff ff ff       	jmp    80105b <vprintfmt+0x26>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801134:	8b 55 14             	mov    0x14(%ebp),%edx
  801137:	8d 42 04             	lea    0x4(%edx),%eax
  80113a:	89 45 14             	mov    %eax,0x14(%ebp)
  80113d:	8b 02                	mov    (%edx),%eax
  80113f:	89 c2                	mov    %eax,%edx
  801141:	c1 fa 1f             	sar    $0x1f,%edx
  801144:	31 d0                	xor    %edx,%eax
  801146:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  801148:	83 f8 0f             	cmp    $0xf,%eax
  80114b:	7f 0b                	jg     801158 <vprintfmt+0x123>
  80114d:	8b 14 85 40 21 80 00 	mov    0x802140(,%eax,4),%edx
  801154:	85 d2                	test   %edx,%edx
  801156:	75 23                	jne    80117b <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  801158:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80115c:	c7 44 24 08 a2 1e 80 	movl   $0x801ea2,0x8(%esp)
  801163:	00 
  801164:	8b 45 0c             	mov    0xc(%ebp),%eax
  801167:	89 44 24 04          	mov    %eax,0x4(%esp)
  80116b:	8b 55 08             	mov    0x8(%ebp),%edx
  80116e:	89 14 24             	mov    %edx,(%esp)
  801171:	e8 ff 02 00 00       	call   801475 <printfmt>
  801176:	e9 e0 fe ff ff       	jmp    80105b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80117b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80117f:	c7 44 24 08 ab 1e 80 	movl   $0x801eab,0x8(%esp)
  801186:	00 
  801187:	8b 45 0c             	mov    0xc(%ebp),%eax
  80118a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80118e:	8b 55 08             	mov    0x8(%ebp),%edx
  801191:	89 14 24             	mov    %edx,(%esp)
  801194:	e8 dc 02 00 00       	call   801475 <printfmt>
  801199:	e9 bd fe ff ff       	jmp    80105b <vprintfmt+0x26>
  80119e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8011a1:	89 f9                	mov    %edi,%ecx
  8011a3:	89 5d ec             	mov    %ebx,-0x14(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8011a6:	8b 55 14             	mov    0x14(%ebp),%edx
  8011a9:	8d 42 04             	lea    0x4(%edx),%eax
  8011ac:	89 45 14             	mov    %eax,0x14(%ebp)
  8011af:	8b 12                	mov    (%edx),%edx
  8011b1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8011b4:	85 d2                	test   %edx,%edx
  8011b6:	75 07                	jne    8011bf <vprintfmt+0x18a>
  8011b8:	c7 45 dc ae 1e 80 00 	movl   $0x801eae,-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8011bf:	85 f6                	test   %esi,%esi
  8011c1:	7e 41                	jle    801204 <vprintfmt+0x1cf>
  8011c3:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  8011c7:	74 3b                	je     801204 <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
  8011c9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8011cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011d0:	89 04 24             	mov    %eax,(%esp)
  8011d3:	e8 e8 02 00 00       	call   8014c0 <strnlen>
  8011d8:	29 c6                	sub    %eax,%esi
  8011da:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8011dd:	85 f6                	test   %esi,%esi
  8011df:	7e 23                	jle    801204 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8011e1:	0f be 55 eb          	movsbl -0x15(%ebp),%edx
  8011e5:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8011e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ef:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8011f2:	89 14 24             	mov    %edx,(%esp)
  8011f5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8011f8:	83 ee 01             	sub    $0x1,%esi
  8011fb:	75 eb                	jne    8011e8 <vprintfmt+0x1b3>
  8011fd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801204:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801207:	0f b6 02             	movzbl (%edx),%eax
  80120a:	0f be d0             	movsbl %al,%edx
  80120d:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801210:	84 c0                	test   %al,%al
  801212:	75 42                	jne    801256 <vprintfmt+0x221>
  801214:	eb 49                	jmp    80125f <vprintfmt+0x22a>
				if (altflag && (ch < ' ' || ch > '~'))
  801216:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80121a:	74 1b                	je     801237 <vprintfmt+0x202>
  80121c:	8d 42 e0             	lea    -0x20(%edx),%eax
  80121f:	83 f8 5e             	cmp    $0x5e,%eax
  801222:	76 13                	jbe    801237 <vprintfmt+0x202>
					putch('?', putdat);
  801224:	8b 45 0c             	mov    0xc(%ebp),%eax
  801227:	89 44 24 04          	mov    %eax,0x4(%esp)
  80122b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801232:	ff 55 08             	call   *0x8(%ebp)
  801235:	eb 0d                	jmp    801244 <vprintfmt+0x20f>
				else
					putch(ch, putdat);
  801237:	8b 45 0c             	mov    0xc(%ebp),%eax
  80123a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123e:	89 14 24             	mov    %edx,(%esp)
  801241:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801244:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  801248:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80124c:	83 c6 01             	add    $0x1,%esi
  80124f:	84 c0                	test   %al,%al
  801251:	74 0c                	je     80125f <vprintfmt+0x22a>
  801253:	0f be d0             	movsbl %al,%edx
  801256:	85 ff                	test   %edi,%edi
  801258:	78 bc                	js     801216 <vprintfmt+0x1e1>
  80125a:	83 ef 01             	sub    $0x1,%edi
  80125d:	79 b7                	jns    801216 <vprintfmt+0x1e1>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80125f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801263:	0f 8e f2 fd ff ff    	jle    80105b <vprintfmt+0x26>
				putch(' ', putdat);
  801269:	8b 55 0c             	mov    0xc(%ebp),%edx
  80126c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801270:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801277:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80127a:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  80127e:	75 e9                	jne    801269 <vprintfmt+0x234>
  801280:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  801283:	e9 d3 fd ff ff       	jmp    80105b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801288:	83 f9 01             	cmp    $0x1,%ecx
  80128b:	90                   	nop    
  80128c:	8d 74 26 00          	lea    0x0(%esi),%esi
  801290:	7e 10                	jle    8012a2 <vprintfmt+0x26d>
		return va_arg(*ap, long long);
  801292:	8b 55 14             	mov    0x14(%ebp),%edx
  801295:	8d 42 08             	lea    0x8(%edx),%eax
  801298:	89 45 14             	mov    %eax,0x14(%ebp)
  80129b:	8b 32                	mov    (%edx),%esi
  80129d:	8b 7a 04             	mov    0x4(%edx),%edi
  8012a0:	eb 2a                	jmp    8012cc <vprintfmt+0x297>
	else if (lflag)
  8012a2:	85 c9                	test   %ecx,%ecx
  8012a4:	74 14                	je     8012ba <vprintfmt+0x285>
		return va_arg(*ap, long);
  8012a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8012a9:	8d 50 04             	lea    0x4(%eax),%edx
  8012ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8012af:	8b 00                	mov    (%eax),%eax
  8012b1:	89 c6                	mov    %eax,%esi
  8012b3:	89 c7                	mov    %eax,%edi
  8012b5:	c1 ff 1f             	sar    $0x1f,%edi
  8012b8:	eb 12                	jmp    8012cc <vprintfmt+0x297>
	else
		return va_arg(*ap, int);
  8012ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8012bd:	8d 50 04             	lea    0x4(%eax),%edx
  8012c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8012c3:	8b 00                	mov    (%eax),%eax
  8012c5:	89 c6                	mov    %eax,%esi
  8012c7:	89 c7                	mov    %eax,%edi
  8012c9:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8012cc:	89 f2                	mov    %esi,%edx
  8012ce:	89 f9                	mov    %edi,%ecx
  8012d0:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
			if ((long long) num < 0) {
  8012d7:	85 ff                	test   %edi,%edi
  8012d9:	0f 89 9b 00 00 00    	jns    80137a <vprintfmt+0x345>
				putch('-', putdat);
  8012df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8012ed:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8012f0:	89 f2                	mov    %esi,%edx
  8012f2:	89 f9                	mov    %edi,%ecx
  8012f4:	f7 da                	neg    %edx
  8012f6:	83 d1 00             	adc    $0x0,%ecx
  8012f9:	f7 d9                	neg    %ecx
  8012fb:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  801302:	eb 76                	jmp    80137a <vprintfmt+0x345>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801304:	89 ca                	mov    %ecx,%edx
  801306:	8d 45 14             	lea    0x14(%ebp),%eax
  801309:	e8 cd fc ff ff       	call   800fdb <getuint>
  80130e:	89 d1                	mov    %edx,%ecx
  801310:	89 c2                	mov    %eax,%edx
  801312:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  801319:	eb 5f                	jmp    80137a <vprintfmt+0x345>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			num = getuint(&ap,lflag);
  80131b:	89 ca                	mov    %ecx,%edx
  80131d:	8d 45 14             	lea    0x14(%ebp),%eax
  801320:	e8 b6 fc ff ff       	call   800fdb <getuint>
  801325:	e9 31 fd ff ff       	jmp    80105b <vprintfmt+0x26>
			base=8;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80132a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80132d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801331:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801338:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80133b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80133e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801342:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801349:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  80134c:	8b 55 14             	mov    0x14(%ebp),%edx
  80134f:	8d 42 04             	lea    0x4(%edx),%eax
  801352:	89 45 14             	mov    %eax,0x14(%ebp)
  801355:	8b 12                	mov    (%edx),%edx
  801357:	b9 00 00 00 00       	mov    $0x0,%ecx
  80135c:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  801363:	eb 15                	jmp    80137a <vprintfmt+0x345>
			base = 16;
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801365:	89 ca                	mov    %ecx,%edx
  801367:	8d 45 14             	lea    0x14(%ebp),%eax
  80136a:	e8 6c fc ff ff       	call   800fdb <getuint>
  80136f:	89 d1                	mov    %edx,%ecx
  801371:	89 c2                	mov    %eax,%edx
  801373:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80137a:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  80137e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801382:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801385:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801389:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80138c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801390:	89 14 24             	mov    %edx,(%esp)
  801393:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801397:	8b 55 0c             	mov    0xc(%ebp),%edx
  80139a:	8b 45 08             	mov    0x8(%ebp),%eax
  80139d:	e8 4e fb ff ff       	call   800ef0 <printnum>
  8013a2:	e9 b4 fc ff ff       	jmp    80105b <vprintfmt+0x26>
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8013a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013ae:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8013b5:	ff 55 08             	call   *0x8(%ebp)
  8013b8:	e9 9e fc ff ff       	jmp    80105b <vprintfmt+0x26>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8013bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8013cb:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8013ce:	83 eb 01             	sub    $0x1,%ebx
  8013d1:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8013d5:	0f 84 80 fc ff ff    	je     80105b <vprintfmt+0x26>
  8013db:	83 eb 01             	sub    $0x1,%ebx
  8013de:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8013e2:	0f 84 73 fc ff ff    	je     80105b <vprintfmt+0x26>
  8013e8:	eb f1                	jmp    8013db <vprintfmt+0x3a6>
				/* do nothing */;
			break;
		}
	}
}
  8013ea:	83 c4 3c             	add    $0x3c,%esp
  8013ed:	5b                   	pop    %ebx
  8013ee:	5e                   	pop    %esi
  8013ef:	5f                   	pop    %edi
  8013f0:	5d                   	pop    %ebp
  8013f1:	c3                   	ret    

008013f2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8013f2:	55                   	push   %ebp
  8013f3:	89 e5                	mov    %esp,%ebp
  8013f5:	83 ec 28             	sub    $0x28,%esp
  8013f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8013fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8013fe:	85 d2                	test   %edx,%edx
  801400:	74 04                	je     801406 <vsnprintf+0x14>
  801402:	85 c0                	test   %eax,%eax
  801404:	7f 07                	jg     80140d <vsnprintf+0x1b>
  801406:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80140b:	eb 3b                	jmp    801448 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80140d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  801414:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
  801418:	89 45 f8             	mov    %eax,-0x8(%ebp)
  80141b:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80141e:	8b 45 14             	mov    0x14(%ebp),%eax
  801421:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801425:	8b 45 10             	mov    0x10(%ebp),%eax
  801428:	89 44 24 08          	mov    %eax,0x8(%esp)
  80142c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801433:	c7 04 24 17 10 80 00 	movl   $0x801017,(%esp)
  80143a:	e8 f6 fb ff ff       	call   801035 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80143f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801442:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801445:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  801448:	c9                   	leave  
  801449:	c3                   	ret    

0080144a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80144a:	55                   	push   %ebp
  80144b:	89 e5                	mov    %esp,%ebp
  80144d:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801450:	8d 45 14             	lea    0x14(%ebp),%eax
  801453:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  801456:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80145a:	8b 45 10             	mov    0x10(%ebp),%eax
  80145d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801461:	8b 45 0c             	mov    0xc(%ebp),%eax
  801464:	89 44 24 04          	mov    %eax,0x4(%esp)
  801468:	8b 45 08             	mov    0x8(%ebp),%eax
  80146b:	89 04 24             	mov    %eax,(%esp)
  80146e:	e8 7f ff ff ff       	call   8013f2 <vsnprintf>
	va_end(ap);

	return rc;
}
  801473:	c9                   	leave  
  801474:	c3                   	ret    

00801475 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801475:	55                   	push   %ebp
  801476:	89 e5                	mov    %esp,%ebp
  801478:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  80147b:	8d 45 14             	lea    0x14(%ebp),%eax
  80147e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  801481:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801485:	8b 45 10             	mov    0x10(%ebp),%eax
  801488:	89 44 24 08          	mov    %eax,0x8(%esp)
  80148c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80148f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801493:	8b 45 08             	mov    0x8(%ebp),%eax
  801496:	89 04 24             	mov    %eax,(%esp)
  801499:	e8 97 fb ff ff       	call   801035 <vprintfmt>
	va_end(ap);
}
  80149e:	c9                   	leave  
  80149f:	c3                   	ret    

008014a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8014a0:	55                   	push   %ebp
  8014a1:	89 e5                	mov    %esp,%ebp
  8014a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8014a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ab:	80 3a 00             	cmpb   $0x0,(%edx)
  8014ae:	74 0e                	je     8014be <strlen+0x1e>
  8014b0:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8014b5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8014b8:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  8014bc:	75 f7                	jne    8014b5 <strlen+0x15>
		n++;
	return n;
}
  8014be:	5d                   	pop    %ebp
  8014bf:	c3                   	ret    

008014c0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8014c9:	85 d2                	test   %edx,%edx
  8014cb:	74 19                	je     8014e6 <strnlen+0x26>
  8014cd:	80 39 00             	cmpb   $0x0,(%ecx)
  8014d0:	74 14                	je     8014e6 <strnlen+0x26>
  8014d2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8014d7:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8014da:	39 d0                	cmp    %edx,%eax
  8014dc:	74 0d                	je     8014eb <strnlen+0x2b>
  8014de:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  8014e2:	74 07                	je     8014eb <strnlen+0x2b>
  8014e4:	eb f1                	jmp    8014d7 <strnlen+0x17>
  8014e6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8014eb:	5d                   	pop    %ebp
  8014ec:	8d 74 26 00          	lea    0x0(%esi),%esi
  8014f0:	c3                   	ret    

008014f1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8014f1:	55                   	push   %ebp
  8014f2:	89 e5                	mov    %esp,%ebp
  8014f4:	53                   	push   %ebx
  8014f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8014f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014fb:	89 da                	mov    %ebx,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8014fd:	0f b6 01             	movzbl (%ecx),%eax
  801500:	88 02                	mov    %al,(%edx)
  801502:	83 c2 01             	add    $0x1,%edx
  801505:	83 c1 01             	add    $0x1,%ecx
  801508:	84 c0                	test   %al,%al
  80150a:	75 f1                	jne    8014fd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80150c:	89 d8                	mov    %ebx,%eax
  80150e:	5b                   	pop    %ebx
  80150f:	5d                   	pop    %ebp
  801510:	c3                   	ret    

00801511 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801511:	55                   	push   %ebp
  801512:	89 e5                	mov    %esp,%ebp
  801514:	57                   	push   %edi
  801515:	56                   	push   %esi
  801516:	53                   	push   %ebx
  801517:	8b 7d 08             	mov    0x8(%ebp),%edi
  80151a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80151d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801520:	85 f6                	test   %esi,%esi
  801522:	74 1c                	je     801540 <strncpy+0x2f>
  801524:	89 fa                	mov    %edi,%edx
  801526:	bb 00 00 00 00       	mov    $0x0,%ebx
		*dst++ = *src;
  80152b:	0f b6 01             	movzbl (%ecx),%eax
  80152e:	88 02                	mov    %al,(%edx)
  801530:	83 c2 01             	add    $0x1,%edx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801533:	80 39 01             	cmpb   $0x1,(%ecx)
  801536:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801539:	83 c3 01             	add    $0x1,%ebx
  80153c:	39 f3                	cmp    %esi,%ebx
  80153e:	75 eb                	jne    80152b <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801540:	89 f8                	mov    %edi,%eax
  801542:	5b                   	pop    %ebx
  801543:	5e                   	pop    %esi
  801544:	5f                   	pop    %edi
  801545:	5d                   	pop    %ebp
  801546:	c3                   	ret    

00801547 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801547:	55                   	push   %ebp
  801548:	89 e5                	mov    %esp,%ebp
  80154a:	56                   	push   %esi
  80154b:	53                   	push   %ebx
  80154c:	8b 75 08             	mov    0x8(%ebp),%esi
  80154f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801552:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801555:	89 f0                	mov    %esi,%eax
  801557:	85 d2                	test   %edx,%edx
  801559:	74 2c                	je     801587 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  80155b:	89 d3                	mov    %edx,%ebx
  80155d:	83 eb 01             	sub    $0x1,%ebx
  801560:	74 20                	je     801582 <strlcpy+0x3b>
  801562:	0f b6 11             	movzbl (%ecx),%edx
  801565:	84 d2                	test   %dl,%dl
  801567:	74 19                	je     801582 <strlcpy+0x3b>
  801569:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  80156b:	88 10                	mov    %dl,(%eax)
  80156d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801570:	83 eb 01             	sub    $0x1,%ebx
  801573:	74 0f                	je     801584 <strlcpy+0x3d>
  801575:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
  801579:	83 c1 01             	add    $0x1,%ecx
  80157c:	84 d2                	test   %dl,%dl
  80157e:	74 04                	je     801584 <strlcpy+0x3d>
  801580:	eb e9                	jmp    80156b <strlcpy+0x24>
  801582:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801584:	c6 00 00             	movb   $0x0,(%eax)
  801587:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  801589:	5b                   	pop    %ebx
  80158a:	5e                   	pop    %esi
  80158b:	5d                   	pop    %ebp
  80158c:	c3                   	ret    

0080158d <pstrcpy>:
//i386-disassember Lab3:your code here pstrcpy()
void pstrcpy(char *buf, int buf_size, const char *str)
{   
  80158d:	55                   	push   %ebp
  80158e:	89 e5                	mov    %esp,%ebp
  801590:	56                   	push   %esi
  801591:	53                   	push   %ebx
  801592:	8b 75 08             	mov    0x8(%ebp),%esi
  801595:	8b 45 0c             	mov    0xc(%ebp),%eax
  801598:	8b 55 10             	mov    0x10(%ebp),%edx
    int c;
    char *q = buf;

    if (buf_size <= 0)
  80159b:	85 c0                	test   %eax,%eax
  80159d:	7e 2e                	jle    8015cd <pstrcpy+0x40>
        return;

    for(;;) {
        c = *str++;
  80159f:	0f b6 0a             	movzbl (%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  8015a2:	84 c9                	test   %cl,%cl
  8015a4:	74 22                	je     8015c8 <pstrcpy+0x3b>
  8015a6:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
  8015aa:	89 f0                	mov    %esi,%eax
  8015ac:	39 de                	cmp    %ebx,%esi
  8015ae:	72 09                	jb     8015b9 <pstrcpy+0x2c>
  8015b0:	eb 16                	jmp    8015c8 <pstrcpy+0x3b>
  8015b2:	83 c2 01             	add    $0x1,%edx
  8015b5:	39 d8                	cmp    %ebx,%eax
  8015b7:	73 11                	jae    8015ca <pstrcpy+0x3d>
            break;
        *q++ = c;
  8015b9:	88 08                	mov    %cl,(%eax)
  8015bb:	83 c0 01             	add    $0x1,%eax

    if (buf_size <= 0)
        return;

    for(;;) {
        c = *str++;
  8015be:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
        if (c == 0 || q >= buf + buf_size - 1)
  8015c2:	84 c9                	test   %cl,%cl
  8015c4:	75 ec                	jne    8015b2 <pstrcpy+0x25>
  8015c6:	eb 02                	jmp    8015ca <pstrcpy+0x3d>
  8015c8:	89 f0                	mov    %esi,%eax
            break;
        *q++ = c;
    }
    *q = '\0';
  8015ca:	c6 00 00             	movb   $0x0,(%eax)
}
  8015cd:	5b                   	pop    %ebx
  8015ce:	5e                   	pop    %esi
  8015cf:	5d                   	pop    %ebp
  8015d0:	c3                   	ret    

008015d1 <strcmp>:
int
strcmp(const char *p, const char *q)
{
  8015d1:	55                   	push   %ebp
  8015d2:	89 e5                	mov    %esp,%ebp
  8015d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8015d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  8015da:	0f b6 02             	movzbl (%edx),%eax
  8015dd:	84 c0                	test   %al,%al
  8015df:	74 16                	je     8015f7 <strcmp+0x26>
  8015e1:	3a 01                	cmp    (%ecx),%al
  8015e3:	75 12                	jne    8015f7 <strcmp+0x26>
		p++, q++;
  8015e5:	83 c1 01             	add    $0x1,%ecx
    *q = '\0';
}
int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8015e8:	0f b6 42 01          	movzbl 0x1(%edx),%eax
  8015ec:	84 c0                	test   %al,%al
  8015ee:	74 07                	je     8015f7 <strcmp+0x26>
  8015f0:	83 c2 01             	add    $0x1,%edx
  8015f3:	3a 01                	cmp    (%ecx),%al
  8015f5:	74 ee                	je     8015e5 <strcmp+0x14>
  8015f7:	0f b6 c0             	movzbl %al,%eax
  8015fa:	0f b6 11             	movzbl (%ecx),%edx
  8015fd:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8015ff:	5d                   	pop    %ebp
  801600:	c3                   	ret    

00801601 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801601:	55                   	push   %ebp
  801602:	89 e5                	mov    %esp,%ebp
  801604:	53                   	push   %ebx
  801605:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801608:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80160b:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80160e:	85 d2                	test   %edx,%edx
  801610:	74 2d                	je     80163f <strncmp+0x3e>
  801612:	0f b6 01             	movzbl (%ecx),%eax
  801615:	84 c0                	test   %al,%al
  801617:	74 1a                	je     801633 <strncmp+0x32>
  801619:	3a 03                	cmp    (%ebx),%al
  80161b:	75 16                	jne    801633 <strncmp+0x32>
  80161d:	83 ea 01             	sub    $0x1,%edx
  801620:	74 1d                	je     80163f <strncmp+0x3e>
		n--, p++, q++;
  801622:	83 c1 01             	add    $0x1,%ecx
  801625:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801628:	0f b6 01             	movzbl (%ecx),%eax
  80162b:	84 c0                	test   %al,%al
  80162d:	74 04                	je     801633 <strncmp+0x32>
  80162f:	3a 03                	cmp    (%ebx),%al
  801631:	74 ea                	je     80161d <strncmp+0x1c>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801633:	0f b6 11             	movzbl (%ecx),%edx
  801636:	0f b6 03             	movzbl (%ebx),%eax
  801639:	29 c2                	sub    %eax,%edx
  80163b:	89 d0                	mov    %edx,%eax
  80163d:	eb 05                	jmp    801644 <strncmp+0x43>
  80163f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801644:	5b                   	pop    %ebx
  801645:	5d                   	pop    %ebp
  801646:	c3                   	ret    

00801647 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	8b 45 08             	mov    0x8(%ebp),%eax
  80164d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801651:	0f b6 10             	movzbl (%eax),%edx
  801654:	84 d2                	test   %dl,%dl
  801656:	74 14                	je     80166c <strchr+0x25>
		if (*s == c)
  801658:	38 ca                	cmp    %cl,%dl
  80165a:	75 06                	jne    801662 <strchr+0x1b>
  80165c:	eb 13                	jmp    801671 <strchr+0x2a>
  80165e:	38 ca                	cmp    %cl,%dl
  801660:	74 0f                	je     801671 <strchr+0x2a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801662:	83 c0 01             	add    $0x1,%eax
  801665:	0f b6 10             	movzbl (%eax),%edx
  801668:	84 d2                	test   %dl,%dl
  80166a:	75 f2                	jne    80165e <strchr+0x17>
  80166c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  801671:	5d                   	pop    %ebp
  801672:	c3                   	ret    

00801673 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	8b 45 08             	mov    0x8(%ebp),%eax
  801679:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80167d:	0f b6 10             	movzbl (%eax),%edx
  801680:	84 d2                	test   %dl,%dl
  801682:	74 18                	je     80169c <strfind+0x29>
		if (*s == c)
  801684:	38 ca                	cmp    %cl,%dl
  801686:	75 0a                	jne    801692 <strfind+0x1f>
  801688:	eb 12                	jmp    80169c <strfind+0x29>
  80168a:	38 ca                	cmp    %cl,%dl
  80168c:	8d 74 26 00          	lea    0x0(%esi),%esi
  801690:	74 0a                	je     80169c <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801692:	83 c0 01             	add    $0x1,%eax
  801695:	0f b6 10             	movzbl (%eax),%edx
  801698:	84 d2                	test   %dl,%dl
  80169a:	75 ee                	jne    80168a <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  80169c:	5d                   	pop    %ebp
  80169d:	c3                   	ret    

0080169e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80169e:	55                   	push   %ebp
  80169f:	89 e5                	mov    %esp,%ebp
  8016a1:	83 ec 08             	sub    $0x8,%esp
  8016a4:	89 1c 24             	mov    %ebx,(%esp)
  8016a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8016ab:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  8016b1:	85 db                	test   %ebx,%ebx
  8016b3:	74 36                	je     8016eb <memset+0x4d>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8016b5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8016bb:	75 26                	jne    8016e3 <memset+0x45>
  8016bd:	f6 c3 03             	test   $0x3,%bl
  8016c0:	75 21                	jne    8016e3 <memset+0x45>
		c &= 0xFF;
  8016c2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8016c6:	89 d0                	mov    %edx,%eax
  8016c8:	c1 e0 18             	shl    $0x18,%eax
  8016cb:	89 d1                	mov    %edx,%ecx
  8016cd:	c1 e1 10             	shl    $0x10,%ecx
  8016d0:	09 c8                	or     %ecx,%eax
  8016d2:	09 d0                	or     %edx,%eax
  8016d4:	c1 e2 08             	shl    $0x8,%edx
  8016d7:	09 d0                	or     %edx,%eax
  8016d9:	89 d9                	mov    %ebx,%ecx
  8016db:	c1 e9 02             	shr    $0x2,%ecx
  8016de:	fc                   	cld    
  8016df:	f3 ab                	rep stos %eax,%es:(%edi)
  8016e1:	eb 08                	jmp    8016eb <memset+0x4d>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8016e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e6:	89 d9                	mov    %ebx,%ecx
  8016e8:	fc                   	cld    
  8016e9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8016eb:	89 f8                	mov    %edi,%eax
  8016ed:	8b 1c 24             	mov    (%esp),%ebx
  8016f0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8016f4:	89 ec                	mov    %ebp,%esp
  8016f6:	5d                   	pop    %ebp
  8016f7:	c3                   	ret    

008016f8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	83 ec 08             	sub    $0x8,%esp
  8016fe:	89 34 24             	mov    %esi,(%esp)
  801701:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801705:	8b 45 08             	mov    0x8(%ebp),%eax
  801708:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  80170b:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80170e:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  801710:	39 c6                	cmp    %eax,%esi
  801712:	73 38                	jae    80174c <memmove+0x54>
  801714:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801717:	39 d0                	cmp    %edx,%eax
  801719:	73 31                	jae    80174c <memmove+0x54>
		s += n;
		d += n;
  80171b:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80171e:	f6 c2 03             	test   $0x3,%dl
  801721:	75 1d                	jne    801740 <memmove+0x48>
  801723:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801729:	75 15                	jne    801740 <memmove+0x48>
  80172b:	f6 c1 03             	test   $0x3,%cl
  80172e:	66 90                	xchg   %ax,%ax
  801730:	75 0e                	jne    801740 <memmove+0x48>
			asm volatile("std; rep movsl\n"
  801732:	8d 7e fc             	lea    -0x4(%esi),%edi
  801735:	8d 72 fc             	lea    -0x4(%edx),%esi
  801738:	c1 e9 02             	shr    $0x2,%ecx
  80173b:	fd                   	std    
  80173c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80173e:	eb 09                	jmp    801749 <memmove+0x51>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801740:	8d 7e ff             	lea    -0x1(%esi),%edi
  801743:	8d 72 ff             	lea    -0x1(%edx),%esi
  801746:	fd                   	std    
  801747:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801749:	fc                   	cld    
  80174a:	eb 21                	jmp    80176d <memmove+0x75>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80174c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801752:	75 16                	jne    80176a <memmove+0x72>
  801754:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80175a:	75 0e                	jne    80176a <memmove+0x72>
  80175c:	f6 c1 03             	test   $0x3,%cl
  80175f:	90                   	nop    
  801760:	75 08                	jne    80176a <memmove+0x72>
			asm volatile("cld; rep movsl\n"
  801762:	c1 e9 02             	shr    $0x2,%ecx
  801765:	fc                   	cld    
  801766:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801768:	eb 03                	jmp    80176d <memmove+0x75>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80176a:	fc                   	cld    
  80176b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80176d:	8b 34 24             	mov    (%esp),%esi
  801770:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801774:	89 ec                	mov    %ebp,%esp
  801776:	5d                   	pop    %ebp
  801777:	c3                   	ret    

00801778 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80177e:	8b 45 10             	mov    0x10(%ebp),%eax
  801781:	89 44 24 08          	mov    %eax,0x8(%esp)
  801785:	8b 45 0c             	mov    0xc(%ebp),%eax
  801788:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178c:	8b 45 08             	mov    0x8(%ebp),%eax
  80178f:	89 04 24             	mov    %eax,(%esp)
  801792:	e8 61 ff ff ff       	call   8016f8 <memmove>
}
  801797:	c9                   	leave  
  801798:	c3                   	ret    

00801799 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801799:	55                   	push   %ebp
  80179a:	89 e5                	mov    %esp,%ebp
  80179c:	57                   	push   %edi
  80179d:	56                   	push   %esi
  80179e:	53                   	push   %ebx
  80179f:	83 ec 04             	sub    $0x4,%esp
  8017a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8017a8:	8b 55 10             	mov    0x10(%ebp),%edx
  8017ab:	83 ea 01             	sub    $0x1,%edx
  8017ae:	83 fa ff             	cmp    $0xffffffff,%edx
  8017b1:	74 47                	je     8017fa <memcmp+0x61>
		if (*s1 != *s2)
  8017b3:	0f b6 30             	movzbl (%eax),%esi
  8017b6:	0f b6 39             	movzbl (%ecx),%edi
			return (int) *s1 - (int) *s2;
  8017b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  8017bc:	89 f0                	mov    %esi,%eax
  8017be:	89 fb                	mov    %edi,%ebx
  8017c0:	38 d8                	cmp    %bl,%al
  8017c2:	74 2e                	je     8017f2 <memcmp+0x59>
  8017c4:	eb 1c                	jmp    8017e2 <memcmp+0x49>
  8017c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c9:	0f b6 70 01          	movzbl 0x1(%eax),%esi
  8017cd:	0f b6 79 01          	movzbl 0x1(%ecx),%edi
  8017d1:	83 c0 01             	add    $0x1,%eax
  8017d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8017d7:	83 c1 01             	add    $0x1,%ecx
  8017da:	89 f3                	mov    %esi,%ebx
  8017dc:	89 f8                	mov    %edi,%eax
  8017de:	38 c3                	cmp    %al,%bl
  8017e0:	74 10                	je     8017f2 <memcmp+0x59>
			return (int) *s1 - (int) *s2;
  8017e2:	89 f1                	mov    %esi,%ecx
  8017e4:	0f b6 d1             	movzbl %cl,%edx
  8017e7:	89 fb                	mov    %edi,%ebx
  8017e9:	0f b6 c3             	movzbl %bl,%eax
  8017ec:	29 c2                	sub    %eax,%edx
  8017ee:	89 d0                	mov    %edx,%eax
  8017f0:	eb 0d                	jmp    8017ff <memcmp+0x66>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8017f2:	83 ea 01             	sub    $0x1,%edx
  8017f5:	83 fa ff             	cmp    $0xffffffff,%edx
  8017f8:	75 cc                	jne    8017c6 <memcmp+0x2d>
  8017fa:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  8017ff:	83 c4 04             	add    $0x4,%esp
  801802:	5b                   	pop    %ebx
  801803:	5e                   	pop    %esi
  801804:	5f                   	pop    %edi
  801805:	5d                   	pop    %ebp
  801806:	c3                   	ret    

00801807 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801807:	55                   	push   %ebp
  801808:	89 e5                	mov    %esp,%ebp
  80180a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80180d:	89 c1                	mov    %eax,%ecx
  80180f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
  801812:	39 c8                	cmp    %ecx,%eax
  801814:	73 15                	jae    80182b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  801816:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
  80181a:	38 10                	cmp    %dl,(%eax)
  80181c:	75 06                	jne    801824 <memfind+0x1d>
  80181e:	eb 0b                	jmp    80182b <memfind+0x24>
  801820:	38 10                	cmp    %dl,(%eax)
  801822:	74 07                	je     80182b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801824:	83 c0 01             	add    $0x1,%eax
  801827:	39 c8                	cmp    %ecx,%eax
  801829:	75 f5                	jne    801820 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80182b:	5d                   	pop    %ebp
  80182c:	8d 74 26 00          	lea    0x0(%esi),%esi
  801830:	c3                   	ret    

00801831 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801831:	55                   	push   %ebp
  801832:	89 e5                	mov    %esp,%ebp
  801834:	57                   	push   %edi
  801835:	56                   	push   %esi
  801836:	53                   	push   %ebx
  801837:	83 ec 04             	sub    $0x4,%esp
  80183a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80183d:	8b 75 10             	mov    0x10(%ebp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801840:	0f b6 01             	movzbl (%ecx),%eax
  801843:	3c 20                	cmp    $0x20,%al
  801845:	74 04                	je     80184b <strtol+0x1a>
  801847:	3c 09                	cmp    $0x9,%al
  801849:	75 0e                	jne    801859 <strtol+0x28>
		s++;
  80184b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80184e:	0f b6 01             	movzbl (%ecx),%eax
  801851:	3c 20                	cmp    $0x20,%al
  801853:	74 f6                	je     80184b <strtol+0x1a>
  801855:	3c 09                	cmp    $0x9,%al
  801857:	74 f2                	je     80184b <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801859:	3c 2b                	cmp    $0x2b,%al
  80185b:	75 0c                	jne    801869 <strtol+0x38>
		s++;
  80185d:	83 c1 01             	add    $0x1,%ecx
  801860:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801867:	eb 15                	jmp    80187e <strtol+0x4d>
	else if (*s == '-')
  801869:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801870:	3c 2d                	cmp    $0x2d,%al
  801872:	75 0a                	jne    80187e <strtol+0x4d>
		s++, neg = 1;
  801874:	83 c1 01             	add    $0x1,%ecx
  801877:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80187e:	85 f6                	test   %esi,%esi
  801880:	0f 94 c0             	sete   %al
  801883:	74 05                	je     80188a <strtol+0x59>
  801885:	83 fe 10             	cmp    $0x10,%esi
  801888:	75 18                	jne    8018a2 <strtol+0x71>
  80188a:	80 39 30             	cmpb   $0x30,(%ecx)
  80188d:	75 13                	jne    8018a2 <strtol+0x71>
  80188f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801893:	75 0d                	jne    8018a2 <strtol+0x71>
		s += 2, base = 16;
  801895:	83 c1 02             	add    $0x2,%ecx
  801898:	be 10 00 00 00       	mov    $0x10,%esi
  80189d:	8d 76 00             	lea    0x0(%esi),%esi
  8018a0:	eb 1b                	jmp    8018bd <strtol+0x8c>
	else if (base == 0 && s[0] == '0')
  8018a2:	85 f6                	test   %esi,%esi
  8018a4:	75 0e                	jne    8018b4 <strtol+0x83>
  8018a6:	80 39 30             	cmpb   $0x30,(%ecx)
  8018a9:	75 09                	jne    8018b4 <strtol+0x83>
		s++, base = 8;
  8018ab:	83 c1 01             	add    $0x1,%ecx
  8018ae:	66 be 08 00          	mov    $0x8,%si
  8018b2:	eb 09                	jmp    8018bd <strtol+0x8c>
	else if (base == 0)
  8018b4:	84 c0                	test   %al,%al
  8018b6:	74 05                	je     8018bd <strtol+0x8c>
  8018b8:	be 0a 00 00 00       	mov    $0xa,%esi
  8018bd:	bf 00 00 00 00       	mov    $0x0,%edi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8018c2:	0f b6 11             	movzbl (%ecx),%edx
  8018c5:	89 d3                	mov    %edx,%ebx
  8018c7:	8d 42 d0             	lea    -0x30(%edx),%eax
  8018ca:	3c 09                	cmp    $0x9,%al
  8018cc:	77 08                	ja     8018d6 <strtol+0xa5>
			dig = *s - '0';
  8018ce:	0f be c2             	movsbl %dl,%eax
  8018d1:	8d 50 d0             	lea    -0x30(%eax),%edx
  8018d4:	eb 1c                	jmp    8018f2 <strtol+0xc1>
		else if (*s >= 'a' && *s <= 'z')
  8018d6:	8d 43 9f             	lea    -0x61(%ebx),%eax
  8018d9:	3c 19                	cmp    $0x19,%al
  8018db:	77 08                	ja     8018e5 <strtol+0xb4>
			dig = *s - 'a' + 10;
  8018dd:	0f be c2             	movsbl %dl,%eax
  8018e0:	8d 50 a9             	lea    -0x57(%eax),%edx
  8018e3:	eb 0d                	jmp    8018f2 <strtol+0xc1>
		else if (*s >= 'A' && *s <= 'Z')
  8018e5:	8d 43 bf             	lea    -0x41(%ebx),%eax
  8018e8:	3c 19                	cmp    $0x19,%al
  8018ea:	77 17                	ja     801903 <strtol+0xd2>
			dig = *s - 'A' + 10;
  8018ec:	0f be c2             	movsbl %dl,%eax
  8018ef:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  8018f2:	39 f2                	cmp    %esi,%edx
  8018f4:	7d 0d                	jge    801903 <strtol+0xd2>
			break;
		s++, val = (val * base) + dig;
  8018f6:	83 c1 01             	add    $0x1,%ecx
  8018f9:	89 f8                	mov    %edi,%eax
  8018fb:	0f af c6             	imul   %esi,%eax
  8018fe:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  801901:	eb bf                	jmp    8018c2 <strtol+0x91>
		// we don't properly detect overflow!
	}
  801903:	89 f8                	mov    %edi,%eax

	if (endptr)
  801905:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801909:	74 05                	je     801910 <strtol+0xdf>
		*endptr = (char *) s;
  80190b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80190e:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  801910:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801914:	74 04                	je     80191a <strtol+0xe9>
  801916:	89 c7                	mov    %eax,%edi
  801918:	f7 df                	neg    %edi
}
  80191a:	89 f8                	mov    %edi,%eax
  80191c:	83 c4 04             	add    $0x4,%esp
  80191f:	5b                   	pop    %ebx
  801920:	5e                   	pop    %esi
  801921:	5f                   	pop    %edi
  801922:	5d                   	pop    %ebp
  801923:	c3                   	ret    
	...

00801930 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	57                   	push   %edi
  801934:	56                   	push   %esi
  801935:	53                   	push   %ebx
  801936:	83 ec 1c             	sub    $0x1c,%esp
  801939:	8b 75 08             	mov    0x8(%ebp),%esi
  80193c:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int r,i=0;
	env = &envs[ENVX(sys_getenvid())];
  80193f:	e8 e5 ea ff ff       	call   800429 <sys_getenvid>
  801944:	25 ff 03 00 00       	and    $0x3ff,%eax
  801949:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80194c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801951:	a3 20 50 80 00       	mov    %eax,0x805020
	do{
		//cprintf("%x send value to %x\n",env->env_id,to_env);
		env = &envs[ENVX(sys_getenvid())];
  801956:	e8 ce ea ff ff       	call   800429 <sys_getenvid>
  80195b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801960:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801963:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801968:	a3 20 50 80 00       	mov    %eax,0x805020
		if(env->env_id==to_env){
  80196d:	8b 40 4c             	mov    0x4c(%eax),%eax
  801970:	39 f0                	cmp    %esi,%eax
  801972:	75 0e                	jne    801982 <ipc_send+0x52>
			cprintf("send:the reciver is sender\n");
  801974:	c7 04 24 a0 21 80 00 	movl   $0x8021a0,(%esp)
  80197b:	e8 09 f5 ff ff       	call   800e89 <cprintf>
  801980:	eb 5a                	jmp    8019dc <ipc_send+0xac>
			return;
		}
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
  801982:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801986:	8b 45 10             	mov    0x10(%ebp),%eax
  801989:	89 44 24 08          	mov    %eax,0x8(%esp)
  80198d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801990:	89 44 24 04          	mov    %eax,0x4(%esp)
  801994:	89 34 24             	mov    %esi,(%esp)
  801997:	e8 ec e7 ff ff       	call   800188 <sys_ipc_try_send>
  80199c:	89 c3                	mov    %eax,%ebx
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	79 25                	jns    8019c7 <ipc_send+0x97>
		{	
			if(r!=-E_IPC_NOT_RECV)
  8019a2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8019a5:	74 2b                	je     8019d2 <ipc_send+0xa2>
				panic("send error:%e",r);
  8019a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019ab:	c7 44 24 08 bc 21 80 	movl   $0x8021bc,0x8(%esp)
  8019b2:	00 
  8019b3:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8019ba:	00 
  8019bb:	c7 04 24 ca 21 80 00 	movl   $0x8021ca,(%esp)
  8019c2:	e8 f5 f3 ff ff       	call   800dbc <_panic>
		}
			sys_yield();
  8019c7:	e8 29 ea ff ff       	call   8003f5 <sys_yield>
		
	}while(r!=0);
  8019cc:	85 db                	test   %ebx,%ebx
  8019ce:	75 86                	jne    801956 <ipc_send+0x26>
  8019d0:	eb 0a                	jmp    8019dc <ipc_send+0xac>
		if((r=sys_ipc_try_send(to_env,val,pg,perm))<0)
		{	
			if(r!=-E_IPC_NOT_RECV)
				panic("send error:%e",r);
		}
			sys_yield();
  8019d2:	e8 1e ea ff ff       	call   8003f5 <sys_yield>
  8019d7:	e9 7a ff ff ff       	jmp    801956 <ipc_send+0x26>
		
	}while(r!=0);
	return;
	//panic("ipc_send not implemented");
}
  8019dc:	83 c4 1c             	add    $0x1c,%esp
  8019df:	5b                   	pop    %ebx
  8019e0:	5e                   	pop    %esi
  8019e1:	5f                   	pop    %edi
  8019e2:	5d                   	pop    %ebp
  8019e3:	c3                   	ret    

008019e4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019e4:	55                   	push   %ebp
  8019e5:	89 e5                	mov    %esp,%ebp
  8019e7:	57                   	push   %edi
  8019e8:	56                   	push   %esi
  8019e9:	53                   	push   %ebx
  8019ea:	83 ec 0c             	sub    $0xc,%esp
  8019ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8019f0:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	void *dstva=NULL;
	if(pg)
		dstva=pg;
	env = &envs[ENVX(sys_getenvid())];
  8019f3:	e8 31 ea ff ff       	call   800429 <sys_getenvid>
  8019f8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8019fd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a00:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801a05:	a3 20 50 80 00       	mov    %eax,0x805020
	if(from_env_store&&(env->env_id==*from_env_store))
  801a0a:	85 f6                	test   %esi,%esi
  801a0c:	74 29                	je     801a37 <ipc_recv+0x53>
  801a0e:	8b 40 4c             	mov    0x4c(%eax),%eax
  801a11:	3b 06                	cmp    (%esi),%eax
  801a13:	75 22                	jne    801a37 <ipc_recv+0x53>
	{
		*from_env_store=0;
  801a15:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  801a1b:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("send:the reciver is sender\n");
  801a21:	c7 04 24 a0 21 80 00 	movl   $0x8021a0,(%esp)
  801a28:	e8 5c f4 ff ff       	call   800e89 <cprintf>
  801a2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a32:	e9 8a 00 00 00       	jmp    801ac1 <ipc_recv+0xdd>
		return 0;
	}
	env = &envs[ENVX(sys_getenvid())];
  801a37:	e8 ed e9 ff ff       	call   800429 <sys_getenvid>
  801a3c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a41:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a44:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801a49:	a3 20 50 80 00       	mov    %eax,0x805020
	if((r=sys_ipc_recv(dstva))<0)
  801a4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a51:	89 04 24             	mov    %eax,(%esp)
  801a54:	e8 d2 e6 ff ff       	call   80012b <sys_ipc_recv>
  801a59:	89 c3                	mov    %eax,%ebx
  801a5b:	85 c0                	test   %eax,%eax
  801a5d:	79 1a                	jns    801a79 <ipc_recv+0x95>
	{
		*from_env_store=0;
  801a5f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store=0;
  801a65:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		cprintf("reciver failed\n");
  801a6b:	c7 04 24 d4 21 80 00 	movl   $0x8021d4,(%esp)
  801a72:	e8 12 f4 ff ff       	call   800e89 <cprintf>
  801a77:	eb 48                	jmp    801ac1 <ipc_recv+0xdd>
		return r;
	}
	else{//接收成功
		env = &envs[ENVX(sys_getenvid())];
  801a79:	e8 ab e9 ff ff       	call   800429 <sys_getenvid>
  801a7e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a83:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a86:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801a8b:	a3 20 50 80 00       	mov    %eax,0x805020
		if(from_env_store)
  801a90:	85 f6                	test   %esi,%esi
  801a92:	74 05                	je     801a99 <ipc_recv+0xb5>
			*from_env_store=env->env_ipc_from;	
  801a94:	8b 40 74             	mov    0x74(%eax),%eax
  801a97:	89 06                	mov    %eax,(%esi)
		if(perm_store)
  801a99:	85 ff                	test   %edi,%edi
  801a9b:	74 0a                	je     801aa7 <ipc_recv+0xc3>
			*perm_store=env->env_ipc_perm;
  801a9d:	a1 20 50 80 00       	mov    0x805020,%eax
  801aa2:	8b 40 78             	mov    0x78(%eax),%eax
  801aa5:	89 07                	mov    %eax,(%edi)
		env = &envs[ENVX(sys_getenvid())];
  801aa7:	e8 7d e9 ff ff       	call   800429 <sys_getenvid>
  801aac:	25 ff 03 00 00       	and    $0x3ff,%eax
  801ab1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ab4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ab9:	a3 20 50 80 00       	mov    %eax,0x805020
		return env->env_ipc_value;
  801abe:	8b 58 70             	mov    0x70(%eax),%ebx
	}
	//panic("ipc_recv not implemented");
	return 0;
}
  801ac1:	89 d8                	mov    %ebx,%eax
  801ac3:	83 c4 0c             	add    $0xc,%esp
  801ac6:	5b                   	pop    %ebx
  801ac7:	5e                   	pop    %esi
  801ac8:	5f                   	pop    %edi
  801ac9:	5d                   	pop    %ebp
  801aca:	c3                   	ret    
  801acb:	00 00                	add    %al,(%eax)
  801acd:	00 00                	add    %al,(%eax)
	...

00801ad0 <__udivdi3>:
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	57                   	push   %edi
  801ad4:	56                   	push   %esi
  801ad5:	83 ec 18             	sub    $0x18,%esp
  801ad8:	8b 45 10             	mov    0x10(%ebp),%eax
  801adb:	8b 55 14             	mov    0x14(%ebp),%edx
  801ade:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ae1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801ae4:	89 c1                	mov    %eax,%ecx
  801ae6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae9:	85 d2                	test   %edx,%edx
  801aeb:	89 d7                	mov    %edx,%edi
  801aed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801af0:	75 1e                	jne    801b10 <__udivdi3+0x40>
  801af2:	39 f1                	cmp    %esi,%ecx
  801af4:	0f 86 8d 00 00 00    	jbe    801b87 <__udivdi3+0xb7>
  801afa:	89 f2                	mov    %esi,%edx
  801afc:	31 f6                	xor    %esi,%esi
  801afe:	f7 f1                	div    %ecx
  801b00:	89 c1                	mov    %eax,%ecx
  801b02:	89 c8                	mov    %ecx,%eax
  801b04:	89 f2                	mov    %esi,%edx
  801b06:	83 c4 18             	add    $0x18,%esp
  801b09:	5e                   	pop    %esi
  801b0a:	5f                   	pop    %edi
  801b0b:	5d                   	pop    %ebp
  801b0c:	c3                   	ret    
  801b0d:	8d 76 00             	lea    0x0(%esi),%esi
  801b10:	39 f2                	cmp    %esi,%edx
  801b12:	0f 87 a8 00 00 00    	ja     801bc0 <__udivdi3+0xf0>
  801b18:	0f bd c2             	bsr    %edx,%eax
  801b1b:	83 f0 1f             	xor    $0x1f,%eax
  801b1e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801b21:	0f 84 89 00 00 00    	je     801bb0 <__udivdi3+0xe0>
  801b27:	b8 20 00 00 00       	mov    $0x20,%eax
  801b2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b2f:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801b32:	89 c1                	mov    %eax,%ecx
  801b34:	d3 ea                	shr    %cl,%edx
  801b36:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  801b3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801b3d:	89 f8                	mov    %edi,%eax
  801b3f:	8b 7d f4             	mov    -0xc(%ebp),%edi
  801b42:	d3 e0                	shl    %cl,%eax
  801b44:	09 c2                	or     %eax,%edx
  801b46:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b49:	d3 e7                	shl    %cl,%edi
  801b4b:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801b4f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801b52:	89 f2                	mov    %esi,%edx
  801b54:	d3 e8                	shr    %cl,%eax
  801b56:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  801b5a:	d3 e2                	shl    %cl,%edx
  801b5c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801b60:	09 d0                	or     %edx,%eax
  801b62:	d3 ee                	shr    %cl,%esi
  801b64:	89 f2                	mov    %esi,%edx
  801b66:	f7 75 e4             	divl   -0x1c(%ebp)
  801b69:	89 d1                	mov    %edx,%ecx
  801b6b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  801b6e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b71:	f7 e7                	mul    %edi
  801b73:	39 d1                	cmp    %edx,%ecx
  801b75:	89 c6                	mov    %eax,%esi
  801b77:	72 70                	jb     801be9 <__udivdi3+0x119>
  801b79:	39 ca                	cmp    %ecx,%edx
  801b7b:	74 5f                	je     801bdc <__udivdi3+0x10c>
  801b7d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801b80:	31 f6                	xor    %esi,%esi
  801b82:	e9 7b ff ff ff       	jmp    801b02 <__udivdi3+0x32>
  801b87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b8a:	85 c0                	test   %eax,%eax
  801b8c:	75 0c                	jne    801b9a <__udivdi3+0xca>
  801b8e:	b8 01 00 00 00       	mov    $0x1,%eax
  801b93:	31 d2                	xor    %edx,%edx
  801b95:	f7 75 f4             	divl   -0xc(%ebp)
  801b98:	89 c1                	mov    %eax,%ecx
  801b9a:	89 f0                	mov    %esi,%eax
  801b9c:	89 fa                	mov    %edi,%edx
  801b9e:	f7 f1                	div    %ecx
  801ba0:	89 c6                	mov    %eax,%esi
  801ba2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ba5:	f7 f1                	div    %ecx
  801ba7:	89 c1                	mov    %eax,%ecx
  801ba9:	e9 54 ff ff ff       	jmp    801b02 <__udivdi3+0x32>
  801bae:	66 90                	xchg   %ax,%ax
  801bb0:	39 d6                	cmp    %edx,%esi
  801bb2:	77 1c                	ja     801bd0 <__udivdi3+0x100>
  801bb4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bb7:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  801bba:	73 14                	jae    801bd0 <__udivdi3+0x100>
  801bbc:	8d 74 26 00          	lea    0x0(%esi),%esi
  801bc0:	31 c9                	xor    %ecx,%ecx
  801bc2:	31 f6                	xor    %esi,%esi
  801bc4:	e9 39 ff ff ff       	jmp    801b02 <__udivdi3+0x32>
  801bc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  801bd0:	b9 01 00 00 00       	mov    $0x1,%ecx
  801bd5:	31 f6                	xor    %esi,%esi
  801bd7:	e9 26 ff ff ff       	jmp    801b02 <__udivdi3+0x32>
  801bdc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801bdf:	0f b6 4d e8          	movzbl -0x18(%ebp),%ecx
  801be3:	d3 e0                	shl    %cl,%eax
  801be5:	39 c6                	cmp    %eax,%esi
  801be7:	76 94                	jbe    801b7d <__udivdi3+0xad>
  801be9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801bec:	31 f6                	xor    %esi,%esi
  801bee:	83 e9 01             	sub    $0x1,%ecx
  801bf1:	e9 0c ff ff ff       	jmp    801b02 <__udivdi3+0x32>
	...

00801c00 <__umoddi3>:
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	57                   	push   %edi
  801c04:	56                   	push   %esi
  801c05:	83 ec 30             	sub    $0x30,%esp
  801c08:	8b 45 10             	mov    0x10(%ebp),%eax
  801c0b:	8b 55 14             	mov    0x14(%ebp),%edx
  801c0e:	8b 75 08             	mov    0x8(%ebp),%esi
  801c11:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c14:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c17:	89 c1                	mov    %eax,%ecx
  801c19:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801c1c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801c1f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  801c26:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801c2d:	89 fa                	mov    %edi,%edx
  801c2f:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  801c32:	85 c0                	test   %eax,%eax
  801c34:	89 75 f0             	mov    %esi,-0x10(%ebp)
  801c37:	89 7d e0             	mov    %edi,-0x20(%ebp)
  801c3a:	75 14                	jne    801c50 <__umoddi3+0x50>
  801c3c:	39 f9                	cmp    %edi,%ecx
  801c3e:	76 60                	jbe    801ca0 <__umoddi3+0xa0>
  801c40:	89 f0                	mov    %esi,%eax
  801c42:	f7 f1                	div    %ecx
  801c44:	89 55 d0             	mov    %edx,-0x30(%ebp)
  801c47:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801c4e:	eb 10                	jmp    801c60 <__umoddi3+0x60>
  801c50:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801c53:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  801c56:	76 18                	jbe    801c70 <__umoddi3+0x70>
  801c58:	89 75 d0             	mov    %esi,-0x30(%ebp)
  801c5b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801c5e:	66 90                	xchg   %ax,%ax
  801c60:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801c63:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801c66:	83 c4 30             	add    $0x30,%esp
  801c69:	5e                   	pop    %esi
  801c6a:	5f                   	pop    %edi
  801c6b:	5d                   	pop    %ebp
  801c6c:	c3                   	ret    
  801c6d:	8d 76 00             	lea    0x0(%esi),%esi
  801c70:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
  801c74:	83 f0 1f             	xor    $0x1f,%eax
  801c77:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801c7a:	75 46                	jne    801cc2 <__umoddi3+0xc2>
  801c7c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801c7f:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  801c82:	0f 87 c9 00 00 00    	ja     801d51 <__umoddi3+0x151>
  801c88:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  801c8b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  801c8e:	0f 83 bd 00 00 00    	jae    801d51 <__umoddi3+0x151>
  801c94:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801c97:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  801c9a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  801c9d:	eb c1                	jmp    801c60 <__umoddi3+0x60>
  801c9f:	90                   	nop    
  801ca0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ca3:	85 c0                	test   %eax,%eax
  801ca5:	75 0c                	jne    801cb3 <__umoddi3+0xb3>
  801ca7:	b8 01 00 00 00       	mov    $0x1,%eax
  801cac:	31 d2                	xor    %edx,%edx
  801cae:	f7 75 ec             	divl   -0x14(%ebp)
  801cb1:	89 c1                	mov    %eax,%ecx
  801cb3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cb6:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801cb9:	f7 f1                	div    %ecx
  801cbb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cbe:	f7 f1                	div    %ecx
  801cc0:	eb 82                	jmp    801c44 <__umoddi3+0x44>
  801cc2:	b8 20 00 00 00       	mov    $0x20,%eax
  801cc7:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801cca:	2b 45 d8             	sub    -0x28(%ebp),%eax
  801ccd:	8b 75 ec             	mov    -0x14(%ebp),%esi
  801cd0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801cd3:	89 c1                	mov    %eax,%ecx
  801cd5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801cd8:	d3 ea                	shr    %cl,%edx
  801cda:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801cdd:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  801ce1:	d3 e0                	shl    %cl,%eax
  801ce3:	09 c2                	or     %eax,%edx
  801ce5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ce8:	d3 e6                	shl    %cl,%esi
  801cea:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  801cee:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801cf1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801cf4:	d3 e8                	shr    %cl,%eax
  801cf6:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  801cfa:	d3 e2                	shl    %cl,%edx
  801cfc:	09 d0                	or     %edx,%eax
  801cfe:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801d01:	d3 e7                	shl    %cl,%edi
  801d03:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  801d07:	d3 ea                	shr    %cl,%edx
  801d09:	f7 75 f4             	divl   -0xc(%ebp)
  801d0c:	89 55 cc             	mov    %edx,-0x34(%ebp)
  801d0f:	f7 e6                	mul    %esi
  801d11:	39 55 cc             	cmp    %edx,-0x34(%ebp)
  801d14:	72 53                	jb     801d69 <__umoddi3+0x169>
  801d16:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  801d19:	74 4a                	je     801d65 <__umoddi3+0x165>
  801d1b:	90                   	nop    
  801d1c:	8d 74 26 00          	lea    0x0(%esi),%esi
  801d20:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801d23:	29 c7                	sub    %eax,%edi
  801d25:	19 d1                	sbb    %edx,%ecx
  801d27:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801d2a:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  801d2e:	89 fa                	mov    %edi,%edx
  801d30:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801d33:	d3 ea                	shr    %cl,%edx
  801d35:	0f b6 4d dc          	movzbl -0x24(%ebp),%ecx
  801d39:	d3 e0                	shl    %cl,%eax
  801d3b:	0f b6 4d d8          	movzbl -0x28(%ebp),%ecx
  801d3f:	09 c2                	or     %eax,%edx
  801d41:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801d44:	89 55 d0             	mov    %edx,-0x30(%ebp)
  801d47:	d3 e8                	shr    %cl,%eax
  801d49:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801d4c:	e9 0f ff ff ff       	jmp    801c60 <__umoddi3+0x60>
  801d51:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801d54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d57:	2b 45 ec             	sub    -0x14(%ebp),%eax
  801d5a:	1b 55 e8             	sbb    -0x18(%ebp),%edx
  801d5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801d60:	e9 2f ff ff ff       	jmp    801c94 <__umoddi3+0x94>
  801d65:	39 f8                	cmp    %edi,%eax
  801d67:	76 b7                	jbe    801d20 <__umoddi3+0x120>
  801d69:	29 f0                	sub    %esi,%eax
  801d6b:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801d6e:	eb b0                	jmp    801d20 <__umoddi3+0x120>
