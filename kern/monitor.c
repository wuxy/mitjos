// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>
#include <inc/mmu.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/trap.h>
#include <kern/pmap.h>
#include <kern/disas.h>
#define CMDBUF_SIZE	80	// enough for one VGA text line


struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "backtrace","Run a stack backtrace",mon_backtrace},
	{ "continue","Continue to execute from the current breakpoint",mon_continue},
	{ "stepi","Sigle-step one instruction at a time",mon_stepi},
	{ "showmappings","Display the physical page mappings at virtual addresses xxxx",mon_showmappings},
        { "permission","Change the permission of the physical page mappings at virtual addresses xxxx,D A PCD PWT U W P",mon_permission},
	{ "dumpx", "Dump the contents of a range of memory given virtual address range", mon_dumpx },
	{ "dumpxp", "Dump the contents of a range of memory given physical address range", mon_dumpxp },
};
#define NCOMMANDS (sizeof(commands)/sizeof(commands[0]))

unsigned read_eip();

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		(end-_start+1023)/1024);
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	int i;
	struct Eipdebuginfo eipinfo;
        uint32_t ebp,eip,arg[5];
        ebp=read_ebp();

        cprintf("Stack backtrace :\n");
        do{

		eip=*((uint32_t *)ebp+1);
                for(i=0;i<5;i++)
                        arg[i]=*((uint32_t *)ebp+i+2);
                cprintf("ebp %08x eip %08x ",ebp,eip);
                cprintf("args %08x %08x %08x %08x %08x\n",arg[0],arg[1],arg[2],arg[3],arg[4]);
                if(!debuginfo_eip((uintptr_t)eip,&eipinfo))
                {
                        cprintf("       %s:%d: %.*s+%d\n",eipinfo.eip_file,eipinfo.eip_line,eipinfo.eip_fn_namelen,eipinfo.eip_fn_name,eip-eipinfo.eip_fn_addr);
                }
                ebp=*(uint32_t *)ebp;
        }while(ebp!=0);
	return 0;
}
uint32_t
getva(char *vastring,int base)
{
	uint32_t va=0;
	int i,length=0;
	if(vastring){
		for(length=0;vastring[length]!='\0';length++);
		//cprintf("vastring[0]=%c vastring[1]=%c length=%d\n",vastring[0],vastring[1],length);
		if(base==16){
			if(vastring[0]!='0'||vastring[1]!='x'||(length>10)){
				cprintf("Virtual Address is not hex!\n");
				return 0;
			}
		
			for(i=2;i<length;i++){
				if(vastring[i]>='0'&&vastring[i]<='9')
					va=vastring[i]-'0'+va*base;
				else if(vastring[i]>='a'&&vastring[i]<='f')
					va=vastring[i]-'a'+10+va*base;
				else{
					cprintf("Virtual Address is bad!\n");
					va=0;
					break;
				}
			}
		}
		else if(base==10){
			 for(i=0;i<length;i++){
                                if(vastring[i]>='0'&&vastring[i]<='9')
                                        va=vastring[i]-'0'+va*base;
                                else{
                                        cprintf("The number string is bad!\n");
                                        va=0;
                                        break;
                                }
			}
		}
		else cprintf("Can not handdle\n");	
	}
	else{
		cprintf("Virtual Address is NULL!\n");
	}
	return va;
}
int
mon_showmappings(int argc,char **argv,struct Trapframe *tf)
{
	int i;
	uint32_t a,la;
	pte_t *pte;
	struct Page *onepage;
	physaddr_t physaddr;
	if(argc!=3)
	{
		cprintf("Command argument is illegle!\n"); 
		return 0;
	}
	//for(i=0;i<argc;i++){
	//	cprintf("%s\n",argv[i]);
	//}
	a=getva(argv[1],16);
	la=getva(argv[2],16);
	for(;;)
	{
		if((onepage=page_lookup(boot_pgdir,(void *)a,&pte))){
			physaddr=page2pa(onepage);
			cprintf("virtual addr=%x page physaddr=%x permission: ",a,physaddr);
			if((*pte)&PTE_D) cprintf("D ");
			else cprintf("- ");
			if(*pte&PTE_A) cprintf("A ");
                        else cprintf("- ");
			if(*pte&PTE_PCD) cprintf("PCD ");
                        else cprintf("- ");
			if(*pte&PTE_PWT) cprintf("PWT ");
                        else cprintf("- ");
			if(*pte&PTE_U) cprintf("U ");
                        else cprintf("- ");
			if(*pte&PTE_W) cprintf("W ");
                        else cprintf("- ");
			cprintf("P \n");
		}	
		else cprintf("this physical page corresponding to %x is not exiting\n",a);
		if(a==la) break;
		a+=PGSIZE;
	}
	return 0;
}
int
mon_permission(int argc, char **argv, struct Trapframe *tf)
{
	uint32_t a=0;
	int i;
	pte_t *pte;
	struct Page *onepage;
	char operator,pte_ch=0,pte_perm;
	if(argc<4)
	{
		cprintf("Command argument is illegle!\n"); 
		return 0;
	}
	a=getva(argv[2],16);
	operator=argv[1][0];
	if((onepage=page_lookup(boot_pgdir,(void *)a,&pte))){
		for(i=3;i<argc;i++)
		{
			pte_perm=argv[i][0];
			switch(pte_perm){
				case 'P':
					 if((argv[i][1]!='\0')&&(argv[i][3]=='\0')){
                               			 if((argv[i][0]=='P')&&(argv[i][1]=='W')&&(argv[i][2]=='T'))
                                        		 pte_ch|=PTE_PWT;
                               			 else if((argv[i][0]=='P')&&(argv[i][1]=='C')&&(argv[i][2]=='D'))
                                        		 pte_ch|=PTE_PCD;
                               			 else {cprintf("permission %s is not exist\n",argv[i]);return 0;}
                       			 }
					else if(argv[i][1]=='\0')	pte_ch|=PTE_P;
					else {cprintf("permission %s is not exist\n",argv[i]);return 0;}
					break;
				case 'W':pte_ch|=PTE_W;break;
				case 'U':pte_ch|=PTE_U;break;
				case 'D':pte_ch|=PTE_D;break;
				case 'A':pte_ch|=PTE_A;break;
				default:
					cprintf("permission %s is not exist\n",argv[i]);
					return 0;
			}
		}
		switch(operator){
			case 's':
				*pte|=pte_ch;break;
			case 'c':
				if(pte_ch&PTE_P)
					{cprintf("clearing PTE_P is denied\n");return 0;}
				else
					{*pte&=(~pte_ch);break;}
			default:
				cprintf("oprator %c is not setting or clearing permission\n",operator);
				return 0;
		}
		cprintf("permission is changed successfully!\n");
	}
	else cprintf("this physical page corresponding to %x is not exiting\n",a);
	return 0;
}

int
mon_dumpx(int argc, char **argv, struct Trapframe *tf)
{
	uint32_t a,*content;
	int i,n;
	if(argc<3)
        {
                cprintf("Command argument is illegle!\n");
                return 0;
        }
	n=(int)getva(argv[1],10);
	a=getva(argv[2],16);
	content=(uint32_t *)a;
	for(i=0;i<n;i++)
		cprintf("%x ",*(content+i));
	cprintf("\n");
	return 0;
}
int
mon_dumpxp(int argc, char **argv, struct Trapframe *tf)
{
	uint32_t va,pa,*content;
        int i,n;
        if(argc<3)
        {
                cprintf("Command argument is illegle!\n");
                return 0;
        }
	n=(int)getva(argv[1],10);
	pa = getva(argv[2],16);
	va = (uint32_t)KADDR(pa);
	content=(uint32_t *)va;
	for(i=0;i<n;i++)
                cprintf("%x ",*(content+i));
        cprintf("\n");
        return 0;
}
int
mon_continue(int argc, char **argv, struct Trapframe *tf)
{
	uint32_t retesp;
	struct Trapframe *tf1;
	if(tf->tf_trapno==3||tf->tf_trapno==1)
	{
		retesp=tf->tf_regs.reg_oesp-0x20;//看看pushal指令做了什么，就知道为什么减0x20,
					//找到异常产生，进行现场保护后的内核栈栈顶指针
		//cprintf("edi=%x oldesp=%x ebp=%x\n",tf1->tf_regs.reg_edi,retesp,read_ebp());
		tf1=(struct Trapframe*)retesp;
		tf1->tf_eflags|=0x10000;//设置EFLAGS中的RF
		tf1->tf_eflags&=~0x100;//复位EFLAGS中的TF
		//print_trapframe(tf1);
 		//cprintf("edi=%x oldesp=%x esp=%x\n",tf1->tf_regs.reg_edi,retesp,read_esp());
		write_esp(retesp);//恢复栈顶指针
		trapret();
	}
	return 0;
}
int 
mon_stepi(int argc, char **argv, struct Trapframe *tf)
{
	uint32_t retesp;
        struct Trapframe *tf1;
        retesp=tf->tf_regs.reg_oesp-0x20;//看看pushal指令做了什么，就知道为什么减0x20,
                                        //找到异常产生，进行现场保护后的内核栈栈顶指针
        //cprintf("edi=%x oldesp=%x ebp=%x\n",tf1->tf_regs.reg_edi,retesp,read_ebp());
        tf1=(struct Trapframe*)retesp;
	monitor_disas(tf1->tf_eip,1);

        //tf1->tf_eflags|=0x10000;//设置EFLAGS中的RF
        tf1->tf_eflags|=0x100;//设置EFLAGS中的TF
        //print_trapframe(tf1);
        //cprintf("edi=%x oldesp=%x esp=%x\n",tf1->tf_regs.reg_edi,retesp,read_esp());
      	write_esp(retesp);//恢复栈顶指针
      	trapret();
      	return 0;
}


/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");

	if (tf != NULL)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}

// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
	return callerpc;
}
