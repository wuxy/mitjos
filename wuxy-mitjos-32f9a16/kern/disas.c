#include <kern/dis-asm.h>
#include <kern/disas.h>
#include <inc/error.h>
#include <inc/types.h>
#include <inc/stdio.h>
#include <inc/string.h>
/* Get LENGTH bytes from info's buffer, at target address memaddr.
 *    Transfer them to myaddr.  */
int
buffer_read_memory(bfd_vma memaddr,bfd_byte *myaddr,int length,struct disassemble_info *info)
{
    //cprintf("read:myaddr=%x\n",myaddr);
    if ((memaddr < info->buffer_vma)
        ||(memaddr + length > info->buffer_vma + info->buffer_length))
        /* Out of bounds.  Use EIO because GDB uses it.  */
	{
		//cprintf("read memory error\n");
        	return -1;
	}
    memmove (myaddr, info->buffer + (memaddr - info->buffer_vma), length);  
    return 0;
}
/* Print an error message.  We can assume that this is in response to
 *    an error return from buffer_read_memory.  */
void
perror_memory (int status, bfd_vma memaddr, struct disassemble_info *info)
{
  if (status != -1)
    /* Can't happen.  */
    cprintf("Unknown error %d\n", status);
  else
    /* Actually, address between memaddr and memaddr + len was
 *        out of bounds.  */
    cprintf("Address 0x%08x is out of bounds.\n", memaddr);
}

void
generic_print_address (bfd_vma addr, struct disassemble_info *info)
{
    cprintf("0x%08x",addr);
}

/* Just return the given address.  */

int
generic_symbol_at_address (bfd_vma addr, struct disassemble_info *info)
{
  return 1;
}

bfd_vma bfd_getl32 (const bfd_byte *addr)
{
  unsigned long v;

  v = (unsigned long) addr[0];
  v |= (unsigned long) addr[1] << 8;
  v |= (unsigned long) addr[2] << 16;
  v |= (unsigned long) addr[3] << 24;
  return (bfd_vma) v;
}

bfd_vma bfd_getb32 (const bfd_byte *addr)
{
  unsigned long v;

  v = (unsigned long) addr[0] << 24;
  v |= (unsigned long) addr[1] << 16;
  v |= (unsigned long) addr[2] << 8;
  v |= (unsigned long) addr[3];
  return (bfd_vma) v;
}

bfd_vma bfd_getl16 (const bfd_byte *addr)
{
  unsigned long v;

  v = (unsigned long) addr[0];
  v |= (unsigned long) addr[1] << 8;
  return (bfd_vma) v;
}

bfd_vma bfd_getb16 (const bfd_byte *addr)
{
  unsigned long v;

  v = (unsigned long) addr[0] << 24;
  v |= (unsigned long) addr[1] << 16;
  return (bfd_vma) v;
}

void monitor_disas(uint32_t pc, int nb_insn)
{
    int count, i;
    struct disassemble_info disasm_info;
    int (*print_insn)(bfd_vma pc, disassemble_info *info);
    
    INIT_DISASSEMBLE_INFO(disasm_info, NULL, cprintf);

    //monitor_disas_env = env;
    //monitor_disas_is_physical = is_physical;
    //disasm_info.read_memory_func = monitor_read_memory;

    disasm_info.buffer_vma = pc;
    disasm_info.buffer_length=7;
    disasm_info.buffer=(bfd_byte *)pc;
    //cprintf("disasm_info=%x\n",&disasm_info);
    //for(i=0;i<7;i++)
    	//cprintf("%x",disasm_info.buffer[i]);
    cprintf("\n");
    disasm_info.endian = BFD_ENDIAN_LITTLE;

    disasm_info.mach = bfd_mach_i386_i386;
    print_insn = print_insn_i386;

    for(i = 0; i < nb_insn; i++) {
        cprintf("0x%08x:  ", pc);
	//cprintf("%08x  ", (int)bfd_getl32((const bfd_byte *)pc));
	count = print_insn(pc, &disasm_info);
        cprintf("\n");
        if (count < 0)
            break;
        pc += count;
    }
}
