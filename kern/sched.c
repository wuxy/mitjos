#include <inc/assert.h>

#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/monitor.h>


// Choose a user environment to run and run it.
void
sched_yield(void)
{
	// Implement simple round-robin scheduling.
	// Search through 'envs' for a runnable environment,
	// in circular fashion starting after the previously running env,
	// and switch to the first such environment found.
	// It's OK to choose the previously running env if no other env
	// is runnable.
	// But never choose envs[0], the idle environment,
	// unless NOTHING else is runnable.

	// LAB 4: Your code here.
	uint32_t retesp;
	envid_t envid;
	int index=0,i;
	if(curenv){
		//retesp=curenv->env_tf.tf_regs.reg_oesp-0x20;
		index=ENVX(curenv->env_id)-ENVX(envs[0].env_id);
		//cprintf("curenv->env_id=%x\n",curenv->env_id);
	}
	//cprintf("all:");
	//for(i=0;i<NENV;i++)
	//	if(envs[i].env_status==ENV_RUNNABLE)
	//	{
	//		cprintf("envs[%d].env_id=%x  ",i,envs[i].env_id);
	//	}
	//for(i=index+1;i<NENV;i++)
	//	if(envs[i].env_status==ENV_RUNNABLE)
	//	{
	//		env_run(&envs[i]);
	//		write_esp(retesp);
	//		trapret();
	//	}
	//for(i=1;i<=index;i++)
	//	if(envs[i].env_status==ENV_RUNNABLE)
	//	{
	//		env_run(&envs[i]);
	//		write_esp(retesp);
	//		trapret();
	//	}
	//下面代码更简洁
	for(i=1;i<=NENV;i++)
	{
		envid=(i+index)%NENV;
		if(envs[envid].env_status==ENV_RUNNABLE)
		{
			if(envid==0)
				continue;
			//cprintf("\nslected env:%x\n",envs[envid].env_id);
			env_run(&envs[envid]);
			//write_esp(retesp);
			//trapret();
		}
	}
	// Run the special idle environment when nothing else is runnable.
	if (envs[0].env_status == ENV_RUNNABLE)
		env_run(&envs[0]);
	else {
		cprintf("Destroyed all environments - nothing more to do!\n");
		while (1)
			monitor(NULL);
	}
}
