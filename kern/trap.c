#include <inc/mmu.h>
#include <inc/x86.h>
#include <inc/assert.h>

#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/env.h>
#include <kern/syscall.h>
#include <kern/sched.h>
#include <kern/kclock.h>
#include <kern/picirq.h>
#include <kern/time.h>

static struct Taskstate ts;

/* Interrupt descriptor table.  (Must be built at run time because
 * shifted function addresses can't be represented in relocation records.)
 */
struct Gatedesc idt[256] = { { 0 } };
struct Pseudodesc idt_pd = {
	sizeof(idt) - 1, (uint32_t) idt
};
//LAB 3:define vectors[] here
extern uint32_t vectors[];
static const char *trapname(int trapno)
{
	static const char * const excnames[] = {
		"Divide error",
		"Debug",
		"Non-Maskable Interrupt",
		"Breakpoint",
		"Overflow",
		"BOUND Range Exceeded",
		"Invalid Opcode",
		"Device Not Available",
		"Double Fault",
		"Coprocessor Segment Overrun",
		"Invalid TSS",
		"Segment Not Present",
		"Stack Fault",
		"General Protection",
		"Page Fault",
		"(unknown trap)",
		"x87 FPU Floating-Point Error",
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
	return "(unknown trap)";
}


void
idt_init(void)
{
	extern struct Segdesc gdt[];
	/*中断门和陷阱门的DPL只有使用INT n指令引起中断/异常时才检查，
	 *硬件产生的中断/异常不检查。 
	 *这里初始化使用的都是中断门。中断发生后，处理器器自动复位
	 *EFLAGES中的IF位，在内核中中断是关闭的。
	 */
	// LAB 3: Your code here.
	int i;
	for(i=0;i<IRQ_OFFSET;i++)
		SETGATE(idt[i],0,GD_KT,vectors[i],0);//陷阱门
	SETGATE(idt[T_BRKPT],0,GD_KT,vectors[T_BRKPT],3);//系统中断门,断点异常，DPL＝3
	SETGATE(idt[T_OFLOW],0,GD_KT,vectors[T_OFLOW],3);//系统陷阱门，溢出异常，DPL＝3
	SETGATE(idt[T_BOUND],0,GD_KT,vectors[T_BOUND],3);
	for(i=IRQ_OFFSET;i<IRQ_OFFSET+MAX_IRQS;i++)
               SETGATE(idt[i],0,GD_KT,vectors[i],0);//中断门,外部硬件中断 16个
	 SETGATE(idt[T_SYSCALL],0,GD_KT,vectors[T_SYSCALL],3);//系统调用,系统陷阱门，DPL＝3
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	//在内核模式中，处理器使用TSS中的ESP0和SS0字段定义内核栈
	//JOS不使用TSS的其他字段
	ts.ts_esp0 = KSTACKTOP;
	ts.ts_ss0 = GD_KD;

	// Initialize the TSS field of the gdt.初始化任务状态段，
	//该段存放在GDT表中
	gdt[GD_TSS >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS >> 3].sd_s = 0;

	// Load the TSS
	ltr(GD_TSS);

	// Load the IDT
	asm volatile("lidt idt_pd");
}

void
print_trapframe(struct Trapframe *tf)
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
	cprintf("  err  0x%08x\n", tf->tf_err);
	cprintf("  eip  0x%08x\n", tf->tf_eip);
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
	cprintf("  esp  0x%08x\n", tf->tf_esp);
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
}

void
print_regs(struct PushRegs *regs)
{
	cprintf("  edi  0x%08x\n", regs->reg_edi);
	cprintf("  esi  0x%08x\n", regs->reg_esi);
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
	cprintf("  edx  0x%08x\n", regs->reg_edx);
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
	cprintf("  eax  0x%08x\n", regs->reg_eax);
}

static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	switch(tf->tf_trapno){
		case T_PGFLT:
			page_fault_handler(tf);
			break;
		case T_BRKPT:
			monitor(tf);
			break;
		case T_DEBUG:
			monitor(tf);
			break;
		case T_SYSCALL:
			curenv->env_tf.tf_regs.reg_eax=syscall(tf->tf_regs.reg_eax,tf->tf_regs.reg_edx,tf->tf_regs.reg_ecx,tf->tf_regs.reg_ebx,tf->tf_regs.reg_edi,tf->tf_regs.reg_esi);
			break;
		default:	
		// Handle clock interrupts.
		// LAB 4: Your code here.
		// Add time tick increment to clock interrupts.
		// LAB 6: Your code here.
		if(tf->tf_trapno==IRQ_OFFSET + IRQ_TIMER){
			time_tick();
			sched_yield();//内核层的环境切换，需要在环境切换中思考
		}


		// Handle spurious interrupts
		// The hardware sometimes raises these because of noise on the
		// IRQ line or other reasons. We don't care.
		if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
			cprintf("Spurious interrupt on irq 7\n");
			print_trapframe(tf);
			return;
		}
	


		// Unexpected trap: The user process or the kernel has a bug.
		print_trapframe(tf);
		if (tf->tf_cs == GD_KT)
			panic("unhandled trap in kernel");
		else {
			env_destroy(curenv);
			return;
		}
	}
}

void
trap(struct Trapframe *tf)
{
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));

	if ((tf->tf_cs & 3) == 3) {
		// Trapped from user mode.
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		assert(curenv);
		curenv->env_tf = *tf;
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
	}
	
	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNABLE)
		env_run(curenv);
	else
		sched_yield();
}


void
page_fault_handler(struct Trapframe *tf)
{
	uint32_t fault_va;

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	
	// LAB 3: Your code here.还可以通过页故障异常的错误码的位2判断
	if((tf->tf_cs&3)==0)
		panic("Page Fault in Kernel Mode");
	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Call the environment's page fault upcall, if one exists.  Set up a
	// page fault stack frame on the user exception stack (below
	// UXSTACKTOP), then branch to curenv->env_pgfault_upcall.
	//
	// The page fault upcall might cause another page fault, in which case
	// we branch to the page fault upcall recursively, pushing another
	// page fault stack frame on top of the user exception stack.
	//
	// The trap handler needs one word of scratch space at the top of the
	// trap-time stack in order to return.  In the non-recursive case, we
	// don't have to worry about this because the top of the regular user
	// stack is free.  In the recursive case, this means we have to leave
	// an extra word between the current top of the exception stack and
	// the new stack frame because the exception stack _is_ the trap-time
	// stack.
	//
	// If there's no page fault upcall, the environment didn't allocate a
	// page for its exception stack or can't write to it, or the exception
	// stack overflows, then destroy the environment that caused the fault.
	// Note that the grade script assumes you will first check for the page
	// fault upcall and print the "user fault va" message below if there is
	// none.  The remaining three checks can be combined into a single test.
	//
	// Hints:
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	struct UTrapframe *utf;
	size_t utf_size;
	if((tf->tf_err&FEC_U)&&curenv->env_pgfault_upcall)
	{
		utf_size = sizeof(struct UTrapframe);
		user_mem_assert(curenv,(void*)(UXSTACKTOP-utf_size),utf_size,0);
		if(tf->tf_esp>(UXSTACKTOP-PGSIZE)&&tf->tf_esp<UXSTACKTOP)
		{
			utf=(struct UTrapframe*)(tf->tf_esp-utf_size-sizeof(utf->utf_eip));
					//这一步处理page fault handler中出现缺页异常
					//先压入一32位空值，再压入UTrapframe,这个空出来的位置在_pgfault_upcall中存放utf->utf_eip
		}
		else{
			utf = (struct UTrapframe*)(UXSTACKTOP-utf_size);   
		}
					//在用户异常栈上设置一个页故障帧栈
		utf->utf_fault_va=fault_va;
		utf->utf_err=tf->tf_err;
		utf->utf_regs=tf->tf_regs;
		utf->utf_eip=tf->tf_eip;
		utf->utf_eflags=tf->tf_eflags;
		utf->utf_esp=tf->tf_esp;
		curenv->env_tf.tf_esp=(uintptr_t)utf;
		//curenv->env_tf.tf_eflags=utf->utf_eflags;
		//cprintf("utf:utf_esp=%x utf_eip=%x\n",utf->utf_esp,utf->utf_eip);
		//cprintf("curenv:tf_esp=%x utf=%x\n",curenv->env_tf.tf_esp,(uintptr_t)utf);
		//cprintf("tf->tf_eflags=%x curenv_eflages=%x\n",tf->tf_eflags,curenv->env_tf.tf_eflags);
		if(curenv->env_pgfault_upcall)
		{	
			user_mem_assert(curenv,(void*)curenv->env_pgfault_upcall,PGSIZE,0);
			curenv->env_tf.tf_eip=(uintptr_t)curenv->env_pgfault_upcall;
			env_run(curenv);
		}
	}
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
	env_destroy(curenv);
}

