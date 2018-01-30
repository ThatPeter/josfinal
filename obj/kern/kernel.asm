
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 12 f0       	mov    $0xf0120000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5c 00 00 00       	call   f010009a <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d 80 fe 21 f0 00 	cmpl   $0x0,0xf021fe80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 fe 21 f0    	mov    %esi,0xf021fe80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 69 65 00 00       	call   f01065ca <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 60 6c 10 f0       	push   $0xf0106c60
f010006d:	e8 6e 3d 00 00       	call   f0103de0 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 3e 3d 00 00       	call   f0103dba <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 88 7e 10 f0 	movl   $0xf0107e88,(%esp)
f0100083:	e8 58 3d 00 00       	call   f0103de0 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 c0 08 00 00       	call   f0100955 <monitor>
f0100095:	83 c4 10             	add    $0x10,%esp
f0100098:	eb f1                	jmp    f010008b <_panic+0x4b>

f010009a <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010009a:	55                   	push   %ebp
f010009b:	89 e5                	mov    %esp,%ebp
f010009d:	53                   	push   %ebx
f010009e:	83 ec 08             	sub    $0x8,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a1:	b8 08 10 26 f0       	mov    $0xf0261008,%eax
f01000a6:	2d 48 ef 21 f0       	sub    $0xf021ef48,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 48 ef 21 f0       	push   $0xf021ef48
f01000b3:	e8 ef 5e 00 00       	call   f0105fa7 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 96 05 00 00       	call   f0100653 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 cc 6c 10 f0       	push   $0xf0106ccc
f01000ca:	e8 11 3d 00 00       	call   f0103de0 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 c0 13 00 00       	call   f0101494 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 c2 30 00 00       	call   f010319b <env_init>
	trap_init();
f01000d9:	e8 fd 3d 00 00       	call   f0103edb <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 dd 61 00 00       	call   f01062c0 <mp_init>
	lapic_init();
f01000e3:	e8 fd 64 00 00       	call   f01065e5 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 1a 3c 00 00       	call   f0103d07 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000ed:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f01000f4:	e8 3f 67 00 00       	call   f0106838 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000f9:	83 c4 10             	add    $0x10,%esp
f01000fc:	83 3d 88 fe 21 f0 07 	cmpl   $0x7,0xf021fe88
f0100103:	77 16                	ja     f010011b <i386_init+0x81>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100105:	68 00 70 00 00       	push   $0x7000
f010010a:	68 84 6c 10 f0       	push   $0xf0106c84
f010010f:	6a 58                	push   $0x58
f0100111:	68 e7 6c 10 f0       	push   $0xf0106ce7
f0100116:	e8 25 ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010011b:	83 ec 04             	sub    $0x4,%esp
f010011e:	b8 26 62 10 f0       	mov    $0xf0106226,%eax
f0100123:	2d ac 61 10 f0       	sub    $0xf01061ac,%eax
f0100128:	50                   	push   %eax
f0100129:	68 ac 61 10 f0       	push   $0xf01061ac
f010012e:	68 00 70 00 f0       	push   $0xf0007000
f0100133:	e8 bc 5e 00 00       	call   f0105ff4 <memmove>
f0100138:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010013b:	bb 20 00 22 f0       	mov    $0xf0220020,%ebx
f0100140:	eb 4d                	jmp    f010018f <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100142:	e8 83 64 00 00       	call   f01065ca <cpunum>
f0100147:	6b c0 74             	imul   $0x74,%eax,%eax
f010014a:	05 20 00 22 f0       	add    $0xf0220020,%eax
f010014f:	39 c3                	cmp    %eax,%ebx
f0100151:	74 39                	je     f010018c <i386_init+0xf2>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100153:	89 d8                	mov    %ebx,%eax
f0100155:	2d 20 00 22 f0       	sub    $0xf0220020,%eax
f010015a:	c1 f8 02             	sar    $0x2,%eax
f010015d:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100163:	c1 e0 0f             	shl    $0xf,%eax
f0100166:	05 00 90 22 f0       	add    $0xf0229000,%eax
f010016b:	a3 84 fe 21 f0       	mov    %eax,0xf021fe84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100170:	83 ec 08             	sub    $0x8,%esp
f0100173:	68 00 70 00 00       	push   $0x7000
f0100178:	0f b6 03             	movzbl (%ebx),%eax
f010017b:	50                   	push   %eax
f010017c:	e8 b2 65 00 00       	call   f0106733 <lapic_startap>
f0100181:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100184:	8b 43 04             	mov    0x4(%ebx),%eax
f0100187:	83 f8 01             	cmp    $0x1,%eax
f010018a:	75 f8                	jne    f0100184 <i386_init+0xea>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010018c:	83 c3 74             	add    $0x74,%ebx
f010018f:	6b 05 c4 03 22 f0 74 	imul   $0x74,0xf02203c4,%eax
f0100196:	05 20 00 22 f0       	add    $0xf0220020,%eax
f010019b:	39 c3                	cmp    %eax,%ebx
f010019d:	72 a3                	jb     f0100142 <i386_init+0xa8>
	lock_kernel();

	// Starting non-boot CPUs
	boot_aps();

	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f010019f:	83 ec 08             	sub    $0x8,%esp
f01001a2:	6a 01                	push   $0x1
f01001a4:	68 b4 c3 1d f0       	push   $0xf01dc3b4
f01001a9:	e8 8a 32 00 00       	call   f0103438 <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001ae:	83 c4 08             	add    $0x8,%esp
f01001b1:	6a 00                	push   $0x0
f01001b3:	68 98 9e 21 f0       	push   $0xf0219e98
f01001b8:	e8 7b 32 00 00       	call   f0103438 <env_create>
	// Touch all you want. Calls fork.
	ENV_CREATE(user_primes, ENV_TYPE_USER);
#endif // TEST* 
	
	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01001bd:	e8 35 04 00 00       	call   f01005f7 <kbd_intr>
	// Schedule and run the first user environment!
	sched_yield();
f01001c2:	e8 df 4a 00 00       	call   f0104ca6 <sched_yield>

f01001c7 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001c7:	55                   	push   %ebp
f01001c8:	89 e5                	mov    %esp,%ebp
f01001ca:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001cd:	a1 8c fe 21 f0       	mov    0xf021fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001d2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001d7:	77 12                	ja     f01001eb <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001d9:	50                   	push   %eax
f01001da:	68 a8 6c 10 f0       	push   $0xf0106ca8
f01001df:	6a 6f                	push   $0x6f
f01001e1:	68 e7 6c 10 f0       	push   $0xf0106ce7
f01001e6:	e8 55 fe ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001eb:	05 00 00 00 10       	add    $0x10000000,%eax
f01001f0:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001f3:	e8 d2 63 00 00       	call   f01065ca <cpunum>
f01001f8:	83 ec 08             	sub    $0x8,%esp
f01001fb:	50                   	push   %eax
f01001fc:	68 f3 6c 10 f0       	push   $0xf0106cf3
f0100201:	e8 da 3b 00 00       	call   f0103de0 <cprintf>

	lapic_init();
f0100206:	e8 da 63 00 00       	call   f01065e5 <lapic_init>
	env_init_percpu();
f010020b:	e8 5b 2f 00 00       	call   f010316b <env_init_percpu>
	trap_init_percpu();
f0100210:	e8 df 3b 00 00       	call   f0103df4 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100215:	e8 b0 63 00 00       	call   f01065ca <cpunum>
f010021a:	6b d0 74             	imul   $0x74,%eax,%edx
f010021d:	81 c2 20 00 22 f0    	add    $0xf0220020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100223:	b8 01 00 00 00       	mov    $0x1,%eax
f0100228:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010022c:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f0100233:	e8 00 66 00 00       	call   f0106838 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100238:	e8 69 4a 00 00       	call   f0104ca6 <sched_yield>

f010023d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010023d:	55                   	push   %ebp
f010023e:	89 e5                	mov    %esp,%ebp
f0100240:	53                   	push   %ebx
f0100241:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100244:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100247:	ff 75 0c             	pushl  0xc(%ebp)
f010024a:	ff 75 08             	pushl  0x8(%ebp)
f010024d:	68 09 6d 10 f0       	push   $0xf0106d09
f0100252:	e8 89 3b 00 00       	call   f0103de0 <cprintf>
	vcprintf(fmt, ap);
f0100257:	83 c4 08             	add    $0x8,%esp
f010025a:	53                   	push   %ebx
f010025b:	ff 75 10             	pushl  0x10(%ebp)
f010025e:	e8 57 3b 00 00       	call   f0103dba <vcprintf>
	cprintf("\n");
f0100263:	c7 04 24 88 7e 10 f0 	movl   $0xf0107e88,(%esp)
f010026a:	e8 71 3b 00 00       	call   f0103de0 <cprintf>
	va_end(ap);
}
f010026f:	83 c4 10             	add    $0x10,%esp
f0100272:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100275:	c9                   	leave  
f0100276:	c3                   	ret    

f0100277 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100277:	55                   	push   %ebp
f0100278:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010027a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010027f:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100280:	a8 01                	test   $0x1,%al
f0100282:	74 0b                	je     f010028f <serial_proc_data+0x18>
f0100284:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100289:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010028a:	0f b6 c0             	movzbl %al,%eax
f010028d:	eb 05                	jmp    f0100294 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010028f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100294:	5d                   	pop    %ebp
f0100295:	c3                   	ret    

f0100296 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100296:	55                   	push   %ebp
f0100297:	89 e5                	mov    %esp,%ebp
f0100299:	53                   	push   %ebx
f010029a:	83 ec 04             	sub    $0x4,%esp
f010029d:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010029f:	eb 2b                	jmp    f01002cc <cons_intr+0x36>
		if (c == 0)
f01002a1:	85 c0                	test   %eax,%eax
f01002a3:	74 27                	je     f01002cc <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01002a5:	8b 0d 24 f2 21 f0    	mov    0xf021f224,%ecx
f01002ab:	8d 51 01             	lea    0x1(%ecx),%edx
f01002ae:	89 15 24 f2 21 f0    	mov    %edx,0xf021f224
f01002b4:	88 81 20 f0 21 f0    	mov    %al,-0xfde0fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002ba:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002c0:	75 0a                	jne    f01002cc <cons_intr+0x36>
			cons.wpos = 0;
f01002c2:	c7 05 24 f2 21 f0 00 	movl   $0x0,0xf021f224
f01002c9:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002cc:	ff d3                	call   *%ebx
f01002ce:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002d1:	75 ce                	jne    f01002a1 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002d3:	83 c4 04             	add    $0x4,%esp
f01002d6:	5b                   	pop    %ebx
f01002d7:	5d                   	pop    %ebp
f01002d8:	c3                   	ret    

f01002d9 <kbd_proc_data>:
f01002d9:	ba 64 00 00 00       	mov    $0x64,%edx
f01002de:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01002df:	a8 01                	test   $0x1,%al
f01002e1:	0f 84 f8 00 00 00    	je     f01003df <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01002e7:	a8 20                	test   $0x20,%al
f01002e9:	0f 85 f6 00 00 00    	jne    f01003e5 <kbd_proc_data+0x10c>
f01002ef:	ba 60 00 00 00       	mov    $0x60,%edx
f01002f4:	ec                   	in     (%dx),%al
f01002f5:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002f7:	3c e0                	cmp    $0xe0,%al
f01002f9:	75 0d                	jne    f0100308 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01002fb:	83 0d 00 f0 21 f0 40 	orl    $0x40,0xf021f000
		return 0;
f0100302:	b8 00 00 00 00       	mov    $0x0,%eax
f0100307:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100308:	55                   	push   %ebp
f0100309:	89 e5                	mov    %esp,%ebp
f010030b:	53                   	push   %ebx
f010030c:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010030f:	84 c0                	test   %al,%al
f0100311:	79 36                	jns    f0100349 <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100313:	8b 0d 00 f0 21 f0    	mov    0xf021f000,%ecx
f0100319:	89 cb                	mov    %ecx,%ebx
f010031b:	83 e3 40             	and    $0x40,%ebx
f010031e:	83 e0 7f             	and    $0x7f,%eax
f0100321:	85 db                	test   %ebx,%ebx
f0100323:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100326:	0f b6 d2             	movzbl %dl,%edx
f0100329:	0f b6 82 80 6e 10 f0 	movzbl -0xfef9180(%edx),%eax
f0100330:	83 c8 40             	or     $0x40,%eax
f0100333:	0f b6 c0             	movzbl %al,%eax
f0100336:	f7 d0                	not    %eax
f0100338:	21 c8                	and    %ecx,%eax
f010033a:	a3 00 f0 21 f0       	mov    %eax,0xf021f000
		return 0;
f010033f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100344:	e9 a4 00 00 00       	jmp    f01003ed <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100349:	8b 0d 00 f0 21 f0    	mov    0xf021f000,%ecx
f010034f:	f6 c1 40             	test   $0x40,%cl
f0100352:	74 0e                	je     f0100362 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100354:	83 c8 80             	or     $0xffffff80,%eax
f0100357:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100359:	83 e1 bf             	and    $0xffffffbf,%ecx
f010035c:	89 0d 00 f0 21 f0    	mov    %ecx,0xf021f000
	}

	shift |= shiftcode[data];
f0100362:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100365:	0f b6 82 80 6e 10 f0 	movzbl -0xfef9180(%edx),%eax
f010036c:	0b 05 00 f0 21 f0    	or     0xf021f000,%eax
f0100372:	0f b6 8a 80 6d 10 f0 	movzbl -0xfef9280(%edx),%ecx
f0100379:	31 c8                	xor    %ecx,%eax
f010037b:	a3 00 f0 21 f0       	mov    %eax,0xf021f000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100380:	89 c1                	mov    %eax,%ecx
f0100382:	83 e1 03             	and    $0x3,%ecx
f0100385:	8b 0c 8d 60 6d 10 f0 	mov    -0xfef92a0(,%ecx,4),%ecx
f010038c:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100390:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100393:	a8 08                	test   $0x8,%al
f0100395:	74 1b                	je     f01003b2 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f0100397:	89 da                	mov    %ebx,%edx
f0100399:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010039c:	83 f9 19             	cmp    $0x19,%ecx
f010039f:	77 05                	ja     f01003a6 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f01003a1:	83 eb 20             	sub    $0x20,%ebx
f01003a4:	eb 0c                	jmp    f01003b2 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f01003a6:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003a9:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003ac:	83 fa 19             	cmp    $0x19,%edx
f01003af:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003b2:	f7 d0                	not    %eax
f01003b4:	a8 06                	test   $0x6,%al
f01003b6:	75 33                	jne    f01003eb <kbd_proc_data+0x112>
f01003b8:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003be:	75 2b                	jne    f01003eb <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01003c0:	83 ec 0c             	sub    $0xc,%esp
f01003c3:	68 23 6d 10 f0       	push   $0xf0106d23
f01003c8:	e8 13 3a 00 00       	call   f0103de0 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003cd:	ba 92 00 00 00       	mov    $0x92,%edx
f01003d2:	b8 03 00 00 00       	mov    $0x3,%eax
f01003d7:	ee                   	out    %al,(%dx)
f01003d8:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003db:	89 d8                	mov    %ebx,%eax
f01003dd:	eb 0e                	jmp    f01003ed <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01003df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01003e4:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01003e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003ea:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003eb:	89 d8                	mov    %ebx,%eax
}
f01003ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003f0:	c9                   	leave  
f01003f1:	c3                   	ret    

f01003f2 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003f2:	55                   	push   %ebp
f01003f3:	89 e5                	mov    %esp,%ebp
f01003f5:	57                   	push   %edi
f01003f6:	56                   	push   %esi
f01003f7:	53                   	push   %ebx
f01003f8:	83 ec 1c             	sub    $0x1c,%esp
f01003fb:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003fd:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100402:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100407:	b9 84 00 00 00       	mov    $0x84,%ecx
f010040c:	eb 09                	jmp    f0100417 <cons_putc+0x25>
f010040e:	89 ca                	mov    %ecx,%edx
f0100410:	ec                   	in     (%dx),%al
f0100411:	ec                   	in     (%dx),%al
f0100412:	ec                   	in     (%dx),%al
f0100413:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100414:	83 c3 01             	add    $0x1,%ebx
f0100417:	89 f2                	mov    %esi,%edx
f0100419:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010041a:	a8 20                	test   $0x20,%al
f010041c:	75 08                	jne    f0100426 <cons_putc+0x34>
f010041e:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100424:	7e e8                	jle    f010040e <cons_putc+0x1c>
f0100426:	89 f8                	mov    %edi,%eax
f0100428:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010042b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100430:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100431:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100436:	be 79 03 00 00       	mov    $0x379,%esi
f010043b:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100440:	eb 09                	jmp    f010044b <cons_putc+0x59>
f0100442:	89 ca                	mov    %ecx,%edx
f0100444:	ec                   	in     (%dx),%al
f0100445:	ec                   	in     (%dx),%al
f0100446:	ec                   	in     (%dx),%al
f0100447:	ec                   	in     (%dx),%al
f0100448:	83 c3 01             	add    $0x1,%ebx
f010044b:	89 f2                	mov    %esi,%edx
f010044d:	ec                   	in     (%dx),%al
f010044e:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100454:	7f 04                	jg     f010045a <cons_putc+0x68>
f0100456:	84 c0                	test   %al,%al
f0100458:	79 e8                	jns    f0100442 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010045a:	ba 78 03 00 00       	mov    $0x378,%edx
f010045f:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100463:	ee                   	out    %al,(%dx)
f0100464:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100469:	b8 0d 00 00 00       	mov    $0xd,%eax
f010046e:	ee                   	out    %al,(%dx)
f010046f:	b8 08 00 00 00       	mov    $0x8,%eax
f0100474:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100475:	89 fa                	mov    %edi,%edx
f0100477:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010047d:	89 f8                	mov    %edi,%eax
f010047f:	80 cc 07             	or     $0x7,%ah
f0100482:	85 d2                	test   %edx,%edx
f0100484:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100487:	89 f8                	mov    %edi,%eax
f0100489:	0f b6 c0             	movzbl %al,%eax
f010048c:	83 f8 09             	cmp    $0x9,%eax
f010048f:	74 74                	je     f0100505 <cons_putc+0x113>
f0100491:	83 f8 09             	cmp    $0x9,%eax
f0100494:	7f 0a                	jg     f01004a0 <cons_putc+0xae>
f0100496:	83 f8 08             	cmp    $0x8,%eax
f0100499:	74 14                	je     f01004af <cons_putc+0xbd>
f010049b:	e9 99 00 00 00       	jmp    f0100539 <cons_putc+0x147>
f01004a0:	83 f8 0a             	cmp    $0xa,%eax
f01004a3:	74 3a                	je     f01004df <cons_putc+0xed>
f01004a5:	83 f8 0d             	cmp    $0xd,%eax
f01004a8:	74 3d                	je     f01004e7 <cons_putc+0xf5>
f01004aa:	e9 8a 00 00 00       	jmp    f0100539 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01004af:	0f b7 05 28 f2 21 f0 	movzwl 0xf021f228,%eax
f01004b6:	66 85 c0             	test   %ax,%ax
f01004b9:	0f 84 e6 00 00 00    	je     f01005a5 <cons_putc+0x1b3>
			crt_pos--;
f01004bf:	83 e8 01             	sub    $0x1,%eax
f01004c2:	66 a3 28 f2 21 f0    	mov    %ax,0xf021f228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004c8:	0f b7 c0             	movzwl %ax,%eax
f01004cb:	66 81 e7 00 ff       	and    $0xff00,%di
f01004d0:	83 cf 20             	or     $0x20,%edi
f01004d3:	8b 15 2c f2 21 f0    	mov    0xf021f22c,%edx
f01004d9:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004dd:	eb 78                	jmp    f0100557 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004df:	66 83 05 28 f2 21 f0 	addw   $0x50,0xf021f228
f01004e6:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004e7:	0f b7 05 28 f2 21 f0 	movzwl 0xf021f228,%eax
f01004ee:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004f4:	c1 e8 16             	shr    $0x16,%eax
f01004f7:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004fa:	c1 e0 04             	shl    $0x4,%eax
f01004fd:	66 a3 28 f2 21 f0    	mov    %ax,0xf021f228
f0100503:	eb 52                	jmp    f0100557 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f0100505:	b8 20 00 00 00       	mov    $0x20,%eax
f010050a:	e8 e3 fe ff ff       	call   f01003f2 <cons_putc>
		cons_putc(' ');
f010050f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100514:	e8 d9 fe ff ff       	call   f01003f2 <cons_putc>
		cons_putc(' ');
f0100519:	b8 20 00 00 00       	mov    $0x20,%eax
f010051e:	e8 cf fe ff ff       	call   f01003f2 <cons_putc>
		cons_putc(' ');
f0100523:	b8 20 00 00 00       	mov    $0x20,%eax
f0100528:	e8 c5 fe ff ff       	call   f01003f2 <cons_putc>
		cons_putc(' ');
f010052d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100532:	e8 bb fe ff ff       	call   f01003f2 <cons_putc>
f0100537:	eb 1e                	jmp    f0100557 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100539:	0f b7 05 28 f2 21 f0 	movzwl 0xf021f228,%eax
f0100540:	8d 50 01             	lea    0x1(%eax),%edx
f0100543:	66 89 15 28 f2 21 f0 	mov    %dx,0xf021f228
f010054a:	0f b7 c0             	movzwl %ax,%eax
f010054d:	8b 15 2c f2 21 f0    	mov    0xf021f22c,%edx
f0100553:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100557:	66 81 3d 28 f2 21 f0 	cmpw   $0x7cf,0xf021f228
f010055e:	cf 07 
f0100560:	76 43                	jbe    f01005a5 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100562:	a1 2c f2 21 f0       	mov    0xf021f22c,%eax
f0100567:	83 ec 04             	sub    $0x4,%esp
f010056a:	68 00 0f 00 00       	push   $0xf00
f010056f:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100575:	52                   	push   %edx
f0100576:	50                   	push   %eax
f0100577:	e8 78 5a 00 00       	call   f0105ff4 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010057c:	8b 15 2c f2 21 f0    	mov    0xf021f22c,%edx
f0100582:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100588:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010058e:	83 c4 10             	add    $0x10,%esp
f0100591:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100596:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100599:	39 d0                	cmp    %edx,%eax
f010059b:	75 f4                	jne    f0100591 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010059d:	66 83 2d 28 f2 21 f0 	subw   $0x50,0xf021f228
f01005a4:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005a5:	8b 0d 30 f2 21 f0    	mov    0xf021f230,%ecx
f01005ab:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005b0:	89 ca                	mov    %ecx,%edx
f01005b2:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005b3:	0f b7 1d 28 f2 21 f0 	movzwl 0xf021f228,%ebx
f01005ba:	8d 71 01             	lea    0x1(%ecx),%esi
f01005bd:	89 d8                	mov    %ebx,%eax
f01005bf:	66 c1 e8 08          	shr    $0x8,%ax
f01005c3:	89 f2                	mov    %esi,%edx
f01005c5:	ee                   	out    %al,(%dx)
f01005c6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005cb:	89 ca                	mov    %ecx,%edx
f01005cd:	ee                   	out    %al,(%dx)
f01005ce:	89 d8                	mov    %ebx,%eax
f01005d0:	89 f2                	mov    %esi,%edx
f01005d2:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005d6:	5b                   	pop    %ebx
f01005d7:	5e                   	pop    %esi
f01005d8:	5f                   	pop    %edi
f01005d9:	5d                   	pop    %ebp
f01005da:	c3                   	ret    

f01005db <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005db:	80 3d 34 f2 21 f0 00 	cmpb   $0x0,0xf021f234
f01005e2:	74 11                	je     f01005f5 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005e4:	55                   	push   %ebp
f01005e5:	89 e5                	mov    %esp,%ebp
f01005e7:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005ea:	b8 77 02 10 f0       	mov    $0xf0100277,%eax
f01005ef:	e8 a2 fc ff ff       	call   f0100296 <cons_intr>
}
f01005f4:	c9                   	leave  
f01005f5:	f3 c3                	repz ret 

f01005f7 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005f7:	55                   	push   %ebp
f01005f8:	89 e5                	mov    %esp,%ebp
f01005fa:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005fd:	b8 d9 02 10 f0       	mov    $0xf01002d9,%eax
f0100602:	e8 8f fc ff ff       	call   f0100296 <cons_intr>
}
f0100607:	c9                   	leave  
f0100608:	c3                   	ret    

f0100609 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100609:	55                   	push   %ebp
f010060a:	89 e5                	mov    %esp,%ebp
f010060c:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010060f:	e8 c7 ff ff ff       	call   f01005db <serial_intr>
	kbd_intr();
f0100614:	e8 de ff ff ff       	call   f01005f7 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100619:	a1 20 f2 21 f0       	mov    0xf021f220,%eax
f010061e:	3b 05 24 f2 21 f0    	cmp    0xf021f224,%eax
f0100624:	74 26                	je     f010064c <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100626:	8d 50 01             	lea    0x1(%eax),%edx
f0100629:	89 15 20 f2 21 f0    	mov    %edx,0xf021f220
f010062f:	0f b6 88 20 f0 21 f0 	movzbl -0xfde0fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100636:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100638:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010063e:	75 11                	jne    f0100651 <cons_getc+0x48>
			cons.rpos = 0;
f0100640:	c7 05 20 f2 21 f0 00 	movl   $0x0,0xf021f220
f0100647:	00 00 00 
f010064a:	eb 05                	jmp    f0100651 <cons_getc+0x48>
		return c;
	}
	return 0;
f010064c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100651:	c9                   	leave  
f0100652:	c3                   	ret    

f0100653 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100653:	55                   	push   %ebp
f0100654:	89 e5                	mov    %esp,%ebp
f0100656:	57                   	push   %edi
f0100657:	56                   	push   %esi
f0100658:	53                   	push   %ebx
f0100659:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010065c:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100663:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010066a:	5a a5 
	if (*cp != 0xA55A) {
f010066c:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100673:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100677:	74 11                	je     f010068a <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100679:	c7 05 30 f2 21 f0 b4 	movl   $0x3b4,0xf021f230
f0100680:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100683:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100688:	eb 16                	jmp    f01006a0 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010068a:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100691:	c7 05 30 f2 21 f0 d4 	movl   $0x3d4,0xf021f230
f0100698:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010069b:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006a0:	8b 3d 30 f2 21 f0    	mov    0xf021f230,%edi
f01006a6:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006ab:	89 fa                	mov    %edi,%edx
f01006ad:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006ae:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006b1:	89 da                	mov    %ebx,%edx
f01006b3:	ec                   	in     (%dx),%al
f01006b4:	0f b6 c8             	movzbl %al,%ecx
f01006b7:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006ba:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006bf:	89 fa                	mov    %edi,%edx
f01006c1:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006c2:	89 da                	mov    %ebx,%edx
f01006c4:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006c5:	89 35 2c f2 21 f0    	mov    %esi,0xf021f22c
	crt_pos = pos;
f01006cb:	0f b6 c0             	movzbl %al,%eax
f01006ce:	09 c8                	or     %ecx,%eax
f01006d0:	66 a3 28 f2 21 f0    	mov    %ax,0xf021f228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006d6:	e8 1c ff ff ff       	call   f01005f7 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006db:	83 ec 0c             	sub    $0xc,%esp
f01006de:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f01006e5:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006ea:	50                   	push   %eax
f01006eb:	e8 9f 35 00 00       	call   f0103c8f <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006f0:	be fa 03 00 00       	mov    $0x3fa,%esi
f01006f5:	b8 00 00 00 00       	mov    $0x0,%eax
f01006fa:	89 f2                	mov    %esi,%edx
f01006fc:	ee                   	out    %al,(%dx)
f01006fd:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100702:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100707:	ee                   	out    %al,(%dx)
f0100708:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f010070d:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100712:	89 da                	mov    %ebx,%edx
f0100714:	ee                   	out    %al,(%dx)
f0100715:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010071a:	b8 00 00 00 00       	mov    $0x0,%eax
f010071f:	ee                   	out    %al,(%dx)
f0100720:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100725:	b8 03 00 00 00       	mov    $0x3,%eax
f010072a:	ee                   	out    %al,(%dx)
f010072b:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100730:	b8 00 00 00 00       	mov    $0x0,%eax
f0100735:	ee                   	out    %al,(%dx)
f0100736:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010073b:	b8 01 00 00 00       	mov    $0x1,%eax
f0100740:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100741:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100746:	ec                   	in     (%dx),%al
f0100747:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100749:	83 c4 10             	add    $0x10,%esp
f010074c:	3c ff                	cmp    $0xff,%al
f010074e:	0f 95 05 34 f2 21 f0 	setne  0xf021f234
f0100755:	89 f2                	mov    %esi,%edx
f0100757:	ec                   	in     (%dx),%al
f0100758:	89 da                	mov    %ebx,%edx
f010075a:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f010075b:	80 f9 ff             	cmp    $0xff,%cl
f010075e:	74 21                	je     f0100781 <cons_init+0x12e>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f0100760:	83 ec 0c             	sub    $0xc,%esp
f0100763:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f010076a:	25 ef ff 00 00       	and    $0xffef,%eax
f010076f:	50                   	push   %eax
f0100770:	e8 1a 35 00 00       	call   f0103c8f <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100775:	83 c4 10             	add    $0x10,%esp
f0100778:	80 3d 34 f2 21 f0 00 	cmpb   $0x0,0xf021f234
f010077f:	75 10                	jne    f0100791 <cons_init+0x13e>
		cprintf("Serial port does not exist!\n");
f0100781:	83 ec 0c             	sub    $0xc,%esp
f0100784:	68 2f 6d 10 f0       	push   $0xf0106d2f
f0100789:	e8 52 36 00 00       	call   f0103de0 <cprintf>
f010078e:	83 c4 10             	add    $0x10,%esp
}
f0100791:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100794:	5b                   	pop    %ebx
f0100795:	5e                   	pop    %esi
f0100796:	5f                   	pop    %edi
f0100797:	5d                   	pop    %ebp
f0100798:	c3                   	ret    

f0100799 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100799:	55                   	push   %ebp
f010079a:	89 e5                	mov    %esp,%ebp
f010079c:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010079f:	8b 45 08             	mov    0x8(%ebp),%eax
f01007a2:	e8 4b fc ff ff       	call   f01003f2 <cons_putc>
}
f01007a7:	c9                   	leave  
f01007a8:	c3                   	ret    

f01007a9 <getchar>:

int
getchar(void)
{
f01007a9:	55                   	push   %ebp
f01007aa:	89 e5                	mov    %esp,%ebp
f01007ac:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007af:	e8 55 fe ff ff       	call   f0100609 <cons_getc>
f01007b4:	85 c0                	test   %eax,%eax
f01007b6:	74 f7                	je     f01007af <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007b8:	c9                   	leave  
f01007b9:	c3                   	ret    

f01007ba <iscons>:

int
iscons(int fdnum)
{
f01007ba:	55                   	push   %ebp
f01007bb:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007bd:	b8 01 00 00 00       	mov    $0x1,%eax
f01007c2:	5d                   	pop    %ebp
f01007c3:	c3                   	ret    

f01007c4 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007c4:	55                   	push   %ebp
f01007c5:	89 e5                	mov    %esp,%ebp
f01007c7:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007ca:	68 80 6f 10 f0       	push   $0xf0106f80
f01007cf:	68 9e 6f 10 f0       	push   $0xf0106f9e
f01007d4:	68 a3 6f 10 f0       	push   $0xf0106fa3
f01007d9:	e8 02 36 00 00       	call   f0103de0 <cprintf>
f01007de:	83 c4 0c             	add    $0xc,%esp
f01007e1:	68 5c 70 10 f0       	push   $0xf010705c
f01007e6:	68 ac 6f 10 f0       	push   $0xf0106fac
f01007eb:	68 a3 6f 10 f0       	push   $0xf0106fa3
f01007f0:	e8 eb 35 00 00       	call   f0103de0 <cprintf>
f01007f5:	83 c4 0c             	add    $0xc,%esp
f01007f8:	68 b5 6f 10 f0       	push   $0xf0106fb5
f01007fd:	68 bd 6f 10 f0       	push   $0xf0106fbd
f0100802:	68 a3 6f 10 f0       	push   $0xf0106fa3
f0100807:	e8 d4 35 00 00       	call   f0103de0 <cprintf>
	return 0;
}
f010080c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100811:	c9                   	leave  
f0100812:	c3                   	ret    

f0100813 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100813:	55                   	push   %ebp
f0100814:	89 e5                	mov    %esp,%ebp
f0100816:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100819:	68 c7 6f 10 f0       	push   $0xf0106fc7
f010081e:	e8 bd 35 00 00       	call   f0103de0 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100823:	83 c4 08             	add    $0x8,%esp
f0100826:	68 0c 00 10 00       	push   $0x10000c
f010082b:	68 84 70 10 f0       	push   $0xf0107084
f0100830:	e8 ab 35 00 00       	call   f0103de0 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100835:	83 c4 0c             	add    $0xc,%esp
f0100838:	68 0c 00 10 00       	push   $0x10000c
f010083d:	68 0c 00 10 f0       	push   $0xf010000c
f0100842:	68 ac 70 10 f0       	push   $0xf01070ac
f0100847:	e8 94 35 00 00       	call   f0103de0 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010084c:	83 c4 0c             	add    $0xc,%esp
f010084f:	68 51 6c 10 00       	push   $0x106c51
f0100854:	68 51 6c 10 f0       	push   $0xf0106c51
f0100859:	68 d0 70 10 f0       	push   $0xf01070d0
f010085e:	e8 7d 35 00 00       	call   f0103de0 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100863:	83 c4 0c             	add    $0xc,%esp
f0100866:	68 48 ef 21 00       	push   $0x21ef48
f010086b:	68 48 ef 21 f0       	push   $0xf021ef48
f0100870:	68 f4 70 10 f0       	push   $0xf01070f4
f0100875:	e8 66 35 00 00       	call   f0103de0 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010087a:	83 c4 0c             	add    $0xc,%esp
f010087d:	68 08 10 26 00       	push   $0x261008
f0100882:	68 08 10 26 f0       	push   $0xf0261008
f0100887:	68 18 71 10 f0       	push   $0xf0107118
f010088c:	e8 4f 35 00 00       	call   f0103de0 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100891:	b8 07 14 26 f0       	mov    $0xf0261407,%eax
f0100896:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010089b:	83 c4 08             	add    $0x8,%esp
f010089e:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01008a3:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01008a9:	85 c0                	test   %eax,%eax
f01008ab:	0f 48 c2             	cmovs  %edx,%eax
f01008ae:	c1 f8 0a             	sar    $0xa,%eax
f01008b1:	50                   	push   %eax
f01008b2:	68 3c 71 10 f0       	push   $0xf010713c
f01008b7:	e8 24 35 00 00       	call   f0103de0 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008bc:	b8 00 00 00 00       	mov    $0x0,%eax
f01008c1:	c9                   	leave  
f01008c2:	c3                   	ret    

f01008c3 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008c3:	55                   	push   %ebp
f01008c4:	89 e5                	mov    %esp,%ebp
f01008c6:	57                   	push   %edi
f01008c7:	56                   	push   %esi
f01008c8:	53                   	push   %ebx
f01008c9:	83 ec 38             	sub    $0x38,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008cc:	89 ee                	mov    %ebp,%esi
	uintptr_t *eip;
	uint32_t bytes_fn_start;

	struct Eipdebuginfo info;
		
	cprintf("Stack backtrace:\n");
f01008ce:	68 e0 6f 10 f0       	push   $0xf0106fe0
f01008d3:	e8 08 35 00 00       	call   f0103de0 <cprintf>
	
	while (ebp != 0) {
f01008d8:	83 c4 10             	add    $0x10,%esp
f01008db:	eb 67                	jmp    f0100944 <mon_backtrace+0x81>
		eip = ebp + 1;	   //eip is stored after ebp
		cprintf("ebp %x eip %x args ", ebp, *eip);
f01008dd:	83 ec 04             	sub    $0x4,%esp
f01008e0:	ff 76 04             	pushl  0x4(%esi)
f01008e3:	56                   	push   %esi
f01008e4:	68 f2 6f 10 f0       	push   $0xf0106ff2
f01008e9:	e8 f2 34 00 00       	call   f0103de0 <cprintf>
f01008ee:	8d 5e 08             	lea    0x8(%esi),%ebx
f01008f1:	8d 7e 1c             	lea    0x1c(%esi),%edi
f01008f4:	83 c4 10             	add    $0x10,%esp

		size_t arg_num;
		//print arguments stored after instruction pointer
		for (arg_num = 1; arg_num <= 5; arg_num++) {
			cprintf("%08x ", *(eip + arg_num));
f01008f7:	83 ec 08             	sub    $0x8,%esp
f01008fa:	ff 33                	pushl  (%ebx)
f01008fc:	68 06 70 10 f0       	push   $0xf0107006
f0100901:	e8 da 34 00 00       	call   f0103de0 <cprintf>
f0100906:	83 c3 04             	add    $0x4,%ebx
		eip = ebp + 1;	   //eip is stored after ebp
		cprintf("ebp %x eip %x args ", ebp, *eip);

		size_t arg_num;
		//print arguments stored after instruction pointer
		for (arg_num = 1; arg_num <= 5; arg_num++) {
f0100909:	83 c4 10             	add    $0x10,%esp
f010090c:	39 fb                	cmp    %edi,%ebx
f010090e:	75 e7                	jne    f01008f7 <mon_backtrace+0x34>
			cprintf("%08x ", *(eip + arg_num));
		} 

		debuginfo_eip(*eip, &info);
f0100910:	83 ec 08             	sub    $0x8,%esp
f0100913:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100916:	50                   	push   %eax
f0100917:	ff 76 04             	pushl  0x4(%esi)
f010091a:	e8 a0 4c 00 00       	call   f01055bf <debuginfo_eip>

		//calculate number of bytes between ret address and address
		//at the start of the function
		bytes_fn_start = *eip - info.eip_fn_addr;
		cprintf("\n\t%s:%d: %.*s+%d\n",
f010091f:	83 c4 08             	add    $0x8,%esp
f0100922:	8b 46 04             	mov    0x4(%esi),%eax
f0100925:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100928:	50                   	push   %eax
f0100929:	ff 75 d8             	pushl  -0x28(%ebp)
f010092c:	ff 75 dc             	pushl  -0x24(%ebp)
f010092f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100932:	ff 75 d0             	pushl  -0x30(%ebp)
f0100935:	68 0c 70 10 f0       	push   $0xf010700c
f010093a:	e8 a1 34 00 00       	call   f0103de0 <cprintf>
		       	info.eip_file, info.eip_line, info.eip_fn_namelen, 
			info.eip_fn_name, bytes_fn_start);

		//iterate through the value stored in ebp
		ebp = (uintptr_t*) *ebp;
f010093f:	8b 36                	mov    (%esi),%esi
f0100941:	83 c4 20             	add    $0x20,%esp

	struct Eipdebuginfo info;
		
	cprintf("Stack backtrace:\n");
	
	while (ebp != 0) {
f0100944:	85 f6                	test   %esi,%esi
f0100946:	75 95                	jne    f01008dd <mon_backtrace+0x1a>
		//iterate through the value stored in ebp
		ebp = (uintptr_t*) *ebp;
	}
	
	return 0;
}
f0100948:	b8 00 00 00 00       	mov    $0x0,%eax
f010094d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100950:	5b                   	pop    %ebx
f0100951:	5e                   	pop    %esi
f0100952:	5f                   	pop    %edi
f0100953:	5d                   	pop    %ebp
f0100954:	c3                   	ret    

f0100955 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100955:	55                   	push   %ebp
f0100956:	89 e5                	mov    %esp,%ebp
f0100958:	57                   	push   %edi
f0100959:	56                   	push   %esi
f010095a:	53                   	push   %ebx
f010095b:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010095e:	68 68 71 10 f0       	push   $0xf0107168
f0100963:	e8 78 34 00 00       	call   f0103de0 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100968:	c7 04 24 8c 71 10 f0 	movl   $0xf010718c,(%esp)
f010096f:	e8 6c 34 00 00       	call   f0103de0 <cprintf>

	if (tf != NULL)
f0100974:	83 c4 10             	add    $0x10,%esp
f0100977:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010097b:	74 0e                	je     f010098b <monitor+0x36>
		print_trapframe(tf);
f010097d:	83 ec 0c             	sub    $0xc,%esp
f0100980:	ff 75 08             	pushl  0x8(%ebp)
f0100983:	e8 cf 3b 00 00       	call   f0104557 <print_trapframe>
f0100988:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f010098b:	83 ec 0c             	sub    $0xc,%esp
f010098e:	68 1e 70 10 f0       	push   $0xf010701e
f0100993:	e8 a0 53 00 00       	call   f0105d38 <readline>
f0100998:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010099a:	83 c4 10             	add    $0x10,%esp
f010099d:	85 c0                	test   %eax,%eax
f010099f:	74 ea                	je     f010098b <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01009a1:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01009a8:	be 00 00 00 00       	mov    $0x0,%esi
f01009ad:	eb 0a                	jmp    f01009b9 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01009af:	c6 03 00             	movb   $0x0,(%ebx)
f01009b2:	89 f7                	mov    %esi,%edi
f01009b4:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01009b7:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01009b9:	0f b6 03             	movzbl (%ebx),%eax
f01009bc:	84 c0                	test   %al,%al
f01009be:	74 63                	je     f0100a23 <monitor+0xce>
f01009c0:	83 ec 08             	sub    $0x8,%esp
f01009c3:	0f be c0             	movsbl %al,%eax
f01009c6:	50                   	push   %eax
f01009c7:	68 22 70 10 f0       	push   $0xf0107022
f01009cc:	e8 99 55 00 00       	call   f0105f6a <strchr>
f01009d1:	83 c4 10             	add    $0x10,%esp
f01009d4:	85 c0                	test   %eax,%eax
f01009d6:	75 d7                	jne    f01009af <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f01009d8:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009db:	74 46                	je     f0100a23 <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01009dd:	83 fe 0f             	cmp    $0xf,%esi
f01009e0:	75 14                	jne    f01009f6 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009e2:	83 ec 08             	sub    $0x8,%esp
f01009e5:	6a 10                	push   $0x10
f01009e7:	68 27 70 10 f0       	push   $0xf0107027
f01009ec:	e8 ef 33 00 00       	call   f0103de0 <cprintf>
f01009f1:	83 c4 10             	add    $0x10,%esp
f01009f4:	eb 95                	jmp    f010098b <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f01009f6:	8d 7e 01             	lea    0x1(%esi),%edi
f01009f9:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01009fd:	eb 03                	jmp    f0100a02 <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01009ff:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a02:	0f b6 03             	movzbl (%ebx),%eax
f0100a05:	84 c0                	test   %al,%al
f0100a07:	74 ae                	je     f01009b7 <monitor+0x62>
f0100a09:	83 ec 08             	sub    $0x8,%esp
f0100a0c:	0f be c0             	movsbl %al,%eax
f0100a0f:	50                   	push   %eax
f0100a10:	68 22 70 10 f0       	push   $0xf0107022
f0100a15:	e8 50 55 00 00       	call   f0105f6a <strchr>
f0100a1a:	83 c4 10             	add    $0x10,%esp
f0100a1d:	85 c0                	test   %eax,%eax
f0100a1f:	74 de                	je     f01009ff <monitor+0xaa>
f0100a21:	eb 94                	jmp    f01009b7 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f0100a23:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a2a:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a2b:	85 f6                	test   %esi,%esi
f0100a2d:	0f 84 58 ff ff ff    	je     f010098b <monitor+0x36>
f0100a33:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a38:	83 ec 08             	sub    $0x8,%esp
f0100a3b:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a3e:	ff 34 85 c0 71 10 f0 	pushl  -0xfef8e40(,%eax,4)
f0100a45:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a48:	e8 bf 54 00 00       	call   f0105f0c <strcmp>
f0100a4d:	83 c4 10             	add    $0x10,%esp
f0100a50:	85 c0                	test   %eax,%eax
f0100a52:	75 21                	jne    f0100a75 <monitor+0x120>
			return commands[i].func(argc, argv, tf);
f0100a54:	83 ec 04             	sub    $0x4,%esp
f0100a57:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a5a:	ff 75 08             	pushl  0x8(%ebp)
f0100a5d:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a60:	52                   	push   %edx
f0100a61:	56                   	push   %esi
f0100a62:	ff 14 85 c8 71 10 f0 	call   *-0xfef8e38(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a69:	83 c4 10             	add    $0x10,%esp
f0100a6c:	85 c0                	test   %eax,%eax
f0100a6e:	78 25                	js     f0100a95 <monitor+0x140>
f0100a70:	e9 16 ff ff ff       	jmp    f010098b <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a75:	83 c3 01             	add    $0x1,%ebx
f0100a78:	83 fb 03             	cmp    $0x3,%ebx
f0100a7b:	75 bb                	jne    f0100a38 <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a7d:	83 ec 08             	sub    $0x8,%esp
f0100a80:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a83:	68 44 70 10 f0       	push   $0xf0107044
f0100a88:	e8 53 33 00 00       	call   f0103de0 <cprintf>
f0100a8d:	83 c4 10             	add    $0x10,%esp
f0100a90:	e9 f6 fe ff ff       	jmp    f010098b <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a95:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a98:	5b                   	pop    %ebx
f0100a99:	5e                   	pop    %esi
f0100a9a:	5f                   	pop    %edi
f0100a9b:	5d                   	pop    %ebp
f0100a9c:	c3                   	ret    

f0100a9d <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100a9d:	55                   	push   %ebp
f0100a9e:	89 e5                	mov    %esp,%ebp
f0100aa0:	56                   	push   %esi
f0100aa1:	53                   	push   %ebx
f0100aa2:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100aa4:	83 ec 0c             	sub    $0xc,%esp
f0100aa7:	50                   	push   %eax
f0100aa8:	e8 b4 31 00 00       	call   f0103c61 <mc146818_read>
f0100aad:	89 c6                	mov    %eax,%esi
f0100aaf:	83 c3 01             	add    $0x1,%ebx
f0100ab2:	89 1c 24             	mov    %ebx,(%esp)
f0100ab5:	e8 a7 31 00 00       	call   f0103c61 <mc146818_read>
f0100aba:	c1 e0 08             	shl    $0x8,%eax
f0100abd:	09 f0                	or     %esi,%eax
}
f0100abf:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ac2:	5b                   	pop    %ebx
f0100ac3:	5e                   	pop    %esi
f0100ac4:	5d                   	pop    %ebp
f0100ac5:	c3                   	ret    

f0100ac6 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100ac6:	89 d1                	mov    %edx,%ecx
f0100ac8:	c1 e9 16             	shr    $0x16,%ecx
f0100acb:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100ace:	a8 01                	test   $0x1,%al
f0100ad0:	74 52                	je     f0100b24 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100ad2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ad7:	89 c1                	mov    %eax,%ecx
f0100ad9:	c1 e9 0c             	shr    $0xc,%ecx
f0100adc:	3b 0d 88 fe 21 f0    	cmp    0xf021fe88,%ecx
f0100ae2:	72 1b                	jb     f0100aff <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100ae4:	55                   	push   %ebp
f0100ae5:	89 e5                	mov    %esp,%ebp
f0100ae7:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100aea:	50                   	push   %eax
f0100aeb:	68 84 6c 10 f0       	push   $0xf0106c84
f0100af0:	68 cd 03 00 00       	push   $0x3cd
f0100af5:	68 51 7b 10 f0       	push   $0xf0107b51
f0100afa:	e8 41 f5 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100aff:	c1 ea 0c             	shr    $0xc,%edx
f0100b02:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b08:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b0f:	89 c2                	mov    %eax,%edx
f0100b11:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b14:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b19:	85 d2                	test   %edx,%edx
f0100b1b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b20:	0f 44 c2             	cmove  %edx,%eax
f0100b23:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100b24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100b29:	c3                   	ret    

f0100b2a <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100b2a:	83 3d 38 f2 21 f0 00 	cmpl   $0x0,0xf021f238
f0100b31:	75 11                	jne    f0100b44 <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b33:	ba 07 20 26 f0       	mov    $0xf0262007,%edx
f0100b38:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b3e:	89 15 38 f2 21 f0    	mov    %edx,0xf021f238
        // Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
        if (n == 0)
f0100b44:	85 c0                	test   %eax,%eax
f0100b46:	75 06                	jne    f0100b4e <boot_alloc+0x24>
                return nextfree;
f0100b48:	a1 38 f2 21 f0       	mov    0xf021f238,%eax

        result = nextfree;        
        nextfree = ROUNDUP((char *) (nextfree + n), PGSIZE);

        return result;
}
f0100b4d:	c3                   	ret    
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100b4e:	55                   	push   %ebp
f0100b4f:	89 e5                	mov    %esp,%ebp
f0100b51:	53                   	push   %ebx
f0100b52:	83 ec 04             	sub    $0x4,%esp
f0100b55:	89 c3                	mov    %eax,%ebx
	// LAB 2: Your code here.
        if (n == 0)
                return nextfree;

        // We only have 4MB of memory available
        if (4 * 1024 * 1024 - PADDR(nextfree) < n) 
f0100b57:	8b 15 38 f2 21 f0    	mov    0xf021f238,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100b5d:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100b63:	77 12                	ja     f0100b77 <boot_alloc+0x4d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100b65:	52                   	push   %edx
f0100b66:	68 a8 6c 10 f0       	push   $0xf0106ca8
f0100b6b:	6a 70                	push   $0x70
f0100b6d:	68 51 7b 10 f0       	push   $0xf0107b51
f0100b72:	e8 c9 f4 ff ff       	call   f0100040 <_panic>
f0100b77:	b8 00 00 40 f0       	mov    $0xf0400000,%eax
f0100b7c:	29 d0                	sub    %edx,%eax
f0100b7e:	39 c3                	cmp    %eax,%ebx
f0100b80:	76 14                	jbe    f0100b96 <boot_alloc+0x6c>
               panic("boot_alloc: ran out of free memory"); 
f0100b82:	83 ec 04             	sub    $0x4,%esp
f0100b85:	68 e4 71 10 f0       	push   $0xf01071e4
f0100b8a:	6a 71                	push   $0x71
f0100b8c:	68 51 7b 10 f0       	push   $0xf0107b51
f0100b91:	e8 aa f4 ff ff       	call   f0100040 <_panic>
	cprintf("in boot alloc: free mem: %d\n",(4 * 1024 * 1024 - PADDR(nextfree)));
f0100b96:	83 ec 08             	sub    $0x8,%esp
f0100b99:	50                   	push   %eax
f0100b9a:	68 5d 7b 10 f0       	push   $0xf0107b5d
f0100b9f:	e8 3c 32 00 00       	call   f0103de0 <cprintf>

        result = nextfree;        
f0100ba4:	a1 38 f2 21 f0       	mov    0xf021f238,%eax
        nextfree = ROUNDUP((char *) (nextfree + n), PGSIZE);
f0100ba9:	8d 94 18 ff 0f 00 00 	lea    0xfff(%eax,%ebx,1),%edx
f0100bb0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100bb6:	89 15 38 f2 21 f0    	mov    %edx,0xf021f238

        return result;
f0100bbc:	83 c4 10             	add    $0x10,%esp
}
f0100bbf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100bc2:	c9                   	leave  
f0100bc3:	c3                   	ret    

f0100bc4 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100bc4:	55                   	push   %ebp
f0100bc5:	89 e5                	mov    %esp,%ebp
f0100bc7:	57                   	push   %edi
f0100bc8:	56                   	push   %esi
f0100bc9:	53                   	push   %ebx
f0100bca:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bcd:	84 c0                	test   %al,%al
f0100bcf:	0f 85 a0 02 00 00    	jne    f0100e75 <check_page_free_list+0x2b1>
f0100bd5:	e9 ad 02 00 00       	jmp    f0100e87 <check_page_free_list+0x2c3>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100bda:	83 ec 04             	sub    $0x4,%esp
f0100bdd:	68 08 72 10 f0       	push   $0xf0107208
f0100be2:	68 00 03 00 00       	push   $0x300
f0100be7:	68 51 7b 10 f0       	push   $0xf0107b51
f0100bec:	e8 4f f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100bf1:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100bf4:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100bf7:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100bfa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100bfd:	89 c2                	mov    %eax,%edx
f0100bff:	2b 15 90 fe 21 f0    	sub    0xf021fe90,%edx
f0100c05:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100c0b:	0f 95 c2             	setne  %dl
f0100c0e:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100c11:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100c15:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100c17:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c1b:	8b 00                	mov    (%eax),%eax
f0100c1d:	85 c0                	test   %eax,%eax
f0100c1f:	75 dc                	jne    f0100bfd <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100c21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c24:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100c2a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c2d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c30:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100c32:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c35:	a3 40 f2 21 f0       	mov    %eax,0xf021f240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c3a:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c3f:	8b 1d 40 f2 21 f0    	mov    0xf021f240,%ebx
f0100c45:	eb 53                	jmp    f0100c9a <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c47:	89 d8                	mov    %ebx,%eax
f0100c49:	2b 05 90 fe 21 f0    	sub    0xf021fe90,%eax
f0100c4f:	c1 f8 03             	sar    $0x3,%eax
f0100c52:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c55:	89 c2                	mov    %eax,%edx
f0100c57:	c1 ea 16             	shr    $0x16,%edx
f0100c5a:	39 f2                	cmp    %esi,%edx
f0100c5c:	73 3a                	jae    f0100c98 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c5e:	89 c2                	mov    %eax,%edx
f0100c60:	c1 ea 0c             	shr    $0xc,%edx
f0100c63:	3b 15 88 fe 21 f0    	cmp    0xf021fe88,%edx
f0100c69:	72 12                	jb     f0100c7d <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c6b:	50                   	push   %eax
f0100c6c:	68 84 6c 10 f0       	push   $0xf0106c84
f0100c71:	6a 58                	push   $0x58
f0100c73:	68 7a 7b 10 f0       	push   $0xf0107b7a
f0100c78:	e8 c3 f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c7d:	83 ec 04             	sub    $0x4,%esp
f0100c80:	68 80 00 00 00       	push   $0x80
f0100c85:	68 97 00 00 00       	push   $0x97
f0100c8a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c8f:	50                   	push   %eax
f0100c90:	e8 12 53 00 00       	call   f0105fa7 <memset>
f0100c95:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c98:	8b 1b                	mov    (%ebx),%ebx
f0100c9a:	85 db                	test   %ebx,%ebx
f0100c9c:	75 a9                	jne    f0100c47 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c9e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ca3:	e8 82 fe ff ff       	call   f0100b2a <boot_alloc>
f0100ca8:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cab:	8b 15 40 f2 21 f0    	mov    0xf021f240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cb1:	8b 0d 90 fe 21 f0    	mov    0xf021fe90,%ecx
		assert(pp < pages + npages);
f0100cb7:	a1 88 fe 21 f0       	mov    0xf021fe88,%eax
f0100cbc:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100cbf:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100cc2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cc5:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100cc8:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ccd:	e9 52 01 00 00       	jmp    f0100e24 <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cd2:	39 ca                	cmp    %ecx,%edx
f0100cd4:	73 19                	jae    f0100cef <check_page_free_list+0x12b>
f0100cd6:	68 88 7b 10 f0       	push   $0xf0107b88
f0100cdb:	68 94 7b 10 f0       	push   $0xf0107b94
f0100ce0:	68 1a 03 00 00       	push   $0x31a
f0100ce5:	68 51 7b 10 f0       	push   $0xf0107b51
f0100cea:	e8 51 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100cef:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100cf2:	72 19                	jb     f0100d0d <check_page_free_list+0x149>
f0100cf4:	68 a9 7b 10 f0       	push   $0xf0107ba9
f0100cf9:	68 94 7b 10 f0       	push   $0xf0107b94
f0100cfe:	68 1b 03 00 00       	push   $0x31b
f0100d03:	68 51 7b 10 f0       	push   $0xf0107b51
f0100d08:	e8 33 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d0d:	89 d0                	mov    %edx,%eax
f0100d0f:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d12:	a8 07                	test   $0x7,%al
f0100d14:	74 19                	je     f0100d2f <check_page_free_list+0x16b>
f0100d16:	68 2c 72 10 f0       	push   $0xf010722c
f0100d1b:	68 94 7b 10 f0       	push   $0xf0107b94
f0100d20:	68 1c 03 00 00       	push   $0x31c
f0100d25:	68 51 7b 10 f0       	push   $0xf0107b51
f0100d2a:	e8 11 f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d2f:	c1 f8 03             	sar    $0x3,%eax
f0100d32:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100d35:	85 c0                	test   %eax,%eax
f0100d37:	75 19                	jne    f0100d52 <check_page_free_list+0x18e>
f0100d39:	68 bd 7b 10 f0       	push   $0xf0107bbd
f0100d3e:	68 94 7b 10 f0       	push   $0xf0107b94
f0100d43:	68 1f 03 00 00       	push   $0x31f
f0100d48:	68 51 7b 10 f0       	push   $0xf0107b51
f0100d4d:	e8 ee f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d52:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d57:	75 19                	jne    f0100d72 <check_page_free_list+0x1ae>
f0100d59:	68 ce 7b 10 f0       	push   $0xf0107bce
f0100d5e:	68 94 7b 10 f0       	push   $0xf0107b94
f0100d63:	68 20 03 00 00       	push   $0x320
f0100d68:	68 51 7b 10 f0       	push   $0xf0107b51
f0100d6d:	e8 ce f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d72:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d77:	75 19                	jne    f0100d92 <check_page_free_list+0x1ce>
f0100d79:	68 60 72 10 f0       	push   $0xf0107260
f0100d7e:	68 94 7b 10 f0       	push   $0xf0107b94
f0100d83:	68 21 03 00 00       	push   $0x321
f0100d88:	68 51 7b 10 f0       	push   $0xf0107b51
f0100d8d:	e8 ae f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d92:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d97:	75 19                	jne    f0100db2 <check_page_free_list+0x1ee>
f0100d99:	68 e7 7b 10 f0       	push   $0xf0107be7
f0100d9e:	68 94 7b 10 f0       	push   $0xf0107b94
f0100da3:	68 22 03 00 00       	push   $0x322
f0100da8:	68 51 7b 10 f0       	push   $0xf0107b51
f0100dad:	e8 8e f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100db2:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100db7:	0f 86 f1 00 00 00    	jbe    f0100eae <check_page_free_list+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100dbd:	89 c7                	mov    %eax,%edi
f0100dbf:	c1 ef 0c             	shr    $0xc,%edi
f0100dc2:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100dc5:	77 12                	ja     f0100dd9 <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100dc7:	50                   	push   %eax
f0100dc8:	68 84 6c 10 f0       	push   $0xf0106c84
f0100dcd:	6a 58                	push   $0x58
f0100dcf:	68 7a 7b 10 f0       	push   $0xf0107b7a
f0100dd4:	e8 67 f2 ff ff       	call   f0100040 <_panic>
f0100dd9:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100ddf:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100de2:	0f 86 b6 00 00 00    	jbe    f0100e9e <check_page_free_list+0x2da>
f0100de8:	68 84 72 10 f0       	push   $0xf0107284
f0100ded:	68 94 7b 10 f0       	push   $0xf0107b94
f0100df2:	68 23 03 00 00       	push   $0x323
f0100df7:	68 51 7b 10 f0       	push   $0xf0107b51
f0100dfc:	e8 3f f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e01:	68 01 7c 10 f0       	push   $0xf0107c01
f0100e06:	68 94 7b 10 f0       	push   $0xf0107b94
f0100e0b:	68 25 03 00 00       	push   $0x325
f0100e10:	68 51 7b 10 f0       	push   $0xf0107b51
f0100e15:	e8 26 f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM) 
			++nfree_basemem;
f0100e1a:	83 c6 01             	add    $0x1,%esi
f0100e1d:	eb 03                	jmp    f0100e22 <check_page_free_list+0x25e>
                else
			++nfree_extmem;
f0100e1f:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e22:	8b 12                	mov    (%edx),%edx
f0100e24:	85 d2                	test   %edx,%edx
f0100e26:	0f 85 a6 fe ff ff    	jne    f0100cd2 <check_page_free_list+0x10e>
			++nfree_basemem;
                else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100e2c:	85 f6                	test   %esi,%esi
f0100e2e:	7f 19                	jg     f0100e49 <check_page_free_list+0x285>
f0100e30:	68 1e 7c 10 f0       	push   $0xf0107c1e
f0100e35:	68 94 7b 10 f0       	push   $0xf0107b94
f0100e3a:	68 2d 03 00 00       	push   $0x32d
f0100e3f:	68 51 7b 10 f0       	push   $0xf0107b51
f0100e44:	e8 f7 f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e49:	85 db                	test   %ebx,%ebx
f0100e4b:	7f 19                	jg     f0100e66 <check_page_free_list+0x2a2>
f0100e4d:	68 30 7c 10 f0       	push   $0xf0107c30
f0100e52:	68 94 7b 10 f0       	push   $0xf0107b94
f0100e57:	68 2e 03 00 00       	push   $0x32e
f0100e5c:	68 51 7b 10 f0       	push   $0xf0107b51
f0100e61:	e8 da f1 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100e66:	83 ec 0c             	sub    $0xc,%esp
f0100e69:	68 cc 72 10 f0       	push   $0xf01072cc
f0100e6e:	e8 6d 2f 00 00       	call   f0103de0 <cprintf>
}
f0100e73:	eb 49                	jmp    f0100ebe <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e75:	a1 40 f2 21 f0       	mov    0xf021f240,%eax
f0100e7a:	85 c0                	test   %eax,%eax
f0100e7c:	0f 85 6f fd ff ff    	jne    f0100bf1 <check_page_free_list+0x2d>
f0100e82:	e9 53 fd ff ff       	jmp    f0100bda <check_page_free_list+0x16>
f0100e87:	83 3d 40 f2 21 f0 00 	cmpl   $0x0,0xf021f240
f0100e8e:	0f 84 46 fd ff ff    	je     f0100bda <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e94:	be 00 04 00 00       	mov    $0x400,%esi
f0100e99:	e9 a1 fd ff ff       	jmp    f0100c3f <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e9e:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100ea3:	0f 85 76 ff ff ff    	jne    f0100e1f <check_page_free_list+0x25b>
f0100ea9:	e9 53 ff ff ff       	jmp    f0100e01 <check_page_free_list+0x23d>
f0100eae:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100eb3:	0f 85 61 ff ff ff    	jne    f0100e1a <check_page_free_list+0x256>
f0100eb9:	e9 43 ff ff ff       	jmp    f0100e01 <check_page_free_list+0x23d>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100ebe:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ec1:	5b                   	pop    %ebx
f0100ec2:	5e                   	pop    %esi
f0100ec3:	5f                   	pop    %edi
f0100ec4:	5d                   	pop    %ebp
f0100ec5:	c3                   	ret    

f0100ec6 <page_init>:
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

        // 1) Mark page 0 as used        
        pages[0].pp_ref++;
f0100ec6:	a1 90 fe 21 f0       	mov    0xf021fe90,%eax
f0100ecb:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0100ed0:	8b 15 40 f2 21 f0    	mov    0xf021f240,%edx
f0100ed6:	b8 08 00 00 00       	mov    $0x8,%eax
        // 2) All base pages except 0 are free
        size_t i;
        size_t mpentry_page = MPENTRY_PADDR / PGSIZE; 

        for (i = 1; i < mpentry_page; i++) {
                pages[i].pp_link = page_free_list;
f0100edb:	8b 0d 90 fe 21 f0    	mov    0xf021fe90,%ecx
f0100ee1:	89 14 01             	mov    %edx,(%ecx,%eax,1)
                page_free_list = &pages[i];
f0100ee4:	8b 0d 90 fe 21 f0    	mov    0xf021fe90,%ecx
f0100eea:	8d 14 01             	lea    (%ecx,%eax,1),%edx
f0100eed:	83 c0 08             	add    $0x8,%eax
       
        // 2) All base pages except 0 are free
        size_t i;
        size_t mpentry_page = MPENTRY_PADDR / PGSIZE; 

        for (i = 1; i < mpentry_page; i++) {
f0100ef0:	83 f8 38             	cmp    $0x38,%eax
f0100ef3:	75 e6                	jne    f0100edb <page_init+0x15>
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100ef5:	55                   	push   %ebp
f0100ef6:	89 e5                	mov    %esp,%ebp
f0100ef8:	56                   	push   %esi
f0100ef9:	53                   	push   %ebx
f0100efa:	89 15 40 f2 21 f0    	mov    %edx,0xf021f240
        for (i = 1; i < mpentry_page; i++) {
                pages[i].pp_link = page_free_list;
                page_free_list = &pages[i];
        }

        pages[mpentry_page].pp_ref++;
f0100f00:	66 83 41 3c 01       	addw   $0x1,0x3c(%ecx)

        for (i = mpentry_page + 1; i < npages_basemem; i++) {
f0100f05:	8b 1d 44 f2 21 f0    	mov    0xf021f244,%ebx
f0100f0b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100f10:	b8 08 00 00 00       	mov    $0x8,%eax
f0100f15:	eb 20                	jmp    f0100f37 <page_init+0x71>
f0100f17:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
                pages[i].pp_link = page_free_list;
f0100f1e:	8b 35 90 fe 21 f0    	mov    0xf021fe90,%esi
f0100f24:	89 14 c6             	mov    %edx,(%esi,%eax,8)
                page_free_list = &pages[i];
        }

        pages[mpentry_page].pp_ref++;

        for (i = mpentry_page + 1; i < npages_basemem; i++) {
f0100f27:	83 c0 01             	add    $0x1,%eax
                pages[i].pp_link = page_free_list;
                page_free_list = &pages[i];
f0100f2a:	89 ca                	mov    %ecx,%edx
f0100f2c:	03 15 90 fe 21 f0    	add    0xf021fe90,%edx
f0100f32:	b9 01 00 00 00       	mov    $0x1,%ecx
                page_free_list = &pages[i];
        }

        pages[mpentry_page].pp_ref++;

        for (i = mpentry_page + 1; i < npages_basemem; i++) {
f0100f37:	39 d8                	cmp    %ebx,%eax
f0100f39:	72 dc                	jb     f0100f17 <page_init+0x51>
f0100f3b:	84 c9                	test   %cl,%cl
f0100f3d:	74 06                	je     f0100f45 <page_init+0x7f>
f0100f3f:	89 15 40 f2 21 f0    	mov    %edx,0xf021f240
                page_free_list = &pages[i];
        }

        // 4) We find the next free memory (boot_alloc() outputs a rounded-up virtual address),
        // convert it to a physical address and get the index of free pages by dividing by PGSIZE  
        for (i = PADDR(boot_alloc(0)) / PGSIZE; i < npages; i++) {
f0100f45:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f4a:	e8 db fb ff ff       	call   f0100b2a <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100f4f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f54:	77 15                	ja     f0100f6b <page_init+0xa5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f56:	50                   	push   %eax
f0100f57:	68 a8 6c 10 f0       	push   $0xf0106ca8
f0100f5c:	68 60 01 00 00       	push   $0x160
f0100f61:	68 51 7b 10 f0       	push   $0xf0107b51
f0100f66:	e8 d5 f0 ff ff       	call   f0100040 <_panic>
f0100f6b:	05 00 00 00 10       	add    $0x10000000,%eax
f0100f70:	c1 e8 0c             	shr    $0xc,%eax
f0100f73:	8b 0d 40 f2 21 f0    	mov    0xf021f240,%ecx
f0100f79:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100f80:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100f85:	eb 1c                	jmp    f0100fa3 <page_init+0xdd>
                pages[i].pp_link = page_free_list;
f0100f87:	8b 35 90 fe 21 f0    	mov    0xf021fe90,%esi
f0100f8d:	89 0c 16             	mov    %ecx,(%esi,%edx,1)
                page_free_list = &pages[i];
f0100f90:	89 d1                	mov    %edx,%ecx
f0100f92:	03 0d 90 fe 21 f0    	add    0xf021fe90,%ecx
                page_free_list = &pages[i];
        }

        // 4) We find the next free memory (boot_alloc() outputs a rounded-up virtual address),
        // convert it to a physical address and get the index of free pages by dividing by PGSIZE  
        for (i = PADDR(boot_alloc(0)) / PGSIZE; i < npages; i++) {
f0100f98:	83 c0 01             	add    $0x1,%eax
f0100f9b:	83 c2 08             	add    $0x8,%edx
f0100f9e:	bb 01 00 00 00       	mov    $0x1,%ebx
f0100fa3:	3b 05 88 fe 21 f0    	cmp    0xf021fe88,%eax
f0100fa9:	72 dc                	jb     f0100f87 <page_init+0xc1>
f0100fab:	84 db                	test   %bl,%bl
f0100fad:	74 06                	je     f0100fb5 <page_init+0xef>
f0100faf:	89 0d 40 f2 21 f0    	mov    %ecx,0xf021f240
                pages[i].pp_link = page_free_list;
                page_free_list = &pages[i];
        }
}
f0100fb5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100fb8:	5b                   	pop    %ebx
f0100fb9:	5e                   	pop    %esi
f0100fba:	5d                   	pop    %ebp
f0100fbb:	c3                   	ret    

f0100fbc <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100fbc:	55                   	push   %ebp
f0100fbd:	89 e5                	mov    %esp,%ebp
f0100fbf:	53                   	push   %ebx
f0100fc0:	83 ec 04             	sub    $0x4,%esp
        if (page_free_list == NULL)
f0100fc3:	8b 1d 40 f2 21 f0    	mov    0xf021f240,%ebx
f0100fc9:	85 db                	test   %ebx,%ebx
f0100fcb:	74 58                	je     f0101025 <page_alloc+0x69>
                return NULL;

        struct PageInfo *page = page_free_list;
        page_free_list = page->pp_link;
f0100fcd:	8b 03                	mov    (%ebx),%eax
f0100fcf:	a3 40 f2 21 f0       	mov    %eax,0xf021f240

	if (alloc_flags & ALLOC_ZERO) {
f0100fd4:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100fd8:	74 45                	je     f010101f <page_alloc+0x63>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fda:	89 d8                	mov    %ebx,%eax
f0100fdc:	2b 05 90 fe 21 f0    	sub    0xf021fe90,%eax
f0100fe2:	c1 f8 03             	sar    $0x3,%eax
f0100fe5:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fe8:	89 c2                	mov    %eax,%edx
f0100fea:	c1 ea 0c             	shr    $0xc,%edx
f0100fed:	3b 15 88 fe 21 f0    	cmp    0xf021fe88,%edx
f0100ff3:	72 12                	jb     f0101007 <page_alloc+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ff5:	50                   	push   %eax
f0100ff6:	68 84 6c 10 f0       	push   $0xf0106c84
f0100ffb:	6a 58                	push   $0x58
f0100ffd:	68 7a 7b 10 f0       	push   $0xf0107b7a
f0101002:	e8 39 f0 ff ff       	call   f0100040 <_panic>
                char *p = page2kva(page);
                memset(p, 0, PGSIZE);
f0101007:	83 ec 04             	sub    $0x4,%esp
f010100a:	68 00 10 00 00       	push   $0x1000
f010100f:	6a 00                	push   $0x0
f0101011:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101016:	50                   	push   %eax
f0101017:	e8 8b 4f 00 00       	call   f0105fa7 <memset>
f010101c:	83 c4 10             	add    $0x10,%esp
        }

        page->pp_link = NULL;
f010101f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return page;
}
f0101025:	89 d8                	mov    %ebx,%eax
f0101027:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010102a:	c9                   	leave  
f010102b:	c3                   	ret    

f010102c <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f010102c:	55                   	push   %ebp
f010102d:	89 e5                	mov    %esp,%ebp
f010102f:	83 ec 08             	sub    $0x8,%esp
f0101032:	8b 45 08             	mov    0x8(%ebp),%eax
        assert(pp);
f0101035:	85 c0                	test   %eax,%eax
f0101037:	75 19                	jne    f0101052 <page_free+0x26>
f0101039:	68 7b 7d 10 f0       	push   $0xf0107d7b
f010103e:	68 94 7b 10 f0       	push   $0xf0107b94
f0101043:	68 8b 01 00 00       	push   $0x18b
f0101048:	68 51 7b 10 f0       	push   $0xf0107b51
f010104d:	e8 ee ef ff ff       	call   f0100040 <_panic>

        // Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
        if (pp->pp_ref != 0) 
f0101052:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101057:	74 17                	je     f0101070 <page_free+0x44>
                panic("pp->pp_ref is nonzero\n");
f0101059:	83 ec 04             	sub    $0x4,%esp
f010105c:	68 41 7c 10 f0       	push   $0xf0107c41
f0101061:	68 91 01 00 00       	push   $0x191
f0101066:	68 51 7b 10 f0       	push   $0xf0107b51
f010106b:	e8 d0 ef ff ff       	call   f0100040 <_panic>

        if (pp->pp_link != NULL)
f0101070:	83 38 00             	cmpl   $0x0,(%eax)
f0101073:	74 17                	je     f010108c <page_free+0x60>
                panic("pp->pp_link is not NULL\n");
f0101075:	83 ec 04             	sub    $0x4,%esp
f0101078:	68 58 7c 10 f0       	push   $0xf0107c58
f010107d:	68 94 01 00 00       	push   $0x194
f0101082:	68 51 7b 10 f0       	push   $0xf0107b51
f0101087:	e8 b4 ef ff ff       	call   f0100040 <_panic>

        pp->pp_link = page_free_list;
f010108c:	8b 15 40 f2 21 f0    	mov    0xf021f240,%edx
f0101092:	89 10                	mov    %edx,(%eax)
        page_free_list = pp;
f0101094:	a3 40 f2 21 f0       	mov    %eax,0xf021f240
}
f0101099:	c9                   	leave  
f010109a:	c3                   	ret    

f010109b <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f010109b:	55                   	push   %ebp
f010109c:	89 e5                	mov    %esp,%ebp
f010109e:	83 ec 08             	sub    $0x8,%esp
f01010a1:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f01010a4:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f01010a8:	83 e8 01             	sub    $0x1,%eax
f01010ab:	66 89 42 04          	mov    %ax,0x4(%edx)
f01010af:	66 85 c0             	test   %ax,%ax
f01010b2:	75 0c                	jne    f01010c0 <page_decref+0x25>
		page_free(pp);
f01010b4:	83 ec 0c             	sub    $0xc,%esp
f01010b7:	52                   	push   %edx
f01010b8:	e8 6f ff ff ff       	call   f010102c <page_free>
f01010bd:	83 c4 10             	add    $0x10,%esp
}
f01010c0:	c9                   	leave  
f01010c1:	c3                   	ret    

f01010c2 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01010c2:	55                   	push   %ebp
f01010c3:	89 e5                	mov    %esp,%ebp
f01010c5:	56                   	push   %esi
f01010c6:	53                   	push   %ebx
f01010c7:	8b 45 08             	mov    0x8(%ebp),%eax
f01010ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        assert(pgdir);
f01010cd:	85 c0                	test   %eax,%eax
f01010cf:	75 19                	jne    f01010ea <pgdir_walk+0x28>
f01010d1:	68 71 7c 10 f0       	push   $0xf0107c71
f01010d6:	68 94 7b 10 f0       	push   $0xf0107b94
f01010db:	68 be 01 00 00       	push   $0x1be
f01010e0:	68 51 7b 10 f0       	push   $0xf0107b51
f01010e5:	e8 56 ef ff ff       	call   f0100040 <_panic>

        size_t pdx = PDX(va);
        pde_t pd_entry = pgdir[pdx]; 
f01010ea:	89 da                	mov    %ebx,%edx
f01010ec:	c1 ea 16             	shr    $0x16,%edx
f01010ef:	8d 34 90             	lea    (%eax,%edx,4),%esi
f01010f2:	8b 16                	mov    (%esi),%edx
       
        pte_t *pt = NULL; 
        if ((pd_entry & PTE_P) == PTE_P) {
f01010f4:	f6 c2 01             	test   $0x1,%dl
f01010f7:	74 30                	je     f0101129 <pgdir_walk+0x67>
                pt = (pte_t *) KADDR(PTE_ADDR(pd_entry));
f01010f9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010ff:	89 d0                	mov    %edx,%eax
f0101101:	c1 e8 0c             	shr    $0xc,%eax
f0101104:	39 05 88 fe 21 f0    	cmp    %eax,0xf021fe88
f010110a:	77 15                	ja     f0101121 <pgdir_walk+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010110c:	52                   	push   %edx
f010110d:	68 84 6c 10 f0       	push   $0xf0106c84
f0101112:	68 c5 01 00 00       	push   $0x1c5
f0101117:	68 51 7b 10 f0       	push   $0xf0107b51
f010111c:	e8 1f ef ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101121:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101127:	eb 60                	jmp    f0101189 <pgdir_walk+0xc7>
        } else {
                if (create == 0)
f0101129:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010112d:	74 68                	je     f0101197 <pgdir_walk+0xd5>
                        return NULL;

                struct PageInfo *pt_page = page_alloc(ALLOC_ZERO);
f010112f:	83 ec 0c             	sub    $0xc,%esp
f0101132:	6a 01                	push   $0x1
f0101134:	e8 83 fe ff ff       	call   f0100fbc <page_alloc>
                if (pt_page == NULL)
f0101139:	83 c4 10             	add    $0x10,%esp
f010113c:	85 c0                	test   %eax,%eax
f010113e:	74 5e                	je     f010119e <pgdir_walk+0xdc>
                        return NULL;

                pgdir[pdx] = page2pa(pt_page) | PTE_U | PTE_W | PTE_P;
f0101140:	89 c2                	mov    %eax,%edx
f0101142:	2b 15 90 fe 21 f0    	sub    0xf021fe90,%edx
f0101148:	c1 fa 03             	sar    $0x3,%edx
f010114b:	c1 e2 0c             	shl    $0xc,%edx
f010114e:	83 ca 07             	or     $0x7,%edx
f0101151:	89 16                	mov    %edx,(%esi)

                pt_page->pp_ref++;
f0101153:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101158:	2b 05 90 fe 21 f0    	sub    0xf021fe90,%eax
f010115e:	c1 f8 03             	sar    $0x3,%eax
f0101161:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101164:	89 c2                	mov    %eax,%edx
f0101166:	c1 ea 0c             	shr    $0xc,%edx
f0101169:	3b 15 88 fe 21 f0    	cmp    0xf021fe88,%edx
f010116f:	72 12                	jb     f0101183 <pgdir_walk+0xc1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101171:	50                   	push   %eax
f0101172:	68 84 6c 10 f0       	push   $0xf0106c84
f0101177:	6a 58                	push   $0x58
f0101179:	68 7a 7b 10 f0       	push   $0xf0107b7a
f010117e:	e8 bd ee ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101183:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
                pt = (pte_t *) page2kva(pt_page);
        }

        return &pt[PTX(va)];
f0101189:	c1 eb 0a             	shr    $0xa,%ebx
f010118c:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0101192:	8d 04 1a             	lea    (%edx,%ebx,1),%eax
f0101195:	eb 0c                	jmp    f01011a3 <pgdir_walk+0xe1>
        pte_t *pt = NULL; 
        if ((pd_entry & PTE_P) == PTE_P) {
                pt = (pte_t *) KADDR(PTE_ADDR(pd_entry));
        } else {
                if (create == 0)
                        return NULL;
f0101197:	b8 00 00 00 00       	mov    $0x0,%eax
f010119c:	eb 05                	jmp    f01011a3 <pgdir_walk+0xe1>

                struct PageInfo *pt_page = page_alloc(ALLOC_ZERO);
                if (pt_page == NULL)
                        return NULL;
f010119e:	b8 00 00 00 00       	mov    $0x0,%eax
                pt_page->pp_ref++;
                pt = (pte_t *) page2kva(pt_page);
        }

        return &pt[PTX(va)];
}
f01011a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01011a6:	5b                   	pop    %ebx
f01011a7:	5e                   	pop    %esi
f01011a8:	5d                   	pop    %ebp
f01011a9:	c3                   	ret    

f01011aa <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01011aa:	55                   	push   %ebp
f01011ab:	89 e5                	mov    %esp,%ebp
f01011ad:	57                   	push   %edi
f01011ae:	56                   	push   %esi
f01011af:	53                   	push   %ebx
f01011b0:	83 ec 1c             	sub    $0x1c,%esp
f01011b3:	89 c7                	mov    %eax,%edi
f01011b5:	8b 45 08             	mov    0x8(%ebp),%eax
        assert(pgdir);
f01011b8:	85 ff                	test   %edi,%edi
f01011ba:	74 1d                	je     f01011d9 <boot_map_region+0x2f>

        uintptr_t map_va = va;
        physaddr_t map_pa = pa;

        size_t i;
        for (i = 0; i < size / PGSIZE; i++) {
f01011bc:	c1 e9 0c             	shr    $0xc,%ecx
f01011bf:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f01011c2:	89 c3                	mov    %eax,%ebx
f01011c4:	be 00 00 00 00       	mov    $0x0,%esi
                pte_t *pte = pgdir_walk(pgdir, (void *) map_va, 1);
f01011c9:	29 c2                	sub    %eax,%edx
f01011cb:	89 55 e0             	mov    %edx,-0x20(%ebp)
                assert(pte);

                *pte = map_pa | perm | PTE_P;
f01011ce:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011d1:	83 c8 01             	or     $0x1,%eax
f01011d4:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01011d7:	eb 5a                	jmp    f0101233 <boot_map_region+0x89>
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
        assert(pgdir);
f01011d9:	68 71 7c 10 f0       	push   $0xf0107c71
f01011de:	68 94 7b 10 f0       	push   $0xf0107b94
f01011e3:	68 e5 01 00 00       	push   $0x1e5
f01011e8:	68 51 7b 10 f0       	push   $0xf0107b51
f01011ed:	e8 4e ee ff ff       	call   f0100040 <_panic>
        uintptr_t map_va = va;
        physaddr_t map_pa = pa;

        size_t i;
        for (i = 0; i < size / PGSIZE; i++) {
                pte_t *pte = pgdir_walk(pgdir, (void *) map_va, 1);
f01011f2:	83 ec 04             	sub    $0x4,%esp
f01011f5:	6a 01                	push   $0x1
f01011f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01011fa:	01 d8                	add    %ebx,%eax
f01011fc:	50                   	push   %eax
f01011fd:	57                   	push   %edi
f01011fe:	e8 bf fe ff ff       	call   f01010c2 <pgdir_walk>
                assert(pte);
f0101203:	83 c4 10             	add    $0x10,%esp
f0101206:	85 c0                	test   %eax,%eax
f0101208:	75 19                	jne    f0101223 <boot_map_region+0x79>
f010120a:	68 77 7c 10 f0       	push   $0xf0107c77
f010120f:	68 94 7b 10 f0       	push   $0xf0107b94
f0101214:	68 ed 01 00 00       	push   $0x1ed
f0101219:	68 51 7b 10 f0       	push   $0xf0107b51
f010121e:	e8 1d ee ff ff       	call   f0100040 <_panic>

                *pte = map_pa | perm | PTE_P;
f0101223:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101226:	09 da                	or     %ebx,%edx
f0101228:	89 10                	mov    %edx,(%eax)

                map_va += PGSIZE;
                map_pa += PGSIZE;
f010122a:	81 c3 00 10 00 00    	add    $0x1000,%ebx

        uintptr_t map_va = va;
        physaddr_t map_pa = pa;

        size_t i;
        for (i = 0; i < size / PGSIZE; i++) {
f0101230:	83 c6 01             	add    $0x1,%esi
f0101233:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0101236:	75 ba                	jne    f01011f2 <boot_map_region+0x48>
                *pte = map_pa | perm | PTE_P;

                map_va += PGSIZE;
                map_pa += PGSIZE;
        }
}
f0101238:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010123b:	5b                   	pop    %ebx
f010123c:	5e                   	pop    %esi
f010123d:	5f                   	pop    %edi
f010123e:	5d                   	pop    %ebp
f010123f:	c3                   	ret    

f0101240 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101240:	55                   	push   %ebp
f0101241:	89 e5                	mov    %esp,%ebp
f0101243:	53                   	push   %ebx
f0101244:	83 ec 04             	sub    $0x4,%esp
f0101247:	8b 45 08             	mov    0x8(%ebp),%eax
f010124a:	8b 5d 10             	mov    0x10(%ebp),%ebx
        assert(pgdir);
f010124d:	85 c0                	test   %eax,%eax
f010124f:	75 19                	jne    f010126a <page_lookup+0x2a>
f0101251:	68 71 7c 10 f0       	push   $0xf0107c71
f0101256:	68 94 7b 10 f0       	push   $0xf0107b94
f010125b:	68 3a 02 00 00       	push   $0x23a
f0101260:	68 51 7b 10 f0       	push   $0xf0107b51
f0101265:	e8 d6 ed ff ff       	call   f0100040 <_panic>

        pte_t *pte = pgdir_walk(pgdir, va, 0);
f010126a:	83 ec 04             	sub    $0x4,%esp
f010126d:	6a 00                	push   $0x0
f010126f:	ff 75 0c             	pushl  0xc(%ebp)
f0101272:	50                   	push   %eax
f0101273:	e8 4a fe ff ff       	call   f01010c2 <pgdir_walk>
        // No page mapped at va
        if (pte == NULL || (*pte & PTE_P) != PTE_P)
f0101278:	83 c4 10             	add    $0x10,%esp
f010127b:	85 c0                	test   %eax,%eax
f010127d:	74 37                	je     f01012b6 <page_lookup+0x76>
f010127f:	f6 00 01             	testb  $0x1,(%eax)
f0101282:	74 39                	je     f01012bd <page_lookup+0x7d>
                return NULL;

        if (pte_store)
f0101284:	85 db                	test   %ebx,%ebx
f0101286:	74 02                	je     f010128a <page_lookup+0x4a>
                *pte_store = pte;
f0101288:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010128a:	8b 00                	mov    (%eax),%eax
f010128c:	c1 e8 0c             	shr    $0xc,%eax
f010128f:	3b 05 88 fe 21 f0    	cmp    0xf021fe88,%eax
f0101295:	72 14                	jb     f01012ab <page_lookup+0x6b>
		panic("pa2page called with invalid pa");
f0101297:	83 ec 04             	sub    $0x4,%esp
f010129a:	68 f0 72 10 f0       	push   $0xf01072f0
f010129f:	6a 51                	push   $0x51
f01012a1:	68 7a 7b 10 f0       	push   $0xf0107b7a
f01012a6:	e8 95 ed ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01012ab:	8b 15 90 fe 21 f0    	mov    0xf021fe90,%edx
f01012b1:	8d 04 c2             	lea    (%edx,%eax,8),%eax

        return pa2page(PTE_ADDR(*pte));
f01012b4:	eb 0c                	jmp    f01012c2 <page_lookup+0x82>
        assert(pgdir);

        pte_t *pte = pgdir_walk(pgdir, va, 0);
        // No page mapped at va
        if (pte == NULL || (*pte & PTE_P) != PTE_P)
                return NULL;
f01012b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01012bb:	eb 05                	jmp    f01012c2 <page_lookup+0x82>
f01012bd:	b8 00 00 00 00       	mov    $0x0,%eax

        if (pte_store)
                *pte_store = pte;

        return pa2page(PTE_ADDR(*pte));
}
f01012c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01012c5:	c9                   	leave  
f01012c6:	c3                   	ret    

f01012c7 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01012c7:	55                   	push   %ebp
f01012c8:	89 e5                	mov    %esp,%ebp
f01012ca:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01012cd:	e8 f8 52 00 00       	call   f01065ca <cpunum>
f01012d2:	6b c0 74             	imul   $0x74,%eax,%eax
f01012d5:	83 b8 28 00 22 f0 00 	cmpl   $0x0,-0xfddffd8(%eax)
f01012dc:	74 19                	je     f01012f7 <tlb_invalidate+0x30>
f01012de:	e8 e7 52 00 00       	call   f01065ca <cpunum>
f01012e3:	6b c0 74             	imul   $0x74,%eax,%eax
f01012e6:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f01012ec:	8b 55 08             	mov    0x8(%ebp),%edx
f01012ef:	39 90 bc 00 00 00    	cmp    %edx,0xbc(%eax)
f01012f5:	75 06                	jne    f01012fd <tlb_invalidate+0x36>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01012f7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012fa:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01012fd:	c9                   	leave  
f01012fe:	c3                   	ret    

f01012ff <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01012ff:	55                   	push   %ebp
f0101300:	89 e5                	mov    %esp,%ebp
f0101302:	56                   	push   %esi
f0101303:	53                   	push   %ebx
f0101304:	83 ec 10             	sub    $0x10,%esp
f0101307:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010130a:	8b 75 0c             	mov    0xc(%ebp),%esi
        assert(pgdir);
f010130d:	85 db                	test   %ebx,%ebx
f010130f:	75 19                	jne    f010132a <page_remove+0x2b>
f0101311:	68 71 7c 10 f0       	push   $0xf0107c71
f0101316:	68 94 7b 10 f0       	push   $0xf0107b94
f010131b:	68 59 02 00 00       	push   $0x259
f0101320:	68 51 7b 10 f0       	push   $0xf0107b51
f0101325:	e8 16 ed ff ff       	call   f0100040 <_panic>

        pte_t *pte;
        struct PageInfo *page = page_lookup(pgdir, va, &pte);
f010132a:	83 ec 04             	sub    $0x4,%esp
f010132d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101330:	50                   	push   %eax
f0101331:	56                   	push   %esi
f0101332:	53                   	push   %ebx
f0101333:	e8 08 ff ff ff       	call   f0101240 <page_lookup>
        // Silently do nothing
        if (page == NULL || (*pte & PTE_P) != PTE_P)
f0101338:	83 c4 10             	add    $0x10,%esp
f010133b:	85 c0                	test   %eax,%eax
f010133d:	74 27                	je     f0101366 <page_remove+0x67>
f010133f:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101342:	f6 02 01             	testb  $0x1,(%edx)
f0101345:	74 1f                	je     f0101366 <page_remove+0x67>
                return;

        page_decref(page);
f0101347:	83 ec 0c             	sub    $0xc,%esp
f010134a:	50                   	push   %eax
f010134b:	e8 4b fd ff ff       	call   f010109b <page_decref>

        // Zero the table entry
        *pte = 0;
f0101350:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101353:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

        tlb_invalidate(pgdir, va);
f0101359:	83 c4 08             	add    $0x8,%esp
f010135c:	56                   	push   %esi
f010135d:	53                   	push   %ebx
f010135e:	e8 64 ff ff ff       	call   f01012c7 <tlb_invalidate>
f0101363:	83 c4 10             	add    $0x10,%esp
}
f0101366:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101369:	5b                   	pop    %ebx
f010136a:	5e                   	pop    %esi
f010136b:	5d                   	pop    %ebp
f010136c:	c3                   	ret    

f010136d <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010136d:	55                   	push   %ebp
f010136e:	89 e5                	mov    %esp,%ebp
f0101370:	57                   	push   %edi
f0101371:	56                   	push   %esi
f0101372:	53                   	push   %ebx
f0101373:	83 ec 0c             	sub    $0xc,%esp
f0101376:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101379:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        assert(pgdir);
f010137c:	85 ff                	test   %edi,%edi
f010137e:	75 19                	jne    f0101399 <page_insert+0x2c>
f0101380:	68 71 7c 10 f0       	push   $0xf0107c71
f0101385:	68 94 7b 10 f0       	push   $0xf0107b94
f010138a:	68 12 02 00 00       	push   $0x212
f010138f:	68 51 7b 10 f0       	push   $0xf0107b51
f0101394:	e8 a7 ec ff ff       	call   f0100040 <_panic>
        assert(pp);
f0101399:	85 db                	test   %ebx,%ebx
f010139b:	75 19                	jne    f01013b6 <page_insert+0x49>
f010139d:	68 7b 7d 10 f0       	push   $0xf0107d7b
f01013a2:	68 94 7b 10 f0       	push   $0xf0107b94
f01013a7:	68 13 02 00 00       	push   $0x213
f01013ac:	68 51 7b 10 f0       	push   $0xf0107b51
f01013b1:	e8 8a ec ff ff       	call   f0100040 <_panic>

        // Return -E_NO_MEM when it fails
        pte_t *pte = pgdir_walk(pgdir, va, 1);
f01013b6:	83 ec 04             	sub    $0x4,%esp
f01013b9:	6a 01                	push   $0x1
f01013bb:	ff 75 10             	pushl  0x10(%ebp)
f01013be:	57                   	push   %edi
f01013bf:	e8 fe fc ff ff       	call   f01010c2 <pgdir_walk>
f01013c4:	89 c6                	mov    %eax,%esi
        if (pte == NULL)
f01013c6:	83 c4 10             	add    $0x10,%esp
f01013c9:	85 c0                	test   %eax,%eax
f01013cb:	74 5a                	je     f0101427 <page_insert+0xba>
                return -E_NO_MEM;

        if ((*pte & PTE_P) == PTE_P) {
f01013cd:	8b 00                	mov    (%eax),%eax
f01013cf:	a8 01                	test   $0x1,%al
f01013d1:	74 32                	je     f0101405 <page_insert+0x98>
                // We don't increment ref because it's the same page
                // but we just change its permissions (this is in tests)
                if (PTE_ADDR(*pte) == page2pa(pp))
f01013d3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01013d8:	89 da                	mov    %ebx,%edx
f01013da:	2b 15 90 fe 21 f0    	sub    0xf021fe90,%edx
f01013e0:	c1 fa 03             	sar    $0x3,%edx
f01013e3:	c1 e2 0c             	shl    $0xc,%edx
f01013e6:	39 d0                	cmp    %edx,%eax
f01013e8:	74 20                	je     f010140a <page_insert+0x9d>
                        goto page_insert_success;

                page_remove(pgdir, va);
f01013ea:	83 ec 08             	sub    $0x8,%esp
f01013ed:	ff 75 10             	pushl  0x10(%ebp)
f01013f0:	57                   	push   %edi
f01013f1:	e8 09 ff ff ff       	call   f01012ff <page_remove>
                // If the page was formerly at va, we invalidate the TLB
                tlb_invalidate(pgdir, va);
f01013f6:	83 c4 08             	add    $0x8,%esp
f01013f9:	ff 75 10             	pushl  0x10(%ebp)
f01013fc:	57                   	push   %edi
f01013fd:	e8 c5 fe ff ff       	call   f01012c7 <tlb_invalidate>
f0101402:	83 c4 10             	add    $0x10,%esp
        }

        pp->pp_ref++;
f0101405:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)

page_insert_success:
        *pte = page2pa(pp) | perm | PTE_P;
f010140a:	2b 1d 90 fe 21 f0    	sub    0xf021fe90,%ebx
f0101410:	c1 fb 03             	sar    $0x3,%ebx
f0101413:	c1 e3 0c             	shl    $0xc,%ebx
f0101416:	8b 45 14             	mov    0x14(%ebp),%eax
f0101419:	83 c8 01             	or     $0x1,%eax
f010141c:	09 c3                	or     %eax,%ebx
f010141e:	89 1e                	mov    %ebx,(%esi)
        return 0; 
f0101420:	b8 00 00 00 00       	mov    $0x0,%eax
f0101425:	eb 05                	jmp    f010142c <page_insert+0xbf>
        assert(pp);

        // Return -E_NO_MEM when it fails
        pte_t *pte = pgdir_walk(pgdir, va, 1);
        if (pte == NULL)
                return -E_NO_MEM;
f0101427:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
        pp->pp_ref++;

page_insert_success:
        *pte = page2pa(pp) | perm | PTE_P;
        return 0; 
}
f010142c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010142f:	5b                   	pop    %ebx
f0101430:	5e                   	pop    %esi
f0101431:	5f                   	pop    %edi
f0101432:	5d                   	pop    %ebp
f0101433:	c3                   	ret    

f0101434 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101434:	55                   	push   %ebp
f0101435:	89 e5                	mov    %esp,%ebp
f0101437:	56                   	push   %esi
f0101438:	53                   	push   %ebx
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
        size_t sz = ROUNDUP(size, PGSIZE); 
f0101439:	8b 45 0c             	mov    0xc(%ebp),%eax
f010143c:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101442:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        uintptr_t result = base;
f0101448:	8b 35 00 23 12 f0    	mov    0xf0122300,%esi

        if (base + sz > MMIOLIM)
f010144e:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f0101451:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f0101456:	76 17                	jbe    f010146f <mmio_map_region+0x3b>
                panic("mmio_map_region: base + sz > MMIOLIM");
f0101458:	83 ec 04             	sub    $0x4,%esp
f010145b:	68 10 73 10 f0       	push   $0xf0107310
f0101460:	68 99 02 00 00       	push   $0x299
f0101465:	68 51 7b 10 f0       	push   $0xf0107b51
f010146a:	e8 d1 eb ff ff       	call   f0100040 <_panic>

        boot_map_region(kern_pgdir, base, sz, pa, PTE_W | PTE_PCD | PTE_PWT);      
f010146f:	83 ec 08             	sub    $0x8,%esp
f0101472:	6a 1a                	push   $0x1a
f0101474:	ff 75 08             	pushl  0x8(%ebp)
f0101477:	89 d9                	mov    %ebx,%ecx
f0101479:	89 f2                	mov    %esi,%edx
f010147b:	a1 8c fe 21 f0       	mov    0xf021fe8c,%eax
f0101480:	e8 25 fd ff ff       	call   f01011aa <boot_map_region>
        base += sz;
f0101485:	01 1d 00 23 12 f0    	add    %ebx,0xf0122300
        
        return (void *) result;
}
f010148b:	89 f0                	mov    %esi,%eax
f010148d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101490:	5b                   	pop    %ebx
f0101491:	5e                   	pop    %esi
f0101492:	5d                   	pop    %ebp
f0101493:	c3                   	ret    

f0101494 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101494:	55                   	push   %ebp
f0101495:	89 e5                	mov    %esp,%ebp
f0101497:	57                   	push   %edi
f0101498:	56                   	push   %esi
f0101499:	53                   	push   %ebx
f010149a:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f010149d:	b8 15 00 00 00       	mov    $0x15,%eax
f01014a2:	e8 f6 f5 ff ff       	call   f0100a9d <nvram_read>
f01014a7:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01014a9:	b8 17 00 00 00       	mov    $0x17,%eax
f01014ae:	e8 ea f5 ff ff       	call   f0100a9d <nvram_read>
f01014b3:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01014b5:	b8 34 00 00 00       	mov    $0x34,%eax
f01014ba:	e8 de f5 ff ff       	call   f0100a9d <nvram_read>
f01014bf:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f01014c2:	85 c0                	test   %eax,%eax
f01014c4:	74 07                	je     f01014cd <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f01014c6:	05 00 40 00 00       	add    $0x4000,%eax
f01014cb:	eb 0b                	jmp    f01014d8 <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f01014cd:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01014d3:	85 f6                	test   %esi,%esi
f01014d5:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f01014d8:	89 c2                	mov    %eax,%edx
f01014da:	c1 ea 02             	shr    $0x2,%edx
f01014dd:	89 15 88 fe 21 f0    	mov    %edx,0xf021fe88
	npages_basemem = basemem / (PGSIZE / 1024);
f01014e3:	89 da                	mov    %ebx,%edx
f01014e5:	c1 ea 02             	shr    $0x2,%edx
f01014e8:	89 15 44 f2 21 f0    	mov    %edx,0xf021f244

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01014ee:	89 c2                	mov    %eax,%edx
f01014f0:	29 da                	sub    %ebx,%edx
f01014f2:	52                   	push   %edx
f01014f3:	53                   	push   %ebx
f01014f4:	50                   	push   %eax
f01014f5:	68 38 73 10 f0       	push   $0xf0107338
f01014fa:	e8 e1 28 00 00       	call   f0103de0 <cprintf>
	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01014ff:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101504:	e8 21 f6 ff ff       	call   f0100b2a <boot_alloc>
f0101509:	a3 8c fe 21 f0       	mov    %eax,0xf021fe8c
	memset(kern_pgdir, 0, PGSIZE);
f010150e:	83 c4 0c             	add    $0xc,%esp
f0101511:	68 00 10 00 00       	push   $0x1000
f0101516:	6a 00                	push   $0x0
f0101518:	50                   	push   %eax
f0101519:	e8 89 4a 00 00       	call   f0105fa7 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010151e:	a1 8c fe 21 f0       	mov    0xf021fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101523:	83 c4 10             	add    $0x10,%esp
f0101526:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010152b:	77 15                	ja     f0101542 <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010152d:	50                   	push   %eax
f010152e:	68 a8 6c 10 f0       	push   $0xf0106ca8
f0101533:	68 98 00 00 00       	push   $0x98
f0101538:	68 51 7b 10 f0       	push   $0xf0107b51
f010153d:	e8 fe ea ff ff       	call   f0100040 <_panic>
f0101542:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101548:	83 ca 05             	or     $0x5,%edx
f010154b:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
        const size_t pages_size = sizeof(struct PageInfo) * npages;
f0101551:	a1 88 fe 21 f0       	mov    0xf021fe88,%eax
f0101556:	c1 e0 03             	shl    $0x3,%eax
f0101559:	89 c7                	mov    %eax,%edi
f010155b:	89 45 cc             	mov    %eax,-0x34(%ebp)
        pages = (struct PageInfo *) boot_alloc(pages_size);
f010155e:	e8 c7 f5 ff ff       	call   f0100b2a <boot_alloc>
f0101563:	a3 90 fe 21 f0       	mov    %eax,0xf021fe90
        memset(pages, 0, pages_size);
f0101568:	83 ec 04             	sub    $0x4,%esp
f010156b:	57                   	push   %edi
f010156c:	6a 00                	push   $0x0
f010156e:	50                   	push   %eax
f010156f:	e8 33 4a 00 00       	call   f0105fa7 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
        const size_t envs_size = sizeof(struct Env) * NENV;
        envs = (struct Env *) boot_alloc(envs_size);
f0101574:	b8 00 60 03 00       	mov    $0x36000,%eax
f0101579:	e8 ac f5 ff ff       	call   f0100b2a <boot_alloc>
f010157e:	a3 4c f2 21 f0       	mov    %eax,0xf021f24c
        memset(envs, 0, envs_size);
f0101583:	83 c4 0c             	add    $0xc,%esp
f0101586:	68 00 60 03 00       	push   $0x36000
f010158b:	6a 00                	push   $0x0
f010158d:	50                   	push   %eax
f010158e:	e8 14 4a 00 00       	call   f0105fa7 <memset>
	
	//Lab 7: Multithreading
	/*Alloc place for the free stack stacks stacking*/

	const size_t stack_size = sizeof(struct FreeStacks) * MAX_THREADS;
	thread_free_stacks = (struct FreeStacks*) boot_alloc(stack_size);
f0101593:	b8 f4 2f 00 00       	mov    $0x2ff4,%eax
f0101598:	e8 8d f5 ff ff       	call   f0100b2a <boot_alloc>
f010159d:	a3 48 f2 21 f0       	mov    %eax,0xf021f248
	memset(thread_free_stacks, 0, stack_size);
f01015a2:	83 c4 0c             	add    $0xc,%esp
f01015a5:	68 f4 2f 00 00       	push   $0x2ff4
f01015aa:	6a 00                	push   $0x0
f01015ac:	50                   	push   %eax
f01015ad:	e8 f5 49 00 00       	call   f0105fa7 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01015b2:	e8 0f f9 ff ff       	call   f0100ec6 <page_init>

	check_page_free_list(1);
f01015b7:	b8 01 00 00 00       	mov    $0x1,%eax
f01015bc:	e8 03 f6 ff ff       	call   f0100bc4 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01015c1:	83 c4 10             	add    $0x10,%esp
f01015c4:	83 3d 90 fe 21 f0 00 	cmpl   $0x0,0xf021fe90
f01015cb:	75 17                	jne    f01015e4 <mem_init+0x150>
		panic("'pages' is a null pointer!");
f01015cd:	83 ec 04             	sub    $0x4,%esp
f01015d0:	68 7b 7c 10 f0       	push   $0xf0107c7b
f01015d5:	68 41 03 00 00       	push   $0x341
f01015da:	68 51 7b 10 f0       	push   $0xf0107b51
f01015df:	e8 5c ea ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015e4:	a1 40 f2 21 f0       	mov    0xf021f240,%eax
f01015e9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01015ee:	eb 05                	jmp    f01015f5 <mem_init+0x161>
		++nfree;
f01015f0:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015f3:	8b 00                	mov    (%eax),%eax
f01015f5:	85 c0                	test   %eax,%eax
f01015f7:	75 f7                	jne    f01015f0 <mem_init+0x15c>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015f9:	83 ec 0c             	sub    $0xc,%esp
f01015fc:	6a 00                	push   $0x0
f01015fe:	e8 b9 f9 ff ff       	call   f0100fbc <page_alloc>
f0101603:	89 c7                	mov    %eax,%edi
f0101605:	83 c4 10             	add    $0x10,%esp
f0101608:	85 c0                	test   %eax,%eax
f010160a:	75 19                	jne    f0101625 <mem_init+0x191>
f010160c:	68 96 7c 10 f0       	push   $0xf0107c96
f0101611:	68 94 7b 10 f0       	push   $0xf0107b94
f0101616:	68 49 03 00 00       	push   $0x349
f010161b:	68 51 7b 10 f0       	push   $0xf0107b51
f0101620:	e8 1b ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101625:	83 ec 0c             	sub    $0xc,%esp
f0101628:	6a 00                	push   $0x0
f010162a:	e8 8d f9 ff ff       	call   f0100fbc <page_alloc>
f010162f:	89 c6                	mov    %eax,%esi
f0101631:	83 c4 10             	add    $0x10,%esp
f0101634:	85 c0                	test   %eax,%eax
f0101636:	75 19                	jne    f0101651 <mem_init+0x1bd>
f0101638:	68 ac 7c 10 f0       	push   $0xf0107cac
f010163d:	68 94 7b 10 f0       	push   $0xf0107b94
f0101642:	68 4a 03 00 00       	push   $0x34a
f0101647:	68 51 7b 10 f0       	push   $0xf0107b51
f010164c:	e8 ef e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101651:	83 ec 0c             	sub    $0xc,%esp
f0101654:	6a 00                	push   $0x0
f0101656:	e8 61 f9 ff ff       	call   f0100fbc <page_alloc>
f010165b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010165e:	83 c4 10             	add    $0x10,%esp
f0101661:	85 c0                	test   %eax,%eax
f0101663:	75 19                	jne    f010167e <mem_init+0x1ea>
f0101665:	68 c2 7c 10 f0       	push   $0xf0107cc2
f010166a:	68 94 7b 10 f0       	push   $0xf0107b94
f010166f:	68 4b 03 00 00       	push   $0x34b
f0101674:	68 51 7b 10 f0       	push   $0xf0107b51
f0101679:	e8 c2 e9 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010167e:	39 f7                	cmp    %esi,%edi
f0101680:	75 19                	jne    f010169b <mem_init+0x207>
f0101682:	68 d8 7c 10 f0       	push   $0xf0107cd8
f0101687:	68 94 7b 10 f0       	push   $0xf0107b94
f010168c:	68 4e 03 00 00       	push   $0x34e
f0101691:	68 51 7b 10 f0       	push   $0xf0107b51
f0101696:	e8 a5 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010169b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010169e:	39 c6                	cmp    %eax,%esi
f01016a0:	74 04                	je     f01016a6 <mem_init+0x212>
f01016a2:	39 c7                	cmp    %eax,%edi
f01016a4:	75 19                	jne    f01016bf <mem_init+0x22b>
f01016a6:	68 74 73 10 f0       	push   $0xf0107374
f01016ab:	68 94 7b 10 f0       	push   $0xf0107b94
f01016b0:	68 4f 03 00 00       	push   $0x34f
f01016b5:	68 51 7b 10 f0       	push   $0xf0107b51
f01016ba:	e8 81 e9 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016bf:	8b 0d 90 fe 21 f0    	mov    0xf021fe90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01016c5:	8b 15 88 fe 21 f0    	mov    0xf021fe88,%edx
f01016cb:	c1 e2 0c             	shl    $0xc,%edx
f01016ce:	89 f8                	mov    %edi,%eax
f01016d0:	29 c8                	sub    %ecx,%eax
f01016d2:	c1 f8 03             	sar    $0x3,%eax
f01016d5:	c1 e0 0c             	shl    $0xc,%eax
f01016d8:	39 d0                	cmp    %edx,%eax
f01016da:	72 19                	jb     f01016f5 <mem_init+0x261>
f01016dc:	68 ea 7c 10 f0       	push   $0xf0107cea
f01016e1:	68 94 7b 10 f0       	push   $0xf0107b94
f01016e6:	68 50 03 00 00       	push   $0x350
f01016eb:	68 51 7b 10 f0       	push   $0xf0107b51
f01016f0:	e8 4b e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01016f5:	89 f0                	mov    %esi,%eax
f01016f7:	29 c8                	sub    %ecx,%eax
f01016f9:	c1 f8 03             	sar    $0x3,%eax
f01016fc:	c1 e0 0c             	shl    $0xc,%eax
f01016ff:	39 c2                	cmp    %eax,%edx
f0101701:	77 19                	ja     f010171c <mem_init+0x288>
f0101703:	68 07 7d 10 f0       	push   $0xf0107d07
f0101708:	68 94 7b 10 f0       	push   $0xf0107b94
f010170d:	68 51 03 00 00       	push   $0x351
f0101712:	68 51 7b 10 f0       	push   $0xf0107b51
f0101717:	e8 24 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010171c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010171f:	29 c8                	sub    %ecx,%eax
f0101721:	c1 f8 03             	sar    $0x3,%eax
f0101724:	c1 e0 0c             	shl    $0xc,%eax
f0101727:	39 c2                	cmp    %eax,%edx
f0101729:	77 19                	ja     f0101744 <mem_init+0x2b0>
f010172b:	68 24 7d 10 f0       	push   $0xf0107d24
f0101730:	68 94 7b 10 f0       	push   $0xf0107b94
f0101735:	68 52 03 00 00       	push   $0x352
f010173a:	68 51 7b 10 f0       	push   $0xf0107b51
f010173f:	e8 fc e8 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101744:	a1 40 f2 21 f0       	mov    0xf021f240,%eax
f0101749:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010174c:	c7 05 40 f2 21 f0 00 	movl   $0x0,0xf021f240
f0101753:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101756:	83 ec 0c             	sub    $0xc,%esp
f0101759:	6a 00                	push   $0x0
f010175b:	e8 5c f8 ff ff       	call   f0100fbc <page_alloc>
f0101760:	83 c4 10             	add    $0x10,%esp
f0101763:	85 c0                	test   %eax,%eax
f0101765:	74 19                	je     f0101780 <mem_init+0x2ec>
f0101767:	68 41 7d 10 f0       	push   $0xf0107d41
f010176c:	68 94 7b 10 f0       	push   $0xf0107b94
f0101771:	68 59 03 00 00       	push   $0x359
f0101776:	68 51 7b 10 f0       	push   $0xf0107b51
f010177b:	e8 c0 e8 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101780:	83 ec 0c             	sub    $0xc,%esp
f0101783:	57                   	push   %edi
f0101784:	e8 a3 f8 ff ff       	call   f010102c <page_free>
	page_free(pp1);
f0101789:	89 34 24             	mov    %esi,(%esp)
f010178c:	e8 9b f8 ff ff       	call   f010102c <page_free>
	page_free(pp2);
f0101791:	83 c4 04             	add    $0x4,%esp
f0101794:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101797:	e8 90 f8 ff ff       	call   f010102c <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010179c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017a3:	e8 14 f8 ff ff       	call   f0100fbc <page_alloc>
f01017a8:	89 c6                	mov    %eax,%esi
f01017aa:	83 c4 10             	add    $0x10,%esp
f01017ad:	85 c0                	test   %eax,%eax
f01017af:	75 19                	jne    f01017ca <mem_init+0x336>
f01017b1:	68 96 7c 10 f0       	push   $0xf0107c96
f01017b6:	68 94 7b 10 f0       	push   $0xf0107b94
f01017bb:	68 60 03 00 00       	push   $0x360
f01017c0:	68 51 7b 10 f0       	push   $0xf0107b51
f01017c5:	e8 76 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01017ca:	83 ec 0c             	sub    $0xc,%esp
f01017cd:	6a 00                	push   $0x0
f01017cf:	e8 e8 f7 ff ff       	call   f0100fbc <page_alloc>
f01017d4:	89 c7                	mov    %eax,%edi
f01017d6:	83 c4 10             	add    $0x10,%esp
f01017d9:	85 c0                	test   %eax,%eax
f01017db:	75 19                	jne    f01017f6 <mem_init+0x362>
f01017dd:	68 ac 7c 10 f0       	push   $0xf0107cac
f01017e2:	68 94 7b 10 f0       	push   $0xf0107b94
f01017e7:	68 61 03 00 00       	push   $0x361
f01017ec:	68 51 7b 10 f0       	push   $0xf0107b51
f01017f1:	e8 4a e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01017f6:	83 ec 0c             	sub    $0xc,%esp
f01017f9:	6a 00                	push   $0x0
f01017fb:	e8 bc f7 ff ff       	call   f0100fbc <page_alloc>
f0101800:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101803:	83 c4 10             	add    $0x10,%esp
f0101806:	85 c0                	test   %eax,%eax
f0101808:	75 19                	jne    f0101823 <mem_init+0x38f>
f010180a:	68 c2 7c 10 f0       	push   $0xf0107cc2
f010180f:	68 94 7b 10 f0       	push   $0xf0107b94
f0101814:	68 62 03 00 00       	push   $0x362
f0101819:	68 51 7b 10 f0       	push   $0xf0107b51
f010181e:	e8 1d e8 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101823:	39 fe                	cmp    %edi,%esi
f0101825:	75 19                	jne    f0101840 <mem_init+0x3ac>
f0101827:	68 d8 7c 10 f0       	push   $0xf0107cd8
f010182c:	68 94 7b 10 f0       	push   $0xf0107b94
f0101831:	68 64 03 00 00       	push   $0x364
f0101836:	68 51 7b 10 f0       	push   $0xf0107b51
f010183b:	e8 00 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101840:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101843:	39 c7                	cmp    %eax,%edi
f0101845:	74 04                	je     f010184b <mem_init+0x3b7>
f0101847:	39 c6                	cmp    %eax,%esi
f0101849:	75 19                	jne    f0101864 <mem_init+0x3d0>
f010184b:	68 74 73 10 f0       	push   $0xf0107374
f0101850:	68 94 7b 10 f0       	push   $0xf0107b94
f0101855:	68 65 03 00 00       	push   $0x365
f010185a:	68 51 7b 10 f0       	push   $0xf0107b51
f010185f:	e8 dc e7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101864:	83 ec 0c             	sub    $0xc,%esp
f0101867:	6a 00                	push   $0x0
f0101869:	e8 4e f7 ff ff       	call   f0100fbc <page_alloc>
f010186e:	83 c4 10             	add    $0x10,%esp
f0101871:	85 c0                	test   %eax,%eax
f0101873:	74 19                	je     f010188e <mem_init+0x3fa>
f0101875:	68 41 7d 10 f0       	push   $0xf0107d41
f010187a:	68 94 7b 10 f0       	push   $0xf0107b94
f010187f:	68 66 03 00 00       	push   $0x366
f0101884:	68 51 7b 10 f0       	push   $0xf0107b51
f0101889:	e8 b2 e7 ff ff       	call   f0100040 <_panic>
f010188e:	89 f0                	mov    %esi,%eax
f0101890:	2b 05 90 fe 21 f0    	sub    0xf021fe90,%eax
f0101896:	c1 f8 03             	sar    $0x3,%eax
f0101899:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010189c:	89 c2                	mov    %eax,%edx
f010189e:	c1 ea 0c             	shr    $0xc,%edx
f01018a1:	3b 15 88 fe 21 f0    	cmp    0xf021fe88,%edx
f01018a7:	72 12                	jb     f01018bb <mem_init+0x427>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018a9:	50                   	push   %eax
f01018aa:	68 84 6c 10 f0       	push   $0xf0106c84
f01018af:	6a 58                	push   $0x58
f01018b1:	68 7a 7b 10 f0       	push   $0xf0107b7a
f01018b6:	e8 85 e7 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01018bb:	83 ec 04             	sub    $0x4,%esp
f01018be:	68 00 10 00 00       	push   $0x1000
f01018c3:	6a 01                	push   $0x1
f01018c5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01018ca:	50                   	push   %eax
f01018cb:	e8 d7 46 00 00       	call   f0105fa7 <memset>
	page_free(pp0);
f01018d0:	89 34 24             	mov    %esi,(%esp)
f01018d3:	e8 54 f7 ff ff       	call   f010102c <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01018d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01018df:	e8 d8 f6 ff ff       	call   f0100fbc <page_alloc>
f01018e4:	83 c4 10             	add    $0x10,%esp
f01018e7:	85 c0                	test   %eax,%eax
f01018e9:	75 19                	jne    f0101904 <mem_init+0x470>
f01018eb:	68 50 7d 10 f0       	push   $0xf0107d50
f01018f0:	68 94 7b 10 f0       	push   $0xf0107b94
f01018f5:	68 6b 03 00 00       	push   $0x36b
f01018fa:	68 51 7b 10 f0       	push   $0xf0107b51
f01018ff:	e8 3c e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101904:	39 c6                	cmp    %eax,%esi
f0101906:	74 19                	je     f0101921 <mem_init+0x48d>
f0101908:	68 6e 7d 10 f0       	push   $0xf0107d6e
f010190d:	68 94 7b 10 f0       	push   $0xf0107b94
f0101912:	68 6c 03 00 00       	push   $0x36c
f0101917:	68 51 7b 10 f0       	push   $0xf0107b51
f010191c:	e8 1f e7 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101921:	89 f0                	mov    %esi,%eax
f0101923:	2b 05 90 fe 21 f0    	sub    0xf021fe90,%eax
f0101929:	c1 f8 03             	sar    $0x3,%eax
f010192c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010192f:	89 c2                	mov    %eax,%edx
f0101931:	c1 ea 0c             	shr    $0xc,%edx
f0101934:	3b 15 88 fe 21 f0    	cmp    0xf021fe88,%edx
f010193a:	72 12                	jb     f010194e <mem_init+0x4ba>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010193c:	50                   	push   %eax
f010193d:	68 84 6c 10 f0       	push   $0xf0106c84
f0101942:	6a 58                	push   $0x58
f0101944:	68 7a 7b 10 f0       	push   $0xf0107b7a
f0101949:	e8 f2 e6 ff ff       	call   f0100040 <_panic>
f010194e:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101954:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010195a:	80 38 00             	cmpb   $0x0,(%eax)
f010195d:	74 19                	je     f0101978 <mem_init+0x4e4>
f010195f:	68 7e 7d 10 f0       	push   $0xf0107d7e
f0101964:	68 94 7b 10 f0       	push   $0xf0107b94
f0101969:	68 6f 03 00 00       	push   $0x36f
f010196e:	68 51 7b 10 f0       	push   $0xf0107b51
f0101973:	e8 c8 e6 ff ff       	call   f0100040 <_panic>
f0101978:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f010197b:	39 d0                	cmp    %edx,%eax
f010197d:	75 db                	jne    f010195a <mem_init+0x4c6>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f010197f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101982:	a3 40 f2 21 f0       	mov    %eax,0xf021f240

	// free the pages we took
	page_free(pp0);
f0101987:	83 ec 0c             	sub    $0xc,%esp
f010198a:	56                   	push   %esi
f010198b:	e8 9c f6 ff ff       	call   f010102c <page_free>
	page_free(pp1);
f0101990:	89 3c 24             	mov    %edi,(%esp)
f0101993:	e8 94 f6 ff ff       	call   f010102c <page_free>
	page_free(pp2);
f0101998:	83 c4 04             	add    $0x4,%esp
f010199b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010199e:	e8 89 f6 ff ff       	call   f010102c <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01019a3:	a1 40 f2 21 f0       	mov    0xf021f240,%eax
f01019a8:	83 c4 10             	add    $0x10,%esp
f01019ab:	eb 05                	jmp    f01019b2 <mem_init+0x51e>
		--nfree;
f01019ad:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01019b0:	8b 00                	mov    (%eax),%eax
f01019b2:	85 c0                	test   %eax,%eax
f01019b4:	75 f7                	jne    f01019ad <mem_init+0x519>
		--nfree;
	assert(nfree == 0);
f01019b6:	85 db                	test   %ebx,%ebx
f01019b8:	74 19                	je     f01019d3 <mem_init+0x53f>
f01019ba:	68 88 7d 10 f0       	push   $0xf0107d88
f01019bf:	68 94 7b 10 f0       	push   $0xf0107b94
f01019c4:	68 7c 03 00 00       	push   $0x37c
f01019c9:	68 51 7b 10 f0       	push   $0xf0107b51
f01019ce:	e8 6d e6 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01019d3:	83 ec 0c             	sub    $0xc,%esp
f01019d6:	68 94 73 10 f0       	push   $0xf0107394
f01019db:	e8 00 24 00 00       	call   f0103de0 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01019e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019e7:	e8 d0 f5 ff ff       	call   f0100fbc <page_alloc>
f01019ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01019ef:	83 c4 10             	add    $0x10,%esp
f01019f2:	85 c0                	test   %eax,%eax
f01019f4:	75 19                	jne    f0101a0f <mem_init+0x57b>
f01019f6:	68 96 7c 10 f0       	push   $0xf0107c96
f01019fb:	68 94 7b 10 f0       	push   $0xf0107b94
f0101a00:	68 e2 03 00 00       	push   $0x3e2
f0101a05:	68 51 7b 10 f0       	push   $0xf0107b51
f0101a0a:	e8 31 e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a0f:	83 ec 0c             	sub    $0xc,%esp
f0101a12:	6a 00                	push   $0x0
f0101a14:	e8 a3 f5 ff ff       	call   f0100fbc <page_alloc>
f0101a19:	89 c3                	mov    %eax,%ebx
f0101a1b:	83 c4 10             	add    $0x10,%esp
f0101a1e:	85 c0                	test   %eax,%eax
f0101a20:	75 19                	jne    f0101a3b <mem_init+0x5a7>
f0101a22:	68 ac 7c 10 f0       	push   $0xf0107cac
f0101a27:	68 94 7b 10 f0       	push   $0xf0107b94
f0101a2c:	68 e3 03 00 00       	push   $0x3e3
f0101a31:	68 51 7b 10 f0       	push   $0xf0107b51
f0101a36:	e8 05 e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a3b:	83 ec 0c             	sub    $0xc,%esp
f0101a3e:	6a 00                	push   $0x0
f0101a40:	e8 77 f5 ff ff       	call   f0100fbc <page_alloc>
f0101a45:	89 c6                	mov    %eax,%esi
f0101a47:	83 c4 10             	add    $0x10,%esp
f0101a4a:	85 c0                	test   %eax,%eax
f0101a4c:	75 19                	jne    f0101a67 <mem_init+0x5d3>
f0101a4e:	68 c2 7c 10 f0       	push   $0xf0107cc2
f0101a53:	68 94 7b 10 f0       	push   $0xf0107b94
f0101a58:	68 e4 03 00 00       	push   $0x3e4
f0101a5d:	68 51 7b 10 f0       	push   $0xf0107b51
f0101a62:	e8 d9 e5 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a67:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101a6a:	75 19                	jne    f0101a85 <mem_init+0x5f1>
f0101a6c:	68 d8 7c 10 f0       	push   $0xf0107cd8
f0101a71:	68 94 7b 10 f0       	push   $0xf0107b94
f0101a76:	68 e7 03 00 00       	push   $0x3e7
f0101a7b:	68 51 7b 10 f0       	push   $0xf0107b51
f0101a80:	e8 bb e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a85:	39 c3                	cmp    %eax,%ebx
f0101a87:	74 05                	je     f0101a8e <mem_init+0x5fa>
f0101a89:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101a8c:	75 19                	jne    f0101aa7 <mem_init+0x613>
f0101a8e:	68 74 73 10 f0       	push   $0xf0107374
f0101a93:	68 94 7b 10 f0       	push   $0xf0107b94
f0101a98:	68 e8 03 00 00       	push   $0x3e8
f0101a9d:	68 51 7b 10 f0       	push   $0xf0107b51
f0101aa2:	e8 99 e5 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101aa7:	a1 40 f2 21 f0       	mov    0xf021f240,%eax
f0101aac:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101aaf:	c7 05 40 f2 21 f0 00 	movl   $0x0,0xf021f240
f0101ab6:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101ab9:	83 ec 0c             	sub    $0xc,%esp
f0101abc:	6a 00                	push   $0x0
f0101abe:	e8 f9 f4 ff ff       	call   f0100fbc <page_alloc>
f0101ac3:	83 c4 10             	add    $0x10,%esp
f0101ac6:	85 c0                	test   %eax,%eax
f0101ac8:	74 19                	je     f0101ae3 <mem_init+0x64f>
f0101aca:	68 41 7d 10 f0       	push   $0xf0107d41
f0101acf:	68 94 7b 10 f0       	push   $0xf0107b94
f0101ad4:	68 ef 03 00 00       	push   $0x3ef
f0101ad9:	68 51 7b 10 f0       	push   $0xf0107b51
f0101ade:	e8 5d e5 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101ae3:	83 ec 04             	sub    $0x4,%esp
f0101ae6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101ae9:	50                   	push   %eax
f0101aea:	6a 00                	push   $0x0
f0101aec:	ff 35 8c fe 21 f0    	pushl  0xf021fe8c
f0101af2:	e8 49 f7 ff ff       	call   f0101240 <page_lookup>
f0101af7:	83 c4 10             	add    $0x10,%esp
f0101afa:	85 c0                	test   %eax,%eax
f0101afc:	74 19                	je     f0101b17 <mem_init+0x683>
f0101afe:	68 b4 73 10 f0       	push   $0xf01073b4
f0101b03:	68 94 7b 10 f0       	push   $0xf0107b94
f0101b08:	68 f2 03 00 00       	push   $0x3f2
f0101b0d:	68 51 7b 10 f0       	push   $0xf0107b51
f0101b12:	e8 29 e5 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101b17:	6a 02                	push   $0x2
f0101b19:	6a 00                	push   $0x0
f0101b1b:	53                   	push   %ebx
f0101b1c:	ff 35 8c fe 21 f0    	pushl  0xf021fe8c
f0101b22:	e8 46 f8 ff ff       	call   f010136d <page_insert>
f0101b27:	83 c4 10             	add    $0x10,%esp
f0101b2a:	85 c0                	test   %eax,%eax
f0101b2c:	78 19                	js     f0101b47 <mem_init+0x6b3>
f0101b2e:	68 ec 73 10 f0       	push   $0xf01073ec
f0101b33:	68 94 7b 10 f0       	push   $0xf0107b94
f0101b38:	68 f5 03 00 00       	push   $0x3f5
f0101b3d:	68 51 7b 10 f0       	push   $0xf0107b51
f0101b42:	e8 f9 e4 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101b47:	83 ec 0c             	sub    $0xc,%esp
f0101b4a:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b4d:	e8 da f4 ff ff       	call   f010102c <page_free>

	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101b52:	6a 02                	push   $0x2
f0101b54:	6a 00                	push   $0x0
f0101b56:	53                   	push   %ebx
f0101b57:	ff 35 8c fe 21 f0    	pushl  0xf021fe8c
f0101b5d:	e8 0b f8 ff ff       	call   f010136d <page_insert>
f0101b62:	83 c4 20             	add    $0x20,%esp
f0101b65:	85 c0                	test   %eax,%eax
f0101b67:	74 19                	je     f0101b82 <mem_init+0x6ee>
f0101b69:	68 1c 74 10 f0       	push   $0xf010741c
f0101b6e:	68 94 7b 10 f0       	push   $0xf0107b94
f0101b73:	68 fa 03 00 00       	push   $0x3fa
f0101b78:	68 51 7b 10 f0       	push   $0xf0107b51
f0101b7d:	e8 be e4 ff ff       	call   f0100040 <_panic>
        assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b82:	8b 3d 8c fe 21 f0    	mov    0xf021fe8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b88:	a1 90 fe 21 f0       	mov    0xf021fe90,%eax
f0101b8d:	89 c1                	mov    %eax,%ecx
f0101b8f:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101b92:	8b 17                	mov    (%edi),%edx
f0101b94:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101b9a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b9d:	29 c8                	sub    %ecx,%eax
f0101b9f:	c1 f8 03             	sar    $0x3,%eax
f0101ba2:	c1 e0 0c             	shl    $0xc,%eax
f0101ba5:	39 c2                	cmp    %eax,%edx
f0101ba7:	74 19                	je     f0101bc2 <mem_init+0x72e>
f0101ba9:	68 4c 74 10 f0       	push   $0xf010744c
f0101bae:	68 94 7b 10 f0       	push   $0xf0107b94
f0101bb3:	68 fb 03 00 00       	push   $0x3fb
f0101bb8:	68 51 7b 10 f0       	push   $0xf0107b51
f0101bbd:	e8 7e e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101bc2:	ba 00 00 00 00       	mov    $0x0,%edx
f0101bc7:	89 f8                	mov    %edi,%eax
f0101bc9:	e8 f8 ee ff ff       	call   f0100ac6 <check_va2pa>
f0101bce:	89 da                	mov    %ebx,%edx
f0101bd0:	2b 55 c8             	sub    -0x38(%ebp),%edx
f0101bd3:	c1 fa 03             	sar    $0x3,%edx
f0101bd6:	c1 e2 0c             	shl    $0xc,%edx
f0101bd9:	39 d0                	cmp    %edx,%eax
f0101bdb:	74 19                	je     f0101bf6 <mem_init+0x762>
f0101bdd:	68 74 74 10 f0       	push   $0xf0107474
f0101be2:	68 94 7b 10 f0       	push   $0xf0107b94
f0101be7:	68 fc 03 00 00       	push   $0x3fc
f0101bec:	68 51 7b 10 f0       	push   $0xf0107b51
f0101bf1:	e8 4a e4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101bf6:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101bfb:	74 19                	je     f0101c16 <mem_init+0x782>
f0101bfd:	68 93 7d 10 f0       	push   $0xf0107d93
f0101c02:	68 94 7b 10 f0       	push   $0xf0107b94
f0101c07:	68 fd 03 00 00       	push   $0x3fd
f0101c0c:	68 51 7b 10 f0       	push   $0xf0107b51
f0101c11:	e8 2a e4 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101c16:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c19:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101c1e:	74 19                	je     f0101c39 <mem_init+0x7a5>
f0101c20:	68 a4 7d 10 f0       	push   $0xf0107da4
f0101c25:	68 94 7b 10 f0       	push   $0xf0107b94
f0101c2a:	68 fe 03 00 00       	push   $0x3fe
f0101c2f:	68 51 7b 10 f0       	push   $0xf0107b51
f0101c34:	e8 07 e4 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c39:	6a 02                	push   $0x2
f0101c3b:	68 00 10 00 00       	push   $0x1000
f0101c40:	56                   	push   %esi
f0101c41:	57                   	push   %edi
f0101c42:	e8 26 f7 ff ff       	call   f010136d <page_insert>
f0101c47:	83 c4 10             	add    $0x10,%esp
f0101c4a:	85 c0                	test   %eax,%eax
f0101c4c:	74 19                	je     f0101c67 <mem_init+0x7d3>
f0101c4e:	68 a4 74 10 f0       	push   $0xf01074a4
f0101c53:	68 94 7b 10 f0       	push   $0xf0107b94
f0101c58:	68 01 04 00 00       	push   $0x401
f0101c5d:	68 51 7b 10 f0       	push   $0xf0107b51
f0101c62:	e8 d9 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c67:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c6c:	a1 8c fe 21 f0       	mov    0xf021fe8c,%eax
f0101c71:	e8 50 ee ff ff       	call   f0100ac6 <check_va2pa>
f0101c76:	89 f2                	mov    %esi,%edx
f0101c78:	2b 15 90 fe 21 f0    	sub    0xf021fe90,%edx
f0101c7e:	c1 fa 03             	sar    $0x3,%edx
f0101c81:	c1 e2 0c             	shl    $0xc,%edx
f0101c84:	39 d0                	cmp    %edx,%eax
f0101c86:	74 19                	je     f0101ca1 <mem_init+0x80d>
f0101c88:	68 e0 74 10 f0       	push   $0xf01074e0
f0101c8d:	68 94 7b 10 f0       	push   $0xf0107b94
f0101c92:	68 02 04 00 00       	push   $0x402
f0101c97:	68 51 7b 10 f0       	push   $0xf0107b51
f0101c9c:	e8 9f e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101ca1:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ca6:	74 19                	je     f0101cc1 <mem_init+0x82d>
f0101ca8:	68 b5 7d 10 f0       	push   $0xf0107db5
f0101cad:	68 94 7b 10 f0       	push   $0xf0107b94
f0101cb2:	68 03 04 00 00       	push   $0x403
f0101cb7:	68 51 7b 10 f0       	push   $0xf0107b51
f0101cbc:	e8 7f e3 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101cc1:	83 ec 0c             	sub    $0xc,%esp
f0101cc4:	6a 00                	push   $0x0
f0101cc6:	e8 f1 f2 ff ff       	call   f0100fbc <page_alloc>
f0101ccb:	83 c4 10             	add    $0x10,%esp
f0101cce:	85 c0                	test   %eax,%eax
f0101cd0:	74 19                	je     f0101ceb <mem_init+0x857>
f0101cd2:	68 41 7d 10 f0       	push   $0xf0107d41
f0101cd7:	68 94 7b 10 f0       	push   $0xf0107b94
f0101cdc:	68 06 04 00 00       	push   $0x406
f0101ce1:	68 51 7b 10 f0       	push   $0xf0107b51
f0101ce6:	e8 55 e3 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ceb:	6a 02                	push   $0x2
f0101ced:	68 00 10 00 00       	push   $0x1000
f0101cf2:	56                   	push   %esi
f0101cf3:	ff 35 8c fe 21 f0    	pushl  0xf021fe8c
f0101cf9:	e8 6f f6 ff ff       	call   f010136d <page_insert>
f0101cfe:	83 c4 10             	add    $0x10,%esp
f0101d01:	85 c0                	test   %eax,%eax
f0101d03:	74 19                	je     f0101d1e <mem_init+0x88a>
f0101d05:	68 a4 74 10 f0       	push   $0xf01074a4
f0101d0a:	68 94 7b 10 f0       	push   $0xf0107b94
f0101d0f:	68 09 04 00 00       	push   $0x409
f0101d14:	68 51 7b 10 f0       	push   $0xf0107b51
f0101d19:	e8 22 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d1e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d23:	a1 8c fe 21 f0       	mov    0xf021fe8c,%eax
f0101d28:	e8 99 ed ff ff       	call   f0100ac6 <check_va2pa>
f0101d2d:	89 f2                	mov    %esi,%edx
f0101d2f:	2b 15 90 fe 21 f0    	sub    0xf021fe90,%edx
f0101d35:	c1 fa 03             	sar    $0x3,%edx
f0101d38:	c1 e2 0c             	shl    $0xc,%edx
f0101d3b:	39 d0                	cmp    %edx,%eax
f0101d3d:	74 19                	je     f0101d58 <mem_init+0x8c4>
f0101d3f:	68 e0 74 10 f0       	push   $0xf01074e0
f0101d44:	68 94 7b 10 f0       	push   $0xf0107b94
f0101d49:	68 0a 04 00 00       	push   $0x40a
f0101d4e:	68 51 7b 10 f0       	push   $0xf0107b51
f0101d53:	e8 e8 e2 ff ff       	call   f0100040 <_panic>
        assert(pp2->pp_ref == 1);
f0101d58:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d5d:	74 19                	je     f0101d78 <mem_init+0x8e4>
f0101d5f:	68 b5 7d 10 f0       	push   $0xf0107db5
f0101d64:	68 94 7b 10 f0       	push   $0xf0107b94
f0101d69:	68 0b 04 00 00       	push   $0x40b
f0101d6e:	68 51 7b 10 f0       	push   $0xf0107b51
f0101d73:	e8 c8 e2 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101d78:	83 ec 0c             	sub    $0xc,%esp
f0101d7b:	6a 00                	push   $0x0
f0101d7d:	e8 3a f2 ff ff       	call   f0100fbc <page_alloc>
f0101d82:	83 c4 10             	add    $0x10,%esp
f0101d85:	85 c0                	test   %eax,%eax
f0101d87:	74 19                	je     f0101da2 <mem_init+0x90e>
f0101d89:	68 41 7d 10 f0       	push   $0xf0107d41
f0101d8e:	68 94 7b 10 f0       	push   $0xf0107b94
f0101d93:	68 0f 04 00 00       	push   $0x40f
f0101d98:	68 51 7b 10 f0       	push   $0xf0107b51
f0101d9d:	e8 9e e2 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101da2:	8b 15 8c fe 21 f0    	mov    0xf021fe8c,%edx
f0101da8:	8b 02                	mov    (%edx),%eax
f0101daa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101daf:	89 c1                	mov    %eax,%ecx
f0101db1:	c1 e9 0c             	shr    $0xc,%ecx
f0101db4:	3b 0d 88 fe 21 f0    	cmp    0xf021fe88,%ecx
f0101dba:	72 15                	jb     f0101dd1 <mem_init+0x93d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101dbc:	50                   	push   %eax
f0101dbd:	68 84 6c 10 f0       	push   $0xf0106c84
f0101dc2:	68 12 04 00 00       	push   $0x412
f0101dc7:	68 51 7b 10 f0       	push   $0xf0107b51
f0101dcc:	e8 6f e2 ff ff       	call   f0100040 <_panic>
f0101dd1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101dd6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101dd9:	83 ec 04             	sub    $0x4,%esp
f0101ddc:	6a 00                	push   $0x0
f0101dde:	68 00 10 00 00       	push   $0x1000
f0101de3:	52                   	push   %edx
f0101de4:	e8 d9 f2 ff ff       	call   f01010c2 <pgdir_walk>
f0101de9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101dec:	8d 51 04             	lea    0x4(%ecx),%edx
f0101def:	83 c4 10             	add    $0x10,%esp
f0101df2:	39 d0                	cmp    %edx,%eax
f0101df4:	74 19                	je     f0101e0f <mem_init+0x97b>
f0101df6:	68 10 75 10 f0       	push   $0xf0107510
f0101dfb:	68 94 7b 10 f0       	push   $0xf0107b94
f0101e00:	68 13 04 00 00       	push   $0x413
f0101e05:	68 51 7b 10 f0       	push   $0xf0107b51
f0101e0a:	e8 31 e2 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101e0f:	6a 06                	push   $0x6
f0101e11:	68 00 10 00 00       	push   $0x1000
f0101e16:	56                   	push   %esi
f0101e17:	ff 35 8c fe 21 f0    	pushl  0xf021fe8c
f0101e1d:	e8 4b f5 ff ff       	call   f010136d <page_insert>
f0101e22:	83 c4 10             	add    $0x10,%esp
f0101e25:	85 c0                	test   %eax,%eax
f0101e27:	74 19                	je     f0101e42 <mem_init+0x9ae>
f0101e29:	68 50 75 10 f0       	push   $0xf0107550
f0101e2e:	68 94 7b 10 f0       	push   $0xf0107b94
f0101e33:	68 16 04 00 00       	push   $0x416
f0101e38:	68 51 7b 10 f0       	push   $0xf0107b51
f0101e3d:	e8 fe e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e42:	8b 3d 8c fe 21 f0    	mov    0xf021fe8c,%edi
f0101e48:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e4d:	89 f8                	mov    %edi,%eax
f0101e4f:	e8 72 ec ff ff       	call   f0100ac6 <check_va2pa>
f0101e54:	89 f2                	mov    %esi,%edx
f0101e56:	2b 15 90 fe 21 f0    	sub    0xf021fe90,%edx
f0101e5c:	c1 fa 03             	sar    $0x3,%edx
f0101e5f:	c1 e2 0c             	shl    $0xc,%edx
f0101e62:	39 d0                	cmp    %edx,%eax
f0101e64:	74 19                	je     f0101e7f <mem_init+0x9eb>
f0101e66:	68 e0 74 10 f0       	push   $0xf01074e0
f0101e6b:	68 94 7b 10 f0       	push   $0xf0107b94
f0101e70:	68 17 04 00 00       	push   $0x417
f0101e75:	68 51 7b 10 f0       	push   $0xf0107b51
f0101e7a:	e8 c1 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101e7f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e84:	74 19                	je     f0101e9f <mem_init+0xa0b>
f0101e86:	68 b5 7d 10 f0       	push   $0xf0107db5
f0101e8b:	68 94 7b 10 f0       	push   $0xf0107b94
f0101e90:	68 18 04 00 00       	push   $0x418
f0101e95:	68 51 7b 10 f0       	push   $0xf0107b51
f0101e9a:	e8 a1 e1 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101e9f:	83 ec 04             	sub    $0x4,%esp
f0101ea2:	6a 00                	push   $0x0
f0101ea4:	68 00 10 00 00       	push   $0x1000
f0101ea9:	57                   	push   %edi
f0101eaa:	e8 13 f2 ff ff       	call   f01010c2 <pgdir_walk>
f0101eaf:	83 c4 10             	add    $0x10,%esp
f0101eb2:	f6 00 04             	testb  $0x4,(%eax)
f0101eb5:	75 19                	jne    f0101ed0 <mem_init+0xa3c>
f0101eb7:	68 90 75 10 f0       	push   $0xf0107590
f0101ebc:	68 94 7b 10 f0       	push   $0xf0107b94
f0101ec1:	68 19 04 00 00       	push   $0x419
f0101ec6:	68 51 7b 10 f0       	push   $0xf0107b51
f0101ecb:	e8 70 e1 ff ff       	call   f0100040 <_panic>
        assert(kern_pgdir[0] & PTE_U);
f0101ed0:	a1 8c fe 21 f0       	mov    0xf021fe8c,%eax
f0101ed5:	f6 00 04             	testb  $0x4,(%eax)
f0101ed8:	75 19                	jne    f0101ef3 <mem_init+0xa5f>
f0101eda:	68 c6 7d 10 f0       	push   $0xf0107dc6
f0101edf:	68 94 7b 10 f0       	push   $0xf0107b94
f0101ee4:	68 1a 04 00 00       	push   $0x41a
f0101ee9:	68 51 7b 10 f0       	push   $0xf0107b51
f0101eee:	e8 4d e1 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ef3:	6a 02                	push   $0x2
f0101ef5:	68 00 10 00 00       	push   $0x1000
f0101efa:	56                   	push   %esi
f0101efb:	50                   	push   %eax
f0101efc:	e8 6c f4 ff ff       	call   f010136d <page_insert>
f0101f01:	83 c4 10             	add    $0x10,%esp
f0101f04:	85 c0                	test   %eax,%eax
f0101f06:	74 19                	je     f0101f21 <mem_init+0xa8d>
f0101f08:	68 a4 74 10 f0       	push   $0xf01074a4
f0101f0d:	68 94 7b 10 f0       	push   $0xf0107b94
f0101f12:	68 1d 04 00 00       	push   $0x41d
f0101f17:	68 51 7b 10 f0       	push   $0xf0107b51
f0101f1c:	e8 1f e1 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101f21:	83 ec 04             	sub    $0x4,%esp
f0101f24:	6a 00                	push   $0x0
f0101f26:	68 00 10 00 00       	push   $0x1000
f0101f2b:	ff 35 8c fe 21 f0    	pushl  0xf021fe8c
f0101f31:	e8 8c f1 ff ff       	call   f01010c2 <pgdir_walk>
f0101f36:	83 c4 10             	add    $0x10,%esp
f0101f39:	f6 00 02             	testb  $0x2,(%eax)
f0101f3c:	75 19                	jne    f0101f57 <mem_init+0xac3>
f0101f3e:	68 c4 75 10 f0       	push   $0xf01075c4
f0101f43:	68 94 7b 10 f0       	push   $0xf0107b94
f0101f48:	68 1e 04 00 00       	push   $0x41e
f0101f4d:	68 51 7b 10 f0       	push   $0xf0107b51
f0101f52:	e8 e9 e0 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f57:	83 ec 04             	sub    $0x4,%esp
f0101f5a:	6a 00                	push   $0x0
f0101f5c:	68 00 10 00 00       	push   $0x1000
f0101f61:	ff 35 8c fe 21 f0    	pushl  0xf021fe8c
f0101f67:	e8 56 f1 ff ff       	call   f01010c2 <pgdir_walk>
f0101f6c:	83 c4 10             	add    $0x10,%esp
f0101f6f:	f6 00 04             	testb  $0x4,(%eax)
f0101f72:	74 19                	je     f0101f8d <mem_init+0xaf9>
f0101f74:	68 f8 75 10 f0       	push   $0xf01075f8
f0101f79:	68 94 7b 10 f0       	push   $0xf0107b94
f0101f7e:	68 1f 04 00 00       	push   $0x41f
f0101f83:	68 51 7b 10 f0       	push   $0xf0107b51
f0101f88:	e8 b3 e0 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101f8d:	6a 02                	push   $0x2
f0101f8f:	68 00 00 40 00       	push   $0x400000
f0101f94:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101f97:	ff 35 8c fe 21 f0    	pushl  0xf021fe8c
f0101f9d:	e8 cb f3 ff ff       	call   f010136d <page_insert>
f0101fa2:	83 c4 10             	add    $0x10,%esp
f0101fa5:	85 c0                	test   %eax,%eax
f0101fa7:	78 19                	js     f0101fc2 <mem_init+0xb2e>
f0101fa9:	68 30 76 10 f0       	push   $0xf0107630
f0101fae:	68 94 7b 10 f0       	push   $0xf0107b94
f0101fb3:	68 22 04 00 00       	push   $0x422
f0101fb8:	68 51 7b 10 f0       	push   $0xf0107b51
f0101fbd:	e8 7e e0 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101fc2:	6a 02                	push   $0x2
f0101fc4:	68 00 10 00 00       	push   $0x1000
f0101fc9:	53                   	push   %ebx
f0101fca:	ff 35 8c fe 21 f0    	pushl  0xf021fe8c
f0101fd0:	e8 98 f3 ff ff       	call   f010136d <page_insert>
f0101fd5:	83 c4 10             	add    $0x10,%esp
f0101fd8:	85 c0                	test   %eax,%eax
f0101fda:	74 19                	je     f0101ff5 <mem_init+0xb61>
f0101fdc:	68 68 76 10 f0       	push   $0xf0107668
f0101fe1:	68 94 7b 10 f0       	push   $0xf0107b94
f0101fe6:	68 25 04 00 00       	push   $0x425
f0101feb:	68 51 7b 10 f0       	push   $0xf0107b51
f0101ff0:	e8 4b e0 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ff5:	83 ec 04             	sub    $0x4,%esp
f0101ff8:	6a 00                	push   $0x0
f0101ffa:	68 00 10 00 00       	push   $0x1000
f0101fff:	ff 35 8c fe 21 f0    	pushl  0xf021fe8c
f0102005:	e8 b8 f0 ff ff       	call   f01010c2 <pgdir_walk>
f010200a:	83 c4 10             	add    $0x10,%esp
f010200d:	f6 00 04             	testb  $0x4,(%eax)
f0102010:	74 19                	je     f010202b <mem_init+0xb97>
f0102012:	68 f8 75 10 f0       	push   $0xf01075f8
f0102017:	68 94 7b 10 f0       	push   $0xf0107b94
f010201c:	68 26 04 00 00       	push   $0x426
f0102021:	68 51 7b 10 f0       	push   $0xf0107b51
f0102026:	e8 15 e0 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010202b:	8b 3d 8c fe 21 f0    	mov    0xf021fe8c,%edi
f0102031:	ba 00 00 00 00       	mov    $0x0,%edx
f0102036:	89 f8                	mov    %edi,%eax
f0102038:	e8 89 ea ff ff       	call   f0100ac6 <check_va2pa>
f010203d:	89 c1                	mov    %eax,%ecx
f010203f:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102042:	89 d8                	mov    %ebx,%eax
f0102044:	2b 05 90 fe 21 f0    	sub    0xf021fe90,%eax
f010204a:	c1 f8 03             	sar    $0x3,%eax
f010204d:	c1 e0 0c             	shl    $0xc,%eax
f0102050:	39 c1                	cmp    %eax,%ecx
f0102052:	74 19                	je     f010206d <mem_init+0xbd9>
f0102054:	68 a4 76 10 f0       	push   $0xf01076a4
f0102059:	68 94 7b 10 f0       	push   $0xf0107b94
f010205e:	68 29 04 00 00       	push   $0x429
f0102063:	68 51 7b 10 f0       	push   $0xf0107b51
f0102068:	e8 d3 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010206d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102072:	89 f8                	mov    %edi,%eax
f0102074:	e8 4d ea ff ff       	call   f0100ac6 <check_va2pa>
f0102079:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f010207c:	74 19                	je     f0102097 <mem_init+0xc03>
f010207e:	68 d0 76 10 f0       	push   $0xf01076d0
f0102083:	68 94 7b 10 f0       	push   $0xf0107b94
f0102088:	68 2a 04 00 00       	push   $0x42a
f010208d:	68 51 7b 10 f0       	push   $0xf0107b51
f0102092:	e8 a9 df ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102097:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f010209c:	74 19                	je     f01020b7 <mem_init+0xc23>
f010209e:	68 dc 7d 10 f0       	push   $0xf0107ddc
f01020a3:	68 94 7b 10 f0       	push   $0xf0107b94
f01020a8:	68 2c 04 00 00       	push   $0x42c
f01020ad:	68 51 7b 10 f0       	push   $0xf0107b51
f01020b2:	e8 89 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01020b7:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01020bc:	74 19                	je     f01020d7 <mem_init+0xc43>
f01020be:	68 ed 7d 10 f0       	push   $0xf0107ded
f01020c3:	68 94 7b 10 f0       	push   $0xf0107b94
f01020c8:	68 2d 04 00 00       	push   $0x42d
f01020cd:	68 51 7b 10 f0       	push   $0xf0107b51
f01020d2:	e8 69 df ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01020d7:	83 ec 0c             	sub    $0xc,%esp
f01020da:	6a 00                	push   $0x0
f01020dc:	e8 db ee ff ff       	call   f0100fbc <page_alloc>
f01020e1:	83 c4 10             	add    $0x10,%esp
f01020e4:	85 c0                	test   %eax,%eax
f01020e6:	74 04                	je     f01020ec <mem_init+0xc58>
f01020e8:	39 c6                	cmp    %eax,%esi
f01020ea:	74 19                	je     f0102105 <mem_init+0xc71>
f01020ec:	68 00 77 10 f0       	push   $0xf0107700
f01020f1:	68 94 7b 10 f0       	push   $0xf0107b94
f01020f6:	68 30 04 00 00       	push   $0x430
f01020fb:	68 51 7b 10 f0       	push   $0xf0107b51
f0102100:	e8 3b df ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102105:	83 ec 08             	sub    $0x8,%esp
f0102108:	6a 00                	push   $0x0
f010210a:	ff 35 8c fe 21 f0    	pushl  0xf021fe8c
f0102110:	e8 ea f1 ff ff       	call   f01012ff <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102115:	8b 3d 8c fe 21 f0    	mov    0xf021fe8c,%edi
f010211b:	ba 00 00 00 00       	mov    $0x0,%edx
f0102120:	89 f8                	mov    %edi,%eax
f0102122:	e8 9f e9 ff ff       	call   f0100ac6 <check_va2pa>
f0102127:	83 c4 10             	add    $0x10,%esp
f010212a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010212d:	74 19                	je     f0102148 <mem_init+0xcb4>
f010212f:	68 24 77 10 f0       	push   $0xf0107724
f0102134:	68 94 7b 10 f0       	push   $0xf0107b94
f0102139:	68 34 04 00 00       	push   $0x434
f010213e:	68 51 7b 10 f0       	push   $0xf0107b51
f0102143:	e8 f8 de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102148:	ba 00 10 00 00       	mov    $0x1000,%edx
f010214d:	89 f8                	mov    %edi,%eax
f010214f:	e8 72 e9 ff ff       	call   f0100ac6 <check_va2pa>
f0102154:	89 da                	mov    %ebx,%edx
f0102156:	2b 15 90 fe 21 f0    	sub    0xf021fe90,%edx
f010215c:	c1 fa 03             	sar    $0x3,%edx
f010215f:	c1 e2 0c             	shl    $0xc,%edx
f0102162:	39 d0                	cmp    %edx,%eax
f0102164:	74 19                	je     f010217f <mem_init+0xceb>
f0102166:	68 d0 76 10 f0       	push   $0xf01076d0
f010216b:	68 94 7b 10 f0       	push   $0xf0107b94
f0102170:	68 35 04 00 00       	push   $0x435
f0102175:	68 51 7b 10 f0       	push   $0xf0107b51
f010217a:	e8 c1 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010217f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102184:	74 19                	je     f010219f <mem_init+0xd0b>
f0102186:	68 93 7d 10 f0       	push   $0xf0107d93
f010218b:	68 94 7b 10 f0       	push   $0xf0107b94
f0102190:	68 36 04 00 00       	push   $0x436
f0102195:	68 51 7b 10 f0       	push   $0xf0107b51
f010219a:	e8 a1 de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010219f:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01021a4:	74 19                	je     f01021bf <mem_init+0xd2b>
f01021a6:	68 ed 7d 10 f0       	push   $0xf0107ded
f01021ab:	68 94 7b 10 f0       	push   $0xf0107b94
f01021b0:	68 37 04 00 00       	push   $0x437
f01021b5:	68 51 7b 10 f0       	push   $0xf0107b51
f01021ba:	e8 81 de ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01021bf:	6a 00                	push   $0x0
f01021c1:	68 00 10 00 00       	push   $0x1000
f01021c6:	53                   	push   %ebx
f01021c7:	57                   	push   %edi
f01021c8:	e8 a0 f1 ff ff       	call   f010136d <page_insert>
f01021cd:	83 c4 10             	add    $0x10,%esp
f01021d0:	85 c0                	test   %eax,%eax
f01021d2:	74 19                	je     f01021ed <mem_init+0xd59>
f01021d4:	68 48 77 10 f0       	push   $0xf0107748
f01021d9:	68 94 7b 10 f0       	push   $0xf0107b94
f01021de:	68 3a 04 00 00       	push   $0x43a
f01021e3:	68 51 7b 10 f0       	push   $0xf0107b51
f01021e8:	e8 53 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01021ed:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01021f2:	75 19                	jne    f010220d <mem_init+0xd79>
f01021f4:	68 fe 7d 10 f0       	push   $0xf0107dfe
f01021f9:	68 94 7b 10 f0       	push   $0xf0107b94
f01021fe:	68 3b 04 00 00       	push   $0x43b
f0102203:	68 51 7b 10 f0       	push   $0xf0107b51
f0102208:	e8 33 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f010220d:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102210:	74 19                	je     f010222b <mem_init+0xd97>
f0102212:	68 0a 7e 10 f0       	push   $0xf0107e0a
f0102217:	68 94 7b 10 f0       	push   $0xf0107b94
f010221c:	68 3c 04 00 00       	push   $0x43c
f0102221:	68 51 7b 10 f0       	push   $0xf0107b51
f0102226:	e8 15 de ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010222b:	83 ec 08             	sub    $0x8,%esp
f010222e:	68 00 10 00 00       	push   $0x1000
f0102233:	ff 35 8c fe 21 f0    	pushl  0xf021fe8c
f0102239:	e8 c1 f0 ff ff       	call   f01012ff <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010223e:	8b 3d 8c fe 21 f0    	mov    0xf021fe8c,%edi
f0102244:	ba 00 00 00 00       	mov    $0x0,%edx
f0102249:	89 f8                	mov    %edi,%eax
f010224b:	e8 76 e8 ff ff       	call   f0100ac6 <check_va2pa>
f0102250:	83 c4 10             	add    $0x10,%esp
f0102253:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102256:	74 19                	je     f0102271 <mem_init+0xddd>
f0102258:	68 24 77 10 f0       	push   $0xf0107724
f010225d:	68 94 7b 10 f0       	push   $0xf0107b94
f0102262:	68 40 04 00 00       	push   $0x440
f0102267:	68 51 7b 10 f0       	push   $0xf0107b51
f010226c:	e8 cf dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102271:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102276:	89 f8                	mov    %edi,%eax
f0102278:	e8 49 e8 ff ff       	call   f0100ac6 <check_va2pa>
f010227d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102280:	74 19                	je     f010229b <mem_init+0xe07>
f0102282:	68 80 77 10 f0       	push   $0xf0107780
f0102287:	68 94 7b 10 f0       	push   $0xf0107b94
f010228c:	68 41 04 00 00       	push   $0x441
f0102291:	68 51 7b 10 f0       	push   $0xf0107b51
f0102296:	e8 a5 dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010229b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022a0:	74 19                	je     f01022bb <mem_init+0xe27>
f01022a2:	68 1f 7e 10 f0       	push   $0xf0107e1f
f01022a7:	68 94 7b 10 f0       	push   $0xf0107b94
f01022ac:	68 42 04 00 00       	push   $0x442
f01022b1:	68 51 7b 10 f0       	push   $0xf0107b51
f01022b6:	e8 85 dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01022bb:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01022c0:	74 19                	je     f01022db <mem_init+0xe47>
f01022c2:	68 ed 7d 10 f0       	push   $0xf0107ded
f01022c7:	68 94 7b 10 f0       	push   $0xf0107b94
f01022cc:	68 43 04 00 00       	push   $0x443
f01022d1:	68 51 7b 10 f0       	push   $0xf0107b51
f01022d6:	e8 65 dd ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01022db:	83 ec 0c             	sub    $0xc,%esp
f01022de:	6a 00                	push   $0x0
f01022e0:	e8 d7 ec ff ff       	call   f0100fbc <page_alloc>
f01022e5:	83 c4 10             	add    $0x10,%esp
f01022e8:	39 c3                	cmp    %eax,%ebx
f01022ea:	75 04                	jne    f01022f0 <mem_init+0xe5c>
f01022ec:	85 c0                	test   %eax,%eax
f01022ee:	75 19                	jne    f0102309 <mem_init+0xe75>
f01022f0:	68 a8 77 10 f0       	push   $0xf01077a8
f01022f5:	68 94 7b 10 f0       	push   $0xf0107b94
f01022fa:	68 46 04 00 00       	push   $0x446
f01022ff:	68 51 7b 10 f0       	push   $0xf0107b51
f0102304:	e8 37 dd ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102309:	83 ec 0c             	sub    $0xc,%esp
f010230c:	6a 00                	push   $0x0
f010230e:	e8 a9 ec ff ff       	call   f0100fbc <page_alloc>
f0102313:	83 c4 10             	add    $0x10,%esp
f0102316:	85 c0                	test   %eax,%eax
f0102318:	74 19                	je     f0102333 <mem_init+0xe9f>
f010231a:	68 41 7d 10 f0       	push   $0xf0107d41
f010231f:	68 94 7b 10 f0       	push   $0xf0107b94
f0102324:	68 49 04 00 00       	push   $0x449
f0102329:	68 51 7b 10 f0       	push   $0xf0107b51
f010232e:	e8 0d dd ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102333:	8b 0d 8c fe 21 f0    	mov    0xf021fe8c,%ecx
f0102339:	8b 11                	mov    (%ecx),%edx
f010233b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102341:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102344:	2b 05 90 fe 21 f0    	sub    0xf021fe90,%eax
f010234a:	c1 f8 03             	sar    $0x3,%eax
f010234d:	c1 e0 0c             	shl    $0xc,%eax
f0102350:	39 c2                	cmp    %eax,%edx
f0102352:	74 19                	je     f010236d <mem_init+0xed9>
f0102354:	68 4c 74 10 f0       	push   $0xf010744c
f0102359:	68 94 7b 10 f0       	push   $0xf0107b94
f010235e:	68 4c 04 00 00       	push   $0x44c
f0102363:	68 51 7b 10 f0       	push   $0xf0107b51
f0102368:	e8 d3 dc ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010236d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102373:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102376:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010237b:	74 19                	je     f0102396 <mem_init+0xf02>
f010237d:	68 a4 7d 10 f0       	push   $0xf0107da4
f0102382:	68 94 7b 10 f0       	push   $0xf0107b94
f0102387:	68 4e 04 00 00       	push   $0x44e
f010238c:	68 51 7b 10 f0       	push   $0xf0107b51
f0102391:	e8 aa dc ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102396:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102399:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010239f:	83 ec 0c             	sub    $0xc,%esp
f01023a2:	50                   	push   %eax
f01023a3:	e8 84 ec ff ff       	call   f010102c <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01023a8:	83 c4 0c             	add    $0xc,%esp
f01023ab:	6a 01                	push   $0x1
f01023ad:	68 00 10 40 00       	push   $0x401000
f01023b2:	ff 35 8c fe 21 f0    	pushl  0xf021fe8c
f01023b8:	e8 05 ed ff ff       	call   f01010c2 <pgdir_walk>
f01023bd:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01023c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01023c3:	8b 0d 8c fe 21 f0    	mov    0xf021fe8c,%ecx
f01023c9:	8b 51 04             	mov    0x4(%ecx),%edx
f01023cc:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023d2:	8b 3d 88 fe 21 f0    	mov    0xf021fe88,%edi
f01023d8:	89 d0                	mov    %edx,%eax
f01023da:	c1 e8 0c             	shr    $0xc,%eax
f01023dd:	83 c4 10             	add    $0x10,%esp
f01023e0:	39 f8                	cmp    %edi,%eax
f01023e2:	72 15                	jb     f01023f9 <mem_init+0xf65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023e4:	52                   	push   %edx
f01023e5:	68 84 6c 10 f0       	push   $0xf0106c84
f01023ea:	68 55 04 00 00       	push   $0x455
f01023ef:	68 51 7b 10 f0       	push   $0xf0107b51
f01023f4:	e8 47 dc ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01023f9:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01023ff:	39 55 c8             	cmp    %edx,-0x38(%ebp)
f0102402:	74 19                	je     f010241d <mem_init+0xf89>
f0102404:	68 30 7e 10 f0       	push   $0xf0107e30
f0102409:	68 94 7b 10 f0       	push   $0xf0107b94
f010240e:	68 56 04 00 00       	push   $0x456
f0102413:	68 51 7b 10 f0       	push   $0xf0107b51
f0102418:	e8 23 dc ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010241d:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0102424:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102427:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010242d:	2b 05 90 fe 21 f0    	sub    0xf021fe90,%eax
f0102433:	c1 f8 03             	sar    $0x3,%eax
f0102436:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102439:	89 c2                	mov    %eax,%edx
f010243b:	c1 ea 0c             	shr    $0xc,%edx
f010243e:	39 d7                	cmp    %edx,%edi
f0102440:	77 12                	ja     f0102454 <mem_init+0xfc0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102442:	50                   	push   %eax
f0102443:	68 84 6c 10 f0       	push   $0xf0106c84
f0102448:	6a 58                	push   $0x58
f010244a:	68 7a 7b 10 f0       	push   $0xf0107b7a
f010244f:	e8 ec db ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102454:	83 ec 04             	sub    $0x4,%esp
f0102457:	68 00 10 00 00       	push   $0x1000
f010245c:	68 ff 00 00 00       	push   $0xff
f0102461:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102466:	50                   	push   %eax
f0102467:	e8 3b 3b 00 00       	call   f0105fa7 <memset>
	page_free(pp0);
f010246c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010246f:	89 3c 24             	mov    %edi,(%esp)
f0102472:	e8 b5 eb ff ff       	call   f010102c <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102477:	83 c4 0c             	add    $0xc,%esp
f010247a:	6a 01                	push   $0x1
f010247c:	6a 00                	push   $0x0
f010247e:	ff 35 8c fe 21 f0    	pushl  0xf021fe8c
f0102484:	e8 39 ec ff ff       	call   f01010c2 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102489:	89 fa                	mov    %edi,%edx
f010248b:	2b 15 90 fe 21 f0    	sub    0xf021fe90,%edx
f0102491:	c1 fa 03             	sar    $0x3,%edx
f0102494:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102497:	89 d0                	mov    %edx,%eax
f0102499:	c1 e8 0c             	shr    $0xc,%eax
f010249c:	83 c4 10             	add    $0x10,%esp
f010249f:	3b 05 88 fe 21 f0    	cmp    0xf021fe88,%eax
f01024a5:	72 12                	jb     f01024b9 <mem_init+0x1025>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024a7:	52                   	push   %edx
f01024a8:	68 84 6c 10 f0       	push   $0xf0106c84
f01024ad:	6a 58                	push   $0x58
f01024af:	68 7a 7b 10 f0       	push   $0xf0107b7a
f01024b4:	e8 87 db ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01024b9:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01024bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01024c2:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01024c8:	f6 00 01             	testb  $0x1,(%eax)
f01024cb:	74 19                	je     f01024e6 <mem_init+0x1052>
f01024cd:	68 48 7e 10 f0       	push   $0xf0107e48
f01024d2:	68 94 7b 10 f0       	push   $0xf0107b94
f01024d7:	68 60 04 00 00       	push   $0x460
f01024dc:	68 51 7b 10 f0       	push   $0xf0107b51
f01024e1:	e8 5a db ff ff       	call   f0100040 <_panic>
f01024e6:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01024e9:	39 d0                	cmp    %edx,%eax
f01024eb:	75 db                	jne    f01024c8 <mem_init+0x1034>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01024ed:	a1 8c fe 21 f0       	mov    0xf021fe8c,%eax
f01024f2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01024f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024fb:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102501:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102504:	89 0d 40 f2 21 f0    	mov    %ecx,0xf021f240

	// free the pages we took
	page_free(pp0);
f010250a:	83 ec 0c             	sub    $0xc,%esp
f010250d:	50                   	push   %eax
f010250e:	e8 19 eb ff ff       	call   f010102c <page_free>
	page_free(pp1);
f0102513:	89 1c 24             	mov    %ebx,(%esp)
f0102516:	e8 11 eb ff ff       	call   f010102c <page_free>
	page_free(pp2);
f010251b:	89 34 24             	mov    %esi,(%esp)
f010251e:	e8 09 eb ff ff       	call   f010102c <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102523:	83 c4 08             	add    $0x8,%esp
f0102526:	68 01 10 00 00       	push   $0x1001
f010252b:	6a 00                	push   $0x0
f010252d:	e8 02 ef ff ff       	call   f0101434 <mmio_map_region>
f0102532:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102534:	83 c4 08             	add    $0x8,%esp
f0102537:	68 00 10 00 00       	push   $0x1000
f010253c:	6a 00                	push   $0x0
f010253e:	e8 f1 ee ff ff       	call   f0101434 <mmio_map_region>
f0102543:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102545:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f010254b:	83 c4 10             	add    $0x10,%esp
f010254e:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102554:	76 07                	jbe    f010255d <mem_init+0x10c9>
f0102556:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f010255b:	76 19                	jbe    f0102576 <mem_init+0x10e2>
f010255d:	68 cc 77 10 f0       	push   $0xf01077cc
f0102562:	68 94 7b 10 f0       	push   $0xf0107b94
f0102567:	68 70 04 00 00       	push   $0x470
f010256c:	68 51 7b 10 f0       	push   $0xf0107b51
f0102571:	e8 ca da ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102576:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f010257c:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102582:	77 08                	ja     f010258c <mem_init+0x10f8>
f0102584:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010258a:	77 19                	ja     f01025a5 <mem_init+0x1111>
f010258c:	68 f4 77 10 f0       	push   $0xf01077f4
f0102591:	68 94 7b 10 f0       	push   $0xf0107b94
f0102596:	68 71 04 00 00       	push   $0x471
f010259b:	68 51 7b 10 f0       	push   $0xf0107b51
f01025a0:	e8 9b da ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01025a5:	89 da                	mov    %ebx,%edx
f01025a7:	09 f2                	or     %esi,%edx
f01025a9:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01025af:	74 19                	je     f01025ca <mem_init+0x1136>
f01025b1:	68 1c 78 10 f0       	push   $0xf010781c
f01025b6:	68 94 7b 10 f0       	push   $0xf0107b94
f01025bb:	68 73 04 00 00       	push   $0x473
f01025c0:	68 51 7b 10 f0       	push   $0xf0107b51
f01025c5:	e8 76 da ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f01025ca:	39 c6                	cmp    %eax,%esi
f01025cc:	73 19                	jae    f01025e7 <mem_init+0x1153>
f01025ce:	68 5f 7e 10 f0       	push   $0xf0107e5f
f01025d3:	68 94 7b 10 f0       	push   $0xf0107b94
f01025d8:	68 75 04 00 00       	push   $0x475
f01025dd:	68 51 7b 10 f0       	push   $0xf0107b51
f01025e2:	e8 59 da ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01025e7:	8b 3d 8c fe 21 f0    	mov    0xf021fe8c,%edi
f01025ed:	89 da                	mov    %ebx,%edx
f01025ef:	89 f8                	mov    %edi,%eax
f01025f1:	e8 d0 e4 ff ff       	call   f0100ac6 <check_va2pa>
f01025f6:	85 c0                	test   %eax,%eax
f01025f8:	74 19                	je     f0102613 <mem_init+0x117f>
f01025fa:	68 44 78 10 f0       	push   $0xf0107844
f01025ff:	68 94 7b 10 f0       	push   $0xf0107b94
f0102604:	68 77 04 00 00       	push   $0x477
f0102609:	68 51 7b 10 f0       	push   $0xf0107b51
f010260e:	e8 2d da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102613:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102619:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010261c:	89 c2                	mov    %eax,%edx
f010261e:	89 f8                	mov    %edi,%eax
f0102620:	e8 a1 e4 ff ff       	call   f0100ac6 <check_va2pa>
f0102625:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010262a:	74 19                	je     f0102645 <mem_init+0x11b1>
f010262c:	68 68 78 10 f0       	push   $0xf0107868
f0102631:	68 94 7b 10 f0       	push   $0xf0107b94
f0102636:	68 78 04 00 00       	push   $0x478
f010263b:	68 51 7b 10 f0       	push   $0xf0107b51
f0102640:	e8 fb d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102645:	89 f2                	mov    %esi,%edx
f0102647:	89 f8                	mov    %edi,%eax
f0102649:	e8 78 e4 ff ff       	call   f0100ac6 <check_va2pa>
f010264e:	85 c0                	test   %eax,%eax
f0102650:	74 19                	je     f010266b <mem_init+0x11d7>
f0102652:	68 98 78 10 f0       	push   $0xf0107898
f0102657:	68 94 7b 10 f0       	push   $0xf0107b94
f010265c:	68 79 04 00 00       	push   $0x479
f0102661:	68 51 7b 10 f0       	push   $0xf0107b51
f0102666:	e8 d5 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f010266b:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102671:	89 f8                	mov    %edi,%eax
f0102673:	e8 4e e4 ff ff       	call   f0100ac6 <check_va2pa>
f0102678:	83 f8 ff             	cmp    $0xffffffff,%eax
f010267b:	74 19                	je     f0102696 <mem_init+0x1202>
f010267d:	68 bc 78 10 f0       	push   $0xf01078bc
f0102682:	68 94 7b 10 f0       	push   $0xf0107b94
f0102687:	68 7a 04 00 00       	push   $0x47a
f010268c:	68 51 7b 10 f0       	push   $0xf0107b51
f0102691:	e8 aa d9 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102696:	83 ec 04             	sub    $0x4,%esp
f0102699:	6a 00                	push   $0x0
f010269b:	53                   	push   %ebx
f010269c:	57                   	push   %edi
f010269d:	e8 20 ea ff ff       	call   f01010c2 <pgdir_walk>
f01026a2:	83 c4 10             	add    $0x10,%esp
f01026a5:	f6 00 1a             	testb  $0x1a,(%eax)
f01026a8:	75 19                	jne    f01026c3 <mem_init+0x122f>
f01026aa:	68 e8 78 10 f0       	push   $0xf01078e8
f01026af:	68 94 7b 10 f0       	push   $0xf0107b94
f01026b4:	68 7c 04 00 00       	push   $0x47c
f01026b9:	68 51 7b 10 f0       	push   $0xf0107b51
f01026be:	e8 7d d9 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01026c3:	83 ec 04             	sub    $0x4,%esp
f01026c6:	6a 00                	push   $0x0
f01026c8:	53                   	push   %ebx
f01026c9:	ff 35 8c fe 21 f0    	pushl  0xf021fe8c
f01026cf:	e8 ee e9 ff ff       	call   f01010c2 <pgdir_walk>
f01026d4:	8b 00                	mov    (%eax),%eax
f01026d6:	83 c4 10             	add    $0x10,%esp
f01026d9:	83 e0 04             	and    $0x4,%eax
f01026dc:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01026df:	74 19                	je     f01026fa <mem_init+0x1266>
f01026e1:	68 2c 79 10 f0       	push   $0xf010792c
f01026e6:	68 94 7b 10 f0       	push   $0xf0107b94
f01026eb:	68 7d 04 00 00       	push   $0x47d
f01026f0:	68 51 7b 10 f0       	push   $0xf0107b51
f01026f5:	e8 46 d9 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01026fa:	83 ec 04             	sub    $0x4,%esp
f01026fd:	6a 00                	push   $0x0
f01026ff:	53                   	push   %ebx
f0102700:	ff 35 8c fe 21 f0    	pushl  0xf021fe8c
f0102706:	e8 b7 e9 ff ff       	call   f01010c2 <pgdir_walk>
f010270b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102711:	83 c4 0c             	add    $0xc,%esp
f0102714:	6a 00                	push   $0x0
f0102716:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102719:	ff 35 8c fe 21 f0    	pushl  0xf021fe8c
f010271f:	e8 9e e9 ff ff       	call   f01010c2 <pgdir_walk>
f0102724:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f010272a:	83 c4 0c             	add    $0xc,%esp
f010272d:	6a 00                	push   $0x0
f010272f:	56                   	push   %esi
f0102730:	ff 35 8c fe 21 f0    	pushl  0xf021fe8c
f0102736:	e8 87 e9 ff ff       	call   f01010c2 <pgdir_walk>
f010273b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102741:	c7 04 24 71 7e 10 f0 	movl   $0xf0107e71,(%esp)
f0102748:	e8 93 16 00 00       	call   f0103de0 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir, UPAGES, ROUNDUP(pages_size, PGSIZE), PADDR(pages), PTE_U); 
f010274d:	a1 90 fe 21 f0       	mov    0xf021fe90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102752:	83 c4 10             	add    $0x10,%esp
f0102755:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010275a:	77 15                	ja     f0102771 <mem_init+0x12dd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010275c:	50                   	push   %eax
f010275d:	68 a8 6c 10 f0       	push   $0xf0106ca8
f0102762:	68 c9 00 00 00       	push   $0xc9
f0102767:	68 51 7b 10 f0       	push   $0xf0107b51
f010276c:	e8 cf d8 ff ff       	call   f0100040 <_panic>
f0102771:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0102774:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f010277a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102780:	83 ec 08             	sub    $0x8,%esp
f0102783:	6a 04                	push   $0x4
f0102785:	05 00 00 00 10       	add    $0x10000000,%eax
f010278a:	50                   	push   %eax
f010278b:	89 d9                	mov    %ebx,%ecx
f010278d:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102792:	a1 8c fe 21 f0       	mov    0xf021fe8c,%eax
f0102797:	e8 0e ea ff ff       	call   f01011aa <boot_map_region>
        boot_map_region(kern_pgdir, (uintptr_t) pages, ROUNDUP(pages_size, PGSIZE), PADDR(pages), PTE_W);
f010279c:	8b 15 90 fe 21 f0    	mov    0xf021fe90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027a2:	83 c4 10             	add    $0x10,%esp
f01027a5:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01027ab:	77 15                	ja     f01027c2 <mem_init+0x132e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027ad:	52                   	push   %edx
f01027ae:	68 a8 6c 10 f0       	push   $0xf0106ca8
f01027b3:	68 ca 00 00 00       	push   $0xca
f01027b8:	68 51 7b 10 f0       	push   $0xf0107b51
f01027bd:	e8 7e d8 ff ff       	call   f0100040 <_panic>
f01027c2:	83 ec 08             	sub    $0x8,%esp
f01027c5:	6a 02                	push   $0x2
f01027c7:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f01027cd:	50                   	push   %eax
f01027ce:	89 d9                	mov    %ebx,%ecx
f01027d0:	a1 8c fe 21 f0       	mov    0xf021fe8c,%eax
f01027d5:	e8 d0 e9 ff ff       	call   f01011aa <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
        boot_map_region(kern_pgdir, UENVS, ROUNDUP(envs_size, PGSIZE), PADDR(envs), PTE_U);
f01027da:	a1 4c f2 21 f0       	mov    0xf021f24c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027df:	83 c4 10             	add    $0x10,%esp
f01027e2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01027e7:	77 15                	ja     f01027fe <mem_init+0x136a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027e9:	50                   	push   %eax
f01027ea:	68 a8 6c 10 f0       	push   $0xf0106ca8
f01027ef:	68 d3 00 00 00       	push   $0xd3
f01027f4:	68 51 7b 10 f0       	push   $0xf0107b51
f01027f9:	e8 42 d8 ff ff       	call   f0100040 <_panic>
f01027fe:	83 ec 08             	sub    $0x8,%esp
f0102801:	6a 04                	push   $0x4
f0102803:	05 00 00 00 10       	add    $0x10000000,%eax
f0102808:	50                   	push   %eax
f0102809:	b9 00 60 03 00       	mov    $0x36000,%ecx
f010280e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102813:	a1 8c fe 21 f0       	mov    0xf021fe8c,%eax
f0102818:	e8 8d e9 ff ff       	call   f01011aa <boot_map_region>
        boot_map_region(kern_pgdir, (uintptr_t) envs, ROUNDUP(envs_size, PGSIZE), PADDR(pages), PTE_W);
f010281d:	a1 90 fe 21 f0       	mov    0xf021fe90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102822:	83 c4 10             	add    $0x10,%esp
f0102825:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010282a:	77 15                	ja     f0102841 <mem_init+0x13ad>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010282c:	50                   	push   %eax
f010282d:	68 a8 6c 10 f0       	push   $0xf0106ca8
f0102832:	68 d4 00 00 00       	push   $0xd4
f0102837:	68 51 7b 10 f0       	push   $0xf0107b51
f010283c:	e8 ff d7 ff ff       	call   f0100040 <_panic>
f0102841:	83 ec 08             	sub    $0x8,%esp
f0102844:	6a 02                	push   $0x2
f0102846:	05 00 00 00 10       	add    $0x10000000,%eax
f010284b:	50                   	push   %eax
f010284c:	b9 00 60 03 00       	mov    $0x36000,%ecx
f0102851:	8b 15 4c f2 21 f0    	mov    0xf021f24c,%edx
f0102857:	a1 8c fe 21 f0       	mov    0xf021fe8c,%eax
f010285c:	e8 49 e9 ff ff       	call   f01011aa <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102861:	83 c4 10             	add    $0x10,%esp
f0102864:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f0102869:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010286e:	77 15                	ja     f0102885 <mem_init+0x13f1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102870:	50                   	push   %eax
f0102871:	68 a8 6c 10 f0       	push   $0xf0106ca8
f0102876:	68 e1 00 00 00       	push   $0xe1
f010287b:	68 51 7b 10 f0       	push   $0xf0107b51
f0102880:	e8 bb d7 ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102885:	83 ec 08             	sub    $0x8,%esp
f0102888:	6a 02                	push   $0x2
f010288a:	68 00 80 11 00       	push   $0x118000
f010288f:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102894:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102899:	a1 8c fe 21 f0       	mov    0xf021fe8c,%eax
f010289e:	e8 07 e9 ff ff       	call   f01011aa <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir, KERNBASE, -KERNBASE, 0, PTE_W);
f01028a3:	83 c4 08             	add    $0x8,%esp
f01028a6:	6a 02                	push   $0x2
f01028a8:	6a 00                	push   $0x0
f01028aa:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01028af:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01028b4:	a1 8c fe 21 f0       	mov    0xf021fe8c,%eax
f01028b9:	e8 ec e8 ff ff       	call   f01011aa <boot_map_region>
f01028be:	c7 45 c4 00 10 22 f0 	movl   $0xf0221000,-0x3c(%ebp)
f01028c5:	83 c4 10             	add    $0x10,%esp
f01028c8:	bb 00 10 22 f0       	mov    $0xf0221000,%ebx
f01028cd:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028d2:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01028d8:	77 15                	ja     f01028ef <mem_init+0x145b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028da:	53                   	push   %ebx
f01028db:	68 a8 6c 10 f0       	push   $0xf0106ca8
f01028e0:	68 22 01 00 00       	push   $0x122
f01028e5:	68 51 7b 10 f0       	push   $0xf0107b51
f01028ea:	e8 51 d7 ff ff       	call   f0100040 <_panic>
	//
	// LAB 4: Your code here:
        size_t i;
        for (i = 0; i < NCPU; i++) {
                uintptr_t kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
                boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);
f01028ef:	83 ec 08             	sub    $0x8,%esp
f01028f2:	6a 02                	push   $0x2
f01028f4:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f01028fa:	50                   	push   %eax
f01028fb:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102900:	89 f2                	mov    %esi,%edx
f0102902:	a1 8c fe 21 f0       	mov    0xf021fe8c,%eax
f0102907:	e8 9e e8 ff ff       	call   f01011aa <boot_map_region>
f010290c:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102912:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
        size_t i;
        for (i = 0; i < NCPU; i++) {
f0102918:	83 c4 10             	add    $0x10,%esp
f010291b:	b8 00 10 26 f0       	mov    $0xf0261000,%eax
f0102920:	39 d8                	cmp    %ebx,%eax
f0102922:	75 ae                	jne    f01028d2 <mem_init+0x143e>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102924:	8b 3d 8c fe 21 f0    	mov    0xf021fe8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010292a:	a1 88 fe 21 f0       	mov    0xf021fe88,%eax
f010292f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102932:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102939:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010293e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102941:	8b 35 90 fe 21 f0    	mov    0xf021fe90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102947:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010294a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010294f:	eb 55                	jmp    f01029a6 <mem_init+0x1512>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102951:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102957:	89 f8                	mov    %edi,%eax
f0102959:	e8 68 e1 ff ff       	call   f0100ac6 <check_va2pa>
f010295e:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102965:	77 15                	ja     f010297c <mem_init+0x14e8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102967:	56                   	push   %esi
f0102968:	68 a8 6c 10 f0       	push   $0xf0106ca8
f010296d:	68 94 03 00 00       	push   $0x394
f0102972:	68 51 7b 10 f0       	push   $0xf0107b51
f0102977:	e8 c4 d6 ff ff       	call   f0100040 <_panic>
f010297c:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f0102983:	39 c2                	cmp    %eax,%edx
f0102985:	74 19                	je     f01029a0 <mem_init+0x150c>
f0102987:	68 60 79 10 f0       	push   $0xf0107960
f010298c:	68 94 7b 10 f0       	push   $0xf0107b94
f0102991:	68 94 03 00 00       	push   $0x394
f0102996:	68 51 7b 10 f0       	push   $0xf0107b51
f010299b:	e8 a0 d6 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01029a0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01029a6:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01029a9:	77 a6                	ja     f0102951 <mem_init+0x14bd>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01029ab:	8b 35 4c f2 21 f0    	mov    0xf021f24c,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029b1:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01029b4:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01029b9:	89 da                	mov    %ebx,%edx
f01029bb:	89 f8                	mov    %edi,%eax
f01029bd:	e8 04 e1 ff ff       	call   f0100ac6 <check_va2pa>
f01029c2:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f01029c9:	77 15                	ja     f01029e0 <mem_init+0x154c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029cb:	56                   	push   %esi
f01029cc:	68 a8 6c 10 f0       	push   $0xf0106ca8
f01029d1:	68 99 03 00 00       	push   $0x399
f01029d6:	68 51 7b 10 f0       	push   $0xf0107b51
f01029db:	e8 60 d6 ff ff       	call   f0100040 <_panic>
f01029e0:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f01029e7:	39 d0                	cmp    %edx,%eax
f01029e9:	74 19                	je     f0102a04 <mem_init+0x1570>
f01029eb:	68 94 79 10 f0       	push   $0xf0107994
f01029f0:	68 94 7b 10 f0       	push   $0xf0107b94
f01029f5:	68 99 03 00 00       	push   $0x399
f01029fa:	68 51 7b 10 f0       	push   $0xf0107b51
f01029ff:	e8 3c d6 ff ff       	call   f0100040 <_panic>
f0102a04:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102a0a:	81 fb 00 60 c3 ee    	cmp    $0xeec36000,%ebx
f0102a10:	75 a7                	jne    f01029b9 <mem_init+0x1525>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102a12:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102a15:	c1 e6 0c             	shl    $0xc,%esi
f0102a18:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102a1d:	eb 30                	jmp    f0102a4f <mem_init+0x15bb>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102a1f:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102a25:	89 f8                	mov    %edi,%eax
f0102a27:	e8 9a e0 ff ff       	call   f0100ac6 <check_va2pa>
f0102a2c:	39 c3                	cmp    %eax,%ebx
f0102a2e:	74 19                	je     f0102a49 <mem_init+0x15b5>
f0102a30:	68 c8 79 10 f0       	push   $0xf01079c8
f0102a35:	68 94 7b 10 f0       	push   $0xf0107b94
f0102a3a:	68 9d 03 00 00       	push   $0x39d
f0102a3f:	68 51 7b 10 f0       	push   $0xf0107b51
f0102a44:	e8 f7 d5 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102a49:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a4f:	39 f3                	cmp    %esi,%ebx
f0102a51:	72 cc                	jb     f0102a1f <mem_init+0x158b>
f0102a53:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102a58:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102a5b:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102a5e:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102a61:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f0102a67:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102a6a:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102a6c:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102a6f:	05 00 80 00 20       	add    $0x20008000,%eax
f0102a74:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102a77:	89 da                	mov    %ebx,%edx
f0102a79:	89 f8                	mov    %edi,%eax
f0102a7b:	e8 46 e0 ff ff       	call   f0100ac6 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a80:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102a86:	77 15                	ja     f0102a9d <mem_init+0x1609>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a88:	56                   	push   %esi
f0102a89:	68 a8 6c 10 f0       	push   $0xf0106ca8
f0102a8e:	68 a5 03 00 00       	push   $0x3a5
f0102a93:	68 51 7b 10 f0       	push   $0xf0107b51
f0102a98:	e8 a3 d5 ff ff       	call   f0100040 <_panic>
f0102a9d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102aa0:	8d 94 0b 00 10 22 f0 	lea    -0xfddf000(%ebx,%ecx,1),%edx
f0102aa7:	39 d0                	cmp    %edx,%eax
f0102aa9:	74 19                	je     f0102ac4 <mem_init+0x1630>
f0102aab:	68 f0 79 10 f0       	push   $0xf01079f0
f0102ab0:	68 94 7b 10 f0       	push   $0xf0107b94
f0102ab5:	68 a5 03 00 00       	push   $0x3a5
f0102aba:	68 51 7b 10 f0       	push   $0xf0107b51
f0102abf:	e8 7c d5 ff ff       	call   f0100040 <_panic>
f0102ac4:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102aca:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0102acd:	75 a8                	jne    f0102a77 <mem_init+0x15e3>
f0102acf:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102ad2:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f0102ad8:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102adb:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102add:	89 da                	mov    %ebx,%edx
f0102adf:	89 f8                	mov    %edi,%eax
f0102ae1:	e8 e0 df ff ff       	call   f0100ac6 <check_va2pa>
f0102ae6:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102ae9:	74 19                	je     f0102b04 <mem_init+0x1670>
f0102aeb:	68 38 7a 10 f0       	push   $0xf0107a38
f0102af0:	68 94 7b 10 f0       	push   $0xf0107b94
f0102af5:	68 a7 03 00 00       	push   $0x3a7
f0102afa:	68 51 7b 10 f0       	push   $0xf0107b51
f0102aff:	e8 3c d5 ff ff       	call   f0100040 <_panic>
f0102b04:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102b0a:	39 f3                	cmp    %esi,%ebx
f0102b0c:	75 cf                	jne    f0102add <mem_init+0x1649>
f0102b0e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102b11:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102b18:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102b1f:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102b25:	b8 00 10 26 f0       	mov    $0xf0261000,%eax
f0102b2a:	39 f0                	cmp    %esi,%eax
f0102b2c:	0f 85 2c ff ff ff    	jne    f0102a5e <mem_init+0x15ca>
f0102b32:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b37:	eb 2a                	jmp    f0102b63 <mem_init+0x16cf>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102b39:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102b3f:	83 fa 04             	cmp    $0x4,%edx
f0102b42:	77 1f                	ja     f0102b63 <mem_init+0x16cf>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102b44:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102b48:	75 7e                	jne    f0102bc8 <mem_init+0x1734>
f0102b4a:	68 8a 7e 10 f0       	push   $0xf0107e8a
f0102b4f:	68 94 7b 10 f0       	push   $0xf0107b94
f0102b54:	68 b2 03 00 00       	push   $0x3b2
f0102b59:	68 51 7b 10 f0       	push   $0xf0107b51
f0102b5e:	e8 dd d4 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102b63:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102b68:	76 3f                	jbe    f0102ba9 <mem_init+0x1715>
				assert(pgdir[i] & PTE_P);
f0102b6a:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102b6d:	f6 c2 01             	test   $0x1,%dl
f0102b70:	75 19                	jne    f0102b8b <mem_init+0x16f7>
f0102b72:	68 8a 7e 10 f0       	push   $0xf0107e8a
f0102b77:	68 94 7b 10 f0       	push   $0xf0107b94
f0102b7c:	68 b6 03 00 00       	push   $0x3b6
f0102b81:	68 51 7b 10 f0       	push   $0xf0107b51
f0102b86:	e8 b5 d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102b8b:	f6 c2 02             	test   $0x2,%dl
f0102b8e:	75 38                	jne    f0102bc8 <mem_init+0x1734>
f0102b90:	68 9b 7e 10 f0       	push   $0xf0107e9b
f0102b95:	68 94 7b 10 f0       	push   $0xf0107b94
f0102b9a:	68 b7 03 00 00       	push   $0x3b7
f0102b9f:	68 51 7b 10 f0       	push   $0xf0107b51
f0102ba4:	e8 97 d4 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102ba9:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102bad:	74 19                	je     f0102bc8 <mem_init+0x1734>
f0102baf:	68 ac 7e 10 f0       	push   $0xf0107eac
f0102bb4:	68 94 7b 10 f0       	push   $0xf0107b94
f0102bb9:	68 b9 03 00 00       	push   $0x3b9
f0102bbe:	68 51 7b 10 f0       	push   $0xf0107b51
f0102bc3:	e8 78 d4 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102bc8:	83 c0 01             	add    $0x1,%eax
f0102bcb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102bd0:	0f 86 63 ff ff ff    	jbe    f0102b39 <mem_init+0x16a5>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102bd6:	83 ec 0c             	sub    $0xc,%esp
f0102bd9:	68 5c 7a 10 f0       	push   $0xf0107a5c
f0102bde:	e8 fd 11 00 00       	call   f0103de0 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102be3:	a1 8c fe 21 f0       	mov    0xf021fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102be8:	83 c4 10             	add    $0x10,%esp
f0102beb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102bf0:	77 15                	ja     f0102c07 <mem_init+0x1773>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bf2:	50                   	push   %eax
f0102bf3:	68 a8 6c 10 f0       	push   $0xf0106ca8
f0102bf8:	68 fa 00 00 00       	push   $0xfa
f0102bfd:	68 51 7b 10 f0       	push   $0xf0107b51
f0102c02:	e8 39 d4 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102c07:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c0c:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102c0f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c14:	e8 ab df ff ff       	call   f0100bc4 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102c19:	0f 20 c0             	mov    %cr0,%eax
f0102c1c:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102c1f:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102c24:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102c27:	83 ec 0c             	sub    $0xc,%esp
f0102c2a:	6a 00                	push   $0x0
f0102c2c:	e8 8b e3 ff ff       	call   f0100fbc <page_alloc>
f0102c31:	89 c3                	mov    %eax,%ebx
f0102c33:	83 c4 10             	add    $0x10,%esp
f0102c36:	85 c0                	test   %eax,%eax
f0102c38:	75 19                	jne    f0102c53 <mem_init+0x17bf>
f0102c3a:	68 96 7c 10 f0       	push   $0xf0107c96
f0102c3f:	68 94 7b 10 f0       	push   $0xf0107b94
f0102c44:	68 92 04 00 00       	push   $0x492
f0102c49:	68 51 7b 10 f0       	push   $0xf0107b51
f0102c4e:	e8 ed d3 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102c53:	83 ec 0c             	sub    $0xc,%esp
f0102c56:	6a 00                	push   $0x0
f0102c58:	e8 5f e3 ff ff       	call   f0100fbc <page_alloc>
f0102c5d:	89 c7                	mov    %eax,%edi
f0102c5f:	83 c4 10             	add    $0x10,%esp
f0102c62:	85 c0                	test   %eax,%eax
f0102c64:	75 19                	jne    f0102c7f <mem_init+0x17eb>
f0102c66:	68 ac 7c 10 f0       	push   $0xf0107cac
f0102c6b:	68 94 7b 10 f0       	push   $0xf0107b94
f0102c70:	68 93 04 00 00       	push   $0x493
f0102c75:	68 51 7b 10 f0       	push   $0xf0107b51
f0102c7a:	e8 c1 d3 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102c7f:	83 ec 0c             	sub    $0xc,%esp
f0102c82:	6a 00                	push   $0x0
f0102c84:	e8 33 e3 ff ff       	call   f0100fbc <page_alloc>
f0102c89:	89 c6                	mov    %eax,%esi
f0102c8b:	83 c4 10             	add    $0x10,%esp
f0102c8e:	85 c0                	test   %eax,%eax
f0102c90:	75 19                	jne    f0102cab <mem_init+0x1817>
f0102c92:	68 c2 7c 10 f0       	push   $0xf0107cc2
f0102c97:	68 94 7b 10 f0       	push   $0xf0107b94
f0102c9c:	68 94 04 00 00       	push   $0x494
f0102ca1:	68 51 7b 10 f0       	push   $0xf0107b51
f0102ca6:	e8 95 d3 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102cab:	83 ec 0c             	sub    $0xc,%esp
f0102cae:	53                   	push   %ebx
f0102caf:	e8 78 e3 ff ff       	call   f010102c <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102cb4:	89 f8                	mov    %edi,%eax
f0102cb6:	2b 05 90 fe 21 f0    	sub    0xf021fe90,%eax
f0102cbc:	c1 f8 03             	sar    $0x3,%eax
f0102cbf:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102cc2:	89 c2                	mov    %eax,%edx
f0102cc4:	c1 ea 0c             	shr    $0xc,%edx
f0102cc7:	83 c4 10             	add    $0x10,%esp
f0102cca:	3b 15 88 fe 21 f0    	cmp    0xf021fe88,%edx
f0102cd0:	72 12                	jb     f0102ce4 <mem_init+0x1850>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102cd2:	50                   	push   %eax
f0102cd3:	68 84 6c 10 f0       	push   $0xf0106c84
f0102cd8:	6a 58                	push   $0x58
f0102cda:	68 7a 7b 10 f0       	push   $0xf0107b7a
f0102cdf:	e8 5c d3 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102ce4:	83 ec 04             	sub    $0x4,%esp
f0102ce7:	68 00 10 00 00       	push   $0x1000
f0102cec:	6a 01                	push   $0x1
f0102cee:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102cf3:	50                   	push   %eax
f0102cf4:	e8 ae 32 00 00       	call   f0105fa7 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102cf9:	89 f0                	mov    %esi,%eax
f0102cfb:	2b 05 90 fe 21 f0    	sub    0xf021fe90,%eax
f0102d01:	c1 f8 03             	sar    $0x3,%eax
f0102d04:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d07:	89 c2                	mov    %eax,%edx
f0102d09:	c1 ea 0c             	shr    $0xc,%edx
f0102d0c:	83 c4 10             	add    $0x10,%esp
f0102d0f:	3b 15 88 fe 21 f0    	cmp    0xf021fe88,%edx
f0102d15:	72 12                	jb     f0102d29 <mem_init+0x1895>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d17:	50                   	push   %eax
f0102d18:	68 84 6c 10 f0       	push   $0xf0106c84
f0102d1d:	6a 58                	push   $0x58
f0102d1f:	68 7a 7b 10 f0       	push   $0xf0107b7a
f0102d24:	e8 17 d3 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102d29:	83 ec 04             	sub    $0x4,%esp
f0102d2c:	68 00 10 00 00       	push   $0x1000
f0102d31:	6a 02                	push   $0x2
f0102d33:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102d38:	50                   	push   %eax
f0102d39:	e8 69 32 00 00       	call   f0105fa7 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102d3e:	6a 02                	push   $0x2
f0102d40:	68 00 10 00 00       	push   $0x1000
f0102d45:	57                   	push   %edi
f0102d46:	ff 35 8c fe 21 f0    	pushl  0xf021fe8c
f0102d4c:	e8 1c e6 ff ff       	call   f010136d <page_insert>
	assert(pp1->pp_ref == 1);
f0102d51:	83 c4 20             	add    $0x20,%esp
f0102d54:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102d59:	74 19                	je     f0102d74 <mem_init+0x18e0>
f0102d5b:	68 93 7d 10 f0       	push   $0xf0107d93
f0102d60:	68 94 7b 10 f0       	push   $0xf0107b94
f0102d65:	68 99 04 00 00       	push   $0x499
f0102d6a:	68 51 7b 10 f0       	push   $0xf0107b51
f0102d6f:	e8 cc d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102d74:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102d7b:	01 01 01 
f0102d7e:	74 19                	je     f0102d99 <mem_init+0x1905>
f0102d80:	68 7c 7a 10 f0       	push   $0xf0107a7c
f0102d85:	68 94 7b 10 f0       	push   $0xf0107b94
f0102d8a:	68 9a 04 00 00       	push   $0x49a
f0102d8f:	68 51 7b 10 f0       	push   $0xf0107b51
f0102d94:	e8 a7 d2 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102d99:	6a 02                	push   $0x2
f0102d9b:	68 00 10 00 00       	push   $0x1000
f0102da0:	56                   	push   %esi
f0102da1:	ff 35 8c fe 21 f0    	pushl  0xf021fe8c
f0102da7:	e8 c1 e5 ff ff       	call   f010136d <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102dac:	83 c4 10             	add    $0x10,%esp
f0102daf:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102db6:	02 02 02 
f0102db9:	74 19                	je     f0102dd4 <mem_init+0x1940>
f0102dbb:	68 a0 7a 10 f0       	push   $0xf0107aa0
f0102dc0:	68 94 7b 10 f0       	push   $0xf0107b94
f0102dc5:	68 9c 04 00 00       	push   $0x49c
f0102dca:	68 51 7b 10 f0       	push   $0xf0107b51
f0102dcf:	e8 6c d2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102dd4:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102dd9:	74 19                	je     f0102df4 <mem_init+0x1960>
f0102ddb:	68 b5 7d 10 f0       	push   $0xf0107db5
f0102de0:	68 94 7b 10 f0       	push   $0xf0107b94
f0102de5:	68 9d 04 00 00       	push   $0x49d
f0102dea:	68 51 7b 10 f0       	push   $0xf0107b51
f0102def:	e8 4c d2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102df4:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102df9:	74 19                	je     f0102e14 <mem_init+0x1980>
f0102dfb:	68 1f 7e 10 f0       	push   $0xf0107e1f
f0102e00:	68 94 7b 10 f0       	push   $0xf0107b94
f0102e05:	68 9e 04 00 00       	push   $0x49e
f0102e0a:	68 51 7b 10 f0       	push   $0xf0107b51
f0102e0f:	e8 2c d2 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102e14:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102e1b:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102e1e:	89 f0                	mov    %esi,%eax
f0102e20:	2b 05 90 fe 21 f0    	sub    0xf021fe90,%eax
f0102e26:	c1 f8 03             	sar    $0x3,%eax
f0102e29:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e2c:	89 c2                	mov    %eax,%edx
f0102e2e:	c1 ea 0c             	shr    $0xc,%edx
f0102e31:	3b 15 88 fe 21 f0    	cmp    0xf021fe88,%edx
f0102e37:	72 12                	jb     f0102e4b <mem_init+0x19b7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e39:	50                   	push   %eax
f0102e3a:	68 84 6c 10 f0       	push   $0xf0106c84
f0102e3f:	6a 58                	push   $0x58
f0102e41:	68 7a 7b 10 f0       	push   $0xf0107b7a
f0102e46:	e8 f5 d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e4b:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102e52:	03 03 03 
f0102e55:	74 19                	je     f0102e70 <mem_init+0x19dc>
f0102e57:	68 c4 7a 10 f0       	push   $0xf0107ac4
f0102e5c:	68 94 7b 10 f0       	push   $0xf0107b94
f0102e61:	68 a0 04 00 00       	push   $0x4a0
f0102e66:	68 51 7b 10 f0       	push   $0xf0107b51
f0102e6b:	e8 d0 d1 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102e70:	83 ec 08             	sub    $0x8,%esp
f0102e73:	68 00 10 00 00       	push   $0x1000
f0102e78:	ff 35 8c fe 21 f0    	pushl  0xf021fe8c
f0102e7e:	e8 7c e4 ff ff       	call   f01012ff <page_remove>
	assert(pp2->pp_ref == 0);
f0102e83:	83 c4 10             	add    $0x10,%esp
f0102e86:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102e8b:	74 19                	je     f0102ea6 <mem_init+0x1a12>
f0102e8d:	68 ed 7d 10 f0       	push   $0xf0107ded
f0102e92:	68 94 7b 10 f0       	push   $0xf0107b94
f0102e97:	68 a2 04 00 00       	push   $0x4a2
f0102e9c:	68 51 7b 10 f0       	push   $0xf0107b51
f0102ea1:	e8 9a d1 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ea6:	8b 0d 8c fe 21 f0    	mov    0xf021fe8c,%ecx
f0102eac:	8b 11                	mov    (%ecx),%edx
f0102eae:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102eb4:	89 d8                	mov    %ebx,%eax
f0102eb6:	2b 05 90 fe 21 f0    	sub    0xf021fe90,%eax
f0102ebc:	c1 f8 03             	sar    $0x3,%eax
f0102ebf:	c1 e0 0c             	shl    $0xc,%eax
f0102ec2:	39 c2                	cmp    %eax,%edx
f0102ec4:	74 19                	je     f0102edf <mem_init+0x1a4b>
f0102ec6:	68 4c 74 10 f0       	push   $0xf010744c
f0102ecb:	68 94 7b 10 f0       	push   $0xf0107b94
f0102ed0:	68 a5 04 00 00       	push   $0x4a5
f0102ed5:	68 51 7b 10 f0       	push   $0xf0107b51
f0102eda:	e8 61 d1 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102edf:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102ee5:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102eea:	74 19                	je     f0102f05 <mem_init+0x1a71>
f0102eec:	68 a4 7d 10 f0       	push   $0xf0107da4
f0102ef1:	68 94 7b 10 f0       	push   $0xf0107b94
f0102ef6:	68 a7 04 00 00       	push   $0x4a7
f0102efb:	68 51 7b 10 f0       	push   $0xf0107b51
f0102f00:	e8 3b d1 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102f05:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102f0b:	83 ec 0c             	sub    $0xc,%esp
f0102f0e:	53                   	push   %ebx
f0102f0f:	e8 18 e1 ff ff       	call   f010102c <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102f14:	c7 04 24 f0 7a 10 f0 	movl   $0xf0107af0,(%esp)
f0102f1b:	e8 c0 0e 00 00       	call   f0103de0 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102f20:	83 c4 10             	add    $0x10,%esp
f0102f23:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f26:	5b                   	pop    %ebx
f0102f27:	5e                   	pop    %esi
f0102f28:	5f                   	pop    %edi
f0102f29:	5d                   	pop    %ebp
f0102f2a:	c3                   	ret    

f0102f2b <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102f2b:	55                   	push   %ebp
f0102f2c:	89 e5                	mov    %esp,%ebp
f0102f2e:	57                   	push   %edi
f0102f2f:	56                   	push   %esi
f0102f30:	53                   	push   %ebx
f0102f31:	83 ec 1c             	sub    $0x1c,%esp
f0102f34:	8b 7d 08             	mov    0x8(%ebp),%edi
        uintptr_t start_va = ROUNDDOWN((uintptr_t) va, PGSIZE);
f0102f37:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f3a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102f3f:	89 c1                	mov    %eax,%ecx
f0102f41:	89 45 e0             	mov    %eax,-0x20(%ebp)
        uintptr_t end_va = start_va + ROUNDUP(len, PGSIZE);        
f0102f44:	8b 45 10             	mov    0x10(%ebp),%eax
f0102f47:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102f4c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102f51:	8d 04 08             	lea    (%eax,%ecx,1),%eax
f0102f54:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
        uintptr_t start_va = ROUNDDOWN((uintptr_t) va, PGSIZE);
f0102f57:	89 cb                	mov    %ecx,%ebx
                        goto user_mem_check_fault;

                if (start_va >= ULIM)
                        goto user_mem_check_fault;

                if ((*pte & (perm | PTE_P)) != (perm | PTE_P))
f0102f59:	8b 75 14             	mov    0x14(%ebp),%esi
f0102f5c:	83 ce 01             	or     $0x1,%esi
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
        uintptr_t start_va = ROUNDDOWN((uintptr_t) va, PGSIZE);
        uintptr_t end_va = start_va + ROUNDUP(len, PGSIZE);        

        while (start_va < end_va) {
f0102f5f:	eb 2e                	jmp    f0102f8f <user_mem_check+0x64>
                pte_t *pte = pgdir_walk(env->env_pgdir, (void *) start_va, 0);
f0102f61:	83 ec 04             	sub    $0x4,%esp
f0102f64:	6a 00                	push   $0x0
f0102f66:	53                   	push   %ebx
f0102f67:	ff b7 bc 00 00 00    	pushl  0xbc(%edi)
f0102f6d:	e8 50 e1 ff ff       	call   f01010c2 <pgdir_walk>
                // No entry for this va in the page table, so no, the env
                // can't access it
                if (pte == NULL)
                        goto user_mem_check_fault;

                if (start_va >= ULIM)
f0102f72:	83 c4 10             	add    $0x10,%esp
f0102f75:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102f7b:	77 1e                	ja     f0102f9b <user_mem_check+0x70>
f0102f7d:	85 c0                	test   %eax,%eax
f0102f7f:	74 1a                	je     f0102f9b <user_mem_check+0x70>
                        goto user_mem_check_fault;

                if ((*pte & (perm | PTE_P)) != (perm | PTE_P))
f0102f81:	89 f2                	mov    %esi,%edx
f0102f83:	23 10                	and    (%eax),%edx
f0102f85:	39 d6                	cmp    %edx,%esi
f0102f87:	75 12                	jne    f0102f9b <user_mem_check+0x70>
                        goto user_mem_check_fault;

                start_va += PGSIZE;
f0102f89:	81 c3 00 10 00 00    	add    $0x1000,%ebx
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
        uintptr_t start_va = ROUNDDOWN((uintptr_t) va, PGSIZE);
        uintptr_t end_va = start_va + ROUNDUP(len, PGSIZE);        

        while (start_va < end_va) {
f0102f8f:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102f92:	72 cd                	jb     f0102f61 <user_mem_check+0x36>
                        goto user_mem_check_fault;

                start_va += PGSIZE;
        }

	return 0;
f0102f94:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f99:	eb 12                	jmp    f0102fad <user_mem_check+0x82>
        //              [00001000] user_mem_check assertion failure for va 00000001
        //      2) make run-buggyhello2:
        //              [00001000] user_mem_check assertion failure for va 00803000
        //
        //              Note: the actual check here is for 00.0.000
        user_mem_check_addr = start_va == ROUNDDOWN((uintptr_t) va, PGSIZE) ? (uintptr_t) va : start_va;        
f0102f9b:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f0102f9e:	0f 44 5d 0c          	cmove  0xc(%ebp),%ebx
f0102fa2:	89 1d 3c f2 21 f0    	mov    %ebx,0xf021f23c
        return -E_FAULT;
f0102fa8:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f0102fad:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102fb0:	5b                   	pop    %ebx
f0102fb1:	5e                   	pop    %esi
f0102fb2:	5f                   	pop    %edi
f0102fb3:	5d                   	pop    %ebp
f0102fb4:	c3                   	ret    

f0102fb5 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102fb5:	55                   	push   %ebp
f0102fb6:	89 e5                	mov    %esp,%ebp
f0102fb8:	53                   	push   %ebx
f0102fb9:	83 ec 04             	sub    $0x4,%esp
f0102fbc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102fbf:	8b 45 14             	mov    0x14(%ebp),%eax
f0102fc2:	83 c8 04             	or     $0x4,%eax
f0102fc5:	50                   	push   %eax
f0102fc6:	ff 75 10             	pushl  0x10(%ebp)
f0102fc9:	ff 75 0c             	pushl  0xc(%ebp)
f0102fcc:	53                   	push   %ebx
f0102fcd:	e8 59 ff ff ff       	call   f0102f2b <user_mem_check>
f0102fd2:	83 c4 10             	add    $0x10,%esp
f0102fd5:	85 c0                	test   %eax,%eax
f0102fd7:	79 24                	jns    f0102ffd <user_mem_assert+0x48>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102fd9:	83 ec 04             	sub    $0x4,%esp
f0102fdc:	ff 35 3c f2 21 f0    	pushl  0xf021f23c
f0102fe2:	ff b3 a4 00 00 00    	pushl  0xa4(%ebx)
f0102fe8:	68 1c 7b 10 f0       	push   $0xf0107b1c
f0102fed:	e8 ee 0d 00 00       	call   f0103de0 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102ff2:	89 1c 24             	mov    %ebx,(%esp)
f0102ff5:	e8 05 08 00 00       	call   f01037ff <env_destroy>
f0102ffa:	83 c4 10             	add    $0x10,%esp
	}
}
f0102ffd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103000:	c9                   	leave  
f0103001:	c3                   	ret    

f0103002 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103002:	55                   	push   %ebp
f0103003:	89 e5                	mov    %esp,%ebp
f0103005:	57                   	push   %edi
f0103006:	56                   	push   %esi
f0103007:	53                   	push   %ebx
f0103008:	83 ec 0c             	sub    $0xc,%esp
f010300b:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
        uintptr_t rva = (uintptr_t) ROUNDDOWN(va, PGSIZE);
f010300d:	89 d3                	mov    %edx,%ebx
f010300f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        uintptr_t rva_end = (uintptr_t) ROUNDUP(va + len, PGSIZE);
f0103015:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f010301c:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi

        while (rva < rva_end) {
f0103022:	eb 5b                	jmp    f010307f <region_alloc+0x7d>
                struct PageInfo *page = page_alloc(0);
f0103024:	83 ec 0c             	sub    $0xc,%esp
f0103027:	6a 00                	push   $0x0
f0103029:	e8 8e df ff ff       	call   f0100fbc <page_alloc>
                if (page == NULL)
f010302e:	83 c4 10             	add    $0x10,%esp
f0103031:	85 c0                	test   %eax,%eax
f0103033:	75 17                	jne    f010304c <region_alloc+0x4a>
                        panic("region_alloc: couldn't allocate page");
f0103035:	83 ec 04             	sub    $0x4,%esp
f0103038:	68 bc 7e 10 f0       	push   $0xf0107ebc
f010303d:	68 5c 01 00 00       	push   $0x15c
f0103042:	68 69 80 10 f0       	push   $0xf0108069
f0103047:	e8 f4 cf ff ff       	call   f0100040 <_panic>

                if (page_insert(e->env_pgdir, page, (void *) rva, PTE_P | PTE_U | PTE_W) < 0)
f010304c:	6a 07                	push   $0x7
f010304e:	53                   	push   %ebx
f010304f:	50                   	push   %eax
f0103050:	ff b7 bc 00 00 00    	pushl  0xbc(%edi)
f0103056:	e8 12 e3 ff ff       	call   f010136d <page_insert>
f010305b:	83 c4 10             	add    $0x10,%esp
f010305e:	85 c0                	test   %eax,%eax
f0103060:	79 17                	jns    f0103079 <region_alloc+0x77>
                        panic("region_alloc: page couldn't be inserted");
f0103062:	83 ec 04             	sub    $0x4,%esp
f0103065:	68 e4 7e 10 f0       	push   $0xf0107ee4
f010306a:	68 5f 01 00 00       	push   $0x15f
f010306f:	68 69 80 10 f0       	push   $0xf0108069
f0103074:	e8 c7 cf ff ff       	call   f0100040 <_panic>

                rva += PGSIZE;
f0103079:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
        uintptr_t rva = (uintptr_t) ROUNDDOWN(va, PGSIZE);
        uintptr_t rva_end = (uintptr_t) ROUNDUP(va + len, PGSIZE);

        while (rva < rva_end) {
f010307f:	39 f3                	cmp    %esi,%ebx
f0103081:	72 a1                	jb     f0103024 <region_alloc+0x22>
                if (page_insert(e->env_pgdir, page, (void *) rva, PTE_P | PTE_U | PTE_W) < 0)
                        panic("region_alloc: page couldn't be inserted");

                rva += PGSIZE;
        }
}
f0103083:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103086:	5b                   	pop    %ebx
f0103087:	5e                   	pop    %esi
f0103088:	5f                   	pop    %edi
f0103089:	5d                   	pop    %ebp
f010308a:	c3                   	ret    

f010308b <stack_push>:
struct FreeStacks* thread_free_stacks = NULL; //free stacks for threads
static struct FreeStacks* free_stacks_stack;


void stack_push(uint32_t id)
{	
f010308b:	55                   	push   %ebp
f010308c:	89 e5                	mov    %esp,%ebp
f010308e:	8b 45 08             	mov    0x8(%ebp),%eax
	thread_free_stacks[id].next_stack = free_stacks_stack;
f0103091:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103094:	a1 48 f2 21 f0       	mov    0xf021f248,%eax
f0103099:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010309c:	8b 15 50 f2 21 f0    	mov    0xf021f250,%edx
f01030a2:	89 50 08             	mov    %edx,0x8(%eax)
        free_stacks_stack = &thread_free_stacks[id];
f01030a5:	a3 50 f2 21 f0       	mov    %eax,0xf021f250
}
f01030aa:	5d                   	pop    %ebp
f01030ab:	c3                   	ret    

f01030ac <stack_pop>:

struct FreeStacks* stack_pop()
{
f01030ac:	55                   	push   %ebp
f01030ad:	89 e5                	mov    %esp,%ebp
	struct FreeStacks* ret = free_stacks_stack;
f01030af:	a1 50 f2 21 f0       	mov    0xf021f250,%eax
	free_stacks_stack = free_stacks_stack->next_stack;
f01030b4:	8b 50 08             	mov    0x8(%eax),%edx
f01030b7:	89 15 50 f2 21 f0    	mov    %edx,0xf021f250
	
	return ret;
}
f01030bd:	5d                   	pop    %ebp
f01030be:	c3                   	ret    

f01030bf <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01030bf:	55                   	push   %ebp
f01030c0:	89 e5                	mov    %esp,%ebp
f01030c2:	56                   	push   %esi
f01030c3:	53                   	push   %ebx
f01030c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01030c7:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01030ca:	85 c0                	test   %eax,%eax
f01030cc:	75 1a                	jne    f01030e8 <envid2env+0x29>
		*env_store = curenv;
f01030ce:	e8 f7 34 00 00       	call   f01065ca <cpunum>
f01030d3:	6b c0 74             	imul   $0x74,%eax,%eax
f01030d6:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f01030dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01030df:	89 01                	mov    %eax,(%ecx)
		return 0;
f01030e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01030e6:	eb 7f                	jmp    f0103167 <envid2env+0xa8>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f01030e8:	89 c3                	mov    %eax,%ebx
f01030ea:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01030f0:	69 db d8 00 00 00    	imul   $0xd8,%ebx,%ebx
f01030f6:	03 1d 4c f2 21 f0    	add    0xf021f24c,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01030fc:	83 bb b0 00 00 00 00 	cmpl   $0x0,0xb0(%ebx)
f0103103:	74 08                	je     f010310d <envid2env+0x4e>
f0103105:	3b 83 a4 00 00 00    	cmp    0xa4(%ebx),%eax
f010310b:	74 10                	je     f010311d <envid2env+0x5e>
		*env_store = 0;
f010310d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103110:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103116:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010311b:	eb 4a                	jmp    f0103167 <envid2env+0xa8>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010311d:	84 d2                	test   %dl,%dl
f010311f:	74 3c                	je     f010315d <envid2env+0x9e>
f0103121:	e8 a4 34 00 00       	call   f01065ca <cpunum>
f0103126:	6b c0 74             	imul   $0x74,%eax,%eax
f0103129:	3b 98 28 00 22 f0    	cmp    -0xfddffd8(%eax),%ebx
f010312f:	74 2c                	je     f010315d <envid2env+0x9e>
f0103131:	8b b3 a8 00 00 00    	mov    0xa8(%ebx),%esi
f0103137:	e8 8e 34 00 00       	call   f01065ca <cpunum>
f010313c:	6b c0 74             	imul   $0x74,%eax,%eax
f010313f:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f0103145:	3b b0 a4 00 00 00    	cmp    0xa4(%eax),%esi
f010314b:	74 10                	je     f010315d <envid2env+0x9e>
		*env_store = 0;
f010314d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103150:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103156:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010315b:	eb 0a                	jmp    f0103167 <envid2env+0xa8>
	}

	*env_store = e;
f010315d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103160:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103162:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103167:	5b                   	pop    %ebx
f0103168:	5e                   	pop    %esi
f0103169:	5d                   	pop    %ebp
f010316a:	c3                   	ret    

f010316b <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f010316b:	55                   	push   %ebp
f010316c:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f010316e:	b8 20 23 12 f0       	mov    $0xf0122320,%eax
f0103173:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103176:	b8 23 00 00 00       	mov    $0x23,%eax
f010317b:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f010317d:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f010317f:	b8 10 00 00 00       	mov    $0x10,%eax
f0103184:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103186:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103188:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f010318a:	ea 91 31 10 f0 08 00 	ljmp   $0x8,$0xf0103191
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f0103191:	b8 00 00 00 00       	mov    $0x0,%eax
f0103196:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103199:	5d                   	pop    %ebp
f010319a:	c3                   	ret    

f010319b <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f010319b:	55                   	push   %ebp
f010319c:	89 e5                	mov    %esp,%ebp
f010319e:	56                   	push   %esi
f010319f:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
        int i;
        for (i = NENV - 1; i >= 0; i--) {
                envs[i].env_status = ENV_FREE;
f01031a0:	8b 35 4c f2 21 f0    	mov    0xf021f24c,%esi
f01031a6:	8b 15 54 f2 21 f0    	mov    0xf021f254,%edx
f01031ac:	8d 86 28 5f 03 00    	lea    0x35f28(%esi),%eax
f01031b2:	8d 9e 28 ff ff ff    	lea    -0xd8(%esi),%ebx
f01031b8:	89 c1                	mov    %eax,%ecx
f01031ba:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
f01031c1:	00 00 00 
                envs[i].env_id = 0;
f01031c4:	c7 80 a4 00 00 00 00 	movl   $0x0,0xa4(%eax)
f01031cb:	00 00 00 
                envs[i].env_link = env_free_list;
f01031ce:	89 90 a0 00 00 00    	mov    %edx,0xa0(%eax)
f01031d4:	2d d8 00 00 00       	sub    $0xd8,%eax
                env_free_list = &envs[i];
f01031d9:	89 ca                	mov    %ecx,%edx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
        int i;
        for (i = NENV - 1; i >= 0; i--) {
f01031db:	39 d8                	cmp    %ebx,%eax
f01031dd:	75 d9                	jne    f01031b8 <env_init+0x1d>
f01031df:	89 35 54 f2 21 f0    	mov    %esi,0xf021f254
f01031e5:	8b 1d 50 f2 21 f0    	mov    0xf021f250,%ebx
f01031eb:	b9 00 c0 bf ee       	mov    $0xeebfc000,%ecx
f01031f0:	b8 fe 03 00 00       	mov    $0x3fe,%eax
f01031f5:	8d 14 40             	lea    (%eax,%eax,2),%edx
	uintptr_t THRDSTACKTOP = ustacktop - PGSIZE - THRDSTKGAP;
	uintptr_t STACKADDR = THRDSTACKTOP;

	for (i = MAX_THREADS - 1; i >= 0 ; i--, STACKADDR -= (THRDSTKSIZE + THRDSTKGAP))
	{	
		thread_free_stacks[i].id = i;
f01031f8:	8b 35 48 f2 21 f0    	mov    0xf021f248,%esi
f01031fe:	89 04 96             	mov    %eax,(%esi,%edx,4)
		thread_free_stacks[i].addr = STACKADDR;
f0103201:	8b 35 48 f2 21 f0    	mov    0xf021f248,%esi
f0103207:	8d 14 96             	lea    (%esi,%edx,4),%edx
f010320a:	89 4a 04             	mov    %ecx,0x4(%edx)
		thread_free_stacks[i].next_stack = free_stacks_stack;
f010320d:	89 5a 08             	mov    %ebx,0x8(%edx)
	/*Lab 7: multithreading*/
	uintptr_t ustacktop = 0xeebfe000;
	uintptr_t THRDSTACKTOP = ustacktop - PGSIZE - THRDSTKGAP;
	uintptr_t STACKADDR = THRDSTACKTOP;

	for (i = MAX_THREADS - 1; i >= 0 ; i--, STACKADDR -= (THRDSTKSIZE + THRDSTKGAP))
f0103210:	83 e8 01             	sub    $0x1,%eax
f0103213:	81 e9 00 20 00 00    	sub    $0x2000,%ecx
	{	
		thread_free_stacks[i].id = i;
		thread_free_stacks[i].addr = STACKADDR;
		thread_free_stacks[i].next_stack = free_stacks_stack;
                free_stacks_stack = &thread_free_stacks[i];
f0103219:	89 d3                	mov    %edx,%ebx
	/*Lab 7: multithreading*/
	uintptr_t ustacktop = 0xeebfe000;
	uintptr_t THRDSTACKTOP = ustacktop - PGSIZE - THRDSTKGAP;
	uintptr_t STACKADDR = THRDSTACKTOP;

	for (i = MAX_THREADS - 1; i >= 0 ; i--, STACKADDR -= (THRDSTKSIZE + THRDSTKGAP))
f010321b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010321e:	75 d5                	jne    f01031f5 <env_init+0x5a>
f0103220:	89 15 50 f2 21 f0    	mov    %edx,0xf021f250
		thread_free_stacks[i].addr = STACKADDR;
		thread_free_stacks[i].next_stack = free_stacks_stack;
                free_stacks_stack = &thread_free_stacks[i];
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0103226:	e8 40 ff ff ff       	call   f010316b <env_init_percpu>
}
f010322b:	5b                   	pop    %ebx
f010322c:	5e                   	pop    %esi
f010322d:	5d                   	pop    %ebp
f010322e:	c3                   	ret    

f010322f <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f010322f:	55                   	push   %ebp
f0103230:	89 e5                	mov    %esp,%ebp
f0103232:	56                   	push   %esi
f0103233:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103234:	8b 1d 54 f2 21 f0    	mov    0xf021f254,%ebx
f010323a:	85 db                	test   %ebx,%ebx
f010323c:	0f 84 e3 01 00 00    	je     f0103425 <env_alloc+0x1f6>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103242:	83 ec 0c             	sub    $0xc,%esp
f0103245:	6a 01                	push   $0x1
f0103247:	e8 70 dd ff ff       	call   f0100fbc <page_alloc>
f010324c:	83 c4 10             	add    $0x10,%esp
f010324f:	85 c0                	test   %eax,%eax
f0103251:	0f 84 d5 01 00 00    	je     f010342c <env_alloc+0x1fd>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103257:	89 c2                	mov    %eax,%edx
f0103259:	2b 15 90 fe 21 f0    	sub    0xf021fe90,%edx
f010325f:	c1 fa 03             	sar    $0x3,%edx
f0103262:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103265:	89 d1                	mov    %edx,%ecx
f0103267:	c1 e9 0c             	shr    $0xc,%ecx
f010326a:	3b 0d 88 fe 21 f0    	cmp    0xf021fe88,%ecx
f0103270:	72 12                	jb     f0103284 <env_alloc+0x55>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103272:	52                   	push   %edx
f0103273:	68 84 6c 10 f0       	push   $0xf0106c84
f0103278:	6a 58                	push   $0x58
f010327a:	68 7a 7b 10 f0       	push   $0xf0107b7a
f010327f:	e8 bc cd ff ff       	call   f0100040 <_panic>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
        e->env_pgdir = (pde_t *) page2kva(p);
f0103284:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010328a:	89 93 bc 00 00 00    	mov    %edx,0xbc(%ebx)
        p->pp_ref++;
f0103290:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0103295:	b8 00 00 00 00       	mov    $0x0,%eax

        for (i = 0; i < PDX(UTOP); i++)
                e->env_pgdir[i] = 0;
f010329a:	8b 93 bc 00 00 00    	mov    0xbc(%ebx),%edx
f01032a0:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
f01032a7:	83 c0 04             	add    $0x4,%eax

	// LAB 3: Your code here.
        e->env_pgdir = (pde_t *) page2kva(p);
        p->pp_ref++;

        for (i = 0; i < PDX(UTOP); i++)
f01032aa:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01032af:	75 e9                	jne    f010329a <env_alloc+0x6b>
                e->env_pgdir[i] = 0;

        for (i = PDX(UTOP); i < NPDENTRIES; i++)
                e->env_pgdir[i] = kern_pgdir[i];
f01032b1:	8b 15 8c fe 21 f0    	mov    0xf021fe8c,%edx
f01032b7:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f01032ba:	8b 93 bc 00 00 00    	mov    0xbc(%ebx),%edx
f01032c0:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f01032c3:	83 c0 04             	add    $0x4,%eax
        p->pp_ref++;

        for (i = 0; i < PDX(UTOP); i++)
                e->env_pgdir[i] = 0;

        for (i = PDX(UTOP); i < NPDENTRIES; i++)
f01032c6:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01032cb:	75 e4                	jne    f01032b1 <env_alloc+0x82>
                e->env_pgdir[i] = kern_pgdir[i];

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01032cd:	8b 83 bc 00 00 00    	mov    0xbc(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032d3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032d8:	77 15                	ja     f01032ef <env_alloc+0xc0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032da:	50                   	push   %eax
f01032db:	68 a8 6c 10 f0       	push   $0xf0106ca8
f01032e0:	68 eb 00 00 00       	push   $0xeb
f01032e5:	68 69 80 10 f0       	push   $0xf0108069
f01032ea:	e8 51 cd ff ff       	call   f0100040 <_panic>
f01032ef:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01032f5:	83 ca 05             	or     $0x5,%edx
f01032f8:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01032fe:	8b 83 a4 00 00 00    	mov    0xa4(%ebx),%eax
f0103304:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103309:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f010330e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103313:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103316:	89 da                	mov    %ebx,%edx
f0103318:	2b 15 4c f2 21 f0    	sub    0xf021f24c,%edx
f010331e:	c1 fa 03             	sar    $0x3,%edx
f0103321:	69 d2 13 da 4b 68    	imul   $0x684bda13,%edx,%edx
f0103327:	09 d0                	or     %edx,%eax
f0103329:	89 83 a4 00 00 00    	mov    %eax,0xa4(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f010332f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103332:	89 83 a8 00 00 00    	mov    %eax,0xa8(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103338:	c7 83 ac 00 00 00 00 	movl   $0x0,0xac(%ebx)
f010333f:	00 00 00 
	e->env_status = ENV_RUNNABLE;
f0103342:	c7 83 b0 00 00 00 02 	movl   $0x2,0xb0(%ebx)
f0103349:	00 00 00 
	e->env_runs = 0;
f010334c:	c7 83 b4 00 00 00 00 	movl   $0x0,0xb4(%ebx)
f0103353:	00 00 00 

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103356:	83 ec 04             	sub    $0x4,%esp
f0103359:	6a 44                	push   $0x44
f010335b:	6a 00                	push   $0x0
f010335d:	8d 43 59             	lea    0x59(%ebx),%eax
f0103360:	50                   	push   %eax
f0103361:	e8 41 2c 00 00       	call   f0105fa7 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103366:	66 c7 43 7d 23 00    	movw   $0x23,0x7d(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010336c:	66 c7 43 79 23 00    	movw   $0x23,0x79(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103372:	66 c7 83 99 00 00 00 	movw   $0x23,0x99(%ebx)
f0103379:	23 00 
	e->env_tf.tf_esp = USTACKTOP;
f010337b:	c7 83 95 00 00 00 00 	movl   $0xeebfe000,0x95(%ebx)
f0103382:	e0 bf ee 
	e->env_tf.tf_cs = GD_UT | 3;
f0103385:	66 c7 83 8d 00 00 00 	movw   $0x1b,0x8d(%ebx)
f010338c:	1b 00 
	// You will set e->env_tf.tf_eip later.
	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
        e->env_tf.tf_eflags |= FL_IF;
f010338e:	81 8b 91 00 00 00 00 	orl    $0x200,0x91(%ebx)
f0103395:	02 00 00 

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103398:	c7 83 c0 00 00 00 00 	movl   $0x0,0xc0(%ebx)
f010339f:	00 00 00 

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01033a2:	c6 83 c4 00 00 00 00 	movb   $0x0,0xc4(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01033a9:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
f01033af:	a3 54 f2 21 f0       	mov    %eax,0xf021f254
	*newenv_store = e;
f01033b4:	8b 45 08             	mov    0x8(%ebp),%eax
f01033b7:	89 18                	mov    %ebx,(%eax)

	// Lab 7 multithreading
	// nastavme proces id ako env id, ak sa alokuje thread, prestavi si process id sam
	// zoznam workerov nastavime ako prazdny
	e->env_process_id = e->env_id;
f01033b9:	8b b3 a4 00 00 00    	mov    0xa4(%ebx),%esi
f01033bf:	89 33                	mov    %esi,(%ebx)
	e->env_waiting = false;
f01033c1:	c6 43 58 00          	movb   $0x0,0x58(%ebx)
f01033c5:	8d 43 08             	lea    0x8(%ebx),%eax
f01033c8:	83 c3 30             	add    $0x30,%ebx
f01033cb:	83 c4 10             	add    $0x10,%esp

	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++)
	{
		e->worker_threads[0][i] = 0;	
f01033ce:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		e->worker_threads[1][i] = 0;		
f01033d4:	c7 40 28 00 00 00 00 	movl   $0x0,0x28(%eax)
f01033db:	83 c0 04             	add    $0x4,%eax
	// zoznam workerov nastavime ako prazdny
	e->env_process_id = e->env_id;
	e->env_waiting = false;

	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++)
f01033de:	39 c3                	cmp    %eax,%ebx
f01033e0:	75 ec                	jne    f01033ce <env_alloc+0x19f>
	{
		e->worker_threads[0][i] = 0;	
		e->worker_threads[1][i] = 0;		
	}

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01033e2:	e8 e3 31 00 00       	call   f01065ca <cpunum>
f01033e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01033ea:	ba 00 00 00 00       	mov    $0x0,%edx
f01033ef:	83 b8 28 00 22 f0 00 	cmpl   $0x0,-0xfddffd8(%eax)
f01033f6:	74 14                	je     f010340c <env_alloc+0x1dd>
f01033f8:	e8 cd 31 00 00       	call   f01065ca <cpunum>
f01033fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0103400:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f0103406:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
f010340c:	83 ec 04             	sub    $0x4,%esp
f010340f:	56                   	push   %esi
f0103410:	52                   	push   %edx
f0103411:	68 74 80 10 f0       	push   $0xf0108074
f0103416:	e8 c5 09 00 00       	call   f0103de0 <cprintf>
	return 0;
f010341b:	83 c4 10             	add    $0x10,%esp
f010341e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103423:	eb 0c                	jmp    f0103431 <env_alloc+0x202>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103425:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010342a:	eb 05                	jmp    f0103431 <env_alloc+0x202>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f010342c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		e->worker_threads[1][i] = 0;		
	}

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103431:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103434:	5b                   	pop    %ebx
f0103435:	5e                   	pop    %esi
f0103436:	5d                   	pop    %ebp
f0103437:	c3                   	ret    

f0103438 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103438:	55                   	push   %ebp
f0103439:	89 e5                	mov    %esp,%ebp
f010343b:	57                   	push   %edi
f010343c:	56                   	push   %esi
f010343d:	53                   	push   %ebx
f010343e:	83 ec 34             	sub    $0x34,%esp
f0103441:	8b 75 08             	mov    0x8(%ebp),%esi
f0103444:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// LAB 3: Your code here.
        struct Env *env;
        int status = env_alloc(&env, 0);
f0103447:	6a 00                	push   $0x0
f0103449:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010344c:	50                   	push   %eax
f010344d:	e8 dd fd ff ff       	call   f010322f <env_alloc>
        if (status < 0)
f0103452:	83 c4 10             	add    $0x10,%esp
f0103455:	85 c0                	test   %eax,%eax
f0103457:	79 15                	jns    f010346e <env_create+0x36>
                panic("env_alloc: %e", status);
f0103459:	50                   	push   %eax
f010345a:	68 89 80 10 f0       	push   $0xf0108089
f010345f:	68 c9 01 00 00       	push   $0x1c9
f0103464:	68 69 80 10 f0       	push   $0xf0108069
f0103469:	e8 d2 cb ff ff       	call   f0100040 <_panic>

        // If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.        
        if (type == ENV_TYPE_FS) {
f010346e:	83 fb 01             	cmp    $0x1,%ebx
f0103471:	75 0d                	jne    f0103480 <env_create+0x48>
                env->env_tf.tf_eflags |= FL_IOPL_3;
f0103473:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103476:	81 88 91 00 00 00 00 	orl    $0x3000,0x91(%eax)
f010347d:	30 00 00 
        }

        env->env_type = type;
f0103480:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103483:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103486:	89 98 ac 00 00 00    	mov    %ebx,0xac(%eax)
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
        struct Elf *elf = (struct Elf *) binary;
        
        if (elf->e_magic != ELF_MAGIC)
f010348c:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f0103492:	74 17                	je     f01034ab <env_create+0x73>
                panic("load_icode: binary isn't elf (invalid magic)");
f0103494:	83 ec 04             	sub    $0x4,%esp
f0103497:	68 0c 7f 10 f0       	push   $0xf0107f0c
f010349c:	68 9e 01 00 00       	push   $0x19e
f01034a1:	68 69 80 10 f0       	push   $0xf0108069
f01034a6:	e8 95 cb ff ff       	call   f0100040 <_panic>
       
        // We could do a bunch more checks here (for e_phnum and such) but let's not.

        struct Proghdr *pht = (struct Proghdr *) (binary + elf->e_phoff); 
f01034ab:	89 f7                	mov    %esi,%edi
f01034ad:	03 7e 1c             	add    0x1c(%esi),%edi
     
        lcr3(PADDR(e->env_pgdir));
f01034b0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01034b3:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01034b9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034be:	77 15                	ja     f01034d5 <env_create+0x9d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034c0:	50                   	push   %eax
f01034c1:	68 a8 6c 10 f0       	push   $0xf0106ca8
f01034c6:	68 a4 01 00 00       	push   $0x1a4
f01034cb:	68 69 80 10 f0       	push   $0xf0108069
f01034d0:	e8 6b cb ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01034d5:	05 00 00 00 10       	add    $0x10000000,%eax
f01034da:	0f 22 d8             	mov    %eax,%cr3

        struct Proghdr *phdr;
        for (phdr = pht; phdr < pht + elf->e_phnum; phdr++) {
f01034dd:	89 fb                	mov    %edi,%ebx
f01034df:	eb 60                	jmp    f0103541 <env_create+0x109>
                if (phdr->p_type != ELF_PROG_LOAD)
f01034e1:	83 3b 01             	cmpl   $0x1,(%ebx)
f01034e4:	75 58                	jne    f010353e <env_create+0x106>
                        continue;

                if (phdr->p_filesz > phdr->p_memsz)
f01034e6:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01034e9:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f01034ec:	76 17                	jbe    f0103505 <env_create+0xcd>
                        panic("load_icode: segment filesz > memsz");
f01034ee:	83 ec 04             	sub    $0x4,%esp
f01034f1:	68 3c 7f 10 f0       	push   $0xf0107f3c
f01034f6:	68 ac 01 00 00       	push   $0x1ac
f01034fb:	68 69 80 10 f0       	push   $0xf0108069
f0103500:	e8 3b cb ff ff       	call   f0100040 <_panic>

                region_alloc(e, (void *) phdr->p_va, phdr->p_memsz);
f0103505:	8b 53 08             	mov    0x8(%ebx),%edx
f0103508:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010350b:	e8 f2 fa ff ff       	call   f0103002 <region_alloc>
                memcpy((void *) phdr->p_va, binary + phdr->p_offset, phdr->p_filesz); 
f0103510:	83 ec 04             	sub    $0x4,%esp
f0103513:	ff 73 10             	pushl  0x10(%ebx)
f0103516:	89 f0                	mov    %esi,%eax
f0103518:	03 43 04             	add    0x4(%ebx),%eax
f010351b:	50                   	push   %eax
f010351c:	ff 73 08             	pushl  0x8(%ebx)
f010351f:	e8 38 2b 00 00       	call   f010605c <memcpy>
                memset((void *) (phdr->p_va + phdr->p_filesz), 0, phdr->p_memsz - phdr->p_filesz);
f0103524:	8b 43 10             	mov    0x10(%ebx),%eax
f0103527:	83 c4 0c             	add    $0xc,%esp
f010352a:	8b 53 14             	mov    0x14(%ebx),%edx
f010352d:	29 c2                	sub    %eax,%edx
f010352f:	52                   	push   %edx
f0103530:	6a 00                	push   $0x0
f0103532:	03 43 08             	add    0x8(%ebx),%eax
f0103535:	50                   	push   %eax
f0103536:	e8 6c 2a 00 00       	call   f0105fa7 <memset>
f010353b:	83 c4 10             	add    $0x10,%esp
        struct Proghdr *pht = (struct Proghdr *) (binary + elf->e_phoff); 
     
        lcr3(PADDR(e->env_pgdir));

        struct Proghdr *phdr;
        for (phdr = pht; phdr < pht + elf->e_phnum; phdr++) {
f010353e:	83 c3 20             	add    $0x20,%ebx
f0103541:	0f b7 46 2c          	movzwl 0x2c(%esi),%eax
f0103545:	c1 e0 05             	shl    $0x5,%eax
f0103548:	01 f8                	add    %edi,%eax
f010354a:	39 c3                	cmp    %eax,%ebx
f010354c:	72 93                	jb     f01034e1 <env_create+0xa9>
                memset((void *) (phdr->p_va + phdr->p_filesz), 0, phdr->p_memsz - phdr->p_filesz);
        }

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
        region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f010354e:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103553:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103558:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010355b:	89 f8                	mov    %edi,%eax
f010355d:	e8 a0 fa ff ff       	call   f0103002 <region_alloc>

	// LAB 3: Your code here.
        e->env_tf.tf_eip = elf->e_entry;
f0103562:	8b 46 18             	mov    0x18(%esi),%eax
f0103565:	89 87 89 00 00 00    	mov    %eax,0x89(%edi)
                env->env_tf.tf_eflags |= FL_IOPL_3;
        }

        env->env_type = type;
        load_icode(env, binary);
}
f010356b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010356e:	5b                   	pop    %ebx
f010356f:	5e                   	pop    %esi
f0103570:	5f                   	pop    %edi
f0103571:	5d                   	pop    %ebp
f0103572:	c3                   	ret    

f0103573 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103573:	55                   	push   %ebp
f0103574:	89 e5                	mov    %esp,%ebp
f0103576:	57                   	push   %edi
f0103577:	56                   	push   %esi
f0103578:	53                   	push   %ebx
f0103579:	83 ec 1c             	sub    $0x1c,%esp
f010357c:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010357f:	e8 46 30 00 00       	call   f01065ca <cpunum>
f0103584:	6b c0 74             	imul   $0x74,%eax,%eax
f0103587:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010358e:	39 b8 28 00 22 f0    	cmp    %edi,-0xfddffd8(%eax)
f0103594:	75 30                	jne    f01035c6 <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f0103596:	a1 8c fe 21 f0       	mov    0xf021fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010359b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035a0:	77 15                	ja     f01035b7 <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035a2:	50                   	push   %eax
f01035a3:	68 a8 6c 10 f0       	push   $0xf0106ca8
f01035a8:	68 e3 01 00 00       	push   $0x1e3
f01035ad:	68 69 80 10 f0       	push   $0xf0108069
f01035b2:	e8 89 ca ff ff       	call   f0100040 <_panic>
f01035b7:	05 00 00 00 10       	add    $0x10000000,%eax
f01035bc:	0f 22 d8             	mov    %eax,%cr3
f01035bf:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01035c6:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01035c9:	89 d0                	mov    %edx,%eax
f01035cb:	c1 e0 02             	shl    $0x2,%eax
f01035ce:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01035d1:	8b 87 bc 00 00 00    	mov    0xbc(%edi),%eax
f01035d7:	8b 34 90             	mov    (%eax,%edx,4),%esi
f01035da:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01035e0:	0f 84 ae 00 00 00    	je     f0103694 <env_free+0x121>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01035e6:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01035ec:	89 f0                	mov    %esi,%eax
f01035ee:	c1 e8 0c             	shr    $0xc,%eax
f01035f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01035f4:	39 05 88 fe 21 f0    	cmp    %eax,0xf021fe88
f01035fa:	77 15                	ja     f0103611 <env_free+0x9e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01035fc:	56                   	push   %esi
f01035fd:	68 84 6c 10 f0       	push   $0xf0106c84
f0103602:	68 f2 01 00 00       	push   $0x1f2
f0103607:	68 69 80 10 f0       	push   $0xf0108069
f010360c:	e8 2f ca ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103611:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103614:	c1 e0 16             	shl    $0x16,%eax
f0103617:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010361a:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f010361f:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103626:	01 
f0103627:	74 1a                	je     f0103643 <env_free+0xd0>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103629:	83 ec 08             	sub    $0x8,%esp
f010362c:	89 d8                	mov    %ebx,%eax
f010362e:	c1 e0 0c             	shl    $0xc,%eax
f0103631:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103634:	50                   	push   %eax
f0103635:	ff b7 bc 00 00 00    	pushl  0xbc(%edi)
f010363b:	e8 bf dc ff ff       	call   f01012ff <page_remove>
f0103640:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103643:	83 c3 01             	add    $0x1,%ebx
f0103646:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010364c:	75 d1                	jne    f010361f <env_free+0xac>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010364e:	8b 87 bc 00 00 00    	mov    0xbc(%edi),%eax
f0103654:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103657:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010365e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103661:	3b 05 88 fe 21 f0    	cmp    0xf021fe88,%eax
f0103667:	72 14                	jb     f010367d <env_free+0x10a>
		panic("pa2page called with invalid pa");
f0103669:	83 ec 04             	sub    $0x4,%esp
f010366c:	68 f0 72 10 f0       	push   $0xf01072f0
f0103671:	6a 51                	push   $0x51
f0103673:	68 7a 7b 10 f0       	push   $0xf0107b7a
f0103678:	e8 c3 c9 ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f010367d:	83 ec 0c             	sub    $0xc,%esp
f0103680:	a1 90 fe 21 f0       	mov    0xf021fe90,%eax
f0103685:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103688:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f010368b:	50                   	push   %eax
f010368c:	e8 0a da ff ff       	call   f010109b <page_decref>
f0103691:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103694:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103698:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010369b:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f01036a0:	0f 85 20 ff ff ff    	jne    f01035c6 <env_free+0x53>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01036a6:	8b 87 bc 00 00 00    	mov    0xbc(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01036ac:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036b1:	77 15                	ja     f01036c8 <env_free+0x155>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036b3:	50                   	push   %eax
f01036b4:	68 a8 6c 10 f0       	push   $0xf0106ca8
f01036b9:	68 00 02 00 00       	push   $0x200
f01036be:	68 69 80 10 f0       	push   $0xf0108069
f01036c3:	e8 78 c9 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f01036c8:	c7 87 bc 00 00 00 00 	movl   $0x0,0xbc(%edi)
f01036cf:	00 00 00 
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01036d2:	05 00 00 00 10       	add    $0x10000000,%eax
f01036d7:	c1 e8 0c             	shr    $0xc,%eax
f01036da:	3b 05 88 fe 21 f0    	cmp    0xf021fe88,%eax
f01036e0:	72 14                	jb     f01036f6 <env_free+0x183>
		panic("pa2page called with invalid pa");
f01036e2:	83 ec 04             	sub    $0x4,%esp
f01036e5:	68 f0 72 10 f0       	push   $0xf01072f0
f01036ea:	6a 51                	push   $0x51
f01036ec:	68 7a 7b 10 f0       	push   $0xf0107b7a
f01036f1:	e8 4a c9 ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f01036f6:	83 ec 0c             	sub    $0xc,%esp
f01036f9:	8b 15 90 fe 21 f0    	mov    0xf021fe90,%edx
f01036ff:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103702:	50                   	push   %eax
f0103703:	e8 93 d9 ff ff       	call   f010109b <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103708:	c7 87 b0 00 00 00 00 	movl   $0x0,0xb0(%edi)
f010370f:	00 00 00 
	e->env_link = env_free_list;
f0103712:	a1 54 f2 21 f0       	mov    0xf021f254,%eax
f0103717:	89 87 a0 00 00 00    	mov    %eax,0xa0(%edi)
	env_free_list = e;
f010371d:	89 3d 54 f2 21 f0    	mov    %edi,0xf021f254
}
f0103723:	83 c4 10             	add    $0x10,%esp
f0103726:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103729:	5b                   	pop    %ebx
f010372a:	5e                   	pop    %esi
f010372b:	5f                   	pop    %edi
f010372c:	5d                   	pop    %ebp
f010372d:	c3                   	ret    

f010372e <thread_destroy>:
// pouzivane env_destroyom pre nicenie vsetkych worker threadov
// narozdiel od thread free neprechadza po poli v main threade a nenuluje pole wokrer
// threadov (je to zbytocne, kedze main thread sa ide znicit)
void
thread_destroy(struct Env *e)
{
f010372e:	55                   	push   %ebp
f010372f:	89 e5                	mov    %esp,%ebp
f0103731:	57                   	push   %edi
f0103732:	56                   	push   %esi
f0103733:	53                   	push   %ebx
f0103734:	83 ec 14             	sub    $0x14,%esp
f0103737:	8b 7d 08             	mov    0x8(%ebp),%edi
	cprintf("In thread destroy, thread: %d\n", e->env_id); 
f010373a:	ff b7 a4 00 00 00    	pushl  0xa4(%edi)
f0103740:	68 60 7f 10 f0       	push   $0xf0107f60
f0103745:	e8 96 06 00 00       	call   f0103de0 <cprintf>
	// hod jej esp adresu na zoznam volnych stackov pre thready
	stack_push(e->env_stack_id);
f010374a:	83 c4 04             	add    $0x4,%esp
f010374d:	ff 77 04             	pushl  0x4(%edi)
f0103750:	e8 36 f9 ff ff       	call   f010308b <stack_push>
	
	e->env_pgdir = 0;
f0103755:	c7 87 bc 00 00 00 00 	movl   $0x0,0xbc(%edi)
f010375c:	00 00 00 
	e->env_status = ENV_FREE;
f010375f:	c7 87 b0 00 00 00 00 	movl   $0x0,0xb0(%edi)
f0103766:	00 00 00 
	e->env_link = env_free_list;
f0103769:	a1 54 f2 21 f0       	mov    0xf021f254,%eax
f010376e:	89 87 a0 00 00 00    	mov    %eax,0xa0(%edi)
	env_free_list = e;
f0103774:	89 3d 54 f2 21 f0    	mov    %edi,0xf021f254
f010377a:	be 28 00 22 f0       	mov    $0xf0220028,%esi
f010377f:	83 c4 10             	add    $0x10,%esp

	/*prejdi vsetky cpu a vymaz z nich env ktory mazeme*/
	size_t i;
	for (i = 0; i < NCPU; i++) {
f0103782:	bb 00 00 00 00       	mov    $0x0,%ebx
		cprintf("in thread destroy: %d\n", i);
f0103787:	83 ec 08             	sub    $0x8,%esp
f010378a:	53                   	push   %ebx
f010378b:	68 97 80 10 f0       	push   $0xf0108097
f0103790:	e8 4b 06 00 00       	call   f0103de0 <cprintf>
		/*ak ma env*/cprintf("cpus[i] curenv: %x\n", cpus[i].cpu_env);
f0103795:	83 c4 08             	add    $0x8,%esp
f0103798:	ff 36                	pushl  (%esi)
f010379a:	68 ae 80 10 f0       	push   $0xf01080ae
f010379f:	e8 3c 06 00 00       	call   f0103de0 <cprintf>
		if ((cpus[i].cpu_env) && (cpus[i].cpu_env->env_id == e->env_id)) {
f01037a4:	8b 06                	mov    (%esi),%eax
f01037a6:	83 c4 10             	add    $0x10,%esp
f01037a9:	85 c0                	test   %eax,%eax
f01037ab:	74 18                	je     f01037c5 <thread_destroy+0x97>
f01037ad:	8b 97 a4 00 00 00    	mov    0xa4(%edi),%edx
f01037b3:	39 90 a4 00 00 00    	cmp    %edx,0xa4(%eax)
f01037b9:	75 0a                	jne    f01037c5 <thread_destroy+0x97>
			cpus[i].cpu_env->env_status = ENV_DYING;
f01037bb:	c7 80 b0 00 00 00 01 	movl   $0x1,0xb0(%eax)
f01037c2:	00 00 00 
	e->env_link = env_free_list;
	env_free_list = e;

	/*prejdi vsetky cpu a vymaz z nich env ktory mazeme*/
	size_t i;
	for (i = 0; i < NCPU; i++) {
f01037c5:	83 c3 01             	add    $0x1,%ebx
f01037c8:	83 c6 74             	add    $0x74,%esi
f01037cb:	83 fb 08             	cmp    $0x8,%ebx
f01037ce:	75 b7                	jne    f0103787 <thread_destroy+0x59>
			cpus[i].cpu_env->env_status = ENV_DYING;
		}
		
	}

	if (curenv == e) {
f01037d0:	e8 f5 2d 00 00       	call   f01065ca <cpunum>
f01037d5:	6b c0 74             	imul   $0x74,%eax,%eax
f01037d8:	3b b8 28 00 22 f0    	cmp    -0xfddffd8(%eax),%edi
f01037de:	75 17                	jne    f01037f7 <thread_destroy+0xc9>
		curenv = NULL;
f01037e0:	e8 e5 2d 00 00       	call   f01065ca <cpunum>
f01037e5:	6b c0 74             	imul   $0x74,%eax,%eax
f01037e8:	c7 80 28 00 22 f0 00 	movl   $0x0,-0xfddffd8(%eax)
f01037ef:	00 00 00 
		sched_yield();
f01037f2:	e8 af 14 00 00       	call   f0104ca6 <sched_yield>
	}
}
f01037f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01037fa:	5b                   	pop    %ebx
f01037fb:	5e                   	pop    %esi
f01037fc:	5f                   	pop    %edi
f01037fd:	5d                   	pop    %ebp
f01037fe:	c3                   	ret    

f01037ff <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01037ff:	55                   	push   %ebp
f0103800:	89 e5                	mov    %esp,%ebp
f0103802:	57                   	push   %edi
f0103803:	56                   	push   %esi
f0103804:	53                   	push   %ebx
f0103805:	83 ec 0c             	sub    $0xc,%esp
f0103808:	8b 7d 08             	mov    0x8(%ebp),%edi
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010380b:	83 bf b0 00 00 00 03 	cmpl   $0x3,0xb0(%edi)
f0103812:	75 1c                	jne    f0103830 <env_destroy+0x31>
f0103814:	e8 b1 2d 00 00       	call   f01065ca <cpunum>
f0103819:	6b c0 74             	imul   $0x74,%eax,%eax
f010381c:	3b b8 28 00 22 f0    	cmp    -0xfddffd8(%eax),%edi
f0103822:	74 0c                	je     f0103830 <env_destroy+0x31>
		e->env_status = ENV_DYING;
f0103824:	c7 87 b0 00 00 00 01 	movl   $0x1,0xb0(%edi)
f010382b:	00 00 00 
		return;
f010382e:	eb 79                	jmp    f01038a9 <env_destroy+0xaa>
	}
	cprintf("In env destroy, destroying env: %d\n", e->env_id); // for testing purposes
f0103830:	83 ec 08             	sub    $0x8,%esp
f0103833:	ff b7 a4 00 00 00    	pushl  0xa4(%edi)
f0103839:	68 80 7f 10 f0       	push   $0xf0107f80
f010383e:	e8 9d 05 00 00       	call   f0103de0 <cprintf>
f0103843:	8d 5f 08             	lea    0x8(%edi),%ebx
f0103846:	8d 77 30             	lea    0x30(%edi),%esi
f0103849:	83 c4 10             	add    $0x10,%esp
	/*prejdi cez pole worker threadov a znic ich*/
	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++)
	{
		if(e->worker_threads[0][i] != 0) {
f010384c:	8b 03                	mov    (%ebx),%eax
f010384e:	85 c0                	test   %eax,%eax
f0103850:	74 1d                	je     f010386f <env_destroy+0x70>
			thread_destroy(&envs[ENVX(e->worker_threads[0][i])]);	
f0103852:	83 ec 0c             	sub    $0xc,%esp
f0103855:	25 ff 03 00 00       	and    $0x3ff,%eax
f010385a:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
f0103860:	03 05 4c f2 21 f0    	add    0xf021f24c,%eax
f0103866:	50                   	push   %eax
f0103867:	e8 c2 fe ff ff       	call   f010372e <thread_destroy>
f010386c:	83 c4 10             	add    $0x10,%esp
f010386f:	83 c3 04             	add    $0x4,%ebx
		return;
	}
	cprintf("In env destroy, destroying env: %d\n", e->env_id); // for testing purposes
	/*prejdi cez pole worker threadov a znic ich*/
	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++)
f0103872:	39 f3                	cmp    %esi,%ebx
f0103874:	75 d6                	jne    f010384c <env_destroy+0x4d>
		if(e->worker_threads[0][i] != 0) {
			thread_destroy(&envs[ENVX(e->worker_threads[0][i])]);	
		}
	}
	// znic main thread
	env_free(e);
f0103876:	83 ec 0c             	sub    $0xc,%esp
f0103879:	57                   	push   %edi
f010387a:	e8 f4 fc ff ff       	call   f0103573 <env_free>

	if (curenv == e) {
f010387f:	e8 46 2d 00 00       	call   f01065ca <cpunum>
f0103884:	6b c0 74             	imul   $0x74,%eax,%eax
f0103887:	83 c4 10             	add    $0x10,%esp
f010388a:	3b b8 28 00 22 f0    	cmp    -0xfddffd8(%eax),%edi
f0103890:	75 17                	jne    f01038a9 <env_destroy+0xaa>
		curenv = NULL;
f0103892:	e8 33 2d 00 00       	call   f01065ca <cpunum>
f0103897:	6b c0 74             	imul   $0x74,%eax,%eax
f010389a:	c7 80 28 00 22 f0 00 	movl   $0x0,-0xfddffd8(%eax)
f01038a1:	00 00 00 
		sched_yield();
f01038a4:	e8 fd 13 00 00       	call   f0104ca6 <sched_yield>
	}
}
f01038a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01038ac:	5b                   	pop    %ebx
f01038ad:	5e                   	pop    %esi
f01038ae:	5f                   	pop    %edi
f01038af:	5d                   	pop    %ebp
f01038b0:	c3                   	ret    

f01038b1 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01038b1:	55                   	push   %ebp
f01038b2:	89 e5                	mov    %esp,%ebp
f01038b4:	53                   	push   %ebx
f01038b5:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01038b8:	e8 0d 2d 00 00       	call   f01065ca <cpunum>
f01038bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01038c0:	8b 98 28 00 22 f0    	mov    -0xfddffd8(%eax),%ebx
f01038c6:	e8 ff 2c 00 00       	call   f01065ca <cpunum>
f01038cb:	89 83 b8 00 00 00    	mov    %eax,0xb8(%ebx)

	asm volatile(
f01038d1:	8b 65 08             	mov    0x8(%ebp),%esp
f01038d4:	61                   	popa   
f01038d5:	07                   	pop    %es
f01038d6:	1f                   	pop    %ds
f01038d7:	83 c4 08             	add    $0x8,%esp
f01038da:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01038db:	83 ec 04             	sub    $0x4,%esp
f01038de:	68 c2 80 10 f0       	push   $0xf01080c2
f01038e3:	68 61 02 00 00       	push   $0x261
f01038e8:	68 69 80 10 f0       	push   $0xf0108069
f01038ed:	e8 4e c7 ff ff       	call   f0100040 <_panic>

f01038f2 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01038f2:	55                   	push   %ebp
f01038f3:	89 e5                	mov    %esp,%ebp
f01038f5:	53                   	push   %ebx
f01038f6:	83 ec 0c             	sub    $0xc,%esp
f01038f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
        //
        // First call to env_run
	cprintf("In env run, running env: %d\n", e->env_id);// can be commented - for testing purposes only
f01038fc:	ff b3 a4 00 00 00    	pushl  0xa4(%ebx)
f0103902:	68 ce 80 10 f0       	push   $0xf01080ce
f0103907:	e8 d4 04 00 00       	call   f0103de0 <cprintf>

        if ((curenv != NULL) && (curenv->env_status == ENV_RUNNING))
f010390c:	e8 b9 2c 00 00       	call   f01065ca <cpunum>
f0103911:	6b c0 74             	imul   $0x74,%eax,%eax
f0103914:	83 c4 10             	add    $0x10,%esp
f0103917:	83 b8 28 00 22 f0 00 	cmpl   $0x0,-0xfddffd8(%eax)
f010391e:	74 2f                	je     f010394f <env_run+0x5d>
f0103920:	e8 a5 2c 00 00       	call   f01065ca <cpunum>
f0103925:	6b c0 74             	imul   $0x74,%eax,%eax
f0103928:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f010392e:	83 b8 b0 00 00 00 03 	cmpl   $0x3,0xb0(%eax)
f0103935:	75 18                	jne    f010394f <env_run+0x5d>
                curenv->env_status = ENV_RUNNABLE;
f0103937:	e8 8e 2c 00 00       	call   f01065ca <cpunum>
f010393c:	6b c0 74             	imul   $0x74,%eax,%eax
f010393f:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f0103945:	c7 80 b0 00 00 00 02 	movl   $0x2,0xb0(%eax)
f010394c:	00 00 00 

        curenv = e;
f010394f:	e8 76 2c 00 00       	call   f01065ca <cpunum>
f0103954:	6b c0 74             	imul   $0x74,%eax,%eax
f0103957:	89 98 28 00 22 f0    	mov    %ebx,-0xfddffd8(%eax)
        curenv->env_status = ENV_RUNNING;
f010395d:	e8 68 2c 00 00       	call   f01065ca <cpunum>
f0103962:	6b c0 74             	imul   $0x74,%eax,%eax
f0103965:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f010396b:	c7 80 b0 00 00 00 03 	movl   $0x3,0xb0(%eax)
f0103972:	00 00 00 
        curenv->env_runs++;
f0103975:	e8 50 2c 00 00       	call   f01065ca <cpunum>
f010397a:	6b c0 74             	imul   $0x74,%eax,%eax
f010397d:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f0103983:	83 80 b4 00 00 00 01 	addl   $0x1,0xb4(%eax)

        lcr3(PADDR(curenv->env_pgdir));
f010398a:	e8 3b 2c 00 00       	call   f01065ca <cpunum>
f010398f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103992:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f0103998:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010399e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01039a3:	77 15                	ja     f01039ba <env_run+0xc8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01039a5:	50                   	push   %eax
f01039a6:	68 a8 6c 10 f0       	push   $0xf0106ca8
f01039ab:	68 8a 02 00 00       	push   $0x28a
f01039b0:	68 69 80 10 f0       	push   $0xf0108069
f01039b5:	e8 86 c6 ff ff       	call   f0100040 <_panic>
f01039ba:	05 00 00 00 10       	add    $0x10000000,%eax
f01039bf:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01039c2:	83 ec 0c             	sub    $0xc,%esp
f01039c5:	68 c0 23 12 f0       	push   $0xf01223c0
f01039ca:	e8 06 2f 00 00       	call   f01068d5 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01039cf:	f3 90                	pause  
        unlock_kernel();
        env_pop_tf(&curenv->env_tf);
f01039d1:	e8 f4 2b 00 00       	call   f01065ca <cpunum>
f01039d6:	6b c0 74             	imul   $0x74,%eax,%eax
f01039d9:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f01039df:	83 c0 59             	add    $0x59,%eax
f01039e2:	89 04 24             	mov    %eax,(%esp)
f01039e5:	e8 c7 fe ff ff       	call   f01038b1 <env_pop_tf>

f01039ea <thread_free>:
// pri multithreadingu zdielany, takze by sme efektivne znicili env pgdir aj pre ostatne worker 
// thready a aj pre main thread, cize po prepnuti do jedneho z tychto threadov
// sa potom sposobuje velmi nepekny triple fault
void 
thread_free(struct Env* e)
{
f01039ea:	55                   	push   %ebp
f01039eb:	89 e5                	mov    %esp,%ebp
f01039ed:	56                   	push   %esi
f01039ee:	53                   	push   %ebx
f01039ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("In thread free, freeing thread: %d\n", e->env_id); 
f01039f2:	83 ec 08             	sub    $0x8,%esp
f01039f5:	ff b3 a4 00 00 00    	pushl  0xa4(%ebx)
f01039fb:	68 a4 7f 10 f0       	push   $0xf0107fa4
f0103a00:	e8 db 03 00 00       	call   f0103de0 <cprintf>
	// hod jej esp adresu na zoznam volnych stackov pre thready
	stack_push(e->env_stack_id);
f0103a05:	83 c4 04             	add    $0x4,%esp
f0103a08:	ff 73 04             	pushl  0x4(%ebx)
f0103a0b:	e8 7b f6 ff ff       	call   f010308b <stack_push>
	struct Env* main_thrd = &envs[ENVX(e->env_process_id)];
f0103a10:	8b 13                	mov    (%ebx),%edx
f0103a12:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0103a18:	69 d2 d8 00 00 00    	imul   $0xd8,%edx,%edx
f0103a1e:	03 15 4c f2 21 f0    	add    0xf021f24c,%edx

	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++) {
		if(main_thrd->worker_threads[0][i] == e->env_id) {
f0103a24:	8b 8b a4 00 00 00    	mov    0xa4(%ebx),%ecx
f0103a2a:	83 c4 10             	add    $0x10,%esp
	// hod jej esp adresu na zoznam volnych stackov pre thready
	stack_push(e->env_stack_id);
	struct Env* main_thrd = &envs[ENVX(e->env_process_id)];

	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++) {
f0103a2d:	b8 00 00 00 00       	mov    $0x0,%eax
		if(main_thrd->worker_threads[0][i] == e->env_id) {
f0103a32:	39 4c 82 08          	cmp    %ecx,0x8(%edx,%eax,4)
f0103a36:	75 18                	jne    f0103a50 <thread_free+0x66>
f0103a38:	8d 04 82             	lea    (%edx,%eax,4),%eax
			main_thrd->worker_threads[0][i] = 0;	
f0103a3b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
			main_thrd->worker_threads[1][i] = 0;
f0103a42:	c7 40 30 00 00 00 00 	movl   $0x0,0x30(%eax)
	// hod jej esp adresu na zoznam volnych stackov pre thready
	stack_push(e->env_stack_id);
	struct Env* main_thrd = &envs[ENVX(e->env_process_id)];

	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++) {
f0103a49:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a4e:	eb 26                	jmp    f0103a76 <thread_free+0x8c>
		if(main_thrd->worker_threads[0][i] == e->env_id) {
			main_thrd->worker_threads[0][i] = 0;	
			main_thrd->worker_threads[1][i] = 0;
			break;
		}
		if(i == MAX_PROCESS_THREADS - 1) {
f0103a50:	83 f8 09             	cmp    $0x9,%eax
f0103a53:	75 17                	jne    f0103a6c <thread_free+0x82>
			panic("environment is not a worker thread of env E - THIS SHOULD NOT 				      HAPPEN\n");
f0103a55:	83 ec 04             	sub    $0x4,%esp
f0103a58:	68 c8 7f 10 f0       	push   $0xf0107fc8
f0103a5d:	68 aa 02 00 00       	push   $0x2aa
f0103a62:	68 69 80 10 f0       	push   $0xf0108069
f0103a67:	e8 d4 c5 ff ff       	call   f0100040 <_panic>
	// hod jej esp adresu na zoznam volnych stackov pre thready
	stack_push(e->env_stack_id);
	struct Env* main_thrd = &envs[ENVX(e->env_process_id)];

	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++) {
f0103a6c:	83 c0 01             	add    $0x1,%eax
f0103a6f:	83 f8 0a             	cmp    $0xa,%eax
f0103a72:	75 be                	jne    f0103a32 <thread_free+0x48>
f0103a74:	eb d3                	jmp    f0103a49 <thread_free+0x5f>
			panic("environment is not a worker thread of env E - THIS SHOULD NOT 				      HAPPEN\n");
		}
	}

	for(i = 0; i < MAX_PROCESS_THREADS; i++) {
		if (main_thrd->worker_threads[1][i] == THREAD_WAIT) {
f0103a76:	83 7c 82 30 01       	cmpl   $0x1,0x30(%edx,%eax,4)
f0103a7b:	74 19                	je     f0103a96 <thread_free+0xac>
			break;
		} 
		if (i == MAX_PROCESS_THREADS-1) {
f0103a7d:	83 f8 09             	cmp    $0x9,%eax
f0103a80:	75 0c                	jne    f0103a8e <thread_free+0xa4>
			main_thrd->env_status = ENV_RUNNABLE;
f0103a82:	c7 82 b0 00 00 00 02 	movl   $0x2,0xb0(%edx)
f0103a89:	00 00 00 
f0103a8c:	eb 08                	jmp    f0103a96 <thread_free+0xac>
		if(i == MAX_PROCESS_THREADS - 1) {
			panic("environment is not a worker thread of env E - THIS SHOULD NOT 				      HAPPEN\n");
		}
	}

	for(i = 0; i < MAX_PROCESS_THREADS; i++) {
f0103a8e:	83 c0 01             	add    $0x1,%eax
f0103a91:	83 f8 0a             	cmp    $0xa,%eax
f0103a94:	75 e0                	jne    f0103a76 <thread_free+0x8c>
		if (i == MAX_PROCESS_THREADS-1) {
			main_thrd->env_status = ENV_RUNNABLE;
		}
	}

	e->env_pgdir = 0;
f0103a96:	c7 83 bc 00 00 00 00 	movl   $0x0,0xbc(%ebx)
f0103a9d:	00 00 00 
	e->env_status = ENV_FREE;
f0103aa0:	c7 83 b0 00 00 00 00 	movl   $0x0,0xb0(%ebx)
f0103aa7:	00 00 00 
	e->env_link = env_free_list;
f0103aaa:	a1 54 f2 21 f0       	mov    0xf021f254,%eax
f0103aaf:	89 83 a0 00 00 00    	mov    %eax,0xa0(%ebx)
	env_free_list = e;
f0103ab5:	89 1d 54 f2 21 f0    	mov    %ebx,0xf021f254
	if (curenv == e) {
f0103abb:	e8 0a 2b 00 00       	call   f01065ca <cpunum>
f0103ac0:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ac3:	3b 98 28 00 22 f0    	cmp    -0xfddffd8(%eax),%ebx
f0103ac9:	75 17                	jne    f0103ae2 <thread_free+0xf8>
		curenv = NULL;
f0103acb:	e8 fa 2a 00 00       	call   f01065ca <cpunum>
f0103ad0:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ad3:	c7 80 28 00 22 f0 00 	movl   $0x0,-0xfddffd8(%eax)
f0103ada:	00 00 00 
		sched_yield();
f0103add:	e8 c4 11 00 00       	call   f0104ca6 <sched_yield>
	}
}
f0103ae2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103ae5:	5b                   	pop    %ebx
f0103ae6:	5e                   	pop    %esi
f0103ae7:	5d                   	pop    %ebp
f0103ae8:	c3                   	ret    

f0103ae9 <thread_create>:

napad:  alokovanie zasobnikov - zasobnik s adresami vrcholov neobsadenych zasobnikov. Pri vytvoreni 		threadu sa popne, pri zniceni threadu pushne. //hotovo
	*/
envid_t 
thread_create(uintptr_t func)
{
f0103ae9:	55                   	push   %ebp
f0103aea:	89 e5                	mov    %esp,%ebp
f0103aec:	53                   	push   %ebx
f0103aed:	83 ec 14             	sub    $0x14,%esp
	print_trapframe(&curenv->env_tf); // can be commented - for testing purposes only
f0103af0:	e8 d5 2a 00 00       	call   f01065ca <cpunum>
f0103af5:	83 ec 0c             	sub    $0xc,%esp
f0103af8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103afb:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f0103b01:	83 c0 59             	add    $0x59,%eax
f0103b04:	50                   	push   %eax
f0103b05:	e8 4d 0a 00 00       	call   f0104557 <print_trapframe>
	
	struct Env *e;
	env_alloc(&e, 0);
f0103b0a:	83 c4 08             	add    $0x8,%esp
f0103b0d:	6a 00                	push   $0x0
f0103b0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103b12:	50                   	push   %eax
f0103b13:	e8 17 f7 ff ff       	call   f010322f <env_alloc>
	e->env_pgdir = curenv->env_pgdir;
f0103b18:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0103b1b:	e8 aa 2a 00 00       	call   f01065ca <cpunum>
f0103b20:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b23:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f0103b29:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
f0103b2f:	89 83 bc 00 00 00    	mov    %eax,0xbc(%ebx)
	
	struct FreeStacks* stack = stack_pop();
f0103b35:	e8 72 f5 ff ff       	call   f01030ac <stack_pop>
f0103b3a:	89 c3                	mov    %eax,%ebx
	e->env_stack_id = stack->id; 
f0103b3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103b3f:	8b 13                	mov    (%ebx),%edx
f0103b41:	89 50 04             	mov    %edx,0x4(%eax)
	region_alloc(e, (void*)(stack->addr - PGSIZE), PGSIZE);
f0103b44:	8b 4b 04             	mov    0x4(%ebx),%ecx
f0103b47:	8d 91 00 f0 ff ff    	lea    -0x1000(%ecx),%edx
f0103b4d:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103b52:	e8 ab f4 ff ff       	call   f0103002 <region_alloc>
	e->env_tf.tf_esp = stack->addr;
f0103b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103b5a:	8b 53 04             	mov    0x4(%ebx),%edx
f0103b5d:	89 90 95 00 00 00    	mov    %edx,0x95(%eax)
	e->env_tf.tf_eip = func;
f0103b63:	8b 55 08             	mov    0x8(%ebp),%edx
f0103b66:	89 90 89 00 00 00    	mov    %edx,0x89(%eax)
f0103b6c:	83 c4 10             	add    $0x10,%esp

	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++)
f0103b6f:	bb 00 00 00 00       	mov    $0x0,%ebx
	{
		if(curenv->worker_threads[0][i] == 0) {
f0103b74:	e8 51 2a 00 00       	call   f01065ca <cpunum>
f0103b79:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b7c:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f0103b82:	83 7c 98 08 00       	cmpl   $0x0,0x8(%eax,%ebx,4)
f0103b87:	75 1d                	jne    f0103ba6 <thread_create+0xbd>
			curenv->worker_threads[0][i] = e->env_id;	
f0103b89:	e8 3c 2a 00 00       	call   f01065ca <cpunum>
f0103b8e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b91:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f0103b97:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103b9a:	8b 92 a4 00 00 00    	mov    0xa4(%edx),%edx
f0103ba0:	89 54 98 08          	mov    %edx,0x8(%eax,%ebx,4)
			break;
f0103ba4:	eb 08                	jmp    f0103bae <thread_create+0xc5>
	region_alloc(e, (void*)(stack->addr - PGSIZE), PGSIZE);
	e->env_tf.tf_esp = stack->addr;
	e->env_tf.tf_eip = func;

	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++)
f0103ba6:	83 c3 01             	add    $0x1,%ebx
f0103ba9:	83 fb 0a             	cmp    $0xa,%ebx
f0103bac:	75 c6                	jne    f0103b74 <thread_create+0x8b>
		if(i == MAX_PROCESS_THREADS - 1) {
			// cant create any more threads - rollback
		}
	}

	e->env_status = ENV_RUNNABLE;
f0103bae:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0103bb1:	c7 83 b0 00 00 00 02 	movl   $0x2,0xb0(%ebx)
f0103bb8:	00 00 00 
	e->env_process_id = curenv->env_process_id; 
f0103bbb:	e8 0a 2a 00 00       	call   f01065ca <cpunum>
f0103bc0:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bc3:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f0103bc9:	8b 00                	mov    (%eax),%eax
f0103bcb:	89 03                	mov    %eax,(%ebx)
	cprintf("in thread create: thread process id: %d\n", e->env_process_id);
f0103bcd:	83 ec 08             	sub    $0x8,%esp
f0103bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103bd3:	ff 30                	pushl  (%eax)
f0103bd5:	68 18 80 10 f0       	push   $0xf0108018
f0103bda:	e8 01 02 00 00       	call   f0103de0 <cprintf>
	return e->env_id;
f0103bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103be2:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
f0103be8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103beb:	c9                   	leave  
f0103bec:	c3                   	ret    

f0103bed <thread_join>:

void 
thread_join(envid_t envid)
{
f0103bed:	55                   	push   %ebp
f0103bee:	89 e5                	mov    %esp,%ebp
f0103bf0:	56                   	push   %esi
f0103bf1:	53                   	push   %ebx
f0103bf2:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Env* worker = &envs[ENVX(envid)];
f0103bf5:	8b 1d 4c f2 21 f0    	mov    0xf021f24c,%ebx
	struct Env* main_thrd = &envs[ENVX(worker->env_process_id)];
f0103bfb:	89 f0                	mov    %esi,%eax
f0103bfd:	25 ff 03 00 00       	and    $0x3ff,%eax
f0103c02:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
f0103c08:	8b 04 03             	mov    (%ebx,%eax,1),%eax
f0103c0b:	25 ff 03 00 00       	and    $0x3ff,%eax
f0103c10:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
f0103c16:	01 c3                	add    %eax,%ebx

	cprintf("in system call THREAD JOIN id: %d \n\n", envid);
f0103c18:	83 ec 08             	sub    $0x8,%esp
f0103c1b:	56                   	push   %esi
f0103c1c:	68 44 80 10 f0       	push   $0xf0108044
f0103c21:	e8 ba 01 00 00       	call   f0103de0 <cprintf>
f0103c26:	83 c4 10             	add    $0x10,%esp
	/*najdi worker thread, nastav jeho stav na nenulovy (waiting)*/
	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++) {
f0103c29:	b8 00 00 00 00       	mov    $0x0,%eax
		if(main_thrd->worker_threads[0][i] == envid) {
f0103c2e:	3b 74 83 08          	cmp    0x8(%ebx,%eax,4),%esi
f0103c32:	75 0a                	jne    f0103c3e <thread_join+0x51>
			main_thrd->worker_threads[1][i] = THREAD_WAIT;	
f0103c34:	c7 44 83 30 01 00 00 	movl   $0x1,0x30(%ebx,%eax,4)
f0103c3b:	00 
			break;
f0103c3c:	eb 0d                	jmp    f0103c4b <thread_join+0x5e>
		}
		if(i == MAX_PROCESS_THREADS - 1) {
f0103c3e:	83 f8 09             	cmp    $0x9,%eax
f0103c41:	74 17                	je     f0103c5a <thread_join+0x6d>
	struct Env* main_thrd = &envs[ENVX(worker->env_process_id)];

	cprintf("in system call THREAD JOIN id: %d \n\n", envid);
	/*najdi worker thread, nastav jeho stav na nenulovy (waiting)*/
	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++) {
f0103c43:	83 c0 01             	add    $0x1,%eax
f0103c46:	83 f8 0a             	cmp    $0xa,%eax
f0103c49:	75 e3                	jne    f0103c2e <thread_join+0x41>
		if(i == MAX_PROCESS_THREADS - 1) {
			// no such thread
			return;
		}
	}
	main_thrd->env_status = ENV_NOT_RUNNABLE;
f0103c4b:	c7 83 b0 00 00 00 04 	movl   $0x4,0xb0(%ebx)
f0103c52:	00 00 00 
	sched_yield();
f0103c55:	e8 4c 10 00 00       	call   f0104ca6 <sched_yield>
}
f0103c5a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103c5d:	5b                   	pop    %ebx
f0103c5e:	5e                   	pop    %esi
f0103c5f:	5d                   	pop    %ebp
f0103c60:	c3                   	ret    

f0103c61 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103c61:	55                   	push   %ebp
f0103c62:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103c64:	ba 70 00 00 00       	mov    $0x70,%edx
f0103c69:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c6c:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103c6d:	ba 71 00 00 00       	mov    $0x71,%edx
f0103c72:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103c73:	0f b6 c0             	movzbl %al,%eax
}
f0103c76:	5d                   	pop    %ebp
f0103c77:	c3                   	ret    

f0103c78 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103c78:	55                   	push   %ebp
f0103c79:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103c7b:	ba 70 00 00 00       	mov    $0x70,%edx
f0103c80:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c83:	ee                   	out    %al,(%dx)
f0103c84:	ba 71 00 00 00       	mov    $0x71,%edx
f0103c89:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c8c:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103c8d:	5d                   	pop    %ebp
f0103c8e:	c3                   	ret    

f0103c8f <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103c8f:	55                   	push   %ebp
f0103c90:	89 e5                	mov    %esp,%ebp
f0103c92:	56                   	push   %esi
f0103c93:	53                   	push   %ebx
f0103c94:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103c97:	66 a3 a8 23 12 f0    	mov    %ax,0xf01223a8
	if (!didinit)
f0103c9d:	80 3d 58 f2 21 f0 00 	cmpb   $0x0,0xf021f258
f0103ca4:	74 5a                	je     f0103d00 <irq_setmask_8259A+0x71>
f0103ca6:	89 c6                	mov    %eax,%esi
f0103ca8:	ba 21 00 00 00       	mov    $0x21,%edx
f0103cad:	ee                   	out    %al,(%dx)
f0103cae:	66 c1 e8 08          	shr    $0x8,%ax
f0103cb2:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103cb7:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103cb8:	83 ec 0c             	sub    $0xc,%esp
f0103cbb:	68 eb 80 10 f0       	push   $0xf01080eb
f0103cc0:	e8 1b 01 00 00       	call   f0103de0 <cprintf>
f0103cc5:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103cc8:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103ccd:	0f b7 f6             	movzwl %si,%esi
f0103cd0:	f7 d6                	not    %esi
f0103cd2:	0f a3 de             	bt     %ebx,%esi
f0103cd5:	73 11                	jae    f0103ce8 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0103cd7:	83 ec 08             	sub    $0x8,%esp
f0103cda:	53                   	push   %ebx
f0103cdb:	68 eb 85 10 f0       	push   $0xf01085eb
f0103ce0:	e8 fb 00 00 00       	call   f0103de0 <cprintf>
f0103ce5:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103ce8:	83 c3 01             	add    $0x1,%ebx
f0103ceb:	83 fb 10             	cmp    $0x10,%ebx
f0103cee:	75 e2                	jne    f0103cd2 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103cf0:	83 ec 0c             	sub    $0xc,%esp
f0103cf3:	68 88 7e 10 f0       	push   $0xf0107e88
f0103cf8:	e8 e3 00 00 00       	call   f0103de0 <cprintf>
f0103cfd:	83 c4 10             	add    $0x10,%esp
}
f0103d00:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103d03:	5b                   	pop    %ebx
f0103d04:	5e                   	pop    %esi
f0103d05:	5d                   	pop    %ebp
f0103d06:	c3                   	ret    

f0103d07 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103d07:	c6 05 58 f2 21 f0 01 	movb   $0x1,0xf021f258
f0103d0e:	ba 21 00 00 00       	mov    $0x21,%edx
f0103d13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103d18:	ee                   	out    %al,(%dx)
f0103d19:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103d1e:	ee                   	out    %al,(%dx)
f0103d1f:	ba 20 00 00 00       	mov    $0x20,%edx
f0103d24:	b8 11 00 00 00       	mov    $0x11,%eax
f0103d29:	ee                   	out    %al,(%dx)
f0103d2a:	ba 21 00 00 00       	mov    $0x21,%edx
f0103d2f:	b8 20 00 00 00       	mov    $0x20,%eax
f0103d34:	ee                   	out    %al,(%dx)
f0103d35:	b8 04 00 00 00       	mov    $0x4,%eax
f0103d3a:	ee                   	out    %al,(%dx)
f0103d3b:	b8 03 00 00 00       	mov    $0x3,%eax
f0103d40:	ee                   	out    %al,(%dx)
f0103d41:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103d46:	b8 11 00 00 00       	mov    $0x11,%eax
f0103d4b:	ee                   	out    %al,(%dx)
f0103d4c:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103d51:	b8 28 00 00 00       	mov    $0x28,%eax
f0103d56:	ee                   	out    %al,(%dx)
f0103d57:	b8 02 00 00 00       	mov    $0x2,%eax
f0103d5c:	ee                   	out    %al,(%dx)
f0103d5d:	b8 01 00 00 00       	mov    $0x1,%eax
f0103d62:	ee                   	out    %al,(%dx)
f0103d63:	ba 20 00 00 00       	mov    $0x20,%edx
f0103d68:	b8 68 00 00 00       	mov    $0x68,%eax
f0103d6d:	ee                   	out    %al,(%dx)
f0103d6e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103d73:	ee                   	out    %al,(%dx)
f0103d74:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103d79:	b8 68 00 00 00       	mov    $0x68,%eax
f0103d7e:	ee                   	out    %al,(%dx)
f0103d7f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103d84:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103d85:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f0103d8c:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103d90:	74 13                	je     f0103da5 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103d92:	55                   	push   %ebp
f0103d93:	89 e5                	mov    %esp,%ebp
f0103d95:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103d98:	0f b7 c0             	movzwl %ax,%eax
f0103d9b:	50                   	push   %eax
f0103d9c:	e8 ee fe ff ff       	call   f0103c8f <irq_setmask_8259A>
f0103da1:	83 c4 10             	add    $0x10,%esp
}
f0103da4:	c9                   	leave  
f0103da5:	f3 c3                	repz ret 

f0103da7 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103da7:	55                   	push   %ebp
f0103da8:	89 e5                	mov    %esp,%ebp
f0103daa:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103dad:	ff 75 08             	pushl  0x8(%ebp)
f0103db0:	e8 e4 c9 ff ff       	call   f0100799 <cputchar>
	*cnt++;
}
f0103db5:	83 c4 10             	add    $0x10,%esp
f0103db8:	c9                   	leave  
f0103db9:	c3                   	ret    

f0103dba <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103dba:	55                   	push   %ebp
f0103dbb:	89 e5                	mov    %esp,%ebp
f0103dbd:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103dc0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103dc7:	ff 75 0c             	pushl  0xc(%ebp)
f0103dca:	ff 75 08             	pushl  0x8(%ebp)
f0103dcd:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103dd0:	50                   	push   %eax
f0103dd1:	68 a7 3d 10 f0       	push   $0xf0103da7
f0103dd6:	e8 48 1b 00 00       	call   f0105923 <vprintfmt>
	return cnt;
}
f0103ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103dde:	c9                   	leave  
f0103ddf:	c3                   	ret    

f0103de0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103de0:	55                   	push   %ebp
f0103de1:	89 e5                	mov    %esp,%ebp
f0103de3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103de6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103de9:	50                   	push   %eax
f0103dea:	ff 75 08             	pushl  0x8(%ebp)
f0103ded:	e8 c8 ff ff ff       	call   f0103dba <vcprintf>
	va_end(ap);

	return cnt;
}
f0103df2:	c9                   	leave  
f0103df3:	c3                   	ret    

f0103df4 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103df4:	55                   	push   %ebp
f0103df5:	89 e5                	mov    %esp,%ebp
f0103df7:	57                   	push   %edi
f0103df8:	56                   	push   %esi
f0103df9:	53                   	push   %ebx
f0103dfa:	83 ec 1c             	sub    $0x1c,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:

	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - (thiscpu->cpu_id * (KSTKSIZE + KSTKGAP));
f0103dfd:	e8 c8 27 00 00       	call   f01065ca <cpunum>
f0103e02:	89 c3                	mov    %eax,%ebx
f0103e04:	e8 c1 27 00 00       	call   f01065ca <cpunum>
f0103e09:	6b d3 74             	imul   $0x74,%ebx,%edx
f0103e0c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e0f:	0f b6 88 20 00 22 f0 	movzbl -0xfddffe0(%eax),%ecx
f0103e16:	c1 e1 10             	shl    $0x10,%ecx
f0103e19:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f0103e1e:	29 c8                	sub    %ecx,%eax
f0103e20:	89 82 30 00 22 f0    	mov    %eax,-0xfddffd0(%edx)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103e26:	e8 9f 27 00 00       	call   f01065ca <cpunum>
f0103e2b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e2e:	66 c7 80 34 00 22 f0 	movw   $0x10,-0xfddffcc(%eax)
f0103e35:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f0103e37:	e8 8e 27 00 00       	call   f01065ca <cpunum>
f0103e3c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e3f:	66 c7 80 92 00 22 f0 	movw   $0x68,-0xfddff6e(%eax)
f0103e46:	68 00 

	uint32_t curr_cpu_gdt_index = GD_TSS0 + ((thiscpu->cpu_id + 1) * 8);
f0103e48:	e8 7d 27 00 00       	call   f01065ca <cpunum>
f0103e4d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e50:	0f b6 80 20 00 22 f0 	movzbl -0xfddffe0(%eax),%eax
f0103e57:	8d 3c c5 30 00 00 00 	lea    0x30(,%eax,8),%edi

	gdt[curr_cpu_gdt_index >> 3] = SEG16
f0103e5e:	89 fb                	mov    %edi,%ebx
f0103e60:	c1 eb 03             	shr    $0x3,%ebx
f0103e63:	e8 62 27 00 00       	call   f01065ca <cpunum>
f0103e68:	89 c6                	mov    %eax,%esi
f0103e6a:	e8 5b 27 00 00       	call   f01065ca <cpunum>
f0103e6f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103e72:	e8 53 27 00 00       	call   f01065ca <cpunum>
f0103e77:	66 c7 04 dd 40 23 12 	movw   $0x67,-0xfeddcc0(,%ebx,8)
f0103e7e:	f0 67 00 
f0103e81:	6b f6 74             	imul   $0x74,%esi,%esi
f0103e84:	81 c6 2c 00 22 f0    	add    $0xf022002c,%esi
f0103e8a:	66 89 34 dd 42 23 12 	mov    %si,-0xfeddcbe(,%ebx,8)
f0103e91:	f0 
f0103e92:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f0103e96:	81 c2 2c 00 22 f0    	add    $0xf022002c,%edx
f0103e9c:	c1 ea 10             	shr    $0x10,%edx
f0103e9f:	88 14 dd 44 23 12 f0 	mov    %dl,-0xfeddcbc(,%ebx,8)
f0103ea6:	c6 04 dd 46 23 12 f0 	movb   $0x40,-0xfeddcba(,%ebx,8)
f0103ead:	40 
f0103eae:	6b c0 74             	imul   $0x74,%eax,%eax
f0103eb1:	05 2c 00 22 f0       	add    $0xf022002c,%eax
f0103eb6:	c1 e8 18             	shr    $0x18,%eax
f0103eb9:	88 04 dd 47 23 12 f0 	mov    %al,-0xfeddcb9(,%ebx,8)
	(STS_T32A, (uint32_t) (&thiscpu->cpu_ts), sizeof(struct Taskstate) - 1, 0);
	gdt[curr_cpu_gdt_index >> 3].sd_s = 0;
f0103ec0:	c6 04 dd 45 23 12 f0 	movb   $0x89,-0xfeddcbb(,%ebx,8)
f0103ec7:	89 
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103ec8:	0f 00 df             	ltr    %di
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0103ecb:	b8 ac 23 12 f0       	mov    $0xf01223ac,%eax
f0103ed0:	0f 01 18             	lidtl  (%eax)
	
	ltr(curr_cpu_gdt_index);

	// Load the IDT
	lidt(&idt_pd);
}
f0103ed3:	83 c4 1c             	add    $0x1c,%esp
f0103ed6:	5b                   	pop    %ebx
f0103ed7:	5e                   	pop    %esi
f0103ed8:	5f                   	pop    %edi
f0103ed9:	5d                   	pop    %ebp
f0103eda:	c3                   	ret    

f0103edb <trap_init>:
}


void
trap_init(void)
{
f0103edb:	55                   	push   %ebp
f0103edc:	89 e5                	mov    %esp,%ebp
f0103ede:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.

	extern void TH_DIVIDE(); 	SETGATE(idt[T_DIVIDE], 0, GD_KT, TH_DIVIDE, 							0); 
f0103ee1:	b8 b8 4a 10 f0       	mov    $0xf0104ab8,%eax
f0103ee6:	66 a3 60 f2 21 f0    	mov    %ax,0xf021f260
f0103eec:	66 c7 05 62 f2 21 f0 	movw   $0x8,0xf021f262
f0103ef3:	08 00 
f0103ef5:	c6 05 64 f2 21 f0 00 	movb   $0x0,0xf021f264
f0103efc:	c6 05 65 f2 21 f0 8e 	movb   $0x8e,0xf021f265
f0103f03:	c1 e8 10             	shr    $0x10,%eax
f0103f06:	66 a3 66 f2 21 f0    	mov    %ax,0xf021f266
	extern void TH_DEBUG(); 	SETGATE(idt[T_DEBUG], 0, GD_KT, TH_DEBUG, 0); 
f0103f0c:	b8 c2 4a 10 f0       	mov    $0xf0104ac2,%eax
f0103f11:	66 a3 68 f2 21 f0    	mov    %ax,0xf021f268
f0103f17:	66 c7 05 6a f2 21 f0 	movw   $0x8,0xf021f26a
f0103f1e:	08 00 
f0103f20:	c6 05 6c f2 21 f0 00 	movb   $0x0,0xf021f26c
f0103f27:	c6 05 6d f2 21 f0 8e 	movb   $0x8e,0xf021f26d
f0103f2e:	c1 e8 10             	shr    $0x10,%eax
f0103f31:	66 a3 6e f2 21 f0    	mov    %ax,0xf021f26e
	extern void TH_NMI(); 		SETGATE(idt[T_NMI], 0, GD_KT, TH_NMI, 0); 
f0103f37:	b8 cc 4a 10 f0       	mov    $0xf0104acc,%eax
f0103f3c:	66 a3 70 f2 21 f0    	mov    %ax,0xf021f270
f0103f42:	66 c7 05 72 f2 21 f0 	movw   $0x8,0xf021f272
f0103f49:	08 00 
f0103f4b:	c6 05 74 f2 21 f0 00 	movb   $0x0,0xf021f274
f0103f52:	c6 05 75 f2 21 f0 8e 	movb   $0x8e,0xf021f275
f0103f59:	c1 e8 10             	shr    $0x10,%eax
f0103f5c:	66 a3 76 f2 21 f0    	mov    %ax,0xf021f276
	extern void TH_BRKPT(); 	SETGATE(idt[T_BRKPT], 0, GD_KT, TH_BRKPT, 3); 
f0103f62:	b8 d6 4a 10 f0       	mov    $0xf0104ad6,%eax
f0103f67:	66 a3 78 f2 21 f0    	mov    %ax,0xf021f278
f0103f6d:	66 c7 05 7a f2 21 f0 	movw   $0x8,0xf021f27a
f0103f74:	08 00 
f0103f76:	c6 05 7c f2 21 f0 00 	movb   $0x0,0xf021f27c
f0103f7d:	c6 05 7d f2 21 f0 ee 	movb   $0xee,0xf021f27d
f0103f84:	c1 e8 10             	shr    $0x10,%eax
f0103f87:	66 a3 7e f2 21 f0    	mov    %ax,0xf021f27e
	extern void TH_OFLOW(); 	SETGATE(idt[T_OFLOW], 0, GD_KT, TH_OFLOW, 0); 
f0103f8d:	b8 e0 4a 10 f0       	mov    $0xf0104ae0,%eax
f0103f92:	66 a3 80 f2 21 f0    	mov    %ax,0xf021f280
f0103f98:	66 c7 05 82 f2 21 f0 	movw   $0x8,0xf021f282
f0103f9f:	08 00 
f0103fa1:	c6 05 84 f2 21 f0 00 	movb   $0x0,0xf021f284
f0103fa8:	c6 05 85 f2 21 f0 8e 	movb   $0x8e,0xf021f285
f0103faf:	c1 e8 10             	shr    $0x10,%eax
f0103fb2:	66 a3 86 f2 21 f0    	mov    %ax,0xf021f286
	extern void TH_BOUND(); 	SETGATE(idt[T_BOUND], 0, GD_KT, TH_BOUND, 0); 
f0103fb8:	b8 ea 4a 10 f0       	mov    $0xf0104aea,%eax
f0103fbd:	66 a3 88 f2 21 f0    	mov    %ax,0xf021f288
f0103fc3:	66 c7 05 8a f2 21 f0 	movw   $0x8,0xf021f28a
f0103fca:	08 00 
f0103fcc:	c6 05 8c f2 21 f0 00 	movb   $0x0,0xf021f28c
f0103fd3:	c6 05 8d f2 21 f0 8e 	movb   $0x8e,0xf021f28d
f0103fda:	c1 e8 10             	shr    $0x10,%eax
f0103fdd:	66 a3 8e f2 21 f0    	mov    %ax,0xf021f28e
	extern void TH_ILLOP(); 	SETGATE(idt[T_ILLOP], 0, GD_KT, TH_ILLOP, 0); 
f0103fe3:	b8 f4 4a 10 f0       	mov    $0xf0104af4,%eax
f0103fe8:	66 a3 90 f2 21 f0    	mov    %ax,0xf021f290
f0103fee:	66 c7 05 92 f2 21 f0 	movw   $0x8,0xf021f292
f0103ff5:	08 00 
f0103ff7:	c6 05 94 f2 21 f0 00 	movb   $0x0,0xf021f294
f0103ffe:	c6 05 95 f2 21 f0 8e 	movb   $0x8e,0xf021f295
f0104005:	c1 e8 10             	shr    $0x10,%eax
f0104008:	66 a3 96 f2 21 f0    	mov    %ax,0xf021f296
	extern void TH_DEVICE(); 	SETGATE(idt[T_DEVICE], 0, GD_KT, TH_DEVICE, 							0); 
f010400e:	b8 fe 4a 10 f0       	mov    $0xf0104afe,%eax
f0104013:	66 a3 98 f2 21 f0    	mov    %ax,0xf021f298
f0104019:	66 c7 05 9a f2 21 f0 	movw   $0x8,0xf021f29a
f0104020:	08 00 
f0104022:	c6 05 9c f2 21 f0 00 	movb   $0x0,0xf021f29c
f0104029:	c6 05 9d f2 21 f0 8e 	movb   $0x8e,0xf021f29d
f0104030:	c1 e8 10             	shr    $0x10,%eax
f0104033:	66 a3 9e f2 21 f0    	mov    %ax,0xf021f29e
	extern void TH_DBLFLT(); 	SETGATE(idt[T_DBLFLT], 0, GD_KT, TH_DBLFLT, 							0); 
f0104039:	b8 08 4b 10 f0       	mov    $0xf0104b08,%eax
f010403e:	66 a3 a0 f2 21 f0    	mov    %ax,0xf021f2a0
f0104044:	66 c7 05 a2 f2 21 f0 	movw   $0x8,0xf021f2a2
f010404b:	08 00 
f010404d:	c6 05 a4 f2 21 f0 00 	movb   $0x0,0xf021f2a4
f0104054:	c6 05 a5 f2 21 f0 8e 	movb   $0x8e,0xf021f2a5
f010405b:	c1 e8 10             	shr    $0x10,%eax
f010405e:	66 a3 a6 f2 21 f0    	mov    %ax,0xf021f2a6
	extern void TH_TSS(); 		SETGATE(idt[T_TSS], 0, GD_KT, TH_TSS, 0); 
f0104064:	b8 10 4b 10 f0       	mov    $0xf0104b10,%eax
f0104069:	66 a3 b0 f2 21 f0    	mov    %ax,0xf021f2b0
f010406f:	66 c7 05 b2 f2 21 f0 	movw   $0x8,0xf021f2b2
f0104076:	08 00 
f0104078:	c6 05 b4 f2 21 f0 00 	movb   $0x0,0xf021f2b4
f010407f:	c6 05 b5 f2 21 f0 8e 	movb   $0x8e,0xf021f2b5
f0104086:	c1 e8 10             	shr    $0x10,%eax
f0104089:	66 a3 b6 f2 21 f0    	mov    %ax,0xf021f2b6
	extern void TH_SEGNP(); 	SETGATE(idt[T_SEGNP], 0, GD_KT, TH_SEGNP, 0); 
f010408f:	b8 18 4b 10 f0       	mov    $0xf0104b18,%eax
f0104094:	66 a3 b8 f2 21 f0    	mov    %ax,0xf021f2b8
f010409a:	66 c7 05 ba f2 21 f0 	movw   $0x8,0xf021f2ba
f01040a1:	08 00 
f01040a3:	c6 05 bc f2 21 f0 00 	movb   $0x0,0xf021f2bc
f01040aa:	c6 05 bd f2 21 f0 8e 	movb   $0x8e,0xf021f2bd
f01040b1:	c1 e8 10             	shr    $0x10,%eax
f01040b4:	66 a3 be f2 21 f0    	mov    %ax,0xf021f2be
	extern void TH_STACK(); 	SETGATE(idt[T_STACK], 0, GD_KT, TH_STACK, 0); 
f01040ba:	b8 20 4b 10 f0       	mov    $0xf0104b20,%eax
f01040bf:	66 a3 c0 f2 21 f0    	mov    %ax,0xf021f2c0
f01040c5:	66 c7 05 c2 f2 21 f0 	movw   $0x8,0xf021f2c2
f01040cc:	08 00 
f01040ce:	c6 05 c4 f2 21 f0 00 	movb   $0x0,0xf021f2c4
f01040d5:	c6 05 c5 f2 21 f0 8e 	movb   $0x8e,0xf021f2c5
f01040dc:	c1 e8 10             	shr    $0x10,%eax
f01040df:	66 a3 c6 f2 21 f0    	mov    %ax,0xf021f2c6
	extern void TH_GPFLT(); 	SETGATE(idt[T_GPFLT], 0, GD_KT, TH_GPFLT, 0); 
f01040e5:	b8 28 4b 10 f0       	mov    $0xf0104b28,%eax
f01040ea:	66 a3 c8 f2 21 f0    	mov    %ax,0xf021f2c8
f01040f0:	66 c7 05 ca f2 21 f0 	movw   $0x8,0xf021f2ca
f01040f7:	08 00 
f01040f9:	c6 05 cc f2 21 f0 00 	movb   $0x0,0xf021f2cc
f0104100:	c6 05 cd f2 21 f0 8e 	movb   $0x8e,0xf021f2cd
f0104107:	c1 e8 10             	shr    $0x10,%eax
f010410a:	66 a3 ce f2 21 f0    	mov    %ax,0xf021f2ce
	extern void TH_PGFLT(); 	SETGATE(idt[T_PGFLT], 0, GD_KT, TH_PGFLT, 0); 
f0104110:	b8 30 4b 10 f0       	mov    $0xf0104b30,%eax
f0104115:	66 a3 d0 f2 21 f0    	mov    %ax,0xf021f2d0
f010411b:	66 c7 05 d2 f2 21 f0 	movw   $0x8,0xf021f2d2
f0104122:	08 00 
f0104124:	c6 05 d4 f2 21 f0 00 	movb   $0x0,0xf021f2d4
f010412b:	c6 05 d5 f2 21 f0 8e 	movb   $0x8e,0xf021f2d5
f0104132:	c1 e8 10             	shr    $0x10,%eax
f0104135:	66 a3 d6 f2 21 f0    	mov    %ax,0xf021f2d6
	extern void TH_FPERR(); 	SETGATE(idt[T_FPERR], 0, GD_KT, TH_FPERR, 0); 
f010413b:	b8 38 4b 10 f0       	mov    $0xf0104b38,%eax
f0104140:	66 a3 e0 f2 21 f0    	mov    %ax,0xf021f2e0
f0104146:	66 c7 05 e2 f2 21 f0 	movw   $0x8,0xf021f2e2
f010414d:	08 00 
f010414f:	c6 05 e4 f2 21 f0 00 	movb   $0x0,0xf021f2e4
f0104156:	c6 05 e5 f2 21 f0 8e 	movb   $0x8e,0xf021f2e5
f010415d:	c1 e8 10             	shr    $0x10,%eax
f0104160:	66 a3 e6 f2 21 f0    	mov    %ax,0xf021f2e6
	extern void TH_ALIGN(); 	SETGATE(idt[T_ALIGN], 0, GD_KT, TH_ALIGN, 0); 
f0104166:	b8 3e 4b 10 f0       	mov    $0xf0104b3e,%eax
f010416b:	66 a3 e8 f2 21 f0    	mov    %ax,0xf021f2e8
f0104171:	66 c7 05 ea f2 21 f0 	movw   $0x8,0xf021f2ea
f0104178:	08 00 
f010417a:	c6 05 ec f2 21 f0 00 	movb   $0x0,0xf021f2ec
f0104181:	c6 05 ed f2 21 f0 8e 	movb   $0x8e,0xf021f2ed
f0104188:	c1 e8 10             	shr    $0x10,%eax
f010418b:	66 a3 ee f2 21 f0    	mov    %ax,0xf021f2ee
	extern void TH_MCHK(); 		SETGATE(idt[T_MCHK], 0, GD_KT, TH_MCHK, 0); 
f0104191:	b8 42 4b 10 f0       	mov    $0xf0104b42,%eax
f0104196:	66 a3 f0 f2 21 f0    	mov    %ax,0xf021f2f0
f010419c:	66 c7 05 f2 f2 21 f0 	movw   $0x8,0xf021f2f2
f01041a3:	08 00 
f01041a5:	c6 05 f4 f2 21 f0 00 	movb   $0x0,0xf021f2f4
f01041ac:	c6 05 f5 f2 21 f0 8e 	movb   $0x8e,0xf021f2f5
f01041b3:	c1 e8 10             	shr    $0x10,%eax
f01041b6:	66 a3 f6 f2 21 f0    	mov    %ax,0xf021f2f6
	extern void TH_SIMDERR(); 	SETGATE(idt[T_SIMDERR], 0, GD_KT, TH_SIMDERR, 							0); 	// prepisat neskor ako interrupt 
f01041bc:	b8 48 4b 10 f0       	mov    $0xf0104b48,%eax
f01041c1:	66 a3 f8 f2 21 f0    	mov    %ax,0xf021f2f8
f01041c7:	66 c7 05 fa f2 21 f0 	movw   $0x8,0xf021f2fa
f01041ce:	08 00 
f01041d0:	c6 05 fc f2 21 f0 00 	movb   $0x0,0xf021f2fc
f01041d7:	c6 05 fd f2 21 f0 8e 	movb   $0x8e,0xf021f2fd
f01041de:	c1 e8 10             	shr    $0x10,%eax
f01041e1:	66 a3 fe f2 21 f0    	mov    %ax,0xf021f2fe
							// namiesto trapu (neskor)
	extern void TH_SYSCALL(); 	SETGATE(idt[T_SYSCALL], 0, GD_KT, TH_SYSCALL, 							3); 
f01041e7:	b8 4e 4b 10 f0       	mov    $0xf0104b4e,%eax
f01041ec:	66 a3 e0 f3 21 f0    	mov    %ax,0xf021f3e0
f01041f2:	66 c7 05 e2 f3 21 f0 	movw   $0x8,0xf021f3e2
f01041f9:	08 00 
f01041fb:	c6 05 e4 f3 21 f0 00 	movb   $0x0,0xf021f3e4
f0104202:	c6 05 e5 f3 21 f0 ee 	movb   $0xee,0xf021f3e5
f0104209:	c1 e8 10             	shr    $0x10,%eax
f010420c:	66 a3 e6 f3 21 f0    	mov    %ax,0xf021f3e6

	extern void TH_IRQ_TIMER();	SETGATE(idt[IRQ_OFFSET + 0], 0, GD_KT, TH_IRQ_TIMER, 0);
f0104212:	b8 54 4b 10 f0       	mov    $0xf0104b54,%eax
f0104217:	66 a3 60 f3 21 f0    	mov    %ax,0xf021f360
f010421d:	66 c7 05 62 f3 21 f0 	movw   $0x8,0xf021f362
f0104224:	08 00 
f0104226:	c6 05 64 f3 21 f0 00 	movb   $0x0,0xf021f364
f010422d:	c6 05 65 f3 21 f0 8e 	movb   $0x8e,0xf021f365
f0104234:	c1 e8 10             	shr    $0x10,%eax
f0104237:	66 a3 66 f3 21 f0    	mov    %ax,0xf021f366
	extern void TH_IRQ_KBD();	SETGATE(idt[IRQ_OFFSET + 1], 0, GD_KT, TH_IRQ_KBD, 0);
f010423d:	b8 5a 4b 10 f0       	mov    $0xf0104b5a,%eax
f0104242:	66 a3 68 f3 21 f0    	mov    %ax,0xf021f368
f0104248:	66 c7 05 6a f3 21 f0 	movw   $0x8,0xf021f36a
f010424f:	08 00 
f0104251:	c6 05 6c f3 21 f0 00 	movb   $0x0,0xf021f36c
f0104258:	c6 05 6d f3 21 f0 8e 	movb   $0x8e,0xf021f36d
f010425f:	c1 e8 10             	shr    $0x10,%eax
f0104262:	66 a3 6e f3 21 f0    	mov    %ax,0xf021f36e
	extern void TH_IRQ_2();		SETGATE(idt[IRQ_OFFSET + 2], 0, GD_KT, TH_IRQ_2, 0);
f0104268:	b8 60 4b 10 f0       	mov    $0xf0104b60,%eax
f010426d:	66 a3 70 f3 21 f0    	mov    %ax,0xf021f370
f0104273:	66 c7 05 72 f3 21 f0 	movw   $0x8,0xf021f372
f010427a:	08 00 
f010427c:	c6 05 74 f3 21 f0 00 	movb   $0x0,0xf021f374
f0104283:	c6 05 75 f3 21 f0 8e 	movb   $0x8e,0xf021f375
f010428a:	c1 e8 10             	shr    $0x10,%eax
f010428d:	66 a3 76 f3 21 f0    	mov    %ax,0xf021f376
	extern void TH_IRQ_3();		SETGATE(idt[IRQ_OFFSET + 3], 0, GD_KT, TH_IRQ_3, 0);
f0104293:	b8 66 4b 10 f0       	mov    $0xf0104b66,%eax
f0104298:	66 a3 78 f3 21 f0    	mov    %ax,0xf021f378
f010429e:	66 c7 05 7a f3 21 f0 	movw   $0x8,0xf021f37a
f01042a5:	08 00 
f01042a7:	c6 05 7c f3 21 f0 00 	movb   $0x0,0xf021f37c
f01042ae:	c6 05 7d f3 21 f0 8e 	movb   $0x8e,0xf021f37d
f01042b5:	c1 e8 10             	shr    $0x10,%eax
f01042b8:	66 a3 7e f3 21 f0    	mov    %ax,0xf021f37e
	extern void TH_IRQ_SERIAL();	SETGATE(idt[IRQ_OFFSET + 4], 0, GD_KT, TH_IRQ_SERIAL, 0);
f01042be:	b8 6c 4b 10 f0       	mov    $0xf0104b6c,%eax
f01042c3:	66 a3 80 f3 21 f0    	mov    %ax,0xf021f380
f01042c9:	66 c7 05 82 f3 21 f0 	movw   $0x8,0xf021f382
f01042d0:	08 00 
f01042d2:	c6 05 84 f3 21 f0 00 	movb   $0x0,0xf021f384
f01042d9:	c6 05 85 f3 21 f0 8e 	movb   $0x8e,0xf021f385
f01042e0:	c1 e8 10             	shr    $0x10,%eax
f01042e3:	66 a3 86 f3 21 f0    	mov    %ax,0xf021f386
	extern void TH_IRQ_5();		SETGATE(idt[IRQ_OFFSET + 5], 0, GD_KT, TH_IRQ_5, 0);
f01042e9:	b8 72 4b 10 f0       	mov    $0xf0104b72,%eax
f01042ee:	66 a3 88 f3 21 f0    	mov    %ax,0xf021f388
f01042f4:	66 c7 05 8a f3 21 f0 	movw   $0x8,0xf021f38a
f01042fb:	08 00 
f01042fd:	c6 05 8c f3 21 f0 00 	movb   $0x0,0xf021f38c
f0104304:	c6 05 8d f3 21 f0 8e 	movb   $0x8e,0xf021f38d
f010430b:	c1 e8 10             	shr    $0x10,%eax
f010430e:	66 a3 8e f3 21 f0    	mov    %ax,0xf021f38e
	extern void TH_IRQ_6();		SETGATE(idt[IRQ_OFFSET + 6], 0, GD_KT, TH_IRQ_6, 0);
f0104314:	b8 78 4b 10 f0       	mov    $0xf0104b78,%eax
f0104319:	66 a3 90 f3 21 f0    	mov    %ax,0xf021f390
f010431f:	66 c7 05 92 f3 21 f0 	movw   $0x8,0xf021f392
f0104326:	08 00 
f0104328:	c6 05 94 f3 21 f0 00 	movb   $0x0,0xf021f394
f010432f:	c6 05 95 f3 21 f0 8e 	movb   $0x8e,0xf021f395
f0104336:	c1 e8 10             	shr    $0x10,%eax
f0104339:	66 a3 96 f3 21 f0    	mov    %ax,0xf021f396
	extern void TH_IRQ_SPURIOUS();	SETGATE(idt[IRQ_OFFSET + 7], 0, GD_KT, TH_IRQ_SPURIOUS, 0);
f010433f:	b8 7e 4b 10 f0       	mov    $0xf0104b7e,%eax
f0104344:	66 a3 98 f3 21 f0    	mov    %ax,0xf021f398
f010434a:	66 c7 05 9a f3 21 f0 	movw   $0x8,0xf021f39a
f0104351:	08 00 
f0104353:	c6 05 9c f3 21 f0 00 	movb   $0x0,0xf021f39c
f010435a:	c6 05 9d f3 21 f0 8e 	movb   $0x8e,0xf021f39d
f0104361:	c1 e8 10             	shr    $0x10,%eax
f0104364:	66 a3 9e f3 21 f0    	mov    %ax,0xf021f39e
	extern void TH_IRQ_8();		SETGATE(idt[IRQ_OFFSET + 8], 0, GD_KT, TH_IRQ_8, 0);
f010436a:	b8 84 4b 10 f0       	mov    $0xf0104b84,%eax
f010436f:	66 a3 a0 f3 21 f0    	mov    %ax,0xf021f3a0
f0104375:	66 c7 05 a2 f3 21 f0 	movw   $0x8,0xf021f3a2
f010437c:	08 00 
f010437e:	c6 05 a4 f3 21 f0 00 	movb   $0x0,0xf021f3a4
f0104385:	c6 05 a5 f3 21 f0 8e 	movb   $0x8e,0xf021f3a5
f010438c:	c1 e8 10             	shr    $0x10,%eax
f010438f:	66 a3 a6 f3 21 f0    	mov    %ax,0xf021f3a6
	extern void TH_IRQ_9();		SETGATE(idt[IRQ_OFFSET + 9], 0, GD_KT, TH_IRQ_9, 0);
f0104395:	b8 8a 4b 10 f0       	mov    $0xf0104b8a,%eax
f010439a:	66 a3 a8 f3 21 f0    	mov    %ax,0xf021f3a8
f01043a0:	66 c7 05 aa f3 21 f0 	movw   $0x8,0xf021f3aa
f01043a7:	08 00 
f01043a9:	c6 05 ac f3 21 f0 00 	movb   $0x0,0xf021f3ac
f01043b0:	c6 05 ad f3 21 f0 8e 	movb   $0x8e,0xf021f3ad
f01043b7:	c1 e8 10             	shr    $0x10,%eax
f01043ba:	66 a3 ae f3 21 f0    	mov    %ax,0xf021f3ae
	extern void TH_IRQ_10();	SETGATE(idt[IRQ_OFFSET + 10], 0, GD_KT, TH_IRQ_10, 0);
f01043c0:	b8 90 4b 10 f0       	mov    $0xf0104b90,%eax
f01043c5:	66 a3 b0 f3 21 f0    	mov    %ax,0xf021f3b0
f01043cb:	66 c7 05 b2 f3 21 f0 	movw   $0x8,0xf021f3b2
f01043d2:	08 00 
f01043d4:	c6 05 b4 f3 21 f0 00 	movb   $0x0,0xf021f3b4
f01043db:	c6 05 b5 f3 21 f0 8e 	movb   $0x8e,0xf021f3b5
f01043e2:	c1 e8 10             	shr    $0x10,%eax
f01043e5:	66 a3 b6 f3 21 f0    	mov    %ax,0xf021f3b6
	extern void TH_IRQ_11();	SETGATE(idt[IRQ_OFFSET + 11], 0, GD_KT, TH_IRQ_11, 0);
f01043eb:	b8 96 4b 10 f0       	mov    $0xf0104b96,%eax
f01043f0:	66 a3 b8 f3 21 f0    	mov    %ax,0xf021f3b8
f01043f6:	66 c7 05 ba f3 21 f0 	movw   $0x8,0xf021f3ba
f01043fd:	08 00 
f01043ff:	c6 05 bc f3 21 f0 00 	movb   $0x0,0xf021f3bc
f0104406:	c6 05 bd f3 21 f0 8e 	movb   $0x8e,0xf021f3bd
f010440d:	c1 e8 10             	shr    $0x10,%eax
f0104410:	66 a3 be f3 21 f0    	mov    %ax,0xf021f3be
	extern void TH_IRQ_12();	SETGATE(idt[IRQ_OFFSET + 12], 0, GD_KT, TH_IRQ_12, 0);
f0104416:	b8 9c 4b 10 f0       	mov    $0xf0104b9c,%eax
f010441b:	66 a3 c0 f3 21 f0    	mov    %ax,0xf021f3c0
f0104421:	66 c7 05 c2 f3 21 f0 	movw   $0x8,0xf021f3c2
f0104428:	08 00 
f010442a:	c6 05 c4 f3 21 f0 00 	movb   $0x0,0xf021f3c4
f0104431:	c6 05 c5 f3 21 f0 8e 	movb   $0x8e,0xf021f3c5
f0104438:	c1 e8 10             	shr    $0x10,%eax
f010443b:	66 a3 c6 f3 21 f0    	mov    %ax,0xf021f3c6
	extern void TH_IRQ_13();	SETGATE(idt[IRQ_OFFSET + 13], 0, GD_KT, TH_IRQ_13, 0);
f0104441:	b8 a2 4b 10 f0       	mov    $0xf0104ba2,%eax
f0104446:	66 a3 c8 f3 21 f0    	mov    %ax,0xf021f3c8
f010444c:	66 c7 05 ca f3 21 f0 	movw   $0x8,0xf021f3ca
f0104453:	08 00 
f0104455:	c6 05 cc f3 21 f0 00 	movb   $0x0,0xf021f3cc
f010445c:	c6 05 cd f3 21 f0 8e 	movb   $0x8e,0xf021f3cd
f0104463:	c1 e8 10             	shr    $0x10,%eax
f0104466:	66 a3 ce f3 21 f0    	mov    %ax,0xf021f3ce
	extern void TH_IRQ_IDE();	SETGATE(idt[IRQ_OFFSET + 14], 0, GD_KT, TH_IRQ_IDE, 0);
f010446c:	b8 a8 4b 10 f0       	mov    $0xf0104ba8,%eax
f0104471:	66 a3 d0 f3 21 f0    	mov    %ax,0xf021f3d0
f0104477:	66 c7 05 d2 f3 21 f0 	movw   $0x8,0xf021f3d2
f010447e:	08 00 
f0104480:	c6 05 d4 f3 21 f0 00 	movb   $0x0,0xf021f3d4
f0104487:	c6 05 d5 f3 21 f0 8e 	movb   $0x8e,0xf021f3d5
f010448e:	c1 e8 10             	shr    $0x10,%eax
f0104491:	66 a3 d6 f3 21 f0    	mov    %ax,0xf021f3d6
	extern void TH_IRQ_15();	SETGATE(idt[IRQ_OFFSET + 15], 0, GD_KT, TH_IRQ_15, 0);
f0104497:	b8 ae 4b 10 f0       	mov    $0xf0104bae,%eax
f010449c:	66 a3 d8 f3 21 f0    	mov    %ax,0xf021f3d8
f01044a2:	66 c7 05 da f3 21 f0 	movw   $0x8,0xf021f3da
f01044a9:	08 00 
f01044ab:	c6 05 dc f3 21 f0 00 	movb   $0x0,0xf021f3dc
f01044b2:	c6 05 dd f3 21 f0 8e 	movb   $0x8e,0xf021f3dd
f01044b9:	c1 e8 10             	shr    $0x10,%eax
f01044bc:	66 a3 de f3 21 f0    	mov    %ax,0xf021f3de

	// Per-CPU setup 
	trap_init_percpu();
f01044c2:	e8 2d f9 ff ff       	call   f0103df4 <trap_init_percpu>
}
f01044c7:	c9                   	leave  
f01044c8:	c3                   	ret    

f01044c9 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01044c9:	55                   	push   %ebp
f01044ca:	89 e5                	mov    %esp,%ebp
f01044cc:	53                   	push   %ebx
f01044cd:	83 ec 0c             	sub    $0xc,%esp
f01044d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01044d3:	ff 33                	pushl  (%ebx)
f01044d5:	68 ff 80 10 f0       	push   $0xf01080ff
f01044da:	e8 01 f9 ff ff       	call   f0103de0 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01044df:	83 c4 08             	add    $0x8,%esp
f01044e2:	ff 73 04             	pushl  0x4(%ebx)
f01044e5:	68 0e 81 10 f0       	push   $0xf010810e
f01044ea:	e8 f1 f8 ff ff       	call   f0103de0 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01044ef:	83 c4 08             	add    $0x8,%esp
f01044f2:	ff 73 08             	pushl  0x8(%ebx)
f01044f5:	68 1d 81 10 f0       	push   $0xf010811d
f01044fa:	e8 e1 f8 ff ff       	call   f0103de0 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01044ff:	83 c4 08             	add    $0x8,%esp
f0104502:	ff 73 0c             	pushl  0xc(%ebx)
f0104505:	68 2c 81 10 f0       	push   $0xf010812c
f010450a:	e8 d1 f8 ff ff       	call   f0103de0 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010450f:	83 c4 08             	add    $0x8,%esp
f0104512:	ff 73 10             	pushl  0x10(%ebx)
f0104515:	68 3b 81 10 f0       	push   $0xf010813b
f010451a:	e8 c1 f8 ff ff       	call   f0103de0 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010451f:	83 c4 08             	add    $0x8,%esp
f0104522:	ff 73 14             	pushl  0x14(%ebx)
f0104525:	68 4a 81 10 f0       	push   $0xf010814a
f010452a:	e8 b1 f8 ff ff       	call   f0103de0 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010452f:	83 c4 08             	add    $0x8,%esp
f0104532:	ff 73 18             	pushl  0x18(%ebx)
f0104535:	68 59 81 10 f0       	push   $0xf0108159
f010453a:	e8 a1 f8 ff ff       	call   f0103de0 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010453f:	83 c4 08             	add    $0x8,%esp
f0104542:	ff 73 1c             	pushl  0x1c(%ebx)
f0104545:	68 68 81 10 f0       	push   $0xf0108168
f010454a:	e8 91 f8 ff ff       	call   f0103de0 <cprintf>
}
f010454f:	83 c4 10             	add    $0x10,%esp
f0104552:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104555:	c9                   	leave  
f0104556:	c3                   	ret    

f0104557 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0104557:	55                   	push   %ebp
f0104558:	89 e5                	mov    %esp,%ebp
f010455a:	56                   	push   %esi
f010455b:	53                   	push   %ebx
f010455c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f010455f:	e8 66 20 00 00       	call   f01065ca <cpunum>
f0104564:	83 ec 04             	sub    $0x4,%esp
f0104567:	50                   	push   %eax
f0104568:	53                   	push   %ebx
f0104569:	68 cc 81 10 f0       	push   $0xf01081cc
f010456e:	e8 6d f8 ff ff       	call   f0103de0 <cprintf>
	print_regs(&tf->tf_regs);
f0104573:	89 1c 24             	mov    %ebx,(%esp)
f0104576:	e8 4e ff ff ff       	call   f01044c9 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010457b:	83 c4 08             	add    $0x8,%esp
f010457e:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0104582:	50                   	push   %eax
f0104583:	68 ea 81 10 f0       	push   $0xf01081ea
f0104588:	e8 53 f8 ff ff       	call   f0103de0 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010458d:	83 c4 08             	add    $0x8,%esp
f0104590:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0104594:	50                   	push   %eax
f0104595:	68 fd 81 10 f0       	push   $0xf01081fd
f010459a:	e8 41 f8 ff ff       	call   f0103de0 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010459f:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f01045a2:	83 c4 10             	add    $0x10,%esp
f01045a5:	83 f8 13             	cmp    $0x13,%eax
f01045a8:	77 09                	ja     f01045b3 <print_trapframe+0x5c>
		return excnames[trapno];
f01045aa:	8b 14 85 a0 84 10 f0 	mov    -0xfef7b60(,%eax,4),%edx
f01045b1:	eb 1f                	jmp    f01045d2 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f01045b3:	83 f8 30             	cmp    $0x30,%eax
f01045b6:	74 15                	je     f01045cd <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01045b8:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f01045bb:	83 fa 10             	cmp    $0x10,%edx
f01045be:	b9 96 81 10 f0       	mov    $0xf0108196,%ecx
f01045c3:	ba 83 81 10 f0       	mov    $0xf0108183,%edx
f01045c8:	0f 43 d1             	cmovae %ecx,%edx
f01045cb:	eb 05                	jmp    f01045d2 <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f01045cd:	ba 77 81 10 f0       	mov    $0xf0108177,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01045d2:	83 ec 04             	sub    $0x4,%esp
f01045d5:	52                   	push   %edx
f01045d6:	50                   	push   %eax
f01045d7:	68 10 82 10 f0       	push   $0xf0108210
f01045dc:	e8 ff f7 ff ff       	call   f0103de0 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01045e1:	83 c4 10             	add    $0x10,%esp
f01045e4:	3b 1d 60 fa 21 f0    	cmp    0xf021fa60,%ebx
f01045ea:	75 1a                	jne    f0104606 <print_trapframe+0xaf>
f01045ec:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01045f0:	75 14                	jne    f0104606 <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f01045f2:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01045f5:	83 ec 08             	sub    $0x8,%esp
f01045f8:	50                   	push   %eax
f01045f9:	68 22 82 10 f0       	push   $0xf0108222
f01045fe:	e8 dd f7 ff ff       	call   f0103de0 <cprintf>
f0104603:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0104606:	83 ec 08             	sub    $0x8,%esp
f0104609:	ff 73 2c             	pushl  0x2c(%ebx)
f010460c:	68 31 82 10 f0       	push   $0xf0108231
f0104611:	e8 ca f7 ff ff       	call   f0103de0 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104616:	83 c4 10             	add    $0x10,%esp
f0104619:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010461d:	75 49                	jne    f0104668 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010461f:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0104622:	89 c2                	mov    %eax,%edx
f0104624:	83 e2 01             	and    $0x1,%edx
f0104627:	ba b0 81 10 f0       	mov    $0xf01081b0,%edx
f010462c:	b9 a5 81 10 f0       	mov    $0xf01081a5,%ecx
f0104631:	0f 44 ca             	cmove  %edx,%ecx
f0104634:	89 c2                	mov    %eax,%edx
f0104636:	83 e2 02             	and    $0x2,%edx
f0104639:	ba c2 81 10 f0       	mov    $0xf01081c2,%edx
f010463e:	be bc 81 10 f0       	mov    $0xf01081bc,%esi
f0104643:	0f 45 d6             	cmovne %esi,%edx
f0104646:	83 e0 04             	and    $0x4,%eax
f0104649:	be 29 83 10 f0       	mov    $0xf0108329,%esi
f010464e:	b8 c7 81 10 f0       	mov    $0xf01081c7,%eax
f0104653:	0f 44 c6             	cmove  %esi,%eax
f0104656:	51                   	push   %ecx
f0104657:	52                   	push   %edx
f0104658:	50                   	push   %eax
f0104659:	68 3f 82 10 f0       	push   $0xf010823f
f010465e:	e8 7d f7 ff ff       	call   f0103de0 <cprintf>
f0104663:	83 c4 10             	add    $0x10,%esp
f0104666:	eb 10                	jmp    f0104678 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104668:	83 ec 0c             	sub    $0xc,%esp
f010466b:	68 88 7e 10 f0       	push   $0xf0107e88
f0104670:	e8 6b f7 ff ff       	call   f0103de0 <cprintf>
f0104675:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104678:	83 ec 08             	sub    $0x8,%esp
f010467b:	ff 73 30             	pushl  0x30(%ebx)
f010467e:	68 4e 82 10 f0       	push   $0xf010824e
f0104683:	e8 58 f7 ff ff       	call   f0103de0 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104688:	83 c4 08             	add    $0x8,%esp
f010468b:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f010468f:	50                   	push   %eax
f0104690:	68 5d 82 10 f0       	push   $0xf010825d
f0104695:	e8 46 f7 ff ff       	call   f0103de0 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010469a:	83 c4 08             	add    $0x8,%esp
f010469d:	ff 73 38             	pushl  0x38(%ebx)
f01046a0:	68 70 82 10 f0       	push   $0xf0108270
f01046a5:	e8 36 f7 ff ff       	call   f0103de0 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01046aa:	83 c4 10             	add    $0x10,%esp
f01046ad:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01046b1:	74 25                	je     f01046d8 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01046b3:	83 ec 08             	sub    $0x8,%esp
f01046b6:	ff 73 3c             	pushl  0x3c(%ebx)
f01046b9:	68 7f 82 10 f0       	push   $0xf010827f
f01046be:	e8 1d f7 ff ff       	call   f0103de0 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01046c3:	83 c4 08             	add    $0x8,%esp
f01046c6:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01046ca:	50                   	push   %eax
f01046cb:	68 8e 82 10 f0       	push   $0xf010828e
f01046d0:	e8 0b f7 ff ff       	call   f0103de0 <cprintf>
f01046d5:	83 c4 10             	add    $0x10,%esp
	}
}
f01046d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01046db:	5b                   	pop    %ebx
f01046dc:	5e                   	pop    %esi
f01046dd:	5d                   	pop    %ebp
f01046de:	c3                   	ret    

f01046df <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01046df:	55                   	push   %ebp
f01046e0:	89 e5                	mov    %esp,%ebp
f01046e2:	57                   	push   %edi
f01046e3:	56                   	push   %esi
f01046e4:	53                   	push   %ebx
f01046e5:	83 ec 0c             	sub    $0xc,%esp
f01046e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01046eb:	0f 20 d6             	mov    %cr2,%esi

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.

	if ((tf->tf_cs & 3) == 0) {
f01046ee:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01046f2:	75 17                	jne    f010470b <page_fault_handler+0x2c>
		panic("kernel page fault\n");
f01046f4:	83 ec 04             	sub    $0x4,%esp
f01046f7:	68 a1 82 10 f0       	push   $0xf01082a1
f01046fc:	68 63 01 00 00       	push   $0x163
f0104701:	68 b4 82 10 f0       	push   $0xf01082b4
f0104706:	e8 35 b9 ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	if (curenv->env_pgfault_upcall) {
f010470b:	e8 ba 1e 00 00       	call   f01065ca <cpunum>
f0104710:	6b c0 74             	imul   $0x74,%eax,%eax
f0104713:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f0104719:	83 b8 c0 00 00 00 00 	cmpl   $0x0,0xc0(%eax)
f0104720:	0f 84 b0 00 00 00    	je     f01047d6 <page_fault_handler+0xf7>
		struct UTrapframe *utf;
		uintptr_t utf_va;
		if ((tf->tf_esp >= UXSTACKTOP - PGSIZE) && 
f0104726:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104729:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
		    (tf->tf_esp < UXSTACKTOP)) {
			utf_va = tf->tf_esp - sizeof(struct UTrapframe) - 4;
f010472f:	83 e8 38             	sub    $0x38,%eax
f0104732:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104738:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f010473d:	0f 46 d0             	cmovbe %eax,%edx
f0104740:	89 d7                	mov    %edx,%edi
		} else {
			utf_va = UXSTACKTOP - sizeof(struct UTrapframe);
		}
	
		user_mem_assert(curenv, (void*)utf_va, sizeof(struct UTrapframe), 					PTE_W);
f0104742:	e8 83 1e 00 00       	call   f01065ca <cpunum>
f0104747:	6a 02                	push   $0x2
f0104749:	6a 34                	push   $0x34
f010474b:	57                   	push   %edi
f010474c:	6b c0 74             	imul   $0x74,%eax,%eax
f010474f:	ff b0 28 00 22 f0    	pushl  -0xfddffd8(%eax)
f0104755:	e8 5b e8 ff ff       	call   f0102fb5 <user_mem_assert>
		utf = (struct UTrapframe*) utf_va;

		utf->utf_fault_va = fault_va;
f010475a:	89 fa                	mov    %edi,%edx
f010475c:	89 37                	mov    %esi,(%edi)
		utf->utf_err = tf->tf_err;
f010475e:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104761:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs = tf->tf_regs;
f0104764:	8d 7f 08             	lea    0x8(%edi),%edi
f0104767:	b9 08 00 00 00       	mov    $0x8,%ecx
f010476c:	89 de                	mov    %ebx,%esi
f010476e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f0104770:	8b 43 30             	mov    0x30(%ebx),%eax
f0104773:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f0104776:	8b 43 38             	mov    0x38(%ebx),%eax
f0104779:	89 d7                	mov    %edx,%edi
f010477b:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f010477e:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104781:	89 42 30             	mov    %eax,0x30(%edx)

		curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0104784:	e8 41 1e 00 00       	call   f01065ca <cpunum>
f0104789:	6b c0 74             	imul   $0x74,%eax,%eax
f010478c:	8b 98 28 00 22 f0    	mov    -0xfddffd8(%eax),%ebx
f0104792:	e8 33 1e 00 00       	call   f01065ca <cpunum>
f0104797:	6b c0 74             	imul   $0x74,%eax,%eax
f010479a:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f01047a0:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
f01047a6:	89 83 89 00 00 00    	mov    %eax,0x89(%ebx)
		curenv->env_tf.tf_esp = utf_va;
f01047ac:	e8 19 1e 00 00       	call   f01065ca <cpunum>
f01047b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01047b4:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f01047ba:	89 b8 95 00 00 00    	mov    %edi,0x95(%eax)
		env_run(curenv);
f01047c0:	e8 05 1e 00 00       	call   f01065ca <cpunum>
f01047c5:	83 c4 04             	add    $0x4,%esp
f01047c8:	6b c0 74             	imul   $0x74,%eax,%eax
f01047cb:	ff b0 28 00 22 f0    	pushl  -0xfddffd8(%eax)
f01047d1:	e8 1c f1 ff ff       	call   f01038f2 <env_run>
	}


	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01047d6:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01047d9:	e8 ec 1d 00 00       	call   f01065ca <cpunum>
		env_run(curenv);
	}


	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01047de:	57                   	push   %edi
f01047df:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f01047e0:	6b c0 74             	imul   $0x74,%eax,%eax
		env_run(curenv);
	}


	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01047e3:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f01047e9:	ff b0 a4 00 00 00    	pushl  0xa4(%eax)
f01047ef:	68 74 84 10 f0       	push   $0xf0108474
f01047f4:	e8 e7 f5 ff ff       	call   f0103de0 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01047f9:	89 1c 24             	mov    %ebx,(%esp)
f01047fc:	e8 56 fd ff ff       	call   f0104557 <print_trapframe>
	env_destroy(curenv);
f0104801:	e8 c4 1d 00 00       	call   f01065ca <cpunum>
f0104806:	83 c4 04             	add    $0x4,%esp
f0104809:	6b c0 74             	imul   $0x74,%eax,%eax
f010480c:	ff b0 28 00 22 f0    	pushl  -0xfddffd8(%eax)
f0104812:	e8 e8 ef ff ff       	call   f01037ff <env_destroy>
}
f0104817:	83 c4 10             	add    $0x10,%esp
f010481a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010481d:	5b                   	pop    %ebx
f010481e:	5e                   	pop    %esi
f010481f:	5f                   	pop    %edi
f0104820:	5d                   	pop    %ebp
f0104821:	c3                   	ret    

f0104822 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104822:	55                   	push   %ebp
f0104823:	89 e5                	mov    %esp,%ebp
f0104825:	57                   	push   %edi
f0104826:	56                   	push   %esi
f0104827:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f010482a:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f010482b:	83 3d 80 fe 21 f0 00 	cmpl   $0x0,0xf021fe80
f0104832:	74 01                	je     f0104835 <trap+0x13>
		asm volatile("hlt");
f0104834:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104835:	e8 90 1d 00 00       	call   f01065ca <cpunum>
f010483a:	6b d0 74             	imul   $0x74,%eax,%edx
f010483d:	81 c2 20 00 22 f0    	add    $0xf0220020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104843:	b8 01 00 00 00       	mov    $0x1,%eax
f0104848:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010484c:	83 f8 02             	cmp    $0x2,%eax
f010484f:	75 10                	jne    f0104861 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104851:	83 ec 0c             	sub    $0xc,%esp
f0104854:	68 c0 23 12 f0       	push   $0xf01223c0
f0104859:	e8 da 1f 00 00       	call   f0106838 <spin_lock>
f010485e:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104861:	9c                   	pushf  
f0104862:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104863:	f6 c4 02             	test   $0x2,%ah
f0104866:	74 19                	je     f0104881 <trap+0x5f>
f0104868:	68 c0 82 10 f0       	push   $0xf01082c0
f010486d:	68 94 7b 10 f0       	push   $0xf0107b94
f0104872:	68 26 01 00 00       	push   $0x126
f0104877:	68 b4 82 10 f0       	push   $0xf01082b4
f010487c:	e8 bf b7 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104881:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104885:	83 e0 03             	and    $0x3,%eax
f0104888:	66 83 f8 03          	cmp    $0x3,%ax
f010488c:	0f 85 ea 00 00 00    	jne    f010497c <trap+0x15a>
f0104892:	83 ec 0c             	sub    $0xc,%esp
f0104895:	68 c0 23 12 f0       	push   $0xf01223c0
f010489a:	e8 99 1f 00 00       	call   f0106838 <spin_lock>
		// serious kernel work.
		// LAB 4: Your code here.

		lock_kernel();

		assert(curenv);
f010489f:	e8 26 1d 00 00       	call   f01065ca <cpunum>
f01048a4:	6b c0 74             	imul   $0x74,%eax,%eax
f01048a7:	83 c4 10             	add    $0x10,%esp
f01048aa:	83 b8 28 00 22 f0 00 	cmpl   $0x0,-0xfddffd8(%eax)
f01048b1:	75 19                	jne    f01048cc <trap+0xaa>
f01048b3:	68 d9 82 10 f0       	push   $0xf01082d9
f01048b8:	68 94 7b 10 f0       	push   $0xf0107b94
f01048bd:	68 30 01 00 00       	push   $0x130
f01048c2:	68 b4 82 10 f0       	push   $0xf01082b4
f01048c7:	e8 74 b7 ff ff       	call   f0100040 <_panic>
		/*Lab 7: Multithreading*/
		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01048cc:	e8 f9 1c 00 00       	call   f01065ca <cpunum>
f01048d1:	6b c0 74             	imul   $0x74,%eax,%eax
f01048d4:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f01048da:	83 b8 b0 00 00 00 01 	cmpl   $0x1,0xb0(%eax)
f01048e1:	75 70                	jne    f0104953 <trap+0x131>
			if (curenv->env_id == curenv->env_process_id) {
f01048e3:	e8 e2 1c 00 00       	call   f01065ca <cpunum>
f01048e8:	6b c0 74             	imul   $0x74,%eax,%eax
f01048eb:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f01048f1:	8b b0 a4 00 00 00    	mov    0xa4(%eax),%esi
f01048f7:	e8 ce 1c 00 00       	call   f01065ca <cpunum>
f01048fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01048ff:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f0104905:	3b 30                	cmp    (%eax),%esi
f0104907:	75 1b                	jne    f0104924 <trap+0x102>
			 	env_free(curenv);
f0104909:	e8 bc 1c 00 00       	call   f01065ca <cpunum>
f010490e:	83 ec 0c             	sub    $0xc,%esp
f0104911:	6b c0 74             	imul   $0x74,%eax,%eax
f0104914:	ff b0 28 00 22 f0    	pushl  -0xfddffd8(%eax)
f010491a:	e8 54 ec ff ff       	call   f0103573 <env_free>
f010491f:	83 c4 10             	add    $0x10,%esp
f0104922:	eb 18                	jmp    f010493c <trap+0x11a>
			} else {
				curenv->env_status = ENV_FREE;
f0104924:	e8 a1 1c 00 00       	call   f01065ca <cpunum>
f0104929:	6b c0 74             	imul   $0x74,%eax,%eax
f010492c:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f0104932:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
f0104939:	00 00 00 
			}
			curenv = NULL;
f010493c:	e8 89 1c 00 00       	call   f01065ca <cpunum>
f0104941:	6b c0 74             	imul   $0x74,%eax,%eax
f0104944:	c7 80 28 00 22 f0 00 	movl   $0x0,-0xfddffd8(%eax)
f010494b:	00 00 00 
			sched_yield();
f010494e:	e8 53 03 00 00       	call   f0104ca6 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104953:	e8 72 1c 00 00       	call   f01065ca <cpunum>
f0104958:	6b c0 74             	imul   $0x74,%eax,%eax
f010495b:	8b b8 28 00 22 f0    	mov    -0xfddffd8(%eax),%edi
f0104961:	83 c7 59             	add    $0x59,%edi
f0104964:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104969:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f010496b:	e8 5a 1c 00 00       	call   f01065ca <cpunum>
f0104970:	6b c0 74             	imul   $0x74,%eax,%eax
f0104973:	8b b0 28 00 22 f0    	mov    -0xfddffd8(%eax),%esi
f0104979:	83 c6 59             	add    $0x59,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f010497c:	89 35 60 fa 21 f0    	mov    %esi,0xf021fa60
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	switch (tf->tf_trapno) {	
f0104982:	8b 46 28             	mov    0x28(%esi),%eax
f0104985:	83 f8 0e             	cmp    $0xe,%eax
f0104988:	74 0c                	je     f0104996 <trap+0x174>
f010498a:	83 f8 30             	cmp    $0x30,%eax
f010498d:	74 38                	je     f01049c7 <trap+0x1a5>
f010498f:	83 f8 03             	cmp    $0x3,%eax
f0104992:	75 57                	jne    f01049eb <trap+0x1c9>
f0104994:	eb 11                	jmp    f01049a7 <trap+0x185>
	case T_PGFLT:
		page_fault_handler(tf);
f0104996:	83 ec 0c             	sub    $0xc,%esp
f0104999:	56                   	push   %esi
f010499a:	e8 40 fd ff ff       	call   f01046df <page_fault_handler>
f010499f:	83 c4 10             	add    $0x10,%esp
f01049a2:	e9 cd 00 00 00       	jmp    f0104a74 <trap+0x252>
		return;
	case T_BRKPT:
		print_trapframe(tf);
f01049a7:	83 ec 0c             	sub    $0xc,%esp
f01049aa:	56                   	push   %esi
f01049ab:	e8 a7 fb ff ff       	call   f0104557 <print_trapframe>
		panic("tf->tf_trapno == T_BRKPT\n");
f01049b0:	83 c4 0c             	add    $0xc,%esp
f01049b3:	68 e0 82 10 f0       	push   $0xf01082e0
f01049b8:	68 e0 00 00 00       	push   $0xe0
f01049bd:	68 b4 82 10 f0       	push   $0xf01082b4
f01049c2:	e8 79 b6 ff ff       	call   f0100040 <_panic>
		return;
	case T_SYSCALL:
		tf->tf_regs.reg_eax = syscall(
f01049c7:	83 ec 08             	sub    $0x8,%esp
f01049ca:	ff 76 04             	pushl  0x4(%esi)
f01049cd:	ff 36                	pushl  (%esi)
f01049cf:	ff 76 10             	pushl  0x10(%esi)
f01049d2:	ff 76 18             	pushl  0x18(%esi)
f01049d5:	ff 76 14             	pushl  0x14(%esi)
f01049d8:	ff 76 1c             	pushl  0x1c(%esi)
f01049db:	e8 f6 03 00 00       	call   f0104dd6 <syscall>
f01049e0:	89 46 1c             	mov    %eax,0x1c(%esi)
f01049e3:	83 c4 20             	add    $0x20,%esp
f01049e6:	e9 89 00 00 00       	jmp    f0104a74 <trap+0x252>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01049eb:	83 f8 27             	cmp    $0x27,%eax
f01049ee:	75 1a                	jne    f0104a0a <trap+0x1e8>
		cprintf("Spurious interrupt on irq 7\n");
f01049f0:	83 ec 0c             	sub    $0xc,%esp
f01049f3:	68 fa 82 10 f0       	push   $0xf01082fa
f01049f8:	e8 e3 f3 ff ff       	call   f0103de0 <cprintf>
		print_trapframe(tf);
f01049fd:	89 34 24             	mov    %esi,(%esp)
f0104a00:	e8 52 fb ff ff       	call   f0104557 <print_trapframe>
f0104a05:	83 c4 10             	add    $0x10,%esp
f0104a08:	eb 6a                	jmp    f0104a74 <trap+0x252>

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f0104a0a:	83 f8 20             	cmp    $0x20,%eax
f0104a0d:	75 0a                	jne    f0104a19 <trap+0x1f7>
		lapic_eoi();
f0104a0f:	e8 01 1d 00 00       	call   f0106715 <lapic_eoi>
		sched_yield();
f0104a14:	e8 8d 02 00 00       	call   f0104ca6 <sched_yield>
	}

	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.

	if (tf->tf_trapno == (IRQ_OFFSET + IRQ_KBD)) {
f0104a19:	83 f8 21             	cmp    $0x21,%eax
f0104a1c:	75 07                	jne    f0104a25 <trap+0x203>
		kbd_intr();
f0104a1e:	e8 d4 bb ff ff       	call   f01005f7 <kbd_intr>
f0104a23:	eb 4f                	jmp    f0104a74 <trap+0x252>
		return;
	}

	if (tf->tf_trapno == (IRQ_OFFSET + IRQ_SERIAL)) {
f0104a25:	83 f8 24             	cmp    $0x24,%eax
f0104a28:	75 07                	jne    f0104a31 <trap+0x20f>
		serial_intr();
f0104a2a:	e8 ac bb ff ff       	call   f01005db <serial_intr>
f0104a2f:	eb 43                	jmp    f0104a74 <trap+0x252>
		return;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104a31:	83 ec 0c             	sub    $0xc,%esp
f0104a34:	56                   	push   %esi
f0104a35:	e8 1d fb ff ff       	call   f0104557 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104a3a:	83 c4 10             	add    $0x10,%esp
f0104a3d:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104a42:	75 17                	jne    f0104a5b <trap+0x239>
		panic("unhandled trap in kernel");
f0104a44:	83 ec 04             	sub    $0x4,%esp
f0104a47:	68 17 83 10 f0       	push   $0xf0108317
f0104a4c:	68 0c 01 00 00       	push   $0x10c
f0104a51:	68 b4 82 10 f0       	push   $0xf01082b4
f0104a56:	e8 e5 b5 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104a5b:	e8 6a 1b 00 00       	call   f01065ca <cpunum>
f0104a60:	83 ec 0c             	sub    $0xc,%esp
f0104a63:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a66:	ff b0 28 00 22 f0    	pushl  -0xfddffd8(%eax)
f0104a6c:	e8 8e ed ff ff       	call   f01037ff <env_destroy>
f0104a71:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104a74:	e8 51 1b 00 00       	call   f01065ca <cpunum>
f0104a79:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a7c:	83 b8 28 00 22 f0 00 	cmpl   $0x0,-0xfddffd8(%eax)
f0104a83:	74 2d                	je     f0104ab2 <trap+0x290>
f0104a85:	e8 40 1b 00 00       	call   f01065ca <cpunum>
f0104a8a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a8d:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f0104a93:	83 b8 b0 00 00 00 03 	cmpl   $0x3,0xb0(%eax)
f0104a9a:	75 16                	jne    f0104ab2 <trap+0x290>
		env_run(curenv);
f0104a9c:	e8 29 1b 00 00       	call   f01065ca <cpunum>
f0104aa1:	83 ec 0c             	sub    $0xc,%esp
f0104aa4:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aa7:	ff b0 28 00 22 f0    	pushl  -0xfddffd8(%eax)
f0104aad:	e8 40 ee ff ff       	call   f01038f2 <env_run>
	else
		sched_yield();
f0104ab2:	e8 ef 01 00 00       	call   f0104ca6 <sched_yield>
f0104ab7:	90                   	nop

f0104ab8 <TH_DIVIDE>:
	.p2align 2
	.globl TRAPHANDLERS
TRAPHANDLERS:
.text

TRAPHANDLER_NOEC(TH_DIVIDE, T_DIVIDE)	// fault
f0104ab8:	6a 00                	push   $0x0
f0104aba:	6a 00                	push   $0x0
f0104abc:	e9 f9 00 00 00       	jmp    f0104bba <_alltraps>
f0104ac1:	90                   	nop

f0104ac2 <TH_DEBUG>:
TRAPHANDLER_NOEC(TH_DEBUG, T_DEBUG)	// fault/trap
f0104ac2:	6a 00                	push   $0x0
f0104ac4:	6a 01                	push   $0x1
f0104ac6:	e9 ef 00 00 00       	jmp    f0104bba <_alltraps>
f0104acb:	90                   	nop

f0104acc <TH_NMI>:
TRAPHANDLER_NOEC(TH_NMI, T_NMI)		//
f0104acc:	6a 00                	push   $0x0
f0104ace:	6a 02                	push   $0x2
f0104ad0:	e9 e5 00 00 00       	jmp    f0104bba <_alltraps>
f0104ad5:	90                   	nop

f0104ad6 <TH_BRKPT>:
TRAPHANDLER_NOEC(TH_BRKPT, T_BRKPT)	// trap
f0104ad6:	6a 00                	push   $0x0
f0104ad8:	6a 03                	push   $0x3
f0104ada:	e9 db 00 00 00       	jmp    f0104bba <_alltraps>
f0104adf:	90                   	nop

f0104ae0 <TH_OFLOW>:
TRAPHANDLER_NOEC(TH_OFLOW, T_OFLOW)	// trap
f0104ae0:	6a 00                	push   $0x0
f0104ae2:	6a 04                	push   $0x4
f0104ae4:	e9 d1 00 00 00       	jmp    f0104bba <_alltraps>
f0104ae9:	90                   	nop

f0104aea <TH_BOUND>:
TRAPHANDLER_NOEC(TH_BOUND, T_BOUND)	// fault
f0104aea:	6a 00                	push   $0x0
f0104aec:	6a 05                	push   $0x5
f0104aee:	e9 c7 00 00 00       	jmp    f0104bba <_alltraps>
f0104af3:	90                   	nop

f0104af4 <TH_ILLOP>:
TRAPHANDLER_NOEC(TH_ILLOP, T_ILLOP)	// fault
f0104af4:	6a 00                	push   $0x0
f0104af6:	6a 06                	push   $0x6
f0104af8:	e9 bd 00 00 00       	jmp    f0104bba <_alltraps>
f0104afd:	90                   	nop

f0104afe <TH_DEVICE>:
TRAPHANDLER_NOEC(TH_DEVICE, T_DEVICE)	// fault
f0104afe:	6a 00                	push   $0x0
f0104b00:	6a 07                	push   $0x7
f0104b02:	e9 b3 00 00 00       	jmp    f0104bba <_alltraps>
f0104b07:	90                   	nop

f0104b08 <TH_DBLFLT>:
TRAPHANDLER     (TH_DBLFLT, T_DBLFLT)	// abort
f0104b08:	6a 08                	push   $0x8
f0104b0a:	e9 ab 00 00 00       	jmp    f0104bba <_alltraps>
f0104b0f:	90                   	nop

f0104b10 <TH_TSS>:
//TRAPHANDLER_NOEC(TH_COPROC, T_COPROC) // abort	
TRAPHANDLER     (TH_TSS, T_TSS)		// fault
f0104b10:	6a 0a                	push   $0xa
f0104b12:	e9 a3 00 00 00       	jmp    f0104bba <_alltraps>
f0104b17:	90                   	nop

f0104b18 <TH_SEGNP>:
TRAPHANDLER     (TH_SEGNP, T_SEGNP)	// fault
f0104b18:	6a 0b                	push   $0xb
f0104b1a:	e9 9b 00 00 00       	jmp    f0104bba <_alltraps>
f0104b1f:	90                   	nop

f0104b20 <TH_STACK>:
TRAPHANDLER     (TH_STACK, T_STACK)	// fault
f0104b20:	6a 0c                	push   $0xc
f0104b22:	e9 93 00 00 00       	jmp    f0104bba <_alltraps>
f0104b27:	90                   	nop

f0104b28 <TH_GPFLT>:
TRAPHANDLER     (TH_GPFLT, T_GPFLT)	// fault/abort
f0104b28:	6a 0d                	push   $0xd
f0104b2a:	e9 8b 00 00 00       	jmp    f0104bba <_alltraps>
f0104b2f:	90                   	nop

f0104b30 <TH_PGFLT>:
TRAPHANDLER     (TH_PGFLT, T_PGFLT)	// fault
f0104b30:	6a 0e                	push   $0xe
f0104b32:	e9 83 00 00 00       	jmp    f0104bba <_alltraps>
f0104b37:	90                   	nop

f0104b38 <TH_FPERR>:
//TRAPHANDLER_NOEC(TH_RES, T_RES)	
TRAPHANDLER_NOEC(TH_FPERR, T_FPERR)	// fault
f0104b38:	6a 00                	push   $0x0
f0104b3a:	6a 10                	push   $0x10
f0104b3c:	eb 7c                	jmp    f0104bba <_alltraps>

f0104b3e <TH_ALIGN>:
TRAPHANDLER     (TH_ALIGN, T_ALIGN)	//
f0104b3e:	6a 11                	push   $0x11
f0104b40:	eb 78                	jmp    f0104bba <_alltraps>

f0104b42 <TH_MCHK>:
TRAPHANDLER_NOEC(TH_MCHK, T_MCHK)	//
f0104b42:	6a 00                	push   $0x0
f0104b44:	6a 12                	push   $0x12
f0104b46:	eb 72                	jmp    f0104bba <_alltraps>

f0104b48 <TH_SIMDERR>:
TRAPHANDLER_NOEC(TH_SIMDERR, T_SIMDERR) //
f0104b48:	6a 00                	push   $0x0
f0104b4a:	6a 13                	push   $0x13
f0104b4c:	eb 6c                	jmp    f0104bba <_alltraps>

f0104b4e <TH_SYSCALL>:

TRAPHANDLER_NOEC(TH_SYSCALL, T_SYSCALL) // trap
f0104b4e:	6a 00                	push   $0x0
f0104b50:	6a 30                	push   $0x30
f0104b52:	eb 66                	jmp    f0104bba <_alltraps>

f0104b54 <TH_IRQ_TIMER>:

TRAPHANDLER_NOEC(TH_IRQ_TIMER, IRQ_OFFSET+IRQ_TIMER)	// 0
f0104b54:	6a 00                	push   $0x0
f0104b56:	6a 20                	push   $0x20
f0104b58:	eb 60                	jmp    f0104bba <_alltraps>

f0104b5a <TH_IRQ_KBD>:
TRAPHANDLER_NOEC(TH_IRQ_KBD, IRQ_OFFSET+IRQ_KBD)	// 1
f0104b5a:	6a 00                	push   $0x0
f0104b5c:	6a 21                	push   $0x21
f0104b5e:	eb 5a                	jmp    f0104bba <_alltraps>

f0104b60 <TH_IRQ_2>:
TRAPHANDLER_NOEC(TH_IRQ_2, IRQ_OFFSET+2)
f0104b60:	6a 00                	push   $0x0
f0104b62:	6a 22                	push   $0x22
f0104b64:	eb 54                	jmp    f0104bba <_alltraps>

f0104b66 <TH_IRQ_3>:
TRAPHANDLER_NOEC(TH_IRQ_3, IRQ_OFFSET+3)
f0104b66:	6a 00                	push   $0x0
f0104b68:	6a 23                	push   $0x23
f0104b6a:	eb 4e                	jmp    f0104bba <_alltraps>

f0104b6c <TH_IRQ_SERIAL>:
TRAPHANDLER_NOEC(TH_IRQ_SERIAL, IRQ_OFFSET+IRQ_SERIAL)	// 4
f0104b6c:	6a 00                	push   $0x0
f0104b6e:	6a 24                	push   $0x24
f0104b70:	eb 48                	jmp    f0104bba <_alltraps>

f0104b72 <TH_IRQ_5>:
TRAPHANDLER_NOEC(TH_IRQ_5, IRQ_OFFSET+5)
f0104b72:	6a 00                	push   $0x0
f0104b74:	6a 25                	push   $0x25
f0104b76:	eb 42                	jmp    f0104bba <_alltraps>

f0104b78 <TH_IRQ_6>:
TRAPHANDLER_NOEC(TH_IRQ_6, IRQ_OFFSET+6)
f0104b78:	6a 00                	push   $0x0
f0104b7a:	6a 26                	push   $0x26
f0104b7c:	eb 3c                	jmp    f0104bba <_alltraps>

f0104b7e <TH_IRQ_SPURIOUS>:
TRAPHANDLER_NOEC(TH_IRQ_SPURIOUS, IRQ_OFFSET+IRQ_SPURIOUS) // 7
f0104b7e:	6a 00                	push   $0x0
f0104b80:	6a 27                	push   $0x27
f0104b82:	eb 36                	jmp    f0104bba <_alltraps>

f0104b84 <TH_IRQ_8>:
TRAPHANDLER_NOEC(TH_IRQ_8, IRQ_OFFSET+8)
f0104b84:	6a 00                	push   $0x0
f0104b86:	6a 28                	push   $0x28
f0104b88:	eb 30                	jmp    f0104bba <_alltraps>

f0104b8a <TH_IRQ_9>:
TRAPHANDLER_NOEC(TH_IRQ_9, IRQ_OFFSET+9)
f0104b8a:	6a 00                	push   $0x0
f0104b8c:	6a 29                	push   $0x29
f0104b8e:	eb 2a                	jmp    f0104bba <_alltraps>

f0104b90 <TH_IRQ_10>:
TRAPHANDLER_NOEC(TH_IRQ_10, IRQ_OFFSET+10)
f0104b90:	6a 00                	push   $0x0
f0104b92:	6a 2a                	push   $0x2a
f0104b94:	eb 24                	jmp    f0104bba <_alltraps>

f0104b96 <TH_IRQ_11>:
TRAPHANDLER_NOEC(TH_IRQ_11, IRQ_OFFSET+11)
f0104b96:	6a 00                	push   $0x0
f0104b98:	6a 2b                	push   $0x2b
f0104b9a:	eb 1e                	jmp    f0104bba <_alltraps>

f0104b9c <TH_IRQ_12>:
TRAPHANDLER_NOEC(TH_IRQ_12, IRQ_OFFSET+12)
f0104b9c:	6a 00                	push   $0x0
f0104b9e:	6a 2c                	push   $0x2c
f0104ba0:	eb 18                	jmp    f0104bba <_alltraps>

f0104ba2 <TH_IRQ_13>:
TRAPHANDLER_NOEC(TH_IRQ_13, IRQ_OFFSET+13)
f0104ba2:	6a 00                	push   $0x0
f0104ba4:	6a 2d                	push   $0x2d
f0104ba6:	eb 12                	jmp    f0104bba <_alltraps>

f0104ba8 <TH_IRQ_IDE>:
TRAPHANDLER_NOEC(TH_IRQ_IDE, IRQ_OFFSET+IRQ_IDE)	// 14
f0104ba8:	6a 00                	push   $0x0
f0104baa:	6a 2e                	push   $0x2e
f0104bac:	eb 0c                	jmp    f0104bba <_alltraps>

f0104bae <TH_IRQ_15>:
TRAPHANDLER_NOEC(TH_IRQ_15, IRQ_OFFSET+15)
f0104bae:	6a 00                	push   $0x0
f0104bb0:	6a 2f                	push   $0x2f
f0104bb2:	eb 06                	jmp    f0104bba <_alltraps>

f0104bb4 <TH_IRQ_ERROR>:
TRAPHANDLER_NOEC(TH_IRQ_ERROR, IRQ_OFFSET+IRQ_ERROR)	// 19
f0104bb4:	6a 00                	push   $0x0
f0104bb6:	6a 33                	push   $0x33
f0104bb8:	eb 00                	jmp    f0104bba <_alltraps>

f0104bba <_alltraps>:
 * Lab 3: Your code here for _alltraps
 */

.text
_alltraps:
	pushl	%ds
f0104bba:	1e                   	push   %ds
	pushl	%es
f0104bbb:	06                   	push   %es
	pushal
f0104bbc:	60                   	pusha  
	mov	$GD_KD, %eax
f0104bbd:	b8 10 00 00 00       	mov    $0x10,%eax
	mov	%ax, %es
f0104bc2:	8e c0                	mov    %eax,%es
	mov	%ax, %ds
f0104bc4:	8e d8                	mov    %eax,%ds
	pushl	%esp
f0104bc6:	54                   	push   %esp
	call	trap
f0104bc7:	e8 56 fc ff ff       	call   f0104822 <trap>

f0104bcc <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104bcc:	55                   	push   %ebp
f0104bcd:	89 e5                	mov    %esp,%ebp
f0104bcf:	83 ec 08             	sub    $0x8,%esp
f0104bd2:	a1 4c f2 21 f0       	mov    0xf021f24c,%eax
f0104bd7:	8d 90 b0 00 00 00    	lea    0xb0(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104bdd:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104be2:	8b 02                	mov    (%edx),%eax
f0104be4:	83 e8 01             	sub    $0x1,%eax
f0104be7:	83 f8 02             	cmp    $0x2,%eax
f0104bea:	76 13                	jbe    f0104bff <sched_halt+0x33>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104bec:	83 c1 01             	add    $0x1,%ecx
f0104bef:	81 c2 d8 00 00 00    	add    $0xd8,%edx
f0104bf5:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104bfb:	75 e5                	jne    f0104be2 <sched_halt+0x16>
f0104bfd:	eb 08                	jmp    f0104c07 <sched_halt+0x3b>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104bff:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104c05:	75 1f                	jne    f0104c26 <sched_halt+0x5a>
		cprintf("No runnable environments in the system!\n");
f0104c07:	83 ec 0c             	sub    $0xc,%esp
f0104c0a:	68 f0 84 10 f0       	push   $0xf01084f0
f0104c0f:	e8 cc f1 ff ff       	call   f0103de0 <cprintf>
f0104c14:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104c17:	83 ec 0c             	sub    $0xc,%esp
f0104c1a:	6a 00                	push   $0x0
f0104c1c:	e8 34 bd ff ff       	call   f0100955 <monitor>
f0104c21:	83 c4 10             	add    $0x10,%esp
f0104c24:	eb f1                	jmp    f0104c17 <sched_halt+0x4b>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104c26:	e8 9f 19 00 00       	call   f01065ca <cpunum>
f0104c2b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c2e:	c7 80 28 00 22 f0 00 	movl   $0x0,-0xfddffd8(%eax)
f0104c35:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104c38:	a1 8c fe 21 f0       	mov    0xf021fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104c3d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104c42:	77 12                	ja     f0104c56 <sched_halt+0x8a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104c44:	50                   	push   %eax
f0104c45:	68 a8 6c 10 f0       	push   $0xf0106ca8
f0104c4a:	6a 54                	push   $0x54
f0104c4c:	68 19 85 10 f0       	push   $0xf0108519
f0104c51:	e8 ea b3 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104c56:	05 00 00 00 10       	add    $0x10000000,%eax
f0104c5b:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104c5e:	e8 67 19 00 00       	call   f01065ca <cpunum>
f0104c63:	6b d0 74             	imul   $0x74,%eax,%edx
f0104c66:	81 c2 20 00 22 f0    	add    $0xf0220020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104c6c:	b8 02 00 00 00       	mov    $0x2,%eax
f0104c71:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104c75:	83 ec 0c             	sub    $0xc,%esp
f0104c78:	68 c0 23 12 f0       	push   $0xf01223c0
f0104c7d:	e8 53 1c 00 00       	call   f01068d5 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104c82:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104c84:	e8 41 19 00 00       	call   f01065ca <cpunum>
f0104c89:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104c8c:	8b 80 30 00 22 f0    	mov    -0xfddffd0(%eax),%eax
f0104c92:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104c97:	89 c4                	mov    %eax,%esp
f0104c99:	6a 00                	push   $0x0
f0104c9b:	6a 00                	push   $0x0
f0104c9d:	fb                   	sti    
f0104c9e:	f4                   	hlt    
f0104c9f:	eb fd                	jmp    f0104c9e <sched_halt+0xd2>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104ca1:	83 c4 10             	add    $0x10,%esp
f0104ca4:	c9                   	leave  
f0104ca5:	c3                   	ret    

f0104ca6 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104ca6:	55                   	push   %ebp
f0104ca7:	89 e5                	mov    %esp,%ebp
f0104ca9:	53                   	push   %ebx
f0104caa:	83 ec 04             	sub    $0x4,%esp
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	size_t i;
	if (!curenv) {
f0104cad:	e8 18 19 00 00       	call   f01065ca <cpunum>
f0104cb2:	6b c0 74             	imul   $0x74,%eax,%eax
		i = 0;
f0104cb5:	ba 00 00 00 00       	mov    $0x0,%edx
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	size_t i;
	if (!curenv) {
f0104cba:	83 b8 28 00 22 f0 00 	cmpl   $0x0,-0xfddffd8(%eax)
f0104cc1:	74 1d                	je     f0104ce0 <sched_yield+0x3a>
		i = 0;
	} else {
		i = ENVX(curenv->env_id) + 1;
f0104cc3:	e8 02 19 00 00       	call   f01065ca <cpunum>
f0104cc8:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ccb:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f0104cd1:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
f0104cd7:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0104cdd:	83 c2 01             	add    $0x1,%edx
	}
	
	for (; i < NENV; i++) {
		if (envs[i].env_status == ENV_RUNNABLE) {
f0104ce0:	a1 4c f2 21 f0       	mov    0xf021f24c,%eax
f0104ce5:	69 ca d8 00 00 00    	imul   $0xd8,%edx,%ecx
f0104ceb:	01 c1                	add    %eax,%ecx
f0104ced:	eb 1a                	jmp    f0104d09 <sched_yield+0x63>
f0104cef:	89 cb                	mov    %ecx,%ebx
f0104cf1:	81 c1 d8 00 00 00    	add    $0xd8,%ecx
f0104cf7:	83 79 d8 02          	cmpl   $0x2,-0x28(%ecx)
f0104cfb:	75 09                	jne    f0104d06 <sched_yield+0x60>
			env_run(&envs[i]);
f0104cfd:	83 ec 0c             	sub    $0xc,%esp
f0104d00:	53                   	push   %ebx
f0104d01:	e8 ec eb ff ff       	call   f01038f2 <env_run>
		i = 0;
	} else {
		i = ENVX(curenv->env_id) + 1;
	}
	
	for (; i < NENV; i++) {
f0104d06:	83 c2 01             	add    $0x1,%edx
f0104d09:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
f0104d0f:	76 de                	jbe    f0104cef <sched_yield+0x49>
f0104d11:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104d16:	eb 19                	jmp    f0104d31 <sched_yield+0x8b>
	}

	size_t j;

	for (j = 0; j < i; j++) {
		if (envs[j].env_status == ENV_RUNNABLE) {
f0104d18:	89 c3                	mov    %eax,%ebx
f0104d1a:	05 d8 00 00 00       	add    $0xd8,%eax
f0104d1f:	83 78 d8 02          	cmpl   $0x2,-0x28(%eax)
f0104d23:	75 09                	jne    f0104d2e <sched_yield+0x88>
			env_run(&envs[j]);
f0104d25:	83 ec 0c             	sub    $0xc,%esp
f0104d28:	53                   	push   %ebx
f0104d29:	e8 c4 eb ff ff       	call   f01038f2 <env_run>
		} 
	}

	size_t j;

	for (j = 0; j < i; j++) {
f0104d2e:	83 c1 01             	add    $0x1,%ecx
f0104d31:	39 ca                	cmp    %ecx,%edx
f0104d33:	75 e3                	jne    f0104d18 <sched_yield+0x72>
		if (envs[j].env_status == ENV_RUNNABLE) {
			env_run(&envs[j]);
		} 
	}

	if (curenv && (curenv->env_status == ENV_RUNNING)) {
f0104d35:	e8 90 18 00 00       	call   f01065ca <cpunum>
f0104d3a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d3d:	83 b8 28 00 22 f0 00 	cmpl   $0x0,-0xfddffd8(%eax)
f0104d44:	74 2d                	je     f0104d73 <sched_yield+0xcd>
f0104d46:	e8 7f 18 00 00       	call   f01065ca <cpunum>
f0104d4b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d4e:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f0104d54:	83 b8 b0 00 00 00 03 	cmpl   $0x3,0xb0(%eax)
f0104d5b:	75 16                	jne    f0104d73 <sched_yield+0xcd>
		env_run(curenv);
f0104d5d:	e8 68 18 00 00       	call   f01065ca <cpunum>
f0104d62:	83 ec 0c             	sub    $0xc,%esp
f0104d65:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d68:	ff b0 28 00 22 f0    	pushl  -0xfddffd8(%eax)
f0104d6e:	e8 7f eb ff ff       	call   f01038f2 <env_run>
	}
	// sched_halt never returns
	sched_halt();
f0104d73:	e8 54 fe ff ff       	call   f0104bcc <sched_halt>
}
f0104d78:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104d7b:	c9                   	leave  
f0104d7c:	c3                   	ret    

f0104d7d <sys_thread_create>:

// Lab 7 Multithreading 
// zavola tvorbu noveho threadu (z env.c)
envid_t	
sys_thread_create(uintptr_t func)
{
f0104d7d:	55                   	push   %ebp
f0104d7e:	89 e5                	mov    %esp,%ebp
f0104d80:	53                   	push   %ebx
f0104d81:	83 ec 0c             	sub    $0xc,%esp
f0104d84:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("in sys thread create, eip: %x\n", func);
f0104d87:	53                   	push   %ebx
f0104d88:	68 28 85 10 f0       	push   $0xf0108528
f0104d8d:	e8 4e f0 ff ff       	call   f0103de0 <cprintf>

	envid_t id = thread_create(func);
f0104d92:	89 1c 24             	mov    %ebx,(%esp)
f0104d95:	e8 4f ed ff ff       	call   f0103ae9 <thread_create>
	return id;
}	
f0104d9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104d9d:	c9                   	leave  
f0104d9e:	c3                   	ret    

f0104d9f <sys_thread_free>:


void 	
sys_thread_free(envid_t envid)
{
f0104d9f:	55                   	push   %ebp
f0104da0:	89 e5                	mov    %esp,%ebp
f0104da2:	83 ec 1c             	sub    $0x1c,%esp
	struct Env* e;
	envid2env(envid, &e, 0);
f0104da5:	6a 00                	push   $0x0
f0104da7:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104daa:	50                   	push   %eax
f0104dab:	ff 75 08             	pushl  0x8(%ebp)
f0104dae:	e8 0c e3 ff ff       	call   f01030bf <envid2env>
	thread_free(e);
f0104db3:	83 c4 04             	add    $0x4,%esp
f0104db6:	ff 75 f4             	pushl  -0xc(%ebp)
f0104db9:	e8 2c ec ff ff       	call   f01039ea <thread_free>
}
f0104dbe:	83 c4 10             	add    $0x10,%esp
f0104dc1:	c9                   	leave  
f0104dc2:	c3                   	ret    

f0104dc3 <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
f0104dc3:	55                   	push   %ebp
f0104dc4:	89 e5                	mov    %esp,%ebp
f0104dc6:	83 ec 14             	sub    $0x14,%esp
	thread_join(envid);
f0104dc9:	ff 75 08             	pushl  0x8(%ebp)
f0104dcc:	e8 1c ee ff ff       	call   f0103bed <thread_join>
}
f0104dd1:	83 c4 10             	add    $0x10,%esp
f0104dd4:	c9                   	leave  
f0104dd5:	c3                   	ret    

f0104dd6 <syscall>:

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104dd6:	55                   	push   %ebp
f0104dd7:	89 e5                	mov    %esp,%ebp
f0104dd9:	57                   	push   %edi
f0104dda:	56                   	push   %esi
f0104ddb:	83 ec 10             	sub    $0x10,%esp
f0104dde:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno) {
f0104de1:	83 f8 10             	cmp    $0x10,%eax
f0104de4:	0f 87 cc 06 00 00    	ja     f01054b6 <syscall+0x6e0>
f0104dea:	ff 24 85 80 85 10 f0 	jmp    *-0xfef7a80(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, PTE_U);
f0104df1:	e8 d4 17 00 00       	call   f01065ca <cpunum>
f0104df6:	6a 04                	push   $0x4
f0104df8:	ff 75 10             	pushl  0x10(%ebp)
f0104dfb:	ff 75 0c             	pushl  0xc(%ebp)
f0104dfe:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e01:	ff b0 28 00 22 f0    	pushl  -0xfddffd8(%eax)
f0104e07:	e8 a9 e1 ff ff       	call   f0102fb5 <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104e0c:	83 c4 0c             	add    $0xc,%esp
f0104e0f:	ff 75 0c             	pushl  0xc(%ebp)
f0104e12:	ff 75 10             	pushl  0x10(%ebp)
f0104e15:	68 47 85 10 f0       	push   $0xf0108547
f0104e1a:	e8 c1 ef ff ff       	call   f0103de0 <cprintf>
f0104e1f:	83 c4 10             	add    $0x10,%esp
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char*)a1, a2);
			return 0;
f0104e22:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e27:	e9 96 06 00 00       	jmp    f01054c2 <syscall+0x6ec>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104e2c:	e8 d8 b7 ff ff       	call   f0100609 <cons_getc>
		case SYS_cputs:
			sys_cputs((char*)a1, a2);
			return 0;

		case SYS_cgetc:
			return sys_cgetc();
f0104e31:	e9 8c 06 00 00       	jmp    f01054c2 <syscall+0x6ec>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104e36:	e8 8f 17 00 00       	call   f01065ca <cpunum>
f0104e3b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e3e:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f0104e44:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax

		case SYS_cgetc:
			return sys_cgetc();

		case SYS_getenvid:
			return sys_getenvid();
f0104e4a:	e9 73 06 00 00       	jmp    f01054c2 <syscall+0x6ec>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104e4f:	83 ec 04             	sub    $0x4,%esp
f0104e52:	6a 01                	push   $0x1
f0104e54:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104e57:	50                   	push   %eax
f0104e58:	ff 75 0c             	pushl  0xc(%ebp)
f0104e5b:	e8 5f e2 ff ff       	call   f01030bf <envid2env>
f0104e60:	83 c4 10             	add    $0x10,%esp
f0104e63:	85 c0                	test   %eax,%eax
f0104e65:	0f 88 57 06 00 00    	js     f01054c2 <syscall+0x6ec>
		return r;
	if (e == curenv)
f0104e6b:	e8 5a 17 00 00       	call   f01065ca <cpunum>
f0104e70:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104e73:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e76:	39 90 28 00 22 f0    	cmp    %edx,-0xfddffd8(%eax)
f0104e7c:	75 26                	jne    f0104ea4 <syscall+0xce>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104e7e:	e8 47 17 00 00       	call   f01065ca <cpunum>
f0104e83:	83 ec 08             	sub    $0x8,%esp
f0104e86:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e89:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f0104e8f:	ff b0 a4 00 00 00    	pushl  0xa4(%eax)
f0104e95:	68 4c 85 10 f0       	push   $0xf010854c
f0104e9a:	e8 41 ef ff ff       	call   f0103de0 <cprintf>
f0104e9f:	83 c4 10             	add    $0x10,%esp
f0104ea2:	eb 2b                	jmp    f0104ecf <syscall+0xf9>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104ea4:	8b b2 a4 00 00 00    	mov    0xa4(%edx),%esi
f0104eaa:	e8 1b 17 00 00       	call   f01065ca <cpunum>
f0104eaf:	83 ec 04             	sub    $0x4,%esp
f0104eb2:	56                   	push   %esi
f0104eb3:	6b c0 74             	imul   $0x74,%eax,%eax
f0104eb6:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f0104ebc:	ff b0 a4 00 00 00    	pushl  0xa4(%eax)
f0104ec2:	68 67 85 10 f0       	push   $0xf0108567
f0104ec7:	e8 14 ef ff ff       	call   f0103de0 <cprintf>
f0104ecc:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104ecf:	83 ec 0c             	sub    $0xc,%esp
f0104ed2:	ff 75 f4             	pushl  -0xc(%ebp)
f0104ed5:	e8 25 e9 ff ff       	call   f01037ff <env_destroy>
f0104eda:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104edd:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ee2:	e9 db 05 00 00       	jmp    f01054c2 <syscall+0x6ec>
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	// check if va is page aligned and isnt above UTOP
	if ((((int)va % PGSIZE) != 0) || ((uintptr_t)va >= UTOP)) {
f0104ee7:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104eee:	0f 85 87 00 00 00    	jne    f0104f7b <syscall+0x1a5>
f0104ef4:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104efb:	77 7e                	ja     f0104f7b <syscall+0x1a5>
		return -E_INVAL;
	}
	// check if PTE_P and PTE_U are set (must be set)
	if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
f0104efd:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f00:	83 e0 05             	and    $0x5,%eax
f0104f03:	83 f8 05             	cmp    $0x5,%eax
f0104f06:	75 7d                	jne    f0104f85 <syscall+0x1af>
	}
	
	int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	// check if no other bits hev bin(where the trash goes) set 
	if ((available_perm ^ to_check) != 0) {
f0104f08:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f0b:	0d 07 0e 00 00       	or     $0xe07,%eax
f0104f10:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f0104f15:	75 78                	jne    f0104f8f <syscall+0x1b9>
		return -E_INVAL;
	}

	struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
f0104f17:	83 ec 0c             	sub    $0xc,%esp
f0104f1a:	6a 01                	push   $0x1
f0104f1c:	e8 9b c0 ff ff       	call   f0100fbc <page_alloc>
f0104f21:	89 c6                	mov    %eax,%esi
	// page alloc return null if there are no free pages on page_free_list
	if (!new_page) {
f0104f23:	83 c4 10             	add    $0x10,%esp
f0104f26:	85 c0                	test   %eax,%eax
f0104f28:	74 6f                	je     f0104f99 <syscall+0x1c3>
		return -E_NO_MEM;
	}

	struct Env *e;
	int retperm = envid2env(envid, &e, true);
f0104f2a:	83 ec 04             	sub    $0x4,%esp
f0104f2d:	6a 01                	push   $0x1
f0104f2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104f32:	50                   	push   %eax
f0104f33:	ff 75 0c             	pushl  0xc(%ebp)
f0104f36:	e8 84 e1 ff ff       	call   f01030bf <envid2env>

	//nechce sa mi uz
	if (retperm) {
f0104f3b:	83 c4 10             	add    $0x10,%esp
f0104f3e:	85 c0                	test   %eax,%eax
f0104f40:	0f 85 7c 05 00 00    	jne    f01054c2 <syscall+0x6ec>
		return retperm;
	}	

	int pg_insert_check = page_insert(e->env_pgdir, new_page, va, perm);
f0104f46:	ff 75 14             	pushl  0x14(%ebp)
f0104f49:	ff 75 10             	pushl  0x10(%ebp)
f0104f4c:	56                   	push   %esi
f0104f4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104f50:	ff b0 bc 00 00 00    	pushl  0xbc(%eax)
f0104f56:	e8 12 c4 ff ff       	call   f010136d <page_insert>
f0104f5b:	89 c7                	mov    %eax,%edi
	
	if (pg_insert_check) {
f0104f5d:	83 c4 10             	add    $0x10,%esp
f0104f60:	85 c0                	test   %eax,%eax
f0104f62:	0f 84 5a 05 00 00    	je     f01054c2 <syscall+0x6ec>
		page_free(new_page);
f0104f68:	83 ec 0c             	sub    $0xc,%esp
f0104f6b:	56                   	push   %esi
f0104f6c:	e8 bb c0 ff ff       	call   f010102c <page_free>
f0104f71:	83 c4 10             	add    $0x10,%esp
		return pg_insert_check;
f0104f74:	89 f8                	mov    %edi,%eax
f0104f76:	e9 47 05 00 00       	jmp    f01054c2 <syscall+0x6ec>
	//   allocated!

	// LAB 4: Your code here.
	// check if va is page aligned and isnt above UTOP
	if ((((int)va % PGSIZE) != 0) || ((uintptr_t)va >= UTOP)) {
		return -E_INVAL;
f0104f7b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104f80:	e9 3d 05 00 00       	jmp    f01054c2 <syscall+0x6ec>
	}
	// check if PTE_P and PTE_U are set (must be set)
	if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
		return -E_INVAL;
f0104f85:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104f8a:	e9 33 05 00 00       	jmp    f01054c2 <syscall+0x6ec>
	
	int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	// check if no other bits hev bin(where the trash goes) set 
	if ((available_perm ^ to_check) != 0) {
		return -E_INVAL;
f0104f8f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104f94:	e9 29 05 00 00       	jmp    f01054c2 <syscall+0x6ec>
	}

	struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
	// page alloc return null if there are no free pages on page_free_list
	if (!new_page) {
		return -E_NO_MEM;
f0104f99:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104f9e:	e9 1f 05 00 00       	jmp    f01054c2 <syscall+0x6ec>
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.

	if ((((int)srcva % PGSIZE) != 0) || ((uintptr_t)srcva >= UTOP)) {
f0104fa3:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104faa:	0f 85 dd 00 00 00    	jne    f010508d <syscall+0x2b7>
f0104fb0:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104fb7:	0f 87 d0 00 00 00    	ja     f010508d <syscall+0x2b7>
		return -E_INVAL;
	}

	if ((((int)dstva % PGSIZE) != 0) || ((uintptr_t)dstva >= UTOP)) {
f0104fbd:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0104fc4:	0f 85 cd 00 00 00    	jne    f0105097 <syscall+0x2c1>
f0104fca:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104fd1:	0f 87 c0 00 00 00    	ja     f0105097 <syscall+0x2c1>
		return -E_INVAL;
	}

	if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
f0104fd7:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104fda:	83 e0 05             	and    $0x5,%eax
f0104fdd:	83 f8 05             	cmp    $0x5,%eax
f0104fe0:	0f 85 bb 00 00 00    	jne    f01050a1 <syscall+0x2cb>
	}
	
	int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	// check if no other bits have been set 
	if ((available_perm ^ to_check) != 0) {
f0104fe6:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104fe9:	0d 07 0e 00 00       	or     $0xe07,%eax
f0104fee:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f0104ff3:	0f 85 b2 00 00 00    	jne    f01050ab <syscall+0x2d5>
		return -E_INVAL;
	}

	struct Env *srce;

	int retperm = envid2env(srcenvid, &srce, true);
f0104ff9:	83 ec 04             	sub    $0x4,%esp
f0104ffc:	6a 01                	push   $0x1
f0104ffe:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105001:	50                   	push   %eax
f0105002:	ff 75 0c             	pushl  0xc(%ebp)
f0105005:	e8 b5 e0 ff ff       	call   f01030bf <envid2env>
	
	if (retperm == -E_BAD_ENV) {
f010500a:	83 c4 10             	add    $0x10,%esp
f010500d:	83 f8 fe             	cmp    $0xfffffffe,%eax
f0105010:	0f 84 9f 00 00 00    	je     f01050b5 <syscall+0x2df>
		return -E_BAD_ENV;
	}

	struct Env *dste;

	int retperm2 = envid2env(dstenvid, &dste, true);
f0105016:	83 ec 04             	sub    $0x4,%esp
f0105019:	6a 01                	push   $0x1
f010501b:	8d 45 f0             	lea    -0x10(%ebp),%eax
f010501e:	50                   	push   %eax
f010501f:	ff 75 14             	pushl  0x14(%ebp)
f0105022:	e8 98 e0 ff ff       	call   f01030bf <envid2env>
	
	if (retperm2 == -E_BAD_ENV) {
f0105027:	83 c4 10             	add    $0x10,%esp
f010502a:	83 f8 fe             	cmp    $0xfffffffe,%eax
f010502d:	0f 84 8c 00 00 00    	je     f01050bf <syscall+0x2e9>
		return -E_BAD_ENV;
	}

	pte_t *pte_store;
	struct PageInfo *p = page_lookup(srce->env_pgdir, srcva, &pte_store);
f0105033:	83 ec 04             	sub    $0x4,%esp
f0105036:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0105039:	50                   	push   %eax
f010503a:	ff 75 10             	pushl  0x10(%ebp)
f010503d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105040:	ff b0 bc 00 00 00    	pushl  0xbc(%eax)
f0105046:	e8 f5 c1 ff ff       	call   f0101240 <page_lookup>
	
	if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
f010504b:	83 c4 10             	add    $0x10,%esp
f010504e:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0105052:	74 08                	je     f010505c <syscall+0x286>
f0105054:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0105057:	f6 02 02             	testb  $0x2,(%edx)
f010505a:	74 6d                	je     f01050c9 <syscall+0x2f3>
		return -E_INVAL;
	}

	if (!p) {
f010505c:	85 c0                	test   %eax,%eax
f010505e:	74 73                	je     f01050d3 <syscall+0x2fd>
		return -E_INVAL;	
	}
	
	int pg_insert_check = page_insert(dste->env_pgdir, p, dstva, perm);
f0105060:	ff 75 1c             	pushl  0x1c(%ebp)
f0105063:	ff 75 18             	pushl  0x18(%ebp)
f0105066:	50                   	push   %eax
f0105067:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010506a:	ff b0 bc 00 00 00    	pushl  0xbc(%eax)
f0105070:	e8 f8 c2 ff ff       	call   f010136d <page_insert>
	
	if (pg_insert_check == -E_NO_MEM) {
f0105075:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
	}
	
	return 0;
f0105078:	83 f8 fc             	cmp    $0xfffffffc,%eax
f010507b:	0f 95 c0             	setne  %al
f010507e:	0f b6 c0             	movzbl %al,%eax
f0105081:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
f0105088:	e9 35 04 00 00       	jmp    f01054c2 <syscall+0x6ec>
	//   check the current permissions on the page.

	// LAB 4: Your code here.

	if ((((int)srcva % PGSIZE) != 0) || ((uintptr_t)srcva >= UTOP)) {
		return -E_INVAL;
f010508d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105092:	e9 2b 04 00 00       	jmp    f01054c2 <syscall+0x6ec>
	}

	if ((((int)dstva % PGSIZE) != 0) || ((uintptr_t)dstva >= UTOP)) {
		return -E_INVAL;
f0105097:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010509c:	e9 21 04 00 00       	jmp    f01054c2 <syscall+0x6ec>
	}

	if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
		return -E_INVAL;
f01050a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050a6:	e9 17 04 00 00       	jmp    f01054c2 <syscall+0x6ec>
	
	int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	// check if no other bits have been set 
	if ((available_perm ^ to_check) != 0) {
		return -E_INVAL;
f01050ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050b0:	e9 0d 04 00 00       	jmp    f01054c2 <syscall+0x6ec>
	struct Env *srce;

	int retperm = envid2env(srcenvid, &srce, true);
	
	if (retperm == -E_BAD_ENV) {
		return -E_BAD_ENV;
f01050b5:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01050ba:	e9 03 04 00 00       	jmp    f01054c2 <syscall+0x6ec>
	struct Env *dste;

	int retperm2 = envid2env(dstenvid, &dste, true);
	
	if (retperm2 == -E_BAD_ENV) {
		return -E_BAD_ENV;
f01050bf:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01050c4:	e9 f9 03 00 00       	jmp    f01054c2 <syscall+0x6ec>

	pte_t *pte_store;
	struct PageInfo *p = page_lookup(srce->env_pgdir, srcva, &pte_store);
	
	if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
		return -E_INVAL;
f01050c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050ce:	e9 ef 03 00 00       	jmp    f01054c2 <syscall+0x6ec>
	}

	if (!p) {
		return -E_INVAL;	
f01050d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050d8:	e9 e5 03 00 00       	jmp    f01054c2 <syscall+0x6ec>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if ((((int)va % PGSIZE) != 0) || ((uintptr_t)va >= UTOP)) {
f01050dd:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01050e4:	75 45                	jne    f010512b <syscall+0x355>
f01050e6:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01050ed:	77 3c                	ja     f010512b <syscall+0x355>
		return -E_INVAL;
	}
	
	struct Env *e;
	int perm = envid2env(envid, &e, true);
f01050ef:	83 ec 04             	sub    $0x4,%esp
f01050f2:	6a 01                	push   $0x1
f01050f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01050f7:	50                   	push   %eax
f01050f8:	ff 75 0c             	pushl  0xc(%ebp)
f01050fb:	e8 bf df ff ff       	call   f01030bf <envid2env>
f0105100:	89 c6                	mov    %eax,%esi
	
	if (perm) {
f0105102:	83 c4 10             	add    $0x10,%esp
f0105105:	85 c0                	test   %eax,%eax
f0105107:	0f 85 b5 03 00 00    	jne    f01054c2 <syscall+0x6ec>
		return perm;
	}	
	
	page_remove(e->env_pgdir, va);
f010510d:	83 ec 08             	sub    $0x8,%esp
f0105110:	ff 75 10             	pushl  0x10(%ebp)
f0105113:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105116:	ff b0 bc 00 00 00    	pushl  0xbc(%eax)
f010511c:	e8 de c1 ff ff       	call   f01012ff <page_remove>
f0105121:	83 c4 10             	add    $0x10,%esp

	return 0;
f0105124:	89 f0                	mov    %esi,%eax
f0105126:	e9 97 03 00 00       	jmp    f01054c2 <syscall+0x6ec>
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if ((((int)va % PGSIZE) != 0) || ((uintptr_t)va >= UTOP)) {
		return -E_INVAL;
f010512b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105130:	e9 8d 03 00 00       	jmp    f01054c2 <syscall+0x6ec>
	// It should be left as env_alloc created it, except that
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
	struct Env *new_env;
	int env_state =	env_alloc(&new_env, curenv->env_id);
f0105135:	e8 90 14 00 00       	call   f01065ca <cpunum>
f010513a:	83 ec 08             	sub    $0x8,%esp
f010513d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105140:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f0105146:	ff b0 a4 00 00 00    	pushl  0xa4(%eax)
f010514c:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010514f:	50                   	push   %eax
f0105150:	e8 da e0 ff ff       	call   f010322f <env_alloc>

	if (env_state < 0) {
f0105155:	83 c4 10             	add    $0x10,%esp
f0105158:	85 c0                	test   %eax,%eax
f010515a:	0f 88 62 03 00 00    	js     f01054c2 <syscall+0x6ec>
		return env_state;
	}

	new_env->env_tf = curenv->env_tf;
f0105160:	8b 7d f4             	mov    -0xc(%ebp),%edi
f0105163:	e8 62 14 00 00       	call   f01065ca <cpunum>
f0105168:	6b c0 74             	imul   $0x74,%eax,%eax
f010516b:	8b 90 28 00 22 f0    	mov    -0xfddffd8(%eax),%edx
f0105171:	8d 47 59             	lea    0x59(%edi),%eax
f0105174:	8d 72 59             	lea    0x59(%edx),%esi
f0105177:	8b 52 59             	mov    0x59(%edx),%edx
f010517a:	89 57 59             	mov    %edx,0x59(%edi)
f010517d:	8b 56 40             	mov    0x40(%esi),%edx
f0105180:	89 97 99 00 00 00    	mov    %edx,0x99(%edi)
f0105186:	83 c7 5d             	add    $0x5d,%edi
f0105189:	83 e7 fc             	and    $0xfffffffc,%edi
f010518c:	29 f8                	sub    %edi,%eax
f010518e:	29 c6                	sub    %eax,%esi
f0105190:	8d 48 44             	lea    0x44(%eax),%ecx
f0105193:	c1 e9 02             	shr    $0x2,%ecx
f0105196:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	new_env->env_status = ENV_NOT_RUNNABLE;
f0105198:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010519b:	c7 80 b0 00 00 00 04 	movl   $0x4,0xb0(%eax)
f01051a2:	00 00 00 
	new_env->env_tf.tf_regs.reg_eax = 0;
f01051a5:	c7 40 75 00 00 00 00 	movl   $0x0,0x75(%eax)

	return new_env->env_id;
f01051ac:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
f01051b2:	e9 0b 03 00 00       	jmp    f01054c2 <syscall+0x6ec>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if ((status != ENV_RUNNABLE) && (status != ENV_NOT_RUNNABLE)) {
f01051b7:	8b 45 10             	mov    0x10(%ebp),%eax
f01051ba:	83 e8 02             	sub    $0x2,%eax
f01051bd:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f01051c2:	75 31                	jne    f01051f5 <syscall+0x41f>
		return -E_INVAL;
	}

	struct Env *e;

	int perm = envid2env(envid, &e, true); 
f01051c4:	83 ec 04             	sub    $0x4,%esp
f01051c7:	6a 01                	push   $0x1
f01051c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01051cc:	50                   	push   %eax
f01051cd:	ff 75 0c             	pushl  0xc(%ebp)
f01051d0:	e8 ea de ff ff       	call   f01030bf <envid2env>
f01051d5:	89 c2                	mov    %eax,%edx

	if (perm) {
f01051d7:	83 c4 10             	add    $0x10,%esp
f01051da:	85 c0                	test   %eax,%eax
f01051dc:	0f 85 e0 02 00 00    	jne    f01054c2 <syscall+0x6ec>
		return perm;
	}	

	e->env_status = status;
f01051e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01051e5:	8b 7d 10             	mov    0x10(%ebp),%edi
f01051e8:	89 b8 b0 00 00 00    	mov    %edi,0xb0(%eax)

	return 0;
f01051ee:	89 d0                	mov    %edx,%eax
f01051f0:	e9 cd 02 00 00       	jmp    f01054c2 <syscall+0x6ec>
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if ((status != ENV_RUNNABLE) && (status != ENV_NOT_RUNNABLE)) {
		return -E_INVAL;
f01051f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01051fa:	e9 c3 02 00 00       	jmp    f01054c2 <syscall+0x6ec>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *e;

	int perm = envid2env(envid, &e, true); 
f01051ff:	83 ec 04             	sub    $0x4,%esp
f0105202:	6a 01                	push   $0x1
f0105204:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0105207:	50                   	push   %eax
f0105208:	ff 75 0c             	pushl  0xc(%ebp)
f010520b:	e8 af de ff ff       	call   f01030bf <envid2env>

	if (perm) {
f0105210:	83 c4 10             	add    $0x10,%esp
f0105213:	85 c0                	test   %eax,%eax
f0105215:	0f 85 a7 02 00 00    	jne    f01054c2 <syscall+0x6ec>
		return perm;
	}
	
	e->env_pgfault_upcall = func;
f010521b:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010521e:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105221:	89 8a c0 00 00 00    	mov    %ecx,0xc0(%edx)

		case SYS_env_set_status:
			return sys_env_set_status(a1, a2);

		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void*)a2);
f0105227:	e9 96 02 00 00       	jmp    f01054c2 <syscall+0x6ec>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f010522c:	e8 75 fa ff ff       	call   f0104ca6 <sched_yield>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.

	struct Env *e;
	int env = envid2env(envid, &e, false);
f0105231:	83 ec 04             	sub    $0x4,%esp
f0105234:	6a 00                	push   $0x0
f0105236:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0105239:	50                   	push   %eax
f010523a:	ff 75 0c             	pushl  0xc(%ebp)
f010523d:	e8 7d de ff ff       	call   f01030bf <envid2env>
	
	if (env < 0) {
f0105242:	83 c4 10             	add    $0x10,%esp
f0105245:	85 c0                	test   %eax,%eax
f0105247:	79 08                	jns    f0105251 <syscall+0x47b>
		return perm;
f0105249:	8b 45 18             	mov    0x18(%ebp),%eax
f010524c:	e9 71 02 00 00       	jmp    f01054c2 <syscall+0x6ec>
	}
	
	if (!e->env_ipc_recving) {
f0105251:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105254:	80 b8 c4 00 00 00 00 	cmpb   $0x0,0xc4(%eax)
f010525b:	0f 84 1e 01 00 00    	je     f010537f <syscall+0x5a9>
		return -E_IPC_NOT_RECV;
	}

	e->env_ipc_perm = 0;
f0105261:	c7 80 d4 00 00 00 00 	movl   $0x0,0xd4(%eax)
f0105268:	00 00 00 

	if ((uint32_t)srcva < UTOP) {
f010526b:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0105272:	0f 87 bc 00 00 00    	ja     f0105334 <syscall+0x55e>
		if (ROUNDDOWN((uint32_t)srcva,PGSIZE) != (uint32_t)srcva) {
			return -E_INVAL;
f0105278:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}

	e->env_ipc_perm = 0;

	if ((uint32_t)srcva < UTOP) {
		if (ROUNDDOWN((uint32_t)srcva,PGSIZE) != (uint32_t)srcva) {
f010527d:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0105284:	0f 85 38 02 00 00    	jne    f01054c2 <syscall+0x6ec>
			return -E_INVAL;
		}

		if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
f010528a:	8b 55 18             	mov    0x18(%ebp),%edx
f010528d:	83 e2 05             	and    $0x5,%edx
f0105290:	83 fa 05             	cmp    $0x5,%edx
f0105293:	0f 85 29 02 00 00    	jne    f01054c2 <syscall+0x6ec>
		}
	
		int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
		int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
		// check if no other bits have been set 
		if ((available_perm ^ to_check) != 0) {
f0105299:	8b 55 18             	mov    0x18(%ebp),%edx
f010529c:	81 ca 07 0e 00 00    	or     $0xe07,%edx
f01052a2:	81 fa 07 0e 00 00    	cmp    $0xe07,%edx
f01052a8:	0f 85 14 02 00 00    	jne    f01054c2 <syscall+0x6ec>
			return -E_INVAL;
		}

		pte_t *pte_store;
		struct PageInfo *p = page_lookup(curenv->env_pgdir, srcva, 							 &pte_store);
f01052ae:	e8 17 13 00 00       	call   f01065ca <cpunum>
f01052b3:	83 ec 04             	sub    $0x4,%esp
f01052b6:	8d 55 f4             	lea    -0xc(%ebp),%edx
f01052b9:	52                   	push   %edx
f01052ba:	ff 75 14             	pushl  0x14(%ebp)
f01052bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01052c0:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f01052c6:	ff b0 bc 00 00 00    	pushl  0xbc(%eax)
f01052cc:	e8 6f bf ff ff       	call   f0101240 <page_lookup>
f01052d1:	89 c1                	mov    %eax,%ecx
	
		if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
f01052d3:	83 c4 10             	add    $0x10,%esp
f01052d6:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f01052da:	74 11                	je     f01052ed <syscall+0x517>
			return -E_INVAL;
f01052dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}

		pte_t *pte_store;
		struct PageInfo *p = page_lookup(curenv->env_pgdir, srcva, 							 &pte_store);
	
		if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
f01052e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01052e4:	f6 02 02             	testb  $0x2,(%edx)
f01052e7:	0f 84 d5 01 00 00    	je     f01054c2 <syscall+0x6ec>
			return -E_INVAL;
		}

		if (!p) {
f01052ed:	85 c9                	test   %ecx,%ecx
f01052ef:	74 39                	je     f010532a <syscall+0x554>
			return -E_INVAL;	
		}

		if ((uint32_t)e->env_ipc_dstva < UTOP){
f01052f1:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01052f4:	8b 82 c8 00 00 00    	mov    0xc8(%edx),%eax
f01052fa:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f01052ff:	77 33                	ja     f0105334 <syscall+0x55e>
			int pg_insert_check = page_insert(e->env_pgdir, p,
f0105301:	ff 75 18             	pushl  0x18(%ebp)
f0105304:	50                   	push   %eax
f0105305:	51                   	push   %ecx
f0105306:	ff b2 bc 00 00 00    	pushl  0xbc(%edx)
f010530c:	e8 5c c0 ff ff       	call   f010136d <page_insert>
	 				          e->env_ipc_dstva, perm);
	
			if (pg_insert_check < 0) {
f0105311:	83 c4 10             	add    $0x10,%esp
f0105314:	85 c0                	test   %eax,%eax
f0105316:	0f 88 a6 01 00 00    	js     f01054c2 <syscall+0x6ec>
				return pg_insert_check;
			}

			e->env_ipc_perm = perm;
f010531c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010531f:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105322:	89 88 d4 00 00 00    	mov    %ecx,0xd4(%eax)
f0105328:	eb 0a                	jmp    f0105334 <syscall+0x55e>
		if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
			return -E_INVAL;
		}

		if (!p) {
			return -E_INVAL;	
f010532a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010532f:	e9 8e 01 00 00       	jmp    f01054c2 <syscall+0x6ec>

			e->env_ipc_perm = perm;
		}
	}

	e->env_ipc_recving = false;
f0105334:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0105337:	c6 86 c4 00 00 00 00 	movb   $0x0,0xc4(%esi)
	e->env_ipc_from = curenv->env_id;
f010533e:	e8 87 12 00 00       	call   f01065ca <cpunum>
f0105343:	6b c0 74             	imul   $0x74,%eax,%eax
f0105346:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f010534c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
f0105352:	89 86 d0 00 00 00    	mov    %eax,0xd0(%esi)
	e->env_ipc_value = value;
f0105358:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010535b:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010535e:	89 88 cc 00 00 00    	mov    %ecx,0xcc(%eax)
	e->env_status = ENV_RUNNABLE;
f0105364:	c7 80 b0 00 00 00 02 	movl   $0x2,0xb0(%eax)
f010536b:	00 00 00 
	e->env_tf.tf_regs.reg_eax = 0;
f010536e:	c7 40 75 00 00 00 00 	movl   $0x0,0x75(%eax)

	return 0;
f0105375:	b8 00 00 00 00       	mov    $0x0,%eax
f010537a:	e9 43 01 00 00       	jmp    f01054c2 <syscall+0x6ec>
	if (env < 0) {
		return perm;
	}
	
	if (!e->env_ipc_recving) {
		return -E_IPC_NOT_RECV;
f010537f:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
		case SYS_yield:
			sys_yield();
			return 0;

		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void*)a3, a4);
f0105384:	e9 39 01 00 00       	jmp    f01054c2 <syscall+0x6ec>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if ((uint32_t)dstva < UTOP) {
f0105389:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0105390:	77 0d                	ja     f010539f <syscall+0x5c9>
		if (ROUNDDOWN((uint32_t)dstva, PGSIZE) != (uint32_t)dstva) {
f0105392:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0105399:	0f 85 1e 01 00 00    	jne    f01054bd <syscall+0x6e7>
			return -E_INVAL;
		}
	}
	curenv->env_ipc_recving = true;	
f010539f:	e8 26 12 00 00       	call   f01065ca <cpunum>
f01053a4:	6b c0 74             	imul   $0x74,%eax,%eax
f01053a7:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f01053ad:	c6 80 c4 00 00 00 01 	movb   $0x1,0xc4(%eax)
	curenv->env_ipc_dstva = dstva;
f01053b4:	e8 11 12 00 00       	call   f01065ca <cpunum>
f01053b9:	6b c0 74             	imul   $0x74,%eax,%eax
f01053bc:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f01053c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01053c5:	89 88 c8 00 00 00    	mov    %ecx,0xc8(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f01053cb:	e8 fa 11 00 00       	call   f01065ca <cpunum>
f01053d0:	6b c0 74             	imul   $0x74,%eax,%eax
f01053d3:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f01053d9:	c7 80 b0 00 00 00 04 	movl   $0x4,0xb0(%eax)
f01053e0:	00 00 00 
	curenv->env_tf.tf_regs.reg_eax = 0;
f01053e3:	e8 e2 11 00 00       	call   f01065ca <cpunum>
f01053e8:	6b c0 74             	imul   $0x74,%eax,%eax
f01053eb:	8b 80 28 00 22 f0    	mov    -0xfddffd8(%eax),%eax
f01053f1:	c7 40 75 00 00 00 00 	movl   $0x0,0x75(%eax)

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f01053f8:	e8 a9 f8 ff ff       	call   f0104ca6 <sched_yield>
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!

	struct Env *e; 
	int env = envid2env(envid, &e, 1);
f01053fd:	83 ec 04             	sub    $0x4,%esp
f0105400:	6a 01                	push   $0x1
f0105402:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0105405:	50                   	push   %eax
f0105406:	ff 75 0c             	pushl  0xc(%ebp)
f0105409:	e8 b1 dc ff ff       	call   f01030bf <envid2env>

	if (env < 0) { 
f010540e:	83 c4 10             	add    $0x10,%esp
f0105411:	85 c0                	test   %eax,%eax
f0105413:	0f 88 a9 00 00 00    	js     f01054c2 <syscall+0x6ec>
		return env;
	}

	user_mem_assert(e, tf, sizeof(struct Trapframe), PTE_U);
f0105419:	6a 04                	push   $0x4
f010541b:	6a 44                	push   $0x44
f010541d:	ff 75 10             	pushl  0x10(%ebp)
f0105420:	ff 75 f4             	pushl  -0xc(%ebp)
f0105423:	e8 8d db ff ff       	call   f0102fb5 <user_mem_assert>

	e->env_tf = *tf;
f0105428:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010542b:	8d 42 59             	lea    0x59(%edx),%eax
f010542e:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105431:	8b 09                	mov    (%ecx),%ecx
f0105433:	89 4a 59             	mov    %ecx,0x59(%edx)
f0105436:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105439:	8b 4f 40             	mov    0x40(%edi),%ecx
f010543c:	89 8a 99 00 00 00    	mov    %ecx,0x99(%edx)
f0105442:	8d 7a 5d             	lea    0x5d(%edx),%edi
f0105445:	83 e7 fc             	and    $0xfffffffc,%edi
f0105448:	29 f8                	sub    %edi,%eax
f010544a:	8b 75 10             	mov    0x10(%ebp),%esi
f010544d:	29 c6                	sub    %eax,%esi
f010544f:	8d 48 44             	lea    0x44(%eax),%ecx
f0105452:	c1 e9 02             	shr    $0x2,%ecx
f0105455:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_eflags |= FL_IF;
	e->env_tf.tf_cs = GD_UT | 3;
f0105457:	66 c7 82 8d 00 00 00 	movw   $0x1b,0x8d(%edx)
f010545e:	1b 00 
	//shoutout to fgt(x)
	e->env_tf.tf_eflags &= ~FL_IOPL_3;
f0105460:	8b 82 91 00 00 00    	mov    0x91(%edx),%eax
f0105466:	80 e4 cf             	and    $0xcf,%ah
f0105469:	80 cc 02             	or     $0x2,%ah
f010546c:	89 82 91 00 00 00    	mov    %eax,0x91(%edx)
f0105472:	83 c4 10             	add    $0x10,%esp

	return 0;
f0105475:	b8 00 00 00 00       	mov    $0x0,%eax
f010547a:	eb 46                	jmp    f01054c2 <syscall+0x6ec>
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe(a1, (struct Trapframe*)a2);

		// LAB 7 Multithreading
		case SYS_thread_create:
			return sys_thread_create((uintptr_t) a1);
f010547c:	83 ec 0c             	sub    $0xc,%esp
f010547f:	ff 75 0c             	pushl  0xc(%ebp)
f0105482:	e8 f6 f8 ff ff       	call   f0104d7d <sys_thread_create>
f0105487:	83 c4 10             	add    $0x10,%esp
f010548a:	eb 36                	jmp    f01054c2 <syscall+0x6ec>

		case SYS_thread_free:
			sys_thread_free((envid_t)a1);
f010548c:	83 ec 0c             	sub    $0xc,%esp
f010548f:	ff 75 0c             	pushl  0xc(%ebp)
f0105492:	e8 08 f9 ff ff       	call   f0104d9f <sys_thread_free>
			return 0;
f0105497:	83 c4 10             	add    $0x10,%esp
f010549a:	b8 00 00 00 00       	mov    $0x0,%eax
f010549f:	eb 21                	jmp    f01054c2 <syscall+0x6ec>
}

void 	
sys_thread_join(envid_t envid) 
{
	thread_join(envid);
f01054a1:	83 ec 0c             	sub    $0xc,%esp
f01054a4:	ff 75 0c             	pushl  0xc(%ebp)
f01054a7:	e8 41 e7 ff ff       	call   f0103bed <thread_join>
f01054ac:	83 c4 10             	add    $0x10,%esp
			sys_thread_free((envid_t)a1);
			return 0;

		case SYS_thread_join:
			sys_thread_join((envid_t)a1);
			return 0;
f01054af:	b8 00 00 00 00       	mov    $0x0,%eax
f01054b4:	eb 0c                	jmp    f01054c2 <syscall+0x6ec>

		default:
			return -E_INVAL;
f01054b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01054bb:	eb 05                	jmp    f01054c2 <syscall+0x6ec>

		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void*)a3, a4);

		case SYS_ipc_recv:
			return sys_ipc_recv((void*)a1);
f01054bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			return 0;

		default:
			return -E_INVAL;
	}
}
f01054c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01054c5:	5e                   	pop    %esi
f01054c6:	5f                   	pop    %edi
f01054c7:	5d                   	pop    %ebp
f01054c8:	c3                   	ret    

f01054c9 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01054c9:	55                   	push   %ebp
f01054ca:	89 e5                	mov    %esp,%ebp
f01054cc:	57                   	push   %edi
f01054cd:	56                   	push   %esi
f01054ce:	53                   	push   %ebx
f01054cf:	83 ec 14             	sub    $0x14,%esp
f01054d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01054d5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01054d8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01054db:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01054de:	8b 1a                	mov    (%edx),%ebx
f01054e0:	8b 01                	mov    (%ecx),%eax
f01054e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01054e5:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01054ec:	eb 7f                	jmp    f010556d <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01054ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01054f1:	01 d8                	add    %ebx,%eax
f01054f3:	89 c6                	mov    %eax,%esi
f01054f5:	c1 ee 1f             	shr    $0x1f,%esi
f01054f8:	01 c6                	add    %eax,%esi
f01054fa:	d1 fe                	sar    %esi
f01054fc:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01054ff:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105502:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0105505:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105507:	eb 03                	jmp    f010550c <stab_binsearch+0x43>
			m--;
f0105509:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010550c:	39 c3                	cmp    %eax,%ebx
f010550e:	7f 0d                	jg     f010551d <stab_binsearch+0x54>
f0105510:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105514:	83 ea 0c             	sub    $0xc,%edx
f0105517:	39 f9                	cmp    %edi,%ecx
f0105519:	75 ee                	jne    f0105509 <stab_binsearch+0x40>
f010551b:	eb 05                	jmp    f0105522 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010551d:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0105520:	eb 4b                	jmp    f010556d <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105522:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105525:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105528:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010552c:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010552f:	76 11                	jbe    f0105542 <stab_binsearch+0x79>
			*region_left = m;
f0105531:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105534:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0105536:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105539:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105540:	eb 2b                	jmp    f010556d <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0105542:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0105545:	73 14                	jae    f010555b <stab_binsearch+0x92>
			*region_right = m - 1;
f0105547:	83 e8 01             	sub    $0x1,%eax
f010554a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010554d:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105550:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105552:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105559:	eb 12                	jmp    f010556d <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010555b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010555e:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0105560:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0105564:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105566:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010556d:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0105570:	0f 8e 78 ff ff ff    	jle    f01054ee <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105576:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010557a:	75 0f                	jne    f010558b <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f010557c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010557f:	8b 00                	mov    (%eax),%eax
f0105581:	83 e8 01             	sub    $0x1,%eax
f0105584:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105587:	89 06                	mov    %eax,(%esi)
f0105589:	eb 2c                	jmp    f01055b7 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010558b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010558e:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105590:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105593:	8b 0e                	mov    (%esi),%ecx
f0105595:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105598:	8b 75 ec             	mov    -0x14(%ebp),%esi
f010559b:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010559e:	eb 03                	jmp    f01055a3 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01055a0:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01055a3:	39 c8                	cmp    %ecx,%eax
f01055a5:	7e 0b                	jle    f01055b2 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f01055a7:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01055ab:	83 ea 0c             	sub    $0xc,%edx
f01055ae:	39 df                	cmp    %ebx,%edi
f01055b0:	75 ee                	jne    f01055a0 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f01055b2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01055b5:	89 06                	mov    %eax,(%esi)
	}
}
f01055b7:	83 c4 14             	add    $0x14,%esp
f01055ba:	5b                   	pop    %ebx
f01055bb:	5e                   	pop    %esi
f01055bc:	5f                   	pop    %edi
f01055bd:	5d                   	pop    %ebp
f01055be:	c3                   	ret    

f01055bf <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01055bf:	55                   	push   %ebp
f01055c0:	89 e5                	mov    %esp,%ebp
f01055c2:	57                   	push   %edi
f01055c3:	56                   	push   %esi
f01055c4:	53                   	push   %ebx
f01055c5:	83 ec 3c             	sub    $0x3c,%esp
f01055c8:	8b 75 08             	mov    0x8(%ebp),%esi
f01055cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01055ce:	c7 03 c4 85 10 f0    	movl   $0xf01085c4,(%ebx)
	info->eip_line = 0;
f01055d4:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01055db:	c7 43 08 c4 85 10 f0 	movl   $0xf01085c4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01055e2:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01055e9:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01055ec:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01055f3:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01055f9:	77 21                	ja     f010561c <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f01055fb:	a1 00 00 20 00       	mov    0x200000,%eax
f0105600:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stab_end = usd->stab_end;
f0105603:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0105608:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f010560e:	89 7d b8             	mov    %edi,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0105611:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f0105617:	89 7d c0             	mov    %edi,-0x40(%ebp)
f010561a:	eb 1a                	jmp    f0105636 <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f010561c:	c7 45 c0 4e 7a 11 f0 	movl   $0xf0117a4e,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0105623:	c7 45 b8 f9 38 11 f0 	movl   $0xf01138f9,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f010562a:	b8 f8 38 11 f0       	mov    $0xf01138f8,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f010562f:	c7 45 bc 70 8b 10 f0 	movl   $0xf0108b70,-0x44(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105636:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105639:	39 7d b8             	cmp    %edi,-0x48(%ebp)
f010563c:	0f 83 95 01 00 00    	jae    f01057d7 <debuginfo_eip+0x218>
f0105642:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0105646:	0f 85 92 01 00 00    	jne    f01057de <debuginfo_eip+0x21f>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010564c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105653:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0105656:	29 f8                	sub    %edi,%eax
f0105658:	c1 f8 02             	sar    $0x2,%eax
f010565b:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0105661:	83 e8 01             	sub    $0x1,%eax
f0105664:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105667:	56                   	push   %esi
f0105668:	6a 64                	push   $0x64
f010566a:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010566d:	89 c1                	mov    %eax,%ecx
f010566f:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105672:	89 f8                	mov    %edi,%eax
f0105674:	e8 50 fe ff ff       	call   f01054c9 <stab_binsearch>
	if (lfile == 0)
f0105679:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010567c:	83 c4 08             	add    $0x8,%esp
f010567f:	85 c0                	test   %eax,%eax
f0105681:	0f 84 5e 01 00 00    	je     f01057e5 <debuginfo_eip+0x226>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105687:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010568a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010568d:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105690:	56                   	push   %esi
f0105691:	6a 24                	push   $0x24
f0105693:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0105696:	89 c1                	mov    %eax,%ecx
f0105698:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010569b:	89 f8                	mov    %edi,%eax
f010569d:	e8 27 fe ff ff       	call   f01054c9 <stab_binsearch>

	if (lfun <= rfun) {
f01056a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01056a5:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01056a8:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f01056ab:	83 c4 08             	add    $0x8,%esp
f01056ae:	39 d0                	cmp    %edx,%eax
f01056b0:	7f 2b                	jg     f01056dd <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01056b2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01056b5:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f01056b8:	8b 11                	mov    (%ecx),%edx
f01056ba:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01056bd:	2b 7d b8             	sub    -0x48(%ebp),%edi
f01056c0:	39 fa                	cmp    %edi,%edx
f01056c2:	73 06                	jae    f01056ca <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01056c4:	03 55 b8             	add    -0x48(%ebp),%edx
f01056c7:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01056ca:	8b 51 08             	mov    0x8(%ecx),%edx
f01056cd:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01056d0:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01056d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01056d5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01056d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01056db:	eb 0f                	jmp    f01056ec <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01056dd:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f01056e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01056e3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01056e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01056e9:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01056ec:	83 ec 08             	sub    $0x8,%esp
f01056ef:	6a 3a                	push   $0x3a
f01056f1:	ff 73 08             	pushl  0x8(%ebx)
f01056f4:	e8 92 08 00 00       	call   f0105f8b <strfind>
f01056f9:	2b 43 08             	sub    0x8(%ebx),%eax
f01056fc:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01056ff:	83 c4 08             	add    $0x8,%esp
f0105702:	56                   	push   %esi
f0105703:	6a 44                	push   $0x44
f0105705:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105708:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010570b:	8b 75 bc             	mov    -0x44(%ebp),%esi
f010570e:	89 f0                	mov    %esi,%eax
f0105710:	e8 b4 fd ff ff       	call   f01054c9 <stab_binsearch>
	if (lline == rline) {
f0105715:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105718:	83 c4 10             	add    $0x10,%esp
f010571b:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f010571e:	0f 85 c8 00 00 00    	jne    f01057ec <debuginfo_eip+0x22d>
		info->eip_line = stabs[lline].n_desc;
f0105724:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105727:	8d 14 96             	lea    (%esi,%edx,4),%edx
f010572a:	0f b7 4a 06          	movzwl 0x6(%edx),%ecx
f010572e:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105731:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105734:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0105738:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010573b:	eb 0a                	jmp    f0105747 <debuginfo_eip+0x188>
f010573d:	83 e8 01             	sub    $0x1,%eax
f0105740:	83 ea 0c             	sub    $0xc,%edx
f0105743:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0105747:	39 c7                	cmp    %eax,%edi
f0105749:	7e 05                	jle    f0105750 <debuginfo_eip+0x191>
f010574b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010574e:	eb 47                	jmp    f0105797 <debuginfo_eip+0x1d8>
	       && stabs[lline].n_type != N_SOL
f0105750:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105754:	80 f9 84             	cmp    $0x84,%cl
f0105757:	75 0e                	jne    f0105767 <debuginfo_eip+0x1a8>
f0105759:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010575c:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0105760:	74 1c                	je     f010577e <debuginfo_eip+0x1bf>
f0105762:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105765:	eb 17                	jmp    f010577e <debuginfo_eip+0x1bf>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105767:	80 f9 64             	cmp    $0x64,%cl
f010576a:	75 d1                	jne    f010573d <debuginfo_eip+0x17e>
f010576c:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0105770:	74 cb                	je     f010573d <debuginfo_eip+0x17e>
f0105772:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105775:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0105779:	74 03                	je     f010577e <debuginfo_eip+0x1bf>
f010577b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010577e:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105781:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0105784:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0105787:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010578a:	8b 75 b8             	mov    -0x48(%ebp),%esi
f010578d:	29 f0                	sub    %esi,%eax
f010578f:	39 c2                	cmp    %eax,%edx
f0105791:	73 04                	jae    f0105797 <debuginfo_eip+0x1d8>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105793:	01 f2                	add    %esi,%edx
f0105795:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105797:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010579a:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010579d:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01057a2:	39 f2                	cmp    %esi,%edx
f01057a4:	7d 52                	jge    f01057f8 <debuginfo_eip+0x239>
		for (lline = lfun + 1;
f01057a6:	83 c2 01             	add    $0x1,%edx
f01057a9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01057ac:	89 d0                	mov    %edx,%eax
f01057ae:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01057b1:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01057b4:	8d 14 97             	lea    (%edi,%edx,4),%edx
f01057b7:	eb 04                	jmp    f01057bd <debuginfo_eip+0x1fe>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01057b9:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01057bd:	39 c6                	cmp    %eax,%esi
f01057bf:	7e 32                	jle    f01057f3 <debuginfo_eip+0x234>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01057c1:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01057c5:	83 c0 01             	add    $0x1,%eax
f01057c8:	83 c2 0c             	add    $0xc,%edx
f01057cb:	80 f9 a0             	cmp    $0xa0,%cl
f01057ce:	74 e9                	je     f01057b9 <debuginfo_eip+0x1fa>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01057d0:	b8 00 00 00 00       	mov    $0x0,%eax
f01057d5:	eb 21                	jmp    f01057f8 <debuginfo_eip+0x239>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01057d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057dc:	eb 1a                	jmp    f01057f8 <debuginfo_eip+0x239>
f01057de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057e3:	eb 13                	jmp    f01057f8 <debuginfo_eip+0x239>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f01057e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057ea:	eb 0c                	jmp    f01057f8 <debuginfo_eip+0x239>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline == rline) {
		info->eip_line = stabs[lline].n_desc;
	} else {
		return -1;	
f01057ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057f1:	eb 05                	jmp    f01057f8 <debuginfo_eip+0x239>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01057f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01057f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01057fb:	5b                   	pop    %ebx
f01057fc:	5e                   	pop    %esi
f01057fd:	5f                   	pop    %edi
f01057fe:	5d                   	pop    %ebp
f01057ff:	c3                   	ret    

f0105800 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105800:	55                   	push   %ebp
f0105801:	89 e5                	mov    %esp,%ebp
f0105803:	57                   	push   %edi
f0105804:	56                   	push   %esi
f0105805:	53                   	push   %ebx
f0105806:	83 ec 1c             	sub    $0x1c,%esp
f0105809:	89 c7                	mov    %eax,%edi
f010580b:	89 d6                	mov    %edx,%esi
f010580d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105810:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105813:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105816:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105819:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010581c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105821:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105824:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0105827:	39 d3                	cmp    %edx,%ebx
f0105829:	72 05                	jb     f0105830 <printnum+0x30>
f010582b:	39 45 10             	cmp    %eax,0x10(%ebp)
f010582e:	77 45                	ja     f0105875 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105830:	83 ec 0c             	sub    $0xc,%esp
f0105833:	ff 75 18             	pushl  0x18(%ebp)
f0105836:	8b 45 14             	mov    0x14(%ebp),%eax
f0105839:	8d 58 ff             	lea    -0x1(%eax),%ebx
f010583c:	53                   	push   %ebx
f010583d:	ff 75 10             	pushl  0x10(%ebp)
f0105840:	83 ec 08             	sub    $0x8,%esp
f0105843:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105846:	ff 75 e0             	pushl  -0x20(%ebp)
f0105849:	ff 75 dc             	pushl  -0x24(%ebp)
f010584c:	ff 75 d8             	pushl  -0x28(%ebp)
f010584f:	e8 7c 11 00 00       	call   f01069d0 <__udivdi3>
f0105854:	83 c4 18             	add    $0x18,%esp
f0105857:	52                   	push   %edx
f0105858:	50                   	push   %eax
f0105859:	89 f2                	mov    %esi,%edx
f010585b:	89 f8                	mov    %edi,%eax
f010585d:	e8 9e ff ff ff       	call   f0105800 <printnum>
f0105862:	83 c4 20             	add    $0x20,%esp
f0105865:	eb 18                	jmp    f010587f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105867:	83 ec 08             	sub    $0x8,%esp
f010586a:	56                   	push   %esi
f010586b:	ff 75 18             	pushl  0x18(%ebp)
f010586e:	ff d7                	call   *%edi
f0105870:	83 c4 10             	add    $0x10,%esp
f0105873:	eb 03                	jmp    f0105878 <printnum+0x78>
f0105875:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105878:	83 eb 01             	sub    $0x1,%ebx
f010587b:	85 db                	test   %ebx,%ebx
f010587d:	7f e8                	jg     f0105867 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010587f:	83 ec 08             	sub    $0x8,%esp
f0105882:	56                   	push   %esi
f0105883:	83 ec 04             	sub    $0x4,%esp
f0105886:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105889:	ff 75 e0             	pushl  -0x20(%ebp)
f010588c:	ff 75 dc             	pushl  -0x24(%ebp)
f010588f:	ff 75 d8             	pushl  -0x28(%ebp)
f0105892:	e8 69 12 00 00       	call   f0106b00 <__umoddi3>
f0105897:	83 c4 14             	add    $0x14,%esp
f010589a:	0f be 80 ce 85 10 f0 	movsbl -0xfef7a32(%eax),%eax
f01058a1:	50                   	push   %eax
f01058a2:	ff d7                	call   *%edi
}
f01058a4:	83 c4 10             	add    $0x10,%esp
f01058a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01058aa:	5b                   	pop    %ebx
f01058ab:	5e                   	pop    %esi
f01058ac:	5f                   	pop    %edi
f01058ad:	5d                   	pop    %ebp
f01058ae:	c3                   	ret    

f01058af <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01058af:	55                   	push   %ebp
f01058b0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01058b2:	83 fa 01             	cmp    $0x1,%edx
f01058b5:	7e 0e                	jle    f01058c5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01058b7:	8b 10                	mov    (%eax),%edx
f01058b9:	8d 4a 08             	lea    0x8(%edx),%ecx
f01058bc:	89 08                	mov    %ecx,(%eax)
f01058be:	8b 02                	mov    (%edx),%eax
f01058c0:	8b 52 04             	mov    0x4(%edx),%edx
f01058c3:	eb 22                	jmp    f01058e7 <getuint+0x38>
	else if (lflag)
f01058c5:	85 d2                	test   %edx,%edx
f01058c7:	74 10                	je     f01058d9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01058c9:	8b 10                	mov    (%eax),%edx
f01058cb:	8d 4a 04             	lea    0x4(%edx),%ecx
f01058ce:	89 08                	mov    %ecx,(%eax)
f01058d0:	8b 02                	mov    (%edx),%eax
f01058d2:	ba 00 00 00 00       	mov    $0x0,%edx
f01058d7:	eb 0e                	jmp    f01058e7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01058d9:	8b 10                	mov    (%eax),%edx
f01058db:	8d 4a 04             	lea    0x4(%edx),%ecx
f01058de:	89 08                	mov    %ecx,(%eax)
f01058e0:	8b 02                	mov    (%edx),%eax
f01058e2:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01058e7:	5d                   	pop    %ebp
f01058e8:	c3                   	ret    

f01058e9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01058e9:	55                   	push   %ebp
f01058ea:	89 e5                	mov    %esp,%ebp
f01058ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01058ef:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01058f3:	8b 10                	mov    (%eax),%edx
f01058f5:	3b 50 04             	cmp    0x4(%eax),%edx
f01058f8:	73 0a                	jae    f0105904 <sprintputch+0x1b>
		*b->buf++ = ch;
f01058fa:	8d 4a 01             	lea    0x1(%edx),%ecx
f01058fd:	89 08                	mov    %ecx,(%eax)
f01058ff:	8b 45 08             	mov    0x8(%ebp),%eax
f0105902:	88 02                	mov    %al,(%edx)
}
f0105904:	5d                   	pop    %ebp
f0105905:	c3                   	ret    

f0105906 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105906:	55                   	push   %ebp
f0105907:	89 e5                	mov    %esp,%ebp
f0105909:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010590c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010590f:	50                   	push   %eax
f0105910:	ff 75 10             	pushl  0x10(%ebp)
f0105913:	ff 75 0c             	pushl  0xc(%ebp)
f0105916:	ff 75 08             	pushl  0x8(%ebp)
f0105919:	e8 05 00 00 00       	call   f0105923 <vprintfmt>
	va_end(ap);
}
f010591e:	83 c4 10             	add    $0x10,%esp
f0105921:	c9                   	leave  
f0105922:	c3                   	ret    

f0105923 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105923:	55                   	push   %ebp
f0105924:	89 e5                	mov    %esp,%ebp
f0105926:	57                   	push   %edi
f0105927:	56                   	push   %esi
f0105928:	53                   	push   %ebx
f0105929:	83 ec 2c             	sub    $0x2c,%esp
f010592c:	8b 75 08             	mov    0x8(%ebp),%esi
f010592f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105932:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105935:	eb 12                	jmp    f0105949 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105937:	85 c0                	test   %eax,%eax
f0105939:	0f 84 89 03 00 00    	je     f0105cc8 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f010593f:	83 ec 08             	sub    $0x8,%esp
f0105942:	53                   	push   %ebx
f0105943:	50                   	push   %eax
f0105944:	ff d6                	call   *%esi
f0105946:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105949:	83 c7 01             	add    $0x1,%edi
f010594c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105950:	83 f8 25             	cmp    $0x25,%eax
f0105953:	75 e2                	jne    f0105937 <vprintfmt+0x14>
f0105955:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0105959:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0105960:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105967:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f010596e:	ba 00 00 00 00       	mov    $0x0,%edx
f0105973:	eb 07                	jmp    f010597c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105975:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105978:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010597c:	8d 47 01             	lea    0x1(%edi),%eax
f010597f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105982:	0f b6 07             	movzbl (%edi),%eax
f0105985:	0f b6 c8             	movzbl %al,%ecx
f0105988:	83 e8 23             	sub    $0x23,%eax
f010598b:	3c 55                	cmp    $0x55,%al
f010598d:	0f 87 1a 03 00 00    	ja     f0105cad <vprintfmt+0x38a>
f0105993:	0f b6 c0             	movzbl %al,%eax
f0105996:	ff 24 85 20 87 10 f0 	jmp    *-0xfef78e0(,%eax,4)
f010599d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01059a0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f01059a4:	eb d6                	jmp    f010597c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01059a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01059a9:	b8 00 00 00 00       	mov    $0x0,%eax
f01059ae:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01059b1:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01059b4:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f01059b8:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f01059bb:	8d 51 d0             	lea    -0x30(%ecx),%edx
f01059be:	83 fa 09             	cmp    $0x9,%edx
f01059c1:	77 39                	ja     f01059fc <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01059c3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01059c6:	eb e9                	jmp    f01059b1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01059c8:	8b 45 14             	mov    0x14(%ebp),%eax
f01059cb:	8d 48 04             	lea    0x4(%eax),%ecx
f01059ce:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01059d1:	8b 00                	mov    (%eax),%eax
f01059d3:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01059d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01059d9:	eb 27                	jmp    f0105a02 <vprintfmt+0xdf>
f01059db:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01059de:	85 c0                	test   %eax,%eax
f01059e0:	b9 00 00 00 00       	mov    $0x0,%ecx
f01059e5:	0f 49 c8             	cmovns %eax,%ecx
f01059e8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01059eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01059ee:	eb 8c                	jmp    f010597c <vprintfmt+0x59>
f01059f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01059f3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01059fa:	eb 80                	jmp    f010597c <vprintfmt+0x59>
f01059fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01059ff:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0105a02:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105a06:	0f 89 70 ff ff ff    	jns    f010597c <vprintfmt+0x59>
				width = precision, precision = -1;
f0105a0c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105a0f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105a12:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105a19:	e9 5e ff ff ff       	jmp    f010597c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105a1e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a21:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105a24:	e9 53 ff ff ff       	jmp    f010597c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105a29:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a2c:	8d 50 04             	lea    0x4(%eax),%edx
f0105a2f:	89 55 14             	mov    %edx,0x14(%ebp)
f0105a32:	83 ec 08             	sub    $0x8,%esp
f0105a35:	53                   	push   %ebx
f0105a36:	ff 30                	pushl  (%eax)
f0105a38:	ff d6                	call   *%esi
			break;
f0105a3a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a3d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105a40:	e9 04 ff ff ff       	jmp    f0105949 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105a45:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a48:	8d 50 04             	lea    0x4(%eax),%edx
f0105a4b:	89 55 14             	mov    %edx,0x14(%ebp)
f0105a4e:	8b 00                	mov    (%eax),%eax
f0105a50:	99                   	cltd   
f0105a51:	31 d0                	xor    %edx,%eax
f0105a53:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105a55:	83 f8 0f             	cmp    $0xf,%eax
f0105a58:	7f 0b                	jg     f0105a65 <vprintfmt+0x142>
f0105a5a:	8b 14 85 80 88 10 f0 	mov    -0xfef7780(,%eax,4),%edx
f0105a61:	85 d2                	test   %edx,%edx
f0105a63:	75 18                	jne    f0105a7d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0105a65:	50                   	push   %eax
f0105a66:	68 e6 85 10 f0       	push   $0xf01085e6
f0105a6b:	53                   	push   %ebx
f0105a6c:	56                   	push   %esi
f0105a6d:	e8 94 fe ff ff       	call   f0105906 <printfmt>
f0105a72:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a75:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105a78:	e9 cc fe ff ff       	jmp    f0105949 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0105a7d:	52                   	push   %edx
f0105a7e:	68 a6 7b 10 f0       	push   $0xf0107ba6
f0105a83:	53                   	push   %ebx
f0105a84:	56                   	push   %esi
f0105a85:	e8 7c fe ff ff       	call   f0105906 <printfmt>
f0105a8a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a8d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105a90:	e9 b4 fe ff ff       	jmp    f0105949 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105a95:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a98:	8d 50 04             	lea    0x4(%eax),%edx
f0105a9b:	89 55 14             	mov    %edx,0x14(%ebp)
f0105a9e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0105aa0:	85 ff                	test   %edi,%edi
f0105aa2:	b8 df 85 10 f0       	mov    $0xf01085df,%eax
f0105aa7:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0105aaa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105aae:	0f 8e 94 00 00 00    	jle    f0105b48 <vprintfmt+0x225>
f0105ab4:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0105ab8:	0f 84 98 00 00 00    	je     f0105b56 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105abe:	83 ec 08             	sub    $0x8,%esp
f0105ac1:	ff 75 d0             	pushl  -0x30(%ebp)
f0105ac4:	57                   	push   %edi
f0105ac5:	e8 77 03 00 00       	call   f0105e41 <strnlen>
f0105aca:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105acd:	29 c1                	sub    %eax,%ecx
f0105acf:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0105ad2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0105ad5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105ad9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105adc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105adf:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105ae1:	eb 0f                	jmp    f0105af2 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0105ae3:	83 ec 08             	sub    $0x8,%esp
f0105ae6:	53                   	push   %ebx
f0105ae7:	ff 75 e0             	pushl  -0x20(%ebp)
f0105aea:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105aec:	83 ef 01             	sub    $0x1,%edi
f0105aef:	83 c4 10             	add    $0x10,%esp
f0105af2:	85 ff                	test   %edi,%edi
f0105af4:	7f ed                	jg     f0105ae3 <vprintfmt+0x1c0>
f0105af6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105af9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0105afc:	85 c9                	test   %ecx,%ecx
f0105afe:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b03:	0f 49 c1             	cmovns %ecx,%eax
f0105b06:	29 c1                	sub    %eax,%ecx
f0105b08:	89 75 08             	mov    %esi,0x8(%ebp)
f0105b0b:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105b0e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105b11:	89 cb                	mov    %ecx,%ebx
f0105b13:	eb 4d                	jmp    f0105b62 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105b15:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105b19:	74 1b                	je     f0105b36 <vprintfmt+0x213>
f0105b1b:	0f be c0             	movsbl %al,%eax
f0105b1e:	83 e8 20             	sub    $0x20,%eax
f0105b21:	83 f8 5e             	cmp    $0x5e,%eax
f0105b24:	76 10                	jbe    f0105b36 <vprintfmt+0x213>
					putch('?', putdat);
f0105b26:	83 ec 08             	sub    $0x8,%esp
f0105b29:	ff 75 0c             	pushl  0xc(%ebp)
f0105b2c:	6a 3f                	push   $0x3f
f0105b2e:	ff 55 08             	call   *0x8(%ebp)
f0105b31:	83 c4 10             	add    $0x10,%esp
f0105b34:	eb 0d                	jmp    f0105b43 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0105b36:	83 ec 08             	sub    $0x8,%esp
f0105b39:	ff 75 0c             	pushl  0xc(%ebp)
f0105b3c:	52                   	push   %edx
f0105b3d:	ff 55 08             	call   *0x8(%ebp)
f0105b40:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105b43:	83 eb 01             	sub    $0x1,%ebx
f0105b46:	eb 1a                	jmp    f0105b62 <vprintfmt+0x23f>
f0105b48:	89 75 08             	mov    %esi,0x8(%ebp)
f0105b4b:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105b4e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105b51:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105b54:	eb 0c                	jmp    f0105b62 <vprintfmt+0x23f>
f0105b56:	89 75 08             	mov    %esi,0x8(%ebp)
f0105b59:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105b5c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105b5f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105b62:	83 c7 01             	add    $0x1,%edi
f0105b65:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105b69:	0f be d0             	movsbl %al,%edx
f0105b6c:	85 d2                	test   %edx,%edx
f0105b6e:	74 23                	je     f0105b93 <vprintfmt+0x270>
f0105b70:	85 f6                	test   %esi,%esi
f0105b72:	78 a1                	js     f0105b15 <vprintfmt+0x1f2>
f0105b74:	83 ee 01             	sub    $0x1,%esi
f0105b77:	79 9c                	jns    f0105b15 <vprintfmt+0x1f2>
f0105b79:	89 df                	mov    %ebx,%edi
f0105b7b:	8b 75 08             	mov    0x8(%ebp),%esi
f0105b7e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105b81:	eb 18                	jmp    f0105b9b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105b83:	83 ec 08             	sub    $0x8,%esp
f0105b86:	53                   	push   %ebx
f0105b87:	6a 20                	push   $0x20
f0105b89:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105b8b:	83 ef 01             	sub    $0x1,%edi
f0105b8e:	83 c4 10             	add    $0x10,%esp
f0105b91:	eb 08                	jmp    f0105b9b <vprintfmt+0x278>
f0105b93:	89 df                	mov    %ebx,%edi
f0105b95:	8b 75 08             	mov    0x8(%ebp),%esi
f0105b98:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105b9b:	85 ff                	test   %edi,%edi
f0105b9d:	7f e4                	jg     f0105b83 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b9f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105ba2:	e9 a2 fd ff ff       	jmp    f0105949 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105ba7:	83 fa 01             	cmp    $0x1,%edx
f0105baa:	7e 16                	jle    f0105bc2 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0105bac:	8b 45 14             	mov    0x14(%ebp),%eax
f0105baf:	8d 50 08             	lea    0x8(%eax),%edx
f0105bb2:	89 55 14             	mov    %edx,0x14(%ebp)
f0105bb5:	8b 50 04             	mov    0x4(%eax),%edx
f0105bb8:	8b 00                	mov    (%eax),%eax
f0105bba:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105bbd:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105bc0:	eb 32                	jmp    f0105bf4 <vprintfmt+0x2d1>
	else if (lflag)
f0105bc2:	85 d2                	test   %edx,%edx
f0105bc4:	74 18                	je     f0105bde <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0105bc6:	8b 45 14             	mov    0x14(%ebp),%eax
f0105bc9:	8d 50 04             	lea    0x4(%eax),%edx
f0105bcc:	89 55 14             	mov    %edx,0x14(%ebp)
f0105bcf:	8b 00                	mov    (%eax),%eax
f0105bd1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105bd4:	89 c1                	mov    %eax,%ecx
f0105bd6:	c1 f9 1f             	sar    $0x1f,%ecx
f0105bd9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105bdc:	eb 16                	jmp    f0105bf4 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0105bde:	8b 45 14             	mov    0x14(%ebp),%eax
f0105be1:	8d 50 04             	lea    0x4(%eax),%edx
f0105be4:	89 55 14             	mov    %edx,0x14(%ebp)
f0105be7:	8b 00                	mov    (%eax),%eax
f0105be9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105bec:	89 c1                	mov    %eax,%ecx
f0105bee:	c1 f9 1f             	sar    $0x1f,%ecx
f0105bf1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105bf4:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105bf7:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105bfa:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105bff:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105c03:	79 74                	jns    f0105c79 <vprintfmt+0x356>
				putch('-', putdat);
f0105c05:	83 ec 08             	sub    $0x8,%esp
f0105c08:	53                   	push   %ebx
f0105c09:	6a 2d                	push   $0x2d
f0105c0b:	ff d6                	call   *%esi
				num = -(long long) num;
f0105c0d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105c10:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105c13:	f7 d8                	neg    %eax
f0105c15:	83 d2 00             	adc    $0x0,%edx
f0105c18:	f7 da                	neg    %edx
f0105c1a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0105c1d:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0105c22:	eb 55                	jmp    f0105c79 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105c24:	8d 45 14             	lea    0x14(%ebp),%eax
f0105c27:	e8 83 fc ff ff       	call   f01058af <getuint>
			base = 10;
f0105c2c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0105c31:	eb 46                	jmp    f0105c79 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0105c33:	8d 45 14             	lea    0x14(%ebp),%eax
f0105c36:	e8 74 fc ff ff       	call   f01058af <getuint>
			base = 8;
f0105c3b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0105c40:	eb 37                	jmp    f0105c79 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0105c42:	83 ec 08             	sub    $0x8,%esp
f0105c45:	53                   	push   %ebx
f0105c46:	6a 30                	push   $0x30
f0105c48:	ff d6                	call   *%esi
			putch('x', putdat);
f0105c4a:	83 c4 08             	add    $0x8,%esp
f0105c4d:	53                   	push   %ebx
f0105c4e:	6a 78                	push   $0x78
f0105c50:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105c52:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c55:	8d 50 04             	lea    0x4(%eax),%edx
f0105c58:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105c5b:	8b 00                	mov    (%eax),%eax
f0105c5d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0105c62:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105c65:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0105c6a:	eb 0d                	jmp    f0105c79 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105c6c:	8d 45 14             	lea    0x14(%ebp),%eax
f0105c6f:	e8 3b fc ff ff       	call   f01058af <getuint>
			base = 16;
f0105c74:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105c79:	83 ec 0c             	sub    $0xc,%esp
f0105c7c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0105c80:	57                   	push   %edi
f0105c81:	ff 75 e0             	pushl  -0x20(%ebp)
f0105c84:	51                   	push   %ecx
f0105c85:	52                   	push   %edx
f0105c86:	50                   	push   %eax
f0105c87:	89 da                	mov    %ebx,%edx
f0105c89:	89 f0                	mov    %esi,%eax
f0105c8b:	e8 70 fb ff ff       	call   f0105800 <printnum>
			break;
f0105c90:	83 c4 20             	add    $0x20,%esp
f0105c93:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105c96:	e9 ae fc ff ff       	jmp    f0105949 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105c9b:	83 ec 08             	sub    $0x8,%esp
f0105c9e:	53                   	push   %ebx
f0105c9f:	51                   	push   %ecx
f0105ca0:	ff d6                	call   *%esi
			break;
f0105ca2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105ca5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105ca8:	e9 9c fc ff ff       	jmp    f0105949 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105cad:	83 ec 08             	sub    $0x8,%esp
f0105cb0:	53                   	push   %ebx
f0105cb1:	6a 25                	push   $0x25
f0105cb3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105cb5:	83 c4 10             	add    $0x10,%esp
f0105cb8:	eb 03                	jmp    f0105cbd <vprintfmt+0x39a>
f0105cba:	83 ef 01             	sub    $0x1,%edi
f0105cbd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0105cc1:	75 f7                	jne    f0105cba <vprintfmt+0x397>
f0105cc3:	e9 81 fc ff ff       	jmp    f0105949 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0105cc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105ccb:	5b                   	pop    %ebx
f0105ccc:	5e                   	pop    %esi
f0105ccd:	5f                   	pop    %edi
f0105cce:	5d                   	pop    %ebp
f0105ccf:	c3                   	ret    

f0105cd0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105cd0:	55                   	push   %ebp
f0105cd1:	89 e5                	mov    %esp,%ebp
f0105cd3:	83 ec 18             	sub    $0x18,%esp
f0105cd6:	8b 45 08             	mov    0x8(%ebp),%eax
f0105cd9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105cdc:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105cdf:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105ce3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105ce6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105ced:	85 c0                	test   %eax,%eax
f0105cef:	74 26                	je     f0105d17 <vsnprintf+0x47>
f0105cf1:	85 d2                	test   %edx,%edx
f0105cf3:	7e 22                	jle    f0105d17 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105cf5:	ff 75 14             	pushl  0x14(%ebp)
f0105cf8:	ff 75 10             	pushl  0x10(%ebp)
f0105cfb:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105cfe:	50                   	push   %eax
f0105cff:	68 e9 58 10 f0       	push   $0xf01058e9
f0105d04:	e8 1a fc ff ff       	call   f0105923 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105d09:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105d0c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105d12:	83 c4 10             	add    $0x10,%esp
f0105d15:	eb 05                	jmp    f0105d1c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105d17:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105d1c:	c9                   	leave  
f0105d1d:	c3                   	ret    

f0105d1e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105d1e:	55                   	push   %ebp
f0105d1f:	89 e5                	mov    %esp,%ebp
f0105d21:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105d24:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105d27:	50                   	push   %eax
f0105d28:	ff 75 10             	pushl  0x10(%ebp)
f0105d2b:	ff 75 0c             	pushl  0xc(%ebp)
f0105d2e:	ff 75 08             	pushl  0x8(%ebp)
f0105d31:	e8 9a ff ff ff       	call   f0105cd0 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105d36:	c9                   	leave  
f0105d37:	c3                   	ret    

f0105d38 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105d38:	55                   	push   %ebp
f0105d39:	89 e5                	mov    %esp,%ebp
f0105d3b:	57                   	push   %edi
f0105d3c:	56                   	push   %esi
f0105d3d:	53                   	push   %ebx
f0105d3e:	83 ec 0c             	sub    $0xc,%esp
f0105d41:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105d44:	85 c0                	test   %eax,%eax
f0105d46:	74 11                	je     f0105d59 <readline+0x21>
		cprintf("%s", prompt);
f0105d48:	83 ec 08             	sub    $0x8,%esp
f0105d4b:	50                   	push   %eax
f0105d4c:	68 a6 7b 10 f0       	push   $0xf0107ba6
f0105d51:	e8 8a e0 ff ff       	call   f0103de0 <cprintf>
f0105d56:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105d59:	83 ec 0c             	sub    $0xc,%esp
f0105d5c:	6a 00                	push   $0x0
f0105d5e:	e8 57 aa ff ff       	call   f01007ba <iscons>
f0105d63:	89 c7                	mov    %eax,%edi
f0105d65:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f0105d68:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105d6d:	e8 37 aa ff ff       	call   f01007a9 <getchar>
f0105d72:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105d74:	85 c0                	test   %eax,%eax
f0105d76:	79 29                	jns    f0105da1 <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0105d78:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f0105d7d:	83 fb f8             	cmp    $0xfffffff8,%ebx
f0105d80:	0f 84 9b 00 00 00    	je     f0105e21 <readline+0xe9>
				cprintf("read error: %e\n", c);
f0105d86:	83 ec 08             	sub    $0x8,%esp
f0105d89:	53                   	push   %ebx
f0105d8a:	68 df 88 10 f0       	push   $0xf01088df
f0105d8f:	e8 4c e0 ff ff       	call   f0103de0 <cprintf>
f0105d94:	83 c4 10             	add    $0x10,%esp
			return NULL;
f0105d97:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d9c:	e9 80 00 00 00       	jmp    f0105e21 <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105da1:	83 f8 08             	cmp    $0x8,%eax
f0105da4:	0f 94 c2             	sete   %dl
f0105da7:	83 f8 7f             	cmp    $0x7f,%eax
f0105daa:	0f 94 c0             	sete   %al
f0105dad:	08 c2                	or     %al,%dl
f0105daf:	74 1a                	je     f0105dcb <readline+0x93>
f0105db1:	85 f6                	test   %esi,%esi
f0105db3:	7e 16                	jle    f0105dcb <readline+0x93>
			if (echoing)
f0105db5:	85 ff                	test   %edi,%edi
f0105db7:	74 0d                	je     f0105dc6 <readline+0x8e>
				cputchar('\b');
f0105db9:	83 ec 0c             	sub    $0xc,%esp
f0105dbc:	6a 08                	push   $0x8
f0105dbe:	e8 d6 a9 ff ff       	call   f0100799 <cputchar>
f0105dc3:	83 c4 10             	add    $0x10,%esp
			i--;
f0105dc6:	83 ee 01             	sub    $0x1,%esi
f0105dc9:	eb a2                	jmp    f0105d6d <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105dcb:	83 fb 1f             	cmp    $0x1f,%ebx
f0105dce:	7e 26                	jle    f0105df6 <readline+0xbe>
f0105dd0:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105dd6:	7f 1e                	jg     f0105df6 <readline+0xbe>
			if (echoing)
f0105dd8:	85 ff                	test   %edi,%edi
f0105dda:	74 0c                	je     f0105de8 <readline+0xb0>
				cputchar(c);
f0105ddc:	83 ec 0c             	sub    $0xc,%esp
f0105ddf:	53                   	push   %ebx
f0105de0:	e8 b4 a9 ff ff       	call   f0100799 <cputchar>
f0105de5:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105de8:	88 9e 80 fa 21 f0    	mov    %bl,-0xfde0580(%esi)
f0105dee:	8d 76 01             	lea    0x1(%esi),%esi
f0105df1:	e9 77 ff ff ff       	jmp    f0105d6d <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105df6:	83 fb 0a             	cmp    $0xa,%ebx
f0105df9:	74 09                	je     f0105e04 <readline+0xcc>
f0105dfb:	83 fb 0d             	cmp    $0xd,%ebx
f0105dfe:	0f 85 69 ff ff ff    	jne    f0105d6d <readline+0x35>
			if (echoing)
f0105e04:	85 ff                	test   %edi,%edi
f0105e06:	74 0d                	je     f0105e15 <readline+0xdd>
				cputchar('\n');
f0105e08:	83 ec 0c             	sub    $0xc,%esp
f0105e0b:	6a 0a                	push   $0xa
f0105e0d:	e8 87 a9 ff ff       	call   f0100799 <cputchar>
f0105e12:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105e15:	c6 86 80 fa 21 f0 00 	movb   $0x0,-0xfde0580(%esi)
			return buf;
f0105e1c:	b8 80 fa 21 f0       	mov    $0xf021fa80,%eax
		}
	}
}
f0105e21:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105e24:	5b                   	pop    %ebx
f0105e25:	5e                   	pop    %esi
f0105e26:	5f                   	pop    %edi
f0105e27:	5d                   	pop    %ebp
f0105e28:	c3                   	ret    

f0105e29 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105e29:	55                   	push   %ebp
f0105e2a:	89 e5                	mov    %esp,%ebp
f0105e2c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105e2f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e34:	eb 03                	jmp    f0105e39 <strlen+0x10>
		n++;
f0105e36:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105e39:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105e3d:	75 f7                	jne    f0105e36 <strlen+0xd>
		n++;
	return n;
}
f0105e3f:	5d                   	pop    %ebp
f0105e40:	c3                   	ret    

f0105e41 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105e41:	55                   	push   %ebp
f0105e42:	89 e5                	mov    %esp,%ebp
f0105e44:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105e47:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105e4a:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e4f:	eb 03                	jmp    f0105e54 <strnlen+0x13>
		n++;
f0105e51:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105e54:	39 c2                	cmp    %eax,%edx
f0105e56:	74 08                	je     f0105e60 <strnlen+0x1f>
f0105e58:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0105e5c:	75 f3                	jne    f0105e51 <strnlen+0x10>
f0105e5e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0105e60:	5d                   	pop    %ebp
f0105e61:	c3                   	ret    

f0105e62 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105e62:	55                   	push   %ebp
f0105e63:	89 e5                	mov    %esp,%ebp
f0105e65:	53                   	push   %ebx
f0105e66:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105e6c:	89 c2                	mov    %eax,%edx
f0105e6e:	83 c2 01             	add    $0x1,%edx
f0105e71:	83 c1 01             	add    $0x1,%ecx
f0105e74:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105e78:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105e7b:	84 db                	test   %bl,%bl
f0105e7d:	75 ef                	jne    f0105e6e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105e7f:	5b                   	pop    %ebx
f0105e80:	5d                   	pop    %ebp
f0105e81:	c3                   	ret    

f0105e82 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105e82:	55                   	push   %ebp
f0105e83:	89 e5                	mov    %esp,%ebp
f0105e85:	53                   	push   %ebx
f0105e86:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105e89:	53                   	push   %ebx
f0105e8a:	e8 9a ff ff ff       	call   f0105e29 <strlen>
f0105e8f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105e92:	ff 75 0c             	pushl  0xc(%ebp)
f0105e95:	01 d8                	add    %ebx,%eax
f0105e97:	50                   	push   %eax
f0105e98:	e8 c5 ff ff ff       	call   f0105e62 <strcpy>
	return dst;
}
f0105e9d:	89 d8                	mov    %ebx,%eax
f0105e9f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105ea2:	c9                   	leave  
f0105ea3:	c3                   	ret    

f0105ea4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105ea4:	55                   	push   %ebp
f0105ea5:	89 e5                	mov    %esp,%ebp
f0105ea7:	56                   	push   %esi
f0105ea8:	53                   	push   %ebx
f0105ea9:	8b 75 08             	mov    0x8(%ebp),%esi
f0105eac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105eaf:	89 f3                	mov    %esi,%ebx
f0105eb1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105eb4:	89 f2                	mov    %esi,%edx
f0105eb6:	eb 0f                	jmp    f0105ec7 <strncpy+0x23>
		*dst++ = *src;
f0105eb8:	83 c2 01             	add    $0x1,%edx
f0105ebb:	0f b6 01             	movzbl (%ecx),%eax
f0105ebe:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105ec1:	80 39 01             	cmpb   $0x1,(%ecx)
f0105ec4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105ec7:	39 da                	cmp    %ebx,%edx
f0105ec9:	75 ed                	jne    f0105eb8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105ecb:	89 f0                	mov    %esi,%eax
f0105ecd:	5b                   	pop    %ebx
f0105ece:	5e                   	pop    %esi
f0105ecf:	5d                   	pop    %ebp
f0105ed0:	c3                   	ret    

f0105ed1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105ed1:	55                   	push   %ebp
f0105ed2:	89 e5                	mov    %esp,%ebp
f0105ed4:	56                   	push   %esi
f0105ed5:	53                   	push   %ebx
f0105ed6:	8b 75 08             	mov    0x8(%ebp),%esi
f0105ed9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105edc:	8b 55 10             	mov    0x10(%ebp),%edx
f0105edf:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105ee1:	85 d2                	test   %edx,%edx
f0105ee3:	74 21                	je     f0105f06 <strlcpy+0x35>
f0105ee5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105ee9:	89 f2                	mov    %esi,%edx
f0105eeb:	eb 09                	jmp    f0105ef6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105eed:	83 c2 01             	add    $0x1,%edx
f0105ef0:	83 c1 01             	add    $0x1,%ecx
f0105ef3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105ef6:	39 c2                	cmp    %eax,%edx
f0105ef8:	74 09                	je     f0105f03 <strlcpy+0x32>
f0105efa:	0f b6 19             	movzbl (%ecx),%ebx
f0105efd:	84 db                	test   %bl,%bl
f0105eff:	75 ec                	jne    f0105eed <strlcpy+0x1c>
f0105f01:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105f03:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105f06:	29 f0                	sub    %esi,%eax
}
f0105f08:	5b                   	pop    %ebx
f0105f09:	5e                   	pop    %esi
f0105f0a:	5d                   	pop    %ebp
f0105f0b:	c3                   	ret    

f0105f0c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105f0c:	55                   	push   %ebp
f0105f0d:	89 e5                	mov    %esp,%ebp
f0105f0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105f12:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105f15:	eb 06                	jmp    f0105f1d <strcmp+0x11>
		p++, q++;
f0105f17:	83 c1 01             	add    $0x1,%ecx
f0105f1a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105f1d:	0f b6 01             	movzbl (%ecx),%eax
f0105f20:	84 c0                	test   %al,%al
f0105f22:	74 04                	je     f0105f28 <strcmp+0x1c>
f0105f24:	3a 02                	cmp    (%edx),%al
f0105f26:	74 ef                	je     f0105f17 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105f28:	0f b6 c0             	movzbl %al,%eax
f0105f2b:	0f b6 12             	movzbl (%edx),%edx
f0105f2e:	29 d0                	sub    %edx,%eax
}
f0105f30:	5d                   	pop    %ebp
f0105f31:	c3                   	ret    

f0105f32 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105f32:	55                   	push   %ebp
f0105f33:	89 e5                	mov    %esp,%ebp
f0105f35:	53                   	push   %ebx
f0105f36:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f39:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105f3c:	89 c3                	mov    %eax,%ebx
f0105f3e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105f41:	eb 06                	jmp    f0105f49 <strncmp+0x17>
		n--, p++, q++;
f0105f43:	83 c0 01             	add    $0x1,%eax
f0105f46:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105f49:	39 d8                	cmp    %ebx,%eax
f0105f4b:	74 15                	je     f0105f62 <strncmp+0x30>
f0105f4d:	0f b6 08             	movzbl (%eax),%ecx
f0105f50:	84 c9                	test   %cl,%cl
f0105f52:	74 04                	je     f0105f58 <strncmp+0x26>
f0105f54:	3a 0a                	cmp    (%edx),%cl
f0105f56:	74 eb                	je     f0105f43 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105f58:	0f b6 00             	movzbl (%eax),%eax
f0105f5b:	0f b6 12             	movzbl (%edx),%edx
f0105f5e:	29 d0                	sub    %edx,%eax
f0105f60:	eb 05                	jmp    f0105f67 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105f62:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105f67:	5b                   	pop    %ebx
f0105f68:	5d                   	pop    %ebp
f0105f69:	c3                   	ret    

f0105f6a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105f6a:	55                   	push   %ebp
f0105f6b:	89 e5                	mov    %esp,%ebp
f0105f6d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f70:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105f74:	eb 07                	jmp    f0105f7d <strchr+0x13>
		if (*s == c)
f0105f76:	38 ca                	cmp    %cl,%dl
f0105f78:	74 0f                	je     f0105f89 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105f7a:	83 c0 01             	add    $0x1,%eax
f0105f7d:	0f b6 10             	movzbl (%eax),%edx
f0105f80:	84 d2                	test   %dl,%dl
f0105f82:	75 f2                	jne    f0105f76 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105f84:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105f89:	5d                   	pop    %ebp
f0105f8a:	c3                   	ret    

f0105f8b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105f8b:	55                   	push   %ebp
f0105f8c:	89 e5                	mov    %esp,%ebp
f0105f8e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f91:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105f95:	eb 03                	jmp    f0105f9a <strfind+0xf>
f0105f97:	83 c0 01             	add    $0x1,%eax
f0105f9a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105f9d:	38 ca                	cmp    %cl,%dl
f0105f9f:	74 04                	je     f0105fa5 <strfind+0x1a>
f0105fa1:	84 d2                	test   %dl,%dl
f0105fa3:	75 f2                	jne    f0105f97 <strfind+0xc>
			break;
	return (char *) s;
}
f0105fa5:	5d                   	pop    %ebp
f0105fa6:	c3                   	ret    

f0105fa7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105fa7:	55                   	push   %ebp
f0105fa8:	89 e5                	mov    %esp,%ebp
f0105faa:	57                   	push   %edi
f0105fab:	56                   	push   %esi
f0105fac:	53                   	push   %ebx
f0105fad:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105fb0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105fb3:	85 c9                	test   %ecx,%ecx
f0105fb5:	74 36                	je     f0105fed <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105fb7:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105fbd:	75 28                	jne    f0105fe7 <memset+0x40>
f0105fbf:	f6 c1 03             	test   $0x3,%cl
f0105fc2:	75 23                	jne    f0105fe7 <memset+0x40>
		c &= 0xFF;
f0105fc4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105fc8:	89 d3                	mov    %edx,%ebx
f0105fca:	c1 e3 08             	shl    $0x8,%ebx
f0105fcd:	89 d6                	mov    %edx,%esi
f0105fcf:	c1 e6 18             	shl    $0x18,%esi
f0105fd2:	89 d0                	mov    %edx,%eax
f0105fd4:	c1 e0 10             	shl    $0x10,%eax
f0105fd7:	09 f0                	or     %esi,%eax
f0105fd9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0105fdb:	89 d8                	mov    %ebx,%eax
f0105fdd:	09 d0                	or     %edx,%eax
f0105fdf:	c1 e9 02             	shr    $0x2,%ecx
f0105fe2:	fc                   	cld    
f0105fe3:	f3 ab                	rep stos %eax,%es:(%edi)
f0105fe5:	eb 06                	jmp    f0105fed <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105fe7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105fea:	fc                   	cld    
f0105feb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105fed:	89 f8                	mov    %edi,%eax
f0105fef:	5b                   	pop    %ebx
f0105ff0:	5e                   	pop    %esi
f0105ff1:	5f                   	pop    %edi
f0105ff2:	5d                   	pop    %ebp
f0105ff3:	c3                   	ret    

f0105ff4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105ff4:	55                   	push   %ebp
f0105ff5:	89 e5                	mov    %esp,%ebp
f0105ff7:	57                   	push   %edi
f0105ff8:	56                   	push   %esi
f0105ff9:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ffc:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105fff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0106002:	39 c6                	cmp    %eax,%esi
f0106004:	73 35                	jae    f010603b <memmove+0x47>
f0106006:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0106009:	39 d0                	cmp    %edx,%eax
f010600b:	73 2e                	jae    f010603b <memmove+0x47>
		s += n;
		d += n;
f010600d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0106010:	89 d6                	mov    %edx,%esi
f0106012:	09 fe                	or     %edi,%esi
f0106014:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010601a:	75 13                	jne    f010602f <memmove+0x3b>
f010601c:	f6 c1 03             	test   $0x3,%cl
f010601f:	75 0e                	jne    f010602f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0106021:	83 ef 04             	sub    $0x4,%edi
f0106024:	8d 72 fc             	lea    -0x4(%edx),%esi
f0106027:	c1 e9 02             	shr    $0x2,%ecx
f010602a:	fd                   	std    
f010602b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010602d:	eb 09                	jmp    f0106038 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010602f:	83 ef 01             	sub    $0x1,%edi
f0106032:	8d 72 ff             	lea    -0x1(%edx),%esi
f0106035:	fd                   	std    
f0106036:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0106038:	fc                   	cld    
f0106039:	eb 1d                	jmp    f0106058 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010603b:	89 f2                	mov    %esi,%edx
f010603d:	09 c2                	or     %eax,%edx
f010603f:	f6 c2 03             	test   $0x3,%dl
f0106042:	75 0f                	jne    f0106053 <memmove+0x5f>
f0106044:	f6 c1 03             	test   $0x3,%cl
f0106047:	75 0a                	jne    f0106053 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0106049:	c1 e9 02             	shr    $0x2,%ecx
f010604c:	89 c7                	mov    %eax,%edi
f010604e:	fc                   	cld    
f010604f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0106051:	eb 05                	jmp    f0106058 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0106053:	89 c7                	mov    %eax,%edi
f0106055:	fc                   	cld    
f0106056:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0106058:	5e                   	pop    %esi
f0106059:	5f                   	pop    %edi
f010605a:	5d                   	pop    %ebp
f010605b:	c3                   	ret    

f010605c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010605c:	55                   	push   %ebp
f010605d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010605f:	ff 75 10             	pushl  0x10(%ebp)
f0106062:	ff 75 0c             	pushl  0xc(%ebp)
f0106065:	ff 75 08             	pushl  0x8(%ebp)
f0106068:	e8 87 ff ff ff       	call   f0105ff4 <memmove>
}
f010606d:	c9                   	leave  
f010606e:	c3                   	ret    

f010606f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010606f:	55                   	push   %ebp
f0106070:	89 e5                	mov    %esp,%ebp
f0106072:	56                   	push   %esi
f0106073:	53                   	push   %ebx
f0106074:	8b 45 08             	mov    0x8(%ebp),%eax
f0106077:	8b 55 0c             	mov    0xc(%ebp),%edx
f010607a:	89 c6                	mov    %eax,%esi
f010607c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010607f:	eb 1a                	jmp    f010609b <memcmp+0x2c>
		if (*s1 != *s2)
f0106081:	0f b6 08             	movzbl (%eax),%ecx
f0106084:	0f b6 1a             	movzbl (%edx),%ebx
f0106087:	38 d9                	cmp    %bl,%cl
f0106089:	74 0a                	je     f0106095 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010608b:	0f b6 c1             	movzbl %cl,%eax
f010608e:	0f b6 db             	movzbl %bl,%ebx
f0106091:	29 d8                	sub    %ebx,%eax
f0106093:	eb 0f                	jmp    f01060a4 <memcmp+0x35>
		s1++, s2++;
f0106095:	83 c0 01             	add    $0x1,%eax
f0106098:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010609b:	39 f0                	cmp    %esi,%eax
f010609d:	75 e2                	jne    f0106081 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010609f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01060a4:	5b                   	pop    %ebx
f01060a5:	5e                   	pop    %esi
f01060a6:	5d                   	pop    %ebp
f01060a7:	c3                   	ret    

f01060a8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01060a8:	55                   	push   %ebp
f01060a9:	89 e5                	mov    %esp,%ebp
f01060ab:	53                   	push   %ebx
f01060ac:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01060af:	89 c1                	mov    %eax,%ecx
f01060b1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01060b4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01060b8:	eb 0a                	jmp    f01060c4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01060ba:	0f b6 10             	movzbl (%eax),%edx
f01060bd:	39 da                	cmp    %ebx,%edx
f01060bf:	74 07                	je     f01060c8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01060c1:	83 c0 01             	add    $0x1,%eax
f01060c4:	39 c8                	cmp    %ecx,%eax
f01060c6:	72 f2                	jb     f01060ba <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01060c8:	5b                   	pop    %ebx
f01060c9:	5d                   	pop    %ebp
f01060ca:	c3                   	ret    

f01060cb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01060cb:	55                   	push   %ebp
f01060cc:	89 e5                	mov    %esp,%ebp
f01060ce:	57                   	push   %edi
f01060cf:	56                   	push   %esi
f01060d0:	53                   	push   %ebx
f01060d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01060d4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01060d7:	eb 03                	jmp    f01060dc <strtol+0x11>
		s++;
f01060d9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01060dc:	0f b6 01             	movzbl (%ecx),%eax
f01060df:	3c 20                	cmp    $0x20,%al
f01060e1:	74 f6                	je     f01060d9 <strtol+0xe>
f01060e3:	3c 09                	cmp    $0x9,%al
f01060e5:	74 f2                	je     f01060d9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01060e7:	3c 2b                	cmp    $0x2b,%al
f01060e9:	75 0a                	jne    f01060f5 <strtol+0x2a>
		s++;
f01060eb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01060ee:	bf 00 00 00 00       	mov    $0x0,%edi
f01060f3:	eb 11                	jmp    f0106106 <strtol+0x3b>
f01060f5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01060fa:	3c 2d                	cmp    $0x2d,%al
f01060fc:	75 08                	jne    f0106106 <strtol+0x3b>
		s++, neg = 1;
f01060fe:	83 c1 01             	add    $0x1,%ecx
f0106101:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106106:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010610c:	75 15                	jne    f0106123 <strtol+0x58>
f010610e:	80 39 30             	cmpb   $0x30,(%ecx)
f0106111:	75 10                	jne    f0106123 <strtol+0x58>
f0106113:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0106117:	75 7c                	jne    f0106195 <strtol+0xca>
		s += 2, base = 16;
f0106119:	83 c1 02             	add    $0x2,%ecx
f010611c:	bb 10 00 00 00       	mov    $0x10,%ebx
f0106121:	eb 16                	jmp    f0106139 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0106123:	85 db                	test   %ebx,%ebx
f0106125:	75 12                	jne    f0106139 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0106127:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010612c:	80 39 30             	cmpb   $0x30,(%ecx)
f010612f:	75 08                	jne    f0106139 <strtol+0x6e>
		s++, base = 8;
f0106131:	83 c1 01             	add    $0x1,%ecx
f0106134:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0106139:	b8 00 00 00 00       	mov    $0x0,%eax
f010613e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0106141:	0f b6 11             	movzbl (%ecx),%edx
f0106144:	8d 72 d0             	lea    -0x30(%edx),%esi
f0106147:	89 f3                	mov    %esi,%ebx
f0106149:	80 fb 09             	cmp    $0x9,%bl
f010614c:	77 08                	ja     f0106156 <strtol+0x8b>
			dig = *s - '0';
f010614e:	0f be d2             	movsbl %dl,%edx
f0106151:	83 ea 30             	sub    $0x30,%edx
f0106154:	eb 22                	jmp    f0106178 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0106156:	8d 72 9f             	lea    -0x61(%edx),%esi
f0106159:	89 f3                	mov    %esi,%ebx
f010615b:	80 fb 19             	cmp    $0x19,%bl
f010615e:	77 08                	ja     f0106168 <strtol+0x9d>
			dig = *s - 'a' + 10;
f0106160:	0f be d2             	movsbl %dl,%edx
f0106163:	83 ea 57             	sub    $0x57,%edx
f0106166:	eb 10                	jmp    f0106178 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0106168:	8d 72 bf             	lea    -0x41(%edx),%esi
f010616b:	89 f3                	mov    %esi,%ebx
f010616d:	80 fb 19             	cmp    $0x19,%bl
f0106170:	77 16                	ja     f0106188 <strtol+0xbd>
			dig = *s - 'A' + 10;
f0106172:	0f be d2             	movsbl %dl,%edx
f0106175:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0106178:	3b 55 10             	cmp    0x10(%ebp),%edx
f010617b:	7d 0b                	jge    f0106188 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010617d:	83 c1 01             	add    $0x1,%ecx
f0106180:	0f af 45 10          	imul   0x10(%ebp),%eax
f0106184:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0106186:	eb b9                	jmp    f0106141 <strtol+0x76>

	if (endptr)
f0106188:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010618c:	74 0d                	je     f010619b <strtol+0xd0>
		*endptr = (char *) s;
f010618e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106191:	89 0e                	mov    %ecx,(%esi)
f0106193:	eb 06                	jmp    f010619b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0106195:	85 db                	test   %ebx,%ebx
f0106197:	74 98                	je     f0106131 <strtol+0x66>
f0106199:	eb 9e                	jmp    f0106139 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010619b:	89 c2                	mov    %eax,%edx
f010619d:	f7 da                	neg    %edx
f010619f:	85 ff                	test   %edi,%edi
f01061a1:	0f 45 c2             	cmovne %edx,%eax
}
f01061a4:	5b                   	pop    %ebx
f01061a5:	5e                   	pop    %esi
f01061a6:	5f                   	pop    %edi
f01061a7:	5d                   	pop    %ebp
f01061a8:	c3                   	ret    
f01061a9:	66 90                	xchg   %ax,%ax
f01061ab:	90                   	nop

f01061ac <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01061ac:	fa                   	cli    

	xorw    %ax, %ax
f01061ad:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01061af:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01061b1:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01061b3:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01061b5:	0f 01 16             	lgdtl  (%esi)
f01061b8:	74 70                	je     f010622a <mpsearch1+0x3>
	movl    %cr0, %eax
f01061ba:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01061bd:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01061c1:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01061c4:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01061ca:	08 00                	or     %al,(%eax)

f01061cc <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01061cc:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01061d0:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01061d2:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01061d4:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01061d6:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01061da:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01061dc:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01061de:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f01061e3:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01061e6:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01061e9:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01061ee:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01061f1:	8b 25 84 fe 21 f0    	mov    0xf021fe84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01061f7:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01061fc:	b8 c7 01 10 f0       	mov    $0xf01001c7,%eax
	call    *%eax
f0106201:	ff d0                	call   *%eax

f0106203 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0106203:	eb fe                	jmp    f0106203 <spin>
f0106205:	8d 76 00             	lea    0x0(%esi),%esi

f0106208 <gdt>:
	...
f0106210:	ff                   	(bad)  
f0106211:	ff 00                	incl   (%eax)
f0106213:	00 00                	add    %al,(%eax)
f0106215:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f010621c:	00                   	.byte 0x0
f010621d:	92                   	xchg   %eax,%edx
f010621e:	cf                   	iret   
	...

f0106220 <gdtdesc>:
f0106220:	17                   	pop    %ss
f0106221:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0106226 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0106226:	90                   	nop

f0106227 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106227:	55                   	push   %ebp
f0106228:	89 e5                	mov    %esp,%ebp
f010622a:	57                   	push   %edi
f010622b:	56                   	push   %esi
f010622c:	53                   	push   %ebx
f010622d:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106230:	8b 0d 88 fe 21 f0    	mov    0xf021fe88,%ecx
f0106236:	89 c3                	mov    %eax,%ebx
f0106238:	c1 eb 0c             	shr    $0xc,%ebx
f010623b:	39 cb                	cmp    %ecx,%ebx
f010623d:	72 12                	jb     f0106251 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010623f:	50                   	push   %eax
f0106240:	68 84 6c 10 f0       	push   $0xf0106c84
f0106245:	6a 57                	push   $0x57
f0106247:	68 7d 8a 10 f0       	push   $0xf0108a7d
f010624c:	e8 ef 9d ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106251:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0106257:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106259:	89 c2                	mov    %eax,%edx
f010625b:	c1 ea 0c             	shr    $0xc,%edx
f010625e:	39 ca                	cmp    %ecx,%edx
f0106260:	72 12                	jb     f0106274 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106262:	50                   	push   %eax
f0106263:	68 84 6c 10 f0       	push   $0xf0106c84
f0106268:	6a 57                	push   $0x57
f010626a:	68 7d 8a 10 f0       	push   $0xf0108a7d
f010626f:	e8 cc 9d ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106274:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f010627a:	eb 2f                	jmp    f01062ab <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010627c:	83 ec 04             	sub    $0x4,%esp
f010627f:	6a 04                	push   $0x4
f0106281:	68 8d 8a 10 f0       	push   $0xf0108a8d
f0106286:	53                   	push   %ebx
f0106287:	e8 e3 fd ff ff       	call   f010606f <memcmp>
f010628c:	83 c4 10             	add    $0x10,%esp
f010628f:	85 c0                	test   %eax,%eax
f0106291:	75 15                	jne    f01062a8 <mpsearch1+0x81>
f0106293:	89 da                	mov    %ebx,%edx
f0106295:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0106298:	0f b6 0a             	movzbl (%edx),%ecx
f010629b:	01 c8                	add    %ecx,%eax
f010629d:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01062a0:	39 d7                	cmp    %edx,%edi
f01062a2:	75 f4                	jne    f0106298 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01062a4:	84 c0                	test   %al,%al
f01062a6:	74 0e                	je     f01062b6 <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01062a8:	83 c3 10             	add    $0x10,%ebx
f01062ab:	39 f3                	cmp    %esi,%ebx
f01062ad:	72 cd                	jb     f010627c <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01062af:	b8 00 00 00 00       	mov    $0x0,%eax
f01062b4:	eb 02                	jmp    f01062b8 <mpsearch1+0x91>
f01062b6:	89 d8                	mov    %ebx,%eax
}
f01062b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01062bb:	5b                   	pop    %ebx
f01062bc:	5e                   	pop    %esi
f01062bd:	5f                   	pop    %edi
f01062be:	5d                   	pop    %ebp
f01062bf:	c3                   	ret    

f01062c0 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01062c0:	55                   	push   %ebp
f01062c1:	89 e5                	mov    %esp,%ebp
f01062c3:	57                   	push   %edi
f01062c4:	56                   	push   %esi
f01062c5:	53                   	push   %ebx
f01062c6:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01062c9:	c7 05 c0 03 22 f0 20 	movl   $0xf0220020,0xf02203c0
f01062d0:	00 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01062d3:	83 3d 88 fe 21 f0 00 	cmpl   $0x0,0xf021fe88
f01062da:	75 16                	jne    f01062f2 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01062dc:	68 00 04 00 00       	push   $0x400
f01062e1:	68 84 6c 10 f0       	push   $0xf0106c84
f01062e6:	6a 6f                	push   $0x6f
f01062e8:	68 7d 8a 10 f0       	push   $0xf0108a7d
f01062ed:	e8 4e 9d ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01062f2:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01062f9:	85 c0                	test   %eax,%eax
f01062fb:	74 16                	je     f0106313 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f01062fd:	c1 e0 04             	shl    $0x4,%eax
f0106300:	ba 00 04 00 00       	mov    $0x400,%edx
f0106305:	e8 1d ff ff ff       	call   f0106227 <mpsearch1>
f010630a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010630d:	85 c0                	test   %eax,%eax
f010630f:	75 3c                	jne    f010634d <mp_init+0x8d>
f0106311:	eb 20                	jmp    f0106333 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0106313:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f010631a:	c1 e0 0a             	shl    $0xa,%eax
f010631d:	2d 00 04 00 00       	sub    $0x400,%eax
f0106322:	ba 00 04 00 00       	mov    $0x400,%edx
f0106327:	e8 fb fe ff ff       	call   f0106227 <mpsearch1>
f010632c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010632f:	85 c0                	test   %eax,%eax
f0106331:	75 1a                	jne    f010634d <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0106333:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106338:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f010633d:	e8 e5 fe ff ff       	call   f0106227 <mpsearch1>
f0106342:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0106345:	85 c0                	test   %eax,%eax
f0106347:	0f 84 5d 02 00 00    	je     f01065aa <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f010634d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106350:	8b 70 04             	mov    0x4(%eax),%esi
f0106353:	85 f6                	test   %esi,%esi
f0106355:	74 06                	je     f010635d <mp_init+0x9d>
f0106357:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f010635b:	74 15                	je     f0106372 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f010635d:	83 ec 0c             	sub    $0xc,%esp
f0106360:	68 f0 88 10 f0       	push   $0xf01088f0
f0106365:	e8 76 da ff ff       	call   f0103de0 <cprintf>
f010636a:	83 c4 10             	add    $0x10,%esp
f010636d:	e9 38 02 00 00       	jmp    f01065aa <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106372:	89 f0                	mov    %esi,%eax
f0106374:	c1 e8 0c             	shr    $0xc,%eax
f0106377:	3b 05 88 fe 21 f0    	cmp    0xf021fe88,%eax
f010637d:	72 15                	jb     f0106394 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010637f:	56                   	push   %esi
f0106380:	68 84 6c 10 f0       	push   $0xf0106c84
f0106385:	68 90 00 00 00       	push   $0x90
f010638a:	68 7d 8a 10 f0       	push   $0xf0108a7d
f010638f:	e8 ac 9c ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106394:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f010639a:	83 ec 04             	sub    $0x4,%esp
f010639d:	6a 04                	push   $0x4
f010639f:	68 92 8a 10 f0       	push   $0xf0108a92
f01063a4:	53                   	push   %ebx
f01063a5:	e8 c5 fc ff ff       	call   f010606f <memcmp>
f01063aa:	83 c4 10             	add    $0x10,%esp
f01063ad:	85 c0                	test   %eax,%eax
f01063af:	74 15                	je     f01063c6 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f01063b1:	83 ec 0c             	sub    $0xc,%esp
f01063b4:	68 20 89 10 f0       	push   $0xf0108920
f01063b9:	e8 22 da ff ff       	call   f0103de0 <cprintf>
f01063be:	83 c4 10             	add    $0x10,%esp
f01063c1:	e9 e4 01 00 00       	jmp    f01065aa <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01063c6:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f01063ca:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f01063ce:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01063d1:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01063d6:	b8 00 00 00 00       	mov    $0x0,%eax
f01063db:	eb 0d                	jmp    f01063ea <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f01063dd:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f01063e4:	f0 
f01063e5:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01063e7:	83 c0 01             	add    $0x1,%eax
f01063ea:	39 c7                	cmp    %eax,%edi
f01063ec:	75 ef                	jne    f01063dd <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01063ee:	84 d2                	test   %dl,%dl
f01063f0:	74 15                	je     f0106407 <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f01063f2:	83 ec 0c             	sub    $0xc,%esp
f01063f5:	68 54 89 10 f0       	push   $0xf0108954
f01063fa:	e8 e1 d9 ff ff       	call   f0103de0 <cprintf>
f01063ff:	83 c4 10             	add    $0x10,%esp
f0106402:	e9 a3 01 00 00       	jmp    f01065aa <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0106407:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f010640b:	3c 01                	cmp    $0x1,%al
f010640d:	74 1d                	je     f010642c <mp_init+0x16c>
f010640f:	3c 04                	cmp    $0x4,%al
f0106411:	74 19                	je     f010642c <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106413:	83 ec 08             	sub    $0x8,%esp
f0106416:	0f b6 c0             	movzbl %al,%eax
f0106419:	50                   	push   %eax
f010641a:	68 78 89 10 f0       	push   $0xf0108978
f010641f:	e8 bc d9 ff ff       	call   f0103de0 <cprintf>
f0106424:	83 c4 10             	add    $0x10,%esp
f0106427:	e9 7e 01 00 00       	jmp    f01065aa <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010642c:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0106430:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0106434:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0106439:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f010643e:	01 ce                	add    %ecx,%esi
f0106440:	eb 0d                	jmp    f010644f <mp_init+0x18f>
f0106442:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0106449:	f0 
f010644a:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f010644c:	83 c0 01             	add    $0x1,%eax
f010644f:	39 c7                	cmp    %eax,%edi
f0106451:	75 ef                	jne    f0106442 <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0106453:	89 d0                	mov    %edx,%eax
f0106455:	02 43 2a             	add    0x2a(%ebx),%al
f0106458:	74 15                	je     f010646f <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f010645a:	83 ec 0c             	sub    $0xc,%esp
f010645d:	68 98 89 10 f0       	push   $0xf0108998
f0106462:	e8 79 d9 ff ff       	call   f0103de0 <cprintf>
f0106467:	83 c4 10             	add    $0x10,%esp
f010646a:	e9 3b 01 00 00       	jmp    f01065aa <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f010646f:	85 db                	test   %ebx,%ebx
f0106471:	0f 84 33 01 00 00    	je     f01065aa <mp_init+0x2ea>
		return;
	ismp = 1;
f0106477:	c7 05 00 00 22 f0 01 	movl   $0x1,0xf0220000
f010647e:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0106481:	8b 43 24             	mov    0x24(%ebx),%eax
f0106484:	a3 00 10 26 f0       	mov    %eax,0xf0261000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106489:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f010648c:	be 00 00 00 00       	mov    $0x0,%esi
f0106491:	e9 85 00 00 00       	jmp    f010651b <mp_init+0x25b>
		switch (*p) {
f0106496:	0f b6 07             	movzbl (%edi),%eax
f0106499:	84 c0                	test   %al,%al
f010649b:	74 06                	je     f01064a3 <mp_init+0x1e3>
f010649d:	3c 04                	cmp    $0x4,%al
f010649f:	77 55                	ja     f01064f6 <mp_init+0x236>
f01064a1:	eb 4e                	jmp    f01064f1 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f01064a3:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f01064a7:	74 11                	je     f01064ba <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f01064a9:	6b 05 c4 03 22 f0 74 	imul   $0x74,0xf02203c4,%eax
f01064b0:	05 20 00 22 f0       	add    $0xf0220020,%eax
f01064b5:	a3 c0 03 22 f0       	mov    %eax,0xf02203c0
			if (ncpu < NCPU) {
f01064ba:	a1 c4 03 22 f0       	mov    0xf02203c4,%eax
f01064bf:	83 f8 07             	cmp    $0x7,%eax
f01064c2:	7f 13                	jg     f01064d7 <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f01064c4:	6b d0 74             	imul   $0x74,%eax,%edx
f01064c7:	88 82 20 00 22 f0    	mov    %al,-0xfddffe0(%edx)
				ncpu++;
f01064cd:	83 c0 01             	add    $0x1,%eax
f01064d0:	a3 c4 03 22 f0       	mov    %eax,0xf02203c4
f01064d5:	eb 15                	jmp    f01064ec <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01064d7:	83 ec 08             	sub    $0x8,%esp
f01064da:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f01064de:	50                   	push   %eax
f01064df:	68 c8 89 10 f0       	push   $0xf01089c8
f01064e4:	e8 f7 d8 ff ff       	call   f0103de0 <cprintf>
f01064e9:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01064ec:	83 c7 14             	add    $0x14,%edi
			continue;
f01064ef:	eb 27                	jmp    f0106518 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01064f1:	83 c7 08             	add    $0x8,%edi
			continue;
f01064f4:	eb 22                	jmp    f0106518 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01064f6:	83 ec 08             	sub    $0x8,%esp
f01064f9:	0f b6 c0             	movzbl %al,%eax
f01064fc:	50                   	push   %eax
f01064fd:	68 f0 89 10 f0       	push   $0xf01089f0
f0106502:	e8 d9 d8 ff ff       	call   f0103de0 <cprintf>
			ismp = 0;
f0106507:	c7 05 00 00 22 f0 00 	movl   $0x0,0xf0220000
f010650e:	00 00 00 
			i = conf->entry;
f0106511:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0106515:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106518:	83 c6 01             	add    $0x1,%esi
f010651b:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f010651f:	39 c6                	cmp    %eax,%esi
f0106521:	0f 82 6f ff ff ff    	jb     f0106496 <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106527:	a1 c0 03 22 f0       	mov    0xf02203c0,%eax
f010652c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0106533:	83 3d 00 00 22 f0 00 	cmpl   $0x0,0xf0220000
f010653a:	75 26                	jne    f0106562 <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f010653c:	c7 05 c4 03 22 f0 01 	movl   $0x1,0xf02203c4
f0106543:	00 00 00 
		lapicaddr = 0;
f0106546:	c7 05 00 10 26 f0 00 	movl   $0x0,0xf0261000
f010654d:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106550:	83 ec 0c             	sub    $0xc,%esp
f0106553:	68 10 8a 10 f0       	push   $0xf0108a10
f0106558:	e8 83 d8 ff ff       	call   f0103de0 <cprintf>
		return;
f010655d:	83 c4 10             	add    $0x10,%esp
f0106560:	eb 48                	jmp    f01065aa <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0106562:	83 ec 04             	sub    $0x4,%esp
f0106565:	ff 35 c4 03 22 f0    	pushl  0xf02203c4
f010656b:	0f b6 00             	movzbl (%eax),%eax
f010656e:	50                   	push   %eax
f010656f:	68 97 8a 10 f0       	push   $0xf0108a97
f0106574:	e8 67 d8 ff ff       	call   f0103de0 <cprintf>

	if (mp->imcrp) {
f0106579:	83 c4 10             	add    $0x10,%esp
f010657c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010657f:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106583:	74 25                	je     f01065aa <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106585:	83 ec 0c             	sub    $0xc,%esp
f0106588:	68 3c 8a 10 f0       	push   $0xf0108a3c
f010658d:	e8 4e d8 ff ff       	call   f0103de0 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106592:	ba 22 00 00 00       	mov    $0x22,%edx
f0106597:	b8 70 00 00 00       	mov    $0x70,%eax
f010659c:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010659d:	ba 23 00 00 00       	mov    $0x23,%edx
f01065a2:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01065a3:	83 c8 01             	or     $0x1,%eax
f01065a6:	ee                   	out    %al,(%dx)
f01065a7:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f01065aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01065ad:	5b                   	pop    %ebx
f01065ae:	5e                   	pop    %esi
f01065af:	5f                   	pop    %edi
f01065b0:	5d                   	pop    %ebp
f01065b1:	c3                   	ret    

f01065b2 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f01065b2:	55                   	push   %ebp
f01065b3:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01065b5:	8b 0d 04 10 26 f0    	mov    0xf0261004,%ecx
f01065bb:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f01065be:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01065c0:	a1 04 10 26 f0       	mov    0xf0261004,%eax
f01065c5:	8b 40 20             	mov    0x20(%eax),%eax
}
f01065c8:	5d                   	pop    %ebp
f01065c9:	c3                   	ret    

f01065ca <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f01065ca:	55                   	push   %ebp
f01065cb:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01065cd:	a1 04 10 26 f0       	mov    0xf0261004,%eax
f01065d2:	85 c0                	test   %eax,%eax
f01065d4:	74 08                	je     f01065de <cpunum+0x14>
		return lapic[ID] >> 24;
f01065d6:	8b 40 20             	mov    0x20(%eax),%eax
f01065d9:	c1 e8 18             	shr    $0x18,%eax
f01065dc:	eb 05                	jmp    f01065e3 <cpunum+0x19>
	return 0;
f01065de:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01065e3:	5d                   	pop    %ebp
f01065e4:	c3                   	ret    

f01065e5 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f01065e5:	a1 00 10 26 f0       	mov    0xf0261000,%eax
f01065ea:	85 c0                	test   %eax,%eax
f01065ec:	0f 84 21 01 00 00    	je     f0106713 <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f01065f2:	55                   	push   %ebp
f01065f3:	89 e5                	mov    %esp,%ebp
f01065f5:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f01065f8:	68 00 10 00 00       	push   $0x1000
f01065fd:	50                   	push   %eax
f01065fe:	e8 31 ae ff ff       	call   f0101434 <mmio_map_region>
f0106603:	a3 04 10 26 f0       	mov    %eax,0xf0261004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106608:	ba 27 01 00 00       	mov    $0x127,%edx
f010660d:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106612:	e8 9b ff ff ff       	call   f01065b2 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0106617:	ba 0b 00 00 00       	mov    $0xb,%edx
f010661c:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106621:	e8 8c ff ff ff       	call   f01065b2 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106626:	ba 20 00 02 00       	mov    $0x20020,%edx
f010662b:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106630:	e8 7d ff ff ff       	call   f01065b2 <lapicw>
	lapicw(TICR, 10000000); 
f0106635:	ba 80 96 98 00       	mov    $0x989680,%edx
f010663a:	b8 e0 00 00 00       	mov    $0xe0,%eax
f010663f:	e8 6e ff ff ff       	call   f01065b2 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0106644:	e8 81 ff ff ff       	call   f01065ca <cpunum>
f0106649:	6b c0 74             	imul   $0x74,%eax,%eax
f010664c:	05 20 00 22 f0       	add    $0xf0220020,%eax
f0106651:	83 c4 10             	add    $0x10,%esp
f0106654:	39 05 c0 03 22 f0    	cmp    %eax,0xf02203c0
f010665a:	74 0f                	je     f010666b <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f010665c:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106661:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106666:	e8 47 ff ff ff       	call   f01065b2 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f010666b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106670:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106675:	e8 38 ff ff ff       	call   f01065b2 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f010667a:	a1 04 10 26 f0       	mov    0xf0261004,%eax
f010667f:	8b 40 30             	mov    0x30(%eax),%eax
f0106682:	c1 e8 10             	shr    $0x10,%eax
f0106685:	3c 03                	cmp    $0x3,%al
f0106687:	76 0f                	jbe    f0106698 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0106689:	ba 00 00 01 00       	mov    $0x10000,%edx
f010668e:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106693:	e8 1a ff ff ff       	call   f01065b2 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106698:	ba 33 00 00 00       	mov    $0x33,%edx
f010669d:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01066a2:	e8 0b ff ff ff       	call   f01065b2 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f01066a7:	ba 00 00 00 00       	mov    $0x0,%edx
f01066ac:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01066b1:	e8 fc fe ff ff       	call   f01065b2 <lapicw>
	lapicw(ESR, 0);
f01066b6:	ba 00 00 00 00       	mov    $0x0,%edx
f01066bb:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01066c0:	e8 ed fe ff ff       	call   f01065b2 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01066c5:	ba 00 00 00 00       	mov    $0x0,%edx
f01066ca:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01066cf:	e8 de fe ff ff       	call   f01065b2 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f01066d4:	ba 00 00 00 00       	mov    $0x0,%edx
f01066d9:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01066de:	e8 cf fe ff ff       	call   f01065b2 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01066e3:	ba 00 85 08 00       	mov    $0x88500,%edx
f01066e8:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01066ed:	e8 c0 fe ff ff       	call   f01065b2 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01066f2:	8b 15 04 10 26 f0    	mov    0xf0261004,%edx
f01066f8:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01066fe:	f6 c4 10             	test   $0x10,%ah
f0106701:	75 f5                	jne    f01066f8 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0106703:	ba 00 00 00 00       	mov    $0x0,%edx
f0106708:	b8 20 00 00 00       	mov    $0x20,%eax
f010670d:	e8 a0 fe ff ff       	call   f01065b2 <lapicw>
}
f0106712:	c9                   	leave  
f0106713:	f3 c3                	repz ret 

f0106715 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0106715:	83 3d 04 10 26 f0 00 	cmpl   $0x0,0xf0261004
f010671c:	74 13                	je     f0106731 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f010671e:	55                   	push   %ebp
f010671f:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0106721:	ba 00 00 00 00       	mov    $0x0,%edx
f0106726:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010672b:	e8 82 fe ff ff       	call   f01065b2 <lapicw>
}
f0106730:	5d                   	pop    %ebp
f0106731:	f3 c3                	repz ret 

f0106733 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106733:	55                   	push   %ebp
f0106734:	89 e5                	mov    %esp,%ebp
f0106736:	56                   	push   %esi
f0106737:	53                   	push   %ebx
f0106738:	8b 75 08             	mov    0x8(%ebp),%esi
f010673b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010673e:	ba 70 00 00 00       	mov    $0x70,%edx
f0106743:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106748:	ee                   	out    %al,(%dx)
f0106749:	ba 71 00 00 00       	mov    $0x71,%edx
f010674e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106753:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106754:	83 3d 88 fe 21 f0 00 	cmpl   $0x0,0xf021fe88
f010675b:	75 19                	jne    f0106776 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010675d:	68 67 04 00 00       	push   $0x467
f0106762:	68 84 6c 10 f0       	push   $0xf0106c84
f0106767:	68 98 00 00 00       	push   $0x98
f010676c:	68 b4 8a 10 f0       	push   $0xf0108ab4
f0106771:	e8 ca 98 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106776:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f010677d:	00 00 
	wrv[1] = addr >> 4;
f010677f:	89 d8                	mov    %ebx,%eax
f0106781:	c1 e8 04             	shr    $0x4,%eax
f0106784:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f010678a:	c1 e6 18             	shl    $0x18,%esi
f010678d:	89 f2                	mov    %esi,%edx
f010678f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106794:	e8 19 fe ff ff       	call   f01065b2 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106799:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010679e:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01067a3:	e8 0a fe ff ff       	call   f01065b2 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01067a8:	ba 00 85 00 00       	mov    $0x8500,%edx
f01067ad:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01067b2:	e8 fb fd ff ff       	call   f01065b2 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01067b7:	c1 eb 0c             	shr    $0xc,%ebx
f01067ba:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01067bd:	89 f2                	mov    %esi,%edx
f01067bf:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01067c4:	e8 e9 fd ff ff       	call   f01065b2 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01067c9:	89 da                	mov    %ebx,%edx
f01067cb:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01067d0:	e8 dd fd ff ff       	call   f01065b2 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01067d5:	89 f2                	mov    %esi,%edx
f01067d7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01067dc:	e8 d1 fd ff ff       	call   f01065b2 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01067e1:	89 da                	mov    %ebx,%edx
f01067e3:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01067e8:	e8 c5 fd ff ff       	call   f01065b2 <lapicw>
		microdelay(200);
	}
}
f01067ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01067f0:	5b                   	pop    %ebx
f01067f1:	5e                   	pop    %esi
f01067f2:	5d                   	pop    %ebp
f01067f3:	c3                   	ret    

f01067f4 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01067f4:	55                   	push   %ebp
f01067f5:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01067f7:	8b 55 08             	mov    0x8(%ebp),%edx
f01067fa:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106800:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106805:	e8 a8 fd ff ff       	call   f01065b2 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f010680a:	8b 15 04 10 26 f0    	mov    0xf0261004,%edx
f0106810:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106816:	f6 c4 10             	test   $0x10,%ah
f0106819:	75 f5                	jne    f0106810 <lapic_ipi+0x1c>
		;
}
f010681b:	5d                   	pop    %ebp
f010681c:	c3                   	ret    

f010681d <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f010681d:	55                   	push   %ebp
f010681e:	89 e5                	mov    %esp,%ebp
f0106820:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106823:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106829:	8b 55 0c             	mov    0xc(%ebp),%edx
f010682c:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010682f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106836:	5d                   	pop    %ebp
f0106837:	c3                   	ret    

f0106838 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106838:	55                   	push   %ebp
f0106839:	89 e5                	mov    %esp,%ebp
f010683b:	56                   	push   %esi
f010683c:	53                   	push   %ebx
f010683d:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106840:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106843:	74 14                	je     f0106859 <spin_lock+0x21>
f0106845:	8b 73 08             	mov    0x8(%ebx),%esi
f0106848:	e8 7d fd ff ff       	call   f01065ca <cpunum>
f010684d:	6b c0 74             	imul   $0x74,%eax,%eax
f0106850:	05 20 00 22 f0       	add    $0xf0220020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106855:	39 c6                	cmp    %eax,%esi
f0106857:	74 07                	je     f0106860 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0106859:	ba 01 00 00 00       	mov    $0x1,%edx
f010685e:	eb 20                	jmp    f0106880 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106860:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106863:	e8 62 fd ff ff       	call   f01065ca <cpunum>
f0106868:	83 ec 0c             	sub    $0xc,%esp
f010686b:	53                   	push   %ebx
f010686c:	50                   	push   %eax
f010686d:	68 c4 8a 10 f0       	push   $0xf0108ac4
f0106872:	6a 42                	push   $0x42
f0106874:	68 28 8b 10 f0       	push   $0xf0108b28
f0106879:	e8 c2 97 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f010687e:	f3 90                	pause  
f0106880:	89 d0                	mov    %edx,%eax
f0106882:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106885:	85 c0                	test   %eax,%eax
f0106887:	75 f5                	jne    f010687e <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106889:	e8 3c fd ff ff       	call   f01065ca <cpunum>
f010688e:	6b c0 74             	imul   $0x74,%eax,%eax
f0106891:	05 20 00 22 f0       	add    $0xf0220020,%eax
f0106896:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106899:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010689c:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f010689e:	b8 00 00 00 00       	mov    $0x0,%eax
f01068a3:	eb 0b                	jmp    f01068b0 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f01068a5:	8b 4a 04             	mov    0x4(%edx),%ecx
f01068a8:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01068ab:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01068ad:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01068b0:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01068b6:	76 11                	jbe    f01068c9 <spin_lock+0x91>
f01068b8:	83 f8 09             	cmp    $0x9,%eax
f01068bb:	7e e8                	jle    f01068a5 <spin_lock+0x6d>
f01068bd:	eb 0a                	jmp    f01068c9 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f01068bf:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01068c6:	83 c0 01             	add    $0x1,%eax
f01068c9:	83 f8 09             	cmp    $0x9,%eax
f01068cc:	7e f1                	jle    f01068bf <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f01068ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01068d1:	5b                   	pop    %ebx
f01068d2:	5e                   	pop    %esi
f01068d3:	5d                   	pop    %ebp
f01068d4:	c3                   	ret    

f01068d5 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01068d5:	55                   	push   %ebp
f01068d6:	89 e5                	mov    %esp,%ebp
f01068d8:	57                   	push   %edi
f01068d9:	56                   	push   %esi
f01068da:	53                   	push   %ebx
f01068db:	83 ec 4c             	sub    $0x4c,%esp
f01068de:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f01068e1:	83 3e 00             	cmpl   $0x0,(%esi)
f01068e4:	74 18                	je     f01068fe <spin_unlock+0x29>
f01068e6:	8b 5e 08             	mov    0x8(%esi),%ebx
f01068e9:	e8 dc fc ff ff       	call   f01065ca <cpunum>
f01068ee:	6b c0 74             	imul   $0x74,%eax,%eax
f01068f1:	05 20 00 22 f0       	add    $0xf0220020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01068f6:	39 c3                	cmp    %eax,%ebx
f01068f8:	0f 84 a5 00 00 00    	je     f01069a3 <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01068fe:	83 ec 04             	sub    $0x4,%esp
f0106901:	6a 28                	push   $0x28
f0106903:	8d 46 0c             	lea    0xc(%esi),%eax
f0106906:	50                   	push   %eax
f0106907:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f010690a:	53                   	push   %ebx
f010690b:	e8 e4 f6 ff ff       	call   f0105ff4 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106910:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106913:	0f b6 38             	movzbl (%eax),%edi
f0106916:	8b 76 04             	mov    0x4(%esi),%esi
f0106919:	e8 ac fc ff ff       	call   f01065ca <cpunum>
f010691e:	57                   	push   %edi
f010691f:	56                   	push   %esi
f0106920:	50                   	push   %eax
f0106921:	68 f0 8a 10 f0       	push   $0xf0108af0
f0106926:	e8 b5 d4 ff ff       	call   f0103de0 <cprintf>
f010692b:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010692e:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0106931:	eb 54                	jmp    f0106987 <spin_unlock+0xb2>
f0106933:	83 ec 08             	sub    $0x8,%esp
f0106936:	57                   	push   %edi
f0106937:	50                   	push   %eax
f0106938:	e8 82 ec ff ff       	call   f01055bf <debuginfo_eip>
f010693d:	83 c4 10             	add    $0x10,%esp
f0106940:	85 c0                	test   %eax,%eax
f0106942:	78 27                	js     f010696b <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106944:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106946:	83 ec 04             	sub    $0x4,%esp
f0106949:	89 c2                	mov    %eax,%edx
f010694b:	2b 55 b8             	sub    -0x48(%ebp),%edx
f010694e:	52                   	push   %edx
f010694f:	ff 75 b0             	pushl  -0x50(%ebp)
f0106952:	ff 75 b4             	pushl  -0x4c(%ebp)
f0106955:	ff 75 ac             	pushl  -0x54(%ebp)
f0106958:	ff 75 a8             	pushl  -0x58(%ebp)
f010695b:	50                   	push   %eax
f010695c:	68 38 8b 10 f0       	push   $0xf0108b38
f0106961:	e8 7a d4 ff ff       	call   f0103de0 <cprintf>
f0106966:	83 c4 20             	add    $0x20,%esp
f0106969:	eb 12                	jmp    f010697d <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f010696b:	83 ec 08             	sub    $0x8,%esp
f010696e:	ff 36                	pushl  (%esi)
f0106970:	68 4f 8b 10 f0       	push   $0xf0108b4f
f0106975:	e8 66 d4 ff ff       	call   f0103de0 <cprintf>
f010697a:	83 c4 10             	add    $0x10,%esp
f010697d:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106980:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106983:	39 c3                	cmp    %eax,%ebx
f0106985:	74 08                	je     f010698f <spin_unlock+0xba>
f0106987:	89 de                	mov    %ebx,%esi
f0106989:	8b 03                	mov    (%ebx),%eax
f010698b:	85 c0                	test   %eax,%eax
f010698d:	75 a4                	jne    f0106933 <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f010698f:	83 ec 04             	sub    $0x4,%esp
f0106992:	68 57 8b 10 f0       	push   $0xf0108b57
f0106997:	6a 68                	push   $0x68
f0106999:	68 28 8b 10 f0       	push   $0xf0108b28
f010699e:	e8 9d 96 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f01069a3:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f01069aa:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01069b1:	b8 00 00 00 00       	mov    $0x0,%eax
f01069b6:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f01069b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01069bc:	5b                   	pop    %ebx
f01069bd:	5e                   	pop    %esi
f01069be:	5f                   	pop    %edi
f01069bf:	5d                   	pop    %ebp
f01069c0:	c3                   	ret    
f01069c1:	66 90                	xchg   %ax,%ax
f01069c3:	66 90                	xchg   %ax,%ax
f01069c5:	66 90                	xchg   %ax,%ax
f01069c7:	66 90                	xchg   %ax,%ax
f01069c9:	66 90                	xchg   %ax,%ax
f01069cb:	66 90                	xchg   %ax,%ax
f01069cd:	66 90                	xchg   %ax,%ax
f01069cf:	90                   	nop

f01069d0 <__udivdi3>:
f01069d0:	55                   	push   %ebp
f01069d1:	57                   	push   %edi
f01069d2:	56                   	push   %esi
f01069d3:	53                   	push   %ebx
f01069d4:	83 ec 1c             	sub    $0x1c,%esp
f01069d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01069db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01069df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01069e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01069e7:	85 f6                	test   %esi,%esi
f01069e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01069ed:	89 ca                	mov    %ecx,%edx
f01069ef:	89 f8                	mov    %edi,%eax
f01069f1:	75 3d                	jne    f0106a30 <__udivdi3+0x60>
f01069f3:	39 cf                	cmp    %ecx,%edi
f01069f5:	0f 87 c5 00 00 00    	ja     f0106ac0 <__udivdi3+0xf0>
f01069fb:	85 ff                	test   %edi,%edi
f01069fd:	89 fd                	mov    %edi,%ebp
f01069ff:	75 0b                	jne    f0106a0c <__udivdi3+0x3c>
f0106a01:	b8 01 00 00 00       	mov    $0x1,%eax
f0106a06:	31 d2                	xor    %edx,%edx
f0106a08:	f7 f7                	div    %edi
f0106a0a:	89 c5                	mov    %eax,%ebp
f0106a0c:	89 c8                	mov    %ecx,%eax
f0106a0e:	31 d2                	xor    %edx,%edx
f0106a10:	f7 f5                	div    %ebp
f0106a12:	89 c1                	mov    %eax,%ecx
f0106a14:	89 d8                	mov    %ebx,%eax
f0106a16:	89 cf                	mov    %ecx,%edi
f0106a18:	f7 f5                	div    %ebp
f0106a1a:	89 c3                	mov    %eax,%ebx
f0106a1c:	89 d8                	mov    %ebx,%eax
f0106a1e:	89 fa                	mov    %edi,%edx
f0106a20:	83 c4 1c             	add    $0x1c,%esp
f0106a23:	5b                   	pop    %ebx
f0106a24:	5e                   	pop    %esi
f0106a25:	5f                   	pop    %edi
f0106a26:	5d                   	pop    %ebp
f0106a27:	c3                   	ret    
f0106a28:	90                   	nop
f0106a29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106a30:	39 ce                	cmp    %ecx,%esi
f0106a32:	77 74                	ja     f0106aa8 <__udivdi3+0xd8>
f0106a34:	0f bd fe             	bsr    %esi,%edi
f0106a37:	83 f7 1f             	xor    $0x1f,%edi
f0106a3a:	0f 84 98 00 00 00    	je     f0106ad8 <__udivdi3+0x108>
f0106a40:	bb 20 00 00 00       	mov    $0x20,%ebx
f0106a45:	89 f9                	mov    %edi,%ecx
f0106a47:	89 c5                	mov    %eax,%ebp
f0106a49:	29 fb                	sub    %edi,%ebx
f0106a4b:	d3 e6                	shl    %cl,%esi
f0106a4d:	89 d9                	mov    %ebx,%ecx
f0106a4f:	d3 ed                	shr    %cl,%ebp
f0106a51:	89 f9                	mov    %edi,%ecx
f0106a53:	d3 e0                	shl    %cl,%eax
f0106a55:	09 ee                	or     %ebp,%esi
f0106a57:	89 d9                	mov    %ebx,%ecx
f0106a59:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106a5d:	89 d5                	mov    %edx,%ebp
f0106a5f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106a63:	d3 ed                	shr    %cl,%ebp
f0106a65:	89 f9                	mov    %edi,%ecx
f0106a67:	d3 e2                	shl    %cl,%edx
f0106a69:	89 d9                	mov    %ebx,%ecx
f0106a6b:	d3 e8                	shr    %cl,%eax
f0106a6d:	09 c2                	or     %eax,%edx
f0106a6f:	89 d0                	mov    %edx,%eax
f0106a71:	89 ea                	mov    %ebp,%edx
f0106a73:	f7 f6                	div    %esi
f0106a75:	89 d5                	mov    %edx,%ebp
f0106a77:	89 c3                	mov    %eax,%ebx
f0106a79:	f7 64 24 0c          	mull   0xc(%esp)
f0106a7d:	39 d5                	cmp    %edx,%ebp
f0106a7f:	72 10                	jb     f0106a91 <__udivdi3+0xc1>
f0106a81:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106a85:	89 f9                	mov    %edi,%ecx
f0106a87:	d3 e6                	shl    %cl,%esi
f0106a89:	39 c6                	cmp    %eax,%esi
f0106a8b:	73 07                	jae    f0106a94 <__udivdi3+0xc4>
f0106a8d:	39 d5                	cmp    %edx,%ebp
f0106a8f:	75 03                	jne    f0106a94 <__udivdi3+0xc4>
f0106a91:	83 eb 01             	sub    $0x1,%ebx
f0106a94:	31 ff                	xor    %edi,%edi
f0106a96:	89 d8                	mov    %ebx,%eax
f0106a98:	89 fa                	mov    %edi,%edx
f0106a9a:	83 c4 1c             	add    $0x1c,%esp
f0106a9d:	5b                   	pop    %ebx
f0106a9e:	5e                   	pop    %esi
f0106a9f:	5f                   	pop    %edi
f0106aa0:	5d                   	pop    %ebp
f0106aa1:	c3                   	ret    
f0106aa2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106aa8:	31 ff                	xor    %edi,%edi
f0106aaa:	31 db                	xor    %ebx,%ebx
f0106aac:	89 d8                	mov    %ebx,%eax
f0106aae:	89 fa                	mov    %edi,%edx
f0106ab0:	83 c4 1c             	add    $0x1c,%esp
f0106ab3:	5b                   	pop    %ebx
f0106ab4:	5e                   	pop    %esi
f0106ab5:	5f                   	pop    %edi
f0106ab6:	5d                   	pop    %ebp
f0106ab7:	c3                   	ret    
f0106ab8:	90                   	nop
f0106ab9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106ac0:	89 d8                	mov    %ebx,%eax
f0106ac2:	f7 f7                	div    %edi
f0106ac4:	31 ff                	xor    %edi,%edi
f0106ac6:	89 c3                	mov    %eax,%ebx
f0106ac8:	89 d8                	mov    %ebx,%eax
f0106aca:	89 fa                	mov    %edi,%edx
f0106acc:	83 c4 1c             	add    $0x1c,%esp
f0106acf:	5b                   	pop    %ebx
f0106ad0:	5e                   	pop    %esi
f0106ad1:	5f                   	pop    %edi
f0106ad2:	5d                   	pop    %ebp
f0106ad3:	c3                   	ret    
f0106ad4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106ad8:	39 ce                	cmp    %ecx,%esi
f0106ada:	72 0c                	jb     f0106ae8 <__udivdi3+0x118>
f0106adc:	31 db                	xor    %ebx,%ebx
f0106ade:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0106ae2:	0f 87 34 ff ff ff    	ja     f0106a1c <__udivdi3+0x4c>
f0106ae8:	bb 01 00 00 00       	mov    $0x1,%ebx
f0106aed:	e9 2a ff ff ff       	jmp    f0106a1c <__udivdi3+0x4c>
f0106af2:	66 90                	xchg   %ax,%ax
f0106af4:	66 90                	xchg   %ax,%ax
f0106af6:	66 90                	xchg   %ax,%ax
f0106af8:	66 90                	xchg   %ax,%ax
f0106afa:	66 90                	xchg   %ax,%ax
f0106afc:	66 90                	xchg   %ax,%ax
f0106afe:	66 90                	xchg   %ax,%ax

f0106b00 <__umoddi3>:
f0106b00:	55                   	push   %ebp
f0106b01:	57                   	push   %edi
f0106b02:	56                   	push   %esi
f0106b03:	53                   	push   %ebx
f0106b04:	83 ec 1c             	sub    $0x1c,%esp
f0106b07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0106b0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0106b0f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106b13:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106b17:	85 d2                	test   %edx,%edx
f0106b19:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0106b1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106b21:	89 f3                	mov    %esi,%ebx
f0106b23:	89 3c 24             	mov    %edi,(%esp)
f0106b26:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106b2a:	75 1c                	jne    f0106b48 <__umoddi3+0x48>
f0106b2c:	39 f7                	cmp    %esi,%edi
f0106b2e:	76 50                	jbe    f0106b80 <__umoddi3+0x80>
f0106b30:	89 c8                	mov    %ecx,%eax
f0106b32:	89 f2                	mov    %esi,%edx
f0106b34:	f7 f7                	div    %edi
f0106b36:	89 d0                	mov    %edx,%eax
f0106b38:	31 d2                	xor    %edx,%edx
f0106b3a:	83 c4 1c             	add    $0x1c,%esp
f0106b3d:	5b                   	pop    %ebx
f0106b3e:	5e                   	pop    %esi
f0106b3f:	5f                   	pop    %edi
f0106b40:	5d                   	pop    %ebp
f0106b41:	c3                   	ret    
f0106b42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106b48:	39 f2                	cmp    %esi,%edx
f0106b4a:	89 d0                	mov    %edx,%eax
f0106b4c:	77 52                	ja     f0106ba0 <__umoddi3+0xa0>
f0106b4e:	0f bd ea             	bsr    %edx,%ebp
f0106b51:	83 f5 1f             	xor    $0x1f,%ebp
f0106b54:	75 5a                	jne    f0106bb0 <__umoddi3+0xb0>
f0106b56:	3b 54 24 04          	cmp    0x4(%esp),%edx
f0106b5a:	0f 82 e0 00 00 00    	jb     f0106c40 <__umoddi3+0x140>
f0106b60:	39 0c 24             	cmp    %ecx,(%esp)
f0106b63:	0f 86 d7 00 00 00    	jbe    f0106c40 <__umoddi3+0x140>
f0106b69:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106b6d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106b71:	83 c4 1c             	add    $0x1c,%esp
f0106b74:	5b                   	pop    %ebx
f0106b75:	5e                   	pop    %esi
f0106b76:	5f                   	pop    %edi
f0106b77:	5d                   	pop    %ebp
f0106b78:	c3                   	ret    
f0106b79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106b80:	85 ff                	test   %edi,%edi
f0106b82:	89 fd                	mov    %edi,%ebp
f0106b84:	75 0b                	jne    f0106b91 <__umoddi3+0x91>
f0106b86:	b8 01 00 00 00       	mov    $0x1,%eax
f0106b8b:	31 d2                	xor    %edx,%edx
f0106b8d:	f7 f7                	div    %edi
f0106b8f:	89 c5                	mov    %eax,%ebp
f0106b91:	89 f0                	mov    %esi,%eax
f0106b93:	31 d2                	xor    %edx,%edx
f0106b95:	f7 f5                	div    %ebp
f0106b97:	89 c8                	mov    %ecx,%eax
f0106b99:	f7 f5                	div    %ebp
f0106b9b:	89 d0                	mov    %edx,%eax
f0106b9d:	eb 99                	jmp    f0106b38 <__umoddi3+0x38>
f0106b9f:	90                   	nop
f0106ba0:	89 c8                	mov    %ecx,%eax
f0106ba2:	89 f2                	mov    %esi,%edx
f0106ba4:	83 c4 1c             	add    $0x1c,%esp
f0106ba7:	5b                   	pop    %ebx
f0106ba8:	5e                   	pop    %esi
f0106ba9:	5f                   	pop    %edi
f0106baa:	5d                   	pop    %ebp
f0106bab:	c3                   	ret    
f0106bac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106bb0:	8b 34 24             	mov    (%esp),%esi
f0106bb3:	bf 20 00 00 00       	mov    $0x20,%edi
f0106bb8:	89 e9                	mov    %ebp,%ecx
f0106bba:	29 ef                	sub    %ebp,%edi
f0106bbc:	d3 e0                	shl    %cl,%eax
f0106bbe:	89 f9                	mov    %edi,%ecx
f0106bc0:	89 f2                	mov    %esi,%edx
f0106bc2:	d3 ea                	shr    %cl,%edx
f0106bc4:	89 e9                	mov    %ebp,%ecx
f0106bc6:	09 c2                	or     %eax,%edx
f0106bc8:	89 d8                	mov    %ebx,%eax
f0106bca:	89 14 24             	mov    %edx,(%esp)
f0106bcd:	89 f2                	mov    %esi,%edx
f0106bcf:	d3 e2                	shl    %cl,%edx
f0106bd1:	89 f9                	mov    %edi,%ecx
f0106bd3:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106bd7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0106bdb:	d3 e8                	shr    %cl,%eax
f0106bdd:	89 e9                	mov    %ebp,%ecx
f0106bdf:	89 c6                	mov    %eax,%esi
f0106be1:	d3 e3                	shl    %cl,%ebx
f0106be3:	89 f9                	mov    %edi,%ecx
f0106be5:	89 d0                	mov    %edx,%eax
f0106be7:	d3 e8                	shr    %cl,%eax
f0106be9:	89 e9                	mov    %ebp,%ecx
f0106beb:	09 d8                	or     %ebx,%eax
f0106bed:	89 d3                	mov    %edx,%ebx
f0106bef:	89 f2                	mov    %esi,%edx
f0106bf1:	f7 34 24             	divl   (%esp)
f0106bf4:	89 d6                	mov    %edx,%esi
f0106bf6:	d3 e3                	shl    %cl,%ebx
f0106bf8:	f7 64 24 04          	mull   0x4(%esp)
f0106bfc:	39 d6                	cmp    %edx,%esi
f0106bfe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106c02:	89 d1                	mov    %edx,%ecx
f0106c04:	89 c3                	mov    %eax,%ebx
f0106c06:	72 08                	jb     f0106c10 <__umoddi3+0x110>
f0106c08:	75 11                	jne    f0106c1b <__umoddi3+0x11b>
f0106c0a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0106c0e:	73 0b                	jae    f0106c1b <__umoddi3+0x11b>
f0106c10:	2b 44 24 04          	sub    0x4(%esp),%eax
f0106c14:	1b 14 24             	sbb    (%esp),%edx
f0106c17:	89 d1                	mov    %edx,%ecx
f0106c19:	89 c3                	mov    %eax,%ebx
f0106c1b:	8b 54 24 08          	mov    0x8(%esp),%edx
f0106c1f:	29 da                	sub    %ebx,%edx
f0106c21:	19 ce                	sbb    %ecx,%esi
f0106c23:	89 f9                	mov    %edi,%ecx
f0106c25:	89 f0                	mov    %esi,%eax
f0106c27:	d3 e0                	shl    %cl,%eax
f0106c29:	89 e9                	mov    %ebp,%ecx
f0106c2b:	d3 ea                	shr    %cl,%edx
f0106c2d:	89 e9                	mov    %ebp,%ecx
f0106c2f:	d3 ee                	shr    %cl,%esi
f0106c31:	09 d0                	or     %edx,%eax
f0106c33:	89 f2                	mov    %esi,%edx
f0106c35:	83 c4 1c             	add    $0x1c,%esp
f0106c38:	5b                   	pop    %ebx
f0106c39:	5e                   	pop    %esi
f0106c3a:	5f                   	pop    %edi
f0106c3b:	5d                   	pop    %ebp
f0106c3c:	c3                   	ret    
f0106c3d:	8d 76 00             	lea    0x0(%esi),%esi
f0106c40:	29 f9                	sub    %edi,%ecx
f0106c42:	19 d6                	sbb    %edx,%esi
f0106c44:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106c48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106c4c:	e9 18 ff ff ff       	jmp    f0106b69 <__umoddi3+0x69>
