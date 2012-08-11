
obj/boot/boot.out:     file format elf32-i386

Disassembly of section .text:

00007c00 <start>:
.set CR0_PE_ON,      0x1         # protected mode enable flag

.globl start
start:
  .code16                     # Assemble for 16-bit mode
  cli                         # Disable interrupts
    7c00:	fa                   	cli    
  cld                         # String operations increment
    7c01:	fc                   	cld    

  # Set up the important data segment registers (DS, ES, SS).
  xorw    %ax,%ax             # Segment number zero
    7c02:	31 c0                	xor    %eax,%eax
  movw    %ax,%ds             # -> Data Segment
    7c04:	8e d8                	mov    %eax,%ds
  movw    %ax,%es             # -> Extra Segment
    7c06:	8e c0                	mov    %eax,%es
  movw    %ax,%ss             # -> Stack Segment
    7c08:	8e d0                	mov    %eax,%ss

00007c0a <seta20.1>:
  # Enable A20:
  #   For backwards compatibility with the earliest PCs, physical
  #   address line 20 is tied low, so that addresses higher than
  #   1MB wrap around to zero by default.  This code undoes this.
seta20.1:
  inb     $0x64,%al               # Wait for not busy
    7c0a:	e4 64                	in     $0x64,%al
  testb   $0x2,%al
    7c0c:	a8 02                	test   $0x2,%al
  jnz     seta20.1
    7c0e:	75 fa                	jne    7c0a <seta20.1>

  movb    $0xd1,%al               # 0xd1 -> port 0x64
    7c10:	b0 d1                	mov    $0xd1,%al
  outb    %al,$0x64
    7c12:	e6 64                	out    %al,$0x64

00007c14 <seta20.2>:

seta20.2:
  inb     $0x64,%al               # Wait for not busy
    7c14:	e4 64                	in     $0x64,%al
  testb   $0x2,%al
    7c16:	a8 02                	test   $0x2,%al
  jnz     seta20.2
    7c18:	75 fa                	jne    7c14 <seta20.2>

  movb    $0xdf,%al               # 0xdf -> port 0x60
    7c1a:	b0 df                	mov    $0xdf,%al
  outb    %al,$0x60
    7c1c:	e6 60                	out    %al,$0x60

  # Switch from real to protected mode, using a bootstrap GDT
  # and segment translation that makes virtual addresses 
  # identical to their physical addresses, so that the 
  # effective memory map does not change during the switch.
  lgdt    gdtdesc
    7c1e:	0f 01 16             	lgdtl  (%esi)
    7c21:	64                   	fs
    7c22:	7c 0f                	jl     7c33 <protcseg+0x1>
  movl    %cr0, %eax
    7c24:	20 c0                	and    %al,%al
  orl     $CR0_PE_ON, %eax
    7c26:	66 83 c8 01          	or     $0x1,%ax
  movl    %eax, %cr0
    7c2a:	0f 22 c0             	mov    %eax,%cr0
  
  # Jump to next instruction, but in 32-bit code segment.
  # Switches processor into 32-bit mode.
  ljmp    $PROT_MODE_CSEG, $protcseg
    7c2d:	ea 32 7c 08 00 66 b8 	ljmp   $0xb866,$0x87c32

00007c32 <protcseg>:

  .code32                     # Assemble for 32-bit mode
protcseg:
  # Set up the protected-mode data segment registers
  movw    $PROT_MODE_DSEG, %ax    # Our data segment selector
    7c32:	66 b8 10 00          	mov    $0x10,%ax
  movw    %ax, %ds                # -> DS: Data Segment
    7c36:	8e d8                	mov    %eax,%ds
  movw    %ax, %es                # -> ES: Extra Segment
    7c38:	8e c0                	mov    %eax,%es
  movw    %ax, %fs                # -> FS
    7c3a:	8e e0                	mov    %eax,%fs
  movw    %ax, %gs                # -> GS
    7c3c:	8e e8                	mov    %eax,%gs
  movw    %ax, %ss                # -> SS: Stack Segment
    7c3e:	8e d0                	mov    %eax,%ss
  
  # Set up the stack pointer and call into C.
  movl    $start, %esp
    7c40:	bc 00 7c 00 00       	mov    $0x7c00,%esp
  call bootmain
    7c45:	e8 db 00 00 00       	call   7d25 <bootmain>

00007c4a <spin>:

  # If bootmain returns (it shouldn't), loop.
spin:
  jmp spin
    7c4a:	eb fe                	jmp    7c4a <spin>

00007c4c <gdt>:
	...
    7c54:	ff                   	(bad)  
    7c55:	ff 00                	incl   (%eax)
    7c57:	00 00                	add    %al,(%eax)
    7c59:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
    7c60:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

00007c64 <gdtdesc>:
    7c64:	17                   	pop    %ss
    7c65:	00 4c 7c 00          	add    %cl,0x0(%esp,%edi,2)
    7c69:	00 90 90 55 89 e5    	add    %dl,-0x1a76aa70(%eax)

00007c6c <waitdisk>:
	}
}

void
waitdisk(void)
{
    7c6c:	55                   	push   %ebp
    7c6d:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
    7c6f:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7c74:	ec                   	in     (%dx),%al
	// wait for disk reaady
	while ((inb(0x1F7) & 0xC0) != 0x40)
    7c75:	25 c0 00 00 00       	and    $0xc0,%eax
    7c7a:	83 f8 40             	cmp    $0x40,%eax
    7c7d:	75 f0                	jne    7c6f <waitdisk+0x3>
		/* do nothing */;
}
    7c7f:	5d                   	pop    %ebp
    7c80:	c3                   	ret    

00007c81 <readsect>:

void
readsect(void *dst, uint32_t offset)
{
    7c81:	55                   	push   %ebp
    7c82:	89 e5                	mov    %esp,%ebp
    7c84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    7c87:	57                   	push   %edi
    7c88:	8b 7d 08             	mov    0x8(%ebp),%edi
    7c8b:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7c90:	ec                   	in     (%dx),%al

void
waitdisk(void)
{
	// wait for disk reaady
	while ((inb(0x1F7) & 0xC0) != 0x40)
    7c91:	25 c0 00 00 00       	and    $0xc0,%eax
    7c96:	83 f8 40             	cmp    $0x40,%eax
    7c99:	75 f0                	jne    7c8b <readsect+0xa>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
    7c9b:	b0 01                	mov    $0x1,%al
    7c9d:	b2 f2                	mov    $0xf2,%dl
    7c9f:	ee                   	out    %al,(%dx)
    7ca0:	b2 f3                	mov    $0xf3,%dl
    7ca2:	88 c8                	mov    %cl,%al
    7ca4:	ee                   	out    %al,(%dx)
    7ca5:	c1 e9 08             	shr    $0x8,%ecx
    7ca8:	b2 f4                	mov    $0xf4,%dl
    7caa:	88 c8                	mov    %cl,%al
    7cac:	ee                   	out    %al,(%dx)
    7cad:	c1 e9 08             	shr    $0x8,%ecx
    7cb0:	b2 f5                	mov    $0xf5,%dl
    7cb2:	88 c8                	mov    %cl,%al
    7cb4:	ee                   	out    %al,(%dx)
    7cb5:	c1 e9 08             	shr    $0x8,%ecx
    7cb8:	b2 f6                	mov    $0xf6,%dl
    7cba:	88 c8                	mov    %cl,%al
    7cbc:	83 c8 e0             	or     $0xffffffe0,%eax
    7cbf:	ee                   	out    %al,(%dx)
    7cc0:	b0 20                	mov    $0x20,%al
    7cc2:	b2 f7                	mov    $0xf7,%dl
    7cc4:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
    7cc5:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7cca:	ec                   	in     (%dx),%al
    7ccb:	25 c0 00 00 00       	and    $0xc0,%eax
    7cd0:	83 f8 40             	cmp    $0x40,%eax
    7cd3:	75 f0                	jne    7cc5 <readsect+0x44>
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
    7cd5:	b2 f0                	mov    $0xf0,%dl
    7cd7:	b9 80 00 00 00       	mov    $0x80,%ecx
    7cdc:	fc                   	cld    
    7cdd:	f2 6d                	repnz insl (%dx),%es:(%edi)
	// wait for disk to be ready
	waitdisk();

	// read a sector
	insl(0x1F0, dst, SECTSIZE/4);
}
    7cdf:	5f                   	pop    %edi
    7ce0:	5d                   	pop    %ebp
    7ce1:	c3                   	ret    

00007ce2 <readseg>:

// Read 'count' bytes at 'offset' from kernel into virtual address 'va'.
// Might copy more than asked
void
readseg(uint32_t va, uint32_t count, uint32_t offset)
{
    7ce2:	55                   	push   %ebp
    7ce3:	89 e5                	mov    %esp,%ebp
    7ce5:	8b 55 08             	mov    0x8(%ebp),%edx
    7ce8:	8b 45 10             	mov    0x10(%ebp),%eax
    7ceb:	57                   	push   %edi
    7cec:	56                   	push   %esi
	uint32_t end_va;

	va &= 0xFFFFFF;
    7ced:	89 d7                	mov    %edx,%edi
    7cef:	81 e7 ff ff ff 00    	and    $0xffffff,%edi
	end_va = va + count;
    7cf5:	03 7d 0c             	add    0xc(%ebp),%edi

// Read 'count' bytes at 'offset' from kernel into virtual address 'va'.
// Might copy more than asked
void
readseg(uint32_t va, uint32_t count, uint32_t offset)
{
    7cf8:	53                   	push   %ebx

	va &= 0xFFFFFF;
	end_va = va + count;
	
	// round down to sector boundary
	va &= ~(SECTSIZE - 1);
    7cf9:	89 d3                	mov    %edx,%ebx

	// translate from bytes to sectors, and kernel starts at sector 1
	offset = (offset / SECTSIZE) + 1;
    7cfb:	c1 e8 09             	shr    $0x9,%eax

	va &= 0xFFFFFF;
	end_va = va + count;
	
	// round down to sector boundary
	va &= ~(SECTSIZE - 1);
    7cfe:	81 e3 00 fe ff 00    	and    $0xfffe00,%ebx

	// translate from bytes to sectors, and kernel starts at sector 1
	offset = (offset / SECTSIZE) + 1;
    7d04:	8d 70 01             	lea    0x1(%eax),%esi
    7d07:	eb 10                	jmp    7d19 <readseg+0x37>

	// If this is too slow, we could read lots of sectors at a time.
	// We'd write more to memory than asked, but it doesn't matter --
	// we load in increasing order.
	while (va < end_va) {
		readsect((uint8_t*) va, offset);
    7d09:	56                   	push   %esi
		va += SECTSIZE;
		offset++;
    7d0a:	46                   	inc    %esi

	// If this is too slow, we could read lots of sectors at a time.
	// We'd write more to memory than asked, but it doesn't matter --
	// we load in increasing order.
	while (va < end_va) {
		readsect((uint8_t*) va, offset);
    7d0b:	53                   	push   %ebx
		va += SECTSIZE;
    7d0c:	81 c3 00 02 00 00    	add    $0x200,%ebx

	// If this is too slow, we could read lots of sectors at a time.
	// We'd write more to memory than asked, but it doesn't matter --
	// we load in increasing order.
	while (va < end_va) {
		readsect((uint8_t*) va, offset);
    7d12:	e8 6a ff ff ff       	call   7c81 <readsect>
		va += SECTSIZE;
		offset++;
    7d17:	58                   	pop    %eax
    7d18:	5a                   	pop    %edx
	offset = (offset / SECTSIZE) + 1;

	// If this is too slow, we could read lots of sectors at a time.
	// We'd write more to memory than asked, but it doesn't matter --
	// we load in increasing order.
	while (va < end_va) {
    7d19:	39 fb                	cmp    %edi,%ebx
    7d1b:	72 ec                	jb     7d09 <readseg+0x27>
		readsect((uint8_t*) va, offset);
		va += SECTSIZE;
		offset++;
	}
}
    7d1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
    7d20:	5b                   	pop    %ebx
    7d21:	5e                   	pop    %esi
    7d22:	5f                   	pop    %edi
    7d23:	5d                   	pop    %ebp
    7d24:	c3                   	ret    

00007d25 <bootmain>:
void readsect(void*, uint32_t);
void readseg(uint32_t, uint32_t, uint32_t);

void
bootmain(void)
{
    7d25:	55                   	push   %ebp
    7d26:	89 e5                	mov    %esp,%ebp
    7d28:	56                   	push   %esi
    7d29:	53                   	push   %ebx
	struct Proghdr *ph, *eph;

	// read 1st page off disk
	readseg((uint32_t) ELFHDR, SECTSIZE*8, 0);
    7d2a:	6a 00                	push   $0x0
    7d2c:	68 00 10 00 00       	push   $0x1000
    7d31:	68 00 00 01 00       	push   $0x10000
    7d36:	e8 a7 ff ff ff       	call   7ce2 <readseg>

	// is this a valid ELF?
	if (ELFHDR->e_magic != ELF_MAGIC)
    7d3b:	83 c4 0c             	add    $0xc,%esp
    7d3e:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
    7d45:	45 4c 46 
    7d48:	75 3f                	jne    7d89 <bootmain+0x64>
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
    7d4a:	8b 1d 1c 00 01 00    	mov    0x1001c,%ebx
	eph = ph + ELFHDR->e_phnum;
    7d50:	0f b7 05 2c 00 01 00 	movzwl 0x1002c,%eax
	// is this a valid ELF?
	if (ELFHDR->e_magic != ELF_MAGIC)
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
    7d57:	81 c3 00 00 01 00    	add    $0x10000,%ebx
	eph = ph + ELFHDR->e_phnum;
    7d5d:	c1 e0 05             	shl    $0x5,%eax
    7d60:	8d 34 03             	lea    (%ebx,%eax,1),%esi
    7d63:	eb 14                	jmp    7d79 <bootmain+0x54>
	for (; ph < eph; ph++)
		readseg(ph->p_va, ph->p_memsz, ph->p_offset);
    7d65:	ff 73 04             	pushl  0x4(%ebx)
    7d68:	ff 73 14             	pushl  0x14(%ebx)
    7d6b:	ff 73 08             	pushl  0x8(%ebx)
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;
	for (; ph < eph; ph++)
    7d6e:	83 c3 20             	add    $0x20,%ebx
		readseg(ph->p_va, ph->p_memsz, ph->p_offset);
    7d71:	e8 6c ff ff ff       	call   7ce2 <readseg>
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;
	for (; ph < eph; ph++)
    7d76:	83 c4 0c             	add    $0xc,%esp
    7d79:	39 f3                	cmp    %esi,%ebx
    7d7b:	72 e8                	jb     7d65 <bootmain+0x40>
		readseg(ph->p_va, ph->p_memsz, ph->p_offset);

	// call the entry point from the ELF header
	// note: does not return!
	((void (*)(void)) (ELFHDR->e_entry & 0xFFFFFF))();
    7d7d:	a1 18 00 01 00       	mov    0x10018,%eax
    7d82:	25 ff ff ff 00       	and    $0xffffff,%eax
    7d87:	ff d0                	call   *%eax
}

static __inline void
outw(int port, uint16_t data)
{
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
    7d89:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
    7d8e:	ba 00 8a 00 00       	mov    $0x8a00,%edx
    7d93:	66 ef                	out    %ax,(%dx)
    7d95:	b8 00 8e ff ff       	mov    $0xffff8e00,%eax
    7d9a:	66 ef                	out    %ax,(%dx)
    7d9c:	eb fe                	jmp    7d9c <bootmain+0x77>
